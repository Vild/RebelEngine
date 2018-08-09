module rebel.ui.imgui;

import rebel.ui;
import rebel.view;
import rebel.renderer;
import rebel.input.event;
import rebel.input.key;

import derelict.imgui.imgui;
import derelict.sdl2.sdl;

import dlsl.vector;

import opengl.gl4;

public import imgui_extensions;

shared static this() {
	DerelictImgui.load();
	/*
	DerelictImgui.bindFunc(cast(void**)&igCreateDockContext, "igCreateDockContext");
	DerelictImgui.bindFunc(cast(void**)&igDestroyDockContext, "igDestroyDockContext");
	DerelictImgui.bindFunc(cast(void**)&igSetCurrentDockContext, "igSetCurrentDockContext");
	DerelictImgui.bindFunc(cast(void**)&igGetCurrentDockContext, "igGetCurrentDockContext");
	DerelictImgui.bindFunc(cast(void**)&igBeginDockspace, "igBeginDockspace");
	DerelictImgui.bindFunc(cast(void**)&igEndDockspace, "igEndDockspace");
	DerelictImgui.bindFunc(cast(void**)&igShutdownDock, "igShutdownDock");
	DerelictImgui.bindFunc(cast(void**)&igSetNextDock, "igSetNextDock");
	DerelictImgui.bindFunc(cast(void**)&igBeginDock, "igBeginDock");
	DerelictImgui.bindFunc(cast(void**)&igEndDock, "igEndDock");
	DerelictImgui.bindFunc(cast(void**)&igSetDockActive, "igSetDockActive");
	DerelictImgui.bindFunc(cast(void**)&igDockDebugWindow, "igDockDebugWindow");*/
}

final class ImguiUI : IUIRenderer {
public:
	this(IView view) {
		_view = view;

		ImGuiIO* io = igGetIO();
		// Keyboard mapping. ImGui will use those indices to peek into the io.KeyDown[] array.
		io.KeyMap[ImGuiKey_Tab] = cast(uint)Key.tab;
		io.KeyMap[ImGuiKey_LeftArrow] = cast(uint)Key.left;
		io.KeyMap[ImGuiKey_RightArrow] = cast(uint)Key.right;
		io.KeyMap[ImGuiKey_UpArrow] = cast(uint)Key.up;
		io.KeyMap[ImGuiKey_DownArrow] = cast(uint)Key.down;
		io.KeyMap[ImGuiKey_PageUp] = cast(uint)Key.pageup;
		io.KeyMap[ImGuiKey_PageDown] = cast(uint)Key.pagedown;
		io.KeyMap[ImGuiKey_Home] = cast(uint)Key.home;
		io.KeyMap[ImGuiKey_End] = cast(uint)Key.end;
		io.KeyMap[ImGuiKey_Delete] = cast(uint)Key.delete_;
		io.KeyMap[ImGuiKey_Backspace] = cast(uint)Key.backspace;
		io.KeyMap[ImGuiKey_Enter] = cast(uint)Key.return_;
		io.KeyMap[ImGuiKey_Escape] = cast(uint)Key.escape;
		io.KeyMap[ImGuiKey_A] = cast(uint)Key.a;
		io.KeyMap[ImGuiKey_C] = cast(uint)Key.c;
		io.KeyMap[ImGuiKey_V] = cast(uint)Key.v;
		io.KeyMap[ImGuiKey_X] = cast(uint)Key.x;
		io.KeyMap[ImGuiKey_Y] = cast(uint)Key.y;
		io.KeyMap[ImGuiKey_Z] = cast(uint)Key.z;

		io.RenderDrawListsFn = &_renderDrawLists;
		io.SetClipboardTextFn = &_setClipboardText;
		io.GetClipboardTextFn = &_getClipboardText;
		io.ClipboardUserData = null;

		/+
		// TODO: Implement this?
		version (Win32) {
			SDL_SysWMinfo wmInfo;
			SDL_VERSION(&wmInfo.version_);
			SDL_GetWindowWMInfo(window, &wmInfo);
			io.ImeWindowHandle = wmInfo.info.win.window;
		}+/

		igStyleColorsDark(igGetStyle());

		igGetStyle().WindowPadding = ImVec2(8, 8);
	}

