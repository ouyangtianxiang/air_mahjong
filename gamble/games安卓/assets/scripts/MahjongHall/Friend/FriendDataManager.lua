require("MahjongSocket/socketCmd");
require("MahjongSocket/socketManager");
require("MahjongHall/Friend/FriendMessageManager");
require("MahjongHall/Friend/ChatWindow");
require("MahjongHall/Friend/FeedbackGoldData")
require("MahjongRoom/FriendMatchRoom/FMRInviteManager")
require("MahjongHall/Rank/RankUserInfo");
--[[
	className    	     :  FriendDataManager
	Description  	     :  To wrap the data of the friend.
	last-modified-date   :  Dec. 4 2013
	create-time 	   	 :  Dec. 3 2013
	last-modified-author :  ClarkWu
	create-author        :　ClarkWu
]]
FriendDataManager = class();

--单例模式
FriendDataManager.m_Instance 		= nil;
--public parameter describes the main friendManager.
FriendDataManager.ADD_PASSIVE_CMD 	= kAddPassiveFriendCmd;
FriendDataManager.ADD_SOCKET_CMD    = kAddFriendSocketCmd;
FriendDataManager.DELETE_CMD 	    = kDeleteFriendCmd;
FriendDataManager.INVITE_CMD 	 	= kInviteFriendCmd;
FriendDataManager.TRACK_CMD 		= kTrackFriendCmd;
FriendDataManager.NOTICE_CMD        = kDeleteFriendCmd; 
FriendDataManager.ONLINE_CMD   		= kOnlineFriendCmd;
FriendDataManager.SHOW_CMD          = kShowFriendCmd;

--[[
	function name      : FriendDataManager.getInstance
	description  	   : To get the instance of friendDataManager.
	param 	 	 	   : self
	last-modified-date : Dec. 3 2013
	create-time		   : Dec. 3 2013
]]
FriendDataManager.getInstance = function()
	if FriendDataManager.m_Instance == nil then 
		--DebugLog("")
		FriendDataManager.m_Instance = new(FriendDataManager);
	end
	return FriendDataManager.m_Instance;
end

--[[
	function name      : FriendDataManager.ctor
	description  	   : To construct the instance of friendDataManager.
	param 	 	 	   : self
	last-modified-date : Dec. 3 2013
	create-time		   : Dec. 3 2013
]]
FriendDataManager.ctor = function(self)
	DebugLog("FriendDataManager.ctor")
	--------------数据池---------------
	--好友池
	--数据结构:{{mid="",name="",money="",sex="",smallImg="",bigImg="",isOnline=}};
	self.m_Friends = {};
    --self.m_enterChanelData.players = {};--面对面加好友:输入统一频道号的人 SendedPlayers:缓存已经发送过的人
    self.m_enterChanelData = {retNo = 0, players = {}, chanelId = 0, inputChanelId = 0, SendedPlayers = {}};--面对面加好友:输入统一频道号数据
	--好友动态
	self.m_FriendsNews 		= {};
	self.m_FriendNotReadN 	= 0;
	--好友详细信息池
	--数据结构:{"mid"={name="",sex="",money="",sitemid="",boyaacoin="",level="",vip="",jushu="",shenglv="",smallImg="",bigImg=""}};
	self.m_Friends_details = {};
	--监听器
	self.m_listener = {};

	self.fetionPicUrl = nil;
	self.fetionApkUrl = nil;
	self.score        = {};
	----------------------------------
	------------PHP注册---------------
	EventDispatcher.getInstance():register(SocketManager.s_phpMsg, self, self.onPhpMsgResponse);
	------------Socket注册------------
	EventDispatcher.getInstance():register(SocketManager.s_serverMsg, self, self.onFriendSocketPackEvent);

end

--[[
	function name      : FriendDataManager.dtor
	description  	   : To destruct the instance of friendDataManager.
	param 	 	 	   : self
	last-modified-date : Dec. 3 2013
	create-time		   : Dec. 3 2013
]]
FriendDataManager.dtor = function(self)
	--fjdkfjkdjfkdfj
	--error("123")
	--DebugLog(tonumber("a"))
	DebugLog("FriendDataManager.dtor")
	EventDispatcher.getInstance():unregister(SocketManager.s_phpMsg, self, self.onPhpMsgResponse);
	EventDispatcher.getInstance():unregister(SocketManager.s_serverMsg, self, self.onFriendSocketPackEvent);
	FriendDataManager.m_Instance = nil;
end

