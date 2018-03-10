-- PropAnim.lua
-- Author: OnlynightZhang
-- 道具动画公共类，提供统一的播放完成动画等，方便管理以及释放动画
local throwRock_pin_map = require("qnPlist/throwRockPin")
PropAnim = class(Node);

PropAnim.ETC_ANIM_TYPE_ROCK = 1; -- 岩石
-- PropAnim.ETC_ANIM_TYPE_ROCK = 1; -- 岩石

function PropAnim:playThrowTargetAnim( targetImage, num, effectName, arcHeight, trackPointNum, isRotate )
	require("Animation/FriendsAnim/ThrowAnim");
	self.m_endEffectAnims = {};
	self.m_throwAnims = {};
	for i=1,num do
		table.insert( self.m_throwAnims, new(ThrowAnim, targetImage, self.m_root, self.m_p1, self.m_p2, effectName , arcHeight, trackPointNum, isRotate) );
	end

	self.m_delayThrowAnim = new(AnimInt,kAnimRepeat,0,1,150);
	self.m_delayThrowAnim:setDebugName("PropAnim || delayThrowAnim")
	self.m_throwAnimNums = 1;
	self.m_delayThrowAnim:setEvent( self, function ( self )
		self:orderPlayAnim( self.m_throwAnims, self.m_throwAnimNums );
		if self.m_throwAnimNums >= num then
			self.m_throwAnimNums = 1;
			delete( self.m_delayThrowAnim );
			self.m_delayThrowAnim = nil;
			return;
		end
		self.m_throwAnimNums = self.m_throwAnimNums + 1;
	end);
end

function PropAnim:orderPlayAnim( anims, index )
	anims[index]:setOnFinishListener( self, function( self )
		self:throwTargetCallback( index, anims[index]:getSize() );
	end);
	anims[index]:play();
end

function PropAnim:playSendTargetAnim( targetImage, num, effectName, isScale )
	require("Animation/FriendsAnim/SendAnim");
	self.m_endEffectAnims = {};
	self.m_throwAnims = {};
	for i=1,num do
		table.insert( self.m_throwAnims, new(SendAnim, targetImage, self.m_root, self.m_p1, self.m_p2, effectName , isScale) );
	end

	self.m_delayThrowAnim = new(AnimInt,kAnimRepeat,0,1,150);
	self.m_delayThrowAnim:setDebugName("PropAnim || delayThrowAnim")
	self.m_throwAnimNums = 1;
	self.m_delayThrowAnim:setEvent( self, function ( self )
		self.m_throwAnims[self.m_throwAnimNums]:setOnFinishListener( self, function( self )
			self:throwTargetCallback( self.m_throwAnimNums, self.m_throwAnims[self.m_throwAnimNums]:getSize() );
		end);
		self.m_throwAnims[self.m_throwAnimNums]:play();
		if self.m_throwAnimNums >= num then
			self.m_throwAnimNums = 1;
			delete( self.m_delayThrowAnim );
			self.m_delayThrowAnim = nil;
			return;
		end
		self.m_throwAnimNums = self.m_throwAnimNums + 1;
	end);
end

function PropAnim:throwTargetCallback( ... )
	-- TODO
end

-- params description:
-- targetImages 资源图片
-- parent 父节点
-- pos 坐标
-- startSize 开始动画图片的尺寸，一般从上一个动画处获取
-- stopFrame 结束动画所需帧数
-- isEnd 是否是结束动画
function PropAnim:playEndEffectAnim( targetImages, parent, pos, startSize, effectName, stopFrame, isEnd, etcAnimType )
	if not parent then 
		return 
	end 

	require("Animation/FriendsAnim/EndEffectAnim");
	local anim = new(EndEffectAnim, targetImages, parent, pos, startSize, stopFrame, isEnd );

	if etcAnimType == self.ETC_ANIM_TYPE_ROCK then
		local subParent = anim:getTarget();
		require("Animation/FriendsAnim/GlassFlakeAnim");
		local subAnim = new(GlassFlakeAnim, throwRock_pin_map["glass_flake.png"], subParent );
		table.insert( self.m_brokenGlassAnim, subAnim );
		subAnim:play();
	end

	anim:play();
	anim:setOnFinishListener( self, function( self )
		self:endEffectCallback();
	end);
	table.insert( self.m_endEffectAnims, anim );
	GameEffect.getInstance():play(effectName);
end

function PropAnim:endEffectCallback( ... )
	-- body
end

function PropAnim:playAddCharmAnim( toId, tcharm, scharm, iconSize, p1, p2 )
	local m_toid = PlayerManager.getInstance():getPlayerBySeat(toId);
	if m_toid then
		if m_toid.mid == self.tagmid then
			if not GameConstant.isSingleGame and (RoomScene_instance or MatchRoomScene_instance) then
				if scharm == 0 and tcharm == 0 then
					return 
				end 
				if 1 > scharm then
					self.showTCharm = new(AnimationShowCharm, p2, tcharm, iconSize);
					self.showTCharm:setDebugName("AnimationCheers--self.showTCharm");
				else
					self.showSCharm = new(AnimationShowCharm, p1, scharm, iconSize);
					self.showSCharm:setDebugName("AnimationCheers--self.showSCharm");
					self.showTCharm = new(AnimationShowCharm, p2, tcharm, iconSize);
					self.showTCharm:setDebugName("AnimationCheers--self.showTCharm");
					self.showSCharm:play();
				end
				self.showTCharm:play();
			end
		end
	end
end
