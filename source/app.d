import std.stdio;

import gfm.math.vector;
import gfm.math.matrix;
import gfm.math.funcs;

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
		_createBuffers();
		_createPipeline();
		_createCommandBuffers();
	}

	void update(float delta) {
		//writeln(__FUNCTION__);

		{
			static float counter = 0;
			counter += delta;

			VkTestUniformBufferObject ubo;
			ubo.model = mat4f.rotation(counter * radians(90.0f), vec3f(0, 0, 1)).transposed;
			ubo.view = mat4f.lookAt(vec3f(2.0f, 2.0f, 2.0f), vec3f(0.0f, 0.0f, 0.0f), vec3f(0.0f, 0.0f, 1.0f)).transposed;
			ubo.proj = mat4f.perspective(radians(45.0f), _view.size.x / cast(float)_view.size.y, 0.1f, 10.0f).transposed;

			if (_renderer.renderType == RendererType.vulkan)
				ubo.proj.c[1][1] *= -1;

			scope Buffer.Ref data = _renderer.get(_uboBuffers[_renderer.outputIdx]);
			BufferData* buffer = data.get();
			buffer.setData((cast(ubyte*)&ubo)[0 .. ubo.sizeof]);
		}

		_renderer.submit(_commandBuffers[_renderer.outputIdx]);
	}

	void exit(IEngineState newState) {
		writeln(__FUNCTION__);
	}

