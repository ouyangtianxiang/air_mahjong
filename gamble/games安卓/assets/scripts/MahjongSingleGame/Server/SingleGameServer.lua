require("MahjongSingleGame/Server/SingleGamePlayer");
require("MahjongConstant/OperatType");
require("MahjongData/PlayerManager");
require("MahjongData/Player");
require("libs/bit");

SingleGameServer = class(RoomState);
require("MahjongSingleGame/Server/ServerProcess");

SingleGameServer.ctor = function(self)
    self.lastMoney = 50000;

    self.myNetPlayerData = PlayerManager.getInstance():myself();
    self.players = nil;
    self.consoleAi = nil;
    self.consoleCardType = nil;
    EventDispatcher.getInstance():register(Event.RoomSocketClient,self,self.onMsgServerDeal);
    self.lastcard = {}; --还剩下的牌数
    self.serverAnimIndex = nil; -- 服务器的可变值 在需要延后做什么事情时候使用 
    self.OperatAnimIndex = nil;
    self.sendFaceAnim = nil;
    self.currentOperaSeatId = nil;
    self.lastOperaSeatId = nil;
    self.lastOperaType = 0;
    self.highPriority = 1;
    self.playsCanOperaValue = {[1] = {}, [2] = {}, [3] = {}, [4] = {}};  --玩家可以操作的值 
    self.playsQiangGangHu = {[1] = {}, [2] = {}, [3] = {}, [4] = {}};  --处理玩家抢杠胡                
    self._gamestart = false;
    self._gameend = false;
    self.di = 100;

    self.isCanleft = true;
    self.canTDhu = true;
    self.qiangganghu = false;
    self.huOrder = {};
    self.playerHuTable = {};
    self.playerHuTable.normalInfo = {};
    self.playerHuTable2 = {};  --新结算
    self.playerHuTable2.normalInfo = {};
    self:create();
    DebugLog("【单机游戏】服务器初始化完毕...");
end

SingleGameServer.create = function(self)
    self:initChatStr();
    if not self.players then 
        self.players = {new (SingleGamePlayer, self, 1),
                        new (SingleGamePlayer, self, 2),
                        new (SingleGamePlayer, self, 3),
                        new (SingleGamePlayer, self, 4)};
    end
    self:playerLoginRoom();
    if self.sendFaceAnim == nil then
        math.randomseed(os.time());
        self.sendFaceAnim = new (AnimInt, kAnimLoop, -1, -1, 18000);
        self.sendFaceAnim:setEvent(self, SingleGameServer.robotSendFaceOrChat);
    end
end

SingleGameServer.onClientCmdLogin = function(self,param)

end

SingleGameServer.onClientCmdReady = function(self,param)
    self:readyStart();  --准备开始
end

SingleGameServer.onClientCmdChat = function(self, param)
	local msg = param.msg;
	local params = {};
	params.userId = 1;
	params.chatinfo = msg;
    self:dispatch_consoleServer_msg(CLIENT_COMMAND_USER_CHAT, params);
end

SingleGameServer.robotSendFaceOrChat = function(self)
	local facetable = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11,
						101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111,
						112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 123,
						124, 125, 126, 127, 401, 402, 403, 404, 405, 406, 407,
                        408, 409, 410, 411, 412};
	local num = #facetable;
	local index = math.random(1, num);
	local uid = math.random(2, 4);

	local params ={};
	params.userId = uid; 
	local chatValue = math.random(1, 8);
	local sendType = math.random(1, 3);
	if sendType == 1 then
        params.faceType = facetable[index];
        DebugLog("【单机游戏】机器人"..uid.."发送表情:"..params.faceType);
        self:dispatch_consoleServer_msg(CLIENT_COMMAND_SEND_FACE, params);
	elseif sendType == 2 then
        local language = g_DiskDataMgr:getAppData("language", kSichuanese)
        if language == kMandarin then
            params.chatinfo = self.chatStrs[string.format("sysChatText_normal%d", chatValue)];
        else
            params.chatinfo = self.chatStrs[string.format("sysChatText%d", chatValue)];

        end

        
        DebugLog("【单机游戏】机器人"..uid.."发送聊天:"..params.chatinfo);
        self:dispatch_consoleServer_msg(CLIENT_COMMAND_USER_CHAT, params);
    else
        params.flag = 1;
        params.mid = uid;
        params.count = 1;
        params.data = {};
        local tab = {};
        while (tab.tagmid == uid or tab.tagmid == nil) do
            tab.tagmid = math.random(1, 4);
        end
        tab.pid = math.random(1, 10);
        table.insert(params.data , tab);
        self:dispatch_consoleServer_msg(SERVERGB_BROADCAST_USEPROP, params);
	end     
end

SingleGameServer.useProp = function (self, param)
    local params ={};
    params.flag = 1;
    params.mid = 1;
    params.count = 1;
    params.data = {};
    params.money = 10;
    local tab = {};
    while (tab.tagmid == uid or tab.tagmid == nil) do
        tab.tagmid = param.b_uid;
    end
    tab.pid = param.p_id;
    table.insert(params.data , tab);
    self:dispatch_consoleServer_msg(SERVERGB_BROADCAST_USEPROP, params);
