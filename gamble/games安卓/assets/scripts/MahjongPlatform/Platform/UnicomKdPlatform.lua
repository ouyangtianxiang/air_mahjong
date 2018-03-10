
--
require("MahjongCommon/CustomNode");
require("MahjongPlatform/Platform/BasePlatform");

UnicomKdPlatform = class(BasePlatform);


UnicomKdPlatform.ctor = function ( self)
	self.curPayType = PlatformConfig.UnicomKdPay;
	self.curDefaultPmode = 251;
	self.m_loginTable = {PlatformConfig.SinaLogin, PlatformConfig.QQLogin, PlatformConfig.BoyaaLogin,PlatformConfig.GuestLogin};
end

UnicomKdPlatform.dtor = function ( self )
end

UnicomKdPlatform.getProductListUrl = function ( self )
	local loginUtl = self:getLoginUtl(self.curLoginType);
	if not loginUtl then 
		return GameConstant.CommonUrl;
	end

	loginUtl.appId = "7040";

	return self.super.getProductListUrl( self );
end

UnicomKdPlatform.getLoginView = function (self)
	return new(UnicomKdPlatformView, self.m_loginTable);
end

--是否显示绑定博雅通行证
UnicomKdPlatform.isNeedToShowBYPassCard = function ( self )
	if self:getCurrentLoginType() == PlatformConfig.GuestLogin then
		return true;
	end
end

UnicomKdPlatform.returnIsLianyunName = function(self)
	return PlatformConfig.feedback_platform_unicomKd;
end

UnicomKdPlatform.getDefaultLoginMethod = function ( self )
	return g_DiskDataMgr:getAppData(kLastLoginType, PlatformConfig.GuestLogin);;
end

-- 是否支持快速充值
UnicomKdPlatform.isSupportQuickRecharge = function ( self )
	return true;
end

UnicomKdPlatform.payUtilCreate = function(self,payType)
	if PlatformConfig.UnicomKdPay ~= payType then
		DebugLog("请检查支付方式，没有对应的payType");
	end
	return new(UnicomKdPayment);
end

UnicomKdPlatform.changeLoginMethod = function(self,loginMethod)
	return new(self.getLoginMethodCls(loginMethod) or GuestLogin);
end

--*****************************************************View平台界面********************************************************************************--
--[[
	className    	     :  UnicomKdPlatformView
	Description  	     :  平台界面类
	last-modified-date   :  Dec.2  2013
	create-time 	     :  Oct.22 2013
	last-modified-author :  ClarkWu
	create-author        :  ClarkWu
]]
UnicomKdPlatformView = class(CustomNode);

--[[
	function name	   : UnicomKdPlatformView.ctor
	description  	   : Construct the class.
	param 	 	 	   : self
	last-modified-date : Dec. 2 2013
	create-time  	   : Oct.22 2013
]]
UnicomKdPlatformView.ctor = function(self, loginTable)
	self.cover:setEventTouch(self , function (self)
		delete(self);
	end);
	self.bg = new(Image, CreatingViewUsingData.switchLoginView.loginBg.fileName, nil, nil, 50, 50, 50, 50);
	self.bg:setSize(800, 500);
	self.bg:setAlign(kAlignCenter);
	self.bg:setEventTouch(self, function ( self )
		
	end);
	self:addChild(self.bg);

	local logoData = CreatingViewUsingData.switchLoginView.logoFile;
	local logoBg = new(Image, logoData.logoBg);
	logoBg:setAlign(kAlignCenter);
	logoBg:setPos(0, -80);
	self.bg:addChild(logoBg);

	local logoData = CreatingViewUsingData.switchLoginView.logoFile;
	local logo = new(Image, logoData.logo);
	logo:setAlign(kAlignCenter);
	logo:setPos(0, -82);
	self.bg:addChild(logo);

	local logoData = CreatingViewUsingData.switchLoginView.logoFile;
	local splite = new(Image, logoData.splite);
	splite:setAlign(kAlignCenter);
	splite:setPos(0, 50);
	self.bg:addChild(splite);


	self.btnView = new(Node);

	local btnArray = {};
	local allLen = kNumZero;
	for k,v in pairs(loginTable) do
		local btn = self.loginBtnCreateFunMap[v](self);
		table.insert(btnArray, btn);
		allLen = allLen + btn.m_width;
	end
	local len = #btnArray;
	local dist = (self.bg.m_width - allLen) / (len + 1);
	local x, y = CreatingViewUsingData.switchLoginView.loginBtn.x, CreatingViewUsingData.switchLoginView.loginBtn.y;
	for k,v in pairs(btnArray) do
		x = x + dist;
		v:setPos(x, y);
		self.btnView:addChild(v);
		x = x + CreatingViewUsingData.switchLoginView.loginBtn.split;
	end

	self.bg:addChild(self.btnView);
