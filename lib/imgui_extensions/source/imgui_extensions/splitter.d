module imgui_extensions.splitter;

import imgui_extensions;

void igDrawSplitter(bool split_vertically, float thickness, float* size0, float* size1, float min_size0, float min_size1, float offset = 0) {
	ImVec2 backup_pos;
	igGetCursorPos(&backup_pos);
	if (split_vertically)
		igSetCursorPosY(backup_pos.y + *size0 + offset);
	else
		igSetCursorPosX(backup_pos.x + *size0 + offset);

	igPushStyleColor(ImGuiCol_Button, ImVec4(0, 0, 0, 0));
	igPushStyleColor(ImGuiCol_ButtonActive, ImVec4(0, 0, 0, 0)); // We don't draw while active/pressed because as we move the panes the splitter button will be 1 frame late
	igPushStyleColor(ImGuiCol_ButtonHovered, ImVec4(0.6f, 0.6f, 0.6f, 0.10f));
	igPushIdPtr(size0);
	igButton("##Splitter", ImVec2(!split_vertically ? thickness : -1.0f, split_vertically ? thickness : -1.0f));
	igPopId();
	igPopStyleColor(3);

	igSetItemAllowOverlap(); // This is to allow having other buttons OVER our splitter.

	auto io = igGetIO();
	if (igIsItemActive() && io.MousePos != ImVec2(-1, -1)) {
		float mouse_delta = split_vertically ? io.MouseDelta.y : io.MouseDelta.x;

		// Minimum pane size
		if (mouse_delta < min_size0 - *size0)
			mouse_delta = min_size0 - *size0;
		if (mouse_delta > *size1 - min_size1)
			mouse_delta = *size1 - min_size1;

		// Apply resize
		*size0 += mouse_delta;
		*size1 -= mouse_delta;
	}
	igSetCursorPos(backup_pos);
}
