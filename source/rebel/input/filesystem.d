module rebel.input.filesystem;

import physfs;

class FSFile {
public:
	@disable this();

	~this() {
		PHYSFS_close(_file);
	}

	ptrdiff_t read(T)(T[] output) {
		return PHYSFS_readBytes(_file, &output[0], T.sizeof * cast(uint)output.length);
	}

	ptrdiff_t write(T)(T[] output) {
		return PHYSFS_writeBytes(_file, &output[0], T.sizeof * cast(uint)output.length);
	}

	@property size_t position() {
		return PHYSFS_tell(_file);
	}

	@property position(size_t pos) {
		return PHYSFS_seek(_file, pos);
	}

	@property size_t length() {
		return PHYSFS_fileLength(_file);
	}

	@property bool eof() {
		return !!PHYSFS_eof(_file);
	}

private:
	string _path;
	FileMode _mode;
	PHYSFS_File* _file;

	this(string path, FileMode mode, PHYSFS_File* file) {
		_path = path;
		_mode = mode;
		_file = file;
		if (!file) {
			import std.stdio : stderr;
			import std.string : fromStringz;

			PHYSFS_ErrorCode err = PHYSFS_getLastErrorCode();
			stderr.writeln("\x1b[33;1mFile error, Path: ", path, "\tMode:", mode, "\t: (", err, ")\n", PHYSFS_getErrorByCode(err).fromStringz, "\x1b[0m");
			throw new Exception("");
		}
	}
}

enum FileMode {
	read,
	write,
	append
}

class FileSystem {
public:
	this() {
		import core.runtime : Runtime;
		import std.file : DirEntry, dirEntries, SpanMode, mkdirRecurse;
		import std.path : dirName;
		import std.algorithm : filter;
		import std.string : toStringz;

		PHYSFS_init(Runtime.cArgs.argv[0]);

		foreach (DirEntry e; dirEntries("assets", SpanMode.shallow).filter!(f => f.isDir))
			PHYSFS_mount(e.name.toStringz, null, 0);

		mkdirRecurse(dirName(Runtime.args[0]) ~ "/assets");

		PHYSFS_mount("bin/assets/", null, 0);
		PHYSFS_setWriteDir("bin/assets/");
	}

	~this() {
		PHYSFS_deinit();
	}

	void tree() {

		extern (C) PHYSFS_EnumerateCallbackResult printDir(void* userdata, const char* origdir, const char* fname) {
			import std.stdio : write, writeln;
			import std.string : fromStringz, toStringz;

			size_t* indent = cast(size_t*)userdata;

			foreach (_; 0 .. *indent)
				write("  ");
			write("→ ");
			if (origdir[1] != '\0')
				write(origdir.fromStringz);
			write("/");
			writeln(fname.fromStringz);

			if (PHYSFS_isDirectory(fname)) {
				(*indent)++;
				PHYSFS_enumerate((origdir.fromStringz ~ fname.fromStringz).toStringz, &printDir, userdata);
				(*indent)--;
			}
			return PHYSFS_EnumerateCallbackResult.PHYSFS_ENUM_OK;
		}
		// ...
		size_t indent = 1;
		PHYSFS_enumerate("/", &printDir, &indent);
	}

	FSFile open(string path, FileMode mode) {
		import std.string : toStringz;
		import std.path : dirName;

		scope (failure)
			return null;

		final switch (mode) {
		case FileMode.read:
			return new FSFile(path, mode, PHYSFS_openRead(path.toStringz));
		case FileMode.write:
			PHYSFS_mkdir(dirName(path).toStringz);
			return new FSFile(path, mode, PHYSFS_openWrite(path.toStringz));
		case FileMode.append:
			PHYSFS_mkdir(dirName(path).toStringz);
			return new FSFile(path, mode, PHYSFS_openAppend(path.toStringz));
		}
	}
}
