module rebel.ui;

import rebel.input.event;

interface IUIRenderer {
	void newFrame(float delta);
	void endRender();
	void processEvents(Event[] events);
	void resetRenderer();
}
