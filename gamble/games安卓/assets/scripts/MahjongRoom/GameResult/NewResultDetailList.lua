NewResultDetailList = class(Node)

NewResultDetailList.dataTypeGFXY = 1; -- 刮风下雨
NewResultDetailList.dataTypeHU = 3; -- 胡和自摸
NewResultDetailList.dataTypeDAJIAO = 4; -- 大叫
NewResultDetailList.dataTypeHUAZHU = 5; -- 花猪


NewResultDetailList.fanshuDist = 10;

NewResultDetailList.ctor = function(self,data)
	if not data then
		return;
	end
	self.m_x = 0;
	self.m_y = 0;
	self.m_w = data.w;
	self.m_h = data.h;
	data.money = tonumber(data.money);
	self.playerBaseInfo = data.playerBaseInfo; -- 保存了4个玩家的基本信息
	self.mySeatId = data.mySeat; -- 自己的座位id
	self.bg = UICreator.createImg( "Commonx/blank.png", 0, 0 );
	self.bg:setSize(data.w, data.h);
	self.dist = 30;
	self:addChild( self.bg );
	self.bg:setVisible(false);
	if NewResultDetailList.dataTypeGFXY == data.type then
		self:createGFXYView(data);
		self.bg:setVisible(true);
	elseif NewResultDetailList.dataTypeHU == data.type then
		self:createZIMOOrHuView(data);
	elseif NewResultDetailList.dataTypeDAJIAO == data.type or NewResultDetailList.dataTypeHUAZHU == data.type then
		self:createDAJIAOOrHUAZHUView(data);
	end
end

NewResultDetailList.createGFXYView = function ( self, data )
	local nickName = UICreator.createText( stringFormatWithString(self.playerBaseInfo[data.mySeat].nickName,8), self.dist, 0, 0, 0, kAlignTopLeft, 26, 0x4b, 0x2b, 0x1c );
	local text = GameString.convert2Platform("刮风下雨所得金币");
	local desc = UICreator.createText( text, 178 + self.dist, 0, 0, 0, kAlignTopLeft, 26, 0x4b, 0x2b, 0x1c );
	local money = nil;
	if data.money >= 0 then
		money = UICreator.createText( "+"..data.money, 635 + self.dist, 0, 0, 0, kAlignTopLeft, 26, 0xcc, 0x44, 0x00 );
	else
		money = UICreator.createText( data.money, 635 + self.dist, 0, 0, 0, kAlignTopLeft, 26, 0x4b, 0x2b, 0x1c );
	end
	self:addChild( nickName );
	self:addChild( desc );
	self:addChild( money );
end

