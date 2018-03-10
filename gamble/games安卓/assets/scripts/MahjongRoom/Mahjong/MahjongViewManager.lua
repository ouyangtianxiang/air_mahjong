require("MahjongRoom/Mahjong/Mahjong")

MahjongViewManager = class();

MahjongViewManager.MahongTypeTable = {
	MAHJONG_TYPE_NORMAL = 10000, -- 普通麻将纸
	MAHJONG_TYPE_VIP = 10001, -- VIP麻将纸
	MAHJONG_TYPE_PINK = 28, -- 粉红麻将子
	MAHJONG_TYPE_CYAN = 29, -- 青绿色
	MAHJONG_TYPE_SKYBLUE = 30, -- 天蓝色
}

MahjongViewManager.instance = nil; -- private
MahjongViewManager.getInstance = function ()
	if not MahjongViewManager.instance then
		MahjongViewManager.instance = new(MahjongViewManager);
	end
	return MahjongViewManager.instance;
end

MahjongViewManager.ctor = function (self)
end

MahjongViewManager.dtor = function (self)
end

MahjongViewManager.needToShowVipCard = function ( self, seat )
	local player = PlayerManager.getInstance():getPlayerBySeat(seat);
	if not seat or not player then
		return false;
	end
	if kSeatMine == seat then
		return player:checkVipStatu(Player.VIP_MZZ);
	else
		return PlayerManager.getInstance():getPlayerBySeat(kSeatMine):checkVipStatu(Player.VIP_MZZ) or 
		player:checkVipStatu(Player.VIP_MZZ);
	end
end

MahjongViewManager.getMahjongType = function( self, seatId )
	if not seatId then
		return MahjongViewManager.MahongTypeTable.MAHJONG_TYPE_NORMAL;
	end

	local player = PlayerManager.getInstance():getPlayerBySeat(seatId);
	if not player then
		return MahjongViewManager.MahongTypeTable.MAHJONG_TYPE_NORMAL;
	end
	return tonumber(player.paizhi) or MahjongViewManager.MahongTypeTable.MAHJONG_TYPE_NORMAL
end

--[[
	取得碰杠的牌的图片拼图
	operatType : 定义可见GameDefine
]]
MahjongViewManager.pengGangMahjongView = function (self, seat , card , operatType)
	if kSeatMine == seat then
		return self:minePengGangMahjongView(card , operatType);
	elseif kSeatRight == seat then
		return self:rightPengGangMahjongView(card , operatType);
	elseif kSeatTop == seat then
		return self:topPengGangMahjongView(card , operatType);
	elseif kSeatLeft == seat then
		return self:leftPengGangMahjongView(card , operatType);
	end
end

-- 内部函数
MahjongViewManager.minePengGangMahjongView = function (self ,card , operatType)
	local node = new(Node);
	local mahjongs = {};
	for i=1,3 do
		local mahjong = nil;
		if an_gang(operatType) then
			mahjong = new(Mahjong , getAnGangImageFileBySeat(kSeatMine, MahjongViewManager.getInstance():getMahjongType(kSeatMine)));
		else
			mahjong = new(Mahjong , getPengGangImageFileBySeat(kSeatMine , card, MahjongViewManager.getInstance():getMahjongType(kSeatMine)));
		end
		-- mahjong:setPos((i - 1) * (MineBlockCard_W + 1) , 0);
		mahjong:setPos((i - 1) * (MineBlockCard_W-5 ) , 0);
		node:addChild(mahjong);
		mahjong:setEnableCustom(false);
		table.insert(mahjongs , mahjong);
	end
	if operatorValueHasGang(operatType) then
		local mahjong = new(Mahjong , getPengGangImageFileBySeat(kSeatMine , card, MahjongViewManager.getInstance():getMahjongType(kSeatMine)));
		mahjong:setPos(MineBlockCard_W - 5, -32*GameConstant.bottomMahjongScale+5);
		mahjong:setEnableCustom(false);
		mahjong.isAboveMahjong = true;
		node:addChild(mahjong);
		table.insert(mahjongs , mahjong);
	end 
	return node , mahjongs;
end

