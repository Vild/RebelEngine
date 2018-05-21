module rebel.renderer.vkrenderer;

import rebel.config;
import rebel.renderer;
import rebel.view;

import erupted;
import erupted.dispatch_device;

import rebel.renderer.internal.vkhelper;

interface IVulkanView : IView {
	@property PFN_vkGetInstanceProcAddr getVkGetInstanceProcAddr();
	VkSurfaceKHR createVulkanSurface(VkInstance instance);

	@property const(char)*[] getRequiredVulkanInstanceExtensions();
}

interface IVulkanRenderer : IRenderer {
}

extern (C) static VkBool32 vulkanDebugCallback(VkDebugReportFlagsEXT flags, VkDebugReportObjectTypeEXT objType, ulong obj,
		size_t location, int code, const char* layerPrefix, const char* msg, void* userData) nothrow {

	import std.stdio : stderr, fprintf;
	import std.string : fromStringz;

	try {
		stderr.writefln("Validation layer: %s", msg.fromStringz);
	}
	catch (Exception) {
	}

	return VK_FALSE;
}

final class VKRenderer : IVulkanRenderer {
public:
	this(string gameName, Version gameVersion) {
		_gameName = gameName;
		_gameVersion = gameVersion;
	}

	void initialize(IView view_) {
		auto view = cast(IVulkanView)view_;
		assert(view);
		_view = view;
		loadGlobalLevelFunctions(view.getVkGetInstanceProcAddr);
		_createInstance();
		loadInstanceLevelFunctions(_instance);
		_surface = view.createVulkanSurface(_instance);
		_createVulkanPhysicalDevice();
		_createVulkanLogicalDevice();
		_createVulkanSwapChain();
		_createVulkanImageViews();
	}

	~this() {
		// TODO: Fix crashes

		foreach (ref Device d; _devices)
			d.destroy;
		_devices.destroy;

		debug DestroyDebugReportCallbackEXT(_instance, _debugCallback, null);

		vkDestroySurfaceKHR(_instance, _surface, null);
		vkDestroyInstance(_instance, null);
	}

	void newFrame() {
	}

	void finalize() {
	}

	@property RendererType renderType() const {
		return RendererType.vulkan;
	}

private:
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

	string _gameName;
	Version _gameVersion;
	IVulkanView _view;
	VkInstance _instance;
	VkDebugReportCallbackEXT _debugCallback;

	VkSurfaceKHR _surface;

	Device[] _devices;

	void _createInstance() {
		import std.stdio;
		import std.string : toStringz;

		writefln("Available Extensions:");
		auto availableExtensions = getVKList(vkEnumerateInstanceExtensionProperties, null);
		foreach (const ref VkExtensionProperties e; availableExtensions)
			writefln("\t%s Version %d.%d.%d", e.extensionName, VK_VERSION_MAJOR(e.specVersion),
					VK_VERSION_MINOR(e.specVersion), VK_VERSION_PATCH(e.specVersion));
		writefln("Available Layers:");
		auto availableLayers = getVKList(vkEnumerateInstanceLayerProperties);
		foreach (const ref VkLayerProperties l; availableLayers)
			writefln("\t%s: Version %d.%d.%d, ImplVersion %d.%d.%d\n\t\t%s", l.layerName, VK_VERSION_MAJOR(l.specVersion),
					VK_VERSION_MINOR(l.specVersion), VK_VERSION_PATCH(l.specVersion), VK_VERSION_MAJOR(l.implementationVersion),
					VK_VERSION_MINOR(l.implementationVersion), VK_VERSION_PATCH(l.implementationVersion), l.description);
		VkApplicationInfo appInfo;
		appInfo.pApplicationName = _gameName.toStringz;
		appInfo.applicationVersion = VK_MAKE_VERSION(_gameVersion.major, _gameVersion.minor, _gameVersion.patch);
		appInfo.pEngineName = engineName.toStringz;
		appInfo.engineVersion = VK_MAKE_VERSION(engineVersion.major, engineVersion.minor, engineVersion.patch);
		appInfo.apiVersion = VK_API_VERSION_1_1;

		VkInstanceCreateInfo createInfo;
		createInfo.pApplicationInfo = &appInfo;
		const(char)*[] layers;
		const(char)*[] extensions = _view.getRequiredVulkanInstanceExtensions();
		extensions ~= "VK_KHR_get_surface_capabilities2";
		extensions ~= "VK_KHR_get_physical_device_properties2";
		debug extensions ~= VK_EXT_DEBUG_REPORT_EXTENSION_NAME;
		debug layers ~= "VK_LAYER_LUNARG_standard_validation";
		createInfo.enabledLayerCount = cast(uint)layers.length;
		createInfo.ppEnabledLayerNames = &layers[0];
		createInfo.enabledExtensionCount = cast(uint)extensions.length;
		createInfo.ppEnabledExtensionNames = &extensions[0];

		vkAssert(vkCreateInstance(&createInfo, null, &_instance), "failed to create instance!");

		debug {
			// VK_LAYER_LUNARG_standard_validation HOOK callback
			VkDebugReportCallbackCreateInfoEXT createInfo2;
			createInfo2.flags = VK_DEBUG_REPORT_ERROR_BIT_EXT | VK_DEBUG_REPORT_WARNING_BIT_EXT;
			createInfo2.pfnCallback = assumeNoGC(&vulkanDebugCallback); // can fail. check for VK_SUCCESS
			vkAssert(CreateDebugReportCallbackEXT(_instance, &createInfo2, null, &_debugCallback), "Failed to create debug report callback");
		}
	}

