-- SingleGameAI.lua
-- Author: YifanHe
-- Date: 2013-12-04
-- Last modification : 2013-12-25
-- Description: 单机游戏机器人出牌人工智能

SingleGameAI = class(RoomState);

GANG_CARDNUM  = 4;
ANKE_CARDNUM  = 3;
SHUN_CARDNUM  = 3;
JIANG_CARDNUM = 2;

SingleGameAI.ctor = function(self)

end

SingleGameAI.dtor=function(self)

end

--应该出那张牌
--参数: 
--  handCard    [table]    手牌列表二维数组[i][j] 
--                         i:代表类型(1万 2筒 3条) 
--                         j:代表值1到9整个数组的值牌得张数,10保存牌的张数
--  notOutCard  [number]   不要出某个值的牌
SingleGameAI.recommandOutCard = function( self, handCard, dingQue, notOutCard )
    local handCardCopy = publ_deepcopy(handCard);
    local recommandOut = 0;  --推荐出的牌
    local outCardPrepare = 0;  --预备推荐出的牌
    local duiNum = 0;  --对子数量

    --如果有定缺先打定缺的牌
    if handCardCopy[dingQue][10] > 0 then 
        for i = 1, 9 do  
            if handCardCopy[dingQue][i] > 0 then
                recommandOut = bit.blshift(dingQue - 1, 4) + i;
                return recommandOut;
            end
        end  
    end

    --定缺牌都打完的情况
    if notOutCard and notOutCard ~= 0 then  --除去不出的某张牌
       local cardValue = bit.band(notOutCard, 0x0F);  --值
       local cardType  = bit.brshift(notOutCard, 4) + 1;  --花色
       handCardCopy[cardType][10] = handCardCopy[cardType][10] - handCardCopy[cardType][cardValue];
       handCardCopy[cardType][cardValue] = 0;
    end

    --先考虑是否有杠
    for cardType = 1, #handCardCopy do
        if self:remainInHand(handCardCopy) >= GANG_CARDNUM then   
            for value = 1, 9 do 
                if GANG_CARDNUM == handCardCopy[cardType][value] then
                    handCardCopy[cardType][10] = handCardCopy[cardType][10] - GANG_CARDNUM;
                    handCardCopy[cardType][value] = handCardCopy[cardType][value] - GANG_CARDNUM;
                    recommandOut = bit.blshift(cardType - 1, 4) + value;
                end
            end 
        end
    end  

    --保留暗刻
    for cardType = 1, #handCardCopy do
         if self:remainInHand(handCardCopy) >= ANKE_CARDNUM then 
            for value = 1, 9 do 
                if ANKE_CARDNUM == handCardCopy[cardType][value] then
                    handCardCopy[cardType][10] = handCardCopy[cardType][10] - ANKE_CARDNUM;
                    handCardCopy[cardType][value] = handCardCopy[cardType][value] - ANKE_CARDNUM;
                    recommandOut = bit.blshift(cardType - 1, 4) + value;
                end
            end 
        end
    end  

    --保留将牌对子
    for cardType = 1, #handCardCopy do
        if self:remainInHand(handCardCopy) >= JIANG_CARDNUM then 
            local duiNum = 0;
            for value = 1, 9 do 
                if JIANG_CARDNUM == handCardCopy[cardType][value] then
                    handCardCopy[cardType][10] = handCardCopy[cardType][10] - JIANG_CARDNUM;
                    handCardCopy[cardType][value] = handCardCopy[cardType][value] - JIANG_CARDNUM;
                    recommandOut = bit.blshift(cardType - 1, 4) + value;
                    outCardPrepare = recommandOut;
                    duiNum = duiNum + 1;
                end
            end 
        end
    end 

    --保留顺子牌
    for cardType = 1, #handCardCopy do
        if self:remainInHand(handCardCopy) >= SHUN_CARDNUM then 
            for value=1,7 do 
                while self:hasShun(handCardCopy,cardType,value) and self:remainInHand(handCardCopy)>=SHUN_CARDNUM do 
                    handCardCopy[cardType][10] = handCardCopy[cardType][10] - SHUN_CARDNUM;
                    handCardCopy[cardType][value] = handCardCopy[cardType][value] - 1;
                    handCardCopy[cardType][value+1] = handCardCopy[cardType][value+1] - 1;
                    handCardCopy[cardType][value+2] = handCardCopy[cardType][value+1] - 1;
                    recommandOut = bit.blshift(cardType - 1, 4) + value;
                end 
            end 
        end
    end

    --如果对子数大于一则先出对子
    if duiNum > 1 then
        recommandOut = outCardPrepare;
    end

    --保留连续的牌
    for cardType = 1, #handCardCopy do
        if self:remainInHand(handCardCopy) >= 2 then 
            for value = 1, 8 do 
                if handCardCopy[cardType][value] > 0 and handCardCopy[cardType][value+1] > 0 then
                    handCardCopy[cardType][10] = handCardCopy[cardType][10] - 2;
                    handCardCopy[cardType][value] = handCardCopy[cardType][value] - 1;
                    handCardCopy[cardType][value+1] = handCardCopy[cardType][value+1] - 1;
                    recommandOut = bit.blshift(cardType - 1, 4) + value;
                end
            end 
        end
    end  

    --选出一张其他牌
    for cardType=1,#handCardCopy do
        for value=1,9 do 
            if handCardCopy[cardType][value] > 0 then
                recommandOut=bit.blshift(cardType - 1, 4) + value;
            end
        end 
    end  
 	return recommandOut;