end

SingleGameServer.onClientCmdFace = function(self, param)
	local faceType = param.faceType;
	local params = {};
	params.userId = 1; 
	params.faceType = faceType;
	self:dispatch_consoleServer_msg(CLIENT_COMMAND_SEND_FACE, params);
end

--服务器收到客户端的操作
SingleGameServer.onClientCmdOperator = function(self, param)
    local value = param.operatorValue;
    local card = param.cardValue;
    DebugLog("【单机】操作值："..value.."  操作牌："..card);

    --处理抢杠胡
    if self.playsQiangGangHu[1].canOpera then  
        local userId_q = self.playsQiangGangHu[1].userId;
        local card_q = self.playsQiangGangHu[1].card;
        local opera_q = self.playsQiangGangHu[1].opera;
        local bakseatid_q = self.playsQiangGangHu[1].bakseatid;
        if value == 0 then
			self:sendCardToPlayer(bakseatid_q);
        elseif hu_qiangGang(value) then  
            local priority = 4;
            self:playsOperator(userId_q, card_q, opera_q, bakseatid_q, true, bakseatid_q);
            self.players[userId_q].ishu = true;         
            self:tellPlayerOperator(userId_q, card_q, opera_q, bakseatid_q); 
            if self.someOneHu then
                self:dispatch_consoleServer_msg(SERVER_BROADCAST_HU_TO_TABLE, self.playerHuTable);
                self.playerHuTable.normalInfo = {};
            end           
            self.currentOperaSeatId = 1;
            if self:getHuCount() > 2 then
            	self:gameOver();
            	return;
            end
            if priority == 4 then --如果是胡牌 胡牌的下家出牌
            	self:sendCardToPlayer();
            end 
        end 
        return;  
    end  

    local opValue = self.playsCanOperaValue[1].opValue;
    local canOperator = false; -- 自己取消看其他玩家能否操作 
    local priority = 0;       
    for num = 2, 4 do
		if self.playsCanOperaValue[num].priority and self.playsCanOperaValue[num].priority > 0 then
            if(self.playsCanOperaValue[num].priority > priority) then 
                priority = self.playsCanOperaValue[num].priority;                
            end  
            canOperator = true;
        end
    end  
    if value == 0 and self.currentOperaSeatId ~= 1 then --客户端取消操作 如果机器人有更低优先级操作需要处理 如果不是自己操作发牌到下个玩家
        if canOperator then
			self.highPriority = priority;
            self.playsCanOperaValue[1].priority = 0;
            self:countdownOutCard(self.currentOperaSeatId, card, true); 
        else 
            self:sendCardToPlayer();
        end
        return;
    end 
    if(bit.band(opValue,value) ==0 )then --判断客户端操作是否有效
        return;   
    end

    local priority = 0;       
    if hu_zimo(value) or hu_qiang(value) or hu_qiangGang(value) then 
        priority = 4;
    elseif peng_gang(value) or an_gang(value) or bu_gang(value) then
        priority = 3;
    elseif peng(value) then
        priority = 2;
    end
    self.playsCanOperaValue[1].opValue = value;
    self.playsCanOperaValue[1].priority = priority;  
    self:countdownOutCard(1, card, false); 
end

--服务器接收自己出牌
SingleGameServer.onClientCmdOutcard = function(self, param)
    local card = param.card;
    self.players[1]:minusCard(card);  --自己手牌 服务器删除一张牌
    self:setOperatorByOutCard(card,true);
end

--key 要移除的值,每次移除一个元素
SingleGameServer.removeTableValueByKey = function(self, tb, key, num)
    for i = 1, num do
    	if type(tb) == "table" then
        	for k, v in pairs(tb) do
        		if v == key then
           			table.remove(tb, k);
           			break;
        		end
       		end
     	else
      		return;
   		end;
    end
end

--服务器接收托管命令
SingleGameServer.onClientCmdAi = function(self, param)
	local type_ai = param.type;
    self.players[1].isAI = type_ai; 
    if self.currentOperaSeatId ==1 then
        self:robotOutCard();
    end 
    local param = {};
    param.nUserId = 1;
    param.nAIType = type_ai;
    self:dispatch_consoleServer_msg(SERVER_BROADCAST_USER_AI, param);
end

SingleGameServer.userExit = function( self )
    for k, v in pairs(PlayerManager.getInstance().playerList) do
        if v.isMyself then
            table.remove(PlayerManager.getInstance().playerList, k);
            table.insert(PlayerManager.getInstance().playerList, GameConstant.mySingleSelf);
            GameConstant.mySingleSelf = nil;
        end
    end
    delete(self.serverAnimIndex);
    self.serverAnimIndex = nil; 
    delete(self.OperatAnimIndex);
    self.OperatAnimIndex = nil; 
    delete(self.sendFaceAnim);
    self.sendFaceAnim = nil;
    delete(self);
end

