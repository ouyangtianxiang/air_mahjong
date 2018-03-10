--[[
	className    	     :  Guest2345Login
	Description  	     :  登录类-子类(游客登录)
	last-modified-date   :  Dec.23 2013
	create-time 	     :  Oct.29 2013
	last-modified-author :  ClarkWu
	create-author        :  ClarkWu
]]
require("MahjongLogin/LoginMethod/BaseLogin");

Guest2345Login = class(BaseLogin);

--[[
	function name      : Guest2345Login.ctor
	description  	   : @Override 
	param 	 	 	   : self
	last-modified-date : Dec.23  2013
	create-time		   : Dec.23  2013
]]
Guest2345Login.ctor = function (self,data )
	self.appId = PlatformFactory.curPlatform:getLoginAppId( PlatformConfig.Guest2345Login );
end

--[[
	function name      : Guest2345Login.dtor
	description  	   : @Override 
	param 	 	 	   : self
	last-modified-date : Dec.23  2013
	create-time		   : Dec.23  2013
]]
Guest2345Login.dtor = function (self )
end

Guest2345Login.getLoginUserName = function(self)
	if PlatformConfig.platformContest == GameConstant.platformType then 
		return CreatingViewUsingData.commonData.userIdentityContest;
	else
		return CreatingViewUsingData.commonData.userIdentityGuest2345;
	end
end
Guest2345Login.getLoginType = function(self)
	return PlatformConfig.Guest2345Login;
end
--[[
	function name      : Guest2345Login.login
	description  	   : @Override 
	param 	 	 	   : self
	last-modified-date : Nov.29 2013
	create-time		   : Nov.29 2013
]]
Guest2345Login.login = function ( self, ... )

	umengStatics_lua(kUmengGuest2345Login);
	self.super.login(self);
	self.m_data = kGuestLoginConfig;
	PlatformFactory.curPlatform:setAPI(PlatformConfig.GuestLogin);

	if isPlatform_Win32() then 
		GameConstant.name = self.m_data.guestDefaultName;
		GameConstant.imei = SystemGetSitemid();
		GameConstant.tf_imei = "357523050938869";
		GameConstant.tf_mac = "D022BE53EAEC";
		GameConstant.tf_imsi = "460008732245540";
		GameConstant.tf_time = "1401103987";
		GameConstant.tf_result = 0;
		self:OnRequestLoginPHP(self:setSendLoginPHPdata());
	else 
		GameConstant.tf_result = g_DiskDataMgr:getAppData("tf_result") or "-1";
		if GameConstant.tf_result == "1" then 
			GameConstant.tf_imei = g_DiskDataMgr:getAppData("tf_imei");
			GameConstant.tf_mac  = g_DiskDataMgr:getAppData("tf_mac");
			GameConstant.tf_imsi = g_DiskDataMgr:getAppData("tf_imsi");
			GameConstant.tf_time = g_DiskDataMgr:getAppData("tf_time");
		end 
		self.m_data.loginType = PlatformConfig.Guest2345Login;
		self.m_data.loginTo2345Result = tonumber(GameConstant.tf_result);
		native_muti_login(self.m_data)
	end
end

--[[
	function name      : Guest2345Login.requestLoginCallBack
	description  	   : @Override 
	param 	 	 	   : self
	last-modified-date : Nov.29 2013
	create-time		   : Nov.29 2013
]]
Guest2345Login.requestLoginCallBack = function (self, isSuccess, data)
	DebugLog("Guest2345Login.requestLoginCallBack")
	GameConstant.requestLogin = false;

	PlatformFactory.curPlatform:setAPI(PlatformConfig.Guest2345Login);
	if isSuccess and data then 
		mahjongPrint(data)
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

		if data.userinfo and data.userinfo.visitorBounded then
			self.visitorBounded = tonumber(data.userinfo.visitorBounded) == 1;
		end
	else
		GameConstant.isLogin = kNoLogin;
		Banner.getInstance():showMsg(PromptMessage.loginFailed);
	end
	EventDispatcher.getInstance():dispatch(self.loginResuleEvent,isSuccess,data);
end

Guest2345Login.getLoginIdentityIcon = function(self)
	return "Login/guestIcon.png";
end

Guest2345Login.callEvent = function(self, key, data)
	self.super.callEvent(self, key, data);
end

