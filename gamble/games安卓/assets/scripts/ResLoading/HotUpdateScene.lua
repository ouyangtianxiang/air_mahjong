require("gameBase/gameScene")
require("MahjongSocket/NetConfig")
require("MahjongData/CreatingViewUsingData")
local HotUpdateScene = class(GameScene);

function HotUpdateScene:ctor( viewConfig )
    -- body
    self.m_loadTimeOut      = 8--最多加载6s
    self.m_needLoadTextures = require("ResLoading/hallFileTextures")
    self.m_progress         = 0

    self.m_isSilent         = true --静默更新
    --
    NativeManager.getInstance()

    self.m_phpEvent = EventDispatcher.getInstance():getUserEvent(); -- php注册回调事件
    EventDispatcher.getInstance():register(self.m_phpEvent, self, self.onResponseCheckHotUpdate); 
    EventDispatcher.getInstance():register(NativeManager._Event, self, self.callEvent);   
end

function HotUpdateScene:dtor( ... )
	EventDispatcher.getInstance():unregister(self.m_phpEvent, self, self.onResponseCheckHotUpdate);
	EventDispatcher.getInstance():unregister(NativeManager._Event, self, self.callEvent);   
    -- body
    self:clearHandle()

end

-- {
--     data = { {
--             desc = "线上熊猫加载不出来 导致nil的问题",
--             isbig = 0,
--             size = 100,
--             url = "http://swf4.17c.cn/mahjong/weibo/lua/update_535_3_f90c0d6f1710868f9d6c51ac4b1ca906.zip",
--             version = 3
--         }, {
--             desc = "",
--             isbig = 0,
--             size = 100,
--             url = "http://swf4.17c.cn/mahjong/weibo/lua/update_535_4_e1ad9d5e4709f4fccc94854f9e5216b2.zip",
--             version = 4
--         } },
--     status = 1
-- }

function HotUpdateScene:onResponseCheckHotUpdate( command, isSuccess, data , jsonData)
	if HttpModule.s_cmds.hotUpdate == command then 
		if not isSuccess or not data then
			--无须更新--log("无法获取热更新数据");
			self:complete()
			return;
		end

		if not data.status or data.status ~= 1 or not data.data or #data.data == 0 then 
			self:complete()
			return 
		end 

		if System.getPlatform()== kPlatformWin32 then 
			self:complete()
			return
		end 

		self:setProgress(0)
		self:getControl( HotUpdateScene.s_controls.progressBg ):setVisible(true)
		self:getControl( HotUpdateScene.s_controls.textTip ):setText('正在更新...')
		--取出最新版本
		local maxItem = nil 
		for k,v in pairs(data.data) do
			if not maxItem then 
				maxItem = v 
			else 
				if maxItem.version < v.version then 
					maxItem = v 
				end
			end 
		end
		self.m_downloadSize = maxItem.size or 1
		
		if maxItem.isbig == 0 then  --非重要版本  静默更新
		else--重要版本 要显示进度条 
			self.m_isSilent = nil
			native_to_java(kCloseLoadingProe)--关闭java的闪屏界面  显示进度条加载的loading界面

			--伪装 防止进度条卡死--  100ms刷新下进度条
			self.m_progressAnimHandle = Clock.instance():schedule(function ( ... )
				self:updateProgress()
			end,0.1)			
		end 
		--封装数据
		local packdata  = {}
		packdata.status = 1
		packdata.data   = {}
		table.insert(packdata.data, maxItem)
		DebugLog(packdata)
		native_to_java( kHotUpdate, json.encode(packdata) );
	end 
end

-- key:kHotUpdate, 
-- jsonData:{"status":1,"size":174582}
-- status: 1表示下载中，2表示下载完成，-1表示下载失败

