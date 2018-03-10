
require("Animation/SCSprite");
local loadingLayout = require(ViewLuaPath.."loadingLayout");
local LoadingPin_map = require("qnPlist/LoadingPin")


Loading = class(CustomNode);
Loading.defaultStr = "Loading";
Loading.instance = nil;

-- 静态函数，用于显示一个load界面
-- title 标题
-- node 根节点，默认使用当前游戏场景
-- x，y 位置默认居中于父节点
-- return loading 实例
-- cancelObj, cancelFun 点击取消按钮时的回调函数
Loading.showLoadingAnim = function (title, node, x, y, cancelObj, cancelFun )

	-- 单例 避免同时显示两个loading动画
	node = node or GameConstant.curGameSceneRef;
	title = title or Loading.defaultStr;
	if not node then
		return;
	end
	
	if not Loading.instance then 
		Loading.instance = new(Loading);
	end
	Loading.instance.node = node;
	Loading.instance:setCloseActionCallback(cancelObj, cancelFun);
	Loading.instance.node:addChild(Loading.instance);
	Loading.instance:setTitle(title);
	Loading.instance:setLevel(10000);

	Loading.instance:show();
end

Loading.hideLoadingAnim =function ( )

	if Loading.instance then
		Loading.instance:removeFromSuper();
		Loading.instance = nil;
	end
end

Loading.ctor = function ( self )

	self.img_bg = SceneLoader.load(loadingLayout);
	self:addChild(self.img_bg);

	--点击空白不消失
	self.cover:setEventTouch(self , function ( self )
		-- nothing
	end);

	self.node = publ_getItemFromTree(self.img_bg, {"img_bg"});
	self.cancelBtn = publ_getItemFromTree(self.img_bg, {"img_bg","btn_close"});

	self.cancelBtn:setOnClick(self, function ( self )
		if self.callbackFun then
			self.callbackFun(self.callbackObj);
		end
		self:hideLoadingAnim();
	end);

	if PlatformConfig.platformWDJ == GameConstant.platformType or 
		PlatformConfig.platformWDJNet == GameConstant.platformType then 
		self.cancelBtn:setFile("Login/wdj/Hall/Commonx/close_btn.png");
		self.cancelBtn.disableFile = "Login/wdj/Hall/Commonx/close_btn_disable.png";
	end

	local aniView = publ_getItemFromTree(self.img_bg, {"img_bg","view_ani"});
	self.anim = new(SCSprite, SpriteConfig.TYPE_LOADING_ANIM);

	self.anim:setPlayMode(kAnimRepeat);
	aniView:addChild(self.anim);

	self.loadingText = publ_getItemFromTree(self.img_bg, {"img_bg","text_loading"});
	self:setVisible(false);
end

Loading.setTitle = function ( self, msg )
	self.loadingText:setText(msg or Loading.defaultStr);
end

Loading.setCloseActionCallback = function ( self, obj, fun )
	self.callbackObj = obj;
	self.callbackFun = fun;
end

Loading.show = function ( self )
	self:setVisible(true);
	self.anim:play();
end

Loading.hide = function ( self )

	self:setVisible(false);
end

Loading.dtor = function ( self )

	self.anim:stop();
	self.anim = nil;
	self:removeAllChildren();
	Loading.instance = nil;
end


