require("MahjongRoom/GameResult/ResultDetailList");
require("MahjongRoom/GameResult/NewResultDetailList");
require("MahjongCommon/MahjongListView");
require("Animation/GameResultNumberAnim");
require("Animation/GameResultScoreAnim");
local gameResultMatch = require(ViewLuaPath.."gameResultMatch");
require("Animation/PlayCardsAnim/animationDraw");
require("Animation/PlayCardsAnim/animationLost");
require("Animation/PlayCardsAnim/animationWin");
require("Animation/PlayCardsAnim/animationTopScore");
require("Animation/ChangeScoreAnim");

local roomResultDetailPin_map = require("qnPlist/roomResultDetailPin")

-- 游戏结算界面
GameResultWindowMatch = class(CustomNode);


GameResultWindowMatch.bankraptcyCoord = 
{
	[kSeatMine] = {0, 0},
	[kSeatRight]= {0, 0},
	[kSeatTop] 	= {0, 0},
	[kSeatLeft] = {0, 0}
}

GameResultWindowMatch.ctor = function ( self )
	self.curShowDetailSeat = nil; -- 默认显示自己
	self.pm = PlayerManager.getInstance(); -- 注意：这个PlayerManager的部分玩家数据有可能被清除了
	self.resultInfoList = {};
	self.listView = {};
	self.huCardOrder = {}; -- 胡牌顺序
	self.playerBaseInfo = {};
	self.resultMoney = 0;
	self.advanceResultFlag = 0;
    self:setCoverTransparent()
  
    self:setLevel(100);
	--禁止窗外关闭
	self.cover:setEventTouch(self, function ( self )
	end);


	self.isFreeMatchGame = MatchRoomScene_instance:isFreeMatchGame()

end

GameResultWindowMatch.setCallbackClose = function ( self, obj, func )
	self.closeObj = obj;
	self.closeFunc = func;
end

GameResultWindowMatch.setAgainCallback = function ( self, obj, fun )
	self.againEvent = fun;
	self.againObj = obj;
end


