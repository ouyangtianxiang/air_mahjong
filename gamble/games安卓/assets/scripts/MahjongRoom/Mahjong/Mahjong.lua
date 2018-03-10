
Mahjong = class(Button, false);

MineFrameUp_Y = 330;

MineFrameUp_W = 98--94 ; -- 根据资源给出的大小
MineFrameUp_H = 142--144;

Mahjong.blank = "Commonx/blank.png";
Mahjong.ctor = function (self, baseDir, faceDir, offsetX, offsetY, ds)
	super(self, baseDir);
	offsetX = offsetX or 0;
	offsetY = offsetY or 0;

	if not faceDir or faceDir == "" then
	
	else
	    self.faceDir = faceDir;
	    self.faceImg = UICreator.createImg( self.faceDir, offsetX, offsetY);
		self:addChild(self.faceImg);
	end
	self.dscale = ds 
	self:setScale(ds)
	self.dY = 65; --frameUp的距离
	self:clearData();
end

Mahjong.setValue = function (self , value)
	self.value = value;
	local mType,val = getMahjongTypeAndValueByValue(value);
	self.mjType = mType;
end


Mahjong.dtor = function (self)
	self:removeAllChildren();
end

Mahjong.clearData = function (self)
	self.mjType = -1;
	self.value = 0;
	self.canBeTouchUp = false;
	self.canBeDrag = false;
	self.isFrameUp = false;
	self.isFrameUpNomal = false; -- 牌不变大的站立
	self.isCatchFrame = false;
	self.canBeOutCard = false;
	self.isMoving = false; -- 是否是正在被拖动的麻将
	self.seat = -1;
	self.hasAppear = false;
	self.isAlreadyHu = false;

	self.isAboveMahjong = false;
	self.isInsertPro = false;
end

Mahjong.frameUp = function (self)
	if not self.canBeTouchUp or self.isFrameUp then
		return;
	end

	self:setPos(self.m_x / System.getLayoutScale() - 4 , MahjongFrame.sMineY - self.dY);

	self:setScale(self.dscale * 1.1)

	if (self.m_addFanImg) then 
		self.m_addFanImg:setPos(0,65);
	end
	self.isFrameUp = true;

	HuCardTipsManager.getInstance():showJiaoTip( self, false );
end

Mahjong.frameDown = function (self)
	if not self.isFrameUp then
		return;
	end

	self:setPos(self.m_x / System.getLayoutScale() + 4 , MahjongFrame.sMineY);
	self.isFrameUp = false;
	
	if self.faceImg then
		self.faceImg:setPos( 0 , 0);
	end

	if (self.m_addFanImg) then 
		self.m_addFanImg:setPos(0,50);
	end

	self:setScale(self.dscale)

	HuCardTipsManager.getInstance():showJiaoTip( self, true );
end

Mahjong.frameUpNomal = function (self, needAnim)
	if not self.canBeTouchUp or self.isFrameUpNomal then
		return false;
	end
	if needAnim then
		local anim = self:addPropTranslate(1, kAnimNormal, 500, 0, 0, 0, 0, -self.dY );
		anim:setEvent(self, function ( self )
			self:setPos(self.m_x  / System.getLayoutScale(), MahjongFrame.sMineY - self.dY);
			self.isFrameUpNomal = true;
			self:removeProp(1);
		end);
	else
		--self:setPos(self.m_x , MineFrameUp_Y);

		self:setPos(self.m_x / System.getLayoutScale(), MahjongFrame.sMineY - self.dY);

		
		self.isFrameUpNomal = true;
	end
	self:setScale(self.dscale)
	return true;
end

Mahjong.setPos = function ( self, x, y )

	Button.setPos(self, x, y);

end

Mahjong.frameDownNomal = function (self, needAnim)
	if not self.isFrameUpNomal then
		return false;
	end
	if needAnim then
		local anim = self:addPropTranslate(1, kAnimNormal, 500, 0, 0, 0, 0, self.dY);
		anim:setEvent(self, function ( self )
			self:setPos(self.m_x / System.getLayoutScale(), MahjongFrame.sMineY);
			self.isFrameUpNomal = false;
			self:removeProp(1);
		end);
	else
		self:setPos(self.m_x / System.getLayoutScale(), MahjongFrame.sMineY);
		self.isFrameUpNomal = false;
	end
	self:setScale(self.dscale)
	return true;
