require("MahjongRoom/RoomScene")
require("teach/TeachManager")
local TeachPin_map = require("qnPlist/TeachPin")
local TeachDir = ""

TeachRoomScene = class(RoomScene);

TeachRoomScene.ctor = function (self, viewConfig, state)
	DebugLog("TeachRoomScene ctor");


	TeachRoomScene_instance = self;
	self.rootNode = new(Node);
	self.m_root:addChild(self.rootNode);
	self.rootNode:setPickable(false);
	self.curStep = 1;
	self.hasNext = false;

	self.tips = false;
	self.ishu = false;

	self:initView();
	RoomData.getInstance().outCardTimeLimit = 0;
	RoomData.getInstance().operationTime = 0;

	self:initTeachLayerTip();

	--
	local  player = PlayerManager.getInstance():myself()
	self.nickName = player.nickName;
	self.money = player.money;
	self.needGang = true;

	TeachManager.getInstance():setTeachNotVisible();

	self.isInSocketRoom = false;

	self.TEXT_VIEW_WIDTH = 315
	self.TEXT_VIEW_HEIGHT = 115

	self:initHttpRequestsCallBackFuncMap()
	--		
end


TeachRoomScene.initTeachLayerTip = function ( self )
	-- self.teachLayerTip = new(Image , TeachPin_map["teachLayer.png"] , nil , nil , 20 ,20 ,20 ,20);
	-- self.teachLayerTip:setSize(330 , 122);
	self.teachLayerTip = new(Image , TeachPin_map["teachLayer.png"],nil,nil,20,20,20,40)
	self.teachLayerTip:setSize(470,150);
	self.m_root:addChild(self.teachLayerTip);
	local tipPlayer = new(Image , TeachPin_map["tipPlayer.png"]);
	tipPlayer:setAlign(kAlignRight)
	tipPlayer:setPos(-25 , 0);
	self.teachLayerTip:addChild(tipPlayer);
	if PlatformConfig.platformYiXin == GameConstant.platformType then 
		tipPlayer:setFile("Login/yx/Room/tipPlayer.png");
	end


	self.tipNextNode = new(Node);
	-- self.tipNextNode:setPos(201 , 70);
	self.teachLayerTip:addChild(self.tipNextNode);

	local tipNextH = new(Button , TeachPin_map["tipNextW.png"]);
	tipNextH:setPos(310 , 90);
	self.tipNextNode:addChild(tipNextH);
	tipNextH:addPropTranslate(0 , kAnimLoop , 395 , 0 , 0 , 5 , 0 , 0);
	--local tipNextW = new(Button , TeachPin_map["tipNextW.png"]);
	--tipNextW:setPos(200 , 100);
	--self.tipNextNode:addChild(tipNextW);

	self.teachTextView = new(TextView , "先准备，不然会被踢出房间哦",self.TEXT_VIEW_WIDTH ,self.TEXT_VIEW_HEIGHT,kAlignLeft,nil, 22, 0xcc, 0x44, 0x00);
	self.teachTextView:setPos(20+8,12);
	self.teachLayerTip:addChild(self.teachTextView);

	self.teachLayerTip:setVisible(false);
end

TeachRoomScene.dtor = function (self)
	--
	delete(self.anim);
	self.anim = nil;
	delete(self.anim_1);
	self.anim_1 = nil;
	--

	DebugLog("TeachRoomScene dtor");
	self.m_root:removeChild(self.rootNode , true);
	self.m_root:removeChild(self.teachLayerTip , true);
	TeachRoomScene_instance = nil;
end

TeachRoomScene.resume = function(self)
	DebugLog("TeachRoomScene resume");
	self.super.resume(self);
	GameConstant.curGameSceneRef = self;
	self:setTeachStartView();
	self:setSettingView();
end 

TeachRoomScene.pause = function(self)
	DebugLog("TeachRoomScene pause");
	self.super.pause(self);
end 

