require("MahjongCommon/BankraptcyClock");
local bankruptcyInSingle = require(ViewLuaPath.."bankruptcyInSingle");

BankruptcyDlgInSingle = class(SCWindow);

BankruptcyDlgInSingle.ctor = function ( self, time )
	self.cover:setEventTouch(self , function (self) end);

	self.window = SceneLoader.load(bankruptcyInSingle);
	self:addChild(self.window);

	self.m_time = time; -- 破产需要显示的时间

	self.bg = publ_getItemFromTree(self.window,{"img_win_bg"});
	self:setWindowNode( self.bg );
	--设置关闭事件
	publ_getItemFromTree(self.window,{"img_win_bg","btn_close"}):setOnClick(self, self.hideWnd);
	self:setBtnGetEnable(false);

	if PlatformConfig.platformWDJ == GameConstant.platformType or
	   PlatformConfig.platformWDJNet == GameConstant.platformType then  
		publ_getItemFromTree(self.window,{"img_win_bg","btn_close"}):setFile("Login/wdj/Hall/Commonx/close_btn.png");
		publ_getItemFromTree(self.window,{"img_win_bg","btn_close"}).disableFile = "Login/wdj/Hall/Commonx/close_btn_disable.png";
	end

    --设置响应事件
	publ_getItemFromTree(self.window,{"img_win_bg","btn_confirm"}):setOnClick(self,self.onToNetWork);
	publ_getItemFromTree(self.window,{"img_win_bg", "img_inner_bg", "view_time", "btn_get"}):setOnClick(self,self.onGetCoin);
	
	--计时器
	self.clock = new (BankraptcyClock,publ_getItemFromTree(self.window,{"img_win_bg", "img_inner_bg", "view_time"}));
	self:setLevel(20000);
	self:loadBankruptcyTime(self.m_time);
	self:showWnd();
end

BankruptcyDlgInSingle.dtor = function ( self )
	self:removeAllChildren();
end

BankruptcyDlgInSingle.hideHandle = function ( self )
	self:hide();
end

BankruptcyDlgInSingle.setBtnGetEnable = function ( self, enable )
	local btnGet = publ_getItemFromTree(self.window,{"img_win_bg", "img_inner_bg", "view_time", "btn_get"});
	btnGet:setGray(not enable)
	--publ_getItemFromTree(btnGet, {"Image3"}):setIsGray(not enable);
	--publ_getItemFromTree(btnGet, {"Image4"}):setIsGray(not enable);
	--publ_getItemFromTree(btnGet, {"Image5"}):setIsGray(not enable);
	btnGet:setPickable(enable);
end

--加载时间
BankruptcyDlgInSingle.loadBankruptcyTime = function ( self ,time)
	if time <= 0 then
		self:onWaittingTimeOut();
	else
		self.clock:start(time,self,self.onWaittingTimeOut);
	end
end

BankruptcyDlgInSingle.hide = function ( self )
	umengStatics_lua(kUmengBankruptCloseBtn);
	if  self.closeListener then
		self.closeListener(self.arg);
	end
	self:setVisible(false);
	self:removeFromSuper();
end

--等待时间 timeout响应事件
BankruptcyDlgInSingle.onWaittingTimeOut = function ( self )
	self:setBtnGetEnable(true);
end

-- --领取金币按钮 响应事件
BankruptcyDlgInSingle.onGetCoin = function ( self )
	umengStatics_lua(kUmengBankruptAwardCoinBtn);
	self:setBtnGetEnable(false);
	PlayerManager.getInstance():myself():setMoney(10000);
	g_DiskDataMgr:setAppData('singleMyMoney',PlayerManager.getInstance():myself().money)
	g_DiskDataMgr:setAppData('singletimemark',-1)
	showGoldDropAnimation();
	self:hide();
end

-- --确定按扭 响应事件
BankruptcyDlgInSingle.onToNetWork = function ( self )
	umengStatics_lua(kUmengBankruptPayBtn);
	g_DiskDataMgr:setAppData('singleMyMoney',PlayerManager.getInstance():myself().money)
	
	RoomScene_instance:toHall();
	GameConstant.singleToOnline = true;
end


