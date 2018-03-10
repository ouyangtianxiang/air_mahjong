--[[
	className    	     :  RankUserInfo
	Description  	     :  排行榜内个人信息界面.
	last-modified-date   :  2014.02.20
	create-time 	   	 :  2014.02.19
	last-modified-author :  YifanHe
	create-author        :  YifanHe
]]
local userInfoWindow = require(ViewLuaPath.."userInfoWindow");
local hall_user_infoPin_map = require("qnPlist/hall_user_infoPin")
RankUserInfo = class(SCWindow);

--typeflag = nil  不显示下边三个按钮  排行榜弹出窗口
--typeflag = 1    世界聊天 弹出窗口
--typeflag = 2    好友弹窗  
RankUserInfo.ctor = function( self, data, node, iconUrl, myData, typeflag)
	--DebugLog("hahaahah")
	--mahjongPrint(data)
	--self.m_city = ""
	self.node = node;
	self.typeflag = typeflag;
	self.node:addChild(self);
	self:setLevel(50);
	--self.cover:setFile(CreatingViewUsingData.commonData.blankBg.fileName, CreatingViewUsingData.commonData.bg.x,CreatingViewUsingData.commonData.bg.y);
	EventDispatcher.getInstance():register(NativeManager._Event, self, self.nativeCallEvent);
	FriendDataManager.getInstance():addListener(self,self.onCallBackFunc);

	EventDispatcher.getInstance():register(SocketManager.s_phpMsg, self, self.onPhpMsgResponse);

	self.layout = SceneLoader.load(userInfoWindow);
	self:addChild(self.layout);
	self.layout:setVisible(true);
	
	self.bg = publ_getItemFromTree(self.layout, {"bg"});
	self:setWindowNode( self.bg );

	if self.typeflag then
		self:setCoverEnable( false );
	else
		self:setCoverEnable( true );
	end

	--获得节点信息
	self.headIcon     = publ_getItemFromTree(self.layout, {"bg","head","headImg"});
	self.idText       = publ_getItemFromTree(self.layout, {"bg","idText"});
	self.genderIcon   = publ_getItemFromTree(self.layout, {"bg","genderIcon"});
	self.nameText     = publ_getItemFromTree(self.layout, {"bg","nameText"});
	self.levelText    = publ_getItemFromTree(self.layout, {"bg","levelText"});
	self.moneyText    = publ_getItemFromTree(self.layout, {"bg","moneyText"});
	self.gameInfoText = publ_getItemFromTree(self.layout, {"bg","gameInfoText"});
	self.atBtn		  = publ_getItemFromTree(self.layout, {"bg","atBtn"});
	self.traceBtn 	  = publ_getItemFromTree(self.layout, {"bg","traceBtn"});
	self.delFriendBtn = publ_getItemFromTree(self.layout, {"bg","addFriendBtn"});
	self.vipImg       = publ_getItemFromTree(self.layout, {"bg","vipImg"});
	self.sexText      = publ_getItemFromTree(self.layout, {"bg","sexText"});
	self.favourText   = publ_getItemFromTree(self.layout, {"bg","favourCount"});
	self.charmText    = publ_getItemFromTree(self.layout, {"bg","charmValueBg", "charmValue"});
	self.charmLvImg   = publ_getItemFromTree(self.layout, {"bg","charmLvImg"});
	self.favourImg    = publ_getItemFromTree(self.layout, {"bg","favourBtn", "favour"});
	self.favourBtn    = publ_getItemFromTree(self.layout, {"bg","favourBtn"});
	self.favourStr    = publ_getItemFromTree(self.layout, {"bg","favourBtn", "text"});
	self.remarkBtn    = publ_getItemFromTree(self.layout, {"bg", "remarkBtn"})

	self.remarkBtn:setType(Button.Gray_Type)
	self.favourBtn:setType(Button.Gray_Type)

	local myData = data or myData
	
		self.m_alias        = myData.alias or "";
		self.m_mid 			= tonumber(myData.mid);
		self.m_nick 		= myData.mnick;
		self.m_sex 			= tonumber(myData.sex) or 0;
		self.m_money 		= tonumber(myData.money) or 0;
		self.m_level 		= tonumber(myData.level) or 0;
		self.m_wintimes 	= tonumber(myData.wintimes) or 0;
		self.m_losetimes 	= tonumber(myData.losetimes) or 0;
		self.m_drawtimes 	= tonumber(myData.drawtimes) or 0;
		self.m_vipLevel 	= tonumber(myData.vip_level) or 0;
		self.m_city         = myData.city or ""
		self.m_largeImageUrl= myData.large_image;

		self.favourText:setText(tostring(myData.likes));
		self.charmText:setText(tostring(myData.charms));

		self.charmLvImg:setFile("Hall/popinfo/charmLv" .. myData.charms_level .. ".png");
		if tonumber(myData.like_status) == 1 then
			self.favoured = true;
			self.favourImg:setFile("Hall/popinfo/zan2.png");
			self.favourStr:setText("已赞");
			self.favourBtn:setPickable(false);
		end
	local location = tostring(self.m_city)
	if location == "nil" or location == "" then 
		location = "未知"
	end 
	self.sexText:setText("地区:".. location)

	self.favourBtn:setOnClick(self , function( self )
		if not self.favoured then
			self:likeIt(self.m_mid or 0);
			self.favourBtn:setPickable(false);
		end
	end);

	--self.closeBtn:setOnClick(self,function(self)
    --	self:hideWnd();
    --end);
	
	local str = "@" .. stringFormatWithString(self.m_nick,6,true)
	if typeflag and typeflag == 1 then 
		publ_getItemFromTree(self.atBtn, {"Text2"}):setText(str)
	end 
	
	self.atBtn:setOnClick(self,function(self)
		self:hideWnd();
		local str = "@" .. self.m_nick;
		DebugLog(self.m_nick .. ";mid:" ..tostring(self.m_mid))
		--self.node.editText:openEditTextView(str);
		--self.node.cleanBtn:setVisible(true);
		self:hideWnd();
		local friends = FriendDataManager.getInstance().m_Friends;
		local name = friends[tostring(self.m_mid)].alias;
		
		if not name or string.len(name) <= 0 then
			name = friends[tostring(self.m_mid)].mnick;
		end
		local chatwnd = new(ChatWindow, PlayerManager.getInstance():myself().mid, PlayerManager.getInstance():myself().sex, PlayerManager.getInstance():myself().small_image, 
						self.m_mid, name, friends[tostring(self.m_mid)].sex, friends[tostring(self.m_mid)].small_image);
		self.node:addChild(chatwnd);
    end);

    self.traceBtn:setOnClick(self,function(self)
    	if MatchRoomScene_instance then
    		Banner.getInstance():showMsg("在比赛场无法使用追踪功能");
    		return;
    	end

    	if PlayerManager.getInstance():myself().isInGame then
    		Banner.getInstance():showMsg("请在游戏结束后再追踪！");
    	else
    		FriendDataManager.getInstance():trackFriendSocket(tonumber(PlayerManager:getInstance():myself().mid),tonumber(self.m_mid));
    		self:hideWnd()
    	end
    end);

    self.delFriendBtn:setOnClick(self,function(self)
		self:onClickDelFriendBtn(self.m_mid, self.m_nick, self.m_alias );
    end);

    self.remarkBtn:setOnClick(self,function ( self )
    	self:onClickRemarkBtn(self.m_mid,self.m_alias)
    end)


    if self.typeflag and tonumber(self.m_mid) ~= PlayerManager.getInstance():myself().mid then -- 好友 or 世界聊天彈窗
    	local hastheFriend = FriendDataManager.getInstance():hastheFriend(self.m_mid);
		
		if self.typeflag == 1 then --世界聊天
			self.atBtn:setVisible(false)
			self.traceBtn:setPos(120,330)
			self.delFriendBtn:setPos(355,330)

			if not hastheFriend then 
			    self.delFriendBtn:setOnClick(self,function(self)
					self:onClickAddFriendBtn(self.m_mid, self.m_nick, self.m_alias );
			    end);

			    self.delFriendBtn:setFile("Commonx/green_small_btn.png")
			    publ_getItemFromTree(self.delFriendBtn, {"Text4"}):setText("添加好友")
			end 

		else --好友 彈窗
			self.remarkBtn:setVisible(true)
		end 
		
	else
		self.atBtn:setVisible(false);
		self.traceBtn:setVisible(false);
		self.delFriendBtn:setVisible(false);
		self.bg:setSize(632, 350);
		self.bg:setFile("Commonx/userinfobg.png")

	end

	if PlatformConfig.platformWDJ == GameConstant.platformType or 
	   PlatformConfig.platformWDJNet == GameConstant.platformType then 
        self.bg:setFile("Login/wdj/Hall/popinfo/window_bg.png");
        self.remarkBtn:setFile("Login/wdj/Hall/popinfo/corner.png");
    end

	self:updateUserInfo();
	self:showWnd();
