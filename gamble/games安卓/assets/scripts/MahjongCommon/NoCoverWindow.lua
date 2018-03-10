-- filename: window.lua
-- author: OnlynightZhang
-- desp: 该类是所有窗口的父类
require("MahjongCommon/NoCoverCustomNode");

NoCoverWindow = class(NoCoverCustomNode);

function NoCoverWindow.ctor( self )
	self.m_isNativeWindow = true; -- 标示该窗口是否是原生窗口
	self.m_window = nil; -- 布局上的window布局
	self.isPlaying = false; -- 是否播放窗口动画
	self.m_isAutoRemove = true; -- 自动从根结点移除当前窗口
	self:setVisible( false );
end

function NoCoverWindow.dtor( self )
end

-- 遮罩点击消息响应函数
function NoCoverWindow.onCoverClick( self )
end

-- 设置窗口结点
function NoCoverWindow.setWindowNode( self, wndNode )
	self.m_window = wndNode;
	self.m_window:setEventTouch(self , function ( self )
		-- TODO
	end);
end

-- 是否自动从根结点移除
function NoCoverWindow.setAutoRemove( self, isAutoRemove )
	self.m_isAutoRemove = isAutoRemove;
end

-- 显示窗口
function NoCoverWindow.showWnd( self )
	self.playShowAnim( self );
end

-- 隐藏窗口
function NoCoverWindow.hideWnd( self )
	self.playHideAnim( self );
end

-- private
-- 全局调用窗口向上运动
function NoCoverWindow.playHideAnim( self )
	if self.isPlaying then
		return;
	end

	self.isPlaying = true;
	local window_w , window_h = self.m_window:getSize();
	local window_x , window_y = self.m_window:getPos();

	if window_y == 0 then
		window_y = ( SCREEN_HEIGHT - window_h )/2;
	end

	local anim = self.m_window:addPropTranslate(2, kAnimNormal, 200, 0, 0, 0, 0, -(window_h + window_y));
	anim:setEvent(self, function()
		self.m_window:removeProp(2);
		self.isPlaying = false;
		self:onWindowHide();
		self:setVisible( false );
		if self.m_isAutoRemove then
			self:removeFromSuper();
		end
	end);
end

-- private
-- 全局调用窗口向下运动
function NoCoverWindow.playShowAnim( self )
	if self.isPlaying then
		return;
	end
	self:setVisible( true );
	self.isPlaying = true;
	local window_w , window_h = self.m_window:getSize();
	local window_x , window_y = self.m_window:getPos();
	
	if window_y == 0 then
		window_y = ( SCREEN_HEIGHT - window_h )/2;
	end

	local anim = self.m_window:addPropTranslate(1, kAnimNormal, 200, 100, 0, 0, -(window_h + window_y), 0);
	anim:setEvent(self, function()
		self.m_window:removeProp(1);
		self.isPlaying = false;
		self:onWindowShow();
	end);
end



-- EVENT

-- event
-- 窗口显示回调
function NoCoverWindow.onWindowShow( self )
	-- TODO
	if self.showCallbackFunc then
		self.showCallbackFunc( self.showCallbackObj );
	end
end

-- event
-- 窗口隐藏回调
function NoCoverWindow.onWindowHide( self )
	-- TODO
	if self.hideCallbackFunc then
		self.hideCallbackFunc( self.hideCallbackObj );
	end
end

function NoCoverWindow.setOnWindowHideListener( self, obj, func )
	self.hideCallbackFunc = func;
	self.hideCallbackObj = obj;
end

function NoCoverWindow.setOnWindowShowListener( self, obj, func )
	self.showCallbackFunc = func;
	self.showCallbackObj = obj;
end
