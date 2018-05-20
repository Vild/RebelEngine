module rebel.input.event;

import std.variant;
import rebel.input.key;

alias Event = Algebraic!(MouseWheelEvent, MouseButtonEvent, KeyEvent, TextInputEvent);

struct MouseWheelEvent {
	int deltaX, deltaY;
}

struct MouseButtonEvent {
	enum Button {
		left,
		right,
		center,
		x1,
		x2
	}

	Button button;
	bool isDown;
	ubyte clicked;

	int x, y;
}

struct KeyEvent {
	Key key;
	Modifier modifiers;
	bool isRepeat;
	bool isDown;
}

// make sure to do this somewhere for imgui SDL_SetTextInputRect
struct TextInputEvent {
	char[32] text;
}
