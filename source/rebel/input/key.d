module rebel.input.key;

import derelict.sdl2.internal.sdl_types;
import std.bitmanip;

private string makeBitfield(T)() {
	import std.traits : EnumMembers;
	import std.format : format;
	import std.math : floor, log2;

	string output = "mixin(bitfields!(\n";
	foreach (i, T key; EnumMembers!T)
		output ~= format("\tbool, \"%s\", 1,\n", __traits(allMembers, T)[i]);

	size_t len = [__traits(allMembers, T)].length;

	size_t roundUp = 2 ^^ cast(ulong)floor(log2(len - 1));
	if (roundUp < 8)
		roundUp = 8;
	assert(roundUp < 64);

	if (len != roundUp)
		output ~= format("\tuint, \"\", %d\n", roundUp - len);
	output ~= "));";
	return output;
}

enum MouseButton {
	left,
	right,
	middle,
	x1,
	x2
}

struct MouseButtonState {
	mixin(makeBitfield!MouseButton);
}

enum Modifier {
	ctrl,
	shift,
	alt,
	super_
}

struct ModifierState {
	mixin(makeBitfield!Modifier);
}

ModifierState translateModifier(SDL_Keymod keymod) {
	ModifierState m;
	m.ctrl = !!(keymod & SDL_Keymod.KMOD_CTRL);
	m.shift = !!(keymod & SDL_Keymod.KMOD_SHIFT);
	m.alt = !!(keymod & SDL_Keymod.KMOD_ALT);
	m.super_ = !!(keymod & SDL_Keymod.KMOD_GUI);
	return m;
}

private string makeKeys() {
	import std.traits : EnumMembers;
	import std.format : format;
	import std.string : toLower, isNumeric;
	import std.algorithm : map, canFind;
	import std.range : chain;
	import std.array : array;

	dstring[] keywords = ["return", "delete", "out"];

	string output;
	foreach (i, SDL_Scancode key; EnumMembers!SDL_Scancode) {
		int value = cast(int)key;
		dstring name = __traits(allMembers, SDL_Scancode)[i]["SDL_SCANCODE_".length .. $].map!toLower.array;
		if (name.isNumeric)
			name = "_" ~ name;
		else if (keywords.canFind(name))
			name ~= "_";

		/+if (value & SDLK_SCANCODE_MASK)
			value = /*Ascii length*/ 0x80 + (value & ~SDLK_SCANCODE_MASK);+/

		output ~= format("\t%s = %s, \n", name, value);
	}
	return output;
}

private enum code = "enum Key : int { \n" ~ makeKeys() ~ "\n}";

//pragma(msg, code);
mixin(code);

Key translateKey(SDL_Scancode code) {
	import std.traits : EnumMembers;

		return cast(Key)code;
	/+switch (keycode) {
		static foreach (SDL_Scancode key; EnumMembers!SDL_Scancode) {
	case key:
			static if (key & SDLK_SCANCODE_MASK)
				return cast(Key)(0x80 + (key & ~SDLK_SCANCODE_MASK));
			else
				return cast(Key)key;
		}
	default:
		import std.stdio;

		writeln("key: ", keycode);
		return Key.unknown;
	}+/
}
