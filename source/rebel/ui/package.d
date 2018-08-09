module rebel.ui;

import rebel.input.event;
import rebel.renderer;

import dlsl.vector;

interface IUIView {
	ITexture2D getRendereredFrame();

	@property ivec2 drawAreaSize();
	@property void drawAreaSize(ivec2 size);
}

interface IUIRenderer {
	void newFrame(float delta);
	void endRender();
	void processEvents(Event[] events);
	void resetRenderer();

	@property IUIView worldView();
	@property void worldView(IUIView view);
}