TeachRoomScene.setSettingView = function (self)

end

-- 进入新手教程的第一个界面
TeachRoomScene.setTeachStartView = function (self)
	self.tips = false;
	self.ishu = false;
	self.quickPay = self:getControl(RoomScene.s_controls.quickPay);
	self.quickPay:setVisible(false);
	self.awardBtn = self:getControl(RoomScene.s_controls.AwardBtn);
	self.awardBtn:setVisible(false);
	RoomData.getInstance().outCardTimeLimit = 0;
	RoomData.getInstance().operationTime = 0;
	self.rootNode:setPickable(false);
	self.quickChatBtn:setVisible(false);
	local myself = PlayerManager.getInstance():myself();
	myself.nickName = "玩家";
	myself.money = 10000000;
	local seat = self.seatManager:getSeatByLocalSeatID(myself.localSeatId);
	seat:setData(myself);
	seat.iconBtn:setPickable(false);
	for i = 1,3 do
		local player = new(Player);
		player.money = 10000000;
		player.localSeatId = i;
		player.mid = myself.mid + i;
		player.nickName = "玩家";
		if 0 == i then
			player.sex = myself.sex;
			player.isReady = false;
		else
			player.sex = i % 2;
			player.isReady = true;
		end
		PlayerManager.getInstance():addPlayer(player);
		local seat = self.seatManager:getSeatByLocalSeatID(player.localSeatId);
		seat:setData(player);
		seat.iconBtn:setPickable(false);
	end
	self:showTableInfo(1,true);


	local scaleW = System.getScreenWidth() / System.getLayoutWidth() / System.getLayoutScale(); 
	local scaleH = System.getScreenHeight() / System.getLayoutHeight() / System.getLayoutScale();
	--400 278 为准备按钮坐标,大小为120x60	
	self.teachLayerTip:setPos(800* scaleW - 50, 475 * scaleH);
	self.teachTextView:setText("先准备，不然会被踢出房间哦",self.TEXT_VIEW_WIDTH,self.TEXT_VIEW_HEIGHT, 0xcc, 0x44, 0x00);
	self.teachLayerTip:setVisible(true);
	self.tipNextNode:setVisible(false);

	local readyBtn = self.seatManager:getSeatByLocalSeatID(myself.localSeatId)._leftBtn;

--	local clickAnim = new(SCSprite , SpriteConfig.TYPE_TEACH_READY_TIP);
--	clickAnim:setPlayMode(kAnimRepeat);
--	clickAnim:setPos(-200 , 7);
--	DebugLog("clickAnim.m_x "..clickAnim.m_x.."    clickAnim.m_y "..clickAnim.m_y);
--	readyBtn:addChild(clickAnim);
--	clickAnim:play();
	local arrowImg = UICreator.createImg(TeachPin_map["clickW.png"],-200, 7-25)
	arrowImg:addPropTranslate(1,kAnimRepeat,1000,0,0,80,0,0)--(self, sequence, animType, duration, delay, startX, endX, startY, endY)
	readyBtn:addChild(arrowImg);
end

TeachRoomScene.readyStartGame = function (self , data)
	self.super.readyStartGame(self,data);
	self.rootNode:removeAllChildren();
end


TeachRoomScene.showReadyBtn = function ( self )
	DebugLog("TeachRoomScene.showReadyBtn")
	local seat = self.seatManager:getSeatByLocalSeatID(kSeatMine,self);
	seat:showReadyBtn();
end
-- 设置基本信息后，还是现实默认logo


