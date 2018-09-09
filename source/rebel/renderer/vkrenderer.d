module rebel.renderer.vkrenderer;

import rebel.config;
import rebel.renderer;
import rebel.view;
import rebel.handle;

import erupted;
import erupted.dispatch_device;

import rebel.renderer.internal.vk;

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
	} catch (Exception) {
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
		_createDevice();
	}

	~this() {
		_shaderModules.clear;
		_pipelines.clear;
		_renderPasses.clear;
		_framebuffers.clear;
		_images.clear;
		_imageTemplates.clear;

		_device.destroy;

		debug DestroyDebugReportCallbackEXT(_instance, _debugCallback, null);

		vkDestroySurfaceKHR(_instance, _surface, null);
		vkDestroyInstance(_instance, null);
	}

	void newFrame() {
	}

	void finalize() {
	}

	// dfmt off
	Framebuffer construct(ref FramebufferBuilder builder) { return _framebuffers.create(builder, &_device); }
	Image construct(ref ImageBuilder builder) { return _images.create(builder, &_device); }
	ImageTemplate construct(ref ImageTemplateBuilder builder) { return _imageTemplates.create(builder, &_device); }
	Pipeline construct(ref PipelineBuilder builder) { return _pipelines.create(builder, &_device); }
	RenderPass construct(ref RenderPassBuilder builder) { return _renderPasses.create(builder, &_device); }
	ShaderModule construct(ref ShaderModuleBuilder builder) { return _shaderModules.create(builder, &_device); }

	// Custom
	Image construct(ref ImageBuilder builder, VkImage image) { return _images.create(builder, &_device, image); }

	Framebuffer.Ref get(Framebuffer handler) { return _framebuffers.get(handler); }
	Image.Ref get(Image handler) { return _images.get(handler); }
	ImageTemplate.Ref get(ImageTemplate handler) { return _imageTemplates.get(handler); }
	Pipeline.Ref get(Pipeline handler) { return _pipelines.get(handler); }
	RenderPass.Ref get(RenderPass handler) { return _renderPasses.get(handler); }
	ShaderModule.Ref get(ShaderModule handler) { return _shaderModules.get(handler); }

	void destruct(Framebuffer handler) { return _framebuffers.remove(handler); }
	void destruct(Image handler) { return _images.remove(handler); }
	void destruct(ImageTemplate handler) { return _imageTemplates.remove(handler); }
	void destruct(Pipeline handler) { return _pipelines.remove(handler); }
	void destruct(RenderPass handler) { return _renderPasses.remove(handler); }
	void destruct(ShaderModule handler) { return _shaderModules.remove(handler); }
	// dfmt on

	@property ImageTemplate framebufferImageTemplate() {
		return _device.fbImageTemplate;
	}

	@property void outputRenderPass(RenderPass renderpass) {
		_device.outputRenderPass = renderpass;
	}

	@property Framebuffer[] outputFramebuffers() {
		return _device.framebuffers;
	}

	@property size_t outputToIdx() {
		return _device.nextFrameIdx;
	}

	@property RendererType renderType() const {
		return RendererType.vulkan;
	}

private:
	string _gameName;
	Version _gameVersion;
	IVulkanView _view;
	VkInstance _instance;
	VkDebugReportCallbackEXT _debugCallback;

	VkSurfaceKHR _surface;

	VKDevice _device;

	HandleStorage!(Framebuffer, VKFramebufferData) _framebuffers;
	HandleStorage!(Image, VKImageData) _images;
	HandleStorage!(ImageTemplate, VKImageTemplateData) _imageTemplates;
	HandleStorage!(Pipeline, VKPipelineData) _pipelines;
	HandleStorage!(RenderPass, VKRenderPassData) _renderPasses;
	HandleStorage!(ShaderModule, VKShaderModuleData) _shaderModules;

	void _recreate() {
		import std.typecons : tuple;

		_device.dispatch.DeviceWaitIdle();
		_device.recreate();
		//_createVulkanSwapChain();
		//_createVulkanImageViews();
		//_createFramebuffers();

		void recreate(T)(ref T storage) {
			foreach (ref obj; storage) {
				obj.cleanup();
				obj.create();
			}
		}

		recreate(_renderPasses);
		recreate(_pipelines);
		//createCommandBuffers();
	}

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

	void _createDevice() {
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
			if (isDeviceSuitable(device, qi, sci)) { // TODO: Rank the GPUs
				_device.initialize(device, qi, sci, _surface);
				return;
			}
		}

		assert(0, "Failed to find suitable physical device!");
	}
}
