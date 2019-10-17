module rebel.ui.imgui;

//TODO: add log system
import std.stdio;

import rebel.engine;
import rebel.ui;
import rebel.view;
import rebel.renderer;
import rebel.input.event;
import rebel.input.key;

//import derelict.imgui.imgui;
import cimgui;
import derelict.sdl2.sdl;

import gfm.math.vector;

//public import imgui_extensions;

shared static this() {
	//DerelictImgui.load();
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
		_context = igCreateContext(null);
		_renderer = Engine.instance.renderer;

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

		resetRenderer(true);
	}

	~this() {
		resetRenderer(false);

		igDestroyContext(_context);
	}

	void newFrame(float delta) {
		ImGuiIO* io = igGetIO();

		// Setup display size (every frame to accommodate for window resizing)
		vec2i size = _view.size;
		vec2i displaySize = _view.drawableSize;

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
		io.MouseDown[0] = _mousePressed[0] || mouseState.buttons.left;
		io.MouseDown[1] = _mousePressed[1] || mouseState.buttons.right;
		io.MouseDown[2] = _mousePressed[2] || mouseState.buttons.middle;
		_mousePressed[0] = _mousePressed[1] = _mousePressed[2] = false;

		io.MouseWheel = _mouseWheel;
		_mouseWheel = 0.0f;

		// Hide OS mouse cursor if ImGui is drawing it
		_view.cursorVisibillity = !io.MouseDrawCursor;

		// Start the frame. This call will update the io.WantCaptureMouse, io.WantCaptureKeyboard flag that you can use to dispatch inputs (or not) to your application.
		igNewFrame();

		ImVec2 menuBarSize;
		if (igBeginMainMenuBar()) {
			if (igBeginMenu("File", true)) {
				igMenuItemBool("New", null, false, true);
				igMenuItemBool("Open", null, false, true);
				igMenuItemBool("Save", null, false, true);
				igMenuItemBool("Save As", null, false, true);
				igSeparator();
				igMenuItemBool("Quit", null, false, true);
				igEndMenu();
			}
			if (igBeginMenu("Editor", true)) {
				igEndMenu();
			}
			if (igBeginMenu("Help", true)) {
				igEndMenu();
			}

			igCheckbox("Show Demo Window", &_showDemoWindow);
			//_showDemoWindow = !_showDemoWindow;

			menuBarSize = igGetWindowSize();
			igEndMainMenuBar();
		}

		igSetNextWindowPos(ImVec2(0, menuBarSize.y), 0, ImVec2(0, 0));
		auto fullscreenSize = igGetIO().DisplaySize;
		fullscreenSize.y -= menuBarSize.y;
		igSetNextWindowSize(fullscreenSize, 0);
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
			static string[] actions = [
				"Select", "Move", "Rotate", "Scale", "New entity", "New Light", "New Block", "Cut block", "Change Material"
			];
			/*igDrawSplitter(false, style.WindowPadding.x, &leftPanelSizeWidth, &viewportSizeWidth, 150, 150);
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
					if (_worldView) { // Center
						ImVec2 drawAreaSize = ImVec2(viewportSizeWidth, viewportSizeHeight);
						_worldView.drawAreaSize = vec2i(cast(int)drawAreaSize.x, cast(int)drawAreaSize.y);
						igImage(*cast(ImTextureID*)_worldView.getRendereredFrame().getHandle(), drawAreaSize);
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
			}*/
		}
		igEnd();
		if (_showDemoWindow)
			igShowDemoWindow(&_showDemoWindow);
	}

	void render(ICommandBufferRecordingState rs) {
		igRender();

		ImDrawData* data = igGetDrawData();

		ImDrawVert[] vertexData;
		ImDrawIdx[] indexData;
		vertexData.length = data.TotalVtxCount;
		indexData.length = data.TotalIdxCount;

		size_t vertexCounter;
		size_t indexCounter;
		foreach (ImDrawList* list; data.CmdLists[0 .. data.CmdListsCount]) {
			vertexData[vertexCounter .. vertexCounter + list.VtxBuffer.Size] = list.VtxBuffer.Data[0 .. list.VtxBuffer.Size];
			indexData[indexCounter .. indexCounter + list.IdxBuffer.Size] = list.IdxBuffer.Data[0 .. list.IdxBuffer.Size];
			vertexCounter += list.VtxBuffer.Size;
			indexCounter += list.IdxBuffer.Size;
		}

		{
			scope Buffer.Ref bufferRef = _renderer.get(_verticesBuffer);
			BufferData* buffer = bufferRef.get();
			buffer.setData(vertexData);
		}

		{
			scope Buffer.Ref bufferRef = _renderer.get(_indicesBuffer);
			BufferData* buffer = bufferRef.get();
			buffer.setData(indexData);
		}

		rs.renderPass = _renderPass;
		rs.pipeline = _pipeline;
		rs.clearColors = [ClearValue(ClearColorValue(0.45f, 0.55f, 0.60f, 1.00f)), ClearValue(ClearDepthValue(1, 0))];

		rs.finalizeState();

		rs.bindVertexBuffer(Bindings.vertex, [BufferOffset(_verticesBuffer, 0)]);
		static assert(ImDrawIdx.sizeof == 2, "Change the IndexType");
		rs.bindIndexBuffer(BufferOffset(_indicesBuffer, 0), IndexType.u16);

		{
			vec2f scale;
			scale.x = 2.0f / data.DisplaySize.x;
			scale.y = 2.0f / data.DisplaySize.y;
			vec2f translate;
			translate.x = -1.0f - data.DisplayPos.x * scale[0];
			translate.y = -1.0f - data.DisplayPos.y * scale[1];
			rs.pushConstants(ShaderStages.vertex, 0 * cast(uint)vec2f.sizeof, [scale]);
			rs.pushConstants(ShaderStages.vertex, 1 * cast(uint)vec2f.sizeof, [translate]);
		}

		int vtx_offset = 0;
		int idx_offset = 0;
		ImVec2 display_pos = data.DisplayPos;
		foreach (ImDrawList* cmd_list; data.CmdLists[0 .. data.CmdListsCount]) {
			foreach (const ref ImDrawCmd pcmd; cmd_list.CmdBuffer.Data[0 .. cmd_list.CmdBuffer.Size]) {
				if (pcmd.UserCallback)
					pcmd.UserCallback(cmd_list, &pcmd);
				else {
					import std.algorithm : max, min;

					// Apply scissor/clipping rectangle
					// FIXME: We could clamp width/height based on clamped min/max values.
					vec4ui scissor;
					scissor.x = max(0, cast(uint)(pcmd.ClipRect.x - display_pos.x));
					scissor.y = max(0, cast(uint)(pcmd.ClipRect.y - display_pos.y));
					scissor.z = cast(uint)(pcmd.ClipRect.z - pcmd.ClipRect.x);
					scissor.w = cast(uint)(pcmd.ClipRect.w - pcmd.ClipRect.y + 1); // FIXME: Why +1 here?
					rs.setScissor(0, [scissor]);

					// Draw
					rs.drawIndexed(pcmd.ElemCount, 1, idx_offset, vtx_offset, 0);
				}
				idx_offset += pcmd.ElemCount;
			}
			vtx_offset += cmd_list.VtxBuffer.Size;
		}
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
					_mouseWheel = 1;
				else if (wheel.deltaY < 0)
					_mouseWheel = -1;
			}, (ref MouseButtonEvent button) {
				if (!button.isDown)
					return;
				if (button.button == MouseButton.left)
					_mousePressed[0] = true;
				if (button.button == MouseButton.right)
					_mousePressed[1] = true;
				if (button.button == MouseButton.middle)
					_mousePressed[2] = true;
			}, (ref KeyEvent key) {
				io.KeysDown[key.key] = key.isDown;
				io.KeyShift = key.modifiers.shift;
				io.KeyCtrl = key.modifiers.ctrl;
				io.KeyAlt = key.modifiers.alt;
				io.KeySuper = key.modifiers.super_;
			}, (ref TextInputEvent text) { ImGuiIO_AddInputCharactersUTF8(igGetIO(), text.text[].dup.ptr); });
	}

	override void resetRenderer() {
		resetRenderer(true);
	}

	void resetRenderer(bool init) {
		if (_vertexShaderModule.isValid) {
			_renderer.destruct(_vertexShaderModule);
			_renderer.destruct(_fragmentShaderModule);
			_renderer.destruct(_pipeline);

			_renderer.destruct(_fontImage);
			_renderer.destruct(_fontImageSampler);
		}
		ImFontAtlas_SetTexID(igGetIO().Fonts, null);
		if (init) {
			_createRenderpass();
			_createShaderModules();
			_createBuffers();
			_createTextures();
			_createPipeline();
			_createCommandBuffers();
		}
	}

	@property IUIView worldView() {
		return _worldView;
	}

	@property void worldView(IUIView view) {
		_worldView = view;
	}

