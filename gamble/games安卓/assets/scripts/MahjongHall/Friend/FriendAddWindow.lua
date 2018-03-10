local friendAddWindow = require(ViewLuaPath.."friendAddWindow");
require("MahjongHall/Friend/FriendDataManager")

FriendAddWindow = class(SCWindow);


FriendAddWindow.ctor = function ( self)
	
	self.layout = SceneLoader.load(friendAddWindow);
	self:addChild(self.layout);

	self:getAllControls()

	self:setWindowNode( self.bg );

	self.cover:setEventTouch(self , function (self)
	end);
  	
	local myself = PlayerManager.getInstance():myself();
	self.myIdText:setText( tostring(myself.mid) )

	self.searchIdEdit:setHintText("请输入搜索的游戏ID");
--	self.chatEdit:setScrollBarWidth(0);

    self.closeBtn:setOnClick(self,function(self)
   		self:hideWnd();
   	end);

   	if PlatformConfig.platformWDJ == GameConstant.platformType or
   	   PlatformConfig.platformWDJNet == GameConstant.platformType then 
		self.closeBtn:setFile("Login/wdj/Hall/Commonx/close_btn.png");
		self.closeBtn.disableFile = "Login/wdj/Hall/Commonx/close_btn_disable.png";
		self.bg:setFile("Login/wdj/Hall/Commonx/pop_window_mid.png");
	end

    DebugLog("self.searchBtn:setOnClick")
   	self.searchBtn:setOnClick(self, function ( self )
   		DebugLog("FriendAddWindow.onClickSearch ")
		-- body
		local TextId= self.searchIdEdit:getText();
		local numId	= tonumber(TextId);
		if numId then
			Loading.showLoadingAnim("正在查找ID...");
			--
			FriendDataManager.getInstance():QueryUserInfo(PHP_CMD_QUERY_USER_INFO,{numId})
			--FriendDataManager.getInstance():searchFriendById({numId});
		else
			Banner.getInstance():showMsg("输入错误，请输入正确的数字ID");
		end
   	end)
   	self.favourBtn:setType(Button.Gray_Type)
   	self.favourBtn:setOnClick(self,self.onclickFavour)
   	self.addFriendBtn:setOnClick(self,self.onclickAddFriend)

   	self.myselfView:setVisible(true)
   	self.friendView:setVisible(false)

   	--监听下载
	EventDispatcher.getInstance():register(NativeManager._Event, self, self.nativeCallEvent);
	--监听好友信息
	FriendDataManager.getInstance():addListener(self,self.onCallBackFunc);
    --监听http请求
	EventDispatcher.getInstance():register(SocketManager.s_phpMsg, self, self.onPhpMsgResponse);



	local isExist,localDir = NativeManager.getInstance():downloadImage( myself.small_image );
	self.m_myIconDir = localDir;

	if not isExist then
		if tonumber(myself.sex) == 0 then
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
	self.myHeadImg:setFile( localDir );


	--self:showWnd();
end


FriendAddWindow.onPhpMsgResponse = function ( self, param, cmd, isSuccess,... )
	if self.httpRequestsCallBackFuncMap[cmd] then 
		self.httpRequestsCallBackFuncMap[cmd](self,isSuccess,param,...)
	end
end

FriendAddWindow.dtor = function( self )
	DebugLog("FriendAddWindow.dtor")
	EventDispatcher.getInstance():unregister(NativeManager._Event, self, self.nativeCallEvent);
	EventDispatcher.getInstance():unregister(SocketManager.s_phpMsg, self, self.onPhpMsgResponse);
	FriendDataManager.getInstance():removeListener(self, self.onCallBackFunc);
	self:removeAllChildren();
end

