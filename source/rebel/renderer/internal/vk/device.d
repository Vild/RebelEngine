module rebel.renderer.internal.vk.device;

import erupted;
import erupted.dispatch_device;

import rebel.engine;
import rebel.view;
import rebel.renderer;
import rebel.renderer.vkrenderer;
import rebel.renderer.internal.vk;

import dlsl.vector;

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

struct VKDevice {
	VKRenderer renderer;
	IView view;

	// Physical device
	VkPhysicalDevice device;
	QueueInformation queueInfo;
	SwapChainInformation swapChainInfo;
	VkSurfaceKHR surface;

	VkPhysicalDeviceProperties2 physicalProperties;
	VkPhysicalDeviceFeatures2 physicalFeatures;
	VkPhysicalDeviceMemoryProperties2 physicalMemoryProperties;
	VkQueueFamilyProperties2[] physicalQueueFamilyProperties;
	string[] physicalSupportedExtensions;

	// Logical device
	DispatchDevice dispatch;

	VkQueue graphicsQueue;
	VkQueue presentQueue;

	VkSurfaceFormat2KHR swapChainImageFormat;
	VkExtent2D swapChainExtent;
	VkSwapchainKHR swapChain;
	VkImage[] swapChainImages;

	ImageTemplate fbImageTemplate;
	Image[] fbImages;
	RenderPass fbRenderPass;
	Framebuffer[] framebuffers;
	size_t nextFrameIdx;

	VkDescriptorPool descriptorPool;

	void initialize(VkPhysicalDevice device, QueueInformation queueInfo, SwapChainInformation swapChainInfo, VkSurfaceKHR surface) {
		import std.string : fromStringz;

		renderer = cast(VKRenderer)Engine.instance.renderer;
		view = Engine.instance.view;

		this.device = device;
		this.queueInfo = queueInfo;
		this.swapChainInfo = swapChainInfo;
		this.surface = surface;

		vkGetPhysicalDeviceProperties2(device, &physicalProperties);
		vkGetPhysicalDeviceFeatures2(device, &physicalFeatures);
		vkGetPhysicalDeviceMemoryProperties2(device, &physicalMemoryProperties);

		physicalQueueFamilyProperties = getVKList(vkGetPhysicalDeviceQueueFamilyProperties2, device);

		auto extensions = getVKList(vkEnumerateDeviceExtensionProperties, device, null);
		physicalSupportedExtensions.length = extensions.length;

		foreach (idx, VkExtensionProperties extension; extensions)
			physicalSupportedExtensions[idx] = extension.extensionName.ptr.fromStringz.idup;

		_createLogicalDevice();
		_createSwapChain();
		_createImageViews();
	}

	~this() {
		if (device == VK_NULL_HANDLE) // On opAssign or when the GC, for some reason, calls this destructor
			return;

		/*foreach (Framebuffer fb; framebuffers)
			renderer.destruct(fb);
		framebuffers.length = 0;
		foreach (Image i; fbImages)
			renderer.destruct(i);
		fbImages.length = 0;
		renderer.destruct(fbImageTemplate);*/

		dispatch.DestroySwapchainKHR(swapChain);
		dispatch.DestroyDevice();
		device = VK_NULL_HANDLE;
	}

	@disable this(this);

	@property void outputRenderPass(RenderPass renderpass) {
		assert(!fbRenderPass.isValid); //TODO: allow this
		fbRenderPass = renderpass;
		_createFramebuffers();
	}

	uint getMemoryType(uint typeBits, VkMemoryPropertyFlags properties, bool* foundIt = null) {
		foreach (i; 0 .. physicalMemoryProperties.memoryProperties.memoryTypeCount) {
			if (typeBits & 0b1)
				if ((physicalMemoryProperties.memoryProperties.memoryTypes[i].propertyFlags & properties) == properties) {
					if (foundIt)
						*foundIt = true;
					return i;
				}

			typeBits >>= 1;
		}

		if (foundIt)
			*foundIt = false;
		return uint.max;
	}