end

RankUserInfo.likeIt = function(self,likeId)
	
	local post_data 		= {};
	post_data.mid 			= PlayerManager:getInstance():myself().mid;
	post_data.fmid 			= likeId;
	
	SocketManager.getInstance():sendPack( PHP_CMD_LIKE_IT,post_data);
end

RankUserInfo.onFavourCallback = function ( self, isSuccess, data, jsonData)
	DebugLog("RankUserInfo.onFavourCallback")
	mahjongPrint(data)
	if not isSuccess or not data then
		self.favourBtn:setPickable(true);
		return;
	end


	DebugLog("self.m_mid:".. tostring(self.m_mid) .. ",fmid:"..data.data.fmid)
	if tonumber(data.status) == 1 and tonumber(self.m_mid) == tonumber(data.data.fmid) then
		DebugLog("11")
		self.favourImg:setFile("Hall/popinfo/zan2.png");
		self.favourStr:setText("已赞");

		self.favourText:setText(tonumber(self.favourText:getText()) + 1);
		self.charmText:setText(tonumber(self.charmText:getText()) + tonumber(data.data.charm));
		self.favoured = true;

		if HallScene_instance and HallScene_instance.m_socialLayer then 
			HallScene_instance.m_socialLayer:setFavouredStatus(self.m_mid)
		end 
	else
		Banner.getInstance():showMsg(data.msg);
		self.favourBtn:setPickable(true);
	end

