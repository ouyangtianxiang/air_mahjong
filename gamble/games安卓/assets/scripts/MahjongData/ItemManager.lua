
ItemManager = class();

-- 各种道具cid
ItemManager.VIP_CID = 1; -- VIP卡
ItemManager.BUQIAN_CID = 2; -- 补签卡
ItemManager.WANJIN_CID = 3; -- 10000金币
ItemManager.GONGZAI_CID = 4; -- 公仔
ItemManager.TOUXIANG1_CID = 5; -- 头像框1
ItemManager.HUANSANZHANG_CID = 6; -- 换三张
ItemManager.XUELIU_CID = 7; -- 血流卡
ItemManager.TOUXIANG2_CID = 8; -- 头像卡2号
ItemManager.JIANFANGJIAN2W_CID = 9; -- 2W创建房间卡
ItemManager.JIANFANGJIAN5W_CID = 10; -- 5万创建房间卡
ItemManager.LABA_CID           = 22; -- 喇叭
ItemManager.CHANGE_NICK_CID  = 31; -- 改名卡
ItemManager.HONG_BAO_CID     = 46;--红包

ItemManager.MATCH_WEEK_CARD    = 50;--周塞卡
ItemManager.MATCH_MONTH_CARD     = 49;--月赛卡
--新版本5.30用新配置的cid  --又不用新id了，先注释
--ItemManager.VIP_CID = 1; -- VIP卡
--ItemManager.BUQIAN_CID = 2; -- 补签卡
--ItemManager.WANJIN_CID = 3; -- 10000金币
--ItemManager.GONGZAI_CID = 4; -- 公仔
--ItemManager.TOUXIANG1_CID = 5; -- 头像框1
--ItemManager.HUANSANZHANG_CID = 6; -- 换三张
--ItemManager.XUELIU_CID = 7; -- 血流卡
--ItemManager.TOUXIANG2_CID = 8; -- 头像卡2号
--ItemManager.JIANFANGJIAN2W_CID = 9; -- 2W创建房间卡
--ItemManager.JIANFANGJIAN5W_CID = 10; -- 5万创建房间卡
--ItemManager.LABA_CID           = 57--22; -- 喇叭
--ItemManager.CHANGE_NICK_CID  = 61--31; -- 改名卡
--ItemManager.HONG_BAO_CID     = 46;--红包

--ItemManager.MATCH_WEEK_CARD    = 50;--周塞卡
--ItemManager.MATCH_MONTH_CARD     = 49;--月赛卡

ItemManager.ItemCardName = {
	[ItemManager.BUQIAN_CID] = "补签卡",
	[ItemManager.TOUXIANG1_CID] = "1号头像框",
	[ItemManager.HUANSANZHANG_CID] = "换三张卡",
	[ItemManager.XUELIU_CID] = "血流卡",
	[ItemManager.TOUXIANG2_CID] = "2号头像卡",
	[ItemManager.JIANFANGJIAN2W_CID] = "2W卡",
	[ItemManager.JIANFANGJIAN5W_CID] = "5W卡",
	[ItemManager.VIP_CID] = "VIP卡",
	[ItemManager.WANJIN_CID] = "10000金币",
	[ItemManager.GONGZAI_CID] = "公仔"
}

-- 本地有的道具图片，没有的话绘制默认图片
ItemManager.itemImgTable = {
    [ItemManager.BUQIAN_CID]         = "newHall/mall/popu/card_2.png",
    [ItemManager.TOUXIANG1_CID]      = "newHall/mall/popu/card_5.png",
    [ItemManager.HUANSANZHANG_CID]   = "newHall/mall/popu/card_6.png",
    [ItemManager.XUELIU_CID]         = "newHall/mall/popu/card_7.png",
    [ItemManager.JIANFANGJIAN2W_CID] = "newHall/mall/popu/card_9.png",
    [ItemManager.JIANFANGJIAN5W_CID] = "newHall/mall/popu/card_10.png",
    [ItemManager.LABA_CID]           = "newHall/mall/popu/trumpet.png",
    -- [ItemManager.CHANGE_NICK_CID]    = "newHall/mall/popu/changeNickname.png",
}

ItemManager.instance = nil;
ItemManager.getInstance = function ( )
	if not ItemManager.instance then
		ItemManager.instance = new(ItemManager);
	end
	return ItemManager.instance;
end

ItemManager.ctor = function ( self )
	self.myItemList = {};
end

ItemManager.addItem = function ( self, item )
	table.insert(self.myItemList, item);
end


-- 根据cid统计列表中某一种卡的数量
ItemManager.getCardNum = function ( self, targetCID )
	local num = 0;
	for k,v in pairs(self.myItemList) do
		if targetCID == v.cid then
			num = num + v.num;
		end
	end
	return num;
end

-- 移除列表中某一种卡num张
ItemManager.removeCard = function ( self, targetCID, num )
	if num == 0 then
		return true;
	end
	for k,v in pairs(self.myItemList) do
		if targetCID == v.cid then
			v.num = v.num - num;
			return true;
		end
	end
	return false;
end

ItemManager.addCard = function ( self, targetCID, num )
	for k,v in pairs(self.myItemList) do
		if targetCID == v.cid then
			v.num = v.num + num;
		end
	end
end


ItemManager.dtor = function ( self )
	
end

