require("MahjongHall/Rank/RankUserInfo");
local friendListItem = require(ViewLuaPath.."friendListItem");
local VipIcon_map = require("qnPlist/VipIcon")

HallCharmRankItem = class(Node)

HallCharmRankItem.ctor = function(self, data)
	if not data then
		return;
	end
	--mahjongPrint(data)
	--DebugLog("HallCharmRankItem.ctor")
	--mahjongPrint(data)

	EventDispatcher.getInstance():register(NativeManager._Event, self, self.nativeCallEvent);


	self.listItem = SceneLoader.load(friendListItem);
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
	self.mid = mid 
	--self.rankRef = delegate;
	self.favoured = false
	if tonumber(data.like_status) == 1 then
		self.favoured = true;
	end

	self:getContrls()

	self.m_head:addPropScaleSolid(0,0.9,0.9,kCenterDrawing)-- = function(self, sequence, scaleX, scaleY, center, x, y)
	--设置名次
	self:setName( nick )
	self:setCharmValue( "魅力值"..charm )
	--设置头像
	self:setHeadIcon(data.icon,sex)
--
	if data.rindex and type(data.rindex) == "number" then
		if data.rindex > 0 and data.rindex < 4 then 
			self.m_crownImg:setVisible(true)
			self.m_crownImg:setFile("Hall/HallSocial/crown".. tostring(data.rindex) .. ".png")
		end 
	end 
	local vipTag = self:getSelfVipImgTag(data.viplevel or 0)
	if vipTag then 
		self.listItem:addChild(vipTag)
	end 

	--设置点击头像事件
	 self.m_bgBtn:setOnClick(self, function(self)
	 	self:getUserInfo( mid );
	end);

end
function HallCharmRankItem.getSelfVipImgTag( self,vip_level )

    if vip_level and vip_level > 0 then 
        if vip_level > 10 then 
            vip_level = 10
        end 
        local m_vipImg = UICreator.createImg(VipIcon_map["V"..vip_level..".png"])
        m_vipImg:setPos(65,15)
        return m_vipImg
    end 
    return nil
end
HallCharmRankItem.setName = function ( self, name )
	self.m_nameText:setText( stringFormatWithString(name,10,true) )
end

HallCharmRankItem.setCharmValue = function ( self, charmValue )
	self.m_moneyText:setText( charmValue )
end

HallCharmRankItem.setHeadIcon = function ( self, url,sex )
    local isExist, localDir = NativeManager.getInstance():downloadImage(url);
	self.localDir = localDir;
    ---setMaskImg( img_node , mask_file_path, img_file_path  )
    if not isExist then -- 图片已下载
    	if tonumber(sex) == 0 then
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
    setMaskImg(self.m_headImg,"Hall/hallRank/head_mask.png",localDir)
    
    --self.m_headImg:setFile(localDir);
end
HallCharmRankItem.setFavauredState = function ( self )
	self.m_sendBtn:setPickable(false);
	self.m_sendBtn:setGray(true)

	self.data.likeIt = true
end

HallCharmRankItem.onZanClick = function ( self )
	--[[
	if not self.favoured then

		if self.data then
			self.data.like_status = 1;
			self.data.likes  = tonumber(myData.likes) + 1;
			self.data.charms = tonumber(myData.charms) + 1;
		end

		FriendDataManager.getInstance():likeIt(self.m_mid or 0);
		self.favourImg:setFile("Hall/popinfo/zan2.png");
		self.favourStr:setText("已赞");
		if myData then
			self.favourText:setText(tostring(myData.likes));
			self.charmText:setText(tostring(myData.charms));
		else
			self.favourText:setText(tonumber(self.favourText:getText()) + 1);
			self.charmText:setText(tonumber(self.charmText:getText()) + 1);
		end
			
		self.favourBtn:setPickable(false);
		self.favoured = true;
	end]]--

	FriendDataManager.getInstance():likeIt(self.mid or 0);
	self:setFavauredState()

end

HallCharmRankItem.setFreeIcon = function ( self, status)
	-- body
	if status ~= 0 then
		self.m_sendBtn:setPickable(false);
	end
end

HallCharmRankItem.getUserInfo = function( self, mid )
	Loading.showLoadingAnim("获取详细信息中");
	FriendDataManager.getInstance():QueryUserInfo(PHP_CMD_QUERY_USER_INFO_POP,{mid})

end

HallCharmRankItem.dtor = function(self)
	DebugLog("HallCharmRankItem.dtor ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
	EventDispatcher.getInstance():unregister(NativeManager._Event, self, self.nativeCallEvent);
	self:removeAllChildren();
end

HallCharmRankItem.nativeCallEvent = function(self, _param, _detailData)
    if _param == kDownloadImageOne then
        if _detailData == self.localDir then
        	setMaskImg(self.m_headImg,"Hall/hallRank/head_mask.png",self.localDir)
            --self.m_headImg:setFile(self.localDir);
        end
    end
end



HallCharmRankItem.getContrls = function ( self )
	self.m_bgBtn 	 = publ_getItemFromTree(self.listItem, {"bg_btn"})
	self.m_head      = publ_getItemFromTree(self.listItem, {"bg_btn","bg"})
	self.m_headImg   = publ_getItemFromTree(self.listItem, {"bg_btn","bg","head_img"})
	
	self.m_crownImg  = publ_getItemFromTree(self.listItem, {"bg_btn","bg","crown_img"})
	self.m_nameText  = publ_getItemFromTree(self.listItem, {"bg_btn","name_text"})
	self.m_moneyText = publ_getItemFromTree(self.listItem, {"bg_btn","money_text"})
	self.m_sendBtn   = publ_getItemFromTree(self.listItem, {"bg_btn","send_btn"})

	self.m_sendBtn:setFile("Hall/HallSocial/heart.png")
	self.m_sendBtn:setOnClick(self,self.onZanClick)
	self.m_bgBtn:setType(Button.White_Type)
	if self.data.likeIt == 1 then 
		self.m_sendBtn:setGray(true)
		self.m_sendBtn:setPickable(false)
	end 
end