-- local temp = {};
-- 	tamp.type = ResultDetailList.dataTypeHU;
-- 	tamp.huType = huType;
-- 	temp.winSeatId = seatId;
-- 	temp.paiTypeStr = paiTypeStr;
-- 	temp.paiTypeFan = paiTypeFan;
-- 	temp.extraTypeStrs = extraTypeStrs;
-- 	temp.isNewCmd = true;
-- 	table.insert(self.resultInfoList[seatId].listItemData, temp); -- 赢钱玩家
-- 	for k,v in pairs(beiHuPlayers) do -- 输钱玩家
-- 		local temp2 = publ_deepcopy(temp);
-- 		local player = PlayerManager.getInstance():getPlayerById(v.mid);
-- 		temp2.loseSeatId = player.localSeatId;
-- 		temp2.loseMoney = v.loseMoney;
-- 		table.insert(self.resultInfoList[temp2.loseSeatId].listItemData, temp);
-- 	end
NewResultDetailList.createZIMOOrHuView = function ( self, data )
	local posX, posY = 0 + self.dist, 0;
	local nickName = UICreator.createText( stringFormatWithString(self.playerBaseInfo[data.winSeatId].nickName,8), posX, posY, 0, 0, kAlignTopLeft, 26, 0x4b, 0x2b, 0x1c);
	local text = nil;
	-- 自摸或是胡牌的文字
	if 1 == data.huType then -- 胡
		if data.huNum and data.huNum > 1 then
			text = GameString.convert2Platform("胡x"..data.huNum);
		else
			text = GameString.convert2Platform("胡");
		end
	else -- 自摸
		if data.zimoNum and data.zimoNum > 1 then
			text = GameString.convert2Platform("自摸x"..data.zimoNum);
		else
			text = GameString.convert2Platform("自摸");
		end
	end
	posX, posY = 178 + self.dist, 0;
	local temp = posX;
	-- local scrollX, scrollY, scrollW, scrollH = posX, posY, 500 - posX - 66, 30; -- 翻型描述添加滚动
	local scrollX, scrollY, scrollW, scrollH = posX, posY, 418, 30; -- 翻型描述添加滚动

	local contentW = 0;
	local roomSelectViewNode = new(ScrollView, scrollX, scrollY, scrollW, scrollH, false);
	roomSelectViewNode:setDirection(kHorizontal);
	roomSelectViewNode:setPickable(false);
	self:addChild(roomSelectViewNode);

	posX, posY = 0, 0;
	local desc = UICreator.createText( text, posX, posY, 0, 0, kAlignTopLeft, 26, 0x4b, 0x2b, 0x1c );

	
	roomSelectViewNode:addChild( desc );

	-- 番型展示
	posX, posY = posX + desc.m_res.m_width, 0;
	
	local paixing = " " .. data.paiTypeStr;
	local paixingText = UICreator.createText( paixing, posX, posY, 0, 0, kAlignTopLeft, 26, 0x4b, 0x2b, 0x1c );
	roomSelectViewNode:addChild( paixingText );
	posX = posX + paixingText.m_res.m_width + NewResultDetailList.fanshuDist;
	
	if data.extraTypeStrs then 
		for k,v in pairs(data.extraTypeStrs) do -- 额外番型
			local fanText = UICreator.createText( " "..v, posX, posY, 0, 0, kAlignTopLeft, 26, 0x4b, 0x2b, 0x1c );
			roomSelectViewNode:addChild( fanText );
			posX = posX + fanText.m_res.m_width + NewResultDetailList.fanshuDist;
		end
	end 
	local contentW = posX - contentW;


	-- 添加自动滚动定时器
	local speed = -3;
	local bLeft = true;
	local coldFrame = 60;
	local bCold = true;
	if contentW > scrollW + 5 then
		local dist = contentW - scrollW; -- 左移距离
		delete(self.moveAnim);
		self.moveAnim = new(AnimInt, kAnimRepeat, 0, 1, 50, 0);
		self.moveAnim:setDebugName("NewResultDetailList|NewResultDetailList.moveAnim");
		self.moveAnim:setEvent(self, function ( self )
			if not bCold then
				roomSelectViewNode.m_mainNode:setPos(roomSelectViewNode.m_mainNode.m_x / System.getLayoutScale() + speed, roomSelectViewNode.m_mainNode.m_y / System.getLayoutScale());
				dist = dist - math.abs(speed);
				if dist <= 0 then
					speed = 0 - speed;
					dist = contentW - scrollW;
					bCold = true;
					coldFrame = 60;
				end
			else
				coldFrame = coldFrame - 1;
				if coldFrame <= 0 then
					bCold = false;
				end
			end
		end);
	end

	posX = temp;

	-- 输赢钱数
	local moneyChange = data.winMoney;
	if self.mySeatId == data.loseSeatId then
		moneyChange = data.loseMoney;
	else
		moneyChange = data.winMoney;
	end
	
	posX = 635 + self.dist;
	if moneyChange >= 0 then
		money = UICreator.createText( "+"..moneyChange, posX, 0, 0, 0, kAlignTopLeft, 26, 0xcc, 0x44, 0x00 );
	else
		money = UICreator.createText( moneyChange, posX, 0, 0, 0, kAlignTopLeft, 26, 0x4b, 0x2b, 0x1c );
	end
	self:addChild( nickName );
	-- self:addChild( desc );
	self:addChild( money );

end

NewResultDetailList.createDAJIAOOrHUAZHUView = function ( self, data )
	local text1 = nil;
	local text2 = nil;
	if NewResultDetailList.dataTypeDAJIAO == data.type then -- 查大叫
		text1 = GameString.convert2Platform("查大叫");
		text2 = GameString.convert2Platform("查大叫");
	else -- 查花猪
		text1 = GameString.convert2Platform("查花猪");
		text2 = GameString.convert2Platform("查花猪");
	end
	-- 显示自己的昵称
	local nickName = UICreator.createText( stringFormatWithString(self.playerBaseInfo[self.mySeatId].nickName,8), 0 + self.dist, 0, 0, 0, kAlignTopLeft, 26, 0x4b, 0x2b, 0x1c );
	local text = nil;
	local moneyChange = data.money;
	if data.winSeatId == self.mySeatId then -- 赢
		text = text1;
	else -- 输
		text = text2;
		moneyChange = 0 - moneyChange; -- 输钱
	end
	local desc = UICreator.createText( text, 178 + self.dist, 0, 0, 0, kAlignTopLeft, 26, 0x4b, 0x2b, 0x1c );
	local money = nil;
	if moneyChange >= 0 then
		money = UICreator.createText( "+"..moneyChange, 635 + self.dist, 0, 0, 0, kAlignTopLeft, 26, 0xcc, 0x44, 0x00 );
	else
		money = UICreator.createText( moneyChange, 635 + self.dist, 0, 0, 0, kAlignTopLeft, 26, 0x4b, 0x2b, 0x1c );
	end
	self:addChild( nickName );
	self:addChild( desc );
	self:addChild( money );
	if NewResultDetailList.dataTypeDAJIAO == data.type then
		text = GameString.convert2Platform(" " .. data.fanNum.."番");
		local desc1 = UICreator.createText( text, 178 + self.dist + desc.m_res.m_width, 0, 0, 0, kAlignTopLeft, 26, 0x4b, 0x2b, 0x1c );
		self:addChild( desc1 );
	end
end



NewResultDetailList.getPos = function(self)
	return self.m_x,self.m_y;
end 

NewResultDetailList.getSize = function(self)
	return self.m_w,self.m_h;
end

NewResultDetailList.dtor = function(self)
	delete(self.moveAnim);
	self:removeAllChildren();
end

