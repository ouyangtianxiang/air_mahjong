-- 大厅 快速开始按钮动画
require("Animation/FriendsAnim/animCurve");
local quickStartGamePin_map = require("qnPlist/quickStartGamePin")

AnimationQuickStart = class(Node);

function AnimationQuickStart.ctor( self , p1, root)
	self.m_p1 = p1;
	self.isPlaying = false;

	-- -- offset,delay,size,pos
	-- self.starParam = {
	-- 	{  {startY= 24, endY=0},  800,  1.0, {x= 20, y=30}},
	-- 	{  {startY= 30, endY=0},    0,  1.3, {x= 50, y=25}},
	-- 	{  {startY= 12, endY=0},  900,  0.8, {x= 80, y=22}},
	-- 	{  {startY= 19, endY=0},    0,  1.1, {x=110, y=36}},
	-- 	{  {startY= 17, endY=0},  800,  0.7, {x=140, y=48}},
	-- 	{  {startY= 40, endY=0},    0,  1.2, {x=170, y=27}},
	-- 	{  {startY= 21, endY=0},  900,  1.0, {x=200, y=39}},
	-- 	{  {startY= 18, endY=0},    0,  1.4, {x=230, y=27}},
	-- 	{  {startY= 34, endY=0},  800,  1.3, {x=260, y=29}},
	-- };

	self.m_node = root;
	self:load();

end

function AnimationQuickStart.load( self )
	self.m_root = new(Node);
	self.m_root:setPos(self.m_p1[1], self.m_p1[2]);
	self.m_root:setSize(312,105);
	self.m_node:addChild(self.m_root);

	-- 按钮 9帧quickStartGamePin_map
	local dirs = {};
	for i=1, 9 do
		table.insert(dirs, quickStartGamePin_map[string.format("quickstart%d.png", i)]);
		--table.insert(dirs, quickStartPin_map[string.format("quickstart%d.png", i)]);
	end
	self.m_btn = UICreator.createImages(dirs);
	self.m_root:addChild(self.m_btn);
	self.m_btn:setVisible(false);
	local w,h = self.m_btn:getSize();
	self.m_btn:setLevel(300);
end

function AnimationQuickStart.play( self )
	if self.isPlaying then
		return;
	end
	self.isPlaying = true;

	self:playBtnAnim();
end

function AnimationQuickStart.playBtnAnim( self )
	if self.m_btnAnim then
		delete(self.m_btnAnim);
		self.m_btnAnim = nil;
	end

	self.btn_i = 0;
	self.m_btnAnim = self.m_btn:addPropTranslate(0, kAnimRepeat, 150, 2000, 0, 0, 0, 0);
	self.m_btnAnim:setEvent(self, self.showBtnOnTime);
	self.m_btnAnim:setDebugName("AnimationQuickStart.playBtnAnim");
	self.m_btn:setVisible(false);	
end

function AnimationQuickStart.showBtnOnTime( self )
	if self.m_btn.m_reses then
		if self.btn_i < 9  then
			self.m_btn:setImageIndex(self.btn_i);
			self.m_btn:setVisible(true);
		elseif self.btn_i < 40 then
			self.m_btn:setVisible(false);
		else
			self.btn_i = -1;
			self.m_btn:setVisible(false);
		end
	else
		delete(self.m_btn);
		self.m_btn = nil;
		self:stop();
		return;
	end
	self.btn_i = self.btn_i + 1;
end

-- function AnimationQuickStart.playStarAnim( self, starParam, i )
-- 	local offset = starParam[1];
-- 	local delay  = starParam[2];
-- 	local size   = starParam[3];

-- 	self.m_starAnim = self.m_star[i]:addPropScale(2, kAnimRepeat, 1300, delay, size, 0, size, 0, kCenterDrawing);
-- 	self.m_starAnim = self.m_star[i]:addPropTranslate(3, kAnimRepeat, 1300, delay, 0, 0, offset.startY,offset.endY);
-- 	self.m_starAnim = self.m_star[i]:addPropTransparency(4, kAnimRepeat, 1300, delay, 1, 0);

-- 	self.m_starAnim:setDebugName("AnimationQuickStart || self.m_starAnim");
-- 	self.m_star[i]:setVisible(true);
-- 	self.m_starAnim:setEvent();
-- end



function AnimationQuickStart.stop( self )
	self.isPlaying = false;
	self:removeFromSuper();
end


function AnimationQuickStart.dtor( self )
	self:removeAllChildren();
end

