--[[
	className    	     :  ZhuoYiPlatform
	Description  	     :  平台类-子类(主平台))
	last-modified-date   :  Dec.2  2013
	create-time 	     :  Oct.22 2013
	last-modified-author :  ClarkWu
	create-author        :  ClarkWu
]]
--
require("MahjongPlatform/Platform/BasePlatform");

ZhuoYiPlatform = class(BasePlatform);

--[[
	function name	   : ZhuoYiPlatform.ctor
	description  	   : Construct a class.
	param 	 	 	   : self
						 api          -- Number    Every platform has different api.
						 loginTable   -- Table     Every platform has different login methods.  
	last-modified-date : Oct.22 2013
	create-time  	   : Oct.22 2013
]]
ZhuoYiPlatform.ctor = function ( self)
	self.curDefaultPmode = 4; --默认为支付宝的商品

	-- 该表标识了该平台下支持的所有支付方式

	if DEBUGMODE == 1 then
		self.m_loginTable = {
			PlatformConfig.NewGuestLogin,
			PlatformConfig.QQLogin,
			-- PlatformConfig.BoyaaLogin,
			PlatformConfig.GuestLogin,
			PlatformConfig.CellphoneLogin
		};
	else
		self.m_loginTable = {
			PlatformConfig.QQLogin,
			-- PlatformConfig.BoyaaLogin,
			PlatformConfig.GuestLogin,
			PlatformConfig.CellphoneLogin
		};
	end

	self.logins = {};

end

-- 获取应用APPID信息
-- @Override
ZhuoYiPlatform.getLoginAppId = function( self, loginType )
	return "186";
end

--是否要调用平台自己的离开方法
ZhuoYiPlatform.isUsePlatformExit = function(self)
	if PlayerManager.getInstance():myself().mid <= 0 or GameConstant.isShowAwardView == 0 then 
		return false;
	end
	if GameConstant.isShowAwardView == 1 then 
		local mid = PlayerManager.getInstance():myself().mid or "";
		local old_day = g_DiskDataMgr:getUserData(mid,'showAwardExit',1)
		local today = os.date("%Y%m%d");
		if today - old_day >= 1 then 
			g_DiskDataMgr:setUserData(mid,'showAwardExit',os.date("%Y%m%d"))
			return true;
		else
			return false;
		end
	end

end

ZhuoYiPlatform.getUnicomChannelId = function( self)
	return "00023080";
end

ZhuoYiPlatform.isCancelBindBtn = function(self)
	return true;
end


--[[
	function name	   : ZhuoYiPlatform.dtor
	description  	   : Destructor a class.
	param 	 	 	   : self
	last-modified-date : Oct.22 2013
	create-time  	   : Oct.22 2013
]]
ZhuoYiPlatform.dtor = function ( self )
end

ZhuoYiPlatform.returnIsLianyunName = function(self)
	return PlatformConfig.feedback_platform_Trunk;
end

--[[
	function name	   : QihuPlatform.getLoginView
	description  	   : @Override.
	param 	 	 	   : self
	last-modified-date : Nov.29 2013
	create-time  	   : Nov.29 2013
]]
ZhuoYiPlatform.getLoginView = function (self)
	return new(ZhuoYiPlatformView,self.m_loginTable);
end

--是否显示绑定博雅通行证
ZhuoYiPlatform.isNeedToShowBYPassCard = function ( self )
	-- body
	DebugLog("ZhuoYiPlatform.isNeedToShowBYPassCard")
	if self:getCurrentLoginType() == PlatformConfig.GuestLogin then

		local loginUtil = self.loginUtls[PlatformConfig.GuestLogin];
		if loginUtil and loginUtil.visitorBounded then
			DebugLog("return false")
			return false;
		end
		DebugLog("return true")
		return true;
		
	end
	DebugLog("return nil")
end

--[[
	function name	   : ZhuoYiPlatform.getDefaultLoginMethod
	description  	   : @Override.
	param 	 	 	   : self
	last-modified-date : Oct.22 2013
	create-time  	   : Oct.22 2013
]]
ZhuoYiPlatform.getDefaultLoginMethod = function ( self )
	local loginType = g_DiskDataMgr:getAppData(kLastLoginType, PlatformConfig.GuestLogin);
	local exist = self:existLoginType( loginType );
	if exist then
		return loginType;
	else
		return PlatformConfig.GuestLogin;
	end
end

ZhuoYiPlatform.changeLoginMethod = function(self,loginMethod)
	if not self.logins[loginMethod] then
		self.logins[loginMethod] = new(self.getLoginMethodCls(loginMethod) or 
			self.getLoginMethodCls(PlatformConfig.GuestLogin));
	end
	return self.logins[loginMethod];
end

--*****************************************************View平台界面********************************************************************************--
--[[
	className    	     :  ZhuoYiPlatformView
	Description  	     :  平台界面类
	last-modified-date   :  Dec.2  2013
	create-time 	     :  Oct.22 2013
	last-modified-author :  ClarkWu
	create-author        :  ClarkWu
]]
ZhuoYiPlatformView = class(BasePlatformView);

--[[
	function name	   : ZhuoYiPlatformView.createGuestBtn
	description  	   : create the Button of the guest.
	param 	 	 	   : self
	last-modified-date : Dec. 2 2013
	create-time  	   : Oct.22 2013
]]
ZhuoYiPlatformView.createGuestBtn = function ( self )
	local btn = nil;
	local btnData = CreatingViewUsingData.switchLoginView.vistorLoginBtn;
	btn = UICreator.createBtn(btnData.fileName, btnData.x, btnData.y, self, function ( self )
		self:onClick(PlatformConfig.GuestLogin);
	end);
	local text = UICreator.createText(btnData.text, 0, -36, 150, 32, kAlignCenter, 28, 75, 43, 28);
	text:setAlign(kAlignBottom);
	btn:addChild(text);
	return btn;
