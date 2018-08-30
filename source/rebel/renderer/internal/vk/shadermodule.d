module rebel.renderer.internal.vk.shadermodule;

import rebel.renderer;
import erupted;

import rebel.renderer.internal.vk.device;
import rebel.renderer.internal.vk.helper;
import rebel.renderer.internal.vk.translate;

struct VkShaderModuleData {
	ShaderModuleData base;
	alias base this;

	VkShaderModule shaderModule;
	Device* device;

	VkPipelineShaderStageCreateInfo stageInfo;

	this(const ref ShaderModuleBuilder builder, Device* device) {
		import std.string : toStringz;
		this.device = device;

		VkShaderModuleCreateInfo createinfo;
		createinfo.pCode = cast(uint*)builder.sourcecode.ptr;
		createinfo.codeSize = builder.sourcecode.length;

		vkAssert(device.dispatch.CreateShaderModule(&createinfo, &shaderModule));

		stageInfo.stage = VK_SHADER_STAGE_VERTEX_BIT;
		stageInfo._module = shaderModule;
		stageInfo.pName = builder.entrypoint.toStringz;
		stageInfo.stage = builder.type.translate;
	}

	~this() {
		if (device)
			device.dispatch.DestroyShaderModule(shaderModule);
		device = null;
	}
}
