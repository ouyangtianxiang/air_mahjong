--[[
	className    	     :  ContestPlatform
	Description  	     :  平台类-子类(主平台))
	last-modified-date   :  Dec.2  2013
	create-time 	     :  Oct.22 2013
	last-modified-author :  ClarkWu
	create-author        :  ClarkWu
]]
--
require("MahjongPlatform/Platform/BasePlatform");

ContestPlatform = class(BasePlatform);

--[[
	function name	   : ContestPlatform.ctor
	description  	   : Construct a class.
	param 	 	 	   : self
					     api          -- Number    Every platform has different api.
					     loginTable   -- Table     Every platform has different login methods.  
	last-modified-date : Oct.22 2013
	create-time  	   : Oct.22 2013
]]
ContestPlatform.ctor = function ( self)
	self.curPayType = PlatformConfig.UnionPay;
	self.m_loginTable = {PlatformConfig.GuestLogin};
end

--[[
	function name	   : ContestPlatform.dtor
	description  	   : Destructor a class.
	param 	 	 	   : self
	last-modified-date : Oct.22 2013
	create-time  	   : Oct.22 2013
]]
ContestPlatform.dtor = function ( self )
end

ContestPlatform.returnIsLianyunName = function(self)
	return PlatformConfig.feedback_platform_contest;
end

--[[
	function name	   : ContestPlatform.getProductListUrl
	description  	   : @Override.
	param 	 	 	   : self
	last-modified-date : Oct.22 2013
	create-time  	   : Oct.22 2013
]]
ContestPlatform.getProductListUrl = function ( self )
	return (GameConstant.CommonUrl or kNullStringStr).. PlatformConfig.TRUNKPRODUCT_GUESTORBOYAA_URL;
end

ContestPlatform.isNeedPostApiHost = function(self)
	return true;
end

--[[
	function name	   : QihuPlatform.getLoginView
	description  	   : @Override.
	param 	 	 	   : self
	last-modified-date : Nov.29 2013
	create-time  	   : Nov.29 2013
]]
ContestPlatform.getLoginView = function (self)
	self:changeLoginMethod(PlatformConfig.GuestLogin):login();
end

--是否显示绑定博雅通行证
ContestPlatform.isNeedToShowBYPassCard = function ( self )
	return false;
end

-- 是否只有游客登录(目前Oppo也使用)
ContestPlatform.hasOnlyGuestLogin = function(self)
	return true;
end

--[[
	function name	   : ContestPlatform.getDefaultLoginMethod
	description  	   : @Override.
	param 	 	 	   : self
	last-modified-date : Oct.22 2013
	create-time  	   : Oct.22 2013
]]
ContestPlatform.getDefaultLoginMethod = function ( self )
	local loginType = g_DiskDataMgr:getAppData(kLastLoginType, PlatformConfig.GuestLogin);
	return loginType;
end

ContestPlatform.isSupportQuickRecharge = function ( self )
	return false;
end

ContestPlatform.payUtilCreate = function(self,payType)
	Banner.getInstance():showMsg("亲，您是在比赛哦，不能进入支付。");
end

ContestPlatform.changeLoginMethod = function(self,loginMethod)
	return new(self.getLoginMethodCls(loginMethod) or GuestLogin);
end


