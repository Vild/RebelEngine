module rebel.renderer.types.buffer;

import rebel.renderer.types;

enum BufferUsage {
	vertex = 1 << 0,
	index = 1 << 1,
	uniform = 1 << 2
}

enum BufferSharing {
	exclusive,
	concurrent
}

enum MemoryUsage {
	gpuOnly,
	cpuOnly,
	cpuToGPU,
	gpuToCPU
}

struct BufferBuilder {
	string name;
	size_t size;
	BufferUsage bufferUsage;
	BufferSharing sharing;
	MemoryUsage memoryUsage;
	//TODO: Add bool isGpuOnly?
}

struct BufferData {
	//	void[] deviceMemory;

	void[]delegate(void[] outputBuffer) getData;
	void delegate(void[] data) setData;
}

alias Buffer = Handle!(BufferData, 64);