function HotUpdateScene:callEvent( param, data )
	DebugLog('HotUpdateScene:callEvent: param = '..param)
	DebugLog(data)
	if kHotUpdate == param then--热更进度
		if data.status == 1 then 
			local size = data.size/1024 -- kb
			self:setProgress(size/self.m_downloadSize)
		elseif data.status == 2 then 
			self:setProgress(1)
			--如果非静默更新  需手动增加显示java的闪屏界面 遮盖重启引擎的闪现效果
			if not self.m_isSilent then 
			    Clock.instance():schedule_once(function()
					native_to_java(kOpenStartScreen)
			    end,0.5)	
			end 
			--800ms后 重启引擎
		    Clock.instance():schedule_once(function()
		    	self:clearHandle()
		        self:restartEngine()
		    end,1.0)			
		else 
			self:complete()
		end 
	end 
end

function HotUpdateScene:resume( ... )
	
	-- body
	self.super.resume(self)
	--
	self:getControl( HotUpdateScene.s_controls.progressBg ):setVisible(false)
	--初始化域名
	NetConfig.getInstance()
	--
	
	--检查是否需要热更
	self:checkForHotUpdate()
	--加载纹理
	--self:loadTextures()
	--添加超时处理
	self.m_timeOutHandle = Clock.instance():schedule(function ( ... )
		self:complete()
	end,self.m_loadTimeOut)
end

function HotUpdateScene:pause( ... )
	-- body
	self.super.pause(self);
end

function HotUpdateScene:stop( ... )
	-- body
	self.super.stop(self);
end


function HotUpdateScene:checkForHotUpdate()

	local param = {};
	param.lua_ver = Version.lua_ver;
	param.mini_ver = Version.mini_ver;
	HttpModule.getInstance():execute(HttpModule.s_cmds.hotUpdate, param,self.m_phpEvent);
end

--同步加载
function HotUpdateScene:loadTextures( ... )
	for i=1,#self.m_needLoadTextures do
		TextureCache.instance():get(self.m_needLoadTextures[i])
	end
end


function HotUpdateScene:setProgress( progress )
	self.m_progress = math.max(self.m_progress, progress)--保障进度条不会回退

	local proImg = self:getControl( HotUpdateScene.s_controls.progress )
	local w,h = proImg:getSize();
	DebugLog("set progress:"..self.m_progress)
	proImg:setClip(0,0,w*self.m_progress,h);
end

function HotUpdateScene:updateProgress( progress )--伪装 缓慢增长下进度条
	self:setProgress(math.min(self.m_progress + 0.05,1))
end

function HotUpdateScene:clearProgressHandle( ... )
	if self.m_progressAnimHandle then 
		self.m_progressAnimHandle:cancel()
		self.m_progressAnimHandle = nil 
	end 
end

function HotUpdateScene:clearHandle( ... )

	if self.m_timeOutHandle then 
		self.m_timeOutHandle:cancel()
		self.m_timeOutHandle = nil 
	end 

	self:clearProgressHandle()
end

function HotUpdateScene:complete( ... )
	DebugLog('HotUpdateScene complete')
	native_to_java(kCloseLoadingProe)--关闭java的闪屏界面
	-- body
	self:clearHandle()
	StateMachine.getInstance():changeState(States.Hall);
end

function HotUpdateScene:restartEngine( ... )
	DebugLog("restartEngine")
	--删除全部4类对象
	res_delete_group(-1);
	anim_delete_group(-1);
	prop_delete_group(-1);
	drawing_delete_all();
	to_lua("main.lua");	
end
--------------------------------------------------------------------------------------------------------------------------------------------
-- 定义可操作控件的标识
HotUpdateScene.s_controls =
{
    textBg             = 1,
    textTip            = 2,
    progressBg         = 3,
    progress           = 4,
}

-- 可操作控件在布局文件中的位置
HotUpdateScene.s_controlConfig =
{
    [HotUpdateScene.s_controls.textBg]                             = {"bg", "text_bg"},
    [HotUpdateScene.s_controls.textTip]                            = {"bg", "text_bg","Text6"},
    [HotUpdateScene.s_controls.progressBg]                         = {"bg", "progress_bg"},
    [HotUpdateScene.s_controls.progress]                           = {"bg", "progress_bg","progress"},    
}

-- 可操作控件的响应函数
HotUpdateScene.s_controlFuncMap =
{

}



return HotUpdateScene