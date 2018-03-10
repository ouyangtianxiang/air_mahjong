require("MahjongRoom/FriendMatchRoom/FriendMatchRoomScene");
require("MahjongRoom/RoomState")
local roomLayout = require(ViewLuaPath.."roomLayout");

FriendMatchRoomState = class(RoomState);

FriendMatchRoomState.getMainScene = function(self)
	return self.m_mainScene;
end

FriendMatchRoomState.ctor = function ( self )	
	DebugLog(" FriendMatchRoomState ctor");
	self.m_mainScene = nil;
end

FriendMatchRoomState.load = function ( self )
	DebugLog(" FriendMatchRoomState load");
	GameState.load(self);
	self.m_mainScene = new(FriendMatchRoomScene, roomLayout, self) 
	return true;
end

FriendMatchRoomState.resume = function( self )
	self.super.resume( self );
end

FriendMatchRoomState.pause = function(self)
	self.super.pause( self );
end

FriendMatchRoomState.stop = function(self)
	self.super.stop( self );
end