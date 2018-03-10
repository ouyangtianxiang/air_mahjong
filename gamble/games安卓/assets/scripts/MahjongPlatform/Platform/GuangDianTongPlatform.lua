--[[
	className    	     :  GuangDianTongPlatform
	Description  	     :  平台类-子类(小包平台))
	last-modified-date   :  Dec.2  2013
	create-time 	     :  Oct.22 2013
	last-modified-author :  ClarkWu
	create-author        :  ClarkWu
]]
--
require("MahjongPlatform/Platform/BasePlatform");

GuangDianTongPlatform = class(BasePlatform);

--[[
	function name	   : GuangDianTongPlatform.ctor
	description  	   : Construct a class.
	param 	 	 	   : self
					     api          -- Number    Every platform has different api.
					     loginTable   -- Table     Every platform has different login methods.  
	last-modified-date : Oct.22 2013
	create-time  	   : Oct.22 2013
]]
GuangDianTongPlatform.ctor = function ( self)
	self.paymentTable = {BasePay.PAY_TYPE_MOBILEMM,BasePay.PAY_TYPE_HUAFUBAO,BasePay.PAY_TYPE_UNICOM,
							BasePay.PAY_TYPE_TELECOM,BasePay.PAY_TYPE_TELE_BARE,BasePay.PAY_TYPE_ALIWEB};
	self.m_loginTable = {PlatformConfig.QQLogin,PlatformConfig.GuestLogin};
	self.curDefaultPmode = 4;
end

GuangDianTongPlatform.returnIsLianyunName = function(self)
	return PlatformConfig.feedback_platform_Trunk_GuangDianTong;
end

GuangDianTongPlatform.getPayManagerType = function(self)
	return BasePayManager.TYPE_MIX;
end

--[[
	function name	   : GuangDianTongPlatform.dtor
	description  	   : Destructor a class.
	param 	 	 	   : self
	last-modified-date : Oct.22 2013
	create-time  	   : Oct.22 2013
]]
GuangDianTongPlatform.dtor = function ( self )
end

GuangDianTongPlatform.notUseChat = function(self)
	return false;
end

GuangDianTongPlatform.isNeedPostApiHost = function(self)
	return true;
end

GuangDianTongPlatform.isNeedChangeXueZhanLogo = function(self)
	return true;
end

--第一次安装是否要下载
GuangDianTongPlatform.needFirstNotDownload = function(self)
	return true;
end

--[[
	function name	   : QihuPlatform.getLoginView
	description  	   : @Override.
	param 	 	 	   : self
	last-modified-date : Nov.29 2013
	create-time  	   : Nov.29 2013
]]
GuangDianTongPlatform.getLoginView = function (self)
	return new(GuangDianTongPlatformView,self.m_loginTable);
end

--[[
	function name	   : GuangDianTongPlatform.getDefaultLoginMethod
	description  	   : @Override.
	param 	 	 	   : self
	last-modified-date : Oct.22 2013
	create-time  	   : Oct.22 2013
]]
GuangDianTongPlatform.getDefaultLoginMethod = function ( self )
	local loginType = g_DiskDataMgr:getAppData(kLastLoginType, PlatformConfig.GuestLogin);
	if self.super.existLoginType( self, loginType ) == false then
		return PlatformConfig.GuestLogin;
	end
	return loginType;
end

GuangDianTongPlatform.isSupportQuickRecharge = function ( self )
	return true;
end

GuangDianTongPlatform.payUtilCreate = function(self,payType)
	if PlatformConfig.GuangDianTong_Pay ~= payType then
		DebugLog("请检查支付方式，没有对应的payType");
	end
	return new(GuangDianTongPayment);
end

GuangDianTongPlatform.changeLoginMethod = function(self,loginMethod)
	return new(self.getLoginMethodCls(loginMethod) or GuestLogin);
end

-- 分享时应用名称
GuangDianTongPlatform.getApplicationShareName = function( self )
	return "博雅四川麻将";
end

--*****************************************************View平台界面********************************************************************************--
--[[
	className    	     :  GuangDianTongPlatformView
	Description  	     :  平台界面类
	last-modified-date   :  Dec.2  2013
	create-time 	     :  Oct.22 2013
	last-modified-author :  ClarkWu
	create-author        :  ClarkWu
]]
GuangDianTongPlatformView = class(CustomNode);