	void _createVulkanPhysicalDevice() {
		bool isDeviceSuitable(VkPhysicalDevice device, ref QueueInformation qi, ref SwapChainInformation sci) {
			{
				// vkPhysicalDeviceProperties deviceProperties = device.getProperties();
				VkPhysicalDeviceFeatures2 deviceFeatures;
				vkGetPhysicalDeviceFeatures2(device, &deviceFeatures);

				if (!deviceFeatures.features.geometryShader)
					return false;
				VkQueueFamilyProperties2[] queueFamilies = getVKList(vkGetPhysicalDeviceQueueFamilyProperties2, device);
				foreach (uint i, VkQueueFamilyProperties2 q; queueFamilies) {
					// TODO: Rate queues
					VkBool32 hasPresent;
					vkGetPhysicalDeviceSurfaceSupportKHR(device, i, _surface, &hasPresent);
					if (!q.queueFamilyProperties.queueCount)
						continue;
					if (q.queueFamilyProperties.queueFlags & VkQueueFlagBits.VK_QUEUE_GRAPHICS_BIT)
						qi.graphics = i;
					if (hasPresent)
						qi.present = i;
				}
			}

			{
				// dfmt off
				VkPhysicalDeviceSurfaceInfo2KHR info = {surface: _surface};
				// dfmt on

				vkGetPhysicalDeviceSurfaceCapabilities2KHR(device, &info, &sci.capabilities);
				sci.formats = getVKList(vkGetPhysicalDeviceSurfaceFormats2KHR, device, &info);
				sci.presentModes = getVKList(vkGetPhysicalDeviceSurfacePresentModesKHR, device, _surface);
			}

			return qi.completed() && sci.formats.length && sci.presentModes.length;
		}

		foreach (VkPhysicalDevice device; getVKList(vkEnumeratePhysicalDevices, _instance)) {
			QueueInformation qi;
			SwapChainInformation sci;
			if (isDeviceSuitable(device, qi, sci))
				_devices ~= Device(device, qi, sci);
		}

		assert(_devices.length, "Failed to find suitable physical devices!");
	}

