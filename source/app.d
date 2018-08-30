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
		writeln(__FUNCTION__);
		_createRenderpass();
		_createShaderModules();
	}

	void update(float delta) {
		//writeln(__FUNCTION__);
	}

	void exit(IEngineState newState) {
		writeln(__FUNCTION__);
	}

private:
	RenderPass _renderPass;
	ShaderModule _vertexShaderModule, _fragmentShaderModule;

	void _createRenderpass() {
		IRenderer renderer = Engine.instance.renderer;
		{
			Attachment colorAttachment;
			{
				colorAttachment.format = ImageFormat.rgb888;
				colorAttachment.samples = 1;
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
			builder.attachments = [&colorAttachment];
			builder.subpasses = [&subpass];
			builder.dependencies = [dependency];

			_renderPass = renderer.construct(builder);
		}
	}

	void _createShaderModules() {
		import std.file : readText;
		import rebel.input.filesystem;

		IRenderer renderer = Engine.instance.renderer;
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
			vertexBuilder.sourcecode = cast(string)data;
			_vertexShaderModule = renderer.construct(vertexBuilder);
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
			fragmentBuilder.sourcecode = cast(string)data;
			_fragmentShaderModule = renderer.construct(fragmentBuilder);
		}
	}

	void _createPipeline() {
		IRenderer renderer = Engine.instance.renderer;
		IView view = Engine.instance.view;

		PipelineBuilder builder;
		builder.shaderStages ~= _vertexShaderModule;
		builder.shaderStages ~= _fragmentShaderModule;

		builder.vertexTopology = VertexTopology.triangleList;

		builder.viewports = [Viewport(vec2(0, 0), cast(vec2)view.size, vec2(0, 1))];
		builder.scissors = [Scissor(ivec2(0, 0), uvec2(view.size))];

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

		renderer.construct(builder);
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
	scope (exit)
		e.destroy;

	e.attach(new SDLView("My SDL2 Window", ivec2(1920, 1080)), new VKRenderer("My Test Game", Version(0, 1, 0)));
	//e.attach(new SDLView("My SDL2 Window", ivec2(1920, 1080)), new GLRenderer("My Test Game", Version(0, 1, 0)));

	// e.socialService ~= DiscordSocialStatus.getInstance("447520822995845130");
	e.currentState = new TestState;

	return e.mainLoop();
}
