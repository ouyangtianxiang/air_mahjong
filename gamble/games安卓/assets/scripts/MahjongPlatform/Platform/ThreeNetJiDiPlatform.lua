--region ThreeNetJiDiPlatform.lua
--Author : BillyYang
--Date   : 2015/1/23
--此文件由[BabeLua]插件自动生成

--平台类-子类(三网合一基地派生平台))

--endregion
require("MahjongPlatform/Platform/BasePlatform");
require("MahjongPay/BasePay");

ThreeNetJiDiPlatform = class(BasePlatform);

--[[
	function name	   : ThreeNetPlatform.ctor
	description  	   : Construct a class.
	param 	 	 	   : self
						 api          -- Number    Every platform has different api.
						 loginTable   -- Table     Every platform has different login methods.  
	last-modified-date : Oct.22 2013
	create-time  	   : Oct.22 2013
]]
ThreeNetJiDiPlatform.ctor = function ( self)
	self.curDefaultPmode = 109; --默认为MOBILE的商品
	self.paymentTable = { BasePay.PAY_TYPE_MOBILE,BasePay.PAY_TYPE_UNICOM,BasePay.PAY_TYPE_EGAME};
	self.m_loginTable = {PlatformConfig.SinaLogin, PlatformConfig.QQLogin, PlatformConfig.BoyaaLogin,PlatformConfig.GuestLogin};
end

-- 获取应用APPID信息
-- @Override
ThreeNetJiDiPlatform.getLoginAppId = function( self, loginType )
	if loginType == PlatformConfig.GuestLogin then
		return "186";
	elseif loginType == PlatformConfig.BoyaaLogin then 
		return "186";
	elseif loginType == PlatformConfig.SinaLogin then 
		return "185";
	elseif loginType == PlatformConfig.QQLogin then 
		return "198";
	elseif loginType == PlatformConfig.WeChatLogin then 
		return "171";
	end
end

--[[
	function name	   : ThreeNetPlatform.dtor
	description  	   : Destructor a class.
	param 	 	 	   : self
	last-modified-date : Oct.22 2013
	create-time  	   : Oct.22 2013
]]
ThreeNetJiDiPlatform.dtor = function ( self )
end

ThreeNetJiDiPlatform.returnIsLianyunName = function(self)
	return PlatformConfig.feedback_platform_3Net_JiDi;
end

ThreeNetJiDiPlatform.isNeedPostApiHost = function(self)
	return true;
end

--[[
	function name	   : QihuPlatform.getLoginView
	description  	   : @Override.
	param 	 	 	   : self
	last-modified-date : Nov.29 2013
	create-time  	   : Nov.29 2013
]]
ThreeNetJiDiPlatform.getLoginView = function (self)
	return new(ThreeNetJiDiPlatformView,self.m_loginTable);
end

--是否显示绑定博雅通行证
ThreeNetJiDiPlatform.isNeedToShowBYPassCard = function ( self )
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
ThreeNetJiDiPlatform.getPayManagerType = function( self )
	return BasePayManager.TYPE_MIX;
end

--[[
	function name	   : ThreeNetPlatform.getDefaultLoginMethod
	description  	   : @Override.
	param 	 	 	   : self
	last-modified-date : Oct.22 2013
	create-time  	   : Oct.22 2013
]]
ThreeNetJiDiPlatform.getDefaultLoginMethod = function ( self )
	local loginType = g_DiskDataMgr:getAppData(kLastLoginType, PlatformConfig.GuestLogin);
	return loginType;
end

ThreeNetJiDiPlatform.changeLoginMethod = function(self,loginMethod)
    if not self.m_loginMethod then 
        self.m_loginMethod = new(self.getLoginMethodCls(loginMethod) or GuestLogin);
    end
	return self.m_loginMethod;
end

