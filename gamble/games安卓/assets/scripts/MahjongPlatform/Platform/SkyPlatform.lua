require("MahjongPlatform/Platform/BasePlatform");

SkyPlatform = class(BasePlatform);

SkyPlatform.ctor = function ( self)
	self.curDefaultPmode = 4;
	self.paymentTable = { BasePay.PAY_TYPE_SKY };
	self.m_loginTable = {PlatformConfig.SkyLogin};
end

SkyPlatform.dtor = function ( self )
end

SkyPlatform.returnIsLianyunName = function(self)
	return PlatformConfig.feedback_platform_Sky;
end

SkyPlatform.isNeedPostApiHost = function(self)
	return true;
end

--[[
	function name	   : QihuPlatform.getLoginView
	description  	   : @Override.
	param 	 	 	   : self
	last-modified-date : Nov.29 2013
	create-time  	   : Nov.29 2013
]]
SkyPlatform.getLoginView = function (self)
	return new(SkyPlatformView,self.m_loginTable);
end

BasePlatform.getPlatformAPI = function ( self )
	return PlatformConfig.API_SKY;
end

-- @Override
SkyPlatform.getPayManagerType = function( self )
	-- return BasePayManager.TYPE_TRUNK;TYPE_SINGLE
	return BasePayManager.TYPE_SINGLE;
end

SkyPlatform.getDefaultLoginMethod = function ( self )
	local loginType = g_DiskDataMgr:getAppData(kLastLoginType, PlatformConfig.GuestLogin);
	return loginType;
end

SkyPlatform.changeLoginMethod = function(self,loginMethod)
	return new(self.getLoginMethodCls[loginMethod] or GuestLogin);
end

SkyPlatform.isNeedChangeXueZhanLogo = function( self )
	return false;
end

-- 该平台的应用名称
-- @Override
SkyPlatform.getApplicationShareName = function( self )
	return "博雅四川麻将！";
end

--*****************************************************View平台界面********************************************************************************--
--[[
	className    	     :  SkyPlatformView
	Description  	     :  平台界面类
	last-modified-date   :  Dec.2  2013
	create-time 	     :  Oct.22 2013
	last-modified-author :  ClarkWu
	create-author        :  ClarkWu
]]
SkyPlatformView = class(CustomNode);

--[[
	function name	   : SkyPlatformView.ctor
	description  	   : Construct the class.
	param 	 	 	   : self
	last-modified-date : Dec. 2 2013
	create-time  	   : Oct.22 2013
]]
SkyPlatformView.ctor = function(self,loginTable)
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
	function name	   : SkyPlatformView.dtor
	description  	   : Destruct the class.
	param 	 	 	   : self
	last-modified-date : Dec. 2 2013
	create-time  	   : Oct.22 2013
]]
SkyPlatformView.dtor = function(self)
	CustomNode.hide(self);
	self:removeAllChildren();
end

--[[
	function name	   : SkyPlatformView.onClick
	description  	   : Destruct the class.
	param 	 	 	   : self
	last-modified-date : Dec. 2 2013
	create-time  	   : Oct.22 2013
]]
SkyPlatformView.onClick = function(self,loginMethod)
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
	function name	   : SkyPlatformView.createQihuBtn
	description  	   : create the Button of the 360.
	param 	 	 	   : self
	last-modified-date : Dec.18 2013
	create-time  	   : Dec.18 2013
]]
SkyPlatformView.createSkyBtn = function(self)
	local btn = nil;
	btn = UICreator.createBtn(CreatingViewUsingData.switchLoginView.loginSkyBtn.fileName,CreatingViewUsingData.switchLoginView.loginSkyBtn.x,CreatingViewUsingData.switchLoginView.loginSkyBtn.y, self, function ( self )
		self:onClick(PlatformConfig.SkyLogin);
	end);
	return btn;
end

--奇虎平台的登录方式列表
SkyPlatformView.loginBtnCreateFunMap = {
	[PlatformConfig.SkyLogin] = SkyPlatformView.createSkyBtn
};