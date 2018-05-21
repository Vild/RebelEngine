module rebel.renderer.glrenderer;

import rebel.view;
import rebel.renderer;
import rebel.config;

import dlsl.vector;

import opengl.gl4;
import opengl.loader;

import derelict.sdl2.sdl;

interface IOpenGLView : IView {
	@property bool vsync() const;
	@property void vsync(bool enabled);
}

interface IOpenGLRenderer : IRenderer {
	@property ivec2 glVersion() const;
}

final class GLRenderer : IOpenGLRenderer {
public:
	this(string gameName, Version gameVersion) {
		_gameName = gameName;
		_gameVersion = gameVersion;
	}

	void initialize(IView view_) {
		IOpenGLView view = cast(IOpenGLView)view_;
		assert(view);

		loadGL!(opengl.gl4);

		glEnable(GL_DEBUG_OUTPUT);
		glEnable(GL_DEBUG_OUTPUT_SYNCHRONOUS);
		glDebugMessageCallback(cast(GLDEBUGPROC)&glDebugLog, null);
		glDebugMessageControl(GL_DONT_CARE, GL_DONT_CARE, GL_DONT_CARE, 0, null, GL_TRUE);
	}

	void newFrame() {
		glClearColor(0, 34.0f / 255, 34.0f / 255, 1);
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	}

	void finalize() {
	}

	@property RendererType renderType() const {
		return RendererType.opengl;
	}

	@property ivec2 glVersion() const {
		return ivec2(4, 5);
	}

private:
	string _gameName;
	Version _gameVersion;
	IVulkanView _view;

	static extern(C) void glDebugLog(GLenum source, GLenum type, GLuint id, GLenum severity, GLsizei /*length*/ , const GLchar* message, const void*  /*userParam*/ ) {
		if (id == 4 || id == 8 || id == 11 || id == 20 || id == 36 || id == 37 || id == 48 || id == 1282 || id == 131169
				|| id == 131185 || id == 131218 || id == 131204)
			return;

		if (severity == GL_DEBUG_SEVERITY_NOTIFICATION)
			return;

		string sourceStr = "!UNKNOWN!";
		if (source == GL_DEBUG_SOURCE_API)
			sourceStr = "API";
		else if (source == GL_DEBUG_SOURCE_WINDOW_SYSTEM)
			sourceStr = "WINDOW_SYSTEM";
		else if (source == GL_DEBUG_SOURCE_SHADER_COMPILER)
			sourceStr = "SHADER_COMPILER";
		else if (source == GL_DEBUG_SOURCE_THIRD_PARTY)
			sourceStr = "THIRD_PARTY";
		else if (source == GL_DEBUG_SOURCE_APPLICATION)
			sourceStr = "APPLICATION";
		else if (source == GL_DEBUG_SOURCE_OTHER)
			sourceStr = "OTHER";

		string typeStr = "!UNKNOWN!";

		if (type == GL_DEBUG_TYPE_ERROR)
			typeStr = "ERROR";
		else if (type == GL_DEBUG_TYPE_DEPRECATED_BEHAVIOR)
			typeStr = "DEPRECATED_BEHAVIOR";
		else if (type == GL_DEBUG_TYPE_UNDEFINED_BEHAVIOR)
			typeStr = "UNDEFINED_BEHAVIOR";
		else if (type == GL_DEBUG_TYPE_PORTABILITY)
			typeStr = "PORTABILITY";
		else if (type == GL_DEBUG_TYPE_PERFORMANCE)
			typeStr = "PERFORMANCE";
		else if (type == GL_DEBUG_TYPE_MARKER)
			typeStr = "MARKER";
		else if (type == GL_DEBUG_TYPE_PUSH_GROUP)
			typeStr = "PUSH_GROUP";
		else if (type == GL_DEBUG_TYPE_POP_GROUP)
			typeStr = "POP_GROUP";
		else if (type == GL_DEBUG_TYPE_OTHER)
			typeStr = "OTHER";

		string severityStr = "!UNKNOWN!";

		enum LogLevel {
			error,
			warning,
			normal,
			verbose
		}

		LogLevel level;

		if (severity == GL_DEBUG_SEVERITY_HIGH) {
			severityStr = "HIGH";
			level = LogLevel.error;
		} else if (severity == GL_DEBUG_SEVERITY_MEDIUM) {
			severityStr = "MEDIUM";
			level = LogLevel.warning;
		} else if (severity == GL_DEBUG_SEVERITY_LOW) {
			severityStr = "LOW";
			level = LogLevel.normal;
		} else if (severity == GL_DEBUG_SEVERITY_NOTIFICATION) {
			severityStr = "NOTIFICATION";
			level = LogLevel.verbose;
		}

		string stackTrace = ""; //Hydra::Ext::getStackTrace();

		import std.stdio : writefln;
		import std.string : fromStringz;

		writefln("[%s] GL error: Source %s, Type: %s, ID: %d, Severity: %s\n%s%s%s", level, sourceStr,
				typeStr, id, severityStr, message.fromStringz, stackTrace.length ? "\n" : "", stackTrace);
	}
}