	void _createVulkanLogicalDevice() {
		foreach (ref Device device; _devices) {
			float queuePriority = 1.0f;

			// TODO: if queue index is same, only create one CreateInfo with count of two
			// dfmt off
			VkDeviceQueueCreateInfo[] queueCreateInfos = [
				{ flags: VkDeviceQueueCreateFlagBits.VK_DEVICE_QUEUE_CREATE_PROTECTED_BIT, queueFamilyIndex: device.queueInfo.graphics, queueCount: 1, pQueuePriorities: &queuePriority },
				{ flags: VkDeviceQueueCreateFlagBits.VK_DEVICE_QUEUE_CREATE_PROTECTED_BIT, queueFamilyIndex: device.queueInfo.present, queueCount: 1, pQueuePriorities: &queuePriority }
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
			vkAssert(vkCreateDevice(device.device, &deviceCreateInfo, null, &tmpDevice), "Create device failed!");
			device.dispatch = DispatchDevice(tmpDevice);

			VkDeviceQueueInfo2 queueInfo;
			queueInfo.flags = VkDeviceQueueCreateFlagBits.VK_DEVICE_QUEUE_CREATE_PROTECTED_BIT;
			queueInfo.queueFamilyIndex = device.queueInfo.graphics;
			queueInfo.queueIndex = 0;

			device.dispatch.GetDeviceQueue2(&queueInfo, &device.graphicsQueue);
			assert(device.graphicsQueue, "Graphic queue is null!");

			queueInfo.queueFamilyIndex = device.queueInfo.present;
			device.dispatch.GetDeviceQueue2(&queueInfo, &device.presentQueue);
			assert(device.presentQueue, "Present queue is null!");
		}
	}

	void _createVulkanSwapChain() {
		foreach (ref Device device; _devices) {
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
			}(device.swapChainInfo.formats);
			device.swapChainImageFormat = surfaceFormat;

			VkPresentModeKHR presentMode = (VkPresentModeKHR[] presentModes) {
				VkPresentModeKHR bestMode = VkPresentModeKHR.VK_PRESENT_MODE_FIFO_KHR;
				foreach (VkPresentModeKHR pm; presentModes)
					if (pm == VkPresentModeKHR.VK_PRESENT_MODE_MAILBOX_KHR)
						return pm;
					else if (pm == VkPresentModeKHR.VK_PRESENT_MODE_IMMEDIATE_KHR)
						bestMode = pm;
				return bestMode;
			}(device.swapChainInfo.presentModes);

			VkExtent2D extent = (ref VkSurfaceCapabilitiesKHR capabilities) {
				import std.algorithm : max, min;

				if (capabilities.currentExtent.width != uint.max)
					return capabilities.currentExtent;

				VkExtent2D actualExtent = VkExtent2D(_view.size.x, _view.size.y);

				actualExtent.width = max(capabilities.minImageExtent.width, min(capabilities.maxImageExtent.width, actualExtent.width));
				actualExtent.height = max(capabilities.minImageExtent.height, min(capabilities.maxImageExtent.height, actualExtent.height));

				return actualExtent;

			}(device.swapChainInfo.capabilities.surfaceCapabilities);
			device.swapChainExtent = extent;

			uint imageCount = device.swapChainInfo.capabilities.surfaceCapabilities.minImageCount + 1;
			if (device.swapChainInfo.capabilities.surfaceCapabilities.maxImageCount > 0
					&& imageCount > device.swapChainInfo.capabilities.surfaceCapabilities.maxImageCount)
				imageCount = device.swapChainInfo.capabilities.surfaceCapabilities.maxImageCount;

			VkSwapchainCreateInfoKHR createInfo;
			createInfo.surface = _surface;
			createInfo.minImageCount = imageCount;
			createInfo.imageFormat = surfaceFormat.surfaceFormat.format;
			createInfo.imageColorSpace = surfaceFormat.surfaceFormat.colorSpace;
			createInfo.imageExtent = extent;
			createInfo.imageArrayLayers = 1;
			createInfo.imageUsage = VkImageUsageFlagBits.VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT;

			uint[] queueFamilyIndices = [device.queueInfo.graphics, device.queueInfo.present];

			if (device.queueInfo.graphics != device.queueInfo.present) {
				createInfo.imageSharingMode = VkSharingMode.VK_SHARING_MODE_CONCURRENT;
				createInfo.queueFamilyIndexCount = 2;
				createInfo.pQueueFamilyIndices = &queueFamilyIndices[0];
			} else {
				createInfo.imageSharingMode = VkSharingMode.VK_SHARING_MODE_EXCLUSIVE;
				createInfo.queueFamilyIndexCount = 0; // Optional
				createInfo.pQueueFamilyIndices = null; // Optional
			}

			createInfo.preTransform = device.swapChainInfo.capabilities.surfaceCapabilities.currentTransform;
			createInfo.compositeAlpha = VkCompositeAlphaFlagBitsKHR.VK_COMPOSITE_ALPHA_OPAQUE_BIT_KHR;
			createInfo.presentMode = presentMode;
			createInfo.clipped = true;
			createInfo.oldSwapchain = VkSwapchainKHR();

			device.dispatch.CreateSwapchainKHR(&createInfo, &device.swapChain);
			assert(device.swapChain, "Create swapchain failed!");

			device.swapChainImages = getVKList(&device.dispatch.GetSwapchainImagesKHR, device.swapChain);
		}
	}

	void _createVulkanImageViews() {
		foreach (ref Device device; _devices) {
			device.swapChainImageViews.length = device.swapChainImages.length;

			foreach (i, image; device.swapChainImages) {
				VkImageViewCreateInfo createInfo;
				createInfo.image = image;
				createInfo.viewType = VkImageViewType.VK_IMAGE_VIEW_TYPE_2D;
				createInfo.format = device.swapChainImageFormat.surfaceFormat.format;
				createInfo.components.r = VkComponentSwizzle.VK_COMPONENT_SWIZZLE_IDENTITY;
				createInfo.components.g = VkComponentSwizzle.VK_COMPONENT_SWIZZLE_IDENTITY;
				createInfo.components.b = VkComponentSwizzle.VK_COMPONENT_SWIZZLE_IDENTITY;
				createInfo.components.a = VkComponentSwizzle.VK_COMPONENT_SWIZZLE_IDENTITY;
				createInfo.subresourceRange.aspectMask = VkImageAspectFlagBits.VK_IMAGE_ASPECT_COLOR_BIT;
				createInfo.subresourceRange.baseMipLevel = 0;
				createInfo.subresourceRange.levelCount = 1;
				createInfo.subresourceRange.baseArrayLayer = 0;
				createInfo.subresourceRange.layerCount = 1;
				device.dispatch.CreateImageView(&createInfo, &device.swapChainImageViews[i]);
			}
		}
	}
}
