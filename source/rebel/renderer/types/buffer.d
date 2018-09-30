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
	//	void[] deviceMemory;

	void[]delegate(void[] outputBuffer) getData;
	void delegate(void[] data) setData;
}

alias Buffer = Handle!(BufferData, 64);