-- 大结算
GameResultWindowMatch.showWindow1 = function ( self )
	self.window = SceneLoader.load(gameResultMatch);
	self:addChild(self.window);

	--禁止窗外关闭
	self.window:setEventTouch(self, function ( self )
	end);


	--设置关闭事件
	self.btnClose = publ_getItemFromTree(self.window,{"btn_close"});
	self.btnClose:setOnClick(self, function ( self )
		MatchRoomScene_instance:deleteLittleResultDetailView();
		if self.m_parent then -- 移除自己
			if self.closeFunc then
				self.closeFunc(self.closeObj);
			end
		end
	end);

	--详情
	self.detailBtn_time = publ_getItemFromTree(self.window,{"view_main","btn_detail_time"});
	self.detailBtn_time:setOnClick(self, function ( self )
		MatchRoomScene_instance:deleteLittleResultDetailView();
		self:createDetailFrom(); --加载详细信息界面
        -- publ_getItemFromTree(self.confirmBtn, {"name"}):setText(self.confirmName or "");
        for k,v in pairs(self.resultInfoList) do
            if kSeatMine == k then
			    self:resuleFrame(v.turnMoney);
		    end
        end
        self:showHeadInfo(); --加载完详细信息后设置头部信息
	    self:showDetailBySeatid(kSeatMine);
		self.window:setVisible(false);
		self.resultView:setVisible(true);
	end);

	--是否破产
	for i = 0, 3 do
		if self.resultInfoList[i].totalMoney <= 0  then
			local bankraptcyImg = UICreator.createImg("Room/result/bankraptcy_tip.png",GameResultWindowMatch.bankraptcyCoord[i][1],GameResultWindowMatch.bankraptcyCoord[i][2]);
			self.window:addChild(bankraptcyImg);
		end
	end

	--动画
	local coord = {};
	for i = 0, 3 do
		coord[i] = {};
	end

	--主玩家
	local viewW, _  	= self:getSize();
	self.continueBtn = publ_getItemFromTree(self.window,{"view_main","btn_continue"});
	self.continueBtn:setOnClick(self, self.onClickContinueBtn);
	local _, 	 btnY 	= publ_getItemFromTree(self.window,{"view_main","btn_continue"}):getAbsolutePos();

	self.continueBtn_time = publ_getItemFromTree(self.window,{"view_main","btn_continue_time"});
	self.continueBtn_time:setOnClick(self, self.onClickContinueBtn_time);
	local money = self.resultInfoList[0].turnMoney;
	local moneyWidth = 51 * (money > 0 and string.len("+".. money) or string.len("" .. money) );
	coord[kSeatMine][1], coord[kSeatMine][2] = (viewW - moneyWidth) / 2 , btnY - 131;


	if self.isFreeMatchGame then 
		local score = self.resultInfoList[0].score;
		local ScoreAnim = new (GameResultScoreAnim, score, true);
		--ScoreAnim:setAlign(kAlignTop);
		ScoreAnim:setPos(coord[kSeatMine][1], coord[kSeatMine][2]+60);--0,65
		self.window:addChild(ScoreAnim);
		ScoreAnim:show();		
	else 
		local numberAnim = new (GameResultNumberAnim, money, money > 0);
		numberAnim:setPos( coord[kSeatMine][1], coord[kSeatMine][2]+20);

		local score = self.resultInfoList[0].score;
		local ScoreAnim = new (GameResultScoreAnim, score, true);
		ScoreAnim:setAlign(kAlignTop);
		ScoreAnim:setPos(0,65);
		--numberAnim:setPos(0,20)
		self.window:addChild(numberAnim);
		numberAnim:addChild(ScoreAnim);

		numberAnim:show();
		ScoreAnim:show();
	end 


	--右玩家
	local money = self.resultInfoList[1].turnMoney;
	local score = self.resultInfoList[1].score;

	local moneyTotolW = 54 * (money == 0 and string.len("" .. money) or string.len("+".. money));
	local scoreTotolW = 40 * (2+string.len("" .. score));
	local x, y = RoomCoor.showMoneyCoor[1][1], RoomCoor.showMoneyCoor[1][2]-30;
	x = x - 54 * (money > 0 and string.len("+".. money) or string.len("" .. money) ); -- 钱右对齐
	if moneyTotolW < scoreTotolW then
		x = x - (scoreTotolW-moneyTotolW)/2;
	end

	coord[1][1], coord[1][2] = x, y;

	--上完家
	coord[2][1], coord[2][2] = RoomCoor.showMoneyCoor[2][1], RoomCoor.showMoneyCoor[2][2];
	--左玩家
	local money = self.resultInfoList[2].turnMoney;
	coord[3][1], coord[3][2] = RoomCoor.showMoneyCoor[3][1], RoomCoor.showMoneyCoor[3][2]-30;

	for i = 1, 3 do


		if self.isFreeMatchGame then 
			local scoreView = new(ChangeScoreAnim, self.resultInfoList[i].score, coord[i][1], coord[i][2],nil,false);
			self.window:addChild(scoreView);
			scoreView:show();			
		else 
			local number = new(ChangeMoneyAnim, tonumber(self.resultInfoList[i].turnMoney), coord[i][1], coord[i][2],nil,false);
			self.window:addChild(number);
			local scoreView = new(ChangeScoreAnim, self.resultInfoList[i].score, coord[i][1], coord[i][2],nil,false);
			number:addChild(scoreView);
			scoreView:setAlign(kAlignTop);
			scoreView:setPos(0,58);
			number:show();
			scoreView:show();			
		end 
	end

	self.centerNode = new(Node);
	self.window:addChild(self.centerNode);
	self.centerNode:setSize(500, 400);
	self.centerNode:setAlign(kAlignCenter);
	self.centerNode:addPropScaleSolid(0,0.7,0.7,kCenterDrawing)
	local p = {{0,-250}, {0,-250}, {0,-250},{360,-40}};

	-- 输
	if self.resultMoney < 0 then
		self.centerLostAnim = new(AnimationLost, p[1], self.centerNode);
		self.centerNode:addChild(self.centerLostAnim);
		self.centerLostAnim:play();
	-- 平局
	elseif self.resultMoney == 0 then
		self.centerDrawAnim = new(AnimationDraw, p[2], self.centerNode);
		self.centerNode:addChild(self.centerDrawAnim);
		self.centerDrawAnim:play();
	-- 赢
	else
		self.centerWinAnim = new(AnimationWin, p[3], self.centerNode);
		self.centerNode:addChild(self.centerWinAnim);
		self.centerWinAnim:play();
		if not self.isFreeMatchGame then 
			showGoldDropAnimation();--播放掉金币动画--显示金币雨
		end 
		-- self.i = 0;
		-- self.screenShock = new(AnimInt, kAnimRepeat, 0, 1, 500, 0);
		-- self.screenShock:setDebugName("GameResultWindowMatch|self.screenShock");
		-- self.screenShock:setEvent(self, function ( self )
		-- 	if self.i < 2 then
		-- 		native_to_java(kScreenShock); -- 振动
		-- 		self.i = self.i + 1;
		-- 	else
		-- 		delete(self.screenShock);
		-- 		self.screenShock = nil;
		-- 	end
		-- end);
	end



-- self.isTopWin = true; -- debug
	if self.isTopWin then -- 显示历史新高动画
		self.centerTopScoreAnim = new(AnimationTopScore, p[4], self.centerNode);
		self.centerTopScoreAnim:play();
	end

	if self.resultContinueTime and self.resultContinueTime > 0 then
		self:showContinueBtn(self.resultContinueTime);
	else
		self.continueBtn_time:setVisible(true);
		self.detailBtn_time:setVisible(true);
		self.btnClose:setVisible(true);
	end

end

