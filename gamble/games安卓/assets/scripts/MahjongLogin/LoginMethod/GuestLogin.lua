--[[
	className    	     :  GuestLogin
	Description  	     :  登录类-子类(游客登录)
	last-modified-date   :  Dec.23 2013
	create-time 	     :  Oct.29 2013
	last-modified-author :  ClarkWu
	create-author        :  ClarkWu
]]
require("MahjongLogin/LoginMethod/BaseLogin");
require("coreex/globalex");

GuestLogin = class(BaseLogin);

--[[
	function name      : GuestLogin.ctor
	description  	   : @Override
	param 	 	 	   : self
	last-modified-date : Dec.23  2013
	create-time		   : Dec.23  2013
]]
GuestLogin.ctor = function (self,data )
	self.m_loginMethod = PlatformConfig.GuestLogin;
	if GameConstant.iosDeviceType>0 then
		if GameConstant.iosDeviceType==1 then
			self.m_loginMethod = PlatformConfig.iPhoneGuestLogin;
		else
			self.m_loginMethod = PlatformConfig.iPadGuestLogin;
		end
	end
end

GuestLogin.getLoginUserName = function(self)
	if PlatformConfig.platformContest == GameConstant.platformType then
		return CreatingViewUsingData.commonData.userIdentityContest;
	else
		return CreatingViewUsingData.commonData.userIdentityGuest;
	end
end
GuestLogin.getLoginType = function(self)
	-- return PlatformConfig.GuestLogin;
	return self.m_loginMethod;
end
--[[
	function name      : GuestLogin.login
	description  	   : @Override
	param 	 	 	   : self
	last-modified-date : Nov.29 2013
	create-time		   : Nov.29 2013
]]
GuestLogin.login = function ( self, ... )
	DebugLog("GuestLogin.login")
	umengStatics_lua(kUmengGuestLogin);
	self.m_data = kGuestLoginConfig;
	if DEBUGMODE == 1 then
		-- Banner.getInstance():showMsg("lastLogin" .. (GameConstant.lastLoginType or 0))
	end
	PlatformFactory.curPlatform:setAPI(self.m_loginMethod);
	if isPlatform_Win32() then
		self.m_nickName = self.m_data.guestDefaultName;
		self.m_sitemid = SystemGetSitemid();--"359583070141439"
		self:OnRequestLoginPHP(self:setSendLoginPHPdata());
	else
		self.m_data.loginType = self.m_loginMethod;
		self.m_sitemid = GameConstant.imei
		self.m_nickName = GameConstant.model_name
		self:OnRequestLoginPHP(self:setSendLoginPHPdata())
	end
end

--[[
	function name      : GuestLogin.requestLoginCallBack
	description  	   : @Override
	param 	 	 	   : self
	last-modified-date : Nov.29 2013
	create-time		   : Nov.29 2013
]]
GuestLogin.requestLoginCallBack = function (self, isSuccess, data)
	DebugLog("GuestLogin.requestLoginCallBack")
	GameConstant.requestLogin = false;


	if isSuccess and data then
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

		GameConstant.lastLoginType = self.m_loginMethod;

	else
		GameConstant.isLogin = kNoLogin;
		Banner.getInstance():showMsg(PromptMessage.loginFailed);
	end
	DebugLog("你没啊分发事件------------------------------")

	EventDispatcher.getInstance():dispatch(self.loginResuleEvent,isSuccess,data);
end

GuestLogin.getLoginIdentityIcon = function(self)
	return "Login/guestIcon.png";
end

GuestLogin.callEvent = function(self, key, data)
	self.super.callEvent(self, key, data);
end

--[[
	function name      : GuestLogin.setSendLoginPHPdata
	description  	   : @Override
	param 	 	 	   : self
	last-modified-date : Nov.29 2013
	create-time		   : Nov.29 2013
]]
GuestLogin.setSendLoginPHPdata = function(self)
	local send_data = {};
	send_data.nick = self.m_nickName;
	send_data.sitemid = self.m_sitemid;
	send_data.macAddress = GameConstant.macAddress;
	if GameConstant.iosDeviceType>0 then
		send_data.sitemid = nil;
		send_data.macAddress = nil;
	end

	if DEBUGMODE == 1 then
		local lastuid = nil;
		local ids   = g_DiskDataMgr:getFileKeyValue(GameConstant.CreateGuestInfoMapListKey,"userid","")
		local locallist = json.mahjong_decode_node(ids) or {};
		DebugLog("DEBUGMODE locallist:");
		DebugLog(locallist);
		local idlist = locallist.uidlist or {};
		local chooseuid = locallist.chooseuid or "";
		if #idlist>0 and string.len(tostring(chooseuid))>10  then
			for i=1,#idlist do
	    	if tostring(idlist[i])==tostring(chooseuid) then
	    		lastuid = tostring(chooseuid);
	    	end
	    end
		end
		if lastuid then
			DebugLog("DEBUGMODE chooseuid lastuid:"..lastuid);
		end
		if GameConstant.iosDeviceType>0 then
			send_data.fakeguest = 0;
			if lastuid then
				send_data.fakeguest = 1;
				send_data.nick = self.m_nickName..lastuid;
				send_data.fakeopenUDID = "by000000000000000000y"..lastuid;
				send_data.fakefactoryid = "BY000000-0000-0000-0"..lastuid;
			end
		else
			if lastuid then
				send_data.nick = self.m_nickName..":"..lastuid;
				send_data.sitemid = "0755F30F82EF82014A5F4EB7DDC"..lastuid;
				send_data.macAddress = "MAC0755F30F82EF82014A5F4EDDC"..lastuid;
			end
		end
	end
	return send_data;
end

--global parameters to request the http,saving for a map.
