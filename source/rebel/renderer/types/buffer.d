module rebel.renderer.types.buffer;

import rebel.renderer.types;

enum BufferUsage {
	vertex = 1 << 0
}

enum BufferSharing {
	exclusive,
	concurrent
}

struct BufferBuilder {
	string name;
	size_t size;
	BufferUsage usage;
	BufferSharing sharing;
}

struct BufferData {
	void[] deviceMemory;

	// TODO: Make more fancy (RAII?)
	void[] delegate() map;
	void delegate() unmap;
}

alias Buffer = Handle!(BufferData, 64);
