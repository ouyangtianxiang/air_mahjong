ThrowAnim = class();

ThrowAnim.ctor = function( self, throwImage, parent, p1, p2, effectName, arcHeight, trackPointNum, isRotate )
	if not throwImage then
		return;
	end

	self.m_image = throwImage;
	self.m_p1 = publ_deepcopy( p1 );
	self.m_p2 = publ_deepcopy( p2 );
	self.m_parent = parent;
	self.m_effectName = effectName;
	self.m_arcHeight = arcHeight or 30;
	self.m_trackPointNum = trackPointNum or 35;
	self.m_isRotate = isRotate;

	--创建鸡蛋飞行路径
	self.m_targetCarve = {};
	if math.abs(p1.x-p2.x) <=100 then
		self.m_rotateFlag = true;
		self.m_p2.y = self.m_p2.y - 33;
		self.m_p2.x = self.m_p2.x + 20 ;
		self.m_targetCarve = AnimCurve.createLineCurve(self.m_p1, self.m_p2, self.m_trackPointNum);
	else
		self.m_targetCarve = AnimCurve.createParabolaCurve(self.m_p1, self.m_p2, self.m_arcHeight, self.m_trackPointNum);
	end

	self.m_target = UICreator.createImg( self.m_image );
	self.m_target:setVisible( false );
	self.m_parent:addChild( self.m_target );
end

ThrowAnim.dtor = function( self )
end

ThrowAnim.load = function( self )
end

ThrowAnim.getSize = function( self )
	local w,h = self.m_target:getSize();
	local temp = {};
	temp.width = w;
	temp.height = h;
	return temp;
end

ThrowAnim.play = function( self )
	self.m_index = 1;
	self.m_speed = 50;
	self.m_angle = 15;
	self.m_curAngle = 0;

	self.m_throwAnim = new(EaseMotion, kEaseOut, 5, 200, 0);
	self.m_throwAnim:setEvent( self, function( self )
		self.m_target:setVisible( true );

		if self.m_rotateFlag then
			self.m_targetCarve[self.m_index].y = self.m_targetCarve[self.m_index].y + self.m_speed*self.m_throwAnim.m_process;
		else
			self.m_targetCarve[self.m_index].x = self.m_targetCarve[self.m_index].x + self.m_speed*self.m_throwAnim.m_process;
		end
		self.m_target:setPos(self.m_targetCarve[self.m_index].x, self.m_targetCarve[self.m_index].y);
		self.m_index = self.m_index + 1;
		self.m_curAngle = self.m_curAngle + self.m_angle;
		if self.m_isRotate then
			self.m_target:setRotate( self.m_curAngle );
		end
		
		if self.m_index >= #self.m_targetCarve then
			self.m_index = 1;
			self.m_target:setVisible(false);
			delete(self.m_throwAnim);
			self.m_throwAnim = nil;

			if self.m_onPlayFinishFunc and self.m_onPlayFinishObj then
				self.m_onPlayFinishFunc( self.m_onPlayFinishObj );
			end
		end

	end);

	GameEffect.getInstance():play(self.m_effectName);
end

ThrowAnim.setOnFinishListener = function( self, obj, func )
	self.m_onPlayFinishObj = obj;
	self.m_onPlayFinishFunc = func;
end
