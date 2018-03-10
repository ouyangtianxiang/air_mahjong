
local matchSmallPopWindow = require(ViewLuaPath.."matchSmallPopWindow");
require("MahjongCommon/CustomNode");

MatchSmallPopuFrame = class(SCWindow);

MatchSmallPopuFrame.ctor = function(self, titleContent, Content, partent)
    self.window = SceneLoader.load(matchSmallPopWindow);
	self:addChild(self.window);

    if parent then
		parent:addChild(self);
	else
		self:addToRoot();
	end

    self.img_win_bg = publ_getItemFromTree(self.window, {"img_win_bg"});
    self:setWindowNode( self.img_win_bg );

    --设置滑动条大小
	publ_getItemFromTree(self.window,{"img_win_bg","img_win_inner_bg", "sv_content"}):setScrollBarWidth(5);

    --确定 取消 事件
	local btncancel  = publ_getItemFromTree(self.window,{"img_win_bg","btn_left"});
	local btnComfirm = publ_getItemFromTree(self.window,{"img_win_bg","btn_right"});
	btncancel:setVisible(true);
	btnComfirm:setVisible(true);
	--publ_getItemFromTree(btncancel,{"text_name"}):setText(cancelStr or "取   消");
	--publ_getItemFromTree(btnComfirm,{"text_name"}):setText(confirmStr or "确   定");
	
	if PlatformConfig.platformWDJ == GameConstant.platformType or
	   PlatformConfig.platformWDJNet == GameConstant.platformType then  
        self.img_win_bg:setFile("Login/wdj/Hall/Commonx/pop_window_small.png");
    end
			
	btncancel:setOnClick(self, function ( self )
		self.hideHandleObj = self.cancelObj;
		self.hideHandleFun = self.cancelFun;
		self:hideWnd();
	end);

	btnComfirm:setOnClick(self, function ( self )
		if self.confirmFun then
			self.confirmFun(self.confirmObj);
		end
		self:hideWnd();
	end);
end


MatchSmallPopuFrame.dtor = function (self)
	DebugLog("PopuFrame dtor");
	self:removeAllChildren();
end

MatchSmallPopuFrame.show = function ( self )
	self:showWnd();
end

-- 设置确定按钮回调函数
MatchSmallPopuFrame.setConfirmCallback = function ( self, obj, fun )
	self.confirmObj = obj;
	self.confirmFun = fun;
end

-- 设置取消按钮回调函数
MatchSmallPopuFrame.setCancelCallback = function ( self, obj, fun )
	self.cancelObj = obj;
	self.cancelFun = fun;
end

function MatchSmallPopuFrame.onWindowHide( self )
	if hideHandleObj and self.hideHandleFunc then
		self.hideHandleFunc( self.hideHandleObj );
	end 
end

--设置标题
MatchSmallPopuFrame.setTitle = function ( self, title )
	publ_getItemFromTree(self.window,{"img_win_bg","view_title", "text_title"}):setText(title);
end
--设置内容
MatchSmallPopuFrame.setContent = function ( self, node )
	publ_getItemFromTree(self.window,{"img_win_bg","img_win_inner_bg","sv_content"}):addChild(node);
end

MatchSmallPopuFrame.setContentText = function ( self, text )
	
	local nodeContent = publ_getItemFromTree(self.window,{"img_win_bg","img_win_inner_bg","sv_content"});
	local nodeW, nodeH= nodeContent:getSize();
	local textContent = new(TextView, text, nodeW, nodeH,kAlignTopLeft, "", 30,  255,  220, 190);
	nodeContent:addChild(textContent);
end

MatchSmallPopuFrame.showNormalDialog = function (title, content, partent)
	local view = new(MatchSmallPopuFrame, title, content, partent);

	title = title or "提 示";
    local infoStr = content or "";
	title = GameString.convert2Platform(title);
	infoStr = GameString.convert2Platform(infoStr);

	view:setTitle( title);
	view:setContentText(infoStr);
	view:setLevel(10000);
	view:show();
	return view;
end

MatchSmallPopuFrame.hide = function ( self )
	self:dtor();
end