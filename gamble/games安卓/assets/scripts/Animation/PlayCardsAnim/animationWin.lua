-- 结算 胜利动画
require("Animation/FriendsAnim/animCurve");

local girlAnimPin_map = require("qnPlist/girlAnimPin")

local winAnimPin_map = require("qnPlist/winAnimPin")

local roomResultDetailPin_map = require("qnPlist/roomResultDetailPin")


AnimationWin = class(Node);

function AnimationWin.ctor( self, p1, root)
	self.m_p1 = p1;
	self.isPlaying = false;
	self.m_node = root;

	self:load();
end

function AnimationWin.load( self )
	self.m_root = new(Node);
	self.m_root:setPos(self.m_p1[1], self.m_p1[2]);
	self.m_root:setSize(500, 400);
	self.m_node:addChild(self.m_root);

	-- level:旗>人>背景光
	-- 旗 
	local dirs = {};
	for i=2, 9 do
		table.insert(dirs, winAnimPin_map[string.format("win%d.png", i)]);
	end

	self.m_flag = UICreator.createImages(dirs);
	self.m_root:addChild(self.m_flag);
	self.m_flag:setVisible(false);
	self.m_flag:setLevel(303);
	--self.m_flag:setScale(600 / 810, 160 / 260)
	self.m_flag:setSize(600,160);
	self.m_flag:setAlign(kAlignBottom);
	self.m_flag:setPos(-20, -70 - 160);

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

	local eyeDirs = {}
	for i=2,4 do 
		table.insert(eyeDirs, girlAnimPin_map[string.format("girlWin%d.png", i)])
	end 
	self.m_peopleEye = UICreator.createImages(eyeDirs)
	self.m_peopleEye:setAlign(kAlignTop)
	self.m_peopleNode:addChild(self.m_peopleEye)

	local handDirs = {}
	for i=5,7 do 
		table.insert(handDirs, girlAnimPin_map[string.format("girlWin%d.png", i)])
	end 
	self.m_peopleHand = UICreator.createImages(handDirs)
	self.m_peopleHand:setAlign(kAlignTop)
	self.m_peopleNode:addChild(self.m_peopleHand)



	-- 背景光
	self.m_light = UICreator.createImg(winAnimPin_map["win10.png"]);
	self.m_root:addChild(self.m_light);
	self.m_light:setVisible(false);
	self.m_light:setLevel(300);
	--self.m_light:setSize(520,520);
	self.m_light:setAlign(kAlignCenter);
	self.m_light:setPos(-20, 70 + 120);

	--小光
	local createStarFunc = function ( )
		local img = UICreator.createImg(roomResultDetailPin_map["firework_1.png"])
		img:setLevel(301);
		img:setVisible(false)
		self.m_root:addChild(img)
		return img 
	end
	self.star1 = createStarFunc()
	self.star2 = createStarFunc()
	self.star3 = createStarFunc()

	self.star1:setPos(0,400)
	self.star2:setPos(310,300)
	self.star3:setPos(265,200)
	--self.m_lightRightStar = UICreator.createImg(roomResultDetailPin["firework_2.png"])
	

end



function AnimationWin.play( self )
	if self.isPlaying then
		return;
	end
	self.isPlaying = true;

	self:playFlagAnim();
	self:playPeopleAnim();
	self:playLightAnim();
	self:playStarAnim()
end

function AnimationWin.playFlagAnim( self )
	if self.m_flagAnim then
		delete(self.m_flagAnim);
		self.m_flagAnim = nil;
	end
	
	self.flag_i = 0;
	self.m_flagAnim = self.m_flag:addPropTranslate(0, kAnimRepeat, 150, 0, 0, 0, 0, 0);
	self.m_flagAnim:setEvent(self, self.showFlagOnTime);
	self.m_flagAnim:setDebugName("AnimationWin.playFlagAnim");
	self.m_flag:setVisible(false);
end

