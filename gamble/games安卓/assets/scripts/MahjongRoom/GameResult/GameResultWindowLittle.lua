require("MahjongRoom/GameResult/ResultDetailList");
require("MahjongRoom/GameResult/NewResultDetailList");
require("MahjongCommon/MahjongListView");
local resultLayoutLittle = require(ViewLuaPath.."resultLayoutLittle");
local roomResultDetailPin_map = require("qnPlist/roomResultDetailPin")


-- 提前胡详情界面
GameResultWindowLittle = class(SCWindow);

GameResultWindowLittle.ctor = function ( self, data)
	self.pm = PlayerManager.getInstance();
	self.resultInfoList = {};
	self.playerBaseInfo = {};
	self.resultViewLittle = SceneLoader.load(resultLayoutLittle);
	self:addChild(self.resultViewLittle);

	self:setCoverTransparent()

	self.bg = publ_getItemFromTree(self.resultViewLittle, {"bg"});
	self:setWindowNode( self.bg );

	self.myMoneyText = publ_getItemFromTree(self.resultViewLittle,{"bg", "listBg", "money_bg", "Text2"});
	self.contentBg = publ_getItemFromTree(self.resultViewLittle, {"bg", "listBg"});


	self.changeTableBtn = publ_getItemFromTree(self.resultViewLittle, { "bg","changeTable"});
	self.changeTableBtn:setOnClick(self, function ( self )
		-- 客户端判断到金币不足，显示金币购买弹窗
		if not GameConstant.curGameSceneRef:judgeMoneyAndShowChargeWnd() then
			return;
		end
		-- 请求换桌
		local param = {};
		param.mid = PlayerManager.getInstance():myself().mid;
		SocketManager.getInstance():sendPack(CLIENT_COMMAND_REQ_LOGOUT, param);
		self:hideWnd();
	end);

	self.changeTableBtnText = publ_getItemFromTree(self.resultViewLittle, {"bg", "changeTable" , "Text1"})

	if  GameConstant.go_to_high  then
		self.changeTableBtnText:setText("去高倍场")
	else 
		self.changeTableBtnText:setText("再来一局")
	end 

	if FriendMatchRoomScene_instance then 
		self.changeTableBtnText:setText("关  闭")
		self.changeTableBtn:setOnClick(self,function ( self )
			self:hideWnd()
		end)
	end 
	self.continueBtn = publ_getItemFromTree(self.resultViewLittle, { "bg","continue"});
	self.continueBtn:setOnClick(self, function ( self )
		self:hideWnd();
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

		-- 提前胡请求换桌
		local param = {};
		param.mid = PlayerManager.getInstance():myself().mid;
		SocketManager.getInstance():sendPack(CLIENT_COMMAND_REQ_LOGOUT, param);
		if 8 == GameConstant.matchStatus.matchStage then
			MatchRoomScene_instance:showWaitStartOrRankView("正在为您配桌");
		elseif 9 == GameConstant.matchStatus.matchStage then
			local str = "预赛已结束，" .. string.sub(os.date("%X", GameConstant.matchStatus.taoTaiStartTime), 0, 5) .. "系统将排名并确定晋级名单";
			MatchRoomScene_instance:showWaitStartOrRankView(str);
		end
	end);


	self.closeBtn = publ_getItemFromTree(self.resultViewLittle, { "bg", "close"});
	self.closeBtn:setOnClick(self, function ( self )
		self:hideWnd();
	end);

	if PlatformConfig.platformWDJ == GameConstant.platformType or
	   PlatformConfig.platformWDJNet == GameConstant.platformType then 
        self.closeBtn:setFile("Login/wdj/Hall/Commonx/close_btn.png");
        self.closeBtn.disableFile = "Login/wdj/Hall/Commonx/close_btn_disable.png";
    end

	if MatchRoomScene_instance then
		self.continueBtn:setVisible(true);
		self.changeTableBtn:setVisible(false);
	end


	self:parseDetailInfo(data);
	self:showHeadInfo();
	self:showDetailBySeatid(kSeatMine);
	self:showWnd();
end



GameResultWindowLittle.parseDetailInfo = function ( self, resultInfo )
	self.resultInfoList[kSeatMine] = {};
	for k,v in pairs(self.resultInfoList) do
		v.listItemData = {};
	end

	local isBankruptSubsidize = RoomData.getInstance().isBankruptSubsidize;

	for k,v in pairs(resultInfo.playerInfo) do
		local player = self.pm:getPlayerById(v.mid);
		self:savePlayerBaseInfo(player);
		local seatId = player.localSeatId;
		local infoTable = self.resultInfoList[seatId];
		infoTable.mid = player.mid;
		infoTable.turnMoney = v.huMoney;

		self:gfxyNew(seatId, v.gfxyMoney);-- 刮风下雨的金币	

		local temp = {};
		for i=1, #v.huInfo do
			temp.type = NewResultDetailList.dataTypeHU;
			temp.huNum = 1;
			temp.huType = v.huInfo[i].huType;
			temp.winSeatId = seatId;
			temp.paiTypeStr = v.huInfo[i].paiTypeStr;
			temp.paiTypeFan = v.huInfo[i].paiType;
			temp.extraTypeStrs = v.huInfo[i].extraFanStr;
			temp.loseMoney = 0;
			temp.winMoney = v.huInfo[i].huWinMoney;
			table.insert(self.resultInfoList[seatId].listItemData, temp); -- 赢钱玩家	
		end

		local temp = {};
		for i=1, #v.beiHuInfo do
			local player =  self.pm:getPlayerBySeat(v.beiHuInfo[i].seatId);
			self:savePlayerBaseInfo(player);
			temp.type = NewResultDetailList.dataTypeHU;
			temp.huNum = 1;
			temp.huType = v.beiHuInfo[i].huType;
			temp.winSeatId = v.beiHuInfo[i].seatId;
			temp.paiTypeStr = v.beiHuInfo[i].paiTypeStr;
			temp.paiTypeFan = v.beiHuInfo[i].paiType;
			temp.extraTypeStrs = v.beiHuInfo[i].extraFanStr;
			temp.loseMoney = v.beiHuInfo[i].lostMoney;
			temp.winMoney = 0;
			temp.loseSeatId = 0;			
			table.insert(self.resultInfoList[seatId].listItemData, temp);
		end
		if kSeatMine == seatId then
			self:resuleFrame(infoTable.turnMoney);
		end
	end
