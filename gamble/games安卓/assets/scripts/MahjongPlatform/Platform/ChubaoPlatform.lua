--[[
	className    	     :  ChubaoPlatform
	Description  	     :  平台类-子类(触宝平台))
]]
require("MahjongCommon/CustomNode");
require("MahjongPlatform/Platform/BasePlatform");

ChubaoPlatform = class(BasePlatform);

--[[
	function name	   : ChubaoPlatform.ctor
	description  	   : Construct a class.
	param 	 	 	   : self
	last-modified-date : Oct.22 2013
	create-time  	   : Oct.22 2013
]]
ChubaoPlatform.ctor = function ( self)
	self.m_loginTable = {PlatformConfig.ChubaoLogin};

	self.logins = {};
end

ChubaoPlatform.returnIsLianyunName = function(self)
	return PlatformConfig.feedback_platform_Chubao;
end

--是否需要分享界面
ChubaoPlatform.needToShareWindow = function(self)
	return false;
end

--[[
	function name	   : ChubaoPlatform.getLoginView
	description  	   : @Override.
	param 	 	 	   : self
	last-modified-date : Nov.29 2013
	create-time  	   : Nov.29 2013
]]
ChubaoPlatform.getLoginView = function ( self)
	return new(ChubaoPlatformView,self.m_loginTable);
end

--[[
	function name	   : ChubaoPlatform.getDefaultLoginMethod
	description  	   : @Override.
	param 	 	 	   : self
	last-modified-date : Nov.29 2013
	create-time  	   : Nov.29 2013
]]
ChubaoPlatform.getDefaultLoginMethod = function ( self )
	local loginType = g_DiskDataMgr:getAppData(kLastLoginType, PlatformConfig.ChubaoLogin);
	return loginType;
end

ChubaoPlatform.changeLoginMethod = function(self,loginMethod)
   if not self.logins[loginMethod] then
		self.logins[loginMethod] = new(self.getLoginMethodCls(loginMethod) or 
			self.getLoginMethodCls(PlatformConfig.GuestLogin));
	end
	return self.logins[loginMethod];
end

-- 获取应用APPID信息
-- @Override
ChubaoPlatform.getLoginAppId = function( self, loginType )
	return "1806";
end

ChubaoPlatform.getUnicomChannelId = function(self)
	return "";
end

--*****************************************************View平台界面********************************************************************************--
--[[
	className    	     :  ChubaoPlatformView
	Description  	     :  平台界面类
	last-modified-date   :  Dec.2  2013
	create-time 	     :  Oct.22 2013
	last-modified-author :  ClarkWu
	create-author        :  ClarkWu
]]
ChubaoPlatformView = class(BasePlatformView);

--[[
	function name	   : ChubaoPlatformView.createChubaoBtn
	description  	   : create the Button of the guest.
	param 	 	 	   : self
	last-modified-date : Dec. 2 2013
	create-time  	   : Oct.22 2013
]]
ChubaoPlatformView.createChubaoBtn = function ( self )
	local btn = new(Node);
	local btnData = CreatingViewUsingData.switchLoginView.loginChubaoBtn;
	local loginBtn = UICreator.createBtn(btnData.fileName, btnData.x, btnData.y, self, function ( self )
		self:onClick(PlatformConfig.ChubaoLogin);
	end);
	for k,v in pairs(btnData) do 
		print(k,v)
	end
	local loginText = UICreator.createText(btnData.text, -25, -135, 150, 32, kAlignCenter, 28, 75, 43, 28);
	loginText:setAlign(kAlignBottom);
	btn:addChild(loginBtn);
	btn:addChild(loginText);

	return btn;
end

--华为平台的登录方式列表
ChubaoPlatformView.loginBtnCreateFunMap = {
	[PlatformConfig.ChubaoLogin] = ChubaoPlatformView.createChubaoBtn,
};

