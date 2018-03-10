-- 升级动画
require("motion/EaseMotion");

AnimationUpGrade = class(Node);


function AnimationUpGrade.ctor( self )
 	
 	self.isPlaying = false;
	self.baseSequence = 10;

	self.screen_w = System.getScreenScaleWidth();
	self.screen_h = System.getScreenScaleHeight();

	self.starsEndPos = {};
	for i=1,7 do
		self.starsEndPos[i] = {};
	end
	self.starsEndPos[1].x = -270;
	self.starsEndPos[1].y = 0;
	self.starsEndPos[2].x = -240;
	self.starsEndPos[2].y = -100;
	self.starsEndPos[3].x = -110;
	self.starsEndPos[3].y = -180;
	
	self.starsEndPos[4].x = -0;
	self.starsEndPos[4].y = -250;

	self.starsEndPos[5].x = 110;
	self.starsEndPos[5].y = -180;
	self.starsEndPos[6].x = 240;
	self.starsEndPos[6].y = -100;
	self.starsEndPos[7].x = 270;
	self.starsEndPos[7].y = 0;

	self.arryPos = {};

	for i=1,7 do
		self.arryPos[i] = {};
		self.arryPos[i].pos = self:produceStarsCurve({x=0,y=0} ,self.starsEndPos[i]);
	end

	self:load();
end 


function AnimationUpGrade.load( self )

	self.m_root = new(Node);
	self.m_root:addToRoot();

	self.m_starNode = new(Node);
	self.m_root:addChild(self.m_starNode);
	self.m_starNode:setPos(self.screen_w/2, self.screen_h/2);

	-- 旋转光
	self.m_bgLight = UICreator.createImg("upGradeAnim/bglight.png");
	self.m_root:addChild(self.m_bgLight);
	self.m_bgLight:setVisible(false);
	local w,h = self.m_bgLight:getSize();
	self.m_bgLight:setPos(self.screen_w/2-w/2, self.screen_h/2-h/2);

	-- 帧动画
	self.imgDirs = {};
	for i=1,16 do
		table.insert(self.imgDirs,"upGradeAnim/upgrade_".. string.format("%d.png", i));
	end
	self.m_upgrades = UICreator.createImages(self.imgDirs);
	self.m_root:addChild(self.m_upgrades);
	self.m_upgrades:setVisible(false);
	local w,h = self.m_upgrades:getSize();
	self.m_upgrades:setPos(self.screen_w/2-w/2, self.screen_h/2-h/2);

	-- 小星星 7 颗
	self.m_stars = {};
	self.scale = 0.5;
	for i=1,7 do
		self.m_stars[i] = UICreator.createImg("upGradeAnim/star.png");
		self.m_starNode:addChild(self.m_stars[i]);
		if i == 4 then
			self.m_stars[i]:addPropScaleSolid(self.baseSequence-1, 0.9, 0.9, kCenterDrawing);
		elseif i~=2 and i~=6 then
			self.m_stars[i]:addPropScaleSolid(self.baseSequence-1, self.scale, self.scale, kCenterDrawing);
		end
		self.m_stars[i]:setAlign(kAlignCenter);
		self.m_stars[i]:setVisible(false);
	end
end

function AnimationUpGrade.play( self )
	if not self.m_root then return; end

	if self.isPlaying then return; end

	self.isPlaying = true;
	self:showFrames();
	self:addBgLightAnim();
	self:addStarsAnim();
end


function AnimationUpGrade.showFrames( self )
	if self.anim then
		delete(self.anim);
		self.anim = nil;
	end
	self.imgIndex = 0;

	self.anim = self.m_upgrades:addPropRotate(0,kAnimRepeat,120,0,0,0,kCenterDrawing);
	self.anim:setDebugName("AnimationUpGrade || self.anim");
	self.anim:setEvent(self, self.showFramesOnTime);
	self.m_upgrades:setVisible(false);
end


