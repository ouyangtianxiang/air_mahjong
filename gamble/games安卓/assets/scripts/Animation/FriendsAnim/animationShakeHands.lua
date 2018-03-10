-- 好友 扔炸弹动画
require("motion/EaseMotion");
require("Animation/FriendsAnim/animCurve");

local shakeHands_pin_map = require("qnPlist/shakeHandsPin")

require("Animation/FriendsAnim/animationShowCharm");
require("Animation/FriendsAnim/PropAnim");

AnimationShakeHands = class(PropAnim);


function AnimationShakeHands.ctor( self, p1, p2, tcharm, scharm, iconSize, tagmid, fromId, toId, times)

	self.m_p1 = p1;
	self.m_p2 = p2;
	self.m_fromId = fromId;
	self.m_toId = toId;
	self.m_h = 50;	--弧线高度
	self.m_pnum = 30;
	self.isPlaying = false;
	self.baseSequence = 10;
	self.tcharm = tcharm;
	self.scharm = scharm;
	self.iconSize = iconSize;
	self.tagmid = tagmid;
	self.m_toId = toId;
	self.m_times = times or 1;

	self:load();
	--创建飞行路径
	self.m_star_Curve_1 = {};
	if math.abs(p1.x-p2.x) <=100 then
		self.m_rotateFlag = true;
		self.m_star_Curve_1 = AnimCurve.createLineCurve(self.m_p1, self.m_p2, self.m_pnum);
	else
		self.m_star_Curve_1 = AnimCurve.createParabolaCurve(self.m_p1, self.m_p2, self.m_h, self.m_pnum);
	end
end

function AnimationShakeHands.load( self )
	self.m_root = new(Node);
	self:addChild(self.m_root) 

	if not shakeHands_pin_map["bgLight.png"] then
		DebugLog( "AnimationShakeHands.load" );
	end

	DebugLog( shakeHands_pin_map["bgLight.png"].file );

	--背景光
	self.m_bgLight = UICreator.createImg(shakeHands_pin_map["bgLight.png"]);
	if not self.m_bgLight then
		DebugLog( "self.m_bgLight nil" );
	else
		DebugLog( "self.m_bgLight not nil" );
	end
	self.m_root:addChild(self.m_bgLight);
	local bgW, bgH = self.m_bgLight:getSize();

	--大星
	self.m_star_1 = UICreator.createImg(shakeHands_pin_map["star_1.png"]);
	self.m_root:addChild(self.m_star_1);
	self.m_star_1:setVisible(false);
	local sW, sH = self.m_star_1:getSize();
	self.m_star_1:setPos(self.m_p1.x+sW/4, self.m_p1.y+5);
	self.m_bgLight:setPos(self.m_p1.x-bgW/2+sW*5/6, self.m_p1.y-bgH/2 + sH/2+5);
	
	--大星2
	self.m_bigStar = UICreator.createImg(shakeHands_pin_map["star_1.png"]);
	self.m_root:addChild(self.m_bigStar);
	self.m_bigStar:setVisible(false);
	local sW2, sH2 = self.m_bigStar:getSize();
	self.m_bigStar:setPos(self.m_p1.x+sW2/4, self.m_p1.y);

	--中星
	self.m_star_2 = UICreator.createImg(shakeHands_pin_map["star_2.png"]);
	self.m_root:addChild(self.m_star_2);
	self.m_star_2:setVisible(false);
	local sW, sH = self.m_bigStar:getSize();
	self.m_star_2:setPos(self.m_p1.x+sW2/3, self.m_p1.y);

	--小星
	self.m_star_3 = UICreator.createImg(shakeHands_pin_map["star_3.png"]);
	self.m_root:addChild(self.m_star_3);
	self.m_star_3:setVisible(false);
	local sW, sH = self.m_bigStar:getSize();
	self.m_star_3:setPos(self.m_p1.x+sW2/2, self.m_p1.y);

	--散射星光
	local dirs = {};
	for i=1,2 do
		table.insert(dirs, shakeHands_pin_map[string.format("light_%d.png",i)]);
	end	
	self.m_endLight = UICreator.createImages(dirs);
	self.m_root:addChild(self.m_endLight);
	self.m_endLight:setVisible(false);
	local gW, gH = self.m_endLight:getSize();

	--握手
	self.m_hand = UICreator.createImg(shakeHands_pin_map["hand.png"]);
	self.m_hand:setVisible(false);
	self.m_root:addChild(self.m_hand);
	local rW, rH = self.m_hand:getSize();
	self.m_hand:setPos(self.m_p2.x - rW/5, self.m_p2.y);
	self.m_endLight:setPos(self.m_p2.x - gW/2 + rW/3, self.m_p2.y - gH/4);

	--彩带
	local dirs = {};
	for i=1,5 do
		table.insert(dirs, shakeHands_pin_map[string.format("colourStripe_%d.png",i)]);
	end	
	self.m_colourStripe = UICreator.createImages(dirs);
	self.m_root:addChild(self.m_colourStripe);
	self.m_colourStripe:setVisible(false);
	local gW, gH = self.m_colourStripe:getSize();
	self.m_colourStripe:setPos(self.m_p2.x - gW/2 + rW/3, self.m_p2.y- gH/4);

