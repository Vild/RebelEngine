module buildlib;

import std.process : executeShell;
import std.file : write, remove, tempDir;
import std.path : buildPath;
import std.ascii : letters;
import std.conv : to;
import std.random : randomSample;
import std.utf : byCodeUnit;
import std.format : format;
import std.stdio : stderr;

int main() {
	auto id = letters.byCodeUnit.randomSample(4).to!string;

	auto myFile = tempDir.buildPath("vk_mem_alloc_impl_"~id~".cpp");
	scope (exit)
		remove(myFile);

	write(myFile, `
#define VMA_IMPLEMENTATION
#define VMA_STATIC_VULKAN_FUNCTIONS 0
#include <vk_mem_alloc.h>
`);

	auto tmp = executeShell(format!"g++ -c %1$s -o %1$s.o -I../../3rdparty/VulkanMemoryAllocator/src && ar rvs ./libVulkanMemoryAllocator.a %1$s.o"(myFile));
	if (tmp.status)
		stderr.writeln(tmp.output);
	return tmp.status;
}