-- 人满赛预赛提前胡
GameResultWindowMatch.showAdvanceResultWindow = function ( self, data )
	self.advanceResultWindow = SceneLoader.load(gameResultMatch);
	self:addChild(self.advanceResultWindow);

	--禁止窗外关闭
	self.advanceResultWindow:setEventTouch(self, function ( self )
	end);

	--动画
	local coord = {};
	for i = 0, 3 do
		coord[i] = {};
	end

	--主玩家
	local viewW, _  	= self:getSize();
	self.continueBtn = publ_getItemFromTree(self.advanceResultWindow,{"view_main","btn_continue"});
	self.continueBtn:setOnClick(self, self.onClickContinueBtn);
	local _, 	 btnY = self.continueBtn:getAbsolutePos();
	local money = data.money;
	local moneyWidth = 51 * (money > 0 and string.len("+".. money) or string.len("" .. money) );
	coord[kSeatMine][1], coord[kSeatMine][2] = (viewW - moneyWidth) / 2 , btnY - 131;
	
	if self.isFreeMatchGame then 
		local score = data.score;
		local ScoreAnim = new (GameResultScoreAnim, score, true);
		self.advanceResultWindow:addChild(ScoreAnim);
		ScoreAnim:setPos(coord[kSeatMine][1], coord[kSeatMine][2]+60);
		ScoreAnim:show();		
	else 
		local numberAnim = new (GameResultNumberAnim, money, money > 0);
		numberAnim:setPos( coord[kSeatMine][1], coord[kSeatMine][2]+20);
		self.advanceResultWindow:addChild(numberAnim);
		local score = data.score;
		local ScoreAnim = new (GameResultScoreAnim, score, true);
		
		numberAnim:addChild(ScoreAnim);
		ScoreAnim:setAlign(kAlignTop);
		ScoreAnim:setPos(0,65);
		--numberAnim:setPos(0,20)
		numberAnim:show();
		ScoreAnim:show();
	end

	self.centerNode = new(Node);
	self.advanceResultWindow:addChild(self.centerNode);
	self.centerNode:setSize(500, 400);
	self.centerNode:setAlign(kAlignCenter);

	self.centerNode:addPropScaleSolid(0,0.7,0.7,kCenterDrawing)
	local p = {{0,-250}, {0,-250}, {0,-250},{360,-40}};

	--local p = {{0,-80}, {0,-130}, {0,-120},{360,-40}};



	-- 输
	if data.money < 0 then
		self.centerLostAnim = new(AnimationLost, p[1], self.centerNode);
		self.centerNode:addChild(self.centerLostAnim);
		self.centerLostAnim:play();
	-- 平局
	elseif data.money == 0 then
		self.centerDrawAnim = new(AnimationDraw, p[2], self.centerNode);
		self.centerNode:addChild(self.centerDrawAnim);
		self.centerDrawAnim:play();
	-- 赢
	else
		self.centerWinAnim = new(AnimationWin, p[3], self.centerNode);
		self.centerNode:addChild(self.centerWinAnim);
		self.centerWinAnim:play();
		if not self.isFreeMatchGame then 
			showGoldDropAnimation();--播放掉金币动画--显示金币雨
		end 
		-- self.i = 0;
		-- self.screenShock = new(AnimInt, kAnimRepeat, 0, 1, 500, 0);
		-- self.screenShock:setDebugName("GameResultadvanceResultWindowMatch|self.screenShock");
		-- self.screenShock:setEvent(self, function ( self )
		-- 	if self.i < 2 then
		-- 		native_to_java(kScreenShock); -- 振动
		-- 		self.i = self.i + 1;
		-- 	else
		-- 		delete(self.screenShock);
		-- 		self.screenShock = nil;
		-- 	end
		-- end);
	end
	self:showContinueBtn(data.time);
end

GameResultWindowMatch.showContinueBtn = function ( self, time)
	local continueW, continueH = self.continueBtn:getSize();
	local str = "继续" .. "( " .. time .. " )";
	self.continueText = UICreator.createText(str,0,0,continueW,continueH,kAlignCenter,30,255,255,255);
	self.continueText:setAlign(kAlignCenter);
	self.continueBtn:addChild(self.continueText);
	self.time = time;
	self.str = "继续";
	self.continueBtn:setVisible(true);
	self:timer();	
end


-- 1秒定时器
GameResultWindowMatch.timer = function (self)
	if self.timerAnim then
		return;
	end

	self.timerAnim = self:addPropRotate(100,kAnimRepeat,1000,0,0,0,kCenterDrawing);
	--new(AnimInt,kAnimRepeat,-1,-1,1000,-1);
	self.timerAnim:setDebugName("GameResultWindowMatch|self.timerAnim");
	self.timerAnim:setEvent(self, self.updateTime);
end

