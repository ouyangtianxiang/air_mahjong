--[[
	className    	     :  BoyaaLogin
	Description  	     :  登录类-子类(博雅通行证登录和注册))
	last-modified-date   :  Dec.23 2013
	create-time 	     :  Oct.29 2013
	last-modified-author :  ClarkWu
	create-author        :  ClarkWu
]]
require("MahjongLogin/LoginMethod/BaseLogin");

local boyaaview = require(ViewLuaPath.."boyaaview");

BoyaaLogin = class(BaseLogin);

--[[
	function name      : BoyaaLogin.ctor
	description  	   : @Override 
	param 	 	 	   : self
	last-modified-date : Dec.23  2013
	create-time		   : Dec.23  2013
]]
BoyaaLogin.ctor = function (self,data )
	self.m_loginMethod = PlatformConfig.BoyaaLogin;
end

BoyaaLogin.getLoginUserName = function(self)
	return CreatingViewUsingData.commonData.userIdentityBoyaa;
end
BoyaaLogin.getLoginType = function(self)
	return PlatformConfig.BoyaaLogin;
end
--[[
	function name      : BoyaaLogin.login
	description  	   : @Override 
	param 	 	 	   : self
	last-modified-date : Nov.29 2013
	create-time		   : Nov.29 2013
]]
BoyaaLogin.login = function ( self, ... )
	umengStatics_lua(kUmengBoyaaLogin);
	local params = ...;
	self.m_data = kBoyaaLoginConfig;
	PlatformFactory.curPlatform:setAPI(PlatformConfig.BoyaaLogin);
	local saveBid  = g_DiskDataMgr:getAppData(kBoyaaLoginBid);
	local nickName = g_DiskDataMgr:getAppData(kBoyaaLoginNick);
	local sitemid  = g_DiskDataMgr:getAppData(kBoyaaLoginSid);

	-- if DEBUGMODE == 1 then 
		-- Banner.getInstance():showMsg("lastLogin" .. GameConstant.lastLoginType);
	-- end
	if GameConstant.lastLoginType ~= PlatformConfig.BoyaaLogin and 
		saveBid and saveBid ~= kNullStringStr and saveBid ~= kNumStrZero then 
		GameConstant.isBidBoyaaLogin = kIsBoyaaBide;
		GameConstant.saveBid = saveBid;
		GameConstant.imei =	sitemid;
		GameConstant.name = nickName;
		self:OnRequestLoginPHP(self:setSendLoginPHPdata());

	else
		self.boyaaloginView = new(BoyaaLoginWindow,self);
		self.boyaaloginView:showWnd();
		self.boyaaloginView:setLevel(10005);
		if HallScene_instance and HallScene_instance.m_mainView then 
			HallScene_instance.m_mainView:addChild(self.boyaaloginView);
		end

		if isPlatform_Win32() then 
			GameConstant.isBidBoyaaLogin = kIsBoyaaBide;
			GameConstant.bid = self.m_data.boyaaDefaultBid;
			GameConstant.email = self.m_data.boyaaDefaultEmail;
			GameConstant.phone = self.m_data.boyaaDefaultPhone;
	    	GameConstant.deviceType = self.m_data.boyaaDefaultDeviceType;
	    	GameConstant.sig = self.m_data.boyaaDefaultSig; 
	    	GameConstant.avatar = self.m_data.boyaaDefaultAvatar;
	    	GameConstant.city = self.m_data.boyaaDefaultCity;
	    	GameConstant.code = self.m_data.boyaaDefaultCode;
	    	GameConstant.country = self.m_data.boyaaDefaultCountry;
	    	GameConstant.gender = self.m_data.boyaaDefaultGender;
	    	GameConstant.province = self.m_data.boyaaDefaultProvince;
	    	GameConstant.imei=self.m_data.boyaaDefaultImei;
			GameConstant.name=self.m_data.boyaaDefaultName;
			self:OnRequestLoginPHP(self:setSendLoginPHPdata());
		else 
			self.m_data.loginType = PlatformConfig.BoyaaLogin; 
			self.m_data.imei = GameConstant.imei
			native_muti_login(self.m_data)
		end
	end
end

