-- 玩牌 放炮动画
require("Animation/FriendsAnim/animCurve");
require("MahjongPinTu/playCardsAnimPin")



AnimationFangPao = class(Node);

function AnimationFangPao.ctor( self, p1, obj, callback)
	self.m_p1 = p1;
	self.isPlaying = false;

	self.obj 		= obj;
	self.callback 	= callback;

	self.fangpaoFrames = {0,1,2,3,4,5,6,7,8,9,10};
	self:load();
end

function AnimationFangPao.load( self )
	self.m_root = new(Node);
	self.m_root:setPos(self.m_p1[1], self.m_p1[2]);
	 
	self:addChild(self.m_root)
	-- 背景旋转光
	local dirs = {};
	for i=1,2 do
		table.insert(dirs, light_bg_map[string.format("light_%d.png", i)]);
	end
	self.m_light = UICreator.createImages(dirs);
	self.m_root:addChild(self.m_light);
	self.m_light:setVisible(false);
	self.m_light:setLevel(300);

	-- 人物 12帧
	local dirs = {};
	for i=1, 11 do
		table.insert(dirs, fangPaoPin_map[string.format("fangpao%d.png", i)]);
	end
	self.m_fangpao = UICreator.createImages(dirs);
	self.m_root:addChild(self.m_fangpao);
	self.m_fangpao:setVisible(false);
	self.m_fangpao:setLevel(302);


	-- 字 1帧
	self.m_word = UICreator.createImg(fangPaoPin_map["fangpao12.png"]);
	self.m_root:addChild(self.m_word);
	self.m_word:setVisible(false);
	self.m_word:setLevel(301);
	self.m_word:setSize(133,77);
	self.m_word:setPos(60,80);

end

function AnimationFangPao.play( self )
	if self.isPlaying then
		return;
	end
	self.isPlaying = true;
	self:playFangPaoAnim();
	self:playLightAnim();
	self:playWordAnim();

end

function  AnimationFangPao.playFangPaoAnim(self)
	if self.m_fangPaoAnim then
		delete(self.m_fangPaoAnim);
		self.m_fangPaoAnim = nil;
	end
	
	self.fangpao_i = 1;
	self.m_fangPaoAnim = self.m_fangpao:addPropTranslate(0, kAnimRepeat, 200, 0, 0, 0, 0, 0);
	self.m_fangPaoAnim:setEvent(self, self.showFangPaoOnTime);
	self.m_fangpao:setVisible(false);
end


function  AnimationFangPao.playLightAnim(self)
	if self.m_lightAnim then
		delete(self.m_lightAnim);
		self.m_lightAnim = nil;
	end
	
	self.light_i    = 1;
	self.lightIndex = 0;
	self.m_lightAnim = self.m_light:addPropRotate(0, kAnimRepeat, 200, 0, 0, 0, 0, 0);
	self.m_lightAnim:setEvent(self, self.showLightOnTime);
	self.m_light:setVisible(false);
end

function  AnimationFangPao.playWordAnim(self)
	if self.m_wordAnim then
		delete(self.m_wordAnim);
		self.m_wordAnim = nil;
	end
	self.word_i = 1;
	self.m_wordAnim = self.m_word:addPropTranslate(0, kAnimRepeat, 200, 0, 0, 0, 0, 0);
	self.m_wordAnim:setEvent(self, self.showWordOnTime);
	self.m_word:setVisible(false);

end


function  AnimationFangPao.showFangPaoOnTime(self)
	if self.m_fangpao.m_reses then	
		if  self.fangpao_i < 12 then
			self.m_fangpao:setImageIndex(self.fangpaoFrames[self.fangpao_i]);
			self.m_fangpao:setVisible(true);
		elseif self.fangpao_i > 12 and self.fangpao_i < 14 then
			self.m_fangpao:setVisible(false);
		else
			self:stop();
		end
	else
		delete(self.m_fangpao);
		self.m_fangpao = nil;
		self:stop();
		return;
	end
	self.fangpao_i = self.fangpao_i + 1;
end

function  AnimationFangPao.showLightOnTime(self)
	if self.m_light.m_reses then
		if self.light_i > 8 then

			self.m_light:setVisible(true);
			self.m_light:setImageIndex(self.lightIndex);
			if 0 == self.lightIndex then
				self.lightIndex = 1;
			else
				self.lightIndex = 0;
			end
		else
			self.m_light:setVisible(false);
		end
	else
		delete(self.m_light);
		self.m_light = nil;
		self:stop();
		return;
	end
	self.light_i = self.light_i + 1;
end

function  AnimationFangPao.showWordOnTime(self)
	if  self.word_i > 8 then
		self.m_word:setVisible(true);
	end
	self.word_i = self.word_i + 1;
end


function AnimationFangPao.stop( self )
	self.isPlaying = false;
	if self.obj and self.callback then
		self.callback(self.obj);
	end

	delete(self);--self:dtor();
end


function AnimationFangPao.dtor( self )
	if self.m_light then
		delete(self.m_light);
		self.m_light = nil;
	end

	if self.m_word then
		delete(self.m_word);
		self.m_word = nil;
	end

	if self.m_fangpao then
		delete(self.m_fangpao);
		self.m_fangpao = nil;
	end

	if self.m_root then
		delete(self.m_root);
		self.m_root = nil;
	end
	self = nil;
end

