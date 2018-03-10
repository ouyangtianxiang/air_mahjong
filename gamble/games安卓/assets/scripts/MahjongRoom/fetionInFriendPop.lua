-- 邀请飞信好友弹窗
local fetionInFriend = require(ViewLuaPath.."fetionInFriend");

FetionInFriend = class(CustomNode);

FetionInFriend.ctor = function ( self )
	self.layout = SceneLoader.load(fetionInFriend);
	self:addChild(self.layout);
	self.cover:setEventTouch(self , function ( self )
	end);

	self.bg        = publ_getItemFromTree(self.layout, {"img_win_bg"});
	self.btn_close = publ_getItemFromTree(self.layout, {"img_win_bg", "btn_close"});
	self.btn_left  = publ_getItemFromTree(self.layout,{"img_win_bg", "Image1", "btn_left"});
	self.btn_right = publ_getItemFromTree(self.layout,{"img_win_bg", "Image1", "btn_right"});
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
	param.pic      = FriendDataManager.getInstance().fetionPicUrl;
	param.apk      = FriendDataManager.getInstance().fetionApkUrl;
	param.inRoom   = 1;
	param.platform = PlatformConfig.platformFetion;
	param_tmp = json.encode(param);
	native_to_java(kFetionMessage, param_tmp);
	end);

	self.btn_right:setOnClick(self, function ( self )
	if not FriendDataManager.getInstance().fetionPicUrl then
		Loading.showLoadingAnim("正在努力加载中...");
		FriendDataManager.getInstance():requestFetionPicAndApk();
		return;
	end
	local param = {};
	local param_tmp;
	param.pic      = FriendDataManager.getInstance().fetionPicUrl;
	param.apk      = FriendDataManager.getInstance().fetionApkUrl;
	param.inRoom   = 1;
	param.platform = PlatformConfig.platformFetion;
	param_tmp = json.encode(param);
	native_to_java(kFetionSMS, param_tmp);
	end);
end

FetionInFriend.hideHandle = function ( self )
	self:removeFromSuper();
end


FetionInFriend.show = function ( self )
	popWindowDown(self, nil, self.bg);
end

FetionInFriend.dtor = function ( self )
	self:removeAllChildren();
end






