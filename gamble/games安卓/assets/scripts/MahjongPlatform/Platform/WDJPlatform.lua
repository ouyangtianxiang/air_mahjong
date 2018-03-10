--[[
	className    	     :  WDJPlatform
	Description  	     :  平台类-子类(豌豆荚平台))
	last-modified-date   :  Dec.2  2013
	create-time 	     :  Oct.22 2013
	last-modified-author :  ClarkWu
	create-author        :  ClarkWu
]]
--
require("MahjongPlatform/Platform/BasePlatform");

WDJPlatform = class( BasePlatform );

WDJPlatform.ctor = function ( self)
	self.curDefaultPmode = 218;
	self.otherPmode = 235;
	self.m_loginMethods = {};
	-- self.paymentTable = { BasePay.PAY_TYPE_MOBILEMM, BasePay.PAY_TYPE_UNICOM, BasePay.PAY_TYPE_EGAME};
	self.m_loginTable = { PlatformConfig.GuestLogin,PlatformConfig.WandouLogin};

	PayConfigDataManager.getInstance().m_verData = {
		PlatformConfig.WDJMMPay,PlatformConfig.WDJUnicomPay,PlatformConfig.WDJEgamePay,PlatformConfig.MobilePay
	};--支付方式

	PayConfigDataManager.getInstance().m_defaultPayData = {};
end

WDJPlatform.dtor = function ( self )
end

WDJPlatform.returnIsLianyunName = function(self)
	return PlatformConfig.feedback_platform_WDJ;
end

WDJPlatform.isNeedPostApiHost = function(self)
	return true;
end

WDJPlatform.getUnicomChannelId = function( self)
	return "00018756";
end


-- 获取应用APPID信息
-- @Override
WDJPlatform.getLoginAppId = function( self, loginType )
	return "7227"; 
end


WDJPlatform.getLoginView = function (self)
	return new(WDJPlatformView,self.m_loginTable);
end

WDJPlatform.getDefaultLoginMethod = function ( self )
	local loginType = g_DiskDataMgr:getAppData(kLastLoginType, PlatformConfig.GuestLogin);
	return loginType;
end

WDJPlatform.changeLoginMethod = function(self,loginMethod)
	if loginMethod and not self.m_loginMethods[loginMethod] then 
		self.m_loginMethods[loginMethod] = new(self.getLoginMethodCls(loginMethod) or GuestLogin);
	end
	return self.m_loginMethods[loginMethod];
end

--*****************************************************View平台界面********************************************************************************--
--[[
	className    	     :  WDJPlatformView
	Description  	     :  平台界面类
	last-modified-date   :  Dec.2  2013
	create-time 	     :  Oct.22 2013
	last-modified-author :  ClarkWu
	create-author        :  ClarkWu
]]
WDJPlatformView = class(BasePlatformView);


--[[
	function name	   : WDJPlatformView.onClick
	description  	   : Destruct the class.
	param 	 	 	   : self
	last-modified-date : Dec. 2 2013
	create-time  	   : Oct.22 2013
]]
WDJPlatformView.onClick = function(self,loginMethod)
	local flag = false;
	if loginMethod == PlatformFactory.curPlatform.curLoginType then
		PlatformFactory.curPlatform:logout();
		flag = false;
	else
		flag = true;
		PlatformFactory.curPlatform:clearCurUserGameData();
	end
	if flag then 
		PlatformFactory.curPlatform:login(loginMethod,true);
	else
		PlatformFactory.curPlatform:login(loginMethod);
	end
	delete(self);
	self = nil;
end

--[[
	function name	   : WDJPlatformView.createGuestBtn
	description  	   : create the Button of the guest.
	param 	 	 	   : self
	last-modified-date : Dec.18 2013
	create-time  	   : Dec.18 2013
]]
WDJPlatformView.createGuestBtn = function ( self )
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

--[[
	function name	   : WDJPlatformView.createWandouBtn
	description  	   : create the Button of the wandou.
	param 	 	 	   : self
	last-modified-date : Dec.18 2013
	create-time  	   : Dec.18 2013
]]
WDJPlatformView.createWandouBtn = function ( self )
	local btn = nil;
	local btnData = CreatingViewUsingData.switchLoginView.wandouLoginBtn;
	btn = UICreator.createBtn(btnData.fileName, btnData.x, btnData.y, self, function ( self )
		self:onClick(PlatformConfig.WandouLogin);
	end);
	local text = UICreator.createText(btnData.text, 0, -36, 150, 32, kAlignCenter, 28, 75, 43, 28);
	text:setAlign(kAlignBottom);
	btn:addChild(text);
	return btn;
end

--奇虎平台的登录方式列表
WDJPlatformView.loginBtnCreateFunMap = {
	[PlatformConfig.GuestLogin] = WDJPlatformView.createGuestBtn,
	[PlatformConfig.WandouLogin] = WDJPlatformView.createWandouBtn,
};