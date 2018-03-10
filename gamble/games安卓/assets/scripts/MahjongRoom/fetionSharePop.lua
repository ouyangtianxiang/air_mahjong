-- 飞信分享弹窗
local fetionShare = require(ViewLuaPath.."fetionShare");
FetionSharePop = class(CustomNode);

FetionSharePop.ctor = function ( self )
	self.layout = SceneLoader.load(fetionShare);
	self:addChild(self.layout);
	self.cover:setEventTouch(self , function ( self )
	end);

	self.bg        = publ_getItemFromTree(self.layout, {"img_win_bg"});
	self.btn_close = publ_getItemFromTree(self.layout, {"img_win_bg", "btn_close"});
	self.btn_left  = publ_getItemFromTree(self.layout,{"img_win_bg", "Image1", "btn_left"});
	self.btn_right = publ_getItemFromTree(self.layout,{"img_win_bg", "Image1", "btn_right"});

	if not self.windowX and not self.windowY then
		self.windowX,self.windowY = self.bg:getPos();
	end
	self.windowW,self.windowH = self.bg:getSize();

	self.btn_close:setOnClick(self, function(self)
		popWindowUp(self, self.hideHandle, self.bg);
	end);

	self.btn_left:setOnClick(self, function ( self )
		if not FriendDataManager.getInstance().fetionPicUrl then
			Loading.showLoadingAnim("正在努力加载中...");
			FriendDataManager.getInstance():requestFetionPicAndApk();
			return ;
		end
		local param = {};
		local param_tmp;

		param.pic         = FriendDataManager.getInstance().fetionPicUrl;
		param.apk         = FriendDataManager.getInstance().fetionApkUrl;
		param.platform    = PlatformConfig.platformFetion;
		param_tmp = json.encode(param);
		native_to_java(kFetionShareInside, param_tmp);
	end);

	self.btn_right:setOnClick(self, function ( self )
		if not FriendDataManager.getInstance().fetionApkUrl then
			Loading.showLoadingAnim("正在努力加载中...");
			FriendDataManager.getInstance():requestFetionPicAndApk();
			return ;
		end
		local param = {};
		local param_tmp;
		param.pic      = FriendDataManager.getInstance().fetionPicUrl;
		param.apk      = FriendDataManager.getInstance().fetionApkUrl;
		param.platform = PlatformConfig.platformFetion;
		param_tmp = json.encode(param);

		native_to_java(kFetionShareOutside, param_tmp);
	end);
end

FetionSharePop.show = function ( self )
	popWindowDown(self, nil, self.bg);
end


FetionSharePop.hideHandle = function ( self )
	self:removeFromSuper();
end

FetionSharePop.dtor = function ( self )
	self:removeAllChildren()
end