-- 刷新倒计时
GameResultWindowMatch.updateTime = function ( self )
	if 0 == self.time then
		self.continueText:setText(self.str .. "( " .. self.time .. " )");
		self:onClickContinueBtn();
	elseif 0 < self.time then
		self.time = self.time - 1;
		if self.continueText then
			self.continueText:setText(self.str .. "( " .. self.time .. " )");
		end
	end
end

--创建详细信息模块
GameResultWindowMatch.createDetailFrom = function ( self)
	local resultLayout = require(ViewLuaPath.."resultLayout");
	self.resultView = SceneLoader.load(resultLayout);
	self:addChild(self.resultView);

	self.tagBtn1 = publ_getItemFromTree(self.resultView, { "tagBtn1"});
	self.tagBtn2 = publ_getItemFromTree(self.resultView, { "tagBtn2"});
	self.tagBtn3 = publ_getItemFromTree(self.resultView, { "tagBtn3"});
	self.tagBtn4 = publ_getItemFromTree(self.resultView, { "tagBtn4"});

	self.bg = publ_getItemFromTree(self.resultView, { "bg"});

	self.resultView:setEventTouch(self,function(self)

	end);
	self.bg:setEventTouch(self, function ( self )
	end);


	self.myMoneyText = publ_getItemFromTree(self.resultView, {"bg", "listBg", "money_bg1", "money"});
	self.moneyText1  = publ_getItemFromTree(self.resultView, {"bg", "listBg", "money_bg2", "money"});
	self.moneyText2  = publ_getItemFromTree(self.resultView, {"bg", "listBg", "money_bg3", "money"});
	self.moneyText3  = publ_getItemFromTree(self.resultView, {"bg", "listBg", "money_bg4", "money"});

	self.myNameText = publ_getItemFromTree(self.resultView, { "tagBtn1","name"});
	self.nameText1  = publ_getItemFromTree(self.resultView, { "tagBtn2","name"});
	self.nameText2  = publ_getItemFromTree(self.resultView, { "tagBtn3","name"});
	self.nameText3  = publ_getItemFromTree(self.resultView, { "tagBtn4","name"});

	self.contentBg = publ_getItemFromTree(self.resultView, {"bg", "listBg"});

	publ_getItemFromTree(self.resultView, {"bg", "confirmBtn"}):setVisible(false);
	publ_getItemFromTree(self.resultView, { "bg","again"}):setVisible(false);
	publ_getItemFromTree(self.resultView, { "bg","continueBtn"}):setVisible(true);
	self.closeBtn = publ_getItemFromTree(self.resultView, { "bg", "close"});
	self.closeBtn:setOnClick(self, function ( self )
		if self.m_parent then -- 移除自己
			if self.closeFunc then
				self.closeFunc(self.closeObj);
			end
		end
	end);
	-- 大结算详情继续按钮
	publ_getItemFromTree(self.resultView, { "bg","continueBtn"}):setOnClick(self, function ( self )
		-- if MatchRoomScene_instance then
		-- 	MatchRoomScene_instance.nodePopu:removeChild(MatchRoomScene_instance.resultView, true);
		-- 	MatchRoomScene_instance.resultView = nil;
		-- end

		-- if 8 == GameConstant.matchStatus.matchStage then
		-- 	-- 提前胡请求换桌
		-- 	local param = {};
		-- 	param.mid = PlayerManager.getInstance():myself().mid;
		-- 	SocketManager.getInstance():sendPack(CLIENT_COMMAND_REQ_LOGOUT, param);
		-- 	MatchRoomScene_instance:showWaitStartOrRankView("正在为您配桌");
		-- elseif 9 == GameConstant.matchStatus.matchStage then
		-- 	PlayerManager:getInstance():removeOtherPlay(); -- 移除其他玩家数据
		-- 	RoomData.getInstance():clearData(); -- 清除房间数据
		-- 	for k,v in pairs(RoomScene_instance:getScene().seatManager.seatList) do
		-- 		v:changeToWaitStaty();
		-- 		if v.seatID ~= kSeatMine then
		-- 			v:clearData();
		-- 		end
		-- 	end
		-- 	RoomScene_instance:updateView(RoomScene.s_cmds.clearDesk);
		-- 	GameConstant.isDirtPlayGame = true;
		-- 	MatchRoomScene_instance:removeResultViewNode();
		-- 	local str = "预赛已结束，" .. string.sub(os.date("%X", GameConstant.matchStatus.taoTaiStartTime), 0, 5) .. "系统将排名并确定晋级名单";
		-- 	MatchRoomScene_instance:showWaitStartOrRankView(str);
		-- 	MatchRoomScene_instance:processLoginRoom();
		-- end

		MatchRoomScene_instance:removeResultViewNode();
		PlayerManager:getInstance():removeOtherPlay(); -- 移除其他玩家数据
		RoomData.getInstance():clearData(); -- 清除房间数据
		for k,v in pairs(RoomScene_instance.seatManager.seatList) do
			v:changeToWaitStaty();
			if v.seatID ~= kSeatMine then
				v:clearData();
			end
		end
		MatchRoomScene_instance:clearDesk();
		GameConstant.isDirtPlayGame = true;
		if 8 == GameConstant.matchStatus.matchStage then
			MatchRoomScene_instance:showWaitStartOrRankView("正在为您配桌");
		elseif 9 == GameConstant.matchStatus.matchStage then
			local str = "预赛已结束，" .. string.sub(os.date("%X", GameConstant.matchStatus.taoTaiStartTime), 0, 5) .. "系统将排名并确定晋级名单";
			MatchRoomScene_instance:showWaitStartOrRankView(str);
		end
		MatchRoomScene_instance:processLoginRoom();

	end);

	self:initTagBtnAction();
	self.resultView:setVisible(false);
