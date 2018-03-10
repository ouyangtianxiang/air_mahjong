--[[
	className    	     :  BasePlatform
	Description  	     :  To wrap all the platform,this is an abstract class.
				    	    which duplicate this method,must implement its all methods.
	last-modified-date   :  Dec. 2 2013
	create-time 	   	 :  Oct.22 2013
	last-modified-author :  ClarkWu
	create-author        :　jkinLiu
]]
require("MahjongCommon/CustomNode");

BasePlatform = class();

BasePlatform.getLoginMethodCls = function ( loginType )
    DebugLog("BasePlatform.getLoginMethodCls  loginType==" .. loginType .. "@@@@@@@@@@@@@@@@@@@@@@");
	-- body
	if PlatformConfig.QQLogin == loginType then
		require("MahjongLogin/LoginMethod/QQLogin");
		return QQLogin;
	elseif PlatformConfig.GuestLogin == loginType then
		require("MahjongLogin/LoginMethod/GuestLogin");
		return GuestLogin;
	elseif PlatformConfig.Guest2345Login == loginType then 
		require("MahjongLogin/LoginMethod/Guest2345Login");
		return Guest2345Login;
	elseif PlatformConfig.SinaLogin == loginType then
		require("MahjongLogin/LoginMethod/SinaLogin");
		return SinaLogin;
	elseif PlatformConfig.HuaweiLogin == loginType then
		require("MahjongLogin/LoginMethod/HuaweiLogin");
		return HuaweiLogin;
	elseif PlatformConfig.BoyaaLogin == loginType then
		require("MahjongLogin/LoginMethod/BoyaaLogin");
		return BoyaaLogin;
	elseif PlatformConfig.OppoLogin == loginType then
		require("MahjongLogin/LoginMethod/OppoLogin");
		return OppoLogin;
	elseif PlatformConfig.QiHuLogin == loginType then
		require("MahjongLogin/LoginMethod/QiHuLogin");
		return QiHuLogin;
	elseif PlatformConfig.Mobile2Login == loginType then
		require("MahjongLogin/LoginMethod/MobileLogin");
		return MobileLogin;
	elseif PlatformConfig.SouGouLogin == loginType then
		require("MahjongLogin/LoginMethod/SoGouLogin");
		return SoGouLogin;
	elseif PlatformConfig.Assistant91Login == loginType then
		require("MahjongLogin/LoginMethod/Assistant91Login");
		return Assistant91Login;
	elseif PlatformConfig.BaiduLogin == loginType then
		require("MahjongLogin/LoginMethod/BaiduLogin");
		return BaiduLogin;
	elseif PlatformConfig.LenovoLogin == loginType then
		require("MahjongLogin/LoginMethod/LenovoLogin");
		return LenovoLogin;
	elseif PlatformConfig.AnZhiLogin == loginType then
		require("MahjongLogin/LoginMethod/AnZhiLogin");
		return AnZhiLogin;
	elseif PlatformConfig.WeChatLogin == loginType then
		require("MahjongLogin/LoginMethod/WeChatLogin");
		return WeChatLogin;
	elseif PlatformConfig.FetionLogin == loginType then
		require("MahjongLogin/LoginMethod/FetionLogin");
		return FetionLogin;
	elseif PlatformConfig.WandouLogin == loginType then
		require("MahjongLogin/LoginMethod/WandouLogin");
		return WandouLogin;	
	elseif PlatformConfig.DingkaiLogin == loginType then 
		require("MahjongLogin/LoginMethod/DingkaiLogin");
		return DingkaiLogin;
	elseif PlatformConfig.NewGuestLogin == loginType then
		require("MahjongLogin/LoginMethod/NewGuestLogin");
		return NewGuestLogin;
	elseif PlatformConfig.XYLogin == loginType then 
		require("MahjongLogin/LoginMethod/XYLogin");
		return XYLogin;
	elseif PlatformConfig.NewEgameLogin == loginType then 
		require("MahjongLogin/LoginMethod/NewEgameLogin");
		return NewEgameLogin;
	elseif PlatformConfig.AoTianLogin == loginType then 
		require("MahjongLogin/LoginMethod/AoTianLogin");
		return AoTianLogin;
    elseif PlatformConfig.CellphoneLogin == loginType then 
		require("MahjongLogin/LoginMethod/CellphoneLogin");
		return CellphoneLogin;
	elseif PlatformConfig.ChubaoLogin == loginType then 
		require("MahjongLogin/LoginMethod/ChubaoLogin")
		return ChubaoLogin
	end
