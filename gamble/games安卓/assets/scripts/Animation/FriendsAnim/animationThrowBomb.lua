-- 好友 扔炸弹动画
require("motion/EaseMotion");
require("Animation/FriendsAnim/animCurve");

local throwBomb_pin_map = require("qnPlist/throwBombPin")
local smogs_pin_map       = require("qnPlist/smogsPin")
local throwRock_pin_map = require("qnPlist/throwRockPin");

require("Animation/FriendsAnim/animationShowCharm");
require("Animation/FriendsAnim/PropAnim");

AnimationThrowBomb = class(PropAnim);


function AnimationThrowBomb.ctor( self, p1, p2, tcharm, scharm, iconSize, tagmid, fromId, toId, times)

	self.m_p1 = p1;
	self.m_p2 = p2;
	self.m_fromId = fromId;
	self.m_toId = toId;
	self.m_h = 50;	--弧线高度
	self.m_pnum = 40;
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
	self.m_rockCurve_1 = {};
	if math.abs(p1.x-p2.x) <=100 then
		self.m_rotateFlag = true;
		self.m_p2.y = self.m_p2.y - 33;
		self.m_p2.x = self.m_p2.x + 20 ;
		self.m_rockCurve_1 = AnimCurve.createLineCurve(self.m_p1, self.m_p2, self.m_pnum);
	else
		self.m_rockCurve_1 = AnimCurve.createParabolaCurve(self.m_p1, self.m_p2, self.m_h, self.m_pnum);
	end

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

function AnimationThrowBomb.load( self )
	self.m_root = new(Node);
	self:addChild(self.m_root) 

	--bomb
	self.m_rock = UICreator.createImg(throwBomb_pin_map["bomb.png"]);
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
	for i=1,7 do
		self.m_glassFlake[i] = UICreator.createImg(throwRock_pin_map["glass_flake.png"]);
		self.m_glassCrack:addChild(self.m_glassFlake[i]);
		self.m_glassFlake[i]:setAlign(kAlignCenter);
		self.m_glassFlake[i]:setVisible(false);
	end

	--爆炸效果
	local dirs = {};
	self.m_endDirs = {};
	for i=1,5 do
		table.insert(dirs, throwBomb_pin_map[string.format("end_%d.png",i)]);
		table.insert(self.m_endDirs, throwBomb_pin_map[string.format("end_%d.png",i)]);
	end	
	self.m_ends = UICreator.createImages(dirs);
	self.m_root:addChild(self.m_ends);
	self.m_ends:setVisible(false);
	local gW, gH = self.m_ends:getSize();
	self.m_ends:setPos(self.m_p2.x - gW/2 + rW/2, self.m_p2.y - gH*2/3 + rH/3);

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

function AnimationThrowBomb.play( self )
	if self.isPlaying then
		return;
	end
	self.isPlaying = true;
	self:playSmogAnim();
	self:throwRockAnim();
end

--[[播放烟圈动画]]
function AnimationThrowBomb.playSmogAnim( self )

	if self.m_smogAnim then
		delete(self.m_smogAnim);
		self.m_smogAnim = nil;
	end
	self.imgIndex = 0;
	self.m_smogAnim = self.m_smogs:addPropRotate(0,kAnimRepeat,120,0,0,0,kCenterDrawing);
	self.m_smogAnim:setDebugName("AnimationThrowBomb || self.m_smogAnim");
	self.m_smogAnim:setEvent(self, self.showSmogsOnTime);
	self.m_smogs:setVisible(false);
	GameEffect.getInstance():play("BOMB_1");
end

function AnimationThrowBomb.showSmogsOnTime( self )
	if self.m_smogs.m_reses then
		local index = self.imgIndex;
		if index > 4 and not self.m_bombFlag then
			index = 4;
			self.m_smogs:setVisible(false);
			GameEffect.getInstance():play("BOMB_2");
		elseif index > 4 and self.m_bombFlag then
			index = 4;
			self.m_ends:setVisible(false);
		elseif self.m_bombFlag then
			if not self.brokeGlassFlag then
				-- self:brokeGlassAnim();
				self.brokeGlassFlag = true;
			end
			self.m_ends:setImageIndex(index);
			self.m_ends:setVisible(true);
			self.m_smogs:setVisible(false);
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
function AnimationThrowBomb.throwRockAnim( self )
	self:playThrowTargetAnim( throwBomb_pin_map["bomb.png"], self.m_times, "BOMB_2", self.m_h, self.m_pnum, true );
end

-- Override
function AnimationThrowBomb:throwTargetCallback( index, size )
	-- 这里的参数一般不会变动
	self:playEndEffectAnim( self.m_endDirs, self.m_root, self.m_p2, size, "BOMB_3", 12, index == self.m_times );
end

-- Override
function AnimationThrowBomb:endEffectCallback()
	-- self:brokeGlassAnim();
	self:stop();
end


--[[砸玻璃]]
function AnimationThrowBomb.brokeGlassAnim( self )

	self.m_glassCrack:setVisible(true);
	self.m_glassCrack:addPropScale(self.baseSequence, kAnimNormal, 50, 0, 0.5, 1, 0.5, 1, kCenterDrawing);
	self.m_glassCrack:addPropTransparency(self.baseSequence+1, kAnimNormal, 1000, 1500, 1, 0);
	self:glassFlakesAnim();
end


--[[玻璃渣散开动画]]
function AnimationThrowBomb.glassFlakesAnim( self )
	for i=1,7 do
		self.m_glassFlake[i]:setVisible(true);
	end

	self.m_glassFlakeAnim = new(EaseMotion, kCCEaseOut, 20, 200, 0);
	self.m_glassFlakeAnim:setDebugName("AnimationThrowBomb--self.m_glassFlakeAnim")
	self.m_glassFlakeIndex = 1;
	self.m_glassFlakeAnim:setEvent(nil, function()

		-- 更新坐标
		for i=1,7 do
			-- self.arryPos[i].pos[self.m_glassFlakeIndex].x = self.arryPos[i].pos[self.m_glassFlakeIndex].x 
			-- 	+ math.random(10,20)*self.m_glassFlakeAnim.m_process;
			self.m_glassFlake[i]:setPos(self.arryPos[i].pos[self.m_glassFlakeIndex].x, self.arryPos[i].pos[self.m_glassFlakeIndex].y);
		end
		self.m_glassFlakeIndex = self.m_glassFlakeIndex + 1;

		if self.m_glassFlakeIndex >= #(self.arryPos[1].pos) then
			self.m_glassFlakeIndex = #(self.arryPos[1].pos);
			delete(self.m_glassFlakeAnim);
			self.m_glassFlakeAnim = nil;
			self:stop();
		end
	end);
	GameEffect.getInstance():play("BOMB_3");
end


function AnimationThrowBomb.stop( self )
	self.isPlaying = false;
	self:playAddCharmAnim( self.m_toId, self.tcharm, self.scharm, self.iconSize, self.m_p1, self.m_p2 );

	delete(self)--self:dtor();
end

function AnimationThrowBomb.dtor( self )

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