--[[
	function name      : BoyaaLogin.requestLoginCallBack
	description  	   : @Override 
	param 	 	 	   : self
	last-modified-date : Nov.29 2013
	create-time		   : Nov.29 2013
]]
BoyaaLogin.requestLoginCallBack = function (self, isSuccess, data)
	GameConstant.isBidBoyaaLogin = kIsBoyaaBide;
	GameConstant.requestLogin = false;
	PlatformFactory.curPlatform:setAPI(PlatformConfig.BoyaaLogin);
	if isSuccess then 
		DebugLog("BoyaaLogin success! status = " .. tostring(GetNumFromJsonTable(data,kStatus)));
		local msg;
		if kNumOne ==  GetNumFromJsonTable(data,kStatus) then
			GameConstant.isLogin = kAlreadyLogin;
			if GetStrFromJsonTable(data,kSavedBid) and kNullStringStr ~= GetStrFromJsonTable(data,kSavedBid) then 
				g_DiskDataMgr:setAppData(kBoyaaLoginBid,GetStrFromJsonTable(data,kSavedBid));
				g_DiskDataMgr:setAppData(kBoyaaLoginNick,data.userinfo.mnick);
				g_DiskDataMgr:setAppData(kBoyaaLoginSid,data.userinfo.sitemid);

				--DebugLog("BoyaaLogin success! save " .. GetStrFromJsonTable(data,kSavedBid) .. data.userinfo.mnick .. data.userinfo.sitemid);
			end
			GameConstant.lastLoginType = PlatformConfig.BoyaaLogin;
			EventDispatcher.getInstance():dispatch(BaseLogin.loginResuleEvent,isSuccess,data);
			--DebugLog("BoyaaLogin success! save " .. GetStrFromJsonTable(data,kSavedBid) .. data.userinfo.mnick .. data.userinfo.sitemid);
			--if kIsBoyaaBide == GameConstant.isBidBoyaaLogin then 
				-- if kNumOne == GetNumFromJsonTable(data,kGuestBided) then 
				-- 	Banner.getInstance():showMsg(PromptMessage.firstBidBoyaa);
				-- end --不需要赠送
			--end
		elseif kNumMinusTwo ==  GetNumFromJsonTable(data,kStatus)  then 
			msg = PromptMessage.failLoginNeedReloginBoyaa;
			if GameConstant.isBidBoyaaLogin == kIsBoyaaBide then
        		GameConstant.isBidBoyaaLogin = kNotBoyaaBide;
			end
			GameConstant.isLogin = kNoLogin;
		elseif kNumMinusHundred ==  GetNumFromJsonTable(data,kStatus) then 
			msg = PromptMessage.failLoginBoyaaDataError;
			if GameConstant.isBidBoyaaLogin == kIsBoyaaBide then
        		GameConstant.isBidBoyaaLogin = kNotBoyaaBide;
			end
			GameConstant.isLogin = kNoLogin;
		else
			msg = GetStrFromJsonTable(data,kMsg);
			if GameConstant.isBidBoyaaLogin == kIsBoyaaBide then
        		GameConstant.isBidBoyaaLogin = kNotBoyaaBide;
			end
			GameConstant.isLogin = kNoLogin;
		end
		if msg ~= nil and kNullStringStr ~= msg then 
			Banner.getInstance():showMsg(msg);
		end
	else
		GameConstant.isLogin = kNoLogin;
		Banner.getInstance():showMsg(PromptMessage.loginFailed);
		g_DiskDataMgr:setAppData(kBoyaaLoginBid,kNumStrZero);
	    g_DiskDataMgr:setAppData(kBoyaaLoginNick,kNumStrZero);
	    g_DiskDataMgr:setAppData(kBoyaaLoginSid,kNumStrZero);
	end

	

end

BoyaaLogin.getLoginIdentityIcon = function(self)
	return "Login/boyaaIcon.png";
end

BoyaaLogin.callEvent = function(self, key, data)
	self.super.callEvent(self, key, data);
end