end

function AnimationShakeHands.play( self )
	if self.isPlaying then
		return;
	end
	self.isPlaying = true;
	self:showBgLightAndStar();
end


--[[播放动画]]
function AnimationShakeHands.showBgLightAndStar( self )

	-- if not self.m_bgLight then
	-- 	DebugLog( "self.m_bgLight is nil" );
	-- else
	-- 	DebugLog( "self.m_bgLight is not nil" );
	-- end
	self.m_bgLight:addPropRotate(self.baseSequence,kAnimRepeat, 1800,0,0,360,kCenterDrawing);
	self.m_bgLight:addPropScale(self.baseSequence+1, kAnimLoop, 1200, 400, 1, 0, 1, 0, kCenterDrawing);
	self.m_starAnim = self.m_star_1:addPropScale(self.baseSequence, kAnimLoop, 400, 0, 0.4, 1.5, 0.4, 1.5, kCenterDrawing);
	self.m_count = 0;
	self.m_star_1:setVisible(true);
	if self.m_starAnim then
		self.m_starAnim:setDebugName("AnimationShakeHands || self.m_starAnim");
		self.m_starAnim:setEvent(self, function(self)
			self.m_count = self.m_count + 1;
			if (self.m_count >= 3) then
				delete(self.m_bgLight);	
				self.m_bgLight = nil;
				delete(self.m_star_1);
				self.m_star_1 = nil;
				self:produceStars();
			end

		end);	
	else
		self:stop();
	end

	GameEffect.getInstance():play("ROSE_1");
end

function AnimationShakeHands.produceStars( self )
	self.m_produceAnim = self.m_star_3:addPropRotate(0,kAnimRepeat,80,0,0,0,kCenterDrawing);
	self.m_produceAnim:setDebugName("AnimationShakeHands || self.m_produceAnim");
	self.m_produceAnimIndex = 1;
	self.m_produceAnim:setEvent(self, function (self)
		if (self.m_produceAnimIndex == 1) then
			self:starFlyAnim();
		elseif (self.m_produceAnimIndex == 2) then
			self:starFlyAnim2();
		elseif (self.m_produceAnimIndex == 3) then
			self:starFlyAnim3();
		else
			return;
		end
		self.m_produceAnimIndex = self.m_produceAnimIndex + 1;
	end);

	-- GameEffect.getInstance():play("ROSE_2");
end


-- [[]]
function AnimationShakeHands.starFlyAnim( self )
	-- TODO nums
	self:playThrowTargetAnim( shakeHands_pin_map["star_1.png"], self.m_times, "ROSE_2", self.m_h, self.m_pnum, false );
	-- GameEffect.getInstance():play("ROSE_3");
end

-- Override
function AnimationShakeHands:throwTargetCallback( index, size )
	--TODO
	-- self:playEndEffectAnim( self.m_brokenImages, self.m_root, self.m_p2, size, "ROSE_3", 9, index == self.m_times );
	if index == self.m_times then
		self:colourStripeAnim();
		self:shakeHandAnim();
		GameEffect.getInstance():play("ROSE_3");
	end
end

