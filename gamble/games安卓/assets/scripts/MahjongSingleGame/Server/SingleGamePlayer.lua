require("MahjongConstant/OperatType");
require("MahjongSingleGame/Server/SingleGameAI");
SingleGamePlayer = class(State);

SingleGamePlayer.ctor = function(self, consoleServer, serverSeatId)
    self.consoleServer = consoleServer; 
    self.singleGameAI = new(SingleGameAI);

    --二维数组[i][j] i:代表类型(1万 2筒 3条)
    --j:代表值1到9整个数组的值牌得张数,10保存牌的张数
    self.handcard = {{},{},{}};  
    for i = 1, #self.handcard do
      for j = 1, 10 do
          self.handcard[i][j] = 0;
      end
    end
    
    --是一个二维数组[i][j] i:代表操作类型(1吃 2碰 3杠)
    --j:操作顺序整个数组的值为牌的值,20:保存操作数
    self.chipenggang={{},{},{},{}}; 
    for i = 1, #self.chipenggang do
        for j = 1, 20 do
      	    self.chipenggang[i][j] = 0;
        end
    end

    self.firstInhand = {}; --第一次发完牌手上的牌
    self.userid = serverSeatId; 
    self.seatid = serverSeatId;
    self.userMoney = 0;
    self.name = "";
    self.headIcon = "";
    self.sex = 2;

    self.an_gang = {};  --每次摸牌暗杠的牌
    self.bu_gang = {};  --每次摸牌补杠的牌
    self.canHuCards = {};  --可以胡牌的列表
    self.Priority = nil;  --优先级,用来表示每个玩家对某一张牌的操作的最大优先级,1是吃、2是碰、3是杠,456都是胡(数字越大优先级越高)
    self.isready = nil;  --准备
    self.isAI = nil ;  --是否托管
    self.isTing = nil;  --是否听牌
    self.dingQueType = 1;  --定缺类型(默认定缺万)
    self.isRobot = nil;  --玩家是否是机器人
        
    self.stauts = nil; --玩家的状态，0初始状态 1抓牌有操作非AI 2别人打牌自己有操作非AI 3抓牌无操作非AI
    self.DingQueHuaSe = nil;
    
    self.operation = nil;
    self.canOperation = nil;
    self.huType = nil;
    self.isOnline = nil;
    self.fan = 0;  --番
    self.GSPao = 0;  --杠上炮
    self.QiangGangHu = 0;  --抢杠胡
    self.GSKaiHua = 0;  --杠上开花
    self.genCount = 0;  --根数
    self.GangCount = 0;  --杠数
    self.gfxyTimes = nil;  --刮风下雨次数
    self.gfxyId = {};
    
    self.paiType = nil;
    self.huCard = nil ;
    self.money = 0;
    self.turnMoney = 0;  --输赢的钱数
    self.ishu = nil;
    self.isFangPao = nil;
    self.ishuazhu = nil;
    self.isdajiao = nil;
    self.fangPaoId = {};
    self.fangPaoId2 = {};  --新结算
    self.huMoneyTab = {};
    self.huCount = 0;
    self.huaZhuId = {};
    self.daJiaoId = {};
    self.daJiaoFan = {};
    self.dajiaoMaxFan = 0;
    self.dajiaoMaxMoney = 0;
    self.dajiaoMaxCardType = 0;
    self.daJiaoMoney = {};  --一个玩家对其他玩家的大叫番数和钱数是一样的，不需要开数组
    self.winMoney = 0;
    self.GFXYMoney = 0;
    self.hjzyMoney = 0;
    self.temp_gfxyMoney = { 0, 0, 0, 0 };
    DebugLog("【单机游戏】服务器玩家"..serverSeatId.."信息初始化完毕...");
end

