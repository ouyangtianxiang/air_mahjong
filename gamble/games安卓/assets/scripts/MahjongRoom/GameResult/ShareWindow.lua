--  author: onlynightzhang
-- time: 2014.9.18
-- describe: 分享窗口 

local shareWindow = require(ViewLuaPath.."shareWindow");

ShareWindow = class(SCWindow)--( CustomNode );

ShareWindow.ctor = function( self, filepath , global_share_data)
    DebugLog("ShareWindow ctor");

    self.m_bPortrait = global_share_data.b;
    self.t = global_share_data.t;
	self:setVisible( false );
	self:setLevel( 30000 );
	self.screenshotPath = filepath;

	self.window = SceneLoader.load( shareWindow );
	self:addChild( self.window );

    self.v = publ_getItemFromTree( self.window, { "v"} );
	self.btnClose = publ_getItemFromTree( self.window, { "v", "window_bg", "btn_close" } );
    self.window_bg = publ_getItemFromTree( self.window, { "v", "window_bg" } );
	self.imgScreenShot = publ_getItemFromTree( self.window, { "v", "window_bg", "img_screenshot" } );

	self.btnQQShare = publ_getItemFromTree( self.window, { "v", "btn_qq_share" } );
	self.btnQzoneShare = publ_getItemFromTree( self.window, { "v", "btn_qzone_share" } );
	self.btnWechatShare = publ_getItemFromTree( self.window, { "v", "btn_wechat_share" } );
	self.btnFriendCircleShare = publ_getItemFromTree( self.window, { "v", "btn_friend_circle_share" } );

    self:setWindowNode( self.v );
	self:setCoverEnable(true);

	if PlatformConfig.platformYiXin ~= GameConstant.platformType then 
		self:resetShareBtnPos();
	else
		self.btnQzoneShare:setFile("Login/yx/Room/share/yx_frend.png");
		self.btnWechatShare:setFile("Login/yx/Room/share/yx_friendCircle.png")
	end


	-- 关闭按钮响应事件
	self.btnClose:setOnClick( self, self.hideWnd);


	-- QQ分享
	self.btnQQShare:setOnClick( self, function( self )
		if PlatformConfig.platformYiXin ~= GameConstant.platformType then 
			self:share( kQQShare, self.screenshotPath );
		else
			self:share(kYxCircleShare,self.screenshotPath);
		end
	end);

	-- QQ空间分享
	self.btnQzoneShare:setOnClick( self, function( self )
		self:share( kQZoneShare, self.screenshotPath );
	end);

	-- 微信分享
	self.btnWechatShare:setOnClick( self, function( self )
		if PlatformConfig.platformYiXin ~= GameConstant.platformType then 
			self:share( kWechatShare, self.screenshotPath );
		else
			self:share(kYx_FriendCircleShare,self.screenshotPath);
		end
	end);

	-- 朋友圈分享
	self.btnFriendCircleShare:setOnClick( self, function( self )
		if PlatformConfig.platformYiXin ~= GameConstant.platformType then 
			self:share( kFriendCircleShare, self.screenshotPath );
		else
			self:share(kYx_FriendShare,self.screenshotPath);
		end
	end);

	if PlatformConfig.platformYiXin == GameConstant.platformType then 
		self.btnQzoneShare:setFile("Login/yx/Room/share/yx_frend.png");
		self.btnQQShare:setFile("Login/yx/Room/share/yx_friendCircle.png")
	end

    --重置横竖屏的位置
    self:initPos();

	self:setCoverTransparent()

end

