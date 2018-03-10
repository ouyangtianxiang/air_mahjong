local midPopWindow = require(ViewLuaPath.."midPopWindow");
local smallPopWindow = require(ViewLuaPath.."smallPopWindow");

require("MahjongCommon/SCWindow");

PopuFrame = class(SCWindow);


-- PopuFrame.nomalViewContentWidth = 380;
-- PopuFrame.nomalViewContentHeight = 140;
-- PopuFrame.bigContentWidth = 440;
-- PopuFrame.bigContentHeight = 180;
-- -- 显示按钮的区域高
-- PopuFrame.buttonAreaHeightSet = 40;

PopuFrame.ctor = function (self, parent, isDialog, isConfirm, isBigContent, confirmStr, cancelStr, noCloseBtn)
	self.window = SceneLoader.load(isBigContent and midPopWindow or smallPopWindow);
	self.noCloseBtn = noCloseBtn;
	self:addChild(self.window);
	self.callbackFunc = nil;
	self.callbackObj = nil;

	if parent then
		parent:addChild(self);
	else
		self:addToRoot();
	end

	self.root_bg = publ_getItemFromTree(self.window, {"root_bg"});

	if HallScene_instance then
		--self.root_bg:setFile( "Commonx/zhezhao.png" );--setFile("Hall/hallComon/hallBgVague.png");
	else
		self.root_bg:setFile("");
	end

	self.img_win_bg = publ_getItemFromTree(self.window, {"root_bg","img_win_bg"});
	self:setWindowNode( self.img_win_bg );

	self.closeBtn = publ_getItemFromTree(self.window,{"root_bg","img_win_bg","btn_close"});
	if self.noCloseBtn then
		self.closeBtn:setVisible( false );
	else
		self.closeBtn:setVisible( true );
		self.closeBtn:setOnClick(self, function ( self )
			self.callbackFunc = self.closeFunc;
			self.callbackObj = self.closeObj;
			self:hideWnd();
		end);
	end
	--设置关闭事件
	-- publ_getItemFromTree(self.window,{"img_win_bg","btn_close"}):setOnClick(self, function ( self )
	-- 	self.callbackFunc = self.closeFunc;
	-- 	self.callbackObj = self.closeObj;
	-- 	self:hideWnd();
	-- 	if self.closeFunc and  self.closeObj then
	-- 		self.closeFunc(self.closeObj);
	-- 	end

	-- end);

	--设置滑动条大小
	publ_getItemFromTree(self.window,{"root_bg","img_win_bg","img_win_inner_bg", "sv_content"}):setScrollBarWidth(5);

	self.isDialog 	= isDialog;
	self.isConfirm 	= isConfirm;

	self.btnComfirm = nil;
	self.btnCancel = nil;

	if self.isDialog then
		if self.isConfirm then
			self.btnComfirm = publ_getItemFromTree(self.window,{"root_bg","img_win_bg","btn_mid"});
			self.btnComfirm:setVisible(true);
			publ_getItemFromTree(self.btnComfirm,{"text_name"}):setText(confirmStr or "确   定");
			--确定 事件
			self.btnComfirm:setOnClick(self, function ( self )
				if self.confirmFun then
					self.confirmFun(self.confirmObj);
				end
				self:hideWnd();
			end);

		else
			--确定 取消 事件
			self.btnCancel  = publ_getItemFromTree(self.window,{"root_bg","img_win_bg","btn_left"});
			self.btnComfirm = publ_getItemFromTree(self.window,{"root_bg","img_win_bg","btn_right"});
			self.btnCancel:setVisible(true);
			self.btnComfirm:setVisible(true);

			self.btnCancelText = publ_getItemFromTree(self.btnCancel,{"text_name"})
			self.btnCancelText:setText(cancelStr or "取   消");

			self.btnComfirmText = publ_getItemFromTree(self.btnComfirm,{"text_name"})
			self.btnComfirmText:setText(confirmStr or "确   定");

			--publ_getItemFromTree(self.btnComfirm,{"text_name"}):setText(confirmStr or "确   定");

			self.btnCancel:setOnClick(self, function ( self )
				self.callbackFunc = self.cancelFun;
				self.callbackObj = self.cancelObj;
				self:hideWnd();
			end);

			self.btnComfirm:setOnClick(self, function ( self )
				self.callbackFunc = self.confirmFun;
				self.callbackObj = self.confirmObj;
				self:hideWnd();
			end);

		end

	else
		local viewContent = publ_getItemFromTree(self.window,{"root_bg","img_win_bg","img_win_inner_bg"});
		local cntW, cntH = viewContent:getSize();
		viewContent:setSize(cntW, cntH+70);
	end


    if PlatformConfig.platformWDJ == GameConstant.platformType or
	   PlatformConfig.platformWDJNet == GameConstant.platformType then
        self.closeBtn:setFile("Login/wdj/Hall/Commonx/close_btn.png");
         self.closeBtn.disableFile = "Login/wdj/Hall/Commonx/close_btn_disable.png";
         if midPopWindow then
        	 self.img_win_bg:setFile("Login/wdj/Hall/Commonx/pop_window_mid.png");
    	 end
    	 if smallPopWindow then
    	 	 self.img_win_bg:setFile("Login/wdj/Hall/Commonx/pop_window_small.png");
    	 end
    end
