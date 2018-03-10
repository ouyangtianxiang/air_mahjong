
require("Animation/ChangeScoreAnim");
require("MahjongRoom/GameResult/GameResultWindowMatch");
require("MahjongRoom/GameResult/CertificateWindow");
require("MahjongRoom/MatchRoomSceneRank");
require("MahjongRoom/UserInfo/RoomUserInfo");
require("MahjongRoom/RoomScene");
require("MahjongRoom/MatchRoom/MatchRankItem");


-- GameConstant.matchStatus.matchStage : = 1:报名阶段 2:预赛阶段 3:淘汰赛阶段 4:决赛阶段 5:比赛结束 8:定时赛预赛阶段 9:定时赛预赛结束排名阶段

MatchRoomScene = class(RoomScene);

MatchRoomScene.ctor = function(self, viewConfig, state, data, matchInfo)
	DebugLog("MatchRoomScene ctor");

	-----
	FriendDataManager.getInstance():addListener(self,self.friendDataControlled);

	self.pm = PlayerManager.getInstance();
	self.beforeServerOutCardValue = 0;
	self.roomData = RoomData.getInstance(); -- 房间数据
	self.lastStatu = StateMachine.getInstance().m_lastState; -- 进入房间之前的上一个状态
	self.myself = PlayerManager.getInstance():myself();
	-- self.m_event = EventDispatcher.getInstance():getUserEvent();
	GameConstant.isInRoom = true;
	self.roomData:initHuTypeInfo();
	self.isInSocketRoom = true;

	self.m_matchData = data;
	self.m_matchInfo = matchInfo;

	self:initSocketEventFuncMap();
	self:initHttpRequestsCallBackFuncMap();

	-----
	MatchRoomScene_instance = self;
	
	self.matchTipNode = new(Node)   --比赛提示横条
	self.m_root:addChild(self.matchTipNode);
	self.nodeRank = new(MatchRoomSceneRank);

	self.matchTipNode:setAlign(kAlignCenter);
	self.matchTipNode:setLevel(100)
	self.certificateWnd = nil; -- 奖状窗口

    --积分榜按钮
    self.m_btn_rank = publ_getItemFromTree(self.m_root,{"btn_rank"});
    if self.m_btn_rank then
        self.m_btn_rank:setVisible(true);
        self.m_btn_rank:setOnClick(self, function(self)
            DebugLog("btn click rank");
            self:create_match_rank();
        end);
    end


	self:initView( true );
	self:initCmdConfig();

	self.nodeHandCard:addChild(self.nodeRank);	
		--结算界面的破产提示
	local bankruptW, bankruptH = 134, 100;
	-- 比赛场
	for i = 0, 3 do
		local x, y = self.mahjongManager.mahjongFrame:getAvatarPos(i);
		GameResultWindowMatch.bankraptcyCoord[i][1] = x - 15;
		GameResultWindowMatch.bankraptcyCoord[i][2] = y - bankruptH + 110;
	end


end

--创建积分榜层
MatchRoomScene.create_match_rank = function (self)
    DebugLog("[MatchRoomScene]:create_match_rank");
    if self.m_rank_layer then
       self.m_rank_layer:removeFromSuper();
       self.m_rank_layer = nil;
    end

    self.m_rank_layer = new(Node);
    self.m_rank_layer:setLevel(1000);
    self.m_rank_layer:setAlign(kAlignTopLeft);
    self.m_rank_layer:setSize(1280, 720);
    self.m_root:addChild(self.m_rank_layer);

    self.m_rank_layer:setEventTouch(self, function(self, finger_action, x, y, drawing_id_first, drawing_id_current)
		if kFingerDown == finger_action then
		elseif kFingerUp == finger_action then
		    self.m_rank_layer:removeFromSuper();
            self.m_rank_layer = nil;	
            self:stop_timer_get_rank();
		end
	end );

    local bg = new(Image, "match_rank/bg.png");
    if bg then
        bg:setAlign(kAlignTopRight);
        bg:setPos(137, 156);
        self.m_rank_layer:addChild(bg);
        local t_title = new(Text, "积分排行榜", 0, 0, kAlignCenter, "", 32, 0x89 , 0x4e , 0x32)
        t_title:setPos(0, 30);
        t_title:setAlign(kAlignTop);
        bg:addChild(t_title); 
    end
    local listview = new(ListView);
    listview:setAlign(kAlignTop);
    listview:setSize(466, 408);
    listview:setPos(0, 80);
    bg:addChild(listview);
    listview:setAdapter(nil); 
    self.m_rank_layer.listview = listview;

    --出错提示
    local t_tip = new(Text, "网络错误", 0, 0, kAlignCenter, "", 26, 0xff , 0xff , 0xff)
    t_tip:setAlign(kAlignCenter);
    t_tip:setVisible(false);
    bg:addChild(t_tip);
    self.m_rank_layer.error_tip = t_tip;

    ---向服务器发送消息获取排行榜信息
    self:send_msg_update_rank(1);
    --启动定时器-向服务器发送消息获取排行榜信息
    self:start_timer_get_rank();

end

--关闭定时器
MatchRoomScene.stop_timer_get_rank = function (self)
    DebugLog("[MatchRoomScene]:stop_timer_get_rank");
    if self.rank_timer then
        self.rank_timer:cancel();
        self.rank_timer = nil;
    end
end

--启动定时器-向服务器发送消息获取排行榜信息
MatchRoomScene.start_timer_get_rank = function (self)
    DebugLog("[MatchRoomScene]:start_timer_get_rank");    
    self:stop_timer_get_rank();

    --获取该比赛的排行榜定时器的刷新间隔
    local delay = self:get_delay_rank_update();
    self.rank_timer = Clock.instance():schedule(function () 
                           --启动定时器-向服务器发送消息获取排行榜信息
                           self:send_msg_update_rank(2);
                      end, delay);

end

--获取该比赛的排行榜定时器的刷新间隔
MatchRoomScene.get_delay_rank_update = function (self)
    local delay = 30;--未获取到数据的话返回30s
    local matchdata = HallConfigDataManager.getInstance():returnMatchDataByLevel(GameConstant.curRoomLevel);
    if matchdata and matchdata.rank_timer and GameConstant.matchStatus.matchStage then
        if GameConstant.matchStatus.matchStage == GameConstant.match_stage.yusai then
            delay = matchdata.rank_timer.prev or delay;
        elseif GameConstant.matchStatus.matchStage == GameConstant.match_stage.taotai then 
            delay = matchdata.rank_timer.elim or delay;
        elseif GameConstant.matchStatus.matchStage == GameConstant.match_stage.juesai then
            delay = matchdata.rank_timer.final or delay;
        elseif GameConstant.matchStatus.matchStage == GameConstant.match_stage.dingshisai_yusai then
            delay = matchdata.rank_timer.prev or delay;
        elseif GameConstant.matchStatus.matchStage == GameConstant.match_stage.dingshisai_yusai_end then
            delay = matchdata.rank_timer.elim or delay;
        else
            delay = matchdata.rank_timer.prev or delay;
        end 
    end
    DebugLog("[MatchRoomScene]:get_delay_rank_update stage:"..tostring(GameConstant.matchStatus.matchStage).." delay:"..tostring(delay));
    delay = tonumber(delay) or 30;
    return delay;
end

--发送更新排行榜消息
MatchRoomScene.send_msg_update_rank = function (self, flag)
    DebugLog("[MatchRoomScene]:send_msg_update_rank");

    if not GameConstant.matchId then
        DebugLog("GameConstant.matchId is nil");
        return;
    end

    local roomtype, roomlevel = global_get_type_and_level_by_matchid(GameConstant.matchId);

    --发送命令
    local param = {};

    param.level_0 = roomlevel or 0; --重连时为0，这个参数，服务器暂时没用到
    param.param = -1;
    param.cmdRequest = CLIENT_REQ_MATCH_RANK;
    param.uid = PlayerManager.getInstance():myself().mid; 
    param.matchid = GameConstant.matchId; 
    param.flag = flag or 2--1表示玩家主动打开排行榜  2表示客户端定时器请求; 

    SocketSender.getInstance():send( SERVER_MATCHSERVER_CMD, param);
end

--更新排行榜
MatchRoomScene.update_match_rank = function (self)
    DebugLog("[MatchRoomScene]:update_match_rank");
    if not self.m_rank_layer then
        DebugLog("self.m_rank_layer is nil");
        return;
    end
    if not self.m_rank_data then
        DebugLog("self.m_rank_data is nil");
        self.m_rank_layer.error_tip:setVisible(true);
        return;
    end
    self.m_rank_layer.error_tip:setVisible(false);
    --如果没有接收到服务器的排行列表则提示网络错误 by欧阳
    if self.m_rank_data.list and #self.m_rank_data.list < 1 and self.m_rank_layer.error_tip then
        DebugLog("self.m_rank_data.list and #self.m_rank_data.list < 1 and self.m_rank_layer.error_tip ");
        self.m_rank_layer.error_tip:setVisible(true);
        return ;
    end
    
    function rank_sort(s1 , s2)
	    return s1.rank < s2.rank
    end
    if #self.m_rank_data.list > 1 then
        table.sort(self.m_rank_data.list, rank_sort);
    end

    local adapter = new(CacheAdapter, MatchRankItem, self.m_rank_data.list);
    self.m_rank_layer.listview:setAdapter(adapter)

    if self.m_rank_layer.listview:hasScroller() then
        local util_len = 103;
        local tmp_index = 0;
        local list_len = #self.m_rank_data.list;
        for i = 1, list_len do
            if self.m_rank_data.list[i].mid == PlayerManager:getInstance():myself().mid then
                break;
            else
                tmp_index = tmp_index + 1;
            end    
        end
        --如果未上榜矫正到最后4个--当前view最多显示4个
        if list_len <= 4 then
            tmp_index = 0;
        else
            if tmp_index < 4 then
                tmp_index = 0;
            else
                if tmp_index < (list_len-4) then
                    tmp_index = tmp_index - 3;
                else
                    if tmp_index >= list_len then
                        tmp_index = list_len - 4;
                    else
                        tmp_index = tmp_index - 3;
                    end
                end  
            end
        end
        local offset = -(tmp_index*util_len)
        self.m_rank_layer.listview.m_scroller:setOffset(offset);
        DebugLog("offset:"..tostring(offset));
    end
