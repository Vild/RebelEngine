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

	void[]delegate(void[] outputBuffer) getData;
	void delegate(void[] data) setData;
}

alias Image = Handle!(ImageData, 1024);
