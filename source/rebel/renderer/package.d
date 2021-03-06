module rebel.renderer;

import rebel.view;
import gfm.math.vector;

import rebel.handle;

public import rebel.renderer.types;

public import rebel.renderer.vkrenderer : IVulkanRenderer, IVulkanView;
public import rebel.renderer.glrenderer : IOpenGLRenderer, IOpenGLView;

enum RendererType {
	null_,
	vulkan,
	opengl
}

// TODO: (re)move
interface ITexture2D {
	@property vec2i getSize();
	@property void* getHandle();
}

interface ITexture3D {
	@property vec3f getSize();
	@property void* getHandle();
}

interface IRenderer {
	void initialize(IView view);

	// IPipelineBuilder newPipeline();
	void newFrame();
	void submit(CommandBuffer commandbuffer);
	void finalize();

	Buffer construct(ref BufferBuilder builder);
	CommandBuffer construct(ref CommandBufferBuilder builder);
	Framebuffer construct(ref FramebufferBuilder builder);
	Image construct(ref ImageBuilder builder);
	ImageTemplate construct(ref ImageTemplateBuilder builder);
	Pipeline construct(ref PipelineBuilder builder);
	RenderPass construct(ref RenderPassBuilder builder);
	Sampler construct(ref SamplerBuilder builder);
	ShaderModule construct(ref ShaderModuleBuilder builder);

	Buffer.Ref get(Buffer handler);
	CommandBuffer.Ref get(CommandBuffer handler);
	Framebuffer.Ref get(Framebuffer handler);
	Image.Ref get(Image handler);
	ImageTemplate.Ref get(ImageTemplate handler);
	Pipeline.Ref get(Pipeline handler);
	RenderPass.Ref get(RenderPass handler);
	Sampler.Ref get(Sampler handler);
	ShaderModule.Ref get(ShaderModule handler);

	void destruct(Buffer handler);
	void destruct(CommandBuffer handler);
	void destruct(Framebuffer handler);
	void destruct(Image handler);
	void destruct(ImageTemplate handler);
	void destruct(Pipeline handler);
	void destruct(RenderPass handler);
	void destruct(Sampler handler);
	void destruct(ShaderModule handler);

	@property ImageTemplate framebufferColorImageTemplate();
	@property ImageTemplate framebufferDepthImageTemplate();
	@property void outputRenderPass(RenderPass renderpass);

	@property Framebuffer[] outputFramebuffers();
	@property size_t outputIdx();

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