	~this() {
		resetRenderer();

		igShutdown();
	}

	void newFrame(float delta) {
		if (!g_FontTexture)
			_createDeviceObjects();

		ImGuiIO* io = igGetIO();

		// Setup display size (every frame to accommodate for window resizing)
		ivec2 size = _view.size;
		ivec2 displaySize = _view.drawableSize;

		io.DisplaySize = ImVec2(displaySize.x, displaySize.y);
		io.DisplayFramebufferScale = ImVec2(size.x > 0 ? (cast(float)displaySize.x / size.x) : 0, size.y > 0
				? (cast(float)displaySize.y / size.y) : 0);

		// Setup time step
		io.DeltaTime = delta;

		MouseState mouseState = _view.mouseState;
		if (mouseState.isFocused)
			io.MousePos = ImVec2(mouseState.position.x, mouseState.position.y);
		else
			io.MousePos = ImVec2(-1, -1);

		// If a mouse press event came, always pass it as "mouse held this frame", so we don't miss click-release events that are shorter than 1 frame.
		io.MouseDown[0] = g_MousePressed[0] || mouseState.buttons.left;
		io.MouseDown[1] = g_MousePressed[1] || mouseState.buttons.right;
		io.MouseDown[2] = g_MousePressed[2] || mouseState.buttons.middle;
		g_MousePressed[0] = g_MousePressed[1] = g_MousePressed[2] = false;

		io.MouseWheel = g_MouseWheel;
		g_MouseWheel = 0.0f;

		// Hide OS mouse cursor if ImGui is drawing it
		_view.cursorVisibillity = !io.MouseDrawCursor;

		// Start the frame. This call will update the io.WantCaptureMouse, io.WantCaptureKeyboard flag that you can use to dispatch inputs (or not) to your application.
		igNewFrame();

		ImVec2 menuBarSize;
		if (igBeginMainMenuBar()) {
			if (igBeginMenu("File")) {
				igMenuItem("New");
				igMenuItem("Open");
				igMenuItem("Save");
				igMenuItem("Save As");
				igSeparator();
				igMenuItem("Quit");
				igEndMenu();
			}
			if (igBeginMenu("Editor")) {
				igEndMenu();
			}
			if (igBeginMenu("Help")) {
				igEndMenu();
			}

			igCheckbox("Show Demo Window", &_showDemoWindow);
			//_showDemoWindow = !_showDemoWindow;

			igGetWindowSize(&menuBarSize);
			igEndMainMenuBar();
		}

		igSetNextWindowPos(ImVec2(0, menuBarSize.y));
		auto fullscreenSize = igGetIO().DisplaySize;
		fullscreenSize.y -= menuBarSize.y;
		igSetNextWindowSize(fullscreenSize);
		const ImGuiWindowFlags flags = (ImGuiWindowFlags_NoMove | ImGuiWindowFlags_NoBringToFrontOnFocus
				| ImGuiWindowFlags_NoResize | ImGuiWindowFlags_NoScrollbar | ImGuiWindowFlags_NoSavedSettings | ImGuiWindowFlags_NoTitleBar);
		const bool visible = igBegin("Workspace", null, flags);

		static float leftPanelSizeWidth = 150;
		static float rightPanelSizeWidth = 150;
		static float consolePanelSizeHeight = 150;

		ImGuiStyle* style = igGetStyle();

		float viewportSizeWidth = fullscreenSize.x - leftPanelSizeWidth - rightPanelSizeWidth - style.WindowPadding.x * 4;
		if (viewportSizeWidth < 150)
			viewportSizeWidth = 150;

		float viewportSizeHeight = fullscreenSize.y - consolePanelSizeHeight - style.WindowPadding.y * 3.2;
		if (viewportSizeHeight < 150)
			viewportSizeHeight = 150;

		if (visible) {
			static size_t selected;
			static string[] actions = ["Select", "Move", "Rotate", "Scale", "New entity", "New Light", "New Block", "Cut block", "Change Material"];
			igDrawSplitter(false, style.WindowPadding.x, &leftPanelSizeWidth, &viewportSizeWidth, 150, 150);
			{ // Left
				igBeginChild("Left pane", ImVec2(leftPanelSizeWidth, 0), true);
				foreach (i, action; actions) {
					import std.format : format;
					import std.string : toStringz;

					ImVec4 color;
					igGetStyleColorVec4(&color, ImGuiCol_Button);
					if (selected == i) {
						color.x *= 2;
						color.y *= 2;
						color.z *= 2;
					}
					igPushStyleColor(ImGuiCol_Button, color);
					if (igButton(action.toStringz))
						selected = i;
					igPopStyleColor();
				}
				igEndChild();
			}
			igSameLine();
			{
				igBeginChild("Top-Bottom Split", ImVec2(0, 0), false);
				igDrawSplitter(true, style.WindowPadding.y, &viewportSizeHeight, &consolePanelSizeHeight, 150, 150);

				{
					igBeginChild("Center-Right Split", ImVec2(0, viewportSizeHeight), false);
					igDrawSplitter(false, style.WindowPadding.x, &viewportSizeWidth, &rightPanelSizeWidth, 150, 150);
					{ // Center
						igBeginChild("Center Pane", ImVec2(viewportSizeWidth, 0), true);
						igBeginGroup();
						igBeginChild("item view", ImVec2(0, -igGetFrameHeightWithSpacing())); // Leave room for 1 line below us
						igText("MyObject: %zu", selected);
						igSeparator();
						igTextWrapped(
								"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. ");
						igEndChild();
						if (igButton("Revert")) {
						}
						igSameLine();
						if (igButton("Save")) {
						}
						igEndGroup();
						igEndChild();
					}
					igSameLine();

					{ // right
						igBeginChild("Right Pane", ImVec2(rightPanelSizeWidth, 0), true);
						if (igCollapsingHeader("Position")) {
							static float[3] pos = [0, 0, 0];
							static float[3] scale = [1, 1, 1];
							igDragFloat3("Position", pos);
							igDragFloat3("Scale", scale);
						}
						if (igCollapsingHeader("Meh")) {
							igButton("Small meh");
							igButton("Big meh");
						}
						if (igCollapsingHeader("Material")) {
							if (igTreeNode("Rocks")) {
								for (int i = 0; i < 5; i++)
									if (igTreeNodePtr(cast(void*)i, "Rock type: %d", i)) {
										igText("This rock is fun :)");
										igTreePop();
									}
								igTreePop();
							}
							if (igTreeNode("Special")) {
								for (int i = 0; i < 5; i++)
									if (igTreeNodePtr(cast(void*)i, "Special type: %d", i)) {
										igText("MAGIC");
										igTreePop();
									}
								igTreePop();
							}
						}
						igEndChild();
					}
					igEndChild();
				}
				auto a = ImVec2(0, style.WindowPadding.y / 5.0f);
				igDummy(&a);
				{ // Console
					igBeginChild("Console pane", ImVec2(0, consolePanelSizeHeight), true);
					igText("DERP");
					igEndChild();
				}
				igEndChild();
			}

			/*igBeginDockspace();

			if (igBeginDock("World view", null, 0, ImVec2(0, 0), ImVec2(0, 0))) {
				igButton("THIS IS THE WORLD", ImVec2(1280, 720));

				igSetNextDock(ImGuiDockSlot.ImGuiDockSlot_Left);
				if (igBeginDock("Toolbar", null, 0, ImVec2(0, 0), ImVec2(0, 0))) {
					igButton("a");
					igButton("b");
					igButton("c");
					igButton("d");
				}
				igEndDock();

				igSetNextDock(ImGuiDockSlot.ImGuiDockSlot_Right);
				if (igBeginDock("Settings", null, 0, ImVec2(0, 0), ImVec2(0, 0))) {

				}
			}*/
		}
		igEnd();
		if (_showDemoWindow)
			igShowDemoWindow(&_showDemoWindow);
	}