end

BasePlatform.getPayFromPayId = function(self,payType)
    DebugLog("BasePlatform.getPayFromPayId  payType==" .. payType .. "@@@@@@@@@@@@@@@@@@@@@@");
    payType = tonumber(payType);

	-- body
	if PlatformConfig.MobilePay == payType then
		require("MahjongPay/Pay/MobilePay");
		return MobilePay;	
	elseif PlatformConfig.MobileBarePay == payType then 
		require("MahjongPay/Pay/MobileBarePay");
		return MobileBarePay;
	elseif PlatformConfig.MMPay == payType then 
		require("MahjongPay/Pay/MMPay");
		return MMPay;
	elseif PlatformConfig.UnicomPay == payType then 
		require("MahjongPay/Pay/UnicomPay");
		return UnicomPay;
	elseif PlatformConfig.YinLianPay == payType then 
		require("MahjongPay/Pay/YinLianPay");
		return YinLianPay;
	elseif PlatformConfig.NewWeChatPay == payType then 
		require("MahjongPay/Pay/NewWechatPay");
		return NewWechatPay;
	elseif PlatformConfig.WeChatPay == payType then 
		require("MahjongPay/Pay/WechatPay");
		return WechatPay;
	elseif PlatformConfig.HuaFuBaoPay == payType then 
		require("MahjongPay/Pay/HuaFuBaoPay");
		return HuaFuBaoPay;
	elseif PlatformConfig.LoveAnimatePay == payType then 
		require("MahjongPay/Pay/LoveAnimatePay");
		return LoveAnimatePay;
	elseif PlatformConfig.UnicomBarePay == payType then 
		require("MahjongPay/Pay/UnicomBarePay");
		return UnicomBarePay;
	elseif PlatformConfig.EGamePay == payType then 
		require("MahjongPay/Pay/EGamePay");
		return EGamePay;
	elseif PlatformConfig.UnicomBareThirdPay == payType then 
		require("MahjongPay/Pay/UnicomBareThirdPay");
		return UnicomBareThirdPay;
	elseif PlatformConfig.MiniStdAliPay == payType then 
		require("MahjongPay/Pay/MiniStdAliPay");
		return MiniStdAliPay;
	elseif PlatformConfig.ReadBasePay == payType then 
		require("MahjongPay/Pay/ReadBasePay");
		return ReadBasePay;
	elseif PlatformConfig.HuaFuBaoComPay == payType then 
		require("MahjongPay/Pay/HuaFuBaoComPay");
		return HuaFuBaoComPay;
	elseif PlatformConfig.OppoPay == payType then 
		require("MahjongPay/Pay/OppoPay");
		return OppoPay;
	elseif PlatformConfig.WDJUnicomPay == payType then 
		require("MahjongPay/Pay/WDJUnicomPay");
		return WDJUnicomPay;
	elseif PlatformConfig.WDJMMPay == payType then 
		require("MahjongPay/Pay/WDJMMPay");
		return WDJMMPay;
	elseif PlatformConfig.WDJEgamePay == payType then 
		require("MahjongPay/Pay/WDJEGamePay");
		return WDJEGamePay;
	elseif PlatformConfig.YiXinPay == payType then 
		require("MahjongPay/Pay/YiXinPay");
		return YiXinPay;
	elseif PlatformConfig.QihuPay == payType then 
		require("MahjongPay/Pay/QihuPay");
		return QihuPay;
	elseif PlatformConfig.BaiduPay == payType then
		require("MahjongPay/Pay/BaiduPay");
		return BaiduPay;
	elseif PlatformConfig.AnzhiPay == payType then 
		require("MahjongPay/Pay/AnzhiPay");
		return AnzhiPay;
	elseif PlatformConfig.AnzhiMMPay == payType then 
		require("MahjongPay/Pay/AnZhiMMPay");
		return AnZhiMMPay;
	elseif PlatformConfig.JiuYouPay == payType then 
		require("MahjongPay/Pay/JiuYouPay");
		return JiuYouPay;
	elseif PlatformConfig.TianYiPay == payType then 
		require("MahjongPay/Pay/TianYiPay");
		return TianYiPay;
	elseif PlatformConfig.WDJNetPay == payType then 
		require("MahjongPay/Pay/WDJPay");
		return WDJPay;
	elseif PlatformConfig.NewEgamePay == payType then 
		require("MahjongPay/Pay/NewEgamePay");
		return NewEgamePay;
	elseif PlatformConfig.MobileOnlyPay == payType then 
		require("MahjongPay/Pay/MobileOnlyPay");
		return MobileOnlyPay;
	elseif PlatformConfig.UnicomOnlyPay == payType then 
		require("MahjongPay/Pay/UnicomOnlyPay");
		return UnicomOnlyPay;
	elseif PlatformConfig.HuaweiPay == payType then 
		require("MahjongPay/Pay/HuaweiPay");
		return HuaweiPay;
	elseif PlatformConfig.WebPay == payType then 
		require("MahjongPay/Pay/WebPay");
		return WebPay;
	end
