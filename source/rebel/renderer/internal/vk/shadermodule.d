module rebel.renderer.internal.vk.shadermodule;

import rebel.renderer;
import erupted;

import rebel.renderer.internal.vk;

struct VKShaderModuleData {
	ShaderModuleData base;
	alias base this;

	ShaderModuleBuilder builder;
	VKDevice* device;

	VkShaderModule shaderModule;
	VkPipelineShaderStageCreateInfo stageInfo;

	this(ref ShaderModuleBuilder builder, VKDevice* device) {
		this.builder = builder;
		this.device = device;
		create();
	}

	void create() {
		import std.string : toStringz;

		VkShaderModuleCreateInfo createinfo;
		createinfo.pCode = cast(uint*)builder.sourcecode.ptr;
		createinfo.codeSize = builder.sourcecode.length;

		vkAssert(device.dispatch.CreateShaderModule(&createinfo, &shaderModule));

		stageInfo._module = shaderModule;
		stageInfo.pName = "main";//builder.entrypoint.toStringz;
		stageInfo.stage = builder.type.translate;
	}

	~this() {
		if (!device)
			return;
		cleanup();
		device = null;
	}

	void cleanup() {
		device.dispatch.DestroyShaderModule(shaderModule);
	}
}

static assert(isCorrectVulkanData!VKShaderModuleData);
