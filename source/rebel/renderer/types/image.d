module rebel.renderer.types.image;

import rebel.renderer.types;
import dlsl.vector;

struct ImageBuilder {
	ImageTemplate imageTemplate;
}

struct ImageData {
	/*ImageFormat format;
	ImageLayout layout;*/
}

alias Image = Handle!(ImageData, 1024);
