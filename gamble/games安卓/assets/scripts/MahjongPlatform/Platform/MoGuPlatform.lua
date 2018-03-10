--[[
	className    	     :  MoGuPlatform
	Description  	     :  平台类-子类(主平台))
	last-modified-date   :  Dec.2  2013
	create-time 	     :  Oct.22 2013
	last-modified-author :  ClarkWu
	create-author        :  ClarkWu
]]
--
require("MahjongPlatform/Platform/BasePlatform");

MoGuPlatform = class(BasePlatform);

--[[
	function name	   : MoGuPlatform.ctor
	description  	   : Construct a class.
	param 	 	 	   : self
						 api          -- Number    Every platform has different api.
						 loginTable   -- Table     Every platform has different login methods.  
	last-modified-date : Oct.22 2013
	create-time  	   : Oct.22 2013
]]
MoGuPlatform.ctor = function ( self)
	self.curDefaultPmode = 4; --默认为支付宝的商品

	-- 该表标识了该平台下支持的所有支付方式

	if DEBUGMODE == 1 then
		self.m_loginTable = {
			PlatformConfig.NewGuestLogin,
			PlatformConfig.QQLogin,
			PlatformConfig.BoyaaLogin,
			PlatformConfig.GuestLogin,
			PlatformConfig.WeChatLogin,
			PlatformConfig.SinaLogin,
		};
	else
		self.m_loginTable = {
			PlatformConfig.QQLogin,
			PlatformConfig.BoyaaLogin,
			PlatformConfig.GuestLogin,
			PlatformConfig.WeChatLogin,
			PlatformConfig.SinaLogin,
		};
	end

	self.logins = {};

	PayConfigDataManager.getInstance().m_verData = {
		PlatformConfig.MMPay,PlatformConfig.UnicomPay,PlatformConfig.YinLianPay,
		PlatformConfig.LoveAnimatePay,
		PlatformConfig.EGamePay,PlatformConfig.MiniStdAliPay,
		PlatformConfig.WeChatPay
	};--支付方式

	PayConfigDataManager.getInstance().m_defaultPayData = {};
	PayConfigDataManager.getInstance().m_defaultPayData[PlatformConfig.YinLianPay .. ""]    = {id = PlatformConfig.YinLianPay,limit = -1,tips = 0};
	PayConfigDataManager.getInstance().m_defaultPayData[PlatformConfig.MiniStdAliPay .. ""] = {id = PlatformConfig.MiniStdAliPay,limit = -1,tips = 0};
	PayConfigDataManager.getInstance().m_defaultPayData[PlatformConfig.WeChatPay .. ""]     = {id = PlatformConfig.WeChatPay,limit = -1,tips = 0};

end

-- 获取应用APPID信息
-- @Override
MoGuPlatform.getLoginAppId = function( self, loginType )
	return "186";
end

--是否要调用平台自己的离开方法
MoGuPlatform.isUsePlatformExit = function(self)
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
	function name	   : MoGuPlatform.dtor
	description  	   : Destructor a class.
	param 	 	 	   : self
	last-modified-date : Oct.22 2013
	create-time  	   : Oct.22 2013
]]
MoGuPlatform.dtor = function ( self )
end

MoGuPlatform.returnIsLianyunName = function(self)
	return PlatformConfig.feedback_platform_Trunk;
end

MoGuPlatform.isNeedPostApiHost = function(self)
	return true;
end

--[[
	function name	   : QihuPlatform.getLoginView
	description  	   : @Override.
	param 	 	 	   : self
	last-modified-date : Nov.29 2013
	create-time  	   : Nov.29 2013
]]
MoGuPlatform.getLoginView = function (self)
	return new(MoGuPlatformView,self.m_loginTable);
end

