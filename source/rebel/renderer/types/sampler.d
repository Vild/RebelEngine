module rebel.renderer.types.sampler;

import rebel.renderer.types;

struct SamplerBuilder {
	string name;
}

struct SamplerData {
}

alias Sampler = Handle!(SamplerData, 64);

DescriptorSetLayoutBinding getDescriptorSetLayoutBinding(Sampler sampler, uint binding, ShaderStages stages) {
	DescriptorSetLayoutBinding layoutBinding;
	layoutBinding.binding = binding;
	layoutBinding.descriptorType = DescriptorType.combinedImageSampler;
	layoutBinding.descriptorCount = 1;
	layoutBinding.stages = stages;
	layoutBinding.immutableSamplers = null;
	return layoutBinding;
}

DescriptorImageInfo getDescriptorBufferInfo(Image image, Sampler sampler, uint binding) {
	DescriptorImageInfo info;
	info.image = image;
	info.sampler = sampler;

	info.writeDescriptorSet.binding = binding;
	info.writeDescriptorSet.arrayElement = 0;
	info.writeDescriptorSet.descriptorCount = 1;
	info.writeDescriptorSet.descriptorType = DescriptorType.combinedImageSampler;
	return info;
}
