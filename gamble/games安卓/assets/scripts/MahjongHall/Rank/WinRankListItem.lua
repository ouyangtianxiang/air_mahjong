local rankListItem1 = require(ViewLuaPath.."rankListItem1");
local VipIcon_map = require("qnPlist/VipIcon")

WinRankListItem = class(Node)

WinRankListItem.ctor = function(self, data)
	if not data then
		return;
	end
	DebugLog("WinRankListItem.ctor")
	 EventDispatcher.getInstance():register(NativeManager._Event, self, self.nativeCallEvent);

	self.listItem = SceneLoader.load(rankListItem1);
	self:addChild(self.listItem);
	self:setSize(self.listItem:getSize());

	self.data = data;

	local rank = data.rank
	local nick = data.nick or "";
	local sex = data.sex or 0;  
	local imageUrl = data.big or "";  -- 头像地址
	self.iconUrl = imageUrl;
	local winmoney = data.winmoney or 0;  --赢钱数
	local wintimes = data.wintimes or "0";
	local losetimes = data.losetimes or "0";
	local drawtimes = data.drawtimes or "0";
	local level = data.level or "";
	local mid = tonumber(data.mid) or 0;
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
		DebugLog(img_place_path)
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
	--img_photo:setFile(localDir);
	setMaskImg(img_photo,"Hall/hallRank/head_mask.png",localDir)
	--设置点击头像事件
	 btn_photo:setOnClick(self, function(self)
	 	self:getUserInfo( mid );
	end);

	 --设置昵称
	 publ_getItemFromTree(self.listItem, {"item_view","text_name"}):setText(stringFormatWithString(nick,GameConstant.rankListItemNameLimit,true));

	 --设置胜负信息
	 local score_info = wintimes .. "胜 " .. losetimes .. "负 " .. drawtimes .. "平";
	 publ_getItemFromTree(self.listItem, {"item_view","text_score"}):setText(score_info);

	 --设置等级
	 publ_getItemFromTree(self.listItem, {"item_view","text_lv"}):setText("Lv."..level);
	local vipTag = self:getSelfVipImgTag(data.viplevel or 0)
	if vipTag then 
		self.listItem:addChild(vipTag)
	end 
end
function WinRankListItem.getSelfVipImgTag( self,vip_level )

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
WinRankListItem.getUserInfo = function( self, mid )
	Loading.showLoadingAnim("获取详细信息中");
	FriendDataManager.getInstance():QueryUserInfo(PHP_CMD_QUERY_USER_INFO_POP,{mid})
end

WinRankListItem.dtor = function(self)
	EventDispatcher.getInstance():unregister(NativeManager._Event, self, self.nativeCallEvent);
	self:removeAllChildren();
end

WinRankListItem.nativeCallEvent = function(self, _param, _detailData)
    if _param == kDownloadImageOne then
        if _detailData == self.localDir then
        	setMaskImg(publ_getItemFromTree(self.listItem, { "item_view", "btn_image", "img_photo" }),"Hall/hallRank/head_mask.png",self.localDir)
            --publ_getItemFromTree(self.listItem, { "item_view", "btn_image", "img_photo" }):setFile(self.localDir);
        end
    end
end


