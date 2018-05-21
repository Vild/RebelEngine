#version 440 core

in VertexData {
	vec4 color;
	vec2 uv;
} inData;

layout(location = 0) out vec4 fragOutput;

/*layout(location = 1) */uniform sampler2D fontTexture;

void main() {
	fragOutput = inData.color * texture(fontTexture, inData.uv.st);
}
