module rebel.renderer.internal.vk.commandbuffer;

import rebel.renderer;
import erupted;
import rebel.engine;

import rebel.renderer.internal.vk;

import gfm.math.vector;
import std.typecons;

final class RecordingSectionScope : IRecordingSectionScope {
public:
	VKCommandBufferData* cbData;

	this(string name, vec4f color) {
		import std.string : toStringz;

		VkDebugUtilsLabelEXT label;
		label.pLabelName = name.toStringz;
		label.color[] = color[];
		vkCmdBeginDebugUtilsLabelEXT(cbData.commandBuffer, &label);
	}

	~this() {
		vkCmdEndDebugUtilsLabelEXT(cbData.commandBuffer);
	}

final override:
	void defineSubsection(string name, vec4f color) {
		import std.string : toStringz;

		VkDebugUtilsLabelEXT label;
		label.pLabelName = name.toStringz;
		label.color[] = color[];
		vkCmdInsertDebugUtilsLabelEXT(cbData.commandBuffer, &label);
	}
}

final class CommandBufferRecordingState : ICommandBufferRecordingState {
public:
	VKCommandBufferData* cbData;

final override:
	@property void index(size_t index) {
		cbData.index = index;
	}

	@property void renderPass(RenderPass renderPass) {
		cbData.renderPass = renderPass;
	}

	@property void pipeline(Pipeline pipeline) {
		cbData.pipeline = pipeline;
	}

	@property void framebuffer(Framebuffer framebuffer) {
		cbData.framebuffer = framebuffer;
	}

	@property void renderArea(vec4ui renderArea) {
		cbData.renderArea = renderArea;
	}

	@property void clearColors(vec4f[] clearColors) {
		cbData.clearColors = clearColors;
	}

	void finalizeState() {
		VkRenderPass rp;
		{
			scope RenderPass.Ref rpRef = cbData.renderer.get(cbData.renderPass);
			rp = rpRef.get!VKRenderPassData().renderPass;
		}
		VkFramebuffer fb;
		{
			scope Framebuffer.Ref fbRef = cbData.renderer.get(cbData.framebuffer);
			fb = fbRef.get!VKFramebufferData().framebuffer;
		}
		VkClearValue[] clearValues;
		clearValues.length = cbData.clearColors.length;
		foreach (i, vec4f color; cbData.clearColors)
			clearValues[i].color = VkClearColorValue([color.r, color.g, color.b, color.a]);

		VkRenderPassBeginInfo info;
		info.renderPass = rp;
		info.framebuffer = fb;
		info.renderArea = VkRect2D(VkOffset2D(cbData.renderArea.x, cbData.renderArea.y), VkExtent2D(cbData.renderArea.z, cbData.renderArea.w));
		info.pClearValues = clearValues.ptr;
		info.clearValueCount = cast(uint)clearValues.length;

		cbData.device.dispatch.vkCmdBeginRenderPass(cbData.commandBuffer, &info, VkSubpassContents.VK_SUBPASS_CONTENTS_INLINE);

		VKPipelineData* p;
		{
			scope Pipeline.Ref pRef = cbData.renderer.get(cbData.pipeline);
			p = pRef.get!VKPipelineData();
		}

		cbData.device.dispatch.vkCmdBindPipeline(cbData.commandBuffer, VkPipelineBindPoint.VK_PIPELINE_BIND_POINT_GRAPHICS, p.pipeline);
	}

	scope IRecordingSectionScope defineSectionScope(string name, vec4f color) {
		//TODO: Add pool allocator
		return new RecordingSectionScope(name, color);
	}

	void bindVertexBuffer(uint firstBinding, BufferOffset[] buffers) {
		import std.range : Chunks, chunks;

		foreach (chunk; buffers.chunks(32)) {
			VkBuffer[32] buf = void;
			VkDeviceSize[32] off = void;

			foreach (idx, buffer; chunk) {
				scope Buffer.Ref bufferRef = cbData.renderer.get(buffer.buffer);
				VKBufferData* data = bufferRef.get!VKBufferData;

				buf[idx] = data.buffer;
				off[idx] = buffer.offset;
			}

			cbData.device.dispatch.vkCmdBindVertexBuffers(cbData.commandBuffer, firstBinding, cast(uint)chunk.length, buf.ptr, off.ptr);
			firstBinding += chunk.length;
		}
	}

