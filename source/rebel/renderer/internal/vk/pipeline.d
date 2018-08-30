module rebel.renderer.internal.vk.pipeline;

import rebel.renderer;
import erupted;
import rebel.engine;

import rebel.renderer.internal.vk.device;
import rebel.renderer.internal.vk.helper;
import rebel.renderer.internal.vk.translate;
import rebel.renderer.internal.vk.shadermodule;

struct VkPipelineData {
	PipelineData base;
	alias base this;

	Device* device;

	VkPipelineLayout pipelineLayout;
	VkPipeline graphicsPipeline;

	this(const ref PipelineBuilder builder, Device* device) {
		this.device = device;

		IRenderer renderer = Engine.instance.renderer;
		VkPipelineShaderStageCreateInfo[] shaderStages;

		foreach (ShaderModule m; builder.shaderStages) {
			scope ShaderModule.Ref shader = renderer.get(m);
			shaderStages ~= shader.get!VkShaderModuleData().stageInfo;
		}

		VkVertexInputBindingDescription[] vertexInputBindingDescriptions;
		vertexInputBindingDescriptions.length = builder.vertexInputBindingDescriptions.length;
		VkVertexInputAttributeDescription[] vertexInputAttributeDescriptions;
		vertexInputAttributeDescriptions.length = builder.vertexInputAttributeDescriptions.length;

		foreach (idx, const VertexInputBindingDescription bind; builder.vertexInputBindingDescriptions) {
			VkVertexInputBindingDescription* desc = &vertexInputBindingDescriptions[idx];
		}
		foreach (idx, const VertexInputAttributeDescription attr; builder.vertexInputAttributeDescriptions) {
			VkVertexInputAttributeDescription* desc = &vertexInputAttributeDescriptions[idx];
		}

		VkPipelineVertexInputStateCreateInfo vertexInputInfo;
		vertexInputInfo.pVertexBindingDescriptions = vertexInputBindingDescriptions.ptr;
		vertexInputInfo.vertexBindingDescriptionCount = cast(uint)vertexInputBindingDescriptions.length;
		vertexInputInfo.pVertexAttributeDescriptions = vertexInputAttributeDescriptions.ptr;
		vertexInputInfo.vertexAttributeDescriptionCount = cast(uint)vertexInputAttributeDescriptions.length;

		VkPipelineInputAssemblyStateCreateInfo inputAssembly;
		inputAssembly.topology = builder.vertexTopology.translate;
		inputAssembly.primitiveRestartEnable = VK_FALSE;

		VkViewport[] viewports;
		viewports.length = builder.viewports.length;

		foreach (idx, const Viewport vp; builder.viewports) {
			VkViewport* viewport = &viewports[idx];
			viewport.x = vp.position.x;
			viewport.y = vp.position.y;
			viewport.width = vp.size.x;
			viewport.height = vp.size.y;
			viewport.minDepth = vp.depthRange.x;
			viewport.maxDepth = vp.depthRange.y;
		}

		VkRect2D[] scissors;
		scissors.length = builder.scissors.length;

		foreach (idx, const Scissor st; builder.scissors) {
			VkRect2D* scissor = &scissors[idx];
			scissor.offset = VkOffset2D(st.start.x, st.start.y);
			scissor.extent = VkExtent2D(st.end.x, st.end.y);
		}

		VkPipelineViewportStateCreateInfo viewportState;
		viewportState.pViewports = viewports.ptr;
		viewportState.viewportCount = cast(uint)viewports.length;
		viewportState.pScissors = scissors.ptr;
		viewportState.scissorCount = cast(uint)scissors.length;

		VkPipelineRasterizationStateCreateInfo rasterizer;
		with (builder.rasterizationState) {
			rasterizer.depthClampEnable = depthClampEnable;
			rasterizer.rasterizerDiscardEnable = rasterizerDiscardEnable;
			rasterizer.polygonMode = polygonMode.translate;
			rasterizer.lineWidth = lineWidth;
			rasterizer.cullMode = cullMode.translate;
			rasterizer.frontFace = frontFace.translate;
			rasterizer.depthBiasEnable = depthBiasEnable;
		}

		VkPipelineMultisampleStateCreateInfo multisampling;
		multisampling.sampleShadingEnable = builder.multisamplingEnabled;
		multisampling.rasterizationSamples = builder.multisamplingCount.translate;

		VkPipelineColorBlendAttachmentState[] colorBlendAttachments;
		colorBlendAttachments.length = builder.blendState.attachments.length;
		foreach (idx, const BlendAttachment blendAttach; builder.blendState.attachments) {
			VkPipelineColorBlendAttachmentState* attach = &colorBlendAttachments[idx];
			attach.colorWriteMask = blendAttach.colorWriteMask.translate;
			attach.blendEnable = blendAttach.blendEnable;
		}

		VkPipelineColorBlendStateCreateInfo colorBlending;
		colorBlending.logicOpEnable = builder.blendState.logicOpEnable;
		colorBlending.logicOp = builder.blendState.logicOp.translate;
		colorBlending.pAttachments = colorBlendAttachments.ptr;
		colorBlending.attachmentCount = cast(uint)colorBlendAttachments.length;
		colorBlending.blendConstants[] = builder.blendState.blendConstants[];

		VkPipelineLayoutCreateInfo pipelineLayoutInfo;
		vkAssert(device.dispatch.CreatePipelineLayout(&pipelineLayoutInfo, &pipelineLayout));

		VkGraphicsPipelineCreateInfo pipelineInfo;
		pipelineInfo.pStages = shaderStages.ptr;
		pipelineInfo.stageCount = cast(uint)shaderStages.length;

		pipelineInfo.pVertexInputState = &vertexInputInfo;
		pipelineInfo.pInputAssemblyState = &inputAssembly;
		pipelineInfo.pViewportState = &viewportState;
		pipelineInfo.pRasterizationState = &rasterizer;
		pipelineInfo.pMultisampleState = &multisampling;
		pipelineInfo.pColorBlendState = &colorBlending;
		pipelineInfo.layout = pipelineLayout;

		{
			import rebel.renderer.internal.vk.renderpass;

			RenderPass.Ref renderpass = renderer.get(builder.renderpass);

			pipelineInfo.renderPass = renderpass.get!VkRenderPassData().renderPass;
		}
		pipelineInfo.subpass = 0;
		pipelineInfo.basePipelineHandle = VK_NULL_HANDLE;

		vkAssert(device.dispatch.CreateGraphicsPipelines(VK_NULL_HANDLE, 1, &pipelineInfo, &graphicsPipeline));
	}

	~this() {
		if (!device)
			return;
		device.dispatch.DestroyPipeline(graphicsPipeline);
		device.dispatch.DestroyPipelineLayout(pipelineLayout);
		device = null;
	}
}
