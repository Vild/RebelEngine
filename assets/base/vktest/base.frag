#version 440 core

layout(location = 0) in VertexData {
	vec4 color;
	vec2 uv;
} inData;

layout(location = 0) out vec4 fragOutput;

layout(set = 6, binding=0) uniform sampler2D fontTexture;

void main() {
	fragOutput = inData.color * texture(fontTexture, inData.uv.st);
}
