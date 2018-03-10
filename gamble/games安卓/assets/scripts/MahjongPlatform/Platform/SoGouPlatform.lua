--[[
	className    	     :  SoGouPlatform
	Description  	     :  平台类-子类(搜狗平台))
	last-modified-date   :  Apr.1  2014
	create-time 	     :  Apr.1  2014
	last-modified-author :  ClarkWu
	create-author        :  ClarkWu
]]
require("MahjongCommon/CustomNode");
--
require("MahjongPlatform/Platform/BasePlatform");

SoGouPlatform = class(BasePlatform);

--[[
	function name	   : SoGouPlatform.ctor
	description  	   : Construct a class.
	param 	 	 	   : self
	last-modified-date : Apr.1  2014
	create-time  	   : Apr.1  2014
]]
SoGouPlatform.ctor = function ( self)
	self.curPayType = PlatformConfig.SouGouPay;
	self.curDefaultPmode = 188;
	self.m_loginTable = {PlatformConfig.SouGouLogin};
end

--[[
	function name	   : SoGouPlatform.dtor
	description  	   : Destructor a class.
	param 	 	 	   : self
	last-modified-date : Apr.1  2014
	create-time  	   : Apr.1  2014
]]
SoGouPlatform.dtor = function ( self )
end

SoGouPlatform.returnIsLianyunName = function(self)
	return PlatformConfig.feedback_platform_sogou;
end
	
--[[
	function name	   : SoGouPlatform.getLoginView
	description  	   : @Override.
	param 	 	 	   : self
	last-modified-date : Apr.1 2014
	create-time  	   : Apr.1 2014
]]
SoGouPlatform.getLoginView = function ( self,hallRef )
	return new(SoGouPlatformView,self.m_loginTable);
end

SoGouPlatform.quickLogin = function(self,loginMethod)
	local loginUtl = self:getLoginUtl(loginMethod);
	if not loginUtl then
		return; -- 登录方式不存在
	end
	-- self:setAPI(loginMethod); -- 目前已经用不着setApi
	self.curLoginType = loginMethod;
	loginUtl:quickLogin();
end


SoGouPlatform.defaultLogin = function ( self )
	local lastLoginMethod = self:getDefaultLoginMethod();

	if not lastLoginMethod then
		return;
	end
	--SocketManager.getInstance():syncClose();
	GameConstant.lastLoginType = lastLoginMethod;
	
	self:quickLogin(PlatformConfig.SouGouLogin);

end


--[[
	function name	   : SoGouPlatform.needToShowUpdataView
	description  	   : @Override.
	param 	 	 	   : self
	last-modified-date : Apr.1 2014
	create-time  	   : Apr.1 2014
]]
SoGouPlatform.needToShowUpdataView = function ( self )
	return false;
end

--[[
	function name	   : SoGouPlatform.getDefaultLoginMethod
	description  	   : @Override.
	param 	 	 	   : self
	last-modified-date : Apr.1 2014
	create-time  	   : Apr.1 2014
]]
SoGouPlatform.getDefaultLoginMethod = function ( self )
	local loginType = g_DiskDataMgr:getAppData(kLastLoginType, PlatformConfig.SouGouLogin);
	return loginType;
end

-- 是否支持快速充值
SoGouPlatform.isSupportQuickRecharge = function ( self )
	return true;
end

SoGouPlatform.payUtilCreate = function(self,payType)
	if PlatformConfig.SouGouPay ~= payType then 
		DebugLog("请检查支付方式，没有对应的payType");
	end
	return new(SoGouPayment);
end

SoGouPlatform.changeLoginMethod = function(self,loginMethod)
	if PlatformConfig.SouGouLogin ~= loginMethod then 
		DebugLog("请检查登录方式,没有对应的loginMethod");
	end
	return new(self.getLoginMethodCls(loginMethod) or SouGouLogin);
end

--是否显示平台精灵
SoGouPlatform.isShowPlatformSprite = function(self)
	return true;
end

--是否要调用平台自己的离开方法
SoGouPlatform.isUsePlatformExit = function(self)
	return true;
end

--*****************************************************View平台界面********************************************************************************--
--[[
	className    	     :  SoGouPlatformView
	Description  	     :  平台界面类
	last-modified-date   :  Apr.1  2014
	create-time 	     :  Apr.1  2014
	last-modified-author :  ClarkWu
	create-author        :  ClarkWu
]]
SoGouPlatformView = class(CustomNode);

--[[
	function name	   : SoGouPlatformView.ctor
	description  	   : Construct the class.
	param 	 	 	   : self
	last-modified-date : Apr.1  2014
	create-time  	   : Apr.1  2014
]]
SoGouPlatformView.ctor = function(self,loginTable)
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
	local x, y = CreatingViewUsingData.switchLoginView.loginBtn.x-25, CreatingViewUsingData.switchLoginView.loginBtn.y+30;
	for k,v in pairs(btnArray) do
		x = x + dist;
		v:setPos(x, y);
		self.btnView:addChild(v);
		x = x + CreatingViewUsingData.switchLoginView.loginBtn.split;
	end

	self.bg:addChild(self.btnView);
end

--[[
	function name	   : SoGouPlatformView.dtor
	description  	   : Destruct the class.
	param 	 	 	   : self
	last-modified-date : Apr.1  2014
	create-time  	   : Apr.1  2014
]]
SoGouPlatformView.dtor = function(self)
	CustomNode.hide(self);
	self:removeAllChildren();
end

--[[
	function name	   : SoGouPlatformView.onClick
	description  	   : Destruct the class.
	param 	 	 	   : self
	last-modified-date : Apr.1  2014
	create-time  	   : Apr.1  2014
]]
SoGouPlatformView.onClick = function(self,loginMethod)
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
	function name	   : SoGouPlatformView.createSogouBtn
	description  	   : create the Button of the sogou.
	param 	 	 	   : self
	last-modified-date : Apr.1 2014
	create-time  	   : Apr.1 2014
]]
SoGouPlatformView.createSogouBtn = function(self)
	local btn = nil;
	btn = UICreator.createBtn(CreatingViewUsingData.switchLoginView.loginSouGouBtn.fileName,CreatingViewUsingData.switchLoginView.loginSouGouBtn.x,
		CreatingViewUsingData.switchLoginView.loginSouGouBtn.y, self, function ( self )
		self:onClick(PlatformConfig.SouGouLogin);
	end);
	return btn;
end

--奇虎平台的登录方式列表
SoGouPlatformView.loginBtnCreateFunMap = {
	[PlatformConfig.SouGouLogin] = SoGouPlatformView.createSogouBtn
};