	void recreate() {
		//TODO:
	}

private:
	void _createLogicalDevice() {
		float queuePriority = 1.0f;

		// TODO: if queue index is same, only create one CreateInfo with count of two
		// dfmt off
		VkDeviceQueueCreateInfo[] queueCreateInfos = [
			{ flags: VkDeviceQueueCreateFlagBits.VK_DEVICE_QUEUE_CREATE_PROTECTED_BIT, queueFamilyIndex: queueInfo.graphics, queueCount: 1, pQueuePriorities: &queuePriority },
			{ flags: VkDeviceQueueCreateFlagBits.VK_DEVICE_QUEUE_CREATE_PROTECTED_BIT, queueFamilyIndex: queueInfo.present, queueCount: 1, pQueuePriorities: &queuePriority }
		];
		// dfmt on

		const(char)*[] layers;
		debug layers ~= "VK_LAYER_LUNARG_standard_validation";

		const(char)*[] extensions = [VK_KHR_SWAPCHAIN_EXTENSION_NAME];

		VkPhysicalDeviceFeatures2 deviceFeatures;
		VkDeviceCreateInfo deviceCreateInfo;
		deviceCreateInfo.pNext = &deviceFeatures;
		deviceCreateInfo.queueCreateInfoCount = cast(uint)queueCreateInfos.length;
		deviceCreateInfo.pQueueCreateInfos = &queueCreateInfos[0];
		deviceCreateInfo.enabledLayerCount = cast(uint)layers.length;
		deviceCreateInfo.ppEnabledLayerNames = &layers[0];
		deviceCreateInfo.enabledExtensionCount = cast(uint)extensions.length;
		deviceCreateInfo.ppEnabledExtensionNames = &extensions[0];
		deviceCreateInfo.pEnabledFeatures = null;

		VkDevice tmpDevice;
		vkAssert(vkCreateDevice(device, &deviceCreateInfo, null, &tmpDevice), "Create device failed!");
		dispatch = DispatchDevice(tmpDevice);

		VkDeviceQueueInfo2 deviceQueueInfo;
		deviceQueueInfo.flags = VkDeviceQueueCreateFlagBits.VK_DEVICE_QUEUE_CREATE_PROTECTED_BIT;
		deviceQueueInfo.queueFamilyIndex = queueInfo.graphics;
		deviceQueueInfo.queueIndex = 0;

		dispatch.GetDeviceQueue2(&deviceQueueInfo, &graphicsQueue);
		assert(graphicsQueue, "Graphic queue is null!");

		deviceQueueInfo.queueFamilyIndex = queueInfo.present;
		dispatch.GetDeviceQueue2(&deviceQueueInfo, &presentQueue);
		assert(presentQueue, "Present queue is null!");
	}

