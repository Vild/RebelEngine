module rebel.renderer.internal.vk.pipeline;

import rebel.renderer;
import erupted;
import rebel.engine;

import rebel.renderer.internal.vk;

struct VKPipelineData {
	PipelineData base;
	alias base this;

	PipelineBuilder builder;
	VKDevice* device;

	VkDescriptorSetLayout descriptorSetLayout;
	VkPipelineLayout pipelineLayout;
	VkPipeline pipeline;

	VkDescriptorSet[] descriptorSets;

	this(ref PipelineBuilder builder, VKDevice* device) {
		this.builder = builder;
		this.device = device;
		create();
	}

	void create() {
		IRenderer renderer = Engine.instance.renderer;
		VkPipelineShaderStageCreateInfo[] shaderStages;

		foreach (ShaderModule m; builder.shaderStages) {
			scope ShaderModule.Ref shader = renderer.get(m);
			shaderStages ~= shader.get!VKShaderModuleData().stageInfo;
		}

		VkVertexInputBindingDescription[] vertexInputBindingDescriptions;
		vertexInputBindingDescriptions.length = builder.vertexInputBindingDescriptions.length;
		VkVertexInputAttributeDescription[] vertexInputAttributeDescriptions;
		vertexInputAttributeDescriptions.length = builder.vertexInputAttributeDescriptions.length;

		foreach (idx, const VertexInputBindingDescription bind; builder.vertexInputBindingDescriptions) {
			VkVertexInputBindingDescription* desc = &vertexInputBindingDescriptions[idx];
			desc.binding = bind.binding;
			desc.stride = bind.stride;
			desc.inputRate = bind.inputRate.translate;
		}
		foreach (idx, const VertexInputAttributeDescription attr; builder.vertexInputAttributeDescriptions) {
			VkVertexInputAttributeDescription* desc = &vertexInputAttributeDescriptions[idx];
			desc.location = attr.location;
			desc.binding = attr.binding;
			desc.format = attr.format.translate;
			desc.offset = attr.offset;
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
			rasterizer.depthBiasClamp = 0;
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

		VkDescriptorSetLayoutBinding[] descriptorSetLayoutBindings;
		descriptorSetLayoutBindings.length = builder.descriptorSetLayoutBindings.length;

		foreach (idx, const DescriptorSetLayoutBinding bind; builder.descriptorSetLayoutBindings) {
			VkDescriptorSetLayoutBinding* desc = &descriptorSetLayoutBindings[idx];
			desc.binding = bind.binding;
			desc.descriptorCount = bind.descriptorCount;
			desc.descriptorType = bind.descriptorType.translate;
			desc.stageFlags = bind.stages.translate;
			desc.pImmutableSamplers = cast(const(VkSampler)*)bind.immutableSamplers;
		}

		VkDescriptorSetLayoutCreateInfo layoutInfo;
		layoutInfo.bindingCount = cast(uint)descriptorSetLayoutBindings.length;
		layoutInfo.pBindings = descriptorSetLayoutBindings.ptr;

		vkAssert(device.dispatch.CreateDescriptorSetLayout(&layoutInfo, &descriptorSetLayout));
		setVkObjectName(device, VK_OBJECT_TYPE_DESCRIPTOR_SET_LAYOUT, descriptorSetLayout, builder.name);

		VkPipelineLayoutCreateInfo pipelineLayoutInfo;
		pipelineLayoutInfo.setLayoutCount = 1; //TODO: Multiple?
		pipelineLayoutInfo.pSetLayouts = &descriptorSetLayout;
		vkAssert(device.dispatch.CreatePipelineLayout(&pipelineLayoutInfo, &pipelineLayout));
		setVkObjectName(device, VK_OBJECT_TYPE_PIPELINE_LAYOUT, pipelineLayout, builder.name);

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

			scope RenderPass.Ref renderpass = renderer.get(builder.renderpass);

			pipelineInfo.renderPass = renderpass.get!VKRenderPassData().renderPass;
		}
		pipelineInfo.subpass = 0;
		pipelineInfo.basePipelineHandle = VK_NULL_HANDLE;

		vkAssert(device.dispatch.CreateGraphicsPipelines(VK_NULL_HANDLE, 1, &pipelineInfo, &pipeline));
		setVkObjectName(device, VK_OBJECT_TYPE_PIPELINE, pipeline, builder.name);

		////////

		VkDescriptorSetLayout[] layouts;
		layouts.length = device.swapChainImages.length;
		layouts[] = descriptorSetLayout;

		VkDescriptorSetAllocateInfo allocInfo;
		allocInfo.descriptorPool = device.descriptorPool;
		allocInfo.descriptorSetCount = cast(uint)device.swapChainImages.length;
		allocInfo.pSetLayouts = layouts.ptr;

		descriptorSets.length = device.swapChainImages.length;
		vkAssert(device.dispatch.AllocateDescriptorSets(&allocInfo, descriptorSets.ptr));

		assert(builder.descriptorBufferInfos.length == device.swapChainImages.length);
		VkDescriptorBufferInfo[] bufferInfos;
		bufferInfos.length = builder.descriptorBufferInfos.length;
		VkWriteDescriptorSet[] descriptorWrites;
		descriptorWrites.length = builder.descriptorBufferInfos.length;

		foreach (size_t i, DescriptorBufferInfo info; builder.descriptorBufferInfos) {
			VkDescriptorBufferInfo* bufferInfo = &bufferInfos[i];
			bufferInfo.buffer = renderer.get(info.buffer).get!VKBufferData().buffer;
			bufferInfo.offset = info.offset;
			bufferInfo.range = info.range;

			VkWriteDescriptorSet* descriptorWrite = &descriptorWrites[i];
			descriptorWrite.dstSet = descriptorSets[i];
			descriptorWrite.dstBinding = info.writeDescriptorSet.binding;
			descriptorWrite.dstArrayElement = info.writeDescriptorSet.arrayElement;
			descriptorWrite.descriptorCount = info.writeDescriptorSet.descriptorCount;
			descriptorWrite.descriptorType = info.writeDescriptorSet.descriptorType.translate;
			descriptorWrite.pBufferInfo = bufferInfo;
		}
		device.dispatch.UpdateDescriptorSets(cast(uint)descriptorWrites.length, descriptorWrites.ptr, 0, null);
	}

	~this() {
		if (!device)
			return;
		cleanup();
		device = null;
	}

	void cleanup() {
		device.dispatch.FreeDescriptorSets(device.descriptorPool, cast(uint)descriptorSets.length, descriptorSets.ptr);
		device.dispatch.DestroyPipeline(pipeline);
		device.dispatch.DestroyPipelineLayout(pipelineLayout);
		device.dispatch.DestroyDescriptorSetLayout(descriptorSetLayout);
	}
}

static assert(isCorrectVulkanData!VKPipelineData);
