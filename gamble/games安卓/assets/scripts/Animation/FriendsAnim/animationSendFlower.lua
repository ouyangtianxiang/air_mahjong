-- 好友 送花动画
require("Animation/FriendsAnim/animCurve");
local sendFlower_pin_map = require("qnPlist/sendFlowerPin")

require("Animation/FriendsAnim/animationShowCharm");
require("Animation/FriendsAnim/PropAnim");

AnimationSendFlower = class(PropAnim);


function AnimationSendFlower.ctor( self, p1, p2, tcharm, scharm, iconSize, tagmid, fromId, toId, times)

	self.m_p1 = p1;
	self.m_p2 = p2;
	self.m_h = 180;	--弧线高度
	self.m_pnum = 50;
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

function AnimationSendFlower.load( self )
	self.m_root = new(Node);
	self:addChild(self.m_root) 

	local startImage = UICreator.createImg(sendFlower_pin_map["flower.png"]);
	local rW, rH = startImage:getSize();
	--startAnim
	self.m_startDirs = {};
	for i=1,11 do
		table.insert(self.m_startDirs, sendFlower_pin_map[string.format("start_%d.png",i)]);
	end	
	self.m_starts = UICreator.createImages(self.m_startDirs);
	self.m_root:addChild(self.m_starts);
	self.m_starts:setVisible(false);
	local gW, gH = self.m_starts:getSize();
	self.m_starts:setPos(self.m_p1.x - gW/2 +rW/3, self.m_p1.y - gH/2 + 35);

	self.m_endDirs = {};
	for i=1,15 do
		table.insert(self.m_endDirs, sendFlower_pin_map[string.format("end_%d.png",i)]);
	end	
end

function AnimationSendFlower.play( self )
	if self.isPlaying then
		return;
	end
	self.isPlaying = true;
	self:playStartAnim();
end

--[[播放动画]]
function AnimationSendFlower.playStartAnim( self )

	if self.m_startAnim then
		delete(self.m_startAnim);
		self.m_startAnim = nil;
	end
	self.imgIndex = 0;
	self.m_startAnim = self.m_starts:addPropRotate(0,kAnimRepeat,95,0,0,0,kCenterDrawing);
	self.m_startAnim:setDebugName("AnimationSendFlower || self.m_startAnim");
	self.m_startAnim:setEvent(self, self.showStartOnTime);

	GameEffect.getInstance():play("CHEER_1");
end

function AnimationSendFlower.showStartOnTime( self )
	if self.m_starts.m_reses then
		local index = self.imgIndex;
		if index > 10 then
			index = 10;
			self.m_starts:setVisible(false);
		else
			self.m_starts:setImageIndex(index);
			self.m_starts:setVisible(true);
		end
	else
		delete(self.m_starts);
		self.m_starts = nil;
		-- self:stop();
		return;
	end
	self.imgIndex = self.imgIndex + 1;
	if self.imgIndex > 12 then
		delete(self.m_starts);
		self.m_starts = nil;
		self:throwTargetAnim();
	end

end

--[[]]
function AnimationSendFlower.throwTargetAnim( self )
	self:playThrowTargetAnim( sendFlower_pin_map["flower.png"], self.m_times, "CHEER_2", self.m_h, self.m_pnum, false );
end

-- Override
function AnimationSendFlower:throwTargetCallback( index, size )
	-- 这里的参数一般不会变动
	self:playEndEffectAnim( self.m_endDirs, self.m_root, self.m_p2, size, "CHEER_3", 16, index == self.m_times );
end

-- Override
function AnimationSendFlower:endEffectCallback()
	self:stop();
end

function AnimationSendFlower.stop( self )
	self.isPlaying = false;
	self:playAddCharmAnim( self.m_toId, self.tcharm, self.scharm, self.iconSize, self.m_p1, self.m_p2 );
	delete(self)--self:dtor();
end

function AnimationSendFlower.dtor( self )
	if self.m_starts then
		delete(self.m_starts);
		self.m_starts = nil;
	end

	if self.m_root then
		delete(self.m_root);
		self.m_root = nil;
	end
end

