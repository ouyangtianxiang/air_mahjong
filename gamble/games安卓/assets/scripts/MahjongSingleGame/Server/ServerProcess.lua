--ServerProcess.lua
--服务器向客户端发送命令处理逻辑

--服务器准备开始游戏
SingleGameServer.readyStart = function(self)
  	if self.notFirstGame then
    	self:clearData();
  	end
   	self.isCanleft = false;
   	local param = {};
    param.bankSeatId = 1;
    self:dispatch_consoleServer_msg(SERVER_BROADCAST_READY_START, param);
    self.serverAnimIndex = new(AnimInt, kAnimNormal, -1, -1, 3000, -1);  --延迟2秒开始发牌
    self.serverAnimIndex:setEvent(self, SingleGameServer.startGame);
end

--洗牌
SingleGameServer.generateCard = function(self)
    local count = 0;
    local tempCards = {};
    self.lastcard = {};

    for i = 1, 9 do
        for j = 0, 2 do
            for k = 1, 4 do
                table.insert(tempCards, tonumber("0x"..j..i));
            end
        end    
    end    
 	math.randomseed(os.time());
  	for m = 1,108 do
	    count = math.random(1, #tempCards);
	    self.lastcard[#self.lastcard+1] = table.remove(tempCards, count);
  	end
end

--从服务器剩余牌中 获取一张牌
SingleGameServer.getNextCard = function(self)
    if(self._gameend)then
    	return;
    end
   
    local count = 0;
    for num = 1, 4 do
        if self.players[num].ishu then
            count=count+1;
        end
    end 

    if #self.lastcard == 0 or count == 3 then
    	DebugLog("【单机游戏】游戏结束-流局....");
        self._gameend = true;
        delete(self.serverAnimIndex);
        self.serverAnimIndex = nil;
        self:gameEnd(); --查花猪 大叫
        self:gameOver();
        return;
    end	
    return table.remove(self.lastcard, 1);
end

--得到想要得到的牌
SingleGameServer.getWantCard = function(self, card)   
   	self:removeTableValueByKey(self.lastcard, card, 1);
   	return card;
end

--配牌：0=万，1=筒，2=条
SingleGameServer.dealcard_set = function(self)
    local temp_Card = {};   --天地胡
    temp_Card[1]={0x01,0x01,0x01,0x02,0x02,0x02,0x03,0x03,0x03,0x04,0x04,0x04,0x05};
    temp_Card[2]={0x06,0x06,0x07,0x07,0x07,0x08,0x08,0x08,0x09,0x09,0x09,0x27,0x27};
    temp_Card[3]={0x11,0x11,0x11,0x12,0x12,0x12,0x13,0x13,0x13,0x14,0x14,0x14,0x16};
    temp_Card[4]={0x21,0x21,0x21,0x21,0x22,0x22,0x23,0x23,0x24,0x24,0x25,0x25,0x26};

    for i = 1, 4 do 
        for j = 1, #temp_Card[i] do 
            self.players[i]:dealHandCard(temp_Card[i][j]);
            self:removeTableValueByKey(self.lastcard, temp_Card[i][j], 1);
        end
    end  
    table.insert(self.lastcard,1,0x05);
    table.insert(self.lastcard,2,0x06);
    table.insert(self.lastcard,3,0x16);
    table.insert(self.lastcard,4,0x26);
    table.insert(self.lastcard,5,0x12);
end

-- 服务器发牌
SingleGameServer.dealcard=function(self)

   -- 警示：请不要上传配牌代码!
   -- Test begin
   -- self:dealcard_set();
   -- Test end  
   
   --发牌
    for i = 1, 4 do
   	    for j=1,13 do         
            self.players[i]:dealHandCard(self:getNextCard());
        end
    end

    --设置定缺的牌
    for i = 1, 4 do
        self.players[i]:setDingQueCard();
    end
    self.isCanleft = true;
end

--服务器发送消息到客户端入口
SingleGameServer.dispatch_consoleServer_msg = function( self, eventType, param )
    DebugLog("【单机游戏】本地服务器发送命令CMD:"..string.format("0x%02x",eventType));
    EventDispatcher.getInstance():dispatch( SocketManager.s_serverMsg, param, eventType );
end

--玩家登陆房间成功
SingleGameServer.playerLoginRoom=function(self)
    local userNameTab = {"大叔", "男神", "萌妹纸", "邻家MM"};
    local userIconTab = {"k_robot51.png", "k_robot31.png", "k_robot41.png", "k_robot21.png"};
    local userSexTab = {0, 0, 1, 1};
    local userInfoTab = {true, true, true, true, true};
    --初始化玩家的一些信息
    for i = 1, 4 do
        self.players[i].userid = i;
        self.players[i].seatid = i;
        if i ~= 1 then 
            local userInfoNum = 0;
            while true do
                userInfoNum = math.random(1, 4);
                if userInfoTab[userInfoNum] then
                    userInfoTab[userInfoNum] = false;
                    break;
                end
            end
            self.players[i].isready = true;
	        self.players[i].isRobot = true;
            self.players[i].userMoney = 10000;
            self.players[i].name = userNameTab[userInfoNum];
            self.players[i].headIcon = "Room/singleGame/"..userIconTab[userInfoNum];
            self.players[i].sex = userSexTab[userInfoNum];
        else
            self.players[i].userMoney = g_DiskDataMgr:getAppData('singleMyMoney',10000)
            PlayerManager.getInstance():myself().money = self.players[i].userMoney;
            self.players[i].isRobot = false;
        end
	    self.players[i].stauts = 0;
    end
    
    --登陆成功的一些参数
    local param = {};
    param.tai = self.di;
    param.di = self.di;
    param.totalQuan = 1;
    param.mySeatId = 1;
    param.myMoney = self.players[1].userMoney;
    param.playerCount = 3;
    param.outCardTimeLimit = 10;
    param.operationTime = 10;
    param.playerInfo = {};
    param.headIcons = {};
    for num = 2, 4 do
	    local temp = {};
	    temp.userId = num;
		temp.seatId = num;
		temp.isReady = 1;
		temp.userinfo = "{\"money\":\""..self.players[num].userMoney.."\",\"sex\":\""..self.players[num].sex.."\""..
						",\"level\":\"100\",\"levelName\":\"初级士兵\",\"nickName\":\""..self.players[num].name.."\"}";		           
	    table.insert(param.playerInfo,temp);
        table.insert(param.headIcons,self.players[num].headIcon);
    end 
    param.outcardTimeout = 8;
    param.operationTimeout = 8;

	local params = {};
    params.level = 1;
    params.roomType = 1;
    params.tableid = 1;
    params.changname = "单机游戏";
    params.fan = 0;
    params.diQue = 0;
    params.playType = 0;  --0为普通玩法  1 为血流玩法
    params.isSwapCard = 0; -- 是否是换三张
    params.wanfa = 0;

    self:dispatch_consoleServer_msg(SERVER_COMMAND_LOGIN_SUCCESS,param);
    self:dispatch_consoleServer_msg(SERVER_COMMAND_TELL_LEVEL_AND_NAME,params);
end

-- 开始游戏 发牌
SingleGameServer.startGame = function(self)
    self._gamestart = true;
    delete(self.serverAnimIndex);
    self.serverAnimIndex = nil;
    self:generateCard();  --服务器生成牌
    self:dealcard();  --服务器发牌
  
    local param = {};
    param.bankSeatId = 1;
    param.shaiziNum = 10;
    param.cardCount = 13;
    param.cardList = publ_deepcopy(self.players[1].firstInhand);

    self:dispatch_consoleServer_msg(SERVER_COMMAND_DEAL_CARD,param);
    self.serverAnimIndex = new(AnimInt,kAnimNormal, -1, -1, 4000, -1);
    self.serverAnimIndex:setEvent(self, SingleGameServer.sendCardToPlayer);
end

--得到玩家出牌的座位
SingleGameServer.calculateCurrentOperaSeatId = function(self)
    if self.currentOperaSeatId == nil then
      	self.lastOperaSeatId = 1;
    elseif self.currentOperaSeatId == 1 then  
      	self.lastOperaSeatId = 1;
    elseif self.currentOperaSeatId == 2 then 
      	self.lastOperaSeatId = 2; 
    elseif self.currentOperaSeatId == 3 then 
      	self.lastOperaSeatId = 3; 
    elseif self.currentOperaSeatId == 4 then 
      	self.lastOperaSeatId = 4;
    end 

    if self.currentOperaSeatId == nil then
      	self.currentOperaSeatId = 1;
    else
       self.currentOperaSeatId = self.currentOperaSeatId + 1;
    end

    if self.currentOperaSeatId == 5 then
       self.currentOperaSeatId = 1;
    end

    if self.players[self.currentOperaSeatId].ishu then 
        self:calculateCurrentOperaSeatId();
    end
end

--得到当前操作玩家的座位号
SingleGameServer.getCurrentOperaSeatId = function(self)
	return self.currentOperaSeatId;
end

--得到上个操作玩家的座位号
SingleGameServer.getLastOperaSeatId = function(self)
	return self.lastOperaSeatId;
end

--发牌到玩家
SingleGameServer.sendCardToPlayer = function(self, to_seatId)
    if self._gameend then 
        return;
    end

    delete(self.serverAnimIndex);
    self.serverAnimIndex = nil;

    if to_seatId ~= nil and to_seatId > 0 then
        self.currentOperaSeatId = to_seatId;
    else
        self:calculateCurrentOperaSeatId(); 
    end
    
    local cardvaule = self:getNextCard();
    self.currentCard = cardvaule;
    if cardvaule == nil then
    	return ;
    end 
   
    if self.currentOperaSeatId == 1  then 
    	local param = {}; 
    	local priority = 0;
        param.cout = 1;
        param.lastCard = cardvaule;
        --自己摸牌后需要计算自己可以进行哪些操作 
        param.operateValue,priority = self.players[1]:calculateOperator(cardvaule, true, self.currentOperaSeatId); 
        self:clearOperatorData();
        self.playsCanOperaValue[1].opValue = param.operateValue;        
        param.angang = self.players[1].an_gang;
        param.bugang = self.players[1].bu_gang;
        param.grabFinal = 0;
        param.none = 0;
        param.byfan = 0;
        param.opTime = 10;
        self.players[self.currentOperaSeatId]:plusCard(param.lastCard);
        self:dispatch_consoleServer_msg(SERVER_COMMAND_GRAB_CARD, param);

        if bu_gang(param.operateValue) then
            local bu_gang_card = param.bugang[1];
            self.currentCard =  bu_gang_card; --把当前操作牌置为可以补杠的牌
            for num = 2, 4 do 
               self.playsQiangGangHu[num].userId = num;
                    self.playsQiangGangHu[num].card = bu_gang_card;
                    self.playsQiangGangHu[num].opera = QIANG_GANG_HU;
                     local operatorType_1,priority_1 = self.players[num]:calculateOperator(bu_gang_card, false, self.currentOperaSeatId);
                if hu_qiang(operatorType_1) and not self.players[num].ishu then
					self.qiangganghu = true;                         
                    self.playsQiangGangHu[num].canOpera = true; 
                    self.playsQiangGangHu[num].bakseatid = self.currentOperaSeatId;
				end
            end
        end

        if tonumber(self.players[1].isAI) == 1 then  --托管情况
          	self.playsCanOperaValue[self.currentOperaSeatId].opValue  = param.operateValue ; 
          	self.playsCanOperaValue[self.currentOperaSeatId].priority = priority;
            if param.operateValue > 0 then
	            self:countdownOutCard(self.currentOperaSeatId, cardvaule, false); 
            else
                self.serverAnimIndex = new(AnimInt,kAnimNormal, -1, -1, 1000, -1); 
                self.serverAnimIndex:setEvent(self,SingleGameServer.robotOutCard);
            end 
        end      
    else  
    	self.canTDhu = false; -- 不能够天地胡了
    	local param = {};
    	param.userId = self.currentOperaSeatId;
    	param.cout = 1;
    	param.card = cardvaule;
    	param.grabFinal = 1;
     	self:dispatch_consoleServer_msg(SERVER_BROADCAST_CURRENT_PLAYER, param);

        local operatorType,priority=self.players[self.currentOperaSeatId]:calculateOperator(cardvaule, true, self.currentOperaSeatId);
        self.players[self.currentOperaSeatId]:plusCard(param.card);

        self:clearOperatorData();
        self.playsCanOperaValue[self.currentOperaSeatId].opValue = operatorType; 
        self.playsCanOperaValue[self.currentOperaSeatId].priority = priority;

        if bu_gang(operatorType) then
            local bu_gang_card = self.players[self.currentOperaSeatId].bu_gang[1];
            if bu_gang_card == nil then
                return;
            end    
            for num = 1, 4 do
                if num ~= self.currentOperaSeatId then
                    local operatorType_1,priority_1=self.players[num]:calculateOperator(bu_gang_card, false, self.currentOperaSeatId);
                    if hu_qiang(operatorType_1) and not self.players[num].ishu then
                        self.qiangganghu = true;                         
                        self.playsQiangGangHu[num].canOpera = true; 
                        self.playsQiangGangHu[num].userId = num;
                        self.playsQiangGangHu[num].card = bu_gang_card;
                        self.playsQiangGangHu[num].opera = QIANG_GANG_HU;
                        self.playsQiangGangHu[num].bakseatid = self.currentOperaSeatId;
                    end
                end     
            end 
        end

        if operatorType > 0 then
            self:countdownOutCard(self.currentOperaSeatId, cardvaule, true); 
        else
            self.serverAnimIndex = new(AnimInt,kAnimNormal, -1, -1, 1500, -1);
            self.serverAnimIndex:setEvent(self, SingleGameServer.robotOutCard);
        end 
    end 
end

--清理操作数据
SingleGameServer.clearOperatorData = function(self)
    --初始化操作值数据 
    self.highPriority = 0;
    self.qiangganghu = false; 
    self.playsCanOperaValue = {[1] = {}, [2] = {}, [3] = {}, [4] = {}};  --玩家可以操作的值 
    self.playsQiangGangHu = {[1] = {}, [2] = {}, [3] = {}, [4] = {}};  --处理玩家抢杠胡
end

-- 电脑出牌
SingleGameServer.robotOutCard = function(self)
    delete(self.serverAnimIndex);
    self.serverAnimIndex = nil;
    if self._gameend then 
        return;
    end

    local operateValue = 0; 
    -- self.players[self.currentOperaSeatId]:setDingQueCard();  --每次接到牌都重新定缺一次
    local card = self.players[self.currentOperaSeatId]:AIOutCard(0);
    self:setOperatorByOutCard(card, true);
end

--根据出的一张牌得到操作
SingleGameServer.setOperatorByOutCard = function(self, card, isRobot)
    --初始化操作值数据 
    self:clearOperatorData();
    for num = 1, 4 do 
        if num ~= self.currentOperaSeatId and not self.players[num].ishu then
            local opValue,priority = self.players[num]:calculateOperator(card, false, self.currentOperaSeatId); 
            self.playsCanOperaValue[num].opValue = opValue;
            self.playsCanOperaValue[num].priority = priority;
            if self.highPriority < priority then
                self.highPriority = priority;
            end  
        end 
    end  

    if self.playsCanOperaValue[1].opValue == nil then
        operateValue = 0
    else
        operateValue = self.playsCanOperaValue[1].opValue;
    end
    self:tellPlayerOutCard(self.currentOperaSeatId, card, operateValue, 0); --告诉出了那张牌
    if self.highPriority > 0 then  --出一张牌其他玩家可以有操作
		self:countdownOutCard(self.currentOperaSeatId, card, isRobot);
    else 
        self:sendCardToPlayer();  --发牌到下一个玩家
    end
end

--处理各种操作并且在本地服务器保存数据
SingleGameServer.countdownOutCard = function(self, seatId, cardValue, robot)
    cardValue = self.currentCard;  --屏蔽之前的逻辑，使用自己保存的当前操作牌
    local opValue = 0;
    local priority = 0;
    if not robot and self.players[1].isAI ~= 1 then --自己出牌控制,比如有胡碰操作,选择碰后需要调整操作优先级
        self.highPriority = self.playsCanOperaValue[1].priority;
        for num = 2, 4 do 
            local priority_temp = self.playsCanOperaValue[num].priority;   
            if priority_temp ~= nil and self.playsCanOperaValue[1].priority < priority_temp then 
                self.highPriority = priority_temp;
            end
        end
    end  
    
    for num = 1, 4 do 
        opValue = self.playsCanOperaValue[num].opValue;
        priority = self.playsCanOperaValue[num].priority;
        if priority ~= nil and priority >= self.highPriority and not self.players[num].ishu then
            if not robot and num == 1 then --不是机器人
                local userId, card, opera, bakseatid = self.players[num]:operator(cardValue, opValue, self.currentOperaSeatId);
                self.playsCanOperaValue[num].canOpera = true; 
                self.playsCanOperaValue[num].userId = userId;
                self.playsCanOperaValue[num].card = card;
                self.playsCanOperaValue[num].opera = opera;
                self.playsCanOperaValue[num].bakseatid = bakseatid;
            elseif (num ~= 1 and robot) or self.players[1].isAI == 1 then  --机器人操作 或者自己托管操作
                local userId, card, opera, bakseatid = self.players[num]:operator(cardValue, opValue, self.currentOperaSeatId);
                self.playsCanOperaValue[num].canOpera = true; 
                self.playsCanOperaValue[num].userId = userId;
                self.playsCanOperaValue[num].card = card;
                self.playsCanOperaValue[num].opera = opera;
                self.playsCanOperaValue[num].bakseatid = bakseatid;
            end  
        end
    end 
    -- 如果机器人出牌优先级高 就不等自己可以操作的牌了 等待1.5s出牌
    if self.players[1].isAI == 1 or self.playsCanOperaValue[1].priority == nil or (self.playsCanOperaValue[1].priority < self.highPriority and robot) then 
    	self.serverAnimIndex = new(AnimInt,kAnimNormal, -1, -1, 1500, -1);
    	self.serverAnimIndex:setEvent(self, SingleGameServer.countDownOperator);
    elseif not robot then --自己立即操作 
    	self:countDownOperator(); 
    end 
end

SingleGameServer.countDownOperator = function(self)
    delete(self.serverAnimIndex);
    self.serverAnimIndex = nil;
    local priority = nil;
    local isQianggang = false;
    local isQianggangSeatId = 0;
    local huCount = self:getHuCount();
    for num = 1, 4 do  
        if self.playsCanOperaValue[num].canOpera then
            local userId = self.playsCanOperaValue[num].userId;
            local card = self.playsCanOperaValue[num].card;
            local opera = self.playsCanOperaValue[num].opera;
            local bakseatid = self.playsCanOperaValue[num].bakseatid;
            priority = self.playsCanOperaValue[num].priority;
            DebugLog("priority:"..priority);
            if priority == 4 then --是胡牌 存在一炮多响 在后面处理发牌到那个玩家 
                --告诉告诉玩家胡牌操作
                self:playsOperator(userId, card, opera, bakseatid, isQianggang, isQianggangSeatId);
                self.players[userId].ishu = true;
                self:tellPlayerOperator(userId, card, opera, bakseatid);             
                self.currentOperaSeatId = userId;
            else  
                DebugLog("self.highPriority:"..self.highPriority);
                if self.highPriority ~= 4 then  --有胡牌的不能够操作,主要是对电脑处理电脑有胡牌一定会胡牌的
                    self.currentOperaSeatId = userId;
                    self:tellPlayerOperator(userId, card, opera, bakseatid);
                    if an_gang(opera) or bu_gang(opera) or peng_gang(opera) then     
                        if self.qiangganghu and bu_gang(opera) then --补杠时候存在抢杠胡,需要处理抢杠胡
                            for i = 1, 4 do 
                                if self.playsQiangGangHu[i].canOpera then
                                    local userId_q = self.playsQiangGangHu[i].userId;
                                    local card_q = self.playsQiangGangHu[i].card;
                                    local opera_q = self.playsQiangGangHu[i].opera;
                                    local bakseatid_q = self.playsQiangGangHu[i].bakseatid;
                                    if i == 1 then  --如果自己可以抢杠胡 提示操作
                                        self:playerQiangGangHu(opera_q,card_q,bakseatid_q);
                                    else  -- 机器人直接给胡操作
                                        priority = 4;
                                        self:playsOperator(userId_q, card_q, opera_q, bakseatid_q, true, userId);
                                        self.players[userId_q].ishu = true;        
                                        self:tellPlayerOperator(userId_q, card_q, opera_q, bakseatid_q);             
                                        self.currentOperaSeatId = i;
                                    end  
                                end  
                            end  
                        else
                            self:sendCardToPlayer(userId);
                        end             
                    else  
                        if userId ~= 1 or self.players[1].isAI == 1 then  --机器人和托管的情况
                            self.serverAnimIndex = new(AnimInt, kAnimNormal, -1, -1, 2000, -1);
                            self.serverAnimIndex:setEvent(self, SingleGameServer.robotOutCard);
                        end  
                    end
                end     
            end  
        end   
    end 

    if self.someOneHu then
        self:dispatch_consoleServer_msg(SERVER_BROADCAST_HU_TO_TABLE, self.playerHuTable);
        self.playerHuTable.normalInfo = {};
        -- self:dispatch_consoleServer_msg(SERVER_BROADCAST_HU_TO_TABLE2, self.playerHuTable2);
        -- self.playerHuTable2.normalInfo = {};
    end
  
    if huCount >= 3 then
        self:gameOver();
        return;
    end
    if priority == 4 then --如果是胡牌 胡牌的下家出牌
        self:sendCardToPlayer();
    end
end

--广播出牌
SingleGameServer.tellPlayerOutCard = function(self, userId, card, operateValue, isUserTing)
    if self._gameend then 
        return;
    end
    self.currentCard = card;

    local param = {};
    param.userId = userId;
    param.card = card;
    param.operateValue = operateValue;
    param.isUserTing = isUserTing;
    param.byfan = 0;
    param.opTime = 0;
    if userId ~= self.lastOperaSeatId then -- 处理杠上炮,某个玩家杠牌后出一张牌放炮了
        self.lastOperaType = 0;
    end  
    self.lastOperaSeatId = userId;
    self:dispatch_consoleServer_msg(SERVER_BROADCAST_OUT_CARD, param);
end

--广播操作
SingleGameServer.tellPlayerOperator = function(self, userId, card, operateValue, beBlockServerSeatId)
    delete(self.OperatAnimIndex);
    self.OperatAnimIndex = nil;
    self.canTDhu = false;

    local param = {};
    param.userId = userId;
    param.card = card;
    param.operateValue = operateValue;
    param.beBlockServerSeatId = beBlockServerSeatId;
    
    self.lastOperaType = operateValue;
    self.lastOperaSeatId = userId;
    --主要处理碰杠操作 计算玩家钱数
    self:playsOperator(userId, card, operateValue, beBlockServerSeatId, false);
    DebugLog("【单机】广播操作：".. operateValue .. "  用户：" .. userId .. "牌值：".. card .. "被操作用户："..beBlockServerSeatId);
	self:dispatch_consoleServer_msg(SERVER_BROADCAST_TAKE_OPERATION, param);

    --发送刮风下雨的动画命令(包含金币变化)
    local params = {};
    if peng_gang(operateValue) or bu_gang(operateValue) then  --刮风
        params.gangType = 1;
        params.userId = userId;
        params.userList = {};
        if peng_gang(operateValue) then --碰杠
        	local user = {};
        	user.userId = self.players[beBlockServerSeatId].userid;
        	user.gangMoney = -2 * self.di;
        	table.insert(params.userList, user);
        	params.userMoney = 2 * self.di;
        else  --补杠
        	local count = 0;
        	for num = 1, 4 do          
	            if num ~= userId and not self.players[num].ishu then  --不是自己而且没有胡
	            	local user = {};
		            user.userId = self.players[num].userid;
		            user.gangMoney = -self.di;
		            table.insert(params.userList, user); 
		            count = count + 1;
	            end  
	        end
	        params.userMoney = count * self.di;
        end
        self:dispatch_consoleServer_msg(SERVER_BROADCAST_GFXY_TO_TABLE, params);

    elseif an_gang(operateValue) then  --下雨
        params.gangType = 2;
        params.userMoney = 100;
        params.userId = userId;
        params.userList = {};
        local count = 0;
        	for num = 1, 4 do          
	            if num ~= userId and not self.players[num].ishu then  --不是自己而且没有胡
	            	local user = {};        
		            user.userId = self.players[num].userid;
		            user.gangMoney = -2 * self.di;
		            table.insert(params.userList, user); 
		            count = count + 1;
	            end  
	        end
	        params.userMoney = 2 * count * self.di;
        self:dispatch_consoleServer_msg(SERVER_BROADCAST_GFXY_TO_TABLE, params);
    end
end

--得到胡人数统计
SingleGameServer.getHuCount = function(self)
    local count = 0;
    --统计胡牌人数
    for i = 1, 4 do 
        if self.playsCanOperaValue[i].canOpera and self.playsCanOperaValue[i].priority == 4 then
            count = count + 1;
	    elseif self.playsQiangGangHu[i].canOpera and i ~= 1 then
	        count = count + 1;
	    elseif self.players[i].ishu then
	        count = count + 1;
	    end
    end
   return count;
end

--玩家的各种操作
SingleGameServer.playsOperator = function(self, userId, card, operateValue, beBlockServerSeatId, isQianggang, isQianggangSeatId)
    local huCount = self:getHuCount();

    --处理刮风的情况
    if peng_gang(operateValue) then
       self.players[userId].temp_gfxyMoney[userId] = self.players[userId].temp_gfxyMoney[userId] + 2 * self.di;
       self.players[beBlockServerSeatId].temp_gfxyMoney[userId] = self.players[beBlockServerSeatId].temp_gfxyMoney[userId] - 2 * self.di;
   
    --处理刮风的情况
    elseif bu_gang(operateValue) then
        local count = 0;
        for num = 1, 4 do
            if num ~= userId and not self.players[num].ishu then         
	            self.players[num].temp_gfxyMoney[userId] = self.players[num].temp_gfxyMoney[userId] - self.di;
	            count = count + 1;
                self.players[userId].huMoneyTab[self.players[num].userid] = (self.players[userId].huMoneyTab[self.players[num].userid] or 0) + self.di;
            end  
        end  
        self.players[userId].temp_gfxyMoney[userId]=self.players[userId].temp_gfxyMoney[userId]+count*self.di;
    
    --处理下雨的情况    
    elseif an_gang(operateValue) then
        local count = 0;
        for num = 1, 4 do          
            if num ~= userId and not self.players[num].ishu then         
	            self.players[num].temp_gfxyMoney[userId] = self.players[num].temp_gfxyMoney[userId] - 2 * self.di;            
	            count = count + 1;
                self.players[userId].huMoneyTab[self.players[num].userid] = (self.players[userId].huMoneyTab[self.players[num].userid] or 0) + self.di * 2;
            end  
        end  
	    self.players[userId].temp_gfxyMoney[userId] = self.players[userId].temp_gfxyMoney[userId] + count * self.di * 2;
    
    --处理自摸的情况
    elseif hu_zimo(operateValue) and not self.players[userId].ishu then
        self.players[userId]:getGangNum();
        self.players[userId]:getGenNum();
        self.players[userId].huType = 2;
        if userId == 1 then
    	    self.players[userId].paiType,self.players[userId].fan = self.players[userId]:paiTypeWhenHu(true, card, self.canTDhu, false);
        else
        	self.players[userId].paiType,self.players[userId].fan = self.players[userId]:paiTypeWhenHu(true, card, false, self.canTDhu);
        end
        if self.players[userId].paiType == 3 or self.players[userId].paiType == 4 then  
        	self.players[userId].genCount=self.players[userId].genCount - 1;
        end
        if self.lastOperaSeatId == userId and (peng_gang(self.lastOperaType) or an_gang(self.lastOperaType) or bu_gang(self.lastOperaType)) then --杠上开花 
        	self.players[userId].GSKaiHua = 1;
        end  
        self.players[userId].huCard = card;
        local temp_fan = self.players[userId].fan + self.players[userId].genCount + self.players[userId].GangCount + self.players[userId].GSKaiHua;    
        local winMoney_temp = math.pow(2, temp_fan - 1) * self.di + self.di;
        if self.canTDhu then
            winMoney_temp = 32 * self.di;
            self.players[userId].genCount = 0;
        end 

        local count_no_hu = 0;
        for i = 1, 4 do               
            if not self.players[i].ishu and i ~= userId then     
                count_no_hu = count_no_hu + 1;
                self.players[i].money = self.players[i].money - winMoney_temp;
                table.insert(self.players[userId].fangPaoId2, self.players[i].userid);
                self.players[userId].huMoneyTab[self.players[i].userid] = (self.players[userId].huMoneyTab[self.players[i].userid] or 0) + winMoney_temp;
            end    
        end    
        self.players[userId].huCount = count_no_hu; --自摸胡了几家
        self.players[userId].winMoney = self.players[userId].winMoney + count_no_hu * winMoney_temp;
        self.huOrder[#self.huOrder + 1] = userId;
        if huCount <= 3 then
            self:playerHuPai(userId);
            -- self:playerHuPai2(userId);
            self.someOneHu = true;
        end
    elseif ( hu_qiangGang(operateValue) or hu_qiang(operateValue) )and not self.players[userId].ishu then  --胡
        self.players[userId].huType = 1;
        local px, f = self.players[userId]:paiTypeWhenHu(false, card, false, self.canTDhu);
        self.players[userId]:getGangNum();
        self.players[userId]:getGenNum(); 
        self.players[userId].paiType = px;
        self.players[userId].fan = f;

        if self.players[userId].paiType == 3 or self.players[userId].paiType == 4 then  
        	self.players[userId].genCount = self.players[userId].genCount - 1;
        end

        if not isQianggang and self.lastOperaSeatId ~= userId and (peng_gang(self.lastOperaType) or an_gang(self.lastOperaType) or bu_gang(self.lastOperaType)) then
            self.players[userId].GSPao = 1; 
            local hjzy_temp = 0;
            if peng_gang(self.lastOperaType) then    --刮风
            	hjzy_temp = 2 * self.di;
            elseif bu_gang(self.lastOperaType) then  --刮风
             	local count = 0;
                for num = 1, 4 do          
                  	if num ~= self.lastOperaSeatId and not self.players[num].ishu then                  
                       	count = count + 1;
                    end  
                end  
                hjzy_temp = count * self.di;
            elseif an_gang(self.lastOperaType) then  --下雨
                local count = 0;
                for num = 1, 4 do          
                 	if num ~= self.lastOperaSeatId and not self.players[num].ishu then                  
                      	count = count + 1;
                   	end  
                end  
                hjzy_temp = count * self.di * 2;
            end   
            self.players[userId].hjzyMoney = hjzy_temp;
            self.players[beBlockServerSeatId].GFXYMoney = self.players[beBlockServerSeatId].GFXYMoney - hjzy_temp; --呼叫转移
        end
        self.players[userId].fangPaoId = beBlockServerSeatId;
        self.players[userId].fangPaoId2 = {beBlockServerSeatId};

        if isQianggang then
        	self.players[userId].QiangGangHu = 1;
            self.players[userId].fangPaoId = isQianggangSeatId;
        	self.players[userId].fangPaoId2 = {isQianggangSeatId};
        end     

    	self.players[userId].huCard = card;
        --算番
      	local temp_fan = self.players[userId].fan + self.players[userId].genCount + self.players[userId].GangCount + self.players[userId].GSPao + self.players[userId].QiangGangHu;
      	local winMoney_temp = math.pow(2, temp_fan - 1) * self.di + self.players[userId].hjzyMoney;
        if self.canTDhu then
        	winMoney_temp = 32 * self.di;
        	self.players[userId].genCount = 0;
        end 
        if isQianggang then
        	self.players[isQianggangSeatId].money = self.players[isQianggangSeatId].money - winMoney_temp; 
        else
        	self.players[beBlockServerSeatId].money = self.players[beBlockServerSeatId].money - winMoney_temp + self.players[userId].hjzyMoney; 
        end
        self.players[userId].winMoney = self.players[userId].winMoney + winMoney_temp;
        self.huOrder[#self.huOrder + 1] = userId;
        if huCount <= 3 then
        	self:playerHuPai(userId);
            -- self:playerHuPai2(userId);
            self.someOneHu = true;
        end  
    end
end

--提示玩家可以操作 抢杠胡 处理
SingleGameServer.playerQiangGangHu = function(self, operatorValue, card, seatId)
	local param = {};
    param.type = operatorValue;
    DebugLog("【单机】可以进行抢杠胡，操作值："..operatorValue);
    param.card = card;
    param.seatId = seatId;
    self:dispatch_consoleServer_msg(SERVER_COMMAND_OPEERATION_HINT, param);
end

--牌局结束前胡牌
SingleGameServer.playerHuPai = function(self, hupaiUserId)
    local param = {};
    param.huCount = 1;
    param.userId = hupaiUserId;
    param.huType = self.players[hupaiUserId].huType;
    param.fanNum = self.players[hupaiUserId].fan;
    param.isGangShangPao = self.players[hupaiUserId].GSPao;
    param.isQiangGangHu = self.players[hupaiUserId].QiangGangHu;
    param.isGangShangKaiHua = self.players[hupaiUserId].GSKaiHua;
    param.genNum = self.players[hupaiUserId].genCount;
    param.gangNum = self.players[hupaiUserId].GangCount;
    param.paiType = self.players[hupaiUserId].paiType;
    param.huCard = self.players[hupaiUserId].huCard; 
    param.fangPaoUserID = self.players[hupaiUserId].fangPaoId; 
    param.hjzyMoney = self.players[hupaiUserId].hjzyMoney;
    table.insert(self.playerHuTable.normalInfo, param);
    -- self:dispatch_consoleServer_msg(SERVER_BROADCAST_HU_TO_TABLE,self.playerHuTable);
end


--牌局结束前胡牌(新结算)
SingleGameServer.playerHuPai2 = function(self, hupaiUserId)
DebugLog("tttt playerHuPai2")
    local param = {};
    -- param.huCount = 1;

    param.mid = hupaiUserId;
    param.huType = self.players[hupaiUserId].huType;
    param.huCard = self.players[hupaiUserId].huCard;
    param.beiHuCount = #self.players[hupaiUserId].fangPaoId2;
    param.beHu = {};
    for k, v in pairs(self.players[hupaiUserId].fangPaoId2) do
        local tb = {};
        tb.mid = v;
        tb.loseMoney = self.players[hupaiUserId].huMoneyTab[v];
        table.insert(param.beHu, tb);
    end
    param.paiTypeStr = self.paiTypeTab[self.players[hupaiUserId].paiType];
    param.paiTypeFanShu = self.paiFanTab[self.players[hupaiUserId].paiType];

    param.extraFanStr = {};
    param.extraFanCount = self.players[hupaiUserId].GSPao + self.players[hupaiUserId].QiangGangHu + self.players[hupaiUserId].GSKaiHua;
    if self.players[hupaiUserId].genCount > 0 then
        param.extraFanCount = param.extraFanCount + 1;
        table.insert(param.extraFanStr, self.players[hupaiUserId].genCount.."根");
    end
    if self.players[hupaiUserId].GangCount > 0 then
        param.extraFanCount = param.extraFanCount + 1;
        table.insert(param.extraFanStr, self.players[hupaiUserId].GangCount.."杠");
    end
    if self.players[hupaiUserId].GSPao > 0 then
        table.insert(param.extraFanStr, "杠上炮");
    end
    if self.players[hupaiUserId].QiangGangHu > 0 then
        table.insert(param.extraFanStr, "抢杠胡");
    end
    if self.players[hupaiUserId].GSKaiHua > 0 then
        table.insert(param.extraFanStr, "杠上开花");
    end
    param.totalFanShu = self.players[hupaiUserId].fan;
    param.isQiangGangHu = self.players[hupaiUserId].QiangGangHu;
    param.hjzy = self.players[hupaiUserId].hjzyMoney;
    param.winMoney = self.players[hupaiUserId].turnMoney;
    table.insert(self.playerHuTable2.normalInfo, param);
end

--查花猪
SingleGameServer.chaHuaZhu = function(self)
    for i = 1, 4 do 
        if not self.players[i].ishu then
            self.players[i]:isHuaZhu();
        end 
    end  

    for i = 1, 4 do 
        if not self.players[i].ishu and self.players[i].ishuazhu then
            for j = 1, 4 do
                if not self.players[j].ishu and not self.players[j].ishuazhu then
                    table.insert(self.players[i].huaZhuId, j);
                    self.players[i].money = self.players[i].money - 16 * self.di;
                    self.players[j].money = self.players[j].money + 16 * self.di;
                end
            end
        end 
    end  
end

--查大叫
SingleGameServer.chaDaJiao = function(self)  
    for i = 1, 4 do 
        if not self.players[i].ishu and not self.players[i].ishuazhu then
            self.players[i]:isDaJiao();
        end  
    end  

    for i = 1, 4 do
        if not self.players[i].ishu and not self.players[i].ishuazhu and self.players[i].isdajiao then
           for j = 1, 4 do
                if not self.players[j].ishu and not self.players[j].ishuazhu and not self.players[j].isdajiao then
                    self.players[i].daJiaoId[#self.players[i].daJiaoId + 1] = j;
                    self.players[i].daJiaoFan[#self.players[i].daJiaoFan+1] = self.players[j].dajiaoMaxFan;
                      
                    local money_temp = self.players[j].dajiaoMaxMoney;
                    self.players[i].daJiaoMoney[#self.players[i].daJiaoMoney + 1] = money_temp;
                    self.players[i].money = self.players[i].money - money_temp;
                    self.players[j].money = self.players[j].money + money_temp;
                end  
            end 
        end  
    end  
end

--处理刮风下雨 
SingleGameServer.dealGfxyMoney = function(self)
    for i = 1, 4 do 
        for j = 1, 4 do
            if self.players[j].ishu or not self.players[j].isdajiao then
            	self.players[i].GFXYMoney = self.players[i].GFXYMoney + self.players[i].temp_gfxyMoney[j];
            end   
        end
        self.players[i].GFXYMoney = self.players[i].GFXYMoney + self.players[i].hjzyMoney; -- 加上呼叫转移钱
        self.players[i].winMoney = self.players[i].winMoney - self.players[i].hjzyMoney;   -- 减去呼叫转移的钱
    end
end

--处理输赢money
SingleGameServer.dealWithWinMoney = function(self)
    for i = 1, 4 do 
   		self.players[i].turnMoney = self.players[i].winMoney + self.players[i].GFXYMoney + self.players[i].money;
    end 
end

SingleGameServer.gameEnd = function(self)
	self:chaHuaZhu();  --查花猪
	self:chaDaJiao();  -- 查大叫
end

SingleGameServer.gameOver = function(self)
DebugLog("ttt gameOver");
    self.notFirstGame = true;
    self._gameend = true;
    self:dealGfxyMoney();  --处理刮风下雨
    self:dealWithWinMoney();  --处理输赢money
    local param = {};
    param.result = 0;
    param.activetime = 0;
    param.resuleInfoList = {};
    for m = 1, 4 do  
        if not self.players[m].ishu then             
            self.huOrder[#self.huOrder + 1] = m;
        end  
    end  

    for i = 1, #self.huOrder do 
        num = self.huOrder[i];
        local huinfo = {};
        local currentPlayer = self.players[num];
        huinfo.userId = currentPlayer.userid;

        if currentPlayer.ishu then
           huinfo.isHu = 1;
        else
           huinfo.isHu = 0;
        end 
       
        huinfo.isFangPao = currentPlayer.isFangPao;
        huinfo.huType = currentPlayer.huType;
        huinfo.huCard = currentPlayer.huCard;
        huinfo.fangPaoUserId = currentPlayer.fangPaoId;
        huinfo.isGangshangpao = currentPlayer.GSPao;
        huinfo.isQianggangHu = currentPlayer.QiangGangHu;
        huinfo.ziMoCard = currentPlayer.huCard;
        huinfo.isGangShangKaiHua = currentPlayer.GSKaiHua;
        
        huinfo.paiType = currentPlayer.paiType;
        huinfo.fanNum = currentPlayer.fan;
        huinfo.winMoney = currentPlayer.winMoney;
        huinfo.siZhangNum = currentPlayer.genCount;
        huinfo.gangShangNum = currentPlayer.GangCount;
        
        huinfo.gfxyMoney = currentPlayer.GFXYMoney;

        if currentPlayer.ishuazhu then
            huinfo.isHuaZhu = 1;
        else 
            huinfo.isHuaZhu = 0;
        end 
        huinfo.huaZhuCount = #currentPlayer.huaZhuId;
        huinfo.huZhuUid = currentPlayer.huaZhuId;

        if currentPlayer.isdajiao then
            huinfo.isDaJiao = 1;
        else 
            huinfo.isDaJiao = 0;
        end 
        huinfo.dajiaoCount = #currentPlayer.daJiaoId;
        huinfo.dajiaoUid = currentPlayer.daJiaoId;
        huinfo.dajiaoFanNum = currentPlayer.daJiaoFan;
        huinfo.dajiaoMoneyNum = currentPlayer.daJiaoMoney;

        huinfo.status = 1;
        huinfo.totalMoney = currentPlayer.userMoney + currentPlayer.turnMoney;
        huinfo.turnMoney = currentPlayer.turnMoney;
        self.players[huinfo.userId].userMoney = huinfo.totalMoney;

        huinfo.cardNum = #currentPlayer.firstInhand;
        table.sort(currentPlayer.firstInhand)
        huinfo.cardList = currentPlayer.firstInhand;
        table.insert(param.resuleInfoList, huinfo);
    end  
    param.stopGame = 1;
    self:dispatch_consoleServer_msg(SERVER_BROADCAST_STOP_ROUND, param);
    -- self:gameOver2();  --再调用一次新结算
end

--新结算
SingleGameServer.gameOver2 = function(self)
DebugLog("ttt gameOver2");
    self.notFirstGame = true;
    self._gameend = true;
    self:dealGfxyMoney();  --处理刮风下雨
    self:dealWithWinMoney();  --处理输赢money
    local param = {};
    param.roundResult = 0;
    param.roundTime = 0;
    param.playerCount = 4;
    param.playerList = {};
    param.huazhuList = {};
    param.dajiaoList = {};
    for i = 1, param.playerCount do
        local temp = {};
        local currentPlayer = self.players[i];
        temp.mid = currentPlayer.userid;
        temp.seatId = currentPlayer.seatid;
        temp.blockCount = currentPlayer.chipenggang[2][20] + currentPlayer.chipenggang[3][20]; -- 总的碰杠操作次数
        temp.blockInfo = {};
        for j = 1, currentPlayer.chipenggang[2][20] do
            local pengTab = {};
            pengTab.cardValue = currentPlayer.chipenggang[2][j]; -- 牌值
            pengTab.blockType = 0x008; -- 操作值
            table.insert(temp.blockInfo, pengTab);
        end
        for j = 1, currentPlayer.chipenggang[3][20] do
            local gangTab = {};
            gangTab.cardValue = currentPlayer.chipenggang[3][j]; -- 牌值
            gangTab.blockType = 0x010; -- 操作值
            table.insert(temp.blockInfo, gangTab);
        end
        temp.cardCount = #currentPlayer.firstInhand;
        temp.cards = currentPlayer.firstInhand;

        temp.huCount = 1;  --不是血流成河玩法固定最多胡一次
        temp.huInfo = {};
        temp.huInfo[1] = {};
        temp.huInfo[1].huType = currentPlayer.huType;
        temp.huInfo[1].huCard = currentPlayer.huCard;
        temp.huInfo[1].beiHuCount = #currentPlayer.fangPaoId2;
        for k, v in pairs(currentPlayer.fangPaoId2) do
            temp.huInfo[1].beiHuPlayer = {};
            temp.huInfo[1].beiHuPlayer[k] = {};
            temp.huInfo[1].beiHuPlayer[k].mid = v;
            temp.huInfo[1].beiHuPlayer[k].loseMoney = currentPlayer.huMoneyTab[v];
        end
        temp.huInfo[1].paiTypeStr = self.paiTypeTab[currentPlayer.paiType];
        temp.huInfo[1].paiTypeFan = self.paiFanTab[currentPlayer.paiType];

        temp.huInfo[1].extraTypeStr = {};
        temp.huInfo[1].extraFanCount = currentPlayer.GSPao + currentPlayer.QiangGangHu + currentPlayer.GSKaiHua;
        if currentPlayer.genCount > 0 then
            temp.huInfo[1].extraFanCount = temp.huInfo[1].extraFanCount + 1;
            table.insert(temp.huInfo[1].extraTypeStr, currentPlayer.genCount.."根");
        end
        if currentPlayer.GangCount > 0 then
            temp.huInfo[1].extraFanCount = temp.huInfo[1].extraFanCount + 1;
            table.insert(temp.huInfo[1].extraTypeStr, currentPlayer.GangCount.."杠");
        end
        if currentPlayer.GSPao > 0 then
            table.insert(temp.huInfo[1].extraTypeStr, "杠上炮");
        end
        if currentPlayer.QiangGangHu > 0 then
            table.insert(temp.huInfo[1].extraTypeStr, "抢杠胡");
        end
        if currentPlayer.GSKaiHua > 0 then
            table.insert(temp.huInfo[1].extraTypeStr, "杠上开花");
        end
        temp.huInfo[1].totalFanShu = currentPlayer.fan;
        temp.huInfo[1].winMoney = currentPlayer.winMoney;

        temp.isQiangGangHu = currentPlayer.QiangGangHu;
        temp.gfxyMoney = currentPlayer.GFXYMoney;
        temp.hjzyMoney = currentPlayer.hjzyMoney;
        temp.turnMoney = currentPlayer.turnMoney;
        temp.totalMoney = currentPlayer.userMoney + currentPlayer.turnMoney;
        table.insert(param, temp);
    end 

    local indexTemp = 0;
    for k, v in pairs(self.players) do
        if v.ishuazhu then
            for m, n in pairs(v.huaZhuId) do
                indexTemp = indexTemp + 1;
                local huazhu = {};
                huazhu.isHuazhu = 1;
                huazhu.info = {};
                huazhu.info[indexTemp].mid = n;
                huazhu.info[indexTemp].beiChaMid = v.userid;
                huazhu.info[indexTemp].huazhuMoney = self.di * 16;
                table.insert(t.huazhuList, dajiao);
            end
        end
    end

    local indexTemp = 0;
    for k, v in pairs(self.players) do
        if v.isDaJiao then
            for m, n in pairs(v.daJiaoId) do
                indexTemp = indexTemp + 1;
                local dajiao = {};
                dajiao.isHuazhu = 1;
                dajiao.info = {};
                dajiao.info[i] = {};
                dajiao.info[i].mid = n;
                dajiao.info[i].beiChaMid = v.userid;
                dajiao.info[i].dajiaoFan = v.daJiaoFan;
                dajiao.info[i].dajiaoMoney = v.daJiaoMoney;
                table.insert(t.dajiaoList, dajiao);
            end
        end
    end
    param.stopGame = 1;
    self:dispatch_consoleServer_msg(SERVER_BROADCAST_STOP_ROUND2, param);
end


SingleGameServer.paiTypeTab = {
    [GameConstant.TIAN_HU_SC] = "天胡",
    [GameConstant.DI_HU_SC] = "地胡",
    [GameConstant.QING_LONG_QI_DUI_SC] = "清龙七对",
    [GameConstant.LONG_QI_DUI_SC] = "龙七对",
    [GameConstant.QING_QI_DUI_SC] = "清七对",
    [GameConstant.QING_YAO_JIU_SC] = "清幺九",
    [GameConstant.QING_DUI_SC] = "清对",
    [GameConstant.JIANG_DUI_SC] = "将对",
    [GameConstant.QING_YI_SE_SC] = "清一色",
    [GameConstant.DAI_YAO_JIU_SC] = "带幺九",
    [GameConstant.QI_DUI_SC] = "七对",
    [GameConstant.DUI_DUI_HU_SC] = "对对胡",
    [GameConstant.PING_HU_SC] = "平胡"
}

SingleGameServer.paiFanTab = {
    [GameConstant.TIAN_HU_SC] = 6,
    [GameConstant.DI_HU_SC] = 6,
    [GameConstant.QING_LONG_QI_DUI_SC] = 6,
    [GameConstant.LONG_QI_DUI_SC] = 5,
    [GameConstant.QING_QI_DUI_SC] = 5,
    [GameConstant.QING_YAO_JIU_SC] = 5,
    [GameConstant.QING_DUI_SC] = 4,
    [GameConstant.JIANG_DUI_SC] = 4,
    [GameConstant.QING_YI_SE_SC] = 3,
    [GameConstant.DAI_YAO_JIU_SC] = 3,
    [GameConstant.QI_DUI_SC] = 3,
    [GameConstant.DUI_DUI_HU_SC] = 2,
    [GameConstant.PING_HU_SC] = 1
}


