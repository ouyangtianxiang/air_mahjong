-- 玩牌 查花猪动画
require("Animation/FriendsAnim/animCurve");
require("MahjongPinTu/playCardsAnimPin")




AnimationHuaZhu = class(Node);

function AnimationHuaZhu.ctor( self, p1)
	self.m_p1 = p1;
	self.isPlaying = false;

	self.manFrames    = {0,0,0,0,0,0,0,0,0,1,1,2,2,3,3,4,4,4,4,4,5,5,6,6,7,7,8,8,9,9,6,7,8,9,6,7,8,9};
	self.womanFrames  = {0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2,2,3,4,5,5,5,5,5,5};
	self.smogFrames   = {0,0,0,0,0,0,0,0,0,0,0,1,1,1,2,2,2,2,2,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3};
	self.wordFrames   = {0,0,0,0,0,0,0,1,1,1,2,2,2,3,3,3,2,2,2,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3};
	self.lightFrames  = {0,0,0,0,0,0,0,0,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1};

	self:load();
end

function AnimationHuaZhu.load( self )
	self.m_root = new(Node);
	self.m_root:setPos(self.m_p1[1], self.m_p1[2]);
	self.m_root:setSize(300, 265);
	 
	self:addChild(self.m_root)
	-- level:烟圈>女=男>字>背景光
	-- 男 10帧
	local dirs = {};
	for i=5,14 do
		table.insert(dirs, huaZhuPin_map[string.format("huazhu%d.png", i)]);
	end
	self.m_man = UICreator.createImages(dirs);
	self.m_root:addChild(self.m_man);
	self.m_man:setVisible(false);
	self.m_man:setLevel(304);
	self.m_man:setAlign(kAlignRight);
	-- self.m_man:setPos(self.m_p1[1], self.m_p1[2]);

	-- 女 6帧
	local dirs = {};
	for i=15,20 do
		table.insert(dirs, huaZhuPin_map[string.format("huazhu%d.png", i)]);
	end
	self.m_woman = UICreator.createImages(dirs);
	self.m_root:addChild(self.m_woman);
	self.m_woman:setVisible(false);
	self.m_woman:setLevel(304);
	self.m_woman:setAlign(kAlignLeft);
	-- self.m_woman:setPos(self.m_p1[1], self.m_p1[2]);

	-- 烟圈 4帧
	local dirs = {};
	for i=21,24 do
		table.insert(dirs, huaZhuPin_map[string.format("huazhu%d.png", i)]);
	end
	self.m_smog = UICreator.createImages(dirs);
	self.m_root:addChild(self.m_smog);
	self.m_smog:setVisible(false);
	self.m_smog:setLevel(305);
	self.m_smog:setAlign(kAlignLeft);
	-- self.m_smog:setPos(self.m_p1[1], self.m_p1[2]);

	-- 字 4帧
	local dirs = {};
	for i=1,4 do
		table.insert(dirs, huaZhuPin_map[string.format("huazhu%d.png", i)]);
	end
	self.m_word = UICreator.createImages(dirs);
	self.m_root:addChild(self.m_word);
	self.m_word:setVisible(false);
	self.m_word:setLevel(303);
	self.m_word:setAlign(kAlignTop);
	self.m_word:setPos(0, -50);

	-- 背景旋转光
	local dirs = {};
	for i=1,2 do
		table.insert(dirs, light_bg_map[string.format("light_%d.png", i)]);
	end
	self.m_light = UICreator.createImages(dirs);
	self.m_root:addChild(self.m_light);
	self.m_light:setVisible(false);
	self.m_light:setLevel(300);
	self.m_light:setAlign(kAlignTop);
	self.m_light:setSize(400,228)
	self.m_light:setPos(0, -85);
end

function AnimationHuaZhu.play( self )
	if self.isPlaying then
		return;
	end
	self.isPlaying = true;

	self:playManAnim();
	self:playWomanAnim();	
	self:playSmogAnim();
	self:playWordAnim();
	self:playLightAnim();
end

function  AnimationHuaZhu.playManAnim(self)
	if self.m_manAnim then
		delete(self.m_manAnim);
		self.m_manAnim = nil;
	end
	
	self.man_i = 1;
	self.m_manAnim = self.m_man:addPropTranslate(0, kAnimRepeat, 100, 0, 0, 0, 0, 0);
	self.m_manAnim:setEvent(self, self.showManOnTime);
	self.m_man:setVisible(false);
end

