module rebel.renderer.internal.vk.device;

import erupted;
import erupted.dispatch_device;

import vulkan_memory_allocator;

import rebel.engine;
import rebel.view;
import rebel.renderer;
import rebel.renderer.vkrenderer;
import rebel.renderer.internal.vk;

import gfm.math.vector;

struct QueueInformation {
	uint graphics = uint.max;
	uint present = uint.max;
	bool completed() {
		return graphics != uint.max && present != uint.max;
	}
}

struct SwapChainInformation {
	VkSurfaceCapabilitiesKHR capabilities;
	VkSurfaceFormatKHR[] formats;
	VkPresentModeKHR[] presentModes;
}

struct VKDevice {
	VKRenderer renderer;
	IVulkanView view;

	// Physical device
	VkPhysicalDevice device;
	QueueInformation queueInfo;
	SwapChainInformation swapChainInfo;
	VkSurfaceKHR surface;

	VkPhysicalDeviceProperties physicalProperties;
	VkPhysicalDeviceFeatures physicalFeatures;
	VkPhysicalDeviceMemoryProperties physicalMemoryProperties;
	VkQueueFamilyProperties[] physicalQueueFamilyProperties;
	string[] physicalSupportedExtensions;

	// Logical device
	DispatchDevice dispatch;

	VmaVulkanFunctions vulkanFunctions;
	VmaAllocator allocator;

	VkQueue graphicsQueue;
	VkQueue presentQueue;

	VkSurfaceFormatKHR swapChainImageFormat;
	VkFormat depthImageFormat;
	VkExtent2D swapChainExtent;
	VkSwapchainKHR swapChain;
	VkImage[] swapChainImages;

	ImageTemplate fbColorImageTemplate;
	ImageTemplate fbDepthImageTemplate;
	Image[] fbImages;
	Image fbDepthImage;
	RenderPass fbRenderPass;
	Framebuffer[] framebuffers;

	VkCommandPool defaultCommandPool;
	VkCommandPool changeEachFrameCommandPool;

	VkCommandBuffer singleTimeCommandBuffer;
	VkFence singleTimeCommandBufferFence;

	VkDescriptorPool descriptorPool;

	void initialize(VkPhysicalDevice device, QueueInformation queueInfo, SwapChainInformation swapChainInfo, VkSurfaceKHR surface) {
		import std.string : fromStringz;

		renderer = cast(VKRenderer)Engine.instance.renderer;
		view = cast(IVulkanView)Engine.instance.view;

		this.device = device;
		this.queueInfo = queueInfo;
		this.swapChainInfo = swapChainInfo;
		this.surface = surface;

		vkGetPhysicalDeviceProperties(device, &physicalProperties);
		vkGetPhysicalDeviceFeatures(device, &physicalFeatures);
		vkGetPhysicalDeviceMemoryProperties(device, &physicalMemoryProperties);

		physicalQueueFamilyProperties = getVKList(vkGetPhysicalDeviceQueueFamilyProperties, device);

		auto extensions = getVKList(vkEnumerateDeviceExtensionProperties, device, null);
		physicalSupportedExtensions.length = extensions.length;

		foreach (idx, VkExtensionProperties extension; extensions)
			physicalSupportedExtensions[idx] = extension.extensionName.ptr.fromStringz.idup;

		_createLogicalDevice();
		_createMemoryAllocator();
		_createSwapChain(false);
		_createImageViews();
		_createCommandPools();
		_createDescriptorPools();
	}

