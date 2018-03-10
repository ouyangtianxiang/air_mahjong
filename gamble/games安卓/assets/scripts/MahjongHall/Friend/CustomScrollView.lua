require("ui/scrollView");

CustomScrollView = class(ScrollView,false);

CustomScrollView.ctor = function(self, x, y, w, h, autoPositionChildren)
	super(self,x, y, w, h, autoPositionChildren);

	self.mNodeHead = new (Node);
 	self.mNodeTail = new (Node);

	self.mNodeHead:setSize(w, 60);
	self.mNodeHead:setPos(0, -60);

	self.mNodeTail:setSize(w, 60);
	self.mNodeTail:setPos(0,  h);

	self.mImgHeadLoading = UICreator.createImg("Common/small_loading.png");
	self.mImgHeadLoading:setAlign(kAlignCenter);
	self.mNodeHead:addChild(self.mImgHeadLoading);
	self.mNodeHead:setName("cv_head");
	
	self.mImgTailLoading = UICreator.createImg("Common/small_loading.png");
	self.mImgTailLoading:setAlign(kAlignCenter);
	self.mNodeTail:addChild(self.mImgTailLoading);
	self.mNodeTail:setName("cv_tail");

	ScrollView.addChild(self, self.mNodeHead);
	ScrollView.addChild(self, self.mNodeTail);

	self.mHeadLoadingIsRotating = false;
	self.mTailLoadingIsRotating = false;

	self.onLoadingEvent = {};

	self.mHeadAction  = false;
	self.mTailAction  = false;

end

--设置 加载触发 的事件
CustomScrollView.setLoadingEvent = function ( self, obj, func )
	-- body
	self.onLoadingEvent.obj = obj;
	self.onLoadingEvent.func= func;