function TeachRoomScene:setRoomDisplayInfo( status )
	--status=1  牌局未开始状态  
	--status=2  牌局开始状态
	assert(status and (status ~= 1 or status ~= 2))
	status = status or 1
	local configMap = {
		{  
		    ["logo"] 		= {0   ,-122,true},
		    ["roomName"]	= {0   , -66,false},
		    ["leftArrow"]   = {133, -66,true},
		    ["rightArrow"]  = {133, -66,true},
		    ["wanfaBg"]     = {0   ,-66,true},
		},
		{  
		    ["logo"] 		= {0   ,-122,true},
		    ["roomName"]	= {0   , -66,false},
		    ["leftArrow"]   = {133,  105,true},
		    ["rightArrow"]  = {133,  105,true},
		    ["wanfaBg"]     = {  0,  105,true},
		},
	}

	local configInfo = configMap[status]

	self:createTableInfo()

	local curConfigItem = nil  
	for key,nodes in pairs(self.RDI) do
		curConfigItem = configInfo[key]
		if curConfigItem then 
			nodes:setPos(curConfigItem[1],curConfigItem[2])
			nodes:setVisible(curConfigItem[3])
		end  
	end

	--self.RDI.wanfaBg.lt:setText("血战到底")
	--self.RDI.wanfaBg.rt:setText("5000底")

end

-- 点击准备后不改变界面显示
TeachRoomScene.readyAction = function ( self )
	self.super.readyAction( self );
	self:showTableInfo(2,true)
	--self:setRoomBaseInfoVisible( false );
end



function TeachRoomScene:showTableInfo(status, visible)
	if status then 
		self:setTableInfoStatus(status)
	end 
	
	--self:showRoomName()

	left  = "血战到底"

	right = "5000底"
	self:showWanfaAndDi(visible,left,mid,right)
end


TeachRoomScene.myselfCatchCard = function (self , data)
	self.super.myselfCatchCard(self,data);
	if not self.tips then
		self.tips = true;
		self.curStep = 1;
		self.hasNext = true;
		self:setTipsView();
		self.mahjongManager:setMineInHandCardsCanNotBeTouch();
	end
	self.rootNode:removeAllChildren();
	if an_gang(data.operateValue)then
		local teachW, teachH = self.teachLayerTip:getSize();
		local x, y = self.mahjongManager.mahjongFrame:getPos(kSeatMine);
		local w, h = self.mahjongManager.mahjongFrame:getSize(kSeatMine);
		self.teachLayerTip:setPos(x + (w - teachW)/2 ,RoomCoor.gameAnim[1][kSeatMine][2] - teachH);
		self.teachTextView:setText("抓到四张一样的，我杠（暗杠，即下雨）",self.TEXT_VIEW_WIDTH,self.TEXT_VIEW_HEIGHT, 0xcc, 0x44, 0x00);
		self.tipNextNode:setVisible(false);
	elseif hu_zimo(data.operateValue) then
		local teachW, teachH = self.teachLayerTip:getSize();
		local x, y = self.mahjongManager.mahjongFrame:getPos(kSeatMine);
		local w, h = self.mahjongManager.mahjongFrame:getSize(kSeatMine);

		self.teachLayerTip:setPos(x + (w - teachW)/2 ,RoomCoor.gameAnim[1][kSeatMine][2] - teachH);
		self.teachTextView:setText("运气真好，杠上开花，我自摸了",self.TEXT_VIEW_WIDTH,self.TEXT_VIEW_HEIGHT, 0xcc, 0x44, 0x00);
		self.tipNextNode:setVisible(false);
	end
end

