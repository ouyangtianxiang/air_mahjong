--[[
	className    	     :  BaiduLogin
	Description  	     :  登录类-子类(91助手登录)
	last-modified-date   :  Feb.12 2014
	create-time 	     :  Feb.12 2014
	last-modified-author :  ClarkWu
	create-author        :  ClarkWu
]]
require("MahjongLogin/LoginMethod/BaseLogin");

BaiduLogin = class(BaseLogin);

--[[
	function name      : BaiduLogin.ctor
	description  	   : @Override 
	param 	 	 	   : self
	last-modified-date : Feb.12 2014
	create-time		   : Feb.12 2014
]]
BaiduLogin.ctor = function (self,data )
	self.appId = "555";
end

--[[
	function name      : BaiduLogin.dtor
	description  	   : @Override 
	param 	 	 	   : self
	last-modified-date : Feb.12 2014
	create-time		   : Feb.12 2014
]]
BaiduLogin.dtor = function (self )
end

BaiduLogin.getLoginUserName = function(self)
	return CreatingViewUsingData.commonData.userIdentityBaidu;
end
BaiduLogin.getLoginType = function(self)
	return PlatformConfig.BaiduLogin;
end
--[[
	function name      : BaiduLogin.login
	description  	   : @Override 
	param 	 	 	   : self
	last-modified-date : Feb.12 2014
	create-time		   : Feb.12 2014
]]
BaiduLogin.login = function ( self, ... )
	umengStatics_lua(kUmengBaiduLogin);
	self.super.login(self);
	self.m_data = k91LoginConfig;
	PlatformFactory.curPlatform:setAPI(PlatformConfig.BaiduLogin);
	if isPlatform_Win32() then 
		GameConstant.timestamp = kBaiduLoginConfig.kTimestamp;
		-- GameConstant.uid = kBaiduLoginConfig.kUid;
		GameConstant.uid = "-";
		GameConstant.sid = "-";
		-- GameConstant.sid = kBaiduLoginConfig.kSid;
		GameConstant.validation = kBaiduLoginConfig.kValidation;
		GameConstant.nickname = kBaiduLoginConfig.kNickname;

		DebugLog(GameConstant.timestamp)
		self:OnRequestLoginPHP(self:setSendLoginPHPdata());
	else 
		self.m_data.loginType = PlatformConfig.BaiduLogin;
		native_muti_login(self.m_data)
	end
end

--[[
	function name      : BaiduLogin.requestLoginCallBack
	description  	   : @Override 
	param 	 	 	   : self
	last-modified-date : Feb.12 2014
	create-time		   : Feb.12 2014
]]
BaiduLogin.requestLoginCallBack = function (self, isSuccess, data)
	PlatformFactory.curPlatform:setAPI(PlatformConfig.BaiduLogin);
	GameConstant.requestLogin = false;
	if isSuccess then 
		local msg;
		if kNumOne ==  GetNumFromJsonTable(data,kStatus) then
			GameConstant.isLogin = kAlreadyLogin;
		else
			GameConstant.isLogin = kNoLogin;
			msg = GetStrFromJsonTable(data,kMsg);
		end
		if msg ~= nil and kNullStringStr ~= msg then 
			Banner.getInstance():showMsg(msg);
		end
	else
		GameConstant.isLogin = kNoLogin;
		Banner.getInstance():showMsg(PromptMessage.loginFailed);
	end
	EventDispatcher.getInstance():dispatch(self.loginResuleEvent,isSuccess,data);
end

BaiduLogin.getLoginIdentityIcon = function(self)
	return "Login/DKIcon.png";
end

BaiduLogin.callEvent = function(self, key, data)
	self.super.callEvent(self, key, data);
end

--[[
	function name      : BaiduLogin.loginCallback
	description  	   : @Override 
	param 	 	 	   : self
	last-modified-date : Feb.12 2014
	create-time		   : Feb.12 2014
]]
BaiduLogin.loginCallback = function(self,json_data)
	local timestamp = kNullStringStr;
	local uid = kNullStringStr;
	local sid = kNullStringStr;
	local validation = kNullStringStr;
	local nickname = kNullStringStr;

	if GetStrFromJsonTable(json_data,"timestamp") and kNullStringStr ~= GetStrFromJsonTable(json_data,"timestamp") then
	 	timestamp = GetStrFromJsonTable(json_data,"timestamp");
	end

	if GetStrFromJsonTable(json_data,"uid") and kNullStringStr ~= GetStrFromJsonTable(json_data,"uid") then
		uid = GetStrFromJsonTable(json_data,"uid");
	end

	if GetStrFromJsonTable(json_data,"sid") and kNullStringStr ~= GetStrFromJsonTable(json_data,"sid") then
		sid = GetStrFromJsonTable(json_data,"sid");
	end

	if GetStrFromJsonTable(json_data,"validation") and kNullStringStr ~= GetStrFromJsonTable(json_data,"validation") then
		validation = GetStrFromJsonTable(json_data,"validation");
	end

	if GetStrFromJsonTable(json_data,"nickname") and kNullStringStr ~= GetStrFromJsonTable(json_data,"nickname") then
		nickname = GetStrFromJsonTable(json_data,"nickname");
	end

	DebugLog("timestamp : " .. timestamp);
	DebugLog("uid : " .. uid);
	DebugLog("sid :" .. sid);
	DebugLog("validation :" .. validation);
	DebugLog("nickname :" .. nickname);
	
	GameConstant.timestamp = timestamp;
	GameConstant.uid = uid;
	GameConstant.sid = sid;
	GameConstant.validation = validation;
	GameConstant.nickname = nickname;
		
	self:OnRequestLoginPHP(self:setSendLoginPHPdata());
end

BaiduLogin.setSendLoginPHPdata = function(self)
	local send_data = {};
	local localtoken = g_DiskDataMgr:getAppData(kLocalToken .. self:getLoginType(),"");
	send_data.localtoken = localtoken;
	send_data.bddk_uid = GameConstant.uid;
	send_data.bddk_mnick = GameConstant.nickname;
	send_data.bddk_session = GameConstant.sid;
	send_data.timestamp = GameConstant.timestamp;
	send_data.validation = GameConstant.validation;
	
	return send_data;
end

--[[
	function name      : BaiduLogin.clearGameData
	description  	   : 清除游客的信息
	param 	 	 	   : self
	last-modified-date : Feb.12 2014
	create-time		   : Feb.12 2014
]]
BaiduLogin.clearGameData = function(self)
	GameConstant.imei = nil;
	GameConstant.name = nil;

	self.super.clearGameData( self );
end

--global parameters to request the http,saving for a map.
BaiduLogin.httpRequestsCallBackFuncMap =
{
	[HttpModule.s_cmds.requestLogin] = BaiduLogin.requestLoginCallBack,
};

