-- HotUpdateManager.lua
-- author: OnlynightZhang
-- desp: 热更新管理器，将模块高度集成化便于移植
require("Version");

HotUpdateManager = class();

HotUpdateManager.instance = nil;
function HotUpdateManager.getInstance()
	if not HotUpdateManager.instance then
		HotUpdateManager.instance = new( HotUpdateManager );
	end
	return HotUpdateManager.instance;
end

function HotUpdateManager:ctor()
	self.isCheckedUpdate = true; -- 是否检查过更新
	self.m_event = EventDispatcher.getInstance():getUserEvent();

	EventDispatcher.getInstance():register(self.m_event, self,self.onHttpMsgResponse)

end

function HotUpdateManager:dtor()


	EventDispatcher.getInstance():unregister(self.m_event, self,self.onHttpMsgResponse)
end

function HotUpdateManager:checkForHotUpdate()
	log("HotUpdateManager checkForHotUpdate");
	if self.isCheckedUpdate then
		log("checkForHotUpdate");
		self.isCheckedUpdate = true;
		local param = {};
		param.lua_ver = Version.lua_ver;
		param.mini_ver = Version.mini_ver;
		--SocketManager.getInstance():sendPack( PHP_CMD_HOT_UPDATE , param)
		HttpModule.getInstance():execute(HttpModule.s_cmds.hotUpdate, param,self.m_event);
	else
		log("has checked HotUpdated");
	end

	if DEBUGMODE == 1 then
		self:showVersion();
	end
end

function HotUpdateManager:showVersion()
	Banner.getInstance():showMsg( "lua_ver:"..Version.lua_ver.." mini_ver:"..Version.mini_ver );
end

function HotUpdateManager:checkForUpdataCallback( isSuccess, data, jsonData )
	log( "HotUpdateManager:checkForUpdataCallback:" .. tostring(isSuccess));
	if not isSuccess or not data then
		log("无法获取热更新数据");
		return;
	end
	native_to_java( kHotUpdate, jsonData );
end



HotUpdateManager.onHttpMsgResponse = function ( self,command,isSuccess,data,jsonData )
	if HttpModule.s_cmds.hotUpdate == command then 
		self:checkForUpdataCallback(isSuccess,data,jsonData)
	end 
end

