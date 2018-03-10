--[[
	className    	     :  AnZhiPlatform
	Description  	     :  平台类-子类(华为平台))
	last-modified-date   :  Dec.2  2013
	create-time 	     :  Nov.29 2013
	last-modified-author :  ClarkWu
	create-author        :  ClarkWu
]]
require("MahjongCommon/CustomNode");
require("MahjongPlatform/Platform/BasePlatform");

AnZhiPlatform = class(BasePlatform);

--[[
	function name	   : AnZhiPlatform.ctor
	description  	   : Construct a class.
	param 	 	 	   : self
	last-modified-date : Oct.22 2013
	create-time  	   : Oct.22 2013
]]
AnZhiPlatform.ctor = function ( self)
	self.curDefaultPmode = 238; --默认为安智的商品mode
	self.m_loginTable = {PlatformConfig.AnZhiLogin};
	self.logins = {};
end

--[[
	function name	   : AnZhiPlatform.dtor
	description  	   : Destructor a class.
	param 	 	 	   : self
	last-modified-date : Oct.22 2013
	create-time  	   : Oct.22 2013
]]
AnZhiPlatform.dtor = function ( self )
end

AnZhiPlatform.returnIsLianyunName = function(self)
	return PlatformConfig.feedback_platform_anzhi;
end

--[[
	function name	   : AnZhiPlatform.getLoginView
	description  	   : @Override.
	param 	 	 	   : self
	last-modified-date : Nov.29 2013
	create-time  	   : Nov.29 2013
]]
AnZhiPlatform.getLoginView = function ( self)
	return new(AnZhiPlatformView,self.m_loginTable);
end

--[[
	function name	   : AnZhiPlatform.getDefaultLoginMethod
	description  	   : @Override.
	param 	 	 	   : self
	last-modified-date : Nov.29 2013
	create-time  	   : Nov.29 2013
]]
AnZhiPlatform.getDefaultLoginMethod = function ( self )
	local loginType = g_DiskDataMgr:getAppData(kLastLoginType, PlatformConfig.AnZhiLogin);
	return loginType;
end

AnZhiPlatform.changeLoginMethod = function(self,loginMethod)
     if not self.logins[loginMethod] then
		self.logins[loginMethod] = new(self.getLoginMethodCls(loginMethod) or 
			self.getLoginMethodCls(PlatformConfig.AnZhiLogin));
	end
	return self.logins[loginMethod];
end

-- 获取应用APPID信息
-- @Override
AnZhiPlatform.getLoginAppId = function( self, loginType )
	return "574";
end

-- 分享时应用名称
AnZhiPlatform.getApplicationShareName = function( self )
	return "安智血战麻将";
end

--是否显示平台精灵
AnZhiPlatform.isShowPlatformSprite = function(self)
	return true;
end

--是否要调用平台自己的离开方法
AnZhiPlatform.isUsePlatformExit = function(self)
	return true;
end

AnZhiPlatform.getUnicomChannelId = function( self)
	return "00020609";
end


--*****************************************************View平台界面********************************************************************************--
--[[
	className    	     :  AnZhiPlatformView
	Description  	     :  平台界面类
	last-modified-date   :  Feb.12 2014
	create-time 	     :  Feb.12 2014
	last-modified-author :  ClarkWu
	create-author        :  ClarkWu
]]
AnZhiPlatformView = class(BasePlatformView);

--[[
	function name	   : AnZhiPlatformView.createAnzhiBtn
	description  	   : create the Button of the baidu.
	param 	 	 	   : self
	last-modified-date : Feb.12 2014
	create-time  	   : Feb.12 2014
]]
AnZhiPlatformView.createAnzhiBtn = function(self)
	-- local btn = nil;
	-- btn = UICreator.createBtn(CreatingViewUsingData.switchLoginView.loginAnzhiBtn.fileName,CreatingViewUsingData.switchLoginView.loginAnzhiBtn.x,CreatingViewUsingData.switchLoginView.loginAnzhiBtn.y, self, function ( self )
	-- 	self:onClick(PlatformConfig.AnZhiLogin);
	-- end);
	local btn = new(Node);
	local btnData = CreatingViewUsingData.switchLoginView.loginAnzhiBtn;
	local anzhiBtn = UICreator.createBtn(btnData.fileName, btnData.x, btnData.y, self, function ( self )
		self:onClick(PlatformConfig.AnZhiLogin);
	end);
	for k,v in pairs(btnData) do 
		print(k,v)
	end
	local anzhiText = UICreator.createText(btnData.text, -45, -135, 150, 32, kAlignCenter, 28, 75, 43, 28);
	anzhiText:setAlign(kAlignBottom);
	btn:addChild(anzhiBtn);
	btn:addChild(anzhiText);

	return btn;
end

--华为平台的登录方式列表
AnZhiPlatformView.loginBtnCreateFunMap = {
	[PlatformConfig.AnZhiLogin] = AnZhiPlatformView.createAnzhiBtn,
};


