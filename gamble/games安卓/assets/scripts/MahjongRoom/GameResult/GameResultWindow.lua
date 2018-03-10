require("MahjongRoom/GameResult/ResultDetailList");
require("MahjongRoom/GameResult/NewResultDetailList");
require("MahjongCommon/MahjongListView");
require("Animation/GameResultNumberAnim")
local gameResult = require(ViewLuaPath.."gameResult");
require("Animation/PlayCardsAnim/animationDraw");
require("Animation/PlayCardsAnim/animationLost");
require("Animation/PlayCardsAnim/animationWin");
require("Animation/PlayCardsAnim/animationTopScore");
--require("MahjongRoom/fetionSharePop");
local roomResultDetailPin_map = require("qnPlist/roomResultDetailPin")


-- 游戏结算界面
GameResultWindow = class(CustomNode);


GameResultWindow.bankraptcyCoord = 
{
	[kSeatMine] = {0, 0},
	[kSeatRight]= {0, 0},
	[kSeatTop] 	= {0, 0},
	[kSeatLeft] = {0, 0}
}

GameResultWindow.ctor = function ( self , delegate)
    self.delegate = delegate;
	self.curShowDetailSeat = nil; -- 默认显示自己
	self.pm = PlayerManager.getInstance(); -- 注意：这个PlayerManager的部分玩家数据有可能被清除了
	self.resultInfoList = {};
	self.listView = {};
    self.confirmName = nil;   --提交的名字  “联网”
	
	self.huCardOrder = {}; -- 胡牌顺序
	self.playerBaseInfo = {};
	self.level  = level;	
	self.isChangePos = false;  --在来一局的位置是否需要重新设置
	self.isVisibileConifBtn = true; -- 是否显示详细
	self:setCoverTransparent()
	self.resultMoney = 0;
end

GameResultWindow.setBtnAgainText = function ( self, str )
	self.btnAgainTextStr = str