--[[
	function name      : BoyaaLogin.callEvent
	description  	   : @Override 
	param 	 	 	   : self
	last-modified-date : Nov.29 2013
	create-time		   : Nov.29 2013
]]
BoyaaLogin.loginCallback = function(self,json_data)
	-- 游客登录
	if kNumOne == tonumber(GetNumFromJsonTable(json_data,kBoyaaGuest)) then 
		self:clearGameData();
		GameConstant.isBidBoyaaLogin = kNotBoyaaBide;
		
		PlatformFactory.curPlatform:login(PlatformConfig.GuestLogin);
			
    else
	    GameConstant.isBidBoyaaLogin = kIsBoyaaBide;
		GameConstant.bid  			 = GetNumFromJsonTable(json_data,kBoyaaBid, ""); 
		GameConstant.email 			 = GetStrFromJsonTable(json_data,kBoyaaEmail, "");
		GameConstant.phone 			 = GetStrFromJsonTable(json_data,kBoyaaPhone, "");
	    GameConstant.deviceType 	 = GetStrFromJsonTable(json_data,kBoyaaDevideType, "");
	    GameConstant.sig 			 = GetStrFromJsonTable(json_data,kBoyaaSig, ""); 
	    GameConstant.avatar 		 = GetStrFromJsonTable(json_data,kBoyaaAvatar, "");
	    GameConstant.city 			 = GetStrFromJsonTable(json_data,kBoyaaCity, "");
	    GameConstant.code 			 = GetNumFromJsonTable(json_data,kBoyaaCode, "");
	    GameConstant.country 		 = GetStrFromJsonTable(json_data,kBoyaaCountry, "");
	    GameConstant.gender 		 = GetNumFromJsonTable(json_data,kBoyaaGender, "");
	    GameConstant.province 		 = GetStrFromJsonTable(json_data,kBoyaaProvince, "");

		if GetStrFromJsonTable(json_data,kLoginSid) and kNullStringStr ~= GetStrFromJsonTable(json_data,kLoginSid) then
			self.m_sitemid = GetStrFromJsonTable(json_data,kLoginSid);
		end

		if GetStrFromJsonTable(json_data,kLoginName) and kNullStringStr ~= GetStrFromJsonTable(json_data,kLoginName) then
			self.m_nickName = GetStrFromJsonTable(json_data,kLoginName);
		end
			
		if self.m_sitemid == kNullStringStr and self.m_nickName == kNullStringStr then 
			return;
		end
		
		local sendData = self:setSendLoginPHPdata()
		self:OnRequestLoginPHP(sendData);
    end

    -- self.boyaaloginView:hideWnd();
end

--[[
	function name      : BoyaaLogin.logout
	description  	   : 博雅通行证登出的信息
	param 	 	 	   : self
	last-modified-date : Nov.29 2013
	create-time		   : Nov.29 2013
]]
BoyaaLogin.logout = function(self)
	DebugLog("BoyaaLogin.logout")
	self.super.logout( self );
	GameConstant.isBidBoyaaLogin = kNotBoyaaBide;
	--g_DiskDataMgr:setAppData(kBoyaaLoginBid,kNumStrZero,true);
	--g_DiskDataMgr:setAppData(kBoyaaLoginNick,kNumStrZero,true);
	--g_DiskDataMgr:setAppData(kBoyaaLoginSid,kNumStrZero,true);
	GameConstant.saveBid = nil;
end

--[[
	function name      : BoyaaLogin.clearGameData
	description  	   : 清除博雅登陆的信息
	param 	 	 	   : self
	last-modified-date : Nov.29 2013
	create-time		   : Nov.29 2013
]]
BoyaaLogin.clearGameData = function(self)

	GameConstant.isBidBoyaaLogin = kNotBoyaaBide;
	GameConstant.bid = nil; 
	GameConstant.email =nil;
	GameConstant.phone = nil;
    GameConstant.deviceType = nil;
    GameConstant.sig = nil; 
    GameConstant.avatar = nil;
    GameConstant.city = nil;
    GameConstant.code = nil;
    GameConstant.country = nil;
    GameConstant.gender = nil;
    GameConstant.province = nil;
	-- GameConstant.imei = nil;
	-- GameConstant.name = nil;
	GameConstant.saveBid = nil;

	self.super.clearGameData( self );
end

--[[
	function name      : BoyaaLogin.setSendLoginPHPdata
	description  	   : @Override 
	param 	 	 	   : self
	last-modified-date : Nov.29 2013
	create-time		   : Nov.29 2013
]]
BoyaaLogin.setSendLoginPHPdata = function(self)
	local send_data = {};
	local localtoken = g_DiskDataMgr:getAppData(kLocalToken .. PlatformConfig.BoyaaLogin,"");
	--如果之前博雅通行证登录过
	if GameConstant.saveBid and  kNullStringStr ~= GameConstant.saveBid then 
		send_data.savedBid = GameConstant.saveBid;
		send_data.nick = self.m_nickName;
		send_data.sitemid = self.m_sitemid;
		send_data.macAddress = GameConstant.macAddress;
		send_data.localtoken = localtoken;

	--没有登录过
	else
		send_data.nick = self.m_nickName;
		send_data.sitemid = self.m_sitemid;
		send_data.boyaaUser = {};
		send_data.boyaaUser.bid = GameConstant.bid;
	    send_data.boyaaUser.email = GameConstant.email;
	    send_data.boyaaUser.phone = GameConstant.phone;
	    send_data.boyaaUser.type = GameConstant.deviceType;
		send_data.boyaaUser.accesstoken = GameConstant.sig;
		send_data.boyaaUser.avatar = GameConstant.avatar;
		send_data.boyaaUser.city = GameConstant.city;
		send_data.boyaaUser.code = GameConstant.code;
		send_data.boyaaUser.country = GameConstant.country;
		send_data.boyaaUser.gender = GameConstant.gender;
		send_data.boyaaUser.province = GameConstant.province;
		send_data.localtoken = localtoken;
	end
	return send_data;