end

BasePlatform.isLianYunNotChannel = function(self)
	return true;
end

--[[
	function name	   : BasePlatform.ctor
	description  	   : Construct a class.
	param 	 	 	   : self
					     api          -- Number    Every platform has different api.
					     loginTable   -- Table     Every platform has different login methods.  
	last-modified-date : Oct.22 2013
	create-time  	   : Oct.22 2013
]]
BasePlatform.ctor = function ( self)
	self.api = GameConstant.api
	self.sid = self.api;
	self.curDefaultPmode = nil;
	self.paymentUtls = {};
	self.curLoginType = kNumMinusOne; -- 当前的登录类型
	self.loginUtls = {}; -- 登录方式功能类集合：key：loginType  value：对应类实例
	self.payUtls = {}; -- 支付方式集合
	
	self.payTypeFroActivity = nil; --活动内特殊支付方式
end

-- 从支付配置表中判断支付方式是否存在
function BasePlatform.existConfigedPayment( self, id )
	if not id or ( not id and not tonumber(id) )then
		return;
	end
	local config = self.paymentTable;
	for k,v in pairs(config) do
		if tonumber( id ) == v then
			return true;
		end
	end
	return false;
end

-- 判断是否存在登录方式
function BasePlatform.existLoginType( self, loginType )
	if self.m_loginTable and #self.m_loginTable > 0 then
		for k,v in pairs(self.m_loginTable) do
			if tonumber( v ) == loginType then
				return true;
			end
		end
	end
	return false;
end

--[[
	function name	   : BasePlatform.dtor
	description  	   : Destructor a class.
	param 	 	 	   : self
	last-modified-date : Oct.22 2013
	create-time  	   : Oct.22 2013
]]
BasePlatform.dtor = function ( self )
	self.api = nil;
	self.sid = nil;
	self.curDefaultPmode = nil;
	self.curLoginType = kNumMinusOne;
	
	if self.payment then
		delete(self.payment);
		self.payment = nil;
	end
	if self.loginUtls then
		for k,v in pairs(self.loginUtls) do
			delete(v);
		end
		self.loginUtls = {};
	end

	if self.payUtls then
		for k,v in pairs(self.payUtls) do
			delete(v);
		end
		self.payUtls = {};
	end	
end

BasePlatform.notUseChat = function(self)
	return false;
end

--[[
	function name	   : BasePlatform.setAPI
	description  	   : set the api of the platform by the type of login.
	param 	 	 	   : self
						 loginType      Number -- the login method. 
	last-modified-date : Oct.22 2013
	create-time  	   : Oct.22 2013
]]
BasePlatform.setAPI = function ( self, loginType )
	self.sid = self.api;
	self.curLoginType = loginType;