	void endRender() {
		igRender();
	}

	// You can read the io.WantCaptureMouse, io.WantCaptureKeyboard flags to tell if dear imgui wants to use your inputs.
	// - When io.WantCaptureMouse is true, do not dispatch mouse input data to your main application.
	// - When io.WantCaptureKeyboard is true, do not dispatch keyboard input data to your main application.
	// Generally you may always pass all inputs to dear imgui, and hide them from your application based on those two flags.
	void processEvents(Event[] events) {
		//TODO: Add support to mark event as processed.

		import std.variant : tryVisit;
		import std.string : toStringz;

		ImGuiIO* io = igGetIO();

		foreach (Event event; events)
			event.tryVisit!((ref MouseWheelEvent wheel) {
				if (wheel.deltaY > 0)
					g_MouseWheel = 1;
				else if (wheel.deltaY < 0)
					g_MouseWheel = -1;
			}, (ref MouseButtonEvent button) {
				if (!button.isDown)
					return;
				if (button.button == MouseButton.left)
					g_MousePressed[0] = true;
				if (button.button == MouseButton.right)
					g_MousePressed[1] = true;
				if (button.button == MouseButton.middle)
					g_MousePressed[2] = true;
			}, (ref KeyEvent key) {
				io.KeysDown[key.key] = key.isDown;
				io.KeyShift = key.modifiers.shift;
				io.KeyCtrl = key.modifiers.ctrl;
				io.KeyAlt = key.modifiers.alt;
				io.KeySuper = key.modifiers.super_;
			}, (ref TextInputEvent text) { ImGuiIO_AddInputCharactersUTF8(text.text[].dup.ptr); });
	}

