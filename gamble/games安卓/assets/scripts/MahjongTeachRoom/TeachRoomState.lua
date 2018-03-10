require("MahjongRoom/RoomState");
require("MahjongTeachRoom/TeachRoomScene");
local roomLayout = require(ViewLuaPath.."roomLayout");

TeachRoomState = class(RoomState);

TeachRoomState.ctor = function ( self )	
	DebugLog(" TeachRoomState ctor");
	self.m_mainScene = nil;
end

TeachRoomState.load = function ( self )
	DebugLog(" TeachRoomState load");
	self.m_mainScene = new(TeachRoomScene, roomLayout, self) 
	return true;
end

TeachRoomState.resume = function( self )
	DebugLog(" TeachRoomState resume");
	self.super.resume(self);
end

TeachRoomState.pause = function(self)
	DebugLog(" TeachRoomState pause");
	self.super.pause(self);
end

TeachRoomState.stop = function(self)
	DebugLog(" TeachRoomState stop");
	self.super.stop(self);
end

TeachRoomState.dtor = function ( self )
	DebugLog(" TeachRoomState dtor");
	delete(self.m_mainScene);
	self.m_mainScene = nil;
end