end

--[[
	function name	   : BasePlatform.getCurrentLoginType
	description  	   : get the current login method.
	param 	 	 	   : self
	last-modified-date : Oct.22 2013
	create-time  	   : Oct.22 2013
]]
BasePlatform.getCurrentLoginType = function(self)
	return self.curLoginType;
end

BasePlatform.defaultLogin = function ( self )
	local lastLoginMethod = self:getDefaultLoginMethod();
	if self.curLoginType > 0 then 
		lastLoginMethod = self.curLoginType ;
	end

	if not lastLoginMethod then
		return;
	end

	self:login(lastLoginMethod,true);
end

--[[
	function name	   : BasePlatform.login
	description  	   : to login by the loginMethod.
	param 	 	 	   : self
						 loginMethod   Number -- the loginMethod
	last-modified-date : Dec. 2 2013
	create-time  	   : Oct.22 2013
]]
BasePlatform.login = function ( self, loginMethod,isQuickLogin)
	local loginUtl = self:getLoginUtl(loginMethod);
	if not loginUtl then
		return; -- 登录方式不存在，或是未登录
	end
	if DEBUGMODE == 1 then
		if loginMethod == -1 then
			loginMethod = 1;
		end
	end

	self.curLoginType = loginMethod;

	local params = { isQuickLogin = isQuickLogin};

	loginUtl:login( params );
end

-- 登出
BasePlatform.logout = function ( self )
	local loginUtl = self:getLoginUtl(self.curLoginType);
	if not loginUtl then
		return; -- 登录方式不存在，或是未登录
	end
	loginUtl:logout();
	self.curLoginType = kNumMinusOne;
end

function BasePlatform:setLogout( loginType, flag )
	local loginCls = self:getLoginUtl(loginType)
	if not loginCls then 
		return
	end
	loginCls:setLogout(flag)
end

BasePlatform.clearCurUserGameData = function ( self )
	local loginUtl = self:getLoginUtl(self.curLoginType);
	if not loginUtl then
		return; -- 登录方式不存在，或是未登录
	end
	loginUtl:clearGameData();
end

-- 根据登录类型获取对应的登录功能类
BasePlatform.getLoginUtl = function ( self, loginType )
	local loginUtl = self.loginUtls[loginType];
	if not loginUtl then
		loginUtl = self:changeLoginMethod(loginType);
		self.loginUtls[loginType] = loginUtl;
	end
	return loginUtl;
end

BasePlatform.getPayUtl = function(self,payType)
	local payUtl = self.payUtls[payType];
	if not payUtl then 
		payUtl = new(self:getPayFromPayId(payType));
		self.payUtls[payType] = payUtl;
	end
	return payUtl;
end

--[[
	function name	   : BasePlatform.changeLoginMethod
	description  	   : choose the method of login.
	param 	 	 	   : self
						 loginMethod        number    	  -- the login method
	last-modified-date : Nov.29 2013
	create-time  	   : Oct.29 2013
]]
BasePlatform.changeLoginMethod = function(self,loginMethod)
	return nil;
end

--添加区分联运
BasePlatform.returnIsLianyunName = function(self)
	error("sub class must define returnIsLianYun");
end

BasePlatform.getPayManager = function( self )
end

-- use the payType to choose a payment method and finish payment
BasePlatform.pay = function ( self, productInfo )
	if not productInfo then
		DebugLog("product is a nil value");
		return;
	end

	local m_time = os.time();

	local last_time = self.m_lastTime or 0;

	self.m_lastTime = m_time;
	
	if m_time - last_time < 1 then 
		return ;
	end
	if PlatformConfig.platformYiXin == GameConstant.platformType then 
		productInfo.gameID = GameConstant.yxGameId;
		productInfo.access_token = GameConstant.accessToken;
	end
	-- PayConfigDataManager.getInstance():executePay(productInfo);
    PayController:payForGoods(true, productInfo, true)
	
end

