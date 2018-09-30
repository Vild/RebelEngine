module rebel.renderer.internal.vk.image;

import rebel.renderer;
import erupted;
import vulkan_memory_allocator;
import rebel.engine;

import rebel.renderer.internal.vk;

struct VKImageData {
	ImageData base;
	alias base this;

	ImageBuilder builder;
	VKDevice* device;

	bool ownsImage = true;
	VkImage image;
	VmaAllocation allocation;
	VmaAllocationInfo allocationInfo;
	VkImageView view;

	this(ref ImageBuilder builder, VKDevice* device, VkImage image = VK_NULL_HANDLE) {
		this.builder = builder;
		this.device = device;
		ownsImage = image == VK_NULL_HANDLE;
		this.image = image;
		create();
	}

	void create() {
		IRenderer renderer = Engine.instance.renderer;

		scope ImageTemplate.Ref it = renderer.get(builder.imageTemplate);
		auto data = it.get!VKImageTemplateData;
		if (ownsImage) {
			VkImageCreateInfo imageCreate;
			imageCreate.imageType = VkImageType.VK_IMAGE_TYPE_2D;
			imageCreate.format = data.format;
			imageCreate.extent.width = data.size.x;
			imageCreate.extent.height = data.size.y;
			imageCreate.extent.depth = 1;
			imageCreate.mipLevels = 1;
			imageCreate.arrayLayers = 1;
			imageCreate.samples = VkSampleCountFlagBits.VK_SAMPLE_COUNT_1_BIT;
			imageCreate.tiling = VkImageTiling.VK_IMAGE_TILING_OPTIMAL;
			imageCreate.usage = data.usage | VK_IMAGE_USAGE_SAMPLED_BIT;

			VmaAllocationCreateInfo allocInfo;
			allocInfo.flags = VmaMemoryUsage.VMA_MEMORY_USAGE_GPU_ONLY;

			vkAssert(vmaCreateImage(device.allocator, &imageCreate, &allocInfo, &image, &allocation, &allocationInfo), "Failed to create Image");
			setVkObjectName(device, VK_OBJECT_TYPE_IMAGE, image, builder.name);
			setVkObjectName(device, VK_OBJECT_TYPE_DEVICE_MEMORY, allocationInfo.deviceMemory, builder.name);
		}

		VkImageViewCreateInfo createinfo;
		createinfo.viewType = VkImageViewType.VK_IMAGE_VIEW_TYPE_2D;
		createinfo.format = data.format;
		createinfo.components.r = VkComponentSwizzle.VK_COMPONENT_SWIZZLE_IDENTITY;
		createinfo.components.g = VkComponentSwizzle.VK_COMPONENT_SWIZZLE_IDENTITY;
		createinfo.components.b = VkComponentSwizzle.VK_COMPONENT_SWIZZLE_IDENTITY;
		createinfo.components.a = VkComponentSwizzle.VK_COMPONENT_SWIZZLE_IDENTITY;
		createinfo.subresourceRange.aspectMask = VkImageAspectFlagBits.VK_IMAGE_ASPECT_COLOR_BIT;
		createinfo.subresourceRange.aspectMask = data.aspectMask;
		createinfo.subresourceRange.baseMipLevel = 0;
		createinfo.subresourceRange.levelCount = 1;
		createinfo.subresourceRange.baseArrayLayer = 0;
		createinfo.subresourceRange.layerCount = 1;
		createinfo.image = image;
		vkAssert(device.dispatch.CreateImageView(&createinfo, &view), "Failed to create ImageView");
		setVkObjectName(device, VK_OBJECT_TYPE_IMAGE_VIEW, view, builder.name);
	}

	~this() {
		if (!device)
			return;
		cleanup();
		device = null;
	}

	void cleanup() {
		device.dispatch.DestroyImageView(view);
		if (ownsImage)
			vmaDestroyImage(device.allocator, image, allocation);
	}
}

static assert(isCorrectVulkanData!VKImageData);
