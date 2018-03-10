require("MahjongRoom/Mahjong/MahjongFrame");
require("MahjongRoom/Mahjong/Mahjong")
require("MahjongConstant/OperatType");
require("MahjongConstant/MahjongImageFunction");
-- require("MahjongConstant/Display")

MahjongManager = class();

local Mahjong_Mine_Level = 2;
local Mahjong_Right_Level = 1;
local Mahjong_Top_Level = 1;
local Mahjong_Left_Level = 1;

local showBigMahjongOnCenterPos = {
	{display.cx - 37, display.bottom - 300},
	{display.right - 400, display.cy - 80},
	{display.cx - 37 , 140},
	{display.left + 400 , display.cy - 80}
}

MahjongManager.ctor = function (self , root , scene)
	self.mahjongFrame = new(MahjongFrame);

	-- for i = 1, 4 do
	-- 	showBigMahjongOnCenterPos[i][1],showBigMahjongOnCenterPos[i][2] = self.mahjongFrame:getBigDiscardPos(i - 1);
	-- end

	self.scene = scene;
	self.myself = PlayerManager.getInstance():myself();
	-- 动画

	-- 发牌动画
	self.dealCardAnim = nil;
	self.hasDealCardNum = 0;

	self.root = root;

	self.mineNode = new(Node);
	self.mineNode:setLevel(Mahjong_Mine_Level);
	self.mineToolBar = new(Node);
	self.mineToolBar:setLevel(Mahjong_Right_Level);
	self.rightNode = new(Node);
	self.rightNode:setLevel(Mahjong_Right_Level);
	self.topNode = new(Node);
	self.topNode:setLevel(Mahjong_Top_Level);
	self.leftNode = new(Node);
	self.leftNode:setLevel(Mahjong_Left_Level);

	self.root:addChild(self.mineToolBar);
	self.root:addChild(self.mineNode);
	self.root:addChild(self.rightNode);
	self.root:addChild(self.topNode);
	self.root:addChild(self.leftNode);

	-- 创建打出牌的node
	self.mineDiscardNode = new(Node);
	self.mineDiscardNode:setPos(self.mahjongFrame:getDiscardNodePos(kSeatMine));
	self.mineDiscardNode:setSize(self.mahjongFrame:getDiscardNodeSize(kSeatMine));
	self.mineNode:addChild(self.mineDiscardNode);
	self.mineDiscardNode:setLevel(-1);

	self.rightDiscardNode = new(Node);
	self.rightDiscardNode:setPos(self.mahjongFrame:getDiscardNodePos(kSeatRight));
	self.rightDiscardNode:setSize(self.mahjongFrame:getDiscardNodeSize(kSeatRight));
	self.rightNode:addChild(self.rightDiscardNode);

	self.topDiscardNode = new(Node);
	self.topDiscardNode:setPos(self.mahjongFrame:getDiscardNodePos(kSeatTop));
	self.topDiscardNode:setSize(self.mahjongFrame:getDiscardNodeSize(kSeatTop));
	self.topNode:addChild(self.topDiscardNode);

	self.leftDiscardNode = new(Node);
	self.leftDiscardNode:setPos(self.mahjongFrame:getDiscardNodePos(kSeatLeft));
	self.leftDiscardNode:setSize(self.mahjongFrame:getDiscardNodeSize(kSeatLeft));
	self.leftNode:addChild(self.leftDiscardNode);

	self.showBigMahjongOnCenter = {}
	self.curShowBigMahjongOnCenter = nil

	self:clearData();
end

MahjongManager.dtor = function (self)
	DebugLog("MahjongManager dtor");
	self:clearData();
	delete(self.mahjongFrame);
	self.mahjongFrame = nil;
	delete(self.dealCardAnim);
	self.dealCardAnim = nil;

	self.mineNode:removeAllChildren();
	self.rightNode:removeAllChildren();
	self.topNode:removeAllChildren();
	self.leftNode:removeAllChildren();
	self.root:removeChild(self.mineNode,true);
	self.root:removeChild(self.rightNode,true);
	self.root:removeChild(self.topNode,true);
	self.root:removeChild(self.leftNode,true);
	self.mineNode = nil;
	self.rightNode = nil;
	self.topNode = nil;
	self.leftNode = nil;
end

MahjongManager.clearData = function (self)
	self.touchTimes = 0;

	self.curShowBigMahjongOnCenter = nil

	delete(self.dealCardAnim);
	self.dealCardAnim = nil;
	delete(self.insertAnim1);
	self.insertAnim1 = nil;
	for k, v in pairs(self.showBigMahjongOnCenter) do
		v:setVisible(false)
	end

	self.mineInHandCards = {};
	self.rightInHandCards = {};
	self.topInHandCards = {};
	self.leftInHandCards = {};

	self.mineDiscardCards = {};
	self.rightDiscardCards = {};
	self.topDiscardCards = {};
	self.leftDiscardCards = {};

	self.mineBlockCards = {};
	self.rightBlockCards = {};
	self.topBlockCards = {};
	self.leftBlockCards = {};

	for k = kSeatMine , kSeatLeft do
--		self:getSeatDiscardNodeBySeat(k):packDrawing(false);
		self:getSeatDiscardNodeBySeat(k):removeAllChildren();
		self:getSeatNodeBySeat(k):removeChild(self:getSeatDiscardNodeBySeat(k));
		self:getSeatNodeBySeat(k):removeAllChildren();
		self:getSeatNodeBySeat(k):addChild(self:getSeatDiscardNodeBySeat(k));
	end
end

function MahjongManager:initShowCenterMahjong(seat)
	if self.showBigMahjongOnCenter[seat+1] then
		local mahjongType = MahjongViewManager.getInstance():getMahjongType(seat)
		self.showBigMahjongOnCenter[seat+1]:setFileImage(getShowCenterImageFileBySeat(seat, 1, mahjongType))
	else
		self.showBigMahjongOnCenter[seat+1] = new(Mahjong, getShowCenterImageFileBySeat(seat, 1, mahjongType))
		self.showBigMahjongOnCenter[seat+1]:setLevel(100)
		self.showBigMahjongOnCenter[seat+1]:setEnableCustom(false);
		self.showBigMahjongOnCenter[seat+1]:setOpenWithImage();
		self.root:addChild(self.showBigMahjongOnCenter[seat+1])
	end
	self.showBigMahjongOnCenter[seat+1]:setVisible(false)
end

MahjongManager.changeFrameCount = function ( self, count )
	-- body
	if self.mahjongFrame:getFrameCount() ~= count then
		self.mahjongFrame = new(MahjongFrame, count);
	end
end

-- 测试牌
MahjongManager.test = function (self)
	for i = 1,kMahjongMaxNum do
		local localValue = 0x10 + (i % 9) + 1;
		local mahjong = new(Mahjong,"Room/majiangzi/own_hand_0x"..localValue..".png");
		mahjong.canBeTouchUp = true;
		mahjong:setVisible(false);
		mahjong.value = localValue;
		--table.insert(self.mineInHandCards , mahjong);
		mahjong:setEventTouch(self , MahjongManager.mahjongOnTouchUp);
		self.mineNode:addChild(mahjong);
	end
end

