module rebel.renderer;

import rebel.view;

public import rebel.renderer.vkrenderer : IVulkanRenderer, IVulkanView;
public import rebel.renderer.glrenderer : IOpenGLRenderer, IOpenGLView;

enum RendererType {
	null_,
	vulkan,
	opengl
}

interface ISubpassAttachmentBuilder {
	void yes();

	// for vulkan:
	// vkAttachmentReference getReference();
}

interface ISubpassBuilder {
	ISubpassBuilder attach(ISubpassAttachmentBuilder attachment);
}

interface IRenderpassBuilder {
	IRenderpassBuilder attach(ISubpassBuilder subpass);
	IRenderpassBuilder depend(ISubpassBuilder source, ISubpassBuilder target, int DERP);
}

interface IPipeline {
}

interface IShaderModule {
}

interface IPipelineBuilder {
	IPipelineBuilder addShader(IShaderModule shaderModule);

	IPipeline set(IRenderpassBuilder renderpass);

	IPipeline construct();
}

interface IRenderer {
	void initialize(IView view);

	// IPipelineBuilder newPipeline();

	@property RendererType renderType() const;
}

final class NullRenderer {
public:
	void initialize(IView view) {
		assert(cast(NullView)view);
	}

	@property RendererType renderType() const {
		return RendererType.null_;
	}
}
