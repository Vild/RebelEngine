module rebel.renderer;

import rebel.view;
import dlsl.vector;

import rebel.handle;

public import rebel.renderer.types;

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

interface IRenderer {
	void initialize(IView view);

	// IPipelineBuilder newPipeline();
	void newFrame();
	void finalize();

	Framebuffer construct(ref FramebufferBuilder builder);
	Image construct(ref ImageBuilder builder);
	ImageTemplate construct(ref ImageTemplateBuilder builder);
	Pipeline construct(ref PipelineBuilder builder);
	RenderPass construct(ref RenderPassBuilder builder);
	ShaderModule construct(ref ShaderModuleBuilder builder);

	Framebuffer.Ref get(Framebuffer handler);
	Image.Ref get(Image handler);
	ImageTemplate.Ref get(ImageTemplate handler);
	Pipeline.Ref get(Pipeline handler);
	RenderPass.Ref get(RenderPass handler);
	ShaderModule.Ref get(ShaderModule handler);

	void destruct(Framebuffer handler);
	void destruct(Image handler);
	void destruct(ImageTemplate handler);
	void destruct(Pipeline handler);
	void destruct(RenderPass handler);
	void destruct(ShaderModule handler);

	@property ImageTemplate framebufferImageTemplate();
	@property void outputRenderPass(RenderPass renderpass);

	@property Framebuffer[] outputFramebuffers();
	@property size_t outputToIdx();

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
