
----验证大厅level和玩法
function isVersionSupport(server_level,server_type)
	local isLevelSupport = false;
    local isTypeSupport = false;

    local matchList = HallConfigDataManager.getInstance():returnMatchData();
    if #matchList > 0 then
		for i=1, #matchList do
			if tonumber(server_level) == tonumber(matchList[i].level) then
				return false;
			end
		end
	end


    for i = 1 , #GameConstant.level do
        if server_level == tonumber(GameConstant.level[i]) then
        	isLevelSupport=true;
        	break;
        end
    end
    DebugLog("server_type : "..server_type);
    DebugLog("GameConstant.playType : "..GameConstant.playType);
    isTypeSupport = isPlayTypeSupport(GameConstant.playType , server_type);

    return isLevelSupport and isTypeSupport;
end

--通过level得到某个比赛场次的入场金额
function getMatchHallConfigRequireMoneyByLevel(level, di, playType)
    
    level = level or 0;
    local matchRoomData = HallConfigDataManager.getInstance():returnMatchDataByLevel(level);
    if matchRoomData then 
    	return matchRoomData.require;
    end

    return 0; --没有该房间信息就返回0
end

--通过level得到某个场次的入场金额
function getHallConfigRequireMoneyByLevel( level , di , playType )
	level = level or 0;
	di = di or 0;
	playType = playType or 0;
	
	local hCDManager = HallConfigDataManager.getInstance()
	local roomData = hCDManager:returnHallConfigByLevel(level);	
	if roomData then 
		return roomData.require,roomData.vip;
	end
	DebugLog("getHallConfigRequireMoneyByLevel di:"..di..".playType:"..playType)
	roomData = hCDManager:getHallConfigByDiAndPlayType(di,playType)
	if roomData then 
		return roomData.require, roomData.vip 
	end 
	----------------------------
	local requireMoney = di * 100;
 	if #GameConstant.privateDiZhuList > 0 then
	 	for k, v in pairs(GameConstant.privateDiZhuList) do
			if tonumber(v.di) == tonumber(di) then
				if isPlayTypeSupport(playType , GameConstant.MahjongTypeXueLiu) then
					requireMoney = tonumber(v.require or (di * 100));
				else
					requireMoney = tonumber(v.require or (di * 50));
				end
			end
		end
	end
	return requireMoney,0;
end


--通过level得到某个场次房间的限额
function getHallConfigLimitByLevel(level,di,playType)
	level = level or 0;
	di = di or 0;
	playType = playType or 0;

	local roomData = HallConfigDataManager.getInstance():returnHallConfigByLevel(level);	
	if roomData then 
		return roomData.xzrequire;
	--有可能是两房牌
	else
		roomData = HallConfigDataManager.getInstance():returnHallDataForLFPByLevel(level);
		if roomData then 
			return roomData.xzrequire;
		end
	end
end

--得到房间信息
function getRoomInformWhenInRoom()
	local roomData = RoomData.getInstance();
	local levelType = 0;
	
	if roomData.isPrivateRoom then 
		levelType = 2;
	else
		levelType = 1;
	end
	return levelType,roomData.level,roomData.di;
end

function isPlayTypeSupport( allPlayType , playType )
	if not allPlayType and not playType then
		return false;
	end
	if bit.band(allPlayType , playType) == playType then
    	return true;
    end
    return false;
end

function getQuickRechargeView(m_rootView)
  	if FirstChargeView.getInstance():show() then
  		return;
  	end

  	if PlayerManager.getInstance():myself().money < GameConstant.bankruptMoney then 
		GlobalDataManager.getInstance():showBankruptDlg(nil,m_rootView);
		return ;
	end
    require("MahjongCommon/RechargeTip");
    local param_t = {t = RechargeTip.enum.default ,isShow = true, is_check_bankruptcy = false, is_check_giftpack = false,}
    if m_rootView then 
  		m_rootView.m_rechargeTip = RechargeTip.create(param_t);
  	else 
  		local rechargeTip = RechargeTip.create(param_t);
  	end
end

function OSTimeoutCallback()
	DebugLog("OSTimeoutCallback");
	require('MahjongData/MahjongCacheData')
    local id = MahjongCacheData_getDictKey_IntValue("OSTimeout" , "id" , -1);
    -- 重连 
    if id == GameConstant.roomReconnectTimeoutId then
    	if GameConstant.isInRoom and PlayerManager.getInstance():myself().mid > 0 then 
	        GameConstant.isNeedReconnectGame = true;
	        -- 关闭socket 如果是在房间内，会自动退出房间
	        SocketManager.getInstance():syncClose();
	    end
    elseif id == GameConstant.exitGameTimeoutId then
        native_muti_exit()
    end
end

-- 下载包  先不要删
-- function DownloadUpdatePackage(data)
-- 	if not data or not 1 ~= GetNumFromJsonTable(data , "status" , -1) or GameConstant.isUpdating then
-- 		return;
-- 	end
-- 	if not PlatformFactory.curPlatform:needToShowUpdataView() then
-- 		return;
-- 	end
-- 	if GameConstant.isUpdating then
-- 		Banner.getInstance():showMsg("正在全速为您更新");
-- 		return;
-- 	end
-- 	-- 更新标志
-- 	local flag = GetNumFromJsonTable(data , "flag" , -1);
-- 	if 1 ~= flag then
-- 		return;
-- 	end
-- 	-- 更新方式  0本地更新  1友盟更新
-- 	local updateMode = GetNumFromJsonTable(data , "mode" , -1);
-- 	-- 友盟更新方式  0增量更新  1全量更新
-- 	local updateUmeng = GetNumFromJsonTable(data , "umeng" , -1);
-- 	-- 本地更新地址
-- 	local updateUrl = GetStrFromJsonTable(data , "url" , "");
-- 	GameConstant.isUpdating = true;
-- 	local param = {};
-- 	if 1 == updateMode then
-- 		param.isCheckForProcess = isCheckProc;
-- 		param.isActUpdata = isActUpdata;
-- 		param.isDeltaUpdate = isDeltaUpdate;
-- 		param.isForceUpdate = isForceUpdate;
-- 		NativeManager.getInstance():downloadUmengUpdate(param);
-- 	else
-- 		param.url_update = url_update;
-- 		param.platform_type = GameConstant.platformType;
-- 		param.update_control = update_control;
-- 		param.update_content = update_content;
-- 		local dataStr = json.encode(data);
-- 		native_to_java(kUpdateVersion,dataStr);
-- 	end
-- end


