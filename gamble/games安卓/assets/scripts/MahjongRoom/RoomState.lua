require("gameBase/gameState")
require("Define")
require("MahjongRoom/RoomScene")
require("MahjongRoom/Seat")
require("MahjongRoom/SeatManager")
local roomLayout = require(ViewLuaPath.."roomLayout");

RoomState = class(GameState);

RoomState.getMainScene = function(self)
	return self.m_mainScene;
end

RoomState.ctor = function ( self )	
	DebugLog(" RoomState ctor");
	self.m_mainScene = nil;
end

RoomState.load = function ( self )
	DebugLog(" RoomState load");
	GameState.load(self);
	self.m_mainScene = new(RoomScene, roomLayout, self) 
	return true;
end

RoomState.resume = function( self )
	DebugLog(" RoomState resume");
	GameState.resume(self);
end

RoomState.pause = function(self)
	DebugLog(" RoomState pause");
	GameState.pause(self);
end

RoomState.stop = function(self)
	DebugLog(" RoomState stop");
	GameState.stop(self);
end

RoomState.dtor = function ( self )
	DebugLog(" RoomState dtor");
	delete(self.m_mainScene);
	self.m_mainScene = nil;
end

RoomState.onBack = function(self)
end

