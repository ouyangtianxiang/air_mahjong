--[[
	className    	     :  WeChatLogin
	Description  	     :  登录类-子类(QQ登录)
	last-modified-date   :  Dec.23 2013
	create-time 	     :  Oct.29 2013
	last-modified-author :  ClarkWu
	create-author        :  ClarkWu
]]
require("MahjongLogin/LoginMethod/BaseLogin");

local KEY_ACCESS_TOKEN  = "ACCESS_TOKEN";
local KEY_REFRESH_TOKEN = "REFRESH_TOKEN";
local KEY_CODE 			= "CODE"
local KEY_OPENID 		= "OPENID"

WeChatLogin = class(BaseLogin);

--[[
	function name      : WeChatLogin.ctor
	description  	   : @Override
	param 	 	 	   : self
	last-modified-date : Dec.23  2013
	create-time		   : Dec.23  2013
]]
WeChatLogin.ctor = function (self,data )
	self.mCode 		  = "";
	self.mAccessToken = "";
	self.mRefressToken= "";

	self.mWeChatHost  	= "https://api.weixin.qq.com/sns/oauth2/"
	self.mAPP_ID 		= "wx1caa961e0c11f56c";
	self.mAPP_SECRET 	= "dbe2a6f0a48c0176f3e0fb0cca1537a0";
	self.appId 			= "7077";

	self.m_loginMethod = PlatformConfig.WeChatLogin;

end

--[[
	function name      : WeChatLogin.dtor
	description  	   : @Override
	param 	 	 	   : self
	last-modified-date : Dec.23  2013
	create-time		   : Dec.23  2013
]]
WeChatLogin.dtor = function (self )
end

WeChatLogin.getLoginUserName = function(self)
	return CreatingViewUsingData.commonData.userIdentityWeChat;
end

WeChatLogin.getLoginType = function(self)
	return PlatformConfig.WeChatLogin;
end

--[[
	function name      : WeChatLogin.login
	description  	   : @Override
	param 	 	 	   : self
	last-modified-date : Nov.29 2013
	create-time		   : Nov.29 2013
]]
WeChatLogin.login = function ( self,...)
	umengStatics_lua(kUmengWeChatLogin);
	local params = ...;
	-- Loading.showLoadingAnim(PromptMessage.loadingLogin);

	self.super.login(self);
	self.m_data = kWeChatLoginConfig;
	PlatformFactory.curPlatform:setAPI(PlatformConfig.WeChatLogin);

	if GameConstant.isReconnectGame or GameConstant.lastLoginType ~= PlatformConfig.WeChatLogin then
		self.m_sitemid = g_DiskDataMgr:getAppData(kLoginSid .. PlatformConfig.WeChatLogin, "");
		self.m_token = g_DiskDataMgr:getAppData(kToken .. PlatformConfig.WeChatLogin, "");
		if DEBUGMODE == 1 then
		end
		if self.m_sitemid ~= "" and self.m_token ~= "" then
			self:OnRequestLoginPHP(self:setSendLoginPHPdata());
			GameConstant.isReconnectGame = false;
			return;
		end
	end
	if isPlatform_Win32() then
		self.m_sitemid = self.m_data.wechatDefaultLoginOpenId;
		self.m_token = self.m_data.wechatDefaultLoginToken;
		self:OnRequestLoginPHP(self:setSendLoginPHPdata());
	else
		self.m_data.loginType = PlatformConfig.WeChatLogin;
		native_muti_login(self.m_data)
	end
end

WeChatLogin.setSendLoginPHPdata = function(self)
	local send_data = {};
	send_data.sitemid = self.m_sitemid;
	send_data.token = self.m_token;
	send_data.vkey = GameConstant.imei;
	send_data.appid = GameConstant.appid;
	send_data.appkey = GameConstant.appkey;
	send_data.macAddress = GameConstant.macAddress;
	send_data.SIMunique = GameConstant.imei;

	send_data.openid = self.m_sitemid;

	local localtoken = g_DiskDataMgr:getAppData(kLocalToken .. PlatformConfig.WeChatLogin,"");
	send_data.localtoken = localtoken;
	return send_data;
end

--刷新或续期access_token使用
--https://api.weixin.qq.com/sns/oauth2/refresh_token?appid=APPID&grant_type=refresh_token&refresh_token=REFRESH_TOKEN
WeChatLogin.refressAccessToken = function ( self, refreshToken )
	-- body
	local param = {};

	param.appid 		= self.mAPP_ID;
	param.grant_type 	= "refresh_token";
	param.refresh_token = refreshToken;
	-- 刷新
	self:requestByHttp(HttpModule.s_cmds.requestRefressAccessToken, "refresh_token?", param);
end
--刷新或续期access_token使用的响应
-- 正确返回
-- {
-- "access_token":"ACCESS_TOKEN",
-- "expires_in":7200,
-- "refresh_token":"REFRESH_TOKEN",
-- "openid":"OPENID",
-- "scope":"SCOPE"
-- }

--错误返回
-- {
-- "errcode":40030,"errmsg":"invalid refresh_token"
-- }

WeChatLogin.onRefressAccessToken = function (self, isSuccess, data )
	-- body
	if not isSuccess or not data then
		-- Loading.hideLoadingAnim();
		Banner.getInstance():showMsg(PromptMessage.loginFailed);
		return;
	end

	if  data.errcode and data.errcode then -- fail
		local code = self:getToken(KEY_CODE);
		if code then
			self:requestAccessToken(code);
		else
			self.m_data.loginType = PlatformConfig.WeChatLogin;
			native_muti_login(self.m_data)
		end

	else

		local access_token 	= data.access_token
		local openid 		= data.openid
		local refresh_token = data.refresh_token

		--登录php
		self:loginOnPHP(access_token, openid);

	end