-- [[]]
function AnimationShakeHands.starFlyAnim2( self )

	self.m_index_2 = 1;
	self.m_speed_2 = 0;	-- 速度
	self.m_star_2:addPropRotate(0,kAnimRepeat,1000,0,0,360,kCenterDrawing);
	self.m_star_Anim2 = new(EaseMotion, kEaseOut, 5, 200, 0);
	self.m_star_Anim2:setDebugName("AnimationShakeHands || self.m_star_Anim2");
	self.m_star_2:setVisible(true);
	self.m_star_Anim2:setEvent(self, function()
		local x = self.m_star_Curve_1[self.m_index_2].x+12;
		local y = self.m_star_Curve_1[self.m_index_2].y;
		if self.m_rotateFlag then
			y = y + self.m_speed_2*self.m_star_Anim2.m_process;
		else
			x = x + self.m_speed_2*self.m_star_Anim2.m_process;
		end
		self.m_star_2:setPos(x, y);	
		self.m_index_2 = self.m_index_2 + 1;
		if self.m_index_2 >= #self.m_star_Curve_1 then
			self.m_index_2 = 1;
			self.m_star_2:setVisible(false);
			delete(self.m_star_Anim2);
			self.m_star_Anim2 = nil;
		end
	end);
end

-- [[]]
function AnimationShakeHands.starFlyAnim3( self )

	self.m_index_3 = 1;
	self.m_speed_3 = 0;	-- 速度
	self.m_star_3:addPropRotate(0,kAnimRepeat,1000,0,0,360,kCenterDrawing);
	self.m_star_Anim3 = new(EaseMotion, kEaseOut, 5, 200, 0);
	self.m_star_Anim3:setDebugName("AnimationShakeHands || self.m_star_Anim3");
	self.m_star_3:setVisible(true);
	self.m_star_Anim3:setEvent(self, function()
		local x = self.m_star_Curve_1[self.m_index_3].x+20;
		local y = self.m_star_Curve_1[self.m_index_3].y;
		if self.m_rotateFlag then
			y = y + self.m_speed_3*self.m_star_Anim3.m_process;
		else
			x = x + self.m_speed_3*self.m_star_Anim3.m_process;
		end
		self.m_star_3:setPos(x, y);	
		self.m_index_3 = self.m_index_3 + 1;
		if self.m_index_3 >= #self.m_star_Curve_1 then
			self.m_index_3 = 1;
			self.m_star_3:setVisible(false);
			delete(self.m_star_Anim3);
			self.m_star_Anim3 = nil;
		end
	end);
end

--[[彩带雨]]
function AnimationShakeHands.colourStripeAnim( self )
	
	self.m_colourIndex = 0;
	self.m_colourAnim = self.m_colourStripe:addPropRotate(0,kAnimRepeat,200,0,0,0,kCenterDrawing);
	self.m_colourAnim:setDebugName("AnimationShakeHands || self.m_colourAnim");
	self.m_colourAnim:setEvent(self, function(self)
		if self.m_colourStripe.m_reses then
			local index = self.m_colourIndex%5;
			self.m_colourStripe:setImageIndex(index);
			self.m_colourStripe:setVisible(true);
		else
			self:stop();
		end

		self.m_colourIndex = self.m_colourIndex + 1;
		if self.m_colourIndex > 12 then
			self:stop();
		end 
	end);

end

--[[]]
function AnimationShakeHands.shakeHandAnim( self )
	self.m_hand:setVisible(true);
	self.m_endLight:setVisible(true);
	self.m_hand:addPropTransparency(self.baseSequence, kAnimNormal, 600, 0, 0, 1);
	self.m_endLightAnim = self.m_endLight:addPropRotate(self.baseSequence, kAnimRepeat, 120,0,0,0,kCenterDrawing);
	self.m_endLightIndex = 0;
	self.m_endLightAnim:setEvent(self, function (self)		
		self.m_endLight:setImageIndex(self.m_endLightIndex);
		if self.m_endLightIndex == 0 then
			self.m_endLightIndex = 1;
		else
			self.m_endLightIndex = 0;
		end
	end);
end


function AnimationShakeHands.stop( self )
	self.isPlaying = false;
	self:playAddCharmAnim( self.m_toId, self.tcharm, self.scharm, self.iconSize, self.m_p1, self.m_p2 );

	delete(self)--self:dtor();
end

function AnimationShakeHands.dtor( self )
	if self.m_bgLight then
		delete(self.m_bgLight);
		self.m_bgLight = nil;
	end

	if self.m_star_1 then
		delete(self.m_star_1);
		self.m_star_1 = nil;
	end
	
	if self.m_root then
		delete(self.m_root);
		self.m_root = nil;
	end
end

