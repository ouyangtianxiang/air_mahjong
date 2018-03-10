require("MahjongRoom/RoomScene");
require("MahjongHall/Friend/InviteFriendInFMRWindow");
require("MahjongRoom/FriendMatchRoom/GameResultFMR")
require("MahjongRoom/FriendMatchRoom/new_fmr_final_result_wnd");

require("MahjongVoice/SCVoiceManager")
require("MahjongVoice/SCVoiceData")
require("Animation/UtilAnim/voiceAnim")

local voicePin_map = require("qnPlist/voicePin")

FriendMatchRoomScene = class(RoomScene);

FriendMatchRoomScene.ctor = function( self, viewConfig, state )
	DebugLog( "FriendMatchRoomScene.ctor" );
	FriendMatchRoomScene_instance = self

	self:initSocketEventFuncMap();
    self:initHttpRequestsCallBackFuncMap();

    self._fmrData =  {}---好友比赛房间的额外信息
	self._fmrData.curRoundNum = 0     ---当前第几局,-1表示未开始
	self._fmrData.roundNum    = 0
	self._fmrData.curRoundMost= 0
	self._fmrData.curRoundIsOver = true

	self:initView( false );
	------------------------------------hide 活动,宝箱,获取金币
	self:requireChestStatus()
	self.quickPay:setVisible(false)
	------------------------------------hide end
	self:initCmdConfig();
	self:initVoiceBtn()

	self:initVoiceManager()
end





FriendMatchRoomScene.chat = function ( self )
	--self:sendVoice()
	self:openQuickChatWnd();
end

FriendMatchRoomScene.dtor = function( self )
	if self.m_voiceManager then
		delete(self.m_voiceManager)
		self.m_voiceManager = nil
	end

	EventDispatcher.getInstance():unregister(NativeManager._Event, self, self.nativeCallEvent);
	--RoomScene_instance = nil;
	FriendMatchRoomScene_instance = nil

	if self.voteAnim then
		delete(self.voteAnim)
		self.voteAnim = nil
	end
end



function FriendMatchRoomScene:getInviteRequestData( ... )
	return self._fmrData.roundNum,self._fmrData.fid,RoomData.getInstance().wanfa
end

-- 创建房间座位按钮节点
FriendMatchRoomScene.createSeat = function ( self )
	self.super.createSeat( self );
	--self:setRoomBaseInfoVisible(true);
end




FriendMatchRoomScene.resume = function ( self )
	DebugLog("FriendMatchRoomScene resume");
	self.super.resume(self);

	if RoomData.getInstance().isInGame == 1 then --重连
		self:reconnectLoginGame()
		return
	end
	local data = RoomData.getInstance().privateData;
	if data.isJoinRoom then --加入房间
		data.isJoinRoom = nil
		SocketManager.getInstance():sendPack(CLIENT_CMD_JOIN_GAME4, data);
	else--主动创建房间
		data.isJoinRoom = nil
		SocketManager.getInstance():sendPack( CREATE_FRIEND_MATCH_ROOM, data );
	end
end

FriendMatchRoomScene.joinGame = function ( self, data )
	if not data then
		return
	end
	----server 要求必须先发1002 收到1008后 才能再发119进入房间

	SocketManager.getInstance():sendPack( CLIENT_COMMAND_LOGOUT ); -- 退出命令
	self._joinData = data

end

-- 登录房间
FriendMatchRoomScene.reconnectLoginGame = function (self)
	log( "FriendMatchRoomScene.reconnectLoginGame" );
	local param = {};
	local uesrInfo = self.myself:getUserData();
	param.roomid = RoomData.getInstance().roomId;
	mahjongPrint( param );
	-- TODO
	if not param.roomid or param.roomid <= 0 then
		Banner.getInstance():showMsg("进入房间失败！");
		self:exitGame();
		return;
	end

	if not SocketManager.m_isRoomSocketOpen then
		self:exitGame();
		return;
	end

	param.mid = self.myself.mid;
	param.key = self.myself.mtkey;
	param.api = self.myself.api;
	param.version = GameConstant.Version;
	param.userInfo = json.encode(uesrInfo);

	SocketManager.getInstance():sendPack(CLIENT_COMMAND_LOGIN, param); -- 登录房间
end



-- 游戏中重新连接了一次大厅socket，處理两种情况：1 游戏中重连 2 不在游戏中退出到大厅
FriendMatchRoomScene.connectSocketSuccess = function ( self, data )
	DebugLog( "FriendMatchRoomScene.connectSocketSuccess" );
	if 1 == data.isInGame then
		Banner.getInstance():showMsg("游戏重连成功。");
		RoomData.getInstance():setRoomAddr(data);
		for k,v in pairs(self.seatManager.seatList) do
			v:changeToWaitStaty();
			v:clearData();
		end
		self:clearDesk()
		self:reconnectLoginGame();
		self.reconnectingGameDirect = true; -- 是否是房间内直接重连
	else
		PlayerManager.getInstance():myself().isInGame = false;
		Banner.getInstance():showMsg("网络重连成功。");
		self:exitGame();
	end
end


-- 退出房间，包括被踢出房间
FriendMatchRoomScene.selfLogoutRoom = function ( self, data )
	if self._joinData then

		for k,v in pairs(self.seatManager.seatList) do
			v:changeToWaitStaty();
			if v.seatID == 0 then
				v.isSingleGameFirst = false;
			end
		end

		local playerMgr = PlayerManager.getInstance();
		playerMgr:removeOtherPlay(); -- 先移除其他玩家

		playerMgr:myself():setFriendMatchScore(0)

		self:clearDesk()

		if self.outCardTimer then
			self.outCardTimer:hide();
		end
		-- body
		SocketManager.getInstance():sendPack(CLIENT_CMD_JOIN_GAME4, self._joinData);
		self._joinData = nil
	end
end

FriendMatchRoomScene.roomLevelAndName = function ( self, data )
	DebugLog("FriendMatchRoomScene.roomLevelAndName")

	self.roomData:parseNameAndLevel( data );
	--self:setPrivateRoomData2();

	if self.isShowRoomInfo then
		self.isShowRoomInfo = false;
	end

	if not self._fmrData.curRoundIsOver  or RoomData.getInstance().isReconnect then
		self:showTableInfo(2,true)
	else
		self:showTableInfo(1,true)
	end

	local rd = HallConfigDataManager.getInstance():returnLevelFromHallConfigByDi(200)
    local level = 52
    if rd and rd.level then
        level = rd.level
    end

	--获取道具列表
	local param_data = {};
	param_data.party_id = level; --GameConstant.curRoomLevel or 50;
	DebugLog("HttpModule.s_cmds.getRoomPropList,")
	SocketManager.getInstance():sendPack(PHP_CMD_GET_ROOM_PROP_LIST,param_data)
end

--牌局是否结束
function FriendMatchRoomScene:isRoundGameOver()
	if (self._finalGameData and self._finalGameData.ret == 0 ) --提前结束
		or (self._fmrData.roundNum == self._fmrData.curRoundNum and self._fmrData.curRoundIsOver) then --结束
		return true
	end

	return false
end

function FriendMatchRoomScene:isRoundNotBeginning( )
	if self._fmrData and self._fmrData.curRoundNum == 0 then
		return false
	end
	return true
end

function FriendMatchRoomScene:createTableInfo( )
	if not self.RDI then
		local parentNode = self:getControl(RoomScene.s_controls.baseInfoView)

		local createImgFunc = function( imgName, align, x, y , parent )
			local img = UICreator.createImg(imgName,x,y)
			img:setAlign(align)
			parent:addChild(img)
			return img
		end

		local createTextFunc = function ( str, x, y, w, h, align, font, r, g, b, parentNode)
			local text = UICreator.createText( str, x, y, w,h, kAlignCenter ,font, r, g, b )
			text:setAlign(align)
			parentNode:addChild(text)
			return text
		end

		self.RDI = {}
		self.RDI.logo 		= createImgFunc("Room/roomInfo/logo.png",kAlignCenter,0,0, parentNode)

		self.RDI.roomNameBg   = createImgFunc("Room/roomInfo/nameBgF.png"     ,kAlignCenter,0,0, parentNode)

		self.RDI.leftArrow  = createImgFunc("Room/roomInfo/logoLeft.png"  ,kAlignRight,0,0, parentNode)
		self.RDI.rightArrow = createImgFunc("Room/roomInfo/logoRight.png" ,kAlignLeft,0,0, parentNode)

		self.RDI.wanfaBg    = UICreator.createImg( "Room/roomInfo/infoFrame.png", 0, 0 ,20, 20, 20, 20)
		self.RDI.wanfaBg:setSize(360,40)--300
		self.RDI.wanfaBg:setAlign(kAlignCenter)
		parentNode:addChild(self.RDI.wanfaBg)

		self.RDI.wanfaBg.lt = createTextFunc("", 20, 0, 0,26, kAlignLeft ,22, 0x17, 0xe3, 0x77, self.RDI.wanfaBg)
		self.RDI.wanfaBg.mt = createTextFunc("",  0, 0, 0,26, kAlignLeft ,22, 0x17, 0xe3, 0x77, self.RDI.wanfaBg)
		self.RDI.wanfaBg.rt = createTextFunc("", 20, 0, 0,26, kAlignRight ,22, 0x17, 0xe3, 0x77, self.RDI.wanfaBg)
		self.RDI.wanfaBg.mt2 = createTextFunc("", 20,0,0,26,  kAlignRight, 22, 0x17, 0xe3, 0x77, self.RDI.wanfaBg)

		self.RDI.roomNameBg.lt = createTextFunc("好友对战",132, 0, 0,26, kAlignRight ,22, 0x17, 0xe3, 0x77, self.RDI.roomNameBg)
		self.RDI.roomNameBg.rt = createTextFunc("", 132, 0, 0,26, kAlignLeft ,22, 0x17, 0xe3, 0x77, self.RDI.roomNameBg)
	end
