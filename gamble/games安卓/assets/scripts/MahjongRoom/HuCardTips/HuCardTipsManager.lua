-- 胡牌提示管理器
-- desp: 控制何时显示下叫提示以及胡牌番数提示
-- author: OnlynightZhang

require("Animation/JiaoTipAnim");

HuCardTipsManager = class();

HuCardTipsManager.instance = nil;
HuCardTipsManager.getInstance = function()
	if HuCardTipsManager.instance == nil then
		HuCardTipsManager.instance = new(HuCardTipsManager);
	end
	return HuCardTipsManager.instance;
end

HuCardTipsManager.ctor = function( self )
	self.jiaoTips = {}; -- 下叫动画列表，方便统一管理
	self.canShowTips = false; -- 是否可以显示提示
	self.m_huCardTipsDataHolder = nil; -- 胡牌提示数据holder
end

-- 设置数据保持者
HuCardTipsManager.setHuCardTipsDataHolder = function( self, huCardTips )
	self:clearAll();
	self.m_huCardTipsDataHolder = huCardTips;
	mahjongPrint( huCardTips );
	mahjongPrint( self.m_huCardTipsDataHolder );
end

-- 获取胡牌数据保持者
HuCardTipsManager.getHuCardTipsDataHolder = function( self )
	return self.m_huCardTipsDataHolder;
end

-- 设置胡牌提示信息
-- mahjongs 自己的手牌
-- huCardTips 下叫以及胡牌提示
HuCardTipsManager.setHuCardTips = function( self, mahjongs, huCardTips )
	self:resetManager();
	self.huCardTips = huCardTips;
	if not mahjongs then
		return;
	end

	self.canShowTips = true;

	local tips = nil;
	if huCardTips then
		tips = huCardTips;
	else
		tips = self.m_huCardTipsDataHolder;
	end

	if not tips or #tips <= 0 then
		return;
	end

	local bestAll = self:getBestHuCard(tips);
	local isBest = false
	local ms   = self:getLastReadyMahjong( mahjongs, tips );
	for k,v in pairs(ms) do
		if bestAll then 
			isBest = false
			for i=1,#bestAll do
				if bestAll[i].card == v.value then 
					isBest = true
					break
				end
			end
		end 
		self:createJiaoTip( v, isBest );
	end
end

-- 获取打出后就下叫的牌
-- huCardTips 下叫以及胡牌提示
HuCardTipsManager.getReadyCards = function( self, huCardTips )
	if not huCardTips then
		return;
	end

	local temp = {};
	for k,v in pairs(huCardTips) do
		table.insert( temp, v.readyCard );
	end

	return temp;
end

-- 获取下叫后胡牌的数据
-- mahjongValue 麻将的value
HuCardTipsManager.getHuCardsData = function( self, mahjongValue )
	local tempTips = self.huCardTips == nil and self.m_huCardTipsDataHolder or self.huCardTips; -- 如果不是马上提示下叫，那么就是点击过以后提示下叫，再有就是异常不显示
	if not mahjongValue or not tempTips then
		return nil;
	end

	for k,v in pairs(tempTips) do
		if tonumber(v.readyCard) == tonumber(mahjongValue) then
			return v;
		end
	end

	return nil;
end