end



GameResultWindowMatch.onClickContinueBtn = function ( self )
	if MatchRoomScene_instance then
		if 4 == GameConstant.matchStatus.matchStage then --  决赛
			MatchRoomScene_instance:removeResultViewCleanCards();
		else -- 非决赛
			MatchRoomScene_instance:removeResultViewCleanDesk();
		end

		if 9 == GameConstant.matchStatus.matchStage then
			local str = "预赛已结束，" .. string.sub(os.date("%X", GameConstant.matchStatus.taoTaiStartTime), 0, 5) .. "系统将排名并确定晋级名单";
			MatchRoomScene_instance:showWaitStartOrRankView(str);
		else
			MatchRoomScene_instance:showWaitStartOrRankView("正在为您排名中");
		end
	end
end



GameResultWindowMatch.onClickContinueBtn_time = function ( self )
	-- if 8 == GameConstant.matchStatus.matchStage then
	-- 	-- 提前胡请求换桌
	-- 	local param = {};
	-- 	param.mid = PlayerManager.getInstance():myself().mid;
	-- 	SocketManager.getInstance():sendPack(CLIENT_COMMAND_REQ_LOGOUT, param);
	-- 	MatchRoomScene_instance:showWaitStartOrRankView("正在为您配桌");


	-- elseif 9 == GameConstant.matchStatus.matchStage then
	-- 	PlayerManager:getInstance():removeOtherPlay(); -- 移除其他玩家数据
	-- 	RoomData.getInstance():clearData(); -- 清除房间数据
	-- 	for k,v in pairs(RoomScene_instance:getScene().seatManager.seatList) do
	-- 		v:changeToWaitStaty();
	-- 		if v.seatID ~= kSeatMine then
	-- 			v:clearData();
	-- 		end
	-- 	end
	-- 	RoomScene_instance:updateView(RoomScene.s_cmds.clearDesk);
	-- 	GameConstant.isDirtPlayGame = true;
	-- 	MatchRoomScene_instance:removeResultViewNode();
	-- 	local str = "预赛已结束，" .. string.sub(os.date("%X", GameConstant.matchStatus.taoTaiStartTime), 0, 5) .. "系统将排名并确定晋级名单";
	-- 	MatchRoomScene_instance:showWaitStartOrRankView(str);
	-- 	MatchRoomScene_instance:processLoginRoom();
	-- end

	MatchRoomScene_instance:deleteLittleResultDetailView();
	-- 提前胡请求换桌
	MatchRoomScene_instance:removeResultViewNode();
	MatchRoomScene_instance:hideReadyBtn();
	PlayerManager:getInstance():removeOtherPlay(); -- 移除其他玩家数据
	RoomData.getInstance():clearData(); -- 清除房间数据
	for k,v in pairs(RoomScene_instance.seatManager.seatList) do
		-- v:changeToWaitStaty();
		if v.seatID ~= kSeatMine then
			v:clearData();
		end
	end
	MatchRoomScene_instance:clearDesk();
	GameConstant.isDirtPlayGame = true;
	MatchRoomScene_instance:processLoginRoom();



	if 8 == GameConstant.matchStatus.matchStage then
		MatchRoomScene_instance:showWaitStartOrRankView("正在为您配桌");
	elseif 9 == GameConstant.matchStatus.matchStage then
		local str = "预赛已结束，" .. string.sub(os.date("%X", GameConstant.matchStatus.taoTaiStartTime), 0, 5) .. "系统将排名并确定晋级名单";
		MatchRoomScene_instance:showWaitStartOrRankView(str);
	end

end

GameResultWindowMatch.setContinueCallback = function ( self, obj, fun )
	self.continueEvent = fun;
	self.continueObj = obj;
end

-- -- 解析网络数据，并显示出来，默认显示自己的结果
GameResultWindowMatch.parseDataAndShowInitinfo = function ( self, resultInfo, isNewCmd )
	self.isNewCmd = isNewCmd or false;
	if isNewCmd then
		self:parseDetailInfo2(resultInfo); -- 新结算
	else
		self:parseDetailInfo(resultInfo); -- 老结算
	end
end

