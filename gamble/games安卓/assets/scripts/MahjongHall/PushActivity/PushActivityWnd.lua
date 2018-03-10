-- filename: PushActivityWnd
-- author: onlynightzhang
-- desp:
local pushActivityWnd = require(ViewLuaPath.."pushActivityWnd");

PushActivityWnd = class(SCWindow);

function PushActivityWnd:ctor( parent, activityType )
	self.parent = parent;
	self.activityType = activityType or 1;
	self.layout = SceneLoader.load( pushActivityWnd );
	self:addChild( self.layout );
	self:initView();

	if self.parent then
		self.parent:addChild( self );
	else
		self:addToRoot();
	end
end

function PushActivityWnd:initView()
	self.window = publ_getItemFromTree( self.layout, { "img_bg" } );
	self:setWindowNode( self.window );

	self.btn_close = publ_getItemFromTree( self.layout, { "img_bg", "btn_close" } );
	self.img_showtext = publ_getItemFromTree( self.layout, { "img_bg", "img_mahjong", "view_showtext", "img_showtext" } );
	self.btn_ok = publ_getItemFromTree( self.layout, { "img_bg", "btn_ok" } );

	self.btn_close:setOnClick( self, function( self )
		self:hideWnd();
	end);

	self.btn_ok:setOnClick( self, function( self )
		self:hideWnd();
		-- TODO
		self:setOnWindowHideListener( self, function( self )
			if self.func then
				self.func( self.obj );
			end
		end);
	end);

	if PlatformConfig.platformWDJ == GameConstant.platformType or 
	   PlatformConfig.platformWDJNet == GameConstant.platformType then 
        self.btn_close:setFile("Login/wdj/Hall/Commonx/close_btn.png");
    end

	self.img_showtext:setFile( string.format( "newHall/pushActivity/push_activity_%d.png", self.activityType ) );
end

function PushActivityWnd:setOnOkClickListener( obj, func )
	self.obj = obj;
	self.func = func;
end