--是否显示平台精灵
BasePlatform.isShowPlatformSprite = function(self)
	return false;
end

--是否要调用平台自己的离开方法
BasePlatform.isUsePlatformExit = function(self)
	return false;
end

-- 是否只有游客登录(目前Oppo也使用)
BasePlatform.hasOnlyGuestLogin = function(self)
	return false;
end

-- 是否显示设置中的绑定按钮
BasePlatform.isCancelBindBtn = function(self)
	return false;
end

BasePlatform.payUtilCreate = function ( self, payType )
	error("sub class must define this function,payUtilCreate");
end

--[[
	function name	   : BasePlatform.getDefaultLoginMethod
	description  	   : To get the default login method.For it's son class,it must duplicate this class .
	param 	 	 	   : self
	last-modified-date : Oct.22 2013
	create-time  	   : Oct.22 2013
]]
BasePlatform.getDefaultLoginMethod = function ( self )
	error("Sub class must define this function,BasePlatform.getDefaultLoginMethodL");
end

--[[
	function name	   : BasePlatform.needToShowUpdataView
	description  	   : To certain whether or not need update.For it's son class,it must duplicate this class .
	param 	 	 	   : self
	last-modified-date : Oct.22 2013
	create-time  	   : Oct.22 2013
]]
BasePlatform.needToShowUpdataView = function ( self )
	return true;
end

--[[
	function name	   : BasePlatform.getLoginView
	description  	   : To get the view of login.For it's son class,it must duplicate this class .
	param 	 	 	   : self
	last-modified-date : Oct.22 2013
	create-time  	   : Oct.22 2013
]]
BasePlatform.getLoginView = function ( self)
	error("Sub class must define this function, return login view");
end

--是否需要分享界面
BasePlatform.needToShareWindow = function(self)
	return true;
end

--返回平台对应的强制更新界面、首冲大礼包、普通更新界面、公告、签到界面的level
BasePlatform.getPlatformLevel = function(self)
	return 20000,15000,10000,8000,6000;
end

-- 获取应用APPID信息
-- @Override
BasePlatform.getLoginAppId = function( self, loginType )
	
end

--获取联通渠道号
BasePlatform.getUnicomChannelId = function(self)
	error("Sub class must define getUnicomChannelId")
end

-- 分享时应用名称
BasePlatform.getApplicationShareName = function( self )
	return "博雅四川麻将";
end

BasePlatformView = class(SCWindow);

BasePlatformView.ctor = function(self,loginTable)
	DebugLog("-----------------TrunkPlatformView.ctor")

	self.cover:setEventTouch(self , function (self)
		self:hideWnd()
	end);
	self.bg = new(Image, CreatingViewUsingData.switchLoginView.loginBg.fileName, nil, nil, 50, 50, 50, 50);
	self.bg:setSize(1000, 500);
	self.bg:setAlign(kAlignCenter);
	self.bg:setEventTouch(self, function ( self )
		
	end);
    self:setWindowNode( self.bg );


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
	local x, y = CreatingViewUsingData.switchLoginView.loginBtn.x, CreatingViewUsingData.switchLoginView.loginBtn.y;
	for k,v in pairs(btnArray) do
		x = x + dist;
		v:setPos(x, y);
		self.btnView:addChild(v);
		x = x + CreatingViewUsingData.switchLoginView.loginBtn.split;
	end

	--self:setCoverTransparent()
	self.bg:addChild(self.btnView);
    self:showWnd();
end

BasePlatformView.dtor = function(self)
	DebugLog("-----------------TrunkPlatformView.dtor")
	CustomNode.hide(self);
	self:removeAllChildren();
end

--[[
	function name	   : TrunkPlatformView.onClick
	description  	   : Destruct the class.
	param 	 	 	   : self
	last-modified-date : Dec. 2 2013
	create-time  	   : Oct.22 2013
]]
BasePlatformView.onClick = function(self, loginMethod)
		SocketManager.getInstance():openSocket(loginMethod,true)

	self:hideWnd()
	self = nil;
end

BasePlatformView.closeSelf = function (self)
    self:hideWnd();
end



