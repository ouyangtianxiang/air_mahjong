--广播推送消息管理类
require("MahjongSocket/socketCmd");
require("MahjongHall/HongBao/HongBaoModel")
BroadcastMsgManager = class();
BroadcastMsgManager.instance = nil;

BroadcastMsgManager.updateSceneEvent = EventDispatcher.getInstance():getUserEvent();  --更新界面事件

BroadcastMsgManager.getInstance = function ( )
	if not BroadcastMsgManager.instance then
		BroadcastMsgManager.instance = new(BroadcastMsgManager);
	end
	return BroadcastMsgManager.instance;
end

BroadcastMsgManager.ctor = function ( self )
	EventDispatcher.getInstance():register(SocketManager.s_serverMsg, self, self.onSocketPackEvent);
	self.m_queue = {};
	self.m_lastInfo = nil;
	self.m_queueForWin = {};
	self.m_topNews = {};

	self.m_queueForWinCount = 0
end

--压入消息的操作(push)
BroadcastMsgManager.receiveBroadcastMsg = function(self, data)
	if not data.info then
		return;
	end

	local msgType_tmp = self:getMsgType(data.info.title);
	if 0 == msgType then
		return;
	end

	if 0 == GameConstant.isDisplayBroadcast and 3 == msgType_tmp then
		return;
	end

	local hongbaoid = data.info.redid
	if hongbaoid and tonumber(hongbaoid) ~= 0 then
		EventDispatcher.getInstance():dispatch(HongBaoModel.DissmissHongbao,hongbaoid);
	end

	--消息结构
	local info = {
		msgType = msgType_tmp;
		priority = data.priority or 0;
		mid = data.info.uid;
	}

	if GameConstant.iosDeviceType>0 and GameConstant.iosPingBiFee then
		if data.info.uid ~= PlayerManager.getInstance():myself().mid then
			return;
		end
	end
	
	if 3 == msgType_tmp then -- 广播类型，1跑马灯条件触发，2后台添加公告,3为玩家
		info.msg =  "【" .. data.info.title .. "】" .. data.info.name .. ": " .. data.info.msg;
	else
		info.msg = "【" .. data.info.title .. "】" .. data.info.msg;
	end

	if #self.m_queueForWin > 49 then
		table.remove(self.m_queueForWin);

		self.m_queueForWinCount = self.m_queueForWinCount + 1
		info.countId = self.m_queueForWinCount
		table.insert(self.m_queueForWin, 1, info);
	else
		self.m_queueForWinCount = self.m_queueForWinCount + 1
		info.countId = self.m_queueForWinCount
		table.insert(self.m_queueForWin, 1, info);
	end


	--根据播放次数重复插入
	local times = tonumber(data.times) or 1;
	if times < 1 then
		times = 1;
	end
	for i = 1, times do
		table.insert(self.m_queue, info);
	end
	self:sort();
	EventDispatcher.getInstance():dispatch(BroadcastMsgManager.updateSceneEvent);
end

--弹出操作，会移除并返回队列里的首条消息
BroadcastMsgManager.pop = function(self)
	self.lastMsg = table.remove(self.m_queue, 1) or {};
	return self.lastMsg;
end

BroadcastMsgManager.push = function ( self )
	table.insert(self.m_queue, 1, self.lastMsg);
end

--排序操作(根据优先级由小到大)
BroadcastMsgManager.sort = function(self)
	table.sort(self.m_queue, self.sortByPriority);
end

BroadcastMsgManager.sortByPriority = function( s1, s2 )
	if not s1 or not s2 then
		return false;
	end

	if s1.priority and s2.priority then
		return s1.priority < s2.priority;
	else
		return false;
	end
end

BroadcastMsgManager.addTopNews = function( self, broadcastMsgData )
	if not broadcastMsgData then
		return;
	end

	table.insert( self.m_topNews, broadcastMsgData );
end

BroadcastMsgManager.getTopNews = function( self )
	return self.m_topNews;
end

BroadcastMsgManager.clearTopNews = function( self )
	self.m_topNews = {};
end

--队列为空的判断
BroadcastMsgManager.isEmpty = function(self)
	return #self.m_queue == 0;
end

--清除队列所有消息
BroadcastMsgManager.clean = function(self)
	self.m_queue = {};
end

--得到队列消息总数
BroadcastMsgManager.getCount = function(self)
	return #self.m_queue;
end

BroadcastMsgManager.getMsgType = function ( self, msgType )
	if "系统" == msgType then
		return 1;
	elseif "公告" == msgType then
		return 2;
	elseif "玩家" == msgType then
		return 3;
	else
		return 0;
	end

end

BroadcastMsgManager.dtor = function ( self )
	EventDispatcher.getInstance():unregister(SocketManager.s_serverMsg, self, self.onSocketPackEvent);
end

--socket分发
BroadcastMsgManager.onSocketPackEvent = function ( self, param, cmd )
	if BroadcastMsgManager.scoketEventFuncMap[cmd] then
		BroadcastMsgManager.scoketEventFuncMap[cmd](self, param);
	end
end

--socket命令字监听列表
BroadcastMsgManager.scoketEventFuncMap = {
	[SERVER_PUSH_RADIO_MSG] 	   = BroadcastMsgManager.receiveBroadcastMsg,  --server广播信息
}
