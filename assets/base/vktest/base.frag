#version 460 core
#extension GL_ARB_separate_shader_objects : enable

layout(location = 0) in vec3 fragColor;
layout(location = 1) in vec2 fragTexCoord;

layout(binding = 1) uniform sampler2D texSampler;

layout(location = 0) out vec4 outColor;

void main() {
	outColor = vec4(texture(texSampler, fragTexCoord * 4.0f).rgb * fragColor * 2, 1.0);
}
