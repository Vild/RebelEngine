import std.stdio;

import dlsl.vector;

import rebel.config;
import rebel.engine;
import rebel.view.sdlview;
import rebel.renderer;
public import rebel.renderer.glrenderer;

import rebel.social;
import rebel.social.discord;

class TestState : IEngineState {
	void enter(IEngineState oldState) {
		writeln(__FUNCTION__);

	}

	void update(float delta) {
		//writeln(__FUNCTION__);
	}

	void exit(IEngineState newState) {
		writeln(__FUNCTION__);
	}

private:
	Renderpass _renderPass;
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
				dependency.srcStageMask = StageMask.colorOutput;
				dependency.dstStageMask = StageMask.colorOutput;
				dependency.srcAccessMask = AccessMask.none;
				dependency.dstAccessMask = AccessMask.readwrite;
			}

			RenderpassBuilder builder;
			builder.attachments = [&colorAttachment];
			builder.subpasses = [&subpass];
			builder.dependency = [dependency];

			_renderPass = renderer.construct(builder);
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
	scope (exit)
		e.destroy;

	// e.attach(new SDLView("My SDL2 Window", ivec2(1920, 1080)), new VKRenderer("My Test Game", Version(0, 1, 0)));
	e.attach(new SDLView("My SDL2 Window", ivec2(1920, 1080)), new GLRenderer("My Test Game", Version(0, 1, 0)));

	// e.socialService ~= DiscordSocialStatus.getInstance("447520822995845130");
	e.currentState = new TestState;

	return e.mainLoop();
}
