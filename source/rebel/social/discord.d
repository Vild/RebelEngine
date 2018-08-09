module rebel.social.discord;

import rebel.social;

import derelict.discord.rpc;

import std.string;
import std.stdio;

shared static this() {
	DerelictDiscordRPC.load();
}

class DiscordSocialStatus : ISocialService {
public:
	static DiscordSocialStatus getInstance(string appID) {
		if (!_instance)
			_instance = new DiscordSocialStatus(appID);
		return _instance;
	}

	~this() {
		Discord_Shutdown();
		_instance = null;
	}

	void update(ref SocialUpdate update) {
		import std.algorithm : min;

		with (update) {
			_rpc.state = state[0 .. min(128, state.length)].toStringz;
			_rpc.details = details[0 .. min(128, details.length)].toStringz;

			_rpc.startTimestamp = startTimestamp;
			_rpc.endTimestamp = endTimestamp;

			_rpc.largeImageKey = largeImageKey[0 .. min(32, largeImageKey.length)].toStringz;
			_rpc.largeImageText = largeImageText[0 .. min(128, largeImageText.length)].toStringz;

			_rpc.smallImageKey = smallImageKey[0 .. min(32, smallImageKey.length)].toStringz;
			_rpc.smallImageText = smallImageText[0 .. min(128, smallImageText.length)].toStringz;

			_rpc.partyId = partyId[0 .. min(128, partyId.length)].toStringz;
			_rpc.partySize = partySize;
			_rpc.partyMax = partyMax;

			_rpc.joinSecret = joinSecret[0 .. min(128, joinSecret.length)].toStringz;
			_rpc.spectateSecret = spectateSecret[0 .. min(128, spectateSecret.length)].toStringz;
		}
		Discord_UpdatePresence(&_rpc);
	}

private:
	static DiscordSocialStatus _instance;
	static DiscordRichPresence _rpc;

	this(string appID) {
		DiscordEventHandlers handlers;
		handlers.ready = &handleReady;
		handlers.disconnected = &handleDisconnected;
		handlers.errored = &handleError;
		handlers.joinGame = &handleJoinGame;
		handlers.spectateGame = &handleSpectateGame;
		handlers.joinRequest = &handleJoinRequest;

		Discord_Initialize(appID.toStringz, &handlers, 1, null);
	}

static extern (C):
	void handleReady() {
		writeln("Discord-RPC is ready.");
	}

	void handleDisconnected(int errorCode, const(char)* message) {
		writeln("Discord-RPC disconnected because of error ", errorCode, ": ", message.fromStringz);
	}

	void handleError(int errorCode, const(char)* message) {
		writeln("An Discord-RPC error occured (", errorCode, "): ", message.fromStringz);
	}

	void handleJoinGame(const(char)* joinSecret) {
		writeln("Someone wants to join the game; secret: ", joinSecret.fromStringz);
	}

	void handleSpectateGame(const(char)* spectateSecret) {
		writeln("Someone wants to spectate; secret: ", spectateSecret.fromStringz);
	}

	void handleJoinRequest(const(DiscordJoinRequest)* request) {
		writeln("Received a join request from ", request.username.fromStringz, " (ID: ", request.userId, ")");
	}
}
