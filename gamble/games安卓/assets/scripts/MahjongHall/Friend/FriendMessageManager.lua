--数据格式

-- message.time 	-- 时间
-- message.chat 	--内容
-- message.state 	--发送状态 0 正在发送 1 发送成功 -1 发送失败
-- message.speakID	--说话人ID

--好友聊天内容管理
FriendMessageManager = class();

--单例模式
FriendMessageManager.m_Instance 		= nil;

FriendMessageManager.MAX_RECORD_NUM     = 100

FriendMessageManager.getInstance = function()
	if FriendMessageManager.m_Instance == nil then 
		FriendMessageManager.m_Instance = new(FriendMessageManager);
	end
	return FriendMessageManager.m_Instance;
end

FriendMessageManager.ctor = function(self)
	
end

FriendMessageManager.dtor = function(self)
end

-----------------------------------------------------------------------------------

function getSortKeys( data, sortfunc)
	local sortedKeys = {}
	for k,v in pairs(data) do
		table.insert(sortedKeys,k);
	end
	table.sort(sortedKeys,sortfunc)
	return sortedKeys
end


function FriendMessageManager.loadData(self, myId, friendId)
	local friendId 			= "" .. friendId; --强制转为字符串
	local myId 				= "" .. myId; --强制转为字符串
	
	return g_DiskDataMgr:getFileKeyValue(kFriendChatMessageHistory,"chat" .. myId .. friendId,{})
end

function FriendMessageManager.saveData( self, myId, friendId, tableData )
	DebugLog("FriendMessageManager.saveData")
	mahjongPrint(tableData)

	local friendId 			= "" .. friendId; --强制转为字符串
	local myId 				= "" .. myId; --强制转为字符串	


	g_DiskDataMgr:setFileKeyValue(kFriendChatMessageHistory,"chat" .. myId .. friendId,tableData)
end

