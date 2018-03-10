-- 好友 显示魅力值动画

local showCharm_pin_map = require("qnPlist/showCharmPin")


AnimationShowCharm = class(Node);

function AnimationShowCharm.ctor( self, p2, charmNum, iconSize )
	self.m_p2 = p2;
	self.charmNum = charmNum;
	self.iconSize = iconSize;
	self.isPlaying = false;
	self:load();
end

function AnimationShowCharm.load( self )
	self.m_root = new(Node);
	self.m_root:addToRoot();

	-- 汉字“魅力值”
	self.m_charm = UICreator.createImg(showCharm_pin_map["charm.png"]);
	self.m_root:addChild(self.m_charm);

	-- 数字
	local chNum = self.charmNum .. "";
	local len = string.len(chNum);
	local x,y = 0,0;
	local charmImgWidth = 0;
	local charImgHeight = 0;
	x = x + self.m_charm.m_res.m_width;
	for i=1, len do
		local url = nil;
		local char = string.sub(chNum, i, -(len+1-i));
		url = char .. ".png";
		local img = UICreator.createImg( showCharm_pin_map[url], x, y );
		x = x + img.m_res.m_width;
		charmImgWidth = charmImgWidth + img.m_res.m_width;
		if img.m_res.m_height > charImgHeight then
			charImgHeight = img.m_res.m_height;
		end
		self.m_root:addChild(img);
	end
	
	self.m_root:setPos(self.m_p2.x+self.iconSize.w/2-x/2, self.m_p2.y);
	self.m_root:setVisible(false);
end

function AnimationShowCharm.play( self )
	if self.isPlaying then
		return;
	end
	self.isPlaying = true;
	self:playStartAnim();
end

--[[播放动画]]
function AnimationShowCharm.playStartAnim( self )
	self.imgIndex = 0;
	self.m_charmAnim = self.m_root:addPropTranslate(0, kAnimNormal, 1000, 0, 0, 0, 20, 0 );
	self.m_root:setVisible(true);

	self.m_charmAnim:setDebugName("AnimationShowCharm || self.m_charmAnim");
	self.m_charmAnim:setEvent(self, self.showCharmOnTime);
end

function AnimationShowCharm.showCharmOnTime( self )
	self:stop();
end

function AnimationShowCharm.stop( self )
	self.isPlaying = false;
	if self.finishFunc and self.finishObj then
		self.finishFunc( self.finishObj );
	end
	self:dtor();
end

function AnimationShowCharm.dtor( self )
	if self.m_charm then
		delete(self.m_charm);
		self.m_charm = nil;
	end

	if self.m_root then
		delete(self.m_root);
		self.m_root = nil;
	end

	if self.img then
		delete(self.img);
		self.img = nil;
	end
end

function AnimationShowCharm.setOnFinishListener( self, obj, func )
	self.finishObj = obj;
	self.finishFunc = func;
end