end

BoyaaLoginWindow = class(SCWindow);

BoyaaLoginWindow.ctor = function ( self,loginController)
	if not loginController then 
		return ;
	end

	self.m_loginController = loginController;
	
	self.layout = SceneLoader.load(boyaaview);
    self:addChild(self.layout);

    self.bg = publ_getItemFromTree(self.layout, {"bg"});
    self:setWindowNode( self.bg );
	self:setCoverEnable(true)

    self.m_account = publ_getItemFromTree(self.layout,{"bg","account","account_infoview","account"});
    self.m_password = publ_getItemFromTree(self.layout,{"bg","password","password_infoview","password"});

    self.m_account:setHintText("手机号/邮箱/博雅号");
    self.m_password:setHintText("请输入密码");
    self.m_password:setEventTouch(self, function ( self, finger_action, x, y, drawing_id_first, drawing_id_current )
		if finger_action == kFingerDown then

		    self.m_password.m_startX = x;
		    self.m_password.m_startY = y;
		    self.m_password.m_touching = true;
		elseif finger_action == kFingerUp then
		    if not self.m_password.m_touching then return end;

		    self.m_password.m_touching = false;
		    
		    local diffX = math.abs(x - self.m_password.m_startX);
		    local diffY = math.abs(y - self.m_password.m_startY);
		    if diffX > self.m_password.m_maxClickOffset 
		    	or diffY > self.m_password.m_maxClickOffset 
		    	or (not self.m_password.m_enable) 
		    	or (drawing_id_first ~= drawing_id_current) then
		        return;
		    end

		    EditTextGlobal = self.m_password;
			-- ime_open_edit(self.m_password_txt or "",
			-- 	"",
			-- 	kEditBoxInputModeSingleLine,
			-- 	kEditBoxInputFlagInitialCapsSentence,
			-- 	kKeyboardReturnTypeDone,
			-- 	self.m_password.m_maxLength or -1,"global");

    	local x,y = self.m_password:getAbsolutePos();
        local actualX= x * System.getLayoutScale();
        local actualY= y * System.getLayoutScale();


        local w,h = self.m_password:getSize();
        local actualW= w * System.getLayoutScale();
        --local actualH= h * System.getLayoutScale();
        local actualH = 0;
        local fontName = self.m_password.m_fontName or "";
         local fontSize = (self.m_password.m_res.m_fontSize or 24)* System.getLayoutScale();

			ime_open_edit(self.m_password:getText() or "",
				"",
				kEditBoxInputModeSingleLine,
				kEditBoxInputFlagInitialCapsSentence,
				kKeyboardReturnTypeDone,
				self.m_password.m_maxLength or -1,"global",fontName,fontSize,
               	self.m_password.m_textColorR,	self.m_password.m_textColorG,	self.m_password.m_textColorB,
                actualX,actualY,actualW,actualH);
	    end
	end);

	self.m_account:setOnTextChange(self, function ( self )
		local str = publ_trim(self.m_account:getText());
		local len = string.len(str);
		if len ~= 0 then 
			self.m_account:setText(str);
		else
			self.m_account:setText("手机号/邮箱/博雅号");
		end
	end);

	self.m_password:setOnTextChange(self, function ( self )
		local str = publ_trim(self.m_password:getText());
		self.m_password_txt = str;
		local len = string.len(str);
		local str = "";
		for i=1,len do 
			str = str .. "*";
		end
		if len ~= 0 then 
			self.m_password:setText(str);
		else
			self.m_password:setText("请输入密码");
		end
	end);

    self.m_loginBtn = publ_getItemFromTree(self.layout,{"bg","login"});

    self.m_loginBtn:setOnClick(self,self.onLoginClickBtn);

    self.m_isRemebered = publ_getItemFromTree(self.layout,{"bg","thirdline","rememberPwdField","rememberPwd","CheckBox1"});

    self.m_isRemebered:setChecked(true);

    self.m_forgetText = publ_getItemFromTree(self.layout,{"bg","thirdline","TextView1"});

	self.m_forgetText:setEventTouch(self,self.onForgetTextBtn);

	local islogin  = g_DiskDataMgr:getAppData("islogin",0);
    local account  = g_DiskDataMgr:getAppData("account", "" );
	local password = g_DiskDataMgr:getAppData("password", "");

	if account ~= "" and account ~= " " then
		self.m_account:setText(account);
	end

	if islogin == 0 then 
		self.m_isRemebered:setChecked(false);
	else
		self.m_isRemebered:setChecked(true);
		if password ~= "" and password ~= " " then 
			self.m_password_txt = password;

			local len = string.len(self.m_password_txt);
			local str = "";
			for i=1,len do 
				str = str .. "*";
			end
			if len ~= 0 then 
				self.m_password:setText(str);
			else
				self.m_password:setText("请输入密码");
			end
		end
	end

	if PlatformConfig.platformWDJ == GameConstant.platformType or 
        PlatformConfig.platformWDJNet == GameConstant.platformType then 
		self.bg:setFile("Login/wdj/Hall/Commonx/pop_window_small.png");
	end
	