end

RankUserInfo.hideHandle = function ( self )
	self:hide();
end

RankUserInfo.onCoverClick = function ( self )
	self:hideWnd();
end

RankUserInfo.onCallBackFunc = function (self, actionType, actionParam)
	DebugLog("RankUserInfo.onCallBackFunc   " .. actionType)
	if kFriendDeleteByPHP == actionType then --好友删除
		--删除标签
		--DebugLog("--------------------------------")
		--mahjongPrint(actionParam)
		if tostring(actionParam) == tostring(self.m_mid) then 
			Loading.hideLoadingAnim();
			self:hideWnd()	
		end 
	--elseif --修改备注
	end
end

RankUserInfo.dtor = function( self )
	EventDispatcher.getInstance():unregister(NativeManager._Event, self, self.nativeCallEvent);
	EventDispatcher.getInstance():unregister(SocketManager.s_phpMsg, self, self.onPhpMsgResponse);
	FriendDataManager.getInstance():removeListener(self, self.onCallBackFunc);
	delete(self.animIndex);
	self.animIndex = nil;
	self:removeAllChildren();
end

RankUserInfo.hide = function( self )
	EventDispatcher.getInstance():unregister(NativeManager._Event, self, self.nativeCallEvent);
	EventDispatcher.getInstance():unregister(SocketManager.s_phpMsg, self, self.onPhpMsgResponse);
	self.node:removeChild(self , true);
	if self.typeflag == 2 then --好友弹窗
		self.node.userInfoWindow = nil;
	end
end

RankUserInfo.updateUserInfo = function( self )

	local isExist , localDir = NativeManager.getInstance():downloadImage(self.m_largeImageUrl);
	self.localDir = localDir; -- 下载图片
	if not isExist then -- 图片已下载
		if self.m_sex == 0 then
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
    self.headIcon:setFile(localDir);
    
    --self.headMask = publ_getItemFromTree(self.layout, {"bg", "headImg", "mask"});
	--self.headIcon:setClipRes(self.headMask.m_res);

	--vip标识
	if self.m_vipLevel <= 0 then
		self.vipImg:setVisible(false);
	else
		local vipLevel = self.m_vipLevel
		if vipLevel >= 10 then 
			vipLevel = 10
		end 
		self.vipImg:setFile(hall_user_infoPin_map["VIP"..vipLevel..".png"]);
	end
	
	self.idText:setText( "ID:" .. tostring(self.m_mid) );

	local namestr = self.m_alias;
		
	if not namestr or string.len(namestr) <= 0 then
		namestr = self.m_nick;
	end

	self.nameText:setText(stringFormatWithString(namestr, CreatingViewUsingData.roomUserInfoView.nameText.limit));
	self.levelText:setText("等级:" .. self.m_level);
	self.moneyText:setText("金币:" .. trunNumberIntoThreeOneFormWithInt(self.m_money));
	
	local coord = CreatingViewUsingData.roomUserInfoView.coinText;
	coord = CreatingViewUsingData.roomUserInfoView.winLostText;

	local gameInfoStr = self.m_wintimes .. coord.win ..
					    self.m_losetimes .. coord.lost .. 
					    self.m_drawtimes .. coord.ping; 
	self.gameInfoText:setText("战绩:" .. stringFormatWithString(gameInfoStr,16,true)); 

    --设置性别图片放在名字后面
    --local namePosX, namePosY = self.nameText:getPos();
    --self.genderIcon:setPos(namePosX + self.nameText.m_res.m_width, namePosY);
	if self.m_sex == 0 then --man 
		--self.sexText:setText( "性别: 男")
		self.genderIcon:setFile("Commonx/male.png")
	else 
		--self.sexText:setText( "性别: 女")
		self.genderIcon:setFile("Commonx/female.png")
	end 
