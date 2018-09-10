module rebel.renderer.internal.vk.__template__;

__EOF__  //

import rebel.renderer;
import erupted;

import rebel.renderer.internal.vk;

struct VK__TEMPLATE__Data {
	__TEMPLATE__Data base;
	alias base this;

	__TEMPLATE__Builder builder;
	VKDevice * device;

	this(const ref __TEMPLATE__Builder builder, VKDevice * device) {
		this.builder = builder;
		this.device = device;
		create();
	}

	void create() {
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

static assert(isCorrectVulkanData!VK__TEMPLATE__Data);
