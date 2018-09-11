module rebel.renderer.types.renderpass;

import rebel.renderer.types;

enum LoadOperation {
	load,
	clear,
	dontCare,
}

enum StoreOperation {
	store,
	dontCare
}

struct Attachment {
	ImageTemplate imageTemplate;
	LoadOperation loadOp;
	StoreOperation storeOp;
	LoadOperation stencilLoadOp;
	StoreOperation stencilStoreOp;
	ImageLayout initialLayout;
	ImageLayout finalLayout;
}

struct SubpassAttachment {
	// RenderPass will use the attachment to get the ID out of the renderpass attachments array
	Attachment* attachment;
	ImageLayout layout;
}

enum SubpassBindPoint {
	graphics // not implemented: compute
}

struct Subpass {
	SubpassBindPoint bindPoint;
	SubpassAttachment[] colorOutput;
	SubpassAttachment[] depthStencilOutput;
}

enum Subpass* externalSubpass = null;
enum StageFlags {
	colorOutput
}

enum AccessMask {
	none,
	read = 1 << 0,
	write = 1 << 1,
	readwrite = read | write
}

struct SubpassDependency {
	Subpass* srcSubpass;
	Subpass* dstSubpass;
	StageFlags srcStageMask;
	StageFlags dstStageMask;
	AccessMask srcAccessMask;
	AccessMask dstAccessMask;
}

struct RenderPassBuilder {
	string name;

	Attachment*[] attachments;

	Subpass*[] subpasses;
	SubpassDependency[] dependencies;
}

struct RenderPassData {
}

alias RenderPass = Handle!(RenderPassData, 64);