end

RankUserInfo.getDetailUserInfo = function (self, isSuccess, data, jsonData)
	if not isSuccess or not data then
		return;
	end
	if tonumber(data.status) == 1 then
		for k, v in pairs(data.data) do
			self.favourText:setText(v.likes or 0);
			self.charmText:setText(v.charms or 0);
			self.charmLvImg:setFile("Hall/popinfo/charmLv" .. v.charms_level .. ".png");
			if tonumber(v.like_status) == 1 then
				self.favoured = true;
				self.favourImg:setFile("Hall/popinfo/zan2.png");
				self.favourStr:setText("已赞");
			end 
		 end
	else
		Banner.getInstance():showMsg(data.msg);
	end
end

RankUserInfo.onClickDelFriendBtn = function(self, mid, mnick, alias )
	if mid == nil then 
		Banner.getInstance():showMsg("数据异常,mid为空,无法删除!")
		return 
	end 

	self.delFriendBtn:setPickable(false);
	self.delFriendBtn:setIsGray(true);
	FriendDataManager.getInstance():deleteFriendSocket(mid, mnick);
	Loading.showLoadingAnim("正在删除好友...");
	--Banner.getInstance():showMsg(PromptMessage.sendMessageSuccess);
end

RankUserInfo.onClickAddFriendBtn = function ( self, mid, mnick, alias )
	self.delFriendBtn:setPickable(false);
	self.delFriendBtn:setIsGray(true);
	FriendDataManager.getInstance():addFriendSocket(mid, mnick, alias );
	Banner.getInstance():showMsg(PromptMessage.sendMessageSuccess);
end

RankUserInfo.onClickRemarkBtn = function ( self,friendId,alias )
	-- body
	if self.mRemarkWnd then
		return;
	end
	require("MahjongHall/Friend/FriendRemarkWindow")
	self.mRemarkWnd = new(FriendRemarkWindow, alias);
	self:addChild(self.mRemarkWnd);

	self.mRemarkWnd:setOnConfirm(function ( self, text )
		local name = text;		
		if not name or string.len(name) <= 0 then
			Banner.getInstance():showMsg("昵称不能为空!")
			return
		end 

		-- body
		FriendDataManager.getInstance():requestModifyFriendAlias(self.m_mid, text)
		self:removeChild(self.mRemarkWnd, true);
		self.mRemarkWnd = nil;

		--更新右侧
		--昵称

		if not name or string.len(name) <= 0 then
			name = self.m_nick;
		end

		self.nameText:setText(stringFormatWithString(name, 22, true));

	end,self);

	self.mRemarkWnd:setOnClose(function ( self )
		-- body
		self:removeChild(self.mRemarkWnd, true);
		self.mRemarkWnd = nil;
	end,self);
end

RankUserInfo.nativeCallEvent = function(self, _param, _detailData)
    if _param == kDownloadImageOne then
        if _detailData == self.localDir then
            self.headIcon:setFile(self.localDir);
        end
    end
end




RankUserInfo.onPhpMsgResponse = function ( self, param, cmd, isSuccess,... )
	if self.httpRequestsCallBackFuncMap[cmd] then 
		self.httpRequestsCallBackFuncMap[cmd](self,isSuccess,param,...)
	end
end

RankUserInfo.httpRequestsCallBackFuncMap =
{
	[PHP_CMD_LIKE_IT]           =  RankUserInfo.onFavourCallback,
};