end

function PopuFrame.playHideAnim( self )
	self.isPlaying = false;
	self:setVisible( false );
	if self.m_isAutoRemove then
		self:removeFromSuper();
	end
	self:onHideHandle();
	self:onWindowHide();
end

function PopuFrame.onHideHandle( self )
	if self.callbackFunc and self.callbackObj then
		self.callbackFunc( self.callbackObj );
	end
end


function PopuFrame.onWindowHide( self )
	-- if self.callbackFunc and self.callbackObj then
	-- 	self.callbackFunc( self.callbackObj );
	-- end
	self.super.onWindowHide(self);
	--new_pop_wnd_mgr.get_instance():hide_and_show( new_pop_wnd_mgr.windows.PopuFrame);
	DebugLog("PopuFrame.onWindowHide@@@@@@@@@@@@@@@@@@@@@@");
end

-- function PopuFrame.setOnWindowHideListener( self, obj, func )
-- 	if obj and func then
-- 		func( obj )
-- 	end
-- end

PopuFrame.setWindowSize = function( self, width, height )
	self.img_win_bg:setSize( width, height );
	local viewContent = publ_getItemFromTree(self.window,{"root_bg","img_win_bg","img_win_inner_bg"});
	viewContent:setSize( width - 50 , height -200 );
end

PopuFrame.setCloseCallback = function( self, obj, func )
	self.closeObj = obj;
	self.closeFunc = func;
end

PopuFrame.setConfirmBtnText = function( self, text )
	if not text then
		return;
	end
	local btnComfirm = publ_getItemFromTree(self.window,{"root_bg","img_win_bg","btn_mid"});
	publ_getItemFromTree(btnComfirm,{"text_name"}):setText(text or "确   定");
end

--设置标题
PopuFrame.setTitle = function ( self, title )
	publ_getItemFromTree(self.window,{"root_bg","img_win_bg","view_title", "text_title"}):setText(title);
end
--设置内容
PopuFrame.setContent = function ( self, node )
	publ_getItemFromTree(self.window,{"root_bg","img_win_bg","img_win_inner_bg","sv_content"}):addChild(node);
end
PopuFrame.setContentText = function ( self, text )

	local nodeContent = publ_getItemFromTree(self.window,{"root_bg","img_win_bg","img_win_inner_bg","sv_content"});
	local nodeW, nodeH=nodeContent:getSize();
	local textContent = new(TextView,text,nodeW, nodeH,kAlignTopLeft,"",30, 0x4b, 0x2b, 0x1c);
	nodeContent:addChild(textContent);
end

-- 是否隐藏关闭按钮
PopuFrame.setHideCloseBtn = function ( self, isHide )
	if isHide then
		publ_getItemFromTree(self.window,{"root_bg","img_win_bg","btn_close"}):setVisible(false);
		--publ_getItemFromTree(self.window,{"img_win_bg"}):setFile("Common/windowsBg_noClose.png");
	end
end

--显示中间的按钮
PopuFrame.set_btn_middle_visible = function (self, v)
    publ_getItemFromTree(self.window,{"root_bg","img_win_bg","btn_mid"}):setVisible(v);
end

--显示中间的按钮
PopuFrame.set_btn_left_right_visible = function (self, v)
    publ_getItemFromTree(self.window,{"root_bg","img_win_bg","btn_left"}):setVisible(v);
    publ_getItemFromTree(self.window,{"root_bg","img_win_bg","btn_right"}):setVisible(v);
