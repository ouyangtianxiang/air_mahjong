local secondConfirmWnd = require(ViewLuaPath.."secondConfirmWnd");
SecondConfirmWnd = class();

SecondConfirmWnd.instance = nil;

SecondConfirmWnd.getInstance = function()
	if not SecondConfirmWnd.instance then
		SecondConfirmWnd.instance = new( SecondConfirmWnd );
	end
	return SecondConfirmWnd.instance;
end

SecondConfirmWnd.ctor = function( self )
	self.titleText = nil;
	self.contentText = nil;
	self.btnText = nil;
	self.cacheDataHttpEvent = EventDispatcher.getInstance():getUserEvent();
	NetCacheDataManager.getInstance():register( self.cacheDataHttpEvent, SecondConfirmWnd.cacheDataHttpCallBackFuncMap, self, self.onCacheDataHttpListener );

	-- self:requestData();
end

SecondConfirmWnd.dtor = function( self )
	NetCacheDataManager.getInstance():unregister(self.cacheDataHttpEvent, self, self.onCacheDataHttpListener);
end


-- cache data manager 请求数据后回调函数
function SecondConfirmWnd:onCacheDataHttpListener( httpCmd, data )
	log( "SecondConfirmWnd:onCacheDataHttpListener" );
	--mahjongPrint( data );
	local isSuccess = (data ~= nil);
	if SecondConfirmWnd.cacheDataHttpCallBackFuncMap[httpCmd] then
		SecondConfirmWnd.cacheDataHttpCallBackFuncMap[httpCmd]( self, isSuccess, data )
	end
end

SecondConfirmWnd.onHttpResponse = function( self, isSuccess, data )
	if not isSuccess or not data then
        return;
    end
	
	if data.data then
		self.titleText = data.data.title or "温馨提示";
		self.contentText = data.data.content or 
		"购买超值金币，畅想精彩游戏！你将购买AAAAA，资费BBBBB元！你确定要购买吗？CCCCC客服电话：400-663-1888或0755-86166169";
		self.btnText = data.data.btn or "确定";
		DebugLog( "SecondConfirmWnd.titleText"..self.titleText );
		DebugLog( "SecondConfirmWnd.contentText"..self.contentText );
		DebugLog( "SecondConfirmWnd.btnText"..self.btnText );
	end
end

SecondConfirmWnd.requestData = function( self )
	NetCacheDataManager.getInstance():activeNotifyReceiver( PHP_CMD_REQUEST_SECOND_CONFIRM_WND_TEXT );
end

SecondConfirmWnd.show = function( self, productName, amount)
	if not self.window then 
		self.window = new( SecondConfirmView, self.titleText, self.contentText, self.btnText,self);
	else 
		return ;
	end
	self.window:addToRoot();
	self.window:show( productName, amount );
end

SecondConfirmWnd.setOnConfirmClick = function( self, obj, func )
	if self.window then
		self.window:setOnConfirmClick( obj, func );
	end
end

SecondConfirmWnd.setOnCloseClick = function( self, obj ,func )
	if self.window then
		self.window:setOnCloseClick( obj, func );

	end
	
end

SecondConfirmView = class(SCWindow);

SecondConfirmView.ctor = function( self, titleText, contentText, btnText,obj )
	self.window = SceneLoader.load( secondConfirmWnd );
	self.obj = obj;
	self:addChild( self.window );

	self.contentText = contentText;
	self.titleText = titleText;
	self.btnText = btnText;

	self.bg = publ_getItemFromTree(self.window,{"img_window_bg"});
	self.btnClose = publ_getItemFromTree(self.window,{"img_window_bg","btn_close"});
	self.title = publ_getItemFromTree(self.window,{"img_window_bg","text_title"});
	self.content = publ_getItemFromTree(self.window,{"img_window_bg","img_inner","text_content"});
	self.btnConfirm = publ_getItemFromTree(self.window,{"img_window_bg","btn_confirm"});
	self.confirmText = publ_getItemFromTree(self.window,{"img_window_bg","btn_confirm","text_confirm"});

	self:setWindowNode( self.bg );

	self.btnClose:setOnClick(self, function ( self )
		self.hideHandleObj = self.closeObj;
		self.hideHandleFunc = self.closeFunc;
		self:hideWnd();
		if self.obj then 
			self.obj.window = nil;
		end
	end);

	self.btnConfirm:setOnClick(self, function ( self )
		self.hideHandleObj = self.confirmObj;
		self.hideHandleFunc = self.confirmFunc;
		self:hideWnd();
		if self.obj then 
			self.obj.window = nil;
		end
	end);

	if PlatformConfig.platformWDJ == GameConstant.platformType or 
        PlatformConfig.platformWDJNet == GameConstant.platformType then 
		self.btnClose:setFile("Login/wdj/Hall/Commonx/close_btn.png");
		self.btnClose.disableFile = "Login/wdj/Hall/Commonx/close_btn_disable.png";
		self.bg:setFile("Login/wdj/Hall/Commonx/pop_window_small.png");
	end
end

SecondConfirmView.show = function( self, productName, amount )
	local tempContent = string.gsub( self.contentText, "AAAAA", productName );
	tempContent = string.gsub( tempContent, "BBBBB", amount );
	tempContent = string.gsub( tempContent, "CCCCC", "\n" );
	
	local tempTitle = GameString.convert2Platform( self.titleText );
	local infoStr = GameString.convert2Platform( tempContent );

	self.title:setText( tempTitle );
	self.content:setText( infoStr );
	if GameConstant.checkType == kCheckStatusOpen then --审核状态
		self.confirmText:setText("购买");
	else
		self.confirmText:setText( self.btnText );
	end

	self:showWnd();
end

SecondConfirmView.setOnConfirmClick = function( self, obj, func )
	self.confirmObj = obj;
	self.confirmFunc = func;
end

SecondConfirmView.setOnCloseClick = function( self, obj ,func )
	self.closeObj = obj;
	self.closeFunc = func;
end

function SecondConfirmView.onWindowHide( self )
	if self.hideHandleObj and self.hideHandleFunc then
		self.hideHandleFunc( self.hideHandleObj );
	end
end

-- 缓存处理函数
SecondConfirmWnd.cacheDataHttpCallBackFuncMap = {
	[PHP_CMD_REQUEST_SECOND_CONFIRM_WND_TEXT] = SecondConfirmWnd.onHttpResponse;
};