end
GameResultWindow.showWindow1 = function ( self )
	self.window = SceneLoader.load(gameResult);
	self:addChild(self.window);

	--禁止窗外关闭
	self.window:setEventTouch(self, function ( self )

	end);

	--设置关闭事件
	self.btnClose = publ_getItemFromTree(self.window,{"btn_close"});
	self.btnClose:setOnClick(self, function ( self )
		if self.m_parent then -- 移除自己
			if self.closeFunc then
				self.closeFunc(self.closeObj);
			end
		end
	end);

	--再来一局
	self.btnAgain = publ_getItemFromTree(self.window,{"view_main","btn_again"});

	self.btnAgain:setOnClick(self, function ( self )
		if self.againEvent then
			self.againEvent(self.againObj,true);
		end
	end);
	self.btnAgainText = publ_getItemFromTree(self.window,{"view_main","btn_again","Text1"});
	self.btnAgainText:setText("再来一局")
	
	--详情
	self.btnDetail = publ_getItemFromTree(self.window,{"view_main","btn_detail"});
	self.btnDetail:setOnClick(self, function ( self )
		self:createDetailFrom(); --加载详细信息界面
        publ_getItemFromTree(self.confirmBtn, {"name"}):setText(self.confirmName or "");
        for k,v in pairs(self.resultInfoList) do
            if kSeatMine == k then
				if RoomData.getInstance().isBankruptSubsidize then
					self:resuleFrame(v.tempTurnMoney);
				else
					self:resuleFrame(v.turnMoney);
				end
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
			local bankraptcyImg = UICreator.createImg(roomResultDetailPin_map["bankraptcy_tip.png"],GameResultWindow.bankraptcyCoord[i][1],GameResultWindow.bankraptcyCoord[i][2]);
			-- local bankraptcyImg = UICreator.createImg("Room/result/bankraptcy_tip.png",GameResultWindow.bankraptcyCoord[i][1],GameResultWindow.bankraptcyCoord[i][2]);
			self.window:addChild(bankraptcyImg);
			if GameConstant.isSingleGame and i ~= 0 then
				PlayerManager.getInstance():getPlayerById(i+1).money = 10000;
			end
		end
	end

	--动画
	local coord = {};
	for i = 0, 3 do
		coord[i] = {};
	end

	--主玩家
	local viewW, _  	= self:getSize();
	local _, 	 btnY 	= publ_getItemFromTree(self.window,{"view_main","btn_again"}):getAbsolutePos();

	local money = self.resultInfoList[0].turnMoney;
	if RoomData.getInstance().isBankruptSubsidize then
		money = self.resultInfoList[0].tempTurnMoney;
	end
	local moneyWidth = 51 * (money > 0 and string.len("+".. money) or string.len("" .. money) );

	coord[kSeatMine][1], coord[kSeatMine][2] = (viewW - moneyWidth) / 2 , btnY - 61;

	local numberAnim = new (GameResultNumberAnim, money, money > 0);
	numberAnim:setPos( coord[kSeatMine][1], coord[kSeatMine][2]);
	self.window:addChild(numberAnim);
	numberAnim:show();


	--右玩家
	local money = self.resultInfoList[1].turnMoney;
	if RoomData.getInstance().isBankruptSubsidize then
		money = self.resultInfoList[1].tempTurnMoney;
	end
	local x, y = RoomCoor.showMoneyCoor[1][1], RoomCoor.showMoneyCoor[1][2];
	x = x - 51 * (money > 0 and string.len("+".. money) or string.len("" .. money) ); -- 右对齐

	coord[1][1], coord[1][2] = x, y;

	--上完家
	coord[2][1], coord[2][2] = RoomCoor.showMoneyCoor[2][1], RoomCoor.showMoneyCoor[2][2];
	--左玩家
	local money = self.resultInfoList[2].turnMoney;
	if RoomData.getInstance().isBankruptSubsidize then
		money = self.resultInfoList[2].tempTurnMoney;
	end
	coord[3][1], coord[3][2] = RoomCoor.showMoneyCoor[3][1], RoomCoor.showMoneyCoor[3][2];

	local isBankruptSubsidize = RoomData.getInstance().isBankruptSubsidize;
	for i = 1, 3 do
		local showMoney = tonumber(self.resultInfoList[i].turnMoney);
		if isBankruptSubsidize then
			showMoney = tonumber(self.resultInfoList[i].tempTurnMoney);
		end
		anim = new(ChangeMoneyAnim, showMoney, coord[i][1], coord[i][2],nil,false);
		self.window:addChild(anim);
		anim:show();
	end

	self.centerNode = new(Node);
	self.window:addChild(self.centerNode);
	self.centerNode:setSize(500, 400);
	self.centerNode:setAlign(kAlignCenter);
	self.centerNode:addPropScaleSolid(0,0.7,0.7,kCenterDrawing)
	local p = {{0,-250}, {0,-250}, {0,-250},{360,-40}};
	--{{0,-80}, {0,-130}, {0,-120},{360,-40}};b

	-- 分享按钮
	self.btnShare = publ_getItemFromTree( self.window, { "view_share","btn_share" } );
	self.imgShareShine = publ_getItemFromTree( self.window, { "view_share","img_share_shine" } ); --闪光图片
	self.btnShare:setVisible( false );
	self.imgShareShine:setVisible( false );

 
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
		
		if not MatchRoomScene_instance and 
			not GameConstant.isSingleGame and 
			PlatformFactory.curPlatform:needToShareWindow() and GameConstant.issupportshare then

			self.btnShare:setOnClick( self, function ( self )
				-- 发起截图请求
				self:screenShot( true );
			end);

			self.btnShare:setVisible( true );-- 获胜后显示分享
		end
		self.centerWinAnim = new(AnimationWin, p[3], self.centerNode);
		self.centerNode:addChild(self.centerWinAnim);
		self.centerWinAnim:play();
		-- self.i = 0;
		-- self.screenShock = new(AnimInt, kAnimRepeat, 0, 1, 500, 0);
		-- self.screenShock:setDebugName("GameResultWindow|self.screenShock");
		-- self.screenShock:setEvent(self, function ( self )
		-- 	if self.i < 2 then
		-- 		native_to_java(kScreenShock); -- 振动
		-- 		self.i = self.i + 1;
		-- 	else
		-- 		delete(self.screenShock);
		-- 		self.screenShock = nil;
		-- 	end
		-- end);

		-- fetion share
		if RoomData.getInstance().inFetionRoom then
			-- self.shareBtn = new(Button, "Room/result/share.png");
			self.shareBtn = new(Button, "fetion/share.png");
			self.centerNode:addChild(self.shareBtn);
			self.shareBtn:setPos(390, 110);
			self.shareBtn:setVisible(true);
			self.shareBtn:setOnClick(self, function(self)
				if not self.fetionSharePop then
					self.fetionSharePop = new(FetionSharePop);
					self.window:addChild(self.fetionSharePop);
					self.fetionSharePop:show();
				end
			end);
		end
	end

-- self.isTopWin = true; -- debug
	if self.isTopWin then -- 显示历史新高动画
		self.centerTopScoreAnim = new(AnimationTopScore, p[4], self.centerNode);
		self.centerTopScoreAnim:play();

		if not MatchRoomScene_instance and not GameConstant.isSingleGame and PlatformFactory.curPlatform:needToShareWindow() and GameConstant.issupportshare then
			-- 历史最高时显示闪光
			if self.imgShareShine then
				self.btnShare:setVisible( true );-- 获胜后显示分享
				self.imgShareShine:setVisible( true );
				self.imgShareShine:addPropRotate(2, kAnimRepeat, 5000, 0, 0, 360, kCenterDrawing);
			end
		end
	end

end

--创建详细信息模块
GameResultWindow.createDetailFrom = function ( self)
	local resultLayout = require(ViewLuaPath.."resultLayout");
	self.resultView = SceneLoader.load(resultLayout);
	self:addChild(self.resultView);

	self.tagBtn1 = publ_getItemFromTree(self.resultView, { "tagBtn1"});
	self.tagBtn2 = publ_getItemFromTree(self.resultView, { "tagBtn2"});
	self.tagBtn3 = publ_getItemFromTree(self.resultView, { "tagBtn3"});
	self.tagBtn4 = publ_getItemFromTree(self.resultView, { "tagBtn4"});

	self.tagBtn1:setType(Button.White_Type)
	self.tagBtn2:setType(Button.White_Type)
	self.tagBtn3:setType(Button.White_Type)
	self.tagBtn4:setType(Button.White_Type)

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
	self.confirmBtn = publ_getItemFromTree(self.resultView, {"bg", "confirmBtn"});
	self.confirmBtn:setVisible(self.isVisibileConifBtn);


	self.againBtn = publ_getItemFromTree(self.resultView, { "bg","again"});
	if not self.isVisibileConifBtn then --如果confirmBtn为false的地方说明目前再来一局需要再中间位置
		self.againBtn:setPos(0,40);
	end

	self.againBtn:setOnClick(self, function ( self )
		if self.againEvent then
			self.againEvent(self.againObj);
		end
	end);
	self.againBtnText1 = publ_getItemFromTree(self.resultView, { "bg","again","Text1"});
	self.againBtnText1:setText( self.btnAgainTextStr or "再来一局")
	
	self.closeBtn = publ_getItemFromTree(self.resultView, { "bg", "close"});

	self.closeBtn:setOnClick(self, function ( self )
		if self.m_parent then -- 移除自己
			if self.closeFunc then
				self.closeFunc(self.closeObj);
			end
		end
	end);

	if PlatformConfig.platformWDJ == GameConstant.platformType or
	   PlatformConfig.platformWDJNet == GameConstant.platformType then 
        self.closeBtn:setFile("Login/wdj/Hall/Commonx/close_btn.png");
        self.closeBtn.disableFile = "Login/wdj/Hall/Commonx/close_btn_disable.png";
    end

	self.confirmBtn:setOnClick(self, function ( self )
			if self.confirmEvent then
				self.confirmEvent(self.confirmObj);
			end
	end);

	self:initTagBtnAction();


	self.resultView:setVisible(false);
end


-- 截图触发函数，控制启动截图和截图完成显示控件
-- isStart 该参数指示了是开始截图还是结束/取消截图
GameResultWindow.screenShot = function( self, isStart )
	if isStart then
		-- 隐藏按钮
		self.btnClose:setVisible( false );
		self.btnAgain:setVisible( false );
		self.btnDetail:setVisible( false );
		self.btnShare:setVisible( false );
		self.isShareShaineVisible = self.imgShareShine:getVisible();
		if self.isShareShaineVisible then
			self.imgShareShine:setVisible( false );
		end

--		local data = self:createShareMsg();
--		native_to_java( kScreenShot , json.encode( data ) );-- 向java发起截图请求
        self:showShareWindow();

	else
		-- 显示按钮
		self.btnClose:setVisible( true );
		self.btnAgain:setVisible( true );
		self.btnDetail:setVisible( true );
		self.btnShare:setVisible( true );
		if self.isShareShaineVisible then
			self.imgShareShine:setVisible( true );
		end
	end
end

GameResultWindow.createShareMsg = function( self )
	math.randomseed( tonumber(tostring(os.time()):reverse():sub(0,#kShareTextContent)) ) 
	local rand = math.random();
	local index = math.modf( rand*1000%6 );
	local player = PlayerManager.getInstance():myself();

	local data = {};
	data.title = PlatformFactory.curPlatform:getApplicationShareName();
	data.content = kShareTextContent[ index or 1 ];
	data.username = player.nickName or "川麻小王子";
	data.url = GameConstant.shareMessage.url or ""
	DebugLog( index );
	DebugLog( data.title );
	DebugLog( data.content );
	DebugLog( data.username );

	return data;
end

GameResultWindow.showShareWindow = function (self)
    if self.delegate and self.delegate.shareData  then
        local dd = self:createShareMsg();
        local shareData = {d = self.delegate.shareData, share = dd , t = GameConstant.shareConfig.game, b = true};
        global_screen_shot(shareData);
    end
end

--根本没有使用
GameResultWindow.showDetailWindow = function ( self )
	self.detailWindow = SceneLoader.load(gameResultDetail);
	self:addChild(self.detailWindow);
end

GameResultWindow.setAgainCallback = function ( self, obj, fun )
	self.againEvent = fun;
	self.againObj = obj;
end

GameResultWindow.setConfirmCallback = function ( self, name, obj, fun )
	self.confirmEvent = fun;
	self.confirmObj   = obj;
    self.confirmName = name;
	--publ_getItemFromTree(self.confirmBtn, {"name"}):setText(name or "");
end

GameResultWindow.setCallbackClose = function ( self, obj, func )
	self.closeObj = obj;
	self.closeFunc = func;
end

GameResultWindow.setAgainCenter  = function ( self, isChangePos )
	self.isChangePos = true;
end
GameResultWindow.setComfirmVisible  = function ( self, visible )
	self.isVisibileConifBtn  = visible;
	
end


GameResultWindow.initTagBtnAction = function ( self )
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

--解析网络数据，并显示出来，默认显示自己的结果
GameResultWindow.parseDataAndShowInitinfo = function ( self, resultInfo, isNewCmd )
	self.isNewCmd = isNewCmd or false;
	if isNewCmd then
		self:parseDetailInfo2(resultInfo); -- 新结算
	else
		self:parseDetailInfo(resultInfo); -- 老结算
	end
end

-- ###################### DEP ############################## --
-- 解析血流成河结算数据
GameResultWindow.parseXLCHDataAndShowInitinfo = function ( self, resultInfo )
	self:parseDetailInfoXLCH(resultInfo);
	self:showHeadInfo();
	self:showDetailBySeatid(kSeatMine);
end

-- ###################### DEP ############################## --
GameResultWindow.parseDetailInfoXLCH = function ( self, resultInfo )
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

		for i,j in pairs(v.huinfoList) do
			if 1 == j.huType then -- hu
				local loseSeatId = self.pm:getPlayerById(j.fangpaoID).localSeatId;
				self:paoHuXLCH(seatId, loseSeatId, j.pai_Type, j.fanNum, j.huMoney, j.gangNum, j.genNum);
			else -- zimo
				self:zimoXLCH(seatId, j.pai_Type, j.fanNum, j.huMoney, j.gangNum, j.genNum);
			end
		end
		infoTable.turnMoney = v.turnMoney;
		infoTable.totalMoney= v.totalMoney;
		
		if kSeatMine == seatId then
			--self:createTotalMoneyTextImg(infoTable.turnMoney, seatId);


			self.resultMoney = infoTable.turnMoney;
			self:resuleFrame(infoTable.turnMoney);
		end
	end
end

-- 处理网络数据，用于之后显示详细列表
GameResultWindow.parseDetailInfo2 = function ( self, resultInfo )
	self.resultInfoList[kSeatMine] = {};
	self.resultInfoList[kSeatRight] = {};
	self.resultInfoList[kSeatTop] = {};
	self.resultInfoList[kSeatLeft] = {};
	for k,v in pairs(self.resultInfoList) do
		v.listItemData = {};
	end

	-- 该场次是否有系统补助
	local isBankruptSubsidize = RoomData.getInstance().isBankruptSubsidize;

	for k,v in pairs(resultInfo.playerList) do
		local player = self.pm:getPlayerById(v.mid); --self.pm:getPlayerBySeat(k - 1) or self.pm:myself();
		local seatId = player.localSeatId;
		local infoTable = self.resultInfoList[seatId];
		self:savePlayerBaseInfo(player);
		infoTable.mid = player.mid;

		if isBankruptSubsidize then
			self:gfxyNew(seatId, v.tempGfxyMoney);-- 刮风下雨的金币
		else
			self:gfxyNew(seatId, v.gfxyMoney);-- 刮风下雨的金币
		end

		for j,n in pairs(v.huInfo) do -- 胡牌和自摸数据
			local winMoney = n.winMoney;
			if isBankruptSubsidize then
				winMoney = n.tempWinMoney;
			end
			GameResultWindow.huNew(self, seatId, n.huType, n.paiTypeStr, n.paiTypeFan, n.extraTypeStr, n.beiHuCount, n, winMoney );
		end

		infoTable.tempTurnMoney = v.tempTurnMoney;
		infoTable.turnMoney = v.turnMoney;
		infoTable.totalMoney= v.totalMoney;
		
		if kSeatMine == seatId then
			--self:resuleFrame(infoTable.turnMoney);
			if RoomData.getInstance().isBankruptSubsidize then
				self.resultMoney = infoTable.tempTurnMoney;
			else
				self.resultMoney = infoTable.turnMoney;
			end			
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

GameResultWindow.gfxyNew = function ( self, winSeatId, money )
	local t = {};
	t.type = NewResultDetailList.dataTypeGFXY;
	t.winSeatId = winSeatId;
	t.money = money;
	table.insert(self.resultInfoList[winSeatId].listItemData, 1, t);
end

GameResultWindow.huaZhuNew = function ( self, huazhuList ) -- 16倍低注
	local isBankruptSubsidize = RoomData.getInstance().isBankruptSubsidize;
	for k,v in pairs(huazhuList) do
		local winPlayer = PlayerManager.getInstance():getPlayerById(v.mid);
		local losePlayer = PlayerManager.getInstance():getPlayerById(v.beiChaMid);
		local t = {};
		t.type = NewResultDetailList.dataTypeHUAZHU;
		t.loseSeatId = losePlayer.localSeatId;
		if isBankruptSubsidize then
			t.money = v.tempHuazhuMoney;
		else
			t.money = v.huazhuMoney;
		end
		t.winSeatId = winPlayer.localSeatId;
		table.insert(self.resultInfoList[t.loseSeatId].listItemData, t);
		table.insert(self.resultInfoList[t.winSeatId].listItemData, publ_deepcopy(t));
	end
end

GameResultWindow.dajiaoNew = function ( self, dajiaoList )
	local isBankruptSubsidize = RoomData.getInstance().isBankruptSubsidize;
	for k,v in pairs(dajiaoList) do
		local winPlayer = PlayerManager.getInstance():getPlayerById(v.mid);
		local losePlayer = PlayerManager.getInstance():getPlayerById(v.beiChaMid);
		local t = {};
		t.type = NewResultDetailList.dataTypeDAJIAO;
		t.loseSeatId = losePlayer.localSeatId;
		t.winSeatId = winPlayer.localSeatId;
		t.fanNum = v.dajiaoFan;
		if isBankruptSubsidize then
			t.money = v.tempDajiaoMoney;
		else
			t.money = v.dajiaoMoney;
		end		
		table.insert(self.resultInfoList[t.loseSeatId].listItemData, publ_deepcopy(t));
		table.insert(self.resultInfoList[t.winSeatId].listItemData, t);
	end
end

GameResultWindow.huNew = function (self, seatId, huType, paiTypeStr, paiTypeFan, extraTypeStrs, beiHuCount, info, winMoney )
	local isBankruptSubsidize = RoomData.getInstance().isBankruptSubsidize;
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
		if isBankruptSubsidize then
			temp2.loseMoney = info["tempLoseMoney"..i];
		else
			temp2.loseMoney = info["loseMoney"..i];
		end
		
		temp2.winMoney = 0;
		table.insert(self.resultInfoList[temp2.loseSeatId].listItemData, temp2);
		-- self:addHuTable(self.resultInfoList[temp2.loseSeatId].listItemData, temp2);
	end
end

-- GameResultWindow.addHuTable = function ( self, list, item )
-- 	for k,v in pairs(list) do
-- 		if self:newIsTheSame(v, item) then
-- 			v.huNum = v.huNum + 1;
-- 			return;
-- 		end
-- 	end
-- 	table.insert(list, item);
-- end

-- GameResultWindow.newIsTheSame = function ( self, item1, item2 )
-- 	if temp.type temp.huType temp.winSeatId then
-- 		return true;
-- 	else
-- 		return false;
-- 	end
-- end

-- 处理网络数据，用于之后显示详细列表
GameResultWindow.parseDetailInfo = function ( self, resultInfo )
	self.resultInfoList[kSeatMine] = {};
	self.resultInfoList[kSeatRight] = {};
	self.resultInfoList[kSeatTop] = {};
	self.resultInfoList[kSeatLeft] = {};
	for k,v in pairs(self.resultInfoList) do
		v.listItemData = {};
	end

	-- 该场次是否有系统补助
	local isBankruptSubsidize = RoomData.getInstance().isBankruptSubsidize;
	
	for k,v in pairs(resultInfo.resuleInfoList) do
		local player = self.pm:getPlayerById(v.userId); --self.pm:getPlayerBySeat(k - 1) or self.pm:myself();
		local seatId = player.localSeatId;
		local infoTable = self.resultInfoList[seatId];
		self:savePlayerBaseInfo(player);
		infoTable.mid = player.mid;

		if isBankruptSubsidize then
			self:gfxy(seatId, v.tempGfxyMoney);-- 刮风下雨的金币
		else
			self:gfxy(seatId, v.gfxyMoney);-- 刮风下雨的金币
		end
		
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

		infoTable.tempTurnMoney = v.tempTurnMoney;
		infoTable.turnMoney = v.turnMoney;
		infoTable.totalMoney= v.totalMoney;
		if kSeatMine == seatId then
			if RoomData.getInstance().isBankruptSubsidize then
				self.resultMoney = infoTable.tempTurnMoney;
			else
				self.resultMoney = infoTable.turnMoney;
			end
		end
	end
end

GameResultWindow.show = function ( self )

	CustomNode.show(self);

	self:showWindow1();
end

GameResultWindow.resuleFrame = function ( self, money )
	money = tonumber(money);
	self.resultMoney = money;
	if money == 0 then
		publ_getItemFromTree(self.resultView, { "title", "titleStr"}):setFile(roomResultDetailPin_map["title_nor.png"]);
		publ_getItemFromTree(self.resultView, { "title", "firework_1"}):setVisible(false);
		publ_getItemFromTree(self.resultView, { "title", "firework_2"}):setVisible(false);
	
	elseif money < 0 then
		publ_getItemFromTree(self.resultView, { "bg" }):setFile(roomResultDetailPin_map["lost_bg.png"]);
		publ_getItemFromTree(self.resultView, { "title"}):setFile(roomResultDetailPin_map["br_title_bg.png"]);
		publ_getItemFromTree(self.resultView, { "bg", "listBg"}):setFile(roomResultDetailPin_map["lost_bg3.png"]);

		publ_getItemFromTree(self.resultView, { "bg", "listBg", "money_bg"}):setFile(roomResultDetailPin_map["lost_score_bg.png"]);
		--publ_getItemFromTree(self.resultView, { "bg", "listBg", "money_bg", "splite_line_1"}):setFile(roomResultDetailPin_map["lost_score_bg.png"]);
		--publ_getItemFromTree(self.resultView, { "bg", "listBg", "money_bg", "splite_line_2"}):setFile(roomResultDetailPin_map["lost_score_bg.png"]);
		--publ_getItemFromTree(self.resultView, { "bg", "listBg", "money_bg", "splite_line_3"}):setFile(roomResultDetailPin_map["lost_score_bg.png"]);

		publ_getItemFromTree(self.resultView, {"title", "titleStr"}):setFile(roomResultDetailPin_map["title_lost.png"]);
		publ_getItemFromTree(self.resultView, { "title", "firework_1"}):setVisible(false);
		publ_getItemFromTree(self.resultView, { "title", "firework_2"}):setVisible(false);
		publ_getItemFromTree(self.resultView, { "title", "wind"}):setVisible(true);

	else
		self.winGame = true;
	end
	self:createTotalMoneyTextImg(money, kSeatMine);
end

GameResultWindow.getResultMoney = function ( self )
	-- body
	return self.resultMoney;
end


GameResultWindow.createTotalMoneyTextImg = function ( self, money, seatId )
    --if not self.totalMoneyList then
    --    self.totalMoneyList = {};
    --end

 --    if money < 0 then

	--     money = tonumber(money);
	--     local offset = "";
	--     if money < 0 then
	--     	money = -money;
	--     	offset = "jian";
	--     else
	--     	offset = "jia";
	--     end
	-- 	local view = new(Node);
	-- 	local mt = money.."";
	-- 	local len = string.len(mt);
	-- 	local x,y = 0,0;
	-- 	for i=1,len do
	-- 		local c = string.sub(mt, i, i);
	-- 		local url = nil;
	-- 		if c == "-" then
	-- 			url = "jiesuan/js_jian.png";
	-- 		elseif c == "+" then
	-- 			url = "jiesuan/js_jia.png";
	-- 		else
	-- 			url = "jiesuan/"..offset..c..".png";
	-- 		end
	-- 		local img = UICreator.createImg( url, x, y );
	-- 		x = x + img.m_res.m_width;
	-- 		view:addChild(img);
	-- 	end
	-- 	view:setVisible(true);
	-- 	view:setPos(339, 93);
	-- 	self:addChild(view);

	-- else

		-- local numberAnim = new (GameResultNumberAnim, money, money>0);
		-- self:addChild(numberAnim);
		-- numberAnim:show();

	--end

	--self.totalMoneyList[seatId] = view;
end

GameResultWindow.gfxy = function ( self, winSeatId, money )
	local t = {};
	t.type = ResultDetailList.dataTypeGFXY;
	t.winSeatId = winSeatId;
	t.money = money;
	table.insert(self.resultInfoList[winSeatId].listItemData, 1, t);
end

GameResultWindow.paoHu = function ( self, winSeatId, loseSeatId, isGangShangPao, isQiangGangHu, paiType, fanNum, money, siZhangNum, gangShangNum )
	table.insert(self.resultInfoList[winSeatId].listItemData, self:getHuTable(winSeatId, loseSeatId, isGangShangPao, 
		isQiangGangHu, paiType, fanNum, money, siZhangNum, gangShangNum));
	table.insert(self.resultInfoList[loseSeatId].listItemData, self:getHuTable(winSeatId, loseSeatId, isGangShangPao, 
		isQiangGangHu, paiType, fanNum, money, siZhangNum, gangShangNum));
end

GameResultWindow.getHuTable = function ( self, winSeatId, loseSeatId, isGangShangPao, isQiangGangHu, paiType, fanNum, money, siZhangNum, gangShangNum, isXLCH  )
	local t = {};
	if isXLCH then
		t.huNum = 1;
	end
	t.type = ResultDetailList.dataTypeHU;
	t.winSeatId = winSeatId;
	t.loseSeatId = loseSeatId;
	t.isGangShangPao = isGangShangPao;
	t.isQiangGangHu = isQiangGangHu;
	t.paiType = paiType;
	t.fanNum = fanNum;
	t.money = money;
	t.siZhangNum = siZhangNum;
	t.gangShangNum = gangShangNum;
	return t;
end

GameResultWindow.zimo = function ( self, winSeatId, paiType, fanNum, money, siZhangNum, gangShangNum, isGangShangKaiHua )
	local beHuList = {  -- 被胡牌的玩家，即比winSeatId胡牌晚
		[kSeatMine] = true,
		[kSeatRight] = true,
		[kSeatTop] = true,
		[kSeatLeft] = true
	}; 
	local beHuNum = 4;
	for k,v in pairs(beHuList) do
		for i,j in pairs(self.huCardOrder) do
			if k == j then
				beHuList[k] = false;
				beHuNum = beHuNum - 1;
			end
		end
	end
	table.insert(self.resultInfoList[winSeatId].listItemData, self:getZimoTable( winSeatId, paiType, fanNum, money, siZhangNum, 
				gangShangNum, isGangShangKaiHua, 1, 0)); -- 胡牌者,只显示一个，因为不用显示被胡者名字了
	for k,v in pairs(beHuList) do
		if v then
			-- table.insert(self.resultInfoList[winSeatId].listItemData, self:getZimoTable( winSeatId, paiType, fanNum, money, siZhangNum, 
			-- 	gangShangNum, isGangShangKaiHua, beHuNum, k)); -- 胡牌者
			table.insert(self.resultInfoList[k].listItemData, self:getZimoTable( winSeatId, paiType, fanNum, money, siZhangNum, 
				gangShangNum, isGangShangKaiHua, beHuNum, k)); -- 被胡者
		end
	end
end

GameResultWindow.getZimoTable = function ( self, winSeatId, paiType, fanNum, money, siZhangNum, gangShangNum, isGangShangKaiHua, beHuNum, loseSeatId, isXLCH )
	local t = {};
	if isXLCH then
		t.zimoNum = 1;
	end
	t.type = ResultDetailList.dataTypeZIMO;
	t.winSeatId = winSeatId;
	t.paiType = paiType;
	t.fanNum = fanNum;
	t.money = money;
	t.siZhangNum = siZhangNum;
	t.gangShangNum = gangShangNum;
	t.isGangShangKaiHua = isGangShangKaiHua;
	t.beHuNum = beHuNum;
	t.loseSeatId = loseSeatId;
	return t;
end

GameResultWindow.huaZhu = function ( self, winSeatId, huazhuList ) -- 16倍低注
	for k,v in pairs(huazhuList) do
		local t = {};
		t.type = ResultDetailList.dataTypeHUAZHU;
		t.loseSeatId = winSeatId;
		t.money = -16 * (RoomData.getInstance().di or 0);
		t.winSeatId = self.pm:getPlayerById(v).localSeatId;
		table.insert(self.resultInfoList[winSeatId].listItemData, t);
		local t1 = {};
		t1.type = ResultDetailList.dataTypeHUAZHU;
		t1.loseSeatId = winSeatId;
		t1.money = 16 * (RoomData.getInstance().di or 0);
		t1.winSeatId = self.pm:getPlayerById(v).localSeatId;
		table.insert(self.resultInfoList[t.winSeatId].listItemData, t1);
	end
end

GameResultWindow.dajiao = function ( self, winSeatId, dajiaoList, dajiaoFanNum, dajiaoMoney )
	for k,v in pairs(dajiaoList) do
		local t = {};
		t.type = ResultDetailList.dataTypeDAJIAO;
		t.loseSeatId = winSeatId;
		local seatId = self.pm:getPlayerById(v).localSeatId;
		local fanNum = dajiaoFanNum[k];
		local money = dajiaoMoney[k];
		t.winSeatId = seatId;
		t.fanNum = fanNum;
		t.money = money;
		table.insert(self.resultInfoList[t.loseSeatId].listItemData, t);
		local t = {};
		t.type = ResultDetailList.dataTypeDAJIAO;
		t.loseSeatId = winSeatId;
		local seatId = self.pm:getPlayerById(v).localSeatId;
		local fanNum = dajiaoFanNum[k];
		local money = dajiaoMoney[k];
		t.winSeatId = seatId;
		t.fanNum = fanNum;
		t.money = money;
		table.insert(self.resultInfoList[t.winSeatId].listItemData, t);
	end
end

GameResultWindow.paoHuXLCH = function (self, winSeatId, loseSeatId, paiType, fanNum, money, gangNum, genNum)
	local huData = self:getHuTable(winSeatId, loseSeatId, false, isQiangGangHu, paiType, fanNum, money, genNum, gangNum, true);
	local b = false;
	-- 判断合并相同的结果
	for k,v in pairs(self.resultInfoList[winSeatId].listItemData) do
		if GameResultWindow.isTheSameHu(v, huData) then
			v.huNum = v.huNum + 1;
			b = true;
			break;
		end
	end
	if not b then
		table.insert(self.resultInfoList[winSeatId].listItemData, huData);
	end
	b = false;
	huData = self:getHuTable(winSeatId, loseSeatId, false, isQiangGangHu, paiType, fanNum, money, genNum, gangNum, true);
	for k,v in pairs(self.resultInfoList[loseSeatId].listItemData) do
		if GameResultWindow.isTheSameHu(v, huData) then
			v.huNum = v.huNum + 1;
			b = true;
			break;
		end
	end
	if not b then
		table.insert(self.resultInfoList[loseSeatId].listItemData, huData);
	end
end

GameResultWindow.zimoXLCH = function (self, winSeatId, paiType, fanNum, money, gangNum, genNum)
	-- 自摸者数据,只显示一条，不显示输钱者名字
	local huData = self:getZimoTable( winSeatId, paiType, fanNum, money, genNum, gangNum, false, 1, k, true);
	local b = false;
	for i,j in pairs(self.resultInfoList[winSeatId].listItemData) do -- 判断合并相同的结果
		if GameResultWindow.isTheSameHu(j, huData) then
			j.zimoNum = j.zimoNum + 1;
			b = true;
			break;
		end
	end
	if not b then
		table.insert(self.resultInfoList[winSeatId].listItemData, huData);
	end
	for k,v in pairs(self.resultInfoList) do
		if k ~= winSeatId then
			-- -- 自摸者数据
			-- local huData = self:getZimoTable( winSeatId, paiType, fanNum, money, genNum, gangNum, false, 3, k, true);
			-- local b = false;
			-- for i,j in pairs(self.resultInfoList[winSeatId].listItemData) do -- 判断合并相同的结果
			-- 	if GameResultWindow.isTheSameHu(j, huData) then
			-- 		j.zimoNum = j.zimoNum + 1;
			-- 		b = true;
			-- 		break;
			-- 	end
			-- end
			-- if not b then
			-- 	table.insert(self.resultInfoList[winSeatId].listItemData, huData);
			-- end
			-- 输钱者数据
			local b = false;
			local huData = self:getZimoTable( winSeatId, paiType, fanNum, money, genNum, gangNum, false, 3, k, true);
			for i,j in pairs(self.resultInfoList[k].listItemData) do -- 判断合并相同的结果
				if GameResultWindow.isTheSameHu(j, huData) then
					j.zimoNum = j.zimoNum + 1;
					b = true;
					break;
				end
			end
			if not b then
				table.insert(self.resultInfoList[k].listItemData, huData);
			end
		end
	end
end

GameResultWindow.isTheSameHu = function ( data1, data2 )
	if data1.money == data2.money and data1.winSeatId == data2.winSeatId -- and data1.loseSeatId == data2.loseSeatId  不显示输钱者姓名了，对这个不加判断
			and data1.paiType == data2.paiType and data1.siZhangNum == data2.siZhangNum 
			and data1.gangShangNum == data2.gangShangNum  then
		return true;
	end
	return false;
end

-- 保存玩家基本信息，用于显示，防止结算界面时玩家数据被清除
GameResultWindow.savePlayerBaseInfo = function ( self, player )
	local t = {};
	t.mid = player.mid;
	t.nickName = player.nickName;
	t.seatId = player.localSeatId;
	self.playerBaseInfo[player.localSeatId] = t;
end

-- 显示顶部基本信息
GameResultWindow.showHeadInfo = function ( self )
	local isBankruptSubsidize = RoomData.getInstance().isBankruptSubsidize;
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
		if isBankruptSubsidize then
			mstr = tonumber(info.tempTurnMoney);
		end
		if mstr >= 0 then
			mstr = "+"..mstr;
			money:setColor(255,255,255);
		else
			money:setColor(255,255,255);
		end
		
		money:setText(mstr);
	end
end

GameResultWindow.getItemBySeatid = function ( self, seatID )
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

-- 显示番数明细
GameResultWindow.showDetailBySeatid = function ( self, seatID )
	DebugLog( "GameResultWindow.showDetailBySeatid" );
	if seatID == self.curShowDetailSeat then
		return;
	end
	local view = self.listView[seatID];
	if not view then
		local listData = self.resultInfoList[seatID].listItemData;
		mahjongPrint( listData );
		for k,v in pairs(listData) do
			v.w = 830;
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



GameResultWindow.changeTagStatu = function ( self, lastSeatID, nowSeatID )

	local file1 = "";
	local file2 = "";
	file1 = roomResultDetailPin_map["win_tab_bg_2.png"];
	if self.resultMoney  < 0 then
		file2 = roomResultDetailPin_map["lost_tab_bg_1.png"];
	else
		file2 = roomResultDetailPin_map["win_tab_bg_1.png"];
		if PlatformConfig.platformWDJ == GameConstant.platformType or
	   	   PlatformConfig.platformWDJNet == GameConstant.platformType then 
			file2 = "Login/wdj/Room/resultDetail/win_tab_bg_1.png";
		end
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

GameResultWindow.getTagBtnBySeatID = function ( self, seatID )
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

GameResultWindow.dtor = function ( self )
	for k,v in pairs(self.listView) do
		if v then
			delete(v);
		end
	end
	-- centerAnim:stop();
	delete(self.newAchieveAnim);
	self.newAchieveAnim = nil;
	self:removeAllChildren();
	self.bg = nil;
	self.myMoneyText = nil;
	self.moneyText1 = nil;
	self.moneyText2 = nil;
	self.moneyText3 = nil;
	self.nameText1 = nil;
	self.nameText2 = nil;
	self.nameText3 = nil;
	self.myIcon = nil;
	self.icon1 = nil;
	self.icon2 = nil;
	self.icon3 = nil;
	self.contentBg = nil;
	self.confirmBtn = nil;
    self.confirmName = nil;
    self.isChangePos = nil
    self.isVisibileConifBtn = nil;
end