FriendAddWindow.getAllControls = function ( self )
	self.bg = publ_getItemFromTree(self.layout, {"bg"});
	self.closeBtn   = publ_getItemFromTree(self.layout, {"bg", "top","closeBtn"});

	self.myselfView   = publ_getItemFromTree(self.layout, {"bg", "View2", "View3"})
	self.friendView = publ_getItemFromTree(self.layout, {"bg", "View2", "View5"})

	self.searchIdEdit   = publ_getItemFromTree(self.layout, {"bg", "View1","edit_bg", "EditTextView1"});
	self.searchBtn      = publ_getItemFromTree(self.layout, {"bg", "View1","search_btn"});
	
	----个人信息
	self.myHeadImg      = publ_getItemFromTree(self.myselfView, {"Image1"})
	self.myIdText		= publ_getItemFromTree(self.myselfView, {"View4", "Text3"})

	----好友信息
	self.friendNoView     = publ_getItemFromTree(self.friendView, {"noResultView"})
	self.friendDetailView = publ_getItemFromTree(self.friendView, {"friendInfoView"})

	self.friendImg        = publ_getItemFromTree(self.friendDetailView, {"head", "headImg"})
	self.favourCountText  = publ_getItemFromTree(self.friendDetailView, {"head", "favourBg" , "favourCount"}) 
	self.favourBtn        = publ_getItemFromTree(self.friendDetailView, {"head", "favourBtn"}) 
	self.favourImg        = publ_getItemFromTree(self.friendDetailView, {"head", "favourBtn", "favour"})
	self.favourStr        = publ_getItemFromTree(self.friendDetailView, {"head", "favourBtn", "Text6"})
	self.vipImg           = publ_getItemFromTree(self.friendDetailView, {"head", "vipImg"})

	self.friendNameText   		= publ_getItemFromTree(self.friendDetailView, {"rightInfo", "nameText"})
	self.friendIDText   	  	= publ_getItemFromTree(self.friendDetailView, {"rightInfo", "idText"})
	self.friendSexText 		    = publ_getItemFromTree(self.friendDetailView, {"rightInfo", "sexText"})
	self.friendLevelText  	    = publ_getItemFromTree(self.friendDetailView, {"rightInfo", "levelText"})
	self.friendMoneyText 	    = publ_getItemFromTree(self.friendDetailView, {"rightInfo", "moneyText"})
	self.friendGameinfoText     = publ_getItemFromTree(self.friendDetailView, {"rightInfo", "gameInfoText"})
	self.friendCharmValueText   = publ_getItemFromTree(self.friendDetailView, {"rightInfo", "charmValueBg", "charmValue"})
	
	self.friendCharmLevelImg    = publ_getItemFromTree(self.friendDetailView, {"rightInfo", "charmLvImg"})
	self.friendSexImg     		= publ_getItemFromTree(self.friendDetailView, {"rightInfo", "genderIcon"})

	self.addFriendBtn           = publ_getItemFromTree(self.friendDetailView, {"rightInfo", "addFriendBtn"})


	self.noResultText     = publ_getItemFromTree(self.friendNoView, {"Text5"})

end
FriendAddWindow.onclickFavour= function( self )
	-- body
	if not self.favoured then
		self.favourBtn:setPickable(false)
		self:likeIt(self.m_fid or 0);
	end
end

FriendAddWindow.likeIt = function(self,likeId)
	
	local post_data 		= {};
	post_data.mid 			= PlayerManager:getInstance():myself().mid;
	post_data.fmid 			= likeId;
	
	SocketManager.getInstance():sendPack( PHP_CMD_LIKE_IT,post_data);
end

