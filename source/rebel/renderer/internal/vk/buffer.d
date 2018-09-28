module rebel.renderer.internal.vk.buffer;

import rebel.renderer;
import erupted;

import rebel.renderer.internal.vk;

struct VKBufferData {
	BufferData base;
	alias base this;

	BufferBuilder builder;
	VKDevice* device;

	VkBuffer buffer;
	VkDeviceMemory memory;

	this(const ref BufferBuilder builder, VKDevice* device) {
		base.map = &map;
		base.unmap = &unmap;
		this.builder = builder;
		this.device = device;
		create();
	}

	void create() {
		VkBufferCreateInfo createInfo;
		createInfo.size = builder.size;
		createInfo.usage = builder.usage.translate;
		createInfo.sharingMode = builder.sharing.translate;

		vkAssert(device.dispatch.CreateBuffer(&createInfo, &buffer), "Failed to create buffer!");
		setVkObjectName(device, VK_OBJECT_TYPE_BUFFER, buffer, builder.name);

		VkMemoryRequirements memRequirements;
		device.dispatch.GetBufferMemoryRequirements(buffer, &memRequirements);

		VkMemoryAllocateInfo allocInfo;
		allocInfo.allocationSize = memRequirements.size;
		allocInfo.memoryTypeIndex = device.getMemoryType(memRequirements.memoryTypeBits,
				VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT | VK_MEMORY_PROPERTY_HOST_COHERENT_BIT);

		vkAssert(device.dispatch.AllocateMemory(&allocInfo, &memory), "Failed to allocate buffer memory!");
		setVkObjectName(device, VK_OBJECT_TYPE_DEVICE_MEMORY, memory, builder.name);

		vkAssert(device.dispatch.BindBufferMemory(buffer, memory, 0), "Failed to bind memory to buffer");
	}

	~this() {
		if (!device)
			return;
		cleanup();
		device = null;
	}

	void cleanup() {
		device.dispatch.DestroyBuffer(buffer);
		device.dispatch.FreeMemory(memory);
	}

	private size_t refCounter;
	void[] map() {
		if (!refCounter) {
			void* ptr;
			vkAssert(device.dispatch.MapMemory(memory, 0, builder.size, 0, &ptr), "Failed to map memory");
			base.deviceMemory = ptr[0 .. builder.size];
		}
		refCounter++;
		return base.deviceMemory;
	}

	void unmap() {
		refCounter--;
		if (!refCounter) {
			device.dispatch.UnmapMemory(memory);
			base.deviceMemory = null;
		}
	}
}

static assert(isCorrectVulkanData!VKBufferData);
