module rebel.renderer.types.shader;

import rebel.renderer.types;

import gfm.math.vector;
import gfm.math.matrix;

enum VertexDataRate {
	vertex,
	instance
}

struct VertexShaderData(T_, ImageFormat Format_) {
	alias T = T_;
	alias Format = Format_;

	T data;
	alias data this;

	this(T data) {
		this.data = data;
	}

	this(Args...)(auto ref Args args) {
		import std.conv : emplace;

		emplace(&data, args);
	}
}

static struct VertexShaderInputInfo(T) {
	static VertexInputBindingDescription getVertexBindingDescription(uint binding) {
		import std.traits : getUDAs;

		VertexInputBindingDescription bindingDescription;
		VertexDataRate VertexDataRate = getUDAs!(T, VertexDataRate)[0];

		bindingDescription.binding = binding;
		bindingDescription.stride = T.sizeof;
		bindingDescription.inputRate = VertexDataRate; // == VertexDataRate.vertex ? VK_VERTEX_INPUT_RATE_VERTEX : VK_VERTEX_INPUT_RATE_INSTANCE;

		return bindingDescription;
	}

	static VertexInputAttributeDescription[] getVertexAttributeDescriptions(uint binding) {
		import std.traits;
		import std.meta;

		template isVariable(string member) {
			enum isVariable = __traits(compiles, mixin("T." ~ member ~ ".T"));
		}

		alias members = Filter!(isVariable, __traits(allMembers, T));
		static VertexInputAttributeDescription[[members].length] attributeDescriptions;
		static bool created;
		if (created)
			return attributeDescriptions;

		size_t idx;
		uint location;
		static foreach (member; members) {
			{
				alias TData = Alias!(mixin("T." ~ member ~ ".T"));

				//pragma(msg, TData);
				static if (isVector!TData) {
					enum channels = TData.init.v.length;
					enum count = 1;
				} else static if (isMatrixInstantiation!TData) {
					enum channels = TData.init.column_t.v.length;
					enum count = TData.init.row_t.v.length;
				} else static if (isFloatingPoint!TData) {
					enum channels = 1;
					enum count = 1;
				} else
					assert(0, "Unknown type");

				//pragma(msg, "\tchannels: ", channels);
				//pragma(msg, "\tcount: ", count);

				for (size_t i; i < count; i++) {
					attributeDescriptions[idx].binding = binding;
					attributeDescriptions[idx].location = location;
					attributeDescriptions[idx].format = mixin("T." ~ member).Format;
					attributeDescriptions[idx].offset = mixin("T." ~ member).offsetof;
					idx++;
					location += (channels * mixin("T." ~ member).Format.getBitsPerChannel + 127) / 128;
				}
			}
		}

		created = true;
		return attributeDescriptions[];
	}
}

static struct ShaderInputInfo(T) {
	static DescriptorSetLayoutBinding getDescriptorSetLayoutBinding(uint binding, ShaderStages stages) {
		DescriptorSetLayoutBinding layoutBinding;
		layoutBinding.binding = binding;
		layoutBinding.descriptorType = DescriptorType.uniformBuffer;
		layoutBinding.descriptorCount = 1;
		layoutBinding.stages = stages;
		layoutBinding.immutableSamplers = null;
		return layoutBinding;
	}

	static DescriptorBufferInfo getDescriptorBufferInfo(Buffer buffer, uint binding) {
		DescriptorBufferInfo info;
		info.buffer = buffer;
		info.offset = 0;
		info.range = T.sizeof;

		info.writeDescriptorSet.binding = binding;
		info.writeDescriptorSet.arrayElement = 0;
		info.writeDescriptorSet.descriptorCount = 1;
		info.writeDescriptorSet.descriptorType = DescriptorType.uniformBuffer;
		return info;
	}
}
