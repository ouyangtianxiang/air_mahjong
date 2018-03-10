-- 
-- 
-- 

EndEffectAnim = class();

EndEffectAnim.ctor = function( self, targetImages, parent, pos, startSize, stopFrame, isEnd )
	self.m_images = targetImages;
	self.m_parent = parent;
	self.m_pos = pos;
	self.m_num = #targetImages;
	self.m_startSize = startSize;
	self.m_stopFrame = stopFrame;
	self.m_isEnd = isEnd;

	self:load();
end

EndEffectAnim.getTarget = function( self )
	return self.m_targets;
end

EndEffectAnim.dtor = function( self )
end

EndEffectAnim.load = function( self )
	self.m_targets = UICreator.createImages(self.m_images);
	if self.m_parent then 
		self.m_parent:addChild( self.m_targets );
	end 
	self.m_targets:setVisible( false );
	local gW, gH = self.m_targets:getSize();
	self.m_targets:setPos(self.m_pos.x - gW/2 + self.m_startSize.width/2 , self.m_pos.y - gH/2 + self.m_startSize.height/2 );
end

EndEffectAnim.play = function( self )
	self.m_targetsIndex = 0;
	self.m_targetsAnim = self.m_targets:addPropRotate(1,kAnimRepeat,120,0,0,0,kCenterDrawing);
	self.m_targetsAnim:setDebugName("EndEffectAnim.m_targetsAnim");
	self.m_targetsAnim:setEvent(self, self.showTargetsOnTime);
end

EndEffectAnim.showTargetsOnTime = function( self )
	if self.m_num <= 0 then
		delete( self.m_targetsAnim );
		self.m_targetsAnim = nil;
		return;
	end

	if self.m_targets.m_reses then
		local index = self.m_targetsIndex;
		if index == self.m_num + 1 then
			self.m_targets:addPropTransparency(2, kAnimNormal, 0, 100, 1, 0);
		elseif index <= self.m_num then
			self.m_targets:setImageIndex(index);
			self.m_targets:setVisible(true);
		end
	else
		delete(self.m_targets);
		self.m_targets = nil;
		self:finishCallback();
		return;
	end

	self.m_targetsIndex = self.m_targetsIndex + 1;
	if self.m_targetsIndex > self.m_stopFrame then
		delete(self.m_targets);
		self.m_targets = nil;
		self:finishCallback();
	end
end

EndEffectAnim.finishCallback = function( self )
	if self.onFinishFunc and self.onFinishObj and self.m_isEnd then
		self.onFinishFunc( self.onFinishObj );
	end
end

EndEffectAnim.setOnFinishListener = function( self, obj, func )
	self.onFinishObj = obj;
	self.onFinishFunc = func;
end