function FriendMessageManager.loadMessageFromHistoryNewVersion(self, myId, friendId, skipCount, maxCount)
	DebugLog("FriendMessageManager.loadMessageFromHistoryNewVersion")
	local data = self:loadData(myId,friendId)

	local find 				= false;
	local message 			= {};
	local loadedMesCount    = 0;


	local sortedKeys = getSortKeys(data,function ( a,b )
		return a > b
	end)

	local insertToMsgs = function ( msg, msgs )
		local tmp 	= {};
		tmp.id 		= msg.id     
		tmp.state 	= msg.state       
		tmp.speakID = msg.speakID
		tmp.chat 	= msg.chat
		tmp.isTime  = msg.isTime
		table.insert(msgs, #msgs + 1, tmp);
	end

	--for date,dateMes in pairs(data) do------------------pairsByKeys
	local count = 0
	local breakIndex = #sortedKeys

	for keyIndex=1,#sortedKeys do
		local date = sortedKeys[keyIndex]
		local dateMes = data[sortedKeys[keyIndex]]
		
		--local startIndex = 1
		if count + #dateMes > skipCount then 
			local beginIndex =  math.max(1,skipCount - count+1)
			local endIndex   = #dateMes

			for i = beginIndex,endIndex do 
				insertToMsgs(dateMes[i],message)
				loadedMesCount = loadedMesCount+1
				if loadedMesCount >= maxCount then
					return message
				end
			end 
			--find 
			breakIndex = keyIndex
			break
		else 
			count = count + #dateMes
		end 
	end

	for i = breakIndex+1,#sortedKeys do 
		local date = sortedKeys[i]
		local dateMes = data[sortedKeys[i]]	
		for k=1,#dateMes do
			insertToMsgs(dateMes[k],message)
			loadedMesCount = loadedMesCount + 1
			if loadedMesCount >= maxCount then
				return message
			end			
		end	
	end 

	return message
end

function FriendMessageManager.setMessageStateFromHistoryNewVersion( self, myId, friendId, msgId, state)
	-- body
	local friendId 			= "" .. friendId; --强制转为字符串
	local myId 				= "" .. myId; --强制转为字符串
	
	local data = self:loadData(myId, friendId)

	for date,dateMes in pairs(data) do
		for i=1,#dateMes do
			if tonumber(dateMes[i].id) == tonumber(msgId) then 
				dateMes[i].state = state
				self:saveData(myId,friendId,data)
				return
			end 
		end
	end
end

function FriendMessageManager.saveAMessageToFileNewVersion(self, myId, friendId, messaga)
	DebugLog("FriendMessageManager.saveAMessageToFileNewVersion")

	local friendId 			= "" .. friendId; --强制转为字符串
	local myId 				= "" .. myId; --强制转为字符串
	local data              = nil
	data = self:loadData(myId, friendId)

	local curTime 	= os.time();
	local date 		= os.date("*t", curTime);
	local curDate   = os.time({year=date.year, month=date.month, day=date.day, hour=0, min = 0, sec=0});

	local key = tostring(curTime)
	if data then 
		
		local mes 	= {}
		mes.id 		= messaga.id 
		mes.state 	= messaga.state
		mes.speakID = tostring(messaga.speakID)
		mes.chat 	= messaga.chat
		mes.isTime  = messaga.isTime

		local dateMes = data[key]
		if dateMes then 
			DebugLog("has dateMes:"..key)
			table.insert(dateMes,mes)
		else
			data[key] = {}
			table.insert(data[key],mes)
		end 
		DebugLog("data key:"..key)

		DebugLog("mes:")
		mahjongPrint(mes)

		DebugLog("data:")
		mahjongPrint(data)
		self:saveData(myId,friendId,data)
	end 
end


function FriendMessageManager.deleteHistoryForIds( self, myId, friendId, messageIds )
	local friendId 			= "" .. friendId; --强制转为字符串
	local myId 				= "" .. myId; --强制转为字符串
	local data              = nil

	data = self:loadData(myId, friendId)	

    local findAndRemoveFunc = function ( data,msgId )
		for date,dateMes in pairs(data) do 
			for i=1,#dateMes do 
				if tonumber(dateMes[i].id) == tonumber(msgId) then 
				   table.remove(dateMes,i)
				   if #dateMes <= 0 then 
				       data[date] = nil
				   end 
				   return 
				end 
			end 
		end 
    end

	while(#messageIds > 0)
	do 
		findAndRemoveFunc(data,messageIds[#messageIds])
		table.remove(messageIds)
	end 

	self:saveData(myId,friendId,data)
end


--删除好友历史记录
function FriendMessageManager.deleteOutDateHistoryNewVersion( self, myId, friendId)

	local friendId 			= "" .. friendId; --强制转为字符串
	local myId 				= "" .. myId; --强制转为字符串
	local data = self:loadData(myId, friendId)

	local curTime 	= os.time();
	local date 		= os.date("*t", curTime);
	local curDate   = os.time({year=date.year, month=date.month, day=date.day, hour=0, min = 0, sec=0});

	local messageCount = 0

	local sortedKeys = getSortKeys(data)
	--	--for date,dateMes in pairs(data) do--pairsByKeys
	for keyIndex=1,#sortedKeys do
		local date = sortedKeys[keyIndex]
		local dateMes = data[date]

		if curDate - tonumber(date) >= 14 * 24 * 3600 then
			data[date] = nil 
		else
			for i=1,#dateMes do
				if not dateMes[i].isTime then 
					messageCount = messageCount + 1
				end 
			end
		end
	end 

	if messageCount > self.MAX_RECORD_NUM then 
		local sortedKeys = getSortKeys(data)
		-------------------------------------------
		for keyIndex=1,#sortedKeys do
			local date = sortedKeys[keyIndex]
			local dateMes = data[date]
		--for date,dateMes in pairs(data) do--pairsByKeys
			if messageCount - #dateMes >= self.MAX_RECORD_NUM then 
				for i=1,#dateMes do
					if not dateMes[i].isTime then 
						messageCount = messageCount - 1
					end 
				end
				data[date] = nil
			else -- < 100
				local needRemoveCount = messageCount - self.MAX_RECORD_NUM
				while( needRemoveCount > 0 and #dateMes > 0)
				do
					if not dateMes[1].isTime then 
						needRemoveCount = needRemoveCount - 1
					end 
					table.remove(dateMes,1) 
				end 
			end 
		end 
	end 

	self:saveData(myId,friendId,data)
end
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------5.0.0之前版本的数据存取方式


--得到唯一的ID
FriendMessageManager.getUniqueId = function ( ... )
	-- body
	local idFile 	= new(Dict, "uniqueid");
	idFile:load();

	local id = idFile:getInt("id",  0);

	if id == 0 then
		id = os.time();
	end
	id = id + 1;
	idFile:setInt("id",  id);
	idFile:save();
	idFile:delete();
	delete(idFile);
	return id;
end


