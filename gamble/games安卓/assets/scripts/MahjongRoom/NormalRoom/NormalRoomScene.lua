require("MahjongRoom/RoomScene");

NormalRoomScene = class(RoomScene);

NormalRoomScene.ctor = function( self, viewConfig, state )
	DebugLog( "NormalRoomScene.ctor" );

	self:initSocketEventFuncMap();
    self:initHttpRequestsCallBackFuncMap();

	self:initView( false );
	self:initCmdConfig();
end

NormalRoomScene.dtor = function( self )
	EventDispatcher.getInstance():unregister(NativeManager._Event, self, self.nativeCallEvent);
	RoomScene_instance = nil;
end

-- 创建房间座位按钮节点
NormalRoomScene.createSeat = function ( self )
	self.super.createSeat( self );
	--self:showTableInfo(1,true)
	--self:setRoomBaseInfoVisible(true);
end

NormalRoomScene.showChangMoneyAnim = function ( self, mid, money )
	self.super.showChangMoneyAnim(self, mid, money);
	if GameConstant.isSingleGame then
		g_DiskDataMgr:setAppData('singleMyMoney',PlayerManager.getInstance():myself().money)
		if player.money < 0 and player.money < 0 then
			self:playBankruptAnim(player.localSeatId);
		end
	end
end


NormalRoomScene.resume = function ( self )
	DebugLog("NormalRoomController resume");
	self.super.resume(self);
	
	if GameConstant.boxRoomFlag  then
		GameConstant.boxRoomFlag = false;
		local data = RoomData.getInstance().privateData;
		SocketManager.getInstance():sendPack( CMD_CLIENT_CREATE_ROOM2, data );
	else
		if not GameConstant.isSingleGame then
			if RoomData.getInstance().isInGame == 1  or GameConstant.isInvitedByFriendInHall then
				GameConstant.isInvitedByFriendInHall = false
				self:reconnectLoginGame();
			else
				self:requireJoinGame();
			end
		end
	end
end

-- 登录房间
NormalRoomScene.reconnectLoginGame = function (self)
	log( "NormalRoomScene.reconnectLoginGame" );
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
	mahjongPrint( param );
	SocketManager.getInstance():sendPack(CLIENT_COMMAND_LOGIN, param); -- 登录房间
end



-- 游戏中重新连接了一次大厅socket，處理两种情况：1 游戏中重连 2 不在游戏中退出到大厅
NormalRoomScene.connectSocketSuccess = function ( self, data )
	DebugLog( "NormalRoomController.connectSocketSuccess" );
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

NormalRoomScene.matchStatus = function( self, data )
	if SVR_CLI_DINGSHI_PAIMING_RESULT == data.cmdRequest then
		if 2 == data.matchType and 3 == data.matchStage and PlayerManager:getInstance():myself().isInGame then
			if 1 == data.isTaotai then
				Banner.getInstance():showMsg("很遗憾,您被 " .. data.matchName .. " 淘汰出局");
			end
		elseif 2 == data.matchType and 3 == data.matchStage and not PlayerManager:getInstance():myself().isInGame then
			if 1 == data.isTaotai then
				self:showQuitPopWin(data, true);
			else
				GameConstant.matchName = data.matchName;
				GameConstant.curRoomLevel = data.level;
				GameConstant.matchId = data.matchId;
				PlayerManager:getInstance():myself().isInGame = false;
				GameConstant.timeMatchFlag = 1;
	            self:exitGame();
			end
		end
	elseif SERVER_SIGNUP_MATCH_RES == data.cmdRequest then
		if data.result ~= 0 then
			Banner.getInstance():showMsg(data.meg);
			--进入到报名界面
			PlayerManager:getInstance():myself().isInGame = false;
			GameConstant.traceMatchFlag = 1;
			RoomData.getInstance():setPrivateRoomData(data);
			GameConstant.HallViewType = HallScene.CONTENT_PLAYSPACE_GAME;
			self:exitGame();
		else
			--报名失败
			Banner.getInstance():showMsg(data.meg);
		end
	end
end