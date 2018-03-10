require("gameBase/gameScene")
require("MahjongData/CreatingViewUsingData")
local LoadingScene = class(GameScene);

function LoadingScene:ctor( viewConfig, controller, data, nextState )
--	g_GameMonitor:addTblToUnderMemLeakMonitor("LoadingScene",self)
    -- body
    self.m_needLoadTextures = data

    self.m_loadTimeOut      = 6--最多加载6s
    self.m_loadTimeRequire  = 1--最少1s

    self.m_nextState = nextState
end

function LoadingScene:dtor( ... )
    -- body
    self.m_needLoadTextures = nil

    self:clearHandle()

end

function LoadingScene:resume( ... )
	DebugLog('Loading resume',LTMap.Loading)
	-- body
	self.super.resume(self);
	self.m_startTime = os.clock()


    if DEBUGMODE == 1 then
        local profileNode = require('MahjongCommon/ProfileNode')
        self.profileNode = new(profileNode)
        self.profileNode:setPos(0,80)
        self.profileNode:setLevel(99999)
        self:addChild(self.profileNode)        
    end	
	--清除不用的纹理
	TextureCache.instance():clean_unused()
	--
	self:playLoadAnim()
	--加载纹理
	self:loadTextures()
	--
	g_DiskDataMgr:save()
	--添加超时处理
	self.m_timeOutHandle = Clock.instance():schedule(function ( ... )
		self:complete()
	end,self.m_loadTimeOut)
end

function LoadingScene:pause( ... )
	-- body
	self.super.pause(self);
end

function LoadingScene:stop( ... )
	-- body
	self.super.stop(self);
end


function LoadingScene:playLoadAnim( ... )
	-- body
	local loadingImg = self:getControl( LoadingScene.s_controls.loadingImg )
	self.m_loadingPoints = {}
	self.m_visibleCount  = 0
	for i=1,6 do
		local key = 'point'..i
		self.m_loadingPoints[key] = publ_getItemFromTree(loadingImg, {key});
		self.m_loadingPoints[key]:setVisible(false)
	end

	self.m_animHandle = Clock.instance():schedule(function()
		self.m_visibleCount = self.m_visibleCount + 1
		if self.m_visibleCount > 6 then 
			self.m_visibleCount = 1
		end 
		for i=1,6 do
			self.m_loadingPoints['point'..i]:setVisible( i<=self.m_visibleCount )
		end
	end,0.2)

	math.randomseed(tostring(os.time()):reverse():sub(1,9)); -- 短时间内保证产生的随机数尽量不一致
	local index = math.random(1,#CreatingViewUsingData.commonData.loadingText);
	self:getControl( LoadingScene.s_controls.tipText ):setText(CreatingViewUsingData.commonData.loadingText[index])

end

--异步加载
function LoadingScene:loadTexturesSync( ... )
	DebugLog('Loading loadTexturesSync:',LTMap.Loading)
	-- body
	if not self.m_needLoadTextures or #self.m_needLoadTextures <= 0 then 
		self:loadCompleteCallback()
	else 
		self:loadTextureCallback(1)
	end 	
end
--同步加载
function LoadingScene:loadTextures( ... )
	DebugLog('Loading loadTextures:',LTMap.Loading)
	for i=1,#self.m_needLoadTextures do
		TextureCache.instance():get(self.m_needLoadTextures[i])
		DebugLog('Loading texture:'..self.m_needLoadTextures[i]..' complete',LTMap.Loading)
	end

	self:loadCompleteCallback()
end


function LoadingScene:loadTextureCallback( index )
	if index > #self.m_needLoadTextures then 
		self:loadCompleteCallback()
		return 
	end 	
	DebugLog('Loading texture:'..self.m_needLoadTextures[index]..' start',LTMap.Loading)
	-- body
	TextureCache.instance():get_async(self.m_needLoadTextures[index],function(texture)
		if not self or not self.m_needLoadTextures then 
			DebugLog('Loading texture '..index..':!!!!!!!!!!!!!!!!!!!!!!',LTMap.Loading)
			return
		end 
		DebugLog('Loading texture '..index..':'..self.m_needLoadTextures[index]..' complete',LTMap.Loading)
    	self:loadTextureCallback(index+1)
	end)
end

function LoadingScene:loadCompleteCallback( ... )
	-- body
	local stopTime = os.clock()
	if stopTime - self.m_startTime > self.m_loadTimeRequire then 
		self:complete()
	else 
		self.m_timeRequireHandle = Clock.instance():schedule(function()
			self:complete()
	    end,self.m_loadTimeRequire)
	end 
end


function LoadingScene:clearHandle( ... )
	if self.m_timeRequireHandle then 
		self.m_timeRequireHandle:cancel()
		self.m_timeRequireHandle = nil 
	end 

	if self.m_timeOutHandle then 
		self.m_timeOutHandle:cancel()
		self.m_timeOutHandle = nil 
	end 

	if self.m_animHandle then 
		self.m_animHandle:cancel()
		self.m_animHandle = nil 
	end 
end

function LoadingScene:complete( ... )
	DebugLog('Loading complete',LTMap.Loading)
	-- body
	self:clearHandle()
	StateMachine.getInstance():changeState(self.m_nextState);
end
--------------------------------------------------------------------------------------------------------------------------------------------
-- 定义可操作控件的标识
LoadingScene.s_controls =
{
    tipText             = 1,
    loadingImg          = 2,
}

-- 可操作控件在布局文件中的位置
LoadingScene.s_controlConfig =
{
    [LoadingScene.s_controls.tipText]                         = {"bgImg", "tipBg", "text"},
    [LoadingScene.s_controls.loadingImg]                      = {"bgImg", "loadingImg"},
}

-- 可操作控件的响应函数
LoadingScene.s_controlFuncMap =
{

}



return LoadingScene