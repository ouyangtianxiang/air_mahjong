require("gameBase/gameState")
require("Define")

require("MahjongRoom/MatchRoom/MatchRoomScene")
require("MahjongRoom/Seat")
require("MahjongRoom/SeatManager")
local roomLayout = require(ViewLuaPath.."roomLayout");

MatchRoomState = class(GameState);

MatchRoomState.getMainScene = function(self)
	return self.m_mainScene;
end

MatchRoomState.ctor = function ( self, ... )
	DebugLog(" MatchRoomState ctor");
	self.m_mainScene 	= nil;
	self.m_argList 		= arg;
end

MatchRoomState.load = function ( self )
	DebugLog(" MatchRoomState load");
	GameState.load(self);
	self.m_mainScene = new(MatchRoomScene, roomLayout, self, unpack(self.m_argList) ) --new(MatchRoomController, self, MatchRoomScene, roomLayout, unpack(self.m_argList));
	return true;
end

MatchRoomState.resume = function( self )
	DebugLog(" MatchRoomState resume");
	GameState.resume(self);
end

MatchRoomState.pause = function(self)
	DebugLog(" MatchRoomState pause");
	GameState.pause(self);
end

MatchRoomState.stop = function(self)
	DebugLog(" MatchRoomState stop");
	GameState.stop(self);
end

MatchRoomState.dtor = function ( self )
	DebugLog(" MatchRoomState dtor");
	delete(self.m_mainScene);
	self.m_mainScene = nil;
end

MatchRoomState.onBack = function(self)
	
end

