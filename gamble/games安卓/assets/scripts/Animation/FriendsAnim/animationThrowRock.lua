-- 好友 扔石头动画
require("motion/EaseMotion");
require("Animation/FriendsAnim/animCurve");

local throwRock_pin_map = require("qnPlist/throwRockPin")
local smogs_pin_map       = require("qnPlist/smogsPin")

require("Animation/FriendsAnim/animationShowCharm");
require("Animation/FriendsAnim/PropAnim");

AnimationThrowRock = class(PropAnim);


function AnimationThrowRock.ctor( self, p1, p2, tcharm, scharm, iconSize, tagmid, fromId, toId, times)

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
	self.m_brokenGlassAnim = {};

	self:load();
	--创建石块一阶段路径
	self.m_rockCurve_1 = {};
	if math.abs(p1.x-p2.x) <=100 then
		self.m_rotateFlag = true;
		self.m_p2.y = self.m_p2.y - 33;	--由于动画要居中做的偏移
		self.m_rockCurve_1 = AnimCurve.createLineCurve(self.m_p1, self.m_p2, self.m_pnum);
	else
		self.m_rockCurve_1 = AnimCurve.createParabolaCurve(self.m_p1, self.m_p2, self.m_h, self.m_pnum);
	end
	--创建石块二阶段路径
	self.m_rockCurve_2 = {};
	local p = {x=self.m_p2.x+300, y=self.m_p2.y}
	self.m_rockCurve_2 = AnimCurve.createParabolaCurve(self.m_p2, p, self.m_h, self.m_pnum);
	--创建玻璃渣路径
	self.starsEndPos = {};
	for i=1,7 do
		self.starsEndPos[i] = {};
	end
	self.starsEndPos[1].x = -90;
	self.starsEndPos[1].y = 0;
	self.starsEndPos[2].x = -60;
	self.starsEndPos[2].y = 80;
	self.starsEndPos[3].x = -70;
	self.starsEndPos[3].y = -50;
	
	self.starsEndPos[4].x = 0;
	self.starsEndPos[4].y = -110;

	self.starsEndPos[5].x = 80;
	self.starsEndPos[5].y = 10;
	self.starsEndPos[6].x = 80;
	self.starsEndPos[6].y = 100;
	self.starsEndPos[7].x = 90;
	self.starsEndPos[7].y = 40;

	self.arryPos = {};

	for i=1,7 do
		self.arryPos[i] = {};
		self.arryPos[i].pos = AnimCurve.createLineCurve({x=0,y=0} ,self.starsEndPos[i], 10);
	end
end

function AnimationThrowRock.load( self )
	self.m_root = new(Node);
	self:addChild(self.m_root) 

	--石块
	self.m_rock = UICreator.createImg( throwRock_pin_map["rock.png"]);
	self.m_rock:setVisible(false);
	self.m_rock:setPos(self.m_p1.x, self.m_p1.y);
	local rW, rH = self.m_rock:getSize();

	--玻璃裂纹
	self.m_glassCrack = UICreator.createImg(throwRock_pin_map["glass_crack.png"]);
	self.m_root:addChild(self.m_glassCrack);
	self.m_root:addChild(self.m_rock);
	self.m_glassCrack:setVisible(false);
	local gW, gH = self.m_glassCrack:getSize();
	self.m_glassCrack:setPos(self.m_p2.x - gW/2 + rW/2, self.m_p2.y - gH/2 + rH/2);
	
	--7个玻璃碎片
	self.m_glassFlake = {};
	self.m_glassFlakeImage = {};
	for i=1,7 do
		-- self.m_glassFlake[i] = UICreator.createImg(throwRock_pin_map["glass_flake.png"]);
		-- self.m_glassCrack:addChild(self.m_glassFlake[i]);
		-- self.m_glassFlake[i]:setAlign(kAlignCenter);
		-- self.m_glassFlake[i]:setVisible(false);
		table.insert( self.m_glassFlakeImage, throwRock_pin_map["glass_crack.png"] );
	end

	--烟雾
	local dirs = {};
	for i=1,5 do
		table.insert(dirs, smogs_pin_map[string.format("smog%d.png",i)]);
	end	
	self.m_smogs = UICreator.createImages(dirs);
	self.m_root:addChild(self.m_smogs);
	self.m_smogs:setVisible(false);
	self.m_smogs:setPos(self.m_p1.x, self.m_p1.y);


end

function AnimationThrowRock.play( self )
	if self.isPlaying then
		return;
	end
	self.isPlaying = true;
	self:playSmogAnim();
	self:throwRockAnim();
end

--[[播放烟圈动画]]
function AnimationThrowRock.playSmogAnim( self )

	if self.m_smogAnim then
		delete(self.m_smogAnim);
		self.m_smogAnim = nil;
	end
	self.imgIndex = 0;

	self.m_smogAnim = self.m_smogs:addPropRotate(0,kAnimRepeat,120,0,0,0,kCenterDrawing);
	self.m_smogAnim:setDebugName("AnimationThrowRock || self.m_smogAnim");
	self.m_smogAnim:setEvent(self, self.showSmogsOnTime);
	self.m_smogs:setVisible(false);

	GameEffect.getInstance():play("ROCK_1");

end

function AnimationThrowRock.showSmogsOnTime( self )

	if self.m_smogs.m_reses then
		local index = self.imgIndex;
		if index > 4 then
			index = 4;
			self.m_smogs:setVisible(false);
			GameEffect.getInstance():play("ROCK_2");
		else
			self.m_smogs:setImageIndex(index);
			self.m_smogs:setVisible(true);
		end
	else
		delete(self.m_smogs);
		self.m_smogs = nil;
		-- self:stop();
		return;
	end
	self.imgIndex = self.imgIndex + 1;
	if self.imgIndex > 10 then
		delete(self.m_smogs);
		self.m_smogs = nil;
		-- self:stop();
	end

end

--[[丢石头]]
function AnimationThrowRock.throwRockAnim( self )
	self:playThrowTargetAnim( throwRock_pin_map["rock.png"], self.m_times, "ROCK_2", self.m_h, self.m_pnum, true );
end

-- Override
function AnimationThrowRock:throwTargetCallback( index, size )
	-- 这里的参数一般不会变动
	self:playEndEffectAnim( self.m_glassFlakeImage, self.m_root, self.m_p2, size, "ROCK_3", 9, index == self.m_times, self.ETC_ANIM_TYPE_ROCK );
end

-- Override
function AnimationThrowRock:endEffectCallback()
	self:stop();
end

--[[砸玻璃]]
function AnimationThrowRock.brokeGlassAnim( self )

	self.m_glassCrack:setVisible(true);
	self.m_glassCrack:addPropScale(self.baseSequence, kAnimNormal, 50, 0, 0.5, 1, 0.5, 1, kCenterDrawing);
	self.m_glassCrack:addPropTransparency(self.baseSequence+1, kAnimNormal, 600, 1500, 1, 0);
	self:glassFlakesAnim();
	GameEffect.getInstance():play("ROCK_3");
end

function AnimationThrowRock.stop( self )
	self.isPlaying = false;
	self:playAddCharmAnim( self.m_toId, self.tcharm, self.scharm, self.iconSize, self.m_p1, self.m_p2 );

	delete(self)--self:dtor();
end

function AnimationThrowRock.dtor( self )

	if self.m_rockAnim then
		delete(self.m_rockAnim);
		self.m_rockAnim = nil;
	end	

	if self.m_smogs then
		delete(self.m_smogs);
		self.m_smogs = nil;
	end

	if self.m_root then
		delete(self.m_root);
		self.m_root = nil;
	end
end

