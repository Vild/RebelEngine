module physfs;

import core.stdc.config;
import core.stdc.stdarg : va_list;

extern (C) {
	alias PHYSFS_uint8 = ubyte;
	alias PHYSFS_sint8 = byte;
	alias PHYSFS_uint16 = ushort;
	alias PHYSFS_sint16 = short;
	alias PHYSFS_uint32 = uint;
	alias PHYSFS_sint32 = int;
	alias PHYSFS_uint64 = ulong;
	alias PHYSFS_sint64 = long;

	struct PHYSFS_File {
		void* opaque;
	}

	struct PHYSFS_ArchiveInfo {
		const(char)* extension;
		const(char)* description;
		const(char)* author;
		const(char)* url;
		int supportsSymlinks;
	}

	struct PHYSFS_Version {
		PHYSFS_uint8 major;
		PHYSFS_uint8 minor;
		PHYSFS_uint8 patch;
	}

	enum PHYSFS_VER_MAJOR = 3;
	enum PHYSFS_VER_MINOR = 0;
	enum PHYSFS_VER_PATCH = 2;

	void PHYSFS_VERSION(ref PHYSFS_Version x) {
		x.major = PHYSFS_VER_MAJOR;
		x.minor = PHYSFS_VER_MINOR;
		x.patch = PHYSFS_VER_PATCH;
	}

	void PHYSFS_getLinkedVersion(PHYSFS_Version* ver);

	int PHYSFS_init(const(char)* argv0);

	int PHYSFS_deinit();

	const(PHYSFS_ArchiveInfo)** PHYSFS_supportedArchiveTypes();

	void PHYSFS_freeList(void* listVar);

	deprecated const(char)* PHYSFS_getLastError();

	const(char)* PHYSFS_getDirSeparator();

	void PHYSFS_permitSymbolicLinks(int allow);

	char** PHYSFS_getCdRomDirs();

	const(char)* PHYSFS_getBaseDir();

	deprecated const(char)* PHYSFS_getUserDir();

	const(char)* PHYSFS_getWriteDir();

	int PHYSFS_setWriteDir(const(char)* newDir);

	deprecated int PHYSFS_addToSearchPath(const(char)* newDir, int appendToPath);
	deprecated int PHYSFS_removeFromSearchPath(const(char)* oldDir);
	char** PHYSFS_getSearchPath();

	int PHYSFS_setSaneConfig(const(char)* organization, const(char)* appName, const(char)* archiveExt, int includeCdRoms, int archivesFirst);
	int PHYSFS_mkdir(const(char)* dirName);

	int PHYSFS_delete(const(char)* filename);

	const(char)* PHYSFS_getRealDir(const(char)* filename);

	char** PHYSFS_enumerateFiles(const(char)* dir);

	int PHYSFS_exists(const(char)* fname);

	deprecated int PHYSFS_isDirectory(const(char)* fname);

	deprecated int PHYSFS_isSymbolicLink(const(char)* fname);

	deprecated PHYSFS_sint64 PHYSFS_getLastModTime(const(char)* filename);

	PHYSFS_File* PHYSFS_openWrite(const(char)* filename);
	PHYSFS_File* PHYSFS_openAppend(const(char)* filename);
	PHYSFS_File* PHYSFS_openRead(const(char)* filename);
	int PHYSFS_close(PHYSFS_File* handle);

	deprecated PHYSFS_sint64 PHYSFS_read(PHYSFS_File* handle, void* buffer, PHYSFS_uint32 objSize, PHYSFS_uint32 objCount);
	deprecated PHYSFS_sint64 PHYSFS_write(PHYSFS_File* handle, const void* buffer, PHYSFS_uint32 objSize, PHYSFS_uint32 objCount);

	int PHYSFS_eof(PHYSFS_File* handle);
	PHYSFS_sint64 PHYSFS_tell(PHYSFS_File* handle);
	int PHYSFS_seek(PHYSFS_File* handle, PHYSFS_uint64 pos);
	PHYSFS_sint64 PHYSFS_fileLength(PHYSFS_File* handle);
	int PHYSFS_setBuffer(PHYSFS_File* handle, PHYSFS_uint64 bufsize);
	int PHYSFS_flush(PHYSFS_File* handle);
	PHYSFS_sint16 PHYSFS_swapSLE16(PHYSFS_sint16 val);
	PHYSFS_uint16 PHYSFS_swapULE16(PHYSFS_uint16 val);
	PHYSFS_sint32 PHYSFS_swapSLE32(PHYSFS_sint32 val);
	PHYSFS_uint32 PHYSFS_swapULE32(PHYSFS_uint32 val);
	PHYSFS_sint64 PHYSFS_swapSLE64(PHYSFS_sint64 val);

	PHYSFS_uint64 PHYSFS_swapULE64(PHYSFS_uint64 val);
	PHYSFS_sint16 PHYSFS_swapSBE16(PHYSFS_sint16 val);
	PHYSFS_uint16 PHYSFS_swapUBE16(PHYSFS_uint16 val);
	PHYSFS_sint32 PHYSFS_swapSBE32(PHYSFS_sint32 val);
	PHYSFS_uint32 PHYSFS_swapUBE32(PHYSFS_uint32 val);
	PHYSFS_sint64 PHYSFS_swapSBE64(PHYSFS_sint64 val);
	PHYSFS_uint64 PHYSFS_swapUBE64(PHYSFS_uint64 val);
	int PHYSFS_readSLE16(PHYSFS_File* file, PHYSFS_sint16* val);
	int PHYSFS_readULE16(PHYSFS_File* file, PHYSFS_uint16* val);
	int PHYSFS_readSBE16(PHYSFS_File* file, PHYSFS_sint16* val);
	int PHYSFS_readUBE16(PHYSFS_File* file, PHYSFS_uint16* val);
	int PHYSFS_readSLE32(PHYSFS_File* file, PHYSFS_sint32* val);
	int PHYSFS_readULE32(PHYSFS_File* file, PHYSFS_uint32* val);
	int PHYSFS_readSBE32(PHYSFS_File* file, PHYSFS_sint32* val);
	int PHYSFS_readUBE32(PHYSFS_File* file, PHYSFS_uint32* val);
	int PHYSFS_readSLE64(PHYSFS_File* file, PHYSFS_sint64* val);
	int PHYSFS_readULE64(PHYSFS_File* file, PHYSFS_uint64* val);
	int PHYSFS_readSBE64(PHYSFS_File* file, PHYSFS_sint64* val);
	int PHYSFS_readUBE64(PHYSFS_File* file, PHYSFS_uint64* val);
	int PHYSFS_writeSLE16(PHYSFS_File* file, PHYSFS_sint16 val);
	int PHYSFS_writeULE16(PHYSFS_File* file, PHYSFS_uint16 val);
	int PHYSFS_writeSBE16(PHYSFS_File* file, PHYSFS_sint16 val);
	int PHYSFS_writeUBE16(PHYSFS_File* file, PHYSFS_uint16 val);
	int PHYSFS_writeSLE32(PHYSFS_File* file, PHYSFS_sint32 val);
	int PHYSFS_writeULE32(PHYSFS_File* file, PHYSFS_uint32 val);
	int PHYSFS_writeSBE32(PHYSFS_File* file, PHYSFS_sint32 val);
	int PHYSFS_writeUBE32(PHYSFS_File* file, PHYSFS_uint32 val);
	int PHYSFS_writeSLE64(PHYSFS_File* file, PHYSFS_sint64 val);
	int PHYSFS_writeULE64(PHYSFS_File* file, PHYSFS_uint64 val);
	int PHYSFS_writeSBE64(PHYSFS_File* file, PHYSFS_sint64 val);
	int PHYSFS_writeUBE64(PHYSFS_File* file, PHYSFS_uint64 val);
	int PHYSFS_isInit();
	int PHYSFS_symbolicLinksPermitted();

	struct PHYSFS_Allocator {
		int function() Init;
		void function() Deinit;
		void* function(PHYSFS_uint64) Malloc;
		void* function(void*, PHYSFS_uint64) Realloc;
		void function(void*) Free;
	}

	int PHYSFS_setAllocator(const PHYSFS_Allocator* allocator);

	int PHYSFS_mount(const(char)* newDir, const(char)* mountPoint, int appendToPath);
	const(char)* PHYSFS_getMountPoint(const(char)* dir);
	alias PHYSFS_StringCallback = void function(void* data, const(char)* str);
	alias PHYSFS_EnumFilesCallback = void function(void* data, const(char)* origdir, const(char)* fname);

	void PHYSFS_getCdRomDirsCallback(PHYSFS_StringCallback c, void* d);
	void PHYSFS_getSearchPathCallback(PHYSFS_StringCallback c, void* d);
	deprecated void PHYSFS_enumerateFilesCallback(const(char)* dir, PHYSFS_EnumFilesCallback c, void* d);

	void PHYSFS_utf8FromUcs4(const PHYSFS_uint32* src, char* dst, PHYSFS_uint64 len);
	void PHYSFS_utf8ToUcs4(const(char)* src, PHYSFS_uint32* dst, PHYSFS_uint64 len);
	void PHYSFS_utf8FromUcs2(const PHYSFS_uint16* src, char* dst, PHYSFS_uint64 len);
	void PHYSFS_utf8ToUcs2(const(char)* src, PHYSFS_uint16* dst, PHYSFS_uint64 len);
	void PHYSFS_utf8FromLatin1(const(char)* src, char* dst, PHYSFS_uint64 len);

	int PHYSFS_caseFold(const PHYSFS_uint32 from, PHYSFS_uint32* to);
	int PHYSFS_utf8stricmp(const(char)* str1, const(char)* str2);
	int PHYSFS_utf16stricmp(const PHYSFS_uint16* str1, const PHYSFS_uint16* str2);
	int PHYSFS_ucs4stricmp(const PHYSFS_uint32* str1, const PHYSFS_uint32* str2);
	enum PHYSFS_EnumerateCallbackResult {
		PHYSFS_ENUM_ERROR = -1, /**< Stop enumerating, report error to app. */
		PHYSFS_ENUM_STOP = 0, /**< Stop enumerating, report success to app. */
		PHYSFS_ENUM_OK = 1 /**< Keep enumerating, no problems */
	}

	alias PHYSFS_EnumerateCallback = PHYSFS_EnumerateCallbackResult function(void* data, const(char)* origdir, const(char)* fname);
	int PHYSFS_enumerate(const(char)* dir, PHYSFS_EnumerateCallback c, void* d);
	int PHYSFS_unmount(const(char)* oldDir);
	const(PHYSFS_Allocator)* PHYSFS_getAllocator();
	enum PHYSFS_FileType {
		PHYSFS_FILETYPE_REGULAR,
		PHYSFS_FILETYPE_DIRECTORY,
		PHYSFS_FILETYPE_SYMLINK,
		PHYSFS_FILETYPE_OTHER
	}

	struct PHYSFS_Stat {
		PHYSFS_sint64 filesize;
		PHYSFS_sint64 modtime;
		PHYSFS_sint64 createtime;
		PHYSFS_sint64 accesstime;
		PHYSFS_FileType filetype;
		int readonly;
	}

	int PHYSFS_stat(const(char)* fname, PHYSFS_Stat* stat);
	void PHYSFS_utf8FromUtf16(const PHYSFS_uint16* src, char* dst, PHYSFS_uint64 len);
	void PHYSFS_utf8ToUtf16(const(char)* src, PHYSFS_uint16* dst, PHYSFS_uint64 len);
	PHYSFS_sint64 PHYSFS_readBytes(PHYSFS_File* handle, void* buffer, PHYSFS_uint64 len);
	PHYSFS_sint64 PHYSFS_writeBytes(PHYSFS_File* handle, const void* buffer, PHYSFS_uint64 len);
	struct PHYSFS_Io {
		PHYSFS_uint32 version_;
		void* opaque;
		PHYSFS_sint64 function(PHYSFS_Io* io, void* buf, PHYSFS_uint64 len) read;
		PHYSFS_sint64 function(PHYSFS_Io* io, const void* buffer, PHYSFS_uint64 len) write;
		int function(PHYSFS_Io* io, PHYSFS_uint64 offset) seek;
		PHYSFS_sint64 function(PHYSFS_Io* io) tell;
		PHYSFS_sint64 function(PHYSFS_Io* io) length;
		PHYSFS_Io* function(PHYSFS_Io* io) duplicate;
		int function(PHYSFS_Io* io) flush;
		void function(PHYSFS_Io* io) destroy;
	}

	int PHYSFS_mountIo(PHYSFS_Io* io, const(char)* newDir, const(char)* mountPoint, int appendToPath);
	int PHYSFS_mountMemory(const void* buf, PHYSFS_uint64 len, void function(void*) del, const(char)* newDir,
			const(char)* mountPoint, int appendToPath);
	int PHYSFS_mountHandle(PHYSFS_File* file, const(char)* newDir, const(char)* mountPoint, int appendToPath);
	enum PHYSFS_ErrorCode {
		PHYSFS_ERR_OK,
		PHYSFS_ERR_OTHER_ERROR,
		PHYSFS_ERR_OUT_OF_MEMORY,
		PHYSFS_ERR_NOT_INITIALIZED,
		PHYSFS_ERR_IS_INITIALIZED,
		PHYSFS_ERR_ARGV0_IS_NULL,
		PHYSFS_ERR_UNSUPPORTED,
		PHYSFS_ERR_PAST_EOF,
		PHYSFS_ERR_FILES_STILL_OPEN,
		PHYSFS_ERR_INVALID_ARGUMENT,
		PHYSFS_ERR_NOT_MOUNTED,
		PHYSFS_ERR_NOT_FOUND,
		PHYSFS_ERR_SYMLINK_FORBIDDEN,
		PHYSFS_ERR_NO_WRITE_DIR,
		PHYSFS_ERR_OPEN_FOR_READING,
		PHYSFS_ERR_OPEN_FOR_WRITING,
		PHYSFS_ERR_NOT_A_FILE,
		PHYSFS_ERR_READ_ONLY,
		PHYSFS_ERR_CORRUPT,
		PHYSFS_ERR_SYMLINK_LOOP,
		PHYSFS_ERR_IO,
		PHYSFS_ERR_PERMISSION,
		PHYSFS_ERR_NO_SPACE,
		PHYSFS_ERR_BAD_FILENAME,
		PHYSFS_ERR_BUSY,
		PHYSFS_ERR_DIR_NOT_EMPTY,
		PHYSFS_ERR_OS_ERROR,
		PHYSFS_ERR_DUPLICATE,
		PHYSFS_ERR_BAD_PASSWORD,
		PHYSFS_ERR_APP_CALLBACK
	}

	PHYSFS_ErrorCode PHYSFS_getLastErrorCode();
	const(char)* PHYSFS_getErrorByCode(PHYSFS_ErrorCode code);
	void PHYSFS_setErrorCode(PHYSFS_ErrorCode code);
	const(char)* PHYSFS_getPrefDir(const(char)* org, const(char)* app);

	struct PHYSFS_Archiver {
		PHYSFS_uint32 version_;
		PHYSFS_ArchiveInfo info;
		void* function(PHYSFS_Io* io, const(char)* name, int forWrite, int* claimed) openArchive;
		PHYSFS_EnumerateCallbackResult function(void* opaque, const(char)* dirname, PHYSFS_EnumerateCallback cb,
				const(char)* origdir, void* callbackdata) enumerate;
		PHYSFS_Io* function(void* opaque, const(char)* fnm) openRead;
		PHYSFS_Io* function(void* opaque, const(char)* filename) openWrite;
		PHYSFS_Io* function(void* opaque, const(char)* filename) openAppend;
		int function(void* opaque, const(char)* filename) remove;
		int function(void* opaque, const(char)* filename) mkdir;
		int function(void* opaque, const(char)* fn, PHYSFS_Stat* stat) stat;
		void function(void* opaque) closeArchive;
	}

	int PHYSFS_registerArchiver(const PHYSFS_Archiver* archiver);
	int PHYSFS_deregisterArchiver(const(char)* ext);
}
