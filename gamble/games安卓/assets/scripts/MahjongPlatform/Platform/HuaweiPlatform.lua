--[[
	className    	     :  HuaweiPlatform
	Description  	     :  平台类-子类(华为平台))
	last-modified-date   :  Dec.2  2013
	create-time 	     :  Nov.29 2013
	last-modified-author :  ClarkWu
	create-author        :  ClarkWu
]]
require("MahjongCommon/CustomNode");
require("MahjongPlatform/Platform/BasePlatform");

HuaweiPlatform = class(BasePlatform);

--[[
	function name	   : HuaweiPlatform.ctor
	description  	   : Construct a class.
	param 	 	 	   : self
	last-modified-date : Oct.22 2013
	create-time  	   : Oct.22 2013
]]
HuaweiPlatform.ctor = function ( self)
	self.curDefaultPmode = 274; --默认为华为的商品
	self.m_loginTable = {PlatformConfig.HuaweiLogin};

	self.logins = {};
end

HuaweiPlatform.returnIsLianyunName = function(self)
	return PlatformConfig.feedback_platform_Huawei;
end

--是否需要分享界面
HuaweiPlatform.needToShareWindow = function(self)
	return false;
end

--[[
	function name	   : HuaweiPlatform.getLoginView
	description  	   : @Override.
	param 	 	 	   : self
	last-modified-date : Nov.29 2013
	create-time  	   : Nov.29 2013
]]
HuaweiPlatform.getLoginView = function ( self)
	return new(HuaweiPlatformView,self.m_loginTable);
end

--[[
	function name	   : HuaweiPlatform.getDefaultLoginMethod
	description  	   : @Override.
	param 	 	 	   : self
	last-modified-date : Nov.29 2013
	create-time  	   : Nov.29 2013
]]
HuaweiPlatform.getDefaultLoginMethod = function ( self )
	local loginType = g_DiskDataMgr:getAppData(kLastLoginType, PlatformConfig.HuaweiLogin);
	return loginType;
end

HuaweiPlatform.changeLoginMethod = function(self,loginMethod)
   if not self.logins[loginMethod] then
		self.logins[loginMethod] = new(self.getLoginMethodCls(loginMethod) or 
			self.getLoginMethodCls(PlatformConfig.GuestLogin));
	end
	return self.logins[loginMethod];
end

-- 获取应用APPID信息
-- @Override
HuaweiPlatform.getLoginAppId = function( self, loginType )
	return "432";
end

HuaweiPlatform.getUnicomChannelId = function(self)
	return "00018755";
end

--*****************************************************View平台界面********************************************************************************--
--[[
	className    	     :  HuaweiPlatformView
	Description  	     :  平台界面类
	last-modified-date   :  Dec.2  2013
	create-time 	     :  Oct.22 2013
	last-modified-author :  ClarkWu
	create-author        :  ClarkWu
]]
HuaweiPlatformView = class(BasePlatformView);

--[[
	function name	   : HuaweiPlatformView.createHuaweiBtn
	description  	   : create the Button of the guest.
	param 	 	 	   : self
	last-modified-date : Dec. 2 2013
	create-time  	   : Oct.22 2013
]]
HuaweiPlatformView.createHuaweiBtn = function ( self )
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
	local huaweiText = UICreator.createText(btnData.text, -25, -135, 150, 32, kAlignCenter, 28, 75, 43, 28);
	huaweiText:setAlign(kAlignBottom);
	btn:addChild(huaweiBtn);
	btn:addChild(huaweiText);

	return btn;
end

--华为平台的登录方式列表
HuaweiPlatformView.loginBtnCreateFunMap = {
	[PlatformConfig.HuaweiLogin] = HuaweiPlatformView.createHuaweiBtn,
};

