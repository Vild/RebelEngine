module rebel.renderer.types.framebuffer;

import rebel.renderer.types;
import gfm.math.vector;

struct FramebufferBuilder {
	string name;
	RenderPass renderPass;
	Image[] attachments;
	vec3ui dimension;
}

struct FramebufferData {
	vec3ui dimension;
}

alias Framebuffer = Handle!(FramebufferData, 64);
