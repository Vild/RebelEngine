module rebel.renderer.glrenderer;

import rebel.view;
import rebel.renderer;
import rebel.config;

import dlsl.vector;

interface IOpenGLView : IView {
	@property bool vsync() const;
	@property void vsync(bool enabled);
}

interface IOpenGLRenderer : IRenderer {
	@property ivec2 glVersion() const;
}

final class GLRenderer : IOpenGLRenderer {
public:
	this(string gameName, Version gameVersion) {
		_gameName = gameName;
		_gameVersion = gameVersion;
	}

	void initialize(IView view_) {
		IOpenGLView view = cast(IOpenGLView)view_;
		assert(view);
	}

	@property RendererType renderType() const {
		return RendererType.opengl;
	}

	@property ivec2 glVersion() const {
		return ivec2(4, 5);
	}

private:
	string _gameName;
	Version _gameVersion;
	IVulkanView _view;
}
