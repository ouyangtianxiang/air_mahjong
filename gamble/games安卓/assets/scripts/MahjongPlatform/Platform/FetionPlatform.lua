--[[
	className    	     :  FetionPlatform
	Description  	     :  平台类-子类(联想平台))
	last-modified-date   :  Feb.12 2014
	create-time 	     :  Feb.12 2014
	last-modified-author :  ClarkWu
	create-author        :  ClarkWu
]]
require("MahjongCommon/CustomNode");
--
require("MahjongPlatform/Platform/BasePlatform");

FetionPlatform = class(BasePlatform);

--[[
	function name	   : FetionPlatform.ctor
	description  	   : Construct a class.
	param 	 	 	   : self
	last-modified-date : Feb.12 2014
	create-time  	   : Feb.12 2014
]]
FetionPlatform.ctor = function ( self)
	self.curDefaultPmode = 218; -- MM的商品
	self.m_loginTable = {PlatformConfig.FetionLogin};
	self.paymentTable = {BasePay.PAY_TYPE_MOBILEMM};
end

--[[
	function name	   : FetionPlatform.dtor
	description  	   : Destructor a class.
	param 	 	 	   : self
	last-modified-date : Feb.12 2014
	create-time  	   : Feb.12 2014
]]
FetionPlatform.dtor = function ( self )
end

FetionPlatform.returnIsLianyunName = function(self)
	return PlatformConfig.feedback_platform_Fetion;
end

--[[
	function name	   : FetionPlatform.getLoginView
	description  	   : @Override.
	param 	 	 	   : self
	last-modified-date : Feb.12 2014
	create-time  	   : Feb.12 2014
]]
FetionPlatform.getLoginView = function ( self)
	return new(FetionPlatformView,self.m_loginTable);
end

--[[
	function name	   : FetionPlatform.getDefaultLoginMethod
	description  	   : @Override.
	param 	 	 	   : self
	last-modified-date : Feb.12 2014
	create-time  	   : Feb.12 2014
]]
FetionPlatform.getDefaultLoginMethod = function ( self )
	return PlatformConfig.FetionLogin;
end

--[[
	function name	   : FetionPlatform.switchLogin
	description  	   : 切换账号.
	param 	 	 	   : self
	last-modified-date : Feb.12 2014
	create-time  	   : Feb.12 2014
]]
FetionPlatform.switchLogin = function ( self, loginMethod)
	local loginUtl = self:getLoginUtl(loginMethod);
	if not loginUtl then
		return; -- 登录方式不存在
	end
	self:setAPI(loginMethod);
	loginUtl:login();
	self.curLoginType = loginMethod;
end

-- @Override
FetionPlatform.getPayManagerType = function( self )
	return BasePayManager.TYPE_SINGLE;
end

FetionPlatform.changeLoginMethod = function(self,loginMethod)
	if PlatformConfig.FetionLogin ~= loginMethod then 
		DebugLog("请检查登录方式,没有对应的loginMethod");
	end		
	return new(self.getLoginMethodCls(loginMethod) or FetionLogin );
end

--*****************************************************View平台界面********************************************************************************--
--[[
	className    	     :  FetionPlatformView
	Description  	     :  平台界面类
	last-modified-date   :  Feb.12 2014
	create-time 	     :  Feb.12 2014
	last-modified-author :  ClarkWu
	create-author        :  ClarkWu
]]
FetionPlatformView = class(CustomNode);

--[[
	function name	   : FetionPlatformView.ctor
	description  	   : Construct the class.
	param 	 	 	   : self
	last-modified-date : Dec. 2 2013
	create-time  	   : Feb.12 2014
]]
FetionPlatformView.ctor = function(self,loginTable)
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
	local x, y = CreatingViewUsingData.switchLoginView.loginBtn.x-25, CreatingViewUsingData.switchLoginView.loginBtn.y+5;
	for k,v in pairs(btnArray) do
		x = x + dist;
		v:setPos(x, y);
		self.btnView:addChild(v);
		x = x + CreatingViewUsingData.switchLoginView.loginBtn.split;
	end

	self.bg:addChild(self.btnView);
end

--[[
	function name	   : FetionPlatformView.dtor
	description  	   : Destruct the class.
	param 	 	 	   : self
	last-modified-date : Feb.12 2014
	create-time  	   : Feb.12 2014
]]
FetionPlatformView.dtor = function(self)
	CustomNode.hide(self);
	self:removeAllChildren();
end

--[[
	function name	   : FetionPlatformView.onClick
	description  	   : Destruct the class.
	param 	 	 	   : self
	last-modified-date : Feb.12 2014
	create-time  	   : Feb.12 2014
]]
FetionPlatformView.onClick = function(self,loginMethod)
	if loginMethod == PlatformFactory.curPlatform.curLoginType then
		PlatformFactory.curPlatform:logout();
	else
		PlatformFactory.curPlatform:clearCurUserGameData();
	end
	umengStatics_lua(kUmengFetionLogin);
	PlatformFactory.curPlatform:switchLogin(loginMethod);
	delete(self);
	self = nil;
end

--[[
	function name	   : FetionPlatformView.create91Btn
	description  	   : create the Button of the 91.
	param 	 	 	   : self
	last-modified-date : Feb.12 2014
	create-time  	   : Feb.12 2014
]]
FetionPlatformView.createFetionLogin = function(self)
	local btn = nil;
	btn = UICreator.createBtn(CreatingViewUsingData.switchLoginView.loginFetionBtn.fileName,CreatingViewUsingData.switchLoginView.loginFetionBtn.x,CreatingViewUsingData.switchLoginView.loginFetionBtn.y, self, function ( self )
		self:onClick(PlatformConfig.FetionLogin);
	end);

	local text = UICreator.createText(CreatingViewUsingData.switchLoginView.loginFetionBtn.text, 0, -36, 150, 32, kAlignCenter, 28, 75, 43, 28);
	text:setAlign(kAlignBottom);
	btn:addChild(text);

	return btn;
end

--华为平台的登录方式列表
FetionPlatformView.loginBtnCreateFunMap = {
	[PlatformConfig.FetionLogin] = FetionPlatformView.createFetionLogin,
};

