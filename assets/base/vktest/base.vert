#version 440 core


layout(set = 0, binding=0) buffer pos { vec2 position_in[]; };
layout(set = 1, binding=1) buffer uv { vec2 uv_in[]; };
layout(set = 2, binding=2) buffer color { vec4 color_in[]; };

layout(set = 3, binding = 3) uniform vp {
	uniform mat4 vp_in;
};

out gl_PerVertex {
	vec4 gl_Position;
};

layout(location = 0) out VertexData {
	vec4 color;
	vec2 uv;
} outData;

void main() {
	outData.color = color_in[gl_VertexIndex];
	outData.uv = uv_in[gl_VertexIndex];
	gl_Position = vp_in * vec4(position_in[gl_VertexIndex].xy, 0, 1);
}
