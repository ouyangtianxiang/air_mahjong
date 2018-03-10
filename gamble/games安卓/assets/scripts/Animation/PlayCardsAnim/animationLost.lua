-- 结算 失败动画
require("Animation/FriendsAnim/animCurve");
local lostAnimPin_map = require("qnPlist/lostAnimPin")

local girlAnimPin_map = require("qnPlist/girlAnimPin")

AnimationLost = class(Node);

function AnimationLost.ctor( self, p1, root )
	self.m_p1 = p1;
	self.isPlaying = false;
	self.m_node = root;

	self:load();
end

function AnimationLost.load( self )
	self.m_root = new(Node);
	self.m_root:setPos(self.m_p1[1], self.m_p1[2]);
	self.m_root:setSize(500,400);
	self.m_node:addChild(self.m_root);

	-- Level:字>旗>人>背景光
	-- 字
	local dirs = {};
	for i=2, 13 do
		table.insert(dirs, lostAnimPin_map[string.format("lost%d.png", i)]);
	end
	--for i=7, 11 do
	--	table.insert(dirs, lostPin_map[string.format("lost%d.png", i)]);
	--end
	--for i=12, 13 do
	--	table.insert(dirs, lostPin_map[string.format("lost%d.png", i)]);
	--end
	self.m_word = UICreator.createImages(dirs);
	self.m_root:addChild(self.m_word);
	self.m_word:setVisible(false);
	self.m_word:setLevel(305);
	self.m_word:setAlign(kAlignBottom);
	self.m_word:setPos(35, -40-190);

	-- 旗
	self.m_flag = UICreator.createImg(lostAnimPin_map["lost15.png"]);
	self.m_root:addChild(self.m_flag);
	self.m_flag:setVisible(false);
	self.m_flag:setLevel(304);
	self.m_flag:setAlign(kAlignBottom);
	self.m_flag:setPos(11, -10-190);


	-- 人
	local girlXoff = -50
	self.m_peopleNode = new(Node)
	self.m_peopleNode:setVisible(false)
	self.m_peopleNode:setLevel(303)
	self.m_peopleNode:setAlign(kAlignTop)
	self.m_peopleNode:setPos(girlXoff,0)
	self.m_root:addChild(self.m_peopleNode)

	self.m_people = UICreator.createImg(girlAnimPin_map["girlFailed1.png"]);
	self.m_peopleNode:addChild(self.m_people);
	self.m_people:setAlign(kAlignTop);

	local eyeDirs = {}
	for i=2,3 do 
		table.insert(eyeDirs, girlAnimPin_map[string.format("girlFailed%d.png", i)])
	end 
	self.m_peopleEye = UICreator.createImages(eyeDirs)
	self.m_peopleEye:setAlign(kAlignTop)
	self.m_peopleNode:addChild(self.m_peopleEye)



	-- 背景光
	self.m_light = UICreator.createImg(lostAnimPin_map["lost1.png"]);
	self.m_root:addChild(self.m_light);
	self.m_light:setVisible(false);
	self.m_light:setLevel(300);
	self.m_light:setSize(500,500);
	self.m_light:setAlign(kAlignCenter);
end

function AnimationLost.play( self )
	if self.isPlaying then
		return;
	end
	self.isPlaying = true;

	self:playWordAnim();
	self:playPeopleAnim();
	self:playFlagAnim();
    --新需求 输了不播背景光v5.3.5
	--self:playLightAnim();
end

function AnimationLost.playWordAnim( self )
	if self.m_wordAnim then
		delete(self.m_wordAnim);
		self.m_wordAnim = nil;
	end

	self.word_i = 0;
	self.m_wordAnim = self.m_word:addPropTranslate(0, kAnimRepeat, 100, 0, 0, 0, 0, 0);
	self.m_wordAnim:setEvent(self, self.showWordOnTime);
	self.m_word:setVisible(false);
end

function AnimationLost.showWordOnTime( self )
	if self.m_word.m_reses then
		if self.word_i < 12  then
			self.m_word:setImageIndex(self.word_i);
			self.m_word:setVisible(true);
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

