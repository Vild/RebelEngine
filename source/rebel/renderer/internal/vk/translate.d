module rebel.renderer.internal.vk.translate;

import erupted;

import rebel.renderer.types;

VkFormat translate(ImageFormat format) {
	final switch (format) {
	case ImageFormat.undefined:
		return VkFormat.VK_FORMAT_UNDEFINED;
	case ImageFormat.rg8_unorm:
		return VkFormat.VK_FORMAT_R8G8_UNORM;
	case ImageFormat.rg32_float:
		return VkFormat.VK_FORMAT_R32G32_SFLOAT;
	case ImageFormat.rgb8_unorm:
		return VkFormat.VK_FORMAT_R8G8B8_UNORM;
	case ImageFormat.rgb32_float:
		return VkFormat.VK_FORMAT_R32G32B32_SFLOAT;
	case ImageFormat.rgba8_unorm:
		return VkFormat.VK_FORMAT_R8G8B8A8_UNORM;
	case ImageFormat.rgba16_float:
		return VkFormat.VK_FORMAT_R16G16B16A16_SFLOAT;
	case ImageFormat.rgba32_float:
		return VkFormat.VK_FORMAT_R32G32B32A32_SFLOAT;

	case ImageFormat.bgr8_unorm:
		return VkFormat.VK_FORMAT_B8G8R8_UNORM;
	case ImageFormat.bgra8_unorm:
		return VkFormat.VK_FORMAT_B8G8R8A8_UNORM;

	case ImageFormat.a2r10g10b10_float:
	return VkFormat.VK_FORMAT_A2R10G10B10_UNORM_PACK32;
	}
}

VkVertexInputRate translate(DataRate dr) {
	final switch (dr) {
	case DataRate.vertex:
		return VK_VERTEX_INPUT_RATE_VERTEX;
	case DataRate.instance:
		return VK_VERTEX_INPUT_RATE_INSTANCE;
	}
}

ImageFormat translate(VkFormat format) {
	switch (format) {
	case VkFormat.VK_FORMAT_UNDEFINED:
		return ImageFormat.undefined;
	case VkFormat.VK_FORMAT_R8G8B8_UNORM:
		return ImageFormat.rgb8_unorm;
	case VkFormat.VK_FORMAT_R8G8B8A8_UNORM:
		return ImageFormat.rgba8_unorm;
	case VkFormat.VK_FORMAT_R16G16B16A16_SFLOAT:
		return ImageFormat.rgba16_float;
	case VkFormat.VK_FORMAT_R32G32B32A32_SFLOAT:
		return ImageFormat.rgba32_float;

	case VkFormat.VK_FORMAT_B8G8R8_UNORM:
		return ImageFormat.bgr8_unorm;
	case VkFormat.VK_FORMAT_B8G8R8A8_UNORM:
		return ImageFormat.bgra8_unorm;
	default:
		import std.format : f = format;

		assert(0, f!"Unknown format: %s"(format));
	}
}

VkImageLayout translate(ImageLayout layout) {
	final switch (layout) {
	case ImageLayout.undefined:
		return VkImageLayout.VK_IMAGE_LAYOUT_UNDEFINED;
	case ImageLayout.color:
		return VkImageLayout.VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL;
	case ImageLayout.colorReadOnly:
		return VkImageLayout.VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL | VkImageLayout.VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL;
	case ImageLayout.present:
		return VkImageLayout.VK_IMAGE_LAYOUT_PRESENT_SRC_KHR;
	case ImageLayout.depthStencil:
		return VkImageLayout.VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL;
	case ImageLayout.depthStencilReadOnly:
		return VkImageLayout.VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL | VkImageLayout.VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL;
	}
}

VkAttachmentLoadOp translate(LoadOperation op) {
	final switch (op) {
	case LoadOperation.load:
		return VkAttachmentLoadOp.VK_ATTACHMENT_LOAD_OP_LOAD;
	case LoadOperation.clear:
		return VkAttachmentLoadOp.VK_ATTACHMENT_LOAD_OP_CLEAR;
	case LoadOperation.dontCare:
		return VkAttachmentLoadOp.VK_ATTACHMENT_LOAD_OP_DONT_CARE;
	}
}

VkAttachmentStoreOp translate(StoreOperation op) {
	final switch (op) {
	case StoreOperation.store:
		return VkAttachmentStoreOp.VK_ATTACHMENT_STORE_OP_STORE;
	case StoreOperation.dontCare:
		return VkAttachmentStoreOp.VK_ATTACHMENT_STORE_OP_DONT_CARE;
	}
}

VkPipelineBindPoint translate(SubpassBindPoint op) {
	final switch (op) {
	case SubpassBindPoint.graphics:
		return VkPipelineBindPoint.VK_PIPELINE_BIND_POINT_GRAPHICS;
	}
}

VkPipelineStageFlags translate(StageFlags sf) {
	final switch (sf) {
	case StageFlags.colorOutput:
		return VkPipelineStageFlagBits.VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT;
	}
}

VkAccessFlags translate(AccessMask am) {
	final switch (am) {
	case AccessMask.none:
		return 0;
	case AccessMask.read:
		return VkAccessFlagBits.VK_ACCESS_COLOR_ATTACHMENT_READ_BIT;
	case AccessMask.write:
		return VkAccessFlagBits.VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT;
	case AccessMask.readwrite:
		return VkAccessFlagBits.VK_ACCESS_COLOR_ATTACHMENT_READ_BIT | VkAccessFlagBits.VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT;
	}
}

