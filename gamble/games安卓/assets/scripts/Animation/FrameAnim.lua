FrameAnim = class(Node);

FrameAnim.ctor = function ( self, config, obj, finishListener )
	-- body

	self.m_obj = obj;
	self.m_finishListener = finishListener;

	self.m_frameCount = #config.imgDirs;
	self.m_roundTime  = config.roundTime;
	self.m_curFrame   = 1;
	self.m_frame 	  = {};

	for i = 1, self.m_frameCount do
		local frame = new(Image, config.imgDirs[i]);
		frame:setVisible(false);
		self:addChild(frame);
		self.m_frame[#self.m_frame + 1] = frame;

	end

	if self.m_frameCount > 0 then
		self.timeAinm = self:addPropTransparency(1, kAnimRepeat, self.m_roundTime/self.m_frameCount, 0, 1, 1);
		self.timeAinm:setDebugName("FrameAnim || anim");
		self.timeAinm:setEvent(self, FrameAnim.onTime);
		self.m_frame[1]:setVisible(true);
	end
end

FrameAnim.dtor = function ( self)
	DebugLog("FrameAnim dtor");
	self:removeAllChildren();
end

FrameAnim.onTime = function ( self )
	-- body
	self.m_frame[self.m_curFrame]:setVisible(false);
	--repeat mode
	self.m_curFrame = self.m_curFrame + 1;
	if self.m_curFrame > self.m_frameCount then

		if self.m_finishListener then
			self:removeProp(1);
			self.m_finishListener(self.m_obj);
			return;
		end
		
		self.m_curFrame = 1;
	end
	self.m_frame[self.m_curFrame]:setVisible(true);
end

