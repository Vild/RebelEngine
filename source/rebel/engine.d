module rebel.engine;

import rebel.view;
import rebel.renderer;

interface IEngineState {
	void enter(IEngineState oldState);
	void update(float delta);
	void exit(IEngineState newState);
}

final class Engine {
public:
	 ~this() {
		_renderer.destroy;
		_view.destroy;
	}

	void attach(IView view, IRenderer renderer) {
		_view = view;
		_renderer = renderer;

		view.initialize(renderer);
		renderer.initialize(view);
	}

	int mainLoop() {
		_currentState = _nextState;
		_nextState = null;
		_currentState.enter(null);

		while (_currentState && !_view.quit) {
			_view.doEvents();
			_currentState.update(1 / 60.0f);

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

	@property IEngineState currentState() {
		return _currentState;
	}

	@property void currentState(IEngineState nextState) {
		_nextState = nextState;
	}

private:
	IView _view;
	IRenderer _renderer;

	IEngineState _currentState;
	IEngineState _nextState;
}
