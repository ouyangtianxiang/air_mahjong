--[[
	className    	     :  DingkaiLogin
	Description  	     :  登录类-子类(鼎开登录)
	last-modified-date   :  Feb.12 2014
	create-time 	     :  Feb.12 2014
	last-modified-author :  ClarkWu
	create-author        :  ClarkWu
]]
require("MahjongLogin/LoginMethod/BaseLogin");

DingkaiLogin = class(BaseLogin);

--[[
	function name      : DingkaiLogin.ctor
	description  	   : @Override 
	param 	 	 	   : self
	last-modified-date : Feb.12 2014
	create-time		   : Feb.12 2014
]]
DingkaiLogin.ctor = function (self,data )
	self.appId = "7072";
end

--[[
	function name      : DingkaiLogin.dtor
	description  	   : @Override 
	param 	 	 	   : self
	last-modified-date : Feb.12 2014
	create-time		   : Feb.12 2014
]]
DingkaiLogin.dtor = function (self )
end

DingkaiLogin.getLoginUserName = function(self)
	return CreatingViewUsingData.commonData.userIdentityDingkai;
end

--[[
	function name      : DingkaiLogin.login
	description  	   : @Override 
	param 	 	 	   : self
	last-modified-date : Feb.12 2014
	create-time		   : Feb.12 2014
]]
DingkaiLogin.login = function ( self, ... )
	umengStatics_lua(kUmengDingKaiLogin);
	self.super.login(self);
	self.m_data = kDingkaiLoginConfig;
	PlatformFactory.curPlatform:setAPI(PlatformConfig.DingkaiLogin);
	local platform = System.getPlatform();
	if kPlatformWin32 == platform then 
		GameConstant.dingkai_id = kDingkaiLoginConfig.dingkai_id;
		GameConstant.name = kGuestLoginConfig.guestDefaultImei or "AF3B5CECA7C8A95A43438FF35F3CA50B";
		GameConstant.imei = SystemGetSitemid();
		PlatformFactory.curPlatform.curLoginType = PlatformConfig.GuestLogin;
		self:OnRequestLoginPHP(self:setSendLoginPHPdata());
		PlatformFactory.curPlatform.curLoginType = PlatformConfig.DingkaiLogin;
	else 
		self.m_data.loginType = PlatformConfig.DingkaiLogin;
		native_muti_login(self.m_data)
	end
end

--[[
	function name      : DingkaiLogin.requestLoginCallBack
	description  	   : @Override 
	param 	 	 	   : self
	last-modified-date : Feb.12 2014
	create-time		   : Feb.12 2014
]]
DingkaiLogin.requestLoginCallBack = function (self, isSuccess, data)
	PlatformFactory.curPlatform:setAPI(PlatformConfig.DingkaiLogin);
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
		EventDispatcher.getInstance():dispatch(self.loginResuleEvent,isSuccess,data);
	else
		GameConstant.isLogin = kNoLogin;
		Banner.getInstance():showMsg(PromptMessage.loginFailed);
	end
	
end

DingkaiLogin.getLoginIdentityIcon = function(self)
	return "Login/guestIcon.png";
end

DingkaiLogin.callEvent = function(self, key, data)
	self.super.callEvent(self, key, data);
end

DingkaiLogin.getLoginType = function(self)
	return PlatformConfig.DingkaiLogin;
end

--[[
	function name      : DingkaiLogin.loginCallback
	description  	   : @Override 
	param 	 	 	   : self
	last-modified-date : Feb.12 2014
	create-time		   : Feb.12 2014
]]
DingkaiLogin.loginCallback = function(self,json_data)
	local dingkai_uid = kNullStringStr;
	local dingkai_coin = kNullStringStr;
	local dingkai_token = kNullStringStr;

	if GetStrFromJsonTable(json_data,"dingkai_id") and kNullStringStr ~= GetStrFromJsonTable(json_data,"dingkai_id") then
	 	dingkai_uid = GetStrFromJsonTable(json_data,"dingkai_id");
	end

	if GetStrFromJsonTable(json_data,"dingkai_coin") and kNullStringStr ~= GetStrFromJsonTable(json_data,"dingkai_coin") then
		dingkai_coin = GetStrFromJsonTable(json_data,"dingkai_coin");
	end

	if GetStrFromJsonTable(json_data,"dingkai_token") and kNullStringStr ~= GetStrFromJsonTable(json_data,"dingkai_token") then
		dingkai_token = GetStrFromJsonTable(json_data,"dingkai_token");
	end

    --起凡设置头像，名字为起凡大厅的头像，名字
    if GetStrFromJsonTable(json_data,"imageUrl") and kNullStringStr ~= GetStrFromJsonTable(json_data,"imageUrl") then
		PlayerManager.getInstance():myself().large_image = GetStrFromJsonTable(json_data,"imageUrl");
	end

    if GetStrFromJsonTable(json_data,"nickName") and kNullStringStr ~= GetStrFromJsonTable(json_data,"nickName") then
		PlayerManager.getInstance():myself().nickName = GetStrFromJsonTable(json_data,"nickName");
	end

	DebugLog("dingkai_id : " .. dingkai_uid);
	DebugLog("dingkai_coin : " .. dingkai_coin);
	DebugLog("dingkai_token : " .. dingkai_token);
	
	GameConstant.dingkai_id = dingkai_uid;
	GameConstant.dingkai_coin = dingkai_coin;
	GameConstant.dingkai_token = dingkai_token;
		
	self:OnRequestLoginPHP(self:setSendLoginPHPdata());
end

DingkaiLogin.setSendLoginPHPdata = function(self)
	local send_data = {};
	 if isPlatform_Win32() then 
    	send_data.nick = GameConstant.name;
		send_data.sitemid = GameConstant.imei;
		send_data.macAddress = GameConstant.macAddress;
		send_data.localtoken = "";

	else
		send_data.dingkai_userid = GameConstant.dingkai_id;
		send_data.dingkai_token = GameConstant.dingkai_token;
		send_data.localtoken = GameConstant.dingkai_token;
	    
    end
	
	return send_data;
end

--[[
	function name      : DingkaiLogin.clearGameData
	description  	   : 清除游客的信息
	param 	 	 	   : self
	last-modified-date : Feb.12 2014
	create-time		   : Feb.12 2014
]]
DingkaiLogin.clearGameData = function(self)
	GameConstant.dingkai_id = nil;
	GameConstant.dingkai_token = nil;
	self.super:clearGameData();
end

--global parameters to request the http,saving for a map.
DingkaiLogin.httpRequestsCallBackFuncMap =
{
	[HttpModule.s_cmds.requestLogin] = DingkaiLogin.requestLoginCallBack,
};