TeachRoomScene.setTipsView = function (self)
	self.rootNode:removeAllChildren();
	DebugLog("TeachRoomScene.setTipsView  self.curStep==" .. self.curStep);
	if 1 == self.curStep then

		local x, y = self.mahjongManager.mahjongFrame:getPos(kSeatMine);
		local w, h = self.mahjongManager.mahjongFrame:getSize(kSeatMine);

		local teachW, teachH = self.teachLayerTip:getSize();
		self.teachLayerTip:setPos(x + w - teachW, y - teachH);
	   	self.teachTextView:setText("四川麻将要缺一门才能胡牌哦",self.TEXT_VIEW_WIDTH,self.TEXT_VIEW_HEIGHT, 0xcc, 0x44, 0x00);
	   	self.tipNextNode:setVisible(true);
	elseif 2 == self.curStep then

		local x, y = self.mahjongManager.mahjongFrame:getPos(kSeatMine);
		local w, h = self.mahjongManager.mahjongFrame:getSize(kSeatMine);

		local teachW, teachH = self.teachLayerTip:getSize();
		--居中
		--30 为 wanTips的高度
		self.teachLayerTip:setPos(x + (w - teachW)/2, y - teachH - 30);
	   	self.teachTextView:setText("这里把条作为缺的一门，那么把缺都打出去吧",self.TEXT_VIEW_WIDTH,self.TEXT_VIEW_HEIGHT, 0xcc, 0x44, 0x00);
	   	self.tipNextNode:setVisible(true);

	   	-- local wanS = self.mahjongManager.mahjongFrame:getInhandFrame ( kSeatMine, 1 , 0);
	   	-- local wanE = self.mahjongManager.mahjongFrame:getInhandFrame ( kSeatMine, 7 , 0);

	   	-- local wanTips = UICreator.createImg(TeachPin_map["wan_tip.png"],10,360);
	   	-- local wanTipsW, wanTipsH = wanTips:getSize();
	   	-- wanTips:setPos(wanS +  (wanE - wanS - wanTipsW) / 2 , y - wanTipsH - 5 ) ;
	   	-- self.rootNode:addChild(wanTips);

	   	-- local tongS = self.mahjongManager.mahjongFrame:getInhandFrame ( kSeatMine, 7 , 0);
	   	-- local tongE = self.mahjongManager.mahjongFrame:getInhandFrame ( kSeatMine, 14 , 0);

	   	-- local tongTips = UICreator.createImg(TeachPin_map["tong_tip.png"],385,360);
	   	-- local tongTipsW, tongTipsH = tongTips:getSize();
	   	-- tongTips:setPos(tongS +  (tongE - tongS - tongTipsW) / 2 , y - tongTipsH - 5 ) ;
	   	-- self.rootNode:addChild(tongTips);

	   	-- local tiaoS = self.mahjongManager.mahjongFrame:getCatchFrame ( kSeatMine, 0 , 0);
	   	-- local tiaoE = x + w;

	   	-- local tiaoTips = UICreator.createImg(TeachPin_map["tiao_tip.png"],720,360);
	   	-- local tiaoTipsW, tiaoTipsH = tiaoTips:getSize();
	   	-- tiaoTips:setPos(tiaoS +  (tiaoE - tiaoS - tiaoTipsW) / 2 , y - tiaoTipsH - 5 ) ;

	   	-- self.rootNode:addChild(tiaoTips);
	   	self:wanTongTiaoView(0);
	elseif 3 == self.curStep then


		local x, y = self.mahjongManager.mahjongFrame:getPos(kSeatMine);
		local w, h = self.mahjongManager.mahjongFrame:getSize(kSeatMine);

		local teachW, teachH = self.teachLayerTip:getSize();
		local teachX = self.mahjongManager.mahjongFrame:getInhandFrame ( kSeatMine, 14 , 0);
		self.teachLayerTip:setPos(teachX - teachW - 40, y - teachH);
		self.teachTextView:setText("双击或拖动三条就可以将它打出去，so easy",self.TEXT_VIEW_WIDTH,self.TEXT_VIEW_HEIGHT, 0xcc, 0x44, 0x00);
		self.tipNextNode:setVisible(false);

		local catchS = self.mahjongManager.mahjongFrame:getCatchFrame ( kSeatMine, 0 , 0);
	   	local catchE = x + w;

		--local clickAnim = new(SCSprite , SpriteConfig.TYPE_TEACH_CLICK);
		--clickAnim:setPlayMode(kAnimRepeat);
		--clickAnim:setPos(catchS, y - 170);
		--clickAnim:play();
		
		--local arrowImg = UICreator.createImg(TeachPin_map["clickW.png"],catchS, y - 170)
		--arrowImg:addPropTranslate(1,kAnimRepeat,1.0,0.0,0,100,0,0)--(self, sequence, animType, duration, delay, startX, endX, startY, endY)
		--self.rootNode:addChild(arrowImg);

		self.hasNext = false;
		for k , v in pairs(self.mahjongManager.mineInHandCards) do
			v:clearHasAppear();
		end
		self:setDingQueTypeWithInHandCards(2);
	end
	self.curStep = self.curStep + 1;
