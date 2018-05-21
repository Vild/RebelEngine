module rebel.input.filesystem;

import derelict.physfs.physfs;

shared static this() {
	DerelictPHYSFS.load();
}

class FSFile {
public:
	@disable this();

	~this() {
		PHYSFS_close(_file);
	}

	ptrdiff_t read(T)(T[] output) {
		return PHYSFS_read(_file, &output[0], T.sizeof, cast(uint)output.length);
	}

	ptrdiff_t write(T)(T[] output) {
		return PHYSFS_write(_file, &output[0], T.sizeof, cast(uint)output.length);
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
	PHYSFS_File* _file;
	bool _owner;

	this(PHYSFS_File* file) {
		_file = file;
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

	FSFile open(string path, FileMode mode) {
		import std.string : toStringz;
		import std.path : dirName;

		final switch (mode) {
		case FileMode.read:
			return new FSFile(PHYSFS_openRead(path.toStringz));
		case FileMode.write:
			PHYSFS_mkdir(dirName(path).toStringz);
			return new FSFile(PHYSFS_openWrite(path.toStringz));
		case FileMode.append:
			PHYSFS_mkdir(dirName(path).toStringz);
			return new FSFile(PHYSFS_openAppend(path.toStringz));
		}
	}
}
