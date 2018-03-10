-- name: AnimSmallCommonOpt.lua 小包碰动画
-- author: OnlynightZhang
-- des: 该动画专门为小包制作，只显示一张图片，所有玩牌中的操作动画都使用该类播放
local playCardsSmallAnimPin_map = require("qnPlist/playCardsSmallAnimPin")

AnimSmallCommonOpt = class();

AnimSmallCommonOpt.moveDownDeltaY = 200; -- Y轴位移
AnimSmallCommonOpt.moveUpDeltaY = 100; -- Y轴位移

-- pos: 传入一个table，里面包含两个整型的值代表其在屏幕上的坐标
function AnimSmallCommonOpt.ctor( self, pos, opt )
	self._pos = pos;
	-- self._pos[2] = self._pos[2] - self.moveDownDeltaY;
	if opt and opt == TYPE_FANGPAO then
		self._pos[1] = self._pos[1] + 30;
	end
	self.isPlaying = false;
	self._pengAnim = nil;
	self.opt = opt;
	self.createSuccess = self:_load(); -- 动画是否创建成功
end

function AnimSmallCommonOpt._load( self )
	self._root = new(Node);
	self._root:addToRoot();

	local path = nil;
	if self.opt then
		path = AnimSmallCommonOpt._img_paths[self.opt];
		if not path then
			return false;
		end
	else
		return false;
	end

	self._peng = UICreator.createImg(path);
	self._peng:setVisible( false );
	self._peng:setPos(self._pos[1], self._pos[2]);

	self._root:addChild(self._peng);

	return true;
end

function AnimSmallCommonOpt.play( self )
	if not self.createSuccess then
		DebugLog( "动画创建失败" );
		return;
	end

	if self.isPlaying then
		return;
	end
	self.isPlaying = true;
	self:_playPengAnim();
end

function AnimSmallCommonOpt._playPengAnim( self )
	if self._pengAnim then
		delete(self._pengAnim);
		self._pengAnim = nil;
	end

	-- kAnimRepeat kAnimNormal
	-- self:_moveDown();
	-- self:_delayToHide();
	self:_emerging();
	self._peng:setVisible( true );
end

function AnimSmallCommonOpt._emerging( self )
	-- body
	self._alphaAnim = self._peng:addPropTransparency(0,kAnimNormal, 500, 0, 0.0, 1.0);
	self._alphaAnim:setDebugName("AnimSmallCommonOpt._emerging|_alphaAnim");
	self._alphaAnim:setEvent(self, function (self)
		self:_delayToHide();
	end);
end

function AnimSmallCommonOpt._delayToHide( self )
	DebugLog( "AnimSmallCommonOpt._delayToHide" );
	if self.timerAnim then
		return;
	end
	self.timerAnim = self._peng:addPropRotate(2,kAnimNormal,1000,0,0,0,kCenterDrawing);
	self.timerAnim:setDebugName("AnimSmallCommonOpt._delayToHide|timerAnim");
	self.timerAnim:setEvent(self, self.stop);
end

function AnimSmallCommonOpt.stop( self )
	DebugLog( "AnimSmallCommonOpt.stop" );
	self.isPlaying = false;
	self.timerAnim = nil;
	self:dtor();
end


function AnimSmallCommonOpt.dtor( self )
	self._peng:setVisible( false );
	if self._peng then
		delete(self.m_peng);
		self._peng = nil;
	end

	if self._root then
		delete(self.m_root);
		self._root = nil;
	end
end

AnimSmallCommonOpt._img_paths = {
	[SpriteConfig.TYPE_PENG] = playCardsSmallAnimPin_map["peng.png"], -- 碰
	[SpriteConfig.TYPE_ZIMO] = playCardsSmallAnimPin_map["zimo.png"], -- 自摸
	[SpriteConfig.TYPE_CHADAJIAO] = playCardsSmallAnimPin_map["dajiao.png"], -- 查大叫
	[SpriteConfig.TYPE_FANGPAO] = playCardsSmallAnimPin_map["fangpao.png"], -- 放炮
	[SpriteConfig.TYPE_CHAHUAZHU] = playCardsSmallAnimPin_map["huazhu.png"], -- 查花猪
	[SpriteConfig.TYPE_GUAFENG] = playCardsSmallAnimPin_map["wind.png"], -- 刮风
	[SpriteConfig.TYPE_XIAYU] = playCardsSmallAnimPin_map["rain.png"] -- 下雨
}