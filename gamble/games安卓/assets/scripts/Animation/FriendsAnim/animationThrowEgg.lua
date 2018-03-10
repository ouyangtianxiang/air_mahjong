-- 好友 扔鸡蛋动画
require("motion/EaseMotion");
require("Animation/FriendsAnim/animCurve");

local throwEgg_pin_map = require("qnPlist/throwEggPin")
local smogs_pin_map       = require("qnPlist/smogsPin")

require("Animation/FriendsAnim/animationShowCharm");
require("Animation/FriendsAnim/PropAnim");

AnimationThrowEgg = class(PropAnim);

function AnimationThrowEgg.ctor( self, p1, p2, tcharm, scharm, iconSize, tagmid, fromId, toId, times )
	self.m_p1 = p1;
	self.m_p2 = p2;
	self.m_h = 30;	--弧线高度
	self.m_pnum = 35;
	self.isPlaying = false;
	self.baseSequence = 10;
	self.tcharm = tcharm;
	self.scharm = scharm;
	self.iconSize = iconSize;
	self.tagmid = tagmid;
	self.m_toId = toId;
	self.m_times = times or 1;

	self:load();
end

function AnimationThrowEgg.load( self )
	self.m_root = new(Node);
	self:addChild(self.m_root) 

	--鸡蛋破碎
	self.m_brokenImages = {};
	for i=1,6 do
		table.insert(self.m_brokenImages, throwEgg_pin_map[string.format("eggEx_%d.png",i)]);
	end

	--烟雾
	local dirs2 = {};
	for i=1,5 do
		table.insert(dirs2, smogs_pin_map[string.format("smog%d.png",i)]);
	end	
	self.m_smogs = UICreator.createImages(dirs2);
	self.m_root:addChild(self.m_smogs);
	self.m_smogs:setVisible(false);
	self.m_smogs:setPos(self.m_p1.x, self.m_p1.y);

end

function AnimationThrowEgg.play( self )
	if self.isPlaying then
		return;
	end
	self.isPlaying = true;
	self:playSmogAnim();
	self:throwEggAnim();
end

--[[播放烟圈动画]]
function AnimationThrowEgg.playSmogAnim( self )

	if self.m_smogAnim then
		delete(self.m_smogAnim);
		self.m_smogAnim = nil;
	end
	self.imgIndex = 0;

	self.m_smogAnim = self.m_smogs:addPropRotate(0,kAnimRepeat,120,0,0,0,kCenterDrawing);
	self.m_smogAnim:setDebugName("AnimationThrowEgg || self.m_smogAnim");
	self.m_smogAnim:setEvent(self, self.showSmogsOnTime);
	self.m_smogs:setVisible(false);
	GameEffect.getInstance():play("EGG_1");

end

function AnimationThrowEgg.showSmogsOnTime( self )
	if self.m_smogs.m_reses then
		local index = self.imgIndex;

		if index == 4 then
			GameEffect.getInstance():play("EGG_2");
		end

		if index > 4 then
			index = 4;
			self.m_smogs:setVisible(false);
		else
			self.m_smogs:setImageIndex(index);
			self.m_smogs:setVisible(true);
		end
	else
		delete(self.m_smogs);
		self.m_smogs = nil;
		self:stop();
		return;
	end
	self.imgIndex = self.imgIndex + 1;
	if self.imgIndex > 8 then
		delete(self.m_smogs);
		self.m_smogs = nil;
	end

end

--[[丢鸡蛋]]
function AnimationThrowEgg.throwEggAnim( self )
	-- TODO nums
	self:playThrowTargetAnim( throwEgg_pin_map["egg.png"], self.m_times, "EGG_2", self.m_h, self.m_pnum, true );
end

-- Override
function AnimationThrowEgg:throwTargetCallback( index, size )
	-- 这里的参数一般不会变动
	self:playEndEffectAnim( self.m_brokenImages, self.m_root, self.m_p2, size, "EGG_3", 9, index == self.m_times );
end

-- Override
function AnimationThrowEgg:endEffectCallback()
	self:stop();
end

function AnimationThrowEgg.stop( self )
	self.isPlaying = false;
	self:playAddCharmAnim( self.m_toId, self.tcharm, self.scharm, self.iconSize, self.m_p1, self.m_p2 );
	delete(self)--self:dtor();
end

function AnimationThrowEgg.dtor( self )
	if self.m_root then
		delete(self.m_root);
		self.m_root = nil;
	end
end

