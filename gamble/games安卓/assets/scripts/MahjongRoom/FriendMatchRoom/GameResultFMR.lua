local resultLayout = require(ViewLuaPath.."resultLayout");
require("MahjongRoom/GameResult/ResultDetailList");
require("MahjongRoom/GameResult/NewResultDetailList");
local roomResultDetailPin_map = require("qnPlist/roomResultDetailPin")
---------------
--好友对战大结算
GameResultFMR = class(SCWindow)

function GameResultFMR:ctor( )
 	self:initView()

 	self.curShowDetailSeat = nil
 	self.pm = PlayerManager.getInstance()
 	self.resultInfoList = {}
 	self.huCardOrder    = {}
 	self.resultMoney    = 0

 	self.playerBaseInfo = {}-- 保存玩家基本信息，用于显示，防止结算界面时玩家数据被清除
 	self.listView = {};
 	--self:startTimer(20)
end

function GameResultFMR:dtor( )
	if self.timeAnim then
		delete(self.timeAnim)
		self.timeAnim = nil
	end

	if self.listView then
		for k,v in pairs(self.listView) do
			if v then
				delete(v);
			end
		end
	end

	self:removeAllChildren();
	self.bg = nil;
	self.myMoneyText = nil;
	self.moneyText1 = nil;
	self.moneyText2 = nil;
	self.moneyText3 = nil;
	self.nameText1 = nil;
	self.nameText2 = nil;
	self.nameText3 = nil;
	self.contentBg = nil;

end

function GameResultFMR:initView( )
	-- body
	self._layout = SceneLoader.load(resultLayout);
	self:addChild(self._layout)

	local tagStr = nil
	local btn    = nil
	local clickMap = {
		kSeatMine,
		kSeatRight,
		kSeatTop,
		kSeatLeft,
	}
	for i=1,4 do
		tagStr = "tagBtn" .. i
		btn    = publ_getItemFromTree(self._layout, {tagStr});
		btn:setType(Button.White_Type)
		btn:setOnClick(self,function ( self )
			self:showDetailBySeatid(clickMap[i])
		end)
		self[tagStr] = btn
	end

	self.bg = publ_getItemFromTree(self._layout,{"bg"})
	self:setWindowNode( self.bg );
	self:setCoverEnable( false );-- 允许点击cover

	self.contentBg = publ_getItemFromTree(self._layout, {"bg", "listBg"});

	self.myMoneyText = publ_getItemFromTree(self._layout, {"bg", "listBg", "money_bg1", "money"});
	self.myNameText  = publ_getItemFromTree(self._layout, { "tagBtn1","name"});

	for i=2,4 do
		tagStr = "tagBtn"..i
		self["nameText"..(i-1)]  = publ_getItemFromTree(self._layout,{tagStr,"name"})

		tagStr = "money_bg"..i
		self["moneyText"..(i-1)] = publ_getItemFromTree(self._layout,{"bg","listBg",tagStr,"money"})
	end

	publ_getItemFromTree(self._layout,{"bg","again"}):setVisible(false)
	publ_getItemFromTree(self._layout,{"bg","confirmBtn"}):setVisible(false)

	self.continueBtn = publ_getItemFromTree(self._layout,{"bg","continueBtn"})
	self.continueBtn:setVisible(true)
  self.touchContinueButton = false;
	self.continueBtn:setOnClick(self,function( self )
    self.touchContinueButton = true;
		self:exit()
	end)

	self.continueBtnLabel = publ_getItemFromTree(self.continueBtn,{"Image1"})

	self.closeBtn    = publ_getItemFromTree(self._layout,{"bg","close"})
	self.closeBtn:setOnClick(self,function( self )
		self:exit()
	end)

end

function GameResultFMR:startTimer( seconds )
	if not seconds or tonumber(seconds) <= 0 then
		return
	end
	self._seconds = tonumber(seconds)
	self.continueBtnLabel:setText("继 续("..tostring(seconds)..")")

	self.timeAnim = new(AnimInt, kAnimRepeat, 0, 1, 1000, 0)
	self.timeAnim:setDebugName("GameResultFMR|timeAnim")
	self.timeAnim:setEvent(self,function ( self )
		self._seconds = self._seconds - 1
		self.continueBtnLabel:setText("继 续("..tostring(self._seconds)..")")
		if self._seconds <= 0 then
			self:stopTimer()
		end
	end)

end

function GameResultFMR:stopTimer(  )
	if self.timeAnim then
		delete(self.timeAnim)
		self.timeAnim = nil
	end

	self:exit()
end

function GameResultFMR:exit( )
	self:hideWnd()