	void resetRenderer() {
		if (g_VaoHandle)
			glDeleteVertexArrays(1, &g_VaoHandle);
		if (g_VboHandle)
			glDeleteBuffers(1, &g_VboHandle);
		if (g_ElementsHandle)
			glDeleteBuffers(1, &g_ElementsHandle);
		g_VaoHandle = g_VboHandle = g_ElementsHandle = 0;

		if (g_ShaderHandle && g_VertHandle)
			glDetachShader(g_ShaderHandle, g_VertHandle);
		if (g_VertHandle)
			glDeleteShader(g_VertHandle);
		g_VertHandle = 0;

		if (g_ShaderHandle && g_FragHandle)
			glDetachShader(g_ShaderHandle, g_FragHandle);
		if (g_FragHandle)
			glDeleteShader(g_FragHandle);
		g_FragHandle = 0;

		if (g_ShaderHandle)
			glDeleteProgram(g_ShaderHandle);
		g_ShaderHandle = 0;

		if (g_FontTexture) {
			glDeleteTextures(1, &g_FontTexture);
			ImFontAtlas_SetTexID(igGetIO().Fonts, cast(void*)0);
			g_FontTexture = 0;
		}
	}

private:
	static IView _view;

	static bool _showDemoWindow = true;

	// Data
	static double g_Time = 0.0f;
	static bool[3] g_MousePressed = [false, false, false];
	static float g_MouseWheel = 0.0f;
	static uint g_FontTexture;
	static uint g_ShaderHandle, g_VertHandle, g_FragHandle;
	static int g_AttribLocationTex, g_AttribLocationProjMtx;
	static int g_AttribLocationPosition, g_AttribLocationUV, g_AttribLocationColor;
	static uint g_VboHandle, g_VaoHandle, g_ElementsHandle;