end

MatchRoomScene.showFirstChargeView = function ( self )
--	FirstChargeView.getInstance():show();

--	return 1 == FirstChargeView.getInstance().isOpenFirstChargeView;
end

MatchRoomScene.quickCharge = function ( self )
	umengStatics_lua(kUmengInRoomPayBtn);
	local player = PlayerManager.getInstance():myself();
	local requireMoney = getMatchHallConfigRequireMoneyByLevel(GameConstant.curRoomLevel);



    local param_t = {t = RechargeTip.enum.enter_match, 
                isShow = false, roomlevel = GameConstant.curRoomLevel, 
                money= requireMoney,
                recommend= self:getRecommend(),
                is_check_bankruptcy = false, 
                is_check_giftpack = true,};
	RechargeTip.create(param_t)
end

-- 获取推荐金额
function MatchRoomScene.getRecommend( self )
    DebugLog("MatchRoomScene getRecommend" .. tostring(GameConstant.curRoomLevel));
    
	local matchRoomData = HallConfigDataManager.getInstance():returnMatchDataByLevel(tonumber(GameConstant.curRoomLevel));
	return matchRoomData.recommend or 0;
end

MatchRoomScene.dtor = function(self)
	----
	self:unregisterAllEvent();
    --停止定时器
    self:stop_timer_get_rank();

	FriendDataManager.getInstance():removeListener(self,self.friendDataControlled);
	delete(self.swapCardAnim);
	self.swapCardAnim = nil;
	GameConstant.isInRoom = false;
	GameConstant.getingRoomActivityDetail = false;
	-----

	if self.matchWaitStartOrRankTailTextAnim then
		delete(self.matchWaitStartOrRankTailTextAnim);
		self.matchWaitStartOrRankTailTextAnim = nil;
	end
	if self.tmp_anim then
		delete(self.tmp_anim);
		self.tmp_anim = nil;
	end
	DebugLog("MatchRoomScene dtor");
	MatchRoomScene_instance = nil;
	QuickChatWnd.canSendFaceOrText = true;

end


-- 重连成功
MatchRoomScene.reconnectSuccess = function (self , data)
	self:setIsFreeMatchGame(data.isFreeMatch)
	self:getRoomActivityInfo();  --开始获取金币活动
	self:requireChestStatus();   -- 请求宝箱
	self.beforeServerOutCardValue = 0;
	GlobalDataManager.getInstance():getTuiJianProduct();
	PlayerManager:getInstance():myself().isInGame = true;
	self.reconnectingGameDirect = false;
	self:reconnectDealPlayerInfo(data);
	-----------
	
	RoomData.getInstance().isReconnect = true;
	DebugLog("重连成功");
	self.reconnectRoom = true;
	--self.reconnectFlagShowInfo = false;

	self:changeFrameCount(data.isLiangFanPai and 11 or 14);

	if not GameConstant.isSingleGame then
		local addFanCard = data.addFanCard;
		self:updateAddFan(addFanCard);
		self:createRecconectAddFan();
	end

	self:dealTableInfo(data);
	self:reconnectSetOthersPlayerCards(data.playerInfo);
	self:reconnectSetMineCards(data.selfInfo);
	local player = PlayerManager.getInstance():myself();
	if not player.isHu then
		player.isAi = true;
		self:showOrDisapperTuoguan(true);
		PlayerManager:getInstance():myself().isInGame = true;
		self.mahjongManager:setAllAddFan();
	else
		-- PlayerManager:getInstance():myself().isInGame = false;
		self.mahjongManager:setAllHuAddFan();
	end

	--金币可见
	self:showMoneyExchange(true);
end


function MatchRoomScene:showTableInfo(status, visible)
	if status then 
		self:setTableInfoStatus(status)
	end 
	local left,mid,right
	local wanfa  = RoomData.getInstance().wanfa;
	local result = self:getWanfaStr(wanfa)
	
	if result then 
		left = result[1]
		mid  = result[2]
	end  

	right = (RoomData.getInstance().di or 0).."底"
	self:showWanfaAndDi(visible,left,mid,right)

	--显示排名信息
	local w, h = self.nodeRank:getSize();
	self.nodeRank:setVisible(true);
	self.nodeRank:setAlign(kAlignCenter);
	self.nodeRank:setPos(0, -50 - 130 / 2 - 5 - h / 2);	
end


