UnautoBanner = class(Node);

UnautoBanner.instance = nil;
UnautoBanner.getInstance = function ()
	if not UnautoBanner.instance then
		UnautoBanner.instance = new(UnautoBanner);
	end
	return UnautoBanner.instance;
end

UnautoBanner.ctor = function ( self )
	self:setLevel(9999);
  	self.m_width = 1017;
  	self.m_height = 105;
  	self:setAlign(kAlignTop);
 	self.m_tips_bg = new(Image,"banner_bg.png");
 	self.m_tips_bg:setAlign(kAlignTop);
	self:addChild(self.m_tips_bg);
  	self.contentArea = new(Node);
	self:addChild(self.contentArea);
	self.contentArea:setSize(900 , 105);
	self.contentArea:setPos(90 , 0);
	self.contentArea:setClip(90 , 0 , 900 , 105);
	self:addToRoot();
end

UnautoBanner.showMsg = function ( self, msg )
	self:setVisible(true);
	if self.m_msg then
		self.contentArea:removeChild(self.m_msg, true);
		self.m_msg = nil;
	end
	self.m_msg = UICreator.createText(msg, 0, -3, 900, 105, kAlignCenter, 34, 0, 0, 0);
	self.m_msg:setAlign(kAlignCenter);
	self.contentArea:addChild(self.m_msg);
end

UnautoBanner.hide = function ( self )
	if m_msg then
		self.m_msg:setText("");
		if self.m_msg then
			self.contentArea:removeChild(self.m_msg, true);
			self.m_msg = nil;
		end
	end
	self:setVisible(false);
end

UnautoBanner.dtor = function ( self )
	self:removeAllChildren();
end

