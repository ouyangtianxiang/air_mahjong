require("MahjongRoom/RoomState");
require("MahjongSingleGame/Client/SingleRoomScene");

local roomLayout = require(ViewLuaPath.."roomLayout");

SingleRoomState = class(RoomState);

SingleRoomState.getMainScene = function(self)
	return self.m_mainScene;
end

SingleRoomState.ctor = function ( self )	
	DebugLog(" SingleRoomState ctor");
	self.m_mainScene = nil;
end

SingleRoomState.load = function ( self )
	DebugLog(" SingleRoomState load");
	-- GameState.load(self);
	self.m_mainScene = new(SingleRoomScene, roomLayout, self) --new(SingleRoomController, self, SingleRoomScene, roomLayout);
	return true;
end

SingleRoomState.resume = function( self )
	DebugLog(" SingleRoomState resume");
	-- self.super.resume(self);
	RoomState.resume(self);
end

SingleRoomState.pause = function(self)
	DebugLog(" SingleRoomState pause");
	-- self.super.pause(self);
	RoomState.pause(self);
end

SingleRoomState.stop = function(self)
	DebugLog(" SingleRoomState stop");
	-- self.super.stop(self);
	RoomState.stop(self);
end

SingleRoomState.dtor = function ( self )
	DebugLog(" SingleRoomState dtor");
	delete(self.m_mainScene);
	self.m_mainScene = nil;
end