end
CustomScrollView.clearAll = function ( self )
	-- body
	local children = {};
	local child = self:getChildren();
	for k, v in pairs(child) do
		if v:getName() ~= "cv_head" and v:getName() ~= "cv_tail" then
			children[#children + 1] = v;
		end
	end

	for i = 1, #children do
		self:removeChild(children[i], true);
	end

	self:update();
end
CustomScrollView.update = function ( self )
	-- body
	local child = self:getChildren();
	local w, h = self:getSize();

	self.m_nodeH = h + 1;
	self.m_nodeW = w + 1;
	for k, v in pairs(child) do
		if v:getName() ~= "cv_head" and v:getName() ~= "cv_tail" then
			local x,y = v:getUnalignPos();
			local w,h = v:getSize();
			if self.m_direction == kVertical then
				self.m_nodeH = (self.m_nodeH > y + h) and self.m_nodeH or (y + h);
			else
				self.m_nodeW = (self.m_nodeW > x + w) and self.m_nodeW or (x + w);
			end
		end
	end


	if self.m_direction == kVertical then
		self.m_nodeH = math.max(self.m_nodeH, h);
	else
		self.m_nodeW = math.max(self.m_nodeW, w);
	end

	self.mNodeTail:setPos(0,  self.m_nodeH);

	local headW, headH	= self.mNodeHead:getSize(); -- 头和尾一样

	
	self.m_scroller:setReboundMargin(self.mTailLoadingIsRotating and headH or 0, self.mHeadLoadingIsRotating and headH or 0);

	ScrollView.update(self);

	self.m_scroller:setScrollCallback(self, CustomScrollView.onScroll);

end

CustomScrollView.setLoadingVisible = function ( self, bHead, visible)
	local head = true;
	local tail = true;

	if bHead ~= nil then
		head = bHead;
		tail = not bHead;
	end

	if head then
		self.mNodeHead:setVisible(visible);
	end

	if tail then
		self.mNodeTail:setVisible(visible);
	end
end

--关闭 加载界面
CustomScrollView.hideLoading = function ( self , bHead)
	-- body
	local head = true;
	local tail = true;

	if bHead ~= nil then
		head = bHead;
		tail = not bHead;
	end

	if head then
		if self.mHeadLoadingIsRotating then
			self:unsetNodeRatation(self.mImgHeadLoading);
			self.mHeadLoadingIsRotating = false;
		end
	end

	if tail then
		if self.mTailLoadingIsRotating then
		self:unsetNodeRatation(self.mImgTailLoading);
		self.mTailLoadingIsRotating = false;
		end
	end
	local headW, headH	= self.mNodeHead:getSize(); -- 头和尾一样
	if self.m_scroller then
		self.m_scroller:setReboundMargin(self.mTailLoadingIsRotating and headH or 0, self.mHeadLoadingIsRotating and headH or 0);
	end
	ScrollView.update(self);
end

CustomScrollView.setScollOffset = function ( self, offset )
	-- body
	self.m_mainNode:setPos(nil,offset);
	self.m_scrollBar:setScrollPos(offset);

	if self.m_scroller then
		self.m_scroller.m_offset = offset;
	end

end

-----------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------private-----------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------
CustomScrollView.onScroll = function(self, scroll_status, diffY, totalOffset,isMarginRebounding, finger_action)

	ScrollView.onScroll(self, scroll_status,diffY, totalOffset, isMarginRebounding);

	local w, h 			= self:getSize();
	local headW, headH	= self.mNodeHead:getSize();
	if finger_action == kFingerDown then
		self.mHeadAction  = false;
		self.mTailAction  = false;
	end
	--移动事件
	if scroll_status == kScrollerStatusMoving then
		if totalOffset > 0 then
			if totalOffset > headH and not self.mHeadLoadingIsRotating then
				self:setNodeAngle(self.mImgHeadLoading, (headH - totalOffset ) * 3);
			end
		elseif totalOffset + self.m_nodeH < h then

			if totalOffset + self.m_nodeH < h - headH and not self.mTailLoadingIsRotating then
				self:setNodeAngle(self.mImgTailLoading, (totalOffset + self.m_nodeH - h - headH) * 3);
			end

		end
	end

	if finger_action == kFingerUp and scroll_status == kScrollerStatusMoving then
		local headW, headH = self.mNodeHead:getSize();
		if totalOffset > headH and not self.mHeadLoadingIsRotating and self.mNodeHead:getVisible() then
			self.mHeadLoadingIsRotating = true;
			self:setNodeRatation(self.mImgHeadLoading);
			self.m_scroller:setReboundMargin(self.mTailLoadingIsRotating and headH or 0, self.mHeadLoadingIsRotating and headH or 0);
			
			self.mHeadAction  = true;
	
		elseif totalOffset + self.m_nodeH < h - headH and not self.mTailLoadingIsRotating and self.mNodeTail:getVisible()then
			self.mTailLoadingIsRotating = true;
			self:setNodeRatation(self.mImgTailLoading);
			self.m_scroller:setReboundMargin(self.mTailLoadingIsRotating and headH or 0, self.mHeadLoadingIsRotating and headH or 0);

			self.mTailAction = true;
		end
	end

	if  self.mHeadAction and math.abs(totalOffset - headH) < 1.5 then
		self.mHeadAction = false;
		if self.onLoadingEvent.func then
			self.onLoadingEvent.func(self.onLoadingEvent.obj, true);
		end
	elseif self.mTailAction and math.abs(self:getFrameLength() - self.m_nodeH - headH - totalOffset) < 1.5 then
		self.mTailAction = false;
		if self.onLoadingEvent.func then
			self.onLoadingEvent.func(self.onLoadingEvent.obj, false);
		end
	end
end


CustomScrollView.setNodeAngle = function(self, node, angle)
 	if not DrawingBase.checkAddProp(node,1) then 
		node:removeProp(1);
	end
	node:addPropRotateSolid(1,angle,kCenterDrawing,0,0);
end

CustomScrollView.setNodeRatation = function(self, node)
 	if not DrawingBase.checkAddProp(node,1) then 
		node:removeProp(1);
	end
	node:addPropRotate(1,kAnimRepeat,500,0,0,360,kCenterDrawing,0,0);
end

CustomScrollView.unsetNodeRatation = function(self, node)
	if not DrawingBase.checkAddProp(node,1) then 
		node:removeProp(1);
	end
end


