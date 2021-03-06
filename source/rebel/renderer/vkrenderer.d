module rebel.renderer.vkrenderer;

import rebel.config;
import rebel.renderer;
import rebel.view;
import rebel.handle;

import erupted;
import erupted.dispatch_device;

import rebel.renderer.internal.vk;

import vulkan_memory_allocator;

import std.stdio;

interface IVulkanView : IView {
	@property PFN_vkGetInstanceProcAddr getVkGetInstanceProcAddr();
	VkSurfaceKHR createVulkanSurface(VkInstance instance);

	@property const(char)*[] getRequiredVulkanInstanceExtensions();
}

interface IVulkanRenderer : IRenderer {
}

extern (C) static VkBool32 vulkanDebugCallback(VkDebugUtilsMessageSeverityFlagBitsEXT messageSeverity,
		VkDebugUtilsMessageTypeFlagsEXT messageType, const(VkDebugUtilsMessengerCallbackDataEXT)* pCallbackData, void* pUserData) nothrow {
	import std.stdio : stderr;
	import std.string : fromStringz;
	import std.algorithm : map, predSwitch;

	// dfmt off
	alias getColor = (VkDebugUtilsMessageSeverityFlagBitsEXT s) => s.predSwitch(
		VK_DEBUG_UTILS_MESSAGE_SEVERITY_VERBOSE_BIT_EXT, "97", // Bright white
		VK_DEBUG_UTILS_MESSAGE_SEVERITY_INFO_BIT_EXT, "96", // Bright cyan
		VK_DEBUG_UTILS_MESSAGE_SEVERITY_WARNING_BIT_EXT, "93", // Bright yellow
		VK_DEBUG_UTILS_MESSAGE_SEVERITY_ERROR_BIT_EXT, "91", // Bright red
		""
	);
	alias getStyle = (VkDebugUtilsMessageTypeFlagsEXT s) => (cast(VkDebugUtilsMessageTypeFlagBitsEXT)s).predSwitch(
		VK_DEBUG_UTILS_MESSAGE_TYPE_PERFORMANCE_BIT_EXT, ";4",
		""
	);
	alias getSeverity = (VkDebugUtilsMessageSeverityFlagBitsEXT s) => s.predSwitch(
		VK_DEBUG_UTILS_MESSAGE_SEVERITY_VERBOSE_BIT_EXT, "Verbose",
		VK_DEBUG_UTILS_MESSAGE_SEVERITY_INFO_BIT_EXT, "Info",
		VK_DEBUG_UTILS_MESSAGE_SEVERITY_WARNING_BIT_EXT, "Warning",
		VK_DEBUG_UTILS_MESSAGE_SEVERITY_ERROR_BIT_EXT, "Error",
		"<UNKNOWN>"
	);
	alias getType = (VkDebugUtilsMessageTypeFlagsEXT s) => (cast(VkDebugUtilsMessageTypeFlagBitsEXT)s).predSwitch(
		VK_DEBUG_UTILS_MESSAGE_TYPE_GENERAL_BIT_EXT, "General",
		VK_DEBUG_UTILS_MESSAGE_TYPE_VALIDATION_BIT_EXT | VK_DEBUG_UTILS_MESSAGE_TYPE_PERFORMANCE_BIT_EXT, "SPEC | PERF",
		VK_DEBUG_UTILS_MESSAGE_TYPE_VALIDATION_BIT_EXT, "SPEC",
		VK_DEBUG_UTILS_MESSAGE_TYPE_PERFORMANCE_BIT_EXT, "PERF",
		""
	);
	// dfmt on

	try {
		stderr.writefln("\x1b[%s%sm[S:%s][T:%s] ID: %d, Name: %s\x1b[0m", getColor(messageSeverity), getStyle(messageType),
				getSeverity(messageSeverity), getType(messageType), pCallbackData.messageIdNumber, pCallbackData.pMessageIdName.fromStringz);

		const(VkDebugUtilsObjectNameInfoEXT)[] objects = pCallbackData.pObjects[0 .. pCallbackData.objectCount];
		if (objects) {
			stderr.writefln("Objects - Amount: %d:", objects.length);
			foreach (idx, ref obj; objects)
				stderr.writefln("\tObject[%d] - Type: %s, Value: 0x%X, Name: \"%s\"", idx, obj.objectType, obj.objectHandle,
						obj.pObjectName.fromStringz);
		}

		const(VkDebugUtilsLabelEXT)[] cmdBufLabels = pCallbackData.pCmdBufLabels[0 .. pCallbackData.cmdBufLabelCount];
		if (cmdBufLabels) {
			stderr.writefln("CommandBuffer Labels - Amount: %d:", cmdBufLabels.length);
			foreach (idx, ref label; cmdBufLabels)
				stderr.writefln("\tLabel[%d]: - %s {%(%f%|, %)}", idx, label.pLabelName.fromStringz, label.color);
		}

		const(VkDebugUtilsLabelEXT)[] queueLabels = pCallbackData.pQueueLabels[0 .. pCallbackData.queueLabelCount];
		if (queueLabels) {
			stderr.writefln("Queue Labels - Amount: %d:", queueLabels.length);
			foreach (idx, ref label; queueLabels)
				stderr.writefln("\tLabel[%d]: - %s {%(%f%|, %)}", idx, label.pLabelName.fromStringz, label.color);
		}

		stderr.writefln("Message:\n\t%s", pCallbackData.pMessage.fromStringz);
		version (Int3OnVKError)
			debug asm pure nothrow @nogc @trusted {
			int 3;
		}
	} catch (Exception) {
	}

	assert(!(messageSeverity & VK_DEBUG_UTILS_MESSAGE_SEVERITY_ERROR_BIT_EXT));
	assert(0);

	//return VK_FALSE;
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
		_createInstance();
		_surface = view.createVulkanSurface(_instance);
		_createDevice();
		_createSyncObjects();
	}

	~this() {
		_device.dispatch.DeviceWaitIdle();

		_commandBuffers.clear;
		_pipelines.clear;
		_buffers.clear;
		_framebuffers.clear;
		_renderPasses.clear;
		_shaderModules.clear;
		_samplers.clear;
		_images.clear;
		_imageTemplates.clear;

		foreach (i; 0 .. _renderFinishedSemaphores.length) {
			_device.dispatch.DestroySemaphore(_renderFinishedSemaphores[i]);
			_device.dispatch.DestroySemaphore(_imageAvailableSemaphores[i]);
			_device.dispatch.DestroyFence(_inFlightFences[i]);
		}

		_device.destroy;

		debug vkDestroyDebugUtilsMessengerEXT(_instance, _debugCallback, null);

		vkDestroySurfaceKHR(_instance, _surface, null);
		vkDestroyInstance(_instance, null);
	}

	void newFrame() {
		_device.dispatch.WaitForFences(1, &_inFlightFences[_currentFrame], true, size_t.max);

		VkResult result = _device.dispatch.AcquireNextImageKHR(_device.swapChain, size_t.max,
				_imageAvailableSemaphores[_currentFrame], VK_NULL_HANDLE, &_swapchainImageIndex);

		if (result == VK_ERROR_OUT_OF_DATE_KHR) {
			writeln("[", __LINE__, "] Will recreate due to result = ", result);
			_recreate();
			return newFrame();
		} else
			vkAssert(result);
	}

	void submit(CommandBuffer cb) {
		scope CommandBuffer.Ref c = get(cb);
		auto cData = c.get!VKCommandBufferData();
		_submittedCommandBuffers ~= cData.commandBuffer;
	}

	void finalize() {
		VkSubmitInfo submitInfo;

		VkSemaphore[] waitSemaphores = [_imageAvailableSemaphores[_currentFrame]];
		VkPipelineStageFlags[] waitStages = [VkPipelineStageFlagBits.VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT];
		submitInfo.waitSemaphoreCount = cast(uint)waitSemaphores.length;
		submitInfo.pWaitSemaphores = waitSemaphores.ptr;
		submitInfo.waitSemaphoreCount = cast(uint)waitStages.length;
		submitInfo.pWaitDstStageMask = waitStages.ptr;

		submitInfo.commandBufferCount = cast(uint)_submittedCommandBuffers.length;
		submitInfo.pCommandBuffers = _submittedCommandBuffers.ptr;

		VkSemaphore[] signalSemaphores = [_renderFinishedSemaphores[_currentFrame]];
		submitInfo.signalSemaphoreCount = cast(uint)signalSemaphores.length;
		submitInfo.pSignalSemaphores = signalSemaphores.ptr;

		vkAssert(_device.dispatch.ResetFences(1, &_inFlightFences[_currentFrame]));

		vkAssert(_device.dispatch.vkQueueSubmit(_device.graphicsQueue, 1, &submitInfo, _inFlightFences[_currentFrame]));

		// Clear submitted commandbuffers
		_submittedCommandBuffers.length = 0;

		VkPresentInfoKHR presentInfo;
		presentInfo.waitSemaphoreCount = cast(uint)signalSemaphores.length;
		presentInfo.pWaitSemaphores = signalSemaphores.ptr;

		VkSwapchainKHR[] swapChains = [_device.swapChain];
		presentInfo.swapchainCount = cast(uint)swapChains.length;
		presentInfo.pSwapchains = swapChains.ptr;

		presentInfo.pImageIndices = &_swapchainImageIndex;

		VkResult result = _device.dispatch.vkQueuePresentKHR(_device.presentQueue, &presentInfo);

		bool framebufferResized; // TODO: FIX THIS NOW
		if (result == VK_ERROR_OUT_OF_DATE_KHR || result == VK_SUBOPTIMAL_KHR || framebufferResized) {
			framebufferResized = false;
			writeln("[", __LINE__, "] Will recreate due to result = ", result);
			_recreate();
		} else
			vkAssert(result);

		_currentFrame = (_currentFrame + 1) % _imageAvailableSemaphores.length;

		static bool done;
		if (!done) {
			done = true;
			char* str;

			vmaBuildStatsString(_device.allocator, &str, true);
			scope (exit)
				vmaFreeStatsString(_device.allocator, str);

			import std.file : write;
			import std.string : fromStringz;

			write("memoryStats.json", str.fromStringz);
		}
	}

	// dfmt off
	Buffer construct(ref BufferBuilder builder) { return _buffers.create(builder, &_device); }
	CommandBuffer construct(ref CommandBufferBuilder builder) { return _commandBuffers.create(builder, &_device); }
	Framebuffer construct(ref FramebufferBuilder builder) { return _framebuffers.create(builder, &_device); }
	Image construct(ref ImageBuilder builder) { return _images.create(builder, &_device); }
	ImageTemplate construct(ref ImageTemplateBuilder builder) { return _imageTemplates.create(builder, &_device); }
	Pipeline construct(ref PipelineBuilder builder) { return _pipelines.create(builder, &_device); }
	RenderPass construct(ref RenderPassBuilder builder) { return _renderPasses.create(builder, &_device); }
	Sampler construct(ref SamplerBuilder builder) { return _samplers.create(builder, &_device); }
	ShaderModule construct(ref ShaderModuleBuilder builder) { return _shaderModules.create(builder, &_device); }

	// Custom
	Image construct(ref ImageBuilder builder, VkImage image) { return _images.create(builder, &_device, image); }

	Buffer.Ref get(Buffer handle) { return _buffers.get(handle); }
	CommandBuffer.Ref get(CommandBuffer handle) { return _commandBuffers.get(handle); }
	Framebuffer.Ref get(Framebuffer handle) { return _framebuffers.get(handle); }
	Image.Ref get(Image handle) { return _images.get(handle); }
	ImageTemplate.Ref get(ImageTemplate handle) { return _imageTemplates.get(handle); }
	Pipeline.Ref get(Pipeline handle) { return _pipelines.get(handle); }
	RenderPass.Ref get(RenderPass handle) { return _renderPasses.get(handle); }
	Sampler.Ref get(Sampler handle) { return _samplers.get(handle); }
	ShaderModule.Ref get(ShaderModule handle) { return _shaderModules.get(handle); }

	void destruct(Buffer handle) { assert(!handle.isValid); return _buffers.remove(handle); }
	void destruct(CommandBuffer handle) { assert(!handle.isValid); return _commandBuffers.remove(handle); }
	void destruct(Framebuffer handle) { assert(!handle.isValid); return _framebuffers.remove(handle); }
	void destruct(Image handle) { assert(!handle.isValid); return _images.remove(handle); }
	void destruct(ImageTemplate handle) { assert(!handle.isValid); return _imageTemplates.remove(handle); }
	void destruct(Pipeline handle) { assert(!handle.isValid); return _pipelines.remove(handle); }
	void destruct(RenderPass handle) { assert(!handle.isValid); return _renderPasses.remove(handle); }
	void destruct(Sampler handle) { assert(!handle.isValid); return _samplers.remove(handle); }
	void destruct(ShaderModule handle) { assert(!handle.isValid); return _shaderModules.remove(handle); }
	// dfmt on

	@property ImageTemplate framebufferColorImageTemplate() {
		return _device.fbColorImageTemplate;
	}
	@property ImageTemplate framebufferDepthImageTemplate() {
		return _device.fbDepthImageTemplate;
	}

	@property void outputRenderPass(RenderPass renderpass) {
		_device.outputRenderPass = renderpass;
	}

	@property Framebuffer[] outputFramebuffers() {
		return _device.framebuffers;
	}

	@property size_t outputIdx() {
		return _swapchainImageIndex;
	}

	@property RendererType renderType() const {
		return RendererType.vulkan;
	}

