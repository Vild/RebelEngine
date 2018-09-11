import std.stdio;

import dlsl.vector;

import rebel.config;
import rebel.engine;
import rebel.view;
import rebel.view.sdlview;
import rebel.renderer;
public import rebel.renderer.glrenderer;
public import rebel.renderer.vkrenderer;

import rebel.social;
import rebel.social.discord;

class TestState : IEngineState {
	void enter(IEngineState oldState) {
		_renderer = Engine.instance.renderer;
		_view = Engine.instance.view;
		writeln(__FUNCTION__);
		_createRenderpass();
		_createShaderModules();
		_createPipeline();
		_createCommandBuffers();
	}

	void update(float delta) {
		//writeln(__FUNCTION__);
		_renderer.submit(_commandBuffers[_renderer.outputIdx]);
	}

	void exit(IEngineState newState) {
		writeln(__FUNCTION__);
	}

private:
	IRenderer _renderer;
	IView _view;

	RenderPass _renderPass;
	ShaderModule _vertexShaderModule, _fragmentShaderModule;
	Pipeline _pipeline;

	CommandBuffer[] _commandBuffers;

	void _createRenderpass() {
		Attachment colorAttachment;
		{
			colorAttachment.imageTemplate = _renderer.framebufferImageTemplate;
			colorAttachment.loadOp = LoadOperation.clear;
			colorAttachment.storeOp = StoreOperation.store;
			colorAttachment.stencilLoadOp = LoadOperation.dontCare;
			colorAttachment.stencilStoreOp = StoreOperation.dontCare;
			colorAttachment.initialLayout = ImageLayout.undefined;
			colorAttachment.finalLayout = ImageLayout.present;
		}

		Subpass subpass;
		{
			subpass.bindPoint = SubpassBindPoint.graphics;
			subpass.colorOutput = [SubpassAttachment(&colorAttachment, ImageLayout.color)];
		}

		SubpassDependency dependency;
		{
			dependency.srcSubpass = externalSubpass;
			dependency.dstSubpass = &subpass;
			dependency.srcStageMask = StageFlags.colorOutput;
			dependency.dstStageMask = StageFlags.colorOutput;
			dependency.srcAccessMask = AccessMask.none;
			dependency.dstAccessMask = AccessMask.readwrite;
		}

		RenderPassBuilder builder;
		builder.name = "Main RenderPass";
		builder.attachments = [&colorAttachment];
		builder.subpasses = [&subpass];
		builder.dependencies = [dependency];

		_renderPass = _renderer.construct(builder);
		_renderer.outputRenderPass = _renderPass;
	}

	void _createShaderModules() {
		import std.file : readText;
		import rebel.input.filesystem;

		FileSystem fs = Engine.instance.fileSystem;

		{
			ShaderModuleBuilder vertexBuilder;
			FSFile file = fs.open("vktest/vert.spv", FileMode.read);
			assert(file);
			char[] data;
			scope (exit)
				data.destroy;
			data.length = file.length;
			file.read(data);

			vertexBuilder.name = "vktest/vert.spv";
			vertexBuilder.sourcecode = cast(string)data;
			vertexBuilder.entrypoint = "main";
			vertexBuilder.type = ShaderType.vertex;
			_vertexShaderModule = _renderer.construct(vertexBuilder);
		}

		{
			ShaderModuleBuilder fragmentBuilder;
			FSFile file = fs.open("vktest/frag.spv", FileMode.read);
			assert(file);
			char[] data;
			scope (exit)
				data.destroy;
			data.length = file.length;
			file.read(data);

			fragmentBuilder.name = "vktest/frag.spv";
			fragmentBuilder.sourcecode = cast(string)data;
			fragmentBuilder.entrypoint = "main";
			fragmentBuilder.type = ShaderType.fragment;
			_fragmentShaderModule = _renderer.construct(fragmentBuilder);
		}
	}

	void _createPipeline() {
		PipelineBuilder builder;
		builder.name = "Main Pipeline";
		builder.renderpass = _renderPass;

		builder.shaderStages ~= _vertexShaderModule;
		builder.shaderStages ~= _fragmentShaderModule;

		builder.vertexTopology = VertexTopology.triangleList;

		builder.viewports = [Viewport(vec2(0, 0), cast(vec2)_view.size, vec2(0, 1))];
		builder.scissors = [Scissor(ivec2(0, 0), uvec2(_view.size))];

		builder.rasterizationState.depthClampEnable = false;
		builder.rasterizationState.rasterizerDiscardEnable = false;
		builder.rasterizationState.polygonMode = PolygonMode.fill;
		builder.rasterizationState.lineWidth = 1;
		builder.rasterizationState.cullMode = CullMode.back;
		builder.rasterizationState.frontFace = FrontFaceMode.clockwise;
		builder.rasterizationState.depthBiasEnable = false;

		builder.multisamplingEnabled = false;
		builder.multisamplingCount = SampleCount.Sample1;

		builder.blendState.attachments = [BlendAttachment(ColorComponent.r | ColorComponent.g | ColorComponent.b | ColorComponent.a, false)];
		builder.blendState.logicOpEnable = false;
		builder.blendState.logicOp = LogicOp.copy;
		builder.blendState.blendConstants[] = 0;

		_pipeline = _renderer.construct(builder);
	}

