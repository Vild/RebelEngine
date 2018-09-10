module rebel.renderer.types.commandbuffer;

import rebel.renderer.types;
import dlsl.vector;

interface ICommandBufferRecordingState {
	@property void renderPass(RenderPass renderPass);
	@property void pipeline(Pipeline pipeline);
	@property void framebuffer(Framebuffer framebuffer);
	@property void renderArea(uvec4 renderArea);
	@property void clearColors(vec4[] clearColors);

	void finalizeState();

	void draw(uint vertexCount, uint instanceCount, uint firstVertex, uint firstInstance);
}

alias CommandBufferCreateCallback = void delegate(ICommandBufferRecordingState recordingState);

struct CommandBufferBuilder {
	CommandBufferCreateCallback callback;
	bool willChangeEachFrame;
}

struct CommandBufferData {
}

alias CommandBuffer = Handle!(CommandBufferData, 1024);
