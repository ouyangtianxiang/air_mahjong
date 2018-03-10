

local LoadingState = class(GameState);
require("gameBase/gameState")
require("Define")
LoadingState.getMainScene = function(self)
	return self.m_mainScene;
end

LoadingState.ctor = function ( self, nextState )	
	self.m_mainScene = nil;

	self.m_nextState = nextState
end

LoadingState.load = function ( self )
	GameState.load(self)
	local scene         = require("ResLoading/LoadingScene")
	local loadingLayout = require(ViewLuaPath.."roomLoading");
	local textures      = nil
	if m_nextState == States.Hall then --hall
		textures = require("ResLoading/hallFileTextures")
	elseif m_nextState ~= States.Loading then --room
		textures = require("ResLoading/roomFileTextures")
	end 
	self.m_mainScene = new(scene, loadingLayout, self,textures,self.m_nextState) 
	return true;
end

LoadingState.resume = function( self )
	GameState.resume(self);
end

LoadingState.pause = function(self)
	GameState.pause(self);
end

LoadingState.stop = function(self)
	GameState.stop(self);
end

LoadingState.dtor = function ( self )
	delete(self.m_mainScene);
	self.m_mainScene = nil;
end

LoadingState.onBack = function(self)
end

return LoadingState