ShareWindow.initPos = function (self)
    local config = {
        portrait = {
            vSize = {w = 720, h = 720}, 
            bShowCloseBtn = false, 
            winBg = {align = kAlignLeft, size = {w = 424, h = 706}},
            shareImg = {size = {w =374, h =656}}, --{w =374, h =656}},
            pos_4 = {{x = 0, y = -216}, {x = 0, y = -72},{x = 0, y = 76},{x = 0, y = 220},},
            pos_2 = {{x = 0, y = -100}, {x = 0, y = 100}},
            btnAlign = kAlignRight,
        },
        landscape = {
            vSize = {w = 1280, h =720}, 
            bShowCloseBtn = true,
            winBg = {align = kAlignCenter, size = {w = 910, h = 595}},
            shareImg = {size = {w =850, h =535}},
            pos_4 = {{x = -380, y = 0}, {x = -130, y = 0},{x = 130, y = 0},{x = 380, y = 0},},
            pos_2 = {{x = -200, y = 0}, {x = 200, y = 0}},
            btnAlign = kAlignBottom,
        },
    };
    local t = self.m_bPortrait == true and config.portrait or config.landscape;
    self.config = t;

    self.v:setSize(t.vSize.w, t.vSize.h);
    self.btnClose:setVisible(t.bShowCloseBtn);

    -- 禁止窗外关闭
	self.window:setEventTouch(self, function ( self )
        if self.config.bShowCloseBtn == false then
            self:hideWnd();
        end
    end);
    self.window_bg:setAlign(t.winBg.align);
    self.window_bg:setSize(t.winBg.size.w, t.winBg.size.h);

    self.imgScreenShot:setSize(t.shareImg.size.w, t.shareImg.size.h);

    self.btnWechatShare:setAlign(t.btnAlign);
    self.btnWechatShare:setPos(t.pos_4[1].x, t.pos_4[1].y);
    self.btnFriendCircleShare:setAlign(t.btnAlign);
    self.btnFriendCircleShare:setPos(t.pos_4[2].x, t.pos_4[2].y);
    self.btnQQShare:setAlign(t.btnAlign);
    self.btnQQShare:setPos(t.pos_4[3].x, t.pos_4[3].y);
    self.btnQzoneShare:setAlign(t.btnAlign);
    self.btnQzoneShare:setPos(t.pos_4[4].x, t.pos_4[4].y);

    if PlatformConfig.platformYiXin ~= GameConstant.platformType then 
	    if GameConstant.isWechatInstalled == false then -- 未安装微信
	        DebugLog("微信未安装");

			self.btnWechatShare:setVisible( false );
			self.btnFriendCircleShare:setVisible( false );

			self.btnQQShare:setPos( t.pos_2[1].x, t.pos_2[1].y );
			self.btnQzoneShare:setPos(t.pos_2[2].x, t.pos_2[2].y  );
	    end

		if GameConstant.isQQInstalled == false then -- 未安装QQ
	        DebugLog("qq未安装");

			self.btnQQShare:setVisible( false );
			self.btnQzoneShare:setVisible( false );

			self.btnWechatShare:setPos( t.pos_2[1].x, t.pos_2[1].y );
			self.btnFriendCircleShare:setPos( t.pos_2[2].x, t.pos_2[2].y );
		end
	else
		self.btnWechatShare:setVisible( false );
		self.btnFriendCircleShare:setVisible( false );
		self.btnQQShare:setVisible(true);
		self.btnQzoneShare:setVisible(true);

		self.btnQQShare:setPos( t.pos_2[1].x, t.pos_2[1].y );
		self.btnQzoneShare:setPos(t.pos_2[2].x, t.pos_2[2].y  );
	end

    self.imgScreenShot:setFile( self.screenshotPath );
end

ShareWindow.exitAction = function ( self )
	if self.onCloseListener and self.onCloseObj then
		self.onCloseListener( self.onCloseObj );
	end
    if not HallScene_instance and GameConstant.curGameSceneRef.myBroadcast then
        GameConstant.curGameSceneRef.myBroadcast:setVisible(true);
    end 
end

ShareWindow.hideWnd = function ( self )
    SCWindow.hideWnd(self);
    self:exitAction();    
end

ShareWindow.resetShareBtnPos = function( self )
end

ShareWindow.share = function( self, TYPE, filePath )
	local data = {};
    local apkStoragePath = System.getStorageImagePath()..filePath;
    DebugLog("apkStoragePath:"..apkStoragePath);
	data.imagePath = apkStoragePath;
	native_to_java( TYPE, json.encode( data ) );
end

ShareWindow.noticePhpUserShared = function ( self )
	local param_data = {};
	param_data.mid 		= PlayerManager.getInstance():myself().mid;
	SocketManager.getInstance():sendPack( PHP_CMD_REQUEST_NOTICE_PHP_SHARE, param_data);
end

ShareWindow.setOnCloseListener = function( self, obj, method )
	self.onCloseObj = obj;
	self.onCloseListener = method;
end

ShareWindow.show = function( self )
--	self:setVisible( true );
    self:showWnd();
	printLog( "ShareWindow.show" );
end

shareWindow.dtor = function ( self )
	printLog("shareWindow.dtor")
    if GameConstant.curGameSceneRef.myBroadcast then
        GameConstant.curGameSceneRef.myBroadcast:setVisible(true);
    end 
end

