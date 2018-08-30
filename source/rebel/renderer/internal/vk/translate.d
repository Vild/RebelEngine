module rebel.renderer.internal.vk.translate;

import rebel.renderer;
import erupted;

VkFormat translate(ImageFormat format) {
	final switch (format) {
	case ImageFormat.undefined:
		return VkFormat.VK_FORMAT_UNDEFINED;
	case ImageFormat.rgb888:
		return VkFormat.VK_FORMAT_R8G8B8_SNORM;
	case ImageFormat.rgba8888:
		return VkFormat.VK_FORMAT_R8G8B8A8_SNORM;
	case ImageFormat.rgba16f:
		return VkFormat.VK_FORMAT_R16G16B16A16_SFLOAT;
	case ImageFormat.rgba32f:
		return VkFormat.VK_FORMAT_R32G32B32A32_SFLOAT;
	}
}

VkImageLayout translate(ImageLayout layout) {
	final switch (layout) {
	case ImageLayout.undefined:
		return VkImageLayout.VK_IMAGE_LAYOUT_UNDEFINED;
	case ImageLayout.color:
		return VkImageLayout.VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL;
	case ImageLayout.present:
		return VkImageLayout.VK_IMAGE_LAYOUT_PRESENT_SRC_KHR;
	case ImageLayout.depthStencil:
		return VkImageLayout.VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL;
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
	case ShaderType.vertext:
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