VkShaderStageFlagBits translate(ShaderType st) {
	final switch (st) {
	case ShaderType.vertex:
		return VkShaderStageFlagBits.VK_SHADER_STAGE_VERTEX_BIT;
	case ShaderType.fragment:
		return VkShaderStageFlagBits.VK_SHADER_STAGE_FRAGMENT_BIT;
	}
}

VkPrimitiveTopology translate(VertexTopology vt) {
	final switch (vt) {
	case VertexTopology.triangleList:
		return VkPrimitiveTopology.VK_PRIMITIVE_TOPOLOGY_TRIANGLE_LIST;
	}
}

VkPolygonMode translate(PolygonMode pm) {
	final switch (pm) {
	case PolygonMode.fill:
		return VkPolygonMode.VK_POLYGON_MODE_FILL;
	case PolygonMode.line:
		return VkPolygonMode.VK_POLYGON_MODE_LINE;
	case PolygonMode.point:
		return VkPolygonMode.VK_POLYGON_MODE_POINT;
	}
}

VkCullModeFlagBits translate(CullMode cm) {
	final switch (cm) {
	case CullMode.none:
		return VkCullModeFlagBits.VK_CULL_MODE_NONE;
	case CullMode.front:
		return VkCullModeFlagBits.VK_CULL_MODE_FRONT_BIT;
	case CullMode.back:
		return VkCullModeFlagBits.VK_CULL_MODE_BACK_BIT;
	case CullMode.frontAndBack:
		return VkCullModeFlagBits.VK_CULL_MODE_FRONT_AND_BACK;
	}
}

VkFrontFace translate(FrontFaceMode ffm) {
	final switch (ffm) {
	case FrontFaceMode.clockwise:
		return VkFrontFace.VK_FRONT_FACE_CLOCKWISE;
	case FrontFaceMode.counterClockwise:
		return VkFrontFace.VK_FRONT_FACE_COUNTER_CLOCKWISE;
	}
}

VkSampleCountFlagBits translate(SampleCount cm) {
	final switch (cm) {
	case SampleCount.Sample1:
		return VkSampleCountFlagBits.VK_SAMPLE_COUNT_1_BIT;
	case SampleCount.Sample2:
		return VkSampleCountFlagBits.VK_SAMPLE_COUNT_2_BIT;
	case SampleCount.Sample4:
		return VkSampleCountFlagBits.VK_SAMPLE_COUNT_4_BIT;
	case SampleCount.Sample8:
		return VkSampleCountFlagBits.VK_SAMPLE_COUNT_8_BIT;
	case SampleCount.Sample16:
		return VkSampleCountFlagBits.VK_SAMPLE_COUNT_16_BIT;
	case SampleCount.Sample32:
		return VkSampleCountFlagBits.VK_SAMPLE_COUNT_32_BIT;
	case SampleCount.Sample64:
		return VkSampleCountFlagBits.VK_SAMPLE_COUNT_64_BIT;
	}
}

VkColorComponentFlagBits translate(ColorComponent cp) {
	VkColorComponentFlagBits output;

	if (cp & ColorComponent.r)
		output |= VkColorComponentFlagBits.VK_COLOR_COMPONENT_R_BIT;
	if (cp & ColorComponent.g)
		output |= VkColorComponentFlagBits.VK_COLOR_COMPONENT_G_BIT;
	if (cp & ColorComponent.b)
		output |= VkColorComponentFlagBits.VK_COLOR_COMPONENT_B_BIT;
	if (cp & ColorComponent.a)
		output |= VkColorComponentFlagBits.VK_COLOR_COMPONENT_A_BIT;

	return output;
}

VkLogicOp translate(LogicOp lo) {
	final switch (lo) {
	case LogicOp.copy:
		return VkLogicOp.VK_LOGIC_OP_COPY;
	}
}

VkImageUsageFlags translate(ImageUsage iu) {
	final switch (iu) {
	case ImageUsage.presentAttachment:
		return VkImageUsageFlagBits.VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT;
	case ImageUsage.colorAttachment:
		return VkImageUsageFlagBits.VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT;
	case ImageUsage.depthAttachment:
		return VkImageUsageFlagBits.VK_IMAGE_USAGE_DEPTH_STENCIL_ATTACHMENT_BIT;
	case ImageUsage.depthStencilAttachment:
		return VkImageUsageFlagBits.VK_IMAGE_USAGE_DEPTH_STENCIL_ATTACHMENT_BIT;
	}
}

VkBufferUsageFlags translate(BufferUsage bu) {
	VkBufferUsageFlags output;

	if (bu & BufferUsage.vertex)
		output |= VkBufferUsageFlagBits.VK_BUFFER_USAGE_VERTEX_BUFFER_BIT;

	return output;
}

VkSharingMode translate(BufferSharing bs) {
	final switch (bs) {
	case BufferSharing.exclusive:
		return VK_SHARING_MODE_EXCLUSIVE;
	case BufferSharing.concurrent:
		return VK_SHARING_MODE_CONCURRENT;
	}
}
