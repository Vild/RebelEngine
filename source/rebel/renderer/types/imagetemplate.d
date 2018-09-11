module rebel.renderer.types.imagetemplate;

import rebel.renderer.types;
import dlsl.vector;

enum ImageFormat {
	undefined,
	rgb8_unorm,
	rgba8_unorm,
	rgba16_float,
	rgba32_float,

	bgr8_unorm,
	bgra8_unorm,
}

enum ImageUsage {
	/*transferSrc,
	transferDst,
	sampled,
	storage,*/
	presentAttachment,
	colorAttachment,
	depthAttachment,
	depthStencilAttachment, //transientAttachment,
	//inputAttachment
}

enum ImageLayout {
	undefined,
	color, // colorAttachment
	colorReadOnly, // colorAttachment + readonly
	depthStencil, // depth(Stencil)Attachment
	depthStencilReadOnly, // depth(Stencil)Attachment + readonly
	//transferSrc, // transferSrc
	//transferDst, // transferDst
	present, // presentAttachment
}

struct ImageTemplateBuilder {
	string name;
	ImageFormat format;
	ImageUsage usage;
	uvec2 size;
	ubyte samples = 1;
	bool readOnly;
}

struct ImageTemplateData {
	ImageFormat format;
	ImageUsage usage;
	ImageLayout layout;
	uvec2 size;
	ubyte samples = 1;
	bool readOnly;
}

alias ImageTemplate = Handle!(ImageTemplateData, 256);
