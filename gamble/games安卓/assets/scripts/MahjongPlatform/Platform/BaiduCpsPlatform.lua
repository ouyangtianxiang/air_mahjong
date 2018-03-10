--[[
	className    	     :  BaiduCpsPlatform
	Description  	     :  百度平台类-子类(百度品宣平台))
	last-modified-date   :  Dec.2  2013
	create-time 	     :  Oct.22 2013
	last-modified-author :  ClarkWu
	create-author        :  ClarkWu
]]
--
require("MahjongPlatform/Platform/BasePlatform");

BaiduCpsPlatform = class(BasePlatform);

--[[
	function name	   : BaiduCpsPlatform.ctor
	description  	   : Construct a class.
	param 	 	 	   : self
						 api          -- Number    Every platform has different api.
						 loginTable   -- Table     Every platform has different login methods.  
	last-modified-date : Oct.22 2013
	create-time  	   : Oct.22 2013
]]
BaiduCpsPlatform.ctor = function ( self)
	self.curDefaultPmode = 265; --默认为支付宝的商品

	if DEBUGMODE == 1 then
		self.m_loginTable = {
			PlatformConfig.NewGuestLogin,
			-- PlatformConfig.SinaLogin,
			PlatformConfig.QQLogin,
			-- PlatformConfig.BoyaaLogin,
			PlatformConfig.WeChatLogin,
			PlatformConfig.GuestLogin,
			PlatformConfig.CellphoneLogin
		};
	else
		self.m_loginTable = {
			-- PlatformConfig.SinaLogin,
			PlatformConfig.QQLogin,
			-- PlatformConfig.BoyaaLogin,
			PlatformConfig.WeChatLogin,
			PlatformConfig.GuestLogin,
			PlatformConfig.CellphoneLogin
		};
	end


	self.logins = {};

end

BaiduCpsPlatform.isLianYunNotChannel = function(self)
	return false;
end

--是否要调用平台自己的离开方法
BaiduCpsPlatform.isUsePlatformExit = function(self)
	return true;
end

-- 获取应用APPID信息
-- @Override
BaiduCpsPlatform.getLoginAppId = function( self, loginType )
	return "1316";
end

--[[
	function name	   : BaiduCpsPlatform.dtor
	description  	   : Destructor a class.
	param 	 	 	   : self
	last-modified-date : Oct.22 2013
	create-time  	   : Oct.22 2013
]]
BaiduCpsPlatform.dtor = function ( self )
end

BaiduCpsPlatform.returnIsLianyunName = function(self)
	return PlatformConfig.feedback_platform_BaiduCps;
end

--[[
	function name	   : QihuPlatform.getLoginView
	description  	   : @Override.
	param 	 	 	   : self
	last-modified-date : Nov.29 2013
	create-time  	   : Nov.29 2013
]]
BaiduCpsPlatform.getLoginView = function (self)
	return new(BaiduCpsPlatformView,self.m_loginTable);
end

BaiduCpsPlatform.isCancelBindBtn = function(self)
	return true;
end


--[[
	function name	   : BaiduCpsPlatform.getDefaultLoginMethod
	description  	   : @Override.
	param 	 	 	   : self
	last-modified-date : Oct.22 2013
	create-time  	   : Oct.22 2013
]]
BaiduCpsPlatform.getDefaultLoginMethod = function ( self )
	local loginType = g_DiskDataMgr:getAppData(kLastLoginType, PlatformConfig.GuestLogin);
	local exist = self:existLoginType( loginType );
	if exist then
		return loginType;
	else
		return PlatformConfig.GuestLogin;
	end
end

BaiduCpsPlatform.changeLoginMethod = function(self,loginMethod)
	if not self.logins[loginMethod] then
		self.logins[loginMethod] = new(self.getLoginMethodCls(loginMethod) or 
			self.getLoginMethodCls(PlatformConfig.GuestLogin));
	end
	return self.logins[loginMethod];
end

BaiduCpsPlatform.getUnicomChannelId = function(self)
	return "00021488";
end

