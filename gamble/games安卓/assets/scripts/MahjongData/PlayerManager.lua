-- 玩家管理器

require("MahjongData/Player")

PlayerManager = class();
PlayerManager.instance = nil; -- private
PlayerManager.getInstance = function ()
	if not PlayerManager.instance then
		PlayerManager.instance = new(PlayerManager);
	end
	return PlayerManager.instance;
end

-- private
PlayerManager.ctor = function ( self )
	self.playerList = {};
end

-- 添加一个网络玩家,data的数据格式必须符合player的initSocketUserData方法
PlayerManager.parseNetPlayerData = function ( self, data, inFetionRoom)
	local player = new(Player);
	player:initSocketUserData(data, inFetionRoom);
	self:addPlayer(player);
	return player;
end

-- 获取准备的玩家列表
PlayerManager.getReadyPlayerList = function ( self )
	local list = {};
	for k,v in pairs(self.playerList) do
		if v.isReady then
			table.insert(list, v);
		end
	end
	return list;
end

-- 添加玩家
PlayerManager.addPlayer = function ( self, player )
	DebugLog("PlayerManager.addPlayer be")
	if not player then
		return;
	end
	for k,v in pairs(self.playerList) do
		if player.mid == v.mid then
			table.remove(self.playerList,k);
			delete(v);
			break;
		end
	end
	DebugLog("PlayerManager.addPlayer en")
	table.insert( self.playerList, player);
end

PlayerManager.getLocalSeatIdByMid = function ( self, mid )
	for k,v in pairs(self.playerList) do
		if mid == v.mid then
			return v.localSeatId;
		end
	end
end

PlayerManager.getPlayerById = function ( self, mid )
	DebugLog(mid)
	if not mid or not self.playerList or  #self.playerList < 1 then
		return nil;
	end
	--mahjongPrint(self.playerList)
	for k,v in pairs(self.playerList) do
		if mid == v.mid then
			return v;
		end
	end
	return nil;
end

PlayerManager.getPlayerBySeat = function ( self, seatId )
	if not seatId or #self.playerList < 1 then
		return nil;
	end
	for k,v in pairs(self.playerList) do
		if seatId == v.localSeatId then
			return v;
		end
	end
	return nil;
end

PlayerManager.getHuPlayerNum = function ( self )
	local num = 0;
	for k,v in pairs(self.playerList) do
		if v.isHu then
			num = num + 1;
		end
	end
	return num;
end

-- 根据mid移除玩家
PlayerManager.removePlayerByMid = function ( self, mid )
	if not mid or #self.playerList < 1 then
		return;
	end
	for k,v in pairs(self.playerList) do
		if mid == v.mid then
			table.remove(self.playerList, k);
			delete(v);
			break;
		end
	end
end

-- 移除自己以外的其他用户， 这个方法应该在玩家退出房间和进入房间前调用
PlayerManager.removeOtherPlay = function ( self )
	DebugLog("PlayerManager.removeOtherPlay")
	local mineData = nil;
	for k,v in pairs(self.playerList) do
		if (v.isMyself) then
			mineData = v;
		else
			delete(v); -- 释放其他玩家数据
		end
	end
	self.playerList = {};
	if mineData then
		table.insert( self.playerList, mineData);
	end
end

PlayerManager.myself = function (self)
	for k,v in pairs(self.playerList) do
		if v.isMyself then
			return v;
		end
	end
	local  player = new(Player);
	player.isMyself = true;
	table.insert(self.playerList, player);
	return player;
end


PlayerManager.isAllReady = function ( self )
	local readyCount = 0
	for k,v in pairs(self.playerList) do
		if v.isReady then
			readyCount = readyCount + 1 
		end 
	end
	if readyCount == 4 then 
		return true
	else 
		return false
	end 
end


