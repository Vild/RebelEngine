module rebel.renderer.types.imagetemplate;

import rebel.renderer.types;
import gfm.math.vector;

// TODO: Rename to better generic format name
enum ImageFormat {
	undefined,

	rg8_unorm,
	rg32_float,

	rgb8_unorm,
	rgb32_float,

	rgba8_unorm,
	rgba16_float,
	rgba32_float,

	bgr8_unorm,
	bgra8_unorm,

	a2r10g10b10_float, // HDR

	d32_sfloat,
	d32_s8_sfloat,
	d24_s8_unorm
}

//TODO: move!!
size_t getBitsPerChannel(ImageFormat f) {
	final switch (f) {
	case ImageFormat.undefined:
		return 0; //TODO: Add assert(0)?

	case ImageFormat.rg8_unorm:
	case ImageFormat.rgb8_unorm:
	case ImageFormat.rgba8_unorm:
	case ImageFormat.bgr8_unorm:
	case ImageFormat.bgra8_unorm:
		return 8;
	case ImageFormat.rgba16_float:
		return 16;
	case ImageFormat.rg32_float:
	case ImageFormat.rgb32_float:
	case ImageFormat.rgba32_float:
	case ImageFormat.a2r10g10b10_float:
	case ImageFormat.d32_sfloat:
	case ImageFormat.d24_s8_unorm:
		return 32;
	case ImageFormat.d32_s8_sfloat:
		return 40;
	}
}

enum ImageUsage {
	/*transferSrc,*/
	transferDst,
	/*sampled,
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
	transferDst, // transferDst
	present, // presentAttachment
}

struct ImageTemplateBuilder {
	string name;
	ImageFormat format;
	ImageUsage usage;
	vec2ui size;
	ubyte samples = 1;
	bool readOnly;
}

struct ImageTemplateData {
	ImageFormat format;
	ImageUsage usage;
	ImageLayout layout;
	vec2ui size;
	ubyte samples = 1;
	bool readOnly;
}

alias ImageTemplate = Handle!(ImageTemplateData, 256);