	void _createSwapChain() {
		VkSurfaceFormat2KHR surfaceFormat = (VkSurfaceFormat2KHR[] formats) {
			if (formats.length == 1 && formats[0].surfaceFormat.format == VkFormat.VK_FORMAT_UNDEFINED) {
				VkSurfaceFormat2KHR format;
				format.surfaceFormat.format = VkFormat.VK_FORMAT_B8G8R8A8_UNORM;
				format.surfaceFormat.colorSpace = VkColorSpaceKHR.VK_COLOR_SPACE_SRGB_NONLINEAR_KHR;
				return format;
			}

			foreach (ref VkSurfaceFormat2KHR f; formats)
				if (f.surfaceFormat.format == VkFormat.VK_FORMAT_B8G8R8A8_UNORM
						&& f.surfaceFormat.colorSpace == VkColorSpaceKHR.VK_COLOR_SPACE_SRGB_NONLINEAR_KHR)
					return f;

			return formats[0];
		}(swapChainInfo.formats);
		swapChainImageFormat = surfaceFormat;

		VkPresentModeKHR presentMode = (VkPresentModeKHR[] presentModes) {
			VkPresentModeKHR bestMode = VkPresentModeKHR.VK_PRESENT_MODE_FIFO_KHR;
			foreach (VkPresentModeKHR pm; presentModes)
				if (pm == VkPresentModeKHR.VK_PRESENT_MODE_MAILBOX_KHR)
					return pm;
				else if (pm == VkPresentModeKHR.VK_PRESENT_MODE_IMMEDIATE_KHR)
					bestMode = pm;
			return bestMode;
		}(swapChainInfo.presentModes);

		VkExtent2D extent = (ref VkSurfaceCapabilitiesKHR capabilities) {
			import std.algorithm : max, min;

			if (capabilities.currentExtent.width != uint.max)
				return capabilities.currentExtent;

			VkExtent2D actualExtent = VkExtent2D(view.size.x, view.size.y);

			actualExtent.width = max(capabilities.minImageExtent.width, min(capabilities.maxImageExtent.width, actualExtent.width));
			actualExtent.height = max(capabilities.minImageExtent.height, min(capabilities.maxImageExtent.height, actualExtent.height));

			return actualExtent;

		}(swapChainInfo.capabilities.surfaceCapabilities);
		swapChainExtent = extent;

		uint imageCount = swapChainInfo.capabilities.surfaceCapabilities.minImageCount + 1;
		if (swapChainInfo.capabilities.surfaceCapabilities.maxImageCount > 0
				&& imageCount > swapChainInfo.capabilities.surfaceCapabilities.maxImageCount)
			imageCount = swapChainInfo.capabilities.surfaceCapabilities.maxImageCount;

		{
			ImageTemplateBuilder builder;
			builder.format = swapChainImageFormat.surfaceFormat.format.translate;
			builder.samples = 1;
			builder.size = uvec2(swapChainExtent.width, swapChainExtent.height);
			builder.usage = ImageUsage.presentAttachment;

			fbImageTemplate = renderer.construct(builder);
		}

		VkSwapchainCreateInfoKHR createInfo;
		createInfo.surface = surface;
		createInfo.minImageCount = imageCount;
		createInfo.imageFormat = surfaceFormat.surfaceFormat.format;
		createInfo.imageColorSpace = surfaceFormat.surfaceFormat.colorSpace;
		createInfo.imageExtent = extent;
		createInfo.imageArrayLayers = 1;
		createInfo.imageUsage = VkImageUsageFlagBits.VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT;

		uint[] queueFamilyIndices = [queueInfo.graphics, queueInfo.present];

		if (queueInfo.graphics != queueInfo.present) {
			createInfo.imageSharingMode = VkSharingMode.VK_SHARING_MODE_CONCURRENT;
			createInfo.queueFamilyIndexCount = 2;
			createInfo.pQueueFamilyIndices = &queueFamilyIndices[0];
		} else {
			createInfo.imageSharingMode = VkSharingMode.VK_SHARING_MODE_EXCLUSIVE;
			createInfo.queueFamilyIndexCount = 0; // Optional
			createInfo.pQueueFamilyIndices = null; // Optional
		}

		createInfo.preTransform = swapChainInfo.capabilities.surfaceCapabilities.currentTransform;
		createInfo.compositeAlpha = VkCompositeAlphaFlagBitsKHR.VK_COMPOSITE_ALPHA_OPAQUE_BIT_KHR;
		createInfo.presentMode = presentMode;
		createInfo.clipped = true;
		createInfo.oldSwapchain = swapChain;

		dispatch.CreateSwapchainKHR(&createInfo, &swapChain);
		assert(swapChain, "Create swapchain failed!");

		swapChainImages = getVKList(&dispatch.GetSwapchainImagesKHR, swapChain);
	}

	void _createImageViews() {
		//swapChainImageViews.length = swapChainImages.length;
		fbImages.length = swapChainImages.length;

		ImageBuilder builder;
		builder.imageTemplate = fbImageTemplate;
		foreach (i, image; swapChainImages)
			fbImages[i] = renderer.construct(builder, image);

		/*VkImageViewCreateInfo createInfo;
			createInfo.image = image;
			createInfo.viewType = VkImageViewType.VK_IMAGE_VIEW_TYPE_2D;
			createInfo.format = swapChainImageFormat.surfaceFormat.format;
			createInfo.components.r = VkComponentSwizzle.VK_COMPONENT_SWIZZLE_IDENTITY;
			createInfo.components.g = VkComponentSwizzle.VK_COMPONENT_SWIZZLE_IDENTITY;
			createInfo.components.b = VkComponentSwizzle.VK_COMPONENT_SWIZZLE_IDENTITY;
			createInfo.components.a = VkComponentSwizzle.VK_COMPONENT_SWIZZLE_IDENTITY;
			createInfo.subresourceRange.aspectMask = VkImageAspectFlagBits.VK_IMAGE_ASPECT_COLOR_BIT;
			createInfo.subresourceRange.baseMipLevel = 0;
			createInfo.subresourceRange.levelCount = 1;
			createInfo.subresourceRange.baseArrayLayer = 0;
			createInfo.subresourceRange.layerCount = 1;
			dispatch.CreateImageView(&createInfo, &swapChainImageViews[i]);*/
	}

	void _createFramebuffers() {
		assert(fbRenderPass.isValid);
		framebuffers.length = fbImages.length;

		foreach (i, Image image; fbImages) {
			FramebufferBuilder builder;
			builder.attachments = [image];
			builder.dimension = uvec3(swapChainExtent.width, swapChainExtent.height, 1);
			builder.renderPass = fbRenderPass;
			framebuffers[i] = renderer.construct(builder);
		}
	}
}
