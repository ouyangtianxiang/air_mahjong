-- filename: BanInfoWnd.lua
-- author: onlynightzhang
-- desp: 封号提示窗口
local banInfoWnd = require(ViewLuaPath.."banInfoWnd");

BanInfoWnd = class(SCWindow);

function BanInfoWnd:ctor( msg, parent )
	self.msg = msg;
	self.parent = parent;

	self.layout = SceneLoader.load( banInfoWnd );
	self:addChild(self.layout);
	self:initView();

	if parent then
		parent:addChild( self );
	else
		self:addToRoot();
	end
end

function BanInfoWnd:dtor()
end

function BanInfoWnd:initView()
	self.window = publ_getItemFromTree(self.layout, {"img_bg"});
	self:setWindowNode( self.window );

	self.textTips = publ_getItemFromTree(self.layout, {"img_bg","img_inner_bg","text_tips"});
	self.textTips:setText( self.msg );

	self.btnOk = publ_getItemFromTree(self.layout, {"img_bg","btn_ok"});
	self.btnOk:setOnClick( self, function( self )
		native_muti_exit()
	end);


	if PlatformConfig.platformWDJ == GameConstant.platformType or
	   PlatformConfig.platformWDJNet == GameConstant.platformType then 
		self.window:setFile("Login/wdj/Hall/Commonx/pop_window_small.png");
	end
end