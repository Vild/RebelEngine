module rebel.renderer.internal.vk.commandbuffer;

import rebel.renderer;
import erupted;
import rebel.engine;

import rebel.renderer.internal.vk;

import dlsl.vector;
import std.typecons;

final class CommandBufferRecordingState : ICommandBufferRecordingState {
public:
	VKCommandBufferData* cb;
	this(VKCommandBufferData* cb) {
		this.cb = cb;
	}

final override:
	@property void renderPass(RenderPass renderPass) {
		cb.renderPass = renderPass;
	}

	@property void pipeline(Pipeline pipeline) {
		cb.pipeline = pipeline;
	}

	@property void framebuffer(Framebuffer framebuffer) {
		cb.framebuffer = framebuffer;
	}

	@property void renderArea(uvec4 renderArea) {
		cb.renderArea = renderArea;
	}

	@property void clearColors(vec4[] clearColors) {
		cb.clearColors = clearColors;
	}

	void finalizeState() {
		VkRenderPass rp;
		{
			scope RenderPass.Ref rpRef = cb.renderer.get(cb.renderPass);
			rp = rpRef.get!VKRenderPassData().renderPass;
		}
		VkFramebuffer fb;
		{
			scope Framebuffer.Ref fbRef = cb.renderer.get(cb.framebuffer);
			fb = fbRef.get!VKFramebufferData().framebuffer;
		}
		VkClearValue[] clearValues;
		clearValues.length = cb.clearColors.length;
		foreach (i, vec4 color; cb.clearColors)
			clearValues[i].color = VkClearColorValue([color.r, color.g, color.b, color.a]);

		VkRenderPassBeginInfo info;
		info.renderPass = rp;
		info.framebuffer = fb;
		info.renderArea = VkRect2D(VkOffset2D(cb.renderArea.x, cb.renderArea.y), VkExtent2D(cb.renderArea.z, cb.renderArea.w));
		info.pClearValues = clearValues.ptr;
		info.clearValueCount = cast(uint)clearValues.length;

		cb.device.dispatch.vkCmdBeginRenderPass(cb.commandBuffer, &info, VkSubpassContents.VK_SUBPASS_CONTENTS_INLINE);

		VkPipeline p;
		{
			scope Pipeline.Ref pRef = cb.renderer.get(cb.pipeline);
			p = pRef.get!VKPipelineData().pipeline;
		}

		cb.device.dispatch.vkCmdBindPipeline(cb.commandBuffer, VkPipelineBindPoint.VK_PIPELINE_BIND_POINT_GRAPHICS, p);
	}

	void draw(uint vertexCount, uint instanceCount, uint firstVertex, uint firstInstance) {
		cb.device.dispatch.vkCmdDraw(cb.commandBuffer, vertexCount, instanceCount, firstVertex, firstInstance);
	}
}

struct VKCommandBufferData {
	CommandBufferData base;
	alias base this;

	CommandBufferBuilder builder;
	VKDevice* device;

	typeof(scoped!CommandBufferRecordingState(null)) recordingState = void; //TODO: Fix this hack, if possible

	IRenderer renderer;
	VkCommandPool pool;
	VkCommandBuffer commandBuffer;

	RenderPass renderPass;
	Pipeline pipeline;
	Framebuffer framebuffer;
	uvec4 renderArea;
	vec4[] clearColors;

	this(const ref CommandBufferBuilder builder, VKDevice* device) {
		this.builder = builder;
		this.device = device;
		renderer = Engine.instance.renderer;

		pool = builder.willChangeEachFrame ? device.changeEachFrameCommandPool : device.defaultCommandPool;
		recordingState = scoped!CommandBufferRecordingState(&this);

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
