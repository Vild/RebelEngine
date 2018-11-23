module rebel.renderer.types.image;

import rebel.renderer.types;
import gfm.math.vector;

struct ImageBuilder {
	string name;
	ImageTemplate imageTemplate;
}

struct ImageData {
	/*ImageFormat format;
	ImageLayout layout;*/
}

alias Image = Handle!(ImageData, 1024);
