--数据格式
--回赠金币数据

FeedbackGoldData = class()
-----------------------------------------------------------------------------------

function FeedbackGoldData.loadData(myId)
	local myId 				= "" .. myId; --强制转为字符串
	return g_DiskDataMgr:getFileKeyValue(kFeedbackRecords,"feedback" ..myId,{})
end

function FeedbackGoldData.saveData( myId,tableData )
	DebugLog("FeedbackGoldData.saveData")
	mahjongPrint(tableData)

	local myId 				= "" .. myId; --强制转为字符串	
	--local fid               = "" .. fid;
	g_DiskDataMgr:setFileKeyValue(kFeedbackRecords,"feedback" ..myId,tableData)
end


function FeedbackGoldData.loadNativeDataIntoDest(myId, dest)
	local myId 				= "" .. myId; --强制转为字符串
	local data = FeedbackGoldData.loadData(myId)	

	local curTime 	= os.date("%Y%m%d",os.time());
	if data then 
		for i=1,#data do
			news = {}
			news.type 		= data[i].type
			news.mid 		= data[i].mid
			news.mnick 		= data[i].mnick
			news.sex 		= data[i].sex
			news.photo 		= data[i].photo
			news.money 		= data[i].money
			news.sendtime 	= data[i].sendtime
			news.vip        = data[i].vip
			news.charms     = data[i].charms
			news.needFeedback = true

			---5.1.4新需求 回赠消息 超过一天 不再显示
			if tonumber(news.type) == 2 then 
				local sendtime = os.date("%Y%m%d",news.sendtime);
				if sendtime ~= curTime then 
					news = nil 
				end 
			end 
			
			if news  then 
				table.insert(dest,news)	
			end 		
		end
	end 
	return dest
end


function FeedbackGoldData.insertARecord( myId,message)
	local myId 				= "" .. myId; --强制转为字符串
	--local fid               = "" .. fid;

	local data = FeedbackGoldData.loadData(myId)

	if data then
		news = {}

		news.type 		= message.type
		news.mid 		= message.mid
		news.mnick 		= message.mnick
		news.sex 		= message.sex
		news.photo 		= message.photo
		news.money 		= message.money
		news.sendtime 	= message.sendtime
		news.vip        = message.vip
		news.charms     = message.charms

		table.insert(data,news)
		FeedbackGoldData.saveData(myId,data)		
	end 

end

function FeedbackGoldData.deleteARecord( myId, fid)
	local myId 				= "" .. myId; --强制转为字符串
	--local fid               = "" .. fid;

	local data = FeedbackGoldData.loadData(myId)
	if data then 
		for i=1,#data do 
			if data[i].mid == fid then 
				table.remove(data,i)
				FeedbackGoldData.saveData(myId,data)	
				return
			end 
		end 
	end 
	return 
end

