-- 玩牌 下雨动画
require("Animation/FriendsAnim/animCurve");
require("MahjongPinTu/playCardsAnimPin")



AnimationRain = class(Node);

function AnimationRain.ctor( self, p1)
	self.m_p1 = p1;
	self.isPlaying = false;

	self.peopleFrames = {0,0,1,1,2,4,3,4,3,4,3,4,3,4,3,4,3,4};
	self.cloudFrames  = {0,0,0,0,0,1,2,3,4,1,2,3,4,1,2,3,4,1};
	self.coinFrames   = {0,0,0,0,0,0,0,0,0,0,1,2,3,3,3,3,3,3};
	self.wordFrames   = {0,0,0,0,0,0,0,1,1,2,3,2,3,3,3,3,3,3};

	self:load();
end

function AnimationRain.load( self )
	self.m_root = new(Node);
	self.m_root:setPos(self.m_p1[1], self.m_p1[2]);
	self.m_root:setSize(300, 265);
	 
	self:addChild(self.m_root)
	
	-- 人 5帧
	local dirs = {};
	for i=1,5 do
		table.insert(dirs, rainPin_map[string.format("rain%d.png", i)]);
	end
	self.m_people = UICreator.createImages(dirs);
	self.m_root:addChild(self.m_people);
	self.m_people:setVisible(false);
	self.m_people:setLevel(301);
	-- self.m_people:setAlign(kAlignCenter);
	self.m_people:setAlign(kAlignBottom);

	-- self.m_people:setPos(0, 50);

	-- 云 5帧
	local dirs = {};
	for i=6,10 do
		table.insert(dirs, rainPin_map[string.format("rain%d.png", i)]);
	end
	self.m_cloud = UICreator.createImages(dirs);
	self.m_root:addChild(self.m_cloud);
	self.m_cloud:setVisible(false);
	self.m_cloud:setLevel(302);
	self.m_cloud:setAlign(kAlignCenter);
	-- self.m_cloud:setPos(self.m_p1[1], self.m_p1[2]);

	-- 金币 4帧
	local dirs = {};
	for i=15,18 do
		table.insert(dirs, rainPin_map[string.format("rain%d.png", i)]);
	end
	self.m_coin = UICreator.createImages(dirs);
	self.m_root:addChild(self.m_coin);
	self.m_coin:setVisible(false);
	self.m_coin:setLevel(304);
	self.m_coin:setAlign(kAlignBottom);
	self.m_coin:setPos(0, -20);

	-- 字 4帧
	local dirs = {};
	for i=11,14 do
		table.insert(dirs, rainPin_map[string.format("rain%d.png", i)]);
	end
	self.m_word = UICreator.createImages(dirs);
	self.m_root:addChild(self.m_word);
	self.m_word:setVisible(false);
	self.m_word:setLevel(303);
	self.m_word:setAlign(kAlignTop);
	-- self.m_word:setPos(self.m_p1[1], self.m_p1[2]);
end

function AnimationRain.play( self )
	if self.isPlaying then
		return;
	end
	self.isPlaying = true;
	self:playPeopleAnim();
	self:playCloudAnim();
	self:playWordAnim();
	self:playCoinAnim();

end

function  AnimationRain.playPeopleAnim(self)
	if self.m_peopleAnim then
		delete(self.m_peopleAnim);
		self.m_peopleAnim = nil;
	end

	self.people_i = 1;
	self.m_peopleAnim = self.m_people:addPropTranslate(0, kAnimRepeat, 200, 0, 0, 0, 0, 0);
	self.m_peopleAnim:setEvent(self, self.showPeopleOnTime);
	self.m_people:setVisible(false); 
end

function  AnimationRain.playCloudAnim(self)
	if self.m_cloudAnim then
		delete(self.m_cloudAnim);
		self.m_cloudAnim = nil;
	end

	self.cloud_i = 1;


	self.m_cloudAnim = self.m_cloud:addPropTranslate(0, kAnimRepeat, 200, 0, 0, 0, 0, 0);
	self.m_cloudAnim:setEvent(self, self.showCloudOnTime);
	self.m_cloud:setVisible(false);
end


function  AnimationRain.playWordAnim(self)
	if self.m_wordAnim then
		delete(self.m_wordAnim);
		self.m_wordAnim = nil;
	end

	self.word_i = 1;
	self.wordCount = 0;
	self.m_wordAnim = self.m_word:addPropTranslate(0, kAnimRepeat, 200, 0, 0, 0, 0, 0);
	self.m_wordAnim:setEvent(self, self.showWordOnTime);
	self.m_word:setVisible(false);
end

function  AnimationRain.playCoinAnim(self)
	if self.m_coinAnim then
		delete(self.m_coinAnim);
		self.m_coinAnim = nil;
	end
	self.coin_i = 1;
	self.coinCount = 0;

	self.m_coinAnim = self.m_coin:addPropTranslate(0, kAnimRepeat, 200, 0, 0, 0, 0, 0);
	self.m_coinAnim:setEvent(self, self.showCoinOnTime);
	self.m_coin:setVisible(false);
end

function AnimationRain.showPeopleOnTime( self )
	if self.m_people.m_reses then
		if  self.people_i < 19  then
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
		return;
	end
	self.people_i = self.people_i + 1;
end

function AnimationRain.showCloudOnTime( self )
	if self.m_cloud.m_reses then
		if  self.cloud_i < 19  then
			self.m_cloud:setImageIndex(self.cloudFrames[self.cloud_i]);
			self.m_cloud:setVisible(true);
		else
			self.m_cloud:setVisible(false);
		end
	else
		delete(self.m_cloud);
		self.m_cloud = nil;
		self:stop();
		return;
	end
	self.cloud_i = self.cloud_i + 1;
end

function AnimationRain.showWordOnTime(self)
	if self.m_word.m_reses then
		if self.word_i > 5 and self.word_i < 19  then
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

function AnimationRain.showCoinOnTime(self)
	if self.m_coin.m_reses then
		if self.coin_i > 9 and self.coin_i < 19  then
			self.m_coin:setImageIndex(self.coinFrames[self.coin_i]);
			self.m_coin:setVisible(true);
		else
			self.m_coin:setVisible(false);
		end
	else
		delete(self.m_coin);
		self.m_coin = nil;
		self:stop();
		return;
	end
	self.coin_i = self.coin_i + 1;
end



function AnimationRain.stop( self )
	self.isPlaying = false;
	--self:dtor();
	delete(self);
end


function AnimationRain.dtor( self )
	if self.m_people then
		delete(self.m_people);
		self.m_people = nil;
	end

	if self.m_cloud then
		delete(self.m_cloud);
		self.m_cloud = nil;
	end

	if self.m_coin then
		delete(self.m_coin);
		self.m_coin = nil;
	end

	if self.m_word then
		delete(self.m_word);
		self.m_word = nil;
	end


	if self.m_root then
		delete(self.m_root);
		self.m_root = nil;
	end

	self = nil;

end

