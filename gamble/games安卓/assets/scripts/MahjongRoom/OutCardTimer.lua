
local timePin_map = require("qnPlist/timePin")


OutCardTimer = class(Node);

OutCardTimer.ctor = function ( self, limitTime )
	self.blockSeat = nil;
	self:setSize(130, 130);
	self.curTime = 0;

	self.timerBg = UICreator.createImg(timePin_map["frame.png"], 0, 0);

	--普通计时
	self.downArrow = UICreator.createImg(timePin_map["down.png"], 0, 0);
	self.rightArrow = UICreator.createImg(timePin_map["right.png"], 0, 0);
	self.upArrow = UICreator.createImg(timePin_map["up.png"], 0, 0);
	self.leftArrow = UICreator.createImg(timePin_map["left.png"], 0, 0);

	--提醒结束计时
	self.downArrowR = UICreator.createImg(timePin_map["downR.png"], 0, 0);
	self.rightArrowR = UICreator.createImg(timePin_map["rightR.png"], 0, 0);
	self.upArrowR = UICreator.createImg(timePin_map["upR.png"], 0, 0);
	self.leftArrowR = UICreator.createImg(timePin_map["leftR.png"], 0, 0);

	self:addChild( self.timerBg );
	self:addChild( self.downArrow );
	self:addChild( self.rightArrow );
	self:addChild( self.upArrow );
	self:addChild( self.leftArrow );
	self:addChild( self.downArrowR );
	self:addChild( self.rightArrowR );
	self:addChild( self.upArrowR );
	self:addChild( self.leftArrowR );
	self:hide();

	self.timerAnim = nil;
	self.timeText = new(Node);
	self.timeText:setSize(60, 60);
	self.timeText:setAlign(kAlignCenter);
	self.timerBg:addChild( self.timeText );

	self.tensImg = UICreator.createImg(timePin_map["0.png"]);
	self.tensImg:setPos(2 , 10);
	self.unitsImg = UICreator.createImg(timePin_map["0.png"]);
	self.unitsImg:setPos(28 , 10);
	self.timeText:addChild(self.tensImg);
	self.timeText:addChild(self.unitsImg);

	self:setTimeText(self.curTime);
end

OutCardTimer.setTimeText = function (self, time)
	if not self.timeText then
		return;
	end
	
	if time < 0 then
		time = 0;
	end
	if time > 99 then
		time = 99;
	end
	local units = 0;  --个位
	local tens = 0;  --十位
	units = time % 10;
	tens = getIntPart(time / 10) or 0;

	self.tensImg:setFile( timePin_map[tens..".png"] );
	self.unitsImg:setFile( timePin_map[units..".png"] );
	self.tensImg:setSize(self.tensImg.m_res.m_width,self.tensImg.m_res.m_height)
	self.unitsImg:setSize(self.unitsImg.m_res.m_width,self.unitsImg.m_res.m_height)
end

OutCardTimer.show = function ( self, seatId, timerLimitInSecond)
	delete( self.timerAnim );
	self.timerAnim = nil;
	self:setVisible(true);
	self.curTime = timerLimitInSecond or 0;
	self.blockSeat = seatId;
	self:setNeedPlayAudio(false);

	local setShowTip = function(obj , id , time)
		if time > 3 then
			obj:showTipAtPlayer(self.blockSeat);
			-- 隐藏红色提示
			obj:showTipAtPlayerR(nil);
			GameEffect.getInstance():stop("AUDIO_TIPS");
		else
			-- 倒计时提示音
			if time <= 3 and time > 0 and id == kSeatMine then
				self:setNeedPlayAudio(true);
			end
			if self.needPlay and time <= 3 and time > 0 then
				GameEffect.getInstance():play("AUDIO_TIPS");
			end
			-- 隐藏绿色提示
			obj:showTipAtPlayer(nil);
			obj:showTipAtPlayerR(self.blockSeat);
		end
		if time < 0 then
			time = 0;
		end
		obj:setTimeText(time);
	end

	setShowTip(self , seatId , self.curTime);
	self.timerAnim = new(AnimInt , kAnimRepeat , 0  , 1000 , 1000 , 0);
	self.timerAnim:setDebugName("OutCardTimer|self.timerAnim");
	self.timerAnim:setEvent(self, function ( self )
		self.curTime = self.curTime - 1;
		setShowTip(self , self.blockSeat , self.curTime);
	end);
end

function OutCardTimer.setNeedPlayAudio( self , flag )
	self.needPlay = flag;
	if not self.needPlay then
		GameEffect.getInstance():stop("AUDIO_TIPS");
	end
end

--绿色提示
OutCardTimer.showTipAtPlayer = function( self, player )
	self.upArrow:setVisible(false);
	if not self.upArrow:checkAddProp(0) then
		self.upArrow:removeProp(0);
	end
	self.downArrow:setVisible(false);
	if not self.downArrow:checkAddProp(0) then
		self.downArrow:removeProp(0);
	end
	self.rightArrow:setVisible(false);
	if not self.rightArrow:checkAddProp(0) then
		self.rightArrow:removeProp(0);
	end
	self.leftArrow:setVisible(false);
	if not self.leftArrow:checkAddProp(0) then
		self.leftArrow:removeProp(0);
	end
	local tempArrow = nil;
	if kSeatMine == player then
		tempArrow = self.downArrow;
	elseif kSeatRight == player then
		tempArrow = self.rightArrow;
	elseif kSeatTop == player then
		tempArrow = self.upArrow;
	elseif kSeatLeft == player then
		tempArrow = self.leftArrow;
	end
	if tempArrow then
		tempArrow:setVisible(true);
		local tempArrowAnim = tempArrow:addPropTransparency(0, kAnimLoop, 1000, 0, 1, 0.3);
		tempArrowAnim:setDebugName("OutCardTimer|tempArrowAnim");
	end
end

--红色提示
OutCardTimer.showTipAtPlayerR = function( self, player )
	self.upArrowR:setVisible(false);
	if not self.upArrowR:checkAddProp(1) then
		self.upArrowR:removeProp(1);
	end
	self.downArrowR:setVisible(false);
	if not self.downArrowR:checkAddProp(1) then
		self.downArrowR:removeProp(1);
	end
	self.rightArrowR:setVisible(false);
	if not self.rightArrowR:checkAddProp(1) then
		self.rightArrowR:removeProp(1);
	end
	self.leftArrowR:setVisible(false);
	if not self.leftArrowR:checkAddProp(1) then
		self.leftArrowR:removeProp(1);
	end
	local tempArrowR = nil;
	if kSeatMine == player then
		tempArrowR = self.downArrowR;
	elseif kSeatRight == player then
		tempArrowR = self.rightArrowR;
	elseif kSeatTop == player then
		tempArrowR = self.upArrowR;
	elseif kSeatLeft == player then
		tempArrowR = self.leftArrowR;
	end
	if tempArrowR then
		tempArrowR:setVisible(true);
		tempArrowR:addPropTransparency(1, kAnimLoop, 1000, 0, 1, 0.3);
	end
end

OutCardTimer.hide = function( self )
	delete( self.timerAnim );
    self.timerAnim = nil;
	self:setVisible(false);
	GameEffect.getInstance():stop();
	self:showTipAtPlayer(nil);
	self:showTipAtPlayerR(nil);
end

OutCardTimer.dtor = function( self )
    delete( self.timerAnim );
    self.timerAnim = nil;
	self:removeAllChildren();
	-- self.timeAaary = {};
end

