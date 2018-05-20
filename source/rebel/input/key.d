module rebel.input.key;

enum Modifier {
	shift,
	ctrl,
	alt,
	super_
}

import derelict.sdl2.internal.sdl_types : SDL_Keycode;

private string mapKeycodes() {
	import std.traits : EnumMembers;
	import std.format : format;
	import std.string : toLower;
	import std.algorithm : map, canFind;
	import std.range : chain;
	import std.array : array;

	dstring[] keywords = ["return", "delete", "out"];

	string output;
	foreach (i, SDL_Keycode key; EnumMembers!SDL_Keycode) {
		dstring name = __traits(allMembers, SDL_Keycode)[i]["SDLK_".length .. $].map!toLower.array;
		if (name.length == 1)
			name = "_" ~ name;
		else if (keywords.canFind(name))
			name ~= "_";
		output ~= format("\t%s = 0x%X,\n", name, key);
	}
	return output;
}

//pragma(msg, "enum Key { \n" ~ mapKeycodes() ~ "\n}");
mixin("enum Key { \n" ~ mapKeycodes() ~ "\n}");
