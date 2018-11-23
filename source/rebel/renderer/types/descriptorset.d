module rebel.renderer.types.descriptorset;

import rebel.renderer.types;
import gfm.math.vector;

struct DescriptorSetBuilder {
	string name;
	Pipeline pipeline;
}

struct DescriptorSetData {
}

alias DescriptorSet = Handle!(DescriptorSetData, 1024);
