module rebel.renderer.types.pipeline;

import rebel.renderer.types;

import gfm.math.vector;

struct VertexInputBindingDescription {
	uint binding;
	uint stride;
	VertexDataRate inputRate;
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

enum DescriptorType {
	//sampler,
	//combinedImageSampler,
	//sampledImage,
	//storageImage,
	//uniformTexelBuffer,
	//storageTexelBuffer,
	uniformBuffer, //storageBuffer,
	//uniformBufferDynamic,
	//storageBufferDynamic,
	//inputAttachment,
	//inlineUniformBlockExt,
}

enum ShaderStages {
	vertex = 1 << 0,
	//tessellationControl = 1 << 1,
	//tessellationEvaluation = 1 << 2,
	geometry = 1 << 3,
	fragment = 1 << 4,
	compute = 1 << 5,
	allGraphics = (1 << 6) - 1,
}

struct DescriptorSetLayoutBinding {
	uint binding;
	DescriptorType descriptorType;
	uint descriptorCount;
	ShaderStages stages;
	/*Sampler*/
	void* immutableSamplers;
}

struct Viewport {
	vec2f position = vec2f(0, 0);
	vec2f size = vec2f(0, 0);
	vec2f depthRange = vec2f(0, 1);
}

struct Scissor {
	vec2i start;
	vec2ui end;
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

struct DescriptorBufferInfo {
	Buffer buffer;
	size_t offset;
	size_t range;

	WriteDescriptorSet writeDescriptorSet;
}
struct WriteDescriptorSet {
	uint binding;
	uint arrayElement;
	uint descriptorCount;
	DescriptorType descriptorType;
}

struct PipelineBuilder {
	string name;

	RenderPass renderpass;

	ShaderModule[] shaderStages;

	// == Input assembly ==
	VertexInputBindingDescription[] vertexInputBindingDescriptions; // VkVertexInputBindingDescription
	VertexInputAttributeDescription[] vertexInputAttributeDescriptions; //VkVertexInputAttributeDescription

	VertexTopology vertexTopology;

	// == Descriptor set layout ==
	DescriptorSetLayoutBinding[] descriptorSetLayoutBindings;
	DescriptorBufferInfo[] descriptorBufferInfos;

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
