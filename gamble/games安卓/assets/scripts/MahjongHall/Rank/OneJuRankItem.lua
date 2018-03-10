require("MahjongHall/Rank/RankUserInfo");
local rankListItem4 = require(ViewLuaPath.."rankListItem4");

OneJuRankItem = class(Node)

OneJuRankItem.ctor = function(self, data)
	if not data then
		return;
	end

	EventDispatcher.getInstance():register(NativeManager._Event, self, self.nativeCallEvent);

	self.listItem = SceneLoader.load(rankListItem4);
	self:addChild(self.listItem);
	self:setSize(self.listItem:getSize());

	self.data = data;
	local money = data.money or "0";
	local times = data.times;
	local rank = data.num;
	local nick = data.mnick or "";
	local sex = data.sex or 0;  
	local imageUrl = data.iconImg or "";  -- 头像地址
	self.iconUrl = imageUrl;
	local mid = data.mid or 0;
	self.rankRef = data.rankRef;


	--设置名次
	local img_place_path = "";
	local img_place_text = "";
	if tonumber(rank) <= 3 then
		img_place_path = string.format("rank/place_%s.png",rank);
	else
		img_place_path = "rank/place_other.png";
		img_place_text = rank;
	end
	publ_getItemFromTree(self.listItem, {"item_view","view_place","text_place"}):setText(img_place_text);
	local img_place = publ_getItemFromTree(self.listItem, {"item_view","view_place","img_place"});
	img_place:setFile(img_place_path);
	img_place:setSize(img_place.m_res.m_width, img_place.m_res.m_height);


	--设置头像
	local btn_photo = publ_getItemFromTree(self.listItem, {"item_view","btn_image"});
	local img_photo  = publ_getItemFromTree(self.listItem, {"item_view","btn_image","img_photo"});

	if tonumber(kSexMan) == tonumber(sex) then
		img_photo:setFile("Commonx/default_man.png");
		if PlatformConfig.platformYiXin == GameConstant.platformType then 
		    localDir = "Login/yx/Commonx/default_man.png";
		end
	else
		img_photo:setFile("Commonx/default_woman.png");
		if PlatformConfig.platformYiXin == GameConstant.platformType then 
		    localDir = "Login/yx/Commonx/default_woman.png";
		end
	end

	local isExist , imageDir = NativeManager.getInstance():downloadImage(imageUrl);

	self.localDir = imageDir or "";
	if isExist then -- 图片已下载
		img_photo:setFile(self.localDir);
	end

	--设置点击头像事件
	btn_photo:setOnClick(self, function(self)
		self:getUserInfo( mid );
	end);

	--设置昵称
	publ_getItemFromTree(self.listItem, {"item_view","text_name"}):setText(stringFormatWithString(nick,20,true));

	--设置金币
	publ_getItemFromTree(self.listItem, {"item_view","text_score"}):setText(trunNumberIntoThreeOneFormWithInt(money,false));

	--设置比赛场次
	publ_getItemFromTree(self.listItem, {"item_view","times"}):setText(times);
end

OneJuRankItem.getUserInfo = function( self, mid )
	Loading.showLoadingAnim("获取详细信息中");
	FriendDataManager.getInstance():QueryUserInfo(PHP_CMD_QUERY_USER_INFO_POP,{mid})
end

OneJuRankItem.dtor = function(self)
	EventDispatcher.getInstance():unregister(NativeManager._Event, self, self.nativeCallEvent);
	self:removeAllChildren();
end

OneJuRankItem.nativeCallEvent = function(self , _param , _detailData)
	if kDownloadImageOne == _param then
		if self.localDir == _detailData then
			publ_getItemFromTree(self.listItem, {"item_view","btn_image","img_photo"}):setFile(self.localDir);
		end
	end
end



