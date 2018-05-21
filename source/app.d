import std.stdio;

import dlsl.vector;

import rebel.config;
import rebel.engine;
import rebel.view.sdlview;
import rebel.renderer.vkrenderer;
import rebel.renderer.glrenderer;

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
}

int main(string[] args) {
	ISocialStatus d = DiscordSocialStatus.getInstance("447520822995845130");
	scope (exit)
		d.destroy;

	{
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
	}

	Engine e = new Engine;
	scope (exit)
		e.destroy;

	//e.attach(new SDLView("My SDL2 Window", ivec2(1920, 1080)), new VKRenderer("My Test Game", Version(0, 1, 0)));
	e.attach(new SDLView("My SDL2 Window", ivec2(1920, 1080)), new GLRenderer("My Test Game", Version(0, 1, 0)));

	e.currentState = new TestState;

	return e.mainLoop();
}
