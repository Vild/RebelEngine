module external.imgui.imguidock;

import derelict.imgui.imgui;

extern (C) @nogc nothrow {
	enum ImGuiDockSlot {
		ImGuiDockSlot_Left = 0,
		ImGuiDockSlot_Right,
		ImGuiDockSlot_Top,
		ImGuiDockSlot_Bottom,
		ImGuiDockSlot_Tab,

		ImGuiDockSlot_Float,
		ImGuiDockSlot_None
	}

	struct ImGuiDockContext;
	alias da_igCreateDockContext = ImGuiDockContext* function();
	alias da_igDestroyDockContext = void function(ImGuiDockContext* dock);
	alias da_igSetCurrentDockContext = void function(ImGuiDockContext* dock);
	alias da_igGetCurrentDockContext = ImGuiDockContext* function();
	alias da_igBeginDockspace = void function();
	alias da_igEndDockspace = void function();
	alias da_igShutdownDock = void function();
	alias da_igSetNextDock = void function(ImGuiDockSlot slot);
	alias da_igBeginDock = bool function(const char* label, bool* opened, ImGuiWindowFlags extra_flags,
			const ImVec2 default_size, const ImVec2 default_pos);
	alias da_igEndDock = void function();
	alias da_igSetDockActive = void function();
	alias da_igDockDebugWindow = void function();
}

__gshared {
	da_igCreateDockContext igCreateDockContext;
	da_igDestroyDockContext igDestroyDockContext;
	da_igSetCurrentDockContext igSetCurrentDockContext;
	da_igGetCurrentDockContext igGetCurrentDockContext;
	da_igBeginDockspace igBeginDockspace;
	da_igEndDockspace igEndDockspace;
	da_igShutdownDock igShutdownDock;
	da_igSetNextDock igSetNextDock;
	da_igBeginDock igBeginDock;
	da_igEndDock igEndDock;
	da_igSetDockActive igSetDockActive;
	da_igDockDebugWindow igDockDebugWindow;
}