function AnimationWin.showFlagOnTime( self )
	if self.m_flag.m_reses then
		if self.flag_i < 8 then
			self.m_flag:setImageIndex(self.flag_i);
			self.m_flag:setVisible(true);
		else
			self.m_flag:setVisible(true);
			-- self:stop();
		end
	else
		delete(self.m_flag);
		self.m_flag = nil;
		self:stop();
	end
	self.flag_i = self.flag_i + 1;
end

function AnimationWin.playStarAnim( self )

	if self.m_isPlayStar then 
		self.m_isPlayStar = nil 

		self.star1:removeProp(1)
		self.star2:removeProp(1)
		self.star3:removeProp(1)
	end 

	self.m_isPlayStar = true
	local addStarEffect = function( node,duration,delay,obj,func )
		local anim = node:addPropScale(1,kAnimNormal,duration,delay,0,1,0,1,kCenterDrawing)
		node:setVisible(true)
		anim:setEvent(self, function ( self )
			node:removeProp(1)
			if obj and func then 
				func(obj)
			end 
		end);
	end

	addStarEffect(self.star1,300,1000)
	addStarEffect(self.star2,300,1000)
	addStarEffect(self.star3,300,1000,self,function ( self )
		self.star1:setFile(roomResultDetailPin_map["firework_2.png"])
		self.star2:setFile(roomResultDetailPin_map["firework_2.png"])
		self.star3:setFile(roomResultDetailPin_map["firework_2.png"])

		local addStarExitEffect = function ( node,obj,func)
			local anim = node:addPropTransparency(1, kAnimNormal, 1000, 0, 1, 0)
			anim:setEvent(self,function ( self )
				node:removeProp(1)
				node:setVisible(false)
				if obj and func then 
					func(obj)
				end 
			end)
		end

		addStarExitEffect(self.star1)
		addStarExitEffect(self.star2)
		addStarExitEffect(self.star3,self,function ( self )
			self.m_isPlayStar = nil
		end)
	end)


end

function AnimationWin.showFaceAnimationOnTime( self )
	-- body
	self.m_faceCount = self.m_faceCount + 1
	if self.m_faceCount >= 12 then 
		self.m_faceCount = 0
	end

	self.m_peopleHand:setImageIndex(self.m_faceCount%3)--			self.m_flag:setImageIndex(self.flag_i);
	DebugLog(self.m_faceCount/2)
	self.m_peopleEye:setImageIndex( self.m_faceCount)
end

function AnimationWin.playPeopleAnim( self )
	if self.m_peopleAnim then
		delete(self.m_peopleAnim);
		self.m_peopleAnim = nil;
	end
	
	self.m_peopleAnim = self.m_peopleNode:addPropTranslate(2, kAnimNormal, 500, 0, 0, 0, 100, 0);
	self.m_peopleAnim = self.m_peopleNode:addPropTransparency(3, kAnimNormal, 500, 0, 0, 1);
	self.m_peopleAnim:setDebugName("AnimationWin || self.m_peopleAnim");
	self.m_peopleNode:setVisible(true);
	self.m_peopleAnim:setEvent(self, function ( self )
		self.m_peopleNode:removeProp(2)
		self.m_peopleNode:removeProp(3)

		local anim = self.m_peopleNode:addPropTranslate(0, kAnimRepeat, 150, 0, 0, 0, 0, 0);
		self.m_faceCount = 1
		anim:setEvent(self,self.showFaceAnimationOnTime)
	end);
end

function AnimationWin.playLightAnim( self )
	if self.m_lightAnim then
		delete(self.m_lightAnim);
		self.m_lightAnim = nil;
	end

	self.m_lightAnim = self.m_light:addPropRotate(2, kAnimRepeat, 5000, 0, 0, 360, kCenterDrawing);
	self.m_lightAnim:setDebugName("AnimationWin || self.m_lightAnim");
	self.m_light:setVisible(true);
	self.m_lightAnim:setEvent();	
end

function AnimationWin.stop( self )
	self.isPlaying = false;
	delete(self);--self:dtor();
end


function AnimationWin.dtor( self )
	-- if self.m_flag then
	-- 	delete(self.m_flag);
	-- 	self.m_flag = nil;
	-- end

	-- if self.m_light then
	-- 	delete(self.m_light);
	--  	self.m_light = nil;
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