end

ZhuoYiPlatformView.createNewGuestBtn = function ( self )
	local btn = nil;
	local btnData = CreatingViewUsingData.switchLoginView.vistorLoginBtn;
	btn = UICreator.createBtn(btnData.fileName, btnData.x, btnData.y, self, function ( self )
		self:onClick(PlatformConfig.NewGuestLogin);
	end);
	local text = UICreator.createText("创建新游客", 0, -36, 150, 32, kAlignCenter, 28,  75, 43, 28);
	text:setAlign(kAlignBottom);
	btn:addChild(text);
	return btn;
end

--[[
	function name	   : ZhuoYiPlatformView.createQQBtn
	description  	   : create the Button of the QQ.
	param 	 	 	   : self
	last-modified-date : Dec. 2 2013
	create-time  	   : Oct.22 2013
]]
ZhuoYiPlatformView.createQQBtn = function ( self )
	local btn = nil;
	local btnData = CreatingViewUsingData.switchLoginView.qqLoginBtn;
	btn = UICreator.createBtn(btnData.fileName, btnData.x, btnData.y, self, function ( self )
		self:onClick(PlatformConfig.QQLogin);
	end);
	local text = UICreator.createText(btnData.text, 0, -36, 150, 32, kAlignCenter, 28,  75, 43, 28);
	text:setAlign(kAlignBottom);
	btn:addChild(text);
	return btn;
end

--[[
	function name	   : ZhuoYiPlatformView.createSinaBtn
	description  	   : create the Button of the Sina.
	param 	 	 	   : self
	last-modified-date : Dec. 2 2013
	create-time  	   : Oct.22 2013
]]
ZhuoYiPlatformView.createSinaBtn = function ( self )
	local btn = nil;
	local btnData = CreatingViewUsingData.switchLoginView.sinaLoginBtn;
	btn = UICreator.createBtn(btnData.fileName, btnData.x, btnData.y, self, function ( self )
		self:onClick(PlatformConfig.SinaLogin);
	end);
	local text = UICreator.createText(btnData.text, 0, -36, 150, 32, kAlignCenter, 28, 75, 43, 28);
	text:setAlign(kAlignBottom);
	btn:addChild(text);
	return btn;
end

--[[
	function name	   : ZhuoYiPlatformView.createBoyaaBtn
	description  	   : create the Button of the Boyaa.
	param 	 	 	   : self
	last-modified-date : Dec. 2 2013
	create-time  	   : Oct.22 2013
]]
ZhuoYiPlatformView.createBoyaaBtn = function ( self )
	local btn = nil;
	local btnData = CreatingViewUsingData.switchLoginView.boyaaLoginBtn;
	btn = UICreator.createBtn(btnData.fileName, btnData.x, btnData.y, self, function ( self )
		self:onClick(PlatformConfig.BoyaaLogin);
	end);
	local text = UICreator.createText(btnData.text, 0, -36, 150, 32, kAlignCenter, 28,  75, 43, 28);
	text:setAlign(kAlignBottom);
	btn:addChild(text);
	return btn;
end

--[[
	function name	   : ZhuoYiPlatformView.createWeChatBtn
	description  	   : create the Button of the WeChat.
	param 	 	 	   : self
	last-modified-date : Dec. 2 2013
	create-time  	   : Oct.22 2013
]]
ZhuoYiPlatformView.createWeChatBtn = function ( self )
	local btn = nil;
	local btnData = CreatingViewUsingData.switchLoginView.loginWeChatBtn;
	btn = UICreator.createBtn(btnData.fileName, btnData.x, btnData.y, self, function ( self )
		self:onClick(PlatformConfig.WeChatLogin);
	end);
	local text = UICreator.createText(btnData.text, 0, -36, 150, 32, kAlignCenter, 28, 75, 43, 28);
	text:setAlign(kAlignBottom);
	btn:addChild(text);
	return btn;
end

--创建手机帐号登陆按钮
ZhuoYiPlatformView.createCellphoneBtn = function ( self )
	local btn = nil;
	local btnData = CreatingViewUsingData.switchLoginView.cellphoneLoginBtn;
	btn = UICreator.createBtn(btnData.fileName, btnData.x, btnData.y, self, function ( self )
        GameConstant.isDisplayView = true;
		self:onClick(PlatformConfig.CellphoneLogin);
        
	end);
	local text = UICreator.createText("手机登录", 0, -36, 150, 32, kAlignCenter, 28,  75, 43, 28);
	text:setAlign(kAlignBottom);
	btn:addChild(text);
	return btn;
end


--主平台的登录方式列表
ZhuoYiPlatformView.loginBtnCreateFunMap = {
	[PlatformConfig.SinaLogin] 	= ZhuoYiPlatformView.createSinaBtn,
	[PlatformConfig.QQLogin] 	= ZhuoYiPlatformView.createQQBtn,
	[PlatformConfig.BoyaaLogin] = ZhuoYiPlatformView.createBoyaaBtn,
	[PlatformConfig.WeChatLogin]= ZhuoYiPlatformView.createWeChatBtn,
	[PlatformConfig.GuestLogin] = ZhuoYiPlatformView.createGuestBtn,
	[PlatformConfig.NewGuestLogin] = ZhuoYiPlatformView.createNewGuestBtn,
	[PlatformConfig.CellphoneLogin] = ZhuoYiPlatformView.createCellphoneBtn
};

