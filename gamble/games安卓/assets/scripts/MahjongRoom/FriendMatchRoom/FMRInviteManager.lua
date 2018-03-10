
--------好友对战最终结算界面
FMRInviteManager = class()

FMRInviteManager.s_instance = nil 

FMRInviteManager.INVITE_FROM_HALL        = 1---大厅
FMRInviteManager.INVITE_FROM_NORMAL_ROOM = 2---普通房间
FMRInviteManager.INVITE_FROM_BATTLE_ROOM = 3---好友对战房间
FMRInviteManager.INVITE_FROM_APP_START   = 4---应用启动
FMRInviteManager.INVITE_FROM_APP_RESUME  = 5---应用恢复

function FMRInviteManager:ctor( )
	EventDispatcher.getInstance():register(SocketManager.s_serverMsg, self, self.onSocketPackEvent);
end 

function FMRInviteManager:dtor(  )
	-- body
	EventDispatcher.getInstance():unregister(SocketManager.s_serverMsg, self, self.onSocketPackEvent);
end

function FMRInviteManager.getInstance()
    if not FMRInviteManager.s_instance then
        FMRInviteManager.s_instance = new(FMRInviteManager);
    end
    return FMRInviteManager.s_instance;
end

function FMRInviteManager:queryCanEnterRoom( roomId, from, obj, successFunc, failedFunc )
	-- body
	if self._isQuerying or not SocketManager.getInstance().m_isRoomSocketOpen then 
		return 
	end 

    local num = tonumber(roomId) or -1
    if num >= 0 and num <= 999999 then 
        self._isQuerying = true 
        self._lisener    = obj 
        self._successFunc = successFunc
        self._failedFunc  = failedFunc

        local param = {}
        param.level = GlobalDataManager.getInstance().fmRoomConfig.level;   
        param.fid   = tonumber(roomId)
        SocketManager.getInstance():sendPack(CLIENT_CMD_JOIN_BATTLE_PRE, param);

        self._from = from or FMRInviteManager.INVITE_FROM_HALL
    end 
end


function FMRInviteManager:getQueryResponse( data )--//0表示存在,1表示不存在,有错误
	self._isQuerying = false 

    local msg = nil
    if data and data.result == 0 then 
        local fid = data.fid or 1 
        self._successFunc(self._lisener, fid, self._from)
        return 
    elseif data and data.result == 2 then 
        msg = "该房间已满"
    else 
        msg = "该房间不存在"
    end 
    self._failedFunc(self._lisener, self._from)
    Banner.getInstance():showMsg(msg or "JoinGameWindow error!")
end

-- function FMRInviteManager:joinFriendMatchRoom( roomId )
-- 	if self._from == FMRInviteManager.INVITE_FROM_HALL then 
-- 	elseif self._from == FMRInviteManager.INVITE_FROM_NORMAL_ROOM then 
-- 	elseif self._from == FMRInviteManager.INVITE_FROM_BATTLE_ROOM then 
-- 	elseif self._from == FMRInviteManager.INVITE_FROM_APP_START then 
-- 	elseif self._from == FMRInviteManager.INVITE_FROM_APP_RESUME then 
-- 	end 


-- end


-- function FMRInviteManager:joinFriendMatchRoomRequest( fid )
--     if (type(fid) == "string" and string.len(fid) == 6) or ( type(fid) == "number" and fid >99999 and fid < 1000000) then 
--         local param = {};
--         local player = PlayerManager.getInstance():myself();
--         local uesrInfo = player:getUserData();
        
--         local config = GlobalDataManager.getInstance().fmRoomConfig
--         param.level     = config.level --or 20; 
--         param.money     = player.money;
--         param.userInfo  = json.encode(uesrInfo);
--         param.mtk       = player.mtkey;
--         param.from      = player.api;
--         param.version   = 1;
--         param.versionName     = GameConstant.Version;
--         --param.changeTableFlag = changeTableFlag;

--         param.roomNum   = tonumber(fid) or 0
--         param.isJoinRoom = true
--         RoomData.getInstance():setPrivateRoomData(param);
--         StateMachine.getInstance():changeState(States.FriendMatchRoom); 
--     else 
--     	Banner.getInstance():showMsg("该房间不存在!")
--     end     

-- end


FMRInviteManager.onSocketPackEvent = function ( self, param, cmd )
	if self.socketEventFuncMap[cmd] then
		DebugLog("HallScene deal socket cmd "..cmd);
		self.socketEventFuncMap[cmd](self, param);
	end
end

FMRInviteManager.socketEventFuncMap = {
    [SERVER_CMD_RESPONSE_JOIN_BATTLE_PRE] = FMRInviteManager.getQueryResponse,
}
