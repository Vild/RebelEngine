module rebel.renderer.internal.vk.device;

import erupted;
import erupted.dispatch_device;

struct QueueInformation {
	uint graphics = uint.max;
	uint present = uint.max;
	bool completed() {
		return graphics != uint.max && present != uint.max;
	}
}

struct SwapChainInformation {
	VkSurfaceCapabilities2KHR capabilities;
	VkSurfaceFormat2KHR[] formats;
	VkPresentModeKHR[] presentModes;
}

struct Device {
	VkPhysicalDevice device;
	QueueInformation queueInfo;
	SwapChainInformation swapChainInfo;

	DispatchDevice dispatch;

	VkQueue graphicsQueue;
	VkQueue presentQueue;

	VkSurfaceFormat2KHR swapChainImageFormat;
	VkExtent2D swapChainExtent;
	VkSwapchainKHR swapChain;
	VkImage[] swapChainImages;
	VkImageView[] swapChainImageViews;
	VkFramebuffer[] swapChainFramebuffers;

	VkDescriptorPool descriptorPool;

	~this() {
		if (!device) {
			import std.stdio : stderr;

			stderr.writeln("Trying to free a invalid object :c");
			return;
		}

		foreach (VkImageView imageView; swapChainImageViews)
			dispatch.DestroyImageView(imageView);

		swapChainImageViews.destroy;
		swapChainImages.destroy;

		dispatch.DestroySwapchainKHR(swapChain);
		dispatch.DestroyDevice();
	}
}
