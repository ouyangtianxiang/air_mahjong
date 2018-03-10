--[[
	className    	     :  UnicomPlatform
	Description  	     :  平台类-子类(主平台))
	last-modified-date   :  Dec.2  2013
	create-time 	     :  Oct.22 2013
	last-modified-author :  ClarkWu
	create-author        :  ClarkWu
]]
--
require("MahjongPlatform/Platform/BasePlatform");

UnicomPlatform = class(BasePlatform);

--[[
	function name	   : UnicomPlatform.ctor
	description  	   : Construct a class.
	param 	 	 	   : self
						 api          -- Number    Every platform has different api.
						 loginTable   -- Table     Every platform has different login methods.  
	last-modified-date : Oct.22 2013
	create-time  	   : Oct.22 2013
]]
UnicomPlatform.ctor = function ( self)
	self.curDefaultPmode = 4; --默认为支付宝的商品

	-- 该表标识了该平台下支持的所有支付方式

	if DEBUGMODE == 1 then
		self.m_loginTable = {
			PlatformConfig.NewGuestLogin,
			PlatformConfig.QQLogin,
			PlatformConfig.BoyaaLogin,
			PlatformConfig.GuestLogin,
			PlatformConfig.CellphoneLogin
		};
	else
		self.m_loginTable = {
			PlatformConfig.QQLogin,
			PlatformConfig.BoyaaLogin,
			PlatformConfig.GuestLogin,
			PlatformConfig.CellphoneLogin
		};
	end

	self.logins = {};

end

UnicomPlatform.isCancelBindBtn = function(self)
	return true;
end

-- 获取应用APPID信息
-- @Override
UnicomPlatform.getLoginAppId = function( self, loginType )
	if GameConstant.platformType == PlatformConfig.platformUnicomWdj then 
		return "1671"
	elseif GameConstant.platformType == PlatformConfig.platformWOSHOP then 
		return "256"
	end
end

--获取联通渠道号
UnicomPlatform.getUnicomChannelId = function(self)
	if GameConstant.platformType == PlatformConfig.platformUnicomWdj then 
		return "00018756"
	elseif GameConstant.platformType == PlatformConfig.platformWOSHOP then 
		return "00012243";
	end
end

--是否要调用平台自己的离开方法
UnicomPlatform.isUsePlatformExit = function(self)
	if PlayerManager.getInstance():myself().mid <= 0 or GameConstant.isShowAwardView == 0 then 
		return false;
	end
	if GameConstant.isShowAwardView == 1 then 
		local mid = PlayerManager.getInstance():myself().mid or "";
		local old_day = g_DiskDataMgr:getUserData(mid,'showAwardExit',1)
		local today = os.date("%Y%m%d");
		if today - old_day >= 1 then 
			g_DiskDataMgr:setUserData(mid,'showAwardExit',os.date("%Y%m%d"))
			return true;
		else
			return false;
		end
	end

end

--[[
	function name	   : UnicomPlatform.dtor
	description  	   : Destructor a class.
	param 	 	 	   : self
	last-modified-date : Oct.22 2013
	create-time  	   : Oct.22 2013
]]
UnicomPlatform.dtor = function ( self )
end

UnicomPlatform.returnIsLianyunName = function(self)
	return PlatformConfig.feedback_platform_unicom;
end

UnicomPlatform.isNeedPostApiHost = function(self)
	return true;
end

--[[
	function name	   : QihuPlatform.getLoginView
	description  	   : @Override.
	param 	 	 	   : self
	last-modified-date : Nov.29 2013
	create-time  	   : Nov.29 2013
]]
UnicomPlatform.getLoginView = function (self)
	return new(UnicomPlatformView,self.m_loginTable);
end

--是否显示绑定博雅通行证
UnicomPlatform.isNeedToShowBYPassCard = function ( self )
	-- body
	DebugLog("UnicomPlatform.isNeedToShowBYPassCard")
	if self:getCurrentLoginType() == PlatformConfig.GuestLogin then

		local loginUtil = self.loginUtls[PlatformConfig.GuestLogin];
		if loginUtil and loginUtil.visitorBounded then
			DebugLog("return false")
			return false;
		end
		DebugLog("return true")
		return true;
		
	end
	DebugLog("return nil")
end

--[[
	function name	   : UnicomPlatform.getDefaultLoginMethod
	description  	   : @Override.
	param 	 	 	   : self
	last-modified-date : Oct.22 2013
	create-time  	   : Oct.22 2013
]]
UnicomPlatform.getDefaultLoginMethod = function ( self )
	local loginType = g_DiskDataMgr:getAppData(kLastLoginType, PlatformConfig.GuestLogin);
	local exist = self:existLoginType( loginType );
	if exist then
		return loginType;
	else
		return PlatformConfig.GuestLogin;
	end
