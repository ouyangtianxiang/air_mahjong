require("MahjongHall/Rank/RankUserInfo");
local rankListItem2 = require(ViewLuaPath.."rankListItem2");
local VipIcon_map = require("qnPlist/VipIcon")

exchange_rank_item = class(Node)

exchange_rank_item.ctor = function(self, data)
	if not data then
		return;
	end
	DebugLog("exchange_rank_item.ctor")
	EventDispatcher.getInstance():register(NativeManager._Event, self, self.nativeCallEvent);

	self.listItem = SceneLoader.load(rankListItem2);
	self:addChild(self.listItem);
	self:setSize(self.listItem:getSize());

	self.data = data;
    local is_me = data.is_me or false;
	local rank = tonumber(data.rank) or -1
	local nick = data.nick or "";
	local sex = data.sex or 0;  
	local imageUrl = data.head_url or "";  -- 头像地址
	self.iconUrl = imageUrl;
	--local nameStr = data.title or "";  --用户称号
	local exchange_num = data.exchange_num or "0";
	local mid = data.mid or 0;
	--self.rankRef = data.rankRef;

    local item_view = publ_getItemFromTree(self.listItem, {"item_view"});
	--设置名次
	local img_place_path = "";
	local img_place_text = "";
    if rank > 0 then  --0 or - 1
        img_place_path = rank <= 3 and string.format("Hall/hallRank/place_%s.png",rank) or "Hall/hallRank/place_other.png"
        img_place_text = rank 
        local t = publ_getItemFromTree(self.listItem, {"item_view","view_place","text_place"})
        t:setText(img_place_text);
        t:setLevel(1);
	    local img_place = publ_getItemFromTree(self.listItem, {"item_view","view_place","img_place"});
	    img_place:setFile(img_place_path);
	    img_place:setSize(img_place.m_res.m_width, img_place.m_res.m_height);
        img_place:setLevel(2);
    end
--	if tonumber(rank) <= 3 then
--		img_place_path = string.format("Hall/hallRank/place_%s.png",rank);
--	else
--		img_place_path = "Hall/hallRank/place_other.png";
--		img_place_text = rank;
--	end
    



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
    DebugLog("isExist:"..tostring(isExist).." localDir:" ..tostring(localDir).." imageUrl:"..tostring(imageUrl));
	--img_photo:setFile(localDir);

	--设置点击头像事件
	 btn_photo:setOnClick(self, function(self)
		self:getUserInfo( mid );
	end);

	  --设置昵称
	 local t_nick = publ_getItemFromTree(self.listItem, {"item_view","text_name"});
     t_nick:setText(stringFormatWithString(nick,GameConstant.rankListItemNameLimit,true));

	 --
	 publ_getItemFromTree(self.listItem, {"item_view","text_score"}):setVisible(false);--setText(trunNumberIntoThreeOneFormWithInt(money,false) .. "金币");
     publ_getItemFromTree(self.listItem, {"item_view","img_coin_icon"}):setVisible(false);
      
	 --设置财富等级
	 local img_wealth_lv = publ_getItemFromTree(self.listItem, {"item_view","img_wealth_lv"});
	 img_wealth_lv:setVisible(false)--setFile("Hall/hallRank/wealth_level_" .. nameStr .. ".png");

	local vipTag = self:getSelfVipImgTag(data.viplevel or 0)
	if vipTag then 
		self.listItem:addChild(vipTag)
	end 
    
    --设置兑换数量
    local str = "已兑换: "..tostring(exchange_num).."话费券";  
    local t_exchange = new(Text, str, 0, 0, kAlignLeft, "", 30, 0x94, 0x32, 0x00);
    t_exchange:setAlign(kAlignLeft);
    t_exchange:setPos(is_me and 650 or 570, -4);
    item_view:addChild(t_exchange);

    self.m_bg = publ_getItemFromTree(self.listItem, {"item_view","img_line"});
    self.m_bg:setVisible(not is_me); 
    
    if is_me then
        t_nick:setColor(0xff,0xff,0xff);
        t_exchange:setColor(255,220,0);
    end     	 
end

--设置背景隐藏
exchange_rank_item.set_bg_disaplay = function (self, v)
    v = v==true and true or false
    self.m_bg:setVisible(v);
end

function exchange_rank_item.getSelfVipImgTag( self,vip_level )

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
exchange_rank_item.getUserInfo = function( self, mid )
	Loading.showLoadingAnim("获取详细信息中");
	FriendDataManager.getInstance():QueryUserInfo(PHP_CMD_QUERY_USER_INFO_POP,{mid})
end

--exchange_rank_item.getNameImgPath = function( self, str )
--	-- 8;//"神马都是浮云";   7;//"富可敌国";   6;//"富甲天下";
--	-- 5;//"千万富翁";   4;//"百万富翁";   3;//"家财万贯";
--	-- 2;//"略有钱财";   1;//"一贫如洗";
--	str = str or 1;
--	local pathStr = "newHall/rank/name" .. str .. ".png";
--	return pathStr;
--end

exchange_rank_item.dtor = function(self)
	EventDispatcher.getInstance():unregister(NativeManager._Event, self, self.nativeCallEvent);
	self:removeAllChildren();
end

exchange_rank_item.nativeCallEvent = function(self, _param, _detailData)
    DebugLog("[exchange_rank_item]nativeCallEvent");
    if _param == kDownloadImageOne then
        DebugLog("self.localDir:"..tostring(self.localDir).."_detailData: "..tostring(_detailData));
        if _detailData == self.localDir  then
        	setMaskImg(publ_getItemFromTree(self.listItem, { "item_view", "btn_image", "img_photo" }),"Hall/hallRank/head_mask.png",self.localDir)
        end
    end
end



