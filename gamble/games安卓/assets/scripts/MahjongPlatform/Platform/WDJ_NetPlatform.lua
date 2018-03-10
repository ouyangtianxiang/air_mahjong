require("MahjongPlatform/Platform/BasePlatform");

WDJ_NetPlatform = class( BasePlatform );

WDJ_NetPlatform.ctor = function ( self)
	self.curDefaultPmode = 235;
	self.m_loginMethods = {};
	self.m_loginTable = { PlatformConfig.GuestLogin,PlatformConfig.WandouLogin};

end

WDJ_NetPlatform.dtor = function ( self )
end

WDJ_NetPlatform.returnIsLianyunName = function(self)
	return PlatformConfig.feedback_platform_WDJNet;
end

-- 获取应用APPID信息
-- @Override
WDJ_NetPlatform.getLoginAppId = function( self, loginType )
	return "1146"; 
end

WDJ_NetPlatform.getUnicomChannelId = function( self)
	return "00018756";
end

WDJ_NetPlatform.getLoginView = function (self)
	return new(WDJPlatformView,self.m_loginTable);
end

WDJ_NetPlatform.getDefaultLoginMethod = function ( self )
	local loginType = g_DiskDataMgr:getAppData(kLastLoginType, PlatformConfig.GuestLogin);
	return loginType;
end

WDJ_NetPlatform.changeLoginMethod = function(self,loginMethod)
	if loginMethod and not self.m_loginMethods[loginMethod] then 
		self.m_loginMethods[loginMethod] = new(self.getLoginMethodCls(loginMethod) or GuestLogin);
	end
	return self.m_loginMethods[loginMethod];
end

-- 该平台的应用名称
-- @Override
WDJ_NetPlatform.getApplicationShareName = function( self )
	return "玩玩四川麻将";
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

--豌豆荚平台的登录方式列表
WDJPlatformView.loginBtnCreateFunMap = {
	[PlatformConfig.GuestLogin] = WDJPlatformView.createGuestBtn,
	[PlatformConfig.WandouLogin] = WDJPlatformView.createWandouBtn,
};