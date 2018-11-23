module rebel.view;

import rebel.renderer;
import rebel.input.event;
import rebel.input.key;

import gfm.math.vector;

struct MouseState {
	bool isFocused;
	vec2i position;
	MouseButtonState buttons;
}

interface IView {
	void initialize(IRenderer renderer);

	void doEvents(ref Event[] events);

	void finalizeFrame();

	@property bool quit() const;

	@property vec2i size();
	@property vec2i drawableSize();

	@property MouseState mouseState();
	@property void cursorVisibillity(bool visible);

	@property string clipboard();
	@property void clipboard(string data);
}

final class NullView : IView {
public:
	void initialize(IRenderer renderer) {
		assert(renderer.renderType == RendererType.null_);
	}

	void doEvents(ref Event[] events) {
	}

	void finalizeFrame() {
	}

	@property bool quit() const {
		return false;
	}

	@property vec2i size() {
		return vec2i(0, 0);
	}

	@property vec2i drawableSize() {
		return size;
	}

	@property MouseState mouseState() {
		return MouseState(false);
	}

	@property void cursorVisibillity(bool visible) {
	}

	@property string clipboard() {
		return "";
	}

	@property void clipboard(string data) {
	}
}