end

function FriendMatchRoomScene:setTableInfoStatus( status )
	--status=1  牌局未开始状态
	--status=2  牌局开始状态
	-- if not status or (status ~= 1 and status ~= 2) then
	-- 	return
	-- end
	assert(status and (status ~= 1 or status ~= 2))

	self._status = status-- or 1
	local configMap = {
		{
		    ["logo"] 		= {0   ,-122,true},
		    ["roomNameBg"]	= {0   , -66,true},
		    ["leftArrow"]   = {180 , -15,true},
		    ["rightArrow"]  = {180 , -15,true},
		    ["wanfaBg"]     = {0   , -15,true},
		},
		{
		    ["logo"] 		= {0   , -122,true},
		    ["roomNameBg"]	= {0   , -66,false},
		    ["leftArrow"]   = {180 ,  105,true},
		    ["rightArrow"]  = {180 ,  105,true},
		    ["wanfaBg"]     = {  0 ,  105,true},
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


end

function FriendMatchRoomScene:autoAdaptReSizeAndPos()

	local function addWidth( node, sum )
		local w,h = node:getSize()
		return (sum + w)
	end

	local textWidthSum = 0
	textWidthSum = addWidth(self.RDI.wanfaBg.lt, textWidthSum)
	--textWidthSum = addWidth(self.RDI.wanfaBg.mt, textWidthSum)
	textWidthSum = addWidth(self.RDI.wanfaBg.rt, textWidthSum)
	textWidthSum = addWidth(self.RDI.wanfaBg.mt2, textWidthSum)

	local edgeOff,midOff = 20,30
	local originW,originH = self.RDI.wanfaBg:getSize()
	local bgWidth = edgeOff*2 + 2*midOff + textWidthSum
	self.RDI.wanfaBg:setSize( bgWidth,originH)

	local function resetX( node, x )
		local x1,y1 = node:getPos()
		node:setPos(x,y1)
	end

	resetX(self.RDI.wanfaBg.lt, 20)
	--resetX(self.RDI.wanfaBg.mt,  addWidth(self.RDI.wanfaBg.lt, 20 + 30) )
	resetX(self.RDI.wanfaBg.rt, 20)
	resetX(self.RDI.wanfaBg.mt2, addWidth(self.RDI.wanfaBg.rt, 20 + 30) )

	resetX(self.RDI.leftArrow,  bgWidth/2)
	resetX(self.RDI.rightArrow, bgWidth/2)
end

-- function FriendMatchRoomScene:setRoomNum( num )
-- 	if self.RDI and self.RDI.roomNameBg and self.RDI.roomNameBg.rt then
-- 		self.RDI.roomNameBg.rt:setText(tostring(num))
-- 	end
-- end

function FriendMatchRoomScene:showRoomName( )
	if self.RDI.roomNameBg.lt then
		self.RDI.roomNameBg.lt:setText("好友对战")
	end
	if self.RDI.roomNameBg.rt and self._fmrData and self._fmrData.fid  then

        self.RDI.roomNameBg.rt:setText(string.format("%06d",self._fmrData.fid))
	end
	if self.RDI.roomNameBg.mt2 then
	end
end


function FriendMatchRoomScene:showTableInfo(status, visible)
	if status then
		self:setTableInfoStatus(status)
	end

	self:showRoomName()

	local left,mid,right
	local wanfa  = RoomData.getInstance().wanfa;
	local result = self:getWanfaStr(wanfa)

	if result then
		left = result[1]
		--mid  = result[2]
	end

	--if status == 1 or not status then
	mid = "底注:"..(RoomData.getInstance().di or 0).."分"
	--else
	right = "第"..(self._fmrData.curRoundNum or 0) .. "/"..(self._fmrData.roundNum or 0).."局"
	--end
	self:showWanfaAndDi(visible,left,mid,right)

	self:autoAdaptReSizeAndPos()
end

function FriendMatchRoomScene:showWanfaAndDi( visible, left, mid ,right  )

	self.RDI.wanfaBg.rt:setText(right or "")
	self.RDI.wanfaBg.lt:setText(left or "")
	--self.RDI.wanfaBg.mt:setText(mid or "")
	self.RDI.wanfaBg.mt:setText("")
	local mt2TipStr = nil
	if not self._fmrData.curRoundMost or self._fmrData.curRoundMost == 0 then
		mt2TipStr   = "不封顶"
	else
		mt2TipStr   = self._fmrData.curRoundMost .. "番封顶"
	end
	self.RDI.wanfaBg.mt2:setText( mt2TipStr )

	self.RDI.wanfaBg.rt:setVisible(visible)
	self.RDI.wanfaBg.lt:setVisible(visible)
	self.RDI.wanfaBg.mt:setVisible(visible)

end

function FriendMatchRoomScene:onClickedInviteFriendCallback( )
	-- -- 未安装微信和QQ 或者 审核版本 直接跳转通讯录
	-- if not GameConstant.isWechatInstalled and not GameConstant.isQQInstalled
	-- 	or GameConstant.checkType ~= kCheckStatusClose then
	-- 	require("MahjongRoom/FriendMatchRoom/FMRInviteSMSFriendWin")
	-- 	local smsWin = new(FMRInviteSMSFriendWin)
	-- 	GameConstant.curGameSceneRef:addChild(smsWin)
	-- 	smsWin:showWnd()
	-- 	return;
	-- end
    --test
--    if true then
--        DebugLog("");
--        self.resultFinal = new(new_fmr_final_result_wnd,{});
--        if self.resultFinal then
--            self:addChild(self.resultFinal )
--		    self.resultFinal:setOnWindowHideListener(self, function ( self )
--			    self.resultFinal = nil
--		    end);
--        end
--        return;
--    end

	if not self.m_inviteRoomWindow then
		self.m_inviteRoomWindow = new(InviteFriendInFMRWindow,self._fmrData and self._fmrData.fid or 0);
		self.nodePopu:addChild(self.m_inviteRoomWindow);
		self.m_inviteRoomWindow:setOnWindowHideListener(self, function( self )
			self.m_inviteRoomWindow = nil
		end);

		self.m_inviteRoomWindow:showWnd()
	end
end

function FriendMatchRoomScene:joinGameSuccess(data)
	DebugLog("FriendMatchRoomScene joinGameSuccess");
	----------------------------------------------------------------super
	GameConstant.boxRoomFlag = false;
	self:changeFrameCount( data.isLiangFanPai and 11 or 14 )
	local playerMgr = PlayerManager.getInstance();
	playerMgr:removeOtherPlay(); -- 先移除其他玩家
	local mySelf = playerMgr:myself();
	local roomData = RoomData.getInstance();
	roomData:enterRoom(data); -- 初始化进入房间的数据
	roomData:setIpAndPort(data);

	self:getRoomActivityInfo();  --开始获取金币活动
	self:requireChestStatus();   -- 请求宝箱
	-- 自己的网络座位id一定要先赋值，用于计算其他玩家的本地座位id

	Player.myNetSeat = roomData.mySeatId;
	mySelf.seatId = Player.myNetSeat;
	--mySelf.money = roomData.myMoney;
	mySelf:setFriendMatchScore(roomData.myMoney)


	local isSendReady =true
	--if mySelf.isReady then --有可能server主动配桌
	--self:readyActionToServer()
	--isSendReady = true
	--end



	-- 创建玩家
	for k,v in pairs(data.playerInfo) do -- 游戏玩家数据
		local player = playerMgr:parseNetPlayerData(v, data.inFetionRoom);
		self:playerEnterGame( player )
	end
	local myself = playerMgr:myself();
	self:playerEnterGame( mySelf )


	if self.reconnectingGameDirect then -- 重连的时候刚好牌局结束，重新设置自己的位置
		self.reconnectingGameDirect = false;
		PlayerManager:getInstance():myself().isInGame = false;
		self:reconnectGameDirectWhenOver( mySelf )
	end

	if GameConstant.isLowLevelClicked then -- 判断是否点击了去低倍场按钮，如果点击了去低倍场按钮就自动准备
		GameConstant.isLowLevelClicked = false;
		GameConstant.isDirtPlayGame = true;
	end



	if GameConstant.isDirtPlayGame then -- 快速进入游戏则直接准备
		GameConstant.isDirtPlayGame = false;
		isSendReady = true
		self:readyActionToServer()
	end

	------------------------------------------------------
	local privateRoomLevel = 0
	if data and data.roomLevel then
		privateRoomLevel = tonumber(data.roomLevel)
	end

	if not mySelf.isReady and ( privateRoomLevel ~= 50) and not GameConstant.isSingleGame then
		self:showReadyBtn()
	end
	---------------------------	-----------------------------
	if not myself.isReady and not self.hasShowTimeOutTip then -- 自己没准备并且没显示准备提示
		if #playerMgr:getReadyPlayerList() == 3 then -- 其他3人已经准备
			self.hasShowTimeOutTip = true;
			if not GameConstant.isSingleGame then
				self:showOrHideTimeOutTip( true, RoomData.getInstance().kickTime )
			end
		end
	end
	---------------------------------------------------------------super end
	self._fmrData.curRoundIsOver = true--当前这一局还未开始

	--设置房间号
	if data and data.fid and self.RDI and self.RDI.roomNameBg then
		self.RDI.roomNameBg.rt:setText(tostring(data.fid))
	end
	self:parseFMRoomData(data)
	self:popInvite(data)

	self:requestInviteShareInfo()

	if self.m_voiceManager then
		self.m_voiceManager:login(data.tid, PlayerManager.getInstance():myself().mid)
	end
end

function FriendMatchRoomScene:requestInviteShareInfo( )
	local param = {}
	param.mid    = PlayerManager.getInstance():myself().mid
	param.fid    = self._fmrData.fid
	--param.fields = {}
	local fields = {}
	fields.roundnum = self._fmrData.roundNum
	fields.basepoint= self._fmrData.basePoint
	param.fields = fields

	fields.playtype = 10--血战
	local wanfa  = RoomData.getInstance().wanfa or 0
	if bit.band(wanfa, 0x10) ~= 0 then
		fields.playtype = 12--两房牌
	end

	if bit.band(wanfa, 0x02) ~= 0 then
		fields.playtype = 11--血流
	end
	GlobalDataManager.getInstance():requestInviteShareInfo(param)--拉取邀请好友的配置信息
end



function FriendMatchRoomScene:parseFMRoomData( data )
	self._fmrData = self._fmrData or {}---好友比赛房间的额外信息
	self._fmrData.fid = data.fid or 0
	self._fmrData.tid = data.tid or 0
	self._fmrData.uid = data.uid or 0
	self._fmrData.roundNum 	  = data.roundNum or 0
	self._fmrData.basePoint   = data.basePoint or 0
	self._fmrData.curRoundNum = data.curRoundNum or self._fmrData.curRoundNum
	self._fmrData.curRoundMost= data.curRoundMost or 0
end

---是不是房间主人
function FriendMatchRoomScene:isRoomOwner( uid )

	if self._fmrData and self._fmrData.uid and self._fmrData.uid ~= 0 then
		local compareId  = uid or tonumber(PlayerManager.getInstance():myself().mid or 0)
		return compareId == self._fmrData.uid
	end
	return false
end



function FriendMatchRoomScene:popInvite(data )
	if self:isRoomOwner() then
		self:onClickedInviteFriendCallback()
	end
	-- DebugLog("FriendMatchRoomScene:doInviteFriendsInCreated")
	-- --邀请好友
	-- local param  = GlobalDataManager.getInstance():getInviteBattleInfo()
	-- if param then
	-- 	mahjongPrint(param)
	-- 	param.fid = data.fid or 0
	-- 	SocketManager.getInstance():sendPack(FRIEND_CMD_FORWARD, param);
	-- end
	-- GlobalDataManager.getInstance():setInviteBattleInfo(nil)
end

function FriendMatchRoomScene:updateRoundNum( num )
	self._fmrData.curRoundNum = num or 0
	---------------------
	if self._status ~= 1 and self.RDI and self.RDI.wanfaBg then
		local str = "第"..(self._fmrData.curRoundNum or 0) .. "/"..(self._fmrData.roundNum or 0).."局"
		self.RDI.wanfaBg.rt:setText(str)
	end
end

FriendMatchRoomScene.showBankruptTips = function( self, beihuMid, huMid )

	-- -- 如果某个场次开启了破产补助，则不提示破产无法获取金币信息
	-- if self.roomData then
	-- 	if self.roomData.isBankruptSubsidize then
	-- 		return;
	-- 	end
	-- end

	-- local tips = "";
	-- if not beihuMid or not huMid then
	-- 	return;
	-- end
	-- if beihuMid == huMid then
	-- 	return;
	-- end
	-- local playerManager = PlayerManager.getInstance();
	-- local myselfMid = playerManager:myself().mid;

	-- if huMid ~= myselfMid then
	-- 	return;
	-- end
	-- local player = playerManager:getPlayerById( beihuMid );
	-- if not player then
	-- 	return;
	-- end
	-- if player.money > 0 then
	-- 	return;
	-- end
	-- tips = player.nickName.."已破产，无法赢取他的金币";

	-- Banner.getInstance():showMsg( tips );
end

-- 服务器广播准备开始游戏
FriendMatchRoomScene.readyStartGameServer = function ( self, data )
	self._fmrData.curRoundIsOver = false--当前这一局已经开始
	self._finalGameData = nil
	----清掉桌子,大结算
	self:removeResultViewCleanCards()

	self:updateRoundNum(data.curRoundNum)
	self.super.readyStartGameServer(self,data)
end

-- 广播开始游戏发牌----------------------------每局开始都会发
FriendMatchRoomScene.startGameDealCardServer = function (self , data)
	-- if self._fmrData.curRoundNum == 1 then
	-- 	--如果是第一轮 清掉积分
	-- end

	self:hideReadyBtn()
	-- if data.serviceFee then
	-- 	for i=1,3 do
	-- 		local player = PlayerManager.getInstance():getPlayerBySeat(i);
	-- 		if player then
	-- 			player:addMoney(-data.serviceFee);
	-- 		end
	-- 	end
	-- end
	self:startGameDealCard( data.cardList, data.serviceFee )
	-- 计算并更新剩余牌数
	local roomData = RoomData.getInstance();
	roomData.leftcard = roomData.isLiangFanPai and 32 or 56;
	self:showLeftCardNum( roomData.leftcard )
end


FriendMatchRoomScene.gameOver2Server = function ( self, data )
	self._fmrData.curRoundIsOver = true--当前这一局已经结束

	HuCardTipsManager.getInstance():clearAll();
	if not GameConstant.isSingleGame then
		GameConstant.justPlayGame = true;
	end
	GameConstant.needCheckMoney = true;
	self:deleteAddFanNode(data)-- 如果是加番玩法，删除加番节点

	local mySelf = PlayerManager.getInstance():myself()


	for k, v in pairs(data.playerList) do
		local player = PlayerManager:getInstance():getPlayerById(v.mid);
		if player then
			if player == mySelf then
				player:setFriendMatchScore(v.totalMoney)
			else
				player.money = v.totalMoney;
			end
		end

		if player and kSeatMine == player.localSeatId then
			PlayerManager:getInstance():myself().isInGame = false;
		end

		if player and not GameConstant.isSingleGame then
			if self.roomData.isXueLiu or not player.isHu then -- 血流场或是普通场没有胡牌的玩家在这里计算胜率
				if v.turnMoney > 0 then
					player.wintimes = player.wintimes + 1;
				elseif v.turnMoney < 0 then
					player.losetimes = player.losetimes + 1;
				else
					player.drawtimes = player.drawtimes + 1;
				end
			end
		end
	end

	-- 更新界面
	EventDispatcher.getInstance():dispatch(GlobalDataManager.updateSceneEvent); -- 直接更新一次金币
	self:gameOver2(data)
	-- GlobalDataManager.getInstance():updateScene();
	for k,v in pairs(PlayerManager:getInstance().playerList) do
		v:gameOver();
	end
	self:showUserUpdateAnim( data )
--    self:checkIs5Cards()

end


FriendMatchRoomScene.gameOver2 = function ( self, data )
	DebugLog("FriendMatchRoomScene.gameOver2")
	self.reconnectRoom = false;
	GameEffect.getInstance():stop();
	self.mahjongManager:setAllMahjongFrameDown();
	self:dealGameOverInHandCards2(data.playerList);

	if self.operationView then
		self.operationView:hideOperation();
	end
	local sm = self.seatManager;
	sm:gameFinish();

	self.mahjongManager:showBigCardCenterDiscard();
	-- 移除中心显示的打出牌
	self.mahjongManager:removeBigShowCenterView();

	self:showOrDisapperTuoguan(false);

	-- 查花猪和查大叫动画播放
	local huazhuList = {};
	local dajiaoList = {};
	for k,v in pairs(data.huazhuList) do
		local p = PlayerManager.getInstance():getPlayerById(v.beiChaMid);
		huazhuList[p.localSeatId] = 1;
	end
	for k,v in pairs(data.dajiaoList) do
		local p = PlayerManager.getInstance():getPlayerById(v.beiChaMid);
		dajiaoList[p.localSeatId] = 1;
	end

	for k,v in pairs(huazhuList) do
		if 1 == v then
			self:playGameAnim(SpriteConfig.TYPE_CHAHUAZHU, k);

			if k == kSeatMine then -- 新手引导 查花猪
				TeachManager.getInstance():show(TeachManager.CHA_DA_JIAO_TIP);
			end
		end
	end
	for k,v in pairs(dajiaoList) do
		if 1 == v then
			self:playGameAnim(SpriteConfig.TYPE_CHADAJIAO, k);
			if k == kSeatMine then -- 新手引导 查大叫
				TeachManager.getInstance():show(TeachManager.CHA_DA_JIAO_TIP);
			end
		end
	end

	-- 胡牌后直接在桌面显示总的输赢钱数
	for k,v in pairs(data.playerList) do
		if v.mid == PlayerManager.getInstance():myself().mid then
			-- 更新一次本局金币数
			RoomData.getInstance().isReconnect = false;
			if RoomData.getInstance().isBankruptSubsidize then
				RoomData.getInstance().mineCurGameWinMoney = v.tempTurnMoney;
			else
				RoomData.getInstance().mineCurGameWinMoney = v.turnMoney;
			end
			self:caluMoneyExchange( 0 );
		end
	end

	-- 显示暗杠的牌
	self.mahjongManager:showAnGangMahjongWhenGameOver();

	if self.littleResultDetailView then
		self.littleResultDetailView:hideWnd();
	end


	-- 先把界面创建出来，延迟显示
	if not self.resultView then
		self.resultView = new(GameResultFMR);
		self.nodePopu:addChild(self.resultView);
		self.resultView:parseDataAndShowInitinfo( data );

		self.resultView:setOnWindowHideListener(self,function ( self )
			DebugLog("setOnWindowHideListener");
			local touchContinueButton = self.resultView.touchContinueButton;
			DebugLog("touchContinueButton:"..tostring(touchContinueButton));
			self.resultView = nil
			--如果是最后一局结束
			if self:isRoundGameOver() then
				self:showGameFinalResult()
			else
				if touchContinueButton then
					self:readyAction();
				else
					self:showReadyBtn();
				end
			end
			--
		end)
	end

	delete(self.showResultAnim);
	self.showResultAnim = new(AnimInt, kAnimNormal,0,1,2000,0);
	DebugLog("ResultViewUmengError: RoomScene,gameOver2,showResultAnim new")
	self.showResultAnim:setDebugName("RoomScene|self.showResultAnim");
	self.showResultAnim:setEvent(self, function ( self )

		delete(self.showResultAnim);
		self.showResultAnim = nil;

		for k,v in pairs(self.seatManager.seatList) do
			local p = PlayerManager.getInstance():getPlayerBySeat(k);
			if p then
			    v:setReadyStatu(p.isReady);
			end
		end

		if self.resultView then
			self.resultView:showWnd();
		end

		if self.outCardTimer then
			self.outCardTimer:hide();
		end

		--self:hideReadyBtn();
		--self:showReadyBtn();
		TeachManager.getInstance():hide();
	end);



	--显示金币雨
	--播放掉金币动画
	if self.resultView and self.resultView:getResultMoney() > 0 then
		showGoldDropAnimation();
	end

	if GameConstant.platformType ~= PlatformConfig.platformContest then
		-- 游戏结束时判断一次金币数，如果不足则显示充值界面
		self:judgeMoneyAndShowChargeWnd();
	end

end
---------------------------------------------------------------------------------------------------------
-- 请求退出房间，不一定能成功退出
FriendMatchRoomScene.exitGameRequire = function( self )
	local myself = PlayerManager:getInstance():myself();
	--牌局未開始
	if self._fmrData.curRoundNum == 0 then
		self:exitWhenGameNotStart()
		return
	end
	mahjongPrint(self._fmrData)
	if self._finalGameData then
		mahjongPrint(self._finalGameData)
	end
	--提前结束 或者 已經結束
	if self:isRoundGameOver() then
		self:exitWhenGameOver()
		return
	end

	---牌局进行中  需请求同意
	if self._fmrData.curRoundIsOver or GameConstant.friendBattle_InGameExit then --当前这一局已经结束  可以请求
		local content = "您还没有完成初始设定的局数,退出需要其余全部玩家同意。您确定要退出吗？"
		local view = PopuFrame.showNormalDialogForCenter( "温馨提示",
														   content,
											  				   self,
											  					  0,
											  					  0,
											  				  false,
											  				  false,
											  				    "确定",
											  				    "取消");
		view:setConfirmCallback(self,function (self )
			self:requestExitToOtherPlayer()
		end)
	else
		Banner.getInstance():showMsg("未完成当前牌局,无法退出。")
	end
end

function FriendMatchRoomScene:exitWhenGameNotStart( )
		local view = nil
		local content = nil
		if self:isRoomOwner() then --房主
			content = "您退出则解散房间,无法继续游戏,您确定要解散吗?"

		else--其他人
			content = "精彩牌局即将开始,您确定要退出吗?"
		end
		view = PopuFrame.showNormalDialogForCenter( "温馨提示",
													   content,
										  				   self,
										  					  0,
										  					  0,
										  				  false,
										  				  false,
										  				    "确定",
										  				    "取消");
		view:setConfirmCallback(self,function ( )
			self:exitGame()
		end)
end

function FriendMatchRoomScene:exitWhenGameOver( )
	self:exitGame()
end

function FriendMatchRoomScene:requestExitToOtherPlayer( )
	local param = {}
	param.mid = tonumber(PlayerManager.getInstance():myself().mid)
	param.opt = 1--玩家请求操作 1-代表退出好友对战桌子
	param.tid = self._fmrData.tid or 0--桌子id
	SocketManager.getInstance():sendPack(CLIENT_COMMAND_JIFENREQUESTLOGOUT, param)
end


function FriendMatchRoomScene:requestExitCallback( data )
	if data.mid == tonumber(PlayerManager.getInstance():myself().mid) then
		if data.result == 1 then --失败
			Banner.getInstance():showMsg(data.msg or "发送请求失败")
		end
	end
end

--收到其它玩家退出请求
function FriendMatchRoomScene:resultOfRequestBack( data )
	if not data or not data.mid then
		return
	end

	local pl = PlayerManager.getInstance():getPlayerById(data.mid or 0)
	if pl then
		if self._voteView then
			self._voteView:hideWnd(true)
		end

		self._voteView = PopuFrame.showNormalDialogForCenter( "温馨提示",
													   pl.nickName .. "想提前结束牌局,您是否同意?",
										  				   self,
										  					  0,
										  					  0,
										  				  false,
										  				  false,
										  				    "同 意",
										  				    "拒 绝(30)");
		self._voteView:setConfirmCallback(self,function ()
			--发出投票结果
			local param = {}
			param.mid   = tonumber(PlayerManager.getInstance():myself().mid)
			param.opmid = data.mid
			param.opt   = 1
			param.tid   = self._fmrData.tid
			SocketManager.getInstance():sendPack(CLIENT_COMMAND_JIFENRESPONSE, param)
		end)
		self._voteView:setCancelCallback(self, function ( )
			local param = {}
			param.mid   = tonumber(PlayerManager.getInstance():myself().mid)
			param.opmid = data.mid
			param.opt   = 0
			param.tid   = self._fmrData.tid
			SocketManager.getInstance():sendPack(CLIENT_COMMAND_JIFENRESPONSE, param)
		end)

		self._voteView:setOnWindowHideListener(self, function ( self )
			self._voteView = nil

			if self.voteAnim then
				delete(self.voteAnim)
				self.voteAnim = nil
			end
		end);
		self._voteView._seconds = 30
		self:startVoteViewTimer()
	end
end

function FriendMatchRoomScene:startVoteViewTimer()
	if self.voteAnim then
		delete(self.voteAnim);
		self.voteAnim = nil;

		if self._voteView then
			self._voteView:hideWnd(true)
		end
	end
	self.voteAnim = new(AnimInt, kAnimRepeat, 0, 1, 1000, 0)
	self.voteAnim:setDebugName("FriendMatchRoomScene|VoteView")
	self.voteAnim:setEvent(self,function ( self )
		if self._voteView then
			self._voteView._seconds = self._voteView._seconds - 1
			if self._voteView.btnCancelText then
				self._voteView.btnCancelText:setText("拒 绝("..tostring(self._voteView._seconds)..")")
			end
			if self._voteView._seconds <= 0 then
				if self.voteAnim then
					delete(self.voteAnim)
					self.voteAnim = nil
				end
				self._voteView:hideWnd(true)
			end
		end
	end)
end


function FriendMatchRoomScene:disbandTable( data )
	--if self._fmrData.curRoundNum < 1 or (self._fmrData.curRoundNum == self._fmrData.roundNum and self._fmrData.curRoundIsOver) then --牌局开始前 退出
	--	self:exitGame()
	--else -- 牌局中 收到解散命令--需要等待用看最终的结算信息  不能直接退出--------------
	--	--do nothing

	--end

	self._voteView = nil
	if self.voteAnim then
		delete(self.voteAnim)
		self.voteAnim = nil
	end

	if self.resultView then
		self.resultView:setOnWindowHideListener(nil,nil)
		self.resultView:stopTimer()
		self.resultView = nil
	end

	--if self:isRoomOwner(tonumber(data.mid)) then --房主退出游戏
	--Banner.getInstance():showMsg("房主解散了房间")
	--else
		--Banner.getInstance():showMsg(player.nickName .. "离开了房间")
	--end
	GameConstant.disbandTableId = tonumber(data.mid)
	--if self:isRoundNotBeginning() then
	self:exitGame()-----------------又改了需求 收到解散命令,客户端立马退出房间

	--end
end

--扣除房主台费
function FriendMatchRoomScene:fmrPayFee( data )
	if data then
        local myself = PlayerManager.getInstance():myself();
		if data.errCode == 0 or data.errCode == 1 then --扣除/返还 0金币 1钻石
            local str = "";
            if data.errCode == 0 then
                str = "金币。";
                myself.money = myself.money + data.money;
            elseif data.errCode == 1 then
                str = "钻石。";
                myself.boyaacoin = myself.boyaacoin + data.money;
            end

			local msg = nil
			if data.money < 0 then
				msg = "创建房间成功,消耗"..(0 - data.money) ..str
			elseif money > 0 then ------------------------------------这里废弃了
				msg = "解散房间成功,返还".. data.money ..str
			end
			Banner.getInstance():showMsg(msg)
		elseif data.errCode == 9 then--金币不足开房费
		end
	end
end



--好友对战：总结算界面
function FriendMatchRoomScene:showGameFinalResult()
	if self._finalGameData then


        self.resultFinal = new(new_fmr_final_result_wnd,self._finalGameData);
        if self.resultFinal then
            self:addChild(self.resultFinal )
		    self.resultFinal:setOnWindowHideListener(self, function ( self )
			    self.resultFinal = nil
                self:showFMRGameResultBtn()
		    end);
        end
--		require("MahjongRoom/FriendMatchRoom/FMRFinalResultWin")
--		self.resultFinal = new(FMRFinalResultWin,self._finalGameData)
--		self:addChild(self.resultFinal )
--		--:addToRoot()
--		self.resultFinal:showWnd()

--		--self._finalGameData = nil
--		self.resultFinal:setOnWindowHideListener(self, function ( self )
--			self.resultFinal = nil
--			self:showFMRGameResultBtn()
--		end);
	end
end
function FriendMatchRoomScene:fmrGameOver( data )
	local param = {}
	param.time  = os.time()
	param.type  = RoomData.getInstance().wanfa
    param.tid   = self._fmrData.tid;
	--param.playerlist = {}
    local result = {};
	for i=1,#data do
		local mid   = data[i].mid
		local d = {}
		local player = PlayerManager.getInstance():getPlayerById(mid)
		if player then
			d.name  		 = player.nickName
			d.money 		 = data[i].score
			d.small_image = player.small_image
			d.sex   		 = player.sex
            d.mid = player.mid;
            table.insert(param, d);
		end
	end
    --param.result = result;
	param.ret = data.ret --正常结束写1，，提前结束写0

	self._finalGameData = param

	if param.ret == 0 and not self.resultView then
		self:showGameFinalResult()
	end


	-----清除掉已经准备的状态
	if not self.seatManager.seatList then
		return
	end

	for k,v in pairs(self.seatManager.seatList) do
		local p = PlayerManager.getInstance():getPlayerBySeat(k);
		if p then
			p.isReady = false
		    v:setReadyStatu(p.isReady);
		end
	end

	--getPlayerById
	--清掉积分数据
	-- local mySelf = PlayerManager.getInstance():myself()
	-- for i =0, 3 do
	-- 	player = PlayerManager.getInstance():getPlayerBySeat(i);
	-- 	if player then
	-- 		if player == mySelf then
	-- 			player:setFriendMatchScore(0)
	-- 		else
	-- 			player.money = 0;
	-- 	    end
	-- 	end
	-- end

--清理 操作 面板 ，选缺信息，听牌提示
if self.operationView then -- 隐藏
	self.operationView:hideOperation();
end
if self.selectQueView then
	self.nodeDingQue:removeChild(self.selectQueView, true);
	self.selectQueView = nil;
end
HuCardTipsManager.getInstance():clearAll();
	--body...
end

--------------------------------------------------------------------------------------------------------

FriendMatchRoomScene.removeResultViewNode = function ( self )
	if self.resultView then
		delete(self.showResultAnim);
		self.showResultAnim = nil;
		self.resultView:hideWnd(true);
		self.resultView = nil;
	end
end



-- 决赛清桌
FriendMatchRoomScene.removeResultViewCleanCards = function ( self )
	self:removeResultViewNode();

	if self._voteView then
		self._voteView:hideWnd(true)
	end

	for k,v in pairs(self.seatManager.seatList) do
		v:changeToWaitStaty();
	end

	self:clearDesk();
	--比赛不出现准备按钮
	self:hideReadyBtn();
end


FriendMatchRoomScene.showReadyBtn = function ( self )
	DebugLog("MatchRoomScene.showReadyBtn")
	local seat = self.seatManager:getSeatByLocalSeatID(kSeatMine,self);
	seat:showReadyBtn()
end

function FriendMatchRoomScene:showFMRGameResultBtn( )
	------


	if self:isRoomOwner() then--显示解散牌局 和 继续开始
		--if self._finalGameData and self._finalGameData.ret == 0 then --提前结束写0
		--	--只能离开房间 什么都不显示
		--	self:hideReadyBtn()
		--else --正常结束 1
			local seat = self.seatManager:getSeatByLocalSeatID(kSeatMine,self);

			if not seat then
				return
			end

			seat:showFMRGameResultBtn(self,function ( self )--解散牌局
				self:exitWhenGameNotStart();
			end, function ( self )--继续开局
				self:continueOpening()
				--self:inviteFriends()
			end)
		--end
	else --不是房主 什么按钮都不显示
		self:hideReadyBtn()
	end
	------
end

--积分清0
function FriendMatchRoomScene:clearAllScoresZero( )
	-- body
	--playerMgr:myself():setFriendMatchScore(0)
	--self.seatManager.seatList
	local myself = PlayerManager.getInstance():myself()
	local pl     = PlayerManager.getInstance().playerList
	if not pl or not self.seatManager or not self.seatManager.seatList then
		return
	end

	for k,v in pairs(pl) do
		if v == myself then
			v:setFriendMatchScore(0)
		else
			v:setMoney(0)
		end
	end

	for k,v in pairs(self.seatManager.seatList) do
		v:updateCoin()
	end

end

function FriendMatchRoomScene:continueOpening()--继续开局
	local config = GlobalDataManager.getInstance().fmRoomConfig
	if not config then
		return
	end

	local roundNum = self._fmrData.roundNum or 0
	local m,t = config:getMoneyByRound(roundNum)
--	if t and tonumber(t) ~= 0 then
--		Banner.getInstance():showMsg(config.ftips)
--		return
--	end
    local myself = PlayerManager.getInstance():myself();
	local myMoney = t == GameConstant.fm_money_type.coin and  myself.money or  myself.boyaacoin;--PlayerManager.getInstance():myself().money
	if m and myMoney and myMoney >= m then
		self._fmrData.curRoundNum = 0

		self:clearAllScoresZero()
		self:readyAction()
		return
	end
	self:notEnoughMoney()
end
function FriendMatchRoomScene:notEnoughMoney( )
	local config = GlobalDataManager.getInstance().fmRoomConfig
	if not config then
		return
	end

	local roundNum = self._fmrData.roundNum or 0
	local m,t = config:getMoneyByRound(roundNum)
    --如果是钻石不足
    local tmp_moneytype = global_transform_money_type_2(t, false)

    --创建快速充值界面
    local param_t = {t = RechargeTip.enum.friend_match_wnd,
                        isShow = true, money = m or 0, moneytype = tmp_moneytype,
                        is_check_bankruptcy = false,
                        is_check_giftpack = false};
	RechargeTip.create(param_t)
end

FriendMatchRoomScene.showMoneyExchange = function ( self, bSHow )

	self:getControl(self.s_controls.mt):setVisible(false);
	self:getControl(self.s_controls.jsmoneyBg):setVisible(false);

	local mySelf = PlayerManager.getInstance():myself()

	for k,v in pairs(self.seatManager.seatList) do
		local p = PlayerManager.getInstance():getPlayerBySeat(k);
		if p then
			local num
			if p == mySelf then
				num = p:getFriendMatchScore()
			else
				num = p.money;
		    end
		    v:setMatchScore(num)
		    v:setMatchScoreVisible(bSHow);
		end
	end
end


FriendMatchRoomScene.broadcastUpdateMoney = function ( self )
	--更新自己金币
	--RoomScene.broadcastUpdateMoney(self)
	--self:getControl(MatchRoomScene.s_controls.mt):setText(trunNumberIntoThreeOneFormWithInt(PlayerManager.getInstance():myself().money or "", true));
	--更新玩家积分
	local mySelf = PlayerManager.getInstance():myself()

	for i =0, 3 do
		player = PlayerManager.getInstance():getPlayerBySeat(i);
		if player then
			local num
			if player == mySelf then
				num = player:getFriendMatchScore()
			else
				num = player.money;
		    end
		    --v:setMatchScore(num)
			self.seatManager:getSeatByLocalSeatID(player.localSeatId):setMatchScore(num);
		end
	end

end


-- 重连成功
FriendMatchRoomScene.reconnectSuccess = function (self , data)
	self.super.reconnectSuccess(self,data)
	self._fmrData.curRoundIsOver = false--当前这一局已经开始

	self:parseFMRoomData(data)
	if data.curRoundNum ~= -1 then
		self:updateRoundNum(data.curRoundNum)
	end

	self:requestInviteShareInfo()--拉取邀请好友的配置信息
	if self.m_voiceManager then
		self.m_voiceManager:login(data.tid, PlayerManager.getInstance():myself().mid)
	end
end

-- 血流重连成功
FriendMatchRoomScene.reconnectSuccessScXLCH = function (self , data)
	self.super.reconnectSuccessScXLCH(self,data)
	self._fmrData.curRoundIsOver = false--当前这一局已经开始

	self:parseFMRoomData(data)
	if data.curRoundNum ~= -1 then
		self:updateRoundNum(data.curRoundNum)
	end
	self:requestInviteShareInfo()--拉取邀请好友的配置信息
	if self.m_voiceManager then
		self.m_voiceManager:login(data.tid, PlayerManager.getInstance():myself().mid)
	end
end


-- 重连成功处理玩家的信息
FriendMatchRoomScene.reconnectDealPlayerInfo = function (self , data)
	DebugLog("FriendMatchRoomScene.reconnectDealPlayerInfo")
	local playerMgr = PlayerManager.getInstance();
	playerMgr:removeOtherPlay(); -- 先移除其他玩家
	local mySelf = playerMgr:myself();
	local roomData = RoomData.getInstance();
	roomData:enterRoom(data.roomInfo); -- 初始化进入房间的数据
	if roomData.di == 0 then -- 说明是私人房间
		roomData:setPrivateRoomInfo(roomData:getLastPrivateRoomInfo()); -- 设置私人房间数据
		roomData.di = tonumber(roomData:getLastPrivateRoomInfo() or 0);
	end
	-- 自己的网络座位id一定要先赋值，用于计算其他玩家的本地座位id
	Player.myNetSeat = roomData.mySeatId;
	mySelf.seatId = Player.myNetSeat;
	--mySelf.money = roomData.myMoney;
	mySelf:setFriendMatchScore(roomData.myMoney)
	mySelf.isReady = false; -- 自己进入房间时是未准备状态
	-- 先把player信息拿到
	local playerInfo = data.playerInfo;
	for k , v in pairs(playerInfo) do
		local pi = {};
		pi.userId =   v.userId;
		pi.seatId =   v.seatId;
		pi.isReady =  1;
		pi.userinfo = v.userinfo;
		pi.money =    v.money;
		local player = PlayerManager.getInstance():parseNetPlayerData(pi);
		if v.isDingQue > 0 then
			player.dingQueType = v.dingQueType;
		end
		if v.isHu > 0 then
			player.isHu = true;
		end
	end
	if data.selfInfo.isDingQue > 0 then
		RoomData.getInstance().diQue = 1;
		mySelf.dingQueType = data.selfInfo.dingQueType;
	end
	if data.selfInfo.isHu > 0 then
		mySelf.isHu = true;
	end
end

FriendMatchRoomScene.showChangMoneyAnim = function ( self, mid, money )
	log( "FriendMatchRoomScene.showChangMoneyAnim" );
	if self.creatingChangeMoneyAnim or self:isFreeMatchGame() then--积分赛无金币流动
		return;
	end
	self.creatingChangeMoneyAnim = true;
	local player = PlayerManager.getInstance():getPlayerById(mid);

	log( "get player by mid" );

	if not player then
		return;
	end

	log( "playing change money anim" );

	local x, y = RoomCoor.showMoneyCoor[player.localSeatId][1], RoomCoor.showMoneyCoor[player.localSeatId][2];
	if player.localSeatId == kSeatRight then
		x = x - 51 * (money > 0 and string.len("+".. money) or string.len("" .. money) ); -- 右对齐
	end

	local key  =  "money" .. mid;
	local anim = self.nodeOperation:getChildByName(key);

	if anim then
		self.nodeOperation:removeChild(anim,true);
	end

	anim = new(ChangeMoneyAnim, tonumber(money), x, y,nil,true);
	anim:setName(key);
	self.nodeOperation:addChild(anim);
	anim:show();

	if kSeatMine == player.localSeatId then
		self:caluMoneyExchange( tonumber(money));
	end

	-- 实时计算玩家金币数
	if kSeatMine == player.localSeatId then
		player:addFriendMatchScore(tonumber(money))
		--player:addMoney(0);
	else
		player:addMoney(tonumber(money));
	end

	self.creatingChangeMoneyAnim = false;

	if GameConstant.isSingleGame then
		g_DiskDataMgr:setAppData('singleMyMoney',PlayerManager.getInstance():myself().money)
		if player.money < 0 and player.money < 0 then
			self:playBankruptAnim(player.localSeatId);
		end
	end
end


FriendMatchRoomScene.playBankruptAnim = function ( self, seatId )
	---好友比赛不播放破产动画
end


FriendMatchRoomScene.showTimeOutTip = function ( self, time )
---好友比赛不倒计时踢人
end

--刷新房间里的玩家金币信息
---- {"MONEY":"995000","UID":"519069687","VIP":"0"}
FriendMatchRoomScene.playerMoney = function ( self , data)
	if not data then
		return;
	end
	DebugLog("我接收到了更新金币");
	local myselfUid = PlayerManager.getInstance():myself().mid;

	for i = 1, #data do
		local player =  PlayerManager.getInstance():getPlayerById(tonumber(data[i].UID) or 0);
		if  player   then
			if  player.mid ~= myselfUid then
				player:setMoney(tonumber(data[i].MONEY) or player.money);
				player.vipLevel = tonumber(data[i].VIP) or player.vipLevel;
			else
				player:setFriendMatchScore(tonumber(data[i].MONEY) or player:getFriendMatchScore());
				player.vipLevel = tonumber(data[i].VIP) or player.vipLevel;
			end
		end
	end
end


FriendMatchRoomScene.readyAction = function ( self )
	DebugLog("FriendMatchRoomScene.readyAction");

	-- if PlayerManager.getInstance():myself().isReady then
	-- 	return;
	-- end

	for k,v in pairs(self.seatManager.seatList) do
		v:changeToWaitStaty();
		if v.seatID == 0 then
			v.isSingleGameFirst = false;
		end
	end

	if GameConstant.isSingleGame then
		self:readyActionToServer()
		self:clearDesk();
	else
		if not self:useChangeTable() then
			DebugLog("request ready  not change table")
			self:readyActionToServer()
			self:clearDesk();
		end
	end

	if self.outCardTimer then
		self.outCardTimer:hide();
	end

end


--广播玩家准备
FriendMatchRoomScene.userReady = function ( self, param )
	local mid = tonumber(param.mid);
	local pm = PlayerManager.getInstance();
	local player = pm:getPlayerById(mid);
	if player then
		player:setReady(true);
		GameEffect.getInstance():play("AUDIO_READY");
		self:playerChangeReadyStatu( player )
	else
		DebugLog(" set player ready failed : no player with id "..mid);
	end
	local myself = pm:myself();
	if not myself.isReady and not self.hasShowTimeOutTip then -- 自己没准备并且没显示准备提示
		if #pm:getReadyPlayerList() == 3 then -- 其他3人已经准备
			self.hasShowTimeOutTip = true;
			self:showOrHideTimeOutTip( true, RoomData.getInstance().kickTime )
		end
	end

	if myself == player then
--		self:readyTimeout()--
	else --不是自己 and not myself.isReady
		if self:isRoomOwner(mid) and self:isRoundGameOver()  then --房主准备 且是当前轮结束了  且自己还未准备
			local desc = "("..tostring(self._fmrData.roundNum).."局、"..global_get_wanfa_desc(RoomData.getInstance().wanfa).."、房间号"..tostring(self._fmrData.fid)..")。"
			local content = "您的好友"..tostring(player.nickName).."邀请您加入好友对战"..desc.."中途不可退出,您确定是否加入?"

			local view = PopuFrame.showNormalDialogForCenter( "温馨提示",
															   content,
												  				   self,
												  					  0,
												  					  0,
												  				  false,
												  				  false,
												  				    "确定",
												  				    "取消");
			view:setConfirmCallback(self,function (self )
				self._fmrData.curRoundNum = 0
				self:readyAction()
				if self.resultView then
					self.resultView:hideWnd()
				end

				if self.resultFinal then
					self.resultFinal:hideWnd()
				end

				self:clearAllScoresZero()
			end)
			view:setCancelCallback(self,function ( self )
				self:exitGame()
			end)
			view:setCloseCallback(self, function ( self )
				self:exitGame()
			end)
		end
	end

	if myself == player and self.hasShowTimeOutTip then -- 自己准备,并且之前已经显示了超时提示
		self:showOrHideTimeOutTip( false )
		self.hasShowTimeOutTip = false;
	end

	----

end



FriendMatchRoomScene.nativeCallEvent = function ( self, param, data )
	DebugLog( "RoomScene.callEvent param = "..param );
	if param == kCheckWechatInstalled then
		self:resetShareAppInstalledState( param );
	end

	if param == kFetionUploadHeadicon then
		if data then
			local player = PlayerManager.getInstance():myself();
			if player.mid > 0  then
				player.localIconDir = player.mid .. ".png";
			end
		end
	elseif kScreenShot == param then -- 显示分享窗口

	elseif param == kNoticeLoopCallLua then
		DebugLog("MusicLog  java to lua kNoticeLoopCallLua")
		self:playBackGroundMusic("bgm")
	elseif param == kStopPlayVoice then
		self:stopPlayCallback(data)
	elseif param == kStopRecordVoice then
		self:stopRecordCallback(data)
	end
end

-- 其他玩家退出游戏
FriendMatchRoomScene.userLogoutRoom = function ( self, data )
	local player = PlayerManager.getInstance():getPlayerById(tonumber(data.mid));
	if not player then
		return;
	end

	if self:isRoomOwner(tonumber(data.mid)) then --房主退出游戏
		Banner.getInstance():showMsg(player.nickName .. "解散了房间")
	else
		--Banner.getInstance():showMsg(player.nickName .. "离开了房间")  --彪哥说这里不需要了，注释；
	end

	self:playerExitGame( player )
	PlayerManager.getInstance():removePlayerByMid(tonumber(data.mid));
	if self.hasShowTimeOutTip then -- 之前已经显示了超时提示，有其他玩家退出，则隐藏
		self:showOrHideTimeOutTip( false )
		self.hasShowTimeOutTip = false;
	end

	if self.m_inviteRoomWindow and FriendDataManager.getInstance():hastheFriend(data.mid) then
		self.m_inviteRoomWindow:updateFriend();
	end


	--self._fmrData.fid
end

-------------屏蔽牌局宝箱,活动,获取金币---------------------------------------------------------
FriendMatchRoomScene.getRoomActivityInfo = function(self)
	self:getControl(RoomScene.s_controls.AwardBtn):setVisible(false);
	self:getControl(RoomScene.s_controls.AwardLight):setVisible(false);
end

FriendMatchRoomScene.requireChestStatus = function ( self )
	self:getControl(RoomScene.s_controls.chestBtn):setVisible(false)
	self:getControl(RoomScene.s_controls.chestText):setVisible(false)
end

FriendMatchRoomScene.showChestStartup = function ( self, t )
	self:getControl(RoomScene.s_controls.chestBtn):setVisible(false)
	self:getControl(RoomScene.s_controls.chestText):setVisible(false)
end

FriendMatchRoomScene.updateChestImg = function ( self, status )
	self:getControl(RoomScene.s_controls.chestBtn):setVisible(false)
	self:getControl(RoomScene.s_controls.chestText):setVisible(false)
end
--获取金币活动具体信息
FriendMatchRoomScene.getRoomActivityDetail = function(self)

end
--房间内活动领取奖励
FriendMatchRoomScene.getRoomActivityAward = function(self)

end


FriendMatchRoomScene.playerExitGame = function ( self, player )
	if self.m_voiceData then
		local seatId = player.localSeatId
		self.m_voiceData:clearUnPlayingData(seatId)
		self:updateVoiceTip(seatId)
	end

	self.super.playerExitGame(self, player)
end


-- FriendMatchRoomScene.playerEnterGame = function ( self, player )
-- 	self.super.playerEnterGame(self, player)
-- 	self.m_voiceManager:playerExit(player.mid)
-- end

-- 直接退出游戏，不做其他判断
-- noClearRoomData : 退出房间时是否清除数据，默认清除
FriendMatchRoomScene.exitGame = function ( self )
	if self.m_voiceManager then
		self.m_voiceManager:logout(self._fmrData.tid, PlayerManager.getInstance():myself().mid)
	end
	self:unregisterAllEvent();
	PlayerManager:getInstance():myself():exitGame(); -- 改变自己的状态
	self:sendExitCmd();
	GameState.changeState( nil, States.Hall );
end

-------------语音相关--------------------------------------------------------

function FriendMatchRoomScene:enableVoiceModule( bEnable )
	self.voiceBtn:setVisible(bEnable)
end

--初始化语音管理器
function FriendMatchRoomScene:initVoiceManager()
	local config = GlobalDataManager.getInstance().fmVoiceConfig
	if config and config.switch == 1 and #config.ipports > 0 and not self.m_voiceManager then
		local ip,port = config:getRandServer()
		if not ip or not port then
			return nil
		end
		--创建语音模块
		self.m_voiceManager = new(SCVoiceManager,ip, port)
		--添加接受到语音消息 回调
		self.m_voiceManager:setRecvVoiceMsgCallback(self, self.addVoiceMsg)
		--添加发送语音消息 回调
		self.m_voiceManager:setSendVoiceMsgCallback(self, self.addVoiceMsg)
		--语音成功登陆 回调
		self.m_voiceManager:setShowVoiceModelCallback(self, self.enableVoiceModule)
		self.m_voiceManager:openSocket()
		self.m_voiceData    = new(SCVoiceData)
	end
end
--初始化桌面上的语音按钮
function FriendMatchRoomScene:initVoiceBtn( )
	local x,y = self.quickChatBtn:getPos()
	self.voiceBtn = UICreator.createImg(voicePin_map["btnColor.png"])
	self.voiceBtn:setPos(x,y)
	self.voiceBtn:setEventTouch(self, function(self, finger_action, x, y, drawing_id_first, drawing_id_current)
		if kFingerDown == finger_action then
			umengStatics_lua(Umeng_RoomVoiceClick)
			self.downx,self.downy = x,y
			self:startRecord()
		elseif kFingerMove == finger_action then
			if self._recordVoiceAnim then
				if (y - self.downy) <= -50 then--moved
					self._recordVoiceAnim:showCancelState()
				else
					self._recordVoiceAnim:showRecordState()
				end
			end
		elseif kFingerUp == finger_action then
			if self._recordVoiceAnim then
				if (y - self.downy) <= -50 then--moved
					self._recordVoiceAnim:showCancelState()
				else
					self._recordVoiceAnim:showRecordState()
				end
				self:stopRecord(self._recordVoiceAnim:isCancel())
			end
		end
	end );
	self.mahjongManager.mineToolBar:addChild(self.voiceBtn);
	self.quickChatBtn:setPos(x + 70, y)

	self.voiceBtn:setVisible(false)--self._recordVoiceAnim:showRecordState()

end
--显示录音提示动画
function FriendMatchRoomScene:showRecordVoiceAnim( )
	DebugLog("showRecordVoiceAnim")
	-- body
	if not self._recordVoiceAnim then
		self._recordVoiceAnim = new(VoiceRecordAnim,"voiceRecordTip")
		self._recordVoiceAnim:setPerFrameTime(0.4)
		self._recordVoiceAnim:play(-1)

		local config = GlobalDataManager.getInstance().fmVoiceConfig
		self._recordTimeOutAnim = self._recordVoiceAnim:addPropTranslate(0, kAnimNormal, config.maxLength*1000, 0, 0, 0, 0, 0);
		self._recordTimeOutAnim:setEvent(self, self.onRecordTimeOut)
		self._recordTimeOutAnim:setDebugName("recordTimeOutAnim")
		self._recordVoiceAnim:showRecordState()
		local x,y = self.voiceBtn:getPos()
		self._recordVoiceAnim:setPos(x - 95 , y-210)
		self.nodePopu:addChild(self._recordVoiceAnim);
	end
end
--关闭录音提示
function FriendMatchRoomScene:hideRecordVoiceAnim( )
	DebugLog("hideRecordVoiceAnim")
	if self._recordVoiceAnim then
		DebugLog("hideRecordVoiceAnim...")
		self._recordVoiceAnim:stop()
		self._recordVoiceAnim:removeFromSuper()
		self._recordVoiceAnim = nil
	end
end


function FriendMatchRoomScene:onRecordTimeOut( )
	-- body
	if self._recordTimeOutAnim then
		delete(self._recordTimeOutAnim)
		self._recordTimeOutAnim = nil
	end

	local isCancel = false
	if self._recordVoiceAnim then
		isCancel = self._recordVoiceAnim:isCancel()
    end
	self:stopRecord(isCancel)

end


function FriendMatchRoomScene:updateVoiceTip( seatNum )
	--showVoice
	if seatNum >= kSeatRight and seatNum <= kSeatLeft then
		local seat = self.seatManager:getSeatByLocalSeatID(seatNum,self);
		if seat then
			local item = self.m_voiceData:getTopItem(seatNum)
			seat:showVoice(item,self.m_voiceData:getVoiceNumBySeat(seatNum))
		end
	end
end

-- function FriendMatchRoomScene:hidePlayVoiceAnim( filename,seatNum, time )
-- 	-- body
-- end

-- function FriendMatchRoomScene:onPlayVoiceAction()
-- 	-- body
-- end

--添加一条语音消息记录
function FriendMatchRoomScene:addVoiceMsg( filename, senderId , tid, playTime )
	--addchatlog
	local logInfo = {}
	logInfo.mid      = senderId
	logInfo.filename = filename
	logInfo.type     = "voice"
	logInfo.seconds  = playTime
	self:addChatLog(logInfo)

	-- body
	DebugLog("FriendMatchRoomScene:addVoiceMsg:"..filename)
	local pm = PlayerManager.getInstance()
	if senderId == pm:myself().mid then
		return
	end
	local seatNum = pm:getLocalSeatIdByMid(senderId or 0)
	self.m_voiceData:pushItem(seatNum, filename,playTime)
	self:updateVoiceTip(seatNum)
end



--开始录音
function FriendMatchRoomScene:startRecord( )
	local config = GlobalDataManager.getInstance().fmVoiceConfig
	if self._stopRecordTime then
		if os.time() - self._stopRecordTime <= config.interval then
			Banner.getInstance():showMsg("亲，不要那么急嘛！")
			return
		end
	end

	--停止正在播放的声音
	self:stopPlay()--调原生停止播放声音
	--动画表现停止
	self:stopAllPlayVoiceOnDesk()
    if self.chatWnd then
    	self.chatWnd:stopAllPlayVoice()
    end

	if not self._recording then
		self:showRecordVoiceAnim()
		-- body
		native_to_java(kStartRecordVoice)
		self._recording = true

		self:pauseGameSound()
	end
	--
end
--停止录音
function FriendMatchRoomScene:stopRecord(isCancel)
	if not isCancel then 
		umengStatics_lua(Umeng_RoomVoiceSuccess)
	end
	if self._recordTimeOutAnim then
		delete(self._recordTimeOutAnim)
		self._recordTimeOutAnim = nil
	end

	if self._recording then
		self._stopRecordTime = os.time()
	    local tbl = {}
	    tbl.isCancel = isCancel
		native_to_java(kStopRecordVoice,json.encode(tbl))

		self:hideRecordVoiceAnim()
		self._recording = false

		self:resumeGameSound()
		if isPlatform_Win32() then --win32模拟发送语音消息
			local param = {}
			param.uid   = PlayerManager.getInstance():myself().mid
			param.tid   = self._fmrData.tid
			param.playTime = 3
			param.filename = System.getStorageOuterRoot().."voice.amr"--"E:\\Mahjong_\\SCMahjong_Lua\\SCMahjong_Lua_1.6\\Resource\\Outer\\voice.amr"
			self.m_voiceManager:sendVoiceMsg(param)
		end
	end
end
--[[
native_stopRecordVoice:
{
	"voiceDuration":18682,
	"fileSize":29184,
	"filePath":"\/storage\/sdcard0\/.com.boyaa.scmj\/im\/data\/voice_chat_temp\/5841CB25F2CD465FB621386BC76A83AD.amr"
}
  ]]
--停止录音native层 回调
function FriendMatchRoomScene:stopRecordCallback( param )
	DebugLog("FriendMatchRoomScene:stopRecordCallback")
	DebugLog(param)
	if self._recording then
		self._recording = false
		self:hideRecordVoiceAnim()

		self:resumeGameSound()
	end

	-- body
	if param and self.m_voiceManager then
		local info = {}--tid,uid,filename
		info.filename = param.filePath
		info.tid      = self._fmrData.tid
		info.uid      = PlayerManager.getInstance():myself().mid
		info.playTime = tonumber(param.voiceDuration or 0)/1000
		info.playTime = math.ceil(info.playTime)
		if info.playTime == 0 then
			info.playTime = 1
		end
		self.m_voiceManager:sendVoiceMsg(info)
	end
end

--开始播放
function FriendMatchRoomScene:startPlay( filename, seatNum )

    local tbl = {}
    tbl.filePath = filename or ""
    native_to_java(kStartPlayVoice, json.encode(tbl))
    self.m_voiceData:startPlayVoice(seatNum)
    self:pauseGameSound()
    ---停止之前播放中的
    local seatList = self.seatManager:getSeatList()
    for k,v in pairs(seatList) do
    	if not seatNum or k ~= seatNum then
    		self:stopPlayVoiceOnDesk(v:getVoice())
    	end
    end

    if self.chatWnd then
    	self.chatWnd:stopAllPlayVoice()
    end


    if isPlatform_Win32() then --win32模拟回调
    	Clock.instance():schedule_once(function()
	        self:stopPlayCallback()
    	end,3.0)
    end
end
--停止播放
function FriendMatchRoomScene:stopPlay( ... )
	native_to_java(kStopPlayVoice)
end

--[[
播放结束的回调：
key：kStopPlayVoice
data: native_stopPlayVoice:{"msg":"停止播放录音","result":3}
result:1为正常结束，2为读写文件异常，3为手动停止播放
]]
--播放完native层 回调
function FriendMatchRoomScene:stopPlayCallback( param )

	self:stopAllPlayVoiceOnDesk()

    if self.chatWnd then
    	self.chatWnd:stopAllPlayVoice()
    end
    self:resumeGameSound()
end


---停止桌边上的语音播放  (非聊天记录)
function FriendMatchRoomScene:stopPlayVoiceOnDesk( voiceAnim )
    if voiceAnim and voiceAnim:isPlaying() then
        voiceAnim:stop()
     	self.m_voiceData:stopPlayVoice(voiceAnim._seatId)
     	self:updateVoiceTip(voiceAnim._seatId)
    end
end



function FriendMatchRoomScene:stopAllPlayVoiceOnDesk( )
    local seatList = self.seatManager:getSeatList()
    for k,v in pairs(seatList) do
    	self:stopPlayVoiceOnDesk(v:getVoice())
    end
end