--[[
	function name      : FriendDataManager.addListener
	description  	   : To add a listener for data change.
	param 	 	 	   : self
						 obj     Table 		--  回调对象
						 fun     Function   --  回调函数
	last-modified-date : Dec. 3 2013
	create-time		   : Dec. 3 2013
]]
FriendDataManager.addListener = function(self, obj, func )
	DebugLog("FriendDataManager.addListener")	
	local listener = {};
	listener.obj = obj;
	listener.func= func;

	for i = 1, #self.m_listener do
		if self.m_listener[i].obj == obj and self.m_listener[i].func == func then
			DebugLog("already have")
			return;
		end
	end
	DebugLog("add listener =")
	DebugLog(tostring(listener))
	DebugLog(tostring(obj))
	DebugLog(tostring(func))
	self.m_listener[#self.m_listener + 1] = listener;

end
--删除监听器
FriendDataManager.removeListener = function(self, obj, func )
	
	for i = #self.m_listener , 1 , -1  do
		if self.m_listener[i].obj == obj and self.m_listener[i].func == func then
			DebugLog("FriendDataManager.removeListener i = " .. tostring(i))
			table.remove(self.m_listener, i);
			break;
		end
	end
end


--[[
	function name      : FriendDataManager.onListener
	description  	   : 响应对应的回调方法.
	param 	 	 	   : self
						 actionType   String -- 行为指令
						 actionParam  String -- 行为参数
	last-modified-date : Dec. 3 2013
	create-time		   : Dec. 3 2013
]]
FriendDataManager.onListener = function(self,actionType,actionParam)

	for i = 1, #self.m_listener do
		DebugLog(tostring(i))
		local listener = self.m_listener[i];
		if listener and listener.func and listener.obj then
			listener.func(listener.obj, actionType, actionParam);
			DebugLog("func")
		end
	end
end

-----------------------------------------------------------------基本操作-------------------------------------------------------------------------------------------
--是否有好友
FriendDataManager.hasFriend = function ( self )
	-- body
	if self.m_Friends then
		for k, v in pairs(self.m_Friends) do
			return true;
		end
	end

	return false;
end

--查找好友是否存在
FriendDataManager.hastheFriend = function (self, friendId )
	friendId = tostring(friendId);
	if self.m_Friends then
		for k, v in pairs(self.m_Friends) do
			if tonumber(v.mid) == tonumber(friendId) then
				return true;
			end
		end
	end
	return false;
end

--获取好友的名称 (如果有备注名，即返回备注名，否则返回呢称)
FriendDataManager.getFriendNameById = function ( self, friendId )
	-- body
	friendId = tostring(friendId);

	if self.m_Friends then
		if self.m_Friends[friendId] then
			if self.m_Friends[friendId].alias and string.len(self.m_Friends[friendId].alias) > 0 then
				return self.m_Friends[friendId].alias;
			else
				return self.m_Friends[friendId].mnick;
			end
		end
	end
	return nil;
end
--清除好友详细信息
FriendDataManager.clearFriendDetail = function ( self )
	-- body
	self.m_Friends_details = {};
end

--查找好友
FriendDataManager.selectFriendByMid = function(self,mid)
	if not self.m_Friends then
		return;
	end

	return self.m_Friends[tostring(mid)];
end
FriendDataManager.clearData = function ( self )
	self.m_Friends = {};
	--好友动态
	self.m_FriendsNews 		= {};
	self.m_FriendNotReadN 	= 0;
	--好友详细信息池
	--数据结构:{"mid"={name="",sex="",money="",sitemid="",boyaacoin="",level="",vip="",jushu="",shenglv="",smallImg="",bigImg=""}};
	self.m_Friends_details = {};
	--监听器
	--self.m_listener = {};

	self.fetionPicUrl = nil;
	self.fetionApkUrl = nil;
	self.score        = {};
end
-----------------------------------------------------------------好友请求--------------------------------------------------------------------------------------------
-----------------------------------------------------------------Socket请求------------------------------------------------------------------------------------------
--[[
	function name      : FriendDataManager.onFriendSocketPackEvent
	description  	   : The method of sending Socket.
	param 	 	 	   : self
						 param   Table   -- socket传递的参数
						 cmd     String  -- 命令字段
 	last-modified-date : Dec. 4 2013
	create-time		   : Dec. 4 2013
]]
FriendDataManager.onFriendSocketPackEvent = function(self,param,cmd)
	if FriendDataManager.socketEventFuncMap[cmd] then
		FriendDataManager.socketEventFuncMap[cmd](self, param);
	end
end

--所有发送socket请求
--[[
	function name      : FriendDataManager.addFriendSocket
	description  	   : To send the socket about adding friends by add_friend_mid;
	param 	 	 	   : self
						 add_friend_mid   Number   -- 好友的Id号
 	last-modified-date : Dec. 4 2013
	create-time		   : Dec. 4 2013
]]
FriendDataManager.addFriendSocket = function(self, bId, bName, bAlias, addWay)
	
	local param = {};
	param.cmd2  = FRIEND_CMD_ADD_FRI;
	param.aId 	= tonumber(PlayerManager:getInstance():myself().mid);
	param.bId 	= tonumber(bId);
	param.aName = PlayerManager:getInstance():myself().nickName;
	param.bName = bName or "";
	param.aSiteId 	= PlayerManager:getInstance():myself().sitemid;
	param.sid 	  	= PlatformFactory.curPlatform.api;
	param.way 		= addWay or 0;
	param.bAlias 	= bAlias or "";

	-- if not param.aId or not param.bId or not param.aName or not param.bName or not param.aSiteId or not param.sid then 
	-- 	Banner.getInstance():showMsg(PromptMessage.addFriendException);
	-- 	return;
	-- end

	SocketManager.getInstance():sendPack(FRIEND_CMD_FORWARD, param);
	if not HallScene_instance then
		self:broadCastAddFriendSuccessInRoom( bId );
	end
end

--[[
	function name      : FriendDataManager.addFriendToServer
	description  	   : 确定是否添加好友socket请求.
	param 	 	 	   : self
						 friendId   Number   --要加的好友mid(主动方)
						 friendName String   --要加的好友nickname(主动方)
						 myName     String   --自己的名字(被动方)  
						 result     Number   --是否确定添加
 	last-modified-date : Dec. 4 2013
	create-time		   : Dec. 4 2013
]]
FriendDataManager.addFriendToServer = function(self,friendId,friendName,bAlias,myName,result)

	local param = {};
	param.cmd2 			= FRIEND_CMD_ADD_FRI_RET;
	param.friendId 		= tonumber(friendId);
	param.userId 		= tonumber(PlayerManager.getInstance():myself().mid);
	param.friendName  	= friendName;
	param.myName 		= myName;
	param.result 		= result;

	param.way 			= 0;
	param.bAlias 		= bAlias;

	-- if not param.friendId or not param.userId or not param.friendName or not param.myName or not param.result or not param.way or not param.bAlias then 
	-- 	Banner.getInstance():showMsg(PromptMessage.inviteFriendDataException);
	-- 	return;
	-- end

	SocketManager.getInstance():sendPack(FRIEND_CMD_FORWARD,param);	
	
end


FriendDataManager.requestRecommondPlayer = function(self, roomlevel )
	local param = {}
	param.cmd2      = FRIEND_CMD_GET_LEVEL_USER_REQ
	param.roomlevel = roomlevel
	param.mid       = tonumber(PlayerManager.getInstance():myself().mid)

	SocketManager.getInstance():sendPack(FRIEND_CMD_FORWARD,param)
end

--[[
	function name      : FriendDataManager.deleteFriendSocket
	description  	   : To send the socket about deleting friends by friend_mid.
	param 	 	 	   : self
						 friend_mid   Number   -- 好友的Id号
						 friend_name  String   -- 好友的昵称
 	last-modified-date : Dec. 4 2013
	create-time		   : Dec. 4 2013
]]
FriendDataManager.deleteFriendSocket = function(self, friend_mid,friend_name)
	if friend_mid == nil then 
		return
	end 
		
	local param 	= {};
	param.userId 	= tonumber(PlayerManager.getInstance():myself().mid);
	param.otherId 	= tonumber(friend_mid);
	param.name 		= PlayerManager.getInstance():myself().nickName;
	param.otherName = friend_name;
	param.cmd2 		= FRIEND_CMD_DEL_FRI;
	-- if not param.userId or not param.otherId or not param.name or not param.otherName then 
	-- 	Banner.getInstance():showMsg(PromptMessage.inviteFriendDataException);
	-- 	return;
	-- end
	SocketManager.getInstance():sendPack(FRIEND_CMD_FORWARD,param);	
end

--[[
	function name      : FriendDataManager.requestFriendsIsOnlineSocket
	description  	   : 请求所有在线好友.
	param 	 	 	   : self
 	last-modified-date : Dec. 4 2013
	create-time		   : Dec. 4 2013
]]
FriendDataManager.requestFriendsIsOnlineSocket = function(self)
	DebugLog("FriendDataManager.requestFriendsIsOnlineSocket")
	--如果是飞信版本
	if GameConstant.platformType == PlatformConfig.platformFetion then
		self:requestFetionFriendsIsOnlineSocket();
		return;
	end

	local param 	= {};
	param.userId 	= tonumber(PlayerManager.getInstance():myself().mid);
	param.cmd2 	 	= FRIEND_CMD_UID_All_ONLINE_FRIEND_LIST;
	SocketManager.getInstance():sendPack(FRIEND_CMD_FORWARD,param);
	
end
--飞信版本 查询好友是否在线 
FriendDataManager.requestFetionFriendsIsOnlineSocket = function(self)
	local param 	= {};

	local fids = {};
	for k, v in pairs(self.m_Friends) do
		fids[#fids + 1] = k;
	end
	param.userId= tonumber(PlayerManager.getInstance():myself().mid);
	param.fids 	= fids;
	param.cmd2 	= FRIEND_CMD_BAT_IS_ONLINE;
	
	SocketManager.getInstance():sendPack(FRIEND_CMD_FORWARD,param);
end

--[[
	function name      : FriendDataManager.requestIsOnlineByMidSocket
	description  	   : 查看对应的mid的好友是否在线.
	param 	 	 	   : self
						 fid     Number  -- 好友id号
 	last-modified-date : Dec. 4 2013
	create-time		   : Dec. 4 2013
]]
FriendDataManager.requestIsOnlineByMidSocket = function(self,fid)
	local param 	= {};
	param.otherId 	= fid;
	param.userId 	= tonumber(PlayerManager.getInstance():myself().mid);
	param.cmd2 	 	= FRIEND_CMD_UID_FRIEND_IS_ONLINE;
	-- check
	-- if not param.otherId or not param.userId then 
	-- 	Banner.getInstance():showMsg(PromptMessage.inviteFriendDataException);
	-- 	return;
	-- end

	SocketManager.getInstance():sendPack(FRIEND_CMD_FORWARD,param);
end

--[[
	function name      : FriendDataManager.trackFriendSocket
	description  	   : 追踪好友Socket请求.
	param 	 	 	   : self
						 userId     Number  -- 自己id号
						 friendId   Number  -- 好友id号
 	last-modified-date : Dec. 4 2013
	create-time		   : Dec. 4 2013
]]
FriendDataManager.trackFriendSocket = function(self,userId,friendId)
	local param = {};
	param.userId 	= userId;
	param.friendId 	= friendId;
	param.cmd2 	 	= FRIEND_CMD_TRACK_IP;

	-- check
	-- if not param.userId or not param.friendId then 
	-- 	Banner.getInstance():showMsg(PromptMessage.inviteFriendDataException);
	-- 	return;
	-- end

	SocketManager.getInstance():sendPack(FRIEND_CMD_FORWARD,param);
end

--[[
	function name      : FriendDataManager.inviteFriendByIdSocket
	description  	   : 邀请好友Socket请求.
	param 	 	 	   : self
						 friendId   Number  -- 好友id号
						 friendName String  -- 好友昵称
 	last-modified-date : Dec. 4 2013
	create-time		   : Dec. 4 2013
]]
FriendDataManager.inviteFriendByIdSocket = function(self,friendId,friendName)
	local param 		= {};
	local roomData 		= RoomData.getInstance();
	param.ipStr 		= roomData.roomIp;
	param.port 			= roomData.roomPort;
	param.roomID 		= roomData.roomId;
	param.roomType 		= roomData.roomType;
	param.roomDi 		= roomData.di;
	param.server_type 	= roomData.playType;
	param.server_level 	= roomData.level;
	param.userId 		= PlayerManager.getInstance():myself().mid;
	param.otherId 		= friendId;
	param.name 			= PlayerManager.getInstance():myself().nickName;
	param.otherName 	= friendName;
	param.cmd2 			= FRIEND_CMD_INVITE_OTHER_IP;
	-- if not param.ipStr or not param.roomType or not param.roomDi or not param.server_type or not param.server_level or param.roomID <= 0 then 
	-- 	Banner.getInstance():showMsg(PromptMessage.inviteFriendDataException);
	-- 	return;
	-- end
	Banner.getInstance():showMsg(PromptMessage.isInvitingFriendInform);
	SocketManager.getInstance():sendPack(FRIEND_CMD_FORWARD,param);	
end

--向小伙伴们发消息
FriendDataManager.sendMsgToFriendBySocket = function(self, friendId, msgId, msg )
	local param 		= {};

	param.mid  			= tonumber(PlayerManager.getInstance():myself().mid);
	param.cmd2 			= MSG_CMD_USER_INFO_REV;
	param.friendId 		= tonumber(friendId);
	param.msgId 		= tonumber(msgId);
	param.msg 			= msg;

	SocketManager.getInstance():sendPack(MSG_CMD_TO_SERVER,param);	
end

--面对面加好友:进入频道
FriendDataManager.face2FaceEnterChanel = function (self, chanelId)
    DebugLog("FriendDataManager.face2FaceEnterChanel:");
    chanelId = tonumber(chanelId);
    if not chanelId then
        DebugLog("FriendDataManager.face2FaceEnterChanel:chanelId is nil");
        return;
    end
    --输入新的chanelId前，清空列表
    if self.m_enterChanelData.inputChanelId ~= chanelId then
        self.m_enterChanelData.SendedPlayers = {};--面对面加好友，已经添加过的好友不再显示界面
        self.m_enterChanelData.players = {};
    end
    self.m_enterChanelData.inputChanelId = chanelId;

	local param 	= {};
	param.userId= tonumber(PlayerManager.getInstance():myself().mid);
	param.chid 	= chanelId;
	param.cmd2 	= FRIEND_CMD_ENTER_FRIEND_CHANNEL;
	
	SocketManager.getInstance():sendPack(FRIEND_CMD_FORWARD,param);
end

--面对面加好友:离开频道
FriendDataManager.face2FaceLeaveChanel = function (self, chanelId)
    DebugLog("FriendDataManager.face2FaceLeaveChanel:");
    chanelId = tonumber(chanelId);
    if not chanelId then
        DebugLog("FriendDataManager.face2FaceLeaveChanel:chanelId is nil");
        return;
    end
	local param 	= {};
	param.userId= tonumber(PlayerManager.getInstance():myself().mid);
	param.chid 	= chanelId;
	param.cmd2 	= FRIEND_CMD_LEAVE_FRIEND_CHANNEL;
	
	SocketManager.getInstance():sendPack(FRIEND_CMD_FORWARD,param);
end

--面对面加好友:频道加好友
FriendDataManager.face2FaceAddFriend = function (self, data)
    DebugLog("FriendDataManager.face2FaceAddFriend:");
    if not data or type(data)~= "table" or #data <= 0 then
        DebugLog("FriendDataManager.face2FaceAddFriend:data is nil");
        return;
    end
	local param 	= {};
	param.userId= tonumber(PlayerManager.getInstance():myself().mid);
	param.data 	= data;
    param.nickName = PlayerManager.getInstance():myself().nickName;
	param.cmd2 	= FRIEND_CMD_ADD_CHANNEL_FRIEND;

	SocketManager.getInstance():sendPack(FRIEND_CMD_FORWARD,param);
end


--所有接收socket请求
--[[
	function name      : FriendDataManager.friendRequest
	description  	   : The main method of receive Socket and dispatch the suitable function.
	param 	 	 	   : self
						 data   Table   -- socket传来的参数
 	last-modified-date : Dec. 4 2013
	create-time		   : Dec. 4 2013
]]
FriendDataManager.onFriendRequest = function(self,data)
	DebugLog("好友请求--Socket返回");

	if data == nil then
		return; 
	end
	
	if 	   FRIEND_CMD_ADD_FRI 					== data.cmd2 then 
		self:onAcceptFriendYesOrNo(data);
	elseif FRIEND_CMD_ADD_FRI_RET 				== data.cmd2 then 
		self:onAddFriendToSuccessInitiative(data);
	elseif FRIEND_CMD_ADD_FRI_RET_RET 			== data.cmd2 then
		self:onAddFriendToSuccessPassive(data); 
	elseif FRIEND_CMD_DEL_FRI_RET 				== data.cmd2 then 
		self:onDeleteFriendToSuccessPassive(data);
	elseif FRIEND_CMD_DEL_FRI_RET_RET 			== data.cmd2 then
		self:onDeleteFriendToSuccessInitiative(data);
	elseif FRIEND_CMD_UID_All_ONLINE_FRIEND_LIST== data.cmd2 then
		self:onRequestAllOnlineFriends(data);
	elseif FRIEND_CMD_BAT_IS_ONLINE 			== data.cmd2 then -- 飞信版 跟主版本一样的逻辑
		self:onRequestAllOnlineFriends(data); 
	elseif FRIEND_CMD_UID_FRIEND_IS_ONLINE 		== data.cmd2 then
		self:onRequestFriendIsOnline(data);
	elseif FRIEND_CMD_TRACK_IP 					== data.cmd2 then 
		self:onTrackOtherRoom(data);
	elseif FRIEND_CMD_INVITE_OTHER_IP 			== data.cmd2 then
		self:onInviteFriendPaassive(data);
	elseif FRIEND_CMD_INVITE_OTHER_RET2 		== data.cmd2 then 
		self:onInviteFriendInitiative(data);
	elseif FRIEND_CMD_LOGIN 					== data.cmd2 then 
		self:onFriendOnLine(data);
	elseif FRIEND_CMD_LOGOUT 					== data.cmd2 then 
		self:onFriendOutLine(data);
	elseif FRIEND_CMD_GET_LEVEL_USER_RET        == data.cmd2 then 
		self:onGetRecommonPlayerList(data)
    elseif FRIEND_CMD_ENTER_FRIEND_CHANNEL      == data.cmd2 then--面对面加好友：进入频道
        self:onFace2FaceEnterChanel(data);
    elseif FRIEND_CMD_LEAVE_FRIEND_CHANNEL      == data.cmd2 then--面对面加好友：离开频道
        self:onFace2FaceLeaveChanel(data);
    elseif FRIEND_CMD_ADD_CHANNEL_FRIEND        == data.cmd2 then--面对面加好友：加频道好友
	    self:onFace2FaceAddFriend(data);
    elseif FRIEND_EVT_ADD_FRIEND == data.cmd2 then--面对面加好友：[通知消息]有人加你为好友了
        self:onFace2FaceNoticeAddFriend(data);
	elseif FRIEND_CMD_BATTLE_INVITE             == data.cmd2 then --被邀请进好友对战
		self:onBeInviteToBattleRoom(data)
    elseif FRIEND_CMD_INVITE_MATCH == data.cmd2 then
        self:invite_match(data);
	end

	
end

--接收到好友信息
FriendDataManager.onFriendMsg = function(self,data)
	DebugLog("FriendDataManager.onFriendMsg")
	if 	MSG_CMD_SERVER_INFO_RET == data.cmd2 then 
		if data.result == 1 or data.result == 0 then
			FriendMessageManager.getInstance():setMessageStateFromHistoryNewVersion(PlayerManager.getInstance():myself().mid, data.friendId, data.msgId, 1);
		elseif data.result == -1 then
			FriendMessageManager.getInstance():setMessageStateFromHistoryNewVersion(PlayerManager.getInstance():myself().mid, data.friendId, data.msgId, -1);
		end
		DebugLog("kFriendRecvSendStateBySockect")
		self:onListener(kFriendRecvSendStateBySockect, data);
	elseif MSG_CMD_USER_INFO_SEND 	== data.cmd2 then

		local message  = {};
		message.speakID = "" .. data.friendId;
		message.chat 	= data.msg;
		message.id 		= FriendMessageManager.getInstance():getUniqueId();
		message.state 	= 1;
		FriendMessageManager.getInstance():saveAMessageToFileNewVersion(PlayerManager.getInstance():myself().mid, message.speakID, message);
		DebugLog("kFriendRecvMsgBySockect")
		self:onListener(kFriendRecvMsgBySockect, message);

		local nowChattingFriendId = ChatWindow.getFriendId();
		if nowChattingFriendId ~= message.speakID then
			--生成离线消息
			local findInNews = false;

			for i = 1, #self.m_FriendsNews do
				if tonumber(self.m_FriendsNews[i].mid) == tonumber(message.speakID) and tonumber(self.m_FriendsNews[i].type) == 3 then
					findInNews = true;
					break;
				end
			end
			--生成离线消息
			local friend = self.m_Friends[message.speakID];
			if not findInNews and friend then
				local news = {};
				news.type 	= "3";
				news.mid 	= friend.mid;
				news.mnick 	= friend.mnick;
				news.sex 	= friend.sex;
				news.photo 	= friend.small_image;
				news.money 	= friend.money;
				self.m_FriendsNews[#self.m_FriendsNews + 1] = news;

				self:saveFriendNews(PlayerManager.getInstance():myself().mid);
				DebugLog("kFriendNewsNumRequestByPHP")
				self:onListener(kFriendNewsNumRequestByPHP, self:getFriendNewsCount()); --更新气泡和动态内容 
			end

		end
	end
end

--[[
	function name      : FriendDataManager.onAcceptFriendYesOrNo
	description  	   : 被动方收到主动方发送的添加好友的操作.
	param 	 	 	   : self
						 data   Table   -- socket传来的参数
 	last-modified-date : Dec. 4 2013
	create-time		   : Dec. 4 2013
]]
FriendDataManager.onAcceptFriendYesOrNo = function(self,data)
	if not data or data.friendId <= kNumZero then 
		Banner.getInstance():showMsg(PromptMessage.addFriendException);
		return;
	end
	local selfId   = PlayerManager.getInstance():myself().mid or ""
	local friendId = data.friendId or ""
	local mapName      = kFriendRequestBlack..selfId
	local hasReject    = g_DiskDataMgr:getFileKeyValue(mapName, friendId.."", 0)
	if hasReject and hasReject == 1 then --以前 已经勾选“拒绝再接收此人的好友请求”
		self:addFriendToServer(tonumber(data.friendId),data.friendName,data.friendName,PlayerManager.getInstance():myself().nickName,kNumMinusOne);
		return 
	end 

	local content = data.friendName .. "(ID:" .. data.friendId .. ")请求加您为好友，是否接受？";
	local view = PopuFrame.showNormalDialogForCenter(CreatingViewUsingData.commonData.popuFrame.title, content, nil, nil, nil, false, false, "接  受", "拒  绝", true);

	----------------------------------------------add checkbox and tip label 
	local rejectCheckBox = new(CheckBox)
	rejectCheckBox:setAlign(kAlignLeft)
	rejectCheckBox:setPos(100,30)
	local label          = UICreator.createText( "拒绝再接收此人的好友请求。", 155, 30, 600,50, kAlignLeft ,30, 0xcc, 0x44, 0x00 )
	label:setAlign(kAlignLeft)
	view.img_win_bg:addChild(rejectCheckBox)
	view.img_win_bg:addChild(label)
	----------------------------------------------

	view:setConfirmCallback(self, function ( self)
		self:addFriendToServer(tonumber(data.friendId),data.friendName,data.myName,PlayerManager.getInstance():myself().nickName,kNumZero);
	end);
	view:setCancelCallback(self, function ( self )
		if rejectCheckBox and rejectCheckBox:isChecked() then 
			g_DiskDataMgr:setFileKeyValue(mapName, friendId.."", 1)
		end 
		self:addFriendToServer(tonumber(data.friendId),data.friendName,data.myName,PlayerManager.getInstance():myself().nickName,kNumMinusOne);
	end);
	view:setNotOnClickFeeling(true);
	if view then
		view:setCallback(view, function ( view, isShow )
			if not isShow then
				
			end
		end);
	end
end

--[[
	function name      : FriendDataManager.onAddFriendToSuccessInitiative
	description  	   : 主动方收到添加好友socket返回.
	param 	 	 	   : self
						 data   Table   -- socket传来的参数
 	last-modified-date : Dec. 4 2013
	create-time		   : Dec. 4 2013
]]
FriendDataManager.onAddFriendToSuccessInitiative = function(self,data)
	DebugLog("result = " .. data.result);
	if data.result ~= kNumZero then 
		local errorNo = tonumber(data.result);
		if errorNo == -1 then
			Banner.getInstance():showMsg(PromptMessage.serverBusy);
		elseif errorNo == -2 then
			Banner.getInstance():showMsg(PromptMessage.friendIsExist);
		elseif errorNo == -3 then
			Banner.getInstance():showMsg(PromptMessage.inviteFriendIsNotOnline)
		elseif errorNo == -4 then
			Banner.getInstance():showMsg(PromptMessage.friendNumLimit);
		elseif errorNo == -5 then
			Banner.getInstance():showMsg(PromptMessage.refuseFriendReqeust);
		elseif errorNo == -6 then
			Banner.getInstance():showMsg(PromptMessage.versionNotSupport);
		elseif errorNo == -7 then
			Banner.getInstance():showMsg(PromptMessage.otherFriendNumLimit)
		elseif errorNo == -8 then
			Banner.getInstance():showMsg(PromptMessage.requestSent);
		elseif errorNo == -9 then
			Banner.getInstance():showMsg(PromptMessage.addselfExcption);
		end
	else
	 	local friend 		= {};
	 	local mid 			= "" .. data.friendId;
	    friend.mid 			= "" .. data.friendId;
	    friend.money 		= 0;
	    friend.sex 			= 2;
	    friend.gift_status 	= 0;
	    friend.mnick 		= data.friendName;
	    friend.alias 		= "";
	    friend.small_image 	= "";
	    friend.online 		= true; -- 默认在线

	    self.m_Friends[mid] = friend;

  		Banner.getInstance():showMsg("恭喜您，添加 "..friend.mnick.."("..friend.mid..")".." 成功！");
  		self:requestPerFriendInformation({mid});
  		self:onListener(kFriendAddSuccessBySocket, mid);
	end
end

--[[
	function name      : FriendDataManager.onAddFriendToSuccessPassive
	description  	   : 被动方收到添加好友socket返回.
	param 	 	 	   : self
						 data   Table   -- socket传来的参数
 	last-modified-date : Dec. 4 2013
	create-time		   : Dec. 4 2013
]]
FriendDataManager.onAddFriendToSuccessPassive = function(self,data)
	if data.result == kNumZero then
	 	local friend 		= {};
	 	local mid 			= "" .. data.friendId
	    friend.mid 			= "" .. data.friendId;
	    friend.money 		= 0;
	    friend.sex 			= 2;
	    friend.gift_status 	= 0;
	    friend.mnick 		= data.friendName;
	    friend.alias 		= "";
	    friend.small_image 	= "";
	    friend.online 		= true; -- 默认在线

	    self.m_Friends[friend.mid] = friend;
  		Banner.getInstance():showMsg("恭喜您，添加 "..friend.mnick.."("..friend.mid..")".." 成功！");
  		self:requestPerFriendInformation({mid});
  		self:onListener(kFriendAddSuccessBySocket, friend.mid);
  		self:broadCastAddFriendSuccessInRoom( data.friendId );
	end
end

FriendDataManager.broadCastAddFriendSuccessInRoom = function( self, fiendId )
	if RoomScene_instance then
		local param = {};
		param.mid1 = PlayerManager.getInstance():myself().mid;
		param.mid2 = fiendId;
		SocketSender.getInstance():send(SERVERGB_BROADCAST_ADDFRI, param);
	end
end

--[[
	function name      : FriendDataManager.onDeleteFriendToSuccessPassive
	description  	   : 主动方删除好友socket返回.
	param 	 	 	   : self
						 data   Table   -- socket传来的参数
 	last-modified-date : Dec. 4 2013
	create-time		   : Dec. 4 2013
]]
FriendDataManager.onDeleteFriendToSuccessPassive = function(self,data)
	
	if not data then 
		return;
	end
	if data.result == kNumMinusOne then 
		local msg = PromptMessage.deleteFriendDataException;
		Banner.getInstance():showMsg(msg);
	else
		local msg = PromptMessage.deleteFriendSuccess;
  		Banner.getInstance():showMsg(msg);
  		self.m_Friends[""..data.friendId] = nil;
    	DebugLog("FriendDataManager.onDeleteFriendToSuccessPassive " .. data.friendId)
  		self:onListener(kFriendDeleteByPHP, "" .. data.friendId);
  	end
end

--[[
	function name      : FriendDataManager.onDeleteFriendToSuccessInitiative
	description  	   : 被动方删除好友socket返回.
	param 	 	 	   : self
						 data   Table   -- socket传来的参数
 	last-modified-date : Dec. 4 2013
	create-time		   : Dec. 4 2013
]]
FriendDataManager.onDeleteFriendToSuccessInitiative = function(self,data)
	if not data then 
		return;
	end
	if data.result ~= kNumMinusOne then
  		self.m_Friends[""..data.friendId] = nil;
  		DebugLog("FriendDataManager.onDeleteFriendToSuccessInitiative " .. data.friendId)
  		self:onListener(kFriendDeleteByPHP, "" .. data.friendId);
  	end
end


FriendDataManager.getOnlineFriends = function ( self )
	local allOnlineFriends = {}

	for k,v in pairs(self.m_Friends) do
		if v.online then 
			table.insert(allOnlineFriends, v)
		end 
	end

	return allOnlineFriends
end

FriendDataManager.findFriendInfoById = function ( self, strId )
	local param = {}
	for k,v in pairs(self.m_Friends) do
		if strId == k then 
			table.insert(param, v)
			return param
		end 
	end
	return param
end
--[[
	function name      : FriendDataManager.onRequestAllOnlineFriends
	description  	   : 请求所有在线好友socket返回.
	param 	 	 	   : self
						 data   Table   -- socket传来的参数
 	last-modified-date : Dec. 4 2013
	create-time		   : Dec. 4 2013
]]
FriendDataManager.onRequestAllOnlineFriends = function(self,data)
	DebugLog("FriendDataManager.onRequestAllOnlineFriends")
	if not data and not self.m_Friends then 
		return ;
	end

	for i, v in pairs(self.m_Friends) do
		v.online = false;
	end

	local online_length = data.len;
    local online_array  = data.online;
    --更新在线好友
	for i=1, online_length do 
		local key  = "" .. online_array[i];
		if self.m_Friends[ key ] then
			self.m_Friends[ key ].online = true;
		end
	end
	self:onListener(kFriendAllOnlineFriendsBySocket);
end

--[[
	function name      : FriendDataManager.onRequestFriendIsOnline
	description  	   : 请求对应mid的好友是否在线socket返回.
	param 	 	 	   : self
						 data   Table   -- socket传来的参数
 	last-modified-date : Dec. 4 2013
	create-time		   : Dec. 4 2013
]]
FriendDataManager.onRequestFriendIsOnline = function(self,data)

	-- if not data then 
	-- 	return;
	-- end
	-- if 
	-- m_Friends[]

	-- if data.result == kNumZero then 
	-- 	self:onListener(kFriendOnlinesBySocket);
	-- 	print("not online" .. data.friendId);
	-- elseif data.result == kNumMinusOne then 
	-- 	print("not online" .. data.friendId);
	-- 	self:onListener(kFriendNotOnlineSocket);
	-- end

	-- if data.result == kNumZero then 
	-- 	self:onListener(kFriendOnlinesBySocket);
	-- elseif data.result == kNumMinusOne then 
	-- 	self:onListener(kFriendNotOnlineSocket);
	-- end
end

--[Comment]
--track match
FriendDataManager.onTrackMatch = function(self,data)
    DebugLog("FriendDataManager.onTrackMatch");
    if not data then
        DebugLog("data is nil");
        return;
    end
	local ipStr			= data.ipStr;
    local port 			= data.port;
    local sid  			= data.sid;
    local tid  			= data.tid;
    local roomCount 	= data.roomCount;  --房间已有人数
    local server_type 	= data.server_type; --房间的玩法类型
    local server_level 	= data.server_level;--房间的场次等级

    if not data.match_level or not data.match_type then
        DebugLog(":"..tostring(data.match_level)..tostring(data.match_type));
        return;
    end
    if HallScene_instance then
        if HallScene_instance.friendView then
            HallScene_instance.friendView:hide();
        end
        HallScene_instance:onGoToMatchRoom( data.match_level, data.match_type );
    end
end

--[[
	function name      : FriendDataManager.onTrackOtherRoom
	description  	   : 追踪好友socket返回.
	param 	 	 	   : self
						 data   Table   -- socket传来的参数
 	last-modified-date : Dec. 4 2013
	create-time		   : Dec. 4 2013
]]
FriendDataManager.onTrackOtherRoom = function(self,data)
	if not data then 
		self:onListener(kTrackFriendByPHP, nil);
		return;
	end
	local ipStr			= data.ipStr;
    local port 			= data.port;
    local sid  			= data.sid;
    local tid  			= data.tid;
    local roomCount 	= data.roomCount;  --房间已有人数
    local server_type 	= data.server_type; --房间的玩法类型
    local server_level 	= data.server_level;--房间的场次等级

    --好友对战特殊提示
    if data.server_level and data.server_level == GlobalDataManager.getInstance().fmRoomConfig.level then
        Banner.getInstance():showMsg("该好友暂时无法追踪，请稍后再试");
        return;
    end

	if roomCount >= kNumFour then --房间已满
		Banner.getInstance():showMsg(PromptMessage.inviteFriendRoomFull);
		self:onListener(kTrackFriendByPHP, nil);
		return;
	end

    if data.isMatch == 1 then
        --比赛追踪
        self:onTrackMatch(data);
        return;
    end


	if tid <= 0 or server_type < 0 then --不在房间内
		Banner.getInstance():showMsg(PromptMessage.friendIsNotInRoom);
		self:onListener(kTrackFriendByPHP, nil);
		return;
	end
	
	local result = isVersionSupport(server_level,server_type);

	local player = PlayerManager.getInstance():myself()
	local canEnter,msg = HallConfigDataManager.getInstance():checkIsSatifiedEnterCondition(player.money,player.vipLevel,data.server_level,nil,data.server_type)
	if not canEnter then 
		if 1 == DEBUGMODE then
			Banner.getInstance():showMsg(msg);
		end 
		return 
	end 

	--如果支持
	if result then
		local  data = {};
		data.ip 	= ipStr;
		data.port 	= port;
		data.roomId = tid;
		data.level  = server_level;
		
		self:onListener(kTrackFriendByPHP, data);
		Banner.getInstance():showMsg(PromptMessage.trackMessage);

	else
		if GameConstant.platformType == PlatformConfig.platformDianxin then 
			Banner.getInstance():showMsg(PromptMessage.versionNotSuitable);
		else
			Banner.getInstance():showMsg(PromptMessage.needUpdateVersion);
			self:onListener(kTrackFriendByPHP, nil);
		end
	end
end

FriendDataManager.getRoomInfo = function ( self,level,di)
	local str = "";
	local data, wanfa = HallConfigDataManager.getInstance():returnDataByLevel(level);
	
	if data and wanfa then
		if "xz" == wanfa then
			local curname  = HallConfigDataManager.getInstance():returnTypeNameForLevel(level)
			if curname then 
				str = "【血战到底】" .. "-【" .. curname .. "】-【" .. data.di .. "底】";
			else 
				str = "游戏场"
			end 
		elseif "xl" == wanfa then 
			local curname  = HallConfigDataManager.getInstance():returnTypeNameForLevel(level)
			if curname then 
				str = "【血流成河】" .. "-【" .. curname .. "】-【" .. data.di .. "底】";
			else 
				str = "游戏场"
			end 	
		elseif "match" == wanfa then
			str = "【比赛场】" .. "-【" .. data.name .. "】-【" .. data.value .. "底】";
		elseif "lfp" == wanfa then	
			str = "【两房牌】" .. "-【" .. data.value .. "底】";
		else
			str = "游戏场";
		end
	end

	if 50 == level then
		str =  "【包厢】" .."-【" .. tostring(di) .. "底】"; 
	end
	return str;
end



function FriendDataManager:onBeInviteToBattleRoom( data )
	if not data or data.fid == -1 then 
		return 
	end 

	local fid     = data.fid 

	local param   = {}
    param.userId    = PlayerManager.getInstance():myself().mid;
	param.otherId   = data.inviteMid;
	param.name      = data.myName or kNullStringStr;
	param.othername = data.inviteName or kNullStringStr;
	
	local desc = "("..data.roundNum.."局、"..global_get_wanfa_desc(data.wanfa).."、房间号"..data.fid..")。"
	local content = "您的好友"..tostring(data.inviteName).."邀请您加入好友对战"..desc.."中途不可退出,您确定是否加入?"

	local inFriendMatch = false
	if FriendMatchRoomScene_instance and (FriendMatchRoomScene_instance:isRoundNotBeginning() and (not FriendMatchRoomScene_instance:isRoundGameOver())) then 
		inFriendMatch = true
	end 
	if PlayerManager.getInstance():myself().isInGame or MatchRoomScene_instance or inFriendMatch then   --普通场牌局中-- 比赛场 
		local view = PopuFrame.showNormalDialogForCenter( "温馨提示", 
															content,
									  GameConstant.curGameSceneRef , 
									  							  0, 
									  							  0, 
									  				
									  						   true,
									  						  false,
									  					  "我知道了");
		view:setCallback(view, function ( view, isShow )
			param.result = kNumMinusTwo;---0同意 -1拒绝 -2在房间中  -3不在线
			param.cmd2   = FRIEND_CMD_INVITE_OTHER_RET2;
			SocketManager.getInstance():sendPack(FRIEND_CMD_FORWARD,param);	
		end);
	else 
		local view = PopuFrame.showNormalDialogForCenter( "温馨提示", 
															content,
									  GameConstant.curGameSceneRef , 
									  							  0, 
									  							  0, 
									  						  false,
									  						  false,
									  					     "确定",
									  					     "取消");
		view:setConfirmCallback(self,function (self)
			param.result = kNumZero;
			param.cmd2   = FRIEND_CMD_INVITE_OTHER_RET2;
			SocketManager.getInstance():sendPack(FRIEND_CMD_FORWARD,param);	

		    FMRInviteManager.getInstance():queryCanEnterRoom( tonumber(fid) , 
		                                 FMRInviteManager.INVITE_FROM_HALL , 
		                                                               self, 
		                                          self.joinFriendMatchSuccessCallback, 
		                                          self.joinFriendMatchFailedCallback )
		end)

		view:setCancelCallback(self,function(self)
			param.result = kNumMinusOne;---0同意 -1拒绝 -2在房间中  -3不在线
			param.cmd2   = FRIEND_CMD_INVITE_OTHER_RET2;
			SocketManager.getInstance():sendPack(FRIEND_CMD_FORWARD,param);	

			if FriendMatchRoomScene_instance and FriendMatchRoomScene_instance:isRoundGameOver() then 
				FriendMatchRoomScene_instance:exitGame()
			end 
		end)


		view:setCloseCallback(self,function (self)
			param.result = kNumMinusOne;---0同意 -1拒绝 -2在房间中  -3不在线
			param.cmd2   = FRIEND_CMD_INVITE_OTHER_RET2;
			SocketManager.getInstance():sendPack(FRIEND_CMD_FORWARD,param);	

			if FriendMatchRoomScene_instance and FriendMatchRoomScene_instance:isRoundGameOver() then 
				FriendMatchRoomScene_instance:exitGame()
			end 
		end)

	end 
end
function FriendDataManager:joinFriendMatchSuccessCallback( fid, from )
	local data = {};
	local player   = PlayerManager.getInstance():myself();
	local uesrInfo = player:getUserData();
	
	data.level 	    = GlobalDataManager.getInstance().fmRoomConfig.level;	
	data.money 	    = player.money;
	data.userInfo   = json.encode(uesrInfo);
	data.mtk 	 	= player.mtkey;
	data.from 		= player.api;
	data.version 	= 1;
	data.versionName 	  = GameConstant.Version;
	data.roomNum    = fid
	data.isJoinRoom = true
	data.isFriendMatch = true
	RoomData.getInstance():setPrivateRoomData(data);
	RoomData.getInstance():setIsFriendMatch(true)
	if FriendMatchRoomScene_instance then 
		FriendMatchRoomScene_instance:joinGame(data)
	elseif RoomScene_instance and RoomScene_instance:exitGameRequire()  then --
		GameConstant.isInvited = true;
	else 
		StateMachine.getInstance():changeState(States.Loading,nil,States.FriendMatchRoom);	
	end 
end
function FriendDataManager:joinFriendMatchFailedCallback( from )
	-- body
end
--[[
	function name      : FriendDataManager.onInviteFriendPaassive
	description  	   : 被动方收到邀请好友消息socket返回.
	param 	 	 	   : self
						 data   Table   -- socket传来的参数
 	last-modified-date : Dec. 4 2013
	create-time		   : Dec. 4 2013
]]
FriendDataManager.onInviteFriendPaassive = function(self,data)
	if data.roomID <= kNumZero or data.server_type < kNumZero then 
		return;
	end


    local param = {};
    local content;

	content = PromptMessage.inviteMessage.str1..data.friendName..PromptMessage.inviteMessage.str2 .. self:getRoomInfo(tonumber(data.server_level),tonumber(data.roomDi)) .. PromptMessage.inviteMessage.str3;


    param.userId = PlayerManager.getInstance():myself().mid;
	param.otherId = data.friendId;
	param.name = data.myName or kNullStringStr;
	param.othername = data.friendName or kNullStringStr;

	
	if PlayerManager.getInstance():myself().isInGame then 
		param.result = kNumMinusTwo;--0同意 -1拒绝 -2在房间中  -3不在线
		--发送被动邀请好友消息
		param.cmd2 = FRIEND_CMD_INVITE_OTHER_RET2;
		SocketManager.getInstance():sendPack(FRIEND_CMD_FORWARD,param);	
		return;
	end

	local view = PopuFrame.showNormalDialogForCenter( CreatingViewUsingData.commonData.popuFrame.title, content,GameConstant.curGameSceneRef , nil, nil, false);
	view:setConfirmCallback(self, function ( self)
		-- 如果已经开始  则不允许退出房间进入被邀请的房间
		if MatchRoomScene_instance and not MatchRoomScene_instance:exitGameRequire() then
			return;
		end

		if FriendMatchRoomScene_instance and not FriendMatchRoomScene_instance:isRoundNotBeginning() then 
			FriendMatchRoomScene_instance:exitWhenGameNotStart()
		elseif RoomScene_instance and not RoomScene_instance:exitGameRequire() then
			return 
		end 

		if HallScene_instance then 
			GameConstant.isInvitedByFriendInHall = true
		end 

		if RoomScene_instance then
			GameConstant.isInvited = true;
		end
		
		local roomData = RoomData.getInstance();
		local param2 = {};
		param2.ip = data.ipStr;
		param2.port = data.port;
		param2.roomId = data.roomID;
		param2.roomType = data.roomType;
		param2.roomDi = data.roomDi;
		param2.server_type = data.server_type;
		param2.server_level = data.server_level;

		param2.isFriendMatch = false
		RoomData.getInstance():setChangeRoomData(param2);
		GameConstant.tempRoomData = param2;


		local result = isVersionSupport(data.server_level,data.server_type);
		
		local player = PlayerManager.getInstance():myself()
		local canEnter,msg = HallConfigDataManager.getInstance():checkIsSatifiedEnterCondition(player.money,player.vipLevel,data.server_level,data.roomDi,data.server_type)
		if not canEnter then 
			if 1 == DEBUGMODE then
				Banner.getInstance():showMsg(msg);
			end 
			return 
		end 
		

		if result then 
			param.result = kNumZero;-----0同意 -1拒绝 -2在房间中  -3不在线
			param.cmd2 = FRIEND_CMD_INVITE_OTHER_RET2;
			--发送被动邀请好友消息
			SocketManager.getInstance():sendPack(FRIEND_CMD_FORWARD,param);	
			--print(HallScene_instance);
			if HallScene_instance then 
				self.callbackObj = HallScene_instance;
				self.callbackFun = HallScene.onCallBackFunc;
				--self:onListener(kInvitingFriendInHall);
                HallScene_instance:friendDataControlled()
			end
			return;
		else
			param.result = kNumMinusFour;
			if GameConstant.platformType == PlatformConfig.platformDianxin then 
				msg = PromptMessage.versionNotSuitable;
			else
				msg = PromptMessage.needUpdateVersion;
			end
			param.cmd2 = FRIEND_CMD_INVITE_OTHER_RET2;
			SocketManager.getInstance():sendPack(FRIEND_CMD_FORWARD,param);	
			Banner.getInstance():showMsg(msg);
		end
	end);

	view:setCancelCallback(self, function ( self )
		GameConstant.isInvitedByFriendInHall = false
		param.result = kNumMinusOne;
		param.cmd2 = FRIEND_CMD_INVITE_OTHER_RET2;
		--发送被动邀请好友消息
		SocketManager.getInstance():sendPack(FRIEND_CMD_FORWARD,param);	
	end);

	view:setNotOnClickFeeling(true);

	if view then
		view:setCallback(view, function ( view, isShow )
			if not isShow then
				
			end
		end);
	end

end

--[[
	function name      : FriendDataManager.onInviteFriendInitiative
	description  	   : 主动方收到邀请好友消息socket返回.
	param 	 	 	   : self
						 data   Table   -- socket传来的参数
 	last-modified-date : Dec. 4 2013
	create-time		   : Dec. 4 2013
]]
FriendDataManager.onInviteFriendInitiative = function(self,data)
	if not data then
		return;
	end
	local msg = PromptMessage.inviteFriendDataException;
	if data.result == kNumZero then 
		msg = PromptMessage.inviteAgree;
	elseif data.result == kNumMinusOne then 
		msg = PromptMessage.refuseYourInviting;
	elseif data.result == kNumMinusTwo then 
		msg = PromptMessage.invitedIsInGame;
	elseif data.result == kNumMinusThree then 
		msg = PromptMessage.inviteFriendIsNotOnline;
		self:onListener(kInvitingResultNoLine);

	end
	Banner.getInstance():showMsg(msg);
end

--[[
	function name      : FriendDataManager.onFriendOnLine
	description  	   : 好友上线socket返回.
	param 	 	 	   : self
						 data   Table   -- socket传来的参数
 	last-modified-date : Dec. 4 2013
	create-time		   : Dec. 4 2013
]]
FriendDataManager.onFriendOnLine = function(self,data)
	if not data or not data.playerName then
		return;
	end
	local name = data.playerName;
	local alias = nil
	local msg = nil 

  	local playerId = "" .. data.player;

  	if self.m_Friends[playerId] then
  		self.m_Friends[playerId].online = true;--是否在线
  		alias = self.m_Friends[playerId].alias
  	end
  	if alias and alias ~= "" then 
		msg = PromptMessage.onlineOrNoOnlinePrompt.str1 .. alias .. PromptMessage.onlineOrNoOnlinePrompt.online ;
  	else 
  		msg = PromptMessage.onlineOrNoOnlinePrompt.str1 .. name .. PromptMessage.onlineOrNoOnlinePrompt.online ;
  	end
  	Banner.getInstance():showMsg(msg);

  	self:onListener(kFriendComeBySocket,playerId);

end

--[[
	function name      : FriendDataManager.onFriendOutLine
	description  	   : 好友下线socket返回.
	param 	 	 	   : self
						 data   Table   -- socket传来的参数
 	last-modified-date : Dec. 4 2013
	create-time		   : Dec. 4 2013
]]
FriendDataManager.onFriendOutLine = function(self,data)
	if not data or not data.playerName then
		return;
	end
	local name = data.playerName;
	local msg = nil
	local alias = nil
  	local playerId = "" .. data.player;

  	if self.m_Friends[playerId] then
  		self.m_Friends[playerId].online = false;--是否在线
  		alias = self.m_Friends[playerId].alias
  	end
  	if alias and alias ~= "" then 
		msg = PromptMessage.onlineOrNoOnlinePrompt.str1 .. alias .. PromptMessage.onlineOrNoOnlinePrompt.notonline ;
  	else 
  		msg = PromptMessage.onlineOrNoOnlinePrompt.str1 .. name .. PromptMessage.onlineOrNoOnlinePrompt.notonline ;
  	end
  	--Banner.getInstance():showMsg(msg); --好友下线不再提示 v5.1.0产品需求
  	self:onListener(kFriendGoneBySocket,playerId);
end
-----------推荐好友 server返回
FriendDataManager.onGetRecommonPlayerList = function ( self,data )
	if not data or not data.playerList then 
		DebugLog("无推荐好友")
		return 
	end 

	--for i=1,#data.playerList do	
	--end
	--self:searchFriendById(data.playerList)
	--searchFriendById

	self:QueryUserInfo(PHP_CMD_QUERY_USER_INFO,data.playerList)
end

--面对面加好友:进入房间 server返回
FriendDataManager.onFace2FaceEnterChanel = function (self, data)
    DebugLog("FriendDataManager.onFace2FaceEnterChanel");
    if not data then
        DebugLog("FriendDataManager.onFace2FaceEnterChanel data is nil");
        return;
    end
    self:onListener(kFriendFace2FaceEnterChanel,data);
--    local playerList = {};
--    self.m_enterChanelData.retNo = data.retNo;
--    --过滤当前输入的频道号
--    if data.chanelId and tostring(self.m_enterChanelData.inputChanelId) ==  tostring(data.chanelId) then
--        self.m_enterChanelData.chanelId = data.chanelId;
--        local num = data.num;
--        for i = 1, #data.list do
--            local tmp = {}
--            tmp.mid = data.list[i];
--            tmp.userdata = nil;
--            --如果进入房间的是自己或者已经是好友不显示
--            if tostring(tmp.mid) ~= tostring(PlayerManager.getInstance():myself().mid) 
--            and not self.m_Friends[tostring(tmp.mid)] then
--                self.m_enterChanelData.players[tostring(tmp.mid)] = tmp;
--            end

--        end

--        self:onListener(kFriendFace2FaceEnterChanel,data.list);

--    end

    

    
    
end

--面对面加好友:离开房间 server返回
FriendDataManager.onFace2FaceLeaveChanel = function (self, data)
    DebugLog("FriendDataManager.onFace2FaceLeaveChanel");
--    self.m_enterChanelData.players = {};
--    self:onListener(kFriendFace2FaceLeaveChanel);
end

--面对面加好友:加好友 server返回
FriendDataManager.onFace2FaceAddFriend = function (self, data)
    DebugLog("FriendDataManager.onFace2FaceAddFriend");
    self:onListener(kFriendFace2FaceAddFriend);
    if data.successTable then
        for k,v in pairs(data.successTable) do
            self.m_enterChanelData.players[k] = nil;
        end
        for k,v in pairs(data.successTable) do
            if not self.m_Friends[v] then
                DebugLog("FriendDataManager.onFace2FaceAddFriend ..requestAllFriends");
                self:requestAllFriends();
                break;
            end
           break;
        end
        
    end
    self:onListener(kFriendFace2FaceAddFriend);
end

--面对面加好友:加好友 有人加你为好友的通知消息
FriendDataManager.onFace2FaceNoticeAddFriend = function (self, data)
    DebugLog("FriendDataManager.onFace2FaceNoticeAddFriend");
    if not data then
        DebugLog("FriendDataManager.onFace2FaceNoticeAddFriend data is nil");
        return;
    end
    Banner.getInstance():showMsg("恭喜您，添加 "..tostring(data.a_nick).."("..tostring(data.a_mid)..")".." 成功！");
    self:onListener(kFriendFace2FaceNoticeAddFriend);
end

--public parameter which to regist the event that friend Socket request needs.
FriendDataManager.socketEventFuncMap = {
	--好友相关
	[FRIEND_CMD_FORWARD]	= FriendDataManager.onFriendRequest,
	[MSG_CMD_TO_SERVER]		= FriendDataManager.onFriendMsg,
};

-----------------------------------------------------------------PHP请求---------------------------------------------------------------------------------------------
--PHP响应
--[[
	function name      : FriendDataManager.onPhpMsgResponse
	description  	   : The method of recving PHP.
	param 	 	 	   : self
						 command     String  -- 命令字段
 	last-modified-date : Dec. 4 2013
	create-time		   : Dec. 4 2013
]]


FriendDataManager.onPhpMsgResponse = function ( self, param, cmd, isSuccess,... )
	if self.httpRequestsCallBackFuncMap[cmd] then 
		self.httpRequestsCallBackFuncMap[cmd](self,isSuccess,param,...)
	end
end
--发送请求(获取好友列表)

FriendDataManager.requestAllFriends = function(self)
	if GameConstant.platformType ~= PlatformConfig.platformFetion then
		local post_data 	= {};
		post_data.mid 		= PlayerManager:getInstance():myself().mid;
		post_data.fields 	= {"vip_level"};		
		SocketManager.getInstance():sendPack(PHP_CMD_REQUEST_FRIEND_LIST,post_data);
	else
		if isPlatform_Win32() then
			self:onFetionGetFriendList(0, "717366487,1905939021,8000119");
		else
			DebugLog("native_to_java kFetionGetFriendList");
			native_to_java(kFetionGetFriendList,"");
		end
	end
end

FriendDataManager.onFetionGetFriendList = function(self, status, code)
	DebugLog("status = " .. status);
	DebugLog("code = " .. code);
	if tonumber(status) == 0 then
		local post_data 	= {};
		post_data.mid 		= PlayerManager:getInstance():myself().mid;
		post_data.fetionID  = code;
		SocketManager.getInstance():sendPack(PHP_CMD_FETION_REQUEST_FRIEND_LIST, post_data);
	end
end

-- 飞信获取邀请和分享的APK和缩略图
FriendDataManager.requestFetionPicAndApk = function ( self )
	if GameConstant.platformType == PlatformConfig.platformFetion then 
		local post_data 	= {};
		post_data.mid 		= PlayerManager:getInstance():myself().mid;
		SocketManager.getInstance():sendPack(PHP_CMD_FETION_GET_PIC_AND_APK, post_data);
	end
end

FriendDataManager.onFetionGetPicAndApk = function ( self, isSuccess, data )
	Loading.hideLoadingAnim();
	if not isSuccess or not data then
		return;
	end
	local status = tonumber(data.status) or 0
	-- error
	if status ~= 1 then
		return ;
	end
	self.fetionPicUrl = data.data.picUrl
	self.fetionApkUrl = data.data.apkUrl
end

FriendDataManager.requestFetionScore = function ( self, data )
	local post_data = {};
	post_data.midAll = data;
	-- post_data.midAll = {12636027,12636029,12636027,12636029};
	SocketManager.getInstance():sendPack(PHP_CMD_FETION_SCORE, post_data);
end

FriendDataManager.onFetionScore = function (self, isSuccess, data)
	if not isSuccess or not data then
	    return;
	end

	local status = tonumber(data.status)
	if status ~= 1 then
		return ;
	end
	self.score = data.data;
end



--响应(获取好友列表)
FriendDataManager.onRequestFriendList = function(self,isSuccess,data)
	--如果失败
	DebugLog("FriendDataManager.onRequestFriendList")
	if not isSuccess or not data then
		return ;
	end
	mahjongPrint(data)
	local status = tonumber(data.status);
	-- error
	if status == -1 then
		return ;
	end
	
	local friendArray = data.data and data.data or {};

	if friendArray then
		--清空之前的数据
		self.m_Friends 		= {};
		for k, v in pairs(friendArray) do
            if v and type(v) == "table" then
            	local friend = {};
                friend.mid 		= tostring(v.mid) or ""
                friend.money 		= v.money or 0
                friend.sex 		= v.sex or 0
                friend.small_image 	= v.small_image or ""
                friend.gift_status 	= v.gift_status or 0
                friend.mnick 		= v.mnick or ""
                friend.alias 		= v.alias or ""
                friend.vip_level    = v.vip_level or 0
                friend.online 		= false--是否在线
                friend.isPhoneAdd   = v.source or 0;--是否是通讯录添加的好友
                if friend.mid then
	                self.m_Friends[friend.mid] = friend;
                end
            end
             

		end

	end
	DebugLog("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@")
	--mahjongPrint(self.m_Friends)
	self:onListener(kFriendRequestByPHP);
	FriendDataManager.getInstance():requestFriendsIsOnlineSocket(); -- 查询所有的在线好友
end


function FriendDataManager:requestPerFriendInformation( search_mid_table )
	self:QueryUserInfo(PHP_CMD_QUERY_USER_INFO_POP_FRIEND,search_mid_table)
end

function FriendDataManager:QueryUserInfo(queryCmd, search_mid_table, fields_table )
	local post_data = {}
	post_data.mid   = PlayerManager:getInstance():myself().mid
	post_data.fmids = search_mid_table
	post_data.fields= fields_table or {"mnick"	, "sex", "money", "level", "boyaacoin", "wintimes", "losetimes", 
									   "drawtimes", "large_image", "small_image", "charms", "likes", "like_status",
									   "gift_status", 	"alias", "vip_level"};
	if queryCmd == PHP_CMD_QUERY_USER_INFO_POP or 
		queryCmd == PHP_CMD_QUERY_USER_INFO_POP_FRIEND  or 
		queryCmd == PHP_CMD_QUERY_USER_INFO_POP_BROADCAST then 
		table.insert(post_data.fields,"city")
	end 
	
	SocketManager.getInstance():sendPack(queryCmd,post_data);
end 

function FriendDataManager:onQueryUserInfo( isSuccess, data )
	if self:checkQueryUserInfoResultIsSuccess(isSuccess, data) then 
		local result = self:parseQueryUserInfoResult(data)

		self:onListener(kFriendSearchByPHP, result);
	end 
end

function FriendDataManager:onQueryUserInfoPopFriend( isSuccess, data )
	if self:checkQueryUserInfoResultIsSuccess(isSuccess, data) then 
		local result = self:parseQueryUserInfoResult(data)
		---------
		for i=1,#result do
			if self:checkIsMyFriend(result[i].mid) then 
				self:updateMyFriendInfo(result[i])
			end 
		end

		if not result or #result < 1 or not HallScene_instance then
			return 
		end
   
		--------popWindow friend
        --remove by NoahHan
--		if self.userInfoWindow then 
--			delete(self.userInfoWindow)
--			self.userInfoWindow = nil 
--		end 
--		if not self.userInfoWindow then 
--			self.userInfoWindow = new(RankUserInfo, result[1], HallScene_instance, nil, result[1],2);
--			self.userInfoWindow:setOnWindowHideListener(self,function ( self )
--				self.userInfoWindow = nil
--			end)
--		end 
        --add by NoahHan
        self:onListener(kFriendDetailByPHP, result);

	end
    --增加php返回的提示
--    if isSuccess == false then
--        if data and data.msg then
--            Banner.getInstance():showMsg(tostring(data.msg));
--        end
--    end 
end

function FriendDataManager:onQueryUserInfoPop( isSuccess, data )
	if self:checkQueryUserInfoResultIsSuccess(isSuccess, data) then 
		local result = self:parseQueryUserInfoResult(data)
		
		if not result or #result < 1 or not HallScene_instance then
			return 
		end
		--------popWindow rank
		if self.userInfoWindow then 
			delete(self.userInfoWindow)
			self.userInfoWindow = nil 
		end 
		if not self.userInfoWindow then 
			self.userInfoWindow = new(RankUserInfo, result[1], HallScene_instance, result[1].large_image);
			self.userInfoWindow:setOnWindowHideListener(self,function ( self )
				self.userInfoWindow = nil
			end)
		end 

	end 
end

function FriendDataManager:onQueryUserInfoPopBroadcast( isSuccess, data )
	if self:checkQueryUserInfoResultIsSuccess(isSuccess, data) then 
		local result = self:parseQueryUserInfoResult(data)
	
		if not result or #result < 1 or not GameConstant.curGameSceneRef then--or not GameConstant.curGameSceneRef.broadcastPopWin then
			return 
		end
        parentNode = GameConstant.curGameSceneRef.broadcastPopWin
        if HallScene_instance  then
            if HallScene_instance.matchApplyWindow then
                if not HallScene_instance.matchApplyWindow.broadcastPopWin then
                    return;
                else
                    parentNode = HallScene_instance.matchApplyWindow.broadcastPopWin
                end
            elseif not HallScene_instance.broadcastPopWin then
                return;
            end
        elseif not GameConstant.curGameSceneRef.broadcastPopWin then
            return;
        end
		
		--------popWindow rank
		if self.userInfoWindow then 
			delete(self.userInfoWindow)
			self.userInfoWindow = nil 
		end 
		if not self.userInfoWindow then 
			self.userInfoWindow = new(RankUserInfo, result[1], parentNode, nil, result[1], 1);
			self.userInfoWindow:setOnWindowHideListener(self,function ( self )
				self.userInfoWindow = nil
			end)
		end 

	end 
end

function FriendDataManager:checkQueryUserInfoResultIsSuccess( isSuccess, data )
	if isSuccess and data then 
		local status = data.status
		if status == 1 then 
			return true
		end 
	end 
	return false
end

function FriendDataManager:checkIsMyFriend( mid )
	if mid and self.m_Friends[mid] then 
		return true
	end 
	return false
end

function FriendDataManager:updateMyFriendInfo( finfo )
	self.m_Friends_details[finfo.mid] = finfo;

	if tonumber(self.m_Friends[finfo.mid].money) ~= tonumber(finfo.money) then
		self.m_Friends[finfo.mid].money = finfo.money;
		local param 	= {};
		param.friendId 	= finfo.mid;
		param.money 	= finfo.money;
		self:onListener(kFriendMoneyUpdateByPHP, param);
	end
end

function FriendDataManager:parseQueryUserInfoResult( data )
	local detailInforArray = data.data and data.data or {};
	local result = {}

	if detailInforArray then
		for k, v in pairs(detailInforArray) do 
			local detailInfor 		= {};
			detailInfor.mid 		= tostring(v.mid)or "";
			detailInfor.charms 		= tonumber(v.charms) or 0;
			detailInfor.charms_level= tonumber(v.charms_level) or 0;
			detailInfor.charms_title= tonumber(v.charms_title) or 0;
			detailInfor.like_status = tonumber(v.like_status) or 0;
			detailInfor.likes 		= tonumber(v.likes) or 0;
			detailInfor.level 		= tonumber(v.level) or 0;
			detailInfor.vip_level   = tonumber(v.vip_level) or 0
			detailInfor.alias 		= v.alias or "";
			detailInfor.drawtimes 	= v.drawtimes or "";
			detailInfor.losetimes 	= v.losetimes or "";
			detailInfor.wintimes 	= v.wintimes or "";
			detailInfor.money 		= v.money or 0;
			detailInfor.gift_status	= tonumber(v.gift_status);
			detailInfor.sex 		= tonumber(v.sex) or 0;
			detailInfor.small_image = v.small_image or "";
			detailInfor.large_image = v.large_image or "";
			detailInfor.city        = v.city or "";
			detailInfor.mnick 		= v.mnick
			if detailInfor.mid ~= "" then 
				table.insert(result,detailInfor)
			end 
		end
	end
	return result
end


--点赞
FriendDataManager.likeIt = function(self,likeId)
	
	local post_data 		= {};
	post_data.mid 			= PlayerManager:getInstance():myself().mid;
	post_data.fmid 			= likeId;
	
	SocketManager.getInstance():sendPack(PHP_CMD_LIKE_IT,post_data);
end
--响应(点赞)
FriendDataManager.onLikeIt = function(self, isSuccess, data)
end

--赠送金币
FriendDataManager.giveMoney = function(self, friendId, index)
	
	local post_data 		= {};
	post_data.mid 			= PlayerManager:getInstance():myself().mid;
	post_data.fmid 			= friendId;
	
	self.feedbackMoneyItemIndex = index;

	SocketManager.getInstance():sendPack(PHP_CMD_GIVE_MONEY,post_data);
end
--响应(赠送)
FriendDataManager.onGiveMoney = function(self, isSuccess, data)
	DebugLog("FriendDataManager.onGiveMoney")
	if not isSuccess or not data or not data.status then
		return;
	end

	local status = data.status
	Banner.getInstance():showMsg(data.msg or "");


	if self.onFeedbackMoneyCallbackFunc then
		self.onFeedbackMoneyCallbackFunc( self.feedbackMoneyItemIndex, 1 == status );
	end

	if 1 == status then
		local param = {};
		param.id 		= data.data.fmid
		param.status 	= status;

		self:onListener(kFriendGiveRequestByPHP, param);
	end
end

--领取金币
FriendDataManager.getMoney = function(self, friendId, sendTime, index)
	
	local post_data 		= {};
	post_data.mid 			= PlayerManager:getInstance():myself().mid;
	post_data.fmid 			= friendId;
	post_data.sendtime 		= sendTime;

	self.getMoneyItemIndex = index;
	
	SocketManager.getInstance():sendPack(PHP_CMD_GET_MONEY,post_data);	
end
--响应(领取)
FriendDataManager.onGetMoney = function(self, isSuccess, data)

	if not isSuccess or not data then
		return ;
	end

	local status = data.status

	if status ~= 1 then
		Banner.getInstance():showMsg(data.msg or "");
		if self.onGetMoneyCallbackFunc then
			self.onGetMoneyCallbackFunc( self.getMoneyItemIndex, false );
		end
		return ;
	end

	local money  = data.data.money

	PlayerManager:getInstance():myself():addMoney(tonumber(money));
	Banner.getInstance():showMsg("领取好友赠送金币成功");

	if self.onGetMoneyCallbackFunc then
		self.onGetMoneyCallbackFunc( self.getMoneyItemIndex, true );
	end
end

FriendDataManager.setOnGetMoneyListener = function( self, func )
	self.onGetMoneyCallbackFunc = func;
end

FriendDataManager.setOnFeedbackMoneyListener = function( self, func )
	self.onFeedbackMoneyCallbackFunc = func;
end

--好友动态
FriendDataManager.requestFriendNews = function(self)
	
	local post_data 		= {};
	post_data.mid 			= PlayerManager:getInstance():myself().mid;
	
	SocketManager.getInstance():sendPack(PHP_CMD_REQUEST_FRIEND_NEWS,post_data);
end
--响应(好友动态)
FriendDataManager.onRequestFriendNews = function(self, isSuccess, data)
	--如果离线消息已经获取
	if not isSuccess or not data then
		return ;
	end
	local status = data.status

	if status ~= 1 then
		return ;
	end

	self.m_FriendNotReadN = 0;

	--删除旧记录
	local lastRemove = 1;
	while true do
		local bRemove = false;
		for i = lastRemove, #self.m_FriendsNews do
			if tonumber(self.m_FriendsNews[i].type) ~= 3 then
				table.remove(self.m_FriendsNews, i);
				lastRemove 	= i;
				bRemove 	= true;
				break;
			end
		end
		if not bRemove then
			break;
		end
	end

	
	local friendNewsArray = data.data and data.data or {};

	for k, v in pairs(friendNewsArray) do 
		local news = {};

		news.type 		= v.type
		news.mid 		= v.mid
		news.mnick 		= v.mnick
		news.sex 		= v.sex
		news.photo 		= v.poto
		news.money 		= v.money
		news.sendtime 	= v.sendtime

		news.vip        = v.vip
		news.charms      = v.charms

		local needToInsert = true;

		if tonumber(news.type) == 3 then
			msgContent= v.content and v.content or {};  --time & msg

			local firstMsg = true;

			for k, v in pairs(msgContent) do
				if firstMsg then
					firstMsg = false;
					--插入时间
					local message   = {};
					message.id 		= FriendMessageManager.getInstance():getUniqueId();
					message.speakID = 0;
					message.state	= 1;
					message.chat 	= getDateStringFromTime(tonumber(v.time))
					FriendMessageManager.getInstance():saveAMessageToFileNewVersion(PlayerManager.getInstance():myself().mid, news.mid, message);
				end

				local message  = {};
				message.speakID = news.mid;
				message.chat 	= v.msg
				message.id 		= FriendMessageManager.getInstance():getUniqueId();
				message.state 	= 1;
				FriendMessageManager.getInstance():saveAMessageToFileNewVersion(PlayerManager.getInstance():myself().mid, news.mid, message);
			end

			
			--检查是否已出现
			for i = 1, #self.m_FriendsNews do
			
				if tonumber(self.m_FriendsNews[i].type) == 3 and tonumber(self.m_FriendsNews[i].mid) == tonumber(news.mid) then
					needToInsert = false;
				end
			end

		end

		if needToInsert then
			self.m_FriendsNews[#self.m_FriendsNews + 1] = news;
		end
	end
	self:saveFriendNews(PlayerManager.getInstance():myself().mid);
	--load native unFeedback data
	FeedbackGoldData.loadNativeDataIntoDest(PlayerManager.getInstance():myself().mid, self.m_FriendsNews)
	--
	self:onListener(kFriendNewsRequestByPHP, self:getFriendNewsCount());
end


FriendDataManager.getFriendNewsCount = function ( self )
	-- body
	--DebugLog("FriendDataManager.getFriendNewsCount: #self.m_FriendsNews=" .. #self.m_FriendsNews .." self.m_FriendNotReadN:"..self.m_FriendNotReadN)
	return #self.m_FriendsNews + self.m_FriendNotReadN
end

FriendDataManager.getTipsCount = function ( self )
	-- body
	--DebugLog("FriendDataManager.getTipsCount: #self.m_FriendsNews=" .. #self.m_FriendsNews .." self.m_FriendNotReadN:"..self.m_FriendNotReadN)
	local messageNum = 0
	for i=1,#self.m_FriendsNews do
	--	DebugLog("type = " .. self.m_FriendsNews[i].type)
		if tonumber(self.m_FriendsNews[i].type) == 3 then  --好友消息
			messageNum = messageNum + 1
		end 
	end
	--DebugLog("return" .. messageNum)
	return messageNum + self.m_FriendNotReadN
end

--好友动态的保存
FriendDataManager.saveFriendNews = function ( self, myId )
	-- body
	-- data format : count [...]
	local myId 			= ""..myId;
	local newsFileName 	= "friendNews"..myId; --强制转为字符串
	local newsFile 		= new(Dict, newsFileName);

	newsFile:load();
	newsFile:delete();

	local count = 0;

	for i = 1, #self.m_FriendsNews do
		if tonumber(self.m_FriendsNews[i].type) == 3 then
			count = count + 1;
		end
	end

	newsFile:setInt("news_count", count);

	local index = 1;

	for i = 1, #self.m_FriendsNews do

		if tonumber(self.m_FriendsNews[i].type) == 3 then
			newsFile:setString("type" .. index,  self.m_FriendsNews[i].type);
			newsFile:setString("mid" ..  index,  self.m_FriendsNews[i].mid);
			newsFile:setString("mnick" ..index,  self.m_FriendsNews[i].mnick);
			newsFile:setString("sex" ..  index,  self.m_FriendsNews[i].sex);
			newsFile:setString("photo" ..index,  self.m_FriendsNews[i].photo);
			newsFile:setString("money" ..index,  self.m_FriendsNews[i].money);
			newsFile:setString("sendtime" ..index,  self.m_FriendsNews[i].sendtime);
			index = index + 1;
		end
	end

	newsFile:save();
	newsFile:delete();
	delete(newsFile);

	return #self.m_FriendsNews;

end
--好友动态的读取
FriendDataManager.loadFriendNews = function ( self, myId)
	-- body
	-- data format : count [...]
	local myId 			= ""..myId;
	local newsFileName 	= "friendNews"..myId;
	local newsFile 		= new(Dict, newsFileName);

	newsFile:load();

	local count = newsFile:getInt("news_count", 0);

	for i = 1, count do

		local news 		= {};
		news.type 		= newsFile:getString("type" .. i, 0);
		news.mid 		= newsFile:getString("mid" ..  i, 0);
		news.mnick 		= newsFile:getString("mnick" ..i, 0);
		news.sex 		= newsFile:getString("sex" ..  i, 0);
		news.photo 		= newsFile:getString("photo" ..i, 0);
		news.money 		= newsFile:getString("money" ..i, 0);
		news.sendtime 	= "" .. newsFile:getString("sendtime" ..i, 0);

		news.content 	= {};
		contentCount 	= newsFile:getInt("ctn_count" ..i,  0);

		for j = 1, contentCount do
			local content 	= {};
			content.time 	= newsFile:getString("ctn" .. i .. "time" .. j,  0);
			content.msg 	=  newsFile:getString("ctn" .. i .. "msg" .. j,  0);
			news.content[#news.content + 1] = content;
		end
		self.m_FriendsNews[#self.m_FriendsNews + 1] = news;
	end

	newsFile:delete();
	delete(newsFile);

	return #self.m_FriendsNews;

end

--好友动态数量
FriendDataManager.requestFriendNewsNum = function(self)
	
	local post_data 		= {};
	post_data.mid 			= PlayerManager:getInstance():myself().mid;

	if PlayerManager:getInstance():myself().mid and tonumber(PlayerManager:getInstance():myself().mid) ~= 0 then
		SocketManager.getInstance():sendPack(PHP_CMD_REQUEST_FRIEND_NEWS_NUM,post_data);
	end
end
--响应(好友动态数量)
FriendDataManager.onRequestFriendNewsNum = function(self, isSuccess, data)
	DebugLog("FriendDataManager.onRequestFriendNewsNum")
	if not isSuccess or not data then
		return ;
	end
	local status = tonumber(data.status)
	
	-- error
	if -1 == status then
		return ;
	end
	local news 				= data.data and data.data or {};
	if news.num then
		self.m_FriendNotReadN	= tonumber(news.num or 0)
		self:onListener(kFriendNewsNumRequestByPHP, self:getFriendNewsCount());
	end
end

--修改好友备注
FriendDataManager.requestModifyFriendAlias = function(self, friendId, alias)
	
	local post_data 		= {};
	post_data.mid 			= PlayerManager:getInstance():myself().mid;
	post_data.fmid 			= friendId;
	post_data.alias 		= alias;
	
	SocketManager.getInstance():sendPack(PHP_CMD_REQUEST_MODIFY_FRIEND_ALIAS,post_data);
end
--响应(修改好友备注)
FriendDataManager.onModifyFriendAlias = function(self, isSuccess, data)
	
	if not isSuccess or not data then
		return ;
	end

	local status = tonumber(data.status);
	-- error
	if status == -1 then
		return ;
	end

	local aliasData = data.data and data.data or {};

	local param = {};

	param.friendId 	= aliasData.fmid or "";
	param.alias 	= aliasData.alias or "";
	--基本信息
	if self.m_Friends[param.friendId] then
		self.m_Friends[param.friendId].alias = param.alias;
	end
	--详细信息
	if self.m_Friends_details[param.friendId] then
		self.m_Friends_details[param.friendId].alias = param.alias;
	end

	self:onListener(kFriendModifyAliasRequestByPHP, param);

end

--邀请好友进入比赛报名界面
FriendDataManager.invite_match = function (self, data)
    DebugLog("[FriendDataManager] invite_match");

    

    

    --
    if not data then--or data.fid == -1 then 
		return 
	end
    if not HallScene_instance then
        return;
    end
    local param   = {}
    param.userId    = PlayerManager.getInstance():myself().mid;
	param.otherId   = data.a_uid;
	param.name      = data.b_name or "";
	param.othername = data.a_name or "";

    local content = "您的好友"..tostring(data.a_name).."邀请您加入比赛["..tostring(data.match_name).."],您确定是否加入?"
	local view = PopuFrame.showNormalDialogForCenter( "温馨提示", 
														content,
									            HallScene_instance , 
									  							0, 
									  							0, 
									  						false,
									  						false,
									  					    "确定",
									  					    "取消");
	view:setConfirmCallback(self,function (self)
        --回复确认消息

		param.result = 0;
		param.cmd2   = FRIEND_CMD_INVITE_OTHER_RET2;
		SocketManager.getInstance():sendPack(FRIEND_CMD_FORWARD,param);	
        --进入比赛报名界面
        HallScene_instance:onGoToMatchRoom( data.match_level, data.match_type );
	end)
    view:setCancelCallback(self,function(self)
		param.result = kNumMinusOne;---0同意 -1拒绝 -2在房间中  -3不在线
		param.cmd2   = FRIEND_CMD_INVITE_OTHER_RET2;
		SocketManager.getInstance():sendPack(FRIEND_CMD_FORWARD,param);	

	end)


	view:setCloseCallback(self,function (self)
		param.result = kNumMinusOne;---0同意 -1拒绝 -2在房间中  -3不在线
		param.cmd2   = FRIEND_CMD_INVITE_OTHER_RET2;
		SocketManager.getInstance():sendPack(FRIEND_CMD_FORWARD,param);	
	end)

            
--	local fid     = data.fid 

--	local param   = {}
--    param.userId    = PlayerManager.getInstance():myself().mid;
--	param.otherId   = data.inviteMid;
--	param.name      = data.myName or kNullStringStr;
--	param.othername = data.inviteName or kNullStringStr;

--	local desc = "("..data.roundNum.."局、"..global_get_wanfa_desc(data.wanfa).."、房间号"..data.fid..")。"
--	local content = "您的好友"..tostring(data.inviteName).."邀请您加入好友对战"..desc.."中途不可退出,您确定是否加入?"

--	local inFriendMatch = false
--	if FriendMatchRoomScene_instance and (FriendMatchRoomScene_instance:isRoundNotBeginning() and (not FriendMatchRoomScene_instance:isRoundGameOver())) then 
--		inFriendMatch = true
--	end 
--	if PlayerManager.getInstance():myself().isInGame or MatchRoomScene_instance or inFriendMatch then   --普通场牌局中-- 比赛场 
--		local view = PopuFrame.showNormalDialogForCenter( "温馨提示", 
--															content,
--									  GameConstant.curGameSceneRef , 
--									  							  0, 
--									  							  0, 

--									  						   true,
--									  						  false,
--									  					  "我知道了");
--		view:setCallback(view, function ( view, isShow )
--			param.result = kNumMinusTwo;---0同意 -1拒绝 -2在房间中  -3不在线
--			param.cmd2   = FRIEND_CMD_INVITE_OTHER_RET2;
--			SocketManager.getInstance():sendPack(FRIEND_CMD_FORWARD,param);	
--		end);
--	else 
--		local view = PopuFrame.showNormalDialogForCenter( "温馨提示", 
--															content,
--									  GameConstant.curGameSceneRef , 
--									  							  0, 
--									  							  0, 
--									  						  false,
--									  						  false,
--									  					     "确定",
--									  					     "取消");
--		view:setConfirmCallback(self,function (self)
--			param.result = kNumZero;
--			param.cmd2   = FRIEND_CMD_INVITE_OTHER_RET2;
--			SocketManager.getInstance():sendPack(FRIEND_CMD_FORWARD,param);	

--		    FMRInviteManager.getInstance():queryCanEnterRoom( tonumber(fid) , 
--		                                 FMRInviteManager.INVITE_FROM_HALL , 
--		                                                               self, 
--		                                          self.joinFriendMatchSuccessCallback, 
--		                                          self.joinFriendMatchFailedCallback )
--		end)

--		view:setCancelCallback(self,function(self)
--			param.result = kNumMinusOne;---0同意 -1拒绝 -2在房间中  -3不在线
--			param.cmd2   = FRIEND_CMD_INVITE_OTHER_RET2;
--			SocketManager.getInstance():sendPack(FRIEND_CMD_FORWARD,param);	

--			if FriendMatchRoomScene_instance and FriendMatchRoomScene_instance:isRoundGameOver() then 
--				FriendMatchRoomScene_instance:exitGame()
--			end 
--		end)


--		view:setCloseCallback(self,function (self)
--			param.result = kNumMinusOne;---0同意 -1拒绝 -2在房间中  -3不在线
--			param.cmd2   = FRIEND_CMD_INVITE_OTHER_RET2;
--			SocketManager.getInstance():sendPack(FRIEND_CMD_FORWARD,param);	

--			if FriendMatchRoomScene_instance and FriendMatchRoomScene_instance:isRoundGameOver() then 
--				FriendMatchRoomScene_instance:exitGame()
--			end 
--		end)

--	end 
end


--public parameter which to regist the event that friend PHP request needs.
FriendDataManager.httpRequestsCallBackFuncMap ={
	[PHP_CMD_REQUEST_FRIEND_LIST]         	= FriendDataManager.onRequestFriendList,


    [PHP_CMD_QUERY_USER_INFO]               = FriendDataManager.onQueryUserInfo,            --纯查询
    [PHP_CMD_QUERY_USER_INFO_POP]           = FriendDataManager.onQueryUserInfoPop,         --查询并弹窗基本信息(排行榜) 
    [PHP_CMD_QUERY_USER_INFO_POP_BROADCAST] = FriendDataManager.onQueryUserInfoPopBroadcast,--查询并弹窗(世界聊天)    
    [PHP_CMD_QUERY_USER_INFO_POP_FRIEND]    = FriendDataManager.onQueryUserInfoPopFriend,   --查询并弹窗(好友)	

	[PHP_CMD_LIKE_IT]			          	= FriendDataManager.onLikeIt,
	[PHP_CMD_GIVE_MONEY]			      	= FriendDataManager.onGiveMoney,
	[PHP_CMD_GET_MONEY]			      		= FriendDataManager.onGetMoney,
	[PHP_CMD_REQUEST_FRIEND_NEWS]		  	= FriendDataManager.onRequestFriendNews,
	
	[PHP_CMD_REQUEST_FRIEND_NEWS_NUM]	  	= FriendDataManager.onRequestFriendNewsNum,
	[PHP_CMD_REQUEST_MODIFY_FRIEND_ALIAS]   = FriendDataManager.onModifyFriendAlias,
	[PHP_CMD_FETION_REQUEST_FRIEND_LIST]    = FriendDataManager.onRequestFriendList,
	[PHP_CMD_FETION_GET_PIC_AND_APK]        = FriendDataManager.onFetionGetPicAndApk,
	[PHP_CMD_FETION_SCORE]              	= FriendDataManager.onFetionScore,
};

