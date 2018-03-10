SendAnim = class();

SendAnim.ctor = function( self, throwImage, parent, p1, p2, effectName, isScale )
	if not throwImage then
		return;
	end

	self.m_image = throwImage;
	self.m_p1 = publ_deepcopy( p1 );
	self.m_p2 = publ_deepcopy( p2 );
	self.m_parent = parent;
	self.m_effectName = effectName;
	self.m_isScale = isScale;

	--创建鸡蛋飞行路径
	self.m_targetCarve = {};
	if math.abs(p1.x-p2.x) <=100 then
		self.m_targetCarve = AnimCurve.createLineCurve(self.m_p1, self.m_p2, 50);
	else
		self.m_targetCarve = AnimCurve.createParabolaCurve(self.m_p1, self.m_p2, 200, 50);
	end

	self.m_target = UICreator.createImg( self.m_image );
	self.m_target:setVisible( false );
	self.m_parent:addChild( self.m_target );

	self.m_targetSize = {};
	local w,h = self.m_target:getSize();
	self.m_targetSize.width = w;
	self.m_targetSize.height = h;
end

SendAnim.dtor = function( self )
end

SendAnim.load = function( self )
end

SendAnim.getSize = function( self )
	return self.m_targetSize;
end

SendAnim.play = function( self )
	self.m_index = 1;
	self.m_speed = 50;

	self.m_throwAnim = self.m_target:addPropRotate(1,kAnimRepeat,20,0,0,0,kCenterDrawing);

	self.m_throwAnim:setEvent(nil, function()
		self.m_target:setVisible(true);
		self.m_target:setPos(self.m_targetCarve[self.m_index].x, self.m_targetCarve[self.m_index].y);

		self.m_index = self.m_index + 1;
		
		if self.m_index >= #self.m_targetCarve then
			self.m_index = 1;
			delete(self.m_target);
			self.m_target = nil;

			if self.m_onPlayFinishFunc and self.m_onPlayFinishObj then
				self.m_onPlayFinishFunc( self.m_onPlayFinishObj );
			end
		end

	end);

	GameEffect.getInstance():play(self.m_effectName);
end

SendAnim.setOnFinishListener = function( self, obj, func )
	self.m_onPlayFinishObj = obj;
	self.m_onPlayFinishFunc = func;
end