--第一次发牌到手牌
SingleGamePlayer.dealHandCard = function( self, card )
    self.firstInhand[#self.firstInhand + 1] = card;
    local cardValue = bit.band(card, 0x0F);  --值
    local cardType = bit.brshift(card, 4) + 1;  --花色
    self.handcard[cardType][10] = self.handcard[cardType][10] + 1;  --该类型张数加一
    self.handcard[cardType][cardValue] = self.handcard[cardType][cardValue] + 1;  --数组中该张牌位置数量加一
end

--设置定缺的牌
SingleGamePlayer.setDingQueCard = function( self )
    self.dingQueType = self.singleGameAI:getDingQue(self.handcard, self.chipenggang);
end

--摸一张牌
SingleGamePlayer.plusCard = function( self, card ) 
    local cardValue = bit.band(card, 0x0F);  --值
    local cardType = bit.brshift(card, 4) + 1;  --花色
    self.handcard[cardType][10] = self.handcard[cardType][10] + 1;
    self.handcard[cardType][cardValue] = self.handcard[cardType][cardValue]+1; 
    self.firstInhand[#self.firstInhand+1] = card;
end

--减一张牌
SingleGamePlayer.minusCard = function( self, card ) 
    local cardValue = bit.band(card, 0x0F);  --值
    local cardType = bit.brshift(card, 4) + 1;  --花色
    self.handcard[cardType][10] = self.handcard[cardType][10]-1;
    self.handcard[cardType][cardValue] = self.handcard[cardType][cardValue]-1; 
    self.consoleServer:removeTableValueByKey(self.firstInhand,card,1);
end

--AI进行出牌决定
SingleGamePlayer.AIOutCard = function( self, notOutCard )
    local outcard = nil; 
    outcard = self.singleGameAI:recommandOutCard(self.handcard, self.dingQueType, notOutCard);  --计算应该出哪张牌
    self:minusCard(outcard);
    return outcard;
end

--计算玩家可以有什么操作 存在两种情况 一自己摸一张牌后 二是其他玩家出了一张牌后
SingleGamePlayer.calculateOperator = function(self, card, iscatch, playerSeatid)
    self.an_gang = {};
    self.bu_gang = {};
      
    if (self.consoleServer.currentOperaSeatId ~= self.seatid) and (playerSeatid == self.seatid) then 
        return 0;
    end 
    self:plusCard(card);  --把牌加入到手牌中
    self.Priority = 0;
    self.canOperation = 0;

    if iscatch then
        if self:isCanZimoOrHu() then
            self.canOperation = bit.bor(self.canOperation, ZI_MO);
            self.Priority = math.max(4, self.Priority);
        end
		if self:isCanAn_Gang() then
            self.canOperation = bit.bor(self.canOperation, AN_KONG);
            self.Priority = math.max(3, self.Priority);
        end
		if self:isCanBu_Gang() then
        	self.canOperation = bit.bor(self.canOperation, BU_KONG);
        	self.Priority = math.max(3, self.Priority);
        end
    else    
        if self:isCanZimoOrHu() then
            self.canOperation = bit.bor(self.canOperation, QIANG);
            self.Priority = math.max(4, self.Priority);
        end
        if self:isCanPeng_gang(card) then
            self.canOperation = bit.bor(self.canOperation, PUNG_KONG);
            self.Priority = math.max(3, self.Priority);
        end
        if self:isCanPung(card) then
            self.canOperation = bit.bor(self.canOperation, PUNG);
            self.Priority = math.max(2, self.Priority);
        end
    end

    self:minusCard(card);  --移除一张牌
    return self.canOperation, self.Priority;
end

--判断自己能自摸或者胡牌(需要缺一门)
SingleGamePlayer.isCanZimoOrHu = function(self)
    local cardTypes = {false, false, false}; --牌类型
	for i = 1, 3 do 
	    for j = 1, self.chipenggang[i][20] do  
	        if self.chipenggang[i][j] > 0 then
	            local index = bit.brshift(self.chipenggang[i][j], 4) + 1
	            cardTypes[index] = true;
	        end                 
	    end 
	end  
   
	for i = 1, #self.handcard do 
	    if self.handcard[i][10] > 0 then 
	        cardTypes[i] = true;
	    end     
	end  

	if cardTypes[1] and cardTypes[2] and cardTypes[3] then
		return false;
	end

	if self:isQiDui() then
	    return true;  --判断是否7对
	end
   
    local tempInhand = publ_deepcopy(self.handcard);
  	local hu = self:playerCanHu(tempInhand, 1);
  	return hu;
end

--是否加一张牌的情况下可以胡牌(听牌)
SingleGamePlayer.isTingAddOneCard = function(self, cardvalue)
    local hu = false;
    self:plusCard(cardvalue);

	if self:isQiDui() then
        hu = true;  --判断是否7对
    end

    local tempInhand = publ_deepcopy(self.handcard);
    local hu = self:playerCanHu(tempInhand, 1);
    self:minusCard(cardvalue);
    return hu;
end

--判断是否是胡七对番型
SingleGamePlayer.isQiDui=function(self)
    local num = 0;  --对子的数量
    for i = 1, #self.handcard do
        if self.handcard[i][10] % 2 ~= 0 then     
        	return false;
        end  
        for j = 1, 9 do
            num = num + getIntPart(self.handcard[i][j] / 2);
        end   
    end
	return (7 == num);  --如果有七个对子则可以胡七对番型
end

--判断是否可以胡牌
SingleGamePlayer.playerCanHu = function(self, inhand, dui)
    if (inhand[1][10] + inhand[2][10] + inhand[3][10]) == 0 then
        return true;
    end
    local ans = false;
    for i = 1, #inhand do 
        for j = 1, 9 do 
            if inhand[i][j] >= 3 then --是否是刻
                inhand[i][j] = inhand[i][j] - 3;
                inhand[i][10] = inhand[i][10] - 3;
				if self:playerCanHu(inhand, dui) then
                    ans = true;
                end
                inhand[i][j] = inhand[i][j] +3;
                inhand[i][10] = inhand[i][10] +3;
			end 

            if inhand[i][j] >= 2 and dui == 1 then
                inhand[i][j] = inhand[i][j] - 2;
                inhand[i][10] = inhand[i][10] - 2;
                if self:playerCanHu(inhand,dui + 1) then 
                    ans = true;
                end   
                inhand[i][j] = inhand[i][j] +2;
                inhand[i][10] = inhand[i][10] +2;
            end

            if j <= 7 and inhand[i][j] > 0 and inhand[i][j+1] > 0 and inhand[i][j+2] > 0 then
                inhand[i][10] = inhand[i][10] - 3;
                inhand[i][j] = inhand[i][j] - 1;
                inhand[i][j+1] = inhand[i][j+1] -1;
                inhand[i][j+2] = inhand[i][j+2] -1;
                if self:playerCanHu(inhand ,dui) then 
                    ans = true;
                end  
                inhand[i][j] = inhand[i][j] +1;
                inhand[i][j+1] = inhand[i][j+1] + 1;
                inhand[i][j+2] = inhand[i][j+2] + 1;
                inhand[i][10] = inhand[i][10] +3;
            end
        end  
    end
    return ans;
end

--判断是否可以暗杠
SingleGamePlayer.isCanAn_Gang = function(self)
    local flag=false;
    for i = 1, #self.handcard do 
        if(self.handcard[i][10] >= 4)then
            for j=1,9 do 
                if(self.handcard[i][j] == 4)then
                    if(self.seatid == 1) then
                        flag=true;
                        self.an_gang[#self.an_gang+1]=bit.blshift(i-1,4)+j;
                    elseif(i ~= self.dingQueType)then
                        flag=true;
                        self.an_gang[#self.an_gang+1]=bit.blshift(i-1,4)+j;
                    end
                end   
            end   
        end  
    end 
    return flag;
end

--判断是否可以补杠
SingleGamePlayer.isCanBu_Gang = function(self)
    local  flag = false;
    for i = 1,self.chipenggang[2][20] do
        if self.chipenggang[2][i] > 0 then
            local index = bit.brshift(self.chipenggang[2][i],4)+1;
            local data = bit.band(self.chipenggang[2][i],0x0f);
            if self.handcard[index][data] == 1 then
                flag = true;
                self.bu_gang[#self.bu_gang+1] = self.chipenggang[2][i];
            end
        end
    end
    return flag;
end

-- 判断是否可以碰杠
SingleGamePlayer.isCanPeng_gang = function(self, card)
    local flag = false;
    local  index = bit.brshift(card,4)+1;
    local  data = bit.band(card,0x0f);
    if self.handcard[index][data] >= 4 then
	    if self.seatid == 1 then
	        flag = true;
	    elseif index ~= self.dingQueType then
	        flag = true; 
	    end
    end  
  return flag;
end

--判断是否可以碰
SingleGamePlayer.isCanPung = function(self, card)
    local flag = false;
    local index = bit.brshift(card,4) + 1;
    local data = bit.band(card, 0x0f);
    if self.handcard[index][data] >= 3 then
	    if self.seatid == 1 then
	        flag = true;
	    elseif index ~= self.dingQueType then
	        flag = true; 
	    end
    end
    return flag;
end

-- 玩家可以进行什么操作
SingleGamePlayer.operator = function(self, card, operatorType, bakseatid)
    local operaValue = operatorType;
    local cardVaule = card;
    
    if hu_zimo(operatorType) then
        operaValue = ZI_MO;
        return self.userid, card, ZI_MO, bakseatid; 
    elseif hu_qiang(operatorType) then
        operaValue = QIANG;
        return self.userid, card, QIANG, bakseatid; 
    elseif hu_qiangGang(operatorType) then
        operaValue = QIANG_GANG_HU;   
        return self.userid, card, QIANG_GANG_HU, bakseatid; 
    end   

    local opera_type = 1;

    if peng_gang(operatorType) then
        operaValue = PUNG_KONG;   
        opera_type = 3;
        self:gang(card,operatorType);
    elseif an_gang(operatorType) then
        operaValue = AN_KONG; 
        opera_type = 3;
        cardVaule = self.an_gang[1];
        self:gang(cardVaule,operatorType);
    elseif bu_gang(operatorType) then
        operaValue = BU_KONG;
        opera_type = 3;
        self:gang(card,operatorType);
    elseif peng(operatorType) then
        operaValue = PUNG;
        self:peng(card);
        opera_type = 2;
    end 

    self.chipenggang[opera_type][20] = self.chipenggang[opera_type][20] + 1;
    self.chipenggang[opera_type][self.chipenggang[opera_type][20]] = cardVaule;
    return self.userid, cardVaule, operaValue, bakseatid;
end

-- 杠操作
SingleGamePlayer.gang = function(self, card, operatorValue)
    if peng_gang(operatorValue) then
    	for num = 1, 3 do 
        	self:minusCard(card);
    	end 
    elseif an_gang(operatorValue) then
	    for num = 1, 4 do 
	    	self:minusCard(card);
	    end 
    elseif bu_gang(operatorValue) then
    	self:minusCard(card);
    end
end

--碰操作
SingleGamePlayer.peng = function(self, card)
    for num = 1, 2 do 
        self:minusCard(card);
    end 
end

--查花猪 
SingleGamePlayer.isHuaZhu = function(self)
    local iscardtype = {};
    for i = 1, #self.handcard do 
        for j = 1, self.chipenggang[i][20] do             
            local index = bit.brshift(self.chipenggang[i][j], 4) + 1;
            iscardtype[index] = true;
        end 
    end 

    for i = 1, #self.handcard do  
        if self.handcard[i][10] > 0 then
            iscardtype[i] = true;         
        end
    end

    if iscardtype[1] and iscardtype[2] and iscardtype[3] then
        self.ishuazhu = true;
    end  
end

--查大叫 
SingleGamePlayer.isDaJiao = function(self)
    local tempCardType = 0;  
    local tempFan = 0;
    local tempDajiao = true;

	if(self.ishuazhu) then 
        self.isdajiao=false;        
    end 

    for i = 1, 3 do
        if i ~= self.dingQueType or self.seatid == 1 then        
   			for j = 1, 9 do 
                local card = bit.blshift(i - 1, 4) + j;
                if self:isTingAddOneCard(card) then --加一张牌可以胡牌说明不可以大叫的
					tempDajiao = false; 
                    tempCardType,tempFan = self:paiTypeWhenHu(false, card, false, false);
                    self:minusCard(card);
                    self:getGangNum();
                    self:getGenNum();
                    tempFan = tempFan + self.genCount + self.GangCount;
                    if(self.dajiaoMaxFan < tempFan)then
                        self.dajiaoMaxFan = tempFan;
                        self.dajiaoMaxMoney = math.pow(2, tempFan - 1) * self.consoleServer.di;
                    end
                end
            end 
        end   
    end 
    self.isdajiao = tempDajiao;
end

--计算胡牌牌型 返回胡牌类型 对应番数
SingleGamePlayer.paiTypeWhenHu = function(self, isCatch, card, isTianHu, isDiHu)
    if not isCatch then
    	self:plusCard(card);
    end 

    if isTianHu then
    	return 1, 6;  --天胡
    elseif isDiHu then
    	return 2, 6;  --地胡
    elseif self:isQingLongQiDui() then
    	return 3, 6;  --清龙七对
    elseif self:isLongQiDui() then
    	return 4, 5;  --龙七对
    elseif self:isQingQiDui() then
    	return 5, 5;  --清七对
    elseif self:isQingYaojiu() then
        return 6, 5;  --清幺九
    elseif self:isQingDui() then
        return 7, 4;  --清对
    elseif self:isJiangDui() then
        return 8, 4;  --将对
    elseif self:isQingYiSe() then
        return 9, 3;  --清一色
    elseif self:isDaiYaoJiu() then
        return 10, 3;  --带幺九
    elseif self:isQiDui() then
        return 11, 3;  --七对
    elseif self:isDuiDuiHu() then
        return 12, 2;  --对对胡
    else
        return 13, 1;  --平胡
    end
    return 0, 0;
end

--计算是否是清龙七对
SingleGamePlayer.isQingLongQiDui = function(self)  
    local flag = false;
    if self:isQingQiDui() and self:isLongQiDui() then        
        flag = true;
    end
    return flag;
end

--计算是否是龙七对
SingleGamePlayer.isLongQiDui = function(self)
    local flag = false
    if self:isQiDui() and self:hasAGangInHand() then        
        flag = true;
    end
    return flag;
end

--计算是否是清七对
SingleGamePlayer.isQingQiDui = function(self)
    local flag = false
    if self:isQiDui() and self:isQingYiSe() then        
        flag = true;
    end
    return flag;
end

--计算是否是清幺九
SingleGamePlayer.isQingYaojiu = function(self)
    local flag = false
    if self:isDaiYaoJiu() and self:isQingYiSe() then
        flag = true;
    end
    return flag;
end

--计算是否是清对
SingleGamePlayer.isQingDui = function(self)
    local  flag = false;
    if self:isQingYiSe() and self:hasNoShunZi() then       
        flag = true;
    end
    return flag;
end

--计算是否是将对
SingleGamePlayer.isJiangDui = function(self)
    local  flag = false;
    if self:onlyHasJiang() and self:hasNoShunZi() then       
        flag = true;
    end
    return flag;
end

--计算是否是清一色
SingleGamePlayer.isQingYiSe=function(self) 
    local cardHuaSe = {};

    for i = 1, 4 do
        for j = 1, self.chipenggang[i][20] do  
            cardHuaSe[bit.brshift(self.chipenggang[i][j],4) + 1] = true;
        end
    end  
    for i = 1, #self.handcard do        
        if(self.handcard[i][10] > 0)then
            cardHuaSe[i] = true;
        end 
    end 

    local count = 0;

    for m = 1, 3 do 
        if cardHuaSe[m] then
        	count = count + 1;
        end 
    end
    return (count == 1);
end

--计算是否是带幺九
SingleGamePlayer.isDaiYaoJiu=function(self)  
    for i = 1, 3 do 
        if i == 1 then
            for j = 1, self.chipenggang[i][20],3 do 
                local data = bit.band(self.chipenggang[i][i], 0x0f);
                if data ~= 1 and data ~= 7 then                                       
                    return false;
                end 
            end             
		else
            for j = 1, self.chipenggang[i][20] do            
                local data = bit.band(self.chipenggang[i][i], 0x0f);    
                if data ~= 1 and data ~= 9 then
                    return false;
                end 
            end 
        end 
    end 

    local tempInhand = publ_deepcopy(self.handcard);    
    for i = 1, #tempInhand do
        local minYaoJiu = math.min(tempInhand[i][1], tempInhand[i][2], tempInhand[i][3]);
        tempInhand[i][1] = tempInhand[i][1] - minYaoJiu;
        tempInhand[i][2] = tempInhand[i][2] - minYaoJiu;
        tempInhand[i][3] = tempInhand[i][3] - minYaoJiu;
        minYaoJiu = math.min(tempInhand[i][7], tempInhand[i][8], tempInhand[i][9]);
        tempInhand[i][7] = tempInhand[i][7] - minYaoJiu;
        tempInhand[i][8] = tempInhand[i][8] - minYaoJiu;
        tempInhand[i][9] = tempInhand[i][9] - minYaoJiu;
    end    
   
    local twoForYaoJiu = 0;

    for i = 1, 3 do 
   		for j = 2, 8 do 
            if tempInhand[i][j] > 0 then
               return false;
            end
        end 
        if tempInhand[i][1] == 4 or tempInhand[i][1] == 1 then
            return false;
        elseif tempInhand[i][1] == 2 then   
            twoForYaoJiu = twoForYaoJiu + 1;
        end

        if tempInhand[i][9] == 4 or tempInhand[i][9] == 1 then 
            return false;
        elseif tempInhand[i][9] == 2 then   
            twoForYaoJiu = twoForYaoJiu + 1;   
        end
    end

    return (twoForYaoJiu == 1);
end

--计算是否是对对胡
SingleGamePlayer.isDuiDuiHu = function(self)  
    local shunNum = 0;
    for i = 1, #self.handcard do            
        for j = 1, 7 do 
            if self.handcard[i][j] > 0 and self.handcard[i][j+1] > 0 and self.handcard[i][j+2] > 0 then
                if self.handcard[i][j] < 3 and self.handcard[i][j+1] < 3 and self.handcard[i][j+2] < 3 then
                    shunNum = shunNum + 1;
                end
            end
        end 
    end

    return shunNum == 0;
end

SingleGamePlayer.onlyHasJiang = function(self)  
    for i = 1, 3 do 
        for j = 1, self.chipenggang[i][20] do 
            if bit.band(self.chipenggang[i][j],0x0f) ~= 2 and bit.band(self.chipenggang[i][j],0x0f) ~= 5 and bit.band(self.chipenggang[i][j],0x0f) ~= 8 then
	            return false; 
            end 
        end  
    end 

    for i = 1, #self.handcard do 
        for j = 1, 9 do  
            if self.handcard[i][j] > 0 and j ~= 2 and j ~= 5 and j ~= 8 then
                return false;
            end
        end 
    end 
    return true;
end

SingleGamePlayer.hasNoShunZi = function(self) 
    if self.chipenggang[1][20] > 0 then
      return false;
    end
      
    local xiaoDui = 0;
    for i = 1, #self.handcard do            
        for j = 1, 9 do 
			if self.handcard[i][j] == 2 then
                xiaoDui = xiaoDui + 1;
            elseif(self.handcard[i][j] == 3 or self.handcard[i][j] == 0) then
                
            else
                return false;
            end
        end 
    end
    return (xiaoDui == 1);
end

SingleGamePlayer.hasAGangInHand = function(self)
    for i = 1, #self.handcard do 
        if self.handcard[i][10] > 3 then
        	for j = 1, 9 do 
            	if 4 == self.handcard[i][j] then
              		return true;
				end  
            end 
        end     
    end   
    return false;
end

--获得杠的数量
SingleGamePlayer.getGangNum = function(self)
	self.GangCount = self.chipenggang[3][20];
end

--获得根的数量
SingleGamePlayer.getGenNum = function(self)
    for i = 1, #self.handcard do 
        for j = 1, 9 do 
            if self.handcard[i][j] == 4 then
            	self.genCount = self.genCount + 1;
            end 
        end 
    end  
end

SingleGamePlayer.dtor=function(self)   
    self.handcard = {{},{},{}};  
    for i = 1, #self.handcard do
      for j = 1, 10 do
          self.handcard[i][j] = 0;
      end
    end
    
    self.chipenggang={{},{},{},{}}; 
    for i = 1, #self.chipenggang do
        for j = 1, 20 do
      	    self.chipenggang[i][j] = 0;
        end
    end

    self.firstInhand = {}; 
    self.an_gang = {};  
    self.bu_gang = {};  
    self.canHuCards = {};
    self.Priority = nil;    
    self.isready = nil;
    self.isAI = nil;
    self.isTing = nil;
    self.isRobot = nil;  
    self.stauts = nil;
    self.DingQueHuaSe = nil;

    self.operation = nil;
    self.canOperation = nil;
    self.huType = nil;
    self.isOnline = nil;
    self.fan = 0;
    self.GSPao = 0;
    self.QiangGangHu = 0;
    self.GSKaiHua = 0;
    self.genCount = 0;
    self.GangCount = 0;
      
    self.gfxyTimes = nil;
    self.gfxyId = {};
    
    self.paiType = nil;
    self.huCard = nil ;
    self.money = 0;
    self.turnMoney = 0;
    self.ishu = nil;
    self.isFangPao = nil;
    self.ishuazhu = nil;
    self.isdajiao = nil;
    self.fangPaoId = {};
    self.huMoneyTab = {};
    self.huCount = 0;
    self.huaZhuId = {};
    self.daJiaoId = {};
    self.daJiaoFan = {};
    self.dajiaoMaxFan = 0;
    self.dajiaoMaxMoney = 0;
    self.dajiaoMaxCardType = 0;
    self.daJiaoMoney = {};
    self.winMoney = 0;
    self.GFXYMoney = 0;
    self.hjzyMoney = 0;
    self.temp_gfxyMoney = {0, 0, 0, 0};
end