end
--获取access_token
--https://api.weixin.qq.com/sns/oauth2/access_token?appid=APPID&secret=SECRET&code=CODE&grant_type=authorization_code
WeChatLogin.requestAccessToken = function ( self, code )
	-- body
	local param = {};

	param.appid 		= self.mAPP_ID;
	param.secret 		= self.mAPP_SECRET;
	param.code 			= code;
	param.grant_type 	= "authorization_code";

	-- 获取
	 self:requestByHttp(HttpModule.s_cmds.requestAccessToken, "access_token?", param);
end
--获取access_token的响应
WeChatLogin.onRequestAccessToken = function (self, isSuccess, data )
	-- body
	if not isSuccess or not data then
		-- Loading.hideLoadingAnim();
		Banner.getInstance():showMsg(PromptMessage.loginFailed);
		return;
	end
	if  data.errcode and data.errcode then -- fail
		--重新认证
		self.m_data.loginType = PlatformConfig.WeChatLogin;
		native_muti_login(self.m_data)

	else
		local access_token 	= data.access_token
		local openid 		= data.openid
		local refresh_token = data.refresh_token

		self.m_sitemid = openid;
		self.m_token = access_token;

		self:OnRequestLoginPHP(self:setSendLoginPHPdata());
	end
end

--登录返回
WeChatLogin.requestLoginCallBack = function (self, isSuccess, data )
	DebugLog("WeChatLogin.requestLoginCallBack。。。。isSuccess:"..tostring(isSuccess))
	GameConstant.lastLoginType = PlatformConfig.WeChatLogin;
	GameConstant.requestLogin = false;
	PlatformFactory.curPlatform:setAPI(PlatformConfig.WeChatLogin);
	if isSuccess then
		local msg;
		if kNumOne ==  GetNumFromJsonTable(data,kStatus) then
			GameConstant.isLogin = kAlreadyLogin;
			g_DiskDataMgr:setAppData(kLoginSid .. PlatformConfig.WeChatLogin, self.m_sitemid);
			g_DiskDataMgr:setAppData(kToken .. PlatformConfig.WeChatLogin, self.m_token);
		else
			GameConstant.isLogin = kNoLogin;
			msg = GetStrFromJsonTable(data,kMsg);
			g_DiskDataMgr:setAppData(kLoginSid .. PlatformConfig.WeChatLogin, "");
			g_DiskDataMgr:setAppData(kToken .. PlatformConfig.WeChatLogin, "");
			g_DiskDataMgr:getAppData(kLocalToken .. PlatformConfig.WeChatLogin,"");
		end
		if msg ~= nil and kNullStringStr ~= msg then
			Banner.getInstance():showMsg(msg);
		end
	end
	EventDispatcher.getInstance():dispatch(BaseLogin.loginResuleEvent,isSuccess,data);
end

WeChatLogin.requestByHttp = function (self,command, subDomain, param)
	-- body
	local url = self.mWeChatHost .. subDomain;
	local paramCount = 0;
	for k, v in pairs(param) do
		url = url .. (paramCount > 0 and "&" or "") .. k .. "=" .. v;
		paramCount = paramCount + 1;
	end

	HttpModule.getInstance():execute(command, kParamData, self.m_event, url);
end


WeChatLogin.getLoginIdentityIcon = function(self)
	return "Login/wechatIcon.png";
end

WeChatLogin.callEvent = function(self, key, data)
	self.super.callEvent(self, key, data);
end

--[[
	function name      : WeChatLogin.loginCallback
	description  	   : @Override
	param 	 	 	   : self
	last-modified-date : Nov.29 2013
	create-time		   : Nov.29 2013
]]
WeChatLogin.loginCallback = function(self,json_data)
	local code = GetStrFromJsonTable(json_data, "code", "")
	local status = GetNumFromJsonTable(json_data, "status", 0)
	self.mAPP_ID = GetStrFromJsonTable(json_data, "appId", "")
	self.mAPP_SECRET = GetStrFromJsonTable(json_data, "appSecret", "")


	if status == 1 then
		self:requestAccessToken(code)
	else
		-- Loading.hideLoadingAnim();
		if HallScene_instance ~= nil then
			HallScene_instance:addLoginView()
		end
	end
end

--[[
	function name      : WeChatLogin.logout
	description  	   : QQ登出的信息
	param 	 	 	   : self
	last-modified-date : Nov.29 2013
	create-time		   : Nov.29 2013
]]
WeChatLogin.logout = function(self)
	self.super.logout( self );
	if not isPlatform_Win32() then
		self.m_data.loginType = PlatformConfig.WeChatLogin;
		local dataStr = json.encode(self.m_data);
		native_to_java(kLogoutPlatform,dataStr);
	end
	self:login()   --重新进行登录
end

--[[
	function name      : WeChatLogin.setSendLoginPHPdata
	description  	   : @Override
	param 	 	 	   : self
	last-modified-date : Nov.29 2013
	create-time		   : Nov.29 2013
]]


--global parameters to request the http,saving for a map.
WeChatLogin.httpRequestsCallBackFuncMap =
{
	[HttpModule.s_cmds.requestRefressAccessToken] 	= WeChatLogin.onRefressAccessToken,
	[HttpModule.s_cmds.requestAccessToken] 			= WeChatLogin.onRequestAccessToken,
};