end

SingleGameAI.getDingQue = function ( self, handCard, opCards )
    local dingQueType = 1;
    local isOpCardtype = {};
    --不能定缺操作过的花色
    for i = 1, #handCard do 
        for j = 1, opCards[i][20] do             
            local index = bit.brshift(opCards[i][j], 4) + 1;
            isOpCardtype[index] = true;
        end 
    end
    --有一门比其他两门都少的情况
    if (handCard[1][10] < handCard[2][10]) and (handCard[1][10] < handCard[3][10]) and not isOpCardtype[1] then
        dingQueType = 1;  --万最少
    elseif (handCard[2][10] < handCard[1][10]) and (handCard[2][10] < handCard[3][10]) and not isOpCardtype[2] then
        dingQueType = 2;  --筒最少
    elseif (handCard[3][10] < handCard[1][10]) and (handCard[3][10] < handCard[2][10]) and not isOpCardtype[3] then
        dingQueType = 3;  --条最少
    end
    --有两门数量相同而且同时小于某一门的情况
    if (handCard[1][10] == handCard[2][10]) and (handCard[1][10] < handCard[3][10]) then  --万筒相等同时小于条
        dingQueType = self:getQueWhenCardNumEqual(handCard, 1, 2, isOpCardtype);
    elseif (handCard[1][10] == handCard[3][10]) and (handCard[1][10] < handCard[2][10]) then  --万条相等同时小于筒
        dingQueType = self:getQueWhenCardNumEqual(handCard, 1, 3, isOpCardtype);
    elseif (handCard[2][10] == handCard[3][10]) and (handCard[2][10] < handCard[1][10]) then  --筒条相等同时小于万
        dingQueType = self:getQueWhenCardNumEqual(handCard, 2, 3, isOpCardtype);
    end

    --测试代码--
    for i = 1, 3 do
        print(handCard[i][1].." "..handCard[i][2].." "..handCard[i][3].." "
                ..handCard[i][4].." "..handCard[i][5].." "..handCard[i][6]..
                " "..handCard[i][7].." "..handCard[i][8].." "..handCard[i][9]..
                " total:"..handCard[i][10]);
    end
    DebugLog("定缺结果:"..dingQueType);
    --测试代码 end--

    return dingQueType;
