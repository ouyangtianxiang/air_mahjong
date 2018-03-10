require("gameBase/gameState")
require("Define")
require("gameBase/gameEffect");
require("gameBase/gameMusic");
require("MahjongUtil/UICreator");
require("MahjongCommon/CustomNode");
require("MahjongCommon/PopuFrame");
require("MahjongHall/HallScene")
require("audioConfig")

-- if PlatformConfig.platformQihoo == GameConstant.platformType then 
-- 	local hallLayout_otherVersion = require(ViewLuaPath.."hallLayout_otherVersion");
-- else
-- 	local hallLayout = require(ViewLuaPath.."hallLayout");
-- end

HallState = class(GameState);

HallState.getMainScene = function(self)
	return self.m_mainScene;
end

HallState.ctor = function ( self )	
	DebugLog(" HallState ctor");
	self.m_mainScene = nil;
end

HallState.load = function ( self )
	DebugLog(" HallState load");
	GameState.load(self);

	if PlatformFactory.curPlatform:needToShowUpdataView() then 
		local hallContent = require(ViewLuaPath.."hallContent");
		self.m_mainScene = new(HallScene, hallContent, self);
	else
		local hallContent = require(ViewLuaPath.."hallContent");
		self.m_mainScene = new(HallScene, hallContent,self);
	end
	return true;
end

HallState.resume = function( self )
	DebugLog(" HallState resume");
	GameState.resume(self);
end

HallState.pause = function(self)
	DebugLog(" HallState pause");
	GameState.pause(self);
end

HallState.stop = function(self)
	DebugLog(" HallState stop");
	GameState.stop(self);
end

HallState.dtor = function ( self )
	DebugLog(" HallState dtor");
	delete(self.m_mainScene);
	self.m_mainScene = nil;
end

HallState.onBack = function(self)
	
end