--[[
	function name      : Guest2345Login.callEvent
	description  	   : @Override 
	param 	 	 	   : self
	last-modified-date : Nov.29 2013
	create-time		   : Nov.29 2013
]]
Guest2345Login.loginCallback = function(self,json_data)

	local imei = kNullStringStr;
	local name = kNullStringStr;
	
	GameConstant.isFirstPopu = 1;

	if GetStrFromJsonTable(json_data,kLoginImei) and kNullStringStr ~= GetStrFromJsonTable(json_data,kLoginImei) then
		imei = GetStrFromJsonTable(json_data,kLoginImei);
	end

	if GetStrFromJsonTable(json_data,kLoginName) and kNullStringStr ~= GetStrFromJsonTable(json_data,kLoginName) then
		name = GetStrFromJsonTable(json_data,kLoginName);
	end

	if imei == kNullStringStr and name == kNullStringStr then 
		Loading.hideLoadingAnim();
		Banner.getInstance():showMsg("登录失败，请重新再试");
		return;
	end
	

	if PlatformFactory.curPlatform:needFirstNotDownload() then 
		if GetNumFromJsonTable(json_data,"needupdate") then 
			GameConstant.needUpdate = GetNumFromJsonTable(json_data,"needupdate");
		end
	end

	if GetNumFromJsonTable(json_data,"isFirstPopu") then 
		GameConstant.isFirstPopu = GetNumFromJsonTable(json_data,"isFirstPopu");
	end

	GameConstant.imei=imei;
	GameConstant.name=name;
		
	if GetStrFromJsonTable(json_data,"tf_imei") and kNullStringStr ~= GetStrFromJsonTable(json_data,"tf_imei") then
		tf_imei = GetStrFromJsonTable(json_data,"tf_imei");
	end
		
	if GetStrFromJsonTable(json_data,"tf_mac") and kNullStringStr ~= GetStrFromJsonTable(json_data,"tf_mac") then
		tf_mac = GetStrFromJsonTable(json_data,"tf_mac");
	end
		
	if GetStrFromJsonTable(json_data,"tf_imsi") and kNullStringStr ~= GetStrFromJsonTable(json_data,"tf_imsi") then
		tf_imsi = GetStrFromJsonTable(json_data,"tf_imsi");
	end
		
	if GetStrFromJsonTable(json_data,"tf_time") and kNullStringStr ~= GetStrFromJsonTable(json_data,"tf_time") then
		tf_time = GetStrFromJsonTable(json_data,"tf_time");
	end

	if GetStrFromJsonTable(json_data, "tf_result") and kNullStringStr ~= GetStrFromJsonTable(json_data,"tf_result") then
		tf_result = GetStrFromJsonTable(json_data,"tf_result");
	end
	GameConstant.tf_imei = tf_imei;
	GameConstant.tf_mac = tf_mac;
	GameConstant.tf_imsi = tf_imsi;
	GameConstant.tf_time = tf_time;
		
	if GameConstant.tf_result ~= "1" then 
		if tf_result == "1" then 
			GameConstant.tf_imei = tf_imei;
			GameConstant.tf_mac = tf_mac;
			GameConstant.tf_imsi = tf_imsi;
			GameConstant.tf_time = tf_time;
			GameConstant.tf_result = tf_result;
			g_DiskDataMgr:setAppData("tf_imei",GameConstant.tf_imei);
			g_DiskDataMgr:setAppData("tf_mac",GameConstant.tf_mac);
			g_DiskDataMgr:setAppData("tf_imsi",GameConstant.tf_imsi);
			g_DiskDataMgr:setAppData("tf_time",GameConstant.tf_time);
		end
		GameConstant.tf_result = tf_result;
		g_DiskDataMgr:setAppData("tf_result",GameConstant.tf_result);
	end
	self:OnRequestLoginPHP(self:setSendLoginPHPdata());
end

--[[
	function name      : Guest2345Login.clearGameData
	description  	   : 清除游客的信息
	param 	 	 	   : self
	last-modified-date : Nov.29 2013
	create-time		   : Nov.29 2013
]]
Guest2345Login.clearGameData = function(self)
	GameConstant.imei = nil;
	GameConstant.name = nil;

	self.super.clearGameData( self );
end

--[[
	function name      : Guest2345Login.setSendLoginPHPdata
	description  	   : @Override 
	param 	 	 	   : self
	last-modified-date : Nov.29 2013
	create-time		   : Nov.29 2013
]]
Guest2345Login.setSendLoginPHPdata = function(self)
	local send_data = {};
	send_data.nick = GameConstant.name;
	send_data.sitemid = GameConstant.imei;
	send_data.macAddress = GameConstant.macAddress;
	
	send_data.tf_imei = GameConstant.tf_imei;
	send_data.tf_mac = GameConstant.tf_mac;
	send_data.tf_imsi = GameConstant.tf_imsi;
	send_data.tf_time = GameConstant.tf_time;
	return send_data;
end

--global parameters to request the http,saving for a map.
Guest2345Login.httpRequestsCallBackFuncMap =
{
	[HttpModule.s_cmds.requestLogin] = Guest2345Login.requestLoginCallBack,
};

