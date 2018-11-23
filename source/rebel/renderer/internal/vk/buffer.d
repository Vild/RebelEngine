module rebel.renderer.internal.vk.buffer;

import rebel.renderer;
import erupted;
import vulkan_memory_allocator;

import rebel.renderer.internal.vk;

struct VKBufferData {
	BufferData base;
	alias base this;

	BufferBuilder builder;
	VKDevice* device;

	VkBuffer buffer;
	VmaAllocation allocation;
	VmaAllocationInfo allocationInfo;

	this(const ref BufferBuilder builder, VKDevice* device) {
		base.getData = &getData;
		base.setData = &setData;
		this.builder = builder;
		this.device = device;
		create();
	}

	void create() {
		bool isUniform = builder.usage == BufferUsage.uniform;

		VkBufferCreateInfo createInfo;
		createInfo.size = builder.size;
		createInfo.usage = builder.usage.translate | (isUniform ? 0 : VK_BUFFER_USAGE_TRANSFER_DST_BIT);
		createInfo.sharingMode = builder.sharing.translate;

		VmaAllocationCreateInfo allocInfo;
		allocInfo.usage = isUniform ? VmaMemoryUsage.VMA_MEMORY_USAGE_CPU_TO_GPU : VmaMemoryUsage.VMA_MEMORY_USAGE_GPU_ONLY;
		allocInfo.flags = VmaAllocationCreateFlagBits.VMA_ALLOCATION_CREATE_MAPPED_BIT;

		vkAssert(vmaCreateBuffer(device.allocator, &createInfo, &allocInfo, &buffer, &allocation, &allocationInfo),
				"Failed to create buffer!");

		setVkObjectName(device, VK_OBJECT_TYPE_BUFFER, buffer, builder.name);
		setVkObjectName(device, VK_OBJECT_TYPE_DEVICE_MEMORY, allocationInfo.deviceMemory, builder.name);
	}

	~this() {
		if (!device)
			return;
		cleanup();
		device = null;
	}

	void cleanup() {
		vmaDestroyBuffer(device.allocator, buffer, allocation);
	}

	struct StagingBuffer {
		VkBuffer buffer;

		VmaAllocation allocation;
		VmaAllocationInfo allocationInfo;
	}

	StagingBuffer createStaging() {
		StagingBuffer ret;
		VkBufferCreateInfo createInfo;
		createInfo.size = builder.size;
		createInfo.usage = VK_BUFFER_USAGE_TRANSFER_SRC_BIT;
		createInfo.sharingMode = VK_SHARING_MODE_EXCLUSIVE;

		VmaAllocationCreateInfo allocInfo;
		allocInfo.usage = VmaMemoryUsage.VMA_MEMORY_USAGE_CPU_ONLY;
		allocInfo.flags = VmaAllocationCreateFlagBits.VMA_ALLOCATION_CREATE_MAPPED_BIT;

		vkAssert(vmaCreateBuffer(device.allocator, &createInfo, &allocInfo, &ret.buffer, &ret.allocation,
				&ret.allocationInfo), "Failed to create buffer!");

		setVkObjectName(device, VK_OBJECT_TYPE_BUFFER, buffer, "Staging buffer");
		setVkObjectName(device, VK_OBJECT_TYPE_DEVICE_MEMORY, allocationInfo.deviceMemory, "Staging buffer");
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
			VkBufferCopy region;
			region.srcOffset = 0;
			region.dstOffset = 0;
			region.size = builder.size;
			device.dispatch.vkCmdCopyBuffer(cb, staging.buffer, buffer, 1, &region);
			device.endSingleTimeCommands();

			vmaDestroyBuffer(device.allocator, staging.buffer, staging.allocation);
		}
	}
}

static assert(isCorrectVulkanData!VKBufferData);