--是否显示绑定博雅通行证
MoGuPlatform.isNeedToShowBYPassCard = function ( self )
	-- body
	DebugLog("MoGuPlatform.isNeedToShowBYPassCard")
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
	function name	   : MoGuPlatform.getDefaultLoginMethod
	description  	   : @Override.
	param 	 	 	   : self
	last-modified-date : Oct.22 2013
	create-time  	   : Oct.22 2013
]]
MoGuPlatform.getDefaultLoginMethod = function ( self )
	local loginType = g_DiskDataMgr:getAppData(kLastLoginType, PlatformConfig.GuestLogin);
	local exist = self:existLoginType( loginType );
	if exist then
		return loginType;
	else
		return PlatformConfig.GuestLogin;
	end
end

MoGuPlatform.changeLoginMethod = function(self,loginMethod)
	if not self.logins[loginMethod] then
		self.logins[loginMethod] = new(self.getLoginMethodCls(loginMethod) or 
			self.getLoginMethodCls(PlatformConfig.GuestLogin));
	end
	return self.logins[loginMethod];
end

MoGuPlatform.getUnicomChannelId = function( self)
	return "00021488";
end

MoGuPlatform.isNeedChangeXueZhanLogo = function( self )
	return false;
end

MoGuPlatform.isUsePHPCheckMethod = function(self)
	return false;
end

--*****************************************************View平台界面********************************************************************************--
--[[
	className    	     :  MoGuPlatformView
	Description  	     :  平台界面类
	last-modified-date   :  Dec.2  2013
	create-time 	     :  Oct.22 2013
	last-modified-author :  ClarkWu
	create-author        :  ClarkWu
]]
MoGuPlatformView = class(BasePlatformView);

--[[
	function name	   : MoGuPlatformView.createGuestBtn
	description  	   : create the Button of the guest.
	param 	 	 	   : self
	last-modified-date : Dec. 2 2013
	create-time  	   : Oct.22 2013
]]
MoGuPlatformView.createGuestBtn = function ( self )
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

MoGuPlatformView.createNewGuestBtn = function ( self )
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
	function name	   : MoGuPlatformView.createQQBtn
	description  	   : create the Button of the QQ.
	param 	 	 	   : self
	last-modified-date : Dec. 2 2013
	create-time  	   : Oct.22 2013
]]
MoGuPlatformView.createQQBtn = function ( self )
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
	function name	   : MoGuPlatformView.createSinaBtn
	description  	   : create the Button of the Sina.
	param 	 	 	   : self
	last-modified-date : Dec. 2 2013
	create-time  	   : Oct.22 2013
]]
MoGuPlatformView.createSinaBtn = function ( self )
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
	function name	   : MoGuPlatformView.createBoyaaBtn
	description  	   : create the Button of the Boyaa.
	param 	 	 	   : self
	last-modified-date : Dec. 2 2013
	create-time  	   : Oct.22 2013
]]
MoGuPlatformView.createBoyaaBtn = function ( self )
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
	function name	   : MoGuPlatformView.createWeChatBtn
	description  	   : create the Button of the WeChat.
	param 	 	 	   : self
	last-modified-date : Dec. 2 2013
	create-time  	   : Oct.22 2013
]]
MoGuPlatformView.createWeChatBtn = function ( self )
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
MoGuPlatformView.loginBtnCreateFunMap = {
	[PlatformConfig.SinaLogin] 	= MoGuPlatformView.createSinaBtn,
	[PlatformConfig.QQLogin] 	= MoGuPlatformView.createQQBtn,
	[PlatformConfig.BoyaaLogin] = MoGuPlatformView.createBoyaaBtn,
	[PlatformConfig.WeChatLogin]= MoGuPlatformView.createWeChatBtn,
	[PlatformConfig.GuestLogin] = MoGuPlatformView.createGuestBtn,
	[PlatformConfig.NewGuestLogin] = MoGuPlatformView.createNewGuestBtn
};

--返回该平台对应的强制更新界面、首冲大礼包、普通更新界面、公告、签到界面的level
--强更>首冲>普更>公告>签到
MoGuPlatform.getPlatformLevel = function(self)
	return 20000,15000,10000,8000,6000;
end


