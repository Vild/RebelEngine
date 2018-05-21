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

shared static this() {
	DerelictImgui.load();
}

final class ImguiUI : IUIRenderer {
public:
	this(IView view) {
		_view = view;

		ImGuiIO* io = igGetIO();
		io.KeyMap[ImGuiKey_Tab] = cast(uint)Key.tab; // Keyboard mapping. ImGui will use those indices to peek into the io.KeyDown[] array.
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

		version (Win32) {
			SDL_SysWMinfo wmInfo;
			SDL_VERSION(&wmInfo.version_);
			SDL_GetWindowWMInfo(window, &wmInfo);
			io.ImeWindowHandle = wmInfo.info.win.window;
		}

		igStyleColorsDark(igGetStyle());
	}

	~this() {
		invalidateDeviceObjects();
		igShutdown();
	}

	void newFrame() {
		if (!g_FontTexture)
			createDeviceObjects();

		ImGuiIO* io = igGetIO();

		// Setup display size (every frame to accommodate for window resizing)
		ivec2 size = _view.size;
		ivec2 displaySize = _view.drawableSize;

		io.DisplaySize = ImVec2(displaySize.x, displaySize.y);
		io.DisplayFramebufferScale = ImVec2(size.x > 0 ? (cast(float)displaySize.x / size.x) : 0, size.y > 0
				? (cast(float)displaySize.y / size.y) : 0);

		// Setup time step
		Uint32 time = SDL_GetTicks();
		double current_time = time / 1000.0;
		io.DeltaTime = g_Time > 0.0 ? cast(float)(current_time - g_Time) : cast(float)(1.0f / 60.0f);
		g_Time = current_time;

		// Setup inputs
		// (we already got mouse wheel, keyboard keys & characters from SDL_PollEvent())

		MouseState mouseState = _view.mouseState;
		if (mouseState.isFocused)
			io.MousePos = ImVec2(mouseState.position.x, mouseState.position.y); // Mouse position, in pixels (set to -1,-1 if no mouse / on another screen, etc.)
		else
			io.MousePos = ImVec2(-float.max, -float.max);

		io.MouseDown[0] = g_MousePressed[0] || mouseState.buttons.left; // If a mouse press event came, always pass it as "mouse held this frame", so we don't miss click-release events that are shorter than 1 frame.
		io.MouseDown[1] = g_MousePressed[1] || mouseState.buttons.right;
		io.MouseDown[2] = g_MousePressed[2] || mouseState.buttons.middle;
		g_MousePressed[0] = g_MousePressed[1] = g_MousePressed[2] = false;

		io.MouseWheel = g_MouseWheel;
		g_MouseWheel = 0.0f;

		// Hide OS mouse cursor if ImGui is drawing it
		// TODO: SDL_ShowCursor(io.MouseDrawCursor ? 0 : 1);

		// Start the frame. This call will update the io.WantCaptureMouse, io.WantCaptureKeyboard flag that you can use to dispatch inputs (or not) to your application.
		igNewFrame();

		if (igButton("RUN imgui_demo (C++ version)"))
			_showDemoWindow = !_showDemoWindow;

		if (_showDemoWindow) {
			igSetNextWindowPos(ImVec2(650, 20), ImGuiCond_FirstUseEver);
			igShowDemoWindow(&_showDemoWindow);
		}
	}

	void endRender() {
		igRender();
	}

	// You can read the io.WantCaptureMouse, io.WantCaptureKeyboard flags to tell if dear imgui wants to use your inputs.
	// - When io.WantCaptureMouse is true, do not dispatch mouse input data to your main application.
	// - When io.WantCaptureKeyboard is true, do not dispatch keyboard input data to your main application.
	// Generally you may always pass all inputs to dear imgui, and hide them from your application based on those two flags.
	static void processEvents(Event[] events) {
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

	void invalidateDeviceObjects() {
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

	bool createDeviceObjects() {
		// Backup GL state
		GLint last_texture, last_array_buffer, last_vertex_array;
		glGetIntegerv(GL_TEXTURE_BINDING_2D, &last_texture);
		glGetIntegerv(GL_ARRAY_BUFFER_BINDING, &last_array_buffer);
		glGetIntegerv(GL_VERTEX_ARRAY_BINDING, &last_vertex_array);

		const GLchar* vertex_shader = q{
			#version 330
			uniform mat4 ProjMtx;
			in vec2 Position;
			in vec2 UV;
			in vec4 Color;
			out vec2 Frag_UV;
			out vec4 Frag_Color;
			void main() {
				Frag_UV = UV;
				Frag_Color = Color;
				gl_Position = ProjMtx * vec4(Position.xy,0,1);
			}
		};

		const GLchar* fragment_shader = q{
			#version 330
			uniform sampler2D Texture;
			in vec2 Frag_UV;
			in vec4 Frag_Color;
			out vec4 Out_Color;
			void main() {
				Out_Color = Frag_Color * texture( Texture, Frag_UV.st);
			}
		};

		g_ShaderHandle = glCreateProgram();
		g_VertHandle = glCreateShader(GL_VERTEX_SHADER);
		g_FragHandle = glCreateShader(GL_FRAGMENT_SHADER);
		glShaderSource(g_VertHandle, 1, &vertex_shader, null);
		glShaderSource(g_FragHandle, 1, &fragment_shader, null);
		glCompileShader(g_VertHandle);
		glCompileShader(g_FragHandle);
		glAttachShader(g_ShaderHandle, g_VertHandle);
		glAttachShader(g_ShaderHandle, g_FragHandle);
		glLinkProgram(g_ShaderHandle);

		g_AttribLocationTex = glGetUniformLocation(g_ShaderHandle, "Texture");
		g_AttribLocationProjMtx = glGetUniformLocation(g_ShaderHandle, "ProjMtx");
		g_AttribLocationPosition = glGetAttribLocation(g_ShaderHandle, "Position");
		g_AttribLocationUV = glGetAttribLocation(g_ShaderHandle, "UV");
		g_AttribLocationColor = glGetAttribLocation(g_ShaderHandle, "Color");

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

private:
	IView _view;
	bool _showDemoWindow = true;

	// Data
	static double g_Time = 0.0f;
	static bool[3] g_MousePressed = [false, false, false];
	static float g_MouseWheel = 0.0f;
	static uint g_FontTexture = 0;
	static uint g_ShaderHandle = 0, g_VertHandle = 0, g_FragHandle = 0;
	static int g_AttribLocationTex = 0, g_AttribLocationProjMtx = 0;
	static int g_AttribLocationPosition = 0, g_AttribLocationUV = 0, g_AttribLocationColor = 0;
	static uint g_VboHandle = 0, g_VaoHandle = 0, g_ElementsHandle = 0;

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
		return SDL_GetClipboardText();
	}

	extern (C) static void _setClipboardText(void*, const(char)* text) nothrow {
		SDL_SetClipboardText(text);
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