MahjongViewManager.rightPengGangMahjongView = function (self ,card , operatType)
	local node = new(Node);
	local mahjongs = {};
	local mahjong = nil;

	local baseY = -3-- + 2*(RightBlockCard_H - 16)*GameConstant.rightMahjongScale
	for i=1,3 do
		if an_gang(operatType) then
			mahjong = new(Mahjong , getAnGangImageFileBySeat(kSeatRight, MahjongViewManager.getInstance():getMahjongType(kSeatRight)));
		else
			mahjong = new(Mahjong , getPengGangImageFileBySeat(kSeatRight , card, MahjongViewManager.getInstance():getMahjongType(kSeatRight)));
		end
		mahjong:setPos(0 ,baseY + (i - 1) * (RightBlockCard_H - 16) *GameConstant.rightMahjongScale);
		--mahjong:setLevel(10 - i);
		mahjong:setEnableCustom(false);
		node:addChild(mahjong);
		table.insert(mahjongs , mahjong);
	end
	if operatorValueHasGang(operatType) then
		if an_gang(operatType) then
			mahjong = new(Mahjong , getAnGangImageFileBySeat(kSeatRight, MahjongViewManager.getInstance():getMahjongType(kSeatRight)));
		else
			mahjong = new(Mahjong , getPengGangImageFileBySeat(kSeatRight , card, MahjongViewManager.getInstance():getMahjongType(kSeatRight)));
		end
		mahjong:setLevel(10);
		mahjong:setPos(0 ,baseY + (RightBlockCard_H - 16)*GameConstant.rightMahjongScale - 15);
		mahjong:setEnableCustom(false);
		mahjong.isAboveMahjong = true;
		node:addChild(mahjong);
		table.insert(mahjongs , mahjong);
	end 
	return node , mahjongs;
end

MahjongViewManager.topPengGangMahjongView = function (self ,card , operatType)
	local node = new(Node);
	local mahjongs = {};
	local mahjong = nil;
	--local baseX = 2
	for i=1,3 do
		if an_gang(operatType) then
			mahjong = new(Mahjong , getAnGangImageFileBySeat(kSeatTop, MahjongViewManager.getInstance():getMahjongType(kSeatTop)));
		else
			mahjong = new(Mahjong , getPengGangImageFileBySeat(kSeatTop , card, MahjongViewManager.getInstance():getMahjongType(kSeatTop)));
		end
		mahjong:setPos(- i * TopBlockCard_W , 0);
		mahjong:setEnableCustom(false);
		node:addChild(mahjong);
		table.insert(mahjongs , mahjong);
	end
	if operatorValueHasGang(operatType) then
		if an_gang(operatType) then
			mahjong = new(Mahjong , getAnGangImageFileBySeat(kSeatTop, MahjongViewManager.getInstance():getMahjongType(kSeatTop)));
		else
			mahjong = new(Mahjong , getPengGangImageFileBySeat(kSeatTop , card, MahjongViewManager.getInstance():getMahjongType(kSeatTop)));
		end
		mahjong:setPos(-2*TopBlockCard_W , -20*GameConstant.topMahjongScale);
		mahjong:setEnableCustom(false);
		mahjong.isAboveMahjong = true;
		node:addChild(mahjong);
		table.insert(mahjongs , mahjong);
	end 
	return node , mahjongs;
end

MahjongViewManager.leftPengGangMahjongView = function (self ,card , operatType)
	local node = new(Node);
	local mahjongs = {};
	local mahjong = nil;
	for i=1,3 do
		if an_gang(operatType) then
			mahjong = new(Mahjong , getAnGangImageFileBySeat(kSeatLeft, MahjongViewManager.getInstance():getMahjongType(kSeatLeft)));
		else
			mahjong = new(Mahjong , getPengGangImageFileBySeat(kSeatLeft , card, MahjongViewManager.getInstance():getMahjongType(kSeatLeft)));
		end
		mahjong:setPos(0 , (i - 1) *(LeftBlockCard_H-16)* GameConstant.leftMahjongScale);
		mahjong:setEnableCustom(false);
		node:addChild(mahjong);
		table.insert(mahjongs , mahjong);
	end
	if operatorValueHasGang(operatType) then
		if an_gang(operatType) then
			mahjong = new(Mahjong , getAnGangImageFileBySeat(kSeatLeft, MahjongViewManager.getInstance():getMahjongType(kSeatLeft)));
		else
			mahjong = new(Mahjong , getPengGangImageFileBySeat(kSeatLeft , card, MahjongViewManager.getInstance():getMahjongType(kSeatLeft)));
		end
		mahjong:setPos(0 , (LeftBlockCard_H-16)*GameConstant.leftMahjongScale-14);
		mahjong:setEnableCustom(false);
		mahjong.isAboveMahjong = true;
		node:addChild(mahjong);
		table.insert(mahjongs , mahjong);
	end 
	return node , mahjongs;
end


--[[
	取得碰杠操作上的牌的图片拼图
	operatType : 定义可见GameDefine
]]
MahjongViewManager.operatPengGangMahjongView = function (self ,card , operatType)
	local node = new(Node);
	if operatType then
		local mahjong = new(Mahjong , getPengGangImageFileBySeat(kSeatMine , card, MahjongViewManager.getInstance():getMahjongType(kSeatMine)));
		mahjong:setPos(170 , 35);
		mahjong:setEnableCustom(false);
		node:addChild(mahjong);
	end 
	return node;
end


