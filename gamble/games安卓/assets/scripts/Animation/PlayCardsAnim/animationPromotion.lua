-- 大厅 升级动画 (to be continue)
require("motion/EaseMotion");
require("Animation/FriendsAnim/animCurve");
require("MahjongPinTu/playCardsAnimPin")



AnimationPromotion = class(Node);

function AnimationPromotion.ctor( self, p)
	self.m_p = p;
	self.isPlaying = false;
	self.m_soapCurve_1 = {};

	self.m_p1 = {{x=500, y=100},{x=500, y=100},{x=500, y=100},{x=500, y=100},{x=500, y=100},{x=500, y=100},{x=500, y=100}};
	self.m_p2 = {{x=700, y=300},{x=600, y=300},{x=500, y=300},{x=400, y=300},{x=300, y=300},{x=200, y=300},{x=200, y=300}};

	self.m_pnum = 40;
	self:load();
end

function AnimationPromotion.load( self )
	self.m_root = new(Node);
	self.m_root:addToRoot();

	-- Level:字>星>背景光
	-- 字 13帧
	local dirs = {};
	for i=1, 2 do
		table.insert(dirs, promotionPin_1_map[string.format("promotion%d.png", i)]);
	end
	for i=3, 4 do
		table.insert(dirs, promotionPin_2_map[string.format("promotion%d.png", i)]);
	end
	for i=5, 6 do
		table.insert(dirs, promotionPin_3_map[string.format("promotion%d.png", i)]);
	end
	for i=7, 8 do
		table.insert(dirs, promotionPin_4_map[string.format("promotion%d.png", i)]);
	end
	for i=9, 10 do
		table.insert(dirs, promotionPin_5_map[string.format("promotion%d.png", i)]);
	end
	for i=11, 12 do
		table.insert(dirs, promotionPin_6_map[string.format("promotion%d.png", i)]);
	end
	table.insert(dirs, promotionPin_7_map["promotion13.png"]);
	self.m_word = UICreator.createImages(dirs);
	self.m_root:addChild(self.m_word);
	self.m_word:setVisible(false);
	self.m_word:setLevel(303);
	-- self.m_word:setPos(self.m_p1[1], self.m_p1[2]);

	-- 星星
	self.m_star = {};
	for i =1, 7 do 
		table.insert(self.m_star, UICreator.createImg(promotionPin_7_map["promotion15.png"]));
		self.m_root:addChild(self.m_star[i]);
		-- self.m_star[i]:setPos(self.starParam[i][4].x, self.starParam[i][4].y);
		self.m_star[i]:setVisible(false);
		self.m_star[i]:setLevel(302);

		if i == 3 then
			self.m_star[i]:setSize(80,80);
		elseif 1 == i%2 then
			self.m_star[i]:setSize(61, 61);
		end
	end

	-- 背景光
	self.m_light = UICreator.createImg(winPin_map["win10.png"]);
	self.m_root:addChild(self.m_light);
	self.m_light:setVisible(false);
	self.m_light:setLevel(301);
	self.m_light:setPos(9, -80);

end

function AnimationPromotion.play( self )
	if self.isPlaying then
		return;
	end
	self.isPlaying = true;

	self:playWordAnim();
	self:playStarAnim();
	self:playLightAnim();
end

function AnimationPromotion.playWordAnim( self )
	if self.m_wordAnim then
		delete(self.m_wordAnim);
		self.m_wordAnim = nil;
	end

	self.word_i = 0;
	self.m_wordAnim = self.m_word:addPropTranslate(0, kAnimRepeat, 100, 0, 0, 0, 0, 0);
	self.m_wordAnim:setEvent(self, self.showWordOnTime);
	self.m_word:setVisible(false);
end

function AnimationPromotion.playStarAnim( self, i )

	self.index = 1;
	local speed = 100;	-- 速度

	--创建肥皂飞行路径	
	for i=1,7 do
		self.m_star[i]:addPropRotate(0, kAnimRepeat, 800, 1000, 360, 0, kCenterDrawing);
	end

	self.m_starAnim = new(EaseMotion, kEaseOut, 5, 300, 1000);
	self.m_starAnim:setDebugName("AnimationPromotion || self.self.m_starAnim");
	self.m_starAnim:setEvent(nil, function()
		for i=1,7 do
			self.m_star[i]:setVisible(true);
			local m_starCurve_1 = AnimCurve.createLineCurve(self.m_p1[i], self.m_p2[i], self.m_pnum);
			m_starCurve_1[self.index].y = m_starCurve_1[self.index].y + speed*self.m_starAnim.m_process;
			m_starCurve_1[self.index].x = m_starCurve_1[self.index].x + speed*self.m_starAnim.m_process;
			self.m_star[i]:setPos(m_starCurve_1[self.index].x, m_starCurve_1[self.index].y);
		end
		self.index = self.index + 1;
		if self.index >= 40 then
			self.index = 40;
			-- self:stop();
		end
	end);
end


function AnimationPromotion.showWordOnTime( self )
	if self.m_word.m_reses then
		if self.word_i < 13  then
			self.m_word:setImageIndex(self.word_i);
			self.m_word:setVisible(true);
		-- elseif self.word_i > 25 then
		-- 	self:stop();
		else
			self.m_word:setVisible(true);
		end
	else
		delete(self.m_word);
		self.m_word = nil;
		self:stop();
		return;
	end
	self.word_i = self.word_i + 1;
end

function AnimationPromotion.playLightAnim( self )
	if self.m_lightAnim then
		delete(self.m_lightAnim);
		self.m_lightAnim = nil;
	end

	self.m_lightAnim = self.m_light:addPropRotate(2, kAnimRepeat, 5000, 0, 0, 360, kCenterDrawing);

	self.m_lightAnim:setDebugName("AnimationPromotion || self.m_lightAnim");
	self.m_light:setVisible(true);
	self.m_lightAnim:setEvent();	
end

function AnimationPromotion.stop( self )
	self.isPlaying = false;
	self:dtor();
end


function AnimationPromotion.dtor( self )
	if self.m_starAnim then			
		delete(self.m_starAnim);
		self.m_starAnim = nil;
	end

	if self.m_star then
		delete(self.m_star);
		self.m_star = nil;
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
end

