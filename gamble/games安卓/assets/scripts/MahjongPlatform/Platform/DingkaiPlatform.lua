require("MahjongPlatform/Platform/BasePlatform");

DingkaiPlatform = class( BasePlatform );

DingkaiPlatform.ctor = function ( self)
	self.curDefaultPmode = 281;
	self.paymentTable = { BasePay.PAY_TYPE_DINGKAI}; --PAY_TYPE_MOBILEMM, BasePay.PAY_TYPE_UNICOM, BasePay.PAY_TYPE_EGAME
	self.m_loginTable = {PlatformConfig.DingkaiLogin};
	GameConstant.dingkai_coin = 0;
end

DingkaiPlatform.dtor = function ( self )
end

DingkaiPlatform.returnIsLianyunName = function(self)
	return PlatformConfig.feedback_platform_dingkai;
end

DingkaiPlatform.isNeedPostApiHost = function(self)
	return true;
end

-- 获取应用APPID信息
-- @Override
DingkaiPlatform.getLoginAppId = function( self, loginType )
	return 7072;
end

-- @Override
DingkaiPlatform.getPayManagerType = function( self )
	return BasePayManager.TYPE_SINGLE;
end

DingkaiPlatform.getLoginView = function (self)
	return new(DingkaiPlatformView,self.m_loginTable);
end

DingkaiPlatform.getDefaultLoginMethod = function ( self )
	local loginType = g_DiskDataMgr:getAppData(kLastLoginType, PlatformConfig.DingkaiLogin);
	return loginType;
end

DingkaiPlatform.hasOnlyGuestLogin = function(self)
	return true;
end

DingkaiPlatform.changeLoginMethod = function(self,loginMethod)
	if not self.m_loginMethod then 
		self.m_loginMethod = new(self.getLoginMethodCls(loginMethod) or DingkaiLogin);
	end

	return self.m_loginMethod;
end

DingkaiPlatform.isNeedChangeXueZhanLogo = function( self )
	return true;
end

-- 该平台的应用名称
-- @Override
DingkaiPlatform.getApplicationShareName = function( self )
	return "血战麻将！";
end

--*****************************************************View平台界面********************************************************************************--
--[[
	className    	     :  DingkaiPlatformView
	Description  	     :  平台界面类
	last-modified-date   :  Feb.12 2014
	create-time 	     :  Feb.12 2014
	last-modified-author :  ClarkWu
	create-author        :  ClarkWu
]]
DingkaiPlatformView = class(CustomNode);

--[[
	function name	   : DingkaiPlatformView.ctor
	description  	   : Construct the class.
	param 	 	 	   : self
	last-modified-date : Dec. 2 2013
	create-time  	   : Feb.12 2014
]]
DingkaiPlatformView.ctor = function(self,loginTable)
	self.cover:setEventTouch(self , function (self)
		delete(self);
		self = nil;
	end);
	-- self.bg = UICreator.createImg(CreatingViewUsingData.switchLoginView.loginBg.fileName, CreatingViewUsingData.switchLoginView.loginBg.x, CreatingViewUsingData.switchLoginView.loginBg.y);
	-- self.bg:setEventTouch(self, function ( self )
		
	-- end);
	-- self.width = self.bg.m_width;
	-- self.height = self.bg.m_height;
	-- self:addChild(self.bg);

	-- self.btnView = new(Node);

	-- local btnArray = {};
	-- local allLen = kNumZero;
	-- for k,v in pairs(loginTable) do
	-- 	local btn = self.loginBtnCreateFunMap[v](self);
	-- 	table.insert(btnArray, btn);
	-- 	allLen = allLen + btn.m_width;
	-- end
	-- local len = #btnArray;
	-- local dist = (self.width - allLen) / (len + 1);
	-- local x, y = CreatingViewUsingData.switchLoginView.loginTo360Btn.x,CreatingViewUsingData.switchLoginView.loginTo360Btn.y;
	-- for k,v in pairs(btnArray) do
	-- 	x = x + dist;
	-- 	v:setPos(x, y);
	-- 	self.btnView:addChild(v);
	-- 	x = x + CreatingViewUsingData.switchLoginView.loginTo360Btn.split;
	-- 	y = CreatingViewUsingData.switchLoginView.loginTo360Btn.y;
	-- end

	-- self.bg:addChild(self.btnView);
	-- makeTheControlAdaptResolution(self.bg);
	self:onClick(PlatformConfig.DingkaiLogin);
end

--[[
	function name	   : DingkaiPlatformView.dtor
	description  	   : Destruct the class.
	param 	 	 	   : self
	last-modified-date : Feb.12 2014
	create-time  	   : Feb.12 2014
]]
DingkaiPlatformView.dtor = function(self)
	CustomNode.hide(self);
	self:removeAllChildren();
end

--[[
	function name	   : DingkaiPlatformView.onClick
	description  	   : Destruct the class.
	param 	 	 	   : self
	last-modified-date : Feb.12 2014
	create-time  	   : Feb.12 2014
]]
DingkaiPlatformView.onClick = function(self,loginMethod)
	if loginMethod == PlatformFactory.curPlatform.curLoginType then
		PlatformFactory.curPlatform:logout();
	else
		PlatformFactory.curPlatform:clearCurUserGameData();
	end
	umengStatics_lua(kUmengDingKaiLogin);
	PlatformFactory.curPlatform:login(loginMethod);
	delete(self);
	self = nil;
end

--[[
	function name	   : DingkaiPlatformView.createBaiduBtn
	description  	   : create the Button of the baidu.
	param 	 	 	   : self
	last-modified-date : Feb.12 2014
	create-time  	   : Feb.12 2014
]]
DingkaiPlatformView.createBaiduBtn = function(self)
	local btn = nil;
	btn = UICreator.createBtn(CreatingViewUsingData.switchLoginView.loginBaiduBtn.fileName,CreatingViewUsingData.switchLoginView.loginBaiduBtn.x,CreatingViewUsingData.switchLoginView.loginBaiduBtn.y, self, function ( self )
		self:onClick(PlatformConfig.BaiduLogin);
	end);
	return btn;
end

--华为平台的登录方式列表
DingkaiPlatformView.loginBtnCreateFunMap = {
	[PlatformConfig.BaiduLogin] = DingkaiPlatformView.createBaiduBtn,
};