-- 绘制手牌  变化之后也可调用
MahjongManager.drawInhandCards = function (self , seat)
	if kSeatMine == seat and not self:judgeMineInhandCards() then
		return;
	end
	local inHandCards = self:getInHandCardsBySeat(seat);
	local blockCards = self:getBlockCardsBySeat(seat);

	local touchUpTable = {};  -- 先不允许点击牌
	if kSeatMine == seat then
		self:clearHasAppearOnTableCard();
		for k , v in pairs(inHandCards) do
			table.insert(touchUpTable, (v.canBeTouchUp or false) );
			v.canBeTouchUp = false;
		end
		self.touchTimes = 0;
	end
	for k , v in pairs(inHandCards) do
		v.isFrameUp = false;
		v.isCatchFrame = false;
		v.isMoving = false;
		v:setPos(self.mahjongFrame:getInhandFrame(seat , k , #blockCards));
		if kSeatMine == seat then
			v:setFileImage(getInHandImageFileBySeat(seat , v.value, MahjongViewManager.getInstance():getMahjongType(kSeatMine)));
			v:setSize(MineInHandCard_W , MineInHandCard_H);
		end
		if k == #inHandCards and needToDiscard(#inHandCards) then
			v.isCatchFrame = true;
			v:setPos(self.mahjongFrame:getCatchFrame(seat,#inHandCards - 1,#blockCards));
		end
	end
	if kSeatMine == seat then -- 恢复牌的点击状态
		for k , v in pairs(inHandCards) do
			v.canBeTouchUp = touchUpTable[k];
		end
	else
		-- self:getSeatNodeBySeat(seat):packDrawing(false);
		-- self:getSeatNodeBySeat(seat):packDrawing(true);
	end
end

-- 设置所有人的手牌 并且绘制
MahjongManager.setPlayersMahjong = function (self , mahjongArray)
	-- 先清空所有的麻将
	self:clearData();

	self:creatMineMahjong(mahjongArray);
	self:creatOtherPlayerMahjong(kSeatRight);
	self:creatOtherPlayerMahjong(kSeatTop);
	self:creatOtherPlayerMahjong(kSeatLeft);

	self:drawInhandCards(kSeatMine);
	self:drawInhandCards(kSeatRight);
	self:drawInhandCards(kSeatTop);
	self:drawInhandCards(kSeatLeft);

	self:startGameDealCardAnim();
	self.hasDealCardNum = 0;
end

-- 重新创建自己的手牌
MahjongManager.recreateMyHandCard = function ( self, cardValueList )
	self.mineInHandCards = {};
	if self.mineNode then
		self:getSeatDiscardNodeBySeat(kSeatMine):removeAllChildren();
		self.mineNode:removeChild(self:getSeatDiscardNodeBySeat(kSeatMine));
		self.mineNode:removeAllChildren();
		self.mineNode:addChild(self:getSeatDiscardNodeBySeat(kSeatMine));
	end
	self:creatMineMahjong(cardValueList);
	for k,v in pairs(self.mineInHandCards) do
		v:setVisible(true);
	end
	self:drawInhandCards(kSeatMine);
end

-- 发牌动画
MahjongManager.startGameDealCardAnim = function (self)
	local time = 0;
	if 0 ~= self.hasDealCardNum then
		time = 500;
	end
	self.dealCardAnim = new(AnimInt , kAnimNormal , 0 , 1 , time , 0);
	self.dealCardAnim:setEvent(self , self.dealCardAnimAnimStop);
end

-- 每次发牌动画回调
MahjongManager.dealCardAnimAnimStop = function (self)
	local kMax = kMahjongMaxNum;
	if self.hasDealCardNum + 4 <= kMax then
		kMax = self.hasDealCardNum + 4;
	end
	GameEffect.getInstance():play("AUDIO_DC");

	for k = kSeatMine , kSeatLeft do
		local inHandCards = self:getInHandCardsBySeat(k);
		for i = self.hasDealCardNum + 1,kMax do
			if inHandCards[i] then
				inHandCards[i]:setVisible(true);
			end
		end
	end

	self.hasDealCardNum = self.hasDealCardNum + 4;

	delete(self.dealCardAnim);
	self.dealCardAnim = nil;
	if self.hasDealCardNum >= kMahjongMaxNum then
		self:onDealCardFinish();
		return ;
	end
	self:startGameDealCardAnim();
end

MahjongManager.onDealCardFinish = function ( self )
	self:sortInHandCards(self.myself.dingQueType);
	self:drawInhandCards(kSeatMine);
	--self:setMineInHandCardsCanNotDoAnything();
	if not needToDiscard(#self.mineInHandCards) then
		self:setMineInhandCardsShade();
	end
	self.scene:createAddFan();
end

-- 设置牌不能响应事件
MahjongManager.setMineInHandCardsEnbale = function (self , flag)
	for k , v in pairs(self.mineInHandCards) do
		v:setEnableCustom(flag);
	end
end

-- 设置自己的手牌不能被点击站起
MahjongManager.setMineInHandCardsCanNotBeTouch = function ( self)
	self:setMineInHandCardsEnbale(false);
	for k , v in pairs(self.mineInHandCards) do
		v.canBeTouchUp = false;
	end
end

-- 设置手牌可以被点击站起
MahjongManager.setMineInHandCardsCanBeTouch = function ( self)
	self:setMineInHandCardsEnbale(true);
	for k , v in pairs(self.mineInHandCards) do
		v.canBeTouchUp = true;
	end
end

-- 设置手牌变黑
MahjongManager.setMineInhandCardsShade = function (self)
	for k , v in pairs(self.mineInHandCards) do
		v:setShadeWithImage();
	end
end

-- 设置手牌变亮
MahjongManager.setMineInhandCardsOpen = function (self)
	for k , v in pairs(self.mineInHandCards) do
		v:setOpenWithImage();
	end
end

-- 设置手牌不能被打出
MahjongManager.setMineInHandCardsCanNotOut = function (self)
	for k , v in pairs(self.mineInHandCards) do
		v.canBeOutCard = false;
	end
end

-- 设置手牌可以被打出
MahjongManager.setMineInHandCardsCanOut = function (self)
	for k , v in pairs(self.mineInHandCards) do
		v.canBeOutCard = true;
	end
end

-- 当不能打牌时 设置手牌的状态
MahjongManager.setMineInHandCardsWhenWait = function (self)
	self:setMineInhandCardsShade();
	self:setMineInHandCardsCanNotOut();
	self:setMineInHandCardsCanBeTouch();
end

-- 当打牌时 设置手牌的状态
MahjongManager.setMineInHandCardsWhenOutCard = function (self)
	if self.myself.isHu then
		return;
	end
	self:setMineInhandCardsShade();
	self:setMineInHandCardsCanNotOut();
	self:setMineInHandCardsCanNotBeTouch();
	local dingQue = self.myself.dingQueType;
	if self:getMineCardTypeNum(dingQue) > 0 then
		for k , v in pairs(self.mineInHandCards) do
			local mType = getMahjongTypeAndValueByValue(v.value);
			if mType == dingQue then
				v.canBeOutCard = true;
				v.canBeTouchUp = true;
				v:setOpenWithImage();
				v:setEnableCustom(true);
			end
		end
		return;
	end
	for k , v in pairs(self.mineInHandCards) do
		v.canBeOutCard = true;
		v.canBeTouchUp = true;
		v:setOpenWithImage();
		v:setEnableCustom(true);
	end
end

-- 设置血流成河摸牌时的手牌的状态
MahjongManager.setMineInHandCardsWhenOutCardXLCH = function (self)
	local inHandCards = self:getInHandCardsBySeat(kSeatMine);
	if self.myself.isHu then
		self:setMineInHandCardsCanNotDoAnything();
		inHandCards[#inHandCards].canBeOutCard = true;
		inHandCards[#inHandCards].canBeTouchUp = true;
		inHandCards[#inHandCards]:setOpenWithImage();
		inHandCards[#inHandCards]:setEnableCustom(true);
	else
		self:setMineInHandCardsWhenOutCard();
	end
end

-- 当有操作时 设置手牌的状态
MahjongManager.setMineInHandCardsWhenOperate = function (self)
	self:setMineInhandCardsShade();
	self:setMineInHandCardsCanNotOut();
	self:setMineInHandCardsCanNotBeTouch();
end

-- 设置手牌 变黑且不能响应任何事件
MahjongManager.setMineInHandCardsCanNotDoAnything = function (self)
	self:setMineInhandCardsShade();
	self:setMineInHandCardsCanNotOut();
	self:setMineInHandCardsCanNotBeTouch();
end

-- 当胡牌时 设置手牌的状态
MahjongManager.setInHandCardsWhenHuBySeat = function (self , seat)
	local inHandCards = self:getInHandCardsBySeat(seat);
	local blockCards = self:getBlockCardsBySeat(seat);
	if kSeatMine == seat then
		self:setMineInhandCardsOpen();
		self:setMineInHandCardsCanNotOut();
		self:setMineInHandCardsCanNotBeTouch();
		for k , v in pairs(inHandCards) do
			v:setFileImage(getHuCardImageFileBySeat(seat , v.value, MahjongViewManager.getInstance():getMahjongType(seat)));
		end
	else
		for k , v in pairs(inHandCards) do
			v:setPos(self.mahjongFrame:getHuInHandCardFrame(seat , k , #blockCards));
			if kSeatRight == seat then
				v:setSize(RightDiscardCard_W , RightDiscardCard_H);
			elseif kSeatLeft == seat then
				v:setSize(LeftDiscardCard_W , LeftDiscardCard_H);
			end
			v:setFileImage(getHuCardImageFileBySeat(seat, 0, MahjongViewManager.getInstance():getMahjongType(seat)));
		end
	end
end

-- 设置胡的牌
MahjongManager.setHuCardBySeat = function (self , seat , card , huType , isOver)
	local inHandCards = self:getInHandCardsBySeat(seat);
	local mahjong = nil;
	local handCardsNum = #inHandCards
	if needToDiscard(#inHandCards) then
		mahjong = inHandCards[#inHandCards];
	else
		mahjong = self:playerCatchCard(seat , card);
		handCardsNum = handCardsNum + 1
	end
	mahjong:setPos(self.mahjongFrame:getHuCardFrame(seat,handCardsNum));
	if kSeatRight == seat then
		mahjong:setSize(RightDiscardCard_W , RightDiscardCard_H);
	elseif kSeatLeft == seat then
		mahjong:setSize(LeftDiscardCard_W , LeftDiscardCard_H);
	end
	mahjong:setOpenWithImage();
	mahjong:setEnableCustom(false);
	mahjong.canBeOutCard = false;
	mahjong.canBeTouchUp = false;
	mahjong.value        = card
	if kSeatMine == seat and not isOver then
		mahjong:setFileImage(getHuCardImageFileBySeat(seat , card, MahjongViewManager.getInstance():getMahjongType(seat)));
	else
		mahjong:setFileImage(getPengGangImageFileBySeat(seat , card, MahjongViewManager.getInstance():getMahjongType(seat)));
	end
end

-- 设置一局结束后玩家的手牌
MahjongManager.setInHandCardsWhenGameOver = function (self , seat ,cards)
	local inHandCards = self:getInHandCardsBySeat(seat);
	local blockCards = self:getBlockCardsBySeat(seat);
	DebugLog("一局结束后，显示自己的手牌");
	if kSeatMine == seat then
		self:setMineInhandCardsOpen();
		self:setMineInHandCardsCanNotOut();
		self:setMineInHandCardsCanNotBeTouch();
		for k , v in pairs(inHandCards) do
			if k > #cards then
				break;
			end
			v.value = cards[k];
			v.mjType = getMahjongTypeAndValueByValue(cards[k]);
			v:setEnableCustom(false);
			v:setFileImage(getGameOverCardImageFileBySeat(seat , v.value, MahjongViewManager.getInstance():getMahjongType(seat)));
		end
	else
		for k , v in pairs(inHandCards) do
			if k > #cards then
				break;
			end
			v:setPos(self.mahjongFrame:getHuInHandCardFrame(seat , k , #blockCards));
			if kSeatRight == seat then
				v:setSize(RightDiscardCard_W , RightDiscardCard_H);
			elseif kSeatLeft == seat then
				v:setSize(LeftDiscardCard_W , LeftDiscardCard_H);
			end
			v.value = cards[k];
			v.mjType = getMahjongTypeAndValueByValue(cards[k]);
			v:setFileImage(getGameOverCardImageFileBySeat(seat , v.value, MahjongViewManager.getInstance():getMahjongType(seat)));
		end
	end
end

-- 某个玩家抓到一张牌
MahjongManager.playerCatchCard = function (self , seat , value)
	local mahjong = nil;
	local inHandCards = self:getInHandCardsBySeat(seat);
	local blockCards = self:getBlockCardsBySeat(seat);
	if kSeatMine == seat then
		mahjong = self:creatAMineInHandCard(value);
		self.newCard = mahjong; --保存新抓牌的引用
		mahjong.isCatchFrame = true;
		local animID = mahjong:addPropTranslate(1, kAnimNormal, 200, 0, 0, 0, -65, 0);
		local ret = animID and animID:setEvent(nil,function () mahjong:removeProp(1); end );

	elseif kSeatRight == seat then
		mahjong = new(Mahjong , getInHandImageFileBySeat(seat , 0, MahjongViewManager.getInstance():getMahjongType(seat)));
		mahjong:setLevel(-17);
		mahjong:setEnableCustom(false);
		self.rightNode:addChild(mahjong);
		local animID = mahjong:addPropTranslate(1, kAnimNormal, 200, 0, 0, 0, -30, 0);
		local ret = animID and animID:setEvent(nil,function () mahjong:removeProp(1); end );
	elseif kSeatTop == seat then
		mahjong = new(Mahjong , getInHandImageFileBySeat(seat , 0, MahjongViewManager.getInstance():getMahjongType(seat)));
		mahjong:setEnableCustom(false);
		self.topNode:addChild(mahjong);
		local animID = mahjong:addPropTranslate(1, kAnimNormal, 200, 0, 0, 0, -20, 0);
		local ret = animID and animID:setEvent(nil,function () mahjong:removeProp(1); end );
	elseif kSeatLeft == seat then
		mahjong = new(Mahjong , getInHandImageFileBySeat(seat , 0, MahjongViewManager.getInstance():getMahjongType(seat)));
		mahjong:setEnableCustom(false);
		self.leftNode:addChild(mahjong);
		local animID = mahjong:addPropTranslate(1, kAnimNormal, 200, 0, 0, 0, -30, 0);
		local ret = animID and animID:setEvent(nil,function () mahjong:removeProp(1); end );
	end
	mahjong:setPos(self.mahjongFrame:getCatchFrame(seat,#inHandCards,#blockCards));
	table.insert(inHandCards , mahjong);
	return mahjong;
end

-- 创建一张自己的手牌
MahjongManager.creatAMineInHandCard = function (self , value)
	local mahjong = new(Mahjong , getInHandImageFileBySeat(kSeatMine , value, MahjongViewManager.getInstance():getMahjongType(kSeatMine)));
	mahjong.canBeTouchUp = true;
	mahjong:setShadeWithImage();
	mahjong:setValue(value);
	mahjong:setLevel(1);
	mahjong:setEventTouch(self, MahjongManager.mahjongOnTouchUp);
	self.mineNode:addChild(mahjong);
	return mahjong;
end

-- 创建自己的手牌
MahjongManager.creatMineMahjong = function (self , mahjongArray)
	self:initShowCenterMahjong(kSeatMine)
	self.mineInHandCards = {};
	for i = 1,#mahjongArray do
		local mahjong = self:creatAMineInHandCard(mahjongArray[i]);
		mahjong:setVisible(false);
		table.insert(self.mineInHandCards , mahjong);
	end
end

-- 创建其他人的手牌
MahjongManager.creatOtherPlayerMahjong = function (self , seat , count)
	self:initShowCenterMahjong(seat)
	local inHandCards = self:getInHandCardsBySeat(seat);
	count = count or self.mahjongFrame:getFrameCount() - 1;
	for i = 1 , count do
		local mahjong = nil;
		if kSeatRight == seat then
			mahjong = new(Mahjong , getInHandImageFileBySeat(seat , 0, MahjongViewManager.getInstance():getMahjongType(seat)));
			mahjong:setLevel(-i);
			self.rightNode:addChild(mahjong);
		elseif kSeatTop == seat then
			mahjong = new(Mahjong , getInHandImageFileBySeat(seat , 0, MahjongViewManager.getInstance():getMahjongType(seat)));
			self.topNode:addChild(mahjong);
		elseif kSeatLeft == seat then
			mahjong = new(Mahjong , getInHandImageFileBySeat(seat , 0, MahjongViewManager.getInstance():getMahjongType(seat)));
			self.leftNode:addChild(mahjong);
		end
		mahjong:setEnableCustom(false);
		table.insert(inHandCards,mahjong);
		mahjong:setVisible(false);
	end
end

-- 显示当前牌已出现在牌桌上的牌
MahjongManager.showHasAppearOnTableCard = function (self , card)
	self:clearHasAppearOnTableCard();
	for k = kSeatMine , kSeatLeft do
		local flag = false;
		local discards = self:getDiscardCardsBySeat(k);   -- 打出去的牌
		for r , t in pairs(discards) do
			if t.value == card then
				t:setHasAppear();
				flag = true;
			end
		end

		if flag then
--			self:getSeatDiscardNodeBySeat(k):packDrawing(false);
			-- self:getSeatDiscardNodeBySeat(k):packDrawing(true);
		end

		local blockCards = self:getBlockCardsBySeat(k);   -- 碰杠牌
		for r , t in pairs(blockCards) do
			if t.card == card then
				for i , j in pairs(t.mahjongs) do
					j:setHasAppear();
				end
			end
		end
	end
end

-- 清空已出现牌的标记
MahjongManager.clearHasAppearOnTableCard = function (self)
	for k = kSeatMine,kSeatLeft do
		local flag = false;
		local discards = self:getDiscardCardsBySeat(k);   -- 打出去的牌
		for r , t in pairs(discards) do
			if t.hasAppear then
				t:clearHasAppear();
				flag = true;
			end
		end

		if flag then
			-- self:getSeatDiscardNodeBySeat(k):packDrawing(false);
			-- self:getSeatDiscardNodeBySeat(k):packDrawing(true);
		end

		local blockCards = self:getBlockCardsBySeat(k);   -- 碰杠牌
		for r , t in pairs(blockCards) do
			for i , j in pairs(t.mahjongs) do
				if j.hasAppear then
					j:clearHasAppear();
				end
			end
		end
	end
end

-- 将显示在中心的牌放在桌面
MahjongManager.showBigCardCenterDiscard = function (self , symbol)
	DebugLog("showBigCardCenterDiscard")
	if not self.curShowBigMahjongOnCenter then
		return;
	end
	DebugLog("showBigCardCenterDiscard curShowBigMahjongOnCenter : "..self.curShowBigMahjongOnCenter.value)
	if self.curShowBigMahjongOnCenter.value > 0 then
		local seat = self.curShowBigMahjongOnCenter.seat;
		local value = self.curShowBigMahjongOnCenter.value;

		--self:showDiscardOnTable(seat , value , symbol or 0)
		-- local delayAnim = new(AnimInt, kAnimNormal, 0, 1, 800, 0)
        -- delayAnim:setDebugName("DelayAnim|timeAnim")
        -- delayAnim:setEvent(self,function ( self )
		-- 	delete(delayAnim);
		-- 	delayAnim = nil;
        --     self:showDiscardOnTableAnim(seat , value , symbol or 0,true);
        -- end)
		self:showDiscardOnTableAnim(seat , value , symbol or 0,true);
	end
end

-- 显示从中间移动到打出去的牌位置的动画
MahjongManager.showDiscardOnTableAnim = function (self , seat ,value ,symbol , isNeedAnim)
	if not self.curShowBigMahjongOnCenter and not isNeedAnim then
		if 1 == DEBUGMODE then
			error("showDiscardOnTableAnim self.showBigMahjongOnCenter is nil ");
		end
		return;
	end
	local discards = self:getDiscardCardsBySeat(seat);
	local mahjong = nil;
	if isNeedAnim then
		mahjong = self:showDiscardOnTable(seat,value,symbol,isNeedAnim);
		mahjong:setVisible(false);
	else
		mahjong = self.showBigMahjongOnCenter;
		table.insert(discards , mahjong);
		self.showBigMahjongOnCenter = nil;
	end
	local x , y = self.mahjongFrame:getDiscardFrame(seat , #discards);

	local level = -math.modf((#discards - 1)/kDisCardHangNum) - 4;

	if kSeatRight == seat then
		level = -#discards;
	elseif kSeatTop == seat then
		level = math.modf((#discards - 1)/kDisCardHangNum);
	end

	-- 先等待一秒
	local anim_temp = mahjong:addPropTranslate(2,kAnimNormal,800,0,0,0,0,0);
	anim_temp:setEvent(self , function ( self )
		mahjong:removeProp(2);
		mahjong:setVisible(true);
		if not mahjong:checkAddProp(3) then
			mahjong:removeProp(3);
		end

		if not isNeedAnim then
			mahjong:removeProp(0);
		end
		mahjong:setPos(showBigMahjongOnCenterPos[seat + 1][1] , showBigMahjongOnCenterPos[seat + 1][2]);
		mahjong:setLevel(level);

		local offest_x = x - mahjong.m_x / System.getLayoutScale();
		local offest_y = y - mahjong.m_y / System.getLayoutScale();
		local anim_1_time = 200;
		-- 变换位移
		local anim_1 = mahjong:addPropTranslate(1,kAnimNormal,anim_1_time,0,0,offest_x,0,offest_y);
		local endW , endH = self.mahjongFrame:getDiscardFrameSize(seat);
		-- 变小
		mahjong:addPropScale(2,kAnimNormal,anim_1_time,0,1.0,endW/mahjong.m_width,1.0,endH/mahjong.m_height);
		if kSeatLeft == seat and kSeatRight == seat then
			mahjong:addPropRotate(3,kAnimNormal,anim_1_time,0,0,kSeatLeft==seat and -90 or 90,kCenterDrawing);
		end
		anim_1:setEvent(self , function (self)
			mahjong:removeProp(1);
			mahjong:removeProp(2);
			if not mahjong:checkAddProp(3) then
				mahjong:removeProp(3);
			end
			mahjong:setPos(x , y);
			mahjong:setSize(endW , endH);
			local mahjongView = MahjongViewManager.getInstance():getMahjongType(seat);
			mahjong:setFileImage(getOutCardImageFileBySeat(seat , value, mahjongView));
			if 2 == symbol then
				mahjong:setRedWithImage();
			end
			self:getSeatNodeBySeat(seat):removeChild(mahjong);
			self:discardsNodeAddMahjongByseat(seat , mahjong);
		end);
	end);
end

-- 显示打出去的牌
MahjongManager.showDiscardOnTable = function (self , seat ,value ,symbol ,isNeedAnim)
	local mahjong = nil;
	if isNeedAnim then
		mahjong = new(Mahjong , getShowCenterImageFileBySeat(seat, value, MahjongViewManager.getInstance():getMahjongType(seat)));
	else
		mahjong = new(Mahjong , getOutCardImageFileBySeat(seat , value, MahjongViewManager.getInstance():getMahjongType(seat)));
	end
	mahjong.value = value;
	mahjong.seat = seat;
	local discards = self:getDiscardCardsBySeat(seat);
	table.insert(discards , mahjong);
	mahjong:setEnableCustom(false);
	if 2 == symbol and not isNeedAnim then  -- 如果是血流成河的胡牌
		mahjong:setRedWithImage();
	end
	mahjong:setLevel(-math.modf((#discards - 1)/kDisCardHangNum) - 4);
	if kSeatRight == seat then
		mahjong:setLevel(-#discards);
	elseif kSeatTop == seat then
		mahjong:setLevel(math.modf((#discards - 1)/kDisCardHangNum));
	end
	if isNeedAnim then
		self:getSeatNodeBySeat(seat):addChild(mahjong);
		mahjong:setPos(showBigMahjongOnCenterPos[seat + 1][1] , showBigMahjongOnCenterPos[seat + 1][2]);
	else
		self:discardsNodeAddMahjongByseat(seat , mahjong);
	end
	return mahjong;
end

-- 移掉中心的显示牌
MahjongManager.removeBigShowCenterView = function (self)
	if self.curShowBigMahjongOnCenter and self.curShowBigMahjongOnCenter.value > 0 then
		local mahjong = self.curShowBigMahjongOnCenter;
		self.curShowBigMahjongOnCenter = nil;

		if not mahjong:checkAddProp(7) then mahjong:removeProp(7) end

		local anim = mahjong:addPropRotate(7 , kAnimNormal ,800 , 0,0,0,0);
		anim:setDebugName("MahjongManager|self.mahjong");
		anim:setEvent(self , function (self)
			mahjong:setVisible(false);
			mahjong:removeProp(7)
			if not mahjong:checkAddProp(0) then mahjong:removeProp(0) end
			if not mahjong:checkAddProp(3) then mahjong:removeProp(3) end
		end);
	end
end

-- 网络重连上来需要清掉一张被碰杠胡的牌
MahjongManager.clearACardshowDiscardOnTable = function (self , seat , card)
	local discards = self:getDiscardCardsBySeat(seat);
	local mahjong = discards[#discards];
	-- DebugLog("clearACardshowDiscardOnTable : seat_"..seat.." card_"..card);
	if mahjong and mahjong.seat == seat and mahjong.value == card then
		-- DebugLog("clearACardshowDiscardOnTable : mahjongseat_"..mahjong.seat.." mahjongcard_"..mahjong.value);
		mahjong:removeFromSuper();
		table.remove(discards , #discards);
		local discardsNode = self:getSeatDiscardNodeBySeat(seat);
--		discardsNode:packDrawing(false);
--		discardsNode:packDrawing(true);
		-- self:getSeatNodeBySeat(seat):removeChild(mahjong , true);
		-- table.remove(discards , #discards);
	end
end

-- 去掉碰杠 手牌中的牌
MahjongManager.removePengGangInHandCards = function (self , seat ,card  ,opreatType)
	if not opreatType then
		return;
	end
	local removeCount = 0;
	if an_gang(opreatType) then
		removeCount = 4;
	elseif peng_gang(opreatType) then
		removeCount = 3;
	elseif bu_gang(opreatType) then
		removeCount = 1;
	elseif peng(opreatType) then
		removeCount = 2;
	end
	for i=1,removeCount do
		self:removeAMahjong(seat , self:getIndexOfMineInHandCardsByValue(card));
	end
end

--[[
	seat : 座位
	card : 牌值(当其他其他玩家暗杠时可以为nil)
	opreatType : 定义见GameDefine
]]
MahjongManager.playerBlockWithSeatAndValue = function (self , seat , card , opreatType)
	local index = self:getNewBlockIndexOfBlockCards(seat , card , opreatType);
	local x , y = self.mahjongFrame:getBlockFrame(seat , index);
	local tNode , mahjongs = MahjongViewManager.getInstance():pengGangMahjongView(seat , card , opreatType);
	tNode:setPos(x , y);
	if kSeatRight == seat then
		tNode:setLevel(16 - index);
	elseif kSeatLeft == seat then
		tNode:setLevel(index - 10);
	end
	--self.mahjongFrame:addAPengOrGang(seat);
	self:getSeatNodeBySeat(seat):addChild(tNode);
	local param = {};
	param.node = tNode;
	param.mahjongs = mahjongs;
	param.index = index;
	param.card = card or 0;
	param.opreatType = opreatType;
	table.insert(self:getBlockCardsBySeat(seat) , param);
	if kSeatMine == seat then
		self:sortInHandCards(self.myself.dingQueType);
	end
	self:drawInhandCards(seat);
end

-- 抢杠胡清空杠牌的麻将
MahjongManager.playerQiangGangHu = function (self , card)
	-- 先找到seat
	local seat = -1;
	for i = kSeatMine , kSeatLeft do
		local blockCards = self:getBlockCardsBySeat(i);
		for k , v in pairs(blockCards) do
			if v.card == card and operatorValueHasGang(v.opreatType) then
				seat = i;
				break;
			end
		end
	end
	if seat == -1 then
		return;
	end
	local index = self:getNewBlockIndexOfBlockCards(seat , card , QIANG_GANG_HU);
	local x , y = self.mahjongFrame:getBlockFrame(seat , index);
	local tNode , mahjongs = MahjongViewManager.getInstance():pengGangMahjongView(seat , card , PUNG);
	tNode:setPos(x , y);
	if kSeatRight == seat then
		tNode:setLevel(16 - index);
	elseif kSeatLeft == seat then
		tNode:setLevel(index - 10);
	end
	self:getSeatNodeBySeat(seat):addChild(tNode);
	local param = {};
	param.node = tNode;
	param.mahjongs = mahjongs;
	param.index = index;
	param.card = card or 0;
	param.opreatType = PUNG;
	table.insert(self:getBlockCardsBySeat(seat) , param);
	if kSeatMine == seat then
		self:sortInHandCards(self.myself.dingQueType);
	end
	self:drawInhandCards(seat);
end

-- 一局结束后，暗杠的牌翻过来
MahjongManager.showAnGangMahjongWhenGameOver = function (self)
	for k = kSeatMine,kSeatLeft do
		local blockCards = self:getBlockCardsBySeat(k);   -- 碰杠牌
		for r , t in pairs(blockCards) do
			if t.card >= 0 and an_gang(t.opreatType) then
				for i , j in pairs(t.mahjongs) do
					if j.isAboveMahjong then
						j:setFileImage(getPengGangImageFileBySeat(k , t.card, MahjongViewManager.getInstance():getMahjongType(k)));
					end
				end
			end
		end
	end
end

-- 设置多张麻将牌站起来,不变大小的站立(如多张牌有同一个value值，只有一张站立起来)
MahjongManager.setMahjongFrameUpNomal = function ( self, cardValueList, needAnim )
	for i,j in pairs(cardValueList) do
		local hasUp = false; -- 用于判断，避免同一value值的牌都站立起来
		for k,v in pairs(self.mineInHandCards) do
			if not hasUp and cardValueList[i] == v.value then
				hasUp = v:frameUpNomal(needAnim);
			end
		end
	end
end

-- 设置麻将牌不变大小下来
MahjongManager.setMahjongFrameDownNomal = function ( self, isAll, mahjongList, needAnim )
	if isAll then
		for k,v in pairs(self.mineInHandCards) do
			v:frameDownNomal(needAnim);
		end
		return;
	end
	if not mahjongList then
		return;
	end
	for k,v in pairs(self.mineInHandCards) do
		for i,j in pairs(mahjongList) do
			if mahjongList[i] == v then
				v:frameDownNomal(needAnim);
			end
		end
	end
end

MahjongManager.getFrameUpNomalNum = function ( self )
	local num = 0;
	for k,v in pairs(self.mineInHandCards) do
		if v.isFrameUpNomal then
			num = num + 1;
		end
	end
	return num;
end

MahjongManager.getFrameUpNomalMahjongValueList = function ( self )
	local t = {};
	for k,v in pairs(self.mineInHandCards) do
		if v.isFrameUpNomal then
			table.insert(t, v.value);
		end
	end
	return t;
end

-- 每个麻将子的响应点击事件
MahjongManager.mahjongOnTouchUp = function (self , finger_action,x, y,drawing_id_first,drawing_id_current)
	--local oldMahjong = self:getMineInHandCardByDrawingId(drawing_id_first);
	local newMahjong = self:getMineInHandCardByDrawingId(drawing_id_current , x , y);
	DebugLog("##touchUp:" .. tostring(drawing_id_current))
	if RoomData.getInstance().isStartSwapCard then -- 换三张时的按键操作
		if kFingerDown == finger_action then
			if newMahjong and not RoomData.getInstance().firstSwapClick then -- 第一次点击
				if newMahjong.isFrameUpNomal then
					newMahjong:frameDownNomal();
				else
					self:setMahjongFrameDownNomal(true); --都下来
					newMahjong:frameUpNomal();
				end
				RoomData.getInstance().firstSwapClick = true;
			elseif newMahjong then
				if newMahjong.isFrameUpNomal then
					newMahjong:frameDownNomal();
				else -- 处于下来的状态
					local cardNum = RoomData.getInstance().swapCardNum or 3;
					if self:getFrameUpNomalNum() < cardNum then -- 少于3张则站起
						newMahjong:frameUpNomal();
					end
				end
			end
		end
		return;
	end

	if kFingerDown == finger_action then
		if newMahjong and newMahjong.isFrameUp then
			self.touchTimes = self.touchTimes + 1;
		end
		self.touchTimes = self.touchTimes + 1;
		if newMahjong and not newMahjong.isFrameUp then
			self:setAllMahjongFrameDown();
			self:showHasAppearOnTableCard(newMahjong.value);
			self:setMahjongFrameUp(newMahjong);
		end
	elseif kFingerMove == finger_action then
		DebugLog("##touchUp:fingerMove:")
		--如果手指移出了之前点击的牌
		if not newMahjong or not newMahjong.isFrameUp then
			self.touchTimes = 0;
		end

		local movingCard = self:getMovingCard();
		if movingCard then
			DebugLog("##touchUp:fingerMove:movingCard")
			local mahjongTemp = self:getNoMovingMahjongCollWithPoint(x, y);
			if y > self.mahjongFrame:getMineHandCardTopLine() then
				if publ_isPointInRect(x, y, self.before_moving_x, self.before_moving_y, movingCard.m_width, movingCard.m_height) then
					self:setAllMahjongFrameDown();
					self:showHasAppearOnTableCard(movingCard.value);
					self:setMahjongFrameUp(movingCard);
				elseif mahjongTemp then
					self:setAllMahjongFrameDown();
					self:showHasAppearOnTableCard(mahjongTemp.value);
					self:setMahjongFrameUp(mahjongTemp);
				end
			else
				self:moveMahjong(x - self.x_dist, y - self.y_dist, movingCard);
			end
			return;
		end
		if newMahjong and not newMahjong.isFrameUp then
			DebugLog("##touchUp:fingerMove:newMahjong and not up")
			-- DebugLog("&&&&&&&&&&&&&&& newMahjong and not newMahjong.isFrameUp.");
			self:setAllMahjongFrameDown();
			self:showHasAppearOnTableCard(newMahjong.value);
			self:setMahjongFrameUp(newMahjong);

			-- self.b = true;
		elseif newMahjong and newMahjong.isFrameUp and newMahjong.canBeOutCard then
			DebugLog("##touchUp:fingerMove:newMahjong and up and can be out")
			if not newMahjong.isMoving and y < self.mahjongFrame:getMineHandCardTopLine() then
				-- DebugLog("&&&&&&&&&&&&&&& mahjong start moving.");
				self:startMovingMahjong(newMahjong, x, y);
			end
		end
	elseif kFingerUp == finger_action then
		local movingCard = self:getMovingCard();
		if movingCard and movingCard.canBeOutCard then
			-- 出牌后会自动调整整付牌的位置
			self:clearHasAppearOnTableCard();
			self:kickOutCard(kSeatMine, movingCard);
		elseif newMahjong and newMahjong.isFrameUp and newMahjong.canBeOutCard then
			if self.touchTimes >= 2 then -- 如果是双击才出牌
				self.touchTimes = 0;
				-- 出牌后会自动调整整付牌的位置
				self:clearHasAppearOnTableCard();
				self:kickOutCard(kSeatMine, newMahjong);
			end
		end
	end
end

MahjongManager.setMahjongFrameUp = function ( self, mahjong )
	if not mahjong or not mahjong.canBeTouchUp then
		return;
	end
	GameEffect.getInstance():play("AUDIO_CC");
	self:whenACardFrameUp(self:getIndexOfMineInHandCardsByMahjong(mahjong));
	mahjong:frameUp();
end

MahjongManager.getNoMovingMahjongCollWithPoint = function ( self, x, y )
	for k ,v in pairs(self.mineInHandCards) do
		if not v.isMoving and v:isRectWithPoint(x, y) then
			return v;
		end
	end
end

MahjongManager.startMovingMahjong = function ( self, mahjong, x, y )
	self.before_moving_x = mahjong.m_x / System.getLayoutScale();
	self.before_moving_y = mahjong.m_y / System.getLayoutScale();
	self.x_dist = mahjong.m_width/2;
	self.y_dist = mahjong.m_height/2;
	self:stopMovingAndResetPos();
	self:moveMahjong( x - self.x_dist, y - self.y_dist, mahjong);
	mahjong.isMoving = true;
end

-- 拖拽一个麻将
MahjongManager.moveMahjong = function ( self, x, y, mahjong )
	mahjong:setPos(x, y);
end

MahjongManager.getMovingCard = function ( self )
	for k ,v in pairs(self.mineInHandCards) do
		if v.isMoving then
			return v;
		end
	end
	return nil;
end

-- 让被拖拽的麻将复位
MahjongManager.stopMovingAndResetPos = function ( self )
	for k ,v in pairs(self.mineInHandCards) do
		if v.isMoving then -- get the card
			v:setPos(self.before_moving_x , self.before_moving_y);
			v.isMoving = false;
		end
	end
end

-- 手动打出一张牌
MahjongManager.kickOutCard = function (self, seat, mahjong)
	self.outCard_x = mahjong.m_x;
	self.outCard_y = mahjong.m_y;
	self:playOutMineCardByMahjong(mahjong);
	self.scene:outCardRequest(mahjong.value);
end

-- 让所有的麻将子坐下来
MahjongManager.setAllMahjongFrameDown = function (self)
	if not self:judgeMineInhandCards() then
		return;
	end
	self.touchTimes = 0;
	self:stopMovingAndResetPos(); -- 检查是否有正在拖拽的牌，把他们放下来
	for k ,v in pairs(self.mineInHandCards) do
		if v.isFrameUp then
			if not v.isCatchFrame then
				self:clearHasAppearOnTableCard(); -- 清空所有已出牌标记
				self:whenACardFrameDown(k);
			end
			v:frameDown();
		end
	end
end

-- 当一个麻将子站起来，左右需要进行移动
MahjongManager.whenACardFrameUp = function (self , index)
	if not self:judgeMineInhandCards() or not self.mineInHandCards[index] then
		return;
	end
	if self.mineInHandCards[index].isCatchFrame then
		return;
	end
	for i = 1,index - 1 do
		self.mineInHandCards[i]:setPos(self.mineInHandCards[i].m_x / System.getLayoutScale()- 6 , self.mineInHandCards[i].m_y/ System.getLayoutScale());
	end
	for i =#self.mineInHandCards,index + 1,-1 do
		self.mineInHandCards[i]:setPos(self.mineInHandCards[i].m_x / System.getLayoutScale()+ 6 , self.mineInHandCards[i].m_y/ System.getLayoutScale());
	end
end

-- 当一个麻将子坐下来，左右需要移动
MahjongManager.whenACardFrameDown = function (self , index)
	self:clearHasAppearOnTableCard();
	if not self:judgeMineInhandCards() or not self.mineInHandCards[index] then
		return;
	end
	if self.mineInHandCards[index].isCatchFrame then
		return;
	end
	for i = 1,index - 1 do
		self.mineInHandCards[i]:setPos(self.mineInHandCards[i].m_x / System.getLayoutScale()+ 6 , self.mineInHandCards[i].m_y/ System.getLayoutScale());
	end
	for i =#self.mineInHandCards,index + 1,-1 do
		self.mineInHandCards[i]:setPos(self.mineInHandCards[i].m_x / System.getLayoutScale()- 6 , self.mineInHandCards[i].m_y/ System.getLayoutScale());
	end
end

-- 打出去一张自己的牌 手动
MahjongManager.playOutMineCardByMahjong = function (self, mahjong)
	if not mahjong then
		return;
	end
	local value = mahjong.value;
	local index = self:getIndexOfMineInHandCardsByMahjong(mahjong);
	if not index then
		return;
	end

	self:removeAMahjong(kSeatMine, index);
	self:sortInHandCards(self.myself.dingQueType);
	self:playOutCardAnim(kSeatMine , value);

	local newCardIndex = self:getIndexOfMineInHandCardsByMahjong(self.newCard);
	local inHandCards = self:getInHandCardsBySeat(kSeatMine);

	-- if newCardIndex and newCardIndex ~= #inHandCards then
	-- 	self.outCardIndex = index;
	-- 	self:simulateTruthInsertCardAction();
	-- else
	-- 	self.tempWaitAnim = new(AnimInt, kAnimNormal, 0, 1, 200, 0);
	-- 	self.tempWaitAnim:setEvent(self, function (self)
	-- 		self:partHandCardMoveAnimation(index);
	-- 		if self.tempWaitAnim then
	-- 			delete(self.tempWaitAnim);
	-- 			self.tempWaitAnim = nil;
	-- 		end
	-- 	end);
	-- 	self.tempWaitAnim:setDebugName("MahjongManager|self.tempWaitAnim");
	-- end
	if self.tempWaitAnim then
		delete(self.tempWaitAnim);
		self.tempWaitAnim = nil;
	end
	self.tempWaitAnim = new(AnimInt, kAnimNormal, 0, 1, 200, 0);
	self.tempWaitAnim:setEvent(self, function (self)
		if newCardIndex and newCardIndex ~= #inHandCards then
			self.outCardIndex = index;
			self:simulateTruthInsertCardAction();
		else
			self:partHandCardMoveAnimation(index);
		end
		if self.tempWaitAnim then
			delete(self.tempWaitAnim);
			self.tempWaitAnim = nil;
		end
	end);
	self.tempWaitAnim:setDebugName("MahjongManager|self.tempWaitAnim");
end

-- 插牌动画开始
--向上移动
MahjongManager.simulateTruthInsertCardAction = function (self)
	if self.newCard then
		self.insertAnimPlaying = true;
		self.newCardTemp = self.newCard;
		--(sequence, animType, duration, delay, startX, endX, startY, endY)
		self.insertAnim = self.newCardTemp:addPropTranslate(2, kAnimNormal, 300, 0, 0, 0, 0, -MineInHandCard_H);
		self.insertAnim:setEvent(self, MahjongManager.insertMoveStepOne);
		self.insertAnim:setDebugName("MahjongManager|self.insertAnim");
	end
end
--手牌左右移动
MahjongManager.insertMoveStepOne = function (self)
	if self.newCardTemp then
		self.newCardTemp:removeProp(2);

		local nx,ny = self.newCardTemp:getPos();
		self.newCardTemp:setPos(nx,ny - MineInHandCard_H);

		local outCardIndex = self.outCardIndex;
		local index = self:getIndexOfMineInHandCardsByMahjong(self.newCardTemp);
		local inHandCards = self:getInHandCardsBySeat(kSeatMine);
		DebugLog("outCardIndex:"..outCardIndex);
		DebugLog("index:"..index);
		if not index or index >= #inHandCards then
			DebugLog("index max is index");
			self:drawInhandCards(kSeatMine);
			self.newCardTemp = nil;  --清除新牌引用
			self.newCard = nil;
			self.insertAnimPlaying = false;
			return;
		end

		self.insertIndex = index;
		if outCardIndex == index then  --不需要移动则直接进入下一步
			self:insertMoveStepTwo();
		else
			-- self:partHandCardMoveAnimationEX(outCardIndex,index);
			-- self.insertAnim1 = new(AnimInt, kAnimNormal, 0, 1, 150, 0);
			-- self.insertAnim1:setEvent(self, MahjongManager.insertMoveStepTwo);
			-- self.insertAnim1:setDebugName("MahjongManager|self.insertAnim1");

			self:partHandCardMoveAnimationEX(outCardIndex,index);
			self:insertMoveStepTwo();
		end
	end
end

--手牌移动
MahjongManager.partHandCardMoveAnimation = function (self,outCardIndex)
	local inHandCards = self:getInHandCardsBySeat(kSeatMine);
	for i = outCardIndex , #inHandCards do
		if inHandCards[i] then
			local mx,my = inHandCards[i]:getPos()
			local moveEndX = mx - MineInHandCard_W - 6;
			local moveAnimation = inHandCards[i]:addPropTranslate(10 , kAnimNormal , 150 , 0 , 0 ,  -MineInHandCard_W-6 , 0 , 0);
			moveAnimation:setEvent(self, function (self)
				inHandCards[i]:setPos(moveEndX,my);
				inHandCards[i]:removeProp(10);
				if i == #inHandCards then
					self:drawInhandCards(kSeatMine);
				end
			end)
		end
	end
end

MahjongManager.partHandCardMoveAnimationEX = function (self,outCardIndex,index)
	local inHandCards = self:getInHandCardsBySeat(kSeatMine);
	if outCardIndex < index then  --需要向左移动
		for i = outCardIndex , (index - 1) do
			if inHandCards[i] then
				local mx,my = inHandCards[i]:getPos()
				local moveEndX = mx - MineInHandCard_W - 6;
				local moveAnimation = inHandCards[i]:addPropTranslate(10 , kAnimNormal , 150 , 0 , 0 ,  -MineInHandCard_W-6 , 0 , 0);
				moveAnimation:setEvent(self, function (self)
					inHandCards[i]:removeProp(10);
					inHandCards[i]:setPos(moveEndX,my);
				end)
			end
		end
	elseif index < outCardIndex then  --需要向右移动
		for i = (index + 1) , (outCardIndex) do
			if inHandCards[i] then
				local mx,my = inHandCards[i]:getPos();
				local moveEndX = mx + MineInHandCard_W+6;
				local moveAnimation = inHandCards[i]:addPropTranslate(10 , kAnimNormal , 150 , 0 , 0 ,  6 + MineInHandCard_W , 0 , 0);
				moveAnimation:setEvent(self, function (self)
					inHandCards[i]:removeProp(10);
					inHandCards[i]:setPos(moveEndX,my);
				end)
			end
		end
	end
end

--newcard平移
MahjongManager.insertMoveStepTwo = function (self)
	if self.newCardTemp then
		if self.insertAnim1 then
			delete(self.insertAnim1);
			self.insertAnim1 = nil;
		end

		local inHandCards = self:getInHandCardsBySeat(kSeatMine);
		local index = self:getIndexOfMineInHandCardsByMahjong(self.newCardTemp);
		local tx, ty = self.newCardTemp:getPos();

		local blockCards = self:getBlockCardsBySeat(kSeatMine);
		local gx,gy = self.mahjongFrame:getInhandFrame(kSeatMine , index , #blockCards)
		self.newCardTemp:setPos(gx, ty);
		local offx = tx - gx;
		-- DebugLog("tx = "..tx);
		-- DebugLog("gx = "..gx);
		-- DebugLog("offx = tx - gx = "..offx);
		local anim = self.newCardTemp:addPropTranslate(4, kAnimNormal, 300, 0, offx, 0, 0, 0);
		anim:setEvent(self, MahjongManager.moveDownAnimation);
		anim:setDebugName("MahjongManager|self.insertAnimMove");
	end
end

--向下移动
MahjongManager.moveDownAnimation = function (self)
	if self.newCardTemp then
		self.newCardTemp:removeProp(4);
		self:drawInhandCards(kSeatMine);  --重绘手牌
		local anim = self.newCardTemp:addPropTranslate(3, kAnimNormal, 300, 0, 0, 0, -MineInHandCard_H, 0);
		anim:setEvent(self, MahjongManager.insertMoveDown);
		anim:setDebugName("MahjongManager|self.insertAnim2");
	end
end

MahjongManager.insertMoveDown = function (self)
	if self.newCardTemp then
		local inHandCards = self:getInHandCardsBySeat(kSeatMine);
		self.newCardTemp:removeProp(3);
		self.newCardTemp = nil;  --清除新牌引用
		self.newCard = nil;
	end
	self:drawInhandCards(kSeatMine);  --重绘手牌
end

-- 打出去一张牌  非手动
MahjongManager.playOutCard = function (self, seat, value)
	if not value or not seat then
		return;
	end

	local index = 1;
	if kSeatMine == seat then
		index = nil;
		for k , v in pairs(self.mineInHandCards) do
			if v.value == value then
				self.outCard_x = v.m_x;
				self.outCard_y = v.m_y;
				index = k;
				break;
			end
		end
	end
	if not index then
		return;
	end

	-- self:playOutCardAnimAndRemoveInhands(seat , index , value);
	self:playOutCardAnim(seat , value);
	self:removeAMahjong(seat, index);
	if kSeatMine == seat then
		self:sortInHandCards(self.myself.dingQueType);
	end
	self:drawInhandCards(seat);
end

-- 打出去的牌和服务器的不一致，换回来
MahjongManager.backendBeforeOutCard = function(self , beforeCard , card)
	if self.curShowBigMahjongOnCenter then
		self.curShowBigMahjongOnCenter.value = card;
		-- 设置图片路径
		local mahjongView = MahjongViewManager.getInstance():getMahjongType(kSeatMine);
		self.curShowBigMahjongOnCenter:setFileImage(getShowCenterImageFileBySeat(kSeatMine, card, mahjongView));
	end

	for k , v in pairs(self.mineInHandCards) do
		if v.value == card then
			v.value = beforeCard;
			break;
		end
	end
	self:sortInHandCards(self.myself.dingQueType);
	self:drawInhandCards(kSeatMine);
end

-- 打牌动画
MahjongManager.playOutCardAnim = function (self ,seat , value)
	local mahjongType = MahjongViewManager.getInstance():getMahjongType(seat);
	DebugLog("playOutCardAnim mahjongType : "..mahjongType)
	self.curShowBigMahjongOnCenter = self.showBigMahjongOnCenter[seat+1]
	self.curShowBigMahjongOnCenter:setFileImage(getShowCenterImageFileBySeat(seat, value, mahjongType));
	self.curShowBigMahjongOnCenter.value = value;
	self.curShowBigMahjongOnCenter.seat = seat;

	local inHandCards = self:getInHandCardsBySeat(seat);
	local blockCards = self:getBlockCardsBySeat(seat);
	self.curShowBigMahjongOnCenter:setPos(self.mahjongFrame:getCatchFrame(seat,#inHandCards,#blockCards));

	local offest_x = showBigMahjongOnCenterPos[seat + 1][1]-self.curShowBigMahjongOnCenter.m_x / System.getLayoutScale();
	local offest_y = showBigMahjongOnCenterPos[seat + 1][2]-self.curShowBigMahjongOnCenter.m_y / System.getLayoutScale();
	if kSeatMine == seat then
		self.curShowBigMahjongOnCenter:setPos(self.outCard_x / System.getLayoutScale(), self.outCard_y / System.getLayoutScale());
		offest_x = showBigMahjongOnCenterPos[seat + 1][1]-self.curShowBigMahjongOnCenter.m_x / System.getLayoutScale();
	    offest_y = showBigMahjongOnCenterPos[seat + 1][2]-self.curShowBigMahjongOnCenter.m_y / System.getLayoutScale();
	end
	if not self.curShowBigMahjongOnCenter:checkAddProp(0) then
		self.curShowBigMahjongOnCenter:removeProp(0)
	end
	if not self.curShowBigMahjongOnCenter:checkAddProp(3) then
		self.curShowBigMahjongOnCenter:removeProp(3)
	end
	if not self.curShowBigMahjongOnCenter:checkAddProp(7) then
		self.curShowBigMahjongOnCenter:removeProp(7)
	end
	local w, h = self.curShowBigMahjongOnCenter:getSize()

	local translateAnimation = self.curShowBigMahjongOnCenter:addPropTranslate(0,kAnimNormal,200,-1,0,offest_x,0,offest_y);
	-- translateAnimation:setEvent(self, function(self)
	-- 	if self.curShowBigMahjongOnCenter then
	-- 		self.curShowBigMahjongOnCenter:removeProp(0);
	-- 	end
	-- end);
	translateAnimation:setDebugName("MahjongManager|translateAnimation");
	local scaleAnimation = self.curShowBigMahjongOnCenter:addPropScale(3,kAnimNormal,200,-1,MineInHandCard_W / w,1.0,MineInHandCard_H / h,1.0)
	-- scaleAnimation:setEvent(self, function(self)
	-- 	if self.curShowBigMahjongOnCenter then
	-- 		self.curShowBigMahjongOnCenter:removeProp(3);
	-- 	end
	-- end);
	scaleAnimation:setDebugName("MahjongManager|scaleAnimation");
	self.curShowBigMahjongOnCenter:setVisible(true)
end

-- 移掉一个麻将子
MahjongManager.removeAMahjong = function(self , seat , index)
	if kSeatMine == seat then
		if not index or not self.mineInHandCards[index] then
			return ;
		end
		self.mineNode:removeChild(self.mineInHandCards[index] , true);
		table.remove(self.mineInHandCards , index);
	else
		local tempInhands = self:getInHandCardsBySeat(seat);
		self:getSeatNodeBySeat(seat):removeChild(tempInhands[#tempInhands] , true);
		table.remove(tempInhands , #tempInhands);
	end
end

function MahjongManager.playOutCardAnimAndRemoveInhands( self , seat , index , value )
	if not seat then
		DebugLog("error : 打出的牌没有seat");
		return;
	end
	if kSeatMine == seat then
		if not index or not self.mineInHandCards[index] then
			return ;
		end
		self.mineNode:removeChild(self.mineInHandCards[index], true);
		table.remove(self.mineInHandCards , index);
	else
		local tempInhands = self:getInHandCardsBySeat(seat);
		self:getSeatNodeBySeat(seat):removeChild(tempInhands[#tempInhands], true);
		table.remove(tempInhands , #tempInhands);
	end
	self:playOutCardAnim(seat , value);
end

-- 通过座位获取自己的手牌
MahjongManager.getInHandCardsBySeat = function ( self ,seat)
	if kSeatMine == seat then
		return self.mineInHandCards;
	elseif kSeatRight == seat then
		return self.rightInHandCards;
	elseif kSeatTop == seat then
		return self.topInHandCards;
	elseif kSeatLeft == seat then
		return self.leftInHandCards;
	end
end

MahjongManager.hasTheTypeMahjong = function ( self, dingQueType)
	if not dingQueType then
		return false;
	end
	local value_s = tonumber(dingQueType) * 0x10 + 1;
	local value_e = value_s + 9;
	for k,v in pairs(self.mineInHandCards) do
		 if v.value >= value_s and v.value < value_e then
		 	return true;
		 end
	end
	return false;
end

-- 通过座位获取自己的打出牌
MahjongManager.getDiscardCardsBySeat = function ( self ,seat)
	if kSeatMine == seat then
		return self.mineDiscardCards;
	elseif kSeatRight == seat then
		return self.rightDiscardCards;
	elseif kSeatTop == seat then
		return self.topDiscardCards;
	elseif kSeatLeft == seat then
		return self.leftDiscardCards;
	end
end

-- 通过座位获取自己的碰杠牌
MahjongManager.getBlockCardsBySeat = function ( self ,seat)
	if kSeatMine == seat then
		return self.mineBlockCards;
	elseif kSeatRight == seat then
		return self.rightBlockCards;
	elseif kSeatTop == seat then
		return self.topBlockCards;
	elseif kSeatLeft == seat then
		return self.leftBlockCards;
	end
end

-- 通过座位获取牌的根节点
MahjongManager.getSeatNodeBySeat = function ( self ,seat)
	if kSeatMine == seat then
		return self.mineNode;
	elseif kSeatRight == seat then
		return self.rightNode;
	elseif kSeatTop == seat then
		return self.topNode;
	elseif kSeatLeft == seat then
		return self.leftNode;
	end
end

-- 通过座位获取打出牌牌的根节点
MahjongManager.getSeatDiscardNodeBySeat = function ( self ,seat)
	if kSeatMine == seat then
		return self.mineDiscardNode;
	elseif kSeatRight == seat then
		return self.rightDiscardNode;
	elseif kSeatTop == seat then
		return self.topDiscardNode;
	elseif kSeatLeft == seat then
		return self.leftDiscardNode;
	end
end

-- 获取手牌某种花色的牌数目
MahjongManager.getMineCardTypeNum = function ( self, mjType )
	if not self:judgeMineInhandCards() and not mjType then
		return 0;
	end
	local num = 0;
	for k,v in pairs(self.mineInHandCards) do
		local localType = getMahjongTypeAndValueByValue(v.value);
		if localType ==  mjType then
			num = num + 1;
		end
	end
	return num;
end

-- 查找当前麻将在手牌的位置
MahjongManager.getIndexOfMineInHandCardsByValue = function (self , value)
	for k,v in pairs(self.mineInHandCards) do
		if v.value == value then
			return k;
		end
	end
end

MahjongManager.getIndexOfMineInHandCardsByMahjong = function (self, mahjong)
	if not mahjong then
		return nil;
	end
	--DebugLog("mahjong not nil");
	for k,v in pairs(self.mineInHandCards) do
		if v == mahjong then
			return k;
		end
	end
end

-- 通过drawing_id来获得当前响应的是哪个麻将子
MahjongManager.getMineInHandCardByDrawingId = function (self , drawing_id_current, x , y)
	if not self:judgeMineInhandCards() then
		return;
	end
	for k ,v in pairs(self.mineInHandCards) do
		if v.m_drawingID == drawing_id_current then
			return v;
		end
	end
	if not x or not y then
		return;
	end
	if y >= MineFrameUp_Y then
		for k , v in pairs(self.mineInHandCards) do
			local width = MineInHandCard_W;
			if v.isFrameUp then
				width = MineFrameUp_W;
			end
			if x >= v.m_x / System.getLayoutScale() and x <= v.m_x / System.getLayoutScale() + width and y >= v.m_y / System.getLayoutScale() and v.canBeTouchUp and v.m_pickable then
				return v;
			end
		end
	end
end

-- 查找当前碰杠是否存在并删除已有的
MahjongManager.getNewBlockIndexOfBlockCards = function (self ,seat , card , opreatType)
	local blockCards = self:getBlockCardsBySeat(seat);
	if bu_gang(opreatType) then
		for k , v in pairs(blockCards) do
			if operatorValueHasPeng(v.opreatType) and v.card == card then
				local index = v.index;
				v.node:removeAllChildren();
				self:getSeatNodeBySeat(seat):removeChild(v.node ,true);
				table.remove(blockCards , k);
				return index;
			end
		end
	end
	if hu_qiangGang(opreatType) then
		for k , v in pairs(blockCards) do
			if operatorValueHasGang(v.opreatType) and v.card == card then
				local index = v.index;
				v.node:removeAllChildren();
				self:getSeatNodeBySeat(seat):removeChild(v.node , true);
				table.remove(blockCards , k);
				return index;
			end
		end
	end
	return #blockCards + 1;
end

-- 判断函数
MahjongManager.judgeMineInhandCards = function (self)
	if #self.mineInHandCards <= 0 then
		return false;
	end
	return true;
end

-- 排序函数
MahjongManager.sortInHandCards = function (self , mjType)
	if not self:judgeMineInhandCards() then
		return;
	end
	-- table.sort( self.mineInHandCards, self.sortMahjong);
	self.mineInHandCards = self:sortMahjong(self.mineInHandCards);

	if not mjType or mjType == -1 then
		return;
	end

	local tempList = self.mineInHandCards;
	self.mineInHandCards = {};
	for k , v in pairs(tempList) do
		if mjType ~= v.mjType then
			table.insert(self.mineInHandCards , v);
		end
	end
	for k , v in pairs(tempList) do
		if mjType == v.mjType then
			table.insert(self.mineInHandCards , v);
		end
	end
end

-- 排序条件
MahjongManager.sortMahjong = function (self, table)
	for i = 1, #table do
		for j = 1, #table - i do
			if table[j+1].value < table[j].value then
				local temp = table[j];
				table[j] = table[j+1];
				table[j+1] = temp;
			end
		end
	end
	return table;
	-- if s1.value > s2.value then
	-- 	return false;
	-- end
	-- return true;
end

-- 是否点击的是麻将
MahjongManager.isMahjongTouch = function (self , x , y)
	if self:getMovingCard() then
		return true;
	end
	if y >= MineFrameUp_Y then
		for k , v in pairs(self.mineInHandCards) do
			local width = MineInHandCard_W;
			if v.isFrameUp then
				width = MineFrameUp_W;
			end
			if x >= v.m_x / System.getLayoutScale() and x <= v.m_x/ System.getLayoutScale() + width and y >= v.m_y/ System.getLayoutScale() and v.canBeTouchUp and v.m_pickable then
				return true;
			end
		end
	end
	return false;
end

MahjongManager.getMineInHandCards = function( self )
	return self.mineInHandCards;
end

-------------------------------加番----------------------------------------------------------------------
--根据座位号设置加番的牌(没有胡牌所有人的牌为站立状态)
MahjongManager.setAddFanForSeat = function(self,seat)
	local tempFlag = false;
	for k,v in pairs(self:getInHandCardsBySeat(seat)) do
		for k2,v2 in pairs(v) do
			if k2 == "value" and tonumber(v2) ~= 0 and string.format("0x%02X",v2) == GameConstant.addFanPai then
				tempFlag = true;
				break;
			end
		end
		if tempFlag then
			v:setTheMahjongForAddFan(seat);
			tempFlag = false;
		end
	end
end

--根据座位号设置吃碰杠的加番图标
MahjongManager.setChiPengGangAndHuAddFan = function(self,seat)
	local tempFlag = false;
	for k,v in pairs(self:getBlockCardsBySeat(seat)) do
		for k2,v2 in pairs(v) do
			if k2 == "card" and string.format("0x%02X",v2) == GameConstant.addFanPai then
				tempFlag = true;
				break;
			end
		end
		if tempFlag then
			for k2,v2 in pairs(v.mahjongs) do
				v2:setTheMahjongChiPengGangAndHuForAddFan(seat);
			end
			tempFlag = false;
		end
	end
end

--根据座位号设置所有加番牌2(胡牌后所有人的牌为倒下的状态)
MahjongManager.setAddFanHuForSeat = function(self,seat)
	local tempFlag = false;
	for k,v in pairs(self:getInHandCardsBySeat(seat)) do
		for k2,v2 in pairs(v) do
			if k2 == "value" and tonumber(v2) ~= 0 and string.format("0x%02X",v2) == GameConstant.addFanPai then
				tempFlag = true;
				break;
			end
		end
		if tempFlag then
			v:setTheMahjongChiPengGangAndHuForAddFan(seat);
			tempFlag = false;
		end
	end
end

--设置所有人的加番标记(未胡牌)
MahjongManager.setAllAddFan = function(self)
	for i = kSeatMine,kSeatMine do
		self:setChiPengGangAndHuAddFan(i);
		self:setAddFanForSeat(i);
	end
end

--设置所有人的加番标记(胡牌)
MahjongManager.setAllHuAddFan = function(self)
	for i = kSeatMine,kSeatMine do
		self:setChiPengGangAndHuAddFan(i);
		self:setAddFanHuForSeat(i);
	end
end

--设置单张牌为加番牌
MahjongManager.setOneCardForAddFan = function(self,card)
	if type(card) == "table" then
		if tonumber(card.value) ~= 0 and string.format("0x%02X",card.value) == GameConstant.addFanPai then
			card:setTheMahjongForAddFan(kSeatMine);
		end
	elseif type(card) == "number" then
		if tonumber(card) ~= 0 and string.format("0x%02X",card) == GameConstant.addFanPai then
			self:setAllAddFan();
		end
	end
end

--根据座位号移除吃碰杠的加番图标
MahjongManager.removeChiPengGangAddFan = function(self,seat)
	local tempFlag = false;
	for k,v in pairs(self:getBlockCardsBySeat(seat)) do
		for k2,v2 in pairs(v) do
			if k2 == "card" and tonumber(v2) ~= 0 and string.format("0x%02X",v2) == GameConstant.addFanPai then
				tempFlag = true;
				break;
			end
		end
		if tempFlag then
			for k2,v2 in pairs(v.mahjongs) do
				v2:removeTheMahjongForAddFan(seat);
			end
			tempFlag = false;
		end
	end
end

--根据座位号移除加番的牌
MahjongManager.removeAddFanForSeat = function(self,seat)
	local tempFlag = false;
	for k,v in pairs(self:getInHandCardsBySeat(seat)) do
		for k2,v2 in pairs(v) do
			if k2 == "value" and tonumber(v2) ~= 0 and string.format("0x%02X",v2) == GameConstant.addFanPai then
				tempFlag = true;
				break;
			end
		end
		if tempFlag then
			v:removeTheMahjongForAddFan(seat);
			tempFlag = false;
		end
	end
end

--移除所有人的加番标记
MahjongManager.removeAllAddFan = function(self)
	for i = kSeatMine,kSeatMine do
		self:removeChiPengGangAddFan(i);
		self:removeAddFanForSeat(i);
	end
end

-- 根据不同的座位添加打出去的牌
function MahjongManager.discardsNodeAddMahjongByseat( self , seat , mahjong )
	if not seat or not mahjong then
		return;
	end
	local discardsNode = self:getSeatDiscardNodeBySeat(seat);
--	discardsNode:packDrawing(false);
	local discards = self:getDiscardCardsBySeat(seat);
	local count = #discards;
	for i = 1 , #discards do
		if discards[i] == mahjong then
			count = i;
			break;
		end
	end
	local x , y = self.mahjongFrame:getShowDiscardPos(seat , count);
	discardsNode:addChild(mahjong);
	mahjong:setPos(x , y);
--	discardsNode:packDrawing(true);
end

--返回手牌中花色最多的一门(万,筒,条,nil)
function MahjongManager.getMaxNumsTypeOfMineInHandCards( self )
	local typeNums = {0,0,0};
	if self.mineInHandCards then
		 for k,v in pairs(self.mineInHandCards) do
		 	local curType = getMahjongTypeAndValueByValue(v.value)
		 	typeNums[curType+1] = typeNums[curType+1] + 1
		 end
	end

	if typeNums[1] > typeNums[2] and typeNums[1] > typeNums[3] then
		return 0
	end
	if typeNums[2] > typeNums[1] and typeNums[2] > typeNums[3] then
		return 1
	end
	if typeNums[3] > typeNums[1] and typeNums[3] > typeNums[2] then
		return 2
	end
	return nil
end
--判断五张牌
function MahjongManager.checkIs5Cards(self)
	local AllCards = {}
	for i=1,41 do
		AllCards[i] = 0
	end
	---自己手牌,自己碰杠的牌 自己弃牌  其他人碰杠的牌,弃牌
	local accessFunc = function ( cards,  ac )
		for k,v in pairs(cards) do
			if ac[v.value] then
				ac[v.value] = ac[v.value] + 1
			end
		end
	end

	local checkBlockFunc = function ( blocks, ac )
		for k,v in pairs(blocks) do
			if v.card and ac[v.card] then
				ac[v.card] = ac[v.card] + #v.mahjongs
			end
		end
	end



	accessFunc(self.mineInHandCards,   AllCards)
	accessFunc(self.rightInHandCards,  AllCards)
	accessFunc(self.topInHandCards,    AllCards)
	accessFunc(self.leftInHandCards,   AllCards)

	accessFunc(self.mineDiscardCards,  AllCards)
	accessFunc(self.rightDiscardCards, AllCards)
	accessFunc(self.topDiscardCards,   AllCards)
	accessFunc(self.leftDiscardCards,  AllCards)

	checkBlockFunc(self.mineBlockCards,  AllCards)
	checkBlockFunc(self.rightBlockCards, AllCards)
	checkBlockFunc(self.topBlockCards,   AllCards)
	checkBlockFunc(self.leftBlockCards,  AllCards)

	local outStr = ""
	local rb     = false
	for i=1,41 do
		if AllCards[i] > 4 then
			outStr = outStr .. self:descForValue(i).."*"..AllCards[i].." "
			rb = true
		end
	end
	return rb,outStr
end

function MahjongManager:descForValue( value )
	local map = {
		["0"] = "万",
		["1"] = "筒",
		["2"] = "条",
		--"万","筒","条"
	}
	if value == 0 then
		return ""
	end
	local t,v = getMahjongTypeAndValueByValue(value or 0)
	local c   = map[tostring(t)]
    if c then
		return v..c
	end
	return tostring(t).."#"..tostring(v)
end

function MahjongManager:printAllCardsFunc()

	local printHands   = function ( tag,handCards )
		local out = tag .. " "
		for k,v in pairs(handCards) do
			out = out .. self:descForValue(v.value).." "
		end
		return out
	end

	local printBlocks  = function ( tag, blockCards )
        local out = tag .. " "
		for k,v in pairs(blockCards) do

			local str = self:descForValue(v.card).." "
			if v.mahjongs then
				for i=1,#v.mahjongs do
					out = out .. str
				end
			end
		end
		return out
	end

	local printPersonMahjong = function ( hand, block, discard,head )
		DebugLog(printHands(head.."手牌:",hand))
		DebugLog(printBlocks(head.."杠牌:",block))
		DebugLog(printHands(head.."弃牌:",discard))
	end
	DebugLog("****************************************************************************************************")
	printPersonMahjong(self.mineInHandCards,self.mineBlockCards,self.mineDiscardCards,"下")
	printPersonMahjong(self.rightInHandCards,self.rightBlockCards,self.rightDiscardCards,"右")
	printPersonMahjong(self.topInHandCards,self.topBlockCards,self.topDiscardCards,"上")
	printPersonMahjong(self.leftInHandCards,self.leftBlockCards,self.leftDiscardCards,"左")

	local b,s = self:checkIs5Cards()
	if b then
		DebugLog("发现5张牌:"..s)
	end
	DebugLog("****************************************************************************************************")
end


--判断抓牌后的手牌是否正常  (大小相公)
function MahjongManager.checkMineInHandCardsIsNormal( self )
	if self.mineInHandCards and #self.mineInHandCards >= 2 and (#self.mineInHandCards - 2)%3 == 0  then
		return true
	end
	return nil
end