--*****************************************************View平台界面********************************************************************************--
--[[
	className    	     :  BaiduCpsPlatformView
	Description  	     :  平台界面类
	last-modified-date   :  Dec.2  2013
	create-time 	     :  Oct.22 2013
	last-modified-author :  ClarkWu
	create-author        :  ClarkWu
]]
BaiduCpsPlatformView = class(BasePlatformView);

--[[
	function name	   : BaiduCpsPlatformView.createGuestBtn
	description  	   : create the Button of the guest.
	param 	 	 	   : self
	last-modified-date : Dec. 2 2013
	create-time  	   : Oct.22 2013
]]
BaiduCpsPlatformView.createGuestBtn = function ( self )
	local btn = nil;
	local btnData = CreatingViewUsingData.switchLoginView.vistorLoginBtn;
	btn = UICreator.createBtn(btnData.fileName, btnData.x, btnData.y, self, function ( self )
		self:onClick(PlatformConfig.GuestLogin);
	end);
	local text = UICreator.createText(btnData.text, 0, -36, 150, 32, kAlignCenter, 28, 75, 43, 28);
	text:setAlign(kAlignBottom);
	btn:addChild(text);
	return btn;
end

BaiduCpsPlatformView.createNewGuestBtn = function ( self )
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
	function name	   : BaiduCpsPlatformView.createQQBtn
	description  	   : create the Button of the QQ.
	param 	 	 	   : self
	last-modified-date : Dec. 2 2013
	create-time  	   : Oct.22 2013
]]
BaiduCpsPlatformView.createQQBtn = function ( self )
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
	function name	   : BaiduCpsPlatformView.createSinaBtn
	description  	   : create the Button of the Sina.
	param 	 	 	   : self
	last-modified-date : Dec. 2 2013
	create-time  	   : Oct.22 2013
]]
BaiduCpsPlatformView.createSinaBtn = function ( self )
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
	function name	   : BaiduCpsPlatformView.createBoyaaBtn
	description  	   : create the Button of the Boyaa.
	param 	 	 	   : self
	last-modified-date : Dec. 2 2013
	create-time  	   : Oct.22 2013
]]
BaiduCpsPlatformView.createBoyaaBtn = function ( self )
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
	function name	   : BaiduCpsPlatformView.createWeChatBtn
	description  	   : create the Button of the WeChat.
	param 	 	 	   : self
	last-modified-date : Dec. 2 2013
	create-time  	   : Oct.22 2013
]]
BaiduCpsPlatformView.createWeChatBtn = function ( self )
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

--创建手机帐号登陆按钮
BaiduCpsPlatformView.createCellPhoneBtn = function ( self )
	local btn = nil;
	local btnData = CreatingViewUsingData.switchLoginView.cellphoneLoginBtn;
	btn = UICreator.createBtn(btnData.fileName, btnData.x, btnData.y, self, function ( self )
        GameConstant.isDisplayView = true;
		self:onClick(PlatformConfig.CellphoneLogin);
        
	end);
	local text = UICreator.createText("手机登录", 0, -36, 150, 32, kAlignCenter, 28,  75, 43, 28);
	text:setAlign(kAlignBottom);
	btn:addChild(text);
	return btn;
end

--主平台的登录方式列表
BaiduCpsPlatformView.loginBtnCreateFunMap = {
	[PlatformConfig.SinaLogin] 	= BaiduCpsPlatformView.createSinaBtn,
	[PlatformConfig.QQLogin] 	= BaiduCpsPlatformView.createQQBtn,
	[PlatformConfig.BoyaaLogin] = BaiduCpsPlatformView.createBoyaaBtn,
	[PlatformConfig.WeChatLogin]= BaiduCpsPlatformView.createWeChatBtn,
	[PlatformConfig.GuestLogin] = BaiduCpsPlatformView.createGuestBtn,
	[PlatformConfig.NewGuestLogin] = BaiduCpsPlatformView.createNewGuestBtn,
	[PlatformConfig.CellphoneLogin] = BaiduCpsPlatformView.createCellPhoneBtn,
};

--返回该平台对应的强制更新界面、首冲大礼包、普通更新界面、公告、签到界面的level
--强更>首冲>普更>公告>签到
BaiduCpsPlatform.getPlatformLevel = function(self)
	return 20000,15000,10000,8000,6000;
end


