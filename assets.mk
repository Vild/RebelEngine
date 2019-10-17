
.PHONY: all base

all: base

BASE_DIR := assets/base/vktest
IMGUI_DIR := assets/base/imgui

base: $(BASE_DIR)/base.vert.spv $(BASE_DIR)/base.frag.spv $(IMGUI_DIR)/base.vert.spv $(IMGUI_DIR)/base.frag.spv
base: $(BASE_DIR)/testTexture.jpg

$(BASE_DIR)/testTexture.jpg:
	@echo -e "\x1b[36mDownload $@...\x1b[0m"
	@wget -q -O $@ https://definewild.se/public/testTexture.jpg

%.vert.spv: %.vert
	@echo -e "\x1b[36mCompiling $@...\x1b[0m"
	@glslangValidator $< -V110 -e main -S vert -o $@

%.frag.spv: %.frag
	@echo -e "\x1b[36mCompiling $@...\x1b[0m"
	@glslangValidator $< -V110 -e main -S frag -o $@