end

TeachRoomScene.setDingQueTypeWithInHandCards = function (self , type)
	local myself = PlayerManager.getInstance():myself();
	myself.dingQueType = type;
	self.mahjongManager:setMineInHandCardsWhenOutCard();
end

TeachRoomScene.wanTongTiaoView = function (self , seatId)
	local inHandCards = self.mahjongManager:getInHandCardsBySeat(seatId);
	for k , v in pairs(inHandCards) do
		if 0 == v.mjType then
			v:setCustomColor(208,171,115);
		end
		if 1 == v.mjType then
			v:setCustomColor(128,141,176);
		end
		if 2 == v.mjType then
			v:setCustomColor(200,151,140);
		end
	end
end

-- 打牌
TeachRoomScene.outCardRequest = function (self , value)
	self.rootNode:removeAllChildren();
	self.super.outCardRequest(self,value);
end

TeachRoomScene.operationCallback = function ( self, operationType, cardValue )
	if cardValue <= 0 then
		return;
	end
	self.operationView:hideOperation();
	-- 玩家选择取消时：operationType, cardValue都为0
	self.chiPengGangCard = cardValue;
	local param = {};
	param.cardValue = cardValue;
	param.operatorValue = operationType;
	self:takeOperation(param)
	--self:requestCtrlCmd(TeachRoomController.s_cmds.takeOperation, param);
	self.mahjongManager:setAllMahjongFrameDown();
end

-- 普通玩法中间有人胡
TeachRoomScene.hu = function ( self, infoTable )
	-- 移除中心显示的打出牌
	self.mahjongManager:removeBigShowCenterView();
	local sm = self.seatManager;
	GameEffect.getInstance():play("AUDIO_WIN");
	self.mahjongManager:setAllMahjongFrameDown();
	self:setMineGameFinish();
	sm.seatList[infoTable.seatId]:huInGame(infoTable.huType);
	if 1 == infoTable.huType then

		--self:playGameAnim(SpriteConfig.TYPE_HU, infoTable.seatId);
	else
		self:playGameAnim(SpriteConfig.TYPE_ZIMO, infoTable.seatId);
	end
	self.mahjongManager:setInHandCardsWhenHuBySeat(infoTable.seatId);
	self.mahjongManager:setHuCardBySeat(infoTable.seatId , infoTable.huCard , infoTable.huType);
	local player = PlayerManager.getInstance():myself();
	self:showChangMoneyAnim(player.mid , 510000);
	for i = 1,3 do
		local player = PlayerManager.getInstance():getPlayerBySeat(i);
		self:showChangMoneyAnim(player.mid , 170000);
	end
	self.ishu = true;
	self.curStep = 1;
	self.hasNext = true;
	self:setTipsViewAfterHu();
	self.seatManager:gameFinish();
end

