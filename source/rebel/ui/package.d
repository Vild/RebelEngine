module rebel.ui;

import rebel.input.event;
import rebel.renderer;

import gfm.math.vector;

interface IUIView {
	ITexture2D getRendereredFrame();

	@property vec2i drawAreaSize();
	@property void drawAreaSize(vec2i size);
}

interface IUIRenderer {
	void newFrame(float delta);
	void endRender();
	void processEvents(Event[] events);
	void resetRenderer();

	@property IUIView worldView();
	@property void worldView(IUIView view);
}
