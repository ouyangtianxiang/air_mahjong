--数据格式




SystemMessageData = class()

SystemMessageData.MAX_RECORD_NUM = 100
-----------------------------------------------------------------------------------



function SystemMessageData.loadData(myId)
	local myId 				= "" .. myId; --强制转为字符串
	
	return g_DiskDataMgr:getFileKeyValue(kSystemMessageHistory,"sysMes" .. myId,{})
end

function SystemMessageData.saveData( myId, tableData )
	DebugLog("SystemMessageData.saveData")
	mahjongPrint(tableData)

	local myId 				= "" .. myId; --强制转为字符串	
	g_DiskDataMgr:setFileKeyValue(kSystemMessageHistory,"sysMes" .. myId,tableData)
end

function SystemMessageData.clearAll( myId )
	g_DiskDataMgr:setFileKeyValue(kSystemMessageHistory,"sysMes" .. myId,nil)
end

--删掉未读或者未领奖的过期消息
function SystemMessageData.filterUncheckAndOuttimeMessage( data )
	local curTime 	= os.time();
	
	for i=#data,1,-1 do
		if (data[i].type == 2 and data[i].award == 0) or (data[i].type == 1 and not data[i].isRead) then 
		    if curTime > data[i].end_time or curTime < data[i].start_time then 
		    	table.remove(data,i)
			end 
		end 
	end
end

function SystemMessageData.clearCancelMessages( data, cancelIds )
	if not cancelIds or not data then 
		return-- data
	end 

	for i=1,#cancelIds do
		local key = tostring(cancelIds[i])
		data[key] = nil
	end
end

function SystemMessageData.loadMessageFromHistory( myId, jsonData, cancelIds)
	DebugLog("FriendMessageManager.loadMessageFromHistoryNewVersion")
	local data = SystemMessageData.loadData(myId) or {}

	SystemMessageData.deleteOutMessages(data) --删除过期消息
	if jsonData and jsonData then 
		for i=1,#jsonData do
			local key = tostring(jsonData[i].id)
			local tmp = {}
			data[key] = data[key] or tmp --newData[i]
			
			for k,v in pairs(jsonData[i]) do
				data[key][k] = v
			end

			--
			if data[key].type == 2 and data[key].award ~= 0 then --有奖 且 已领
				data[key].isRead = true
			end 
		end
	end 
	
	SystemMessageData.clearCancelMessages(data,cancelIds)
	SystemMessageData.saveData(myId,data)
	return SystemMessageData.sortData(data)

--[[
	local insertToMsgs = function ( msg, msgs )
		local tmp 	= {};
		tmp.type 		= msg.type     
		tmp.award 		= msg.award       
		tmp.title 		= msg.title
		tmp.content 	= msg.content
		tmp.start_time  = msg.start_time
		tmp.end_time  	= msg.end_time
		tmp.id          = msg.id
		table.insert(msgs, #msgs + 1, tmp);
	end
]]
end

function SystemMessageData.sortData( data )
	local resultData = {}
	if not data then 
		return resultData
	end 
	
	for k,v in pairs(data) do
		local tmp 	= {};
		tmp.type 		= v.type--()     
		tmp.award 		= v.award--()       
		tmp.title 		= v.title--()
		tmp.content 	= v.content--()
		tmp.start_time  = v.start_time--()
		tmp.end_time  	= v.end_time--()
		tmp.id          = v.id--()
		tmp.isRead      = v.isRead--()

		table.insert(resultData, #resultData + 1, tmp);
	end

	SystemMessageData.filterUncheckAndOuttimeMessage(resultData)

	table.sort(resultData,function(a,b)
							if a.isRead and not b.isRead then 
								return false
							elseif not a.isRead and b.isRead then 
								return true
							else
								return a.start_time > b.start_time 
							end 
						  end)

	for i=#resultData,SystemMessageData.MAX_RECORD_NUM+1,-1 do
		resultData[i] = nil
	end
	return resultData
end

function SystemMessageData.saveMessage( myId, message)

	local myId 				= "" .. myId; --强制转为字符串
	
	local data = SystemMessageData.loadData(myId)

	if data then
		local key = tostring(message.id)
		data[key] = message
		--local tmp = {}
		--data[key] = tmp 
		--for k,v in pairs(message) do
		--	tmp[k] = v
		--end
		SystemMessageData.saveData(myId,data)		
	end 

end


function SystemMessageData.deleteMsgById( myId, msgId, cacheData )
	local myId = "" .. myId
	local data = SystemMessageData.loadData(myId)
	if data then 
		local key = tostring(myId)
		data[key] = nil
		SystemMessageData.saveData(myId,data)
	end 

	if cacheData then
		 for i=1,#cacheData do
		 	if cacheData[i].id == tostring(msgId) then 
		 		table.remove(cacheData,i)
		 		return
		 	end 
		 end
	end 

end

function SystemMessageData.deleteOutMessages( data )
	if not data then 
		return 
	end 
	local curTime 	= os.time();
	local date 		= os.date("*t", curTime);
	local curDate   = os.time({year=date.year, month=date.month, day=date.day, hour=0, min = 0, sec=0});

	--2012-09-01
	local limitTime = 15*24*3600

	local tmp = {}
	local outMesKeys = {}
	
	for k,v in pairs(data) do	
		--local y 	 = tonumber(string.sub((v.start_time),1,4))
		--local m 	 = tonumber(string.sub((v.start_time),6,7))
		---local d   	 = tonumber(string.sub((v.start_time),9,10))
		--local theDate = os.time({year=y,month=m,day=d,hour=0,min=0,sec=0})
		local theDate = (v.end_time)--:-------//20.16/2/19 ZainTan  
		if curDate - theDate > limitTime then --失效了
			table.insert(outMesKeys,v.id)
		else 
			local sortValue = {}
			sortValue.id 	= (v.id)--:
			sortValue.time 	= (v.start_time)--:
			table.insert(tmp,sortValue)
		end 	
	end

	table.sort(tmp, function ( a , b )
		return a.time > b.time
	end)

	for i=1,#outMesKeys do
		data[outMesKeys[i]] = nil
	end
	for i=SystemMessageData.MAX_RECORD_NUM+1,#tmp do 
		data[tostring(tmp[i].id)] = nil
	end 
	return data 

end

