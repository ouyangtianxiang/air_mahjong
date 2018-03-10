--[[
	className    	     :  TrunkPrePlatform
	Description  	     :  平台类-子类(主平台预装版))
	last-modified-date   :  Dec.2  2013
	create-time 	     :  Oct.22 2013
	last-modified-author :  ClarkWu
	create-author        :  ClarkWu
]]
--
require("MahjongPlatform/Platform/BasePlatform");

TrunkPrePlatform = class(BasePlatform);

--[[
	function name	   : TrunkPrePlatform.ctor
	description  	   : Construct a class.
	param 	 	 	   : self
	last-modified-date : Oct.22 2013
	create-time  	   : Oct.22 2013
]]
TrunkPrePlatform.ctor = function ( self)
	self.curDefaultPmode = 4; --默认为支付宝的商品
	self.curPayType = PlatformConfig.Union_Web_Pay;
	self.m_loginTable = {PlatformConfig.SinaLogin, PlatformConfig.QQLogin, PlatformConfig.BoyaaLogin,PlatformConfig.GuestLogin};
end

--[[
	function name	   : TrunkPrePlatform.dtor
	description  	   : Destructor a class.
	param 	 	 	   : self
	last-modified-date : Oct.22 2013
	create-time  	   : Oct.22 2013
]]
TrunkPrePlatform.dtor = function ( self )
end

TrunkPrePlatform.returnIsLianyunName = function(self)
	return PlatformConfig.feedback_platform_TrunkPre;
end

--[[
	function name	   : TrunkPrePlatform.getProductListUrl
	description  	   : @Override.
	param 	 	 	   : self
	last-modified-date : Oct.22 2013
	create-time  	   : Oct.22 2013
]]
TrunkPrePlatform.getProductListUrl = function ( self )
	local loginUtl = self:getLoginUtl(self.curLoginType);
	if not loginUtl then 
		return GameConstant.CommonUrl;
	end

	if PlatformConfig.GuestLogin == self.curLoginType or PlatformConfig.BoyaaLogin == self.curLoginType then
		loginUtl.appId = "499";

	elseif PlatformConfig.QQLogin == self.curLoginType then
		loginUtl.appId = "496";

	elseif PlatformConfig.SinaLogin == self.curLoginType then
		loginUtl.appId = "497";
	end

	return self.super.getProductListUrl( self );
end

--[[
	function name	   : QihuPlatform.getLoginView
	description  	   : @Override.
	param 	 	 	   : self
	last-modified-date : Nov.29 2013
	create-time  	   : Nov.29 2013
]]
TrunkPrePlatform.getLoginView = function (self)
	return new(TrunkPrePlatformView,self.m_loginTable);
end

--[[
	function name	   : TrunkPrePlatform.getDefaultLoginMethod
	description  	   : @Override.
	param 	 	 	   : self
	last-modified-date : Oct.22 2013
	create-time  	   : Oct.22 2013
]]
TrunkPrePlatform.getDefaultLoginMethod = function ( self )
	local loginType = g_DiskDataMgr:getAppData(kLastLoginType, PlatformConfig.GuestLogin);
	return loginType;
end

TrunkPrePlatform.isSupportQuickRecharge = function ( self )
	return true;
end

TrunkPrePlatform.payUtilCreate = function(self,payType)
	if PlatformConfig.Union_Web_Pay ~= payType then
		DebugLog("请检查支付方式，没有对应的payType");
	end
	return new(UnionPayment);
end

--是否显示绑定博雅通行证
TrunkPrePlatform.isNeedToShowBYPassCard = function ( self )
	-- body
	if self:getCurrentLoginType() == PlatformConfig.GuestLogin then
		return true;
	end
end

TrunkPrePlatform.changeLoginMethod = function(self,loginMethod)
	return new(self.getLoginMethodCls(loginMethod) or GuestLogin );
end

--*****************************************************View平台界面********************************************************************************--
--[[
	className    	     :  TrunkPrePlatformView
	Description  	     :  平台界面类
	last-modified-date   :  Dec.2  2013
	create-time 	     :  Oct.22 2013
	last-modified-author :  ClarkWu
	create-author        :  ClarkWu
]]
TrunkPrePlatformView = class(CustomNode);

--[[
	function name	   : TrunkPrePlatformView.ctor
	description  	   : Construct the class.
	param 	 	 	   : self
	last-modified-date : Dec. 2 2013
	create-time  	   : Oct.22 2013
]]
TrunkPrePlatformView.ctor = function(self, loginTable)
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
	function name	   : TrunkPrePlatformView.dtor
	description  	   : Destruct the class.
	param 	 	 	   : self
	last-modified-date : Dec. 2 2013
	create-time  	   : Oct.22 2013
]]
TrunkPrePlatformView.dtor = function(self)
	CustomNode.hide(self);
	self:removeAllChildren();
end

--[[
	function name	   : TrunkPrePlatformView.onClick
	description  	   : Destruct the class.
	param 	 	 	   : self
	last-modified-date : Dec. 2 2013
	create-time  	   : Oct.22 2013
]]
TrunkPrePlatformView.onClick = function(self, loginMethod)
	DebugLog("  loginMethod  : "..loginMethod or 0);
	DebugLog("  self.curLoginType  : "..PlatformFactory.curPlatform.curLoginType or 0);
	if loginMethod == PlatformFactory.curPlatform.curLoginType then
		DebugLog("  loginMethod == self.curLoginType  ");
		PlatformFactory.curPlatform:logout();
	else
		DebugLog("  loginMethod != self.curLoginType  ");
		PlatformFactory.curPlatform:clearCurUserGameData();
	end
	PlatformFactory.curPlatform:login(loginMethod);
	delete(self);
	self = nil;
end

--[[
	function name	   : TrunkPrePlatformView.createGuestBtn
	description  	   : create the Button of the guest.
	param 	 	 	   : self
	last-modified-date : Dec. 2 2013
	create-time  	   : Oct.22 2013
]]
TrunkPrePlatformView.createGuestBtn = function ( self )
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
	function name	   : TrunkPrePlatformView.createQQBtn
	description  	   : create the Button of the QQ.
	param 	 	 	   : self
	last-modified-date : Dec. 2 2013
	create-time  	   : Oct.22 2013
]]
TrunkPrePlatformView.createQQBtn = function ( self )
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
	function name	   : TrunkPrePlatformView.createSinaBtn
	description  	   : create the Button of the Sina.
	param 	 	 	   : self
	last-modified-date : Dec. 2 2013
	create-time  	   : Oct.22 2013
]]
TrunkPrePlatformView.createSinaBtn = function ( self )
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
	function name	   : TrunkPrePlatformView.createBoyaaBtn
	description  	   : create the Button of the Boyaa.
	param 	 	 	   : self
	last-modified-date : Dec. 2 2013
	create-time  	   : Oct.22 2013
]]
TrunkPrePlatformView.createBoyaaBtn = function ( self )
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
TrunkPrePlatformView.loginBtnCreateFunMap = {
	[PlatformConfig.SinaLogin] = TrunkPrePlatformView.createSinaBtn,
	[PlatformConfig.QQLogin] = TrunkPrePlatformView.createQQBtn,
	[PlatformConfig.BoyaaLogin] = TrunkPrePlatformView.createBoyaaBtn,
	[PlatformConfig.GuestLogin] = TrunkPrePlatformView.createGuestBtn
};

