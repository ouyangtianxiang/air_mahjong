
ReportSocket = class();

reportPHPDataTable = {};

local ReportSocket_Table = {
	[HALL_SERVER_COMMAND_SYNC] = HALL_CLIENT_COMMAND_SYNC,
	[HALL_SERVER_COMMAND_LOGIN_SUCCESS] = HALL_CLIENT_COMMAND_LOGIN,
	[HALL_SERVER_COMMAND_LOGIN_ERR] = HALL_CLIENT_COMMAND_LOGIN,
	[HALL_SERVER_RESPOND_JOIN_GAME2] = HALL_CLIENT_COMMAND_JOIN_GAME2,
	[HALL_CLIENT_GET_ROOM_LEVER_NUM] = HALL_CLIENT_GET_ROOM_LEVER_NUM,
	[SERVER_COMMAND_LOGIN_SUCCESS] = CLIENT_COMMAND_LOGIN,
	[SERVER_COMMAND_LOGIN_ERR] = CLIENT_COMMAND_LOGIN,
	[SERVER_COMMAND_OTHER_ERR] = CLIENT_COMMAND_LOGIN,
	[CLIENT_COMMAND_RSP_LOGOUT] = CLIENT_COMMAND_REQ_LOGOUT,
	[SERVER_COMMAND_VIP_KICK_PLAYER] = CLIENT_COMMAND_VIP_KICK_PLAYER,
	[SERVER_CMD_BROADCAST_TRUMPET] = CLIENT_CMD_BROADCAST_TRUMPET,
	[HALL_SERVER_RESPOND_ENTER_ROOM] = CMD_CLIENT_ENTER_PRIVATE_ROOM,
	[SERVER_CMD_RES_CREATE_ROOM] = CMD_CLIENT_CREATE_ROOM2,
	[SERVER_CMD_LIST_PRIVATE_ROOM3] = CMD_CLIENT_LIST_PRIVATE_ROOM3,
	[SERVER_BROADCAST_OUT_CARD] = CLIENT_COMMAND_OUTCARD,
	[SERVER_BROADCAST_USER_READY] = CLIENT_COMMAND_READY,
	[SERVER_BROADCAST_TAKE_OPERATION] = CLIENT_COMMAND_TAKE_OPERATION,
	[SERVER_BROADCAST_HU_TO_TABLE2] = CLIENT_COMMAND_TAKE_OPERATION,
}

function ReportSocket.ctor(self , second)
	DebugLog("ReportSocket ctor");
	self.reportAnim = new(AnimInt , kAnimRepeat , 0 , second * 1000 , second *1000 , 0);
	self.reportAnim:setEvent(self , function( self )
		self:reportSocketData();
		self:reportPHPData();
	end);
	reportPHPDataTable = {};

	self.socketData = {};
	self.reportSocketDataTable = {};
end

function ReportSocket.dtor(self)
	DebugLog("ReportSocket dtor");
	delete(self.reportAnim);
	self.reportAnim = nil;
	self.socketData = {};
	reportPHPDataTable = {};
	self.reportSocketDataTable = {};
end

-- 收集socket数据
-- 先阶段没有序列号的情况下，默认应答都是有记录的第一条发出的
-- 如果某条应答超过5S，则默认为配对失败，则抛弃
local kSend = 1;
local kRec = 2;
function ReportSocket.collectSocketData( self , dataType , send_Or_rec )
	if not dataType or not send_Or_rec then
		return;
	end
	DebugLog("ReportSocket.collectSocketData : "..dataType.."  "..send_Or_rec);
	if kSend == send_Or_rec then
		for k , v in pairs(ReportSocket_Table) do
			if dataType == v then
				if not self.socketData[dataType] then
					self.socketData[dataType] = os.clock() * 1000;
				else
					local lTime = os.clock() * 1000;
					if lTime - self.socketData[dataType] >= 4000 then
						self.socketData[dataType] = lTime;
					end
				end
				break;
			end
		end
	elseif kRec == send_Or_rec then
		for k , v in pairs(ReportSocket_Table) do
			if self.socketData[v] and dataType == k then
				local tmpTable = {}; 
				tmpTable.dataType = v;
				tmpTable.time = os.clock() * 1000 - self.socketData[v];
				-- 如果超过N秒 就抛弃
				if tmpTable.time <= 8000 then
					table.insert(self.reportSocketDataTable , tmpTable);
				end
				self.socketData[v] = nil;
				break;
			end
		end
	end
end

-- 上报socket数据
function ReportSocket.reportSocketData( self )
	DebugLog("ReportSocket.reportSocketData");
	if #self.reportSocketDataTable > 0 then
		local dataStr = json.encode(self.reportSocketDataTable);
		if dataStr then
			DebugLog("self.reportSocketDataTable json : "..dataStr);
			local data = {};
			data.str = dataStr;
			data.secondCmd = CLIENT_COMMAND_REPORT_SOCKET;
			SocketManager.getInstance():sendPack( CLIENT_COMMAND_REPORT_DATA, data );
		end
	end
	self.reportSocketDataTable = {};
end

function ReportSocket.reportPHPData( self )
	DebugLog("ReportSocket.reportPHPData");
	if #reportPHPDataTable > 0 then
		local dataStr = json.encode(reportPHPDataTable);
		if dataStr then
			DebugLog("reportPHPDataTable json : "..dataStr);
			local data = {};
			data.str = dataStr;
			data.secondCmd = CLIENT_COMMAND_REPORT_PHP;
			SocketManager.getInstance():sendPack( CLIENT_COMMAND_REPORT_DATA, data );
		end
	end
	reportPHPDataTable = {};
end