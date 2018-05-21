module rebel.engine;

import rebel.view;
import rebel.renderer;

import rebel.input.filesystem;
import rebel.input.event;

import rebel.ui;
import rebel.ui.imgui;

import core.time;

interface IEngineState {
	void enter(IEngineState oldState);
	void update(float delta);
	void exit(IEngineState newState);
}

final class Engine {
public:
	this() {
		_instance = this;
		_fileSystem = new FileSystem();
	}

	static Engine instance() {
		return _instance;
	}

	~this() {
		_renderer.destroy;
		_view.destroy;
		_instance = null;
	}

	void attach(IView view, IRenderer renderer) {
		_view = view;
		_renderer = renderer;

		view.initialize(renderer);
		renderer.initialize(view);

		_ui = new ImguiUI(view);
	}

	int mainLoop() {
		_currentState = _nextState;
		_nextState = null;
		_currentState.enter(null);

		_oldTime = MonoTime.currTime;
		while (_currentState && !_view.quit) {
			MonoTime curTime = MonoTime.currTime;
			const float delta = (curTime - _oldTime).total!"usecs" / 1_000_000.0f; //1 000 000 µsec/ 1 sec
			_oldTime = curTime;

			_view.doEvents(_events);
			_ui.processEvents(_events);
			_renderer.newFrame();
			_ui.newFrame(delta);

			_currentState.update(delta);

			_ui.endRender();
			_renderer.finalize();
			_view.finalizeFrame();

			_events.length = 0;
			if (_nextState) {
				_nextState.enter(_currentState);
				_currentState.exit(_nextState);

				_currentState.destroy;
				_currentState = _nextState;
				_nextState = null;
			}
		}
		if (_currentState) {
			_currentState.exit(null);
			_currentState.destroy;
			_currentState = null;
		}

		return 0;
	}

	void pushEvent(Event event) {
		_events ~= event;
	}

	@property FileSystem fileSystem() {
		return _fileSystem;
	}

	@property IView view() {
		return _view;
	}

	@property IRenderer renderer() {
		return _renderer;
	}

	@property IEngineState currentState() {
		return _currentState;
	}

	@property void currentState(IEngineState nextState) {
		_nextState = nextState;
	}

	@property Event[] events() {
		return _events;
	}

private:
	static Engine _instance;
	MonoTime _oldTime;
	FileSystem _fileSystem;

	IView _view;
	IRenderer _renderer;

	IEngineState _currentState;
	IEngineState _nextState;

	Event[] _events;

	IUIRenderer _ui;
}