function AnimationUpGrade.showFramesOnTime( self )

	if self.m_upgrades.m_reses then
		local index = self.imgIndex;
		if index > 15 then
			index = 15;
		end
		if self.imgIndex == 28 then
			self.m_root:addPropTransparency(self.baseSequence+1, kAnimNormal, 800, 0, 1.0, 0.0);
		end
		self.m_upgrades:setImageIndex(index);
		self.m_upgrades:setVisible(true);
	else

		delete(self.m_upgrades);
		self.m_upgrades = nil;
		self:stop();
		return;
	end
	self.imgIndex = self.imgIndex + 1;
	if self.imgIndex > 35 then
		delete(self.m_upgrades);
		self.m_upgrades = nil;
		self:stop();
	end
end

-- 背景光动画
function AnimationUpGrade.addBgLightAnim( self )
	self.m_bgLight:setVisible(true);
	self.m_bgLight:addPropScale(self.baseSequence, kAnimNormal, 1500, 0, 0, 1, 0, 1, kCenterDrawing);
	self.m_bgLight:addPropRotate(self.baseSequence+1, kAnimRepeat, 4500, 0, 0, 360, kCenterDrawing);
end

-- 星星动画
function AnimationUpGrade.addStarsAnim( self )

	for i=1,7 do
		self.m_stars[i]:setVisible(true);
		-- 随机正反转 及转动速度
		if math.random(0,1) == 1 then
			self.m_stars[i]:addPropRotate(self.baseSequence, kAnimRepeat, 2000+math.random(100,600), 0,0,360,kCenterDrawing);
		else
			self.m_stars[i]:addPropRotate(self.baseSequence, kAnimRepeat, 2000+math.random(100,600), 0,360,0,kCenterDrawing);
		end
	end

	self.m_starAnim = new(EaseMotion, kEaseOut, 20, 200, 0);
	self.m_starAnim:setDebugName("AnimationUpGrade--self.m_starAnim")
	self.m_starIndex = 1;
	self.m_starAnim:setEvent(nil, function()

		-- 更新坐标
		for i=1,7 do
			self.m_stars[i]:setVisible(true);
			self.m_stars[i]:setPos(self.arryPos[i].pos[self.m_starIndex].x, self.arryPos[i].pos[self.m_starIndex].y);
		end
		self.m_starIndex = self.m_starIndex + 1;

		if self.m_starIndex >= #(self.arryPos[1].pos) then
			self.m_starIndex = #(self.arryPos[1].pos)
			delete(self.m_starAnim);
			self.m_starAnim = nil;
		end
	end);
end

--[[ 生成星星移动轨迹 ]]
function AnimationUpGrade.produceStarsCurve( self, p1, p2 , num)
	local pos = {};
	local a = (p1.y-p2.y) / (p1.x-p2.x);
	local b = p1.y - a*p1.x;
	local pnum = num or 20;
	local temp = (p2.x-p1.x);
	local flag = false;
	if (p2.x-p1.x) == 0 then
		temp = p2.y-p1.y;
		flag = true;
	end
	local step = temp/pnum;

	for i=1,pnum do
		pos[i] = {};
		if not flag then
			pos[i].x = p1.x + (i-1)*step;
			pos[i].y = a*pos[i].x + b;
		else
			pos[i].x = 0;
			pos[i].y = (i-1)*step;
		end
	end
	return pos;
end


function AnimationUpGrade.stop(self)
	if not self.m_root then
		return;
	end

	self.isPlaying = false;
	if self.m_bgLight then
		delete(self.m_bgLight);
		self.m_bgLight = nil;
	end

	if self.m_starAnim then
		delete(self.m_starAnim);
		self.m_starAnim = nil;
	end

	if self.m_stars then
		for i=1,#self.m_stars do
			delete(self.m_stars[i]);
		end
	end
	self.m_stars = nil;

	if self.m_upgrades then
		self.m_upgrades:removeAllChildren(true);
		delete(self.m_upgrades);
		self.m_upgrades = nil;
	end
end

function AnimationUpGrade.release(self)
	self:stop();
end

