-- 任务界面
local friendMessage = require(ViewLuaPath.."friendMessage");
require("ui/listView")
require("MahjongHall/Friend/MailSysMessageItem")
require("MahjongHall/Friend/SystemMessageData")
require("MahjongHall/hall_2_interface_base")



MailWindow = class(hall_2_interface_base);

MailWindow.SystemTab =  1
MailWindow.FriendTab =  2


MailWindow.updateSystemListView   = EventDispatcher.getInstance():getUserEvent();

MailWindow.ctor = function ( self , delegate )
	self.delegate = delegate;
--	g_GameMonitor:addTblToUnderMemLeakMonitor("Mail",self)
    --设置基类的基础配置
    self:set_tag(GameConstant.view_tag.message);
    self:set_tab_title({"系统消息", "好友消息"});
    self:set_tab_count(2);

    delegate.m_mainView:addChild(self)
    self:play_anim_enter();
end

MailWindow.selectTab = function ( self, tabType )
	self.curSelectedTab = tabType
	self:updateNoDataLabel()

	if tabType == MailWindow.SystemTab then
		self.mSystemSelected:setVisible(true)
		self.mFriendSelected:setVisible(false)
		self.mFriendTab:setFile("Commonx/tab_right.png")
		self.mylistView:setVisible(false)
		self.mySyslistView:setVisible(true)
	else--好友
		self.mSystemSelected:setVisible(false)
		self.mFriendSelected:setVisible(true)
		self.mFriendTab:setFile("Commonx/tab_left.png")
		self.mylistView:setVisible(true)
		self.mySyslistView:setVisible(false)
	end
end

MailWindow.on_enter = function (self)


	self.mid = PlayerManager.getInstance():myself().mid;
	EventDispatcher.getInstance():register(MailWindow.updateSystemListView, self, self.reloadSystemView);
	--网络事件
	FriendDataManager.getInstance():addListener(self,self.onCallBackFunc);


	self.mainContent = SceneLoader.load(friendMessage);
	self.m_bg:addChild(self.mainContent);

	self.mSystemTab 	 = self.m_btn_tab[1];
	self.mSystemSelected = self.m_btn_tab[1].img;

	self.mFriendTab 	 = self.m_btn_tab[2];
	self.mFriendSelected = self.m_btn_tab[2].img;


	self.mylistView    = publ_getItemFromTree(self.mainContent, {"content","listview"});
	self.mySyslistView = publ_getItemFromTree(self.mainContent, {"content","listview_sys"});
	self.emptyTipText  = publ_getItemFromTree(self.mainContent, {"content","empty_tip_text"})

	self.headTipImg    = publ_getItemFromTree(self.mainContent, {"content","tip"})


	if PlatformConfig.platformWDJ == GameConstant.platformType or
	   PlatformConfig.platformWDJNet == GameConstant.platformType then
		self.mSystemSelected:setFile("Login/wdj/Hall/Commonx/tag_red.png");
		self.mFriendSelected:setFile("Login/wdj/Hall/Commonx/tag_red.png");
    end
    self.enterAnimIsDone = false;


    self:set_tab_callback(self,self.tab_click);

    DebugLog('Profile clicked mail stop:'..os.clock(),LTMap.Profile)

    self.enterAnimIsDone = true
	if self.needUpdateViewAfterAnimOver then
		self:updateFriendNewsView()
	end

    FriendDataManager.getInstance():requestFriendNews();
	self.systemData = GlobalDataManager.getInstance().systemData
	self:updateSystemNewsView()

	self:selectTab(self:getDefaultDisplayTab())
end

MailWindow.on_exit = function (self)

end

MailWindow.tab_click = function (self, index)
    --1:系统消息，2:好友消息

    if index == 1 then
        self:selectTab(self.SystemTab)
    elseif index == 2 then
        self:selectTab(self.mFriendTab)
    end
end