-- 处理网络数据，用于之后显示详细列表
GameResultWindowMatch.parseDetailInfo2 = function ( self, resultInfo )
	self.resultInfoList[kSeatMine] = {};
	self.resultInfoList[kSeatRight] = {};
	self.resultInfoList[kSeatTop] = {};
	self.resultInfoList[kSeatLeft] = {};
	for k,v in pairs(self.resultInfoList) do
		v.listItemData = {};
	end
	
	for k,v in pairs(resultInfo.playerList) do
		local player = self.pm:getPlayerById(v.mid); --self.pm:getPlayerBySeat(k - 1) or self.pm:myself();
		local seatId = player.localSeatId;
		local infoTable = self.resultInfoList[seatId];
		self:savePlayerBaseInfo(player);
		infoTable.mid = player.mid;
		self:gfxyNew(seatId, v.gfxyMoney);-- 刮风下雨的金币

		for j,n in pairs(v.huInfo) do -- 胡牌和自摸数据
			GameResultWindowMatch.huNew(self, seatId, n.huType, n.paiTypeStr, n.paiTypeFan, n.extraTypeStr, n.beiHuCount, n, n.winMoney );
		end

		infoTable.turnMoney = v.turnMoney;
		infoTable.totalMoney= v.totalMoney;
		

		if resultInfo.matchScoreTable then
			local matchScoreTable = resultInfo.matchScoreTable;
			if matchScoreTable[""..v.mid] then
				self.resultInfoList[seatId].score = tonumber(matchScoreTable[""..v.mid].chgmark);
				if kSeatMine ==  PlayerManager.getInstance():getLocalSeatIdByMid(v.mid) then
					self.resultContinueTime = tonumber(matchScoreTable.time);
				end
			end
		end

		if kSeatMine == seatId then
			--self:resuleFrame(infoTable.turnMoney);
			self.resultMoney = infoTable.turnMoney;
			if (1 == v.topWin) then
				self.isTopWin = true;
			else
				self.isTopWin = false;
			end
		end
	end
	-- 查花猪和查大叫数据
	self:huaZhuNew(resultInfo.huazhuList);
	self:dajiaoNew(resultInfo.dajiaoList);
end

-- 处理网络数据，用于之后显示详细列表
GameResultWindowMatch.parseDetailInfo = function ( self, resultInfo )
	self.resultInfoList[kSeatMine] = {};
	self.resultInfoList[kSeatRight] = {};
	self.resultInfoList[kSeatTop] = {};
	self.resultInfoList[kSeatLeft] = {};
	for k,v in pairs(self.resultInfoList) do
		v.listItemData = {};
	end
	
	for k,v in pairs(resultInfo.resuleInfoList) do
		local player = self.pm:getPlayerById(v.userId); --self.pm:getPlayerBySeat(k - 1) or self.pm:myself();
		local seatId = player.localSeatId;
		local infoTable = self.resultInfoList[seatId];
		self:savePlayerBaseInfo(player);
		infoTable.mid = player.mid;
		self:gfxy(seatId, v.gfxyMoney);-- 刮风下雨的金币
		if 1 == v.isHu then
			table.insert(self.huCardOrder, seatId);
			if 1 == v.huType then -- 吃炮
			    local loseSeatId = self.pm:getPlayerById(v.fangPaoUserId).localSeatId;
				self:paoHu(seatId, loseSeatId, v.isGangShangPao, v.isQiangGangHu, v.paiType, v.fanNum, v.winMoney, v.siZhangNum, v.gangShangNum);
			else -- 自摸
				self:zimo(seatId, v.paiType, v.fanNum, v.winMoney, v.siZhangNum, v.gangShangNum, v.isGangShangKaiHua);
			end
		end
		if 1 == v.isHuaZhu then
			self:huaZhu(seatId, v.huZhuUid);
		end
		if 1 == v.isDaJiao then
			self:dajiao(seatId, v.dajiaoUid, v.dajiaoFanNum, v.dajiaoMoneyNum);
		end


		infoTable.turnMoney = v.turnMoney;
		infoTable.totalMoney= v.totalMoney;
		if kSeatMine == seatId then
			self.resultMoney = infoTable.turnMoney;
		end
	end
end

-- 保存玩家基本信息，用于显示，防止结算界面时玩家数据被清除
GameResultWindowMatch.savePlayerBaseInfo = function ( self, player )
	local t = {};
	t.mid = player.mid;
	t.nickName = player.nickName;
	t.seatId = player.localSeatId;
	self.playerBaseInfo[player.localSeatId] = t;
end

GameResultWindowMatch.gfxyNew = function ( self, winSeatId, money )
	local t = {};
	t.type = NewResultDetailList.dataTypeGFXY;
	t.winSeatId = winSeatId;
	t.money = money;
	table.insert(self.resultInfoList[winSeatId].listItemData, 1, t);
end

