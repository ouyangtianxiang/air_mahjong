-- ChangeItemWnd.lua
-- author: OnlynightZhang
-- desp: 切换牌纸窗口
local changePaizhiWnd = require(ViewLuaPath.."changePaizhiWnd");

ChangeItemWnd = class(SCWindow);

ChangeItemWnd.ctor = function( self, paizhiName, cid, goodsType, parent )
	self.paizhiName = paizhiName or "";
	self.cid = cid;
	self.goodsType = goodsType;
	self:initView();
	if parent then
		parent:addChild( self );
	else
		self:addToRoot();
	end
end

ChangeItemWnd.initView = function( self )
	self.layout = SceneLoader.load( changePaizhiWnd );
	self:addChild( self.layout );

	self.window = publ_getItemFromTree(self.layout, {"img_bg"});
	self:setWindowNode( self.window );

	self.btnClose = publ_getItemFromTree( self.layout, {"img_bg","btn_close"} );

	if PlatformConfig.platformWDJ == GameConstant.platformType or 
        PlatformConfig.platformWDJNet == GameConstant.platformType then 
		self.btnClose:setFile("Login/wdj/Hall/Commonx/close_btn.png");
		self.btnClose.disableFile = "Login/wdj/Hall/Commonx/close_btn_disable.png";
	end
	self.btnCancel = publ_getItemFromTree( self.layout, {"img_bg","btn_cancel"} );
	self.btnOK = publ_getItemFromTree( self.layout, {"img_bg","btn_ok"} );
	self.textTips = publ_getItemFromTree( self.layout, {"img_bg","img_inner_bg","text_tips"} );

	self.textTips:setText( "是否在游戏中使用 "..self.paizhiName.."？" );
	self.btnCancel:setOnClick( self, function( self )
		self:hideWnd();
	end);
	self.btnClose:setOnClick( self, function( self )
		self:hideWnd();
	end);

	self.btnOK:setOnClick( self, function( self )
		if self.okClickObj and self.okClickFunc then
			self.okClickFunc( self.okClickObj );
		end

		PlayerManager.getInstance():myself().paizhi = tostring(self.cid or 10000);
		DebugLog("GlobalDataManager.updatePaizhiEvent dispatch cid: " .. tostring(self.cid) .. ",goodsType: " ..tostring(self.goodsType))
		EventDispatcher.getInstance():dispatch( GlobalDataManager.updatePaizhiEvent, self.cid, self.goodsType );
		self:hideWnd();
	end);

	if PlatformConfig.platformWDJ == GameConstant.platformType then 
		self.window:setFile("Login/wdj/Hall/Commonx/pop_window_small.png");
	end
end

ChangeItemWnd.setOnOkClickListener = function( self, obj, func )
	self.okClickObj = obj;
	self.okClickFunc = func;
end
