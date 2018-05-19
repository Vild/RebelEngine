import std.stdio;

import dlsl.vector;

import rebel.config;
import rebel.engine;
import rebel.view.sdlview;
import rebel.renderer.vkrenderer;

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
	Engine e = new Engine;
	scope (exit)
		e.destroy;

	e.attach(new SDLView("My SDL2 Window", ivec2(1920, 1080)), new VKRenderer("My Test Game", Version(0, 1, 0)));

	e.currentState = new TestState;

	return e.mainLoop();
}
