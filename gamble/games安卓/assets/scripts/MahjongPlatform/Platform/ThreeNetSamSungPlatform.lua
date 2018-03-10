--region ThreeNetSamSungPlatform .lua
--Author : BillyYang
--Date   : 2015/1/23
--此文件由[BabeLua]插件自动生成

--平台类-子类(三网合一基地派生平台))

--endregion
require("MahjongPlatform/Platform/BasePlatform");

ThreeNetSamSungPlatform = class(BasePlatform);

--[[
	function name	   : ThreeNetPlatform.ctor
	description  	   : Construct a class.
	param 	 	 	   : self
						 api          -- Number    Every platform has different api.
						 loginTable   -- Table     Every platform has different login methods.  
	last-modified-date : Oct.22 2013
	create-time  	   : Oct.22 2013
]]
ThreeNetSamSungPlatform.ctor = function ( self)
	self.m_loginMethods = {};
	self.curDefaultPmode = 109; --默认为MOBILE的商品
	self.m_loginTable = { PlatformConfig.QQLogin, 
						   -- PlatformConfig.BoyaaLogin,
						   PlatformConfig.GuestLogin,
						   PlatformConfig.CellphoneLogin};

end

-- 获取应用APPID信息
-- @Override
ThreeNetSamSungPlatform.getLoginAppId = function( self, loginType )
	return "1699";
end

--[[
	function name	   : ThreeNetPlatform.dtor
	description  	   : Destructor a class.
	param 	 	 	   : self
	last-modified-date : Oct.22 2013
	create-time  	   : Oct.22 2013
]]
ThreeNetSamSungPlatform.dtor = function ( self )
end

ThreeNetSamSungPlatform.returnIsLianyunName = function(self)
	return PlatformConfig.feedback_platform_3Net_XIAOMI;
end

--[[
	function name	   : QihuPlatform.getLoginView
	description  	   : @Override.
	param 	 	 	   : self
	last-modified-date : Nov.29 2013
	create-time  	   : Nov.29 2013
]]
ThreeNetSamSungPlatform.getLoginView = function (self)
	return new(ThreeNetSamSungPlatformView,self.m_loginTable);
end

--[[
	function name	   : ThreeNetPlatform.getDefaultLoginMethod
	description  	   : @Override.
	param 	 	 	   : self
	last-modified-date : Oct.22 2013
	create-time  	   : Oct.22 2013
]]
ThreeNetSamSungPlatform.getDefaultLoginMethod = function ( self )
	local loginType = g_DiskDataMgr:getAppData(kLastLoginType, PlatformConfig.GuestLogin);
	return loginType;
end

ThreeNetSamSungPlatform.changeLoginMethod = function(self,loginMethod)
   if loginMethod and not self.m_loginMethods[loginMethod] then 
		self.m_loginMethods[loginMethod] = new(self.getLoginMethodCls(loginMethod) or GuestLogin);
	end
	return self.m_loginMethods[loginMethod];
end

ThreeNetSamSungPlatform.getUnicomChannelId = function(self)
	return "00022544";
end

ThreeNetSamSungPlatform.isCancelBindBtn = function(self)
	return true;
end

--*****************************************************View平台界面********************************************************************************--
--[[
	className    	     :  ThreeNetSamSungPlatform View
	Description  	     :  平台界面类
	last-modified-date   :  Dec.2  2013
	create-time 	     :  Oct.22 2013
	last-modified-author :  ClarkWu
	create-author        :  ClarkWu
]]
ThreeNetSamSungPlatformView = class(BasePlatformView);


--[[
	function name	   : ThreeNetSamSungPlatform View.createGuestBtn
	description  	   : create the Button of the guest.
	param 	 	 	   : self
	last-modified-date : Dec. 2 2013
	create-time  	   : Oct.22 2013
]]
ThreeNetSamSungPlatformView.createGuestBtn = function ( self )
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
	function name	   : ThreeNetSamSungPlatform View.createQQBtn
	description  	   : create the Button of the QQ.
	param 	 	 	   : self
	last-modified-date : Dec. 2 2013
	create-time  	   : Oct.22 2013
]]
ThreeNetSamSungPlatformView.createQQBtn = function ( self )
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
	function name	   : ThreeNetSamSungPlatform View.createSinaBtn
	description  	   : create the Button of the Sina.
	param 	 	 	   : self
	last-modified-date : Dec. 2 2013
	create-time  	   : Oct.22 2013
]]
ThreeNetSamSungPlatformView.createSinaBtn = function ( self )
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
	function name	   : ThreeNetSamSungPlatform View.createBoyaaBtn
	description  	   : create the Button of the Boyaa.
	param 	 	 	   : self
	last-modified-date : Dec. 2 2013
	create-time  	   : Oct.22 2013
]]
ThreeNetSamSungPlatformView.createBoyaaBtn = function ( self )
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
	function name	   : ThreeNetSamSungPlatform View.createWeChatBtn
	description  	   : create the Button of the WeChat.
	param 	 	 	   : self
	last-modified-date : Dec. 2 2013
	create-time  	   : Oct.22 2013
]]
ThreeNetSamSungPlatformView.createWeChatBtn = function ( self )
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
ThreeNetSamSungPlatformView.createCellphoneBtn = function ( self )
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
ThreeNetSamSungPlatformView.loginBtnCreateFunMap = {
	[PlatformConfig.QQLogin] 	= ThreeNetSamSungPlatformView.createQQBtn,
	[PlatformConfig.GuestLogin] = ThreeNetSamSungPlatformView.createGuestBtn,
	[PlatformConfig.CellphoneLogin] = ThreeNetSamSungPlatformView.createCellphoneBtn
};

--返回该平台对应的强制更新界面、首冲大礼包、普通更新界面、公告、签到界面的level
--强更>首冲>普更>公告>签到
ThreeNetSamSungPlatform.getPlatformLevel = function(self)
	return 20000,15000,10000,8000,6000;
end