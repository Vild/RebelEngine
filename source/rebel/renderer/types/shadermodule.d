module rebel.renderer.types.shadermodule;

import rebel.renderer.types;

enum ShaderType {
	vertex,
	fragment
}

struct ShaderModuleBuilder {
	string sourcecode;
	string entrypoint;
	ShaderType type;
}

struct ShaderModuleData {
}

alias ShaderModule = Handle!(ShaderModuleData, 64);