--[[
	function name	   : GuangDianTongPlatformView.ctor
	description  	   : Construct the class.
	param 	 	 	   : self
	last-modified-date : Dec. 2 2013
	create-time  	   : Oct.22 2013
]]
GuangDianTongPlatformView.ctor = function(self, loginTable)
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
	function name	   : GuangDianTongPlatformView.dtor
	description  	   : Destruct the class.
	param 	 	 	   : self
	last-modified-date : Dec. 2 2013
	create-time  	   : Oct.22 2013
]]
GuangDianTongPlatformView.dtor = function(self)
	CustomNode.hide(self);
	self:removeAllChildren();
end

--[[
	function name	   : GuangDianTongPlatformView.onClick
	description  	   : Destruct the class.
	param 	 	 	   : self
	last-modified-date : Dec. 2 2013
	create-time  	   : Oct.22 2013
]]
GuangDianTongPlatformView.onClick = function(self, loginMethod)
	DebugLog("  loginMethod  : "..loginMethod);
	DebugLog("  self.curLoginType  : "..PlatformFactory.curPlatform.curLoginType);
	if loginMethod == PlatformFactory.curPlatform.curLoginType then
		DebugLog("  loginMethod == self.curLoginType  ");
		PlatformFactory.curPlatform:logout();
	else
		DebugLog("  loginMethod != self.curLoginType  ");
		PlatformFactory.curPlatform:clearCurUserGameData();
	end
	GameConstant.isFirstPopu = 1;
	PlatformFactory.curPlatform:login(loginMethod);
	delete(self);
	self = nil;
end

--[[
	function name	   : GuangDianTongPlatformView.createGuestBtn
	description  	   : create the Button of the guest.
	param 	 	 	   : self
	last-modified-date : Dec. 2 2013
	create-time  	   : Oct.22 2013
]]
GuangDianTongPlatformView.createGuestBtn = function ( self )
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
	function name	   : GuangDianTongPlatformView.createQQBtn
	description  	   : create the Button of the QQ.
	param 	 	 	   : self
	last-modified-date : Dec. 2 2013
	create-time  	   : Oct.22 2013
]]
GuangDianTongPlatformView.createQQBtn = function ( self )
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
	function name	   : GuangDianTongPlatformView.createSinaBtn
	description  	   : create the Button of the Sina.
	param 	 	 	   : self
	last-modified-date : Dec. 2 2013
	create-time  	   : Oct.22 2013
]]
GuangDianTongPlatformView.createSinaBtn = function ( self )
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
	function name	   : GuangDianTongPlatformView.createBoyaaBtn
	description  	   : create the Button of the Boyaa.
	param 	 	 	   : self
	last-modified-date : Dec. 2 2013
	create-time  	   : Oct.22 2013
]]
GuangDianTongPlatformView.createBoyaaBtn = function ( self )
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
	function name	   : GuangDianTongPlatformView.createBoyaaBtn
	description  	   : create the Button of the Boyaa.
	param 	 	 	   : self
	last-modified-date : Dec. 2 2013
	create-time  	   : Oct.22 2013
]]
-- GuangDianTongPlatformView.createBoyaaBtn = function ( self )
-- 	local btn = nil;
-- 	btn = UICreator.createBtn(CreatingViewUsingData.switchLoginView.boyaaLoginBtn.fileName, CreatingViewUsingData.switchLoginView.boyaaLoginBtn.x, CreatingViewUsingData.switchLoginView.boyaaLoginBtn.y, self, function ( self )
-- 		self:onClick(PlatformConfig.BoyaaLogin);
-- 	end);
-- 	return btn;
-- end

--主平台的登录方式列表
GuangDianTongPlatformView.loginBtnCreateFunMap = {
	[PlatformConfig.SinaLogin] = GuangDianTongPlatformView.createSinaBtn,
	[PlatformConfig.QQLogin] = GuangDianTongPlatformView.createQQBtn,
	-- [PlatformConfig.BoyaaLogin] = GuangDianTongPlatformView.createBoyaaBtn,
	[PlatformConfig.GuestLogin] = GuangDianTongPlatformView.createGuestBtn
};

--返回该平台对应的强制更新界面、首冲大礼包、普通更新界面、公告、签到界面的level
--强更>首冲>普更>公告>签到
GuangDianTongPlatform.getPlatformLevel = function(self)
	return 20000,15000,10000,8000,6000;
end

GuangDianTongPlatform.isSupportUnicom30PayCode = function(self)
	return true;
end