end

--[[
	function name	   : UnicomKdPlatformView.dtor
	description  	   : Destruct the class.
	param 	 	 	   : self
	last-modified-date : Dec. 2 2013
	create-time  	   : Oct.22 2013
]]
UnicomKdPlatformView.dtor = function(self)
	CustomNode.hide(self);
	self:removeAllChildren();
end

--[[
	function name	   : UnicomKdPlatformView.onClick
	description  	   : Destruct the class.
	param 	 	 	   : self
	last-modified-date : Dec. 2 2013
	create-time  	   : Oct.22 2013
]]
UnicomKdPlatformView.onClick = function(self, loginMethod)
	if loginMethod == PlatformFactory.curPlatform.curLoginType then
		PlatformFactory.curPlatform:logout();
	else
		PlatformFactory.curPlatform:clearCurUserGameData();
	end
	PlatformFactory.curPlatform:login(loginMethod);
	delete(self);
	self = nil;
end

--[[
	function name	   : UnicomKdPlatformView.createGuestBtn
	description  	   : create the Button of the guest.
	param 	 	 	   : self
	last-modified-date : Dec. 2 2013
	create-time  	   : Oct.22 2013
]]
UnicomKdPlatformView.createGuestBtn = function ( self )
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
	function name	   : UnicomKdPlatformView.createQQBtn
	description  	   : create the Button of the QQ.
	param 	 	 	   : self
	last-modified-date : Dec. 2 2013
	create-time  	   : Oct.22 2013
]]
UnicomKdPlatformView.createQQBtn = function ( self )
	local btn = nil;
	local btnData = CreatingViewUsingData.switchLoginView.qqLoginBtn;
	btn = UICreator.createBtn(btnData.fileName, btnData.x, btnData.y, self, function ( self )
		self:onClick(PlatformConfig.QQLogin);
	end);
	local text = UICreator.createText(btnData.text, 0, -36, 150, 32, kAlignCenter, 28, 75, 43, 28);
	text:setAlign(kAlignBottom);
	btn:addChild(text);
	return btn;
end

--[[
	function name	   : UnicomKdPlatformView.createSinaBtn
	description  	   : create the Button of the Sina.
	param 	 	 	   : self
	last-modified-date : Dec. 2 2013
	create-time  	   : Oct.22 2013
]]
UnicomKdPlatformView.createSinaBtn = function ( self )
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
	function name	   : UnicomKdPlatformView.createBoyaaBtn
	description  	   : create the Button of the Boyaa.
	param 	 	 	   : self
	last-modified-date : Dec. 2 2013
	create-time  	   : Oct.22 2013
]]
UnicomKdPlatformView.createBoyaaBtn = function ( self )
	local btn = nil;
	local btnData = CreatingViewUsingData.switchLoginView.boyaaLoginBtn;
	btn = UICreator.createBtn(btnData.fileName, btnData.x, btnData.y, self, function ( self )
		self:onClick(PlatformConfig.BoyaaLogin);
	end);
	local text = UICreator.createText(btnData.text, 0, -36, 150, 32, kAlignCenter, 28, 75, 43, 28);
	text:setAlign(kAlignBottom);
	btn:addChild(text);
	return btn;
end

--主平台的登录方式列表
UnicomKdPlatformView.loginBtnCreateFunMap = {
	[PlatformConfig.SinaLogin] = UnicomKdPlatformView.createSinaBtn,
	[PlatformConfig.QQLogin] = UnicomKdPlatformView.createQQBtn,
	[PlatformConfig.BoyaaLogin] = UnicomKdPlatformView.createBoyaaBtn,
	[PlatformConfig.GuestLogin] = UnicomKdPlatformView.createGuestBtn
};

