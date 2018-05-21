module rebel.view.sdlview;

import rebel.view;
import rebel.renderer;
import rebel.input.event;
import rebel.input.key;

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

final class SDLView : IView, IVulkanView, IOpenGLView {
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

		SDL_WindowFlags windowFlags = SDL_WindowFlags.SDL_WINDOW_SHOWN;

		_rendererType = renderer.renderType;
		if (_rendererType == RendererType.vulkan) {
			sdlAssert(!SDL_Vulkan_LoadLibrary(null), "Vulkan failed to load");
			windowFlags |= SDL_WindowFlags.SDL_WINDOW_VULKAN;
		} else if (_rendererType == RendererType.opengl) {
			windowFlags |= SDL_WindowFlags.SDL_WINDOW_OPENGL;

			auto glRenderer = cast(IOpenGLRenderer)renderer;
			int flags = SDL_GL_CONTEXT_FORWARD_COMPATIBLE_FLAG;
			debug flags |= SDL_GL_CONTEXT_DEBUG_FLAG;

			SDL_GL_SetAttribute(SDL_GL_CONTEXT_FLAGS, flags);
			SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_CORE);
			SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1);
			SDL_GL_SetAttribute(SDL_GL_DEPTH_SIZE, 24);
			SDL_GL_SetAttribute(SDL_GL_STENCIL_SIZE, 8);

			auto glVersion = glRenderer.glVersion;
			SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, glVersion.x);
			SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, glVersion.y);
		}

		sdlAssert(_window = SDL_CreateWindow(_title.toStringz, SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, _size.x,
				_size.y, windowFlags), "Failed to create window");

		if (_rendererType == RendererType.opengl) {
			_glContext = SDL_GL_CreateContext(_window);
			vsync = true;
		}
	}

	~this() {
		if (_rendererType == RendererType.vulkan)
			SDL_Vulkan_UnloadLibrary();
		else if (_rendererType == RendererType.opengl)
			SDL_GL_DeleteContext(_glContext);

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

	void doEvents(ref Event[] events) {
		import std.stdio;

		immutable MouseButton[ubyte] translateMouseButton = [
	SDL_BUTTON_LEFT : MouseButton.left, SDL_BUTTON_MIDDLE : MouseButton.middle, SDL_BUTTON_RIGHT : MouseButton.right,
	SDL_BUTTON_X1 : MouseButton.x1, SDL_BUTTON_X2 : MouseButton.x2
		];

		SDL_Event event;
		while (SDL_PollEvent(&event)) {
			switch (event.type) {
			case SDL_QUIT:
				_quit = true;
				break;
			case SDL_MOUSEWHEEL:
				events ~= MouseWheelEvent(event.wheel.x, event.wheel.y).Event;
				break;
			case SDL_MOUSEBUTTONUP:
			case SDL_MOUSEBUTTONDOWN:
				MouseButtonEvent mb;
				mb.button = translateMouseButton[event.button.button];
				mb.isDown = event.button.state == SDL_PRESSED;
				mb.clicks = event.button.clicks;
				mb.x = event.button.x;
				mb.y = event.button.y;
				events ~= mb.Event;
				break;
			case SDL_KEYUP:
			case SDL_KEYDOWN:
				if (event.key.keysym.sym == SDLK_ESCAPE) {
					_quit = true;
					break;
				}

				KeyEvent key;
				key.key = event.key.keysym.scancode.translateKey;
				key.modifiers = translateModifier(cast(SDL_Keymod)event.key.keysym.mod);
				key.repeat = event.key.repeat;
				key.isDown = event.key.state == SDL_PRESSED;
				events ~= key.Event;

				break;
			case SDL_TEXTINPUT:
				events ~= TextInputEvent(event.text.text).Event;
				break;
			default:
				break;
			}
		}
	}

	void finalizeFrame() {
		if (_rendererType == RendererType.opengl)
			SDL_GL_SwapWindow(_window);
	}

	@property bool quit() const {
		return _quit;
	}

	@property ivec2 size() {
		int x, y;
		SDL_GetWindowSize(_window, &x, &y);
		return ivec2(x, y);
	}

	@property ivec2 drawableSize() {
		int x, y;
		if (_rendererType == RendererType.vulkan)
			SDL_Vulkan_GetDrawableSize(_window, &x, &y);
		else if (_rendererType == RendererType.opengl)
			SDL_GL_GetDrawableSize(_window, &x, &y);
		return ivec2(x, y);
	}

	@property bool vsync() const {
		return _vsync;
	}

	@property void vsync(bool enabled) {
		SDL_GL_SetSwapInterval(enabled);
		_vsync = enabled;
	}

	@property MouseState mouseState() {
		MouseState ms;
		ms.isFocused = !!(SDL_GetWindowFlags(_window) & SDL_WINDOW_MOUSE_FOCUS);
		const uint mouseMask = SDL_GetMouseState(&ms.position[0], &ms.position[1]);
		ms.buttons.left = !!(mouseMask & SDL_BUTTON(SDL_BUTTON_LEFT));
		ms.buttons.middle = !!(mouseMask & SDL_BUTTON(SDL_BUTTON_MIDDLE));
		ms.buttons.right = !!(mouseMask & SDL_BUTTON(SDL_BUTTON_RIGHT));
		return ms;
	}

	@property void cursorVisibillity(bool visible) {
		SDL_ShowCursor(visible);
	}

	@property string clipboard() {
		import std.string : fromStringz;

		return cast(string)SDL_GetClipboardText().fromStringz;
	}

	@property void clipboard(string data) {
		import std.string : toStringz;

		SDL_SetClipboardText(data.toStringz);
	}

private:
	string _title;
	bool _quit;
	bool _vsync;
	ivec2 _size;

	IRenderer _renderer;
	RendererType _rendererType;

	SDL_Window* _window;
	SDL_GLContext _glContext;
}