end

GameResultWindowLittle.gfxyNew = function ( self, winSeatId, money )
	local t = {};
	t.type = NewResultDetailList.dataTypeGFXY;
	t.winSeatId = winSeatId;
	t.money = money;
	table.insert(self.resultInfoList[winSeatId].listItemData, 1, t);
end


-- 保存玩家基本信息，用于显示，防止结算界面时玩家数据被清除
GameResultWindowLittle.savePlayerBaseInfo = function ( self, player )
	local t = {};
	t.mid = player.mid;
	t.nickName = player.nickName;
	t.seatId = player.localSeatId;
	self.playerBaseInfo[player.localSeatId] = t;
end

-- 显示顶部基本信息
GameResultWindowLittle.showHeadInfo = function ( self )
	local player = self.pm:getPlayerById(self.resultInfoList[kSeatMine].mid);
	local mstr = tonumber(self.resultInfoList[kSeatMine].turnMoney);
	if mstr >= 0 then
		mstr = "+"..mstr;
		--self.myMoneyText:setColor( 0xcc, 0x44, 0x00);
		self.myMoneyText:setText(mstr,0,0, 0xcc , 0x44, 0x00);
	else
		--self.myMoneyText:setColor( 0x4b, 0x2b, 0x1c);
		self.myMoneyText:setText(mstr,0,0, 0x4b , 0x2b, 0x1c);
	end
	--self.myMoneyText:setText(mstr);

end

-- 显示番数明细
GameResultWindowLittle.showDetailBySeatid = function ( self, seatID )
	DebugLog( "GameResultWindowLittle.showDetailBySeatid" );
	local listData = self.resultInfoList[seatID].listItemData;
	mahjongPrint( self.resultInfoList );
	mahjongPrint( listData );
	for k,v in pairs(listData) do
		v.w = 830;
		v.h = 40;
		v.mySeat = seatID;
		v.playerBaseInfo = self.playerBaseInfo;
	end
	local adapter = nil;
	adapter = new(CacheAdapter, NewResultDetailList, listData);
	view = new(MahjongListView, 20, 100, 830, 200);
	self.contentBg:addChild(view);
	view:setAlign(kAlignTopLeft);
	view:setAdapter(adapter);
	view:setScrollBarWidth(2);
	view:setMaxClickOffset(5);
end


GameResultWindowLittle.resuleFrame = function ( self, money )
	money = tonumber(money);
	if money == 0 then
		publ_getItemFromTree(self.resultViewLittle, { "bg","title", "titleStr"}):setFile(roomResultDetailPin_map["title_nor.png"]);
		publ_getItemFromTree(self.resultViewLittle, { "bg","title", "firework_1"}):setVisible(false);
		publ_getItemFromTree(self.resultViewLittle, { "bg","title", "firework_2"}):setVisible(false);
	elseif money < 0 then
		publ_getItemFromTree(self.resultViewLittle, { "bg" }):setFile(roomResultDetailPin_map["lost_bg.png"]);
		publ_getItemFromTree(self.resultViewLittle, { "bg", "title"}):setFile(roomResultDetailPin_map["br_title_bg.png"]);
		publ_getItemFromTree(self.resultViewLittle, { "bg", "listBg"}):setFile(roomResultDetailPin_map["lost_bg3.png"]);

		publ_getItemFromTree(self.resultViewLittle, { "bg", "listBg", "money_bg"}):setFile(roomResultDetailPin_map["lost_score_bg.png"]);

		publ_getItemFromTree(self.resultViewLittle, { "bg","title", "titleStr"}):setFile(roomResultDetailPin_map["title_lost.png"]);
		publ_getItemFromTree(self.resultViewLittle, { "bg","title", "firework_1"}):setVisible(false);
		publ_getItemFromTree(self.resultViewLittle, { "bg","title", "firework_2"}):setVisible(false);
		publ_getItemFromTree(self.resultViewLittle, { "bg","title", "wind"}):setVisible(true);
	end
end


-- GameResultWindowLittle.show = function ( self )
-- 	popWindowDown(self, nil, self.bg);
-- end

GameResultWindowLittle.dtor = function ( self )
	-- self:removeAllChildren(true);
end