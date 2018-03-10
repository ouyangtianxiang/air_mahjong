
require("MahjongCommon/CustomNode");
--
require("MahjongPlatform/Platform/BasePlatform");

NewEgamePlatform = class(BasePlatform);

-- 注意：oppo支付商品列表返回的 pamount 单位为分，推荐商品返回的列表单位为 元

-- 当前N宝余额
NewEgamePlatform.curNBao = 0;
-- 当前可币余额
NewEgamePlatform.curKeBi = 0;

NewEgamePlatform.ctor = function ( self)
	self.curDefaultPmode = 34; --默认为OPPO的商品
	self.m_loginTable = {PlatformConfig.NewEgameLogin};

	
end

NewEgamePlatform.returnIsLianyunName = function(self)
	return PlatformConfig.feedback_platform_new_egame;
end

--[[
	function name	   : NewEgamePlatform.getLoginView
	description  	   : @Override.
	param 	 	 	   : self
	last-modified-date : Nov.29 2013
	create-time  	   : Nov.29 2013
]]
NewEgamePlatform.getLoginView = function ( self, hallRef )
	return new(NewEgamePlatformView,self.m_loginTable);
end

--[[
	function name	   : NewEgamePlatform.getDefaultLoginMethod
	description  	   : @Override.
	param 	 	 	   : self
	last-modified-date : Nov.29 2013
	create-time  	   : Nov.29 2013
]]
NewEgamePlatform.getDefaultLoginMethod = function ( self )
	return PlatformConfig.NewEgameLogin;
end

NewEgamePlatform.changeLoginMethod = function(self,loginMethod)
	if PlatformConfig.OppoLogin ~= loginMethod then 
		DebugLog("请检查登录方式,没有对应的loginMethod");
	end
	if not self.m_loginMethod then 
		self.m_loginMethod = new(self.getLoginMethodCls(loginMethod) or NewEgameLogin);
	end
	return self.m_loginMethod;
end

--是否显示平台精灵
NewEgamePlatform.isShowPlatformSprite = function(self)
	return true;
end

--是否要调用平台自己的离开方法
NewEgamePlatform.isUsePlatformExit = function(self)
	return true
end

-- 获取应用APPID信息
-- @Override
NewEgamePlatform.getLoginAppId = function( self, loginType )
	if GameConstant.platformType == PlatformConfig.platformEgameWdj then 
		return "1672"
	elseif GameConstant.platformType == PlatformConfig.platformNewEgame then 
		return "1301";
	end
end

--------------------------------------------------------------------------------------------------------------------------------------------------

NewEgamePlatformView = class(BasePlatformView);

--[[
	function name	   : NewEgamePlatformView.createOppoBtn
	description  	   : create the Button of the baidu.
	param 	 	 	   : self
	last-modified-date : Feb.12 2014
	create-time  	   : Feb.12 2014
]]
NewEgamePlatformView.createNewEgameLoginBtn = function(self)
	local btn = new(Node);
	local btnData = CreatingViewUsingData.switchLoginView.loginNewEgameBtn;
	local oppoBtn = UICreator.createBtn(btnData.fileName, btnData.x, btnData.y, self, function ( self )
		self:onClick(PlatformConfig.NewEgameLogin);
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
NewEgamePlatformView.loginBtnCreateFunMap = {
	[PlatformConfig.NewEgameLogin] = NewEgamePlatformView.createNewEgameLoginBtn,
};

