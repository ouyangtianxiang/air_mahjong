--[[
	className    	     :  QihuPlatform
	Description  	     :  平台类-子类(奇虎平台))
	last-modified-date   :  Dec.18  2013
	create-time 	     :  Dec.18  2013
	last-modified-author :  ClarkWu
	create-author        :  ClarkWu
]]
require("MahjongCommon/CustomNode");
require("MahjongPlatform/Platform/BasePlatform");

QihuPlatform = class(BasePlatform);

--[[
	function name	   : QihuPlatform.ctor
	description  	   : Construct a class.
	param 	 	 	   : self
					     api          -- Number    Every platform has different api.
					     loginTable   -- Table     Every platform has different login methods.  
	last-modified-date : Oct.22 2013
	create-time  	   : Oct.22 2013
]]
QihuPlatform.ctor = function ( self)
	self.curDefaultPmode = 136;
	self.m_loginTable = {PlatformConfig.QiHuLogin};

	self.logins = {};
end

--[[
	function name	   : QihuPlatform.dtor
	description  	   : Destructor a class.
	param 	 	 	   : self
	last-modified-date : Oct.22 2013
	create-time  	   : Oct.22 2013
]]
QihuPlatform.dtor = function ( self )
end

QihuPlatform.returnIsLianyunName = function(self)
	return PlatformConfig.feedback_platform_qihoo;
end

--[[
	function name	   : QihuPlatform.getLoginView
	description  	   : @Override.
	param 	 	 	   : self
	last-modified-date : Nov.29 2013
	create-time  	   : Nov.29 2013
]]
QihuPlatform.getLoginView = function ( self,hallRef )
	return new(QihuPlatformView,self.m_loginTable);
end

--[[
	function name	   : QihuPlatform.getDefaultLoginMethod
	description  	   : @Override.
	param 	 	 	   : self
	last-modified-date : Nov.29 2013
	create-time  	   : Nov.29 2013
]]
QihuPlatform.getDefaultLoginMethod = function ( self )
	local loginType = g_DiskDataMgr:getAppData(kLastLoginType, PlatformConfig.QiHuLogin);
	return loginType;
end


function QihuPlatform:needToShareWindow(  )
	return false
end

-- 获取应用APPID信息
-- @Override
QihuPlatform.getLoginAppId = function( self, loginType )
	return "335";
end

QihuPlatform.changeLoginMethod = function(self,loginMethod)
	if not self.logins[loginMethod] then
		self.logins[loginMethod] = new(self.getLoginMethodCls(loginMethod) or 
			self.getLoginMethodCls(PlatformConfig.GuestLogin));
	end
	return self.logins[loginMethod];
end

QihuPlatform.getUnicomChannelId = function(self)
	return "00018594";
end

--*****************************************************View平台界面********************************************************************************--
--[[
	className    	     :  QihuPlatformView
	Description  	     :  平台界面类
	last-modified-date   :  Dec.2  2013
	create-time 	     :  Oct.22 2013
	last-modified-author :  ClarkWu
	create-author        :  ClarkWu
]]
QihuPlatformView = class(BasePlatformView);

--[[
	function name	   : QihuPlatformView.createQihuBtn
	description  	   : create the Button of the 360.
	param 	 	 	   : self
	last-modified-date : Dec.18 2013
	create-time  	   : Dec.18 2013
]]
QihuPlatformView.createQihuBtn = function(self)
	local btn = new(Node);
	local btnData = CreatingViewUsingData.switchLoginView.login360Btn;
	local huaweiBtn = UICreator.createBtn(btnData.fileName, btnData.x, btnData.y, self, function ( self )
		self:onClick(PlatformConfig.QiHuLogin);
	end);
	for k,v in pairs(btnData) do 
		print(k,v)
	end
	local huaweiText = UICreator.createText(btnData.text, -30, -135, 150, 32, kAlignCenter, 28, 75, 43, 28);
	huaweiText:setAlign(kAlignBottom);
	btn:addChild(huaweiBtn);
	btn:addChild(huaweiText);

	return btn;
end

--奇虎平台的登录方式列表
QihuPlatformView.loginBtnCreateFunMap = {
	[PlatformConfig.QiHuLogin] = QihuPlatformView.createQihuBtn
};

