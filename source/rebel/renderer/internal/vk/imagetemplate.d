module rebel.renderer.internal.vk.imagetemplate;

import rebel.renderer;
import erupted;

import rebel.renderer.internal.vk;

struct VKImageTemplateData {
	ImageTemplateData base;
	alias base this;

	ImageTemplateBuilder builder;
	VKDevice* device;

	VkImageAspectFlags aspectMask;
	VkFormat format;
	VkSampleCountFlagBits samples;

	this(ref ImageTemplateBuilder builder, VKDevice* device) {
		this.builder = builder;
		this.device = device;
		create();
	}

	void create() {
		base.format = builder.format;
		base.usage = builder.usage;
		base.size = builder.size;
		base.samples = builder.samples;
		base.readOnly = builder.readOnly;

		format = builder.format.translate;

		// TODO: Validate number
		samples = cast(VkSampleCountFlagBits)builder.samples;

		final switch (builder.usage) {
		case ImageUsage.transferDst:
			aspectMask = VkImageAspectFlagBits.VK_IMAGE_ASPECT_COLOR_BIT;
			base.layout = ImageLayout.transferDst;
			break;
		case ImageUsage.presentAttachment:
			aspectMask = VkImageAspectFlagBits.VK_IMAGE_ASPECT_COLOR_BIT;
			base.layout = ImageLayout.present;
			break;
		case ImageUsage.colorAttachment:
			aspectMask = VkImageAspectFlagBits.VK_IMAGE_ASPECT_COLOR_BIT;
			base.layout = ImageLayout.color;
			break;
		case ImageUsage.depthAttachment:
			aspectMask = VkImageAspectFlagBits.VK_IMAGE_ASPECT_DEPTH_BIT;
			//base.layout = ImageLayout.depthStencil;
			goto case;
		case ImageUsage.depthStencilAttachment:
			aspectMask |= VkImageAspectFlagBits.VK_IMAGE_ASPECT_STENCIL_BIT;
			base.layout = ImageLayout.depthStencil;
			break;
		}
	}

	~this() {
		if (!device)
			return;
		cleanup();
		device = null;
	}

	void cleanup() {
	}
}

static assert(isCorrectVulkanData!VKImageTemplateData);