function MatchRoomScene:setTableInfoStatus( status )
	--status=1  牌局未开始状态  
	--status=2  牌局开始状态
	-- if not status or (status ~= 1 and status ~= 2) then 
	-- 	return 
	-- end 
	assert(status and (status ~= 1 or status ~= 2))

	status = status or 1
	local configMap = {
		{  
		    ["logo"] 		= {0   ,-122,false},
		    ["roomName"]	= {0   , -66,false},
		    ["leftArrow"]   = {133,  105,false},
		    ["rightArrow"]  = {133,  105,false},
		    ["wanfaBg"]     = {  0,   105,false},
		},	
		{  
		    ["logo"] 		= {0   ,-122,false},
		    ["roomName"]	= {0   , -66,true},
		    ["leftArrow"]   = {113, -66,true},
		    ["rightArrow"]  = {113, -66,true},
		    ["wanfaBg"]     = {0   ,   0,false},
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


-- 准备时候，如果服务器判断到金币不足，会返回换桌（因金币不足，换桌会失败，回到大厅）和金币不足的踢人命令。
MatchRoomScene.readyAction = function ( self )
	for k,v in pairs(self.seatManager.seatList) do
		v:changeToWaitStaty();
		if v.seatID == 0 then
			v.isSingleGameFirst = false;
		end
	end
	self:readyActionToServer()
	--self:requestCtrlCmd(RoomController.s_cmds.ready);
	self:clearDesk();
end

MatchRoomScene.showOrHideTimeOutTip = function ( self, bShow, time )
	--TODO nothing
end

-- 准备开始游戏 摇骰 定庄
MatchRoomScene.readyStartGame = function ( self, data )
	self:hideWaitStartOrRankView();-- 比赛准备开始隐藏横条提示
	if self.logoutView then
		popWindowUp(self.logoutView, nil, self.logoutView.bg);
		self.nodePopu:removeChild(self.logoutView, true);
		self.logoutView = nil;
	end
	if RoomData.getInstance().inFetionRoom then
		local mySeat = self.seatManager:getSeatByLocalSeatID(0);
		mySeat.fetionInviteLeft:setVisible(false);
		mySeat.fetionInviteRight:setVisible(false);
	end
	RoomData.getInstance().mineCurGameWinMoney = 0;
	if self.m_inviteRoomWindow then   --邀请好友弹框
		self.m_inviteRoomWindow:hideWnd()
	end
	self:showTableInfo(2,true)

	local seatMgr = self.seatManager;
	seatMgr:changeToWaittingStatu();
	seatMgr:changeToStartGameStatu(true);
	seatMgr:getSeatByLocalSeatID(data,self):setBankSeat();
	ShaiziAnimation.setDelegate(self, data);
	local shaiziNode = ShaiziAnimation.play(RoomCoor.shaizhiAni.x, RoomCoor.shaizhiAni.y, RoomCoor.shaizhiAni.w, RoomCoor.shaizhiAni.h);
	if shaiziNode then
		self.nodeOperation:addChild(shaiziNode);
	end
end

-- 播放碰，杠等动画
MatchRoomScene.playGameAnim = function ( self, animType, seatId, obj, callback )
	local x,y = 0,0;
	x = RoomCoor.gameAnim[animType][seatId][1];
	y = RoomCoor.gameAnim[animType][seatId][2];

	if SpriteConfig.TYPE_GUAFENG == animType then
		local view = new(AnimationWind, {x,y});
		self.nodeOperation:addChild(view);
		view:play();
	elseif SpriteConfig.TYPE_XIAYU == animType then
		local view = new(AnimationRain, {x,y});
		self.nodeOperation:addChild(view);
		view:play();
	elseif SpriteConfig.TYPE_PENG == animType then
		local view = new(AnimationPeng, {x,y});
		self.nodeOperation:addChild(view);
		view:play();
	elseif SpriteConfig.TYPE_FANGPAO == animType then
		local view = new(AnimationFangPao, {x,y}, obj, callback);
		self.nodeOperation:addChild(view);
		view:play();
	elseif SpriteConfig.TYPE_ZIMO == animType then
		local view = new(AnimationZiMo, {x,y}, obj, callback);
		self.nodeOperation:addChild(view);
		view:play();
	elseif SpriteConfig.TYPE_CHADAJIAO == animType then
		local view = new(AnimationDaJiao, {x,y});
		self.nodeOperation:addChild(view);
		view:play();
	elseif SpriteConfig.TYPE_CHAHUAZHU == animType then
		local view = new(AnimationHuaZhu, {x,y});
		self.nodeOperation:addChild(view);
		view:play();
	end


	if SpriteAudioConfig[animType] then
		GameEffect.getInstance():play(SpriteAudioConfig[animType]);
		local sex = PlayerManager.getInstance():getPlayerBySeat(seatId).sex;
		if sex == 0 then
			GameEffect.getInstance():play("m"..SpriteAudioConfig[animType]);  --男声操作音
		else
			GameEffect.getInstance():play("w"..SpriteAudioConfig[animType]);  --女声操作音
		end
	end
end

-- 自己打出的牌和服务器不同，换牌
MatchRoomScene.backendBeforeOutCard = function (self , beforeCard , data)
	self.mahjongManager:backendBeforeOutCard(beforeCard , data.card);
end

MatchRoomScene.setBaseInfoHide = function ( self, bVisible )
	self:getControl(MatchRoomScene.s_controls.baseInfoView):setVisible(bVisible);
end


function MatchRoomScene:showRoomName( )
	self:setRoomName("Room/roomInfo/logo_match.png")
end

MatchRoomScene.hu2 = function ( self, infoTable )
	self:hasHued()
	if RoomData.getInstance().isXueLiu then
		self:huXLCH2(infoTable);
		return;
	end

	-- 移除中心显示的打出牌
	self.mahjongManager:removeBigShowCenterView();
	local fangPaoId, huCard = -1,0;
	local sm = self.seatManager;
	local pm = PlayerManager.getInstance();

	for k,v in pairs(infoTable) do
		local player = pm:getPlayerById(v.mid);
		local huSeatId = player.localSeatId;
		sm.seatList[huSeatId]:huInGame(v.huType);
		if kSeatMine == huSeatId then
			GameEffect.getInstance():play("AUDIO_WIN");
			self.mahjongManager:setAllMahjongFrameDown();
			self:setMineGameFinish();
		end
		-- 清空被抢杠胡的杠牌
		if 1 == v.isQiangGangHu then
			self.mahjongManager:playerQiangGangHu(v.huCard);
		end
		-- 胡牌动画
		if 1 == v.huType then  
			-- self:playGameAnim(SpriteConfig.TYPE_HU, huSeatId);
			huCard = v.huCard;
			for j,n in pairs(v.beHu) do -- 放炮的时候这里只有一个
				fangPaoId = pm:getLocalSeatIdByMid(n.mid);
			end
			--胡，非血流
			if PlayerManager.getInstance():myself().isHu and not RoomData.getInstance().isXueLiu then 
				self:playGameAnim(SpriteConfig.TYPE_FANGPAO, fangPaoId, self, function ( self )
					-- body
					--说明joingameSuc消息还没有到达
					if PlayerManager.getInstance():myself().isHu then
						-- self:clearDeskAndBackToReady();
					end
				end);
			else
				self:playGameAnim(SpriteConfig.TYPE_FANGPAO, fangPaoId);
			end
			
		else

			if PlayerManager.getInstance():myself().isHu and not RoomData.getInstance().isXueLiu then
				self:playGameAnim(SpriteConfig.TYPE_ZIMO, huSeatId, self, function ( self )
					-- body
					--说明joingameSuc消息还没有到达
					if PlayerManager.getInstance():myself().isHu then
						-- self:clearDeskAndBackToReady();
					end
				end);
			else
				self:playGameAnim(SpriteConfig.TYPE_ZIMO, huSeatId);
			end
			
		end
		-- 大番型动画
		local dafanxin = new(DaFanXin, v.paiTypeStr, huSeatId, self.m_root);
		dafanxin:play();
		table.insert(self.dafanxinAnimList, dafanxin);
		-- 设置牌状态
		self.mahjongManager:setInHandCardsWhenHuBySeat(huSeatId);
		self.mahjongManager:setHuCardBySeat(huSeatId, v.huCard , v.huType);

		DebugLog("设置胡牌的人的加番牌图标1")
		self.mahjongManager:setAddFanHuForSeat(huSeatId);

		if PlayerManager.getInstance():getHuPlayerNum() > 2 then
			local changeRoom = self.seatManager:getSeatByLocalSeatID( kSeatMine ).changeRoom;
			local detailBtn = self.seatManager:getSeatByLocalSeatID( kSeatMine ).detailBtn;
			local continueBtn = self.seatManager:getSeatByLocalSeatID( kSeatMine ).continueBtn; 
			if changeRoom then
				changeRoom:setVisible( false );
			end

			if detailBtn then
				detailBtn:setVisible( false );
			end

			if continueBtn then
				continueBtn:setVisible( false );
			end
		end
	end

	if self.reconnectRoom and fangPaoId >= 0 then
		self.reconnectRoom = false;
		local seatId = fangPaoId;
		self.mahjongManager:clearACardshowDiscardOnTable(seatId , huCard);
	end
	self.reconnectRoom = false;
end

MatchRoomScene.showMoneyExchange = function ( self, bSHow )
	if bSHow then
		RoomScene.broadcastUpdateMoney(self)
		--self:getControl(MatchRoomScene.s_controls.mt):setText("" .. trunNumberIntoThreeOneFormWithInt(PlayerManager.getInstance():myself().money or "", true));
		self:getControl(MatchRoomScene.s_controls.mt):setVisible(true);
		self:getControl(MatchRoomScene.s_controls.jsmoneyBg):setVisible(true);
	else
		self:getControl(MatchRoomScene.s_controls.mt):setVisible(false);
		self:getControl(MatchRoomScene.s_controls.jsmoneyBg):setVisible(false);
	end

	for k,v in pairs(self.seatManager.seatList) do
		local p = PlayerManager.getInstance():getPlayerBySeat(k);
		if p then
			v:setMatchScore(p.matchScore);
		    v:setMatchScoreVisible(bSHow);
		end
	end
end

MatchRoomScene.gameOver2 = function ( self, data )
	self.reconnectRoom = false;
	GameEffect.getInstance():stop();
	self.mahjongManager:setAllMahjongFrameDown();
	self:dealGameOverInHandCards2(data.playerList);
	if self.outCardTimer then
		self.outCardTimer:hide();
	end
	if self.operationView then
		self.operationView:hideOperation();
	end
	local sm = self.seatManager;
	sm:gameFinish();

	self.mahjongManager:showBigCardCenterDiscard();
	-- 移除中心显示的打出牌
	self.mahjongManager:removeBigShowCenterView();

	self:showOrDisapperTuoguan(false);
	if self.leftCardNumText then
		self.leftCardNumText:setVisible(false);
		self.leftCardNumStatic:setVisible(false);
	end

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
			RoomData.getInstance().mineCurGameWinMoney = v.turnMoney;
			self:caluMoneyExchange( 0 );
		end
	end

	-- 显示暗杠的牌
	self.mahjongManager:showAnGangMahjongWhenGameOver();

	self:deleteLittleResultDetailView();
	if self.resultView then
		self.nodePopu:removeChild(self.resultView, true);
		self.resultView = nil;
	end
	-- 先把界面创建出来，延迟显示
	self.resultView = new(GameResultWindowMatch);
	self.resultView:parseDataAndShowInitinfo( data, true );
	-- self.resultView:setContinueCallback(self, function ( self )
	-- 	self:continueBtnFun();
	-- end);
	self.resultView:setCallbackClose(self, function ( self )
		self.nodePopu:removeChild(self.resultView, true);
		self.resultView = nil;
        --大奖赛且预赛阶段
        if GameConstant.matchStatus and GameConstant.matchStatus.matchStage == GameConstant.match_stage.dingshisai_yusai
           and GameConstant.matchStatus.matchType == GameConstant.matchTypeConfig.award then
		    local seat = self.seatManager:getSeatByLocalSeatID(kSeatMine,self);
            seat:showContinueBtn1();
        end
	end);
	self.nodePopu:addChild(self.resultView);

	delete(self.showResultAnim);
	self.showResultAnim = nil;
	self.showResultAnim = new(AnimInt, kAnimNormal,0,1,2000,0);
	self.showResultAnim:setDebugName("MatchRoomScene|self.showResultAnim");
	self.showResultAnim:setEvent(self, function ( self )
		delete(self.showResultAnim);
		self.showResultAnim = nil;
		for k,v in pairs(self.seatManager.seatList) do

			local p = PlayerManager.getInstance():getPlayerBySeat(k);
			if p then
			    v:setReadyStatu(p.isReady);
			end
		end
		self.resultView:show();
		self:hideReadyBtn();
		TeachManager.getInstance():hide();
		
	end);

	-- --显示金币雨
	-- --播放掉金币动画
	-- if self.resultView:getResultMoney() > 0 then
	-- 	showGoldDropAnimation();
	-- end

	if GameConstant.platformType ~= PlatformConfig.platformContest then 
		-- 游戏结束时判断一次金币数，如果不足则显示充值界面
		self:judgeMoneyAndShowChargeWnd();
	end
end

MatchRoomScene.deleteLittleResultDetailView = function ( self )
	if self.littleResultDetailView then
		self.littleResultDetailView:hideWnd();
		self.littleResultDetailView = nil;
	end	
end


-- 预赛提前胡显示结算
MatchRoomScene.showAdvanceResultWin = function ( self, data )
	GameEffect.getInstance():stop();
	self.mahjongManager:setAllMahjongFrameDown();
	if self.outCardTimer then
		self.outCardTimer:hide();
	end
	if self.operationView then
		self.operationView:hideOperation();
	end

	self.mahjongManager:showBigCardCenterDiscard();
	-- 移除中心显示的打出牌
	self.mahjongManager:removeBigShowCenterView();

	self:showOrDisapperTuoguan(false);
	if self.leftCardNumText then
		self.leftCardNumText:setVisible(false);
		self.leftCardNumStatic:setVisible(false);
	end
	-- 显示暗杠的牌
	self.mahjongManager:showAnGangMahjongWhenGameOver();

	-- 先把界面创建出来，延迟显示
	self.resultView = new(GameResultWindowMatch);
	self.nodePopu:addChild(self.resultView);

	delete(self.showAdvanceResultAnim);
	self.showAdvanceResultAnim = nil;
	self.showAdvanceResultAnim = new(AnimInt, kAnimNormal,0,1,3000,0);
	self.showAdvanceResultAnim:setDebugName("MatchRoomScene|self.showAdvanceResultAnim");
	self.showAdvanceResultAnim:setEvent(self, function ( self )
		delete(self.showAdvanceResultAnim);
		self.showAdvanceResultAnim = nil;
		if self.resultView then
			self.resultView:showAdvanceResultWindow(data);
		end
	end);
end

MatchRoomScene.showTimeGameLogoutWnd = function ( self, str1, str2, str3 )
    if self.logoutView then
        DebugLog("ttt logoutView show")
        if self.logoutView:getVisible() then
            popWindowUp(self.logoutView, nil, self.logoutView.bg);
        else
            self.logoutView:show(str1, str2, str3);
        end
    else
        require("MatchApply/MatchLogoutView");
        DebugLog("ttt logoutView create");
        DebugLog(str1)
        DebugLog(str2)
        DebugLog(str3)
        self.logoutView = new(MatchLogoutView, self, str1, str2, str3);
        self.nodePopu:addChild(self.logoutView);
    end
end


-- Seat 函数
function MatchRoomScene.showPlayerInfoBySeat(self , seatID)
	DebugLog("MatchRoomScene.showPlayerInfoBySeat")
	local player = PlayerManager.getInstance():getPlayerBySeat(seatID);
	if player then
		if not self.roomUserInfo then
			self.roomUserInfo = new(RoomUserInfo , player , self.nodePopu, true);
		else
			self.roomUserInfo:updateUserInfo(player);
		end

		self.roomUserInfo:setPropCanUseMoney( self:getPropCanUseMoney() );
	end
end


MatchRoomScene.againBtnFun = function( self )
	-- 客户端判断到金币不足，显示金币购买弹窗
	if not self:judgeMoneyAndShowChargeWnd() 
		and GameConstant.platformConfig ~= PlatformConfig.platformContest then 
		return;
	end
	self:readyAction();
	self:removeResultViewNode();
end

-- 普通场一局结束
MatchRoomScene.gameOver = function ( self, data )
    DebugLog("MatchRoomScene.gameOver");

	self.reconnectRoom = false;
	GameEffect.getInstance():stop();
	self.mahjongManager:setAllMahjongFrameDown();
	self:dealGameOverInHandCards(data.resuleInfoList);
	if self.outCardTimer then
		self.outCardTimer:hide();
	end
	local isFinalHu = false;
	local sm = self.seatManager;
	for k , v in pairs(data.resuleInfoList) do
		local player = PlayerManager.getInstance():getPlayerById(v.userId);
		if 1 == v.isDaJiao then -- 被查大叫
			self:playGameAnim(SpriteConfig.TYPE_CHADAJIAO, player.localSeatId);
			TeachManager.getInstance():show(TeachManager.CHA_DA_JIAO_TIP);
		end
		if 1 == v.isHuaZhu then -- 被查花猪
			self:playGameAnim(SpriteConfig.TYPE_CHAHUAZHU, player.localSeatId);
			TeachManager.getInstance():show(TeachManager.CHA_DA_JIAO_TIP);
		end
	end
	sm:gameFinish();
		
	self.mahjongManager:showBigCardCenterDiscard();
	-- 移除中心显示的打出牌
	self.mahjongManager:removeBigShowCenterView();
	--设置所有加番的牌图标为有
	self.mahjongManager:setAllHuAddFan();

	self:showOrDisapperTuoguan(false);
	if self.leftCardNumText then
		self.leftCardNumText:setVisible(false);
		self.leftCardNumStatic:setVisible(false);
	end
	
	for k,v in pairs(data.resuleInfoList) do
		if v.userId == PlayerManager.getInstance():myself().mid then
			-- 更新一次本局金币数
			RoomData.getInstance().isReconnect = false;
			RoomData.getInstance().mineCurGameWinMoney = v.turnMoney; -- 直接显示总钱数
			self:caluMoneyExchange( 0 );
		end
	end

	-- 显示暗杠的牌
	self.mahjongManager:showAnGangMahjongWhenGameOver();
	

	-- 先把界面创建出来，延迟显示
	self.resultView = new(GameResultWindowMatch, self);
	self.resultView:parseDataAndShowInitinfo( data );
	self.resultView:setCallbackClose(self, function ( self )
		self:removeResultViewNode();
		self:showReadyBtn();
	end);
	self.resultView:setAgainCallback(self, function ( self )
		self:againBtnFun();
	end);

	-- self.resultView:setContinueCallback(self, function ( self )
	-- 	self:continueBtnFun();
	-- end);

	--设置单机版的联网
	self.resultView:setConfirmCallback("联 网", self, function ( self )
		self:toHall();
		GameConstant.singleToOnline = true;
	end);

	self.nodePopu:addChild(self.resultView);
	self.resultView:hide();
	delete(self.showResultAnim);

	self.showResultAnim = new(AnimInt, kAnimNormal,0,1,1000,0);
	self.showResultAnim:setDebugName("MatchRoomScene|self.showResultAnim");
	self.showResultAnim:setEvent(self, function ( self )
		-- self:showOrHideAgainBtn(true); -- 显示再来一局按钮
		delete(self.showResultAnim);
		self.showResultAnim = nil;
		for k,v in pairs(self.seatManager.seatList) do
			-- v:changeToWaitStaty();
			local p = PlayerManager.getInstance():getPlayerBySeat(k);
			if p then
			    v:setReadyStatu(p.isReady);
			end
		end
		self.resultView:show();
		self:hideReadyBtn();
		TeachManager.getInstance():hide();
		
		--播放掉金币动画
		if self.resultView:getResultMoney() > 0 then
			showGoldDropAnimation();
		end
	end);
end

MatchRoomScene.showReadyBtn = function ( self )
	DebugLog("MatchRoomScene.showReadyBtn")
	local seat = self.seatManager:getSeatByLocalSeatID(kSeatMine,self);
	seat:showReadyBtn()
end
-- 判断玩家钱数，如钱数不足则显示破产弹窗
MatchRoomScene.judgeMoneyAndShowChargeWnd = function ( self )
	if GameConstant.isSingleGame then
		return true;
	end
	local roomNeedMoney = getHallConfigRequireMoneyByLevel(GameConstant.curRoomLevel);
	if not roomNeedMoney or PlayerManager.getInstance():myself().money >= roomNeedMoney then
		return true;
	end
	-- 玩家的钱数小于房间要求的金币数，显示购买弹窗
	self:playerMoneyNoEnough(roomNeedMoney);
	return false;
end

-- 玩家钱数不足
-- requireMoney 要求的钱数
MatchRoomScene.playerMoneyNoEnough = function ( self, requireMoney )
--	if not FirstChargeView.getInstance().m_visible and  self:showFirstChargeView() then
--		return;
--	end 

    local param_t = {t = RechargeTip.enum.enter_match, 
            isShow = true, roomlevel = GameConstant.curRoomLevel, 
            money= requireMoney,
            recommend= self:getRecommend(),
            is_check_bankruptcy = false, 
            is_check_giftpack = false,};
	RechargeTip.create(param_t)
end

MatchRoomScene.clearDesk = function ( self )
	self.mahjongManager:clearData();
	if not PlayerManager.getInstance():myself().isHu then --  自己之前有胡牌的话，在这里清理一次数据
		self:setMineGameFinish();
	end
	RoomData.getInstance():initHuTypeInfo();

	--删除加番
	self:deleteAddFanNode();

	--时钟
	if self.outCardTimer then
		self.outCardTimer:hide();
	end

	if self.leftCardNumText then
		self.leftCardNumText:setVisible(false);
		self.leftCardNumStatic:setVisible(false);
	end

	--删除操作层的节点
	--self.nodeOperation:removeAllChildren();
end

MatchRoomScene.backEvent = function ( self )
    if HallScene_instance then
        return;
    end
	if FirstChargeView.getInstance().m_visible  then
		FirstChargeView.getInstance():hideWnd();
		return;
	end

	-- 如果不在游戏中，才将主动返回大厅的标志置为true
	local myself = PlayerManager:getInstance():myself();
	if not myself.isInGame then
		GameConstant.isBackToHallActivitely = true;
		new_pop_wnd_mgr.get_instance():set_back_to_hall_actively( true ); -- 主动返回大厅标记
	end
	
	
	--关闭对话框
	if self.chatWnd and self.chatWnd:getVisible() then
		self.chatWnd:hide();
		return;
	end
	
	--关闭设置框
	if self.settingWnd and self.settingWnd:getVisible() then
		self.settingWnd:hideWnd();
		return;
	end

	--关闭个人信息框
	local seatMgr = self.seatManager;
	for k, v in pairs(seatMgr.seatList) do
		if v.userInfoWindow and v.userInfoWindow.showing then
			delete(v.userInfoWindow);
			v.userInfoWindow = nil;
			return;
		end
	end
	
	--DebugLog("roomUserInfo? : "..tostring(self.roomUserInfo) .. " visible:" ..tostring(self.roomUserInfo:getVisible()))
	if self.roomUserInfo and self.roomUserInfo:getVisible() then
		self.roomUserInfo:hide();
		return true;
	end
	
	if self.chestPopWnd and self.chestPopWnd:getVisible() then
		self.chestPopWnd:hideHandle();
		return true;
	end

	if self.certificateWnd and self.certificateWnd:getVisible() then 
		local sw = self.certificateWnd.shareWindow
		if sw then 
			sw:exitAction()
			return true;
		end 
	end 


	if self.shareWindow and self.shareWindow:getVisible() then 
		self.shareWindow:exitAction()
		return true;
	end 

	if self.broadcastPopWin and self.broadcastPopWin:getVisible() then 
		self.broadcastPopWin:hide()
		return true;
	end 	
	--退出房间
	self:exitGameRequire()
	--self:requestCtrlCmd(RoomController.s_cmds.exitGame);
end

MatchRoomScene.createAddFan = function(self)
	if GameConstant.isSingleGame then
		return;
	end
end

MatchRoomScene.showChestAwardTip = function ( self, str )
	AnimationAwardTips.load(str, true);
end

-- 非决赛清桌
MatchRoomScene.removeResultViewCleanDesk = function ( self )
	self:removeResultViewNode();
	self:clearDeskAndBackToReady();
end

-- 决赛清桌
MatchRoomScene.removeResultViewCleanCards = function ( self )
	self:removeResultViewNode();

	for k,v in pairs(self.seatManager.seatList) do
		v:changeToWaitStaty();
	end

	self:clearDesk();
	--比赛不出现准备按钮
	self:hideReadyBtn();
end


MatchRoomScene.removeResultViewNode = function ( self )
	if self.resultView then
		delete(self.showResultAnim);
		self.showResultAnim = nil;
		self.resultView:removeFromSuper();
		self.resultView = nil;
	end
end

--清掉其他玩家,保留个人信息，回到准备界面
MatchRoomScene.clearDeskAndBackToReady = function ( self )
	PlayerManager.getInstance():removeOtherPlay();

	for k,v in pairs(self.seatManager.seatList) do
		v:changeToWaitStaty();
		if v.seatID ~= kSeatMine then
			v:clearData();
		end
	end
	self:clearDesk();
	--比赛不出现准备按钮
	self:hideReadyBtn();
end

-- 比赛奖状窗口
MatchRoomScene.showCertificateWindow = function ( self,data )
    DebugLog("[MatchRoomScene]:showCertificateWindow");

	BaseInfoManager.getInstance():refreshCards();
	GlobalDataManager.getInstance():updateScene();
    local data = {name = data.matchName, rank = data.rank, awardString = data.awardString, is_large_award = data.is_large_award};
	self.certificateWnd = new(CertificateWindow, data);
	self.certificateWnd:show();
end

MatchRoomScene.delayQuitPopWin = function ( self, data )
	if self.resultView then
		if self.tmp_anim then
			delete(self.tmp_anim);
			self.tmp_anim = nil;
		end
		self.tmp_anim = new(AnimInt,kAnimRepeat,-1,-1,9000,-1);
		self.tmp_anim:setDebugName("MatchRoomScene|self.tmp_anim");
		self.tmp_anim:setEvent(self, function ( self )
			delete(self.tmp_anim);
			self.tmp_anim = nil;
			self:showQuitPopWin(data);
		end);
	else
		self:showQuitPopWin(data);
	end	
end

MatchRoomScene.showWaitStartOrRankView = function ( self, str )
	if self.matchWaitStartOrRankTailTextAnim then
		delete(self.matchWaitStartOrRankTailTextAnim);
		self.matchWaitStartOrRankTailTextAnim = nil;
	end
	if self.matchWaitStartOrRankTailText then
		self.matchWaitStartOrRankView:removeChild(self.matchWaitStartOrRankTailText,true);
	end

	if self.matchWaitStartOrRankText then
		self.matchWaitStartOrRankView:removeChild(self.matchWaitStartOrRankText,true);
	end

	if self.matchWaitStartOrRankView then
		local _, viewH = self.matchWaitStartOrRankView:getSize();
		self.matchWaitStartOrRankText = UICreator.createText(str,0,0,0,viewH,kAlignCenter,28,150,40,40);
		self.matchWaitStartOrRankView:addChild(self.matchWaitStartOrRankText);
		self.matchWaitStartOrRankText:setAlign(kAlignCenter);
		self:addAnim();
		self.matchWaitStartOrRankView:setVisible(true);
		return;
	end

	self.matchWaitStartOrRankView = UICreator.createImg("Commonx/coinBanner.png");
	self.matchTipNode:addChild(self.matchWaitStartOrRankView);
	self.matchWaitStartOrRankView:setAlign(kAlignCenter);
	local _, viewH = self.matchWaitStartOrRankView:getSize();
	self.matchWaitStartOrRankText = UICreator.createText(str,0,0,0,viewH,kAlignCenter,28,150,40,40);
	self.matchWaitStartOrRankView:addChild(self.matchWaitStartOrRankText);
	self.matchWaitStartOrRankText:setAlign(kAlignCenter);
	self:addAnim();
end

MatchRoomScene.addAnim = function ( self )
	local w, viewH = self.matchWaitStartOrRankText:getSize();

	local tmp_i = 0;
	self.matchWaitStartOrRankTailText = UICreator.createText("",0,0,40,viewH,kAlignLeft,28,150,40,40);
	local w1, _ = self.matchWaitStartOrRankTailText:getSize();
	self.matchWaitStartOrRankView:addChild(self.matchWaitStartOrRankTailText);
	self.matchWaitStartOrRankTailText:setAlign(kAlignCenter);
	self.matchWaitStartOrRankTailText:setPos(w/2+w1/2, 0);
	self.matchWaitStartOrRankTailTextAnim = new(AnimInt, kAnimRepeat, 0, 1, 500, 0);
	self.matchWaitStartOrRankTailTextAnim:setDebugName("MatchRoomScene|self.matchWaitStartOrRankTailTextAnim");
	self.matchWaitStartOrRankTailTextAnim:setEvent(self, function ( self )
		
		tmp_i = math.mod(tmp_i,4);
		if  0 == tmp_i then
			self.matchWaitStartOrRankTailText:setText("");
		elseif 1 == tmp_i then
			self.matchWaitStartOrRankTailText:setText(".");
		elseif 2 == tmp_i then
			self.matchWaitStartOrRankTailText:setText("..");
		else
			self.matchWaitStartOrRankTailText:setText("...");
		end
		tmp_i = tmp_i + 1;
	end);
end

MatchRoomScene.hideWaitStartOrRankView = function ( self )
	if self.matchWaitStartOrRankView then
		self.matchWaitStartOrRankView:setVisible(false);
	end
end



MatchRoomScene.updateMatchRankView = function (self, data)
	local str = tostring(data.text);
	self:showWaitStartOrRankView(str);
end



MatchRoomScene.broadcastUpdateMoney = function ( self )
	--更新自己金币
	RoomScene.broadcastUpdateMoney(self)
	--self:getControl(MatchRoomScene.s_controls.mt):setText(trunNumberIntoThreeOneFormWithInt(PlayerManager.getInstance():myself().money or "", true));
	--更新玩家积分
	for i =0, 3 do
		player = PlayerManager.getInstance():getPlayerBySeat(i);
		if player then
			self.seatManager:getSeatByLocalSeatID(player.localSeatId):setMatchScore(player.matchScore);
		end
	end
	
end

MatchRoomScene.updateMatchInfo = function ( self, matchInfo )
DebugLog("ttt MatchRoomScene.updateMatchInfo")
	self.nodeRank:setMatchInfo(matchInfo);
end


MatchRoomScene.nativeCallEvent = function ( self, param, data )
	self.super.nativeCallEvent( self, param, data );
	DebugLog( "MatchRoomScene.callEvent param = "..param );
	if kSaveCertificateImg == param then
		DebugLog( "show certificate window hided buttons" );
		if self.certificateWnd then
			self.certificateWnd:share( data );
		else
			DebugLog( "certificate window is nil" );
		end
	end
end

-----

-- 重连进房间
MatchRoomScene.reProcessLoginRoom = function ( self )
	local param = {};
	local roomData  = RoomData.getInstance();
	local myself = PlayerManager.getInstance():myself();
	local uesrInfo  = myself:getUserData();

	if not roomData.roomId or not roomData.matchId then
		Banner.getInstance():showMsg("进入房间失败！");
		self:exitGame();
		return;
	end


	if not SocketManager.m_isRoomSocketOpen then
		self:exitGame();
		return; 
	end

	local param     = {};
	param.tid       = roomData.roomId;
	param.playerId  = myself.mid;
	param.matchId   = roomData.matchId;
	param.serverId  = tonumber(roomData.serverId);
	param.key       = myself.mtkey;
	param.api       = myself.api;
	param.version   = GameConstant.Version;

	param.userInfo  = json.encode(uesrInfo);

	GameConstant.matchId = param.matchId;
	--发送登陆房间
	SocketSender.getInstance():send(CLIENT_MATCH_LOGIN_REQ, param);
end



-- 登录房间
MatchRoomScene.processLoginRoom = function (self)
	DebugLog("ttt MatchRoomScene.processLoginRoom");
    local param = {};
    local player = PlayerManager.getInstance():myself();
    local uesrInfo = player:getUserData();
    param.level =  GameConstant.curRoomLevel;
    param.matchId = GameConstant.matchId;
    param.mtk = player.mtkey;
    param.userInfo = json.encode(uesrInfo);
    param.api = player.api;
    param.versionName = GameConstant.Version;
    SocketManager.getInstance():sendPack(CLIENT_MATCH_SIGNUP_REQ, param);
end



-- 登录房间成功
MatchRoomScene.joinGameSuccess = function (self , data)

	self:setIsFreeMatchGame(data.isFreeMatch)
	local playerMgr = PlayerManager.getInstance();
	local mySelf = playerMgr:myself();
	mySelf.isReady = true;
	mySelf.isHu    = false;
	self:changeFrameCount( data.isLiangFanPai and 11 or 14 )
	--self:updateView(RoomScene.s_cmds.changeFrameCount, data.isLiangFanPai and 11 or 14);
	self:getRoomActivityInfo();  --开始获取金币活动
	self:requireChestStatus();   -- 请求宝箱
	
	playerMgr:removeOtherPlay(); -- 先移除其他玩家

	for k,v in pairs(self.seatManager.seatList) do --先移除座位
		v:changeToWaitStaty();
		v:clearData();
	end

	if self.resultView then
		self:removeResultViewNode();
	end

	self:clearDesk();
	if 1 == GameConstant.matchChangeTableFlag then 
		GameConstant.matchChangeTableFlag = 0;
		if GameConstant.matchResultStatus.waitingFlag and 0 == GameConstant.matchResultStatus.waitingFlag and 8 == GameConstant.matchStatus.matchStage  then
			self:showWaitStartOrRankView("正在为您配桌");
		elseif GameConstant.matchResultStatus.waitingFlag and 0 == GameConstant.matchResultStatus.waitingFlag and 9 == GameConstant.matchStatus.matchStage then
			local str = "预赛已结束，" .. string.sub(os.date("%X", GameConstant.matchStatus.taoTaiStartTime), 0, 5) .. "系统将排名并确定晋级名单";
			self:showWaitStartOrRankView(str);
		elseif GameConstant.matchResultStatus.waitingFlag and 0 == GameConstant.matchResultStatus.waitingFlag and 4 ~= GameConstant.matchStatus.matchStage and 2 ~= GameConstant.matchStatus.matchType then
			local str = "正在为您排名中";
			self:showWaitStartOrRankView(str);
		end 
	end

	if "" ~= GameConstant.matchName then
		Banner.getInstance():showMsg("恭喜顺利晋级" .. GameConstant.matchName .. "第二轮");
		GameConstant.matchName = "";
	end

	local roomData = RoomData.getInstance();
	roomData:enterRoom(data); -- 初始化进入房间的数据
	if GameConstant.platformType == PlatformConfig.platformMobile then
		if roomData and roomData.tai then
			Banner.getInstance():showMsg("本局游戏将收取"..roomData.tai.."金币的服务费");
		end
	end
	-- 自己的网络座位id一定要先赋值，用于计算其他玩家的本地座位id

	self:showTableInfo(1)
	--self:updateView(RoomScene.s_cmds.showRoomBaseInfo, self.roomData );
	--self:updateView(RoomScene.s_cmds.showChangNameAndPlaytype, self.roomData);
	--self:updateView(RoomScene.s_cmds.roomBaseInfoVisible, true);
	Player.myNetSeat = roomData.mySeatId;
	mySelf.seatId = Player.myNetSeat;
	mySelf.money = roomData.myMoney;
	mySelf.matchScore = roomData.myMatchScore;

	-- mySelf.isReady = false; -- 自己进入房间时是未准备状态

	-- 创建玩家
	for k,v in pairs(data.playerInfo) do -- 游戏玩家数据
		local player = playerMgr:parseNetPlayerData(v, data.inFetionRoom);
		self:playerEnterGame( player )
		--self:updateView(RoomScene.s_cmds.playerEnterGame, player);
	end
	local myself = playerMgr:myself();
	self:playerEnterGame( mySelf )
	--self:updateView(RoomScene.s_cmds.playerEnterGame, myself);

	if self.reconnectingGameDirect then -- 重连的时候刚好牌局结束，重新设置自己的位置
		self.reconnectingGameDirect = false;
		if 2 == GameConstant.matchStatus.matchType then
			PlayerManager:getInstance():myself().isInGame = false; -- 屏蔽此处，不允许点返回
		end
		self:reconnectGameDirectWhenOver( mySelf )
		--self:updateView(RoomScene.s_cmds.reconnectGameDirectWhenOver, myself);
	end
	if GameConstant.isDirtPlayGame then -- 快速进入游戏则直接准备
		GameConstant.isDirtPlayGame = false;
		self:readyActionToServer()
	end
	if not myself.isReady and not self.hasShowTimeOutTip then -- 自己没准备并且没显示准备提示
		if #playerMgr:getReadyPlayerList() == 3 then -- 其他3人已经准备
			self.hasShowTimeOutTip = true;
			if not GameConstant.isSingleGame then
				self:showOrHideTimeOutTip( true, RoomData.getInstance().kickTime )
				--self:updateView(RoomScene.s_cmds.timeOutTip, true, RoomData.getInstance().kickTime);
			end
		end
	end

	--比赛不出现准备按钮
	self:hideReadyBtn();
	--self:updateView(RoomScene.s_cmds.setReadyBtnVisible, false);

	--可以发表情
	QuickChatWnd.canSendFaceOrText = true;
end

MatchRoomScene.resume = function(self)
	DebugLog("MatchRoomScene resume");
	self.super.resume(self);

	-- 进入比赛场就不能退出
	--设置比赛场的时候不进行显示强推界面
	GameConstant.isInApplyWindow = true;

	if self.m_matchData then
		self:joinGameSuccess(self.m_matchData);
		self:updateMatchInfo( self.m_matchInfo )
		--self:updateView(RoomScene.s_cmds.updateMatchInfo, self.m_matchInfo);

		self.m_matchData = nil;
		self.m_matchInfo = nil;
	else

		if 1 == RoomData.getInstance().isInGame then -- 大厅重连进比赛
			self:reProcessLoginRoom();
		else  -- 定时赛/人满赛
			self:processLoginRoom();
		end
	end
end



MatchRoomScene.roomLevelAndName = function ( self, data )
	self.roomData:parseNameAndLevel( data );
	self:setIsFreeMatchGame(data.isFreeMatch)

	self:showTableInfo(nil,true)

	--self:updateView(RoomScene.s_cmds.showRoomBaseInfo, self.roomData);
	--self:updateView(RoomScene.s_cmds.showChangNameAndPlaytype, self.roomData);

	--根据数据获取道具信息
	if not GameConstant.isSingleGame then
		local level = GameConstant.curRoomLevel or 50;

		self:getProp( level );
	end
end

function MatchRoomScene.getProp( self, roomlevel )
	if not roomlevel then
		return;
	end
	--获取道具列表
	local param_data = {};
	param_data.party_id = roomlevel; --GameConstant.curRoomLevel or 50;
	SocketManager.getInstance():sendPack(PHP_CMD_GET_ROOM_PROP_LIST,param_data)
end

-- 退出房间，包括被踢出房间
MatchRoomScene.selfLogoutRoom = function ( self )
	DebugLog("ttt MatchRoomScene.selfLogoutRoom");
	DebugLog("ttt GameConstant.curRoomLevel= " .. GameConstant.curRoomLevel);
	if self.isChangeTableActively then
		self.isChangeTableActively = false;
		local playerMgr = PlayerManager.getInstance():removeOtherPlay();

		for k,v in pairs(self.seatManager.seatList) do
			v:changeToWaitStaty();
			if v.seatID ~= kSeatMine then
				v:clearData();
			end
		end
		self:clearDesk()
		--self:updateView(RoomScene.s_cmds.clearDesk);
		GameConstant.isDirtPlayGame = true;
		self:processLoginRoom();
	else
		self:exitGame();
	end
end

-- 游戏中重新连接了一次大厅socket，處理两种情况：1 游戏中重连 2 不在游戏中退出到大厅
MatchRoomScene.connectSocketSuccess = function ( self, data )
	if 1 == data.isInGame then
		Banner.getInstance():showMsg("游戏重连成功。");
		RoomData.getInstance():setRoomAddr(data);
		for k,v in pairs(self.seatManager.seatList) do
			v:changeToWaitStaty();
			v:clearData();
		end
		self:clearDesk()
		--self:updateView(RoomScene.s_cmds.clearDesk);
		self:reProcessLoginRoom();
		self.reconnectingGameDirect = true; -- 是否是房间内直接重连
	else
		PlayerManager.getInstance():myself().isInGame = false;
		Banner.getInstance():showMsg("网络重连成功。");
		self:exitGame();
	end
end


-- 服务器广播准备开始游戏
MatchRoomScene.readyStartGameServer = function ( self, data )
	--self:playNormalMusicWhenStart()
	
	local localSeat = Player.getLocalSeat(data.bankSeatId); -- 庄家位置
	PlayerManager:getInstance():myself():startGame();
	RoomData.getInstance().isReconnect = false;

	local data = {};
	for i =1, 4 do
		player = PlayerManager.getInstance():getPlayerBySeat(i-1);
		if player then
			table.insert(data, player.mid);
		end
	end
	if RoomData.getInstance().inFetionRoom then
		FriendDataManager.getInstance():requestFetionScore(data);
	end
	self:readyStartGame( localSeat )
	--self:updateView(RoomScene.s_cmds.readyStartGame, localSeat);
end

MatchRoomScene.broadcastHu2 = function ( self, infoTable )
	if not GameConstant.isSingleGame then
		GameConstant.justPlayGame = true;
	end
	GameConstant.needCheckMoney = true;
	local moneyexchange = {}; -- 统计钱数，用于显示动画
	local huMid = nil;
	for k,v in pairs(infoTable.playerList) do
		huMid = v.mid;
		local player = PlayerManager.getInstance():getPlayerById(v.mid);

		if player and kSeatMine == player.localSeatId and not self.roomData.isXueLiu then
			PlayerManager:getInstance():myself().isInGame = false;
		end
		-- 血流用于统计胡牌次数的
		local huTypeInfo = RoomData.getInstance():getHuTypeInfoBySeat(player.localSeatId);
		if 1 == v.huType then
			huTypeInfo.hu = huTypeInfo.hu + 1;
		else
			huTypeInfo.zimo = huTypeInfo.zimo + 1;
		end
		-- 胡牌标志
		player.isHu = true;
		-- 计算赢钱数
		local winMoney = 0;
		if not self.roomData.isXueLiu then -- 非血流成河，计算当前局金币
			winMoney = v.winMoney + v.hjzy; -- 胡牌的钱数
			local turnMoney = player.gfxyMoney + winMoney; -- 当前局总的输赢钱数
			-- player:addMoney(turnMoney); -- 加钱
			-- 计算胜率
			if turnMoney > 0 then
				player.wintimes = player.wintimes + 1;
			elseif turnMoney < 0 then
				player.losetimes = player.losetimes + 1;
			else
				player.drawtimes = player.drawtimes + 1;
			end
		else
			winMoney = v.winMoney + v.hjzy;
		end
		if not moneyexchange[v.mid] then
			moneyexchange[v.mid] = 0;
		end
		moneyexchange[v.mid] = moneyexchange[v.mid] + winMoney;
		-- 计算放炮玩家输的钱
		for j,n in pairs(v.beHu) do
			if not moneyexchange[n.mid] then
				moneyexchange[n.mid] = 0;
			end
			moneyexchange[n.mid] = moneyexchange[n.mid] + n.loseMoney;
			self:showBankruptTips( n.mid, v.mid );
		end
		--更新积分
		if infoTable.matchScoreTable then
			local matchScoreTable = infoTable.matchScoreTable;
			if matchScoreTable[""..v.mid] then
				player:setMatchScore(tonumber(matchScoreTable[""..v.mid].mark));
				-- 显示结算
				if kSeatMine ==  PlayerManager.getInstance():getLocalSeatIdByMid(v.mid) and (tonumber(matchScoreTable.time) > 0) and (2 == GameConstant.matchStatus.matchStage) and not self.roomData.isXueLiu then
					local data = {};
					data.money = player.gfxyMoney + winMoney; -- 血战有提前胡，血流没有
					data.score = tonumber(matchScoreTable[""..v.mid].chgmark);
					data.time = tonumber(matchScoreTable.time);
					self:showAdvanceResultWin(data);		
				elseif kSeatMine ==  PlayerManager.getInstance():getLocalSeatIdByMid(v.mid) and 9 == GameConstant.matchStatus.matchStage and not self.roomData.isXueLiu  then
					Banner.getInstance():showMsg("请等待确定晋级名单");
				end
			end
		end

		--是否为自己胡,是，则不能发表情
		QuickChatWnd.canSendFaceOrText = player.localSeatId ~= kSeatMine;

	end

	for k,v in pairs(moneyexchange) do -- 显示钱动画
		self:showChangMoneyAnim(k,v)
		--self:updateView(RoomScene.s_cmds.showChangMoneyAnim, k, v);
		-- self:showBankruptTips( k, huMid );
	end
	self:hu2( infoTable.playerList )
	--self:updateView(RoomScene.s_cmds.hu2, infoTable.playerList); -- 界面更新

	-- 更新相关
	if PlayerManager.getInstance():myself().isHu and not self.roomData.isXueLiu then 
		if 2 == GameConstant.matchStatus.matchType then
			PlayerManager.getInstance():myself().isInGame = false; -- 屏蔽此处，不允许点返回
		end
		native_to_java(kGameOver);
		if GameConstant.updateFinishButInGame then 
			GameConstant.updateFinishButInGame = false;
			native_to_java(kUpdate);
		end
	end

	self:showUserUpdateAnim( infoTable );
	--self:updateView(RoomScene.s_cmds.showUserUpdateAnim, infoTable);
end

-- 请求退出房间，不一定能成功退出
MatchRoomScene.exitGameRequire = function( self )
	DebugLog("ttt MatchRoomScene.exitGameRequire");
	local myself = PlayerManager:getInstance():myself();
	local score  = 0
	if myself.matchScore <= 0 then 
		score    = GameConstant.matchStatus.jifen
	else 
		score    = myself.matchScore
	end 
	if not myself.isInGame and 8 == GameConstant.matchStatus.matchStage then
        str1 = "本场积分:" .. score .. "  排名:" .. GameConstant.matchStatus.rank;
        str2 = GameConstant.matchStatus.matchName .. "正在进行中，确定要退出吗？";
        str3 = "";
        self:showTimeGameLogoutWnd( str1, str2, str3 );
	elseif not myself.isInGame and 9 == GameConstant.matchStatus.matchStage then
        str1 = "本场积分:" .. score .. "  排名:" .. GameConstant.matchStatus.rank;
        str2 = "请确保" .. string.sub(os.date("%X", GameConstant.matchStatus.taoTaiStartTime), 0, 5) .. "在线且未开始其他游戏，否";
        str3 = "则将视为放弃晋级资格";
        self:showTimeGameLogoutWnd( str1, str2, str3 );
	elseif myself.isInGame then
		Banner.getInstance():showMsg("您还未打完比赛，请打完再离开吧！");
    elseif GameConstant.matchType == GameConstant.matchTypeConfig.playTime then
        Banner.getInstance():showMsg("您还未打完比赛，请打完再离开吧！");
	elseif GameConstant.matchType == GameConstant.matchTypeConfig.award and 4 == GameConstant.matchStatus.matchStage or 3 == GameConstant.matchStatus.matchStage then--决赛阶段
        Banner.getInstance():showMsg("您还未打完比赛，请打完再离开吧！");
	end
end

-- 重连成功处理玩家的信息
MatchRoomScene.reconnectDealPlayerInfo = function (self , data)
	DebugLog("MatchRoomScene.reconnectDealPlayerInfo")
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
	mySelf.money = roomData.myMoney;
	mySelf.matchScore = roomData.myMatchScore;
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
		pi.matchScore = v.matchScore;
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


MatchRoomScene.gameOver2Server = function ( self, data )
	QuickChatWnd.canSendFaceOrText = false;
	if not GameConstant.isSingleGame then
		GameConstant.justPlayGame = true;
	end
	GameConstant.needCheckMoney = true;
	self:deleteAddFanNode( data )
	--self:updateView(RoomScene.s_cmds.deleteAddFan,data); -- 如果是加番玩法，删除加番节点
	
	for k, v in pairs(data.playerList) do
		local player = PlayerManager:getInstance():getPlayerById(v.mid);
		if player then
			player.money = v.totalMoney;
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
			--更新积分
			if data.matchScoreTable then
				local matchScoreTable = data.matchScoreTable;
				if matchScoreTable[""..v.mid] then
					player:setMatchScore(tonumber(matchScoreTable[""..v.mid].mark));
					if kSeatMine ==  PlayerManager.getInstance():getLocalSeatIdByMid(v.mid) and 9 == GameConstant.matchStatus.matchStage then
						local str = "预赛已结束, " .. string.sub(os.date("%X", GameConstant.matchStatus.taoTaiStartTime), 0, 5) ..  "系统将排名并确定晋级名单";
						self:showWaitStartOrRankView(str);
					end
				end
			end
		end
	end
	
	-- 更新界面
	EventDispatcher.getInstance():dispatch(GlobalDataManager.updateSceneEvent); -- 直接更新一次金币
	self:gameOver2(data)
	--self:updateView(RoomScene.s_cmds.gameOver2, data);
	-- GlobalDataManager.getInstance():updateScene();
	for k,v in pairs(PlayerManager:getInstance().playerList) do
		v:gameOver();
	end
	self:showUserUpdateAnim( data )
	--self:updateView(RoomScene.s_cmds.showUserUpdateAnim, data);
end


MatchRoomScene.changeTable = function ( self, data )
	DebugLog("MatchRoomScene changeTable");
	DebugLog("ttt level= " .. GameConstant.curRoomLevel);
	if tonumber(data.result) == 0 then
		self:sendExitCmd( true );
	else
		Banner.getInstance():showMsg("您还不满足换桌的条件哦。");
	end
end

MatchRoomScene.bankruptPush = function ( self, data )
	for k,v in pairs(data) do
		local player = PlayerManager.getInstance():getPlayerById(tonumber(v));
		if player and player:isFirstTimeBankruptInGame() then
			player.hasBankruptInGame = true;
			self:playBankruptAnim(player.localSeatId);
		end
	end
end


-- 比赛的状态信息(积分与钱，是否要等待，比赛阶段等)
MatchRoomScene.matchStatus = function ( self, data )
	DebugLog("ttt MatchRoomScene matchStatus");
	if not data then
		return;
	end
	if SERVER_USERSTATE_MATCH == data.cmdRequest then
		t = GameConstant.matchResultStatus;
		t.level             = data.level;
		t.matchId           = data.matchId;
		t.scoreAndMoneyFlag = data.scoreAndMoneyFlag;
		t.score             = data.score;
		t.waitingFlag       = data.waitingFlag;
		t.matchStage        = data.stage;
		t.playingPeopleNum  = data.playingPeopleNum;
		-- t.playingTableNum   = data.playingTableNum;
		t.rank              = data.rank;
		t.nextStageNum      = data.nextStageNum;
		GameConstant.matchResultStatus = t;

		GameConstant.matchChangeTableFlag = 1;  -- 重新进房间时判断是换桌引起的
		 if 0 < data.scoreAndMoneyFlag then -- 积分够
			PlayerManager.getInstance():myself():setMatchScore(data.score);-- 先胡刷新积分
			self:judgeScoreAndMoney();
		else -- 积分不够，淘汰
			self:delayQuitPopWin(data);
		end
	elseif data.cmdRequest == SERVER_BROADCAST_MATCH_INFO then
		-- if GameConstant.matchStatus.matchType and data.matchType == GameConstant.matchStatus.matchType then -- 区分同时进定时赛和人满赛时，同一类型的比赛才刷新
		if GameConstant.matchType == data.matchType or 0 == GameConstant.matchType then
			DebugLog("ttt 00e true");
			self:updateMatchInfo(data)
			--self:updateView(RoomScene.s_cmds.updateMatchInfo, data);
			self:getRankAndStage(data);
		end
	elseif SERVER_BROADCAST_ENTER_NEXT_STAGE == data.cmdRequest then
		-- 进入下一阶段广播
		self:judgeToNextMatchStage(data);
	elseif SVR_CLI_DINGSHI_PAIMING_RESULT == data.cmdRequest then
        if 1 == data.isTaotai and  data.matchId == GameConstant.matchId then--这里添加的是意外的情况下，服务器发过来这个信息，就谈个msg
            --Banner.getInstance():showMsg("很遗憾," .. data.matchName .. "您被淘汰出局");
            self:showQuitPopWin(data, true);
		elseif 2 == data.matchType and 3 == data.matchStage and PlayerManager:getInstance():myself().isInGame then
			if 1 == data.isTaotai then
				Banner.getInstance():showMsg("很遗憾,您被 " .. data.matchName .. " 淘汰出局");
			end
		elseif 2 == data.matchType and 3 == data.matchStage and not PlayerManager:getInstance():myself().isInGame then
			if 1 == data.isTaotai then
				self:showQuitPopWin(data);
			else
				GameConstant.matchName = data.matchName;
				GameConstant.curRoomLevel = data.level;
    			GameConstant.matchId = data.matchId;
    			PlayerManager:getInstance():myself().isInGame = false;
				self:processLoginRoom();
			end
		end
	elseif SC_TABLE_INFO == data.cmdRequest  then
		self:removeResultViewCleanDesk();
		self:updateMatchRankView(data);
	elseif CLIENT_RENSHU_REQ == data.cmdRequest  then -- 认输返回
		if 1 == data.is_award then
			self:showCertificateWindow(data);
		else
			self:showQuitPopWin(data);
		end
	elseif SERVER_USERSTATE_CHANGE_MATCH == data.cmdRequest  then
		GameConstant.matchResultStatus.waitingFlag = data.changeWaitingFlag;
	elseif SERVER_BROADCAST_MATCH_STATUS == data.cmdRequest  then -- 更新状态
		self:getRankAndStage(data);
		if 9 == GameConstant.matchStatus.matchStage and not PlayerManager.getInstance():myself().isInGame then
			local str = "预赛已结束，" .. string.sub(os.date("%X", GameConstant.matchStatus.taoTaiStartTime), 0, 5) .. "系统将排名并确定晋级名单";
			self:showWaitStartOrRankView(str);
		end
    elseif data.cmdRequest == SERVER_RET_MATCH_RANK then--服务器返回比赛排名信息
--    t.matchid =  socket_read_int(packetId, -1); --玩家请求比赛id
--        t.alive_num = socket_read_int(packetId, -1); --晋级人数,如果小于等于0，展示提示信息  -1表示未找到比赛，可能是服务器挂了，或者比赛结束了
--        t.msg = socket_read_string(packetId);--给前端的提醒信息"	//如果失败给玩家的提示信息
--        t.match_state = socket_read_int(packetId, -1);--请求的比赛的状态
--        t.my_rank = socket_read_int(packetId, -1);  --玩家在该场比赛中的排名
--        t.total_num =  socket_read_int(packetId, -1);--该
        self.m_rank_data = {};
        self.m_rank_data.matchid = data.matchid;
        self.m_rank_data.alive_num = data.alive_num;
        self.m_rank_data.msg = data.msg;
        self.m_rank_data.my_rank = data.my_rank;
        self.m_rank_data.total_num = data.total_num;
        self.m_rank_data.list = {};
        if data.list and type(data.list) == "table" then
            for i = 1, #data.list do
                 local item = {};
                 item.score = data.list[i].j or 0;
                 item.rank = data.list[i].r or 0;
                 item.mid = data.list[i].u or 0;
                 table.insert(self.m_rank_data.list, item);
            end
        end
        
        self:update_match_rank();
	end
end

MatchRoomScene.getRankAndStage = function ( self, data )
	local t = {};
	t.rank            = data.rank;
	t.matchStage      = data.stage;
	t.matchName       = data.matchName;
	t.taoTaiStartTime = data.taoTaiStartTime;
	t.jifen           = data.jifen;
	t.matchType		  = data.matchType;
	GameConstant.matchStatus = t;
end

-- 晋级判断
MatchRoomScene.judgeToNextMatchStage = function ( self, data )
	self:hideWaitStartOrRankView();
	if 1 == data.isTaotai then
		if 1 == data.is_award then
			if  1 == data.tipFlag then
				Banner.getInstance():showMsg("有玩家破产，决赛提前结束并颁奖!");
			end
			self:showCertificateWindow(data);
		elseif 0 == data.is_award then
			GameConstant.matchStatus.rank = data.rank;
			self:delayQuitPopWin(data);
		end
	else
		self:updateMatchInfo(data);
		GameConstant.matchResultStatus.waitingFlag = 0;
	end
end

MatchRoomScene.judgeScoreAndMoney = function ( self )
	if 1 == GameConstant.matchResultStatus.scoreAndMoneyFlag then
		require("MahjongCommon/RechargeTip");
        local param_t = {t = RechargeTip.enum.enter_match, 
                        isShow = true, roomlevel = GameConstant.matchResultStatus.level, 
                        money= requireMoney,
                        matchQuitFlag=true ,
                        recommend= self:getRecommend(),
                        matchType=GameConstant.matchStatus.matchType,
                        is_check_bankruptcy = false, 
                        is_check_giftpack = false,};
	    RechargeTip.create(param_t)
	end
end

-- 获取推荐金额
MatchRoomScene.getRecommend = function( self )
	local matchRoomData = HallConfigDataManager.getInstance():returnMatchDataByLevel(tonumber(GameConstant.curRoomLevel));
	if matchRoomData then
		return matchRoomData.recommend or 0;
	else
		return 0;
	end
end

MatchRoomScene.reconnectWaitToMatch = function ( self, data )
	self:setIsFreeMatchGame(data.isFreeMatch)
	if 1 == GameConstant.matchChangeTableFlag then 
		GameConstant.matchChangeTableFlag = 0;
		if GameConstant.matchResultStatus.waitingFlag and 0 == GameConstant.matchResultStatus.waitingFlag and 4 ~= GameConstant.matchStatus.matchStage then
			local str = "正在为您排名中";
			self:showWaitStartOrRankView(str);
		end 
	end


	local playerMgr = PlayerManager.getInstance();
	local mySelf = playerMgr:myself();
	mySelf.isReady = false;

	playerMgr:removeOtherPlay(); -- 先移除其他玩家

	for k,v in pairs(self.seatManager.seatList) do --先移除座位
		v:changeToWaitStaty();
		v:clearData();
	end
	
	local roomBase = {};

	roomBase.tai = nil;
	roomBase.di = nil;
	roomBase.totalQuan = 0;
	roomBase.mySeatId = 0;
	roomBase.myMoney = data.money;
	roomBase.myMatchScore = data.matchScore;
	roomBase.outCardTimeLimit = nil;
	roomBase.operationTime = nil;
	roomBase.isLiangFanPai = false;
	roomBase.wanfa = 0;

	local roomData = RoomData.getInstance();
	roomData:enterRoom(roomBase); -- 初始化进入房间的数据

	-- 自己的网络座位id一定要先赋值，用于计算其他玩家的本地座位id
	--self:updateView(RoomScene.s_cmds.showRoomBaseInfo, self.roomData );
	--self:updateView(RoomScene.s_cmds.showChangNameAndPlaytype, self.roomData);
	self:showTableInfo(1)
	--self:updateView(RoomScene.s_cmds.roomBaseInfoVisible, true);

	Player.myNetSeat = roomData.mySeatId;
	mySelf.seatId = Player.myNetSeat;
	mySelf.money = roomData.myMoney;
	mySelf.matchScore = roomData.myMatchScore;

	local myself = playerMgr:myself();
	self:playerEnterGame( myself )
	--self:updateView(RoomScene.s_cmds.playerEnterGame, myself);

	--比赛不出现准备按钮
	self:hideReadyBtn()
	--self:updateView(RoomScene.s_cmds.setReadyBtnVisible, false);

	--这时候不能发表情
	QuickChatWnd.canSendFaceOrText = false;
	self:getProp( data.level );
end

-----