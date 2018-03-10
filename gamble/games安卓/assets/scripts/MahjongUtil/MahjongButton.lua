require("ui/button");

MahjongButton = class(Button, false)

MahjongButton.ctor = function ( self, normalFile, disableFile, fmt, filter, leftWidth, rightWidth, topWidth, bottomWidth )
	super(self, normalFile, disableFile, fmt, filter, leftWidth, rightWidth, topWidth, bottomWidth);
	self.actionOffset = 5; -- 响应按键的偏移范围
	self.dir = kVertical; -- 方向 默认垂直，另一个类型：kHorizontal（水平）
	self.clickOffsetY = 0;
	self.clickOffsetX = 0;
end

--virtual
MahjongButton.onClick = function(self, finger_action, x, y, drawing_id_first, drawing_id_current)
	if not self.m_enable then
		return;
	end
	
	if finger_action == kFingerDown then
		GameEffect.getInstance():play("BUTTON_CLICK");
	    self.m_showEnbaleFunc(self,false);
	    if self.dir == kVertical then
	    	self.clickOffsetY = y;
	    else
	    	self.clickOffsetX = x;
	    end
	elseif finger_action == kFingerMove then
		if not (self.m_responseType == kButtonUpInside and drawing_id_first ~= drawing_id_current) then
			self.m_showEnbaleFunc(self,false);
		else
			self.m_showEnbaleFunc(self,true);
		end
	elseif finger_action == kFingerUp then
		self.m_showEnbaleFunc(self,true);

		if self.dir == kVertical then
			if math.abs(y - self.clickOffsetY) > self.actionOffset then
	    		return;
	    	end
	    elseif math.abs(x - self.clickOffsetX) > self.actionOffset then
	    	return;
	    end
		
		local responseCallback = function()
			if self.m_eventCallback.func then
                self.m_eventCallback.func(self.m_eventCallback.obj,finger_action,x,y,
                	drawing_id_first,drawing_id_current);
            end	
		end

		if self.m_responseType == kButtonUpInside then
			if drawing_id_first == drawing_id_current then
				responseCallback();
			end
	    elseif self.m_responseType == kButtonUpOutside then
	    	if drawing_id_first ~= drawing_id_current then
				responseCallback();
			end
		else
			responseCallback();
		end
	elseif finger_action==kFingerCancel then
		self.m_showEnbaleFunc(self,true);
	end
end

MahjongButton.dtor = function ( self )
	self:removeAllChildren();
end

