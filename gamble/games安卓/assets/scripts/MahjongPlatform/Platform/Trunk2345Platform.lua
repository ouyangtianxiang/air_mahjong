--[[
	className    	     :  Trunk2345Platform
	Description  	     :  平台类-子类(主平台))
	last-modified-date   :  Dec.2  2013
	create-time 	     :  Oct.22 2013
	last-modified-author :  ClarkWu
	create-author        :  ClarkWu
]]
--
require("MahjongPlatform/Platform/BasePlatform");

Trunk2345Platform = class(BasePlatform);

--[[
	function name	   : Trunk2345Platform.ctor
	description  	   : Construct a class.
	param 	 	 	   : self
						 api          -- Number    Every platform has different api.
						 loginTable   -- Table     Every platform has different login methods.  
	last-modified-date : Oct.22 2013
	create-time  	   : Oct.22 2013
]]
Trunk2345Platform.ctor = function ( self)
	self.curDefaultPmode = 4; --默认为支付宝的商品

	-- 该表标识了该平台下支持的所有支付方式

	if DEBUGMODE == 1 then
		self.m_loginTable = {
			PlatformConfig.NewGuestLogin,
			PlatformConfig.SinaLogin,
			PlatformConfig.QQLogin,
			PlatformConfig.BoyaaLogin,
			PlatformConfig.WeChatLogin,
			PlatformConfig.Guest2345Login
		};
	else
		self.m_loginTable = {
			PlatformConfig.SinaLogin,
			PlatformConfig.QQLogin,
			PlatformConfig.BoyaaLogin,
			PlatformConfig.WeChatLogin,
			PlatformConfig.Guest2345Login
		};
	end

	self.logins = {};
end

-- 获取应用APPID信息
-- @Override
Trunk2345Platform.getLoginAppId = function( self, loginType )
	if loginType == PlatformConfig.Guest2345Login then
		return "186";
	elseif loginType == PlatformConfig.BoyaaLogin then 
		return "186";
	elseif loginType == PlatformConfig.SinaLogin then 
		return "185";
	elseif loginType == PlatformConfig.QQLogin then 
		return "198";
	elseif loginType == PlatformConfig.WeChatLogin then 
		return "171";
	end
end

--[[
	function name	   : Trunk2345Platform.dtor
	description  	   : Destructor a class.
	param 	 	 	   : self
	last-modified-date : Oct.22 2013
	create-time  	   : Oct.22 2013
]]
Trunk2345Platform.dtor = function ( self )
end

Trunk2345Platform.returnIsLianyunName = function(self)
	return PlatformConfig.feedback_platform_2345;
end

Trunk2345Platform.isNeedPostApiHost = function(self)
	return true;
end

--[[
	function name	   : QihuPlatform.getLoginView
	description  	   : @Override.
	param 	 	 	   : self
	last-modified-date : Nov.29 2013
	create-time  	   : Nov.29 2013
]]
Trunk2345Platform.getLoginView = function (self)
	return new(Trunk2345PlatformView,self.m_loginTable);
end

--[[
	function name	   : Trunk2345Platform.getDefaultLoginMethod
	description  	   : @Override.
	param 	 	 	   : self
	last-modified-date : Oct.22 2013
	create-time  	   : Oct.22 2013
]]
Trunk2345Platform.getDefaultLoginMethod = function ( self )
	local loginType = g_DiskDataMgr:getAppData(kLastLoginType, PlatformConfig.Guest2345Login);
	local exist = self:existLoginType( loginType );
	if exist then
		return loginType;
	else
		return PlatformConfig.Guest2345Login;
	end
end

Trunk2345Platform.changeLoginMethod = function(self,loginMethod)
	if not self.logins[loginMethod] then
		self.logins[loginMethod] = new(self.getLoginMethodCls(loginMethod) or 
			self.getLoginMethodCls(PlatformConfig.Guest2345Login));
	end
	return self.logins[loginMethod];
end

Trunk2345Platform.isNeedChangeXueZhanLogo = function( self )
	return false;
end

--*****************************************************View平台界面********************************************************************************--
--[[
	className    	     :  Trunk2345PlatformView
	Description  	     :  平台界面类
	last-modified-date   :  Dec.2  2013
	create-time 	     :  Oct.22 2013
	last-modified-author :  ClarkWu
	create-author        :  ClarkWu
]]
Trunk2345PlatformView = class(BasePlatformView);

--[[
	function name	   : Trunk2345PlatformView.createGuestBtn
	description  	   : create the Button of the guest.
	param 	 	 	   : self
	last-modified-date : Dec. 2 2013
	create-time  	   : Oct.22 2013
]]
Trunk2345PlatformView.createGuestBtn = function ( self )
	local btn = nil;
	local btnData = CreatingViewUsingData.switchLoginView.vistorLoginBtn;
	btn = UICreator.createBtn(btnData.fileName, btnData.x, btnData.y, self, function ( self )
		self:onClick(PlatformConfig.Guest2345Login);
	end);
	local text = UICreator.createText(btnData.text, 0, -36, 150, 32, kAlignCenter, 28, 75, 43, 28);
	text:setAlign(kAlignBottom);
	btn:addChild(text);
	return btn;
