--[[
	className    	     :  YiXinPlatform
	Description  	     :  平台类-子类(百度平台))
	last-modified-date   :  Feb.12 2014
	create-time 	     :  Feb.12 2014
	last-modified-author :  ClarkWu
	create-author        :  ClarkWu
]]
require("MahjongCommon/CustomNode");
--
require("MahjongPlatform/Platform/BasePlatform");

YiXinPlatform = class(BasePlatform);

--[[
	function name	   : YiXinPlatform.ctor
	description  	   : Construct a class.
	param 	 	 	   : self
	last-modified-date : Feb.12 2014
	create-time  	   : Feb.12 2014
]]
YiXinPlatform.ctor = function ( self)
	self.curDefaultPmode = 34; --默认为多酷的商品 4
	self.m_loginTable = {PlatformConfig.YiXinLogin};

	if DEBUGMODE == 1 then
		self.m_loginTable = {
			PlatformConfig.NewGuestLogin,
			PlatformConfig.YiXinLogin,
		};
	else
		self.m_loginTable = {
			 PlatformConfig.YiXinLogin
		};
	end
	
	self.m_loginMethods = {};

	
end

--[[
	function name	   : YiXinPlatform.dtor
	description  	   : Destructor a class.
	param 	 	 	   : self
	last-modified-date : Feb.12 2014
	create-time  	   : Feb.12 2014
]]
YiXinPlatform.dtor = function ( self )
end

YiXinPlatform.returnIsLianyunName = function(self)
	return PlatformConfig.feedback_platform_YiXin;
end

--[[
	function name	   : YiXinPlatform.getLoginView
	description  	   : @Override.
	param 	 	 	   : self
	last-modified-date : Feb.12 2014
	create-time  	   : Feb.12 2014
]]
YiXinPlatform.getLoginView = function ( self)
	return new(YiXinPlatformView,self.m_loginTable);
end

--[[
	function name	   : YiXinPlatform.getDefaultLoginMethod
	description  	   : @Override.
	param 	 	 	   : self
	last-modified-date : Feb.12 2014
	create-time  	   : Feb.12 2014
]]
YiXinPlatform.getDefaultLoginMethod = function ( self )
	local loginType = g_DiskDataMgr:getAppData(kLastLoginType, PlatformConfig.YiXinLogin);
	if not self.super.existLoginType( self, loginType ) then
		return PlatformConfig.YiXinLogin;
	end
	return loginType;
end

YiXinPlatform.changeLoginMethod = function(self,loginMethod)
	-- if PlatformConfig.BaiduLogin ~= loginMethod then 
	-- 	DebugLog("请检查登录方式,没有对应的loginMethod");
	-- end 											
	if loginMethod and not self.m_loginMethods[loginMethod] then 
		require("MahjongLogin/LoginMethod/YiXinLogin");
		self.m_loginMethods[loginMethod] = new(self.getLoginMethodCls(loginMethod) or YiXinLogin);
	end
	return self.m_loginMethods[loginMethod];
end

-- 获取应用APPID信息
-- @Override
YiXinPlatform.getLoginAppId = function( self, loginType )
	return "7340";
end

-- 分享时应用名称
YiXinPlatform.getApplicationShareName = function( self )
	return "易信四川麻将";
end

YiXinPlatform.isLianYunNotChannel = function(self)
	return false;
end

--*****************************************************View平台界面********************************************************************************--
--[[
	className    	     :  YiXinPlatformView
	Description  	     :  平台界面类
	last-modified-date   :  Feb.12 2014
	create-time 	     :  Feb.12 2014
	last-modified-author :  ClarkWu
	create-author        :  ClarkWu
]]
YiXinPlatformView = class(BasePlatformView);

--[[
	function name	   : TrunkPlatformView.createYiXinBtn
	description  	   : create the Button of the YiXin.
	param 	 	 	   : self
	last-modified-date : Dec. 2 2013
	create-time  	   : Oct.22 2013
]]
YiXinPlatformView.createYiXinBtn = function ( self )
	local btn = nil;
	local btnData = CreatingViewUsingData.switchLoginView.yixinLoginBtn;
	btn = UICreator.createBtn(btnData.fileName, btnData.x, btnData.y, self, function ( self )
		self:onClick(PlatformConfig.YiXinLogin);
	end);
	local text = UICreator.createText(btnData.text, 0, -36, 150, 32, kAlignCenter, 28, 75, 43, 28);
	text:setAlign(kAlignBottom);
	btn:addChild(text);
	return btn;
end

YiXinPlatformView.createNewGuestBtn = function ( self )
	local btn = nil;
	local btnData = CreatingViewUsingData.switchLoginView.vistorLoginBtn;
	btn = UICreator.createBtn(btnData.fileName, btnData.x, btnData.y, self, function ( self )
		self:onClick(PlatformConfig.NewGuestLogin);
	end);
	local text = UICreator.createText("创建新游客", 0, -36, 150, 32, kAlignCenter, 28,  75, 43, 28);
	text:setAlign(kAlignBottom);
	btn:addChild(text);
	return btn;
end

--易信联运的登录方式列表
YiXinPlatformView.loginBtnCreateFunMap = {
	[PlatformConfig.YiXinLogin] 	= YiXinPlatformView.createYiXinBtn,
	[PlatformConfig.NewGuestLogin] = YiXinPlatformView.createNewGuestBtn
};