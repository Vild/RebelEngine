#version 440 core

/*layout(location = 0) */in vec2 position;
/*layout(location = 1) */in vec2 uv;
/*layout(location = 2) */in vec4 color;

out VertexData {
	vec4 color;
	vec2 uv;
} outData;

layout(location = 0) uniform mat4 vp;

void main() {
	outData.color = color;
	outData.uv = uv;
	gl_Position = vp * vec4(position.xy, 0, 1);
}
