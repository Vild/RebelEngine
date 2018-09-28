module rebel.renderer.types.pipeline;

import rebel.renderer.types;

import dlsl.vector;

struct VertexInputBindingDescription {
	uint binding;
	uint stride;
	DataRate inputRate;
}

struct VertexInputAttributeDescription {
	uint location;
	uint binding;
	ImageFormat format;
	uint offset;
}

enum VertexTopology {
	triangleList
}

struct Viewport {
	vec2 position = vec2(0, 0);
	vec2 size = vec2(0, 0);
	vec2 depthRange = vec2(0, 1);
}

struct Scissor {
	ivec2 start;
	uvec2 end;
}

enum PolygonMode {
	fill,
	line,
	point
}

enum CullMode {
	none,
	front,
	back,
	frontAndBack
}

enum FrontFaceMode {
	clockwise,
	counterClockwise
}

enum SampleCount {
	Sample1,
	Sample2,
	Sample4,
	Sample8,
	Sample16,
	Sample32,
	Sample64
}

struct RasterizationState {
	bool depthClampEnable;
	bool rasterizerDiscardEnable;
	PolygonMode polygonMode;
	float lineWidth;
	CullMode cullMode;
	FrontFaceMode frontFace;
	bool depthBiasEnable;
}

enum ColorComponent {
	r,
	g,
	b,
	a
}

struct BlendAttachment {
	ColorComponent colorWriteMask;
	bool blendEnable;
}

enum LogicOp {
	copy
}

struct BlendState {
	bool logicOpEnable;
	LogicOp logicOp;

	BlendAttachment[] attachments;
	float[4] blendConstants;
}

struct PipelineBuilder {
	string name;

	RenderPass renderpass;

	ShaderModule[] shaderStages;

	// == Input assembly ==
	VertexInputBindingDescription[] vertexInputBindingDescriptions; // VkVertexInputBindingDescription
	VertexInputAttributeDescription[] vertexInputAttributeDescriptions; //VkVertexInputAttributeDescription

	VertexTopology vertexTopology;

	// == ViewportState ==
	Viewport[] viewports;
	Scissor[] scissors;

	// == Rasterizer ==
	RasterizationState rasterizationState;
	bool multisamplingEnabled;
	SampleCount multisamplingCount;

	BlendState blendState;
}

struct PipelineData {
	// pipelineLayout
}

alias Pipeline = Handle!(PipelineData, 64);