TeachRoomScene.setTipsViewAfterHu = function (self)
	self.rootNode:removeAllChildren();
	if 1 == self.curStep then
		local teachW, teachH = self.teachLayerTip:getSize();
		local x, y = self.mahjongManager.mahjongFrame:getPos(kSeatMine);
		local w, h = self.mahjongManager.mahjongFrame:getSize(kSeatMine);
		self.teachLayerTip:setPos(x + w - teachW, y - teachH);
	   	self.teachTextView:setText("一家胡牌，其他继续玩牌，直到三家胡牌或者牌抓完",self.TEXT_VIEW_WIDTH,self.TEXT_VIEW_HEIGHT, 0xcc, 0x44, 0x00);
	   	self.tipNextNode:setVisible(true);
	elseif 2 == self.curStep then
		self:showAllPlayerInHands();
		local teachW, teachH = self.teachLayerTip:getSize();
		local x, y = self.mahjongManager.mahjongFrame:getPos(kSeatMine);
		local w, h = self.mahjongManager.mahjongFrame:getSize(kSeatMine);
		self.teachLayerTip:setPos(x + w - teachW, y - teachH);
	   	self.teachTextView:setText("结束时，没胡牌的人参与查花猪，查大叫",self.TEXT_VIEW_WIDTH,self.TEXT_VIEW_HEIGHT, 0xcc, 0x44, 0x00);
	   	self.tipNextNode:setVisible(true);
  		self:showLeftCardNum(0);
	elseif 3 == self.curStep then
		local teachW, teachH = self.teachLayerTip:getSize();
		local x, y = self.mahjongManager.mahjongFrame:getPos(kSeatMine);
		local w, h = self.mahjongManager.mahjongFrame:getSize(kSeatMine);
		self.teachLayerTip:setPos(x + w - teachW, y - teachH);
	   	self.teachTextView:setText("有三种花色牌的人要被查花猪哦",self.TEXT_VIEW_WIDTH,self.TEXT_VIEW_HEIGHT, 0xcc, 0x44, 0x00);
	   	self.tipNextNode:setVisible(true);
	   	self:wanTongTiaoView(2);
	   	local player = PlayerManager.getInstance():myself();
	   	self:showChangMoneyAnim(player.mid + 2 , -320000);
	   	self:showChangMoneyAnim(player.mid + 1 , 160000);
	   	self:showChangMoneyAnim(player.mid + 3 , 160000);
	elseif 4 == self.curStep then
		local inHandCards = self.mahjongManager:getInHandCardsBySeat(2);
		for k , v in pairs(inHandCards) do
			v:clearHasAppear();
		end
		local teachW, teachH = self.teachLayerTip:getSize();
		local x, y = self.mahjongManager.mahjongFrame:getPos(kSeatMine);
		local w, h = self.mahjongManager.mahjongFrame:getSize(kSeatMine);
		self.teachLayerTip:setPos(x + w - teachW, y - teachH);
	   	self.teachTextView:setText("没听牌的要被听牌的查大叫,按手牌能胡的最大番算",self.TEXT_VIEW_WIDTH,self.TEXT_VIEW_HEIGHT, 0xcc, 0x44, 0x00);
	   	self.tipNextNode:setVisible(true);
	   	local player = PlayerManager.getInstance():myself();
	   	self:showChangMoneyAnim(player.mid + 1 , 20000);
	   	self:showChangMoneyAnim(player.mid + 3 , -20000);
	elseif 5 == self.curStep then
		self:setTeachEndView();
		self.hasNext = false;
		self.ishu = false;
	end
	self.curStep = self.curStep + 1;
end

TeachRoomScene.setTeachEndView = function (self)
	self.teachLayerTip:setVisible(false);
	self.rootNode:setPickable(true);


	local scaleW = System.getScreenWidth() / System.getLayoutWidth() / System.getLayoutScale(); 
	local scaleH = System.getScreenHeight() / System.getLayoutHeight() / System.getLayoutScale();
	

	local btnTitle = UICreator.createText( "继 续", 0, -5, 0, 0, kAlignCenter, 36, 255, 255, 255)
	local quickGameBtn = UICreator.createBtn("Commonx/green_big_wide_btn.png");
	quickGameBtn:addChild(btnTitle);
	btnTitle:setAlign(kAlignCenter);	
	local quickW , quickH = quickGameBtn:getSize();
	quickGameBtn:setPos((MahjongLayout_W - quickW) / 2 , 483);
	makeTheControlAdaptResolution(quickGameBtn);
	self.nodeRoomItem:addChild(quickGameBtn);
	quickGameBtn:setOnClick(self , function ( self )
		GameConstant.teachRoomQuickStart = true;
		self:exitGame();
	end);
