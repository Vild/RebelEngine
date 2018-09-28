module rebel.renderer.types.vertex;

import rebel.renderer.types;

import dlsl.vector;
import dlsl.matrix;

enum DataRate {
	vertex,
	instance
}

struct ShaderData(T_, ImageFormat Format_) {
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

static struct ShaderInputInfo(T) {
	static VertexInputBindingDescription getBindingDescription(uint binding) {
		import std.traits : getUDAs;

		VertexInputBindingDescription bindingDescription;
		DataRate dataRate = getUDAs!(T, DataRate)[0];

		bindingDescription.binding = binding;
		bindingDescription.stride = T.sizeof;
		bindingDescription.inputRate = dataRate; // == DataRate.vertex ? VK_VERTEX_INPUT_RATE_VERTEX : VK_VERTEX_INPUT_RATE_INSTANCE;

		return bindingDescription;
	}

	static VertexInputAttributeDescription[] getAttributeDescriptions(uint binding) {
		static VertexInputAttributeDescription[[__traits(allMembers, T)].length] attributeDescriptions;
		static bool created;
		if (created)
			return attributeDescriptions;

		size_t idx;
		uint location;
		static foreach (member; __traits(allMembers, T)) {
			{
				import std.traits;
				import std.meta;

				alias TData = Alias!(mixin("T." ~ member ~ ".T"));
				static if (isVector!TData) {
					enum channels = TData.dimension;
					enum count = 1;
				} else static if (isMatrix!TData) {
					enum channels = TData.cols;
					enum count = TData.rows;
				} else static if (isFloatingPoint!TData) {
					enum channels = 1;
					enum count = 1;
				}

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
