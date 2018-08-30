module rebel.renderer.internal.vk.helper;

import erupted;
import erupted.dispatch_device;

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

/// VkResult function(Object, uint*, T*)
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

static VkResult CreateDebugReportCallbackEXT(VkInstance instance, const VkDebugReportCallbackCreateInfoEXT* pCreateInfo,
		const VkAllocationCallbacks* pAllocator, VkDebugReportCallbackEXT* pCallback) {
	auto func = cast(PFN_vkCreateDebugReportCallbackEXT)vkGetInstanceProcAddr(instance, "vkCreateDebugReportCallbackEXT");
	if (func)
		return func(instance, pCreateInfo, pAllocator, pCallback);
	else
		return VK_ERROR_EXTENSION_NOT_PRESENT;
}

static void DestroyDebugReportCallbackEXT(VkInstance instance, VkDebugReportCallbackEXT callback, const VkAllocationCallbacks* pAllocator) {
	auto func = cast(PFN_vkDestroyDebugReportCallbackEXT)vkGetInstanceProcAddr(instance, "vkDestroyDebugReportCallbackEXT");
	if (func)
		func(instance, callback, pAllocator);
}
// Casts @nogc out of a function or delegate type.
import std.traits;

auto assumeNoGC(T)(T t) nothrow if (isFunctionPointer!T || isDelegate!T) {
	enum attrs = functionAttributes!T | FunctionAttribute.nogc;
	return cast(SetFunctionAttributes!(T, functionLinkage!T, attrs))t;
}
