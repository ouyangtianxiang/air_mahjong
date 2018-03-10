
-- 房间数据
RoomData = class();

RoomData.instance = nil;
RoomData.getInstance = function ()
	if not RoomData.instance then
		RoomData.instance = new(RoomData);
	end
	return RoomData.instance;
end

RoomData.ctor = function ( self )
	self:clearData();
end

RoomData.setRoomAddr = function ( self, data )
	self.roomIp = data.ip;
	self.roomPort = data.port;
	self.roomId = data.roomId;
	self.isMatch = data.isMatch or false;
	--self.isFriendMatch = data.isFriendMatch or false
	self:setIsFriendMatch(data.isFriendMatch or false)
	self.matchId= data.matchId;
	self.serverId = data.sid;
	self.isInGame = data.isInGame;
end


RoomData.setIsFriendMatch = function ( self, bValue )
	self.isFriendMatch = bValue
end

RoomData.isInFetionRoom = function ( self, data )
	self.inFetionRoom = data.inFetionRoom;
end

RoomData.setIpAndPort = function ( self, data )
	self.roomIp = data.ip;
	self.roomPort = data.port;
	self.roomId = data.roomId;
end

RoomData.enterRoom = function ( self, data )
	DebugLog("RoomData.enterRoom")
	self:parseNetworkData(data);
end

-- 解析进入房间时服务器发过来的数据
RoomData.parseNetworkData = function ( self, data )
	DebugLog("RoomData.parseNetworkData")
	if not data then
		return;
	end
	self.tai = data.tai;
	self.di = tonumber(data.di);
	self.totalQuan = data.totalQuan;
	self.mySeatId = data.mySeatId;
	self.myMoney = data.myMoney;
	self.myMatchScore = data.myMatchScore;
	self.outCardTimeLimit = data.outCardTimeLimit;
	self.operationTime = data.operationTime;
	self.isLiangFanPai = data.isLiangFanPai;
	self.wanfa = data.wanfa;
	
	self:setPlayType(data.wanfa)
	GameConstant.curRoomLevel = data.roomLevel;
end

RoomData.parseNameAndLevel = function ( self, data )
	DebugLog("RoomData.parseNameAndLevel")
	self.getLevel = true;
	self.level = data.level;
	GameConstant.curRoomLevel = self.level;
    self.roomType = data.roomType;
    self.tableid = data.tableid;
    self.changname = data.changname;
    self.fan = data.fan;
    self.diQue = data.diQue;
    -------------------------------------------------------------------坑爹货啊  这是server为了兼容老版本
    --self.playType = data.playType;  --0为普通玩法  1 为血流玩法
    self:setPlayType(data.playType)
    -------------------------------------------------------------------新版本用的按位&取字段

    self.isXueLiu = (1 == self.playType);
    self.isSwapCard = data.isSwapCard; -- 是否是换三张
    self.wanfa = data.wanfa;--0x00为普通玩法 0x01为定缺 0x02为血流 0x04为换三张 0x08为加番 0x10 两房牌
    --self.playType = self.wanfa
    self:setPlayType(data.wanfa)
    self.isLiangFanPai = data.isLiangFanPai;
    self.isBankruptSubsidize = data.isBankruptSubsidize; -- 是否有系统补助
end

RoomData.setPlayType = function ( self, pt )
	DebugLog("RoomData.setPlayType"..tostring(pt))
	self.playType = pt 
end

RoomData.setInFetionRoom = function ( self, data )
	if 1 == data then
		self.inFetionRoom = true;
	end
end

RoomData.setPrivateRoomData = function ( self, data )
	self.privateData = data;
end


RoomData.setChangeRoomData = function(self,data)
	DebugLog("RoomData.setChangeRoomData")
	self.roomIp = data.ip;
	self.roomPort = data.port;
	self.roomId = data.roomId;
	self.roomType = data.roomType;
	self.di = data.roomDi;
	--self.isFriendMatch = data.isFriendMatch or false
	self:setIsFriendMatch(data.isFriendMatch or false)
	--self.playType = data.server_type;
	self:setPlayType(data.server_type)
	self.level = data.server_level;
	GameConstant.curRoomLevel = self.level;
end

-- 清除房间数据，在游戏结束或是进入房间前要调用一次
RoomData.clearData = function ( self )
	DebugLog("RoomData.clearData")
	self.isReconnect = false;
	self.mineCurGameWinMoney = 0; -- 自己当前局的赢钱数统计
	self.isPrivateRoom = false; -- 是否是私人房间
	self.isStartSwapCard = false; -- 是否开始了换三张流程
	self.firstSwapClick = false;
	self.swapCardList = {}; -- 换三张要替换的牌
	self.swapCardTime = 0; -- 换三张操作时间

	-- self.isEnterRoom = false;

	self.kickTime = 10; -- 不准备踢出时间
	self.leftcard = 0; -- 剩余牌数
	self.roomId = nil;
	self.roomIp = nil;
	self.roomPort = nil;

	self.roomItem = nil;

	self.tai = nil;
	self.di = nil; -- 如果底==0，说明在包厢内，客户端根据进入包厢时候的底来赋值
	self.totalQuan = nil;
	self.mySeatId = nil;
	self.myMoney = nil;
	self.outCardTimeLimit = nil; -- 出牌时限
	self.operationTime = nil; -- 操作时限
	self.inFetionRoom = nil;

	-- GameConstant.curRoomLevel = 0;

	self.getLevel = false;
	self.level = nil;
    self.roomType = nil;
    self.tableid = nil;
    self.changname = nil;
    self.fan = nil;
    self.diQue = nil;
    self:setPlayType(0)
    --self.playType = 0;  --0为普通玩法  1 为血流玩法
    self.isXueLiu = false;
    self.isSwapCard = nil; -- 是否是换三张
    self.wanfa = nil;
    self.huTypeInfo = {};
    self:initHuTypeInfo();
    self.inFetionRoom = nil;
    self.isInGame = 0;
    self.boxType = 0; -- 0为银宝箱，1为金宝箱
end

-- 设置私人房间的低注
RoomData.setPrivateRoomInfo = function ( self, di )
	self.isPrivateRoom = true;
	g_DiskDataMgr:setAppData('privateRoomDi', di)
end

-- 获取最后一次保存的私人房间低注
RoomData.getLastPrivateRoomInfo = function ( self )
	return g_DiskDataMgr:getAppData('privateRoomDi',0)
end

-- 初始化胡牌信息列表
RoomData.initHuTypeInfo = function (self)
	self.huTypeInfo = {};
	for k = kSeatMine , kSeatLeft do
		local t = {};
		t.hu = 0;
		t.zimo = 0;
		t.seatId = k;
		table.insert(self.huTypeInfo , t);
	end
end

RoomData.getHuTypeInfoBySeat = function (self , seatId)
	for  k , v in pairs(self.huTypeInfo) do
		if v.seatId == seatId then
			return v;
		end
	end
end 

RoomData.dtor = function ( self )
	
end