GameResultWindowMatch.huaZhuNew = function ( self, huazhuList ) -- 16倍低注
	for k,v in pairs(huazhuList) do
		local winPlayer = PlayerManager.getInstance():getPlayerById(v.mid);
		local losePlayer = PlayerManager.getInstance():getPlayerById(v.beiChaMid);
		local t = {};
		t.type = NewResultDetailList.dataTypeHUAZHU;
		t.loseSeatId = losePlayer.localSeatId;
		t.money = v.huazhuMoney;
		t.winSeatId = winPlayer.localSeatId;
		table.insert(self.resultInfoList[t.loseSeatId].listItemData, t);
		table.insert(self.resultInfoList[t.winSeatId].listItemData, publ_deepcopy(t));
	end
end

GameResultWindowMatch.dajiaoNew = function ( self, dajiaoList )
	for k,v in pairs(dajiaoList) do
		local winPlayer = PlayerManager.getInstance():getPlayerById(v.mid);
		local losePlayer = PlayerManager.getInstance():getPlayerById(v.beiChaMid);
		local t = {};
		t.type = NewResultDetailList.dataTypeDAJIAO;
		t.loseSeatId = losePlayer.localSeatId;
		t.winSeatId = winPlayer.localSeatId;
		t.fanNum = v.dajiaoFan;
		t.money = v.dajiaoMoney;
		table.insert(self.resultInfoList[t.loseSeatId].listItemData, publ_deepcopy(t));
		table.insert(self.resultInfoList[t.winSeatId].listItemData, t);
	end
end

GameResultWindowMatch.huNew = function (self, seatId, huType, paiTypeStr, paiTypeFan, extraTypeStrs, beiHuCount, info, winMoney )
	local temp = {};
	temp.type = NewResultDetailList.dataTypeHU;
	temp.huNum = 1;
	temp.huType = huType;
	temp.winSeatId = seatId;
	temp.paiTypeStr = paiTypeStr;
	temp.paiTypeFan = paiTypeFan;
	temp.extraTypeStrs = extraTypeStrs;
	temp.loseMoney = 0;
	temp.winMoney = winMoney;
	table.insert(self.resultInfoList[seatId].listItemData, temp); -- 赢钱玩家
	-- self:addHuTable(self.resultInfoList[seatId].listItemData, temp);
	for i=1,beiHuCount do
		local temp2 = publ_deepcopy(temp);
		local player = PlayerManager.getInstance():getPlayerById(info["mid"..i]);
		temp2.loseSeatId = player.localSeatId;
		temp2.loseMoney = info["loseMoney"..i];
		temp2.winMoney = 0;
		table.insert(self.resultInfoList[temp2.loseSeatId].listItemData, temp2);
		-- self:addHuTable(self.resultInfoList[temp2.loseSeatId].listItemData, temp2);
	end
end

GameResultWindowMatch.resuleFrame = function ( self, money )
	money = tonumber(money);
	self.resultMoney = money;
    local w_title = publ_getItemFromTree(self.resultView, { "title"});
	if money == 0 then
        if w_title then
            publ_getItemFromTree(w_title, {  "titleStr"}):setFile(roomResultDetailPin_map["title_nor.png"]);
		    publ_getItemFromTree(w_title, {  "firework_1"}):setVisible(false);
		    publ_getItemFromTree(w_title, {  "firework_2"}):setVisible(false);
        end
		
	
	elseif money < 0 then
		publ_getItemFromTree(self.resultView, { "bg" }):setFile(roomResultDetailPin_map["lost_bg.png"]);
        if w_title then
            w_title:setFile(roomResultDetailPin_map["br_title_bg.png"]);
            publ_getItemFromTree(w_title, {  "titleStr"}):setFile(roomResultDetailPin_map["title_lost.png"]);
		    publ_getItemFromTree(w_title, { "firework_1"}):setVisible(false);
		    publ_getItemFromTree(w_title, {  "firework_2"}):setVisible(false);
		    publ_getItemFromTree(w_title, {  "wind"}):setVisible(true);
        end
		
		publ_getItemFromTree(self.resultView, { "bg", "listBg"}):setFile(roomResultDetailPin_map["lost_bg3.png"]);

		publ_getItemFromTree(self.resultView, { "bg", "listBg", "money_bg"}):setFile(roomResultDetailPin_map["lost_score_bg.png"]);
		publ_getItemFromTree(self.resultView, { "bg", "listBg", "money_bg", "splite_line_1"}):setFile(roomResultDetailPin_map["lost_score_bg.png"]);
		publ_getItemFromTree(self.resultView, { "bg", "listBg", "money_bg", "splite_line_2"}):setFile(roomResultDetailPin_map["lost_score_bg.png"]);
		publ_getItemFromTree(self.resultView, { "bg", "listBg", "money_bg", "splite_line_3"}):setFile(roomResultDetailPin_map["lost_score_bg.png"]);



	else
		self.winGame = true;
	end
end


