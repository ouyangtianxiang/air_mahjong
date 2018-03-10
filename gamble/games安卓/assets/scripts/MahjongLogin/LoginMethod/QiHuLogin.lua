--[[
	className    	     :  QiHuLogin
	Description  	     :  登录类-子类(奇虎登录)
	last-modified-date   :  Dec.20 2013
	create-time 	     :  Dec.18 2013
	last-modified-author :  ClarkWu
	create-author        :  ClarkWu
]]
require("MahjongLogin/LoginMethod/BaseLogin");

QiHuLogin = class(BaseLogin);

--[[
	function name      : QiHuLogin.ctor
	description  	   : @Override 
	param 	 	 	   : self
	last-modified-date : Dec.20  2013
	create-time		   : Dec.20  2013
]]
QiHuLogin.ctor = function (self,data )
end

--[[
	function name      : QiHuLogin.dtor
	description  	   : @Override 
	param 	 	 	   : self
	last-modified-date : Dec.20  2013
	create-time		   : Dec.20  2013
]]
QiHuLogin.dtor = function (self )
end

QiHuLogin.getLoginUserName = function(self)
	return CreatingViewUsingData.commonData.userIdentity360;
end
QiHuLogin.getLoginType = function(self)
	return PlatformConfig.QiHuLogin;
end
--[[
	function name      : QiHuLogin.login
	description  	   : @Override 
	param 	 	 	   : self
	last-modified-date : Dec.18  2013
	create-time		   : Dec.18  2013
]]
QiHuLogin.login = function ( self, ... )
	umengStatics_lua(kUmeng360Login);
	self.super.login(self);
	self.m_data = kQiHuLoginConfig;
	PlatformFactory.curPlatform:setAPI(PlatformConfig.QiHuLogin);
	local dataStr = json.encode(self.m_data);

	self.m_loginMethod = PlatformConfig.QiHuLogin;

	if isPlatform_Win32() then 
		GameConstant.name = kGuestLoginConfig.guestDefaultImei or "AF3B5CECA7C8A95A43438FF35F3CA50B";
		GameConstant.imei = SystemGetSitemid();
		PlatformFactory.curPlatform.curLoginType = PlatformConfig.GuestLogin;
		self:OnRequestLoginPHP(self:setSendLoginPHPdata());
		PlatformFactory.curPlatform.curLoginType = PlatformConfig.QiHuLogin;

	else 
		local param = {};
		param.loginType = PlatformConfig.QiHuLogin;
		native_muti_login(param)
	end
end

--[[
	function name      : QiHuLogin.requestLoginCallBack
	description  	   : @Override 
	param 	 	 	   : self
	last-modified-date : Dec.18  2013
	create-time		   : Dec.18  2013
]]
QiHuLogin.requestLoginCallBack = function (self, isSuccess, data)
	mahjongPrint(data);
	GameConstant.requestLogin = false;
	PlatformFactory.curPlatform:setAPI(PlatformConfig.QiHuLogin);
	if isSuccess then 
		local msg;
		if kNumOne ==  GetNumFromJsonTable(data,kStatus) then
			GameConstant.isLogin = kAlreadyLogin;
			--GameConstant.token360 = data.qihoo.access_token
			--GameConstant.tokenRefreshToken360 = data.qihoo.refresh_token
			--GameConstant.expires_in = data.qihoo.expires_in
			--GameConstant.scope = data.qihoo.scope
			--self:refresh360Token();
			GameConstant.lastLoginType = PlatformConfig.QiHuLogin;
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
	EventDispatcher.getInstance():dispatch(BaseLogin.loginResuleEvent,isSuccess,data);
end

QiHuLogin.getLoginIdentityIcon = function(self)
	return "Login/qihoo.png";
end

--[[
	function name      : QiHuLogin.refresh360Token
	description  	   : 刷新360Token值. 
	param 	 	 	   : self
	last-modified-date : Dec.24  2013
	create-time		   : Dec.18  2013
]]
QiHuLogin.refresh360Token = function(self)
	if self.m_anim360 then 
		delete(self.m_anim360);
		self.m_anim360 = nil;
	end
	
	if GameConstant.expires_in then 
		self.m_anim360 = new(AnimInt, kAnimNormal, CreatingViewUsingData.switchLoginView.login360AnimToken.startX, CreatingViewUsingData.switchLoginView.login360AnimToken.startY, GameConstant.expires_in * CreatingViewUsingData.switchLoginView.login360AnimToken.expired_in, CreatingViewUsingData.switchLoginView.login360AnimToken.delay);
	    self.m_anim360:setEvent(self,self.getRefresh360TokenPHP);
	end
end

--[[
	function name      : QiHuLogin.getRefresh360TokenPHP
	description  	   : 发送360Token值. 
	param 	 	 	   : self
	last-modified-date : Dec.24  2013
	create-time		   : Dec.18  2013
]]
QiHuLogin.getRefresh360TokenPHP = function(self)
	 if self.m_anim360 then
        delete(self.m_anim360);
        self.m_anim360 = nil;
      end
      local url = PlatformConfig.TOKEN360URL .. GameConstant.tokenRefreshToken360..k360ClientId..GameConstant.appkey..k360ClientSecret..GameConstant.appsecret..k360ClientScope;
      -- 刷新
      HttpModule.getInstance():execute(HttpModule.s_cmds.refresh360Token, kParamData, self.m_event,url);