end

BoyaaLoginWindow.onLoginClickBtn = function(self)
	local account = self.m_account:getText();

	local islogin = self.m_isRemebered:isChecked() and 1 or 0;

	local password = self.m_password_txt or "";

	if account == "" or account == " " then 
		Banner.getInstance():showMsg("用户名不能为空!");
		return ;
	end

	if password == "" or password == " " then 
		Banner.getInstance():showMsg("密码不能为空!");
		return ;
	end

	g_DiskDataMgr:setAppData("account", account );
	g_DiskDataMgr:setAppData("islogin", islogin);

	if islogin == 1 then 
		g_DiskDataMgr:setAppData("password", password );
	end

	-- if isPlatform_Win32() then 
		-- GameConstant.isBidBoyaaLogin = kIsBoyaaBide;
		-- GameConstant.bid = self.m_loginController.m_data.boyaaDefaultBid;
		-- GameConstant.email = self.m_loginController.m_data.boyaaDefaultEmail;
		-- GameConstant.phone = self.m_loginController.m_data.boyaaDefaultPhone;
	 --    GameConstant.deviceType = self.m_loginController.m_data.boyaaDefaultDeviceType;
	 --    GameConstant.sig = self.m_loginController.m_data.boyaaDefaultSig; 
	 --    GameConstant.avatar = self.m_loginController.m_data.boyaaDefaultAvatar;
	 --    GameConstant.city = self.m_loginController.m_data.boyaaDefaultCity;
	 --    GameConstant.code = self.m_loginController.m_data.boyaaDefaultCode;
	 --    GameConstant.country = self.m_loginController.m_data.boyaaDefaultCountry;
	 --    GameConstant.gender = self.m_loginController.m_data.boyaaDefaultGender;
	 --    GameConstant.province = self.m_loginController.m_data.boyaaDefaultProvince;
	 --    GameConstant.imei=self.m_loginController.m_data.boyaaDefaultImei;
		-- GameConstant.name=self.m_loginController.m_data.boyaaDefaultName;
		-- self.m_loginController:OnRequestLoginPHP(self.m_loginController:setSendLoginPHPdata());
		-- self:hideWnd();
	-- else
		
		local param = {};
		param.loginType = PlatformConfig.BoyaaLogin;
		param.type = "account=" .. account .. ";password=" .. password;
		param.imei = GameConstant.imei
		native_muti_login(param)

		self:hideWnd();
	-- end
end

BoyaaLoginWindow.onForgetTextBtn = function(self)
	self:setOnWindowHideListener(self,self.onRequestJava);
	self:setAutoRemove(false);
	self:hideWnd();
	-- self.m_time = os.time();
	-- if self.lasttime then 
	-- 	if self.lasttime - self.m_time < 10 then 
	-- 		return;
	-- 	end
	-- end
	-- self.lasttime = self.m_time;
	-- local param = {};
	-- param.loginType = PlatformConfig.BoyaaLogin; 
	-- param.type = "-1"; -- 忘记密码
	-- native_muti_login(param);
end

BoyaaLoginWindow.onRequestJava = function(self)
	self.setOnWindowHideListener(self,nil);
	self.m_time = os.time();
	if self.lasttime then 
		if self.lasttime - self.m_time < 10 then 
			return;
		end
	end
	self.lasttime = self.m_time;
	local param = {};
	param.loginType = PlatformConfig.BoyaaLogin; 
	param.type = "-1"; -- 忘记密码
	param.imei = GameConstant.imei

	native_muti_login(param)
end


