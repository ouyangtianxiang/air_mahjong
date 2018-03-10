--[[
	className    	     :  BaiduPlatform
	Description  	     :  平台类-子类(百度平台))
	last-modified-date   :  Feb.12 2014
	create-time 	     :  Feb.12 2014
	last-modified-author :  ClarkWu
	create-author        :  ClarkWu
]]
require("MahjongCommon/CustomNode");
--
require("MahjongPlatform/Platform/BasePlatform");

BaiduPlatform = class(BasePlatform);

--[[
	function name	   : BaiduPlatform.ctor
	description  	   : Construct a class.
	param 	 	 	   : self
	last-modified-date : Feb.12 2014
	create-time  	   : Feb.12 2014
]]
BaiduPlatform.ctor = function ( self)
	self.curPayType = PlatformConfig.Union_Web_Pay;
	self.curDefaultPmode = 213; --默认为百度的pmode
	self.m_loginTable = {PlatformConfig.BaiduLogin};
end

--[[
	function name	   : BaiduPlatform.dtor
	description  	   : Destructor a class.
	param 	 	 	   : self
	last-modified-date : Feb.12 2014
	create-time  	   : Feb.12 2014
]]
BaiduPlatform.dtor = function ( self )
end

BaiduPlatform.returnIsLianyunName = function(self)
	return PlatformConfig.feedback_platform_baidu;
end

--[[
	function name	   : BaiduPlatform.getProductListUrl
	description  	   : @Override.
	param 	 	 	   : self
	last-modified-date : Feb.12 2014
	create-time  	   : Feb.12 2014
]]
BaiduPlatform.getProductListUrl = function ( self )
	return (GameConstant.CommonUrl or kNullStringStr) .. PlatformConfig.BAIDUPRODUCT_URL;
end

BaiduPlatform.isNeedPostApiHost = function(self)
	return true;
end

-- 是否只有游客登录(目前Oppo也使用)
BaiduPlatform.hasOnlyGuestLogin = function(self)
	return true;
end

--[[
	function name	   : BaiduPlatform.getLoginView
	description  	   : @Override.
	param 	 	 	   : self
	last-modified-date : Feb.12 2014
	create-time  	   : Feb.12 2014
]]
BaiduPlatform.getLoginView = function ( self)
	return new(BaiduPlatformView,self.m_loginTable);
end

--[[
	function name	   : BaiduPlatform.getDefaultLoginMethod
	description  	   : @Override.
	param 	 	 	   : self
	last-modified-date : Feb.12 2014
	create-time  	   : Feb.12 2014
]]
BaiduPlatform.getDefaultLoginMethod = function ( self )
	return PlatformConfig.BaiduLogin;
end

BaiduPlatform.payUtilCreate = function(self,payType)
	if PlatformConfig.Union_Web_Pay ~= payType then
		DebugLog("请检查支付方式，没有对应的payType");
	end
	return new(UnionPayment);
end

BaiduPlatform.changeLoginMethod = function(self,loginMethod)
	if PlatformConfig.BaiduLogin ~= loginMethod then 
		DebugLog("请检查登录方式,没有对应的loginMethod");
	end 											
	return new(self.getLoginMethodCls(loginMethod) or BaiduLogin );
end

-- 分享时应用名称
BaiduPlatform.getApplicationShareName = function( self )
	return "欢乐血战麻将";
end

--*****************************************************View平台界面********************************************************************************--
--[[
	className    	     :  BaiduPlatformView
	Description  	     :  平台界面类
	last-modified-date   :  Feb.12 2014
	create-time 	     :  Feb.12 2014
	last-modified-author :  ClarkWu
	create-author        :  ClarkWu
]]
BaiduPlatformView = class(BasePlatformView);

--[[
	function name	   : BaiduPlatformView.createBaiduBtn
	description  	   : create the Button of the baidu.
	param 	 	 	   : self
	last-modified-date : Feb.12 2014
	create-time  	   : Feb.12 2014
]]
BaiduPlatformView.createBaiduBtn = function(self)
	local btn = nil;
	btn = UICreator.createBtn(CreatingViewUsingData.switchLoginView.loginBaiduBtn.fileName,CreatingViewUsingData.switchLoginView.loginBaiduBtn.x,CreatingViewUsingData.switchLoginView.loginBaiduBtn.y, self, function ( self )
		self:onClick(PlatformConfig.BaiduLogin);
	end);
	return btn;
end

--华为平台的登录方式列表
BaiduPlatformView.loginBtnCreateFunMap = {
	[PlatformConfig.BaiduLogin] = BaiduPlatformView.createBaiduBtn,
};