--[[
	local clickAnim = new(SCSprite , SpriteConfig.TYPE_TEACH_READY_TIP);
	clickAnim:setPlayMode(kAnimRepeat);
	clickAnim:setPos(-200  , 17 );
	DebugLog("clickAnim.m_x "..(clickAnim.m_x or 0).."    clickAnim.m_y "..(clickAnim.m_y or 0));
	quickGameBtn:addChild(clickAnim);
	clickAnim:play();
]]
end

TeachRoomScene.showAllPlayerInHands = function (self)
	local param = { { 0x02, 0x03 , 0x04, 0x15 , 0x19 , 0x19, 0x19},
					{ 0x14 , 0x14 , 0x14 , 0x25, 0x25, 0x25 , 0x26, 0x26, 0x26, 0x27, 0x27, 0x27, 0x29},
					{ 0x07, 0x08, 0x09, 0x11, 0x11, 0x12, 0x12, 0x18, 0x18 , 0x21, 0x21, 0x28, 0x28},
					{ 0x02, 0x06, 0x06, 0x07, 0x07, 0x07, 0x08, 0x08, 0x08, 0x09, 0x24, 0x24, 0x25}};
	local infoTable = {};
	for i = 0 , 3 do
		local t = {};
		local player = PlayerManager.getInstance():getPlayerBySeat(i);
		t.userId = player.mid;
		t.isHu = 0;
		if player.isMyself then
			t.isHu = 1;
			t.huCard = 0x15;
			t.huType = 2;
		end
		t.cardList = param[i + 1];
		table.insert(infoTable , t);
	end
	self:dealGameOverInHandCards(infoTable);
	param = { { 0x02 , 0x09 , 0x06 , 0x09, 0x11, 0x11 , 0x12, 0x13, 0x04, 0x04},
					{ 0x17, 0x18, 0x19, 0x18, 0x19, 0x22, 0x02, 0x02, 0x22 },
					{ 0x05, 0x05, 0x22, 0x23, 0x23, 0x29, 0x29}};
	for i = 1 , 3 do
		local player = PlayerManager.getInstance():getPlayerBySeat(i);
		for k , v in pairs(param[i]) do
			self.mahjongManager:showDiscardOnTable(player.localSeatId , v);
		end
	end
end

TeachRoomScene.broadcastOutCard = function (self , data)
	self.super.broadcastOutCard(self,data);
	if data.operateValue > 0 then
		self.rootNode:removeAllChildren();
		local teachW, teachH = self.teachLayerTip:getSize();
		local x, y = self.mahjongManager.mahjongFrame:getPos(kSeatMine);
		local w, h = self.mahjongManager.mahjongFrame:getSize(kSeatMine);

		self.teachLayerTip:setPos(x + (w - teachW)/2 ,RoomCoor.gameAnim[1][kSeatMine][2] - teachH);
		self.teachTextView:setText("有人打出一万，哇，快点杠了（明杠，即刮风）",self.TEXT_VIEW_WIDTH,self.TEXT_VIEW_HEIGHT, 0xcc, 0x44, 0x00);
	end
end

TeachRoomScene.OnClickBackGroundImg = function (self , finger_action,x, y,drawing_id_first,drawing_id_current)
	if kFingerDown == finger_action then
		if self.hasNext then
			if self.ishu then
				self:setTipsViewAfterHu();
			else
				self:setTipsView();
			end
		end
	end
end

