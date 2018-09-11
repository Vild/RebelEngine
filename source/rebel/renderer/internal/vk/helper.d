module rebel.renderer.internal.vk.helper;

import erupted;
import erupted.dispatch_device;

import rebel.renderer.vkrenderer;
import rebel.renderer.internal.vk;

package(rebel.renderer):
void vkAssert(Args...)(VkResult result, Args args) {
	import std.stdio : stderr;
	import std.string : fromStringz;

	if (result == VkResult.VK_SUCCESS)
		return;
	stderr.writeln(args);
	stderr.writeln("Vulkan Result: ", result);
	assert(0);
}

template RemovePointer(T) {
	static if (is(T : X*, X))
		alias RemovePointer = X;
	else
		static assert(0, "Not pointer!");
}

/// VkResult function(Objects..., uint*, T*)
auto getVKList(Func, Objects...)(Func func, Objects objs) {
	import std.traits : Parameters, ReturnType, Unqual;

	static assert(is(Parameters!Func[$ - 2] == uint*));
	RemovePointer!(Parameters!(Func)[$ - 1])[] list;
	uint count;

	static if (is(ReturnType!Func == VkResult))
		vkAssert(func(objs, &count, null), "Getting list count");
	else
		func(objs, &count, null);

	list.length = count;

	static if (is(ReturnType!Func == VkResult))
		vkAssert(func(objs, &count, &list[0]), "Getting list data");
	else
		func(objs, &count, &list[0]);

	return list;
}

/// VkResult function(uint*, T*)
auto getVKList(Func)(Func func) {
	import std.traits : Parameters, ReturnType, Unqual;

	static assert(is(ReturnType!Func == VkResult));
	static assert(is(Parameters!Func[0] == uint*));
	RemovePointer!(Parameters!(Func)[1])[] list;
	uint count;
	vkAssert(func(&count, null), "Getting list count");
	list.length = count;
	vkAssert(func(&count, &list[0]), "Getting list data");
	return list;
}

// Casts @nogc out of a function or delegate type.
import std.traits;

auto assumeNoGC(T)(T t) nothrow if (isFunctionPointer!T || isDelegate!T) {
	enum attrs = functionAttributes!T | FunctionAttribute.nogc;
	return cast(SetFunctionAttributes!(T, functionLinkage!T, attrs))t;
}

enum isCorrectVulkanData(T) = is(typeof((T t) => t.create())) && is(typeof((T t) => t.cleanup()))
		&& is(typeof(T.tupleof[0]) == typeof(T.base));

void setVkObjectName(T)(VKDevice* device, VkObjectType type, T* handle, string name) {
	import std.string : toStringz;

	VkDebugUtilsObjectNameInfoEXT nameInfo;
	nameInfo.objectType = type;
	nameInfo.objectHandle = cast(ulong)handle;
	nameInfo.pObjectName = name.toStringz;

	vkAssert(device.dispatch.SetDebugUtilsObjectNameEXT(&nameInfo));
}
