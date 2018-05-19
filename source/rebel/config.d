module rebel.config;

struct Version {
	ushort major, minor, patch;
}

enum string engineName = "RebelEngine";
enum Version engineVersion = Version(1, 0, 0);
