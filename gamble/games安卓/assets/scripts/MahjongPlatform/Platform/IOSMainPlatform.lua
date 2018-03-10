--[[
	className    	     :  IOSMainPlatform
	Description  	     :  平台类-子类(ios))
	last-modified-date   :  Feb.12 2014
	create-time 	     :  Feb.12 2014
	last-modified-author :  ClarkWu
	create-author        :  ClarkWu
]]
require("MahjongCommon/CustomNode");
--
require("MahjongPlatform/Platform/BasePlatform");

IOSMainPlatform = class(BasePlatform);

IOSMainPlatform.openMutiPay = 0;   -- 默认关闭多重支付

IOSMainPlatform.ctor = function ( self)
	self.curDefaultPmode = 99; --默认为支付宝的商品

	-- 该表标识了该平台下支持的所有支付方式--5.21需求去掉新浪登录和通行证登录
	self.m_loginTable = {
			--PlatformConfig.SinaLogin,
            PlatformConfig.CellphoneLogin,
            PlatformConfig.WeChatLogin,
			PlatformConfig.QQLogin,
			--PlatformConfig.BoyaaLogin,
			PlatformConfig.GuestLogin,

		};
    if DEBUGMODE == 1 then
        table.insert(self.m_loginTable, PlatformConfig.NewGuestLogin);
    end

	self.logins = {};

end

IOSMainPlatform.isCancelBindBtn = function(self)
	return true;
end

IOSMainPlatform.isLianYunNotChannel = function(self)
	return false;
end

IOSMainPlatform.returnIsLianyunName = function(self)
	if GameConstant.iosDeviceType==1 then
		return tostring(PlatformConfig.feedback_platform_IOS_IPHONE);
	end
	return PlatformConfig.feedback_platform_IOS_IPAD;
end

IOSMainPlatform.getPlatformAPI = function ( self )
	if GameConstant.iosDeviceType==1 then
		return tostring(PlatformConfig.API_IOS_IPHONE);
	end
	return tostring(PlatformConfig.API_IOS_IPAD);
end

IOSMainPlatform.getLoginAppId = function( self, loginType )
	return "117";
end

IOSMainPlatform.feedbackGameAppID = function(self)
	if GameConstant.iosDeviceType==1 then
		return "2011";
	end
	return "3005";
end

IOSMainPlatform.getDefaultLoginMethod = function ( self )
	local loginType = g_DiskDataMgr:getAppData(kLastLoginType, PlatformConfig.GuestLogin);
	return loginType;
end

IOSMainPlatform.changeLoginMethod = function(self,loginMethod)
	if not self.logins[loginMethod] then
		self.logins[loginMethod] = new(self.getLoginMethodCls(loginMethod) or
			self.getLoginMethodCls(PlatformConfig.GuestLogin));
	end
	return self.logins[loginMethod];
end

IOSMainPlatform.getLoginView = function (self)
	return new(TrunkPlatformView,self.m_loginTable);
end

--返回该平台对应的强制更新界面、首冲大礼包、普通更新界面、公告、签到界面的level
--强更>首冲>普更>公告>签到
IOSMainPlatform.getPlatformLevel = function(self)
	return 20000,15000,10000,8000,6000;
end
--*****************************************************View平台界面********************************************************************************--
--[[
	className    	     :  TrunkPlatformView
	Description  	     :  平台界面类
	last-modified-date   :  Dec.2  2013
	create-time 	     :  Oct.22 2013
	last-modified-author :  ClarkWu
	create-author        :  ClarkWu
]]
TrunkPlatformView = class(BasePlatformView);

--[[
	function name	   : TrunkPlatformView.createGuestBtn
	description  	   : create the Button of the guest.
	param 	 	 	   : self
	last-modified-date : Dec. 2 2013
	create-time  	   : Oct.22 2013
]]
TrunkPlatformView.createGuestBtn = function ( self )
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

TrunkPlatformView.createNewGuestBtn = function ( self )
	local btn = nil;
	local btnData = CreatingViewUsingData.switchLoginView.vistorLoginBtn;
	btn = UICreator.createBtn(btnData.fileName, btnData.x, btnData.y, self, function ( self )
		require("MahjongLogin/CreateUserWindow")
		local win = new(CreateUserWindow)
		win:addToRoot()
		win:showWnd()

		self:closeSelf()
		self = nil;
		--self:onClick(PlatformConfig.NewGuestLogin);
	end);
	local text = UICreator.createText("创建新游客", 0, -36, 150, 32, kAlignCenter, 28,  75, 43, 28);
	text:setAlign(kAlignBottom);
	btn:addChild(text);
	return btn;
end

--[[
	function name	   : TrunkPlatformView.createQQBtn
	description  	   : create the Button of the QQ.
	param 	 	 	   : self
	last-modified-date : Dec. 2 2013
	create-time  	   : Oct.22 2013
]]
TrunkPlatformView.createQQBtn = function ( self )
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
	function name	   : TrunkPlatformView.createSinaBtn
	description  	   : create the Button of the Sina.
	param 	 	 	   : self
	last-modified-date : Dec. 2 2013
	create-time  	   : Oct.22 2013
]]
TrunkPlatformView.createSinaBtn = function ( self )
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
	function name	   : TrunkPlatformView.createBoyaaBtn
	description  	   : create the Button of the Boyaa.
	param 	 	 	   : self
	last-modified-date : Dec. 2 2013
	create-time  	   : Oct.22 2013
]]
TrunkPlatformView.createBoyaaBtn = function ( self )
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
	function name	   : TrunkPlatformView.createWeChatBtn
	description  	   : create the Button of the WeChat.
	param 	 	 	   : self
	last-modified-date : Dec. 2 2013
	create-time  	   : Oct.22 2013
]]
TrunkPlatformView.createWeChatBtn = function ( self )
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
TrunkPlatformView.createCellphoneBtn = function ( self )
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
TrunkPlatformView.loginBtnCreateFunMap = {
	[PlatformConfig.SinaLogin] 	= TrunkPlatformView.createSinaBtn,
	[PlatformConfig.QQLogin] 	= TrunkPlatformView.createQQBtn,
	[PlatformConfig.BoyaaLogin] = TrunkPlatformView.createBoyaaBtn,
	[PlatformConfig.WeChatLogin]= TrunkPlatformView.createWeChatBtn,
	[PlatformConfig.GuestLogin] = TrunkPlatformView.createGuestBtn,
	[PlatformConfig.NewGuestLogin] = TrunkPlatformView.createNewGuestBtn,
    [PlatformConfig.CellphoneLogin] = TrunkPlatformView.createCellphoneBtn
};
