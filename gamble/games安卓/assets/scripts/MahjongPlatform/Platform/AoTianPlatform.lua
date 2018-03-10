--region AoTianPlatform .lua
--Author : ClarkWu
--Date   : 2015/1/23
--此文件由[BabeLua]插件自动生成

--平台类-子类(傲天平台))

--endregion
require("MahjongPlatform/Platform/BasePlatform");

AoTianPlatform = class(BasePlatform);

--[[
	function name	   : ThreeNetPlatform.ctor
	description  	   : Construct a class.
	param 	 	 	   : self
						 api          -- Number    Every platform has different api.
						 loginTable   -- Table     Every platform has different login methods.  
	last-modified-date : Oct.22 2013
	create-time  	   : Oct.22 2013
]]
AoTianPlatform.ctor = function ( self)
	self.m_loginMethods = {};
	self.curDefaultPmode = 586; --默认为MOBILE的商品
	self.m_loginTable = { PlatformConfig.AoTianLogin};
end

-- 获取应用APPID信息
-- @Override
AoTianPlatform.getLoginAppId = function( self, loginType )
	return "1395";
end

--[[
	function name	   : ThreeNetPlatform.dtor
	description  	   : Destructor a class.
	param 	 	 	   : self
	last-modified-date : Oct.22 2013
	create-time  	   : Oct.22 2013
]]
AoTianPlatform.dtor = function ( self )
end

AoTianPlatform.returnIsLianyunName = function(self)
	return PlatformConfig.feedback_platform_aotian;
end

AoTianPlatform.isNeedPostApiHost = function(self)
	return true;
end

--[[
	function name	   : QihuPlatform.getLoginView
	description  	   : @Override.
	param 	 	 	   : self
	last-modified-date : Nov.29 2013
	create-time  	   : Nov.29 2013
]]
AoTianPlatform.getLoginView = function (self)
	return new(AoTianPlatformView,self.m_loginTable);
end

--[[
	function name	   : ThreeNetPlatform.getDefaultLoginMethod
	description  	   : @Override.
	param 	 	 	   : self
	last-modified-date : Oct.22 2013
	create-time  	   : Oct.22 2013
]]
AoTianPlatform.getDefaultLoginMethod = function ( self )
	local loginType = g_DiskDataMgr:getAppData(kLastLoginType, PlatformConfig.AoTianLogin);
	return loginType;
end

AoTianPlatform.changeLoginMethod = function(self,loginMethod)
   if loginMethod and not self.m_loginMethods[loginMethod] then 
		self.m_loginMethods[loginMethod] = new(self.getLoginMethodCls(loginMethod) or AoTianLogin);
	end
	return self.m_loginMethods[loginMethod];
end

--*****************************************************View平台界面********************************************************************************--
--[[
	className    	     :  AoTianPlatform View
	Description  	     :  平台界面类
	last-modified-date   :  Dec.2  2013
	create-time 	     :  Oct.22 2013
	last-modified-author :  ClarkWu
	create-author        :  ClarkWu
]]
AoTianPlatformView = class(CustomNode);

--[[
	function name	   : AoTianPlatform View.ctor
	description  	   : Construct the class.
	param 	 	 	   : self
	last-modified-date : Dec. 2 2013
	create-time  	   : Oct.22 2013
]]
AoTianPlatformView.ctor = function(self, loginTable)
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
	function name	   : AoTianPlatform View.dtor
	description  	   : Destruct the class.
	param 	 	 	   : self
	last-modified-date : Dec. 2 2013
	create-time  	   : Oct.22 2013
]]
AoTianPlatformView.dtor = function(self)
	CustomNode.hide(self);
	self:removeAllChildren();
end

--[[
	function name	   : AoTianPlatform View.onClick
	description  	   : Destruct the class.
	param 	 	 	   : self
	last-modified-date : Dec. 2 2013
	create-time  	   : Oct.22 2013
]]
AoTianPlatformView.onClick = function(self, loginMethod)
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
	function name	   : AoTianPlatform View.createGuestBtn
	description  	   : create the Button of the guest.
	param 	 	 	   : self
	last-modified-date : Dec. 2 2013
	create-time  	   : Oct.22 2013
]]
AoTianPlatformView.createAoTianBtn = function ( self )
	local btn = nil;
	local btnData = CreatingViewUsingData.switchLoginView.aotianLoginBtn;
	btn = UICreator.createBtn(btnData.fileName, btnData.x, btnData.y, self, function ( self )
		self:onClick(PlatformConfig.AoTianLogin);
	end);
	local text = UICreator.createText(btnData.text, 0, -36, 150, 32, kAlignCenter, 28, 75, 43, 28);
	text:setAlign(kAlignBottom);
	btn:addChild(text);
	return btn;
end

--主平台的登录方式列表
AoTianPlatformView.loginBtnCreateFunMap = {
	[PlatformConfig.AoTianLogin] 	= AoTianPlatformView.createAoTianBtn,
};

--返回该平台对应的强制更新界面、首冲大礼包、普通更新界面、公告、签到界面的level
--强更>首冲>普更>公告>签到
AoTianPlatform.getPlatformLevel = function(self)
	return 20000,15000,10000,8000,6000;
end

-- 该平台的应用名称
-- @Override
AoTianPlatform.getApplicationShareName = function( self )
	return "博雅四川麻将";
end