function  AnimationHuaZhu.playWomanAnim(self)
	if self.m_womanAnim then
		delete(self.m_womanAnim);
		self.m_womanAnim = nil;
	end
	
	self.woman_i = 1;
	self.m_womanAnim = self.m_woman:addPropTranslate(0, kAnimRepeat, 100, 0, 0, 0, 0, 0);
	self.m_womanAnim:setEvent(self, self.showWomanOnTime);
	self.m_woman:setVisible(false);
end

function  AnimationHuaZhu.playSmogAnim(self)
	if self.m_smogAnim then
		delete(self.m_smogAnim);
		self.m_smogAnim = nil;
	end
	
	self.smog_i = 1;
	self.m_smogAnim = self.m_smog:addPropTranslate(0, kAnimRepeat, 100, 0, 0, 0, 0, 0);
	self.m_smogAnim:setEvent(self, self.showSmogOnTime);
	self.m_smog:setVisible(false);
end



function  AnimationHuaZhu.playWordAnim(self)
	if self.m_wordAnim then
		delete(self.m_wordAnim);
		self.m_wordAnim = nil;
	end
	
	self.word_i = 1;
	self.m_wordAnim = self.m_word:addPropTranslate(0, kAnimRepeat, 100, 0, 0, 0, 0, 0);
	self.m_wordAnim:setEvent(self, self.showWordOnTime);
	self.m_word:setVisible(false);
end

function  AnimationHuaZhu.playLightAnim(self)
	if self.m_lightAnim then
		delete(self.m_lightAnim);
		self.m_lightAnim = nil;
	end
	
	self.light_i = 1;
	self.m_lightAnim = self.m_light:addPropTranslate(0, kAnimRepeat, 100, 0, 0, 0, 0, 0);
	self.m_lightAnim:setEvent(self, self.showLightOnTime);
	self.m_light:setVisible(false);
end


function AnimationHuaZhu.showManOnTime( self )
	if self.m_man.m_reses then
		if  self.man_i < 39  then
			self.m_man:setImageIndex(self.manFrames[self.man_i]);
			self.m_man:setVisible(true);
		else
			self.m_man:setVisible(false);
			self:stop();
		end
	else
		delete(self.m_man);
		self.m_man = nil;
		self:stop();
		return;
	end
	self.man_i = self.man_i + 1;
end

function AnimationHuaZhu.showWomanOnTime( self )
	if self.m_woman.m_reses then
		if self.woman_i > 11 and self.woman_i < 39  then
			self.m_woman:setImageIndex(self.womanFrames[self.woman_i]);
			self.m_woman:setVisible(true);
		else
			self.m_woman:setVisible(false);
		end
	else
		delete(self.m_woman);
		self.m_woman = nil;
		self:stop();
		return;
	end
	self.woman_i = self.woman_i + 1;
end

function AnimationHuaZhu.showSmogOnTime( self )
	if self.m_smog.m_reses then
		if self.smog_i > 9 and self.smog_i < 25  then
			self.m_smog:setImageIndex(self.smogFrames[self.smog_i]);
			self.m_smog:setVisible(true);
		else
			self.m_smog:setVisible(false);
		end
	else
		delete(self.m_smog);
		self.m_smog = nil;
		self:stop();
		return;
	end
	self.smog_i = self.smog_i + 1;
end



function AnimationHuaZhu.showWordOnTime( self )
	if self.m_word.m_reses then
		if self.word_i > 6 and self.word_i < 39  then
			self.m_word:setImageIndex(self.wordFrames[self.word_i]);
			self.m_word:setVisible(true);
		else
			self.m_word:setVisible(false);
		end
	else
		delete(self.m_word);
		self.m_word = nil;
		self:stop();
		return;
	end
	self.word_i = self.word_i + 1;
end


function AnimationHuaZhu.showLightOnTime( self )
	if self.m_light.m_reses then
		if self.light_i > 8 and self.light_i < 39  then
			self.m_light:setImageIndex(self.lightFrames[self.light_i]);
			self.m_light:setVisible(true);
		else
			self.m_light:setVisible(false);
		end
	else
		delete(self.m_light);
		self.m_light = nil;
		self:stop();
		return;
	end
	self.light_i = self.light_i + 1;
end

function AnimationHuaZhu.stop( self )
	self.isPlaying = false;
	delete(self);--self:dtor();
end


function AnimationHuaZhu.dtor( self )
	if self.m_man then
		delete(self.m_man);
		self.m_man = nil;
	end

	if self.m_woman then
		delete(self.m_woman);
		self.m_woman = nil;
	end

	if self.m_word then
		delete(self.m_word);
		self.m_word = nil;
	end

	if self.m_smog then
		delete(self.m_smog);
		self.m_smog = nil;
	end

	if self.m_root then
		delete(self.m_root);
		self.m_root = nil;
	end
end

