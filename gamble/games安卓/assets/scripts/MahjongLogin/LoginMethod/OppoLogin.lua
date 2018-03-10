--[[
	className    	     :  HuaweiLogin
	Description  	     :  登录类-子类(Oppo登录)
	last-modified-date   :  Dec.20 2013
	create-time 	     :  Dec.20 2013
	last-modified-author :  JkinLiu
	create-author        :  JkinLiu
]]
OppoLogin = class(BaseLogin);

require("MahjongLogin/LoginMethod/BaseLogin");

--[[
	function name      : OppoLogin.ctor
	description  	   : @Override 
	param 	 	 	   : self
	last-modified-date : Dec.20  2013
	create-time		   : Dec.20  2013
]]
OppoLogin.ctor = function ( self, data )
	self.m_loginMethod = PlatformConfig.OppoLogin;
end

--[[
	function name      : OppoLogin.dtor
	description  	   : @Override 
	param 	 	 	   : self
	last-modified-date : Dec.20  2013
	create-time		   : Dec.20  2013
]]
OppoLogin.dtor = function ( self )
	-- body
end

OppoLogin.getLoginUserName = function(self)
	return CreatingViewUsingData.commonData.userIdentityOppo;
end
OppoLogin.getLoginType = function(self)
	return PlatformConfig.OppoLogin;
end
--[[
	function name      : OppoLogin.login
	description  	   : @Override 
	param 	 	 	   : self
	last-modified-date : Dec.20 2013
	create-time		   : Dec.20 2013
]]
OppoLogin.login = function ( self, ... )
	umengStatics_lua(kUmengOppoLogin);
	self.super.login(self);
	
	if not isPlatform_Win32() then 
		self.m_data.loginType = PlatformConfig.OppoLogin;
		native_muti_login(self.m_data)
	else
		GameConstant.name = kGuestLoginConfig.guestDefaultImei or "AF3B5CECA7C8A95A43438FF35F3CA50B";
		GameConstant.imei = SystemGetSitemid();
		PlatformFactory.curPlatform.curLoginType = PlatformConfig.GuestLogin;
		self:OnRequestLoginPHP(self:setSendLoginPHPdata());
		PlatformFactory.curPlatform.curLoginType = PlatformConfig.OppoLogin;
	end
end

--[[
	function name      : OppoLogin.changeAccount
	description  	   : to change the account.
	param 	 	 	   : self
	last-modified-date : Dec.20 2013
	create-time		   : Dec.20 2013
]]
OppoLogin.changeAccount = function ( self )
	if not isPlatform_Win32() then 
		self.m_data.loginType = PlatformConfig.OppoLogin;
		local dataStr = json.encode(self.m_data);
		native_to_java(kSwitchPlatform,dataStr);
	end
end

--[[
	function name      : OppoLogin.requestLoginCallBack
	description  	   : @Override 
	param 	 	 	   : self
	last-modified-date : Dec.20 2013
	create-time		   : Dec.20 2013
]]
OppoLogin.requestLoginCallBack = function (self, isSuccess, data)
	GameConstant.requestLogin = false;
	if isSuccess then -- 登录成功返回
		if 1 == GetNumFromJsonTable(data,kStatus) then
			-- 登录成功，通过事件通知游戏系统更新用户信息
			GameConstant.isLogin = kAlreadyLogin;
			GameConstant.lastLoginType = PlatformConfig.OppoLogin;
		else
			GameConstant.isLogin = kNoLogin;
			DebugLog(" oppo login failed.");
		end
	else
		GameConstant.isLogin = kNoLogin;
		Banner.getInstance():showMsg(PromptMessage.loginFailed);
	end
	EventDispatcher.getInstance():dispatch(BaseLogin.loginResuleEvent, isSuccess, data); -- 通知游戏更新界面
end

OppoLogin.getLoginIdentityIcon = function(self)
	return "Login/oppoIcon.png";
end

OppoLogin.callEvent = function(self, key, data)
	self.super.callEvent(self, key, data);
end

--[[
	function name      : OppoLogin.oppoLoginJavaCallback
	description  	   : Java的回调函数.
	param 	 	 	   : self
						 json_data  --Table Json数据
	last-modified-date : Dec.20 2013
	create-time		   : Dec.20 2013
]]
OppoLogin.loginCallback = function ( self, json_data )
	if not json_data then
		return;
	end
	self.oppoId = json_data.id or kNumMinusOne;
	self.oppoSex = json_data.sex or kNumZero;
	self.oppoProfilePictureUrl = json_data.profilePictureUrl or kNullStringStr;
	self.oppoName = json_data.nickname or kNullStringStr;
	self.oppoGameBalance = tonumber(json_data.gameBalance or kNumZero);
	self.token = json_data.token or kNullStringStr;
	self.secret = json_data.secret or kNullStringStr;
	-- self.ssoid = json_data.ssoid or kNullStringStr;

	if self.token == kNullStringStr then 
		return;
	end

	OppoPlatform.curNBao = 	self.oppoGameBalance;
	OppoPlatform.curKeBi =  self.oppoGameBalance;


	self:OnRequestLoginPHP(self:setSendLoginPHPdata()); -- 请求登录游戏服务器
end

--[[
	function name      : OppoLogin.logout
	description  	   : Oppo登出的信息
	param 	 	 	   : self
	last-modified-date : Dec.20 2013
	create-time		   : Dec.20 2013
]]
OppoLogin.logout = function(self)
	self.super.logout( self );
end

--[[
	function name      : OppoLogin.clearGameData
	description  	   : 清除Oppo登陆的信息
	param 	 	 	   : self
	last-modified-date : Dec.20 2013
	create-time		   : Dec.20 2013
]]
OppoLogin.clearGameData = function(self)
	self.super.clearGameData( self );
	self.oppoId = kNumMinusOne;
	self.oppoSex = kNumZero;
	self.oppoProfilePictureUrl = kNullStringStr;
	self.oppoName = kNullStringStr;
	self.oppoGameBalance = kNumZero;
	self.token = kNullStringStr;
	self.secret = kNullStringStr;
end

--[[
	function name      : OppoLogin.setSendLoginPHPdata
	description  	   : @Override 
	param 	 	 	   : self
	last-modified-date : Dec.20 2013
	create-time		   : Dec.20 2013
]]
OppoLogin.setSendLoginPHPdata = function(self)
	local post_data = {};
	local localtoken = g_DiskDataMgr:getAppData(kLocalToken .. self:getLoginType(),"");
	if isPlatform_Win32() then 
    	post_data.nick = GameConstant.name;
		post_data.sitemid = GameConstant.imei;
		post_data.macAddress = GameConstant.macAddress;
		post_data.localtoken = localtoken;
	else
		post_data.oppoId = self.oppoId;
		post_data.oppoConstellation = self.oppoConstellation;
		post_data.oppoSex = self.oppoSex;
		post_data.oppoProfilePictureUrl = self.oppoProfilePictureUrl;
		post_data.oppoName = self.oppoName;
		post_data.oppoGameBalance = self.oppoGameBalance;
		post_data.token = self.token;
		post_data.secret = self.secret;
		post_data.macAddress = GameConstant.macAddress;
		post_data.localtoken = localtoken;
    end
	
	return post_data;
end

--global parameters to request the http,saving for a map.
OppoLogin.httpRequestsCallBackFuncMap =
{
	[HttpModule.s_cmds.requestLogin] = OppoLogin.requestLoginCallBack,
};

