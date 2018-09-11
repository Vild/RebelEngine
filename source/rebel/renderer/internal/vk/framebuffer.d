module rebel.renderer.internal.vk.framebuffer;

import rebel.renderer;
import erupted;
import rebel.engine;

import rebel.renderer.internal.vk;

struct VKFramebufferData {
	FramebufferData base;
	alias base this;

	FramebufferBuilder builder;
	VKDevice* device;

	VkFramebuffer framebuffer;

	this(ref FramebufferBuilder builder, VKDevice* device) {
		this.builder = builder;
		this.device = device;
		create();
	}

	void create() {
		IRenderer renderer = Engine.instance.renderer;
		VkFramebufferCreateInfo framebufferInfo;

		VkImageView[] attachments;
		foreach (Image m; builder.attachments) {
			scope Image.Ref shader = renderer.get(m);
			attachments ~= shader.get!VKImageData().view;
		}

		framebufferInfo.renderPass = renderer.get(builder.renderPass).get!VKRenderPassData().renderPass;
		framebufferInfo.pAttachments = attachments.ptr;
		framebufferInfo.attachmentCount = cast(uint)attachments.length;
		framebufferInfo.width = builder.dimension.x;
		framebufferInfo.height = builder.dimension.y;
		framebufferInfo.layers = builder.dimension.z;

		vkAssert(device.dispatch.CreateFramebuffer(&framebufferInfo, &framebuffer));

		setVkObjectName(device, VK_OBJECT_TYPE_FRAMEBUFFER, framebuffer, builder.name);
	}

	~this() {
		if (!device)
			return;
		cleanup();
		device = null;
	}

	void cleanup() {
		device.dispatch.DestroyFramebuffer(framebuffer);
	}
}

static assert(isCorrectVulkanData!VKFramebufferData);