MailWindow.updateNoDataLabel = function ( self )
	if self.curSelectedTab == MailWindow.SystemTab then
		if self.systemData and #self.systemData > 0 then
			self.emptyTipText:setVisible(false)
		else
			self.emptyTipText:setVisible(true)
		end
	else
		local newCount = FriendDataManager.getInstance():getFriendNewsCount();
		self.emptyTipText:setVisible( newCount == 0 )
	end
end

MailWindow.updateSystemNewsView = function ( self )
	if GameConstant.iosDeviceType>0 and GameConstant.iosPingBiFee then
		self.mySyslistView:setAdapter(nil);
		return;
	end
	if self.systemData and #self.systemData > 0 and self.mySyslistView then
	    local adapter = new(CacheAdapter, MailSysMessageItem, self.systemData , self, self.deleteSystemMessageItem);
	    self.mySyslistView:setAdapter(adapter)
	else
		self.mySyslistView:setAdapter(nil)
	end
end

function MailWindow.reorderSystemData( self )
	if self.systemData then
		table.sort(self.systemData,function(a,b)
								if a.isRead and not b.isRead then
									return false
								elseif not a.isRead and b.isRead then
									return true
								else
									return a.start_time > b.start_time
								end
							  end)
	end
end

function MailWindow.reloadSystemView( self )
	self:reorderSystemData()
	self:updateSystemNewsView()
end

--默认首显项
MailWindow.getDefaultDisplayTab = function ( self )
	--有未读的系统消息
	if GlobalDataManager.getInstance():getUnReadSystemMessageNum() > 0 then
		return MailWindow.SystemTab
	end

	--有未读的好友消息
	if FriendDataManager.getInstance():getTipsCount() > 0 then
		return MailWindow.FriendTab
	end

	return MailWindow.SystemTab
end

MailWindow.deleteSystemMessageItem = function ( self, id )
	DebugLog("MailWindow.deleteSystemMessageItem:" .. tostring(id))