private:
	alias Position = VertexShaderData!(vec2f, ImageFormat.rg32_float);
	alias Color = VertexShaderData!(vec3ub, ImageFormat.rgb8_unorm);

	@VertexDataRate(VertexDataRate.vertex) struct VkTestShaderDataVertex {
		Position position;
		Color color;
	}

	struct VkTestUniformBufferObject {
		mat4f model;
		mat4f view;
		mat4f proj;
	}

	IRenderer _renderer;
	IView _view;

	RenderPass _renderPass;
	ShaderModule _vertexShaderModule, _fragmentShaderModule;
	Buffer _verticesBuffer, _indicesBuffer;
	Buffer[] _uboBuffers;
	Pipeline _pipeline;

	CommandBuffer[] _commandBuffers;

	enum Bindings : uint {
		vertex = 0, // Basically just a misc
		uniformBufferObject = 0
	}

	// dfmt off
	VkTestShaderDataVertex[] _vertices = [
		VkTestShaderDataVertex(Position(-0.5f, -0.5f), Color(ubyte.max, ubyte.min, ubyte.min)),
		VkTestShaderDataVertex(Position(0.5f, -0.5f), Color(ubyte.min, ubyte.max, ubyte.min)),
		VkTestShaderDataVertex(Position(0.5f, 0.5f), Color(ubyte.min, ubyte.min, ubyte.max)),
		VkTestShaderDataVertex(Position(-0.5f, 0.5f), Color(ubyte.max, ubyte.max, ubyte.max))
	];
	ushort[] _indices = [
		0, 1, 2,
		2, 3, 0
	];
	// dfmt on

	void _createRenderpass() {
		Attachment* colorAttachment = new Attachment;
		{
			colorAttachment.imageTemplate = _renderer.framebufferImageTemplate;
			colorAttachment.loadOp = LoadOperation.clear;
			colorAttachment.storeOp = StoreOperation.store;
			colorAttachment.stencilLoadOp = LoadOperation.dontCare;
			colorAttachment.stencilStoreOp = StoreOperation.dontCare;
			colorAttachment.initialLayout = ImageLayout.undefined;
			colorAttachment.finalLayout = ImageLayout.present;
		}

		Subpass* subpass = new Subpass;
		{
			subpass.bindPoint = SubpassBindPoint.graphics;
			subpass.colorOutput = [SubpassAttachment(colorAttachment, ImageLayout.color)];
		}

		SubpassDependency dependency;
		{
			dependency.srcSubpass = externalSubpass;
			dependency.dstSubpass = subpass;
			dependency.srcStageMask = StageFlags.colorOutput;
			dependency.dstStageMask = StageFlags.colorOutput;
			dependency.srcAccessMask = AccessMask.none;
			dependency.dstAccessMask = AccessMask.readwrite;
		}

		RenderPassBuilder builder;
		builder.name = "Main RenderPass";
		builder.attachments = [colorAttachment];
		builder.subpasses = [subpass];
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

	void _createBuffers() {
		{
			BufferBuilder builder;
			builder.name = "Vertices Buffer";
			builder.size = _vertices.length * _vertices[0].sizeof;
			builder.usage = BufferUsage.vertex;
			builder.sharing = BufferSharing.exclusive;

			_verticesBuffer = _renderer.construct(builder);

			scope Buffer.Ref data = _renderer.get(_verticesBuffer);
			BufferData* buffer = data.get();
			buffer.setData(_vertices);
		}
		{
			BufferBuilder builder;
			builder.name = "Indices Buffer";
			builder.size = _indices.length * _indices[0].sizeof;
			builder.usage = BufferUsage.index;
			builder.sharing = BufferSharing.exclusive;

			_indicesBuffer = _renderer.construct(builder);

			scope Buffer.Ref data = _renderer.get(_indicesBuffer);
			BufferData* buffer = data.get();
			buffer.setData(_indices);
		}

		_uboBuffers.length = _renderer.outputFramebuffers.length;
		foreach (i, ref uboBuffer; _uboBuffers) {
			import std.format : format;

			BufferBuilder builder;
			builder.name = format!"UBO Buffer - Framebuffer #%d"(i);
			builder.size = VkTestUniformBufferObject.sizeof;
			builder.usage = BufferUsage.uniform;
			builder.sharing = BufferSharing.exclusive;

			uboBuffer = _renderer.construct(builder);
		}
	}

	void _createPipeline() {
		PipelineBuilder builder;
		builder.name = "Main Pipeline";
		builder.renderpass = _renderPass;

		builder.shaderStages ~= _vertexShaderModule;
		builder.shaderStages ~= _fragmentShaderModule;

		alias vktestVertex = VertexShaderInputInfo!VkTestShaderDataVertex;
		builder.vertexInputBindingDescriptions ~= vktestVertex.getVertexBindingDescription(Bindings.vertex);
		builder.vertexInputAttributeDescriptions ~= vktestVertex.getVertexAttributeDescriptions(Bindings.vertex);

		alias vktestUBO = ShaderInputInfo!VkTestUniformBufferObject;
		builder.descriptorSetLayoutBindings ~= vktestUBO.getDescriptorSetLayoutBinding(Bindings.uniformBufferObject, ShaderStages.vertex);

		foreach (i, uboBuffer; _uboBuffers)
			builder.descriptorBufferInfos ~= vktestUBO.getDescriptorBufferInfo(uboBuffer, Bindings.uniformBufferObject);

		builder.vertexTopology = VertexTopology.triangleList;

		builder.viewports = [Viewport(vec2f(0, 0), vec2f(_view.size), vec2f(0, 1))];
		builder.scissors = [Scissor(vec2i(0, 0), cast(vec2ui)_view.size)];

		builder.rasterizationState.depthClampEnable = false;
		builder.rasterizationState.rasterizerDiscardEnable = false;
		builder.rasterizationState.polygonMode = PolygonMode.fill;
		builder.rasterizationState.lineWidth = 1;
		builder.rasterizationState.cullMode = CullMode.back;
		builder.rasterizationState.frontFace = FrontFaceMode.counterClockwise;
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
		foreach (i; 0 .. _renderer.outputFramebuffers.length) {
			import std.format : format;

			CommandBufferBuilder builder;
			builder.name = format("Main commandbuffer - Framebuffer #%d", i);
			builder.callback = (size_t fbIndex) {
				return (ICommandBufferRecordingState rs) {
					Framebuffer fb = _renderer.outputFramebuffers[fbIndex];
					vec2ui size;
					{
						scope Framebuffer.Ref fbRef = _renderer.get(fb);
						FramebufferData* data = fbRef.get();
						size = data.dimension.xy;
					}

					rs.index = fbIndex;
					rs.renderPass = _renderPass;
					rs.framebuffer = fb;
					rs.pipeline = _pipeline;
					rs.renderArea = vec4ui(0, 0, size.x, size.y);
					rs.clearColors = [vec4f(34 / 255.0f, 0, 34 / 255.0f, 1.0f)];

					rs.finalizeState();

					rs.bindVertexBuffer(Bindings.vertex, [BufferOffset(_verticesBuffer, 0)]);
					rs.bindIndexBuffer(BufferOffset(_indicesBuffer, 0), IndexType.u16);
					rs.drawIndexed(cast(uint)_indices.length, 1, 0, 0, 0);
				};
			}(i);
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
	const vec2i windowSize = vec2i(1920, 1080);
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
