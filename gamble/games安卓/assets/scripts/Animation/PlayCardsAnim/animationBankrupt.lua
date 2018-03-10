-- 玩牌 破产动画
require("MahjongPinTu/playCardsAnimPin")



AnimationBankrupt = class(Node);

function AnimationBankrupt.ctor( self, p1, root)
	self.m_p1 = p1;
	self.isPlaying = false;
	self.m_node = root;

	self.m_node:addChild(self);

	self.wordFrames       = {0,0,0,0,0,0,0,0,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7,8,8,9,9};
	self.lightningFrames  = {0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,1,1,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};

	self:load();
end

function AnimationBankrupt.load( self )
	self.m_root = new(Node);
	self.m_root:setPos(self.m_p1[1]-120, self.m_p1[2]-100);
	self.m_root:setSize(300, 500);
	self:addChild(self.m_root);

	-- level:闪电>字
	-- 字 8帧
	local dirs = {};
	for i = 1, 10 do
		table.insert(dirs, bankruptPin_map[string.format("bankrupt%d.png", i)]);
	end
	self.m_word = UICreator.createImages(dirs);
	self.m_root:addChild(self.m_word);
	self.m_word:setVisible(false);
	self.m_word:setLevel(300);
	self.m_word:setAlign(kAlignCenter);
	self.m_word:setPos(0, -50);

	-- 闪电 4帧
	local dirs = {};
	for i=11,12 do
		table.insert(dirs, bankruptPin_map[string.format("bankrupt%d.png", i)]);
	end
	self.m_lightning = UICreator.createImages(dirs);
	self.m_root:addChild(self.m_lightning);
	self.m_lightning:setVisible(false);
	self.m_lightning:setLevel(301);
	self.m_lightning:setAlign(kAlignTop);
end

function AnimationBankrupt.play( self )
	if self.isPlaying then
		return;
	end
	self.isPlaying = true;
	self:playWordAnim();
	self:playLightningAnim();
end

function AnimationBankrupt.playWordAnim( self )
	if self.m_wordAnim then
		delete(self.m_wordAnim);
		self.m_wordAnim = nil;
	end

	self.word_i = 1;
	self.m_wordAnim = self.m_word:addPropTranslate(0, kAnimRepeat, 50, 0, 0, 0, 0, 0);
	self.m_wordAnim:setEvent(self, self.showWordOnTime);
	self.m_word:setVisible(false);
end

function AnimationBankrupt.playLightningAnim( self )
	if self.m_lightningAnim then
		delete(self.m_lightningAnim);
		self.m_lightningAnim = nil;
	end

	self.lightning_i = 1;
	self.m_lightningAnim = self.m_lightning:addPropTranslate(0, kAnimRepeat, 50, 0, 0, 0, 0, 0);
	self.m_lightningAnim:setEvent(self, self.showLightningOnTime);
	self.m_lightning:setVisible(false);
end

function  AnimationBankrupt.showWordOnTime(self)
	if self.m_word.m_reses then
		if self.word_i < 41 then
			self.m_word:setImageIndex(self.wordFrames[self.word_i]);
			self.m_word:setVisible(true);
		else
			self.m_word:setVisible(false);
			self:stop();
		end
	else
		delete(self.m_word);
		self.m_word = nil;
		self:stop();
	end
	self.word_i = self.word_i + 1;
end

function  AnimationBankrupt.showLightningOnTime(self)
	if self.m_lightning.m_reses then
		if self.lightning_i > 10 and self.lightning_i < 25 then
			self.m_lightning:setImageIndex(self.lightningFrames[self.lightning_i]);
			self.m_lightning:setVisible(true);
		else
			self.m_lightning:setVisible(false);
		end
	else
		delete(self.m_lightning);
		self.m_lightning = nil;
		self:stop();
	end
	self.lightning_i = self.lightning_i + 1;
end

function AnimationBankrupt.stop( self )
	self.isPlaying = false;
	self:dtor();
end

function AnimationBankrupt.dtor( self )
	DebugLog("AnimationBankrupt dtor");
	if self.m_word then
		delete(self.m_word);
		self.m_word = nil;
	end

	if m_lightning then
		delete(m_lightning);
		m_lightning = nil;
	end

	if self.m_root then
		delete(self.m_root);
		self.m_root = nil;
	end
	self = nil;
end

