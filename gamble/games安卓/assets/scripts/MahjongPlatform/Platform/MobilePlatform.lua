--[[
	className    	     :  MobilePlatform
	Description  	     :  平台类-子类(基地平台))
	last-modified-date   :  Dec.2  2013
	create-time 	     :  Oct.22 2013
	last-modified-author :  ClarkWu
	create-author        :  ClarkWu
]]
--
require("MahjongPlatform/Platform/BasePlatform");

MobilePlatform = class( BasePlatform );

MobilePlatform.ctor = function ( self)
	self.curDefaultPmode = 31;
	self.m_loginMethods = {};
	-- self.paymentTable = { BasePay.PAY_TYPE_MOBILEMM, BasePay.PAY_TYPE_UNICOM, BasePay.PAY_TYPE_EGAME};
	self.m_loginTable = { PlatformConfig.Mobile2Login};

end

MobilePlatform.dtor = function ( self )
end

MobilePlatform.returnIsLianyunName = function(self)
	return PlatformConfig.feedback_platform_mobile;
end

-- 获取应用APPID信息
-- @Override
MobilePlatform.getLoginAppId = function( self, loginType )
	return "213"; 
end

MobilePlatform.isUsePlatformExit = function(self)
	return true;
end


MobilePlatform.getLoginView = function (self)
	return new(MobilePlatformView,self.m_loginTable);
end

MobilePlatform.getDefaultLoginMethod = function ( self )
	local loginType = g_DiskDataMgr:getAppData(kLastLoginType, PlatformConfig.Mobile2Login);
	return loginType;
end

MobilePlatform.changeLoginMethod = function(self,loginMethod)
	if loginMethod and not self.m_loginMethods[loginMethod] then 
		self.m_loginMethods[loginMethod] = new(self.getLoginMethodCls(loginMethod) or MobileLogin);
	end
	return self.m_loginMethods[loginMethod];
end

--*****************************************************View平台界面********************************************************************************--
--[[
	className    	     :  MobilePlatformView
	Description  	     :  平台界面类
	last-modified-date   :  Dec.2  2013
	create-time 	     :  Oct.22 2013
	last-modified-author :  ClarkWu
	create-author        :  ClarkWu
]]
MobilePlatformView = class(BasePlatformView);

--[[
	function name	   : MobilePlatformView.createGuestBtn
	description  	   : create the Button of the guest.
	param 	 	 	   : self
	last-modified-date : Dec.18 2013
	create-time  	   : Dec.18 2013
]]
MobilePlatformView.createGuestBtn = function ( self )
	local btn = new(Node);
	local btnData = CreatingViewUsingData.switchLoginView.mobileLoginBtn;
	local mobileBtn = UICreator.createBtn(btnData.fileName, btnData.x, btnData.y, self, function ( self )
		self:onClick(PlatformConfig.Mobile2Login);
	end);
	for k,v in pairs(btnData) do 
		print(k,v)
	end
	local oppoText = UICreator.createText(btnData.text, -50, -135, 150, 32, kAlignCenter, 28, 75, 43, 28);
	oppoText:setAlign(kAlignBottom);
	btn:addChild(mobileBtn);
	btn:addChild(oppoText);

	return btn;
end


--奇虎平台的登录方式列表
MobilePlatformView.loginBtnCreateFunMap = {
	[PlatformConfig.Mobile2Login] = MobilePlatformView.createGuestBtn,
};