	void bindIndexBuffer(BufferOffset buffer, IndexType type) {
		scope Buffer.Ref bufferRef = cbData.renderer.get(buffer.buffer);
		VKBufferData* data = bufferRef.get!VKBufferData;

		cbData.device.dispatch.vkCmdBindIndexBuffer(cbData.commandBuffer, data.buffer, buffer.offset, type.translate);
	}

	void draw(uint vertexCount, uint instanceCount, uint firstVertex, uint firstInstance) {
		VKPipelineData* p;
		{
			scope Pipeline.Ref pRef = cbData.renderer.get(cbData.pipeline);
			p = pRef.get!VKPipelineData();
		}
		cbData.device.dispatch.vkCmdBindDescriptorSets(cbData.commandBuffer, VK_PIPELINE_BIND_POINT_GRAPHICS,
				p.pipelineLayout, 0, 1, &p.descriptorSets[cbData.index], 0, null);
		cbData.device.dispatch.vkCmdDraw(cbData.commandBuffer, vertexCount, instanceCount, firstVertex, firstInstance);
	}

	void drawIndexed(uint indexCount, uint instanceCount, uint firstIndex, uint vertexOffset, uint firstInstance) {
		VKPipelineData* p;
		{
			scope Pipeline.Ref pRef = cbData.renderer.get(cbData.pipeline);
			p = pRef.get!VKPipelineData();
		}
		cbData.device.dispatch.vkCmdBindDescriptorSets(cbData.commandBuffer, VK_PIPELINE_BIND_POINT_GRAPHICS,
				p.pipelineLayout, 0, 1, &p.descriptorSets[cbData.index], 0, null);
		cbData.device.dispatch.vkCmdDrawIndexed(cbData.commandBuffer, indexCount, instanceCount, firstIndex, vertexOffset, firstInstance);
	}
}

struct VKCommandBufferData {
	CommandBufferData base;
	alias base this;

	CommandBufferBuilder builder;
	VKDevice* device;

	typeof(scoped!CommandBufferRecordingState()) recordingState = void; //TODO: Fix this hack, if possible

	IRenderer renderer;
	VkCommandPool pool;
	VkCommandBuffer commandBuffer;

	size_t index;
	RenderPass renderPass;
	Pipeline pipeline;
	Framebuffer framebuffer;
	vec4ui renderArea;
	vec4f[] clearColors;

	this(const ref CommandBufferBuilder builder, VKDevice* device) {
		this.builder = builder;
		this.device = device;
		renderer = Engine.instance.renderer;

		pool = builder.willChangeEachFrame ? device.changeEachFrameCommandPool : device.defaultCommandPool;
		recordingState = scoped!CommandBufferRecordingState();

		VkCommandBufferAllocateInfo info;
		info.commandPool = pool;
		info.level = VkCommandBufferLevel.VK_COMMAND_BUFFER_LEVEL_PRIMARY; //TODO: allow secondary
		info.commandBufferCount = 1;

		vkAssert(device.dispatch.AllocateCommandBuffers(&info, &commandBuffer));

		create();
	}

	void create() {
		VkCommandBufferBeginInfo beginInfo;
		beginInfo.flags = VkCommandBufferUsageFlagBits.VK_COMMAND_BUFFER_USAGE_SIMULTANEOUS_USE_BIT;
		vkAssert(device.dispatch.vkBeginCommandBuffer(commandBuffer, &beginInfo));

		setVkObjectName(device, VK_OBJECT_TYPE_COMMAND_BUFFER, commandBuffer, builder.name);

		recordingState.cbData = &this;
		builder.callback(recordingState);

		device.dispatch.vkCmdEndRenderPass(commandBuffer);
		vkAssert(device.dispatch.vkEndCommandBuffer(commandBuffer));
	}

	~this() {
		if (!device)
			return;
		cleanup();
		device.dispatch.FreeCommandBuffers(pool, 1, &commandBuffer);
		device = null;
	}

	void cleanup() {
	}
}

static assert(isCorrectVulkanData!VKCommandBufferData);
