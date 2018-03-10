local HotUpdateState = class(GameState);
require("gameBase/gameState")
require("Define")
HotUpdateState.getMainScene = function(self)
	return self.m_mainScene;
end

HotUpdateState.ctor = function ( self )	
	self.m_mainScene = nil;
end

HotUpdateState.load = function ( self )
	GameState.load(self)
	local scene         = require("ResLoading/HotUpdateScene")
	local layout        = require(ViewLuaPath.."hotUpdateLoading");

	self.m_mainScene = new(scene, layout, self) 
	return true;
end

HotUpdateState.resume = function( self )
	GameState.resume(self);
end

HotUpdateState.pause = function(self)
	GameState.pause(self);
end

HotUpdateState.stop = function(self)
	GameState.stop(self);
end

HotUpdateState.dtor = function ( self )
	delete(self.m_mainScene);
	self.m_mainScene = nil;
end

HotUpdateState.onBack = function(self)
end

return HotUpdateState
