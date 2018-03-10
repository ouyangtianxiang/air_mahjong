-- 结算 平局动画
require("Animation/FriendsAnim/animCurve");
local girlAnimPin_map = require("qnPlist/girlAnimPin")

local lostAnimPin_map = require("qnPlist/lostAnimPin")

AnimationDraw = class(Node);

function AnimationDraw.ctor( self, p1, root)
	self.m_p1 = p1;
	self.isPlaying = false;
	self.m_node = root;

	self:load();
end

function AnimationDraw.load( self )
	self.m_root = new(Node);
	self.m_root:setPos(self.m_p1[1], self.m_p1[2]);
	self.m_root:setSize(500, 400);
	self.m_node:addChild(self.m_root);

	-- level:字>旗>人
	-- 红旗 
	self.m_flag = UICreator.createImg(lostAnimPin_map["draw1.png"]);
	self.m_root:addChild(self.m_flag);
	self.m_flag:setVisible(false);
	self.m_flag:setLevel(303);
	self.m_flag:setAlign(kAlignBottom);
	self.m_flag:setPos(0, -50-180);

	-- 字 
	self.m_word = UICreator.createImg(lostAnimPin_map["draw2.png"]);
	self.m_root:addChild(self.m_word);
	self.m_word:setVisible(false);
	self.m_word:setLevel(304);
	self.m_word:setAlign(kAlignBottom);
	self.m_word:setPos(0, -35-180);

	-- 人
	local girlXoff = -50
	self.m_peopleNode = new(Node)
	self.m_peopleNode:setVisible(false)
	self.m_peopleNode:setLevel(302)
	self.m_peopleNode:setAlign(kAlignTop)
	self.m_peopleNode:setPos(girlXoff,0)
	self.m_root:addChild(self.m_peopleNode)

	self.m_people = UICreator.createImg(girlAnimPin_map["girlWin1.png"]);
	self.m_peopleNode:addChild(self.m_people);
	self.m_people:setAlign(kAlignTop);

	self.m_peopleEye = UICreator.createImg(girlAnimPin_map["girlWin3.png"])
	self.m_peopleEye:setAlign(kAlignTop)
	self.m_peopleNode:addChild(self.m_peopleEye)

	self.m_peopleHand = UICreator.createImg(girlAnimPin_map["girlWin5.png"])
	self.m_peopleHand:setAlign(kAlignTop)
	self.m_peopleNode:addChild(self.m_peopleHand)

end

function AnimationDraw.play( self )
	if self.isPlaying then
		return;
	end
	self.isPlaying = true;

	self:playFlagAnim();
	-- self:playWordAnim();
	self:playPeopleAnim();
end

function AnimationDraw.playFlagAnim( self )
	if self.m_flagAnim then
		delete(self.m_flagAnim);
		self.m_flagAnim = nil;
	end

	local W, H = self.m_flag:getSize();
	self.m_flagAnim = self.m_flag:addPropScale(2, kAnimNormal, 200,   0, 1, 1,   0, 1.1, kCenterXY, 0, H);
	self.m_flagAnim = self.m_flag:addPropScale(3, kAnimNormal, 200, 200, 1, 1, 1.06, 0.8, kCenterXY, 0, H);

	self.m_flag:setVisible(true);
	self.m_flagAnim:setDebugName("AnimationDraw || self.m_flagAnim");
	self.m_flagAnim:setEvent(self, self.playWordAnim);
end


function AnimationDraw.playWordAnim( self )
	if self.m_wordAnim then
		delete(self.m_wordAnim);
		self.m_wordAnim = nil;
	end

	local W, H = self.m_word:getSize();
	self.m_wordAnim = self.m_word:addPropScale(2, kAnimNormal, 150, 0, 1.6, 0.8, 1.6, 0.8, kCenterDrawing);
	self.m_wordAnim = self.m_word:addPropScale(3, kAnimNormal, 150, 150, 0.8, 1, 0.8, 1, kCenterDrawing);
	self.m_word:setVisible(true);
	self.m_wordAnim:setDebugName("AnimationDraw || self.m_wordAnim");
	self.m_wordAnim:setEvent();
end

function AnimationDraw.playPeopleAnim( self )
	if self.m_peopleAnim then
		delete(self.m_peopleAnim);
		self.m_peopleAnim = nil;
	end
	
	local W, H = self.m_people:getSize();
	self.m_peopleAnim = self.m_people:addPropScale(2, kAnimNormal, 200, 0, 1, 1, 0, 1, kCenterXY, 0, H);
	self.m_peopleAnim = self.m_people:addPropTransparency(3, kAnimNormal, 200, 0, 0, 1);
	self.m_peopleAnim:setDebugName("AnimationDraw || self.m_peopleAnim");
	self.m_peopleNode:setVisible(true);
	self.m_peopleAnim:setEvent();
end

function AnimationDraw.stop( self )
	self.isPlaying = false;
	self:dtor();
end


function AnimationDraw.dtor( self )
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

	-- if self.m_root then
	-- 	delete(self.m_root);
	-- 	self.m_root = nil;
	-- end
end

