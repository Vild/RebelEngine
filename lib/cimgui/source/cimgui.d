module cimgui;

import core.stdc.config;
import core.stdc.stdarg : va_list;

extern (C) {
	struct ImVec2_Simple {
		float x;
		float y;
	}

	struct ImVec4_Simple {
		float x;
		float y;
		float z;
		float w;
	}

	struct ImColor_Simple {
		ImVec4_Simple Value;
	}

	struct CustomRect {
		uint ID;
		ushort Width;
		ushort Height;
		ushort X;
		ushort Y;
		float GlyphAdvanceX;
		ImVec2 GlyphOffset;
		ImFont* Font;
	}

	struct GlyphRangesBuilder {
		ImVector_unsigned_char UsedChars;
	}

	struct ImFontGlyph {
		ushort Codepoint;
		float AdvanceX;
		float X0;
		float Y0;
		float X1;
		float Y1;
		float U0;
		float V0;
		float U1;
		float V1;
	}

	alias ImDrawIdx = ushort;
	struct Pair {
		uint key;
		static union _Anonymous_0 {
			int val_i;
			float val_f;
			void* val_p;
		}

		_Anonymous_0 _anonymous_1;
		auto val_i() @property @nogc pure nothrow {
			return _anonymous_1.val_i;
		}

		void val_i(_T_)(auto ref _T_ val) @property @nogc pure nothrow {
			_anonymous_1.val_i = val;
		}

		auto val_f() @property @nogc pure nothrow {
			return _anonymous_1.val_f;
		}

		void val_f(_T_)(auto ref _T_ val) @property @nogc pure nothrow {
			_anonymous_1.val_f = val;
		}

		auto val_p() @property @nogc pure nothrow {
			return _anonymous_1.val_p;
		}

		void val_p(_T_)(auto ref _T_ val) @property @nogc pure nothrow {
			_anonymous_1.val_p = val;
		}
	}

	struct TextRange {
		const(char)* b;
		const(char)* e;
	}

	struct ImVec4 {
		float x;
		float y;
		float z;
		float w;
	}

	struct ImVec2 {
		float x;
		float y;
	}

	struct ImGuiTextBuffer {
		ImVector_char Buf;
		char[1] EmptyString;
	}

	struct ImGuiTextFilter {
		char[256] InputBuf;
		ImVector_TextRange Filters;
		int CountGrep;
	}

	struct ImGuiStyle {
		float Alpha;
		ImVec2 WindowPadding;
		float WindowRounding;
		float WindowBorderSize;
		ImVec2 WindowMinSize;
		ImVec2 WindowTitleAlign;
		float ChildRounding;
		float ChildBorderSize;
		float PopupRounding;
		float PopupBorderSize;
		ImVec2 FramePadding;
		float FrameRounding;
		float FrameBorderSize;
		ImVec2 ItemSpacing;
		ImVec2 ItemInnerSpacing;
		ImVec2 TouchExtraPadding;
		float IndentSpacing;
		float ColumnsMinSpacing;
		float ScrollbarSize;
		float ScrollbarRounding;
		float GrabMinSize;
		float GrabRounding;
		ImVec2 ButtonTextAlign;
		ImVec2 DisplayWindowPadding;
		ImVec2 DisplaySafeAreaPadding;
		float MouseCursorScale;
		bool AntiAliasedLines;
		bool AntiAliasedFill;
		float CurveTessellationTol;
		ImVec4[43] Colors;
	}

	struct ImGuiStorage {
		ImVector_Pair Data;
	}

	struct ImGuiSizeCallbackData {
		void* UserData;
		ImVec2 Pos;
		ImVec2 CurrentSize;
		ImVec2 DesiredSize;
	}

	struct ImGuiPayload {
		void* Data;
		int DataSize;
		uint SourceId;
		uint SourceParentId;
		int DataFrameCount;
		char[33] DataType;
		bool Preview;
		bool Delivery;
	}

	struct ImGuiOnceUponAFrame {
		int RefFrame;
	}

	struct ImGuiListClipper {
		float StartPosY;
		float ItemsHeight;
		int ItemsCount;
		int StepNo;
		int DisplayStart;
		int DisplayEnd;
	}

	struct ImGuiInputTextCallbackData {
		int EventFlag;
		int Flags;
		void* UserData;
		ushort EventChar;
		int EventKey;
		char* Buf;
		int BufTextLen;
		int BufSize;
		bool BufDirty;
		int CursorPos;
		int SelectionStart;
		int SelectionEnd;
	}

	struct ImGuiIO {
		int ConfigFlags;
		int BackendFlags;
		ImVec2 DisplaySize;
		float DeltaTime;
		float IniSavingRate;
		const(char)* IniFilename;
		const(char)* LogFilename;
		float MouseDoubleClickTime;
		float MouseDoubleClickMaxDist;
		float MouseDragThreshold;
		int[21] KeyMap;
		float KeyRepeatDelay;
		float KeyRepeatRate;
		void* UserData;
		ImFontAtlas* Fonts;
		float FontGlobalScale;
		bool FontAllowUserScaling;
		ImFont* FontDefault;
		ImVec2 DisplayFramebufferScale;
		ImVec2 DisplayVisibleMin;
		ImVec2 DisplayVisibleMax;
		bool MouseDrawCursor;
		bool ConfigMacOSXBehaviors;
		bool ConfigInputTextCursorBlink;
		bool ConfigResizeWindowsFromEdges;
		const(char)* function(void*) GetClipboardTextFn;
		void function(void*, const(char)*) SetClipboardTextFn;
		void* ClipboardUserData;
		void function(int, int) ImeSetInputScreenPosFn;
		void* ImeWindowHandle;
		void* RenderDrawListsFnUnused;
		ImVec2 MousePos;
		bool[5] MouseDown;
		float MouseWheel;
		float MouseWheelH;
		bool KeyCtrl;
		bool KeyShift;
		bool KeyAlt;
		bool KeySuper;
		bool[512] KeysDown;
		ushort[17] InputCharacters;
		float[21] NavInputs;
		bool WantCaptureMouse;
		bool WantCaptureKeyboard;
		bool WantTextInput;
		bool WantSetMousePos;
		bool WantSaveIniSettings;
		bool NavActive;
		bool NavVisible;
		float Framerate;
		int MetricsRenderVertices;
		int MetricsRenderIndices;
		int MetricsRenderWindows;
		int MetricsActiveWindows;
		int MetricsActiveAllocations;
		ImVec2 MouseDelta;
		ImVec2 MousePosPrev;
		ImVec2[5] MouseClickedPos;
		double[5] MouseClickedTime;
		bool[5] MouseClicked;
		bool[5] MouseDoubleClicked;
		bool[5] MouseReleased;
		bool[5] MouseDownOwned;
		float[5] MouseDownDuration;
		float[5] MouseDownDurationPrev;
		ImVec2[5] MouseDragMaxDistanceAbs;
		float[5] MouseDragMaxDistanceSqr;
		float[512] KeysDownDuration;
		float[512] KeysDownDurationPrev;
		float[21] NavInputsDownDuration;
		float[21] NavInputsDownDurationPrev;
	}

	struct ImGuiContext;
	struct ImColor {
		ImVec4 Value;
	}

	struct ImFontConfig {
		void* FontData;
		int FontDataSize;
		bool FontDataOwnedByAtlas;
		int FontNo;
		float SizePixels;
		int OversampleH;
		int OversampleV;
		bool PixelSnapH;
		ImVec2 GlyphExtraSpacing;
		ImVec2 GlyphOffset;
		const(ushort)* GlyphRanges;
		float GlyphMinAdvanceX;
		float GlyphMaxAdvanceX;
		bool MergeMode;
		uint RasterizerFlags;
		float RasterizerMultiply;
		char[40] Name;
		ImFont* DstFont;
	}

	struct ImFontAtlas {
		bool Locked;
		int Flags;
		void* TexID;
		int TexDesiredWidth;
		int TexGlyphPadding;
		ubyte* TexPixelsAlpha8;
		uint* TexPixelsRGBA32;
		int TexWidth;
		int TexHeight;
		ImVec2 TexUvScale;
		ImVec2 TexUvWhitePixel;
		ImVector_ImFontPtr Fonts;
		ImVector_CustomRect CustomRects;
		ImVector_ImFontConfig ConfigData;
		int[1] CustomRectIds;
	}

	struct ImFont {
		float FontSize;
		float Scale;
		ImVec2 DisplayOffset;
		ImVector_ImFontGlyph Glyphs;
		ImVector_float IndexAdvanceX;
		ImVector_ImWchar IndexLookup;
		const(ImFontGlyph)* FallbackGlyph;
		float FallbackAdvanceX;
		ushort FallbackChar;
		short ConfigDataCount;
		ImFontConfig* ConfigData;
		ImFontAtlas* ContainerAtlas;
		float Ascent;
		float Descent;
		bool DirtyLookupTables;
		int MetricsTotalSurface;
	}

	struct ImDrawVert {
		ImVec2 pos;
		ImVec2 uv;
		uint col;
	}

	struct ImDrawListSharedData;
	struct ImDrawList {
		ImVector_ImDrawCmd CmdBuffer;
		ImVector_ImDrawIdx IdxBuffer;
		ImVector_ImDrawVert VtxBuffer;
		int Flags;
		const(ImDrawListSharedData)* _Data;
		const(char)* _OwnerName;
		uint _VtxCurrentIdx;
		ImDrawVert* _VtxWritePtr;
		ushort* _IdxWritePtr;
		ImVector_ImVec4 _ClipRectStack;
		ImVector_ImTextureID _TextureIdStack;
		ImVector_ImVec2 _Path;
		int _ChannelsCurrent;
		int _ChannelsCount;
		ImVector_ImDrawChannel _Channels;
	}

	struct ImDrawData {
		bool Valid;
		ImDrawList** CmdLists;
		int CmdListsCount;
		int TotalIdxCount;
		int TotalVtxCount;
		ImVec2 DisplayPos;
		ImVec2 DisplaySize;
	}

	struct ImDrawCmd {
		uint ElemCount;
		ImVec4 ClipRect;
		void* TextureId;
		void function(const(ImDrawList)*, const(ImDrawCmd)*) nothrow UserCallback;
		void* UserCallbackData;
	}

	struct ImDrawChannel {
		ImVector_ImDrawCmd CmdBuffer;
		ImVector_ImDrawIdx IdxBuffer;
	}

	alias ImTextureID = void*;
	alias ImGuiID = uint;
	alias ImWchar = ushort;
	alias ImGuiCol = int;
	alias ImGuiCond = int;
	alias ImGuiDataType = int;
	alias ImGuiDir = int;
	alias ImGuiKey = int;
	alias ImGuiNavInput = int;
	alias ImGuiMouseCursor = int;
	alias ImGuiStyleVar = int;
	alias ImDrawCornerFlags = int;
	alias ImDrawListFlags = int;
	alias ImFontAtlasFlags = int;
	alias ImGuiBackendFlags = int;
	alias ImGuiColorEditFlags = int;
	alias ImGuiColumnsFlags = int;
	alias ImGuiConfigFlags = int;
	alias ImGuiComboFlags = int;
	alias ImGuiDragDropFlags = int;
	alias ImGuiFocusedFlags = int;
	alias ImGuiHoveredFlags = int;
	alias ImGuiInputTextFlags = int;
	alias ImGuiSelectableFlags = int;
	alias ImGuiTreeNodeFlags = int;
	alias ImGuiWindowFlags = int;
	alias ImGuiInputTextCallback = int function(ImGuiInputTextCallbackData*);
	alias ImGuiSizeCallback = void function(ImGuiSizeCallbackData*);
	alias ImS32 = int;
	alias ImU32 = uint;
	alias ImS64 = c_long;
	alias ImU64 = c_ulong;
	enum ImGuiWindowFlags_ {
		ImGuiWindowFlags_None = 0,
		ImGuiWindowFlags_NoTitleBar = 1,
		ImGuiWindowFlags_NoResize = 2,
		ImGuiWindowFlags_NoMove = 4,
		ImGuiWindowFlags_NoScrollbar = 8,
		ImGuiWindowFlags_NoScrollWithMouse = 16,
		ImGuiWindowFlags_NoCollapse = 32,
		ImGuiWindowFlags_AlwaysAutoResize = 64,
		ImGuiWindowFlags_NoBackground = 128,
		ImGuiWindowFlags_NoSavedSettings = 256,
		ImGuiWindowFlags_NoMouseInputs = 512,
		ImGuiWindowFlags_MenuBar = 1024,
		ImGuiWindowFlags_HorizontalScrollbar = 2048,
		ImGuiWindowFlags_NoFocusOnAppearing = 4096,
		ImGuiWindowFlags_NoBringToFrontOnFocus = 8192,
		ImGuiWindowFlags_AlwaysVerticalScrollbar = 16384,
		ImGuiWindowFlags_AlwaysHorizontalScrollbar = 32768,
		ImGuiWindowFlags_AlwaysUseWindowPadding = 65536,
		ImGuiWindowFlags_NoNavInputs = 262144,
		ImGuiWindowFlags_NoNavFocus = 524288,
		ImGuiWindowFlags_NoNav = 786432,
		ImGuiWindowFlags_NoDecoration = 43,
		ImGuiWindowFlags_NoInputs = 786944,
		ImGuiWindowFlags_NavFlattened = 8388608,
		ImGuiWindowFlags_ChildWindow = 16777216,
		ImGuiWindowFlags_Tooltip = 33554432,
		ImGuiWindowFlags_Popup = 67108864,
		ImGuiWindowFlags_Modal = 134217728,
		ImGuiWindowFlags_ChildMenu = 268435456,
	}

	enum ImGuiWindowFlags_None = ImGuiWindowFlags_.ImGuiWindowFlags_None;
	enum ImGuiWindowFlags_NoTitleBar = ImGuiWindowFlags_.ImGuiWindowFlags_NoTitleBar;
	enum ImGuiWindowFlags_NoResize = ImGuiWindowFlags_.ImGuiWindowFlags_NoResize;
	enum ImGuiWindowFlags_NoMove = ImGuiWindowFlags_.ImGuiWindowFlags_NoMove;
	enum ImGuiWindowFlags_NoScrollbar = ImGuiWindowFlags_.ImGuiWindowFlags_NoScrollbar;
	enum ImGuiWindowFlags_NoScrollWithMouse = ImGuiWindowFlags_.ImGuiWindowFlags_NoScrollWithMouse;
	enum ImGuiWindowFlags_NoCollapse = ImGuiWindowFlags_.ImGuiWindowFlags_NoCollapse;
	enum ImGuiWindowFlags_AlwaysAutoResize = ImGuiWindowFlags_.ImGuiWindowFlags_AlwaysAutoResize;
	enum ImGuiWindowFlags_NoBackground = ImGuiWindowFlags_.ImGuiWindowFlags_NoBackground;
	enum ImGuiWindowFlags_NoSavedSettings = ImGuiWindowFlags_.ImGuiWindowFlags_NoSavedSettings;
	enum ImGuiWindowFlags_NoMouseInputs = ImGuiWindowFlags_.ImGuiWindowFlags_NoMouseInputs;
	enum ImGuiWindowFlags_MenuBar = ImGuiWindowFlags_.ImGuiWindowFlags_MenuBar;
	enum ImGuiWindowFlags_HorizontalScrollbar = ImGuiWindowFlags_.ImGuiWindowFlags_HorizontalScrollbar;
	enum ImGuiWindowFlags_NoFocusOnAppearing = ImGuiWindowFlags_.ImGuiWindowFlags_NoFocusOnAppearing;
	enum ImGuiWindowFlags_NoBringToFrontOnFocus = ImGuiWindowFlags_.ImGuiWindowFlags_NoBringToFrontOnFocus;
	enum ImGuiWindowFlags_AlwaysVerticalScrollbar = ImGuiWindowFlags_.ImGuiWindowFlags_AlwaysVerticalScrollbar;
	enum ImGuiWindowFlags_AlwaysHorizontalScrollbar = ImGuiWindowFlags_.ImGuiWindowFlags_AlwaysHorizontalScrollbar;
	enum ImGuiWindowFlags_AlwaysUseWindowPadding = ImGuiWindowFlags_.ImGuiWindowFlags_AlwaysUseWindowPadding;
	enum ImGuiWindowFlags_NoNavInputs = ImGuiWindowFlags_.ImGuiWindowFlags_NoNavInputs;
	enum ImGuiWindowFlags_NoNavFocus = ImGuiWindowFlags_.ImGuiWindowFlags_NoNavFocus;
	enum ImGuiWindowFlags_NoNav = ImGuiWindowFlags_.ImGuiWindowFlags_NoNav;
	enum ImGuiWindowFlags_NoDecoration = ImGuiWindowFlags_.ImGuiWindowFlags_NoDecoration;
	enum ImGuiWindowFlags_NoInputs = ImGuiWindowFlags_.ImGuiWindowFlags_NoInputs;
	enum ImGuiWindowFlags_NavFlattened = ImGuiWindowFlags_.ImGuiWindowFlags_NavFlattened;
	enum ImGuiWindowFlags_ChildWindow = ImGuiWindowFlags_.ImGuiWindowFlags_ChildWindow;
	enum ImGuiWindowFlags_Tooltip = ImGuiWindowFlags_.ImGuiWindowFlags_Tooltip;
	enum ImGuiWindowFlags_Popup = ImGuiWindowFlags_.ImGuiWindowFlags_Popup;
	enum ImGuiWindowFlags_Modal = ImGuiWindowFlags_.ImGuiWindowFlags_Modal;
	enum ImGuiWindowFlags_ChildMenu = ImGuiWindowFlags_.ImGuiWindowFlags_ChildMenu;
	enum ImGuiInputTextFlags_ {
		ImGuiInputTextFlags_None = 0,
		ImGuiInputTextFlags_CharsDecimal = 1,
		ImGuiInputTextFlags_CharsHexadecimal = 2,
		ImGuiInputTextFlags_CharsUppercase = 4,
		ImGuiInputTextFlags_CharsNoBlank = 8,
		ImGuiInputTextFlags_AutoSelectAll = 16,
		ImGuiInputTextFlags_EnterReturnsTrue = 32,
		ImGuiInputTextFlags_CallbackCompletion = 64,
		ImGuiInputTextFlags_CallbackHistory = 128,
		ImGuiInputTextFlags_CallbackAlways = 256,
		ImGuiInputTextFlags_CallbackCharFilter = 512,
		ImGuiInputTextFlags_AllowTabInput = 1024,
		ImGuiInputTextFlags_CtrlEnterForNewLine = 2048,
		ImGuiInputTextFlags_NoHorizontalScroll = 4096,
		ImGuiInputTextFlags_AlwaysInsertMode = 8192,
		ImGuiInputTextFlags_ReadOnly = 16384,
		ImGuiInputTextFlags_Password = 32768,
		ImGuiInputTextFlags_NoUndoRedo = 65536,
		ImGuiInputTextFlags_CharsScientific = 131072,
		ImGuiInputTextFlags_CallbackResize = 262144,
		ImGuiInputTextFlags_Multiline = 1048576,
	}

	enum ImGuiInputTextFlags_None = ImGuiInputTextFlags_.ImGuiInputTextFlags_None;
	enum ImGuiInputTextFlags_CharsDecimal = ImGuiInputTextFlags_.ImGuiInputTextFlags_CharsDecimal;
	enum ImGuiInputTextFlags_CharsHexadecimal = ImGuiInputTextFlags_.ImGuiInputTextFlags_CharsHexadecimal;
	enum ImGuiInputTextFlags_CharsUppercase = ImGuiInputTextFlags_.ImGuiInputTextFlags_CharsUppercase;
	enum ImGuiInputTextFlags_CharsNoBlank = ImGuiInputTextFlags_.ImGuiInputTextFlags_CharsNoBlank;
	enum ImGuiInputTextFlags_AutoSelectAll = ImGuiInputTextFlags_.ImGuiInputTextFlags_AutoSelectAll;
	enum ImGuiInputTextFlags_EnterReturnsTrue = ImGuiInputTextFlags_.ImGuiInputTextFlags_EnterReturnsTrue;
	enum ImGuiInputTextFlags_CallbackCompletion = ImGuiInputTextFlags_.ImGuiInputTextFlags_CallbackCompletion;
	enum ImGuiInputTextFlags_CallbackHistory = ImGuiInputTextFlags_.ImGuiInputTextFlags_CallbackHistory;
	enum ImGuiInputTextFlags_CallbackAlways = ImGuiInputTextFlags_.ImGuiInputTextFlags_CallbackAlways;
	enum ImGuiInputTextFlags_CallbackCharFilter = ImGuiInputTextFlags_.ImGuiInputTextFlags_CallbackCharFilter;
	enum ImGuiInputTextFlags_AllowTabInput = ImGuiInputTextFlags_.ImGuiInputTextFlags_AllowTabInput;
	enum ImGuiInputTextFlags_CtrlEnterForNewLine = ImGuiInputTextFlags_.ImGuiInputTextFlags_CtrlEnterForNewLine;
	enum ImGuiInputTextFlags_NoHorizontalScroll = ImGuiInputTextFlags_.ImGuiInputTextFlags_NoHorizontalScroll;
	enum ImGuiInputTextFlags_AlwaysInsertMode = ImGuiInputTextFlags_.ImGuiInputTextFlags_AlwaysInsertMode;
	enum ImGuiInputTextFlags_ReadOnly = ImGuiInputTextFlags_.ImGuiInputTextFlags_ReadOnly;
	enum ImGuiInputTextFlags_Password = ImGuiInputTextFlags_.ImGuiInputTextFlags_Password;
	enum ImGuiInputTextFlags_NoUndoRedo = ImGuiInputTextFlags_.ImGuiInputTextFlags_NoUndoRedo;
	enum ImGuiInputTextFlags_CharsScientific = ImGuiInputTextFlags_.ImGuiInputTextFlags_CharsScientific;
	enum ImGuiInputTextFlags_CallbackResize = ImGuiInputTextFlags_.ImGuiInputTextFlags_CallbackResize;
	enum ImGuiInputTextFlags_Multiline = ImGuiInputTextFlags_.ImGuiInputTextFlags_Multiline;
	enum ImGuiTreeNodeFlags_ {
		ImGuiTreeNodeFlags_None = 0,
		ImGuiTreeNodeFlags_Selected = 1,
		ImGuiTreeNodeFlags_Framed = 2,
		ImGuiTreeNodeFlags_AllowItemOverlap = 4,
		ImGuiTreeNodeFlags_NoTreePushOnOpen = 8,
		ImGuiTreeNodeFlags_NoAutoOpenOnLog = 16,
		ImGuiTreeNodeFlags_DefaultOpen = 32,
		ImGuiTreeNodeFlags_OpenOnDoubleClick = 64,
		ImGuiTreeNodeFlags_OpenOnArrow = 128,
		ImGuiTreeNodeFlags_Leaf = 256,
		ImGuiTreeNodeFlags_Bullet = 512,
		ImGuiTreeNodeFlags_FramePadding = 1024,
		ImGuiTreeNodeFlags_NavLeftJumpsBackHere = 8192,
		ImGuiTreeNodeFlags_CollapsingHeader = 26,
	}

	enum ImGuiTreeNodeFlags_None = ImGuiTreeNodeFlags_.ImGuiTreeNodeFlags_None;
	enum ImGuiTreeNodeFlags_Selected = ImGuiTreeNodeFlags_.ImGuiTreeNodeFlags_Selected;
	enum ImGuiTreeNodeFlags_Framed = ImGuiTreeNodeFlags_.ImGuiTreeNodeFlags_Framed;
	enum ImGuiTreeNodeFlags_AllowItemOverlap = ImGuiTreeNodeFlags_.ImGuiTreeNodeFlags_AllowItemOverlap;
	enum ImGuiTreeNodeFlags_NoTreePushOnOpen = ImGuiTreeNodeFlags_.ImGuiTreeNodeFlags_NoTreePushOnOpen;
	enum ImGuiTreeNodeFlags_NoAutoOpenOnLog = ImGuiTreeNodeFlags_.ImGuiTreeNodeFlags_NoAutoOpenOnLog;
	enum ImGuiTreeNodeFlags_DefaultOpen = ImGuiTreeNodeFlags_.ImGuiTreeNodeFlags_DefaultOpen;
	enum ImGuiTreeNodeFlags_OpenOnDoubleClick = ImGuiTreeNodeFlags_.ImGuiTreeNodeFlags_OpenOnDoubleClick;
	enum ImGuiTreeNodeFlags_OpenOnArrow = ImGuiTreeNodeFlags_.ImGuiTreeNodeFlags_OpenOnArrow;
	enum ImGuiTreeNodeFlags_Leaf = ImGuiTreeNodeFlags_.ImGuiTreeNodeFlags_Leaf;
	enum ImGuiTreeNodeFlags_Bullet = ImGuiTreeNodeFlags_.ImGuiTreeNodeFlags_Bullet;
	enum ImGuiTreeNodeFlags_FramePadding = ImGuiTreeNodeFlags_.ImGuiTreeNodeFlags_FramePadding;
	enum ImGuiTreeNodeFlags_NavLeftJumpsBackHere = ImGuiTreeNodeFlags_.ImGuiTreeNodeFlags_NavLeftJumpsBackHere;
	enum ImGuiTreeNodeFlags_CollapsingHeader = ImGuiTreeNodeFlags_.ImGuiTreeNodeFlags_CollapsingHeader;
	enum ImGuiSelectableFlags_ {
		ImGuiSelectableFlags_None = 0,
		ImGuiSelectableFlags_DontClosePopups = 1,
		ImGuiSelectableFlags_SpanAllColumns = 2,
		ImGuiSelectableFlags_AllowDoubleClick = 4,
		ImGuiSelectableFlags_Disabled = 8,
	}

	enum ImGuiSelectableFlags_None = ImGuiSelectableFlags_.ImGuiSelectableFlags_None;
	enum ImGuiSelectableFlags_DontClosePopups = ImGuiSelectableFlags_.ImGuiSelectableFlags_DontClosePopups;
	enum ImGuiSelectableFlags_SpanAllColumns = ImGuiSelectableFlags_.ImGuiSelectableFlags_SpanAllColumns;
	enum ImGuiSelectableFlags_AllowDoubleClick = ImGuiSelectableFlags_.ImGuiSelectableFlags_AllowDoubleClick;
	enum ImGuiSelectableFlags_Disabled = ImGuiSelectableFlags_.ImGuiSelectableFlags_Disabled;
	enum ImGuiComboFlags_ {
		ImGuiComboFlags_None = 0,
		ImGuiComboFlags_PopupAlignLeft = 1,
		ImGuiComboFlags_HeightSmall = 2,
		ImGuiComboFlags_HeightRegular = 4,
		ImGuiComboFlags_HeightLarge = 8,
		ImGuiComboFlags_HeightLargest = 16,
		ImGuiComboFlags_NoArrowButton = 32,
		ImGuiComboFlags_NoPreview = 64,
		ImGuiComboFlags_HeightMask_ = 30,
	}

	enum ImGuiComboFlags_None = ImGuiComboFlags_.ImGuiComboFlags_None;
	enum ImGuiComboFlags_PopupAlignLeft = ImGuiComboFlags_.ImGuiComboFlags_PopupAlignLeft;
	enum ImGuiComboFlags_HeightSmall = ImGuiComboFlags_.ImGuiComboFlags_HeightSmall;
	enum ImGuiComboFlags_HeightRegular = ImGuiComboFlags_.ImGuiComboFlags_HeightRegular;
	enum ImGuiComboFlags_HeightLarge = ImGuiComboFlags_.ImGuiComboFlags_HeightLarge;
	enum ImGuiComboFlags_HeightLargest = ImGuiComboFlags_.ImGuiComboFlags_HeightLargest;
	enum ImGuiComboFlags_NoArrowButton = ImGuiComboFlags_.ImGuiComboFlags_NoArrowButton;
	enum ImGuiComboFlags_NoPreview = ImGuiComboFlags_.ImGuiComboFlags_NoPreview;
	enum ImGuiComboFlags_HeightMask_ = ImGuiComboFlags_.ImGuiComboFlags_HeightMask_;
	enum ImGuiFocusedFlags_ {
		ImGuiFocusedFlags_None = 0,
		ImGuiFocusedFlags_ChildWindows = 1,
		ImGuiFocusedFlags_RootWindow = 2,
		ImGuiFocusedFlags_AnyWindow = 4,
		ImGuiFocusedFlags_RootAndChildWindows = 3,
	}

	enum ImGuiFocusedFlags_None = ImGuiFocusedFlags_.ImGuiFocusedFlags_None;
	enum ImGuiFocusedFlags_ChildWindows = ImGuiFocusedFlags_.ImGuiFocusedFlags_ChildWindows;
	enum ImGuiFocusedFlags_RootWindow = ImGuiFocusedFlags_.ImGuiFocusedFlags_RootWindow;
	enum ImGuiFocusedFlags_AnyWindow = ImGuiFocusedFlags_.ImGuiFocusedFlags_AnyWindow;
	enum ImGuiFocusedFlags_RootAndChildWindows = ImGuiFocusedFlags_.ImGuiFocusedFlags_RootAndChildWindows;
	enum ImGuiHoveredFlags_ {
		ImGuiHoveredFlags_None = 0,
		ImGuiHoveredFlags_ChildWindows = 1,
		ImGuiHoveredFlags_RootWindow = 2,
		ImGuiHoveredFlags_AnyWindow = 4,
		ImGuiHoveredFlags_AllowWhenBlockedByPopup = 8,
		ImGuiHoveredFlags_AllowWhenBlockedByActiveItem = 32,
		ImGuiHoveredFlags_AllowWhenOverlapped = 64,
		ImGuiHoveredFlags_AllowWhenDisabled = 128,
		ImGuiHoveredFlags_RectOnly = 104,
		ImGuiHoveredFlags_RootAndChildWindows = 3,
	}

	enum ImGuiHoveredFlags_None = ImGuiHoveredFlags_.ImGuiHoveredFlags_None;
	enum ImGuiHoveredFlags_ChildWindows = ImGuiHoveredFlags_.ImGuiHoveredFlags_ChildWindows;
	enum ImGuiHoveredFlags_RootWindow = ImGuiHoveredFlags_.ImGuiHoveredFlags_RootWindow;
	enum ImGuiHoveredFlags_AnyWindow = ImGuiHoveredFlags_.ImGuiHoveredFlags_AnyWindow;
	enum ImGuiHoveredFlags_AllowWhenBlockedByPopup = ImGuiHoveredFlags_.ImGuiHoveredFlags_AllowWhenBlockedByPopup;
	enum ImGuiHoveredFlags_AllowWhenBlockedByActiveItem = ImGuiHoveredFlags_.ImGuiHoveredFlags_AllowWhenBlockedByActiveItem;
	enum ImGuiHoveredFlags_AllowWhenOverlapped = ImGuiHoveredFlags_.ImGuiHoveredFlags_AllowWhenOverlapped;
	enum ImGuiHoveredFlags_AllowWhenDisabled = ImGuiHoveredFlags_.ImGuiHoveredFlags_AllowWhenDisabled;
	enum ImGuiHoveredFlags_RectOnly = ImGuiHoveredFlags_.ImGuiHoveredFlags_RectOnly;
	enum ImGuiHoveredFlags_RootAndChildWindows = ImGuiHoveredFlags_.ImGuiHoveredFlags_RootAndChildWindows;
	enum ImGuiDragDropFlags_ {
		ImGuiDragDropFlags_None = 0,
		ImGuiDragDropFlags_SourceNoPreviewTooltip = 1,
		ImGuiDragDropFlags_SourceNoDisableHover = 2,
		ImGuiDragDropFlags_SourceNoHoldToOpenOthers = 4,
		ImGuiDragDropFlags_SourceAllowNullID = 8,
		ImGuiDragDropFlags_SourceExtern = 16,
		ImGuiDragDropFlags_SourceAutoExpirePayload = 32,
		ImGuiDragDropFlags_AcceptBeforeDelivery = 1024,
		ImGuiDragDropFlags_AcceptNoDrawDefaultRect = 2048,
		ImGuiDragDropFlags_AcceptNoPreviewTooltip = 4096,
		ImGuiDragDropFlags_AcceptPeekOnly = 3072,
	}

	enum ImGuiDragDropFlags_None = ImGuiDragDropFlags_.ImGuiDragDropFlags_None;
	enum ImGuiDragDropFlags_SourceNoPreviewTooltip = ImGuiDragDropFlags_.ImGuiDragDropFlags_SourceNoPreviewTooltip;
	enum ImGuiDragDropFlags_SourceNoDisableHover = ImGuiDragDropFlags_.ImGuiDragDropFlags_SourceNoDisableHover;
	enum ImGuiDragDropFlags_SourceNoHoldToOpenOthers = ImGuiDragDropFlags_.ImGuiDragDropFlags_SourceNoHoldToOpenOthers;
	enum ImGuiDragDropFlags_SourceAllowNullID = ImGuiDragDropFlags_.ImGuiDragDropFlags_SourceAllowNullID;
	enum ImGuiDragDropFlags_SourceExtern = ImGuiDragDropFlags_.ImGuiDragDropFlags_SourceExtern;
	enum ImGuiDragDropFlags_SourceAutoExpirePayload = ImGuiDragDropFlags_.ImGuiDragDropFlags_SourceAutoExpirePayload;
	enum ImGuiDragDropFlags_AcceptBeforeDelivery = ImGuiDragDropFlags_.ImGuiDragDropFlags_AcceptBeforeDelivery;
	enum ImGuiDragDropFlags_AcceptNoDrawDefaultRect = ImGuiDragDropFlags_.ImGuiDragDropFlags_AcceptNoDrawDefaultRect;
	enum ImGuiDragDropFlags_AcceptNoPreviewTooltip = ImGuiDragDropFlags_.ImGuiDragDropFlags_AcceptNoPreviewTooltip;
	enum ImGuiDragDropFlags_AcceptPeekOnly = ImGuiDragDropFlags_.ImGuiDragDropFlags_AcceptPeekOnly;
	enum ImGuiDataType_ {
		ImGuiDataType_S32 = 0,
		ImGuiDataType_U32 = 1,
		ImGuiDataType_S64 = 2,
		ImGuiDataType_U64 = 3,
		ImGuiDataType_Float = 4,
		ImGuiDataType_Double = 5,
		ImGuiDataType_COUNT = 6,
	}

	enum ImGuiDataType_S32 = ImGuiDataType_.ImGuiDataType_S32;
	enum ImGuiDataType_U32 = ImGuiDataType_.ImGuiDataType_U32;
	enum ImGuiDataType_S64 = ImGuiDataType_.ImGuiDataType_S64;
	enum ImGuiDataType_U64 = ImGuiDataType_.ImGuiDataType_U64;
	enum ImGuiDataType_Float = ImGuiDataType_.ImGuiDataType_Float;
	enum ImGuiDataType_Double = ImGuiDataType_.ImGuiDataType_Double;
	enum ImGuiDataType_COUNT = ImGuiDataType_.ImGuiDataType_COUNT;
	enum ImGuiDir_ {
		ImGuiDir_None = -1,
		ImGuiDir_Left = 0,
		ImGuiDir_Right = 1,
		ImGuiDir_Up = 2,
		ImGuiDir_Down = 3,
		ImGuiDir_COUNT = 4,
	}

	enum ImGuiDir_None = ImGuiDir_.ImGuiDir_None;
	enum ImGuiDir_Left = ImGuiDir_.ImGuiDir_Left;
	enum ImGuiDir_Right = ImGuiDir_.ImGuiDir_Right;
	enum ImGuiDir_Up = ImGuiDir_.ImGuiDir_Up;
	enum ImGuiDir_Down = ImGuiDir_.ImGuiDir_Down;
	enum ImGuiDir_COUNT = ImGuiDir_.ImGuiDir_COUNT;
	enum ImGuiKey_ {
		ImGuiKey_Tab = 0,
		ImGuiKey_LeftArrow = 1,
		ImGuiKey_RightArrow = 2,
		ImGuiKey_UpArrow = 3,
		ImGuiKey_DownArrow = 4,
		ImGuiKey_PageUp = 5,
		ImGuiKey_PageDown = 6,
		ImGuiKey_Home = 7,
		ImGuiKey_End = 8,
		ImGuiKey_Insert = 9,
		ImGuiKey_Delete = 10,
		ImGuiKey_Backspace = 11,
		ImGuiKey_Space = 12,
		ImGuiKey_Enter = 13,
		ImGuiKey_Escape = 14,
		ImGuiKey_A = 15,
		ImGuiKey_C = 16,
		ImGuiKey_V = 17,
		ImGuiKey_X = 18,
		ImGuiKey_Y = 19,
		ImGuiKey_Z = 20,
		ImGuiKey_COUNT = 21,
	}

	enum ImGuiKey_Tab = ImGuiKey_.ImGuiKey_Tab;
	enum ImGuiKey_LeftArrow = ImGuiKey_.ImGuiKey_LeftArrow;
	enum ImGuiKey_RightArrow = ImGuiKey_.ImGuiKey_RightArrow;
	enum ImGuiKey_UpArrow = ImGuiKey_.ImGuiKey_UpArrow;
	enum ImGuiKey_DownArrow = ImGuiKey_.ImGuiKey_DownArrow;
	enum ImGuiKey_PageUp = ImGuiKey_.ImGuiKey_PageUp;
	enum ImGuiKey_PageDown = ImGuiKey_.ImGuiKey_PageDown;
	enum ImGuiKey_Home = ImGuiKey_.ImGuiKey_Home;
	enum ImGuiKey_End = ImGuiKey_.ImGuiKey_End;
	enum ImGuiKey_Insert = ImGuiKey_.ImGuiKey_Insert;
	enum ImGuiKey_Delete = ImGuiKey_.ImGuiKey_Delete;
	enum ImGuiKey_Backspace = ImGuiKey_.ImGuiKey_Backspace;
	enum ImGuiKey_Space = ImGuiKey_.ImGuiKey_Space;
	enum ImGuiKey_Enter = ImGuiKey_.ImGuiKey_Enter;
	enum ImGuiKey_Escape = ImGuiKey_.ImGuiKey_Escape;
	enum ImGuiKey_A = ImGuiKey_.ImGuiKey_A;
	enum ImGuiKey_C = ImGuiKey_.ImGuiKey_C;
	enum ImGuiKey_V = ImGuiKey_.ImGuiKey_V;
	enum ImGuiKey_X = ImGuiKey_.ImGuiKey_X;
	enum ImGuiKey_Y = ImGuiKey_.ImGuiKey_Y;
	enum ImGuiKey_Z = ImGuiKey_.ImGuiKey_Z;
	enum ImGuiKey_COUNT = ImGuiKey_.ImGuiKey_COUNT;
	enum ImGuiNavInput_ {
		ImGuiNavInput_Activate = 0,
		ImGuiNavInput_Cancel = 1,
		ImGuiNavInput_Input = 2,
		ImGuiNavInput_Menu = 3,
		ImGuiNavInput_DpadLeft = 4,
		ImGuiNavInput_DpadRight = 5,
		ImGuiNavInput_DpadUp = 6,
		ImGuiNavInput_DpadDown = 7,
		ImGuiNavInput_LStickLeft = 8,
		ImGuiNavInput_LStickRight = 9,
		ImGuiNavInput_LStickUp = 10,
		ImGuiNavInput_LStickDown = 11,
		ImGuiNavInput_FocusPrev = 12,
		ImGuiNavInput_FocusNext = 13,
		ImGuiNavInput_TweakSlow = 14,
		ImGuiNavInput_TweakFast = 15,
		ImGuiNavInput_KeyMenu_ = 16,
		ImGuiNavInput_KeyLeft_ = 17,
		ImGuiNavInput_KeyRight_ = 18,
		ImGuiNavInput_KeyUp_ = 19,
		ImGuiNavInput_KeyDown_ = 20,
		ImGuiNavInput_COUNT = 21,
		ImGuiNavInput_InternalStart_ = 16,
	}

	enum ImGuiNavInput_Activate = ImGuiNavInput_.ImGuiNavInput_Activate;
	enum ImGuiNavInput_Cancel = ImGuiNavInput_.ImGuiNavInput_Cancel;
	enum ImGuiNavInput_Input = ImGuiNavInput_.ImGuiNavInput_Input;
	enum ImGuiNavInput_Menu = ImGuiNavInput_.ImGuiNavInput_Menu;
	enum ImGuiNavInput_DpadLeft = ImGuiNavInput_.ImGuiNavInput_DpadLeft;
	enum ImGuiNavInput_DpadRight = ImGuiNavInput_.ImGuiNavInput_DpadRight;
	enum ImGuiNavInput_DpadUp = ImGuiNavInput_.ImGuiNavInput_DpadUp;
	enum ImGuiNavInput_DpadDown = ImGuiNavInput_.ImGuiNavInput_DpadDown;
	enum ImGuiNavInput_LStickLeft = ImGuiNavInput_.ImGuiNavInput_LStickLeft;
	enum ImGuiNavInput_LStickRight = ImGuiNavInput_.ImGuiNavInput_LStickRight;
	enum ImGuiNavInput_LStickUp = ImGuiNavInput_.ImGuiNavInput_LStickUp;
	enum ImGuiNavInput_LStickDown = ImGuiNavInput_.ImGuiNavInput_LStickDown;
	enum ImGuiNavInput_FocusPrev = ImGuiNavInput_.ImGuiNavInput_FocusPrev;
	enum ImGuiNavInput_FocusNext = ImGuiNavInput_.ImGuiNavInput_FocusNext;
	enum ImGuiNavInput_TweakSlow = ImGuiNavInput_.ImGuiNavInput_TweakSlow;
	enum ImGuiNavInput_TweakFast = ImGuiNavInput_.ImGuiNavInput_TweakFast;
	enum ImGuiNavInput_KeyMenu_ = ImGuiNavInput_.ImGuiNavInput_KeyMenu_;
	enum ImGuiNavInput_KeyLeft_ = ImGuiNavInput_.ImGuiNavInput_KeyLeft_;
	enum ImGuiNavInput_KeyRight_ = ImGuiNavInput_.ImGuiNavInput_KeyRight_;
	enum ImGuiNavInput_KeyUp_ = ImGuiNavInput_.ImGuiNavInput_KeyUp_;
	enum ImGuiNavInput_KeyDown_ = ImGuiNavInput_.ImGuiNavInput_KeyDown_;
	enum ImGuiNavInput_COUNT = ImGuiNavInput_.ImGuiNavInput_COUNT;
	enum ImGuiNavInput_InternalStart_ = ImGuiNavInput_.ImGuiNavInput_InternalStart_;
	enum ImGuiConfigFlags_ {
		ImGuiConfigFlags_NavEnableKeyboard = 1,
		ImGuiConfigFlags_NavEnableGamepad = 2,
		ImGuiConfigFlags_NavEnableSetMousePos = 4,
		ImGuiConfigFlags_NavNoCaptureKeyboard = 8,
		ImGuiConfigFlags_NoMouse = 16,
		ImGuiConfigFlags_NoMouseCursorChange = 32,
		ImGuiConfigFlags_IsSRGB = 1048576,
		ImGuiConfigFlags_IsTouchScreen = 2097152,
	}

	enum ImGuiConfigFlags_NavEnableKeyboard = ImGuiConfigFlags_.ImGuiConfigFlags_NavEnableKeyboard;
	enum ImGuiConfigFlags_NavEnableGamepad = ImGuiConfigFlags_.ImGuiConfigFlags_NavEnableGamepad;
	enum ImGuiConfigFlags_NavEnableSetMousePos = ImGuiConfigFlags_.ImGuiConfigFlags_NavEnableSetMousePos;
	enum ImGuiConfigFlags_NavNoCaptureKeyboard = ImGuiConfigFlags_.ImGuiConfigFlags_NavNoCaptureKeyboard;
	enum ImGuiConfigFlags_NoMouse = ImGuiConfigFlags_.ImGuiConfigFlags_NoMouse;
	enum ImGuiConfigFlags_NoMouseCursorChange = ImGuiConfigFlags_.ImGuiConfigFlags_NoMouseCursorChange;
	enum ImGuiConfigFlags_IsSRGB = ImGuiConfigFlags_.ImGuiConfigFlags_IsSRGB;
	enum ImGuiConfigFlags_IsTouchScreen = ImGuiConfigFlags_.ImGuiConfigFlags_IsTouchScreen;
	enum ImGuiBackendFlags_ {
		ImGuiBackendFlags_HasGamepad = 1,
		ImGuiBackendFlags_HasMouseCursors = 2,
		ImGuiBackendFlags_HasSetMousePos = 4,
	}

	enum ImGuiBackendFlags_HasGamepad = ImGuiBackendFlags_.ImGuiBackendFlags_HasGamepad;
	enum ImGuiBackendFlags_HasMouseCursors = ImGuiBackendFlags_.ImGuiBackendFlags_HasMouseCursors;
	enum ImGuiBackendFlags_HasSetMousePos = ImGuiBackendFlags_.ImGuiBackendFlags_HasSetMousePos;
	enum ImGuiCol_ {
		ImGuiCol_Text = 0,
		ImGuiCol_TextDisabled = 1,
		ImGuiCol_WindowBg = 2,
		ImGuiCol_ChildBg = 3,
		ImGuiCol_PopupBg = 4,
		ImGuiCol_Border = 5,
		ImGuiCol_BorderShadow = 6,
		ImGuiCol_FrameBg = 7,
		ImGuiCol_FrameBgHovered = 8,
		ImGuiCol_FrameBgActive = 9,
		ImGuiCol_TitleBg = 10,
		ImGuiCol_TitleBgActive = 11,
		ImGuiCol_TitleBgCollapsed = 12,
		ImGuiCol_MenuBarBg = 13,
		ImGuiCol_ScrollbarBg = 14,
		ImGuiCol_ScrollbarGrab = 15,
		ImGuiCol_ScrollbarGrabHovered = 16,
		ImGuiCol_ScrollbarGrabActive = 17,
		ImGuiCol_CheckMark = 18,
		ImGuiCol_SliderGrab = 19,
		ImGuiCol_SliderGrabActive = 20,
		ImGuiCol_Button = 21,
		ImGuiCol_ButtonHovered = 22,
		ImGuiCol_ButtonActive = 23,
		ImGuiCol_Header = 24,
		ImGuiCol_HeaderHovered = 25,
		ImGuiCol_HeaderActive = 26,
		ImGuiCol_Separator = 27,
		ImGuiCol_SeparatorHovered = 28,
		ImGuiCol_SeparatorActive = 29,
		ImGuiCol_ResizeGrip = 30,
		ImGuiCol_ResizeGripHovered = 31,
		ImGuiCol_ResizeGripActive = 32,
		ImGuiCol_PlotLines = 33,
		ImGuiCol_PlotLinesHovered = 34,
		ImGuiCol_PlotHistogram = 35,
		ImGuiCol_PlotHistogramHovered = 36,
		ImGuiCol_TextSelectedBg = 37,
		ImGuiCol_DragDropTarget = 38,
		ImGuiCol_NavHighlight = 39,
		ImGuiCol_NavWindowingHighlight = 40,
		ImGuiCol_NavWindowingDimBg = 41,
		ImGuiCol_ModalWindowDimBg = 42,
		ImGuiCol_COUNT = 43,
	}

	enum ImGuiCol_Text = ImGuiCol_.ImGuiCol_Text;
	enum ImGuiCol_TextDisabled = ImGuiCol_.ImGuiCol_TextDisabled;
	enum ImGuiCol_WindowBg = ImGuiCol_.ImGuiCol_WindowBg;
	enum ImGuiCol_ChildBg = ImGuiCol_.ImGuiCol_ChildBg;
	enum ImGuiCol_PopupBg = ImGuiCol_.ImGuiCol_PopupBg;
	enum ImGuiCol_Border = ImGuiCol_.ImGuiCol_Border;
	enum ImGuiCol_BorderShadow = ImGuiCol_.ImGuiCol_BorderShadow;
	enum ImGuiCol_FrameBg = ImGuiCol_.ImGuiCol_FrameBg;
	enum ImGuiCol_FrameBgHovered = ImGuiCol_.ImGuiCol_FrameBgHovered;
	enum ImGuiCol_FrameBgActive = ImGuiCol_.ImGuiCol_FrameBgActive;
	enum ImGuiCol_TitleBg = ImGuiCol_.ImGuiCol_TitleBg;
	enum ImGuiCol_TitleBgActive = ImGuiCol_.ImGuiCol_TitleBgActive;
	enum ImGuiCol_TitleBgCollapsed = ImGuiCol_.ImGuiCol_TitleBgCollapsed;
	enum ImGuiCol_MenuBarBg = ImGuiCol_.ImGuiCol_MenuBarBg;
	enum ImGuiCol_ScrollbarBg = ImGuiCol_.ImGuiCol_ScrollbarBg;
	enum ImGuiCol_ScrollbarGrab = ImGuiCol_.ImGuiCol_ScrollbarGrab;
	enum ImGuiCol_ScrollbarGrabHovered = ImGuiCol_.ImGuiCol_ScrollbarGrabHovered;
	enum ImGuiCol_ScrollbarGrabActive = ImGuiCol_.ImGuiCol_ScrollbarGrabActive;
	enum ImGuiCol_CheckMark = ImGuiCol_.ImGuiCol_CheckMark;
	enum ImGuiCol_SliderGrab = ImGuiCol_.ImGuiCol_SliderGrab;
	enum ImGuiCol_SliderGrabActive = ImGuiCol_.ImGuiCol_SliderGrabActive;
	enum ImGuiCol_Button = ImGuiCol_.ImGuiCol_Button;
	enum ImGuiCol_ButtonHovered = ImGuiCol_.ImGuiCol_ButtonHovered;
	enum ImGuiCol_ButtonActive = ImGuiCol_.ImGuiCol_ButtonActive;
	enum ImGuiCol_Header = ImGuiCol_.ImGuiCol_Header;
	enum ImGuiCol_HeaderHovered = ImGuiCol_.ImGuiCol_HeaderHovered;
	enum ImGuiCol_HeaderActive = ImGuiCol_.ImGuiCol_HeaderActive;
	enum ImGuiCol_Separator = ImGuiCol_.ImGuiCol_Separator;
	enum ImGuiCol_SeparatorHovered = ImGuiCol_.ImGuiCol_SeparatorHovered;
	enum ImGuiCol_SeparatorActive = ImGuiCol_.ImGuiCol_SeparatorActive;
	enum ImGuiCol_ResizeGrip = ImGuiCol_.ImGuiCol_ResizeGrip;
	enum ImGuiCol_ResizeGripHovered = ImGuiCol_.ImGuiCol_ResizeGripHovered;
	enum ImGuiCol_ResizeGripActive = ImGuiCol_.ImGuiCol_ResizeGripActive;
	enum ImGuiCol_PlotLines = ImGuiCol_.ImGuiCol_PlotLines;
	enum ImGuiCol_PlotLinesHovered = ImGuiCol_.ImGuiCol_PlotLinesHovered;
	enum ImGuiCol_PlotHistogram = ImGuiCol_.ImGuiCol_PlotHistogram;
	enum ImGuiCol_PlotHistogramHovered = ImGuiCol_.ImGuiCol_PlotHistogramHovered;
	enum ImGuiCol_TextSelectedBg = ImGuiCol_.ImGuiCol_TextSelectedBg;
	enum ImGuiCol_DragDropTarget = ImGuiCol_.ImGuiCol_DragDropTarget;
	enum ImGuiCol_NavHighlight = ImGuiCol_.ImGuiCol_NavHighlight;
	enum ImGuiCol_NavWindowingHighlight = ImGuiCol_.ImGuiCol_NavWindowingHighlight;
	enum ImGuiCol_NavWindowingDimBg = ImGuiCol_.ImGuiCol_NavWindowingDimBg;
	enum ImGuiCol_ModalWindowDimBg = ImGuiCol_.ImGuiCol_ModalWindowDimBg;
	enum ImGuiCol_COUNT = ImGuiCol_.ImGuiCol_COUNT;
	enum ImGuiStyleVar_ {
		ImGuiStyleVar_Alpha = 0,
		ImGuiStyleVar_WindowPadding = 1,
		ImGuiStyleVar_WindowRounding = 2,
		ImGuiStyleVar_WindowBorderSize = 3,
		ImGuiStyleVar_WindowMinSize = 4,
		ImGuiStyleVar_WindowTitleAlign = 5,
		ImGuiStyleVar_ChildRounding = 6,
		ImGuiStyleVar_ChildBorderSize = 7,
		ImGuiStyleVar_PopupRounding = 8,
		ImGuiStyleVar_PopupBorderSize = 9,
		ImGuiStyleVar_FramePadding = 10,
		ImGuiStyleVar_FrameRounding = 11,
		ImGuiStyleVar_FrameBorderSize = 12,
		ImGuiStyleVar_ItemSpacing = 13,
		ImGuiStyleVar_ItemInnerSpacing = 14,
		ImGuiStyleVar_IndentSpacing = 15,
		ImGuiStyleVar_ScrollbarSize = 16,
		ImGuiStyleVar_ScrollbarRounding = 17,
		ImGuiStyleVar_GrabMinSize = 18,
		ImGuiStyleVar_GrabRounding = 19,
		ImGuiStyleVar_ButtonTextAlign = 20,
		ImGuiStyleVar_COUNT = 21,
	}

	enum ImGuiStyleVar_Alpha = ImGuiStyleVar_.ImGuiStyleVar_Alpha;
	enum ImGuiStyleVar_WindowPadding = ImGuiStyleVar_.ImGuiStyleVar_WindowPadding;
	enum ImGuiStyleVar_WindowRounding = ImGuiStyleVar_.ImGuiStyleVar_WindowRounding;
	enum ImGuiStyleVar_WindowBorderSize = ImGuiStyleVar_.ImGuiStyleVar_WindowBorderSize;
	enum ImGuiStyleVar_WindowMinSize = ImGuiStyleVar_.ImGuiStyleVar_WindowMinSize;
	enum ImGuiStyleVar_WindowTitleAlign = ImGuiStyleVar_.ImGuiStyleVar_WindowTitleAlign;
	enum ImGuiStyleVar_ChildRounding = ImGuiStyleVar_.ImGuiStyleVar_ChildRounding;
	enum ImGuiStyleVar_ChildBorderSize = ImGuiStyleVar_.ImGuiStyleVar_ChildBorderSize;
	enum ImGuiStyleVar_PopupRounding = ImGuiStyleVar_.ImGuiStyleVar_PopupRounding;
	enum ImGuiStyleVar_PopupBorderSize = ImGuiStyleVar_.ImGuiStyleVar_PopupBorderSize;
	enum ImGuiStyleVar_FramePadding = ImGuiStyleVar_.ImGuiStyleVar_FramePadding;
	enum ImGuiStyleVar_FrameRounding = ImGuiStyleVar_.ImGuiStyleVar_FrameRounding;
	enum ImGuiStyleVar_FrameBorderSize = ImGuiStyleVar_.ImGuiStyleVar_FrameBorderSize;
	enum ImGuiStyleVar_ItemSpacing = ImGuiStyleVar_.ImGuiStyleVar_ItemSpacing;
	enum ImGuiStyleVar_ItemInnerSpacing = ImGuiStyleVar_.ImGuiStyleVar_ItemInnerSpacing;
	enum ImGuiStyleVar_IndentSpacing = ImGuiStyleVar_.ImGuiStyleVar_IndentSpacing;
	enum ImGuiStyleVar_ScrollbarSize = ImGuiStyleVar_.ImGuiStyleVar_ScrollbarSize;
	enum ImGuiStyleVar_ScrollbarRounding = ImGuiStyleVar_.ImGuiStyleVar_ScrollbarRounding;
	enum ImGuiStyleVar_GrabMinSize = ImGuiStyleVar_.ImGuiStyleVar_GrabMinSize;
	enum ImGuiStyleVar_GrabRounding = ImGuiStyleVar_.ImGuiStyleVar_GrabRounding;
	enum ImGuiStyleVar_ButtonTextAlign = ImGuiStyleVar_.ImGuiStyleVar_ButtonTextAlign;
	enum ImGuiStyleVar_COUNT = ImGuiStyleVar_.ImGuiStyleVar_COUNT;
	enum ImGuiColorEditFlags_ {
		ImGuiColorEditFlags_None = 0,
		ImGuiColorEditFlags_NoAlpha = 2,
		ImGuiColorEditFlags_NoPicker = 4,
		ImGuiColorEditFlags_NoOptions = 8,
		ImGuiColorEditFlags_NoSmallPreview = 16,
		ImGuiColorEditFlags_NoInputs = 32,
		ImGuiColorEditFlags_NoTooltip = 64,
		ImGuiColorEditFlags_NoLabel = 128,
		ImGuiColorEditFlags_NoSidePreview = 256,
		ImGuiColorEditFlags_NoDragDrop = 512,
		ImGuiColorEditFlags_AlphaBar = 65536,
		ImGuiColorEditFlags_AlphaPreview = 131072,
		ImGuiColorEditFlags_AlphaPreviewHalf = 262144,
		ImGuiColorEditFlags_HDR = 524288,
		ImGuiColorEditFlags_RGB = 1048576,
		ImGuiColorEditFlags_HSV = 2097152,
		ImGuiColorEditFlags_HEX = 4194304,
		ImGuiColorEditFlags_Uint8 = 8388608,
		ImGuiColorEditFlags_Float = 16777216,
		ImGuiColorEditFlags_PickerHueBar = 33554432,
		ImGuiColorEditFlags_PickerHueWheel = 67108864,
		ImGuiColorEditFlags__InputsMask = 7340032,
		ImGuiColorEditFlags__DataTypeMask = 25165824,
		ImGuiColorEditFlags__PickerMask = 100663296,
		ImGuiColorEditFlags__OptionsDefault = 42991616,
	}

	enum ImGuiColorEditFlags_None = ImGuiColorEditFlags_.ImGuiColorEditFlags_None;
	enum ImGuiColorEditFlags_NoAlpha = ImGuiColorEditFlags_.ImGuiColorEditFlags_NoAlpha;
	enum ImGuiColorEditFlags_NoPicker = ImGuiColorEditFlags_.ImGuiColorEditFlags_NoPicker;
	enum ImGuiColorEditFlags_NoOptions = ImGuiColorEditFlags_.ImGuiColorEditFlags_NoOptions;
	enum ImGuiColorEditFlags_NoSmallPreview = ImGuiColorEditFlags_.ImGuiColorEditFlags_NoSmallPreview;
	enum ImGuiColorEditFlags_NoInputs = ImGuiColorEditFlags_.ImGuiColorEditFlags_NoInputs;
	enum ImGuiColorEditFlags_NoTooltip = ImGuiColorEditFlags_.ImGuiColorEditFlags_NoTooltip;
	enum ImGuiColorEditFlags_NoLabel = ImGuiColorEditFlags_.ImGuiColorEditFlags_NoLabel;
	enum ImGuiColorEditFlags_NoSidePreview = ImGuiColorEditFlags_.ImGuiColorEditFlags_NoSidePreview;
	enum ImGuiColorEditFlags_NoDragDrop = ImGuiColorEditFlags_.ImGuiColorEditFlags_NoDragDrop;
	enum ImGuiColorEditFlags_AlphaBar = ImGuiColorEditFlags_.ImGuiColorEditFlags_AlphaBar;
	enum ImGuiColorEditFlags_AlphaPreview = ImGuiColorEditFlags_.ImGuiColorEditFlags_AlphaPreview;
	enum ImGuiColorEditFlags_AlphaPreviewHalf = ImGuiColorEditFlags_.ImGuiColorEditFlags_AlphaPreviewHalf;
	enum ImGuiColorEditFlags_HDR = ImGuiColorEditFlags_.ImGuiColorEditFlags_HDR;
	enum ImGuiColorEditFlags_RGB = ImGuiColorEditFlags_.ImGuiColorEditFlags_RGB;
	enum ImGuiColorEditFlags_HSV = ImGuiColorEditFlags_.ImGuiColorEditFlags_HSV;
	enum ImGuiColorEditFlags_HEX = ImGuiColorEditFlags_.ImGuiColorEditFlags_HEX;
	enum ImGuiColorEditFlags_Uint8 = ImGuiColorEditFlags_.ImGuiColorEditFlags_Uint8;
	enum ImGuiColorEditFlags_Float = ImGuiColorEditFlags_.ImGuiColorEditFlags_Float;
	enum ImGuiColorEditFlags_PickerHueBar = ImGuiColorEditFlags_.ImGuiColorEditFlags_PickerHueBar;
	enum ImGuiColorEditFlags_PickerHueWheel = ImGuiColorEditFlags_.ImGuiColorEditFlags_PickerHueWheel;
	enum ImGuiColorEditFlags__InputsMask = ImGuiColorEditFlags_.ImGuiColorEditFlags__InputsMask;
	enum ImGuiColorEditFlags__DataTypeMask = ImGuiColorEditFlags_.ImGuiColorEditFlags__DataTypeMask;
	enum ImGuiColorEditFlags__PickerMask = ImGuiColorEditFlags_.ImGuiColorEditFlags__PickerMask;
	enum ImGuiColorEditFlags__OptionsDefault = ImGuiColorEditFlags_.ImGuiColorEditFlags__OptionsDefault;
	enum ImGuiMouseCursor_ {
		ImGuiMouseCursor_None = -1,
		ImGuiMouseCursor_Arrow = 0,
		ImGuiMouseCursor_TextInput = 1,
		ImGuiMouseCursor_ResizeAll = 2,
		ImGuiMouseCursor_ResizeNS = 3,
		ImGuiMouseCursor_ResizeEW = 4,
		ImGuiMouseCursor_ResizeNESW = 5,
		ImGuiMouseCursor_ResizeNWSE = 6,
		ImGuiMouseCursor_Hand = 7,
		ImGuiMouseCursor_COUNT = 8,
	}

	enum ImGuiMouseCursor_None = ImGuiMouseCursor_.ImGuiMouseCursor_None;
	enum ImGuiMouseCursor_Arrow = ImGuiMouseCursor_.ImGuiMouseCursor_Arrow;
	enum ImGuiMouseCursor_TextInput = ImGuiMouseCursor_.ImGuiMouseCursor_TextInput;
	enum ImGuiMouseCursor_ResizeAll = ImGuiMouseCursor_.ImGuiMouseCursor_ResizeAll;
	enum ImGuiMouseCursor_ResizeNS = ImGuiMouseCursor_.ImGuiMouseCursor_ResizeNS;
	enum ImGuiMouseCursor_ResizeEW = ImGuiMouseCursor_.ImGuiMouseCursor_ResizeEW;
	enum ImGuiMouseCursor_ResizeNESW = ImGuiMouseCursor_.ImGuiMouseCursor_ResizeNESW;
	enum ImGuiMouseCursor_ResizeNWSE = ImGuiMouseCursor_.ImGuiMouseCursor_ResizeNWSE;
	enum ImGuiMouseCursor_Hand = ImGuiMouseCursor_.ImGuiMouseCursor_Hand;
	enum ImGuiMouseCursor_COUNT = ImGuiMouseCursor_.ImGuiMouseCursor_COUNT;
	enum ImGuiCond_ {
		ImGuiCond_Always = 1,
		ImGuiCond_Once = 2,
		ImGuiCond_FirstUseEver = 4,
		ImGuiCond_Appearing = 8,
	}

	enum ImGuiCond_Always = ImGuiCond_.ImGuiCond_Always;
	enum ImGuiCond_Once = ImGuiCond_.ImGuiCond_Once;
	enum ImGuiCond_FirstUseEver = ImGuiCond_.ImGuiCond_FirstUseEver;
	enum ImGuiCond_Appearing = ImGuiCond_.ImGuiCond_Appearing;
	struct ImVector {
		int Size;
		int Capacity;
		void* Data;
	}

	struct ImVector_float {
		int Size;
		int Capacity;
		float* Data;
	}

	struct ImVector_ImWchar {
		int Size;
		int Capacity;
		ushort* Data;
	}

	struct ImVector_ImFontConfig {
		int Size;
		int Capacity;
		ImFontConfig* Data;
	}

	struct ImVector_ImFontGlyph {
		int Size;
		int Capacity;
		ImFontGlyph* Data;
	}

	struct ImVector_unsigned_char {
		int Size;
		int Capacity;
		ubyte* Data;
	}

	struct ImVector_Pair {
		int Size;
		int Capacity;
		Pair* Data;
	}

	struct ImVector_CustomRect {
		int Size;
		int Capacity;
		CustomRect* Data;
	}

	struct ImVector_ImDrawChannel {
		int Size;
		int Capacity;
		ImDrawChannel* Data;
	}

	struct ImVector_char {
		int Size;
		int Capacity;
		char* Data;
	}

	struct ImVector_ImTextureID {
		int Size;
		int Capacity;
		void** Data;
	}

	struct ImVector_ImDrawVert {
		int Size;
		int Capacity;
		ImDrawVert* Data;
	}

	struct ImVector_ImDrawCmd {
		int Size;
		int Capacity;
		ImDrawCmd* Data;
	}

	struct ImVector_ImFontPtr {
		int Size;
		int Capacity;
		ImFont** Data;
	}

	struct ImVector_TextRange {
		int Size;
		int Capacity;
		TextRange* Data;
	}

	struct ImVector_ImVec4 {
		int Size;
		int Capacity;
		ImVec4* Data;
	}

	struct ImVector_ImDrawIdx {
		int Size;
		int Capacity;
		ushort* Data;
	}

	struct ImVector_ImVec2 {
		int Size;
		int Capacity;
		ImVec2* Data;
	}

	alias ImDrawCallback = void function(const(ImDrawList)*, const(ImDrawCmd)*);
	enum ImDrawCornerFlags_ {
		ImDrawCornerFlags_TopLeft = 1,
		ImDrawCornerFlags_TopRight = 2,
		ImDrawCornerFlags_BotLeft = 4,
		ImDrawCornerFlags_BotRight = 8,
		ImDrawCornerFlags_Top = 3,
		ImDrawCornerFlags_Bot = 12,
		ImDrawCornerFlags_Left = 5,
		ImDrawCornerFlags_Right = 10,
		ImDrawCornerFlags_All = 15,
	}

	enum ImDrawCornerFlags_TopLeft = ImDrawCornerFlags_.ImDrawCornerFlags_TopLeft;
	enum ImDrawCornerFlags_TopRight = ImDrawCornerFlags_.ImDrawCornerFlags_TopRight;
	enum ImDrawCornerFlags_BotLeft = ImDrawCornerFlags_.ImDrawCornerFlags_BotLeft;
	enum ImDrawCornerFlags_BotRight = ImDrawCornerFlags_.ImDrawCornerFlags_BotRight;
	enum ImDrawCornerFlags_Top = ImDrawCornerFlags_.ImDrawCornerFlags_Top;
	enum ImDrawCornerFlags_Bot = ImDrawCornerFlags_.ImDrawCornerFlags_Bot;
	enum ImDrawCornerFlags_Left = ImDrawCornerFlags_.ImDrawCornerFlags_Left;
	enum ImDrawCornerFlags_Right = ImDrawCornerFlags_.ImDrawCornerFlags_Right;
	enum ImDrawCornerFlags_All = ImDrawCornerFlags_.ImDrawCornerFlags_All;
	enum ImDrawListFlags_ {
		ImDrawListFlags_AntiAliasedLines = 1,
		ImDrawListFlags_AntiAliasedFill = 2,
	}

	enum ImDrawListFlags_AntiAliasedLines = ImDrawListFlags_.ImDrawListFlags_AntiAliasedLines;
	enum ImDrawListFlags_AntiAliasedFill = ImDrawListFlags_.ImDrawListFlags_AntiAliasedFill;
	enum ImFontAtlasFlags_ {
		ImFontAtlasFlags_None = 0,
		ImFontAtlasFlags_NoPowerOfTwoHeight = 1,
		ImFontAtlasFlags_NoMouseCursors = 2,
	}

	enum ImFontAtlasFlags_None = ImFontAtlasFlags_.ImFontAtlasFlags_None;
	enum ImFontAtlasFlags_NoPowerOfTwoHeight = ImFontAtlasFlags_.ImFontAtlasFlags_NoPowerOfTwoHeight;
	enum ImFontAtlasFlags_NoMouseCursors = ImFontAtlasFlags_.ImFontAtlasFlags_NoMouseCursors;
	ImVec2* ImVec2_ImVec2() @nogc nothrow;
	void ImVec2_destroy(ImVec2*) @nogc nothrow;
	ImVec2* ImVec2_ImVec2Float(float, float) @nogc nothrow;
	ImVec4* ImVec4_ImVec4() @nogc nothrow;
	void ImVec4_destroy(ImVec4*) @nogc nothrow;
	ImVec4* ImVec4_ImVec4Float(float, float, float, float) @nogc nothrow;
	ImGuiContext* igCreateContext(ImFontAtlas*) @nogc nothrow;
	void igDestroyContext(ImGuiContext*) @nogc nothrow;
	ImGuiContext* igGetCurrentContext() @nogc nothrow;
	void igSetCurrentContext(ImGuiContext*) @nogc nothrow;
	bool igDebugCheckVersionAndDataLayout(const(char)*, c_ulong, c_ulong, c_ulong, c_ulong, c_ulong) @nogc nothrow;
	ImGuiIO* igGetIO() @nogc nothrow;
	ImGuiStyle* igGetStyle() @nogc nothrow;
	void igNewFrame() @nogc nothrow;
	void igEndFrame() @nogc nothrow;
	void igRender() @nogc nothrow;
	ImDrawData* igGetDrawData() @nogc nothrow;
	void igShowDemoWindow(bool*) @nogc nothrow;
	void igShowMetricsWindow(bool*) @nogc nothrow;
	void igShowStyleEditor(ImGuiStyle*) @nogc nothrow;
	bool igShowStyleSelector(const(char)*) @nogc nothrow;
	void igShowFontSelector(const(char)*) @nogc nothrow;
	void igShowUserGuide() @nogc nothrow;
	const(char)* igGetVersion() @nogc nothrow;
	void igStyleColorsDark(ImGuiStyle*) @nogc nothrow;
	void igStyleColorsClassic(ImGuiStyle*) @nogc nothrow;
	void igStyleColorsLight(ImGuiStyle*) @nogc nothrow;
	bool igBegin(const(char)*, bool*, int) @nogc nothrow;
	void igEnd() @nogc nothrow;
	bool igBeginChild(const(char)*, const(ImVec2), bool, int) @nogc nothrow;
	bool igBeginChildID(uint, const(ImVec2), bool, int) @nogc nothrow;
	void igEndChild() @nogc nothrow;
	bool igIsWindowAppearing() @nogc nothrow;
	bool igIsWindowCollapsed() @nogc nothrow;
	bool igIsWindowFocused(int) @nogc nothrow;
	bool igIsWindowHovered(int) @nogc nothrow;
	ImDrawList* igGetWindowDrawList() @nogc nothrow;
	ImVec2 igGetWindowPos() @nogc nothrow;
	ImVec2 igGetWindowSize() @nogc nothrow;
	float igGetWindowWidth() @nogc nothrow;
	float igGetWindowHeight() @nogc nothrow;
	ImVec2 igGetContentRegionMax() @nogc nothrow;
	ImVec2 igGetContentRegionAvail() @nogc nothrow;
	float igGetContentRegionAvailWidth() @nogc nothrow;
	ImVec2 igGetWindowContentRegionMin() @nogc nothrow;
	ImVec2 igGetWindowContentRegionMax() @nogc nothrow;
	float igGetWindowContentRegionWidth() @nogc nothrow;
	void igSetNextWindowPos(const(ImVec2), int, const(ImVec2)) @nogc nothrow;
	void igSetNextWindowSize(const(ImVec2), int) @nogc nothrow;
	void igSetNextWindowSizeConstraints(const(ImVec2), const(ImVec2), void function(ImGuiSizeCallbackData*), void*) @nogc nothrow;
	void igSetNextWindowContentSize(const(ImVec2)) @nogc nothrow;
	void igSetNextWindowCollapsed(bool, int) @nogc nothrow;
	void igSetNextWindowFocus() @nogc nothrow;
	void igSetNextWindowBgAlpha(float) @nogc nothrow;
	void igSetWindowPosVec2(const(ImVec2), int) @nogc nothrow;
	void igSetWindowSizeVec2(const(ImVec2), int) @nogc nothrow;
	void igSetWindowCollapsedBool(bool, int) @nogc nothrow;
	void igSetWindowFocus() @nogc nothrow;
	void igSetWindowFontScale(float) @nogc nothrow;
	void igSetWindowPosStr(const(char)*, const(ImVec2), int) @nogc nothrow;
	void igSetWindowSizeStr(const(char)*, const(ImVec2), int) @nogc nothrow;
	void igSetWindowCollapsedStr(const(char)*, bool, int) @nogc nothrow;
	void igSetWindowFocusStr(const(char)*) @nogc nothrow;
	float igGetScrollX() @nogc nothrow;
	float igGetScrollY() @nogc nothrow;
	float igGetScrollMaxX() @nogc nothrow;
	float igGetScrollMaxY() @nogc nothrow;
	void igSetScrollX(float) @nogc nothrow;
	void igSetScrollY(float) @nogc nothrow;
	void igSetScrollHereY(float) @nogc nothrow;
	void igSetScrollFromPosY(float, float) @nogc nothrow;
	void igPushFont(ImFont*) @nogc nothrow;
	void igPopFont() @nogc nothrow;
	void igPushStyleColorU32(int, uint) @nogc nothrow;
	void igPushStyleColor(int, const(ImVec4)) @nogc nothrow;
	void igPopStyleColor(int) @nogc nothrow;
	void igPushStyleVarFloat(int, float) @nogc nothrow;
	void igPushStyleVarVec2(int, const(ImVec2)) @nogc nothrow;
	void igPopStyleVar(int) @nogc nothrow;
	const(ImVec4)* igGetStyleColorVec4(int) @nogc nothrow;
	ImFont* igGetFont() @nogc nothrow;
	float igGetFontSize() @nogc nothrow;
	ImVec2 igGetFontTexUvWhitePixel() @nogc nothrow;
	uint igGetColorU32(int, float) @nogc nothrow;
	uint igGetColorU32Vec4(const(ImVec4)) @nogc nothrow;
	uint igGetColorU32U32(uint) @nogc nothrow;
	void igPushItemWidth(float) @nogc nothrow;
	void igPopItemWidth() @nogc nothrow;
	float igCalcItemWidth() @nogc nothrow;
	void igPushTextWrapPos(float) @nogc nothrow;
	void igPopTextWrapPos() @nogc nothrow;
	void igPushAllowKeyboardFocus(bool) @nogc nothrow;
	void igPopAllowKeyboardFocus() @nogc nothrow;
	void igPushButtonRepeat(bool) @nogc nothrow;
	void igPopButtonRepeat() @nogc nothrow;
	void igSeparator() @nogc nothrow;
	void igSameLine(float, float) @nogc nothrow;
	void igNewLine() @nogc nothrow;
	void igSpacing() @nogc nothrow;
	void igDummy(const(ImVec2)) @nogc nothrow;
	void igIndent(float) @nogc nothrow;
	void igUnindent(float) @nogc nothrow;
	void igBeginGroup() @nogc nothrow;
	void igEndGroup() @nogc nothrow;
	ImVec2 igGetCursorPos() @nogc nothrow;
	float igGetCursorPosX() @nogc nothrow;
	float igGetCursorPosY() @nogc nothrow;
	void igSetCursorPos(const(ImVec2)) @nogc nothrow;
	void igSetCursorPosX(float) @nogc nothrow;
	void igSetCursorPosY(float) @nogc nothrow;
	ImVec2 igGetCursorStartPos() @nogc nothrow;
	ImVec2 igGetCursorScreenPos() @nogc nothrow;
	void igSetCursorScreenPos(const(ImVec2)) @nogc nothrow;
	void igAlignTextToFramePadding() @nogc nothrow;
	float igGetTextLineHeight() @nogc nothrow;
	float igGetTextLineHeightWithSpacing() @nogc nothrow;
	float igGetFrameHeight() @nogc nothrow;
	float igGetFrameHeightWithSpacing() @nogc nothrow;
	void igPushIDStr(const(char)*) @nogc nothrow;
	void igPushIDRange(const(char)*, const(char)*) @nogc nothrow;
	void igPushIDPtr(const(void)*) @nogc nothrow;
	void igPushIDInt(int) @nogc nothrow;
	void igPopID() @nogc nothrow;
	uint igGetIDStr(const(char)*) @nogc nothrow;
	uint igGetIDRange(const(char)*, const(char)*) @nogc nothrow;
	uint igGetIDPtr(const(void)*) @nogc nothrow;
	void igTextUnformatted(const(char)*, const(char)*) @nogc nothrow;
	void igText(const(char)*, ...) @nogc nothrow;
	void igTextV(const(char)*, va_list*) @nogc nothrow;
	void igTextColored(const(ImVec4), const(char)*, ...) @nogc nothrow;
	void igTextColoredV(const(ImVec4), const(char)*, va_list*) @nogc nothrow;
	void igTextDisabled(const(char)*, ...) @nogc nothrow;
	void igTextDisabledV(const(char)*, va_list*) @nogc nothrow;
	void igTextWrapped(const(char)*, ...) @nogc nothrow;
	void igTextWrappedV(const(char)*, va_list*) @nogc nothrow;
	void igLabelText(const(char)*, const(char)*, ...) @nogc nothrow;
	void igLabelTextV(const(char)*, const(char)*, va_list*) @nogc nothrow;
	void igBulletText(const(char)*, ...) @nogc nothrow;
	void igBulletTextV(const(char)*, va_list*) @nogc nothrow;
	bool igButton(const(char)*, const(ImVec2)) @nogc nothrow;
	bool igSmallButton(const(char)*) @nogc nothrow;
	bool igInvisibleButton(const(char)*, const(ImVec2)) @nogc nothrow;
	bool igArrowButton(const(char)*, int) @nogc nothrow;
	void igImage(void*, const(ImVec2), const(ImVec2), const(ImVec2), const(ImVec4), const(ImVec4)) @nogc nothrow;
	bool igImageButton(void*, const(ImVec2), const(ImVec2), const(ImVec2), int, const(ImVec4), const(ImVec4)) @nogc nothrow;
	bool igCheckbox(const(char)*, bool*) @nogc nothrow;
	bool igCheckboxFlags(const(char)*, uint*, uint) @nogc nothrow;
	bool igRadioButtonBool(const(char)*, bool) @nogc nothrow;
	bool igRadioButtonIntPtr(const(char)*, int*, int) @nogc nothrow;
	void igProgressBar(float, const(ImVec2), const(char)*) @nogc nothrow;
	void igBullet() @nogc nothrow;
	bool igBeginCombo(const(char)*, const(char)*, int) @nogc nothrow;
	void igEndCombo() @nogc nothrow;
	bool igCombo(const(char)*, int*, const(const(char)*)*, int, int) @nogc nothrow;
	bool igComboStr(const(char)*, int*, const(char)*, int) @nogc nothrow;
	bool igComboFnPtr(const(char)*, int*, bool function(void*, int, const(char)**), void*, int, int) @nogc nothrow;
	bool igDragFloat(const(char)*, float*, float, float, float, const(char)*, float) @nogc nothrow;
	bool igDragFloat2(const(char)*, float*, float, float, float, const(char)*, float) @nogc nothrow;
	bool igDragFloat3(const(char)*, float*, float, float, float, const(char)*, float) @nogc nothrow;
	bool igDragFloat4(const(char)*, float*, float, float, float, const(char)*, float) @nogc nothrow;
	bool igDragFloatRange2(const(char)*, float*, float*, float, float, float, const(char)*, const(char)*, float) @nogc nothrow;
	bool igDragInt(const(char)*, int*, float, int, int, const(char)*) @nogc nothrow;
	bool igDragInt2(const(char)*, int*, float, int, int, const(char)*) @nogc nothrow;
	bool igDragInt3(const(char)*, int*, float, int, int, const(char)*) @nogc nothrow;
	bool igDragInt4(const(char)*, int*, float, int, int, const(char)*) @nogc nothrow;
	bool igDragIntRange2(const(char)*, int*, int*, float, int, int, const(char)*, const(char)*) @nogc nothrow;
	bool igDragScalar(const(char)*, int, void*, float, const(void)*, const(void)*, const(char)*, float) @nogc nothrow;
	bool igDragScalarN(const(char)*, int, void*, int, float, const(void)*, const(void)*, const(char)*, float) @nogc nothrow;
	bool igSliderFloat(const(char)*, float*, float, float, const(char)*, float) @nogc nothrow;
	bool igSliderFloat2(const(char)*, float*, float, float, const(char)*, float) @nogc nothrow;
	bool igSliderFloat3(const(char)*, float*, float, float, const(char)*, float) @nogc nothrow;
	bool igSliderFloat4(const(char)*, float*, float, float, const(char)*, float) @nogc nothrow;
	bool igSliderAngle(const(char)*, float*, float, float, const(char)*) @nogc nothrow;
	bool igSliderInt(const(char)*, int*, int, int, const(char)*) @nogc nothrow;
	bool igSliderInt2(const(char)*, int*, int, int, const(char)*) @nogc nothrow;
	bool igSliderInt3(const(char)*, int*, int, int, const(char)*) @nogc nothrow;
	bool igSliderInt4(const(char)*, int*, int, int, const(char)*) @nogc nothrow;
	bool igSliderScalar(const(char)*, int, void*, const(void)*, const(void)*, const(char)*, float) @nogc nothrow;
	bool igSliderScalarN(const(char)*, int, void*, int, const(void)*, const(void)*, const(char)*, float) @nogc nothrow;
	bool igVSliderFloat(const(char)*, const(ImVec2), float*, float, float, const(char)*, float) @nogc nothrow;
	bool igVSliderInt(const(char)*, const(ImVec2), int*, int, int, const(char)*) @nogc nothrow;
	bool igVSliderScalar(const(char)*, const(ImVec2), int, void*, const(void)*, const(void)*, const(char)*, float) @nogc nothrow;
	bool igInputText(const(char)*, char*, c_ulong, int, int function(ImGuiInputTextCallbackData*), void*) @nogc nothrow;
	bool igInputTextMultiline(const(char)*, char*, c_ulong, const(ImVec2), int, int function(ImGuiInputTextCallbackData*), void*) @nogc nothrow;
	bool igInputFloat(const(char)*, float*, float, float, const(char)*, int) @nogc nothrow;
	bool igInputFloat2(const(char)*, float*, const(char)*, int) @nogc nothrow;
	bool igInputFloat3(const(char)*, float*, const(char)*, int) @nogc nothrow;
	bool igInputFloat4(const(char)*, float*, const(char)*, int) @nogc nothrow;
	bool igInputInt(const(char)*, int*, int, int, int) @nogc nothrow;
	bool igInputInt2(const(char)*, int*, int) @nogc nothrow;
	bool igInputInt3(const(char)*, int*, int) @nogc nothrow;
	bool igInputInt4(const(char)*, int*, int) @nogc nothrow;
	bool igInputDouble(const(char)*, double*, double, double, const(char)*, int) @nogc nothrow;
	bool igInputScalar(const(char)*, int, void*, const(void)*, const(void)*, const(char)*, int) @nogc nothrow;
	bool igInputScalarN(const(char)*, int, void*, int, const(void)*, const(void)*, const(char)*, int) @nogc nothrow;
	bool igColorEdit3(const(char)*, float*, int) @nogc nothrow;
	bool igColorEdit4(const(char)*, float*, int) @nogc nothrow;
	bool igColorPicker3(const(char)*, float*, int) @nogc nothrow;
	bool igColorPicker4(const(char)*, float*, int, const(float)*) @nogc nothrow;
	bool igColorButton(const(char)*, const(ImVec4), int, ImVec2) @nogc nothrow;
	void igSetColorEditOptions(int) @nogc nothrow;
	bool igTreeNodeStr(const(char)*) @nogc nothrow;
	bool igTreeNodeStrStr(const(char)*, const(char)*, ...) @nogc nothrow;
	bool igTreeNodePtr(const(void)*, const(char)*, ...) @nogc nothrow;
	bool igTreeNodeVStr(const(char)*, const(char)*, va_list*) @nogc nothrow;
	bool igTreeNodeVPtr(const(void)*, const(char)*, va_list*) @nogc nothrow;
	bool igTreeNodeExStr(const(char)*, int) @nogc nothrow;
	bool igTreeNodeExStrStr(const(char)*, int, const(char)*, ...) @nogc nothrow;
	bool igTreeNodeExPtr(const(void)*, int, const(char)*, ...) @nogc nothrow;
	bool igTreeNodeExVStr(const(char)*, int, const(char)*, va_list*) @nogc nothrow;
	bool igTreeNodeExVPtr(const(void)*, int, const(char)*, va_list*) @nogc nothrow;
	void igTreePushStr(const(char)*) @nogc nothrow;
	void igTreePushPtr(const(void)*) @nogc nothrow;
	void igTreePop() @nogc nothrow;
	void igTreeAdvanceToLabelPos() @nogc nothrow;
	float igGetTreeNodeToLabelSpacing() @nogc nothrow;
	void igSetNextTreeNodeOpen(bool, int) @nogc nothrow;
	bool igCollapsingHeader(const(char)*, int) @nogc nothrow;
	bool igCollapsingHeaderBoolPtr(const(char)*, bool*, int) @nogc nothrow;
	bool igSelectable(const(char)*, bool, int, const(ImVec2)) @nogc nothrow;
	bool igSelectableBoolPtr(const(char)*, bool*, int, const(ImVec2)) @nogc nothrow;
	bool igListBoxStr_arr(const(char)*, int*, const(const(char)*)*, int, int) @nogc nothrow;
	bool igListBoxFnPtr(const(char)*, int*, bool function(void*, int, const(char)**), void*, int, int) @nogc nothrow;
	bool igListBoxHeaderVec2(const(char)*, const(ImVec2)) @nogc nothrow;
	bool igListBoxHeaderInt(const(char)*, int, int) @nogc nothrow;
	void igListBoxFooter() @nogc nothrow;
	void igPlotLines(const(char)*, const(float)*, int, int, const(char)*, float, float, ImVec2, int) @nogc nothrow;
	void igPlotLinesFnPtr(const(char)*, float function(void*, int), void*, int, int, const(char)*, float, float, ImVec2) @nogc nothrow;
	void igPlotHistogramFloatPtr(const(char)*, const(float)*, int, int, const(char)*, float, float, ImVec2, int) @nogc nothrow;
	void igPlotHistogramFnPtr(const(char)*, float function(void*, int), void*, int, int, const(char)*, float, float, ImVec2) @nogc nothrow;
	void igValueBool(const(char)*, bool) @nogc nothrow;
	void igValueInt(const(char)*, int) @nogc nothrow;
	void igValueUint(const(char)*, uint) @nogc nothrow;
	void igValueFloat(const(char)*, float, const(char)*) @nogc nothrow;
	bool igBeginMainMenuBar() @nogc nothrow;
	void igEndMainMenuBar() @nogc nothrow;
	bool igBeginMenuBar() @nogc nothrow;
	void igEndMenuBar() @nogc nothrow;
	bool igBeginMenu(const(char)*, bool) @nogc nothrow;
	void igEndMenu() @nogc nothrow;
	bool igMenuItemBool(const(char)*, const(char)*, bool, bool) @nogc nothrow;
	bool igMenuItemBoolPtr(const(char)*, const(char)*, bool*, bool) @nogc nothrow;
	void igBeginTooltip() @nogc nothrow;
	void igEndTooltip() @nogc nothrow;
	void igSetTooltip(const(char)*, ...) @nogc nothrow;
	void igSetTooltipV(const(char)*, va_list*) @nogc nothrow;
	void igOpenPopup(const(char)*) @nogc nothrow;
	bool igBeginPopup(const(char)*, int) @nogc nothrow;
	bool igBeginPopupContextItem(const(char)*, int) @nogc nothrow;
	bool igBeginPopupContextWindow(const(char)*, int, bool) @nogc nothrow;
	bool igBeginPopupContextVoid(const(char)*, int) @nogc nothrow;
	bool igBeginPopupModal(const(char)*, bool*, int) @nogc nothrow;
	void igEndPopup() @nogc nothrow;
	bool igOpenPopupOnItemClick(const(char)*, int) @nogc nothrow;
	bool igIsPopupOpen(const(char)*) @nogc nothrow;
	void igCloseCurrentPopup() @nogc nothrow;
	void igColumns(int, const(char)*, bool) @nogc nothrow;
	void igNextColumn() @nogc nothrow;
	int igGetColumnIndex() @nogc nothrow;
	float igGetColumnWidth(int) @nogc nothrow;
	void igSetColumnWidth(int, float) @nogc nothrow;
	float igGetColumnOffset(int) @nogc nothrow;
	void igSetColumnOffset(int, float) @nogc nothrow;
	int igGetColumnsCount() @nogc nothrow;
	void igLogToTTY(int) @nogc nothrow;
	void igLogToFile(int, const(char)*) @nogc nothrow;
	void igLogToClipboard(int) @nogc nothrow;
	void igLogFinish() @nogc nothrow;
	void igLogButtons() @nogc nothrow;
	bool igBeginDragDropSource(int) @nogc nothrow;
	bool igSetDragDropPayload(const(char)*, const(void)*, c_ulong, int) @nogc nothrow;
	void igEndDragDropSource() @nogc nothrow;
	bool igBeginDragDropTarget() @nogc nothrow;
	const(ImGuiPayload)* igAcceptDragDropPayload(const(char)*, int) @nogc nothrow;
	void igEndDragDropTarget() @nogc nothrow;
	const(ImGuiPayload)* igGetDragDropPayload() @nogc nothrow;
	void igPushClipRect(const(ImVec2), const(ImVec2), bool) @nogc nothrow;
	void igPopClipRect() @nogc nothrow;
	void igSetItemDefaultFocus() @nogc nothrow;
	void igSetKeyboardFocusHere(int) @nogc nothrow;
	bool igIsItemHovered(int) @nogc nothrow;
	bool igIsItemActive() @nogc nothrow;
	bool igIsItemFocused() @nogc nothrow;
	bool igIsItemClicked(int) @nogc nothrow;
	bool igIsItemVisible() @nogc nothrow;
	bool igIsItemEdited() @nogc nothrow;
	bool igIsItemDeactivated() @nogc nothrow;
	bool igIsItemDeactivatedAfterEdit() @nogc nothrow;
	bool igIsAnyItemHovered() @nogc nothrow;
	bool igIsAnyItemActive() @nogc nothrow;
	bool igIsAnyItemFocused() @nogc nothrow;
	ImVec2 igGetItemRectMin() @nogc nothrow;
	ImVec2 igGetItemRectMax() @nogc nothrow;
	ImVec2 igGetItemRectSize() @nogc nothrow;
	void igSetItemAllowOverlap() @nogc nothrow;
	bool igIsRectVisible(const(ImVec2)) @nogc nothrow;
	bool igIsRectVisibleVec2(const(ImVec2), const(ImVec2)) @nogc nothrow;
	double igGetTime() @nogc nothrow;
	int igGetFrameCount() @nogc nothrow;
	ImDrawList* igGetOverlayDrawList() @nogc nothrow;
	ImDrawListSharedData* igGetDrawListSharedData() @nogc nothrow;
	const(char)* igGetStyleColorName(int) @nogc nothrow;
	void igSetStateStorage(ImGuiStorage*) @nogc nothrow;
	ImGuiStorage* igGetStateStorage() @nogc nothrow;
	ImVec2 igCalcTextSize(const(char)*, const(char)*, bool, float) @nogc nothrow;
	void igCalcListClipping(int, float, int*, int*) @nogc nothrow;
	bool igBeginChildFrame(uint, const(ImVec2), int) @nogc nothrow;
	void igEndChildFrame() @nogc nothrow;
	ImVec4 igColorConvertU32ToFloat4(uint) @nogc nothrow;
	uint igColorConvertFloat4ToU32(const(ImVec4)) @nogc nothrow;
	int igGetKeyIndex(int) @nogc nothrow;
	bool igIsKeyDown(int) @nogc nothrow;
	bool igIsKeyPressed(int, bool) @nogc nothrow;
	bool igIsKeyReleased(int) @nogc nothrow;
	int igGetKeyPressedAmount(int, float, float) @nogc nothrow;
	bool igIsMouseDown(int) @nogc nothrow;
	bool igIsAnyMouseDown() @nogc nothrow;
	bool igIsMouseClicked(int, bool) @nogc nothrow;
	bool igIsMouseDoubleClicked(int) @nogc nothrow;
	bool igIsMouseReleased(int) @nogc nothrow;
	bool igIsMouseDragging(int, float) @nogc nothrow;
	bool igIsMouseHoveringRect(const(ImVec2), const(ImVec2), bool) @nogc nothrow;
	bool igIsMousePosValid(const(ImVec2)*) @nogc nothrow;
	ImVec2 igGetMousePos() @nogc nothrow;
	ImVec2 igGetMousePosOnOpeningCurrentPopup() @nogc nothrow;
	ImVec2 igGetMouseDragDelta(int, float) @nogc nothrow;
	void igResetMouseDragDelta(int) @nogc nothrow;
	int igGetMouseCursor() @nogc nothrow;
	void igSetMouseCursor(int) @nogc nothrow;
	void igCaptureKeyboardFromApp(bool) @nogc nothrow;
	void igCaptureMouseFromApp(bool) @nogc nothrow;
	const(char)* igGetClipboardText() @nogc nothrow;
	void igSetClipboardText(const(char)*) @nogc nothrow;
	void igLoadIniSettingsFromDisk(const(char)*) @nogc nothrow;
	void igLoadIniSettingsFromMemory(const(char)*, c_ulong) @nogc nothrow;
	void igSaveIniSettingsToDisk(const(char)*) @nogc nothrow;
	const(char)* igSaveIniSettingsToMemory(c_ulong*) @nogc nothrow;
	void igSetAllocatorFunctions(void* function(c_ulong, void*), void function(void*, void*), void*) @nogc nothrow;
	void* igMemAlloc(c_ulong) @nogc nothrow;
	void igMemFree(void*) @nogc nothrow;
	ImGuiStyle* ImGuiStyle_ImGuiStyle() @nogc nothrow;
	void ImGuiStyle_destroy(ImGuiStyle*) @nogc nothrow;
	void ImGuiStyle_ScaleAllSizes(ImGuiStyle*, float) @nogc nothrow;
	void ImGuiIO_AddInputCharacter(ImGuiIO*, ushort) @nogc nothrow;
	void ImGuiIO_AddInputCharactersUTF8(ImGuiIO*, const(char)*) @nogc nothrow;
	void ImGuiIO_ClearInputCharacters(ImGuiIO*) @nogc nothrow;
	ImGuiIO* ImGuiIO_ImGuiIO() @nogc nothrow;
	void ImGuiIO_destroy(ImGuiIO*) @nogc nothrow;
	ImGuiOnceUponAFrame* ImGuiOnceUponAFrame_ImGuiOnceUponAFrame() @nogc nothrow;
	void ImGuiOnceUponAFrame_destroy(ImGuiOnceUponAFrame*) @nogc nothrow;
	ImGuiTextFilter* ImGuiTextFilter_ImGuiTextFilter(const(char)*) @nogc nothrow;
	void ImGuiTextFilter_destroy(ImGuiTextFilter*) @nogc nothrow;
	bool ImGuiTextFilter_Draw(ImGuiTextFilter*, const(char)*, float) @nogc nothrow;
	bool ImGuiTextFilter_PassFilter(ImGuiTextFilter*, const(char)*, const(char)*) @nogc nothrow;
	void ImGuiTextFilter_Build(ImGuiTextFilter*) @nogc nothrow;
	void ImGuiTextFilter_Clear(ImGuiTextFilter*) @nogc nothrow;
	bool ImGuiTextFilter_IsActive(ImGuiTextFilter*) @nogc nothrow;
	TextRange* TextRange_TextRange() @nogc nothrow;
	void TextRange_destroy(TextRange*) @nogc nothrow;
	TextRange* TextRange_TextRangeStr(const(char)*, const(char)*) @nogc nothrow;
	const(char)* TextRange_begin(TextRange*) @nogc nothrow;
	const(char)* TextRange_end(TextRange*) @nogc nothrow;
	bool TextRange_empty(TextRange*) @nogc nothrow;
	void TextRange_split(TextRange*, char, ImVector_TextRange*) @nogc nothrow;
	ImGuiTextBuffer* ImGuiTextBuffer_ImGuiTextBuffer() @nogc nothrow;
	void ImGuiTextBuffer_destroy(ImGuiTextBuffer*) @nogc nothrow;
	const(char)* ImGuiTextBuffer_begin(ImGuiTextBuffer*) @nogc nothrow;
	const(char)* ImGuiTextBuffer_end(ImGuiTextBuffer*) @nogc nothrow;
	int ImGuiTextBuffer_size(ImGuiTextBuffer*) @nogc nothrow;
	bool ImGuiTextBuffer_empty(ImGuiTextBuffer*) @nogc nothrow;
	void ImGuiTextBuffer_clear(ImGuiTextBuffer*) @nogc nothrow;
	void ImGuiTextBuffer_reserve(ImGuiTextBuffer*, int) @nogc nothrow;
	const(char)* ImGuiTextBuffer_c_str(ImGuiTextBuffer*) @nogc nothrow;
	void ImGuiTextBuffer_appendfv(ImGuiTextBuffer*, const(char)*, va_list*) @nogc nothrow;
	Pair* Pair_PairInt(uint, int) @nogc nothrow;
	void Pair_destroy(Pair*) @nogc nothrow;
	Pair* Pair_PairFloat(uint, float) @nogc nothrow;
	Pair* Pair_PairPtr(uint, void*) @nogc nothrow;
	void ImGuiStorage_Clear(ImGuiStorage*) @nogc nothrow;
	int ImGuiStorage_GetInt(ImGuiStorage*, uint, int) @nogc nothrow;
	void ImGuiStorage_SetInt(ImGuiStorage*, uint, int) @nogc nothrow;
	bool ImGuiStorage_GetBool(ImGuiStorage*, uint, bool) @nogc nothrow;
	void ImGuiStorage_SetBool(ImGuiStorage*, uint, bool) @nogc nothrow;
	float ImGuiStorage_GetFloat(ImGuiStorage*, uint, float) @nogc nothrow;
	void ImGuiStorage_SetFloat(ImGuiStorage*, uint, float) @nogc nothrow;
	void* ImGuiStorage_GetVoidPtr(ImGuiStorage*, uint) @nogc nothrow;
	void ImGuiStorage_SetVoidPtr(ImGuiStorage*, uint, void*) @nogc nothrow;
	int* ImGuiStorage_GetIntRef(ImGuiStorage*, uint, int) @nogc nothrow;
	bool* ImGuiStorage_GetBoolRef(ImGuiStorage*, uint, bool) @nogc nothrow;
	float* ImGuiStorage_GetFloatRef(ImGuiStorage*, uint, float) @nogc nothrow;
	void** ImGuiStorage_GetVoidPtrRef(ImGuiStorage*, uint, void*) @nogc nothrow;
	void ImGuiStorage_SetAllInt(ImGuiStorage*, int) @nogc nothrow;
	void ImGuiStorage_BuildSortByKey(ImGuiStorage*) @nogc nothrow;
	ImGuiInputTextCallbackData* ImGuiInputTextCallbackData_ImGuiInputTextCallbackData() @nogc nothrow;
	void ImGuiInputTextCallbackData_destroy(ImGuiInputTextCallbackData*) @nogc nothrow;
	void ImGuiInputTextCallbackData_DeleteChars(ImGuiInputTextCallbackData*, int, int) @nogc nothrow;
	void ImGuiInputTextCallbackData_InsertChars(ImGuiInputTextCallbackData*, int, const(char)*, const(char)*) @nogc nothrow;
	bool ImGuiInputTextCallbackData_HasSelection(ImGuiInputTextCallbackData*) @nogc nothrow;
	ImGuiPayload* ImGuiPayload_ImGuiPayload() @nogc nothrow;
	void ImGuiPayload_destroy(ImGuiPayload*) @nogc nothrow;
	void ImGuiPayload_Clear(ImGuiPayload*) @nogc nothrow;
	bool ImGuiPayload_IsDataType(ImGuiPayload*, const(char)*) @nogc nothrow;
	bool ImGuiPayload_IsPreview(ImGuiPayload*) @nogc nothrow;
	bool ImGuiPayload_IsDelivery(ImGuiPayload*) @nogc nothrow;
	ImColor* ImColor_ImColor() @nogc nothrow;
	void ImColor_destroy(ImColor*) @nogc nothrow;
	ImColor* ImColor_ImColorInt(int, int, int, int) @nogc nothrow;
	ImColor* ImColor_ImColorU32(uint) @nogc nothrow;
	ImColor* ImColor_ImColorFloat(float, float, float, float) @nogc nothrow;
	ImColor* ImColor_ImColorVec4(const(ImVec4)) @nogc nothrow;
	void ImColor_SetHSV(ImColor*, float, float, float, float) @nogc nothrow;
	ImColor ImColor_HSV(ImColor*, float, float, float, float) @nogc nothrow;
	ImGuiListClipper* ImGuiListClipper_ImGuiListClipper(int, float) @nogc nothrow;
	void ImGuiListClipper_destroy(ImGuiListClipper*) @nogc nothrow;
	bool ImGuiListClipper_Step(ImGuiListClipper*) @nogc nothrow;
	void ImGuiListClipper_Begin(ImGuiListClipper*, int, float) @nogc nothrow;
	void ImGuiListClipper_End(ImGuiListClipper*) @nogc nothrow;
	ImDrawCmd* ImDrawCmd_ImDrawCmd() @nogc nothrow;
	void ImDrawCmd_destroy(ImDrawCmd*) @nogc nothrow;
	ImDrawList* ImDrawList_ImDrawList(const(ImDrawListSharedData)*) @nogc nothrow;
	void ImDrawList_destroy(ImDrawList*) @nogc nothrow;
	void ImDrawList_PushClipRect(ImDrawList*, ImVec2, ImVec2, bool) @nogc nothrow;
	void ImDrawList_PushClipRectFullScreen(ImDrawList*) @nogc nothrow;
	void ImDrawList_PopClipRect(ImDrawList*) @nogc nothrow;
	void ImDrawList_PushTextureID(ImDrawList*, void*) @nogc nothrow;
	void ImDrawList_PopTextureID(ImDrawList*) @nogc nothrow;
	ImVec2 ImDrawList_GetClipRectMin(ImDrawList*) @nogc nothrow;
	ImVec2 ImDrawList_GetClipRectMax(ImDrawList*) @nogc nothrow;
	void ImDrawList_AddLine(ImDrawList*, const(ImVec2), const(ImVec2), uint, float) @nogc nothrow;
	void ImDrawList_AddRect(ImDrawList*, const(ImVec2), const(ImVec2), uint, float, int, float) @nogc nothrow;
	void ImDrawList_AddRectFilled(ImDrawList*, const(ImVec2), const(ImVec2), uint, float, int) @nogc nothrow;
	void ImDrawList_AddRectFilledMultiColor(ImDrawList*, const(ImVec2), const(ImVec2), uint, uint, uint, uint) @nogc nothrow;
	void ImDrawList_AddQuad(ImDrawList*, const(ImVec2), const(ImVec2), const(ImVec2), const(ImVec2), uint, float) @nogc nothrow;
	void ImDrawList_AddQuadFilled(ImDrawList*, const(ImVec2), const(ImVec2), const(ImVec2), const(ImVec2), uint) @nogc nothrow;
	void ImDrawList_AddTriangle(ImDrawList*, const(ImVec2), const(ImVec2), const(ImVec2), uint, float) @nogc nothrow;
	void ImDrawList_AddTriangleFilled(ImDrawList*, const(ImVec2), const(ImVec2), const(ImVec2), uint) @nogc nothrow;
	void ImDrawList_AddCircle(ImDrawList*, const(ImVec2), float, uint, int, float) @nogc nothrow;
	void ImDrawList_AddCircleFilled(ImDrawList*, const(ImVec2), float, uint, int) @nogc nothrow;
	void ImDrawList_AddText(ImDrawList*, const(ImVec2), uint, const(char)*, const(char)*) @nogc nothrow;
	void ImDrawList_AddTextFontPtr(ImDrawList*, const(ImFont)*, float, const(ImVec2), uint, const(char)*, const(char)*,
			float, const(ImVec4)*) @nogc nothrow;
	void ImDrawList_AddImage(ImDrawList*, void*, const(ImVec2), const(ImVec2), const(ImVec2), const(ImVec2), uint) @nogc nothrow;
	void ImDrawList_AddImageQuad(ImDrawList*, void*, const(ImVec2), const(ImVec2), const(ImVec2), const(ImVec2),
			const(ImVec2), const(ImVec2), const(ImVec2), const(ImVec2), uint) @nogc nothrow;
	void ImDrawList_AddImageRounded(ImDrawList*, void*, const(ImVec2), const(ImVec2), const(ImVec2), const(ImVec2), uint, float, int) @nogc nothrow;
	void ImDrawList_AddPolyline(ImDrawList*, const(ImVec2)*, const(int), uint, bool, float) @nogc nothrow;
	void ImDrawList_AddConvexPolyFilled(ImDrawList*, const(ImVec2)*, const(int), uint) @nogc nothrow;
	void ImDrawList_AddBezierCurve(ImDrawList*, const(ImVec2), const(ImVec2), const(ImVec2), const(ImVec2), uint, float, int) @nogc nothrow;
	void ImDrawList_PathClear(ImDrawList*) @nogc nothrow;
	void ImDrawList_PathLineTo(ImDrawList*, const(ImVec2)) @nogc nothrow;
	void ImDrawList_PathLineToMergeDuplicate(ImDrawList*, const(ImVec2)) @nogc nothrow;
	void ImDrawList_PathFillConvex(ImDrawList*, uint) @nogc nothrow;
	void ImDrawList_PathStroke(ImDrawList*, uint, bool, float) @nogc nothrow;
	void ImDrawList_PathArcTo(ImDrawList*, const(ImVec2), float, float, float, int) @nogc nothrow;
	void ImDrawList_PathArcToFast(ImDrawList*, const(ImVec2), float, int, int) @nogc nothrow;
	void ImDrawList_PathBezierCurveTo(ImDrawList*, const(ImVec2), const(ImVec2), const(ImVec2), int) @nogc nothrow;
	void ImDrawList_PathRect(ImDrawList*, const(ImVec2), const(ImVec2), float, int) @nogc nothrow;
	void ImDrawList_ChannelsSplit(ImDrawList*, int) @nogc nothrow;
	void ImDrawList_ChannelsMerge(ImDrawList*) @nogc nothrow;
	void ImDrawList_ChannelsSetCurrent(ImDrawList*, int) @nogc nothrow;
	void ImDrawList_AddCallback(ImDrawList*, void function(const(ImDrawList)*, const(ImDrawCmd)*), void*) @nogc nothrow;
	void ImDrawList_AddDrawCmd(ImDrawList*) @nogc nothrow;
	ImDrawList* ImDrawList_CloneOutput(ImDrawList*) @nogc nothrow;
	void ImDrawList_Clear(ImDrawList*) @nogc nothrow;
	void ImDrawList_ClearFreeMemory(ImDrawList*) @nogc nothrow;
	void ImDrawList_PrimReserve(ImDrawList*, int, int) @nogc nothrow;
	void ImDrawList_PrimRect(ImDrawList*, const(ImVec2), const(ImVec2), uint) @nogc nothrow;
	void ImDrawList_PrimRectUV(ImDrawList*, const(ImVec2), const(ImVec2), const(ImVec2), const(ImVec2), uint) @nogc nothrow;
	void ImDrawList_PrimQuadUV(ImDrawList*, const(ImVec2), const(ImVec2), const(ImVec2), const(ImVec2), const(ImVec2),
			const(ImVec2), const(ImVec2), const(ImVec2), uint) @nogc nothrow;
	void ImDrawList_PrimWriteVtx(ImDrawList*, const(ImVec2), const(ImVec2), uint) @nogc nothrow;
	void ImDrawList_PrimWriteIdx(ImDrawList*, ushort) @nogc nothrow;
	void ImDrawList_PrimVtx(ImDrawList*, const(ImVec2), const(ImVec2), uint) @nogc nothrow;
	void ImDrawList_UpdateClipRect(ImDrawList*) @nogc nothrow;
	void ImDrawList_UpdateTextureID(ImDrawList*) @nogc nothrow;
	ImDrawData* ImDrawData_ImDrawData() @nogc nothrow;
	void ImDrawData_destroy(ImDrawData*) @nogc nothrow;
	void ImDrawData_Clear(ImDrawData*) @nogc nothrow;
	void ImDrawData_DeIndexAllBuffers(ImDrawData*) @nogc nothrow;
	void ImDrawData_ScaleClipRects(ImDrawData*, const(ImVec2)) @nogc nothrow;
	ImFontConfig* ImFontConfig_ImFontConfig() @nogc nothrow;
	void ImFontConfig_destroy(ImFontConfig*) @nogc nothrow;
	ImFontAtlas* ImFontAtlas_ImFontAtlas() @nogc nothrow;
	void ImFontAtlas_destroy(ImFontAtlas*) @nogc nothrow;
	ImFont* ImFontAtlas_AddFont(ImFontAtlas*, const(ImFontConfig)*) @nogc nothrow;
	ImFont* ImFontAtlas_AddFontDefault(ImFontAtlas*, const(ImFontConfig)*) @nogc nothrow;
	ImFont* ImFontAtlas_AddFontFromFileTTF(ImFontAtlas*, const(char)*, float, const(ImFontConfig)*, const(ushort)*) @nogc nothrow;
	ImFont* ImFontAtlas_AddFontFromMemoryTTF(ImFontAtlas*, void*, int, float, const(ImFontConfig)*, const(ushort)*) @nogc nothrow;
	ImFont* ImFontAtlas_AddFontFromMemoryCompressedTTF(ImFontAtlas*, const(void)*, int, float, const(ImFontConfig)*, const(ushort)*) @nogc nothrow;
	ImFont* ImFontAtlas_AddFontFromMemoryCompressedBase85TTF(ImFontAtlas*, const(char)*, float, const(ImFontConfig)*, const(ushort)*) @nogc nothrow;
	void ImFontAtlas_ClearInputData(ImFontAtlas*) @nogc nothrow;
	void ImFontAtlas_ClearTexData(ImFontAtlas*) @nogc nothrow;
	void ImFontAtlas_ClearFonts(ImFontAtlas*) @nogc nothrow;
	void ImFontAtlas_Clear(ImFontAtlas*) @nogc nothrow;
	bool ImFontAtlas_Build(ImFontAtlas*) @nogc nothrow;
	bool ImFontAtlas_IsBuilt(ImFontAtlas*) @nogc nothrow;
	void ImFontAtlas_GetTexDataAsAlpha8(ImFontAtlas*, ubyte**, int*, int*, int*) @nogc nothrow;
	void ImFontAtlas_GetTexDataAsRGBA32(ImFontAtlas*, ubyte**, int*, int*, int*) @nogc nothrow;
	void ImFontAtlas_SetTexID(ImFontAtlas*, void*) @nogc nothrow;
	const(ushort)* ImFontAtlas_GetGlyphRangesDefault(ImFontAtlas*) @nogc nothrow;
	const(ushort)* ImFontAtlas_GetGlyphRangesKorean(ImFontAtlas*) @nogc nothrow;
	const(ushort)* ImFontAtlas_GetGlyphRangesJapanese(ImFontAtlas*) @nogc nothrow;
	const(ushort)* ImFontAtlas_GetGlyphRangesChineseFull(ImFontAtlas*) @nogc nothrow;
	const(ushort)* ImFontAtlas_GetGlyphRangesChineseSimplifiedCommon(ImFontAtlas*) @nogc nothrow;
	const(ushort)* ImFontAtlas_GetGlyphRangesCyrillic(ImFontAtlas*) @nogc nothrow;
	const(ushort)* ImFontAtlas_GetGlyphRangesThai(ImFontAtlas*) @nogc nothrow;
	GlyphRangesBuilder* GlyphRangesBuilder_GlyphRangesBuilder() @nogc nothrow;
	void GlyphRangesBuilder_destroy(GlyphRangesBuilder*) @nogc nothrow;
	bool GlyphRangesBuilder_GetBit(GlyphRangesBuilder*, int) @nogc nothrow;
	void GlyphRangesBuilder_SetBit(GlyphRangesBuilder*, int) @nogc nothrow;
	void GlyphRangesBuilder_AddChar(GlyphRangesBuilder*, ushort) @nogc nothrow;
	void GlyphRangesBuilder_AddText(GlyphRangesBuilder*, const(char)*, const(char)*) @nogc nothrow;
	void GlyphRangesBuilder_AddRanges(GlyphRangesBuilder*, const(ushort)*) @nogc nothrow;
	void GlyphRangesBuilder_BuildRanges(GlyphRangesBuilder*, ImVector_ImWchar*) @nogc nothrow;
	CustomRect* CustomRect_CustomRect() @nogc nothrow;
	void CustomRect_destroy(CustomRect*) @nogc nothrow;
	bool CustomRect_IsPacked(CustomRect*) @nogc nothrow;
	int ImFontAtlas_AddCustomRectRegular(ImFontAtlas*, uint, int, int) @nogc nothrow;
	int ImFontAtlas_AddCustomRectFontGlyph(ImFontAtlas*, ImFont*, ushort, int, int, float, const(ImVec2)) @nogc nothrow;
	const(CustomRect)* ImFontAtlas_GetCustomRectByIndex(ImFontAtlas*, int) @nogc nothrow;
	void ImFontAtlas_CalcCustomRectUV(ImFontAtlas*, const(CustomRect)*, ImVec2*, ImVec2*) @nogc nothrow;
	bool ImFontAtlas_GetMouseCursorTexData(ImFontAtlas*, int, ImVec2*, ImVec2*, ImVec2*, ImVec2*) @nogc nothrow;
	ImFont* ImFont_ImFont() @nogc nothrow;
	void ImFont_destroy(ImFont*) @nogc nothrow;
	void ImFont_ClearOutputData(ImFont*) @nogc nothrow;
	void ImFont_BuildLookupTable(ImFont*) @nogc nothrow;
	const(ImFontGlyph)* ImFont_FindGlyph(ImFont*, ushort) @nogc nothrow;
	const(ImFontGlyph)* ImFont_FindGlyphNoFallback(ImFont*, ushort) @nogc nothrow;
	void ImFont_SetFallbackChar(ImFont*, ushort) @nogc nothrow;
	float ImFont_GetCharAdvance(ImFont*, ushort) @nogc nothrow;
	bool ImFont_IsLoaded(ImFont*) @nogc nothrow;
	const(char)* ImFont_GetDebugName(ImFont*) @nogc nothrow;
	ImVec2 ImFont_CalcTextSizeA(ImFont*, float, float, float, const(char)*, const(char)*, const(char)**) @nogc nothrow;
	const(char)* ImFont_CalcWordWrapPositionA(ImFont*, float, const(char)*, const(char)*, float) @nogc nothrow;
	void ImFont_RenderChar(ImFont*, ImDrawList*, float, ImVec2, uint, ushort) @nogc nothrow;
	void ImFont_RenderText(ImFont*, ImDrawList*, float, ImVec2, uint, const(ImVec4), const(char)*, const(char)*, float, bool) @nogc nothrow;
	void ImFont_GrowIndex(ImFont*, int) @nogc nothrow;
	void ImFont_AddGlyph(ImFont*, ushort, float, float, float, float, float, float, float, float, float) @nogc nothrow;
	void ImFont_AddRemapChar(ImFont*, ushort, ushort, bool) @nogc nothrow;
	void igGetWindowPos_nonUDT(ImVec2*) @nogc nothrow;
	ImVec2_Simple igGetWindowPos_nonUDT2() @nogc nothrow;
	void igGetWindowSize_nonUDT(ImVec2*) @nogc nothrow;
	ImVec2_Simple igGetWindowSize_nonUDT2() @nogc nothrow;
	void igGetContentRegionMax_nonUDT(ImVec2*) @nogc nothrow;
	ImVec2_Simple igGetContentRegionMax_nonUDT2() @nogc nothrow;
	void igGetContentRegionAvail_nonUDT(ImVec2*) @nogc nothrow;
	ImVec2_Simple igGetContentRegionAvail_nonUDT2() @nogc nothrow;
	void igGetWindowContentRegionMin_nonUDT(ImVec2*) @nogc nothrow;
	ImVec2_Simple igGetWindowContentRegionMin_nonUDT2() @nogc nothrow;
	void igGetWindowContentRegionMax_nonUDT(ImVec2*) @nogc nothrow;
	ImVec2_Simple igGetWindowContentRegionMax_nonUDT2() @nogc nothrow;
	void igGetFontTexUvWhitePixel_nonUDT(ImVec2*) @nogc nothrow;
	ImVec2_Simple igGetFontTexUvWhitePixel_nonUDT2() @nogc nothrow;
	void igGetCursorPos_nonUDT(ImVec2*) @nogc nothrow;
	ImVec2_Simple igGetCursorPos_nonUDT2() @nogc nothrow;
	void igGetCursorStartPos_nonUDT(ImVec2*) @nogc nothrow;
	ImVec2_Simple igGetCursorStartPos_nonUDT2() @nogc nothrow;
	void igGetCursorScreenPos_nonUDT(ImVec2*) @nogc nothrow;
	ImVec2_Simple igGetCursorScreenPos_nonUDT2() @nogc nothrow;
	void igGetItemRectMin_nonUDT(ImVec2*) @nogc nothrow;
	ImVec2_Simple igGetItemRectMin_nonUDT2() @nogc nothrow;
	void igGetItemRectMax_nonUDT(ImVec2*) @nogc nothrow;
	ImVec2_Simple igGetItemRectMax_nonUDT2() @nogc nothrow;
	void igGetItemRectSize_nonUDT(ImVec2*) @nogc nothrow;
	ImVec2_Simple igGetItemRectSize_nonUDT2() @nogc nothrow;
	void igCalcTextSize_nonUDT(ImVec2*, const(char)*, const(char)*, bool, float) @nogc nothrow;
	ImVec2_Simple igCalcTextSize_nonUDT2(const(char)*, const(char)*, bool, float) @nogc nothrow;
	void igColorConvertU32ToFloat4_nonUDT(ImVec4*, uint) @nogc nothrow;
	ImVec4_Simple igColorConvertU32ToFloat4_nonUDT2(uint) @nogc nothrow;
	void igGetMousePos_nonUDT(ImVec2*) @nogc nothrow;
	ImVec2_Simple igGetMousePos_nonUDT2() @nogc nothrow;
	void igGetMousePosOnOpeningCurrentPopup_nonUDT(ImVec2*) @nogc nothrow;
	ImVec2_Simple igGetMousePosOnOpeningCurrentPopup_nonUDT2() @nogc nothrow;
	void igGetMouseDragDelta_nonUDT(ImVec2*, int, float) @nogc nothrow;
	ImVec2_Simple igGetMouseDragDelta_nonUDT2(int, float) @nogc nothrow;
	void ImColor_HSV_nonUDT(ImColor*, ImColor*, float, float, float, float) @nogc nothrow;
	ImColor_Simple ImColor_HSV_nonUDT2(ImColor*, float, float, float, float) @nogc nothrow;
	void ImDrawList_GetClipRectMin_nonUDT(ImVec2*, ImDrawList*) @nogc nothrow;
	ImVec2_Simple ImDrawList_GetClipRectMin_nonUDT2(ImDrawList*) @nogc nothrow;
	void ImDrawList_GetClipRectMax_nonUDT(ImVec2*, ImDrawList*) @nogc nothrow;
	ImVec2_Simple ImDrawList_GetClipRectMax_nonUDT2(ImDrawList*) @nogc nothrow;
	void ImFont_CalcTextSizeA_nonUDT(ImVec2*, ImFont*, float, float, float, const(char)*, const(char)*, const(char)**) @nogc nothrow;
	ImVec2_Simple ImFont_CalcTextSizeA_nonUDT2(ImFont*, float, float, float, const(char)*, const(char)*, const(char)**) @nogc nothrow;
	void igLogText(const(char)*, ...) @nogc nothrow;
	void ImGuiTextBuffer_appendf(ImGuiTextBuffer*, const(char)*, ...) @nogc nothrow;
	float igGET_FLT_MAX() @nogc nothrow;
	void igColorConvertRGBtoHSV(float, float, float, float*, float*, float*) @nogc nothrow;
	void igColorConvertHSVtoRGB(float, float, float, float*, float*, float*) @nogc nothrow;
	ImVector_ImWchar* ImVector_ImWchar_create() @nogc nothrow;
	void ImVector_ImWchar_destroy(ImVector_ImWchar*) @nogc nothrow;
	void ImVector_ImWchar_Init(ImVector_ImWchar*) @nogc nothrow;
	void ImVector_ImWchar_UnInit(ImVector_ImWchar*) @nogc nothrow;
}
