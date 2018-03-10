require("MahjongHall/Rank/RankUserInfo");
local rankListItem2 = require(ViewLuaPath.."rankListItem2");
local VipIcon_map = require("qnPlist/VipIcon")

PaiJuRankListItem = class(Node)

PaiJuRankListItem.ctor = function(self, data)
	if not data then
		return;
	end
	DebugLog("PaiJuRankListItem.ctor")
	EventDispatcher.getInstance():register(NativeManager._Event, self, self.nativeCallEvent);

	self.listItem = SceneLoader.load(rankListItem2);
	self:addChild(self.listItem);
	self:setSize(self.listItem:getSize());

	self.data = data;
	local rank = data.rank
	local nick = data.nick or "";
	local sex = data.sex or 0;  
	local imageUrl = data.big or "";  -- 头像地址
	self.iconUrl = imageUrl;
	local nameStr = data.title or "";  --用户称号
	local money = data.money or "0";
	local mid = data.mid or 0;
	self.rankRef = data.rankRef;

	--设置名次
	local img_place_path = "";
	local img_place_text = "";
	if tonumber(rank) <= 3 then
		img_place_path = string.format("Hall/hallRank/place_%s.png",rank);
	else
		img_place_path = "Hall/hallRank/place_other.png";
		img_place_text = rank;
	end
	publ_getItemFromTree(self.listItem, {"item_view","view_place","text_place"}):setText(img_place_text);
	local img_place = publ_getItemFromTree(self.listItem, {"item_view","view_place","img_place"});
	img_place:setFile(img_place_path);
	img_place:setSize(img_place.m_res.m_width, img_place.m_res.m_height);


	--设置头像
	local btn_photo = publ_getItemFromTree(self.listItem, {"item_view","btn_image"});
	local img_photo  = publ_getItemFromTree(self.listItem, {"item_view","btn_image","img_photo"});

    local isExist , localDir = NativeManager.getInstance():downloadImage(imageUrl);
	self.localDir = localDir; -- 下载图片
    if not isExist then
        if tonumber(kSexMan) == tonumber(sex) then
            localDir = "Commonx/default_man.png";
            if PlatformConfig.platformYiXin == GameConstant.platformType then 
			    localDir = "Login/yx/Commonx/default_man.png";
			end
	    else
            localDir = "Commonx/default_woman.png";
            if PlatformConfig.platformYiXin == GameConstant.platformType then 
			    localDir = "Login/yx/Commonx/default_woman.png";
			end
	    end
    end

    setMaskImg(img_photo,"Hall/hallRank/head_mask.png",localDir)
	--img_photo:setFile(localDir);

	--设置点击头像事件
	 btn_photo:setOnClick(self, function(self)
		self:getUserInfo( mid );
	end);

	  --设置昵称
	 publ_getItemFromTree(self.listItem, {"item_view","text_name"}):setText(stringFormatWithString(nick,GameConstant.rankListItemNameLimit,true));

	 --设置金币
	 publ_getItemFromTree(self.listItem, {"item_view","text_score"}):setText(trunNumberIntoThreeOneFormWithInt(money,false) .. "金币");

	 --设置财富等级
	 local img_wealth_lv = publ_getItemFromTree(self.listItem, {"item_view","img_wealth_lv"});
	 img_wealth_lv:setFile("Hall/hallRank/wealth_level_" .. nameStr .. ".png");

	local vipTag = self:getSelfVipImgTag(data.viplevel or 0)
	if vipTag then 
		self.listItem:addChild(vipTag)
	end 	 
end
function PaiJuRankListItem.getSelfVipImgTag( self,vip_level )

    if vip_level and vip_level > 0 then 
        if vip_level > 10 then 
            vip_level = 10
        end 
        local m_vipImg = UICreator.createImg(VipIcon_map["V"..vip_level..".png"])
        m_vipImg:setPos(175,15)
        return m_vipImg
    end 
    return nil
end
PaiJuRankListItem.getUserInfo = function( self, mid )
	Loading.showLoadingAnim("获取详细信息中");
	FriendDataManager.getInstance():QueryUserInfo(PHP_CMD_QUERY_USER_INFO_POP,{mid})
end

PaiJuRankListItem.getNameImgPath = function( self, str )
	-- 8;//"神马都是浮云";   7;//"富可敌国";   6;//"富甲天下";
	-- 5;//"千万富翁";   4;//"百万富翁";   3;//"家财万贯";
	-- 2;//"略有钱财";   1;//"一贫如洗";
	str = str or 1;
	local pathStr = "newHall/rank/name" .. str .. ".png";
	return pathStr;
end

PaiJuRankListItem.dtor = function(self)
	EventDispatcher.getInstance():unregister(NativeManager._Event, self, self.nativeCallEvent);
	self:removeAllChildren();
end

PaiJuRankListItem.nativeCallEvent = function(self, _param, _detailData)
    if _param == kDownloadImageOne then
        if _detailData == self.localDir then
        	setMaskImg(publ_getItemFromTree(self.listItem, { "item_view", "btn_image", "img_photo" }),"Hall/hallRank/head_mask.png",self.localDir)
        end
    end
end