--*****************************************************View平台界面********************************************************************************--
--[[
	className    	     :  ThreeNetJiDiPlatformView
	Description  	     :  平台界面类
	last-modified-date   :  Dec.2  2013
	create-time 	     :  Oct.22 2013
	last-modified-author :  ClarkWu
	create-author        :  ClarkWu
]]
ThreeNetJiDiPlatformView = class(CustomNode);

--[[
	function name	   : ThreeNetJiDiPlatformView.ctor
	description  	   : Construct the class.
	param 	 	 	   : self
	last-modified-date : Dec. 2 2013
	create-time  	   : Oct.22 2013
]]
ThreeNetJiDiPlatformView.ctor = function(self, loginTable)
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
	function name	   : ThreeNetJiDiPlatformView.dtor
	description  	   : Destruct the class.
	param 	 	 	   : self
	last-modified-date : Dec. 2 2013
	create-time  	   : Oct.22 2013
]]
ThreeNetJiDiPlatformView.dtor = function(self)
	CustomNode.hide(self);
	self:removeAllChildren();
end

--[[
	function name	   : ThreeNetJiDiPlatformView.onClick
	description  	   : Destruct the class.
	param 	 	 	   : self
	last-modified-date : Dec. 2 2013
	create-time  	   : Oct.22 2013
]]
ThreeNetJiDiPlatformView.onClick = function(self, loginMethod)
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
	function name	   : ThreeNetJiDiPlatformView.createGuestBtn
	description  	   : create the Button of the guest.
	param 	 	 	   : self
	last-modified-date : Dec. 2 2013
	create-time  	   : Oct.22 2013
]]
ThreeNetJiDiPlatformView.createGuestBtn = function ( self )
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
	function name	   : ThreeNetJiDiPlatformView.createQQBtn
	description  	   : create the Button of the QQ.
	param 	 	 	   : self
	last-modified-date : Dec. 2 2013
	create-time  	   : Oct.22 2013
]]
ThreeNetJiDiPlatformView.createQQBtn = function ( self )
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
	function name	   : ThreeNetJiDiPlatformView.createSinaBtn
	description  	   : create the Button of the Sina.
	param 	 	 	   : self
	last-modified-date : Dec. 2 2013
	create-time  	   : Oct.22 2013
]]
ThreeNetJiDiPlatformView.createSinaBtn = function ( self )
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
	function name	   : ThreeNetJiDiPlatformView.createBoyaaBtn
	description  	   : create the Button of the Boyaa.
	param 	 	 	   : self
	last-modified-date : Dec. 2 2013
	create-time  	   : Oct.22 2013
]]
ThreeNetJiDiPlatformView.createBoyaaBtn = function ( self )
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

--[[
	function name	   : ThreeNetJiDiPlatformView.createWeChatBtn
	description  	   : create the Button of the WeChat.
	param 	 	 	   : self
	last-modified-date : Dec. 2 2013
	create-time  	   : Oct.22 2013
]]
ThreeNetJiDiPlatformView.createWeChatBtn = function ( self )
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



--主平台的登录方式列表
ThreeNetJiDiPlatformView.loginBtnCreateFunMap = {
	[PlatformConfig.SinaLogin] 	= ThreeNetJiDiPlatformView.createSinaBtn,
	[PlatformConfig.QQLogin] 	= ThreeNetJiDiPlatformView.createQQBtn,
	[PlatformConfig.BoyaaLogin] = ThreeNetJiDiPlatformView.createBoyaaBtn,
	[PlatformConfig.GuestLogin] = ThreeNetJiDiPlatformView.createGuestBtn
};

--返回该平台对应的强制更新界面、首冲大礼包、普通更新界面、公告、签到界面的level
--强更>首冲>普更>公告>签到
ThreeNetJiDiPlatform.getPlatformLevel = function(self)
	return 20000,15000,10000,8000,6000;
end

-- 该平台的应用名称
-- @Override
ThreeNetJiDiPlatform.getApplicationShareName = function( self )
	return "博雅四川麻将";
end