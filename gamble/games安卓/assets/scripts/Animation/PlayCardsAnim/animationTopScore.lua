-- 结算 历史最高动画

AnimationTopScore = class(Node);

function AnimationTopScore.ctor( self, p1, root)
	self.m_p1 = p1;
	self.isPlaying = false;
	self.m_node = root;

	self:load();
end

function AnimationTopScore.load( self )
	self.m_root = new(Node);
	self.m_root:setPos(self.m_p1[1], self.m_p1[2]);
	self.m_root:setSize(65,156);
	-- self.m_root:addToRoot(); -- debug
	self.m_node:addChild(self.m_root);

	-- 印章
	self.m_seal = UICreator.createImg("Room/result/top.png");
	self.m_root:addChild(self.m_seal);
	self.m_seal:setVisible(false);


end

function AnimationTopScore.play( self )
	if self.isPlaying then
		return;
	end
	self.isPlaying = true;

	self:playSealAnim();
end


function AnimationTopScore.playSealAnim( self )
	if self.sealAnim then
   		delete(self.sealAnim);
		self.sealAnim = nil;
   	end

	self.sealAnim = self.m_seal:addPropScale(0, kAnimNormal, 700, 0, 2.4, 1.2, 2.4, 1.2, kCenterDrawing);
	self.sealAnim:setDebugName("AnimationTopScore || self.sealAnim");
	self.m_seal:setVisible(true);
	self.sealAnim:setEvent();
end

function AnimationTopScore.stop( self )
	self.isPlaying = false;
	self:dtor();
end


function AnimationTopScore.dtor( self )
	if self.m_seal then
		delete(self.m_seal);
		self.m_seal = nil;
	end

	if self.m_root then
		delete(self.m_root);
		self.m_root = nil;
	end
	self = nil;

end