end

--是否不让点击其他位置自动消除
PopuFrame.setNotOnClickFeeling = function(self,isFeeling)
	if isFeeling then
		self.cover:setEventTouch(self,function(self)

		end);
	end
end

PopuFrame.dtor = function (self)
	DebugLog("PopuFrame dtor");
	self:removeAllChildren();
end

-- 设置确定按钮回调函数
PopuFrame.setConfirmCallback = function ( self, obj, fun )
	if not self.isDialog then
		return;
	end
	self.confirmObj = obj;
	self.confirmFun = fun;
end

-- 设置取消按钮回调函数
PopuFrame.setCancelCallback = function ( self, obj, fun )
	if not self.isDialog and self.isConfirm then
		return;
	end
	self.cancelObj = obj;
	self.cancelFun = fun;
end

PopuFrame.show = function ( self )
	self:showWnd();
end

PopuFrame.hide = function ( self )
	self:hideWnd();
end

PopuFrame.hideWnd = function ( self,notHideAnim )
	self.btnCancelText = nil
	self.btnComfirmText = nil;
	self.super.hideWnd(self,notHideAnim)
end

-- 普通的提示框 只是显示一段文字 文字自动换行
-- posX, posY可选参数，默认居中于父节点区域
-- 如果node是空的， 添加到根节点下
PopuFrame.showNormalAlertView = function ( title, infoStr, node, posX, posY, isBigContent )
	local view = new(PopuFrame, node, false, false, isBigContent);

	title = title or "提 示";
	infoStr = infoStr or "";
	title = GameString.convert2Platform(title);
	infoStr = GameString.convert2Platform(infoStr);

	view:setTitle( title);
	view:setContentText(infoStr);
	view:setLevel(10000);
	view:showWnd();
	return view;
end

-- 定制的提示弹出框
-- contentView 要显示的内容视图
PopuFrame.showCustomAlertView = function ( title, infoStr, node, posX, posY, isBigContent, confirmStr, cancelStr )

	local view = new(PopuFrame, node,false, false, isBigContent, confirmStr, cancelStr);

	view:setTitle( GameString.convert2Platform(title or "提 示"));
	view:setContentText(GameString.convert2Platform(infoStr or ""));
	view:setLevel(10000);
	view:showWnd();
	return view;
end

-- 普通对话框，只是显示一行文字信息
-- isConfirm 是否是只有确认按钮的确认框
PopuFrame.showNormalDialog = function ( title, infoStr, node, posX, posY, isConfirm, isBigContent, confirmStr, cancelStr )
	if nil == isBigContent then -- 默认用大图
		isBigContent = true;
	end
	local view = new(PopuFrame, node, true, isConfirm, isBigContent, confirmStr, cancelStr);

	title = title or "提 示";
	infoStr = infoStr or "";
	title = GameString.convert2Platform(title);
	infoStr = GameString.convert2Platform(infoStr);

	view:setTitle( title);
	view:setContentText(infoStr);
	view:setLevel(10000);
	view:showWnd();
	return view;
end

PopuFrame.showNormalDialogForCenter = function(title, infoStr, node, posX, posY, isConfirm, isBigContent, confirmStr, cancelStr, noCloseBtn)
	if nil == isBigContent then -- 默认用大图
		isBigContent = true;
	end
	local view = new(PopuFrame, node, true, isConfirm, isBigContent, confirmStr, cancelStr, noCloseBtn);

	title = title or "提 示";
	infoStr = infoStr or "";
	title = GameString.convert2Platform(title);
	infoStr = GameString.convert2Platform(infoStr);

	view:setTitle(title);
	view:setContentText(infoStr);
	view:setLevel(10000);
	view:show();
	return view;
end

PopuFrame.showCustomDialog = function ( title, contentView, node, posX, posY, isConfirm, isBigContent, confirmStr, cancelStr )
	if nil == isBigContent then -- 默认用大图
		isBigContent = true;
	end
	if not contentView then
		return;
	end

	local view = new(PopuFrame, node,true, isConfirm, isBigContent, confirmStr, cancelStr);
	title = title or "提 示";
	infoStr = infoStr or "";
	title = GameString.convert2Platform(title);

	view:setTitle(title);
	view:setContent(contentView);

	view:setLevel(10000);
	view:showWnd();
	return view;
end