	bool _createDeviceObjects() {
		import std.file : readText;

		// Backup GL state
		GLint last_texture, last_array_buffer, last_vertex_array;
		glGetIntegerv(GL_TEXTURE_BINDING_2D, &last_texture);
		glGetIntegerv(GL_ARRAY_BUFFER_BINDING, &last_array_buffer);
		glGetIntegerv(GL_VERTEX_ARRAY_BINDING, &last_vertex_array);

		import rebel.engine;
		import rebel.input.filesystem;

		FileSystem fs = Engine.instance.fileSystem;

		GLchar[] vertex_shader;
		scope (exit)
			vertex_shader.destroy;
		GLchar[] fragment_shader;
		scope (exit)
			fragment_shader.destroy;

		{
			FSFile file = fs.open("imgui/base.vert", FileMode.read);
			scope (exit)
				file.destroy;
			vertex_shader.length = file.length;
			file.read(cast(ubyte[])vertex_shader);
		}
		{
			FSFile file = fs.open("imgui/base.frag", FileMode.read);
			scope (exit)
				file.destroy;
			fragment_shader.length = file.length;
			file.read(cast(ubyte[])fragment_shader);
		}

		const GLchar* vertex_shader_ptr = &vertex_shader[0];
		const GLchar* fragment_shader_ptr = &fragment_shader[0];

		g_ShaderHandle = glCreateProgram();
		g_VertHandle = glCreateShader(GL_VERTEX_SHADER);
		g_FragHandle = glCreateShader(GL_FRAGMENT_SHADER);
		glShaderSource(g_VertHandle, 1, &vertex_shader_ptr, null);
		glShaderSource(g_FragHandle, 1, &fragment_shader_ptr, null);

		glCompileShader(g_VertHandle);

		GLint status;
		glGetShaderiv(g_VertHandle, GL_COMPILE_STATUS, &status);
		if (status == GL_FALSE) {
			import std.stdio : writefln;
			import std.string : fromStringz;

			GLuint len;
			glGetShaderiv(g_VertHandle, GL_INFO_LOG_LENGTH, cast(GLint*)&len);

			GLchar[] errorLog;
			scope (exit)
				errorLog.destroy;
			errorLog.length = len;
			glGetShaderInfoLog(g_VertHandle, len, &len, &errorLog[0]);

			writefln("[error] Shader compilation failed %s (%u):\n%s", "<Vertex>", g_VertHandle, errorLog.ptr.fromStringz);
		}

		glCompileShader(g_FragHandle);
		glGetShaderiv(g_FragHandle, GL_COMPILE_STATUS, &status);
		if (status == GL_FALSE) {
			import std.stdio : writefln;
			import std.string : fromStringz;

			GLuint len;
			glGetShaderiv(g_FragHandle, GL_INFO_LOG_LENGTH, cast(GLint*)&len);

			GLchar[] errorLog;
			scope (exit)
				errorLog.destroy;
			errorLog.length = len;
			glGetShaderInfoLog(g_FragHandle, len, &len, &errorLog[0]);

			writefln("[error] Shader compilation failed %s (%u):\n%s", "<Fragment>", g_FragHandle, errorLog.ptr.fromStringz);
		}

		glAttachShader(g_ShaderHandle, g_VertHandle);
		glAttachShader(g_ShaderHandle, g_FragHandle);
		glLinkProgram(g_ShaderHandle);

		glGetProgramiv(g_ShaderHandle, GL_LINK_STATUS, &status);
		if (status == GL_FALSE) {
			import std.stdio : writefln;
			import std.string : fromStringz;

			GLuint len;
			glGetProgramiv(g_ShaderHandle, GL_INFO_LOG_LENGTH, cast(GLint*)&len);

			GLchar[] errorLog;
			scope (exit)
				errorLog.destroy;
			errorLog.length = len;
			glGetProgramInfoLog(g_ShaderHandle, len, &len, &errorLog[0]);

			writefln("[error] Linking the program failed %u:\n%s", g_ShaderHandle, errorLog.ptr.fromStringz);
		}

		g_AttribLocationTex = glGetUniformLocation(g_ShaderHandle, "fontTexture");
		g_AttribLocationProjMtx = glGetUniformLocation(g_ShaderHandle, "vp");
		g_AttribLocationPosition = glGetAttribLocation(g_ShaderHandle, "position");
		g_AttribLocationUV = glGetAttribLocation(g_ShaderHandle, "uv");
		g_AttribLocationColor = glGetAttribLocation(g_ShaderHandle, "color");

		glGenBuffers(1, &g_VboHandle);
		glGenBuffers(1, &g_ElementsHandle);

		glGenVertexArrays(1, &g_VaoHandle);
		glBindVertexArray(g_VaoHandle);
		glBindBuffer(GL_ARRAY_BUFFER, g_VboHandle);
		glEnableVertexAttribArray(g_AttribLocationPosition);
		glEnableVertexAttribArray(g_AttribLocationUV);
		glEnableVertexAttribArray(g_AttribLocationColor);

		glVertexAttribPointer(g_AttribLocationPosition, 2, GL_FLOAT, GL_FALSE, ImDrawVert.sizeof, cast(GLvoid*)ImDrawVert.pos.offsetof);
		glVertexAttribPointer(g_AttribLocationUV, 2, GL_FLOAT, GL_FALSE, ImDrawVert.sizeof, cast(GLvoid*)ImDrawVert.uv.offsetof);
		glVertexAttribPointer(g_AttribLocationColor, 4, GL_UNSIGNED_BYTE, GL_TRUE, ImDrawVert.sizeof, cast(GLvoid*)ImDrawVert.col.offsetof);

		_createFontsTexture();

		// Restore modified GL state
		glBindTexture(GL_TEXTURE_2D, last_texture);
		glBindBuffer(GL_ARRAY_BUFFER, last_array_buffer);
		glBindVertexArray(last_vertex_array);

		return true;
	}