--服务器收到客户端发送过来的消息
SingleGameServer.onMsgServerDeal = function(self, eventType, param)
    DebugLog("【单机游戏】收到客户端数据包CMD:"..string.format("0x%02x",eventType));
    if SingleGameServer.s_socketPacketFuncMap[eventType] then
        SingleGameServer.s_socketPacketFuncMap[eventType](self,param);
    end
end

SingleGameServer.s_socketPacketFuncMap = {
  [CLIENT_COMMAND_LOGIN] = SingleGameServer.onClientCmdLogin;  --玩家登陆
  [CLIENT_COMMAND_READY] = SingleGameServer.onClientCmdReady;  --玩家准备了
  [CLIENT_COMMAND_USER_CHAT] = SingleGameServer.onClientCmdChat;  --玩家聊天
  [CLIENT_COMMAND_SEND_FACE] = SingleGameServer.onClientCmdFace;  --玩家发送表情
  [CLIENT_COMMAND_TAKE_OPERATION] = SingleGameServer.onClientCmdOperator;  --玩家操作 碰杠操作
  [CLIENT_COMMAND_OUTCARD] = SingleGameServer.onClientCmdOutcard;  --玩家出牌
  [CLIENT_COMMAND_REQUEST_AI] = SingleGameServer.onClientCmdAi;    --玩家托管
  [CLIENT_COMMAND_LOGOUT] = SingleGameServer.userExit;  --玩家退出房间
  [SERVERGB_BROADCAST_USEPROP] = SingleGameServer.useProp;  --使用道具
};

--服务器情况数据
SingleGameServer.dtor = function(self)
	EventDispatcher.getInstance():unregister(Event.RoomSocketClient, self, self.onMsgServerDeal);
 	for num = 1, 4 do 
        if self.players and self.players[num] then
    	   delete(self.players[num]);
        end
 	end
	self.notFirstGame = nil;
	self.players = nil;
	delete(self.consoleAi);
	self.consoleAi = nil;

	delete(self.consoleCardType);
	self.consoleCardType = nil;

	self._gamestart = false;
	self._gameend = false;
	self.canTDhu = true;
	self.qiangganghu = false;
	DebugLog("【单机游戏】本地服务器已经完全关闭...");
end

SingleGameServer.clearData = function(self)
	for num = 1, 4 do 
    	delete(self.players[num]);
	end
	delete(self.consoleAi);
	delete(self.consoleCardType);
	self._gamestart = false;
	self._gameend = false;
	self.currentOperaSeatId = nil;
	self.lastOperaSeatId = nil;
	self.lastOperaType = 0;
	delete(self.serverAnimIndex);
	self.serverAnimIndex = nil
	delete(self.OperatAnimIndex);
	self.OperatAnimIndex = nil;
	delete(self.sendFaceAnim);
	self.sendFaceAnim = nil;
	self.highPriority = 1;
	self.playsCanOperaValue = {[1] = {},[2] = {},[3] = {},[4] = {}};   
	self.playsQiangGangHu = {[1] = {},[2] = {},[3] = {},[4] = {}};                      
	self.isCanleft = true;
	self.huOrder = {};
	self.canTDhu = true;
	self.qiangganghu = false;
end

SingleGameServer.initChatStr = function ( self )
	self.chatStrs = {};
	self.chatStrs["faceBTextStr"] = "B表情";
	self.chatStrs["faceMTextStr"] = "M表情";
	self.chatStrs["faceQTextStr"]= "Q表情";
	self.chatStrs["chatInputTxStr"] = "请输入内容"
	self.chatStrs["sysChatText1"] = "速度些撒，都又少打两盘了";
	self.chatStrs["sysChatText2"] = "催啥子，我在想割哪张";
	self.chatStrs["sysChatText3"] = "你们太要不得了，咋只晓得按到我割喃";
	self.chatStrs["sysChatText4"] = "你们耍的安逸哦，我也来参一个";
	self.chatStrs["sysChatText5"] = "输家不开口，赢家不许走哈";
	self.chatStrs["sysChatText6"] = "再打一盘我就走了哈，你们慢慢耍";
	self.chatStrs["sysChatText7"] = "点花我也割了哈，不得再放你娃些了";
	self.chatStrs["sysChatText8"] = "美女，你割啥子，我打给你哇";
    self.chatStrs["sysChatText_normal1"] = "大家好！很高兴见到各位！";
    self.chatStrs["sysChatText_normal2"] = "快点吧,我等到花儿都谢了！";
    self.chatStrs["sysChatText_normal3"] = "不要走！决战到天亮！";
    self.chatStrs["sysChatText_normal4"] = "你是帥哥还是美女？";
    self.chatStrs["sysChatText_normal5"] = "君子报仇,十盘不算晚!";
    self.chatStrs["sysChatText_normal6"] = "快放炮啊,我都等得不耐烦了!";
    self.chatStrs["sysChatText_normal7"] = "真不好意思,又胡啦!哈哈~";
    self.chatStrs["sysChatText_normal8"] = "打错了,呜呜~~";
	self.chatStrs["tfacexuan1Str"] = "表情";
	self.chatStrs["tfacexuan2Str"] = "常用语";
	self.chatStrs["tfacexuan3Str"] = "历史记录";
end





