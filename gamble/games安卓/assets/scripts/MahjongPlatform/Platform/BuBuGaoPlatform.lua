--[[
	className    	     :  BuBuGaoPlatform
	Description  	     :  平台类-子类(步步高联运平台))
	last-modified-date   :  Sep.17 2014
	create-time 	     :  Sep.17 2014
	last-modified-author :  ClarkWu
	create-author        :  ClarkWu
]]
--
require("MahjongPlatform/Platform/BasePlatform");

BuBuGaoPlatform = class(BasePlatform);

--[[
	function name	   : BuBuGaoPlatform.ctor
	description  	   : Construct a class.
	param 	 	 	   : self
	last-modified-date : Sep.17 2014
	create-time  	   : Sep.17 2014
]]
BuBuGaoPlatform.ctor = function ( self)
	self.paymentTable = {BasePay.PAY_TYPE_MOBILEMM,BasePay.PAY_TYPE_UNICOM,BasePay.PAY_TYPE_BUBUGAO};
	self.m_loginMethods = {};
	self.curDefaultPmode = 309;-- 步步高默认的步步高支付
	self.m_loginTable = {PlatformConfig.QQLogin, PlatformConfig.BoyaaLogin,PlatformConfig.GuestLogin};
end

BuBuGaoPlatform.getPayManagerType = function( self )
	return BasePayManager.TYPE_MIX;
end

-- 获取应用APPID信息
-- @Override
BuBuGaoPlatform.getLoginAppId = function( self, loginType )
	if loginType == PlatformConfig.GuestLogin then
		return "7116";
	elseif loginType == PlatformConfig.BoyaaLogin then 
		return "7117";
	elseif loginType == PlatformConfig.QQLogin then 
		return "7118";
	end
end


--[[
	function name	   : BuBuGaoPlatform.dtor
	description  	   : Destructor a class.
	param 	 	 	   : self
	last-modified-date : Sep.17 2014
	create-time  	   : Sep.17 2014
]]
BuBuGaoPlatform.dtor = function ( self )
end

BuBuGaoPlatform.returnIsLianyunName = function(self)
	return PlatformConfig.feedback_platform_bubugao;
end

--[[
	function name	   : QihuPlatform.getLoginView
	description  	   : @Override.
	param 	 	 	   : self
	last-modified-date : Nov.29 2013
	create-time  	   : Nov.29 2013
]]
BuBuGaoPlatform.getLoginView = function (self)
	return new(BuBuGaoPlatformView,self.m_loginTable);
end

--[[
	function name	   : BuBuGaoPlatform.getDefaultLoginMethod
	description  	   : @Override.
	param 	 	 	   : self
	last-modified-date : Sep.17 2014
	create-time  	   : Sep.17 2014
]]
BuBuGaoPlatform.getDefaultLoginMethod = function ( self )
	local loginType = g_DiskDataMgr:getAppData(kLastLoginType, PlatformConfig.GuestLogin);
	return loginType;
end

--[[
	function name	   : BuBuGaoPlatform.isSupportQuickRecharge
	description  	   : 是否支持快捷支付.
	param 	 	 	   : self
	last-modified-date : Sep.17 2014
	create-time  	   : Sep.17 2014
]]
BuBuGaoPlatform.isSupportQuickRecharge = function ( self )
	return true;
end

BuBuGaoPlatform.getPlatformAPI = function ( self )
	-- body
	return tostring(PlatformConfig.API_BUBUGAO);
end

BuBuGaoPlatform.changeLoginMethod = function(self,loginMethod)
	if loginMethod and not self.m_loginMethods[loginMethod] then 
		self.m_loginMethods[loginMethod] = new(self.getLoginMethodCls(loginMethod) or GuestLogin);
	end
	return self.m_loginMethods[loginMethod];
end


BuBuGaoPlatform.isNeedChangeXueZhanLogo = function(self)
	return true;
end
--*****************************************************View平台界面********************************************************************************--
--[[
	className    	     :  BuBuGaoPlatformView
	Description  	     :  平台界面类
	last-modified-date   :  Dec.2  2013
	create-time 	     :  Oct.22 2013
	last-modified-author :  ClarkWu
	create-author        :  ClarkWu
]]
BuBuGaoPlatformView = class(CustomNode);

--[[
	function name	   : BuBuGaoPlatformView.ctor
	description  	   : Construct the class.
	param 	 	 	   : self
	last-modified-date : Dec. 2 2013
	create-time  	   : Oct.22 2013
]]
BuBuGaoPlatformView.ctor = function(self, loginTable)
	self.cover:setEventTouch(self , function (self)
		delete(self);
	end);
	self.bg = new(Image, CreatingViewUsingData.switchLoginView.loginBg.fileName, nil, nil, 50, 50, 50, 50);
	self.bg:setSize(900, 500);
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
	function name	   : BuBuGaoPlatformView.dtor
	description  	   : Destruct the class.
	param 	 	 	   : self
	last-modified-date : Dec. 2 2013
	create-time  	   : Oct.22 2013
]]
BuBuGaoPlatformView.dtor = function(self)
	CustomNode.hide(self);
	self:removeAllChildren();
end

--[[
	function name	   : BuBuGaoPlatformView.onClick
	description  	   : Destruct the class.
	param 	 	 	   : self
	last-modified-date : Dec. 2 2013
	create-time  	   : Oct.22 2013
]]
BuBuGaoPlatformView.onClick = function(self, loginMethod)
	DebugLog("  loginMethod  : "..loginMethod);
	DebugLog("  self.curLoginType  : "..PlatformFactory.curPlatform.curLoginType);
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
	function name	   : BuBuGaoPlatformView.createGuestBtn
	description  	   : create the Button of the guest.
	param 	 	 	   : self
	last-modified-date : Dec. 2 2013
	create-time  	   : Oct.22 2013
]]
BuBuGaoPlatformView.createGuestBtn = function ( self )
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
	function name	   : BuBuGaoPlatformView.createQQBtn
	description  	   : create the Button of the QQ.
	param 	 	 	   : self
	last-modified-date : Dec. 2 2013
	create-time  	   : Oct.22 2013
]]
BuBuGaoPlatformView.createQQBtn = function ( self )
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
	function name	   : BuBuGaoPlatformView.createBoyaaBtn
	description  	   : create the Button of the Boyaa.
	param 	 	 	   : self
	last-modified-date : Dec. 2 2013
	create-time  	   : Oct.22 2013
]]
BuBuGaoPlatformView.createBoyaaBtn = function ( self )
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
BuBuGaoPlatformView.loginBtnCreateFunMap = {
	[PlatformConfig.QQLogin] 	= BuBuGaoPlatformView.createQQBtn,
	[PlatformConfig.BoyaaLogin] = BuBuGaoPlatformView.createBoyaaBtn,
	[PlatformConfig.GuestLogin] = BuBuGaoPlatformView.createGuestBtn
};