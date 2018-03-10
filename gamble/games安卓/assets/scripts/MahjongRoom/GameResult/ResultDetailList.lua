ResultDetailList = class(Node)

ResultDetailList.dataTypeGFXY = 1; -- 刮风下雨
ResultDetailList.dataTypeZIMO = 2; -- 自摸
ResultDetailList.dataTypeHU = 3; -- 胡
ResultDetailList.dataTypeDAJIAO = 4; -- 大叫
ResultDetailList.dataTypeHUAZHU = 5; -- 花猪
ResultDetailList.dataTypeHUXLCH = 6; -- 血流胡牌
ResultDetailList.dataTypeZIMOXLCH = 7; -- 血流自摸


ResultDetailList.fanshuDist = 10;

ResultDetailList.ctor = function(self,data)
	if not data then
		return;
	end

	self.m_x = 0;
	self.m_y = 0;
	self.m_w = data.w;
	self.m_h = data.h;
	self.descWidth = 396;

	data.money = tonumber(data.money);
	self.playerBaseInfo = data.playerBaseInfo; -- 保存了4个玩家的基本信息
	self.mySeatId = data.mySeat; -- 自己的座位id

	self.bg = UICreator.createImg( "Commonx/blank.png", 0, 0 );
	self.bg:setSize(data.w, data.h);
	self.dist = 30;
	self:addChild( self.bg );
	self.bg:setVisible(false);
	if ResultDetailList.dataTypeGFXY == data.type then
		self:createGFXYView(data);
		self.bg:setVisible(true);
	elseif ResultDetailList.dataTypeZIMO == data.type or ResultDetailList.dataTypeHU == data.type then
		self:createZIMOOrHuView(data);
	elseif ResultDetailList.dataTypeDAJIAO == data.type or ResultDetailList.dataTypeHUAZHU == data.type then
		self:createDAJIAOOrHUAZHUView(data);
	end
end

ResultDetailList.createGFXYView = function ( self, data )
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

