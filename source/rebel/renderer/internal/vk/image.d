module rebel.renderer.internal.vk.image;

import rebel.renderer;
import erupted;
import vulkan_memory_allocator;
import rebel.engine;
import gfm.math.vector;

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

	vec2ui _size;

	this(ref ImageBuilder builder, VKDevice* device, VkImage image = VK_NULL_HANDLE) {
		base.getData = &getData;
		base.setData = &setData;
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
		_size = data.size;
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
			imageCreate.usage = data.usage.translate | VK_IMAGE_USAGE_SAMPLED_BIT;
			imageCreate.initialLayout = VkImageLayout.VK_IMAGE_LAYOUT_UNDEFINED;
			imageCreate.sharingMode = VkSharingMode.VK_SHARING_MODE_EXCLUSIVE;

			VmaAllocationCreateInfo allocInfo;
			allocInfo.flags = VmaMemoryUsage.VMA_MEMORY_USAGE_GPU_ONLY;

			vkAssert(vmaCreateImage(device.allocator, &imageCreate, &allocInfo, &image, &allocation, &allocationInfo),
					"Failed to create Image");
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

	struct StagingBuffer {
		VkBuffer buffer;

		VmaAllocation allocation;
		VmaAllocationInfo allocationInfo;
	}

	StagingBuffer createStaging() {
		StagingBuffer ret;
		VkBufferCreateInfo createInfo;
		createInfo.size = allocationInfo.size;
		createInfo.usage = VK_BUFFER_USAGE_TRANSFER_SRC_BIT;
		createInfo.sharingMode = VK_SHARING_MODE_EXCLUSIVE;

		VmaAllocationCreateInfo allocInfo;
		allocInfo.usage = VmaMemoryUsage.VMA_MEMORY_USAGE_CPU_ONLY;
		allocInfo.flags = VmaAllocationCreateFlagBits.VMA_ALLOCATION_CREATE_MAPPED_BIT;

		vkAssert(vmaCreateBuffer(device.allocator, &createInfo, &allocInfo, &ret.buffer, &ret.allocation,
				&ret.allocationInfo), "Failed to create buffer!");

		setVkObjectName(device, VK_OBJECT_TYPE_BUFFER, ret.buffer, "Staging buffer");
		setVkObjectName(device, VK_OBJECT_TYPE_DEVICE_MEMORY, ret.allocationInfo.deviceMemory, "Staging buffer");
		return ret;
	}

	//TODO: add staging buffer, if needed
	void[] getData(void[] outputBuffer) {
		import std.algorithm : min;

		size_t maxSize = min(allocationInfo.size, outputBuffer.length);

		if (allocationInfo.pMappedData)
			outputBuffer[0 .. maxSize] = allocationInfo.pMappedData[0 .. maxSize];
		else {
			assert(0);
			//void* ptr;
			//vkAssert(vmaMapMemory(device.allocator, allocation, &ptr), "Failed to map memory");
			//vmaUnmapMemory(device.allocator, allocation);
		}
		return outputBuffer;
	}

	void setData(void[] data) {
		import std.algorithm : min;

		size_t maxSize = min(allocationInfo.size, data.length);
		if (allocationInfo.pMappedData) {
			allocationInfo.pMappedData[0 .. maxSize] = data[0 .. maxSize];
		} else {
			StagingBuffer staging = createStaging();
			assert(staging.allocationInfo.pMappedData);
			staging.allocationInfo.pMappedData[0 .. maxSize] = data[0 .. maxSize];

			auto cb = device.beginSingleTimeCommands();

			{
				VkImageMemoryBarrier barrier;
				barrier.oldLayout = VK_IMAGE_LAYOUT_UNDEFINED;
				barrier.newLayout = VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL;
				barrier.srcQueueFamilyIndex = VK_QUEUE_FAMILY_IGNORED;
				barrier.dstQueueFamilyIndex = VK_QUEUE_FAMILY_IGNORED;
				barrier.image = image;
				barrier.subresourceRange.aspectMask = VK_IMAGE_ASPECT_COLOR_BIT;
				barrier.subresourceRange.baseMipLevel = 0;
				barrier.subresourceRange.levelCount = 1;
				barrier.subresourceRange.baseArrayLayer = 0;
				barrier.subresourceRange.layerCount = 1;
				barrier.srcAccessMask = 0;
				barrier.dstAccessMask = VK_ACCESS_TRANSFER_WRITE_BIT;

				VkPipelineStageFlags sourceStage = VK_PIPELINE_STAGE_TOP_OF_PIPE_BIT;
				VkPipelineStageFlags destinationStage = VK_PIPELINE_STAGE_TRANSFER_BIT;

				device.dispatch.vkCmdPipelineBarrier(cb, sourceStage, destinationStage, 0, 0, null, 0, null, 1, &barrier);
			}

			{
				VkBufferImageCopy region;
				region.bufferOffset = 0;
				region.bufferRowLength = 0;
				region.bufferImageHeight = 0;
				region.imageSubresource.aspectMask = VK_IMAGE_ASPECT_COLOR_BIT;
				region.imageSubresource.mipLevel = 0;
				region.imageSubresource.baseArrayLayer = 0;
				region.imageSubresource.layerCount = 1;
				region.imageOffset = VkOffset3D(0, 0, 0);
				region.imageExtent = VkExtent3D(_size.x, _size.y, 1);
				device.dispatch.vkCmdCopyBufferToImage(cb, staging.buffer, image, VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL, 1, &region);
			}

			{
				VkImageMemoryBarrier barrier;
				barrier.oldLayout = VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL;
				barrier.newLayout = VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL;
				barrier.srcQueueFamilyIndex = VK_QUEUE_FAMILY_IGNORED;
				barrier.dstQueueFamilyIndex = VK_QUEUE_FAMILY_IGNORED;
				barrier.image = image;
				barrier.subresourceRange.aspectMask = VK_IMAGE_ASPECT_COLOR_BIT;
				barrier.subresourceRange.baseMipLevel = 0;
				barrier.subresourceRange.levelCount = 1;
				barrier.subresourceRange.baseArrayLayer = 0;
				barrier.subresourceRange.layerCount = 1;
				barrier.srcAccessMask = VK_ACCESS_TRANSFER_WRITE_BIT;
				barrier.dstAccessMask = VK_ACCESS_SHADER_READ_BIT;

				VkPipelineStageFlags sourceStage = VK_PIPELINE_STAGE_TRANSFER_BIT;
				VkPipelineStageFlags destinationStage = VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT;

				device.dispatch.vkCmdPipelineBarrier(cb, sourceStage, destinationStage, 0, 0, null, 0, null, 1, &barrier);
			}

			device.endSingleTimeCommands();

			vmaDestroyBuffer(device.allocator, staging.buffer, staging.allocation);
		}
	}
}

static assert(isCorrectVulkanData!VKImageData);
