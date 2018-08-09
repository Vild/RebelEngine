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
enum StageMask {
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
	StageMask srcStageMask;
	StageMask dstStageMask;
	AccessMask srcAccessMask;
	AccessMask dstAccessMask;
}

struct RenderpassBuilder {
	Attachment*[] attachments;

	Subpass*[] subpasses;
	SubpassDependency[] dependency;
}

struct RenderpassData {

}

alias Renderpass = Handle!(RenderpassData, 64);

// ======================

interface IRenderer {
	void initialize(IView view);

	// IPipelineBuilder newPipeline();
	void newFrame();
	void finalize();

	Renderpass construct(const ref RenderpassBuilder builder);

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
