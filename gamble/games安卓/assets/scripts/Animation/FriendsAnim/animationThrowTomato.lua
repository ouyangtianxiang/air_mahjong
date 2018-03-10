-- 好友 扔西红柿动画
require("motion/EaseMotion");
require("Animation/FriendsAnim/animCurve");


local throwTomato_pin_map = require("qnPlist/throwTomatoPin")
local smogs_pin_map       = require("qnPlist/smogsPin")

require("Animation/FriendsAnim/animationShowCharm");
require("Animation/FriendsAnim/PropAnim");

AnimationThrowTomato = class(PropAnim);


function AnimationThrowTomato.ctor( self, p1, p2, tcharm, scharm, iconSize, tagmid, fromId, toId, times)

	self.m_p1 = p1;
	self.m_p2 = p2;
	self.m_h = 80;	--弧线高度
	self.m_pnum = 45;
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

function AnimationThrowTomato.load( self )
	self.m_root = new(Node);
	self:addChild(self.m_root) 

	--西红柿破碎
	self.m_brokenImages = {};
	for i=1,8 do
		table.insert(self.m_brokenImages, throwTomato_pin_map[string.format("crack_tomato_%d.png",i)]);
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

function AnimationThrowTomato.play( self )
	if self.isPlaying then
		return;
	end
	self.isPlaying = true;
	self:playSmogAnim();
	self:throwTargetAnim();
end

--[[播放烟圈动画]]
function AnimationThrowTomato.playSmogAnim( self )

	if self.m_smogAnim then
		delete(self.m_smogAnim);
		self.m_smogAnim = nil;
	end
	self.imgIndex = 0;

	self.m_smogAnim = self.m_smogs:addPropRotate(0,kAnimRepeat,120,0,0,0,kCenterDrawing);
	self.m_smogAnim:setDebugName("AnimationThrowTomato || self.m_smogAnim");
	self.m_smogAnim:setEvent(self, self.showSmogsOnTime);

	GameEffect.getInstance():play("EGG_1");
end

function AnimationThrowTomato.showSmogsOnTime( self )
	if self.m_smogs.m_reses then
		local index = self.imgIndex;

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
function AnimationThrowTomato.throwTargetAnim( self )
	self:playThrowTargetAnim( throwTomato_pin_map["tomato.png"], self.m_times, "EGG_2", self.m_h, self.m_pnum, true );
end

-- Override
function AnimationThrowTomato:throwTargetCallback( index, size )
	-- 这里的参数一般不会变动
	self:playEndEffectAnim( self.m_brokenImages, self.m_root, self.m_p2, size, "EGG_3", 10, index == self.m_times );
end

-- Override
function AnimationThrowTomato:endEffectCallback()
	self:stop();
end

function AnimationThrowTomato.stop( self )
	self.isPlaying = false;
	self:playAddCharmAnim( self.m_toId, self.tcharm, self.scharm, self.iconSize, self.m_p1, self.m_p2 );
	delete(self)--self:dtor();
end

function AnimationThrowTomato.dtor( self )
	if self.m_root then
		delete(self.m_root);
		self.m_root = nil;
	end
end

