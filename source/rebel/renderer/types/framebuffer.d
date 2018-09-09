module rebel.renderer.types.framebuffer;

import rebel.renderer.types;
import dlsl.vector;

struct FramebufferBuilder {
	RenderPass renderPass;
	Image[] attachments;
	uvec3 dimension;
}

struct FramebufferData {
}

alias Framebuffer = Handle!(FramebufferData, 64);
