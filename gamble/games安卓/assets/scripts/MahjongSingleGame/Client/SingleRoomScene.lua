local roomLayout = require(ViewLuaPath.."roomLayout");
require("MahjongRoom/RoomScene");
require("MahjongSingleGame/Server/SingleGameServer");

SingleRoomScene = class(RoomScene);

--由父类初始化
SingleRoomScene.onlineGameCoor = {0,0};

SingleRoomScene.ctor = function (self, viewConfig, state)
	DebugLog("SingleRoomScene.ctor");
	GameConstant.isSingleGame = true;
	GameConstant.lastLoginType = 0;
	self:initView( false );
	self:initCmdConfig();
	--坐标
	local againW, againH = 243, 88;
	local onlineW, onlineH = 243, 88;
	local againOnlineSpaceW = 120;

	local x, y = self.mahjongManager.mahjongFrame:getPos(kSeatMine);
	local w, h = self.mahjongManager.mahjongFrame:getSize(kSeatMine);
	local discardX, discardY = 	self.mahjongManager.mahjongFrame:getDiscardFrame(kSeatMine,1);
	local discardW, discardH = self.mahjongManager.mahjongFrame:getDiscardSize(kSeatMine);

	SingleRoomScene.onlineGameCoor[1] = x+(w-againW-onlineW-againOnlineSpaceW)/2+againW+againOnlineSpaceW;
	SingleRoomScene.onlineGameCoor[2] = discardY - againH - 10;

	--初始化事件机制
	Event.RoomSocketClient	= EventDispatcher.getInstance():getUserEvent();
	DebugLog("【单机游戏】事件机制初始化完毕...");
	SocketManager.getInstance():syncClose();  --断开sokcet

	GameConstant.isSingleGameBackToHall = true;
	-- self.taskWnd:setVisible(false);  --屏蔽任务功能
	GameConstant.noPopEvaluate = true


	local player = PlayerManager.getInstance():myself();
	local myMid = player.mid;

	GameConstant.mySingleSelf = publ_deepcopy(player);
	if myMid <= 0 then
		player.mid = 1;
		player.nickName = "玩家";
		player.money = 1000000;
		player.wintimes = 0;
		player.losetimes = 0;
		player.drawtimes = 0;
	elseif myMid then
		GameConstant.myMid = player.mid;
		player.mid = 1;
	end

	local chestBtn = self:getControl(RoomScene.s_controls.chestBtn);
	if chestBtn then
		chestBtn:setVisible(false)
	end
	----------------------
	self:initSocketEventFuncMap();
    self:initCmdConfig();
    self:initHttpRequestsCallBackFuncMap();



	-------------
end

SingleRoomScene.onClickedOnlineBtn = function ( self )
	self:toHall();
	GameConstant.singleToOnline = true;
end

SingleRoomScene.getPropCanUseMoney = function( self )
	return PlayerManager.getInstance():myself().money;
end

-- 准备开始游戏 摇骰 定庄
SingleRoomScene.readyStartGame = function ( self, data )
	self.super.readyStartGame(self, data);
end

-- 普通玩法中间有人胡

-- 普通场一局结束
SingleRoomScene.gameOver = function ( self, data )
	self.super.gameOver(self, data);

	local seat = self.seatManager:getSeatByLocalSeatID(kSeatMine,self);
	seat:showReadyOnlineBtn();
end

SingleRoomScene.showReadyBtn = function ( self )
	local seat = self.seatManager:getSeatByLocalSeatID(kSeatMine,self);
	seat:showReadyBtn();
end
SingleRoomScene.handleCmd = function(self, cmd, ...)
	if SingleRoomScene.s_cmdConfig[cmd] then
		return SingleRoomScene.s_cmdConfig[cmd](self,...);
	end
	if not RoomScene.s_cmdConfig[cmd] then
		FwLog("SingleRoomScene, no such cmd  "..cmd);
	end
	return RoomScene.s_cmdConfig[cmd](self,...);
end


SingleRoomScene.dtor = function ( self )
	DebugLog("SingleRoomScene.dtor")
	delete(self.consolegameser);  --销毁本地服务器
	self.consolegameser = nil;
	GameConstant.myMid = 0;
	GameConstant.isSingleGame = false;
end

SingleRoomScene.resume = function ( self )
	DebugLog("SingleRoomScene resume");
	self.super.resume(self);
	if not self.consolegameser then
		self.consolegameser = new(SingleGameServer);  --启动本地服务器
    	self.isInSocketRoom = false;
	end
end

SingleRoomScene.run = function(self)
	DebugLog("SingleRoomScene run");
	self.super.run(self);
end

SingleRoomScene.pause = function(self)
	DebugLog("SingleRoomScene pause");
	self.super.pause(self);
end

SingleRoomScene.stop = function(self)
	DebugLog("SingleRoomScene stop");
	self.super.stop(self);
end



-- 普通玩法中间有人胡
SingleRoomScene.hu = function ( self, infoTable )
	--self:hasHued()
	-- 移除中心显示的打出牌
	self.mahjongManager:removeBigShowCenterView();

	local fangPaoId, huCard = -1,0;
	local sm = self.seatManager;

	for k,v in pairs(infoTable) do
		self:hasHued()
		local player = PlayerManager.getInstance():getPlayerBySeat(v.seatId);

		sm.seatList[v.seatId]:huInGame(v.huType);
		if kSeatMine == v.seatId then
			GameEffect.getInstance():play("AUDIO_WIN");
			self.mahjongManager:setAllMahjongFrameDown();
			self:setMineGameFinish();
		end
		-- 清空被抢杠胡的杠牌
		if 1 == v.isQiangGangHu then
			self.mahjongManager:playerQiangGangHu(v.huCard);
		end
		if 1 == v.huType then
			-- self:playGameAnim(SpriteConfig.TYPE_HU, v.seatId);
			fangPaoId = PlayerManager.getInstance():getLocalSeatIdByMid(v.fangPaoUserID);
			self:playGameAnim(SpriteConfig.TYPE_FANGPAO, fangPaoId);
			huCard = v.huCard;
		else
			self:playGameAnim(SpriteConfig.TYPE_ZIMO, v.seatId);
		end

		local dafanxin = new(DaFanXin, v.paiType, v.seatId, self.m_root);
		dafanxin:play();
		table.insert(self.dafanxinAnimList, dafanxin);
		self.mahjongManager:setInHandCardsWhenHuBySeat(v.seatId);
		self.mahjongManager:setHuCardBySeat(v.seatId , v.huCard , v.huType);

		DebugLog("设置胡牌的人的加番牌图标1")
		self.mahjongManager:setAddFanHuForSeat(v.seatId);

	end


	if self.reconnectRoom and fangPaoId >= 0 then
		self.reconnectRoom = false;
		local seatId = fangPaoId;
		self.mahjongManager:clearACardshowDiscardOnTable(seatId , huCard);
	end
	self.reconnectRoom = false;
end


-- socket的状态  --单机忽略
SingleRoomScene.onSocketStateEvent = function (self , eventType)
end

SingleRoomScene.s_cmds = {
	readyStartGame = 3,
	hu = 18,
	gameOver = 19
};

SingleRoomScene.s_cmdConfig =
{
	[SingleRoomScene.s_cmds.readyStartGame] = SingleRoomScene.readyStartGame,
	[SingleRoomScene.s_cmds.hu] = SingleRoomScene.hu,
	[SingleRoomScene.s_cmds.gameOver] = SingleRoomScene.gameOver
};
