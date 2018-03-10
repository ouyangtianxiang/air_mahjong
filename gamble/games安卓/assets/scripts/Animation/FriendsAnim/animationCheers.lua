-- 好友 干杯动画
require("Animation/FriendsAnim/animCurve");

local cheers_pin_map = require("qnPlist/cheersPin")
local smogs_pin_map       = require("qnPlist/smogsPin")
require("Animation/FriendsAnim/animationShowCharm");
require("Animation/FriendsAnim/PropAnim");

AnimationCheers = class(PropAnim);


function AnimationCheers.ctor( self, p1, p2, tcharm, scharm, iconSize, tagmid, fromId, toId, times)

	self.m_p1 = p1;
	self.m_p2 = p2;
	self.m_h = 200;	--弧线高度
	self.m_pnum = 40;
	self.isPlaying = false;
	self.baseSequence = 10;
	self.tcharm = tcharm;
	self.scharm = scharm;
	self.iconSize = {w=iconSize.w*2, h=iconSize.h};
	self.tagmid = tagmid;
	self.m_toId = toId;
	self.m_times = times or 1;

	self:load();
end

function AnimationCheers.load( self )
	self.m_root = new(Node);
	self:addChild(self.m_root)

	--酒杯
	self.m_target = UICreator.createImg(cheers_pin_map["cup.png"]);
	self.m_root:addChild(self.m_target);
	self.m_target:setVisible(false);
	self.m_target:setPos(self.m_p1.x, self.m_p1.y);
	local rW, rH = self.m_target:getSize();

	--干杯
	self.m_cheersImages = {};
	for i=1,9 do
		table.insert(self.m_cheersImages, cheers_pin_map[string.format("cheers_%d.png",i)]);
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

function AnimationCheers.play( self )
	if self.isPlaying then
		return;
	end
	self.isPlaying = true;
	self:playSmogAnim();
	self:throwTargetAnim();
	self.m_time = os.time();
end

--[[播放烟圈动画]]
function AnimationCheers.playSmogAnim( self )

	if self.m_smogAnim then
		delete(self.m_smogAnim);
		self.m_smogAnim = nil;
	end
	self.imgIndex = 0;

	self.m_smogAnim = self.m_smogs:addPropRotate(0,kAnimRepeat,120,0,0,0,kCenterDrawing);
	self.m_smogAnim:setDebugName("AnimationCheers || self.m_smogAnim");
	self.m_smogAnim:setEvent(self, self.showSmogsOnTime);

	GameEffect.getInstance():play("CHEER_1");

end

function AnimationCheers.showSmogsOnTime( self )
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


function AnimationCheers.throwTargetAnim( self )
	self:playThrowTargetAnim( cheers_pin_map["cup.png"], self.m_times, "CHEER_2", self.m_h, self.m_pnum, false );
end

-- Override
function AnimationCheers:throwTargetCallback( index, size )
	-- 这里的参数一般不会变动
	self:playEndEffectAnim( self.m_cheersImages, self.m_root, self.m_p2, size, "CHEER_3", 12, index == self.m_times );
end

-- Override
function AnimationCheers:endEffectCallback()
	self:stop();
end

function AnimationCheers.stop( self )
	self.m_time = os.time() - self.m_time ;
	self.isPlaying = false;
	self:playAddCharmAnim( self.m_toId, self.tcharm, self.scharm, self.iconSize, self.m_p1, self.m_p2 );

	delete(self)--self:dtor();
end

function AnimationCheers.dtor( self )

	if self.m_targetAnim then
		delete(self.m_targetAnim);
		self.m_targetAnim = nil;
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

