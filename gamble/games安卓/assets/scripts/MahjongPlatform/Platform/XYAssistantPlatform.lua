--region XYAssistantPlatform .lua
--Author : BillyYang
--Date   : 2015/1/23
--此文件由[BabeLua]插件自动生成

--平台类-子类(三网合一基地派生平台))

--endregion
require("MahjongPlatform/Platform/BasePlatform");
require("MahjongPay/BasePay");

XYAssistantPlatform = class(BasePlatform);

--[[
	function name	   : ThreeNetPlatform.ctor
	description  	   : Construct a class.
	param 	 	 	   : self
						 api          -- Number    Every platform has different api.
						 loginTable   -- Table     Every platform has different login methods.  
	last-modified-date : Oct.22 2013
	create-time  	   : Oct.22 2013
]]
XYAssistantPlatform.ctor = function ( self)
	self.m_loginMethods = {};
	self.curDefaultPmode = 464; --默认为MOBILE的商品
	self.paymentTable = { BasePay.PAY_TYPE_XY_ASSIST};
	self.m_loginTable = { PlatformConfig.XYLogin};
end

-- 获取应用APPID信息
-- @Override
XYAssistantPlatform.getLoginAppId = function( self, loginType )
	return "1125";
end

--[[
	function name	   : ThreeNetPlatform.dtor
	description  	   : Destructor a class.
	param 	 	 	   : self
	last-modified-date : Oct.22 2013
	create-time  	   : Oct.22 2013
]]
XYAssistantPlatform.dtor = function ( self )
end

XYAssistantPlatform.returnIsLianyunName = function(self)
	return PlatformConfig.feedback_platform_XY_Assistant;
end

XYAssistantPlatform.isNeedPostApiHost = function(self)
	return true;
end

--[[
	function name	   : QihuPlatform.getLoginView
	description  	   : @Override.
	param 	 	 	   : self
	last-modified-date : Nov.29 2013
	create-time  	   : Nov.29 2013
]]
XYAssistantPlatform.getLoginView = function (self)
	return new(XYAssistantPlatformView,self.m_loginTable);
end

--是否显示绑定博雅通行证
XYAssistantPlatform.isNeedToShowBYPassCard = function ( self )
	-- body
	if self:getCurrentLoginType() == PlatformConfig.GuestLogin then

		local loginUtil = self.loginUtls[PlatformConfig.GuestLogin];
		if loginUtil and loginUtil.visitorBounded then
			return false;
		end
		return true;
		
	end
end
-- @Override
XYAssistantPlatform.getPayManagerType = function( self )
	return BasePayManager.TYPE_SINGLE;
end

--[[
	function name	   : ThreeNetPlatform.getDefaultLoginMethod
	description  	   : @Override.
	param 	 	 	   : self
	last-modified-date : Oct.22 2013
	create-time  	   : Oct.22 2013
]]
XYAssistantPlatform.getDefaultLoginMethod = function ( self )
	local loginType = g_DiskDataMgr:getAppData(kLastLoginType, PlatformConfig.GuestLogin);
	return loginType;
end

XYAssistantPlatform.changeLoginMethod = function(self,loginMethod)
   if loginMethod and not self.m_loginMethods[loginMethod] then 
		self.m_loginMethods[loginMethod] = new(self.getLoginMethodCls(loginMethod) or GuestLogin);
	end
	return self.m_loginMethods[loginMethod];
end

--*****************************************************View平台界面********************************************************************************--
--[[
	className    	     :  XYAssistantPlatform View
	Description  	     :  平台界面类
	last-modified-date   :  Dec.2  2013
	create-time 	     :  Oct.22 2013
	last-modified-author :  ClarkWu
	create-author        :  ClarkWu
]]
XYAssistantPlatformView = class(CustomNode);

--[[
	function name	   : XYAssistantPlatform View.ctor
	description  	   : Construct the class.
	param 	 	 	   : self
	last-modified-date : Dec. 2 2013
	create-time  	   : Oct.22 2013
]]
XYAssistantPlatformView.ctor = function(self, loginTable)
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
	function name	   : XYAssistantPlatform View.dtor
	description  	   : Destruct the class.
	param 	 	 	   : self
	last-modified-date : Dec. 2 2013
	create-time  	   : Oct.22 2013
]]
XYAssistantPlatformView.dtor = function(self)
	CustomNode.hide(self);
	self:removeAllChildren();
end

--[[
	function name	   : XYAssistantPlatform View.onClick
	description  	   : Destruct the class.
	param 	 	 	   : self
	last-modified-date : Dec. 2 2013
	create-time  	   : Oct.22 2013
]]
XYAssistantPlatformView.onClick = function(self, loginMethod)
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
	function name	   : XYAssistantPlatform View.createXYBtn
	description  	   : create the Button of the XY.
	param 	 	 	   : self
	last-modified-date : Dec. 2 2013
	create-time  	   : Oct.22 2013
]]
XYAssistantPlatformView.createXYBtn = function ( self )
	local btn = nil;
	local btnData = CreatingViewUsingData.switchLoginView.loginXYBtn;
	btn = UICreator.createBtn(btnData.fileName, btnData.x, btnData.y, self, function ( self )
		self:onClick(PlatformConfig.XYLogin);
	end);
	local text = UICreator.createText(btnData.text, 0, -36, 150, 32, kAlignCenter, 28, 75, 43, 28);
	text:setAlign(kAlignBottom);
	btn:addChild(text);
	return btn;
end



--主平台的登录方式列表
XYAssistantPlatformView.loginBtnCreateFunMap = {
	[PlatformConfig.XYLogin] 	= XYAssistantPlatformView.createXYBtn,
};

--返回该平台对应的强制更新界面、首冲大礼包、普通更新界面、公告、签到界面的level
--强更>首冲>普更>公告>签到
XYAssistantPlatform.getPlatformLevel = function(self)
	return 20000,15000,10000,8000,6000;
end