function AnimationLost.playPeopleAnim( self )
	if self.m_peopleAnim then
		delete(self.m_peopleAnim);
		self.m_peopleAnim = nil;
	end

	local W, H = self.m_people:getSize();
	self.m_peopleAnim = self.m_people:addPropScale(2, kAnimNormal, 100, 0, 1, 1, 0, 1, kCenterXY, 0, H);
	self.m_peopleAnim = self.m_people:addPropTransparency(3, kAnimNormal, 1000, 0, 0, 1);
	self.m_peopleAnim:setDebugName("AnimationLost || self.m_peopleAnim");
	self.m_peopleNode:setVisible(true);
	self.m_FaceCount = 0
	self.m_peopleAnim:setEvent(self,function ( self )
		self.m_peopleNode:removeProp(2)
		self.m_peopleNode:removeProp(3)
		local anim = self.m_peopleNode:addPropTranslate(1,kAnimRepeat,150,0,0,0)
		if anim then 
			anim:setEvent(self,function ( self )
				self.m_FaceCount = self.m_FaceCount + 1
				self.m_peopleEye:setImageIndex(self.m_FaceCount%2);
			end)
		end 
	end);
end

function AnimationLost.playFlagAnim( self )
	if self.m_flagAnim then
		delete(self.m_flagAnim);
		self.m_flagAnim = nil;
	end

	local W, H = self.m_flag:getSize();
	self.m_flagAnim = self.m_flag:addPropScale(2, kAnimNormal, 100, 0, 1, 1, 0, 1.1, kCenterXY, 0, H);
	self.m_flagAnim = self.m_flag:addPropScale(3, kAnimNormal, 100, 100, 1, 1, 1.1, 0.9, kCenterXY, 0, H);
	self.m_flagAnim = self.m_flag:addPropScale(4, kAnimNormal, 100, 200, 1, 1, 0.9, 1.07, kCenterXY, 0, H);
	self.m_flagAnim = self.m_flag:addPropScale(5, kAnimNormal, 100, 300, 1, 1, 1.07, 0.93, kCenterXY, 0, H);
	self.m_flagAnim = self.m_flag:addPropScale(6, kAnimNormal, 100, 400, 1, 1, 0.93, 1.01, kCenterXY, 0, H);
	self.m_flagAnim = self.m_flag:addPropScale(7, kAnimNormal, 100, 500, 1, 1, 1.01, 1, kCenterXY, 0, H);

	self.m_flagAnim = self.m_flag:addPropScale(8, kAnimNormal, 100, 600, 1, 1.02, 1, 1, kCenterDrawing);
	self.m_flagAnim = self.m_flag:addPropScale(9, kAnimNormal, 100, 700, 1.02, 0.9, 1, 1, kCenterDrawing);
	self.m_flagAnim = self.m_flag:addPropScale(10, kAnimNormal, 100, 800, 0.9, 1.02, 1, 1, kCenterDrawing);
	self.m_flagAnim = self.m_flag:addPropScale(11, kAnimNormal, 100, 900, 1.02, 1, 1, 1, kCenterDrawing);


	self.m_flagAnim = self.m_flag:addPropTransparency(12, kAnimNormal, 100, 0, 0, 1);
	self.m_flagAnim:setDebugName("AnimationLost || self.m_flagAnim");
	self.m_flag:setVisible(true);
	self.m_flagAnim:setEvent();	
end

function AnimationLost.playLightAnim( self )
--新需求 输了不播背景光v5.3.5
--	if self.m_lightAnim then
--		delete(self.m_lightAnim);
--		self.m_lightAnim = nil;
--	end

--	self.m_lightAnim = self.m_light:addPropRotate(2, kAnimRepeat, 5000, 0, 0, 360, kCenterDrawing);
--	-- self.m_lightAnim = self.m_light:addPropTransparency(3, kAnimNormal, 1000, 0, 0, 1);
--	self.m_lightAnim:setDebugName("AnimationLost || self.m_lightAnim");
--	self.m_light:setVisible(true);
--	self.m_lightAnim:setEvent();	
end

function AnimationLost.stop( self )
	self.isPlaying = false;
	self:dtor();
end


function AnimationLost.dtor( self )
	-- if self.m_flag then
	-- 	delete(self.m_flag);
	-- 	self.m_flag = nil;
	-- end

	-- if self.m_word then
	-- 	delete(self.m_word);
	--  	self.m_word = nil;
	-- end

	-- if self.m_people then
	-- 	delete(self.m_people);
	-- 	self.m_people = nil;
	-- end

	-- if self.m_light then
	-- 	delete(self.m_light);
	-- 	self.m_light = nil;
	-- end	

	-- if self.m_root then
	-- 	delete(self.m_root);
	-- 	self.m_root = nil;
	-- end
end