	// This is the main rendering function that you have to implement and provide to ImGui (via setting up 'RenderDrawListsFn' in the ImGuiIO structure)
	// Note that this implementation is little overcomplicated because we are saving/setting up/restoring every OpenGL state explicitly, in order to be able to run within any OpenGL engine that doesn't do so.
	// If text or lines are blurry when integrating ImGui in your engine: in your Render function, try translating your projection matrix by (0.5f,0.5f) or (0.375f,0.375f)
	extern (C) static void _renderDrawLists(ImDrawData* draw_data) nothrow {
		// Avoid rendering when minimized, scale coordinates for retina displays (screen coordinates != framebuffer coordinates)
		ImGuiIO* io = igGetIO();
		int fb_width = cast(uint)(io.DisplaySize.x * io.DisplayFramebufferScale.x);
		int fb_height = cast(uint)(io.DisplaySize.y * io.DisplayFramebufferScale.y);
		if (fb_width == 0 || fb_height == 0)
			return;
		draw_data.ScaleClipRects(io.DisplayFramebufferScale);

		// Backup GL state
		GLenum last_active_texture;
		glGetIntegerv(GL_ACTIVE_TEXTURE, cast(GLint*)&last_active_texture);
		glActiveTexture(GL_TEXTURE0);
		GLint last_program;
		glGetIntegerv(GL_CURRENT_PROGRAM, &last_program);
		GLint last_texture;
		glGetIntegerv(GL_TEXTURE_BINDING_2D, &last_texture);
		GLint last_sampler;
		glGetIntegerv(GL_SAMPLER_BINDING, &last_sampler);
		GLint last_array_buffer;
		glGetIntegerv(GL_ARRAY_BUFFER_BINDING, &last_array_buffer);
		GLint last_element_array_buffer;
		glGetIntegerv(GL_ELEMENT_ARRAY_BUFFER_BINDING, &last_element_array_buffer);
		GLint last_vertex_array;
		glGetIntegerv(GL_VERTEX_ARRAY_BINDING, &last_vertex_array);
		GLint[2] last_polygon_mode;
		glGetIntegerv(GL_POLYGON_MODE, &last_polygon_mode[0]);
		GLint[4] last_viewport;
		glGetIntegerv(GL_VIEWPORT, &last_viewport[0]);
		GLint[4] last_scissor_box;
		glGetIntegerv(GL_SCISSOR_BOX, &last_scissor_box[0]);
		GLenum last_blend_src_rgb;
		glGetIntegerv(GL_BLEND_SRC_RGB, cast(GLint*)&last_blend_src_rgb);
		GLenum last_blend_dst_rgb;
		glGetIntegerv(GL_BLEND_DST_RGB, cast(GLint*)&last_blend_dst_rgb);
		GLenum last_blend_src_alpha;
		glGetIntegerv(GL_BLEND_SRC_ALPHA, cast(GLint*)&last_blend_src_alpha);
		GLenum last_blend_dst_alpha;
		glGetIntegerv(GL_BLEND_DST_ALPHA, cast(GLint*)&last_blend_dst_alpha);
		GLenum last_blend_equation_rgb;
		glGetIntegerv(GL_BLEND_EQUATION_RGB, cast(GLint*)&last_blend_equation_rgb);
		GLenum last_blend_equation_alpha;
		glGetIntegerv(GL_BLEND_EQUATION_ALPHA, cast(GLint*)&last_blend_equation_alpha);
		GLboolean last_enable_blend = glIsEnabled(GL_BLEND);
		GLboolean last_enable_cull_face = glIsEnabled(GL_CULL_FACE);
		GLboolean last_enable_depth_test = glIsEnabled(GL_DEPTH_TEST);
		GLboolean last_enable_scissor_test = glIsEnabled(GL_SCISSOR_TEST);

		// Setup render state: alpha-blending enabled, no face culling, no depth testing, scissor enabled, polygon fill
		glEnable(GL_BLEND);
		glBlendEquation(GL_FUNC_ADD);
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
		glDisable(GL_CULL_FACE);
		glDisable(GL_DEPTH_TEST);
		glEnable(GL_SCISSOR_TEST);
		glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);

