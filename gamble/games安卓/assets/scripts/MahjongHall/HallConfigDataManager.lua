-- HallConfigDataManager.lua
-- Author: ClarkWu
-- Date: 2015-01-24
-- Last modification : 2015-01-25
-- Description: 用于管理大厅配置数据[中间只负责接收数据，不做任何UI处理]

HallConfigDataManager = class();

HallConfigDataManager.instance = nil;

function HallConfigDataManager.getInstance()
	if not HallConfigDataManager.instance then
		HallConfigDataManager.instance = new(HallConfigDataManager);
	end
	return HallConfigDataManager.instance;
end

function HallConfigDataManager.ctor(self)
	self.m_hallData = {}; -- 存放从文件中取出的大厅数据

	--数据池中的东西客户端暂时写死
	self.m_hallData["xl"] = {}; 	-- 血流场
	self.m_hallData["xz"] = {};		-- 血战场
	self.m_hallData["match"] = {}; 	-- 比赛场
	self.m_hallData["lfp"] = {};    -- 两房场
	self.m_hallData["typelist"] = {};   --新游戏场
	self.m_setDataFlag = false;		-- 是否设置过数据
	self.m_typeDataMap = {};
	self.m_onlineText = "人在线";   -- 在线文字标识
	self.m_diText = "底"; 		    -- 底注文字标识
    self.m_onlineCnt = {["xl"] = {}, ["xz"] = {}};--在线人数缓存;
end

function HallConfigDataManager.insertHallDataTypeList( self, data_type , data_level )
	-- body
	for k,value in pairs(self.m_hallData["typelist"]) do
		if value.type == data_type then 
			table.insert(value.levelList,data_level)
			break
		end
	end
end

function HallConfigDataManager.sortLevelListInTypeList( self)
	-- body
	local sortFuc = function ( a , b )	
		return tonumber(self:returnDataByLevel(a).require) > tonumber(self:returnDataByLevel(b).require)
	end
	for k,value in pairs(self.m_hallData["typelist"]) do
		table.sort(value.levelList, sortFuc)
	end
