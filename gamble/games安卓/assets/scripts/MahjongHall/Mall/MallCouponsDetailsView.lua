local mallCouponsDetails = require(ViewLuaPath.."mallCouponsDetails");

MallCouponsDetailsView = class(SCWindow);

MallCouponsDetailsView.ctor = function ( self, root )
	self.layout = SceneLoader.load(mallCouponsDetails);
	self.root = root;
	self:addChild(self.layout);
	self.cover:setEventTouch(self,function(self)
	end);
	self.bg = publ_getItemFromTree(self.layout, {"img_win_bg"});
	self.btn_close = publ_getItemFromTree(self.layout, {"img_win_bg", "btn_close"});
	self.btn_1 = publ_getItemFromTree(self.layout, {"img_win_bg", "img_win_inner_bg", "Button1"});
	self.btn_2 = publ_getItemFromTree(self.layout, {"img_win_bg", "img_win_inner_bg", "Button2"});
	self.btn_3 = publ_getItemFromTree(self.layout, {"img_win_bg", "img_win_inner_bg", "Button3"});
	self.btn_4 = publ_getItemFromTree(self.layout, {"img_win_bg", "img_win_inner_bg", "Button4"});

	self.btn_close:setOnClick(self, function(self)
		self:hideWnd()
	end);

	if PlatformConfig.platformWDJ == GameConstant.platformType or
	   PlatformConfig.platformWDJNet == GameConstant.platformType then 
        self.btn_close:setFile("Login/wdj/Hall/Commonx/close_btn.png");
        self.bg:setFile("Login/wdj/Hall/Commonx/pop_window_mid.png");
    end

	self.btn_1:setOnClick(self, function(self)
		self:hideWnd()
		self:goNormallRoom();
	end);

	self.btn_2:setOnClick(self, function(self)
		self:hideWnd()
		self.root:play_anim_exit(self,function ( self )
			self:goMatchRoom()
		end, false)

	end);

	self.btn_3:setOnClick(self, function(self)
		self:hideWnd()
		self:showSignWindow();

	end);

	self.btn_4:setOnClick(self, function(self)
		self:hideWnd()
		self.root:play_anim_exit(self,function ( self )
			self:goHallActivity()
		end, false)

	end);
    self:setWindowNode( self.bg );
	--popWindowDown(self, nil, self.bg);
end

--MallCouponsDetailsView.show = function ( self )

--	popWindowDown(self, nil, self.bg);
--end
--MallCouponsDetailsView.hideWnd = function ( self )

--	popWindowUp(self, nil, self.bg);
--end

MallCouponsDetailsView.goMatchRoom = function ( self )
	DebugLog("tttttt比赛报名");
	if HallScene_instance then
		HallScene_instance:enterMatchRoomList();
	end
end


MallCouponsDetailsView.goNormallRoom = function ( self )
	DebugLog("tttttt快速开始");
	if HallScene_instance then
		HallScene_instance:onClickedQuickStartBtn();
	end
end


MallCouponsDetailsView.showSignWindow = function ( self )
	DebugLog("tttttt签到弹窗");
	if HallScene_instance then
		--HallScene_instance:onSignClick();
		HallScene_instance:pushSignWindow();
	end
end


MallCouponsDetailsView.goHallActivity = function ( self )
	DebugLog("tttttt活动中心");
	if HallScene_instance then
		HallScene_instance.m_bottomLayer:enterActivityView();
	end
end