module rebel.social;

interface ISocialStatus {
	void update(ref SocialUpdate update);
}

// Based on https://discordapp.com/developers/docs/rich-presence/how-to#updating-presence-update-presence-payload-fields
struct SocialUpdate {
	string state; // 128 bytes
	string details; // 128 bytes

	long startTimestamp;
	long endTimestamp;

	string largeImageKey; // 32 bytes
	string largeImageText; // 128 bytes

	string smallImageKey; // 32 bytes
	string smallImageText; // 128 bytes

	string partyId; // 128 bytes
	int partySize;
	int partyMax;

	string joinSecret; // 128 bytes
	string spectateSecret; // 128 bytes
}
