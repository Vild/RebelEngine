module rebel.renderer.types.commandbuffer;

import rebel.renderer.types;
import gfm.math.vector;

interface IRecordingSectionScope {
	void defineSubsection(string name, vec4f color);
}

struct BufferOffset {
	Buffer buffer;
	size_t offset;
}

enum IndexType {
	u16,
	u32
}

import std.variant : Algebraic;

alias ClearColorValue = vec4f;
struct ClearDepthValue {
	float depth;
	int stencil;
}

alias ClearValue = Algebraic!(ClearColorValue, ClearDepthValue);

interface ICommandBufferRecordingState {
	@property void index(size_t index);
	@property void renderPass(RenderPass renderPass);
	@property void pipeline(Pipeline pipeline);
	@property void framebuffer(Framebuffer framebuffer);
	@property void renderArea(vec4ui renderArea);
	@property void clearColors(ClearValue[] clearColors);

	void finalizeState();

	scope IRecordingSectionScope defineSectionScope(string name, vec4f color);

	void bindVertexBuffer(uint firstBinding, BufferOffset[] buffers);
	void bindIndexBuffer(BufferOffset buffer, IndexType type);
	void draw(uint vertexCount, uint instanceCount, uint firstVertex, uint firstInstance);
	void drawIndexed(uint indexCount, uint instanceCount, uint firstIndex, uint vertexOffset, uint firstInstance);

	void pushConstants(ShaderStages stage, uint offset, void[] values);
	void setScissor(uint offset, vec4ui[] scissors);
}

alias CommandBufferCreateCallback = void delegate(ICommandBufferRecordingState recordingState);

struct CommandBufferBuilder {
	string name;
	CommandBufferCreateCallback callback;
	bool willChangeEachFrame;
}

struct CommandBufferData {
	void delegate() rebuild;
}

alias CommandBuffer = Handle!(CommandBufferData, 1024);