end

--[[
	function name      : QiHuLogin.refresh360TokenByPHP
	description  	   : 发送360Token值回调值. 
	param 	 	 	   : self
					   : isSuccess      Boolean   -- The value of the php return,if Success returns true,it expresses success,and false,it express failed.
					   : data           Table     -- The data of PHP command returns.
	last-modified-date : Dec.24  2013
	create-time		   : Dec.18  2013
]]
QiHuLogin.refresh360TokenByPHP = function(self,isSuccess,data)
	if isSuccess then 
		GameConstant.token360 = data.access_token
		GameConstant.tokenRefreshToken360 = data.refresh_token
		GameConstant.expires_in = data.expires_in
		GameConstant.scope = data.scope
		self:refresh360Token();
	end
end

QiHuLogin.callEvent = function(self, key, data)
	self.super.callEvent(self, key, data);
end

--[[
	function name      : QiHuLogin.callEvent
	description  	   : @Override 
	param 	 	 	   : self
	last-modified-date : Dec.18  2013
	create-time		   : Dec.18  2013
]]
QiHuLogin.loginCallback = function(self,json_data)

	local appid = GetStrFromJsonTable(json_data,k360Appid,"200206401");
    local appkey = GetStrFromJsonTable(json_data,k360Appkey,"d6cc42ddb930b4e6e3f528916cf6a514");
    local appsecret = GetStrFromJsonTable(json_data,k360AppSecret,"55a03f1625a4500e4ea79144d592c151");
    local authocode = GetStrFromJsonTable(json_data,k360Authocode,kNullStringStr);
    local accesscode = GetStrFromJsonTable(json_data,k360Accesscode,kNullStringStr);
--[[
	if GetStrFromJsonTable(json_data,k360Appid) and kNullStringStr ~= GetStrFromJsonTable(json_data,k360Appid) then
	 	appid = GetStrFromJsonTable(json_data,k360Appid);
	end

	if GetStrFromJsonTable(json_data,k360Appkey) and kNullStringStr ~= GetStrFromJsonTable(json_data,k360Appkey) then
		appkey = GetStrFromJsonTable(json_data,k360Appkey);
	end

	if GetStrFromJsonTable(json_data,k360AppSecret) and kNullStringStr ~= GetStrFromJsonTable(json_data,k360AppSecret) then
		appsecret = GetStrFromJsonTable(json_data,k360AppSecret);
	end

	if GetStrFromJsonTable(json_data,"authocode") and kNullStringStr ~= GetStrFromJsonTable(json_data,"authocode") then
		authocode = GetStrFromJsonTable(json_data,"authocode");
	end
]]--
	DebugLog("appid" .. appid .. ";appkey:" .. appkey .. ";appsecret:" .. appsecret .. ";authocode:" .. authocode .. ";access_token:" .. authocode);
	GameConstant.appid = appid;
    GameConstant.appkey = appkey;
    GameConstant.appsecret = appsecret; 
    GameConstant.token = authocode;
    GameConstant.accesscode = authocode;
	self:OnRequestLoginPHP(self:setSendLoginPHPdata());

end

--[[
	function name      : QiHuLogin.logout
	description  	   : 奇虎登出的信息
	param 	 	 	   : self
	last-modified-date : Dec.18  2013
	create-time		   : Dec.18  2013
]]
QiHuLogin.logout = function(self)
	GameConstant.appid = nil;
    GameConstant.appkey = nil;
    GameConstant.appsecret = nil; 
    GameConstant.token = nil;
    GameConstant.accesscode = nil;
	self:clearGameData();
	self.super.logout( self );
end

--[[
	function name      : QiHuLogin.clearGameData
	description  	   : 清除奇虎登陆的信息
	param 	 	 	   : self
	last-modified-date : Dec.18  2013
	create-time		   : Dec.18  2013
]]
QiHuLogin.clearGameData = function(self)
	GameConstant.appid = nil;
    GameConstant.appkey = nil;
    GameConstant.appsecret = nil; 
    GameConstant.token = nil;
    GameConstant.accesscode = nil;
	self.super.clearGameData( self );
end

--[[
	function name      : QiHuLogin.setSendLoginPHPdata
	description  	   : @Override 
	param 	 	 	   : self
	last-modified-date : Nov.29 2013
	create-time		   : Nov.29 2013
]]
QiHuLogin.setSendLoginPHPdata = function(self)
	local send_data = {};
    local localtoken = g_DiskDataMgr:getAppData(kLocalToken .. self:getLoginType(),"");
    if isPlatform_Win32() then 
    	send_data.nick = GameConstant.name;
		send_data.sitemid = GameConstant.imei;
		send_data.macAddress = GameConstant.macAddress;
		send_data.localtoken = localtoken;

	else
		send_data.appkey = GameConstant.appkey;
	    send_data.appsecret = GameConstant.appsecret; 
	    send_data.macAddress = GameConstant.macAddress;
	    send_data.token = GameConstant.token;
		send_data.localtoken = localtoken;
	    send_data.access_token = GameConstant.accesscode;
    end
	return send_data;
end


