-- filename: MiuiSmsSettingWnd
-- author: onlynightzhang
-- desp:
local miuiSmsSettingWnd = require(ViewLuaPath.."miuiSmsSettingWnd");

MiuiSmsSettingWnd = class(SCWindow);

function MiuiSmsSettingWnd:ctor( parent,cancelFuc )
	self.layout = SceneLoader.load( miuiSmsSettingWnd );
	self.window = publ_getItemFromTree(self.layout, {"img_bg"});
	self:addChild( self.layout );
	self:initView();
	self:setWindowNode(self.window);

	self.obj = parent;
	self.cancelFuc = cancelFuc;
	self:showWnd();
end

function MiuiSmsSettingWnd:dtor()
end

function MiuiSmsSettingWnd:initView()
	self.btnClose = publ_getItemFromTree( self.window, {"btn_close"} );
	self.btnCancel = publ_getItemFromTree( self.window, {"btn_cancel"} );
	self.btnSetting = publ_getItemFromTree( self.window, {"btn_setting"} );

	self.btnClose:setOnClick( self, function( self )
		self.cancelFuc(PayController)
		if self.cancelFuc then 
			Banner.getInstance():showMsg("cancel")
		end
		self:hideWnd();
	end);

	self.btnCancel:setOnClick( self, function( self )
		self.cancelFuc(PayController)
		if self.cancelFuc then 
			Banner.getInstance():showMsg("cancel")
		end
		self:hideWnd();
	end);

	self.btnSetting:setOnClick( self, function( self )
		self.gotoSettings = true;
		self:hideWnd();
		self:toSettingWnd();
	end);

	if PlatformConfig.platformWDJ == GameConstant.platformType or 
	   PlatformConfig.platformWDJNet == GameConstant.platformType then 
        self.btnClose:setFile("Login/wdj/Hall/Commonx/close_btn.png");
        self.window:setFile("Login/wdj/Hall/Commonx/pop_window_mid.png");
    end
end

function MiuiSmsSettingWnd:hideWnd()
	self.super.hideWnd( self );
	if self.obj then
		self.obj.m_miuismsWnd = nil; 
	end
end


function MiuiSmsSettingWnd:toSettingWnd()
	GameConstant.isShowMiuiSmsSettingWnd = false;
	native_to_java(kSetMiuiSettingWndShowed);
end

function MiuiSmsSettingWnd:onWindowHide()
	self.super.onWindowHide( self );
	if self.gotoSettings then
		self.gotoSettings = false;
		GameConstant.isShowMiuiSmsSettingWnd = false;
		native_to_java(kGotoMiuiSmsSettingPage);
	end
end
