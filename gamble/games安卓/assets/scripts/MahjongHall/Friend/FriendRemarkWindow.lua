local friendRemarkWindow = require(ViewLuaPath.."friendRemarkWindow");

FriendRemarkWindow = class(CustomNode);



FriendRemarkWindow.ctor = function ( self, alias )

	self.cover:setEventTouch(self , function (self)
	end);

	self.mLayout = SceneLoader.load(friendRemarkWindow);
	self:addChild(self.mLayout);

	self.img_win_bg   = publ_getItemFromTree(self.mLayout, {"img_win_bg"});	

	publ_getItemFromTree(self.mLayout, {"img_win_bg", "btn_close"}):setOnClick(self, self.popWindowUp);
	publ_getItemFromTree(self.mLayout, {"img_win_bg", "btn_left"}):setOnClick(self, self.popWindowUp);	
	publ_getItemFromTree(self.mLayout, {"img_win_bg", "btn_right"}):setOnClick(self, self.onClickConfirm);
	self.mEditor = publ_getItemFromTree(self.mLayout, {"img_win_bg", "img_edit_bg", "et_alias"});
	self.mEditor:setHintText("备注名最长为12个字符", 0x96, 0x28, 0x28);
	self.mEditor:setOnTextChange(self, FriendRemarkWindow.onTextChange);
	self.mOldAlias = alias or "";

	if PlatformConfig.platformWDJ == GameConstant.platformType or 
	   PlatformConfig.platformWDJNet == GameConstant.platformType then 
		publ_getItemFromTree(self.mLayout, {"img_win_bg", "btn_close"}):setFile("Login/wdj/Hall/Commonx/close_btn.png");
		publ_getItemFromTree(self.mLayout, {"img_win_bg", "btn_close"}).disableFile = "Login/wdj/Hall/Commonx/close_btn_disable.png";
		self.img_win_bg:setFile("Login/wdj/Hall/Commonx/pop_window_small.png");
	end
	self.mEditor:setText(self.mOldAlias);

	self:onTextChange();

	popWindowDown(self, nil, self.img_win_bg);
end
FriendRemarkWindow.popWindowUp = function ( self )
	popWindowUp(self, self.hideHandle, self.img_win_bg);
end

FriendRemarkWindow.hideHandle = function ( self )
	self:onClose();
end
FriendRemarkWindow.dtor = function ( self )
	self:removeAllChildren();
end

FriendRemarkWindow.onTextChange = function ( self )
	local alias  = self.mEditor:getText() or "";

	if string.len(self.mOldAlias) == 0 then
		if string.len(alias) == 1 then
			--变灰
			local btn = publ_getItemFromTree(self.mLayout, {"img_win_bg", "btn_right"});
			btn:setGray(true)
			btn:setPickable(false);
		else
			local btn = publ_getItemFromTree(self.mLayout, {"img_win_bg", "btn_right"});
			btn:setGray(false)
			btn:setPickable(true);
		end
	end
		
end

FriendRemarkWindow.onClickConfirm = function ( self )
	local alias  = self.mEditor:getText();
	if not alias  or getStringLen(alias) > 12 then
		Banner.getInstance():showMsg("备注名最长为12个字符");
		return;
	end
	if self.mClickOnConfirmFunc then
		self.mClickOnConfirmFunc(self.mClickOnConfirmParam, alias);
	end
end

FriendRemarkWindow.onClose = function ( self )
	-- body
	if self.mClickOnCloseFunc then
		self.mClickOnCloseFunc(self.mClickOnClosemParam);
	end
end

FriendRemarkWindow.setOnConfirm = function ( self, func, param)
	-- body
	self.mClickOnConfirmFunc = func;
	self.mClickOnConfirmParam= param;
end

FriendRemarkWindow.setOnClose = function ( self, func, param)
	-- body
	self.mClickOnCloseFunc = func;
	self.mClickOnClosemParam= param;
end


