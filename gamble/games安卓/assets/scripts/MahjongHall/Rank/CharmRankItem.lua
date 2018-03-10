require("MahjongHall/Rank/RankUserInfo");
local rankListItem4 = require(ViewLuaPath.."rankListItem4");
local VipIcon_map = require("qnPlist/VipIcon")

CharmRankListItem = class(Node)

CharmRankListItem.ctor = function(self, data)
	if not data then
		return;
	end
	EventDispatcher.getInstance():register(NativeManager._Event, self, self.nativeCallEvent);


	self.listItem = SceneLoader.load(rankListItem4);
	self:addChild(self.listItem);
	self:setSize(self.listItem:getSize());

	self.data = data;
	local rank = data.rank or 0;
	local nick = data.nick or "";
	local sex = tonumber(data.sex) or 0;  
	local imageUrl = data.big or "";  -- 头像地址
	self.iconUrl = imageUrl;
	local charmLevel = tonumber(data.charm_level) or 0;  --魅力等级
	local charm = data.meili_week or "0";  --当前获得魅力值
	local mid = data.mid or 0;
	self.rankRef = data.rankRef;

	--设置名次
	local img_place_path = "";
	local img_place_text = "";
	if tonumber(rank) <= 3 and tonumber(rank) > 0 then
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

	--设置当前获得魅力值
	publ_getItemFromTree(self.listItem, {"item_view","text_score"}):setText("本周获得魅力值"..charm);

	--设置魅力等级称号
	local img_charm_lv = publ_getItemFromTree(self.listItem, {"item_view","img_charm_lv"});
	if charmLevel then
		if charmLevel >= 7 and charmLevel <= 9 then
			if kSexMan == tonumber(sex) then
				img_charm_lv:setFile("Hall/hallRank/charm_level_"..charmLevel.."_0.png");
			else
				img_charm_lv:setFile("Hall/hallRank/charm_level_"..charmLevel.."_1.png");
			end
		else
			img_charm_lv:setFile("Hall/hallRank/charm_level_"..charmLevel..".png");
		end
	end
	local vipTag = self:getSelfVipImgTag(data.viplevel or 0)
	if vipTag then 
		self.listItem:addChild(vipTag)
	end 
end
function CharmRankListItem.getSelfVipImgTag( self,vip_level )

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
CharmRankListItem.getUserInfo = function( self, mid )
	Loading.showLoadingAnim("获取详细信息中");
	FriendDataManager.getInstance():QueryUserInfo(PHP_CMD_QUERY_USER_INFO_POP,{mid})
end

CharmRankListItem.dtor = function(self)
	EventDispatcher.getInstance():unregister(NativeManager._Event, self, self.nativeCallEvent);

	self:removeAllChildren();
end

CharmRankListItem.nativeCallEvent = function(self, _param, _detailData)
    if _param == kDownloadImageOne then
        if _detailData == self.localDir then
        	setMaskImg(publ_getItemFromTree(self.listItem, { "item_view", "btn_image", "img_photo" }),"Hall/hallRank/head_mask.png",self.localDir)
            --:setFile(self.localDir);
        end
    end
end