end

function GameResultFMR:savePlayerBaseInfo(player)
	local t = {};
	t.mid = player.mid;
	t.nickName = player.nickName;
	t.seatId = player.localSeatId;
	self.playerBaseInfo[player.localSeatId] = t;
end

function GameResultFMR:gfxyNew( winSeatId, money )
	local t = {};
	t.type = NewResultDetailList.dataTypeGFXY;
	t.winSeatId = winSeatId;
	t.money = money;
	table.insert(self.resultInfoList[winSeatId].listItemData, 1, t);
end

function GameResultFMR:huNew( seatId, huType, paiTypeStr, paiTypeFan, extraTypeStr, beiHuCount, info, winMoney )

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

	for i=1,beiHuCount do
		local temp2 = publ_deepcopy(temp);
		local player = PlayerManager.getInstance():getPlayerById(info["mid"..i]);
		temp2.loseSeatId = player.localSeatId;
		temp2.loseMoney = info["tempLoseMoney"..i];
		temp2.winMoney = 0;
		table.insert(self.resultInfoList[temp2.loseSeatId].listItemData, temp2);

	end
end

function GameResultFMR:huaZhuNew( huazhuList )
	for k,v in pairs(huazhuList) do
		local winPlayer  = PlayerManager.getInstance():getPlayerById(v.mid);
		local losePlayer = PlayerManager.getInstance():getPlayerById(v.beiChaMid);
		local t = {};
		t.type       = NewResultDetailList.dataTypeHUAZHU;
		t.loseSeatId = losePlayer.localSeatId;
		t.money      = v.tempHuazhuMoney;
		t.winSeatId  = winPlayer.localSeatId;
		table.insert(self.resultInfoList[t.loseSeatId].listItemData, t);
		table.insert(self.resultInfoList[t.winSeatId].listItemData, publ_deepcopy(t));
	end
end

function GameResultFMR:dajiaoNew( dajiaoList )

	for k,v in pairs(dajiaoList) do
		local winPlayer = PlayerManager.getInstance():getPlayerById(v.mid);
		local losePlayer = PlayerManager.getInstance():getPlayerById(v.beiChaMid);
		local t = {};
		t.type = NewResultDetailList.dataTypeDAJIAO;
		t.loseSeatId = losePlayer.localSeatId;
		t.winSeatId = winPlayer.localSeatId;
		t.fanNum = v.dajiaoFan;
		t.money = v.tempDajiaoMoney;

		table.insert(self.resultInfoList[t.loseSeatId].listItemData, publ_deepcopy(t));
		table.insert(self.resultInfoList[t.winSeatId].listItemData, t);
	end
end

function GameResultFMR:parseDataAndShowInitinfo( resultInfo )
	DebugLog("GameResultFMR:parseDataAndShowInitinfo")
	mahjongPrint(resultInfo)

	self.resultInfoList[kSeatMine]  = {};
	self.resultInfoList[kSeatRight] = {};
	self.resultInfoList[kSeatTop]   = {};
	self.resultInfoList[kSeatLeft]  = {};

	for k,v in pairs(self.resultInfoList) do
		v.listItemData = {};
	end


	for k,v in pairs(resultInfo.playerList) do
		local player    = self.pm:getPlayerById(v.mid); --self.pm:getPlayerBySeat(k - 1) or self.pm:myself();
		local seatId    = player.localSeatId;
		local infoTable = self.resultInfoList[seatId];
		self:savePlayerBaseInfo(player);
		infoTable.mid   = player.mid;

		self:gfxyNew(seatId, v.tempGfxyMoney);-- 刮风下雨的金币

		for j,n in pairs(v.huInfo) do -- 胡牌和自摸数据
			local winMoney = n.tempWinMoney;
			self:huNew(seatId, n.huType, n.paiTypeStr, n.paiTypeFan, n.extraTypeStr, n.beiHuCount, n, winMoney)
		end

		infoTable.tempTurnMoney = v.tempTurnMoney;
		infoTable.turnMoney     = v.turnMoney;
		infoTable.totalMoney    = v.totalMoney;

		if kSeatMine == seatId then
			self.resultMoney = infoTable.tempTurnMoney;
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

  self.continueBtnLabel:setText("继 续")
	-- --倒计时
	-- if resultInfo.matchScoreTable and resultInfo.matchScoreTable.jf_time then
	-- 	self:startTimer(resultInfo.matchScoreTable.jf_time)
	-- else
	-- 	self:startTimer(20)
	-- end
