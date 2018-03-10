-- 玩牌 碰动画
require("Animation/FriendsAnim/animCurve");
require("MahjongPinTu/playCardsAnimPin")



AnimationPeng = class(Node);

function AnimationPeng.ctor( self, p1)
	self.m_p1 = p1;
	self.isPlaying = false;
	
	self:load();
end

function AnimationPeng.load( self )
	self.m_root = new(Node);
	 
	self:addChild(self.m_root)
	-- 人 6帧, 字 7帧
	local dirs = {};
	for i=1, 13 do
		table.insert(dirs, pengPin_map[string.format("peng%d.png", i)]);
	end
	self.m_peng = UICreator.createImages(dirs);
	self.m_root:addChild(self.m_peng);
	self.m_peng:setVisible(false);
	self.m_peng:setPos(self.m_p1[1], self.m_p1[2]);

end

function AnimationPeng.play( self )
	if self.isPlaying then
		return;
	end
	self.isPlaying = true;
	self:playPengAnim();
end


function  AnimationPeng.playPengAnim(self)
	if self.m_pengAnim then
		delete(self.m_pengAnim);
		self.m_pengAnim = nil;
	end
	
	self.pengIndex = 0;
	self.m_pengAnim = self.m_peng:addPropTranslate(0, kAnimRepeat, 150, 0, 0, 0, 0, 0);
	self.m_pengAnim:setEvent(self, self.showPengOnTime);
	self.m_pengAnim:setDebugName("AnimationPeng.playPengAnim");
	self.m_peng:setVisible(false);
end

function AnimationPeng.showPengOnTime( self )
	if self.m_peng.m_reses then
		local index = self.pengIndex;
		if index > 12 then
			index = 12;
			self.m_peng:setVisible(false);
		else
			self.m_peng:setImageIndex(index);
			self.m_peng:setVisible(true);
		end
	else
		delete(self.m_peng);
		self.m_peng = nil;
		self:stop();
		return;
	end
	self.pengIndex = self.pengIndex + 1;
	if self.pengIndex > 14 then
		delete(self.m_peng);
		self.m_peng = nil;
	end
end

function AnimationPeng.stop( self )
	self.isPlaying = false;
	delete(self);--self:dtor();
end


function AnimationPeng.dtor( self )
	if self.m_people then
		delete(self.m_people);
		self.m_people = nil;
	end

	if self.m_peng then
		delete(self.m_peng);
		self.m_peng = nil;
	end

	if self.m_root then
		delete(self.m_root);
		self.m_root = nil;
	end
end

