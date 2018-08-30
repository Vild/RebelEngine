module rebel.engine;

import rebel.view;
import rebel.renderer;

import rebel.input.filesystem;
import rebel.input.event;

import rebel.social;

import rebel.ui;
import rebel.ui.imgui;

import core.time;

interface IEngineState {
	void enter(IEngineState oldState);
	void update(float delta);
	void exit(IEngineState newState);
}

import dlsl.vector;

final class TestView : IUIView, ITexture2D {

	import opengl.gl4;

public:
	this() {
		glGenFramebuffers(1, &_fb);
		glBindFramebuffer(GL_FRAMEBUFFER, _fb);

		glGenTextures(1, &_color);
		glActiveTexture(GL_TEXTURE0);
		glBindTexture(GL_TEXTURE_2D, _color);
		glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, _drawAreaSize.x, _drawAreaSize.y, 0, GL_RGB, GL_UNSIGNED_BYTE, null);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
		glFramebufferTexture(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, _color, 0);

		glGenTextures(1, &_depth);
		glActiveTexture(GL_TEXTURE0);
		glBindTexture(GL_TEXTURE_2D, _depth);
		glTexImage2D(GL_TEXTURE_2D, 0, GL_DEPTH_COMPONENT, _drawAreaSize.x, _drawAreaSize.y, 0, GL_DEPTH_COMPONENT, GL_FLOAT, null);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_BORDER);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_BORDER);
		GLfloat[4] border = [1, 1, 1, 1];
		glTexParameterfv(GL_TEXTURE_2D, GL_TEXTURE_BORDER_COLOR, border.ptr);
		glFramebufferTexture(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, _depth, 0);
		glDrawBuffer(GL_NONE);

		GLenum[] buffers = [GL_COLOR_ATTACHMENT0];
		glDrawBuffers(cast(GLsizei)(buffers.length), buffers.ptr);
		GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
		assert(status == GL_FRAMEBUFFER_COMPLETE);
	}

	~this() {
		glDeleteTextures(1, &_depth);
		glDeleteTextures(1, &_color);
		glDeleteFramebuffers(1, &_fb);
	}

	void render() {
		import std.math : sin, abs;

		glBindFramebuffer(GL_FRAMEBUFFER, _fb);
		glClearColor((_drawAreaSize.x / 400.0f).sin.abs, (_drawAreaSize.y / 400.0f).sin.abs,
				((_drawAreaSize.x + _drawAreaSize.y) / 400.0f).sin.abs, 1);
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
		glBindFramebuffer(GL_FRAMEBUFFER, 0);
	}

	ITexture2D getRendereredFrame() {
		return this;
	}

	@property ivec2 drawAreaSize() {
		return _drawAreaSize;
	}

	@property void drawAreaSize(ivec2 size) {
		if (size.x < 1)
			size.x = 1;
		if (size.y < 1)
			size.y = 1;
		_drawAreaSize = size;

		glBindTexture(GL_TEXTURE_2D, _color);
		glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, _drawAreaSize.x, _drawAreaSize.y, 0, GL_RGB, GL_UNSIGNED_BYTE, null);
		glBindTexture(GL_TEXTURE_2D, _depth);
		glTexImage2D(GL_TEXTURE_2D, 0, GL_DEPTH_COMPONENT, _drawAreaSize.x, _drawAreaSize.y, 0, GL_DEPTH_COMPONENT, GL_FLOAT, null);
		glBindTexture(GL_TEXTURE_2D, 0);
	}

	@property ivec2 getSize() {
		return _drawAreaSize;
	}

	@property void* getHandle() {
		return &_fb;
	}

private:
	GLuint _fb;
	ivec2 _drawAreaSize = ivec2(640, 480);

	GLuint _color;
	GLuint _depth;
}

final class Engine {
public:
	this() {
		_instance = this;
		_fileSystem = new FileSystem();
	}

	static Engine instance() {
		if (!_instance)
			_instance = new Engine();
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

		/*_ui = new ImguiUI(view);
		_testView = new TestView();
		_ui.worldView = _testView;*/
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
			if (_ui)
				_ui.processEvents(_events);
			_renderer.newFrame();
			if (_ui)
				_ui.newFrame(delta);

			if (_testView)
				_testView.render();

			_currentState.update(delta);

			if (_ui)
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

	@property IUIRenderer ui() {
		return _ui;
	}

	@property ref ISocialService[] socialService() {
		return _socialService;
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
	ISocialService[] _socialService;

	TestView _testView;
}