		// Setup viewport, orthographic projection matrix
		glViewport(0, 0, cast(GLsizei)fb_width, cast(GLsizei)fb_height);
		const float[4][4] ortho_projection = [[2.0f / io.DisplaySize.x, 0.0f, 0.0f, 0.0f], [
			0.0f, 2.0f / -io.DisplaySize.y, 0.0f, 0.0f
		], [0.0f, 0.0f, -1.0f, 0.0f], [-1.0f, 1.0f, 0.0f, 1.0f]];
		glUseProgram(g_ShaderHandle);
		glUniform1i(g_AttribLocationTex, 0);
		glUniformMatrix4fv(g_AttribLocationProjMtx, 1, GL_FALSE, &ortho_projection[0][0]);
		glBindVertexArray(g_VaoHandle);
		glBindSampler(0, 0); // Rely on combined texture/sampler state.

		for (int n = 0; n < draw_data.CmdListsCount; n++) {
			ImDrawList* cmd_list = draw_data.CmdLists[n];
			ImDrawIdx* idx_buffer_offset = null;

			glBindBuffer(GL_ARRAY_BUFFER, g_VboHandle);
			glBufferData(GL_ARRAY_BUFFER, cast(GLsizeiptr)ImDrawList_GetVertexBufferSize(cmd_list) * ImDrawVert.sizeof,
					cast(const GLvoid*)ImDrawList_GetVertexPtr(cmd_list, 0), GL_STREAM_DRAW);

			glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, g_ElementsHandle);
			glBufferData(GL_ELEMENT_ARRAY_BUFFER, cast(GLsizeiptr)ImDrawList_GetIndexBufferSize(cmd_list) * ImDrawIdx.sizeof,
					cast(const GLvoid*)ImDrawList_GetIndexPtr(cmd_list, 0), GL_STREAM_DRAW);

