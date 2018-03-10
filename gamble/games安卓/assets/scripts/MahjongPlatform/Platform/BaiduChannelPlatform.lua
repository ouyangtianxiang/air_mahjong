--[[
	className    	     :  BaiduChannelPlatform
	Description  	     :  平台类-子类(百度平台))
	last-modified-date   :  Feb.12 2014
	create-time 	     :  Feb.12 2014
	last-modified-author :  ClarkWu
	create-author        :  ClarkWu
]]
require("MahjongCommon/CustomNode");
--
require("MahjongPlatform/Platform/BasePlatform");

BaiduChannelPlatform = class(BasePlatform);

--[[
	function name	   : BaiduChannelPlatform.ctor
	description  	   : Construct a class.
	param 	 	 	   : self
	last-modified-date : Feb.12 2014
	create-time  	   : Feb.12 2014
]]
BaiduChannelPlatform.ctor = function ( self)
	self.curDefaultPmode = 294; --默认为多酷的商品 4
	self.m_loginTable = {
	-- PlatformConfig.SinaLogin,
	PlatformConfig.QQLogin,
	-- PlatformConfig.BoyaaLogin,
	PlatformConfig.GuestLogin,
	PlatformConfig.CellphoneLogin
	};
	-- self.paymentTable = {BasePay.PAY_TYPE_BAIDU};
	self.m_loginMethods = {};

end

--是否要调用平台自己的离开方法
BaiduChannelPlatform.isUsePlatformExit = function(self)
	return true;
end
--[[
	function name	   : BaiduChannelPlatform.dtor
	description  	   : Destructor a class.
	param 	 	 	   : self
	last-modified-date : Feb.12 2014
	create-time  	   : Feb.12 2014
]]
BaiduChannelPlatform.dtor = function ( self )
end

BaiduChannelPlatform.returnIsLianyunName = function(self)
	return PlatformConfig.feedback_platform_baidu_channel;
end

-- 是否只有游客登录(目前Oppo也使用)
BaiduChannelPlatform.hasOnlyGuestLogin = function(self)
	return false;
end

--[[
	function name	   : BaiduChannelPlatform.getLoginView
	description  	   : @Override.
	param 	 	 	   : self
	last-modified-date : Feb.12 2014
	create-time  	   : Feb.12 2014
]]
BaiduChannelPlatform.getLoginView = function ( self)
	return new(BaiduChannelPlatformView,self.m_loginTable);
end

--[[
	function name	   : BaiduChannelPlatform.getDefaultLoginMethod
	description  	   : @Override.
	param 	 	 	   : self
	last-modified-date : Feb.12 2014
	create-time  	   : Feb.12 2014
]]
BaiduChannelPlatform.getDefaultLoginMethod = function ( self )
	local loginType = g_DiskDataMgr:getAppData(kLastLoginType, PlatformConfig.GuestLogin);
	return loginType;
	-- return PlatformConfig.GuestLogin;
end

BaiduChannelPlatform.changeLoginMethod = function(self,loginMethod)
	-- if PlatformConfig.BaiduLogin ~= loginMethod then 
	-- 	DebugLog("请检查登录方式,没有对应的loginMethod");
	-- end 											
	if loginMethod and not self.m_loginMethods[loginMethod] then 
		self.m_loginMethods[loginMethod] = new(self.getLoginMethodCls(loginMethod) or GuestLogin);
	end
	return self.m_loginMethods[loginMethod];
end

-- 获取应用APPID信息
-- @Override
BaiduChannelPlatform.getLoginAppId = function( self, loginType )
	return "7162"; 
end

BaiduChannelPlatform.isCancelBindBtn = function(self)
	return true;
end

--*****************************************************View平台界面********************************************************************************--
--[[
	className    	     :  BaiduChannelPlatformView
	Description  	     :  平台界面类
	last-modified-date   :  Feb.12 2014
	create-time 	     :  Feb.12 2014
	last-modified-author :  ClarkWu
	create-author        :  ClarkWu
]]
BaiduChannelPlatformView = class(BasePlatformView);

--[[
	function name	   : TrunkPlatformView.createGuestBtn
	description  	   : create the Button of the guest.
	param 	 	 	   : self
	last-modified-date : Dec. 2 2013
	create-time  	   : Oct.22 2013
]]
BaiduChannelPlatformView.createGuestBtn = function ( self )
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

--[[
	function name	   : TrunkPlatformView.createQQBtn
	description  	   : create the Button of the QQ.
	param 	 	 	   : self
	last-modified-date : Dec. 2 2013
	create-time  	   : Oct.22 2013
]]
BaiduChannelPlatformView.createQQBtn = function ( self )
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
	function name	   : TrunkPlatformView.createSinaBtn
	description  	   : create the Button of the Sina.
	param 	 	 	   : self
	last-modified-date : Dec. 2 2013
	create-time  	   : Oct.22 2013
]]
BaiduChannelPlatformView.createSinaBtn = function ( self )
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
	function name	   : TrunkPlatformView.createBoyaaBtn
	description  	   : create the Button of the Boyaa.
	param 	 	 	   : self
	last-modified-date : Dec. 2 2013
	create-time  	   : Oct.22 2013
]]
BaiduChannelPlatformView.createBoyaaBtn = function ( self )
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
	function name	   : BaiduChannelPlatformView.dtor
	description  	   : Destruct the class.
	param 	 	 	   : self
	last-modified-date : Feb.12 2014
	create-time  	   : Feb.12 2014
]]
BaiduChannelPlatformView.dtor = function(self)
	CustomNode.hide(self);
	self:removeAllChildren();
end

--创建手机帐号登陆按钮
BaiduChannelPlatformView.createCellPhoneBtn = function ( self )
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

--百度渠道联运的登录方式列表
BaiduChannelPlatformView.loginBtnCreateFunMap = {
	[PlatformConfig.CellphoneLogin] = BaiduChannelPlatformView.createCellPhoneBtn,
	[PlatformConfig.SinaLogin] 	= BaiduChannelPlatformView.createSinaBtn,
	[PlatformConfig.QQLogin] 	= BaiduChannelPlatformView.createQQBtn,
	[PlatformConfig.BoyaaLogin] = BaiduChannelPlatformView.createBoyaaBtn,
	[PlatformConfig.GuestLogin] = BaiduChannelPlatformView.createGuestBtn,
};