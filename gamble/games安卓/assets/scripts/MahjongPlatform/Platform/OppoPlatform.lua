
require("MahjongCommon/CustomNode");
--
require("MahjongPlatform/Platform/BasePlatform");

OppoPlatform = class(BasePlatform);

-- 注意：oppo支付商品列表返回的 pamount 单位为分，推荐商品返回的列表单位为 元

-- 当前N宝余额
OppoPlatform.curNBao = 0;
-- 当前可币余额
OppoPlatform.curKeBi = 0;

OppoPlatform.ctor = function ( self)
	self.curAmount = 0;
	self.paying = false;
	self.curDefaultPmode = 215; --默认为OPPO的商品
	self.m_loginTable = {PlatformConfig.OppoLogin};

	self.logins = {};
end

--是否要调用平台自己的离开方法
OppoPlatform.isUsePlatformExit = function(self)
	return true;
end

OppoPlatform.dtor = function ( self )
	self.pruductUrl = nil;
	self.curAmount = 0;
	self.paymentTable = {};
	self.paying = false;
end

-- 是否只有游客登录(目前Oppo也使用)
OppoPlatform.hasOnlyGuestLogin = function(self)
	return true;
end

OppoPlatform.returnIsLianyunName = function(self)
	return PlatformConfig.feedback_platform_oppo;
end

--[[
	function name	   : OppoPlatform.getLoginView
	description  	   : @Override.
	param 	 	 	   : self
	last-modified-date : Nov.29 2013
	create-time  	   : Nov.29 2013
]]
OppoPlatform.getLoginView = function ( self, hallRef )
	return new(OppoPlatformView,self.m_loginTable);
end

--[[
	function name	   : OppoPlatform.getDefaultLoginMethod
	description  	   : @Override.
	param 	 	 	   : self
	last-modified-date : Nov.29 2013
	create-time  	   : Nov.29 2013
]]
OppoPlatform.getDefaultLoginMethod = function ( self )
	return PlatformConfig.OppoLogin;
end

-- 获取应用APPID信息
-- @Override
OppoPlatform.getLoginAppId = function( self, loginType )
	return "189";
end

OppoPlatform.getUnicomChannelId = function( self)
	return "00022744";
end

OppoPlatform.changeLoginMethod = function(self,loginMethod)
	if not self.logins[loginMethod] then
		self.logins[loginMethod] = new(self.getLoginMethodCls(loginMethod) or 
			self.getLoginMethodCls(PlatformConfig.GuestLogin));
	end
	return self.logins[loginMethod];
end

--是否显示平台精灵
OppoPlatform.isShowPlatformSprite = function(self)
	return true;
end

--------------------------------------------------------------------------------------------------------------------------------------------------

OppoPlatformView = class(BasePlatformView);

--[[
	function name	   : OppoPlatformView.createOppoBtn
	description  	   : create the Button of the baidu.
	param 	 	 	   : self
	last-modified-date : Feb.12 2014
	create-time  	   : Feb.12 2014
]]
OppoPlatformView.createOppoBtn = function(self)
	local btn = new(Node);
	local btnData = CreatingViewUsingData.switchLoginView.loginOppoBtn;
	local oppoBtn = UICreator.createBtn(btnData.fileName, btnData.x, btnData.y, self, function ( self )
		self:onClick(PlatformConfig.OppoLogin);
	end);
	for k,v in pairs(btnData) do 
		print(k,v)
	end
	local oppoText = UICreator.createText(btnData.text, -50, -135, 150, 32, kAlignCenter, 28, 75, 43, 28);
	oppoText:setAlign(kAlignBottom);
	btn:addChild(oppoBtn);
	btn:addChild(oppoText);

	return btn;
end



--华为平台的登录方式列表
OppoPlatformView.loginBtnCreateFunMap = {
	[PlatformConfig.OppoLogin] = OppoPlatformView.createOppoBtn,
};

