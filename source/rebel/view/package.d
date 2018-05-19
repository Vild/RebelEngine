module rebel.view;

import rebel.renderer;
import dlsl.vector;

interface IView {
	void initialize(IRenderer renderer);

	void doEvents();

	@property bool quit() const;

	@property ivec2 size() const;
}

final class NullView : IView {
public:
	void initialize(IRenderer renderer) {
		assert(renderer.renderType == RendererType.null_);
	}

	void doEvents() {
	}

	@property bool quit() const {
		return false;
	}

	@property ivec2 size() const {
		return ivec2(0, 0);
	}
}