private:
	string _gameName;
	Version _gameVersion;
	IVulkanView _view;
	VkInstance _instance;
	VkDebugUtilsMessengerEXT _debugCallback;

	VkSurfaceKHR _surface;

	VKDevice _device;

	VkSemaphore[] _imageAvailableSemaphores;
	VkSemaphore[] _renderFinishedSemaphores;
	VkFence[] _inFlightFences;
	uint _currentFrame;
	uint _swapchainImageIndex;

	VkCommandBuffer[] _submittedCommandBuffers;

	HandleStorage!(Buffer, VKBufferData) _buffers;
	HandleStorage!(CommandBuffer, VKCommandBufferData) _commandBuffers;
	HandleStorage!(Framebuffer, VKFramebufferData) _framebuffers;
	HandleStorage!(Image, VKImageData) _images;
	HandleStorage!(ImageTemplate, VKImageTemplateData) _imageTemplates;
	HandleStorage!(Pipeline, VKPipelineData) _pipelines;
	HandleStorage!(RenderPass, VKRenderPassData) _renderPasses;
	HandleStorage!(Sampler, VKSamplerData) _samplers;
	HandleStorage!(ShaderModule, VKShaderModuleData) _shaderModules;

	void _recreate() {
		void cleanup(T)(ref T storage) {
			foreach (ref obj; storage)
				obj.cleanup();
		}

		void create(T)(ref T storage) {
			foreach (ref obj; storage)
				obj.create();
		}

		writeln("WILL REBUILD!!!");

		_device.dispatch.DeviceWaitIdle();
		_device.dispatch.vkQueueWaitIdle(_device.presentQueue);

		cleanup(_commandBuffers);
		cleanup(_pipelines);
		cleanup(_buffers);
		cleanup(_framebuffers);
		cleanup(_renderPasses);
		cleanup(_samplers);
		cleanup(_images);
		cleanup(_imageTemplates);

		_device.recreate();

		create(_imageTemplates);
		create(_images);
		create(_samplers);
		create(_renderPasses);
		create(_framebuffers);
		create(_buffers);
		create(_pipelines);
		create(_commandBuffers);

		_device.dispatch.DeviceWaitIdle();
		_device.dispatch.vkQueueWaitIdle(_device.presentQueue);
		writeln("DONE WITH REBUILD!!!");
	}

	void _createInstance() {
		import std.stdio;
		import std.string : toStringz, fromStringz;

		loadGlobalLevelFunctions(_view.getVkGetInstanceProcAddr);

		writefln("Available Extensions:");
		auto availableExtensions = getVKList(vkEnumerateInstanceExtensionProperties, null);
		foreach (const ref VkExtensionProperties e; availableExtensions)
			writefln("\t%-64s Version %d.%d.%d", e.extensionName.ptr.fromStringz, VK_VERSION_MAJOR(e.specVersion),
					VK_VERSION_MINOR(e.specVersion), VK_VERSION_PATCH(e.specVersion));
		writefln("Available Layers:");
		auto availableLayers = getVKList(vkEnumerateInstanceLayerProperties);
		foreach (const ref VkLayerProperties l; availableLayers)
			writefln("\t%-64s: Version %d.%d.%d, ImplVersion %d.%d.%d\n\t\t%s", l.layerName.ptr.fromStringz,
					VK_VERSION_MAJOR(l.specVersion), VK_VERSION_MINOR(l.specVersion), VK_VERSION_PATCH(l.specVersion),
					VK_VERSION_MAJOR(l.implementationVersion), VK_VERSION_MINOR(l.implementationVersion),
					VK_VERSION_PATCH(l.implementationVersion), l.description.ptr.fromStringz);
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

		debug extensions ~= VK_EXT_DEBUG_UTILS_EXTENSION_NAME;
		debug layers ~= "VK_LAYER_LUNARG_standard_validation";

		createInfo.enabledLayerCount = cast(uint)layers.length;
		createInfo.ppEnabledLayerNames = &layers[0];
		createInfo.enabledExtensionCount = cast(uint)extensions.length;
		createInfo.ppEnabledExtensionNames = &extensions[0];

		vkAssert(vkCreateInstance(&createInfo, null, &_instance), "failed to create instance!");
		loadInstanceLevelFunctions(_instance);

		debug {
			VkDebugUtilsMessengerCreateInfoEXT debugInfo;
			debugInfo.messageSeverity = VK_DEBUG_UTILS_MESSAGE_SEVERITY_ERROR_BIT_EXT | VK_DEBUG_UTILS_MESSAGE_SEVERITY_WARNING_BIT_EXT;
			debugInfo.messageType = VK_DEBUG_UTILS_MESSAGE_TYPE_GENERAL_BIT_EXT
				| VK_DEBUG_UTILS_MESSAGE_TYPE_PERFORMANCE_BIT_EXT | VK_DEBUG_UTILS_MESSAGE_TYPE_VALIDATION_BIT_EXT;
			debugInfo.pfnUserCallback = assumeNoGC(&vulkanDebugCallback);
			vkAssert(vkCreateDebugUtilsMessengerEXT(_instance, &debugInfo, null, &_debugCallback), "Failed to create debug report callback");
		}
	}

	void _createDevice() {
		bool isDeviceSuitable(VkPhysicalDevice device, ref QueueInformation qi, ref SwapChainInformation sci) {
			{
				// vkPhysicalDeviceProperties deviceProperties = device.getProperties();
				VkPhysicalDeviceFeatures deviceFeatures;
				vkGetPhysicalDeviceFeatures(device, &deviceFeatures);

				if (!deviceFeatures.geometryShader || !deviceFeatures.samplerAnisotropy)
					return false;
				VkQueueFamilyProperties[] queueFamilies = getVKList(vkGetPhysicalDeviceQueueFamilyProperties, device);
				foreach (uint i, VkQueueFamilyProperties q; queueFamilies) {
					// TODO: Rate queues
					VkBool32 hasPresent;
					vkGetPhysicalDeviceSurfaceSupportKHR(device, i, _surface, &hasPresent);
					if (!q.queueCount)
						continue;
					if (q.queueFlags & VkQueueFlagBits.VK_QUEUE_GRAPHICS_BIT)
						qi.graphics = i;
					if (hasPresent)
						qi.present = i;
				}
			}

			{
				vkGetPhysicalDeviceSurfaceCapabilitiesKHR(device, _surface, &sci.capabilities);
				sci.formats = getVKList(vkGetPhysicalDeviceSurfaceFormatsKHR, device, _surface);
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

	void _createSyncObjects() {
		import std.format : format;

		enum maxFramesInFlight = 2;
		_imageAvailableSemaphores.length = maxFramesInFlight;
		_renderFinishedSemaphores.length = maxFramesInFlight;
		_inFlightFences.length = maxFramesInFlight;

		VkSemaphoreCreateInfo semaphoreInfo;
		VkFenceCreateInfo fenceInfo;
		fenceInfo.flags = VkFenceCreateFlagBits.VK_FENCE_CREATE_SIGNALED_BIT;

		foreach (i; 0 .. maxFramesInFlight) {
			vkAssert(_device.dispatch.CreateSemaphore(&semaphoreInfo, &_imageAvailableSemaphores[i]));
			setVkObjectName(&_device, VK_OBJECT_TYPE_SEMAPHORE, _imageAvailableSemaphores[i], format("Image Available Semaphore #%d", i));

			vkAssert(_device.dispatch.CreateSemaphore(&semaphoreInfo, &_renderFinishedSemaphores[i]));
			setVkObjectName(&_device, VK_OBJECT_TYPE_SEMAPHORE, _renderFinishedSemaphores[i], format("Render Finished Semaphore #%d", i));

			vkAssert(_device.dispatch.CreateFence(&fenceInfo, &_inFlightFences[i]));
			setVkObjectName(&_device, VK_OBJECT_TYPE_FENCE, _imageAvailableSemaphores[i], format("In Flight Fence #%d", i));
		}
	}
}