------------------------------------------------------------------------------------
TeachRoomScene.readyActionToServer = function ( self )
	DebugLog("点击准备，开始游戏");
	self:readyStartGame(0)
	self.needGang = true;
	self.anim = new(AnimInt,kAnimNormal,0,1,1000);
	self.anim:setDebugName("TeachRoomController|self.anim");
	self.anim:setEvent(self, function ( self )
		local t = { 0x01 , 0x01 , 0x01 , 0x02 , 0x03 , 0x04 , 0x15 , 0x16 , 0x16 , 0x16 , 0x19 , 0x19, 0x19};
		self:startGameDealCard(t)
		delete(self.anim);
		self.anim = nil;
	end);
	self.anim_1 = new(AnimInt,kAnimNormal,0,1,4000);
	self.anim_1:setEvent(self, function ( self )
		local roomData = RoomData.getInstance();
  		roomData.leftcard = 56;
  		self:showLeftCardNum( roomData.leftcard )
		local data = {};
		data.lastCard = 0x23;
		data.operateValue = 0;
		self:myselfCatchCard(data)
		delete(self.anim_1);
		self.anim_1 = nil;
	end);
end

TeachRoomScene.outCardAction = function (self , value)
	local data = {};
	data.userId = self.myself.mid + 1;

	self:broadcastCurrentPlayerServer(data);
	data = {};
	data.userId = self.myself.mid + 1;
	data.card = 0x01;
	data.operateValue = PUNG_KONG;
	self:broadcastOutCardServer(data);
end

TeachRoomScene.broadcastOutCardServer = function (self , data)
	self.super.broadcastOutCardServer(self , data);
end

-- 进行操作
TeachRoomScene.takeOperation = function ( self, data )
	if operatorValueHasHu(data.operatorValue) then
		local param = {};
		param.seatId = 0;
		param.huCard = data.cardValue;
		param.huType = 2;
		self:hu(param)
		return;
	end
	local param = {};
	param.userId = self.myself.mid;
	param.card = data.cardValue;
	param.operateValue = data.operatorValue;
	self:broadcastTakeOperation(param);
	param = {};
	
	if peng_gang(data.operatorValue) then
		param.gangType = 1;
		param.userId =	self.myself.mid;
		param.userMoney = 20000;
		param.userList = {};
		local t = {};
		t.userId = self.myself.mid + 1;
		t.gangMoney = -20000;
		table.insert(param.userList , t);
	else
		param.gangType = 2;
		param.userId =	self.myself.mid;
		param.userMoney = 60000;
		param.userList = {};
		for i = 1,3 do
			local t = {};
			t.userId = self.myself.mid + i;
			t.gangMoney = -20000;
			table.insert(param.userList , t);
		end
	end
	self:broadcastGFXYToTable(param);
	if self.needGang then
		self.needGang = false;
		param = {};
		param.lastCard = 0x16;
		param.operateValue = AN_KONG;
		param.angang = {};
		table.insert(param.angang , 0x16);
		param.bugang = {};
		self:myselfCatchCardServer(param);
	else
		param = {};
		param.lastCard = 0x15;
		param.operateValue = ZI_MO;
		param.angang = {};
		param.bugang = {};
		self:myselfCatchCardServer(param);
	end
end

-- 退出游戏
TeachRoomScene.exitGame = function ( self )
	PlayerManager:getInstance():removeOtherPlay(); -- 移除其他玩家数据
	RoomData.getInstance():clearData(); -- 清除房间数据
	PlayerManager:getInstance():myself():exitGame(); -- 改变自己的状态
	local player = PlayerManager.getInstance():myself();
	player.nickName = self.nickName;
	player.money = self.money;
	GameState.changeState( nil, States.Hall );
end

----------------------------------------------------------------------------------------------------
TeachRoomScene.s_controlFuncMap =
{
	[TeachRoomScene.s_controls.backGround] = TeachRoomScene.OnClickBackGroundImg,
}

-- 可接受的更新界面命令
TeachRoomScene.s_cmds = 
{

};

-- 命令响应函数
TeachRoomScene.s_cmdConfig = 
{
};

