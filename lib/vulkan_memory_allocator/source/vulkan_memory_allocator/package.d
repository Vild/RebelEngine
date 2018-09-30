module vulkan_memory_allocator;

import erupted.types;
import erupted.functions;
import erupted.platform_extensions;

extern (C) {
	struct VmaAllocator_T;
	alias VmaAllocator = VmaAllocator_T*;
	alias PFN_vmaAllocateDeviceMemoryFunction = void function(VmaAllocator, uint32_t, VkDeviceMemory, VkDeviceSize) @nogc nothrow;
	alias PFN_vmaFreeDeviceMemoryFunction = void function(VmaAllocator, uint32_t, VkDeviceMemory, VkDeviceSize) @nogc nothrow;

	struct VmaDeviceMemoryCallbacks {
		PFN_vmaAllocateDeviceMemoryFunction pfnAllocate;
		PFN_vmaFreeDeviceMemoryFunction pfnFree;
	}

	enum VmaAllocatorCreateFlagBits {
		VMA_ALLOCATOR_CREATE_EXTERNALLY_SYNCHRONIZED_BIT = 1,
		VMA_ALLOCATOR_CREATE_KHR_DEDICATED_ALLOCATION_BIT = 2,
		VMA_ALLOCATOR_CREATE_FLAG_BITS_MAX_ENUM = 2147483647,
	}

	enum VMA_ALLOCATOR_CREATE_EXTERNALLY_SYNCHRONIZED_BIT = VmaAllocatorCreateFlagBits.VMA_ALLOCATOR_CREATE_EXTERNALLY_SYNCHRONIZED_BIT;
	enum VMA_ALLOCATOR_CREATE_KHR_DEDICATED_ALLOCATION_BIT = VmaAllocatorCreateFlagBits.VMA_ALLOCATOR_CREATE_KHR_DEDICATED_ALLOCATION_BIT;
	enum VMA_ALLOCATOR_CREATE_FLAG_BITS_MAX_ENUM = VmaAllocatorCreateFlagBits.VMA_ALLOCATOR_CREATE_FLAG_BITS_MAX_ENUM;

	alias VmaAllocatorCreateFlags = uint;
	struct VmaVulkanFunctions {
		PFN_vkGetPhysicalDeviceProperties vkGetPhysicalDeviceProperties;
		PFN_vkGetPhysicalDeviceMemoryProperties vkGetPhysicalDeviceMemoryProperties;
		PFN_vkAllocateMemory vkAllocateMemory;
		PFN_vkFreeMemory vkFreeMemory;
		PFN_vkMapMemory vkMapMemory;
		PFN_vkUnmapMemory vkUnmapMemory;
		PFN_vkFlushMappedMemoryRanges vkFlushMappedMemoryRanges;
		PFN_vkInvalidateMappedMemoryRanges vkInvalidateMappedMemoryRanges;
		PFN_vkBindBufferMemory vkBindBufferMemory;
		PFN_vkBindImageMemory vkBindImageMemory;
		PFN_vkGetBufferMemoryRequirements vkGetBufferMemoryRequirements;
		PFN_vkGetImageMemoryRequirements vkGetImageMemoryRequirements;
		PFN_vkCreateBuffer vkCreateBuffer;
		PFN_vkDestroyBuffer vkDestroyBuffer;
		PFN_vkCreateImage vkCreateImage;
		PFN_vkDestroyImage vkDestroyImage;
		PFN_vkGetBufferMemoryRequirements2 vkGetBufferMemoryRequirements2;
		PFN_vkGetImageMemoryRequirements2 vkGetImageMemoryRequirements2;
	}

	enum VmaRecordFlagBits {
		VMA_RECORD_FLUSH_AFTER_CALL_BIT = 1,
		VMA_RECORD_FLAG_BITS_MAX_ENUM = 2147483647,
	}

	enum VMA_RECORD_FLUSH_AFTER_CALL_BIT = VmaRecordFlagBits.VMA_RECORD_FLUSH_AFTER_CALL_BIT;
	enum VMA_RECORD_FLAG_BITS_MAX_ENUM = VmaRecordFlagBits.VMA_RECORD_FLAG_BITS_MAX_ENUM;

	alias VmaRecordFlags = uint;
	struct VmaRecordSettings {
		VmaRecordFlags flags;
		const(char)* pFilePath;
	}

	struct VmaAllocatorCreateInfo {
		VmaAllocatorCreateFlags flags;
		VkPhysicalDevice physicalDevice;
		VkDevice device;
		VkDeviceSize preferredLargeHeapBlockSize;
		const(VkAllocationCallbacks)* pAllocationCallbacks;
		const(VmaDeviceMemoryCallbacks)* pDeviceMemoryCallbacks;
		uint32_t frameInUseCount;
		const(VkDeviceSize)* pHeapSizeLimit;
		const(VmaVulkanFunctions)* pVulkanFunctions;
		const(VmaRecordSettings)* pRecordSettings;
	}

	VkResult vmaCreateAllocator(const(VmaAllocatorCreateInfo)*, VmaAllocator*) @nogc nothrow;
	void vmaDestroyAllocator(VmaAllocator) @nogc nothrow;
	void vmaGetPhysicalDeviceProperties(VmaAllocator, const(VkPhysicalDeviceProperties)**) @nogc nothrow;
	void vmaGetMemoryProperties(VmaAllocator, const(VkPhysicalDeviceMemoryProperties)**) @nogc nothrow;
	void vmaGetMemoryTypeProperties(VmaAllocator, uint32_t, VkMemoryPropertyFlags*) @nogc nothrow;
	void vmaSetCurrentFrameIndex(VmaAllocator, uint32_t) @nogc nothrow;
	struct VmaStatInfo {
		uint32_t blockCount;
		uint32_t allocationCount;
		uint32_t unusedRangeCount;
		VkDeviceSize usedBytes;
		VkDeviceSize unusedBytes;
		VkDeviceSize allocationSizeMin;
		VkDeviceSize allocationSizeAvg;
		VkDeviceSize allocationSizeMax;
		VkDeviceSize unusedRangeSizeMin;
		VkDeviceSize unusedRangeSizeAvg;
		VkDeviceSize unusedRangeSizeMax;
	}

	struct VmaStats {
		VmaStatInfo[32] memoryType;
		VmaStatInfo[16] memoryHeap;
		VmaStatInfo total;
	}

	void vmaCalculateStats(VmaAllocator, VmaStats*) @nogc nothrow;
	void vmaBuildStatsString(VmaAllocator, char**, VkBool32) @nogc nothrow;
	void vmaFreeStatsString(VmaAllocator, char*) @nogc nothrow;

	struct VmaPool_T;
	alias VmaPool = VmaPool_T*;

	enum VmaMemoryUsage {
		VMA_MEMORY_USAGE_UNKNOWN = 0,
		VMA_MEMORY_USAGE_GPU_ONLY = 1,
		VMA_MEMORY_USAGE_CPU_ONLY = 2,
		VMA_MEMORY_USAGE_CPU_TO_GPU = 3,
		VMA_MEMORY_USAGE_GPU_TO_CPU = 4,
		VMA_MEMORY_USAGE_MAX_ENUM = 2147483647,
	}

	enum VMA_MEMORY_USAGE_UNKNOWN = VmaMemoryUsage.VMA_MEMORY_USAGE_UNKNOWN;
	enum VMA_MEMORY_USAGE_GPU_ONLY = VmaMemoryUsage.VMA_MEMORY_USAGE_GPU_ONLY;
	enum VMA_MEMORY_USAGE_CPU_ONLY = VmaMemoryUsage.VMA_MEMORY_USAGE_CPU_ONLY;
	enum VMA_MEMORY_USAGE_CPU_TO_GPU = VmaMemoryUsage.VMA_MEMORY_USAGE_CPU_TO_GPU;
	enum VMA_MEMORY_USAGE_GPU_TO_CPU = VmaMemoryUsage.VMA_MEMORY_USAGE_GPU_TO_CPU;
	enum VMA_MEMORY_USAGE_MAX_ENUM = VmaMemoryUsage.VMA_MEMORY_USAGE_MAX_ENUM;

	enum VmaAllocationCreateFlagBits {
		VMA_ALLOCATION_CREATE_DEDICATED_MEMORY_BIT = 1,
		VMA_ALLOCATION_CREATE_NEVER_ALLOCATE_BIT = 2,
		VMA_ALLOCATION_CREATE_MAPPED_BIT = 4,
		VMA_ALLOCATION_CREATE_CAN_BECOME_LOST_BIT = 8,
		VMA_ALLOCATION_CREATE_CAN_MAKE_OTHER_LOST_BIT = 16,
		VMA_ALLOCATION_CREATE_USER_DATA_COPY_STRING_BIT = 32,
		VMA_ALLOCATION_CREATE_UPPER_ADDRESS_BIT = 64,
		VMA_ALLOCATION_CREATE_STRATEGY_BEST_FIT_BIT = 65536,
		VMA_ALLOCATION_CREATE_STRATEGY_WORST_FIT_BIT = 131072,
		VMA_ALLOCATION_CREATE_STRATEGY_FIRST_FIT_BIT = 262144,
		VMA_ALLOCATION_CREATE_STRATEGY_MIN_MEMORY_BIT = 65536,
		VMA_ALLOCATION_CREATE_STRATEGY_MIN_TIME_BIT = 262144,
		VMA_ALLOCATION_CREATE_STRATEGY_MIN_FRAGMENTATION_BIT = 131072,
		VMA_ALLOCATION_CREATE_STRATEGY_MASK = 458752,
		VMA_ALLOCATION_CREATE_FLAG_BITS_MAX_ENUM = 2147483647,
	}

	enum VMA_ALLOCATION_CREATE_DEDICATED_MEMORY_BIT = VmaAllocationCreateFlagBits.VMA_ALLOCATION_CREATE_DEDICATED_MEMORY_BIT;
	enum VMA_ALLOCATION_CREATE_NEVER_ALLOCATE_BIT = VmaAllocationCreateFlagBits.VMA_ALLOCATION_CREATE_NEVER_ALLOCATE_BIT;
	enum VMA_ALLOCATION_CREATE_MAPPED_BIT = VmaAllocationCreateFlagBits.VMA_ALLOCATION_CREATE_MAPPED_BIT;
	enum VMA_ALLOCATION_CREATE_CAN_BECOME_LOST_BIT = VmaAllocationCreateFlagBits.VMA_ALLOCATION_CREATE_CAN_BECOME_LOST_BIT;
	enum VMA_ALLOCATION_CREATE_CAN_MAKE_OTHER_LOST_BIT = VmaAllocationCreateFlagBits.VMA_ALLOCATION_CREATE_CAN_MAKE_OTHER_LOST_BIT;
	enum VMA_ALLOCATION_CREATE_USER_DATA_COPY_STRING_BIT = VmaAllocationCreateFlagBits.VMA_ALLOCATION_CREATE_USER_DATA_COPY_STRING_BIT;
	enum VMA_ALLOCATION_CREATE_UPPER_ADDRESS_BIT = VmaAllocationCreateFlagBits.VMA_ALLOCATION_CREATE_UPPER_ADDRESS_BIT;
	enum VMA_ALLOCATION_CREATE_STRATEGY_BEST_FIT_BIT = VmaAllocationCreateFlagBits.VMA_ALLOCATION_CREATE_STRATEGY_BEST_FIT_BIT;
	enum VMA_ALLOCATION_CREATE_STRATEGY_WORST_FIT_BIT = VmaAllocationCreateFlagBits.VMA_ALLOCATION_CREATE_STRATEGY_WORST_FIT_BIT;
	enum VMA_ALLOCATION_CREATE_STRATEGY_FIRST_FIT_BIT = VmaAllocationCreateFlagBits.VMA_ALLOCATION_CREATE_STRATEGY_FIRST_FIT_BIT;
	enum VMA_ALLOCATION_CREATE_STRATEGY_MIN_MEMORY_BIT = VmaAllocationCreateFlagBits.VMA_ALLOCATION_CREATE_STRATEGY_MIN_MEMORY_BIT;
	enum VMA_ALLOCATION_CREATE_STRATEGY_MIN_TIME_BIT = VmaAllocationCreateFlagBits.VMA_ALLOCATION_CREATE_STRATEGY_MIN_TIME_BIT;
	enum VMA_ALLOCATION_CREATE_STRATEGY_MIN_FRAGMENTATION_BIT = VmaAllocationCreateFlagBits
			.VMA_ALLOCATION_CREATE_STRATEGY_MIN_FRAGMENTATION_BIT;
	enum VMA_ALLOCATION_CREATE_STRATEGY_MASK = VmaAllocationCreateFlagBits.VMA_ALLOCATION_CREATE_STRATEGY_MASK;
	enum VMA_ALLOCATION_CREATE_FLAG_BITS_MAX_ENUM = VmaAllocationCreateFlagBits.VMA_ALLOCATION_CREATE_FLAG_BITS_MAX_ENUM;

	alias VmaAllocationCreateFlags = uint;
	struct VmaAllocationCreateInfo {
		VmaAllocationCreateFlags flags;
		VmaMemoryUsage usage;
		VkMemoryPropertyFlags requiredFlags;
		VkMemoryPropertyFlags preferredFlags;
		uint32_t memoryTypeBits;
		VmaPool pool;
		void* pUserData;
	}

	VkResult vmaFindMemoryTypeIndex(VmaAllocator, uint32_t, const(VmaAllocationCreateInfo)*, uint32_t*) @nogc nothrow;
	VkResult vmaFindMemoryTypeIndexForBufferInfo(VmaAllocator, const(VkBufferCreateInfo)*, const(VmaAllocationCreateInfo)*, uint32_t*) @nogc nothrow;
	VkResult vmaFindMemoryTypeIndexForImageInfo(VmaAllocator, const(VkImageCreateInfo)*, const(VmaAllocationCreateInfo)*, uint32_t*) @nogc nothrow;

	enum VmaPoolCreateFlagBits {
		VMA_POOL_CREATE_IGNORE_BUFFER_IMAGE_GRANULARITY_BIT = 2,
		VMA_POOL_CREATE_LINEAR_ALGORITHM_BIT = 4,
		VMA_POOL_CREATE_BUDDY_ALGORITHM_BIT = 8,
		VMA_POOL_CREATE_ALGORITHM_MASK = 12,
		VMA_POOL_CREATE_FLAG_BITS_MAX_ENUM = 2147483647,
	}

	enum VMA_POOL_CREATE_IGNORE_BUFFER_IMAGE_GRANULARITY_BIT = VmaPoolCreateFlagBits.VMA_POOL_CREATE_IGNORE_BUFFER_IMAGE_GRANULARITY_BIT;
	enum VMA_POOL_CREATE_LINEAR_ALGORITHM_BIT = VmaPoolCreateFlagBits.VMA_POOL_CREATE_LINEAR_ALGORITHM_BIT;
	enum VMA_POOL_CREATE_BUDDY_ALGORITHM_BIT = VmaPoolCreateFlagBits.VMA_POOL_CREATE_BUDDY_ALGORITHM_BIT;
	enum VMA_POOL_CREATE_ALGORITHM_MASK = VmaPoolCreateFlagBits.VMA_POOL_CREATE_ALGORITHM_MASK;
	enum VMA_POOL_CREATE_FLAG_BITS_MAX_ENUM = VmaPoolCreateFlagBits.VMA_POOL_CREATE_FLAG_BITS_MAX_ENUM;

	alias VmaPoolCreateFlags = uint;
	struct VmaPoolCreateInfo {
		uint32_t memoryTypeIndex;
		VmaPoolCreateFlags flags;
		VkDeviceSize blockSize;
		size_t minBlockCount;
		size_t maxBlockCount;
		uint32_t frameInUseCount;
	}

	struct VmaPoolStats {
		VkDeviceSize size;
		VkDeviceSize unusedSize;
		size_t allocationCount;
		size_t unusedRangeCount;
		VkDeviceSize unusedRangeSizeMax;
		size_t blockCount;
	}

	VkResult vmaCreatePool(VmaAllocator, const(VmaPoolCreateInfo)*, VmaPool*) @nogc nothrow;
	void vmaDestroyPool(VmaAllocator, VmaPool) @nogc nothrow;
	void vmaGetPoolStats(VmaAllocator, VmaPool, VmaPoolStats*) @nogc nothrow;
	void vmaMakePoolAllocationsLost(VmaAllocator, VmaPool, size_t*) @nogc nothrow;
	VkResult vmaCheckPoolCorruption(VmaAllocator, VmaPool) @nogc nothrow;

	alias VmaAllocation = VmaAllocation_T*;
	struct VmaAllocation_T;

	struct VmaAllocationInfo {
		uint32_t memoryType;
		VkDeviceMemory deviceMemory;
		VkDeviceSize offset;
		VkDeviceSize size;
		void* pMappedData;
		void* pUserData;
	}

	VkResult vmaAllocateMemory(VmaAllocator, const(VkMemoryRequirements)*, const(VmaAllocationCreateInfo)*,
			VmaAllocation*, VmaAllocationInfo*) @nogc nothrow;
	VkResult vmaAllocateMemoryForBuffer(VmaAllocator, VkBuffer, const(VmaAllocationCreateInfo)*, VmaAllocation*, VmaAllocationInfo*) @nogc nothrow;
	VkResult vmaAllocateMemoryForImage(VmaAllocator, VkImage, const(VmaAllocationCreateInfo)*, VmaAllocation*, VmaAllocationInfo*) @nogc nothrow;
	void vmaFreeMemory(VmaAllocator, VmaAllocation) @nogc nothrow;
	void vmaGetAllocationInfo(VmaAllocator, VmaAllocation, VmaAllocationInfo*) @nogc nothrow;
	VkBool32 vmaTouchAllocation(VmaAllocator, VmaAllocation) @nogc nothrow;
	void vmaSetAllocationUserData(VmaAllocator, VmaAllocation, void*) @nogc nothrow;
	void vmaCreateLostAllocation(VmaAllocator, VmaAllocation*) @nogc nothrow;
	VkResult vmaMapMemory(VmaAllocator, VmaAllocation, void**) @nogc nothrow;
	void vmaUnmapMemory(VmaAllocator, VmaAllocation) @nogc nothrow;
	void vmaFlushAllocation(VmaAllocator, VmaAllocation, VkDeviceSize, VkDeviceSize) @nogc nothrow;
	void vmaInvalidateAllocation(VmaAllocator, VmaAllocation, VkDeviceSize, VkDeviceSize) @nogc nothrow;
	VkResult vmaCheckCorruption(VmaAllocator, uint32_t) @nogc nothrow;

	struct VmaDefragmentationInfo {
		VkDeviceSize maxBytesToMove;
		uint32_t maxAllocationsToMove;
	}

	struct VmaDefragmentationStats {
		VkDeviceSize bytesMoved;
		VkDeviceSize bytesFreed;
		uint32_t allocationsMoved;
		uint32_t deviceMemoryBlocksFreed;
	}

	VkResult vmaDefragment(VmaAllocator, VmaAllocation*, size_t, VkBool32*, const(VmaDefragmentationInfo)*, VmaDefragmentationStats*) @nogc nothrow;
	VkResult vmaBindBufferMemory(VmaAllocator, VmaAllocation, VkBuffer) @nogc nothrow;
	VkResult vmaBindImageMemory(VmaAllocator, VmaAllocation, VkImage) @nogc nothrow;
	VkResult vmaCreateBuffer(VmaAllocator, const(VkBufferCreateInfo)*, const(VmaAllocationCreateInfo)*, VkBuffer*,
			VmaAllocation*, VmaAllocationInfo*) @nogc nothrow;
	void vmaDestroyBuffer(VmaAllocator, VkBuffer, VmaAllocation) @nogc nothrow;
	VkResult vmaCreateImage(VmaAllocator, const(VkImageCreateInfo)*, const(VmaAllocationCreateInfo)*, VkImage*,
			VmaAllocation*, VmaAllocationInfo*) @nogc nothrow;
	void vmaDestroyImage(VmaAllocator, VkImage, VmaAllocation) @nogc nothrow;
}
