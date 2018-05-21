module rebel.input.event;

import std.variant;
import rebel.input.key;

alias Event = Algebraic!(MouseWheelEvent, MouseButtonEvent, KeyEvent, TextInputEvent);

struct MouseWheelEvent {
	int deltaX, deltaY;
}

struct MouseButtonEvent {
	MouseButton button;
	bool isDown;
	ubyte clicks;

	int x, y;
}

struct KeyEvent {
import rebel.input.key : Key;
	Key key;
	ModifierState modifiers;
	ubyte repeat;
	bool isDown;
}

// make sure to do this somewhere for imgui SDL_SetTextInputRect
struct TextInputEvent {
	char[32] text;
}