end

UnicomPlatform.changeLoginMethod = function(self,loginMethod)
	if not self.logins[loginMethod] then
		self.logins[loginMethod] = new(self.getLoginMethodCls(loginMethod) or 
			self.getLoginMethodCls(PlatformConfig.GuestLogin));
	end
	return self.logins[loginMethod];
end

UnicomPlatform.isNeedChangeXueZhanLogo = function( self )
	return false;
end

UnicomPlatform.isUsePHPCheckMethod = function(self)
	return false;
end

--*****************************************************View平台界面********************************************************************************--
--[[
	className    	     :  UnicomPlatformView
	Description  	     :  平台界面类
	last-modified-date   :  Dec.2  2013
	create-time 	     :  Oct.22 2013
	last-modified-author :  ClarkWu
	create-author        :  ClarkWu
]]
UnicomPlatformView = class(BasePlatformView);

--[[
	function name	   : UnicomPlatformView.createGuestBtn
	description  	   : create the Button of the guest.
	param 	 	 	   : self
	last-modified-date : Dec. 2 2013
	create-time  	   : Oct.22 2013
]]
UnicomPlatformView.createGuestBtn = function ( self )
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

UnicomPlatformView.createNewGuestBtn = function ( self )
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

--[[
	function name	   : UnicomPlatformView.createQQBtn
	description  	   : create the Button of the QQ.
	param 	 	 	   : self
	last-modified-date : Dec. 2 2013
	create-time  	   : Oct.22 2013
]]
UnicomPlatformView.createQQBtn = function ( self )
	local btn = nil;
	local btnData = CreatingViewUsingData.switchLoginView.qqLoginBtn;
	btn = UICreator.createBtn(btnData.fileName, btnData.x, btnData.y, self, function ( self )
		self:onClick(PlatformConfig.QQLogin);
	end);
	local text = UICreator.createText(btnData.text, 0, -36, 150, 32, kAlignCenter, 28,  75, 43, 28);
	text:setAlign(kAlignBottom);
	btn:addChild(text);
	return btn;
end

--[[
	function name	   : UnicomPlatformView.createSinaBtn
	description  	   : create the Button of the Sina.
	param 	 	 	   : self
	last-modified-date : Dec. 2 2013
	create-time  	   : Oct.22 2013
]]
UnicomPlatformView.createSinaBtn = function ( self )
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
	function name	   : UnicomPlatformView.createBoyaaBtn
	description  	   : create the Button of the Boyaa.
	param 	 	 	   : self
	last-modified-date : Dec. 2 2013
	create-time  	   : Oct.22 2013
]]
UnicomPlatformView.createBoyaaBtn = function ( self )
	local btn = nil;
	local btnData = CreatingViewUsingData.switchLoginView.boyaaLoginBtn;
	btn = UICreator.createBtn(btnData.fileName, btnData.x, btnData.y, self, function ( self )
		self:onClick(PlatformConfig.BoyaaLogin);
	end);
	local text = UICreator.createText(btnData.text, 0, -36, 150, 32, kAlignCenter, 28,  75, 43, 28);
	text:setAlign(kAlignBottom);
	btn:addChild(text);
	return btn;
end

--[[
	function name	   : UnicomPlatformView.createWeChatBtn
	description  	   : create the Button of the WeChat.
	param 	 	 	   : self
	last-modified-date : Dec. 2 2013
	create-time  	   : Oct.22 2013
]]
UnicomPlatformView.createWeChatBtn = function ( self )
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

UnicomPlatformView.createCellphoneBtn = function(self)
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
UnicomPlatformView.loginBtnCreateFunMap = {
	[PlatformConfig.SinaLogin] 	= UnicomPlatformView.createSinaBtn,
	[PlatformConfig.QQLogin] 	= UnicomPlatformView.createQQBtn,
	[PlatformConfig.BoyaaLogin] = UnicomPlatformView.createBoyaaBtn,
	[PlatformConfig.WeChatLogin]= UnicomPlatformView.createWeChatBtn,
	[PlatformConfig.GuestLogin] = UnicomPlatformView.createGuestBtn,
	[PlatformConfig.NewGuestLogin] = UnicomPlatformView.createNewGuestBtn,
	[PlatformConfig.CellphoneLogin] = UnicomPlatformView.createCellphoneBtn
};

--返回该平台对应的强制更新界面、首冲大礼包、普通更新界面、公告、签到界面的level
--强更>首冲>普更>公告>签到
UnicomPlatform.getPlatformLevel = function(self)
	return 20000,15000,10000,8000,6000;
end


