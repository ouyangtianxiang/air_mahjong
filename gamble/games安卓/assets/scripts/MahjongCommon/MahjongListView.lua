
-- majong定制listView
MahjongListView = class(ListView);


MahjongListView.onEventDrag =  function(self, finger_action, x, y, drawing_id_first, drawing_id_current)
	if TableView.hasScroller(self) then 
		self.m_scroller:onEventTouch(finger_action,x,y,drawing_id_first,drawing_id_current);
	end

	if finger_action == kFingerDown then
		self.m_startX = x;
		self.m_startY = y;
		local localX,localY = TableView.convertSurfacePointToView(self,x,y);
		local view,index = TableView.getCurTouchViewAndIndex(self,localX,localY);
		if view then
			view.bg:setVisible(true);
			view.bg:revisePos(); -- 在一个drawing隐藏的时候，移动父节点，子节点的位置不会计算，所以显示的时候要调用一次 revisePos
			for k,v in pairs(self.m_views) do
				if v ~= view then
					v.bg:setVisible(false);
				end
			end
		end
		
	elseif finger_action ~= kFingerMove then
		if 	math.abs(y-self.m_startY) < self.m_maxClickOffset 
			and math.abs(x-self.m_startX) < self.m_maxClickOffset then

			if self.m_itemEventCallback.func then
			    local localX,localY = TableView.convertSurfacePointToView(self,x,y);
				local view,index = TableView.getCurTouchViewAndIndex(self,localX,localY);

				if view then 
					self.m_itemEventCallback.func(self.m_itemEventCallback.obj,self.m_adapter,view,index);
				end
			end
		end
	end
end