private:

	// These types need to match imgui's types:
	alias ImguiPosition = VertexShaderData!(vec2f, ImageFormat.rg32_float);
	alias ImguiUV = VertexShaderData!(vec2f, ImageFormat.rg32_float);
	alias ImguiColor = VertexShaderData!(vec4ub, ImageFormat.rgba8_unorm);

	@VertexDataRate(VertexDataRate.vertex) struct ImguiImDrawVert {
		ImguiPosition position;
		ImguiUV uv;
		ImguiColor color;
	}

	enum Bindings : uint {
		vertex = 0,
		fontTexture = 0
	}

	IRenderer _renderer;
	ImGuiContext* _context;
	IView _view;
	IUIView _worldView;
	bool _showDemoWindow = true; // Data
	bool[3] _mousePressed = [false, false, false];
	float _mouseWheel = 0.0f;

	RenderPass _renderPass;
	ShaderModule _vertexShaderModule, _fragmentShaderModule;
	Buffer _verticesBuffer, _indicesBuffer;
	Pipeline _pipeline;

	Image _fontImage;
	Sampler _fontImageSampler;

	CommandBuffer[] _commandBuffers;

	void _createRenderpass() {
		Attachment* colorAttachment = new Attachment;
		{
			colorAttachment.imageTemplate = _renderer.framebufferColorImageTemplate;
			colorAttachment.loadOp = LoadOperation.dontCare;
			colorAttachment.storeOp = StoreOperation.store;
			colorAttachment.stencilLoadOp = LoadOperation.dontCare;
			colorAttachment.stencilStoreOp = StoreOperation.dontCare;
			colorAttachment.initialLayout = ImageLayout.undefined;
			colorAttachment.finalLayout = ImageLayout.present;
		}
		Attachment* depthAttachment = new Attachment;
		{
			depthAttachment.imageTemplate = _renderer.framebufferDepthImageTemplate;
			depthAttachment.loadOp = LoadOperation.dontCare;
			depthAttachment.storeOp = StoreOperation.dontCare;
			depthAttachment.stencilLoadOp = LoadOperation.dontCare;
			depthAttachment.stencilStoreOp = StoreOperation.dontCare;
			depthAttachment.initialLayout = ImageLayout.undefined;
			depthAttachment.finalLayout = ImageLayout.depthStencil;
		}
		Subpass* subpass = new Subpass;
		{
			subpass.bindPoint = SubpassBindPoint.graphics;
			subpass.colorOutput = [SubpassAttachment(colorAttachment, ImageLayout.color)];
			subpass.depthStencilOutput = [SubpassAttachment(depthAttachment, ImageLayout.depthStencil)];
		}

		SubpassDependency dependency;
		{
			dependency.srcSubpass = externalSubpass;
			dependency.dstSubpass = subpass;
			dependency.srcStageMask = StageFlags.colorOutput;
			dependency.dstStageMask = StageFlags.colorOutput;
			dependency.srcAccessMask = AccessMask.none;
			dependency.dstAccessMask = AccessMask.write;
		}

		RenderPassBuilder builder;
		builder.name = "Imgui RenderPass";
		builder.attachments = [colorAttachment, depthAttachment];
		builder.subpasses = [subpass];
		builder.dependencies = [dependency];

		_renderPass = _renderer.construct(builder);
		//_renderer.outputRenderPass = _renderPass;
	}

	void _createShaderModules() {
		import std.file : readText;
		import rebel.engine;
		import rebel.input.filesystem;

		FileSystem fs = Engine.instance.fileSystem;

		{
			ShaderModuleBuilder vertexBuilder;
			fs.tree();
			FSFile file = fs.open("/imgui/base.vert.spv", FileMode.read);
			scope (exit)
				file.destroy;
			assert(file);
			char[] data;
			scope (exit)
				data.destroy;
			data.length = file.length;
			file.read(data);

			vertexBuilder.name = "/imgui/base.frag.spv";
			vertexBuilder.sourcecode = cast(string)data;
			vertexBuilder.entrypoint = "main";
			vertexBuilder.type = ShaderType.vertex;
			_vertexShaderModule = _renderer.construct(vertexBuilder);
		}

		{
			ShaderModuleBuilder fragmentBuilder;
			FSFile file = fs.open("/imgui/base.frag.spv", FileMode.read);
			scope (exit)
				file.destroy;
			assert(file);
			char[] data;
			scope (exit)
				data.destroy;
			data.length = file.length;
			file.read(data);

			fragmentBuilder.name = "/imgui/base.frag.spv";
			fragmentBuilder.sourcecode = cast(string)data;
			fragmentBuilder.entrypoint = "main";
			fragmentBuilder.type = ShaderType.fragment;
			_fragmentShaderModule = _renderer.construct(fragmentBuilder);
		}

		{
			SamplerBuilder builder;
			builder.name = "ImFontAtlas";
			_fontImageSampler = _renderer.construct(builder);
		}

	}

	void _createBuffers() {
		{
			BufferBuilder builder;
			builder.name = "Vertices Buffer";
			builder.size = 1024 * vec3f.sizeof; // TODO: Calc
			builder.bufferUsage = BufferUsage.vertex;
			builder.memoryUsage = MemoryUsage.cpuToGPU;
			builder.sharing = BufferSharing.exclusive;

			_verticesBuffer = _renderer.construct(builder);
		}
		{
			BufferBuilder builder;
			builder.name = "Indices Buffer";
			builder.size = 3*1024 * ushort.sizeof; // TODO: Calc
			builder.bufferUsage = BufferUsage.index;
			builder.memoryUsage = MemoryUsage.cpuToGPU;
			builder.sharing = BufferSharing.exclusive;

			_indicesBuffer = _renderer.construct(builder);
		}
	}

	void _createTextures() {
		const float fontSize = 24;
		{
			import rebel.engine : Engine;
			import rebel.input.filesystem : FSFile, FileMode;
			import std.format : format;
			import std.algorithm : min;

			FSFile f = Engine.instance.fileSystem.open("imgui/DroidSans.ttf", FileMode.read);
			scope (exit)
				f.destroy;

			ubyte[] data = (cast(ubyte*)igMemAlloc(f.length))[0 .. f.length];
			f.read(data);

			ImFontConfig cfg;

			string genName = format("%s, %.0fpx", "DroidSans.ttf", fontSize);
			cfg.Name[0 .. min(genName.length, cfg.Name.length)] = genName[0 .. min(genName.length, cfg.Name.length)];

			ImFontAtlas_AddFontFromMemoryTTF(igGetIO().Fonts, data.ptr, cast(int)data.length, fontSize, &cfg, null);
		}

		{
			import rebel.engine : Engine;
			import rebel.input.filesystem : FSFile, FileMode;

			FSFile f = Engine.instance.fileSystem.open("imgui/forkawesome-webfont.ttf", FileMode.read);
			scope (exit)
				f.destroy;

			ubyte[] data = (cast(ubyte*)igMemAlloc(f.length))[0 .. f.length];

			f.read(data);

			//initSymbolFont("FontAwesome", fontSize, data);
		}

		ImGuiIO* io = igGetIO();
		ubyte* pixels;
		int width, height;
		ImFontAtlas_GetTexDataAsRGBA32(io.Fonts, &pixels, &width, &height, null);

		ImageTemplate imageTemplate;
		{
			ImageTemplateBuilder templateBuilder;
			templateBuilder.name = "ImFontAtlas - Image Template";
			templateBuilder.readOnly = true;
			templateBuilder.format = ImageFormat.rgba8_unorm;
			templateBuilder.samples = 1;
			templateBuilder.size = vec2ui(width, height);
			templateBuilder.usage = ImageUsage.transferDst;

			imageTemplate = _renderer.construct(templateBuilder);
		}

		{
			ImageBuilder builder;
			builder.name = "ImFontAtlas - Image";
			builder.imageTemplate = imageTemplate;

			_fontImage = _renderer.construct(builder);
		}

		{
			scope Image.Ref imageRef = _renderer.get(_fontImage);
			ImageData* image = imageRef.get();
			image.setData(pixels[0 .. width * height * 4]);
		}

		ImFontAtlas_SetTexID(io.Fonts, cast(void*)&_fontImage);
	}

	bool _createPipeline() {
		PipelineBuilder builder;
		builder.name = "ImgUI Pipeline";
		builder.renderpass = _renderPass;

		builder.shaderStages ~= _vertexShaderModule;
		builder.shaderStages ~= _fragmentShaderModule;

		alias imDrawVert = VertexShaderInputInfo!ImguiImDrawVert;
		builder.vertexInputBindingDescriptions ~= imDrawVert.getVertexBindingDescription(Bindings.vertex);
		builder.vertexInputAttributeDescriptions ~= imDrawVert.getVertexAttributeDescriptions(Bindings.vertex);

		builder.descriptorSetLayoutBindings ~= getDescriptorSetLayoutBinding(_fontImageSampler, Bindings.fontTexture, ShaderStages.fragment);

		// vec2 offset, vec2 scale
		// TODO: make struct
		builder.pushContants ~= PushContant(ShaderStages.vertex, 0, float.sizeof * 4);

		/*foreach (i, uboBuffer; _uboBuffers)
			builder.descriptorBufferInfos ~= vktestUBO.getDescriptorBufferInfo(uboBuffer, Bindings.uniformBufferObject);*/

		builder.descriptorImageInfos ~= getDescriptorBufferInfo(_fontImage, _fontImageSampler, Bindings.fontTexture);

		builder.vertexTopology = VertexTopology.triangleList;

		builder.viewports = [Viewport(vec2f(0, 0), vec2f(_view.size), vec2f(0, 1))];
		builder.scissors = [Scissor(vec2i(0, 0), cast(vec2ui)_view.size)];

		builder.rasterizationState.depthClampEnable = false;
		builder.rasterizationState.rasterizerDiscardEnable = false;
		builder.rasterizationState.polygonMode = PolygonMode.fill;
		builder.rasterizationState.lineWidth = 1;
		builder.rasterizationState.cullMode = CullMode.none;
		builder.rasterizationState.frontFace = FrontFaceMode.counterClockwise;
		builder.rasterizationState.depthBiasEnable = false;

		builder.multisamplingEnabled = false;
		builder.multisamplingCount = SampleCount.Sample1;

		{
			auto attach = BlendAttachment();
			attach.blendEnable = true;
			attach.srcColorBlendFactor = BlendFactor.srcAlpha;
			attach.dstColorBlendFactor = BlendFactor.oneMinusSrcAlpha;
			attach.colorBlendOp = BlendOp.add;
			attach.srcAlphaBlendFactor = BlendFactor.oneMinusSrcAlpha;
			attach.dstAlphaBlendFactor = BlendFactor.zero;
			attach.alphaBlendOp = BlendOp.add;
			attach.colorWriteMask = ColorComponent.r | ColorComponent.g | ColorComponent.b | ColorComponent.a;
			builder.blendState.attachments ~= attach;
		}
		builder.blendState.logicOpEnable = false;
		builder.blendState.logicOp = LogicOp.copy;
		builder.blendState.blendConstants[] = 0;

		builder.dynamicStates = [DynamicState.viewport, DynamicState.scissor];

		_pipeline = _renderer.construct(builder);

		return true;
	}

	void _createCommandBuffers() {
	}

	// This is the main rendering function that you have to implement and provide to ImGui (via setting up 'RenderDrawListsFn' in the ImGuiIO structure)
	// Note that this implementation is little overcomplicated because we are saving/setting up/restoring every OpenGL state explicitly, in order to be able to run within any OpenGL engine that doesn't do so.
	// If text or lines are blurry when integrating ImGui in your engine: in your Render function, try translating your projection matrix by (0.5f,0.5f) or (0.375f,0.375f)

	extern (C) static const(char)* _getClipboardText(void*) nothrow {
		import std.string : toStringz;

		scope (failure)
			return "";
		return Engine.instance.view.clipboard.toStringz;
	}

	extern (C) static void _setClipboardText(void*, const(char)* text) nothrow {
		import std.string : fromStringz;

		scope (failure)
			return;
		Engine.instance.view.clipboard = cast(string)text.fromStringz;
	}
}