			foreach (ref ImDrawCmd pcmd; ImDrawList_GetCmdPtr(cmd_list, 0)[0 .. ImDrawList_GetCmdSize(cmd_list)]) {
				if (pcmd.UserCallback)
					pcmd.UserCallback(cmd_list, &pcmd);
				else {
					glBindTexture(GL_TEXTURE_2D, cast(GLuint)pcmd.TextureId);
					glScissor(cast(uint)pcmd.ClipRect.x, cast(uint)(fb_height - pcmd.ClipRect.w),
							cast(uint)(pcmd.ClipRect.z - pcmd.ClipRect.x), cast(uint)(pcmd.ClipRect.w - pcmd.ClipRect.y));
					glDrawElements(GL_TRIANGLES, cast(GLsizei)pcmd.ElemCount, ImDrawIdx.sizeof == 2 ? GL_UNSIGNED_SHORT
							: GL_UNSIGNED_INT, idx_buffer_offset);
				}
				idx_buffer_offset += pcmd.ElemCount;
			}
		}

		// Restore modified GL state
		glUseProgram(last_program);
		glBindTexture(GL_TEXTURE_2D, last_texture);
		glBindSampler(0, last_sampler);
		glActiveTexture(last_active_texture);
		glBindVertexArray(last_vertex_array);
		glBindBuffer(GL_ARRAY_BUFFER, last_array_buffer);
		glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, last_element_array_buffer);
		glBlendEquationSeparate(last_blend_equation_rgb, last_blend_equation_alpha);
		glBlendFuncSeparate(last_blend_src_rgb, last_blend_dst_rgb, last_blend_src_alpha, last_blend_dst_alpha);
		if (last_enable_blend)
			glEnable(GL_BLEND);
		else
			glDisable(GL_BLEND);
		if (last_enable_cull_face)
			glEnable(GL_CULL_FACE);
		else
			glDisable(GL_CULL_FACE);
		if (last_enable_depth_test)
			glEnable(GL_DEPTH_TEST);
		else
			glDisable(GL_DEPTH_TEST);
		if (last_enable_scissor_test)
			glEnable(GL_SCISSOR_TEST);
		else
			glDisable(GL_SCISSOR_TEST);
		glPolygonMode(GL_FRONT_AND_BACK, last_polygon_mode[0]);
		glViewport(last_viewport[0], last_viewport[1], cast(GLsizei)last_viewport[2], cast(GLsizei)last_viewport[3]);
		glScissor(last_scissor_box[0], last_scissor_box[1], cast(GLsizei)last_scissor_box[2], cast(GLsizei)last_scissor_box[3]);
	}

	extern (C) static const(char)* _getClipboardText(void*) nothrow {
		import std.string : toStringz;

		scope (failure)
			return "";

		return _view.clipboard.toStringz;
	}

	extern (C) static void _setClipboardText(void*, const(char)* text) nothrow {
		import std.string : fromStringz;

		scope (failure)
			return;

		_view.clipboard = cast(string)text.fromStringz;
	}

	static void _createFontsTexture() {
		// Build texture atlas
		ImGuiIO* io = igGetIO();
		ubyte* pixels;
		int width, height;
		ImFontAtlas_GetTexDataAsRGBA32(io.Fonts, &pixels, &width, &height); // Load as RGBA 32-bits for OpenGL3 demo because it is more likely to be compatible with user's existing shader.

		// Upload texture to graphics system
		GLint last_texture;
		glGetIntegerv(GL_TEXTURE_BINDING_2D, &last_texture);
		glGenTextures(1, &g_FontTexture);
		glBindTexture(GL_TEXTURE_2D, g_FontTexture);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
		glPixelStorei(GL_UNPACK_ROW_LENGTH, 0);
		glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, pixels);

		// Store our identifier
		ImFontAtlas_SetTexID(io.Fonts, cast(void*)g_FontTexture);

		// Restore state
		glBindTexture(GL_TEXTURE_2D, last_texture);
	}

}
