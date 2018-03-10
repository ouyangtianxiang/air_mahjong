-- 好友 kiss动画
require("Animation/FriendsAnim/animCurve");

local sendKissPin_map = require("qnPlist/sendKissPin")

require("Animation/FriendsAnim/animationShowCharm");
require("Animation/FriendsAnim/PropAnim");

AnimationSendKiss = class(PropAnim);


function AnimationSendKiss.ctor( self, p1, p2, tcharm, scharm, iconSize, tagmid, fromId, toId, times)

	self.m_p1 = p1;
	self.m_p2 = p2;
	self.m_h = 200;	--弧线高度
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

function AnimationSendKiss.load( self )
	self.m_root = new(Node);
	self:addChild(self.m_root) 

	local kissImg = UICreator.createImg(sendKissPin_map["redLip_start_6.png"]);
	local rW, rH = kissImg:getSize();
	--loveHeart
	local dirs = {};
	for i=1,5 do
		table.insert(dirs, sendKissPin_map[string.format("loveHeart_%d.png",i)]);
	end	
	self.m_loveHearts = UICreator.createImages(dirs);
	self.m_root:addChild(self.m_loveHearts);
	self.m_loveHearts:setVisible(false);
	local gW, gH = self.m_loveHearts:getSize();
	self.m_loveHearts:setPos(self.m_p1.x - gW/2 + rW/2-10, self.m_p1.y - gH/2 + rH/2);

	--redLip_start
	local dirs = {};
	for i=1,6 do
		table.insert(dirs, sendKissPin_map[string.format("redLip_start_%d.png",i)]);
	end	
	self.m_redLip_starts = UICreator.createImages(dirs);
	self.m_loveHearts:addChild(self.m_redLip_starts);
	self.m_redLip_starts:setVisible(false);
	self.m_redLip_starts:setAlign(kAlignCenter);

	self.m_kissEndImages = {};
	for i=1,8 do
		table.insert(self.m_kissEndImages, sendKissPin_map[string.format("kiss_end_%d.png",i)]);
	end

end

function AnimationSendKiss.play( self )
	if self.isPlaying then
		return;
	end
	self.isPlaying = true;
	self:playRedLipStartAnim();
end

--[[播放嘴唇出现动画]]
function AnimationSendKiss.playRedLipStartAnim( self )

	if self.m_redLipAnim then
		delete(self.m_redLipAnim);
		self.m_redLipAnim = nil;
	end
	self.imgIndex1 = 0;
	self.imgIndex2 = 0;

	self.m_redLipAnim = self.m_redLip_starts:addPropRotate(0,kAnimRepeat,120,0,0,0,kCenterDrawing);
	self.m_redLipAnim:setDebugName("AnimationSendKiss || self.m_redLipAnim");
	self.m_redLipAnim:setEvent(self, self.showRedLipOnTime);

	GameEffect.getInstance():play("ROSE_1");

end

function AnimationSendKiss.showRedLipOnTime( self )
	if self.m_redLip_starts.m_reses then
		local index1 = self.imgIndex1;
		local index2 = self.imgIndex2;
		if index1 > 5 then
			index1 = 5;
		elseif index2 > 4 then
			index2 = 4; 
		else
			self.m_redLip_starts:setImageIndex(index1);
			self.m_redLip_starts:setVisible(true);
			self.m_loveHearts:setImageIndex(index2);
			self.m_loveHearts:setVisible(true);
		end
	else
		delete(self.m_redLip_starts);
		self.m_redLip_starts = nil;
		self:stop();
		return;
	end
	self.imgIndex1 = self.imgIndex1 + 1;
	self.imgIndex2 = self.imgIndex2 + 1;
	if self.imgIndex2 > 4 then
		delete(self.m_redLip_starts);
		self.m_redLip_starts = nil;
		delete(self.m_loveHearts);
		self.m_loveHearts = nil;
		self:sendKissAnim();
	end

end

--[[send kiss]]
function AnimationSendKiss.sendKissAnim( self )
	self:playSendTargetAnim( sendKissPin_map["redLip_start_6.png"], self.m_times, "ROSE_2", self.m_h, self.m_pnum, false );
end

-- Override
function AnimationSendKiss:throwTargetCallback( index, size )
	-- 这里的参数一般不会变动
	self:playEndEffectAnim( self.m_kissEndImages, self.m_root, self.m_p2, size, "ROSE_3", 10, index == self.m_times );
end

-- Override
function AnimationSendKiss:endEffectCallback()
	self:stop();
end

function AnimationSendKiss.stop( self )
	self.isPlaying = false;
	self:playAddCharmAnim( self.m_toId, self.tcharm, self.scharm, self.iconSize, self.m_p1, self.m_p2 );
	delete(self)--self:dtor();
end

function AnimationSendKiss.dtor( self )

	if self.m_loveHearts then
		delete(self.m_loveHearts);
		self.m_loveHearts = nil;
	end

	if self.m_root then
		delete(self.m_root);
		self.m_root = nil;
	end
end

