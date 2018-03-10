--[[
	className    	     :  HuaweiSecondPlatform
	Description  	     :  平台类-子类(华为平台))
	last-modified-date   :  Dec.2  2013
	create-time 	     :  Nov.29 2013
	last-modified-author :  ClarkWu
	create-author        :  ClarkWu
]]
require("MahjongCommon/CustomNode");
require("MahjongPlatform/Platform/BasePlatform");

HuaweiSecondPlatform = class(BasePlatform);

--[[
	function name	   : HuaweiSecondPlatform.ctor
	description  	   : Construct a class.
	param 	 	 	   : self
	last-modified-date : Oct.22 2013
	create-time  	   : Oct.22 2013
]]
HuaweiSecondPlatform.ctor = function ( self)
	self.curDefaultPmode = 110; --默认为华为的商品
	self.m_loginTable = {PlatformConfig.HuaweiLogin};
end

--[[
	function name	   : HuaweiSecondPlatform.dtor
	description  	   : Destructor a class.
	param 	 	 	   : self
	last-modified-date : Oct.22 2013
	create-time  	   : Oct.22 2013
]]
HuaweiSecondPlatform.dtor = function ( self )
end

HuaweiSecondPlatform.returnIsLianyunName = function(self)
	return PlatformConfig.feedback_platform_Huawei_new;
end

--[[
	function name	   : HuaweiSecondPlatform.getLoginView
	description  	   : @Override.
	param 	 	 	   : self
	last-modified-date : Nov.29 2013
	create-time  	   : Nov.29 2013
]]
HuaweiSecondPlatform.getLoginView = function ( self)
	return new(HuaweiSecondPlatformView,self.m_loginTable);
end

--[[
	function name	   : HuaweiSecondPlatform.getDefaultLoginMethod
	description  	   : @Override.
	param 	 	 	   : self
	last-modified-date : Nov.29 2013
	create-time  	   : Nov.29 2013
]]
HuaweiSecondPlatform.getDefaultLoginMethod = function ( self )
	local loginType = g_DiskDataMgr:getAppData(kLastLoginType, PlatformConfig.HuaweiLogin);
	return loginType;
end

HuaweiSecondPlatform.changeLoginMethod = function(self,loginMethod)
    if self.m_loginMethod then 
        return self.m_loginMethod;
    end
    self.m_loginMethod = new(self.getLoginMethodCls(loginMethod) or HuaweiLogin) ;
	return self.m_loginMethod;
end

-- 获取应用APPID信息
-- @Override
HuaweiSecondPlatform.getLoginAppId = function( self, loginType )
	return "1337";
end

--*****************************************************View平台界面********************************************************************************--
--[[
	className    	     :  HuaweiSecondPlatformView
	Description  	     :  平台界面类
	last-modified-date   :  Dec.2  2013
	create-time 	     :  Oct.22 2013
	last-modified-author :  ClarkWu
	create-author        :  ClarkWu
]]
HuaweiSecondPlatformView = class(CustomNode);

--[[
	function name	   : HuaweiSecondPlatformView.ctor
	description  	   : Construct the class.
	param 	 	 	   : self
	last-modified-date : Dec. 2 2013
	create-time  	   : Oct.22 2013
]]
HuaweiSecondPlatformView.ctor = function(self,loginTable)
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
	local x, y = CreatingViewUsingData.switchLoginView.loginBtn.x-70, CreatingViewUsingData.switchLoginView.loginBtn.y;
	for k,v in pairs(btnArray) do
		x = x + dist;
		v:setPos(x, y);
		self.btnView:addChild(v);
		x = x + CreatingViewUsingData.switchLoginView.loginBtn.split;
	end
	makeTheControlAdaptResolution(self.btnView);
	self.bg:addChild(self.btnView);
end

--[[
	function name	   : HuaweiSecondPlatformView.dtor
	description  	   : Destruct the class.
	param 	 	 	   : self
	last-modified-date : Dec. 2 2013
	create-time  	   : Oct.22 2013
]]
HuaweiSecondPlatformView.dtor = function(self)
	CustomNode.hide(self);
	self:removeAllChildren();
end

--[[
	function name	   : HuaweiSecondPlatformView.onClick
	description  	   : Destruct the class.
	param 	 	 	   : self
	last-modified-date : Dec. 2 2013
	create-time  	   : Oct.22 2013
]]
HuaweiSecondPlatformView.onClick = function(self,loginMethod)
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
	function name	   : HuaweiSecondPlatformView.createHuaweiBtn
	description  	   : create the Button of the guest.
	param 	 	 	   : self
	last-modified-date : Dec. 2 2013
	create-time  	   : Oct.22 2013
]]
HuaweiSecondPlatformView.createHuaweiBtn = function ( self )
	-- local btn = nil;
	-- btn = UICreator.createBtn(CreatingViewUsingData.switchLoginView.loginHuaWeiBtn.fileName, CreatingViewUsingData.switchLoginView.loginHuaWeiBtn.x, CreatingViewUsingData.switchLoginView.loginHuaWeiBtn.y, self, function ( self )
	-- 	self:onClick(PlatformConfig.HuaweiLogin);
	-- end);
	-- return btn;

	local btn = new(Node);
	local btnData = CreatingViewUsingData.switchLoginView.loginHuaWeiBtn;
	local huaweiBtn = UICreator.createBtn(btnData.fileName, btnData.x, btnData.y, self, function ( self )
		self:onClick(PlatformConfig.HuaweiLogin);
	end);
	for k,v in pairs(btnData) do 
		print(k,v)
	end
	local huaweiText = UICreator.createText(btnData.text, 45, -135, 150, 32, kAlignCenter, 28, 75, 43, 28);
	huaweiText:setAlign(kAlignBottom);
	btn:addChild(huaweiBtn);
	btn:addChild(huaweiText);

	return btn;
end

--华为平台的登录方式列表
HuaweiSecondPlatformView.loginBtnCreateFunMap = {
	[PlatformConfig.HuaweiLogin] = HuaweiSecondPlatformView.createHuaweiBtn,
};