end
--设置大厅配置信息
function HallConfigDataManager.setHallDataFromCacheData(self,data)
	if not data then 
		return ;
	end
	--mahjongPrint(data)
	--DebugLog("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
	self:clearAllHallData();

	self.m_setDataFlag = true;

	if data.memstr then 
		self.m_onlineText = string.gsub(data.memstr,"##","") ;
	end

	if data.valuestr then 
		self.m_diText = string.gsub(data.valuestr,"@@","") ;
	end

	if data.imgurl then 
		self.m_imgUrl = data.imgurl or "";
	end

	self.m_typeDataMap = {}
	--解析游戏场数据
	if data.typelist then
		for k,v in pairs(data.typelist) do
			self.m_hallData["typelist"][#self.m_hallData["typelist"]+1] = {};
			self.m_hallData["typelist"][#self.m_hallData["typelist"]].type       = v.type
			self.m_hallData["typelist"][#self.m_hallData["typelist"]].limit      = v.limit
			self.m_hallData["typelist"][#self.m_hallData["typelist"]].name       = v.name
			self.m_hallData["typelist"][#self.m_hallData["typelist"]].desc       = v.desc
			self.m_hallData["typelist"][#self.m_hallData["typelist"]].onlineText = self.m_onlineText;
			self.m_hallData["typelist"][#self.m_hallData["typelist"]].index      = v.index or #self.m_hallData["typelist"]
			self.m_hallData["typelist"][#self.m_hallData["typelist"]].nameUrl    = self.m_imgUrl .. ( v.img or "")
			self.m_hallData["typelist"][#self.m_hallData["typelist"]].sub        = v.sub or ""
			NativeManager.getInstance():downloadImage( self.m_hallData["typelist"][#self.m_hallData["typelist"]].nameUrl );
			self.m_hallData["typelist"][#self.m_hallData["typelist"]].levelList  = {}
		end

		table.sort( self.m_hallData["typelist"], function(a ,b)
													return a.type < b.type 
		  										 end)
	else
		NetCacheDataManager.getInstance():clearCache();
		NetCacheDataManager.getInstance():activeNotifyReceiver(PHP_CMD_REQUEST_NEW_HALL_CONFIG);
		return;
	end

	-- 解析血流场的数据
	if data.xl then 
		for k ,v in pairs(data.xl) do 
			self.m_hallData["xl"][#self.m_hallData["xl"]+1] = {};
			self.m_hallData["xl"][#self.m_hallData["xl"]].type      = v.type 
			self.m_hallData["xl"][#self.m_hallData["xl"]].index     = v.index 							  -- 排序(客户端不排序)
			self.m_hallData["xl"][#self.m_hallData["xl"]].level     = v.level 							  -- 场次level
			self.m_hallData["xl"][#self.m_hallData["xl"]].key     	= "xl"; 										  -- key值
			self.m_hallData["xl"][#self.m_hallData["xl"]].name      = v.name  							  -- 名字
			self.m_hallData["xl"][#self.m_hallData["xl"]].di    	= v.value   						  -- 底注
			self.m_hallData["xl"][#self.m_hallData["xl"]].require   = v.require    					  -- 准入金币
			self.m_hallData["xl"][#self.m_hallData["xl"]].xzrequire = v.xzrequire  					  -- 房间内玩牌金币下限
			self.m_hallData["xl"][#self.m_hallData["xl"]].uppermost = v.uppermost  					  -- 房间上限
			self.m_hallData["xl"][#self.m_hallData["xl"]].outtime   = v.time 	   						  -- 出牌时间
			self.m_hallData["xl"][#self.m_hallData["xl"]].dq 	    = v.dq or 0  						  -- 是否定缺
			self.m_hallData["xl"][#self.m_hallData["xl"]].hsz 	    = v.hsz or 0  						  -- 是否换三张
			self.m_hallData["xl"][#self.m_hallData["xl"]].nameUrl   = self.m_imgUrl .. v.list_img or ""  -- 场次图片url
			self.m_hallData["xl"][#self.m_hallData["xl"]].rNameImg  = self.m_imgUrl .. v.room_img or ""  -- 房间内图片url
			self.m_hallData["xl"][#self.m_hallData["xl"]].onlineText= self.m_onlineText;
			self.m_hallData["xl"][#self.m_hallData["xl"]].diText 	= self.m_diText;
			self.m_hallData["xl"][#self.m_hallData["xl"]].vip       = v.vip or 0

			self:insertHallDataTypeList(v.type,v.level)
			self.m_typeDataMap[v.type] = "xl"
		end

		table.sort(self.m_hallData["xl"], function(a ,b)
													return a.require > b.require 
		  										 end)		
	end

	

	-- 解析血战场的数据
	if data.xz then 
		for k ,v in pairs(data.xz) do 
			self.m_hallData["xz"][#self.m_hallData["xz"]+1] = {};
			self.m_hallData["xz"][#self.m_hallData["xz"]].type      = v.type 	
			self.m_hallData["xz"][#self.m_hallData["xz"]].index     = v.index 								-- 排序(客户端不排序)
			self.m_hallData["xz"][#self.m_hallData["xz"]].level     = v.level 								-- 场次level
			self.m_hallData["xz"][#self.m_hallData["xz"]].name      = v.name  								-- 名字
			self.m_hallData["xz"][#self.m_hallData["xz"]].di    	= v.value   							-- 底注
			self.m_hallData["xz"][#self.m_hallData["xz"]].key     	= "xz";												-- key值
			self.m_hallData["xz"][#self.m_hallData["xz"]].require   = v.require    						-- 准入金币
			self.m_hallData["xz"][#self.m_hallData["xz"]].xzrequire = v.xzrequire  						-- 房间内玩牌金币下限
			self.m_hallData["xz"][#self.m_hallData["xz"]].uppermost = v.uppermost  						-- 房间上限
			self.m_hallData["xz"][#self.m_hallData["xz"]].outtime   = v.time 	   							-- 出牌时间
			self.m_hallData["xz"][#self.m_hallData["xz"]].dq 	    = v.dq or 0   							-- 是否定缺
			self.m_hallData["xz"][#self.m_hallData["xz"]].hsz 	    = v.hsz or 0							-- 是否换三张
			self.m_hallData["xz"][#self.m_hallData["xz"]].nameUrl   = self.m_imgUrl .. v.list_img or ""  	-- 场次图片url
			self.m_hallData["xz"][#self.m_hallData["xz"]].rNameImg  = self.m_imgUrl .. v.room_img or ""  	-- 房间内图片url
			self.m_hallData["xz"][#self.m_hallData["xz"]].onlineText= self.m_onlineText;
			self.m_hallData["xz"][#self.m_hallData["xz"]].diText 	= self.m_diText;  	
			self.m_hallData["xz"][#self.m_hallData["xz"]].vip       = v.vip or 0
			self:insertHallDataTypeList(v.type,v.level)
			self.m_typeDataMap[v.type] = "xz"
		end

		table.sort(self.m_hallData["xz"], function(a ,b)
													return a.require > b.require 
		  										 end)
	end
	DebugLog(self.m_hallData["xz"])
	-- 解析更多场两房牌的东西
	if data.lfp then 
		for k,v in pairs(data.lfp) do 
			self.m_hallData["lfp"][#self.m_hallData["lfp"]+1] = {};
			self.m_hallData["lfp"][#self.m_hallData["lfp"]].type     	= v.type 
			self.m_hallData["lfp"][#self.m_hallData["lfp"]].index   	= v.index  							-- 排序(客户端不排序)
			self.m_hallData["lfp"][#self.m_hallData["lfp"]].level 		= v.level 								-- 场次level
			self.m_hallData["lfp"][#self.m_hallData["lfp"]].name    	= v.name   							-- 名字
			self.m_hallData["lfp"][#self.m_hallData["lfp"]].value  		= v.value 								-- 底注
			self.m_hallData["lfp"][#self.m_hallData["lfp"]].require		= v.require							-- 准入
			self.m_hallData["lfp"][#self.m_hallData["lfp"]].key     	= "lfp"											-- key值
			self.m_hallData["lfp"][#self.m_hallData["lfp"]].xzrequire   = v.xzrequire							-- 房间内玩牌金币下限
			self.m_hallData["lfp"][#self.m_hallData["lfp"]].uppermost   = v.uppermost							-- 房间上限
			self.m_hallData["lfp"][#self.m_hallData["lfp"]].time   		= v.time								-- 出牌时间
			self.m_hallData["lfp"][#self.m_hallData["lfp"]].nameUrl   	= self.m_imgUrl .. v.list_img or ""  	-- 场次图片url
			self.m_hallData["lfp"][#self.m_hallData["lfp"]].rNameImg  	= self.m_imgUrl .. v.room_img or ""  	-- 房间内图片url
			self.m_hallData["lfp"][#self.m_hallData["lfp"]].hsz   		= v.hsz								-- 换三张
			self.m_hallData["lfp"][#self.m_hallData["lfp"]].dq   		= v.dq	
			self.m_hallData["lfp"][#self.m_hallData["lfp"]].vip         = v.vip or 0
			self.m_typeDataMap[v.type] = "lfp"
		end

		table.sort(self.m_hallData["lfp"], function(a ,b)
													return a.require > b.require 
		  										 end)
	end

	self:sortLevelListInTypeList();
end

--设置比赛场配置信息
function HallConfigDataManager.setMatchDataFromCacheData(self,data)
	if not data or ( data and #data <= 0 ) then
		return;
	end

	self:clearAllMatchData();

	for k,v in pairs(data) do 
        local matchData = {};
		matchData.id 			= v.id				-- 比赛配置id
		matchData.type 		= tonumber(v.type) or GameConstant.matchTypeConfig.award;----比赛类型 1:人满赛 2:大奖赛（旧定时赛） 3:新定时赛
		matchData.index 		= v.index			-- 比赛序列(php排序规则)
		matchData.level 		= v.level			-- 比赛场次level
		matchData.value 		= v.value			-- 比赛底注
		matchData.require		= v.require		-- 比赛报名限制准入
		matchData.time		= v.time			-- 比赛出牌时间
		matchData.paytime		= v.paytime		-- 比赛用户达到底线金币时，等待玩家充值时间
		matchData.tax			= v.tax			-- 比赛台费
		matchData.name		= v.name			-- 比赛场名字
		matchData.apply		= v.apply			-- 比赛报名费
		matchData.sub			= v.sub			-- 比赛角标 0:无  1:话费  2:实物  3:热门  4:活动 
		matchData.xz			= v.xz or 0;		-- 比赛场 血战玩法 0 不是 1 是
		matchData.xl			= v.xl or 0; 		-- 比赛场 血流玩法 0 不是 1 是
		matchData.lfp			= v.lf or 0;		-- 比赛场 两房牌玩法 0 不是 1 是
		matchData.hsz			= v.hs or 0;		-- 比赛场 换三张玩法 0 不是 1 是
		matchData.hlz			= v.hl or 0;		-- 比赛场 换两张玩法 0 不是 1 是
		matchData.dq			= v.dq or 0;		-- 比赛场 定缺玩法 0 不是 1 是
		matchData.exceed	    = v.exceed			-- 比赛场 入场金币上限
		matchData.offline   	= v.offline		-- 比赛场 房间内金币下限
		matchData.person		= v.person			-- 比赛场 开赛人数
		matchData.recommend	= v.recommend		-- 比赛场 推荐商品金额
		matchData.kemp		= v.kemp			-- 比赛场 冠军奖励dingshic --kemp 已经修改 ：下面代码
        --matchData.img	= v.img		-- 比赛场 界面的title图片
        matchData.showpic	= v.showpic		-- 比赛场列表 界面的item图片
        

		matchData.free        = v.free           -- 1免费金币赛, 0其他
		
		matchData.nameUrl		= v.img or ""-- 比赛场列表 界面的item图片			-- 
		NativeManager.getInstance():downloadImage( matchData.nameUrl );	
        NativeManager.getInstance():downloadImage( matchData.showpic );		
		if 2 == tonumber(matchData.type) then
			matchData.starttime	= v.starttime	-- 比赛场 定时赛才有，开赛时间和结束时间的字串
			matchData.st			= tonumber(v.st)			-- 比赛场 定时赛才有，开赛时间时间戳
			matchData.et			= tonumber(v.et)			-- 比赛场 定时赛才有，结束时间时间戳
		end

        --前三名的冠军奖励配置
        local qian3 = {};
        v.qian3 = v.qian3 or {};
        for i = 1, #v.qian3 do
            local k = v.qian3[i];
            if not k then
                break;
            end
            local tmp = {};
            tmp.pic = k.pic;
            tmp.t = k.ward;
            table.insert(qian3, tmp);
        end
        matchData.qian3 = qian3;

        matchData.applyprop = v.applyprop or {};
        matchData.rank_timer = v.jfbsxpl or {};--php配置的刷新排行榜的计时器时间
        self.m_hallData["match"][#self.m_hallData["match"]+1] = matchData;
	end
    if HallScene_instance and HallScene_instance.matchApplyWindow then
        HallScene_instance.matchApplyWindow:setAwardView();
    end
end

--根据level获取php后台该level所在的id
HallConfigDataManager.get_php_id_by_level = function (self, level)
    if not level then
        return nil
    end
    if self.m_hallData["match"] and #self.m_hallData["match"] > 0 then
        for i = 1, #self.m_hallData["match"] do
            if not self.m_hallData["match"][i] then
                return nil;
            end

            if level == self.m_hallData["match"][i].level then
                return self.m_hallData["match"][i].id;
            end
        end

    end

end
----------------------------------------------------------------新游戏场相关----------------------------------------------------------
--返回新游戏场的所有数据
function HallConfigDataManager.returnHallDataForTypelist(self)
	return self.m_hallData["typelist"];
end

--通过比赛id获取比赛数据
function HallConfigDataManager.getMatchDataByMatchId(self, matchId)
    if not matchId then
        return nil;
    end
	local data = self.m_hallData["match"];
    for i = 1, #data do
        if matchId == data[i].id then
            return data[i];
        end
    end
    return nil;
end

function HallConfigDataManager.returnTypeNameForLevel( self,curLevel )
	if not curLevel then 
		return nil 
	end
	local curType  = self:returnTypeForLevel(curLevel)
	---xl 特殊处理
	if tonumber(curType) == tonumber(self.m_hallData["xl"][1].type) then 
		for i=1,#self.m_hallData["xl"] do
			if tonumber(curLevel) == tonumber(self.m_hallData["xl"][i].level) then 
				return self.m_hallData["xl"][i].name
			end 
		end
	end 	


	local typeData = self:returnTypeDataForType(curType) 
	if typeData then 
		return typeData.name
	end 
	return nil
end

function HallConfigDataManager.returnTypeDataForType( self,curType)
	if not curType then 
		return nil 
	end 
	for i=1,#self.m_hallData["typelist"] do
		if tonumber(curType) == tonumber(self.m_hallData["typelist"][i].type) then 
			return self.m_hallData["typelist"][i]
		end
	end
	return nil
end

function HallConfigDataManager.returnTypeForLevel(self,curLevel)
	if curLevel == nil or curLevel == 0 or tostring(curLevel) == "" then 
		return nil 
	end 
	DebugLog("HallConfigDataManager.returnTypeForLevel")
	DebugLog("args:")
	DebugLog(curLevel)
	for k_type,v_table in pairs( self.m_hallData["typelist"] ) do 
		for k, level in pairs(v_table.levelList) do
			DebugLog("level type " .. type(level))
			DebugLog("curLevel type " .. type(curLevel))
			if tonumber(level) == tonumber(curLevel) then 
				return v_table.type or k_type
			end
		end 
		--end
	end
	DebugLog("typelist not find")
	DebugLog(curLevel)
	DebugLog(type(curLevel))
	mahjongPrint(self.m_hallData["lfp"])
	for i = 1,#self.m_hallData["lfp"] do 
		DebugLog(type(curLevel))
		DebugLog(type(self.m_hallData["lfp"][i].level))
		DebugLog("curLevel: " .. curLevel .. "self.m_hallData['fp'][i].level" .. self.m_hallData["lfp"][i].level)
		
		if tonumber(curLevel) == tonumber(self.m_hallData["lfp"][i].level) then 
			return self.m_hallData["lfp"][i].type
		end 
	end 
	DebugLog("not find type")
	return nil;
end
--返回 money 满足该curType类场中最高require的房间信息
--如果都不满足 返回 false,最低场房间信息
function HallConfigDataManager.returnMaxRequireHallDataForType( self,curType, money, vipLevel)
	----------------levellist已经排序过 保证是require  是从大到小找
	local data = nil
	DebugLog("HallConfigDataManager.returnMaxRequireHallDataForType")
	for iType,vTable in pairs(self.m_hallData["typelist"]) do 
		DebugLog("find type: curType"..curType .. " =? typeInlist:"..iType)
	    if tonumber(vTable.type) and tonumber(vTable.type) == tonumber(curType) then  --正确查询方法
    	--if tonumber(iType) == tonumber(curType) then  --老版本错误查询方法
			DebugLog("match type!! start find suitable level... ")
			for k,v in pairs(vTable.levelList) do 
				data = self:returnDataByLevel( v )
				DebugLog("find level: curMoney"..money .. " <= ? level require:"..data.require)
				if tonumber(data.require) <= tonumber(money) then 
					DebugLog("money require match!  return true,data")
					if self:checkVipLevelConditionIsSatisfied(data,vipLevel) then 
						return true,data
					end
				end
			end
			return false,data
		end
	end
	--[[
	DebugLog("start find in lfp")
	if #self.m_hallData["lfp"] < 1 then 
		DebugLog("no lfp data,return false,nil")
		return false,data
	end 

	DebugLog("find type: curType"..curType .. " =? m_hallData [lfp][1].type:".. self.m_hallData["lfp"][1].type)
	if tonumber(curType) == tonumber(self.m_hallData["lfp"][1].type) then 
		for i =1,#self.m_hallData["lfp"] do 
			DebugLog("find lfp level: curMoney"..money .. " <= ? lfp level require:"..self.m_hallData["lfp"][i].require)
			if tonumber(self.m_hallData["lfp"][i].require) <= tonumber(money) then 
				DebugLog("money require match!  return true,data")
				if self:checkVipLevelConditionIsSatisfied(data,vipLevel) then 
					return true,data
				end
			end
		end
	end 
	--]]
	DebugLog("没有找到该类的场次,return false nil!")
	return false,data
end

function HallConfigDataManager.checkVipLevelConditionIsSatisfied(self,data, playerVip)
	if not playerVip then 
		playerVip = PlayerManager.getInstance():myself().vipLevel
	end
	if data and data.vip then
		local iVip = tonumber(data.vip) 
		if iVip == 0 or tonumber(playerVip) > iVip then 
			return true
		end 
	end
	return false
end

-- 找 > curLevel 的房间 找 能够进入的  从下往上找第一个符合要求的
function HallConfigDataManager.returnMinRequireHallDataForTypeAndLevel( self,curType, curLevel ,money,vipLevel)
	----------------levellist已经排序过 保证是level 是从大到小找
	DebugLog("HallConfigDataManager.returnMinRequireHallDataForTypeAndLevel")
	if not curType or not curLevel or not money or not vipLevel then 
		return false,nil 
	end 
	--mahjongPrint(self.m_typeDataMap)
    local key = self.m_typeDataMap[curType]
    local datalist = self.m_hallData[key]
    iLevel = tonumber(curLevel)
    iMoney = tonumber(money)
    if datalist then 
    	mahjongPrint(datalist)
    	local findIndex = -1
    	for i = 1,#datalist do 
    		if iLevel == tonumber(datalist[i].level) then 
    			findIndex = i 
    			break
    		end
    	end
    	DebugLog("find index = " .. tostring(findIndex))
    	DebugLog(type(iMoney))
    	for i = findIndex-1,1,-1 do 
    		if iMoney >= tonumber(datalist[i].require) and iMoney <= tonumber(datalist[i].uppermost) then 
    			DebugLog("true")
    			if self:checkVipLevelConditionIsSatisfied(datalist[i],vipLevel) then 
    				return true, datalist[i]
    			end
    		end
    	end
    end
    return false,nil
end


--通过底注.玩法来获取vip下限 (作用于包厢) 
---playType==1 血战  
---playType==2 血流
function HallConfigDataManager.getHallConfigVipLimitByDiAndPlayType( self, di, playType )
	local data = self:getHallConfigByDiAndPlayType(di,playType)
	if data then 
		return data.vip
	end 
	return 0
end

function HallConfigDataManager.getHallConfigByDiAndPlayType( self, di, playType )
	if not di or not playType then 
		return nil 
	end 
	local key = nil
	if bit.band(playType, 2) == 0 then 
		key = "xz"
	else 
		key = "xl"
	end

	if key and self.m_hallData[key] then 
		for i=1,#self.m_hallData[key] do
			if tonumber(self.m_hallData[key][i].di) == tonumber(di) then 
				return self.m_hallData[key][i]
			end
		end
	end 
	return nil
end


function HallConfigDataManager.returnLFPData( self,money,curVipLevel )
	-- body
	local vTable = self.m_hallData["lfp"]
	for i = 1,#vTable do 
		if vTable[i].require <= money then 
			return vTable[i]
		end
	end
	return nil
end

function HallConfigDataManager.returnKeyByType(self,sType)
	mahjongPrint(self.m_typeDataMap)
	if type(sType) ~= "string" then 
		sType = tostring(sType)
	end
	--DebugLog(type(sType))
	--DebugLog(sType)
	--DebugLog("ntype" .. self.m_typeDataMap[tonumber(sType)])
	return self.m_typeDataMap[sType] or self.m_typeDataMap[tonumber(sType)]
end

function HallConfigDataManager.returnDataByKey( self,skey,iMoney )
	-- body
	if not skey or not iMoney then 
		return false,nil
	end 

	DebugLog("key: " .. skey .. "iMoney: " .. tostring(iMoney) )
	if self.m_hallData[skey] then 
		--mahjongPrint(self.m_hallData[skey])
		for i=1,#self.m_hallData[skey] do 
			if tonumber(self.m_hallData[skey][i].require) <= iMoney then 
				if self:checkVipLevelConditionIsSatisfied(self.m_hallData[skey][i]) then 
					return true,self.m_hallData[skey][i]
				end
			end
		end
	end
	return false,nil
end

function HallConfigDataManager.returnDataByTypeAndMoney(self,sType,iMoney )
	-- body
	local key = self.m_typeDataMap[sType] or self.m_typeDataMap[tonumber(sType)]
	if key then 
		return self:returnDataByKey(key,iMoney)
	end
	return false,nil
end
------------------------------------------------------------------------------------------------------------------------------------


----------------------------------------------------------------血战场相关----------------------------------------------------------
--返回血战场的所有数据
function HallConfigDataManager.returnHallDataForXZ(self)
	return self.m_hallData["xz"];
end

--返回血战场的所有level数据
function HallConfigDataManager.returnHallDataForXZLevel(self)
	local levelArray = {};
	for i=1,#self.m_hallData["xz"] do
		levelArray[#levelArray + 1] = self.m_hallData["xz"][i].level;
	end
	return levelArray;
end

--返回血战场的所有require数据
function HallConfigDataManager.returnHallDataForXZRequire(self)
	local requireArray = {};
	for i=1,#self.m_hallData["xz"] do
		requireArray[#requireArray + 1] = self.m_hallData["xz"][i].require;
	end
	return requireArray;
end

--返回血战场的所有di数据
function HallConfigDataManager.returnHallDataForXZDi(self)
	local diArray = {};
	for i=1,#self.m_hallData["xz"] do
		diArray[#diArray + 1] = self.m_hallData["xz"][i].di;
	end
	return diArray;
end

--根据require找到对应的血战场
function HallConfigDataManager.returnHallDataForXZByRequire(self,requireMoney)
	if not requireMoney then 
		return false;
	end
	for i=1,#self.m_hallData["xz"] do 
		if self.m_hallData["xz"][i].require == requireMoney then 
			return true,self.m_hallData["xz"][i];
		end
	end
	return false;
end

--根据level找到对应的血战场
function HallConfigDataManager.returnHallDataForXZByLevel(self,level)
	if not level then 
		return false;
	end
	for i=1,#self.m_hallData["xz"] do 
		if self.m_hallData["xz"][i].level == level then 
			return true,self.m_hallData["xz"][i];
		end
	end
	return false;
end

--根据底注找到对应的血战场
function HallConfigDataManager.returnHallDataForXZByDi(self,di)
	if not di then 
		return false;
	end
	for i=1,#self.m_hallData["xz"] do
		if self.m_hallData["xz"][i].di == di then 
			return true,self.m_hallData["xz"][i];
		end
	end
	return false;
end

----------------------------------------------------------------血流场相关----------------------------------------------------------
--返回血流场的所有数据
function HallConfigDataManager.returnHallDataForXL(self)
	return self.m_hallData["xl"];
end

--返回血流场的所有level数据
function HallConfigDataManager.returnHallDataForXLLevel(self)
	local levelArray = {};

	for i=1,#self.m_hallData["xl"] do
		levelArray[#levelArray + 1] = self.m_hallData["xl"][i].level;
	end
	return levelArray;
end

--返回血流场的所有require数据
function HallConfigDataManager.returnHallDataForXLRequire(self)
	local requireArray = {};
	for i=1,#self.m_hallData["xl"] do
		requireArray[#requireArray + 1] = self.m_hallData["xl"][i].require;
	end
	return requireArray;
end

--返回血流场的所有di数据
function HallConfigDataManager.returnHallDataForXLDi(self)
	local diArray = {};
	for i=1,#self.m_hallData["xl"] do
		diArray[#diArray + 1] = self.m_hallData["xl"][i].di;
	end
	return diArray;
end

--根据require找到对应的血流场
function HallConfigDataManager.returnHallDataForXLByRequire(self,requireMoney)
	if not requireMoney then 
		return false;
	end
	for i=1,#self.m_hallData["xl"] do 
		if self.m_hallData["xl"][i].require == requireMoney then 
			return true,self.m_hallData["xl"][i];
		end
	end
	return false;
end

--根据level找到对应的血流场
function HallConfigDataManager.returnHallDataForXLByLevel(self,level)
	if not level then 
		return false;
	end
	for i=1,#self.m_hallData["xl"] do 
		if self.m_hallData["xl"][i].level == level then 
			return true,self.m_hallData["xl"][i];
		end
	end
	return false;
end

--根据底注找到对应的血流场
function HallConfigDataManager.returnHallDataForXLByDi(self,di)
	if not di then 
		return false;
	end
	for i=1,#self.m_hallData["xl"] do
		if self.m_hallData["xl"][i].di == di then 
			return true,self.m_hallData["xl"][i];
		end
	end
	return false;
end

---------------------------------------------------------------更多相关-------------------------------------------------------------
--返回更多场两房牌的信息(当前版本只有一项，则只需要返回第一项给外部即可)
function HallConfigDataManager.returnHallDataForLFP(self)
	return self.m_hallData["lfp"][1];
end

function HallConfigDataManager.returnMinHallDataForLFP(self)
	return self.m_hallData["lfp"][#self.m_hallData["lfp"]];
end



--根据level找到更多的两房场的数据信息
function HallConfigDataManager.returnHallDataForLFPByLevel(self,level)
	for i = 1,#self.m_hallData["lfp"] do 
		if self.m_hallData["lfp"][i].level == level then 
			return self.m_hallData["lfp"][i],"lfp"
		end
	end 
end

-- 返回两房牌所有的level
function HallConfigDataManager.returnAllDataForLFPLevel(self)
	local newLevels = {};
	for i = 1,#self.m_hallData["lfp"] do 
		newLevels[#newLevels+1] = self.m_hallData["lfp"][i].level;
	end
	return newLevels;
end

-- 返回两房牌的所有require
function HallConfigDataManager.returnAllDataForLFPRequire(self)
	local newRequires = {};
	for i = 1,#self.m_hallData["lfp"] do 
		newRequires[#newRequires+1] = self.m_hallData["lfp"][i].require;
	end
	return newRequires;
end

---------------------------------------------------------------比赛场相关-------------------------------------------------------------
--返回比赛场的所有信息
function HallConfigDataManager.returnMatchData(self)
	return self.m_hallData["match"];
end

--返回level对应的比赛信息
function HallConfigDataManager.returnMatchDataByLevel(self,level)
	if not level then 
		return ;
	end
	for i = 1,#self.m_hallData["match"] do 
		if tonumber(self.m_hallData["match"][i].level) == tonumber(level) then 
			return self.m_hallData["match"][i];
		end
	end
end

function HallConfigDataManager.returnMatchTimeData(self)
	local t = {};

	for i = 1,#self.m_hallData["match"] do 
		if self.m_hallData["match"][i].type == GameConstant.matchTypeConfig.playTime then 
			table.insert(t, self.m_hallData["match"][i]);
		end
	end
	if t then
		table.sort(t,function(a,b) return a.require > b.require end );
	end

	return t ;
end

function HallConfigDataManager.returnMatchAwardData(self)
	local t = {};

	for i = 1,#self.m_hallData["match"] do 
		if self.m_hallData["match"][i].type == GameConstant.matchTypeConfig.award then 
			table.insert(t, self.m_hallData["match"][i]);
		end
	end
	if t then
		table.sort(t,function(a,b) return a.require > b.require end );
	end

	return t ;
end

function HallConfigDataManager.returnMatchPeopleData(self)
	local t = {};

	for i = 1,#self.m_hallData["match"] do 
		if self.m_hallData["match"][i].type == GameConstant.matchTypeConfig.playerNum then 
			table.insert(t, self.m_hallData["match"][i]);
		end
	end
	if t then
		table.sort(t,function(a,b) return a.require > b.require end );
	end

	return t ;
end


--按照require升序返回比赛列表
function HallConfigDataManager.getAscendMatchListByRequire(self)
	table.sort(self.m_hallData["match"],function(a,b) return a.require < b.require end );
	return self.m_hallData["match"];
end

--按照require降序返回比赛列表
function HallConfigDataManager.getDescendMatchListByRequire(self)
	table.sort(self.m_hallData["match"],function(a,b) return a.require > b.require end );
	return self.m_hallData["match"];
end

--根据requires找到对应的比赛信息
function HallConfigDataManager.returnMatchDataByRequire(self,requires)
	if not requires then 
		return ;
	end
	for i = 1,#self.m_hallData["match"] do 
		if self.m_hallData["match"][i].require == requires then 
			return self.m_hallData["match"][i];
		end
	end
end


function HallConfigDataManager.addMatchList( self, data)
DebugLog("tttt addMatchList");
	if not data then 
		return ;
	end
	
	local t = {};
	t.id 			= data.id				-- 比赛配置id
	t.type 		    = data.type		-- 比赛类型 1:人满开赛 2:定时赛
	t.index 		= data.index			-- 比赛序列(php排序规则)
	t.level 		= data.level			-- 比赛场次level
	t.value 		= data.value			-- 比赛底注
	t.require		= data.require		-- 比赛报名限制准入
	t.time		    = data.time			-- 比赛出牌时间
	t.paytime		= data.paytime		-- 比赛用户达到底线金币时，等待玩家充值时间
	t.tax			= data.tax			-- 比赛台费
	t.name		    = data.name			-- 比赛场名字
	t.apply		    = data.apply			-- 比赛报名费
	t.sub			= data.sub			-- 比赛角标 0:无  1:话费  2:实物  3:热门  4:活动 
	t.xz			= data.xz or 0;		-- 比赛场 血战玩法 0 不是 1 是
	t.xl			= data.xl or 0; 		-- 比赛场 血流玩法 0 不是 1 是
	t.lfp			= data.lf or 0;		-- 比赛场 两房牌玩法 0 不是 1 是
	t.hsz			= data.hs or 0;		-- 比赛场 换三张玩法 0 不是 1 是
	t.hlz			= data.hl or 0;		-- 比赛场 换两张玩法 0 不是 1 是
	t.dq			= data.dq or 0;		-- 比赛场 定缺玩法 0 不是 1 是
	t.exceed	    = data.exceed			-- 比赛场 入场金币上限
	t.offline	    = data.offline		-- 比赛场 房间内金币下限
	t.person		= data.person			-- 比赛场 开赛人数
	t.recommend	    = data.recommend		-- 比赛场 推荐商品金额

	if 2 == tonumber(t.type) then
		t.starttime = data.starttime		-- 比赛场 定时赛才有，开赛时间和结束时间的字串
		t.st 		= tonumber(data.st)				-- 比赛场 定时赛才有，开赛时间时间戳
		t.et 		= tonumber(data.et)				-- 比赛场 定时赛才有，结束时间时间戳
	end

    t.kemp		    = data.kemp			-- 比赛场 冠军奖励
    --前三名的冠军奖励配置
    local qian3 = {};
    data.qian3 = data.qian3 or {};
    for i = 1, #data.qian3 do
        local k = data.qian3[i];
        if not k then
            break;
        end
        local tmp = {};
        tmp.pic = k.pic;
        tmp.t = k.ward;
        table.insert(qian3, tmp);
    end
    t.qian3 = qian3;
    t.applyprop = data.applyprop or {};
    t.rank_timer = data.jfbsxpl or {};--php配置的刷新排行榜的计时器时间
	table.insert(self.m_hallData["match"], t);

    if HallScene_instance and HallScene_instance.matchApplyWindow then
        HallScene_instance.matchApplyWindow:setAwardView();
    end
end

function HallConfigDataManager.deleteMatchList( self, id )
	if not id then 
		return ;
	end

	if 1 > #self.m_hallData["match"] then
		return;
	end

	for i = 1,#self.m_hallData["match"] do 
		if tonumber(self.m_hallData["match"][i].id) == tonumber(id) then 
			table.remove(self.m_hallData["match"], i);
			return;
		end
	end
end

---------------------------------------------------------------其    他-------------------------------------------------------------
--是否设置过大厅数据
function HallConfigDataManager.isSetHallData(self)
	return (#self.m_hallData["xz"] > 0) and (#self.m_hallData["xl"] > 0 );
end

--是否设置过比赛场数据
function HallConfigDataManager.isSetMatchData(self)
	return (#self.m_hallData["match"] > 0);
end

--返回所有的大厅数据
function HallConfigDataManager.returnAllHallData(self)
	return self.m_hallData["xz"],self.m_hallData["xl"],self.m_hallData["more"];
end

--返回所有场次的level(血战+血流)
--(用于好友邀请进房间) 漏掉了两房牌的情况
function HallConfigDataManager.returnAllHallDataLevel(self)
	local levelArray = {};
	local xzLevelArray = self:returnHallDataForXZLevel();
	local xlLevelArray = self:returnHallDataForXLLevel();
	for k=1,#xzLevelArray do 
		levelArray[#levelArray + 1] = xzLevelArray[k];
	end
	for k=1,#xlLevelArray do 
		levelArray[#levelArray + 1] = xlLevelArray[k];
	end

	for k=1,#self.m_hallData["lfp"] do 
		levelArray[#levelArray + 1] = self.m_hallData["lfp"][k].level;
	end 
	table.sort(levelArray);
	return levelArray;
end

--返回场次的require(血战+血流)
function HallConfigDataManager.returnAllHallConfigRequire(self)
	local requireArray = {};
	local xzRequireArray = self:returnHallDataForXZRequire();
	local xlRequireArray = self:returnHallDataForXLRequire();
	for k=1,#xzRequireArray do 
		requireArray[#requireArray + 1] = xzRequireArray[k];
	end
	for k=1,#xlRequireArray do 
		requireArray[#requireArray + 1] = xlRequireArray[k];
	end
	table.sort(requireArray);

	return requireArray;
end

--返回场次的level(血战+血流)
function HallConfigDataManager.returnAllHallConfigLevel(self)
	local levelArray = {};
	local xzLevelArray = self:returnHallDataForXZLevel();
	local xlLevelArray = self:returnHallDataForXLLevel();
	for k=1,#xzLevelArray do 
		levelArray[#levelArray + 1] = xzLevelArray[k];
	end
	for k=1,#xlLevelArray do 
		levelArray[#levelArray + 1] = xlLevelArray[k];
	end
	table.sort(levelArray);

	return levelArray;
end

--根据require返回对应的血战场或血流场，如果require相同，优先返回血战场(血战+血流)
function HallConfigDataManager.returnHallConfigByRequire(self,requireMoney)
	local hallData;
	local xzFlag,tempXZData = self:returnHallDataForXZByRequire(requireMoney);
	if xzFlag then 
		hallData = tempXZData;
		return hallData,"xz";
	end
	local xlFlag,tempXLData = self:returnHallDataForXLByRequire(requireMoney);
	if xlFlag then 
		hallData = tempXLData;
		return hallData,"xl";
	end
	return hallData;
end

--根据level返回对应的血战场或血流场，如果level相同，优先返回血战场(血战+血流)
function HallConfigDataManager.returnHallConfigByLevel(self,level)
	local hallData;
	local xzFlag,tempXZData = self:returnHallDataForXZByLevel(level);
	if xzFlag then 
		hallData = tempXZData;
		return hallData,"xz";
	end
	local xlFlag,tempXLData = self:returnHallDataForXLByLevel(level);
	if xlFlag then 
		hallData = tempXLData;
		return hallData,"xl";
	end
	return hallData;
end

--根据底注返回对应的血战场或血流场，如果底注相同，优先返回血战场(血战+血流)
function HallConfigDataManager.returnLevelFromHallConfigByDi(self,di)
	local hallData;
	local xzFlag,tempXZData = self:returnHallDataForXZByDi(di);
	if xzFlag then 
		hallData = tempXZData;
		return hallData,"xz";
	end
	local xlFlag,tempXLData = self:returnHallDataForXLByDi(di);
	if xlFlag then 
		hallData = tempXLData;
		return hallData,"xl";
	end
	return hallData;
end

--如果玩家在血战场，那么他点击更多或者去低倍场会优先找到他当前所在的场次，没有再去匹配血流场，相反亦如是
--所以当前方法根据key值找到所对应的场次level
function HallConfigDataManager.changeAllLevelsFromHallDataByKey(self,key)
	if not key then 
		return self:returnAllHallConfigLevel();
	elseif key == "xl" then 
		return self:returnHallDataForXZLevel();
	elseif key == "xz" then 
		return self:returnHallDataForXLLevel();
	elseif key == "lfp" then 
		return self:returnAllDataForLFPLevel();
	end
end

--如果玩家在血战场，那么他点击更多或者去低倍场会优先找到他当前所在的场次，没有再去匹配血流场，相反亦如是
--所以当前方法根据key值找到所对应的场次require
function HallConfigDataManager.changeAllRequiresFromHallDataByKey(self,key)
	if not key then 
		return self:returnAllHallConfigRequire();
	elseif key == "xl" then 
		return self:returnHallDataForXLRequire();
	elseif key == "xz" then 
		return self:returnHallDataForXZRequire();
	elseif key == "lfp" then 
		return self:returnAllDataForLFPRequire();
	end
end

function HallConfigDataManager.returnDataByLevel(self, level)
	if not level then 
		return ;
	end
	for i = 1,#self.m_hallData["xl"] do 
		if self.m_hallData["xl"][i].level == level then 
			return self.m_hallData["xl"][i], "xl";
		end
	end

	for i = 1,#self.m_hallData["xz"] do 
		if self.m_hallData["xz"][i].level == level then 
			return self.m_hallData["xz"][i], "xz";
		end
	end	

	for i = 1,#self.m_hallData["match"] do 
		if self.m_hallData["match"][i].level == level then 
			return self.m_hallData["match"][i], "match";
		end
	end	

	for i = 1,#self.m_hallData["lfp"] do 
		if self.m_hallData["lfp"][i].level == level then 
			return self.m_hallData["lfp"][i], "lfp";
		end
	end	
    for i = 1,#self.m_hallData["typelist"] do 
		if self.m_hallData["typelist"][i].level == level then 
			return self.m_hallData["typelist"][i], "typelist";
		end
	end
    
end

function HallConfigDataManager.checkIsSatifiedEnterCondition( self, money, vipLevel, level, di,playType)
	local errorMsg = nil

	if not level then 
		errorMsg = "无法追踪好友，请稍后再试"-- "无法找到该场次level=nil的信息"
		return false,errorMsg
	end

	local myMoney    = tonumber(money or 0)
	local myVipLevel = tonumber(vipLevel or 0) 
	local configData = self:returnDataByLevel(level)
	if not configData and level == 50 then 
		if not di then -----没有底注信息  跟踪的好友在包厢  准入限制由server判断 客户端信息不足
			return true
		end 
		configData = self:getHallConfigByDiAndPlayType(di,playType)
	end 

	if configData then 
		if myMoney < tonumber(configData.require) then 
			errorMsg = "金币不足,无法进入该房间"
			return false,errorMsg
		end 
		if myMoney > tonumber(configData.uppermost) then 
			errorMsg = "金币超过该房间上限,无法进入该房间!"
			return false,errorMsg			
		end 

		local vip = tonumber(configData.vip)
		if vip and vip ~= 0 and  myVipLevel <= vip then 
			errorMsg = "VIP等级不足,无法进入该房间!"
			return false,errorMsg
		end 
	else 
		errorMsg = "无法追踪好友，请稍后再试"--"无法找到该场次level="..level.."的信息"
		return false,errorMsg
	end
	return true
end


function HallConfigDataManager.clearAllHallData(self)
	self.m_hallData["xl"] = {}; 	-- 血流场
	self.m_hallData["xz"] = {};		-- 血战场
	self.m_hallData["lfp"] = {};    -- 两房场

	self.m_hallData["typelist"] = {};   --新游戏场
	self.m_setDataFlag = false;
end

function HallConfigDataManager.clearAllMatchData(self)
	self.m_hallData["match"] = {}; 	-- 比赛场
end

function HallConfigDataManager.dtor(self)
	self.m_hallData = {};
	--数据池中的东西客户端暂时写死
	self.m_hallData["xl"] = {}; 	-- 血流场
	self.m_hallData["xz"] = {};		-- 血战场
	self.m_hallData["match"] = {}; 	-- 比赛场
	self.m_hallData["lfp"] = {};    -- 两房场
	self.m_setDataFlag = false;
end