end

--获取手牌数量
SingleGameAI.remainInHand = function( self, handCard )
    return handCard[1][10] + handCard[2][10] + handCard[3][10];
end

--判断是否有顺子
SingleGameAI.hasShun = function( self, handCard, cardType, value )
	local card1 = handCard[cardType][value] > 0;
	local card2 = handCard[cardType][value+1] > 0;
	local card3 = handCard[cardType][value+2] > 0;
    return card1 and card2 and card3;  --有连续3张有值的牌即为顺子
end

--判断是否有连张
SingleGameAI.hasLian = function( self, handCard, cardType, value )
    local card1 = handCard[cardType][value] > 0;
    local card2 = handCard[cardType][value+1] > 0;
    return card1 and card2;  --有连续2张有值的牌即为连张
end

--判断是否有对子或暗刻
SingleGameAI.hasDui = function( self, handCard, cardType, value )
    local isDui = handCard[cardType][value] >= 2;
    return isDui;
end

--判断两门手牌数量相同的情况下应该定缺哪门
--逻辑描述：两门张数相同的情况下，会优先保留有两对的一门，其次是有顺子的门，再次是
--          有一对的一门，再次是连续的两张牌，在这些情况满足的条件下会优先保留靠近中张的牌
SingleGameAI.getQueWhenCardNumEqual = function( self, handCard, cardType1, cardType2 ,opCards )
    -- --不能定缺操作过的花色
    -- if opCards[cardType1] or opCards[cardType2] then
    --     if opCards[cardType1] then
    --         return cardType2;
    --     end
    --     if opCards[cardType2] then
    --         return cardType1;
    --     end
    -- end
    local DUI_VALUE = 200;  --对子的价值度
    local SHUN_VALUE = 300;  --顺子的价值度
    local LIAN_VALUE = 20;  --连张的价值度 

    local dingQue = cardType1;  --先默认定缺1
    local value1 = 0;  --cardType1的价值度
    local value2 = 0;  --cardType2的价值度

    --先检测牌中的顺子
    for i = 1, #handCard[1] - 3 do
        if self:hasShun(handCard, cardType1, i) then
            value1 = value1 + SHUN_VALUE;
        end
        if self:hasShun(handCard, cardType2, i) then
            value2 = value2 + SHUN_VALUE;
        end
    end
    --再检测牌中的对子
    for i = 1, #handCard[1] - 1 do
        if self:hasDui(handCard, cardType1, i) then
            value1 = value1 + DUI_VALUE;
        end
        if self:hasDui(handCard, cardType2, i) then
            value2 = value2 + DUI_VALUE;
        end
    end
    --再检测牌中的连张
    for i = 1, #handCard[1] - 2 do
        if self:hasLian(handCard, cardType1, i) then
            value1 = value1 + LIAN_VALUE;
        end
        if self:hasLian(handCard, cardType2, i) then
            value2 = value2 + LIAN_VALUE;
        end
    end
    --计算牌的单张价值度(5-“牌面数字-5”的绝对值)(即中张程度,越中张的值越大))
    for i = 1, #handCard[1] - 1 do
        if handCard[cardType1][i] > 0 then
            value1 = value1 + ((5 - math.abs(i - 5)) * handCard[cardType1][i]);
        end
        if handCard[cardType2][i] > 0 then
            value2 = value2 + ((5 - math.abs(i - 5)) * handCard[cardType2][i]);
        end
    end

    if value1 > value2 then
        dingQue = cardType2;  --默认定缺的是type1,如果type1的价值大于type2则定缺type2
    end
    DebugLog("【单机游戏】开始计算定缺价值度----------------->");
    DebugLog("【单机游戏】"..cardType1.."定缺价值度-->"..value1);
    DebugLog("【单机游戏】"..cardType2.."定缺价值度-->"..value2);
    return dingQue;
end

