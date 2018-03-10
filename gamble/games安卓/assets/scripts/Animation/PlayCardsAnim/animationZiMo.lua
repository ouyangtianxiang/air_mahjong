-- 玩牌 自摸动画
require("Animation/FriendsAnim/animCurve");
require("MahjongPinTu/playCardsAnimPin")



AnimationZiMo = class(Node);

function AnimationZiMo.ctor( self, p1, obj, callback)
	self.m_p1 = p1;
	self.isPlaying = false;

	self.obj = obj;
	self.callback = callback;

	self.peopleFrames = {0,1,2,3,4,5,6,7,1,2,3,4,5,6,7,0,1,2,3,4,5,6,7,0,1,2,3};
	self.wordFrames   = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,2,2,3,3,3,3,3,3,3,3};
	self.lightFrames  = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,1,0,1,0,1,0,1,0,1,0};

	self:load();
end

function AnimationZiMo.load( self )
	self.m_root = new(Node);
	self.m_root:setPos(self.m_p1[1], self.m_p1[2]);
	self.m_root:setSize(300, 500);
	 
	self:addChild(self.m_root)
	-- level:人>字>背景光
	-- 人物 8帧
	local dirs = {};
	for i = 1, 8 do
		table.insert(dirs, ziMoPin_map[string.format("zimo%d.png", i)]);
	end
	self.m_people = UICreator.createImages(dirs);
	self.m_root:addChild(self.m_people);
	self.m_people:setVisible(false);
	self.m_people:setLevel(303);
	self.m_people:setAlign(kAlignCenter);
	self.m_people:setPos(0, -80);
	


	-- 字 4帧
	local dirs = {};
	for i=9,12 do
		table.insert(dirs, ziMoPin_map[string.format("zimo%d.png", i)]);
	end
	self.m_word = UICreator.createImages(dirs);
	self.m_root:addChild(self.m_word);
	self.m_word:setVisible(false);
	self.m_word:setLevel(302);
	self.m_word:setAlign(kAlignTop);

	-- 背景旋转光 2帧
	local dirs = {};
	for i=1, 2 do
		table.insert(dirs, light_bg_map[string.format("light_%d.png", i)]);
	end
	self.m_light = UICreator.createImages(dirs);
	self.m_root:addChild(self.m_light);
	self.m_light:setVisible(false);
	self.m_light:setLevel(301);
	self.m_light:setSize(220, 147);
	self.m_light:setAlign(kAlignTop);
end

function AnimationZiMo.play( self )
	if self.isPlaying then
		return;
	end
	self.isPlaying = true;
	self:playPeopleAnim();
	self:playWordAnim();
	self:playLightAnim();
end

function AnimationZiMo.playPeopleAnim( self )
	if self.m_peopleAnim then
		delete(self.m_peopleAnim);
		self.m_peopleAnim = nil;
	end

	self.people_i = 1;
	self.m_peopleAnim = self.m_people:addPropTranslate(0, kAnimRepeat, 100, 0, 0, 0, 0, 0);
	self.m_peopleAnim:setEvent(self, self.showPeopleOnTime);
	self.m_people:setVisible(false);
end

function AnimationZiMo.playWordAnim( self )
	if self.m_wordAnim then
		delete(self.m_wordAnim);
		self.m_wordAnim = nil;
	end

	self.word_i = 1;
	self.m_wordAnim = self.m_word:addPropTranslate(0, kAnimRepeat, 100, 0, 0, 0, 0, 0);
	self.m_wordAnim:setEvent(self, self.showWordOnTime);
	self.m_word:setVisible(false);
end

function AnimationZiMo.playLightAnim( self )
	if self.m_lightAnim then
		delete(self.m_lightAnim);
		self.m_lightAnim =  nil;
	end

	self.light_i = 1;
	self.m_lightAnim = self.m_light:addPropTranslate(0, kAnimRepeat, 100, 0, 0, 0, 0, 0);
	self.m_lightAnim:setEvent(self, self.showLightOnTime);
	self.m_light:setVisible(false);
end

function  AnimationZiMo.showPeopleOnTime(self)
	if self.m_people.m_reses then
		if self.people_i < 28 then
			self.m_people:setImageIndex(self.peopleFrames[self.people_i]);
			self.m_people:setVisible(true);
		else
			self.m_people:setVisible(false);
			self:stop();
		end
	else
		delete(self.m_people);
		self.m_people = nil;
		self:stop();
	end
	self.people_i = self.people_i + 1;
end

function  AnimationZiMo.showWordOnTime(self)
	if self.m_word.m_reses then
		if self.word_i > 14 and self.word_i < 28 then
			self.m_word:setImageIndex(self.wordFrames[self.word_i]);
			self.m_word:setVisible(true);
		else
			self.m_word:setVisible(false);
		end
	else
		delete(self.m_word);
		self.m_word = nil;
	end
		self.word_i = self.word_i + 1;
end

function  AnimationZiMo.showLightOnTime(self)
	if self.m_light.m_reses then
		if self.light_i > 14 and self.light_i < 28 then
			self.m_light:setImageIndex(self.lightFrames[self.light_i]);
			self.m_light:setVisible(true);
		else
			self.m_light:setVisible(false);
		end
	else
		delete(self.m_light);
		self.m_light = nil;
	end
	self.light_i = self.light_i + 1;
end

function AnimationZiMo.stop( self )
	self.isPlaying = false;
	if self.obj and self.callback then
		self.callback(self.obj);
	end
	delete(self);--self:dtor();
end

function AnimationZiMo.dtor( self )
	if self.m_people then
		delete(self.m_people);
		self.m_people = nil;
	end

	if self.m_word then
		delete(self.m_word);
		self.m_word = nil;
	end

	if self.m_light then
		delete(self.m_light);
		self.m_light = nil;
	end

	if self.m_root then
		delete(self.m_root);
		self.m_root = nil;
	end
	self = nil;
end

