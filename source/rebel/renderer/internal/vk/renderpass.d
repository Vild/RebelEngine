module rebel.renderer.internal.vk.renderpass;

import rebel.renderer;
import erupted;
import rebel.engine;

import rebel.renderer.internal.vk;

struct VKRenderPassData {
	RenderPassData base;
	alias base this;

	RenderPassBuilder builder;
	VKDevice* device;

	VkRenderPass renderPass;

	this(ref RenderPassBuilder builder, VKDevice* device) {
		this.builder = builder;
		this.device = device;
		create();
	}

	void create() {
		IRenderer renderer = Engine.instance.renderer;

		VkAttachmentDescription[] attachments;
		attachments.length = builder.attachments.length;
		foreach (idx, Attachment* attr; builder.attachments) {
			VkAttachmentDescription* desc = &attachments[idx];
			scope ImageTemplate.Ref it = renderer.get(attr.imageTemplate);
			auto data = it.get!VKImageTemplateData;

			desc.format = data.format;
			desc.samples = data.samples;
			desc.loadOp = attr.loadOp.translate;
			desc.storeOp = attr.storeOp.translate;
			desc.stencilLoadOp = attr.stencilLoadOp.translate;
			desc.stencilStoreOp = attr.stencilStoreOp.translate;
			desc.initialLayout = attr.initialLayout.translate;
			desc.finalLayout = attr.finalLayout.translate;
		}

		VkSubpassDescription[] subpasses;
		subpasses.length = builder.subpasses.length;

		foreach (idx, const Subpass* sp; builder.subpasses) {
			VkSubpassDescription* subpass = &subpasses[idx];

			VkAttachmentReference[] colorAttachments;
			colorAttachments.length = sp.colorOutput.length;
			foreach (idx2, const ref SubpassAttachment sa; sp.colorOutput) {
				import std.algorithm : countUntil;

				VkAttachmentReference* attach = &colorAttachments[idx2];
				attach.attachment = cast(uint)builder.attachments.countUntil(sa.attachment);
				attach.layout = sa.layout.translate;
			}

			VkAttachmentReference[] depthStencilAttachments;
			depthStencilAttachments.length = sp.depthStencilOutput.length;
			foreach (idx2, const ref SubpassAttachment sa; sp.depthStencilOutput) {
				import std.algorithm : countUntil;

				VkAttachmentReference* attach = &depthStencilAttachments[idx2];
				attach.attachment = cast(uint)builder.attachments.countUntil(sa.attachment);
				attach.layout = sa.layout.translate;
			}

			subpass.pipelineBindPoint = sp.bindPoint.translate;
			subpass.colorAttachmentCount = cast(uint)colorAttachments.length;
			subpass.pColorAttachments = colorAttachments.ptr;
			subpass.pDepthStencilAttachment = depthStencilAttachments.ptr;
		}

		VkSubpassDependency[] dependencies;
		dependencies.length = builder.dependencies.length;

		foreach (idx, const ref SubpassDependency sd; builder.dependencies) {
			import std.algorithm : countUntil;

			VkSubpassDependency* dep = &dependencies[idx];

			dep.srcSubpass = sd.srcSubpass ? cast(uint)builder.subpasses.countUntil(sd.srcSubpass) : VK_SUBPASS_EXTERNAL;
			dep.dstSubpass = sd.dstSubpass ? cast(uint)builder.subpasses.countUntil(sd.dstSubpass) : VK_SUBPASS_EXTERNAL;
			dep.srcStageMask = sd.srcStageMask.translate;
			dep.srcAccessMask = sd.srcAccessMask.translate;
			dep.dstStageMask = sd.dstStageMask.translate;
			dep.dstAccessMask = sd.dstAccessMask.translate;
		}

		VkRenderPassCreateInfo renderPassInfo;
		renderPassInfo.sType = VK_STRUCTURE_TYPE_RENDER_PASS_CREATE_INFO;

		renderPassInfo.pAttachments = attachments.ptr;
		renderPassInfo.attachmentCount = cast(uint)attachments.length;

		renderPassInfo.pSubpasses = subpasses.ptr;
		renderPassInfo.subpassCount = cast(uint)subpasses.length;

		renderPassInfo.pDependencies = dependencies.ptr;
		renderPassInfo.dependencyCount = cast(uint)dependencies.length;

		vkAssert(device.dispatch.CreateRenderPass(&renderPassInfo, &renderPass));

		setVkObjectName(device, VK_OBJECT_TYPE_RENDER_PASS, renderPass, builder.name);
	}

	~this() {
		if (!device)
			return;
		cleanup();
		device = null;
	}

	void cleanup() {
		device.dispatch.DestroyRenderPass(renderPass);
	}
}

static assert(isCorrectVulkanData!VKRenderPassData);