end

Trunk2345PlatformView.createNewGuestBtn = function ( self )
	local btn = nil;
	local btnData = CreatingViewUsingData.switchLoginView.vistorLoginBtn;
	btn = UICreator.createBtn(btnData.fileName, btnData.x, btnData.y, self, function ( self )
		self:onClick(PlatformConfig.NewGuestLogin);
	end);
	local text = UICreator.createText("创建新游客", 0, -36, 150, 32, kAlignCenter, 28, 75, 43, 28);
	text:setAlign(kAlignBottom);
	btn:addChild(text);
	return btn;
end

--[[
	function name	   : Trunk2345PlatformView.createQQBtn
	description  	   : create the Button of the QQ.
	param 	 	 	   : self
	last-modified-date : Dec. 2 2013
	create-time  	   : Oct.22 2013
]]
Trunk2345PlatformView.createQQBtn = function ( self )
	local btn = nil;
	local btnData = CreatingViewUsingData.switchLoginView.qqLoginBtn;
	btn = UICreator.createBtn(btnData.fileName, btnData.x, btnData.y, self, function ( self )
		self:onClick(PlatformConfig.QQLogin);
	end);
	local text = UICreator.createText(btnData.text, 0, -36, 150, 32, kAlignCenter, 28, 75, 43, 28);
	text:setAlign(kAlignBottom);
	btn:addChild(text);
	return btn;
end

--[[
	function name	   : Trunk2345PlatformView.createSinaBtn
	description  	   : create the Button of the Sina.
	param 	 	 	   : self
	last-modified-date : Dec. 2 2013
	create-time  	   : Oct.22 2013
]]
Trunk2345PlatformView.createSinaBtn = function ( self )
	local btn = nil;
	local btnData = CreatingViewUsingData.switchLoginView.sinaLoginBtn;
	btn = UICreator.createBtn(btnData.fileName, btnData.x, btnData.y, self, function ( self )
		self:onClick(PlatformConfig.SinaLogin);
	end);
	local text = UICreator.createText(btnData.text, 0, -36, 150, 32, kAlignCenter, 28, 75, 43, 28);
	text:setAlign(kAlignBottom);
	btn:addChild(text);
	return btn;
end

--[[
	function name	   : Trunk2345PlatformView.createBoyaaBtn
	description  	   : create the Button of the Boyaa.
	param 	 	 	   : self
	last-modified-date : Dec. 2 2013
	create-time  	   : Oct.22 2013
]]
Trunk2345PlatformView.createBoyaaBtn = function ( self )
	local btn = nil;
	local btnData = CreatingViewUsingData.switchLoginView.boyaaLoginBtn;
	btn = UICreator.createBtn(btnData.fileName, btnData.x, btnData.y, self, function ( self )
		self:onClick(PlatformConfig.BoyaaLogin);
	end);
	local text = UICreator.createText(btnData.text, 0, -36, 150, 32, kAlignCenter, 28, 75, 43, 28);
	text:setAlign(kAlignBottom);
	btn:addChild(text);
	return btn;
end

--[[
	function name	   : Trunk2345PlatformView.createWeChatBtn
	description  	   : create the Button of the WeChat.
	param 	 	 	   : self
	last-modified-date : Dec. 2 2013
	create-time  	   : Oct.22 2013
]]
Trunk2345PlatformView.createWeChatBtn = function ( self )
	local btn = nil;
	local btnData = CreatingViewUsingData.switchLoginView.loginWeChatBtn;
	btn = UICreator.createBtn(btnData.fileName, btnData.x, btnData.y, self, function ( self )
		self:onClick(PlatformConfig.WeChatLogin);
	end);
	local text = UICreator.createText(btnData.text, 0, -36, 150, 32, kAlignCenter, 28, 75, 43, 28);
	text:setAlign(kAlignBottom);
	btn:addChild(text);
	return btn;
end

--主平台的登录方式列表
Trunk2345PlatformView.loginBtnCreateFunMap = {
	[PlatformConfig.SinaLogin] 	= Trunk2345PlatformView.createSinaBtn,
	[PlatformConfig.QQLogin] 	= Trunk2345PlatformView.createQQBtn,
	[PlatformConfig.BoyaaLogin] = Trunk2345PlatformView.createBoyaaBtn,
	[PlatformConfig.WeChatLogin]= Trunk2345PlatformView.createWeChatBtn,
	[PlatformConfig.Guest2345Login] = Trunk2345PlatformView.createGuestBtn,
	[PlatformConfig.NewGuestLogin] = Trunk2345PlatformView.createNewGuestBtn
};

--返回该平台对应的强制更新界面、首冲大礼包、普通更新界面、公告、签到界面的level
--强更>首冲>普更>公告>签到
Trunk2345Platform.getPlatformLevel = function(self)
	return 20000,15000,10000,8000,6000;
end

-- 该平台的应用名称
-- @Override
Trunk2345Platform.getApplicationShareName = function( self )
	return "博雅四川麻将！";
end

