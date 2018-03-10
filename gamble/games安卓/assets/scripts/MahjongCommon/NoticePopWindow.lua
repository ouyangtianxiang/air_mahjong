local noticePopWindow = require(ViewLuaPath.."noticePopWindow");
require("MahjongCommon/NoticeItem");

NoticePopWindow = class(SCWindow);


NoticePopWindow.ctor = function (self, data, isUnLogin )
    self:set_pop_index(new_pop_wnd_mgr.get_instance():get_wnd_idx(new_pop_wnd_mgr.enum.notice));
	self.noticeDataList = data;
	self:initView();

	self.isUnLogin = isUnLogin
end

NoticePopWindow.createNoticeItem = function ( self )
	local noticeNum = #self.noticeDataList;
	local x,y = 0,0;
	for i=1, noticeNum do
		local noticeItem = new(NoticeItem, self.noticeDataList[i], self);
		noticeItem:setPos(x,y);
		local h = noticeItem:getTotalLength();
		y = y + h;
		self.scrollNode:addChild(noticeItem);
	end
end

function NoticePopWindow.initView( self )
	self.bg = SceneLoader.load(noticePopWindow);
	self:addChild(self.bg);
	self.layout     = publ_getItemFromTree(self.bg,{"win_bg"});
	self.inner_bg   = publ_getItemFromTree(self.bg, {"win_bg", "win_inner_bg"});
	self.closeBtn   = publ_getItemFromTree(self.bg, {"win_bg", "btn_close"});

	self:setWindowNode( self.layout );
	self.closeBtn:setOnClick(self, function ( self )
		self:hideWnd();
	end);

	self.scrollNode = new(ScrollView, 0, 0, 750, 370, false);
	self.scrollNode:setScrollBarWidth(0);
	self.inner_bg:addChild(self.scrollNode);
	self.scrollNode:setSize(self.scrollNode:getSize());

	self:createNoticeItem();

	 if PlatformConfig.platformWDJ == GameConstant.platformType or 
		PlatformConfig.platformWDJNet == GameConstant.platformType then 
        self.closeBtn:setFile("Login/wdj/Hall/Commonx/close_btn.png");
        self.closeBtn.disableFile = "Login/wdj/Hall/Commonx/close_btn_disable.png";
        self.layout:setFile("Login/wdj/Hall/Commonx/pop_window_mid.png");
    end
end

function NoticePopWindow.onWindowHide( self )
   if not self.isUnLogin then 
       new_pop_wnd_mgr.get_instance():hide_and_show( new_pop_wnd_mgr.enum.notice );
   else 
		if self.hideCallbackFunc then
			self.hideCallbackFunc( self.hideCallbackObj );
		end
   end 
end

NoticePopWindow.dtor = function ( self )
	self:removeAllChildren();
end