	void _createCommandBuffers() {
		_commandBuffers.length = _renderer.outputFramebuffers.length;
		foreach (i, Framebuffer fb; _renderer.outputFramebuffers) {
			import std.format : format;
			CommandBufferBuilder builder;
			builder.name = format("Main commandbuffer - Framebuffer #%d", i);
			builder.callback = (ICommandBufferRecordingState rs) {
				rs.renderPass = _renderPass;
				rs.framebuffer = fb;
				rs.pipeline = _pipeline;
				rs.renderArea = uvec4(0, 0, _view.size.x, _view.size.y);
				rs.clearColors = [vec4(34 / 255.0f, 0, 34 / 255.0f, 1.0f)];

				rs.finalizeState();

				rs.draw(3, 1, 0, 0);
			};
			_commandBuffers[i] = _renderer.construct(builder);
		}
	}

}

int main(string[] args) {
	/*{
		import std.datetime;

		SocialUpdate update;
		update.startTimestamp = Clock.currTime.toUnixTime;
		update.endTimestamp = (Clock.currTime + 4.hours).toUnixTime;
		update.state = "Loading...";
		update.details = "Setting up renderer!";

		update.largeImageKey = "yelloweyes";
		update.largeImageText = "Yellow Eyes monster";
		update.smallImageKey = "powernex";
		update.smallImageText = "PowerNex";

		update.partyId = "DerpHerpDerp";
		update.partySize = 1;
		update.partyMax = 1;

		update.joinSecret = "MyJoinSecret";
		update.spectateSecret = "MySpectateSecret";

		d.update(update);
	}*/

	Engine e = Engine.instance;
	scope (success)
		e.destroy;

	enum Renderer : int {
		error = -1,
		vulkan = 0,
		gl45,
		quit,
	}

	const string windowTitle = "My SDL2 Window";
	const ivec2 windowSize = ivec2(1920, 1080);
	const string gameName = "My Test Game";
	const Version gameVersion = Version(0, 1, 0);

	Renderer renderer = Renderer.vulkan;
	if (args.length > 1 && args[1] == "selectRenderer") {
		import derelict.sdl2.sdl;

		// dfmt off
		const SDL_MessageBoxButtonData[] buttons = [
			SDL_MessageBoxButtonData(SDL_MESSAGEBOX_BUTTON_RETURNKEY_DEFAULT, Renderer.vulkan, "> Vulkan <"),
			SDL_MessageBoxButtonData(0, Renderer.gl45, "OpenGL 4.5"),
			SDL_MessageBoxButtonData(SDL_MESSAGEBOX_BUTTON_ESCAPEKEY_DEFAULT, Renderer.quit, "Quit"),
		];
		const SDL_MessageBoxColor[5] colorSchemeColors = [
				SDL_MessageBoxColorType.SDL_MESSAGEBOX_COLOR_BACKGROUND: SDL_MessageBoxColor(0x00, 0x22, 0x22),
				SDL_MessageBoxColorType.SDL_MESSAGEBOX_COLOR_TEXT: SDL_MessageBoxColor(0xAA, 0xAA, 0xAA),
				SDL_MessageBoxColorType.SDL_MESSAGEBOX_COLOR_BUTTON_BORDER: SDL_MessageBoxColor(0x00, 0xFF, 0xFF),
				SDL_MessageBoxColorType.SDL_MESSAGEBOX_COLOR_BUTTON_BACKGROUND: SDL_MessageBoxColor(0x00, 0x11, 0x11),
				SDL_MessageBoxColorType.SDL_MESSAGEBOX_COLOR_BUTTON_SELECTED: SDL_MessageBoxColor(0xAA, 0xFF, 0xFF)
		];
		const SDL_MessageBoxColorScheme colorScheme = SDL_MessageBoxColorScheme(colorSchemeColors);
		const SDL_MessageBoxData messageboxdata = SDL_MessageBoxData(
				SDL_MESSAGEBOX_INFORMATION,
				null,
				"RebelEngine - Select renderer",
				"Please select the renderer you want to use",
				cast(int)buttons.length,
				buttons.ptr,
				&colorScheme
		);
		// dfmt on

		if (SDL_ShowMessageBox(&messageboxdata, cast(int*)&renderer) < 0)
			renderer = Renderer.error;
	}

	final switch (renderer) {
	case Renderer.vulkan:
		e.attach(new SDLView(windowTitle, windowSize), new VKRenderer(gameName, gameVersion));
		break;
	case Renderer.gl45:
		e.attach(new SDLView(windowTitle, windowSize), new GLRenderer(gameName, gameVersion));
		break;
	case Renderer.error:
		return -1;
	case Renderer.quit:
		return 0;
	}

	// e.socialService ~= DiscordSocialStatus.getInstance("447520822995845130");
	e.currentState = new TestState;

	return e.mainLoop();
}