end
--创建好友动态视图
MailWindow.updateFriendNewsView = function ( self )
	-- body
	--清除历史数据
	self.mylistView:removeAllChildren()
	local newCount = FriendDataManager.getInstance():getFriendNewsCount();
	self.mNewsItem = {}
	if newCount > 0 then

		self.mylistView:setDirection(kVertical);
		self.mylistView:setScrollBarWidth(5);

		local friendNews = FriendDataManager.getInstance().m_FriendsNews;

		local w, h = self.mylistView:getSize();

		local maxNum = math.min(#friendNews,100)
		require("MahjongHall/Friend/FriendNewsListItem")
		for  i = 1, maxNum do

			local item = new(FriendNewsListItem, 1120, 110, self,i,friendNews[i]);
			item:setPos(19,(i - 1) * (110 + 15) );
			item:setOnClick(self.onClickNewsItem);
			self.mNewsItem[i] = item;
			self.mylistView:addChild(item);
		end
		self.mylistView:setSize( w, h);
	end
	self:updateNoDataLabel()

end

MailWindow.feedbackMoneySuccessfully = function ( self, isSuccess, index )
    local friendNews = FriendDataManager.getInstance().m_FriendsNews;
    if index and friendnews and friendnews[index] then
        FeedbackGoldData.deleteARecord(self.mid,friendNews[index].mid )
		self:removeItem( friendNews, index );
    end
end

MailWindow.getMoneySuccessfully = function ( self,isSuccess, index )
    local friendNews = FriendDataManager.getInstance().m_FriendsNews;
	if isSuccess and index and friendNews then
		showGoldDropAnimation()
		self.mNewsItem[index]:setFeedbackState(true)
		FeedbackGoldData.insertARecord(self.mid, friendNews[index])
	end
end
--点击 动态 标签 响应
MailWindow.onClickNewsItem = function ( self, index, whichBtn )

	local friendNews = FriendDataManager.getInstance().m_FriendsNews;

	local newType =  tonumber(friendNews[index].type);
	--处理
	if newType == 1 then -- 加好友
		if whichBtn == 1 then -- 同意
			--添加某人为好友
			FriendDataManager.getInstance():addFriendToServer(tonumber(friendNews[index].mid),friendNews[index].mnick,
																friendNews[index].mnick,PlayerManager.getInstance():myself().nickName,kNumZero);
		else 				  -- 忽略
			--do nothing
			FriendDataManager.getInstance():addFriendToServer(tonumber(friendNews[index].mid),friendNews[index].mnick,
																friendNews[index].mnick,PlayerManager.getInstance():myself().nickName,kNumMinusOne);
		end
	elseif newType == 2 then --收取金币
		--self.mNewsItem[index]
		if whichBtn == 2 then --2回赠
			FriendDataManager.getInstance():giveMoney(tostring(friendNews[index].mid),index);
			FriendDataManager.getInstance():setOnFeedbackMoneyListener( function( itemIndex, isSuccess )
				self:feedbackMoneySuccessfully(isSuccess,itemIndex)
			end);
		else                  --1收取
			FriendDataManager.getInstance():getMoney(tostring(friendNews[index].mid),tostring(friendNews[index].sendtime),index);
			FriendDataManager.getInstance():setOnGetMoneyListener( function( itemIndex, isSuccess )
				self:getMoneySuccessfully(isSuccess,itemIndex)
			end);
		end
	elseif newType == 3 then --查看
		--显示聊天框
		local name = FriendDataManager.getInstance():getFriendNameById( friendNews[index].mid );

		self.mChatWnd = new(ChatWindow, PlayerManager.getInstance():myself().mid, PlayerManager.getInstance():myself().sex, PlayerManager.getInstance():myself().small_image,
			friendNews[index].mid, name, friendNews[index].sex, friendNews[index].photo, function ( self )
		-- body
			if self.mChatWnd then
				self:removeChild(self.mChatWnd, true);
				self.mChatWnd = nil;
			end
		end, self);

		self:addChild(self.mChatWnd);

	end

	--删除标签
	if newType ~= 2 then
		self:removeItem( friendNews, index );
	end
end

MailWindow.removeItem = function( self, friendNews, index )
	self.mylistView:removeChild(self.mNewsItem[index], true);

	table.remove(friendNews, index);
	table.remove(self.mNewsItem, index);
	--reposition
	for i = 1, #self.mNewsItem do
		self.mNewsItem[i]:setIndex(i);
		self.mNewsItem[i]:setPos(31,(i - 1) * (110+15));
	end
	self.mylistView:setSize( self.mylistView:getSize());
	--没有数据
	if #self.mNewsItem == 0 then
		self.mylistView:removeAllChildren()
		self.emptyTipText:setVisible(true);
	end

	--保存数据
	FriendDataManager.getInstance():saveFriendNews(PlayerManager.getInstance():myself().mid);
	--更新气泡
	--FriendDataManager.getInstance():onListener(kFriendNewsNumRequestByPHP, FriendDataManager.getInstance():getFriendNewsCount());
    FriendDataManager.getInstance():requestFriendNews();
end



MailWindow.onCallBackFunc = function(self, actionType, actionParam)
	DebugLog("MailWindow.onCallBackFunc")
	--进入动画还未完成  需等动画完成后再刷新界面
	if not self.enterAnimIsDone then
		self.needUpdateViewAfterAnimOver = true
		return
	end

	if kFriendNewsRequestByPHP == actionType then
		self:updateFriendNewsView();
		Loading.hideLoadingAnim();

	elseif kFriendNewsNumRequestByPHP == actionType then --更新气泡
		--更新气泡
		--self:updateFriendNewsNum(actionParam);
		self:updateFriendNewsView();

	end

end


MailWindow.dtor = function ( self )
    self.super.dtor(self);

	self.systemData = nil
	
	FriendDataManager.getInstance():setOnGetMoneyListener(nil)
	FriendDataManager.getInstance():removeListener(self,self.onCallBackFunc);
	--EventDispatcher.getInstance():unregister(self.m_event,self,self.httpRequestsListenster);
	EventDispatcher.getInstance():unregister(MailWindow.updateSystemListView, self, self.reloadSystemView);
	self:removeAllChildren();
end
