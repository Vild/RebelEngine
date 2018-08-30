module rebel.renderer;

import rebel.view;
import dlsl.vector;

import rebel.handle;

public import rebel.renderer.vkrenderer : IVulkanRenderer, IVulkanView;
public import rebel.renderer.glrenderer : IOpenGLRenderer, IOpenGLView;

enum RendererType {
	null_,
	vulkan,
	opengl
}

interface ITexture2D {
	@property ivec2 getSize();
	@property void* getHandle();
}

interface ITexture3D {
	@property ivec3 getSize();
	@property void* getHandle();
}

// ======================

enum ImageFormat {
	undefined,
	rgb888,
	rgba8888,
	rgba16f,
	rgba32f
}

enum ImageLayout {
	undefined,
	color,
	present,
	depthStencil
}

enum LoadOperation {
	load,
	clear,
	dontCare,
}

enum StoreOperation {
	store,
	dontCare
}

struct Attachment {
	ImageFormat format;
	size_t samples;
	LoadOperation loadOp;
	StoreOperation storeOp;
	LoadOperation stencilLoadOp;
	StoreOperation stencilStoreOp;
	ImageLayout initialLayout;
	ImageLayout finalLayout;
}

// ======================

struct SubpassAttachment {
	// RenderPass will use the attachment to get the ID out of the renderpass attachments array
	Attachment* attachment;
	ImageLayout layout;
}

enum SubpassBindPoint {
	graphics // not implemented: compute
}

struct Subpass {
	SubpassBindPoint bindPoint;
	SubpassAttachment[] colorOutput;
	SubpassAttachment[] depthStencilOutput;
}

enum Subpass* externalSubpass = null;
enum StageFlags {
	colorOutput
}

enum AccessMask {
	none,
	read = 1 << 0,
	write = 1 << 1,
	readwrite = read | write
}

struct SubpassDependency {
	Subpass* srcSubpass;
	Subpass* dstSubpass;
	StageFlags srcStageMask;
	StageFlags dstStageMask;
	AccessMask srcAccessMask;
	AccessMask dstAccessMask;
}

struct RenderPassBuilder {
	bool isFinalScreenRenderPass; //TODO: remove this hack

	Attachment*[] attachments;

	Subpass*[] subpasses;
	SubpassDependency[] dependencies;
}

struct RenderPassData {
}

alias RenderPass = Handle!(RenderPassData, 64);

// ======================

enum ShaderType {
	vertext,
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

// ======================

struct VertexInputBindingDescription {
}

struct VertexInputAttributeDescription {
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

// ======================

interface IRenderer {
	void initialize(IView view);

	// IPipelineBuilder newPipeline();
	void newFrame();
	void finalize();

	RenderPass construct(ref RenderPassBuilder builder);
	ShaderModule construct(ref ShaderModuleBuilder builder);
	Pipeline construct(ref PipelineBuilder builder);

	RenderPass.Ref get(RenderPass handler);
	ShaderModule.Ref get(ShaderModule handler);
	Pipeline.Ref get(Pipeline handler);

	@property RendererType renderType() const;
}
/*
final class NullRenderer {
public:
	void initialize(IView view) {
		assert(cast(NullView)view);
	}

	void newFrame() {
	}

	void finalize() {
	}

	@property RendererType renderType() const {
		return RendererType.null_;
	}
}*/