-- 显示顶部基本信息
GameResultWindowMatch.showHeadInfo = function ( self )
	for k,v in pairs(self.resultInfoList) do
		local seatid = k;
		local info = v;

		local player = self.playerBaseInfo[k];
		local name, money = self:getItemBySeatid(seatid);

		local nameStr = nil;
		if not player then  --有可能部分玩家数据被清除了
			nameStr = "";
		else
			nameStr = stringFormatWithString(player.nickName,8) or "";
		end
	
		name:setText(nameStr);
		local mstr = tonumber(info.turnMoney);
		if mstr >= 0 then
			mstr = "+"..mstr;
			money:setColor(255,255,255);
		else
			money:setColor(255,255,255);
		end
		
		money:setText(mstr);
	end
end

GameResultWindowMatch.getItemBySeatid = function ( self, seatID )
	if kSeatMine == seatID then
		return self.myNameText, self.myMoneyText;
	elseif kSeatRight == seatID then
		return self.nameText1, self.moneyText1;
	elseif kSeatTop == seatID then
		return self.nameText2, self.moneyText2;
	else
		return self.nameText3, self.moneyText3;
	end
end

GameResultWindowMatch.initTagBtnAction = function ( self )
	self.tagBtn1:setOnClick(self, function ( self )
		self:showDetailBySeatid(kSeatMine);
	end);
	self.tagBtn2:setOnClick(self, function ( self )
		self:showDetailBySeatid(kSeatRight);
	end);
	self.tagBtn3:setOnClick(self, function ( self )
		self:showDetailBySeatid(kSeatTop);
	end);
	self.tagBtn4:setOnClick(self, function ( self )
		self:showDetailBySeatid(kSeatLeft);
	end);
end

-- 显示番数明细
GameResultWindowMatch.showDetailBySeatid = function ( self, seatID )
	if seatID == self.curShowDetailSeat then
		return;
	end
	local view = self.listView[seatID];
	if not view then
		local listData = self.resultInfoList[seatID].listItemData;
		for k,v in pairs(listData) do
			v.w = 766;
			v.h = 40;
			v.mySeat = seatID;
			v.playerBaseInfo = self.playerBaseInfo;
		end
		local adapter = nil;
		if self.isNewCmd then
			adapter = new(CacheAdapter, NewResultDetailList, listData);
		else
			adapter = new(CacheAdapter, ResultDetailList, listData);
		end
		view = new(MahjongListView, 20, 100, 830, 200);
		self.listView[seatID] = view;
		view:setAlign(kAlignTopLeft);
		view:setAdapter(adapter);
		view:setScrollBarWidth(2);
		view:setMaxClickOffset(5);
	end
	if view then -- create view success

		self:changeTagStatu(self.curShowDetailSeat, seatID); -- change tag statu
		if self.curShowDetailSeat then
			self.contentBg:removeChild(self.listView[self.curShowDetailSeat]); -- remove last view
			self.listView[self.curShowDetailSeat]:setVisible(false);
		end
		self.curShowDetailSeat = seatID;
		self.contentBg:addChild(view); -- show it
		view:setVisible(true);
		self.listView[seatID] = view;
	end
end



GameResultWindowMatch.changeTagStatu = function ( self, lastSeatID, nowSeatID )

	local file1 = "";
	local file2 = "";

	if self.resultMoney  < 0 then

		file1 = roomResultDetailPin_map["lost_tab_bg_1.png"];
		file2 = roomResultDetailPin_map["win_tab_bg_2.png"];
	else
		file1 = roomResultDetailPin_map["win_tab_bg_1.png"];
		file2 = roomResultDetailPin_map["win_tab_bg_2.png"];

	end


	if not lastSeatID then
		-- 初始化时候lastSeatID为空
		self:getTagBtnBySeatID(0):setFile(file1);
		self:getTagBtnBySeatID(1):setFile(file1);
		self:getTagBtnBySeatID(2):setFile(file1);
		self:getTagBtnBySeatID(3):setFile(file1);
	else
		self:getTagBtnBySeatID(lastSeatID):setFile(file1);
	end
	self:getTagBtnBySeatID(nowSeatID):setFile(file2);

end

GameResultWindowMatch.getTagBtnBySeatID = function ( self, seatID )
	if kSeatMine == seatID then
		return  self.tagBtn1;
	elseif kSeatRight == seatID then
		return self.tagBtn2;
	elseif kSeatTop == seatID then
		return self.tagBtn3;
	else
		return self.tagBtn4;
	end
end



GameResultWindowMatch.show = function ( self )
	CustomNode.show(self);
	self:showWindow1();
end

-- GameResultWindowMatch.resuleFrame = function ( self, money )
-- 	self.resultMoney = tonumber(money);
-- end

GameResultWindowMatch.getResultMoney = function ( self )
	return self.resultMoney;
end

GameResultWindowMatch.dtor = function ( self )
    DebugLog("GameResultWindowMatch dtor");
	self:removeAllChildren();
end

