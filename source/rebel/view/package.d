module rebel.view;

import rebel.renderer;
import rebel.input.event;
import rebel.input.key;

import dlsl.vector;

struct MouseState {
	bool isFocused;
	ivec2 position;
	MouseButtonState buttons;
}

interface IView {
	void initialize(IRenderer renderer);

	void doEvents(ref Event[] events);

	void finalizeFrame();

	@property bool quit() const;

	@property ivec2 size();
	@property ivec2 drawableSize();

	@property MouseState mouseState();
}

final class NullView : IView {
public:
	void initialize(IRenderer renderer) {
		assert(renderer.renderType == RendererType.null_);
	}

	void doEvents(ref Event[] events) {
	}

void finalizeFrame() {}

	@property bool quit() const {
		return false;
	}

	@property ivec2 size() {
		return ivec2(0, 0);
	}

	@property ivec2 drawableSize() {
		return size;
	}

	@property MouseState mouseState() {
		return MouseState(false);
	}
}
