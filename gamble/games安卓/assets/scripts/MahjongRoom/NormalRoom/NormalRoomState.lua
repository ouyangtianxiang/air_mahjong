require("MahjongRoom/NormalRoom/NormalRoomScene");
require("MahjongRoom/RoomState")
local roomLayout = require(ViewLuaPath.."roomLayout");

NormalRoomState = class(RoomState);

NormalRoomState.getMainScene = function(self)
	return self.m_mainScene;
end

NormalRoomState.ctor = function ( self )	
	DebugLog(" NormalRoomState ctor");
	self.m_mainScene = nil;
end

NormalRoomState.load = function ( self )
	DebugLog(" NormalRoomState load");
	GameState.load(self);
	self.m_mainScene = new(NormalRoomScene, roomLayout, self) 
	return true;
end

NormalRoomState.resume = function( self )
	self.super.resume( self );
end

NormalRoomState.pause = function(self)
	self.super.pause( self );
end

NormalRoomState.stop = function(self)
	self.super.stop( self );
end