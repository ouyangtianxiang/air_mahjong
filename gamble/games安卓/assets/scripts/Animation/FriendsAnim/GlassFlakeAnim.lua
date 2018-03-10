GlassFlakeAnim = class();

GlassFlakeAnim.ctor = function( self, imageSrc, parent )
	self.m_parent = parent;
	self.m_arryPos = {};

	self.m_starsEndPos = {};
	for i=1,7 do
		self.m_starsEndPos[i] = {};
	end
	self.m_starsEndPos[1].x = -90;
	self.m_starsEndPos[1].y = 0;
	self.m_starsEndPos[2].x = -60;
	self.m_starsEndPos[2].y = 80;
	self.m_starsEndPos[3].x = -70;
	self.m_starsEndPos[3].y = -50;
	
	self.m_starsEndPos[4].x = 0;
	self.m_starsEndPos[4].y = -110;

	self.m_starsEndPos[5].x = 80;
	self.m_starsEndPos[5].y = 10;
	self.m_starsEndPos[6].x = 80;
	self.m_starsEndPos[6].y = 100;
	self.m_starsEndPos[7].x = 90;
	self.m_starsEndPos[7].y = 40;
	for i=1,7 do
		self.m_arryPos[i] = {};
		self.m_arryPos[i].pos = AnimCurve.createLineCurve({x=0,y=0} ,self.m_starsEndPos[i], 10);
	end

	self.m_glassFlake = {};
	mahjongPrint( imageSrc );
	for i=1,7 do
		self.m_glassFlake[i] = UICreator.createImg( imageSrc );
		self.m_parent:addChild(self.m_glassFlake[i]);
		self.m_glassFlake[i]:setAlign(kAlignCenter);
		self.m_glassFlake[i]:setVisible(false);
	end
end

GlassFlakeAnim.play = function( self )
	for i=1,7 do
		self.m_glassFlake[i]:setVisible(true);
	end
	DebugLog( "GlassFlakeAnim.play" );

	self.m_glassFlakeAnim = new(EaseMotion, kCCEaseOut, 20, 200, 0);
	self.m_glassFlakeAnim:setDebugName("AnimationThrowRock--self.m_glassFlakeAnim")
	self.m_glassFlakeIndex = 1;
	self.m_glassFlakeAnim:setEvent(nil, function()
		-- 更新坐标
		for i=1,7 do
			self.m_arryPos[i].pos[self.m_glassFlakeIndex].x = self.m_arryPos[i].pos[self.m_glassFlakeIndex].x 
				+ math.random(10,20)*self.m_glassFlakeAnim.m_process;
			self.m_glassFlake[i]:setPos(self.m_arryPos[i].pos[self.m_glassFlakeIndex].x, self.m_arryPos[i].pos[self.m_glassFlakeIndex].y);
		end
		self.m_glassFlakeIndex = self.m_glassFlakeIndex + 1;

		if self.m_glassFlakeIndex >= #(self.m_arryPos[1].pos) then
			self.m_glassFlakeIndex = #(self.m_arryPos[1].pos);
			delete(self.m_glassFlakeAnim);
			self.m_glassFlakeAnim = nil;
		end
	end);
end