module rebel.view.sdlview;

import rebel.view;
import rebel.renderer;
import rebel.renderer.vkrenderer : IVulkanRenderer, IVulkanView;

import derelict.sdl2.sdl;

//public import derelict.sdl2.image;

import dlsl.vector;

shared static this() {
	DerelictSDL2.load();
	//DerelictSDL2Image.load();
}

void sdlAssert(T, Args...)(T cond, Args args) {
	import std.stdio : stderr;
	import std.string : fromStringz;

	if (!!cond)
		return;
	stderr.writeln(args);
	stderr.writeln("SDL_ERROR: ", SDL_GetError().fromStringz);
	assert(0);
}

final class SDLView : IView, IVulkanView {
public:
	this(string title, ivec2 size) {
		_title = title;
		_size = size;
	}

	void initialize(IRenderer renderer) {
		import std.string : toStringz;

		_renderer = renderer;
		sdlAssert(!SDL_Init(SDL_INIT_EVERYTHING), "SDL could not initialize!");
		//sdlAssert(IMG_Init(IMG_INIT_PNG), "SDL_image could not initialize!");

		SDL_WindowFlags windowFlags = SDL_WINDOW_SHOWN;

		_rendererType = renderer.renderType;
		if (_rendererType == RendererType.vulkan) {
			sdlAssert(!SDL_Vulkan_LoadLibrary(null), "Vulkan failed to load");
			windowFlags |= SDL_WINDOW_VULKAN;
		}

		sdlAssert(_window = SDL_CreateWindow(_title.toStringz, SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, _size.x,
				_size.y, windowFlags), "Failed to create window");
	}

	~this() {
		if (_rendererType == RendererType.vulkan)
			SDL_Vulkan_UnloadLibrary();

		//IMG_Quit();
		SDL_Quit();
	}

	import erupted : PFN_vkGetInstanceProcAddr, VkSurfaceKHR, VkInstance;

	PFN_vkGetInstanceProcAddr getVkGetInstanceProcAddr() {
		return cast(PFN_vkGetInstanceProcAddr)SDL_Vulkan_GetVkGetInstanceProcAddr();
	}

	VkSurfaceKHR createVulkanSurface(VkInstance instance) {
		VkSurfaceKHR surface;
		sdlAssert(SDL_Vulkan_CreateSurface(_window, instance, &surface), "Failed to create VkSurfaceKHR");
		return surface;
	}

	@property const(char)*[] getRequiredVulkanInstanceExtensions() {
		const(char)*[] extensions;
		uint count;

		sdlAssert(SDL_Vulkan_GetInstanceExtensions(_window, &count, null), "Failed to get instance extension count");
		extensions.length = count;
		sdlAssert(SDL_Vulkan_GetInstanceExtensions(_window, &count, &extensions[0]), "Failed to get instance extensions");
		return extensions;
	}

	void doEvents() {
		SDL_Event event;
		while (SDL_PollEvent(&event)) {
			switch (event.type) {
			case SDL_QUIT:
				_quit = true;
				break;
			case SDL_KEYDOWN:
				if (event.key.keysym.sym == SDLK_ESCAPE)
					_quit = true;
				break;
			default:
				break;
			}
		}
	}

	@property bool quit() const {
		return _quit;
	}

	@property ivec2 size() const {
		return _size;
	}

private:
	string _title;
	ivec2 _size;
	bool _quit;

	IRenderer _renderer;
	RendererType _rendererType;

	SDL_Window* _window;
}