	~this() {
		if (device == VK_NULL_HANDLE) // On opAssign or when the GC, for some reason, calls this destructor
			return;

		dispatch.DestroyDescriptorPool(descriptorPool);

		dispatch.DestroyFence(singleTimeCommandBufferFence);
		dispatch.FreeCommandBuffers(changeEachFrameCommandPool, 1, &singleTimeCommandBuffer);
		dispatch.DestroyCommandPool(changeEachFrameCommandPool);
		dispatch.DestroyCommandPool(defaultCommandPool);

		/*foreach (Framebuffer fb; framebuffers)
			renderer.destruct(fb);
		framebuffers.length = 0;
		foreach (Image i; fbImages)
			renderer.destruct(i);
		fbImages.length = 0;
		renderer.destruct(fbImageTemplate);*/

		dispatch.DestroySwapchainKHR(swapChain);
		vmaDestroyAllocator(allocator);
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
		foreach (i; 0 .. physicalMemoryProperties.memoryTypeCount) {
			if (typeBits & 0b1 && (physicalMemoryProperties.memoryTypes[i].propertyFlags & properties) == properties) {
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
		_createSwapChain(true);
	}

	VkCommandBuffer beginSingleTimeCommands() {
		VkCommandBufferBeginInfo cmdBufBeginInfo;
		cmdBufBeginInfo.flags = VK_COMMAND_BUFFER_USAGE_ONE_TIME_SUBMIT_BIT;
		vkAssert(dispatch.vkBeginCommandBuffer(singleTimeCommandBuffer, &cmdBufBeginInfo));
		return singleTimeCommandBuffer;
	}

	void endSingleTimeCommands() {
		vkAssert(dispatch.vkEndCommandBuffer(singleTimeCommandBuffer));

		VkSubmitInfo submitInfo;
		submitInfo.commandBufferCount = 1;
		submitInfo.pCommandBuffers = &singleTimeCommandBuffer;

		vkAssert(dispatch.vkQueueSubmit(graphicsQueue, 1, &submitInfo, singleTimeCommandBufferFence));
		vkAssert(dispatch.WaitForFences(1, &singleTimeCommandBufferFence, true, size_t.max));
		vkAssert(dispatch.ResetFences(1, &singleTimeCommandBufferFence));
	}

private:
	void _createLogicalDevice() {
		float queuePriority = 1.0f;

		// TODO: if queue index is same, only create one CreateInfo with count of two
		// dfmt off
		VkDeviceQueueCreateInfo[] queueCreateInfos = [
			{ queueFamilyIndex: queueInfo.graphics, queueCount: 1, pQueuePriorities: &queuePriority },
			{ queueFamilyIndex: queueInfo.present, queueCount: 1, pQueuePriorities: &queuePriority }
		];
		// dfmt on
		if (queueInfo.graphics == queueInfo.present)
			queueCreateInfos = queueCreateInfos[0 .. 1];

		const(char)*[] layers;
		debug layers ~= "VK_LAYER_LUNARG_standard_validation";
		const(char)*[] extensions = [VK_KHR_SWAPCHAIN_EXTENSION_NAME];

		VkPhysicalDeviceFeatures deviceFeatures;
		deviceFeatures.samplerAnisotropy = true;
		deviceFeatures.geometryShader = true;
		VkDeviceCreateInfo deviceCreateInfo;
		deviceCreateInfo.queueCreateInfoCount = cast(uint)queueCreateInfos.length;
		deviceCreateInfo.pQueueCreateInfos = &queueCreateInfos[0];
		deviceCreateInfo.enabledLayerCount = cast(uint)layers.length;
		deviceCreateInfo.ppEnabledLayerNames = &layers[0];
		deviceCreateInfo.enabledExtensionCount = cast(uint)extensions.length;
		deviceCreateInfo.ppEnabledExtensionNames = &extensions[0];
		deviceCreateInfo.pEnabledFeatures = &deviceFeatures;

		VkDevice tmpDevice;
		vkAssert(vkCreateDevice(device, &deviceCreateInfo, null, &tmpDevice), "Create device failed!");
		dispatch = DispatchDevice(tmpDevice);
		setVkObjectName(&this, VK_OBJECT_TYPE_DEVICE, tmpDevice, "Main device");

		dispatch.GetDeviceQueue(queueInfo.graphics, 0, &graphicsQueue);
		assert(graphicsQueue, "Graphic queue is null!");
		setVkObjectName(&this, VK_OBJECT_TYPE_DEVICE, tmpDevice, "Main device");

		if (queueCreateInfos.length == 1) {
			setVkObjectName(&this, VK_OBJECT_TYPE_QUEUE, graphicsQueue, "Graphics- & Present Queue");
			presentQueue = graphicsQueue;
		} else {
			setVkObjectName(&this, VK_OBJECT_TYPE_QUEUE, graphicsQueue, "Graphics Queue");

			dispatch.GetDeviceQueue(queueInfo.present, 0, &presentQueue);
			assert(presentQueue, "Present queue is null!");
			setVkObjectName(&this, VK_OBJECT_TYPE_QUEUE, presentQueue, "Present Queue");
		}
	}

	void _createMemoryAllocator() {
		vulkanFunctions.vkGetPhysicalDeviceProperties = vkGetPhysicalDeviceProperties;
		vulkanFunctions.vkGetPhysicalDeviceMemoryProperties = vkGetPhysicalDeviceMemoryProperties;
		vulkanFunctions.vkAllocateMemory = dispatch.vkAllocateMemory;
		vulkanFunctions.vkFreeMemory = dispatch.vkFreeMemory;
		vulkanFunctions.vkMapMemory = dispatch.vkMapMemory;
		vulkanFunctions.vkUnmapMemory = dispatch.vkUnmapMemory;
		vulkanFunctions.vkFlushMappedMemoryRanges = dispatch.vkFlushMappedMemoryRanges;
		vulkanFunctions.vkInvalidateMappedMemoryRanges = dispatch.vkInvalidateMappedMemoryRanges;
		vulkanFunctions.vkBindBufferMemory = dispatch.vkBindBufferMemory;
		vulkanFunctions.vkBindImageMemory = dispatch.vkBindImageMemory;
		vulkanFunctions.vkGetBufferMemoryRequirements = dispatch.vkGetBufferMemoryRequirements;
		vulkanFunctions.vkGetImageMemoryRequirements = dispatch.vkGetImageMemoryRequirements;
		vulkanFunctions.vkCreateBuffer = dispatch.vkCreateBuffer;
		vulkanFunctions.vkDestroyBuffer = dispatch.vkDestroyBuffer;
		vulkanFunctions.vkCreateImage = dispatch.vkCreateImage;
		vulkanFunctions.vkDestroyImage = dispatch.vkDestroyImage;
		vulkanFunctions.vkGetBufferMemoryRequirements2 = dispatch.vkGetBufferMemoryRequirements2;
		vulkanFunctions.vkGetImageMemoryRequirements2 = dispatch.vkGetImageMemoryRequirements2;

		VmaAllocatorCreateInfo allocatorInfo;
		allocatorInfo.flags |= VMA_ALLOCATOR_CREATE_KHR_DEDICATED_ALLOCATION_BIT;
		allocatorInfo.physicalDevice = device;
		allocatorInfo.device = dispatch.vkDevice;
		allocatorInfo.pVulkanFunctions = &vulkanFunctions;
		vmaCreateAllocator(&allocatorInfo, &allocator);
	}

	void _createSwapChain(bool recreate) {
		VkSurfaceFormatKHR surfaceFormat = (VkSurfaceFormatKHR[] formats) {
			if (formats.length == 1 && formats[0].format == VkFormat.VK_FORMAT_UNDEFINED) {
				VkSurfaceFormatKHR format;
				format.format = VkFormat.VK_FORMAT_B8G8R8A8_UNORM;
				format.colorSpace = VkColorSpaceKHR.VK_COLOR_SPACE_SRGB_NONLINEAR_KHR;
				return format;
			}

			foreach (ref VkSurfaceFormatKHR f; formats)
				if (f.format == VkFormat.VK_FORMAT_B8G8R8A8_UNORM && f.colorSpace == VkColorSpaceKHR.VK_COLOR_SPACE_SRGB_NONLINEAR_KHR)
					return f;

			return formats[0];
		}(swapChainInfo.formats);
		swapChainImageFormat = surfaceFormat;

		depthImageFormat = () {
			foreach (VkFormat format; [VK_FORMAT_D32_SFLOAT, VK_FORMAT_D32_SFLOAT_S8_UINT, VK_FORMAT_D24_UNORM_S8_UINT]) {
				VkFormatProperties props;
				vkGetPhysicalDeviceFormatProperties(device, format, &props);

				if ((props.optimalTilingFeatures & VK_FORMAT_FEATURE_DEPTH_STENCIL_ATTACHMENT_BIT) == VK_FORMAT_FEATURE_DEPTH_STENCIL_ATTACHMENT_BIT)
					return format;
			}
			return VK_FORMAT_D32_SFLOAT;
		}();

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

		}(swapChainInfo.capabilities);
		swapChainExtent = extent;

		uint imageCount = swapChainInfo.capabilities.minImageCount + 1;
		if (swapChainInfo.capabilities.maxImageCount > 0 && imageCount > swapChainInfo.capabilities.maxImageCount)
			imageCount = swapChainInfo.capabilities.maxImageCount;

		if (recreate) {
			scope ImageTemplate.Ref itColorRef = renderer.get(fbColorImageTemplate);
			auto dataColor = itColorRef.get!VKImageTemplateData();
			dataColor.builder.format = swapChainImageFormat.format.translate;
			dataColor.builder.size = vec2ui(swapChainExtent.width, swapChainExtent.height);

			scope ImageTemplate.Ref itDepthRef = renderer.get(fbColorImageTemplate);
			auto dataDepth = itDepthRef.get!VKImageTemplateData();
			dataDepth.builder.format = depthImageFormat.translate;
			dataDepth.builder.size = vec2ui(swapChainExtent.width, swapChainExtent.height);
		} else {
			ImageTemplateBuilder builder;
			builder.name = "SwapChain Color Image Template";
			builder.format = swapChainImageFormat.format.translate;
			builder.samples = 1;
			builder.size = vec2ui(swapChainExtent.width, swapChainExtent.height);
			builder.usage = ImageUsage.presentAttachment;

			fbColorImageTemplate = renderer.construct(builder);

			builder.name = "SwapChain Depth Image Template";
			builder.format = depthImageFormat.translate;
			builder.samples = 1;
			builder.size = vec2ui(swapChainExtent.width, swapChainExtent.height);
			builder.usage = ImageUsage.depthAttachment;

			fbDepthImageTemplate = renderer.construct(builder);
		}

		VkSwapchainCreateInfoKHR createInfo;
		createInfo.surface = surface;
		createInfo.minImageCount = imageCount;
		createInfo.imageFormat = surfaceFormat.format;
		createInfo.imageColorSpace = surfaceFormat.colorSpace;
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

		createInfo.preTransform = swapChainInfo.capabilities.currentTransform;
		createInfo.compositeAlpha = VkCompositeAlphaFlagBitsKHR.VK_COMPOSITE_ALPHA_OPAQUE_BIT_KHR;
		createInfo.presentMode = presentMode;
		createInfo.clipped = true;
		auto oldSwapchain = createInfo.oldSwapchain = swapChain;

		dispatch.CreateSwapchainKHR(&createInfo, &swapChain);
		assert(swapChain, "Create swapchain failed!");
		setVkObjectName(&this, VK_OBJECT_TYPE_SWAPCHAIN_KHR, swapChain, "Main swapchain");

		if (oldSwapchain != VK_NULL_HANDLE)
			dispatch.DestroySwapchainKHR(oldSwapchain);

		const size_t oldLength = swapChainImages.length;

		swapChainImages = getVKList(&dispatch.GetSwapchainImagesKHR, swapChain);

		foreach (i, image; swapChainImages) {
			import std.format : format;

			setVkObjectName(&this, VK_OBJECT_TYPE_IMAGE, image, format("Swapchain Image #%d", i));
		}
		if (recreate) {
			assert(oldLength == swapChainImages.length);
			foreach (i, VkImage image; swapChainImages) {
				scope Image.Ref imgRef = renderer.get(fbImages[i]);
				imgRef.get!VKImageData().image = image;
			}
		}
	}

	void _createImageViews() {
		ImageBuilder builder;
		builder.imageTemplate = fbColorImageTemplate;
		fbImages.length = swapChainImages.length;
		foreach (i, image; swapChainImages) {
			import std.format : format;

			builder.name = format("Swapchain ImageView for output #%d", i);
			fbImages[i] = renderer.construct(builder, image);
		}

	}

	void _createFramebuffers(bool recreate = false) {
		assert(fbRenderPass.isValid);

		if (!fbDepthImage.isValid) {
			ImageBuilder builder;
			builder.name = "Swapchain Depth image";
			builder.imageTemplate = fbDepthImageTemplate;
			fbDepthImage = renderer.construct(builder);

			VkFormat format = renderer.get(fbDepthImageTemplate).get!VKImageTemplateData().format;

			auto cb = beginSingleTimeCommands();
			{
				VkImageMemoryBarrier barrier;
				barrier.oldLayout = VK_IMAGE_LAYOUT_UNDEFINED;
				barrier.newLayout = VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL;
				barrier.srcQueueFamilyIndex = VK_QUEUE_FAMILY_IGNORED;
				barrier.dstQueueFamilyIndex = VK_QUEUE_FAMILY_IGNORED;
				barrier.image = renderer.get(fbDepthImage).get!VKImageData().image;
				alias isStencil = (VkFormat format) => format == VK_FORMAT_D32_SFLOAT_S8_UINT || format == VK_FORMAT_D24_UNORM_S8_UINT;
				barrier.subresourceRange.aspectMask = VK_IMAGE_ASPECT_DEPTH_BIT | (isStencil(format) ? VK_IMAGE_ASPECT_STENCIL_BIT : 0);
				barrier.subresourceRange.baseMipLevel = 0;
				barrier.subresourceRange.levelCount = 1;
				barrier.subresourceRange.baseArrayLayer = 0;
				barrier.subresourceRange.layerCount = 1;
				barrier.srcAccessMask = 0;
				barrier.dstAccessMask = VK_ACCESS_DEPTH_STENCIL_ATTACHMENT_READ_BIT | VK_ACCESS_DEPTH_STENCIL_ATTACHMENT_WRITE_BIT;

				VkPipelineStageFlags sourceStage = VK_PIPELINE_STAGE_TOP_OF_PIPE_BIT;
				VkPipelineStageFlags destinationStage = VK_PIPELINE_STAGE_EARLY_FRAGMENT_TESTS_BIT;

				dispatch.vkCmdPipelineBarrier(cb, sourceStage, destinationStage, 0, 0, null, 0, null, 1, &barrier);
			}
			endSingleTimeCommands();
		}

		framebuffers.length = fbImages.length;
		foreach (i, Image image; fbImages) {
			import std.format : format;

			FramebufferBuilder builder;
			builder.name = format("Framebuffer for output #%d", i);
			builder.attachments = [image, fbDepthImage];
			builder.dimension = vec3ui(swapChainExtent.width, swapChainExtent.height, 1);
			builder.renderPass = fbRenderPass;
			framebuffers[i] = renderer.construct(builder);
		}
	}

	void _createCommandPools() {
		VkCommandPoolCreateInfo poolInfo;
		poolInfo.queueFamilyIndex = queueInfo.graphics;

		poolInfo.flags = VkCommandPoolCreateFlagBits.VK_COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT;
		vkAssert(dispatch.CreateCommandPool(&poolInfo, &defaultCommandPool));
		setVkObjectName(&this, VK_OBJECT_TYPE_COMMAND_POOL, defaultCommandPool, "Default CommandPool");

		poolInfo.flags |= VkCommandPoolCreateFlagBits.VK_COMMAND_POOL_CREATE_TRANSIENT_BIT;
		vkAssert(dispatch.CreateCommandPool(&poolInfo, &changeEachFrameCommandPool));
		setVkObjectName(&this, VK_OBJECT_TYPE_COMMAND_POOL, changeEachFrameCommandPool, "Change Each Frame CommandPool");

		// TODO: Move to a better place
		VkCommandBufferAllocateInfo allocInfo;
		allocInfo.commandPool = changeEachFrameCommandPool;
		allocInfo.level = VkCommandBufferLevel.VK_COMMAND_BUFFER_LEVEL_PRIMARY;
		allocInfo.commandBufferCount = 1;
		vkAssert(dispatch.AllocateCommandBuffers(&allocInfo, &singleTimeCommandBuffer));
		setVkObjectName(&this, VK_OBJECT_TYPE_COMMAND_BUFFER, singleTimeCommandBuffer, "Single time commandbuffer");

		VkFenceCreateInfo fenceInfo;
		vkAssert(dispatch.CreateFence(&fenceInfo, &singleTimeCommandBufferFence));
		setVkObjectName(&this, VK_OBJECT_TYPE_FENCE, singleTimeCommandBufferFence, "Single time commandbuffer - fence");
	}

	void _createDescriptorPools() {
		VkDescriptorPoolSize[] poolSizes = [
			VkDescriptorPoolSize(VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER, cast(uint)swapChainImages.length),
			VkDescriptorPoolSize(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER, cast(uint)swapChainImages.length)
		];

		VkDescriptorPoolCreateInfo poolInfo;
		poolInfo.poolSizeCount = cast(uint)poolSizes.length;
		poolInfo.pPoolSizes = poolSizes.ptr;
		poolInfo.maxSets = cast(uint)swapChainImages.length;
		poolInfo.flags = VK_DESCRIPTOR_POOL_CREATE_FREE_DESCRIPTOR_SET_BIT;

		vkAssert(dispatch.CreateDescriptorPool(&poolInfo, &descriptorPool));
	}
}