end
-- 显示番数明细
function GameResultFMR:showDetailBySeatid( seatID )

	DebugLog( "GameResultWindow.showDetailBySeatid" );
	if seatID == self.curShowDetailSeat then
		return;
	end
	local view = self.listView[seatID];
	if not view then
		local listData = self.resultInfoList[seatID].listItemData;
		mahjongPrint( listData );
		for k,v in pairs(listData) do
			v.w 		= 830;
			v.h 		= 40;
			v.mySeat    = seatID;
			v.playerBaseInfo = self.playerBaseInfo;
		end
		local adapter = new(CacheAdapter, NewResultDetailList, listData);
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

function GameResultFMR:changeTagStatu( lastSeatID, nowSeatID )
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
		self:getTagBtnBySeatID(kSeatMine):setFile(file1);
		self:getTagBtnBySeatID(kSeatRight):setFile(file1);
		self:getTagBtnBySeatID(kSeatTop):setFile(file1);
		self:getTagBtnBySeatID(kSeatLeft):setFile(file1);
	else
		self:getTagBtnBySeatID(lastSeatID):setFile(file1);
	end
	self:getTagBtnBySeatID(nowSeatID):setFile(file2);
end

function GameResultFMR:getResultMoney()
	return self.resultMoney
end

function GameResultFMR:showWnd()
	self.super.showWnd(self)

   for k,v in pairs(self.resultInfoList) do
      if kSeatMine == k then
		self:resuleFrame(v.tempTurnMoney);
      end
   end
   self:showHeadInfo(); --加载完详细信息后设置头部信息
   self:showDetailBySeatid(kSeatMine);
end

function GameResultFMR:showHeadInfo( )
	DebugLog("GameResultFMR:showHeadInfo-------------------------------------")
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

		mstr = tonumber(info.tempTurnMoney);

		if mstr >= 0 then
			mstr = "+"..mstr;
			--money:setColor( 0xcc , 0x44, 0x00);
			money:setText(mstr,0,0, 0xcc , 0x44, 0x00);
		else
			--mstr = "-"..mstr
			--money:setColor( 0x4b , 0x2b, 0x1c);
			money:setText(mstr,0,0, 0x4b , 0x2b, 0x1c);
		end
		DebugLog(nameStr..":"..mstr)

	end
end



GameResultFMR.resuleFrame = function ( self, money )
	money = tonumber(money);
	self.resultMoney = money;
	if money == 0 then
		publ_getItemFromTree(self._layout, { "title", "titleStr"}):setFile(roomResultDetailPin_map["title_nor.png"]);
		publ_getItemFromTree(self._layout, { "title", "firework_1"}):setVisible(false);
		publ_getItemFromTree(self._layout, { "title", "firework_2"}):setVisible(false);

	elseif money < 0 then
		publ_getItemFromTree(self._layout, { "bg" }):setFile(roomResultDetailPin_map["lost_bg.png"]);
		publ_getItemFromTree(self._layout, { "title"}):setFile(roomResultDetailPin_map["br_title_bg.png"]);
		publ_getItemFromTree(self._layout, { "bg", "listBg"}):setFile(roomResultDetailPin_map["lost_bg3.png"]);

		publ_getItemFromTree(self._layout, { "bg", "listBg", "money_bg"}):setFile(roomResultDetailPin_map["lost_score_bg.png"]);

		publ_getItemFromTree(self._layout, {"title", "titleStr"}):setFile(roomResultDetailPin_map["title_lost.png"]);
		publ_getItemFromTree(self._layout, { "title", "firework_1"}):setVisible(false);
		publ_getItemFromTree(self._layout, { "title", "firework_2"}):setVisible(false);
		publ_getItemFromTree(self._layout, { "title", "wind"}):setVisible(true);

	else
		self.winGame = true;
	end
	--self:createTotalMoneyTextImg(money, kSeatMine);
end

GameResultFMR.getItemBySeatid = function ( self, seatID )
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

-- function GameResultFMR:updateHeadMoneyInfo()
-- 	local moneyNodeKey = {"myMoneyText","moneyText1","moneyText2","moneyText3"}
-- 	local node,str,num
-- 	for i=1,#moneyNodeKey do
-- 		local node = self[moneyNodeKey[1]]
-- 		if node then
-- 			str = node:getText()
-- 			num = tonumber(str) or 0
-- 			if num >= 0 then
-- 				money:setColor( 0xcc , 0x44, 0x00);
-- 			else
-- 				money:setColor( 0x4b , 0x2b, 0x1c);
-- 			end
-- 		end
-- 	end
-- end

GameResultFMR.getTagBtnBySeatID = function ( self, seatID )
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