HuCardTipsManager.getBestHuCard = function ( self, huCardTips )
	if not huCardTips or #huCardTips <= 0 then
		return nil;
	end

	--非vip用户不显示最佳
	local vip = PlayerManager.getInstance():myself().vipLevel
	if not(vip and tonumber(vip) > 0) then 
		return nil
	end 


	local maxHuNum = 0
	local maxFan   = 0
	local maxRemainNum = 0
	local findCard = 0
	local cmp = {}

	for k,v in pairs(huCardTips) do
		local item = {}
		item.card   = v.readyCard
		item.huNum  = v.num
		item.maxFan = 0
		item.remainNum = 0

		for i=1,#v.cards do
			if v.cards[i].fans > item.maxFan then 
				item.maxFan = v.cards[i].fans
			end
			item.remainNum = item.remainNum + v.cards[i].left
		end

		table.insert(cmp,item)
	end
	if #cmp <= 0 then 
		return nil
	end 

	local maxItems = {} 
	--cmp[1]
	for i=1,#cmp do
		if #maxItems <= 0 then
			table.insert(maxItems,cmp[i])
		elseif cmp[i].huNum > maxItems[1].huNum then ---- 胡牌张数最多
			maxItems = {}
			table.insert(maxItems,cmp[i])
		elseif cmp[i].huNum == maxItems[1].huNum then 
			if cmp[i].maxFan > maxItems[1].maxFan then--番型最大 
				maxItems = {}
				table.insert(maxItems,cmp[i])
			elseif cmp[i].maxFan == maxItems[1].maxFan then
				if cmp[i].remainNum > maxItems[1].remainNum then --剩余有效张数最多
					maxItems = {}
					table.insert(maxItems,cmp[i])
				elseif cmp[i].remainNum == maxItems[1].remainNum then 
					table.insert(maxItems,cmp[i])
				end 
			end
		end 
	end
	return maxItems
end
-- 获取下叫的牌中的最后一张牌
-- mahjongs 玩家的手牌
-- huCardTips 下叫以及胡牌提示
HuCardTipsManager.getLastReadyMahjong = function( self, mahjongs, huCardTips )
	local cards = self:getReadyCards( huCardTips );
	local temp = {};
	local times = #mahjongs;
	local lastSameIndex = -1;
	local curMahjong = nil;

	-- 修正获取最后一张相等的牌的算法
	for k,value in pairs(cards) do
		for i=1,times do
			curMahjong = mahjongs[i];

			-- 如果当前下叫的牌和手牌的某一张匹配，则记下牌的index
			if curMahjong.value == value then
				lastSameIndex = i;
			end

			-- 当整这个序列便利完成后，需要得到最后一张相等的麻将，并把麻添加到最终输出的表中
			if i == times then
				if lastSameIndex ~= -1 then
					table.insert( temp, mahjongs[lastSameIndex] );
				end
				lastSameIndex = -1;
			end
		end
	end

	if lastSameIndex == times then
		table.insert( temp, mahjongs[times] );
	end

	return temp
end

HuCardTipsManager.createJiaoTip = function( self, mahjong,bIsBest )
	if not mahjong then
		return;
	end
	local x,y = mahjong:getPos();
	local jiaotipanim = new(JiaoTipAnim, mahjong.value, x, y,nil,bIsBest);
	jiaotipanim:play();
	table.insert( self.jiaoTips, jiaotipanim );
end

HuCardTipsManager.showJiaoTip = function( self, mahjong, isShow )
	if not mahjong then
		return;
	end

	for k,v in pairs(self.jiaoTips) do
		if v.value == mahjong.value then
			v:setVisible( isShow or false );
		end
	end

	if isShow then
		self:hideHuCardTipsWindow();
	else
		self:showHuCardTipsWindow( mahjong );
	end
end

HuCardTipsManager.showHuCardTipsWindow = function( self, mahjong )
	if not mahjong then
		return;
	end

	if not self.canShowTips then
		return;
	end

	require("MahjongRoom/HuCardTips/HuCardTipsWindow");
	local x,y = mahjong:getPos();
	self.huCardTipswindow = new( HuCardTipsWindow, self:getHuCardsData(mahjong.value), x, y - 100 );
	self.huCardTipswindow:showWnd();
	self.huCardTipswindow:setOnWindowHideListener( self, function( self )
		self.huCardTipswindow = nil;
	end);
end

HuCardTipsManager.hideHuCardTipsWindow = function( self )
	if self.huCardTipswindow then
		self.huCardTipswindow:hideWnd();
	end
end

HuCardTipsManager.clearJiaoTips = function( self )
	for k,v in pairs(self.jiaoTips) do
		v:stop();
	end
	self.jiaoTips = {};
end

HuCardTipsManager.resetManager = function( self )
	self.canShowTips = false;
	self:clearJiaoTips();
	self:hideHuCardTipsWindow();
	self.huCardTips = nil;
end

HuCardTipsManager.clearAll = function( self )
	self:resetManager();
	self.m_huCardTipsDataHolder = nil;
end

HuCardTipsManager.dtor = function( self )
end