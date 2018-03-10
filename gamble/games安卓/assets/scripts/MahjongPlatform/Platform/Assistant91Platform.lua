--[[
	className    	     :  Assistant91Platform
	Description  	     :  平台类-子类(91助手平台))
	last-modified-date   :  Feb.12 2014
	create-time 	     :  Feb.12 2014
	last-modified-author :  ClarkWu
	create-author        :  ClarkWu
]]
require("MahjongCommon/CustomNode");
--
require("MahjongHall/Mall/PaymentMode/YidongMMPayment");

require("MahjongPlatform/Platform/BasePlatform");

Assistant91Platform = class(BasePlatform);

--[[
	function name	   : Assistant91Platform.ctor
	description  	   : Construct a class.
	param 	 	 	   : self
	last-modified-date : Feb.12 2014
	create-time  	   : Feb.12 2014
]]
Assistant91Platform.ctor = function ( self)
	self.curPayType = PlatformConfig.Assistant91Pay;
	self.curDefaultPmode = 3; -- 默认为91的商品mode
	self.m_loginTable = {PlatformConfig.Assistant91Login};
end

--[[
	function name	   : Assistant91Platform.dtor
	description  	   : Destructor a class.
	param 	 	 	   : self
	last-modified-date : Feb.12 2014
	create-time  	   : Feb.12 2014
]]
Assistant91Platform.dtor = function ( self )
end

Assistant91Platform.returnIsLianyunName = function(self)
	return PlatformConfig.feedback_platform_91;
end

--[[
	function name	   : Assistant91Platform.getLoginView
	description  	   : @Override.
	param 	 	 	   : self
	last-modified-date : Feb.12 2014
	create-time  	   : Feb.12 2014
]]
Assistant91Platform.getLoginView = function ( self)
	return new(Assistant91PlatformView,self.m_loginTable);
end

--[[
	function name	   : Assistant91Platform.needToShowUpdataView
	description  	   : @Override.
	param 	 	 	   : self
	last-modified-date : Feb.12 2014
	create-time  	   : Feb.12 2014
]]
Assistant91Platform.needToShowUpdataView = function ( self )
	return false;
end

--[[
	function name	   : Assistant91Platform.getDefaultLoginMethod
	description  	   : @Override.
	param 	 	 	   : self
	last-modified-date : Feb.12 2014
	create-time  	   : Feb.12 2014
]]
Assistant91Platform.getDefaultLoginMethod = function ( self )
	return PlatformConfig.Assistant91Login;
end

--[[
	function name	   : Assistant91Platform.switchLogin
	description  	   : 切换账号.
	param 	 	 	   : self
	last-modified-date : Feb.12 2014
	create-time  	   : Feb.12 2014
]]
Assistant91Platform.switchLogin = function ( self, loginMethod)
	local loginUtl = self:getLoginUtl(loginMethod);
	if not loginUtl then
		return; -- 登录方式不存在
	end
	self:setAPI(loginMethod);
	loginUtl:switchLogin();
	self.curLoginType = loginMethod;
end

Assistant91Platform.payUtilCreate = function(self,payType)
	if PlatformConfig.Assistant91Pay ~= payType then
		DebugLog("请检查支付方式，没有对应的payType");
	end
	return new(Assistant91Payment);
end

Assistant91Platform.changeLoginMethod = function(self,loginMethod)
	if PlatformConfig.Assistant91Login ~= loginMethod then 
		DebugLog("请检查登录方式,没有对应的loginMethod");
	end 											
	return new(self.getLoginMethodCls(loginMethod) or Assistant91Login );
end

--是否显示平台精灵
Assistant91Platform.isShowPlatformSprite = function(self)
	return true;
end

--*****************************************************View平台界面********************************************************************************--
--[[
	className    	     :  Assistant91PlatformView
	Description  	     :  平台界面类
	last-modified-date   :  Feb.12 2014
	create-time 	     :  Feb.12 2014
	last-modified-author :  ClarkWu
	create-author        :  ClarkWu
]]
Assistant91PlatformView = class(CustomNode);

--[[
	function name	   : Assistant91PlatformView.ctor
	description  	   : Construct the class.
	param 	 	 	   : self
	last-modified-date : Dec. 2 2013
	create-time  	   : Feb.12 2014
]]
Assistant91PlatformView.ctor = function(self,loginTable)
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
	function name	   : Assistant91PlatformView.dtor
	description  	   : Destruct the class.
	param 	 	 	   : self
	last-modified-date : Feb.12 2014
	create-time  	   : Feb.12 2014
]]
Assistant91PlatformView.dtor = function(self)
	CustomNode.hide(self);
	self:removeAllChildren();
end

--[[
	function name	   : Assistant91PlatformView.onClick
	description  	   : Destruct the class.
	param 	 	 	   : self
	last-modified-date : Feb.12 2014
	create-time  	   : Feb.12 2014
]]
Assistant91PlatformView.onClick = function(self,loginMethod)
	if loginMethod == PlatformFactory.curPlatform.curLoginType then
		PlatformFactory.curPlatform:logout();
	else
		PlatformFactory.curPlatform:clearCurUserGameData();
	end
	umengStatics_lua(kUmengAssistant91Login);
	PlatformFactory.curPlatform:switchLogin(loginMethod);
	delete(self);
	self = nil;
end

--[[
	function name	   : Assistant91PlatformView.create91Btn
	description  	   : create the Button of the 91.
	param 	 	 	   : self
	last-modified-date : Feb.12 2014
	create-time  	   : Feb.12 2014
]]
Assistant91PlatformView.create91Btn = function(self)
	local btn = nil;
	btn = UICreator.createBtn(CreatingViewUsingData.switchLoginView.login91Btn.fileName,CreatingViewUsingData.switchLoginView.login91Btn.x,CreatingViewUsingData.switchLoginView.login91Btn.y, self, function ( self )
		self:onClick(PlatformConfig.Assistant91Login);
	end);
	return btn;
end

--华为平台的登录方式列表
Assistant91PlatformView.loginBtnCreateFunMap = {
	[PlatformConfig.Assistant91Login] = Assistant91PlatformView.create91Btn,
};

