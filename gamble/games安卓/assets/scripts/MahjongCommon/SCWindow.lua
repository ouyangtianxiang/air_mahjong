-- filename: window.lua
-- author: OnlynightZhang
-- desp: 该类是所有窗口的父类，new_pop_wnd_mgr可通过父类控制各个窗口
require("MahjongCommon/CustomNode");
require("MahjongCommon/new_pop_wnd_mgr");
--local blurW = require('libEffect/shaders/blurWidget')

SCWindow = class(CustomNode);

-- private  动画数据
SCWindow.scaleData = {
	[1] = {
		seq         = 1,
		playTime    = 200,
		startScale  = 1.2,
		endScale    = 0.9,  
	},
	[2] = {
		seq         = 1,
		playTime    = 100,
		startScale  = 0.9,
		endScale    = 1.05,  
	},
	[3] = {
		seq         = 1,
		playTime    = 100,
		startScale  = 1.05,
		endScale    = 1,  
	},		
}


function SCWindow.ctor( self )
	DebugLog("SCWindow.ctor")

    
    self.m_b_invalid_back_event = false;--标记是否可以通过返回键弹出窗口，默认为false
	self.m_isNativeWindow = true; -- 标示该窗口是否是原生窗口
	self.m_window = nil; -- 布局上的window布局
	self.isPlaying = false; -- 是否播放窗口动画
	self.m_isAutoRemove = true; -- 自动从根结点移除当前窗口
	self.m_isCoverEnable = false; -- cover 是否可点击
	self:setVisible( false );
	self:setCoverEnable( self.m_isCoverEnable );-- 不允许点击cover

	self:setCoverTransparent()

   

	-- self.blurSprite,self.tex,self.texUnit = blurW.createBlurWidget(GameConstant.curGameSceneRef,{intensity = 2 })
	-- self:getWidget():add(self.blurSprite)
	-- local blurW = require("blurWidget")
	-- local blurSprite = blurW.createBlurWidget(GameConstant.curGameSceneRef,{intensity = 10})
	-- self:getWidget():add(blurSprite)  	
end

function SCWindow.dtor( self )
	DebugLog("SCWindow.dtor")
	-- self:getWidget():remove(self.blurSprite)
	-- blurW.removeBlur(self.blurSprite,self.tex,self.texUnit)
	-- self.blurSprite = nil 
	-- self.tex        = nil
	-- self.texUnit    = nil 


    back_event_manager.get_instance():remove_event(self);
    self:remove_wnd_from_pop_mgr();
end


--重写 node的 setvisible
--准确实时的加入back event 事件 关闭窗口
SCWindow.setVisible = function(self, b)
    Node.setVisible(self, b);
    if b == true then
        back_event_manager.get_instance():add_event(self,self.hideWnd);   
    end
end


SCWindow.get_playing_anim = function (self)
    return self.isPlaying;
end

SCWindow.set_playing_anim = function (self, b)
    self.isPlaying = b;
end


-- 设置cover是否能够点击--点击还是可以点击的，true和false标记是否隐藏window
function SCWindow.setCoverEnable( self, enable )
	self.m_isCoverEnable = enable;
	if not enable then
		self.cover:setEventTouch(self , function ( self )
			if self.m_isCoverEnable then
				self:hideWnd();
			end
			self:onCoverClick();
		end);
	else
		self.cover:setEventTouch(self , function ( self, finger_action, x, y, drawing_id_first, drawing_id_current )
			if finger_action == kFingerUp then
				if self.m_isCoverEnable then
					self:hideWnd();
				end
				self:onCoverClick();
			end
		end);
	end
end

-- 遮罩点击消息响应函数
function SCWindow.onCoverClick( self )
end

-- 设置窗口结点
function SCWindow.setWindowNode( self, wndNode )
	self.m_window = wndNode;
	self.m_window:setEventTouch(self , function ( self )
		-- TODO
	end);
end

-- 是否自动从根结点移除
function SCWindow.setAutoRemove( self, isAutoRemove )
	self.m_isAutoRemove = isAutoRemove;
end

-- 显示窗口
function SCWindow.showWnd( self )
    self:add_wnd_to_pop_mgr(true);
    --self:playShowAnim();
end

-- 隐藏窗口
function SCWindow.hideWnd( self, notHideAnim )
	if notHideAnim then 
		self:hideAnimOver()
	else
		self:playHideAnim();
	end
end

SCWindow.show = function ( self )
    self:add_wnd_to_pop_mgr(false);
	--CustomNode.show(self);
end

SCWindow.hide = function ( self )
	CustomNode.hide(self);
    self:remove_wnd_from_pop_mgr();
    back_event_manager.get_instance():remove_event(self);
end

--添加窗口到管理类
SCWindow.add_wnd_to_pop_mgr = function (self, b_show_wnd)
    local obj = {pop_index = self.m_pop_index, 
                t = new_pop_wnd_mgr.enum.normal, 
                b_play_anim = b_show_wnd, wnd = self}
    self.m_pop_index = new_pop_wnd_mgr.get_instance():add_window(obj);