end

Mahjong.setSize = function ( self, w, h )
	self.super.setSize(self, w, h);

	if self.faceImg then 
		self.faceImg:setSize(w, h)
	end
end


Mahjong.setScale = function ( self, xs, ys )

	xs = xs or 1
	ys = ys or xs or 1

	if not self:checkAddProp(0) then
		self:removeProp(0);
	end	
	
	self:addPropScaleSolid(0, xs, ys, kNotCenter);
	-- if self.faceImg then 
	-- 	self.faceImg:setScale(xs,ys)
	-- end 

 --    self:setSize(self.originW * xs , self.originH * ys);
end 


Mahjong.setFileImage = function (self , baseDir, faceDir, offsetX, offsetY, ds )
	offsetX = offsetX or 0;
	offsetY = offsetY or 0;
	self:setFile(baseDir);
	--self:setSize(baseDir.width, baseDir.height)
	if not faceDir or faceDir == "" then
		--self.faceDir = Mahjong.blank;
	else
		self.faceDir = faceDir;
		if not self.faceImg then 
			self.faceImg = UICreator.createImg( self.faceDir, offsetX, offsetY );
			self:addChild(self.faceImg);
		else
			self.faceImg:setFile(self.faceDir);
		end
		--self.faceImg:setSize(self.faceDir.width, self.faceDir.height);
		--self.faceImg:setPos(offsetX, offsetY);
	end
	self.dscale = ds
	self:setScale(self.dscale)
end

-- 设置是否响应点击事件
Mahjong.setEnableCustom = function (self , flag)
	self:setPickable(flag);
end

-- 变黑
Mahjong.setShadeWithImage = function (self)
	self:setColor(171 , 172 , 175);
end

-- 变亮
Mahjong.setOpenWithImage = function (self)
	self:setEnable(true);
end

-- 设置红色遮罩
Mahjong.setRedWithImage = function (self)
	self.isAlreadyHu = true;
	self:setColor(236 , 129 , 117); 
end

-- 是已出现的牌(绿色)
Mahjong.setHasAppear = function (self)
	self.hasAppear = true;
	self:setColor(115 , 174 , 89);
	--self:setTransparency(0.5);
end

-- 清除已出现牌
Mahjong.clearHasAppear = function (self)
	self.hasAppear = false;
	if self.isAlreadyHu then
		self:setRedWithImage();
	else
		self:setColor(255 , 255 , 255);
	end
end

-- 设置自定义的颜色
Mahjong.setCustomColor = function (self , r,g,b)
	self:setColor(r , g , b);
end

-- 判断麻将是否和某一点碰撞
Mahjong.isRectWithPoint = function ( self, x, y )
	return publ_isPointInRect(x, y, self.m_x / System.getLayoutScale(), self.m_y/ System.getLayoutScale(), self.m_width, self.m_height);
end

--------------------加番相关----------------------------------
--在麻将子上添加加番图片
Mahjong.setTheMahjongForAddFan = function(self,seat)
	if not self.m_addFanImg then 
		if seat == kSeatMine and not self.m_addFanImg then
			self.m_addFanImg = UICreator.createImg("Room/addfan/add_fan_icon_other.png",0,50);
		end
		self:addChild(self.m_addFanImg);
	end
end

--根据座位号在麻将子上添加加番图片
Mahjong.setTheMahjongChiPengGangAndHuForAddFan = function(self,seat)
	if not self.m_addFanImg then 
		if seat == kSeatMine then
			self.m_addFanImg = UICreator.createImg("Room/addfan/add_fan_icon.png",20,0);
		end
		self:addChild(self.m_addFanImg);
	else 
		if seat == kSeatMine then 
			self.m_addFanImg:setFile("Room/addfan/add_fan_icon.png");
			self.m_addFanImg:setSize(36,42);
			self.m_addFanImg:setPos(19,0);
		end
	end
end

--在麻将子上移除加番图片
Mahjong.removeTheMahjongForAddFan = function(self)
	if self.m_addFanImg then 
		self.removeChild(self.m_addFanImg,true);
	end
	self.m_addFanImg = nil;
end


