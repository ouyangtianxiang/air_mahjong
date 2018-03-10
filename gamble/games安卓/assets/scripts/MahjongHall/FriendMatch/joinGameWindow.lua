local joinGame = require(ViewLuaPath.."joinGame");

JoinGameWindow = class(SCWindow);

function JoinGameWindow:ctor(level)
	DebugLog("JoinGameWindow:ctor")

    --拉取配置
    GlobalDataManager.getInstance():requestFriendMatchConfig()

	self:initLoadView()

	self.level = level
	self.passwordArray = {}

	--EventDispatcher.getInstance():register(SocketManager.s_serverMsg, self, self.onSocketPackEvent);
end

function JoinGameWindow:dtor()
	DebugLog("JoinGameWindow:dtor")
	--EventDispatcher.getInstance():unregister(SocketManager.s_serverMsg, self, self.onSocketPackEvent);
end

-- JoinGameWindow.onSocketPackEvent = function ( self, param, cmd )
-- 	if self.socketEventFuncMap[cmd] then
-- 		DebugLog("HallScene deal socket cmd "..cmd);
-- 		self.socketEventFuncMap[cmd](self, param);
-- 	end
-- end

function JoinGameWindow:initLoadView()

	self._layout = SceneLoader.load(joinGame);
	self:addChild(self._layout)

	local winBg = publ_getItemFromTree(self._layout, {"bg"});
	self:setWindowNode( winBg );
	self:setCoverEnable( true );-- 允许点击cover

	-----passwordView
	self.passwordTexts = {}
	for i=1,6 do
		self.passwordTexts[i] = publ_getItemFromTree(self._layout,{"bg","passwordView","bg"..i, "txt"})
	end

	-----inputView
	self.inputButtons = {}
	for i=0,9 do
		self.inputButtons[i]  = publ_getItemFromTree(self._layout,{"bg","inputView","Button"..i})
		self.inputButtons[i]:setOnClick(self,self.clickNumberButtonCallback)
		self.inputButtons[i].__tag = i
	end
	self.deleteBtn              = publ_getItemFromTree(self._layout,{"bg","inputView","ButtonDel"})
	self.deleteBtn:setOnClick(self,self.clickDeleteButtonCallback)
	

	publ_getItemFromTree(self._layout,{"bg","close"}):setOnClick(self,function ( self )
		self:hideWnd()
	end)
end 

function JoinGameWindow:clickDeleteButtonCallback()
	DebugLog("JoinGameWindow:clickDeleteButtonCallback")
	if #self.passwordArray > 0 then 
		local pos = #self.passwordArray
		self.passwordTexts[pos]:setVisible(false)
		table.remove(self.passwordArray)
	end 
end

function JoinGameWindow:clickNumberButtonCallback(finger_action,x,y,drawing_id_first,drawing_id_current,sender)
	DebugLog("JoinGameWindow:clickNumberButtonCallback")
	if not sender then 
		return 
	end 

	local num = sender.__tag or -1
	if num ~= -1 then 
		self:inputAnNumber(num)
	end 
end

function JoinGameWindow:inputAnNumber( num )
	DebugLog("JoinGameWindow:inputAnNumber:"..num)
	if #self.passwordArray < 6 then 
		local pos = #self.passwordArray + 1
		self.passwordTexts[pos]:setText(tostring(num))
		self.passwordTexts[pos]:setVisible(true)
		table.insert(self.passwordArray,num)

		if pos == 6 then 
		    FMRInviteManager.getInstance():queryCanEnterRoom( tonumber(self:getRoomId()), 
		                                 FMRInviteManager.INVITE_FROM_HALL , 
		                                                               self, 
		                                          self.requestMatchPasswordRoom, 
		                                          self.joinFailed )
			--self:requestMatchPasswordRoom(table.concat(self.passwordArray,""))
		end 
	end 
end

function JoinGameWindow:requestMatchPasswordRoom( fid )
	DebugLog("JoinGameWindow:requestMatchPasswordRoom:"..fid)

	local param = {};
	local player = PlayerManager.getInstance():myself();
	local uesrInfo = player:getUserData();
	
	param.level 	= self.level;	
	param.money 	= player.money;
	param.userInfo  = json.encode(uesrInfo);
	param.mtk 	 	= player.mtkey;
	param.from 		= player.api;
	param.version 	= 1;
	param.versionName 	  = GameConstant.Version;
	--param.changeTableFlag = changeTableFlag;
	param.roomNum   = tonumber(fid)
	
	param.isJoinRoom = true
	
	RoomData.getInstance():setPrivateRoomData(param);
	StateMachine.getInstance():changeState(States.Loading,nil,States.FriendMatchRoom);	
	self:hideWnd()	
end


-- 遮罩点击消息响应函数
function JoinGameWindow.onCoverClick( self )
	DebugLog("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
end

function JoinGameWindow:processJoinBattlePre( data  )--//0表示存在,1表示不存在,有错误

end

function JoinGameWindow:joinFailed( )
	for i=1,6 do
		self.passwordTexts[i]:setVisible(false)
	end
	self.passwordArray = {}	
end

function JoinGameWindow:getRoomId( )
	return table.concat(self.passwordArray,"")
end
-- function JoinGameWindow:joinSuccess( )

-- 	self:requestMatchPasswordRoom(table.concat(self.passwordArray,""))
-- end
-- JoinGameWindow.socketEventFuncMap = {
-- 	[SERVER_CMD_RESPONSE_JOIN_BATTLE_PRE] = JoinGameWindow.processJoinBattlePre,
-- }