FriendAddWindow.showSearchResultView = function ( self, actionParam )
	local searchId = tonumber(self.searchIdEdit:getText())
	
	if actionParam and #actionParam > 0 then 
		actionParam = actionParam[1]
	end 
	
	local queryResult = actionParam;
	
	if searchId and queryResult and tonumber(queryResult.mid) == searchId then
			--找到
		self.myselfView:setVisible(false)
		self.friendView:setVisible(true)
		self.friendNoView:setVisible(false)
		self.friendDetailView:setVisible(true)
		--设置内容

		local name = FriendDataManager.getInstance():getFriendNameById(queryResult.mid);
		self.friendNameText:setText( stringFormatWithString(name or queryResult.mnick, 22, true) )
		self.friendMoneyText:setText( "金币:" .. trunNumberIntoThreeOneFormWithInt(queryResult.money) )

		--添加好友
		--是否已是对方好友
		if  name then
			self.addFriendBtn:setGray(true)
			self.addFriendBtn:setPickable(false);
		else
			self.addFriendBtn:setGray(false)
			self.addFriendBtn:setPickable(true);
			
			self.addFriendBtn:setOnClick(self, function ( self )
				-- body
				if FriendDataManager.getInstance():hastheFriend(searchId) then			
					Banner.getInstance():showMsg("对方已是您的好友");
				else
					FriendDataManager.getInstance():addFriendSocket(queryResult.mid,queryResult.mnick,queryResult.alias );
					Banner.getInstance():showMsg("好友请求已发送");
				end
				self.addFriendBtn:setGray(true)
				self.addFriendBtn:setPickable(false);
			end);
		end 
		
		local isExist,localDir = NativeManager.getInstance():downloadImage( actionParam.large_image );
		self.m_friendIconDir = localDir;
		DebugLog("searchIconImg , 被搜索人的图片"..self.m_friendIconDir  );
		if not isExist then
			if tonumber(queryResult.sex) == 0 then
				localDir = "Commonx/default_man.png";
			else
				localDir = "Commonx/default_woman.png";
			end
		end
		self.friendImg:setFile( localDir );
		self.m_fid = queryResult.mid
		self.friendIDText:setText("ID:" .. tostring(queryResult.mid) )
		local coord = CreatingViewUsingData.roomUserInfoView.winLostText;
		local gameInfoStr = tostring(queryResult.wintimes) .. coord.win ..
					    	tostring(queryResult.losetimes) .. coord.lost .. 
					    	tostring(queryResult.drawtimes) .. coord.ping
		self.friendGameinfoText:setText("战绩:" .. stringFormatWithString(gameInfoStr,16,true)); 		

		if tonumber(queryResult.sex) == 0 then --man 
			self.friendSexText:setText( "性别: 男")
			self.friendSexImg:setFile("Commonx/male.png")
		else 
			self.friendSexText:setText( "性别: 女")
			self.friendSexImg:setFile("Commonx/female.png")
		end 	

		self.friendLevelText:setText("等级:" .. tostring(queryResult.level));		
		self.favourCountText:setText(tostring(queryResult.likes))

		if tonumber(queryResult.like_status) == 0 then
			self.favourImg:setFile("Hall/popinfo/zan1.png");
			self.favourStr:setText("赞");
			self.favourBtn:setPickable(true)
			self.favoured = false
		else 
			self.favourImg:setFile("Hall/popinfo/zan2.png");
			self.favourStr:setText("已赞");
			self.favourBtn:setPickable(false)
			self.favoured = true
		end 

		self.friendCharmValueText:setText( tostring(queryResult.charms) );
		
		local charmlevel = tonumber(queryResult.charms_level) or 0 
		if charmlevel < 0  then 
			charmlevel = 0
		elseif charmlevel > 7 then 
			charmlevel = 7
		end 

		self.friendCharmLevelImg:setFile("Hall/popinfo/charmLv" .. tostring(charmlevel) .. ".png");		
	else
			--没有找到
		self.myselfView:setVisible(false)
		self.friendView:setVisible(true)
		self.friendNoView:setVisible(true)
		self.friendDetailView:setVisible(false)
		self.noResultText:setText("没有找到ID为:" .. self.searchIdEdit:getText() .. " 的玩家")
	end

	--关闭等待界面
	Loading.hideLoadingAnim();
end


--点击 搜索 事件
FriendAddWindow.onClickSearch = function (self )
	DebugLog("FriendAddWindow.onClickSearch ")
	-- body
	local TextId= self.searchIdEdit:getText();
	local numId	= tonumber(TextId);
	if numId then
		Loading.showLoadingAnim("正在查找ID...");
		FriendDataManager.getInstance():QueryUserInfo(PHP_CMD_QUERY_USER_INFO,{numId})
		--FriendDataManager.getInstance():searchFriendById({numId});
	else
		Banner.getInstance():showMsg("输入错误，请输入正确的数字ID");
	end
end

FriendAddWindow.onFavourCallback = function ( self, isSuccess, data, jsonData)
	DebugLog("FriendAddWindow.onFavourCallback")
	mahjongPrint(data)
	if not isSuccess or not data then
		self.favourBtn:setPickable(true);
		return;
	end
	if tonumber(data.status) == 1 and tonumber(self.m_fid) == tonumber(data.data.fmid) then
		self.favourImg:setFile("Hall/popinfo/zan2.png");
		self.favourStr:setText("已赞");

		local count = self.favourCountText:getText() or 0
		self.favourCountText:setText(tostring(count + 1))

		self.friendCharmValueText:setText(tonumber(self.friendCharmValueText:getText()) + tonumber(data.data.charm));
		self.favoured = true;

	else
		Banner.getInstance():showMsg(data.msg);
		self.favourBtn:setPickable(true);
	end

end

FriendAddWindow.onCallBackFunc = function(self, actionType, actionParam)
	DebugLog("FriendAddWindow onCallBackFunc actionType : "..actionType);
	if kFriendSearchByPHP == actionType then --查找ID
		self:showSearchResultView(actionParam);
	end 
end 

FriendAddWindow.nativeCallEvent = function(self, _param, _detailData)
    if _param == kDownloadImageOne then
        if _detailData == self.m_myIconDir then
            self.myHeadImg:setFile(self.m_myIconDir);
        elseif _detailData == self.m_friendIconDir then 
        	self.friendImg:setFile(self.m_friendIconDir);
        end
    end
end

FriendAddWindow.httpRequestsCallBackFuncMap =
{
	[PHP_CMD_LIKE_IT]           =  FriendAddWindow.onFavourCallback,
};