ResultDetailList.createZIMOOrHuView = function ( self, data )
	local posX, posY = 0 + self.dist, 0;
	local nickName = UICreator.createText( stringFormatWithString(self.playerBaseInfo[data.winSeatId].nickName,8), posX, posY, 0, 0, kAlignTopLeft, 26, 0x4b, 0x2b, 0x1c);
	local text = nil;
	-- 自摸或是胡牌的文字
	if ResultDetailList.dataTypeHU == data.type then -- 胡
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
	local desc = UICreator.createText( text, posX, posY, 0, 0, kAlignTopLeft, 26, 0x4b, 0x2b, 0x1c );

	-- 番型展示
	posX, posY = posX + desc.m_res.m_width, 0;
	local paixing = " "..GameString.convert2Platform(GameConstant.paixingfanshu[data.paiType] or "");
	local paixingText = UICreator.createText( paixing, posX, posY, 0, 0, kAlignTopLeft, 26, 0x4b, 0x2b, 0x1c );
	self:addChild( paixingText );
	posX = posX + paixingText.m_res.m_width + ResultDetailList.fanshuDist;
	local fan = nil;
	if ResultDetailList.dataTypeHU == data.type then -- 胡
		if 1 == data.isGangShangPao then -- 杠上炮
			fan = " "..GameString.convert2Platform(GameConstant.paixingfanshu[GameConstant.GANG_SHANG_PAO]);
			local fanText = UICreator.createText( fan, posX, posY, 0, 0, kAlignTopLeft, 26, 0x4b, 0x2b, 0x1c );
			self:addChild( fanText );
			posX = posX + fanText.m_res.m_width + ResultDetailList.fanshuDist;
		elseif 1 == data.isQiangGangHu then -- 抢杠胡
			fan = " "..GameString.convert2Platform(GameConstant.paixingfanshu[GameConstant.QIANG_GANG_HU]);
			local fanText = UICreator.createText( fan, posX, posY, 0, 0, kAlignTopLeft, 26, 0x4b, 0x2b, 0x1c );
			self:addChild( fanText );
			posX = posX + fanText.m_res.m_width + ResultDetailList.fanshuDist;
		end
	else -- 自摸
		if 1 == data.isGangShangKaiHua then -- 杠上花
			fan = " "..GameString.convert2Platform(GameConstant.paixingfanshu[GameConstant.GANG_SHANG_HUA]);
			local fanText = UICreator.createText( fan, posX, posY, 0, 0, kAlignTopLeft, 26, 0x4b, 0x2b, 0x1c );
			self:addChild( fanText );
			posX = posX + fanText.m_res.m_width + ResultDetailList.fanshuDist;
		end
	end
	local genFan = nil;
	local gangFan = nil;
	if data.siZhangNum > 0 then
		genFan = GameString.convert2Platform(" 根"..data.siZhangNum.."番");
	end
	if data.gangShangNum > 0 then
		gangFan = GameString.convert2Platform(" 杠"..data.gangShangNum.."番");
	end
	if genFan then
		local genFanText = UICreator.createText( genFan, posX, posY, 0, 0, kAlignTopLeft, 26, 0x4b, 0x2b, 0x1c );
		self:addChild( genFanText );
		posX = posX + genFanText.m_res.m_width + ResultDetailList.fanshuDist;
	end
	if gangFan then
		local gangFanText = UICreator.createText( gangFan, posX, posY, 0, 0, kAlignTopLeft, 26, 0x4b, 0x2b, 0x1c );
		self:addChild( gangFanText );
		posX = posX + gangFanText.m_res.m_width + ResultDetailList.fanshuDist;
	end

	-- 输赢钱数
	local moneyChange = data.money;
	if self.mySeatId ~= data.winSeatId then
		moneyChange = 0 - moneyChange; -- 被胡牌的玩家输掉的钱数
	end
	if ResultDetailList.dataTypeHU == data.type then -- 胡
		
	else -- 自摸
		moneyChange = moneyChange / data.beHuNum; -- 自摸钱数均分
	end
	local money = nil;
	
	-- 乘上胡牌次数
	if ResultDetailList.dataTypeHU == data.type then -- 胡
		if data.huNum and data.huNum > 1 then
			moneyChange = tonumber(moneyChange)*tonumber(data.huNum);
		end
	else -- 自摸
		if data.zimoNum and data.zimoNum > 1 then
			moneyChange = tonumber(moneyChange)*tonumber(data.zimoNum);
		end
	end
	posX = ((posX > (635 + self.dist)) and posX) or (635 + self.dist);
	if moneyChange >= 0 then
		money = UICreator.createText( "+"..moneyChange, posX, 0, 0, 0, kAlignTopLeft, 26, 0xcc, 0x44, 0x00);
	else
		money = UICreator.createText( moneyChange, posX, 0, 0, 0, kAlignTopLeft, 26, 0x4b, 0x2b, 0x1c );
	end
	self:addChild( nickName );
	self:addChild( desc );
	self:addChild( money );

end

ResultDetailList.createDAJIAOOrHUAZHUView = function ( self, data )
	local text1 = nil;
	local text2 = nil;
	if ResultDetailList.dataTypeDAJIAO == data.type then -- 查大叫
		text1 = GameString.convert2Platform("查大叫");
		text2 = GameString.convert2Platform("查大叫");
	else -- 查花猪
		text1 = GameString.convert2Platform("查花猪");
		text2 = GameString.convert2Platform("查花猪");
	end
	local nickName = UICreator.createText( stringFormatWithString(self.playerBaseInfo[data.winSeatId].nickName,8), 0 + self.dist, 0, 0, 0, kAlignTopLeft, 26, 0x4b, 0x2b, 0x1c);
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
		money = UICreator.createText( "+"..moneyChange, 635 + self.dist, 0, 0, 0, kAlignTopLeft,26, 0xcc, 0x44, 0x00 );
	else
		money = UICreator.createText( moneyChange, 635 + self.dist, 0, 0, 0, kAlignTopLeft, 26, 0x4b, 0x2b, 0x1c );
	end
	self:addChild( nickName );
	self:addChild( desc );
	self:addChild( money );
	
	if ResultDetailList.dataTypeDAJIAO == data.type then
		text = GameString.convert2Platform(" " .. data.fanNum.."番");
		local desc1 = UICreator.createText( text, 178 + self.dist + desc.m_res.m_width, 0, 0, 0, kAlignTopLeft, 26, 0x4b, 0x2b, 0x1c );
		self:addChild( desc1 );
	end
end



ResultDetailList.getPos = function(self)
	return self.m_x,self.m_y;
end 

ResultDetailList.getSize = function(self)
	return self.m_w,self.m_h;
end

ResultDetailList.dtor = function(self)
	self:removeAllChildren();
end

