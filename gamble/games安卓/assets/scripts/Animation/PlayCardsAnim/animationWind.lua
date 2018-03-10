-- 玩牌 刮风动画
require("Animation/FriendsAnim/animCurve");
require("MahjongPinTu/playCardsAnimPin")



AnimationWind = class(Node);

function AnimationWind.ctor( self, p1)
	self.m_p1 = p1;
	self.isPlaying = false;

	self.peopleFrames = {0,0,0,0,0,0,0,1,1,2,3,4,5,6,7,7,7,7,7,8,9,10,11,11,11,11,11};
	self.moneyFrames  = {0,0,0,0,0,0,0,0,1,2,3,4,5,6,6,6,6,6,6,6,6,6,6,6,6,6,6};
	self.wordFrames   = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,2,3};
	self.smogFrames   = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,2,3};

	self:load();
end

function AnimationWind.load( self )
	self.m_root = new(Node);
	self.m_root:setPos(self.m_p1[1], self.m_p1[2]);
	self.m_root:setSize(390, 234);
	 
	self:addChild(self.m_root)
	-- level:钱>人>字>烟圈>光
	-- 字 4帧
	local dirs = {};
	for i=20,23 do
		table.insert(dirs, windPin_map[string.format("wind%d.png", i)]);
	end
	self.m_word = UICreator.createImages(dirs);
	self.m_root:addChild(self.m_word);
	self.m_word:setVisible(false);
	self.m_word:setLevel(302);

	-- 钱 7帧
	local dirs = {};
	for i=1,7 do
		table.insert(dirs, windPin_map[string.format("wind%d.png", i)]);
	end
	self.m_money= UICreator.createImages(dirs);
	self.m_root:addChild(self.m_money);
	self.m_money:setVisible(false);
	self.m_money:setLevel(304);

	-- 人 12帧
	local dirs = {};
	for i=8,19 do
		table.insert(dirs, windPin_map[string.format("wind%d.png", i)]);
	end
	self.m_people = UICreator.createImages(dirs);
	self.m_root:addChild(self.m_people);
	self.m_people:setVisible(false);
	self.m_people:setLevel(303);

	-- 烟圈 4帧
	local dirs = {};
	for i=24,27 do
		table.insert(dirs, windPin_map[string.format("wind%d.png", i)]);
	end
	self.m_smog = UICreator.createImages(dirs);
	self.m_root:addChild(self.m_smog);
	self.m_smog:setVisible(false);
	self.m_smog:setLevel(301);

	-- 背景旋转光
	local dirs = {};
	for i=1,2 do
		table.insert(dirs, light_bg_map[string.format("light_%d.png", i)]);
	end
	self.m_light = UICreator.createImages(dirs);
	self.m_root:addChild(self.m_light);
	self.m_light:setVisible(false);
	self.m_light:setAlign(kAlignCenter);
	self.m_light:setLevel(300);
end


function AnimationWind.play( self )
	if self.isPlaying then
		return;
	end
	self.isPlaying = true;
	self:playMoneyAnim();
	self:playPeopleAnim();
	self:playWordAnim();
	self:playSmogAnim();
	self:playLightAnim();
	
end

function  AnimationWind.playMoneyAnim(self)
	if self.m_moneyAnim then
		delete(self.m_moneyAnim);
		self.m_moneyAnim = nil;
	end
	
	self.money_i = 1;
	self.m_moneyAnim = self.m_money:addPropTranslate(0, kAnimRepeat, 100, 0, 0, 0, 0, 0);
	self.m_moneyAnim:setEvent(self, self.showMoneyOnTime);
	self.m_money:setVisible(false);
end

function AnimationWind.showMoneyOnTime( self )
	if self.m_people.m_reses then
		if  self.money_i < 7  then
			self.m_money:setImageIndex(self.moneyFrames[self.money_i]);
			self.m_money:setVisible(false);
		elseif self.money_i > 6 and self.money_i < 15 then
			self.m_money:setImageIndex(self.moneyFrames[self.money_i]);
			self.m_money:setVisible(true);			

		else
			self.m_money:setVisible(false);
		end
	else
		delete(self.m_money);
		self.m_money = nil;
		self:stop();
		return;
	end
	self.money_i = self.money_i + 1;
end

function  AnimationWind.playPeopleAnim(self)
	if self.m_peopleAnim then
		delete(self.m_peopleAnim);
		self.m_peopleAnim = nil;
	end
	self.people_i = 1;
	self.m_peopleAnim = self.m_people:addPropTranslate(0, kAnimRepeat, 100, 0, 0, 0, 0, 0);
	self.m_peopleAnim:setEvent(self, self.showPeopleOnTime);
	self.m_people:setVisible(false); 
end



function AnimationWind.showPeopleOnTime( self )
	if self.m_people.m_reses then	
		if  self.people_i < 24 then
			self.m_people:setImageIndex(self.peopleFrames[self.people_i]);
			self.m_people:setVisible(true);
		elseif self.people_i > 23 and self.people_i < 28 then
			self.m_people:setImageIndex(self.peopleFrames[self.people_i]);
			self.m_people:setVisible(false);
		elseif self.people_i > 27 then
			self.m_people:setVisible(false);
			self:stop();
		end
	else
		delete(self.m_people);
		self.m_people = nil;
		self:stop();
		return;
	end
	self.people_i = self.people_i + 1;
end


function  AnimationWind.playWordAnim(self)
	if self.m_wordAnim then
		delete(self.m_wordAnim);
		self.m_wordAnim = nil;
	end
	self.word_i = 1;
	self.m_wordAnim = self.m_word:addPropTranslate(0, kAnimRepeat, 100, 0, 0, 0, 0, 0);
	self.m_wordAnim:setEvent(self, self.showWordOnTime);
	self.m_word:setVisible(false); 
end


function AnimationWind.showWordOnTime(self)
	if self.m_word.m_reses then
		if self.word_i > 23  then
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

function  AnimationWind.playSmogAnim(self)
	if self.m_smogAnim then
		delete(self.m_smogAnim);
		self.m_smogAnim = nil;
	end
	self.smog_i = 0;
	self.m_smogAnim = self.m_smog:addPropTranslate(0, kAnimRepeat, 100, 0, 0, 0, 0, 0);
	self.m_smogAnim:setEvent(self, self.showSmogOnTime);
	self.m_smog:setVisible(false); 
end

function  AnimationWind.showSmogOnTime(self)
	if self.m_smog.m_reses then
		if self.smog_i > 23  then
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

function  AnimationWind.playLightAnim(self)
	if self.m_lightAnim then
		delete(self.m_lightAnim);
		self.m_lightAnim = nil;
	end
	self.light_i    = 1;
	self.lightIndex = 0;
	self.m_lightAnim = self.m_light:addPropTranslate(0, kAnimRepeat, 100, 0, 0, 0, 0, 0);
	self.m_lightAnim:setEvent(self, self.showLightOnTime);
	self.m_light:setVisible(false); 
end

function  AnimationWind.showLightOnTime(self)
	if self.m_light.m_reses then
		if self.light_i > 23 then
			self.m_light:setVisible(true);
			self.m_light:setImageIndex(self.lightIndex);
			if 0 == self.lightIndex then
				self.lightIndex = 1;
			else
				self.lightIndex = 0;
			end
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



function AnimationWind.stop( self )
	self.isPlaying = false;
	self:dtor();
end


function AnimationWind.dtor( self )
	if self.m_people then
		delete(self.m_people);
		self.m_people = nil;
	end

	if self.m_money then
		delete(self.m_money);
		self.m_money = nil;
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
	self = nil;
end