end

SCWindow.remove_wnd_from_pop_mgr = function (self)
    new_pop_wnd_mgr.get_instance():remove_wnd_by_pop_index(self.m_pop_index);
    self.m_pop_index = nil;
end

SCWindow.set_pop_index = function (self, index)
    index = tonumber(index)
    if index then
        self.m_pop_index = index;
    end
end

SCWindow.clean_pop_index = function (self)
    self.m_pop_index = nil;
end



-- private
-- 全局调用窗口向上运动
function SCWindow.playHideAnim( self )
	if self.isPlaying or  not self.m_window then
		return;
	end

	self.isPlaying = true;

	local anim = self.m_window:addPropTransparency(0, kAnimNormal, 300, 0, 1, 0);
	if anim then 
		anim:setDebugName("SCWindow|hide|trans")
		anim:setEvent(self,function ( self )
			self.m_window:removeProp(0)
		end)
	end 

	local anim = self.m_window:addPropScale(1, kAnimNormal, 300, 0, 1, 1.1, 1, 1.1, kCenterDrawing)
	if anim then 
		anim:setDebugName("SCWindow|hide|scale")
		anim:setEvent(self, function(self)
			self.m_window:removeProp(1);
			self:hideAnimOver()
		end);
	else 
		self:hideAnimOver()
	end 
end

-- 全局调用窗口向下运动
function SCWindow.playShowAnim( self )
	DebugLog("Window.playShowAnim")
	if self.isPlaying or not self.m_window then
		return;
	end
	self:setVisible( true );
	self.isPlaying = true;

	local anim = self.m_window:addPropTransparency(0, kAnimNormal, 400, 0, 0.3, 1);
	if anim then 
		anim:setDebugName("SCWindow|show|trans")
		anim:setEvent(self,function ( self )
			self.m_window:removeProp(0)
		end)
	end 

	self:playScaleAnimStep(1)
end

function SCWindow.playScaleAnimStep( self,step )
	if not step or step < 1 or step > 3 then 
		self.m_window:removeProp(self.scaleData[3].seq)
		self:showAnimOver()
		return
	end 
	self.m_window:removeProp(self.scaleData[step].seq)
	local anim = self.m_window:addPropScale(self.scaleData[step].seq, 
														 kAnimNormal,
									   self.scaleData[step].playTime,
																   0,
									 self.scaleData[step].startScale,
									   self.scaleData[step].endScale,
									 self.scaleData[step].startScale,
									   self.scaleData[step].endScale,
									   				  kCenterDrawing)
	if anim then 
		anim:setDebugName("SCWindow|scale|step"..tostring(step))
		anim:setEvent(self,function ( self )
			self:playScaleAnimStep(step+1)
		end)
	else 
		self:showAnimOver()
	end 
end

function SCWindow.showAnimOver( self )
	DebugLog("Window.showAnimOver")
	self.isPlaying = false;
	self:onWindowShow();
end

function SCWindow.hideAnimOver( self )
	self.isPlaying = false;
	self:onWindowHide();
	self:setVisible( false );
	if self.m_isAutoRemove then
		self:removeFromSuper();
	end
    self:remove_wnd_from_pop_mgr();
    back_event_manager.get_instance():remove_event(self);
end


function SCWindow.showLoadingAnim( self )
	if self.m_window then 
		if not self.m_loadingSpr then 
			self.m_loadingSpr = new(Image, "Hall/chooseLevel/loading.png")
			self.m_window:addChild(self.m_loadingSpr)
			self.m_loadingSpr:setAlign(kAlignCenter)
			self.m_loadingSpr:setLevel(10000)

			self.m_loadingSpr:addPropRotate(0, kAnimRepeat, 1800, 0, 0, 360, kCenterDrawing);
		end 
		self.m_loadingSpr:setVisible(true) 		
	end 
end

function SCWindow.hideLoadingAnim( self )
	if self.m_window and self.m_loadingSpr then 
		self.m_loadingSpr:setVisible(false)
	end 
end



-- EVENT

-- event
-- 窗口显示回调
function SCWindow.onWindowShow( self )
	-- TODO
	if self.showCallbackFunc then
		self.showCallbackFunc( self.showCallbackObj );
	end
end

-- event
-- 窗口隐藏回调
function SCWindow.onWindowHide( self )
	-- TODO
	if self.hideCallbackFunc then
		self.hideCallbackFunc( self.hideCallbackObj );
	end
end

function SCWindow.setOnWindowHideListener( self, obj, func )
	self.hideCallbackFunc = func;
	self.hideCallbackObj = obj;
end

function SCWindow.setOnWindowShowListener( self, obj, func )
	self.showCallbackFunc = func;
	self.showCallbackObj = obj;
end




