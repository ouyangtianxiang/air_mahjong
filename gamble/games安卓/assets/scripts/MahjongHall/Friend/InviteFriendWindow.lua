--[[
	className    	     :  InviteFriendWindow
	Description  	     :  To wrap the view of the inviting Friend.
	last-modified-date   :  Dec. 6 2013
	create-time 	   	 :  Oct.31 2013
	last-modified-author :  ClarkWu
	create-author        :　ClarkWu
]]
require("MahjongHall/Friend/InviteFriendItem");

InviteFriendWindow = class(SCWindow);

--[[
	function name	   : InviteFriendWindow.ctor
	description  	   : Construct a class.
	param 	 	 	   : self
	last-modified-date : Dec. 6 2013
	create-time  	   : Oct.31 2013
]]
InviteFriendWindow.ctor = function (self,roomlevel)
	local roomData = RoomData.getInstance();
	
	self.roomlevel = roomlevel or 0
	self.player = PlayerManager:getInstance():myself();
	
	--self.cover:setFile(CreatingViewUsingData.commonData.blankBg.fileName);

	self.bg = UICreator.createImg("Commonx/pop_window_mid.png", 0, 0);
	self.bg:setEventTouch(self, function(self)  end);
	self.bg:setAlign(kAlignCenter);
	self:addChild(self.bg);

	self:setWindowNode( self.bg );
	self:setCoverEnable( true );-- 允许点击cover


	self.bgTitleText = UICreator.createText("邀请好友", 0, 30, 160, 40, kAlignCenter, 40, 0xff, 0xff, 0xff);
	self.bgTitleText:setAlign(kAlignTop);
    self.bgTitleText:setPos(0,25);
	self.bg:addChild(self.bgTitleText);

	--self.onlineFriendView = self:createNoOnLineFriends();
	--self.bg:addChild(self.onlineFriendView);
	--self.onlineFriendView:setAlign(kAlignCenter);
	--self.onlineFriendView:setPos(31,85)

	self.cover:setEventTouch(self , function (self)
		self:hideWnd();
	end);
	self:setCoverTransparent()
	--查询好友是否在线
	
	self:setOnWindowShowListener(nil,function (  )
		FriendDataManager.getInstance():addListener(self,self.onCallBackFunc);
		FriendDataManager.getInstance():requestAllFriends(); 
	end)
	

	if PlatformConfig.platformWDJ == GameConstant.platformType or 
		PlatformConfig.platformWDJNet == GameConstant.platformType then 
		self.bg:setFile("Login/wdj/Hall/Commonx/pop_window_mid.png");
	end
end


-- 隐藏窗口
function InviteFriendWindow.hideWnd( self, notHideAnim )
	FriendDataManager.getInstance():removeListener(self, self.onCallBackFunc);

	self.super.hideWnd(self, notHideAnim)
end
--[[
	function name	   : InviteFriendWindow.hide
	description  	   : To Destruct a class.
	param 	 	 	   : self
	last-modified-date : Dec. 6 2013
	create-time  	   : Oct.31 2013
]]
-- InviteFriendWindow.hide = function(self)
-- 	delete(self);
-- end


InviteFriendWindow.showRecommondList = function ( self, list )
	if not list or  #list <= 0 then 
		return 
	end 
		if not self.myInViteFriendsAdapter then
			self.bg:removeChild(self.onlineFriendView,true);
			self.onlineFriendView = nil;
			self.onlineFriendView = self:createOnLineFriends(list,330);
			self.onlineFriendView:setPos(31,185)
			--self.onlineFriendView:setAlign(kAlignCenter);
			self.bg:addChild(self.onlineFriendView);
		else
			local data = {};
			for i = 1 , #list do 
				data[i] = {};
				data[i].btnId 		= i;
				data[i].mid   	  = list[i].mid;
				if list[i].alias and string.len(list[i].alias) > 0 then
					data[i].name 	  = list[i].alias;
				else
					data[i].name 	  = list[i].mnick;
				end
				data[i].money 	  = list[i].money;
				data[i].sex       = list[i].sex;
				data[i].smallImg  = list[i].small_image;
				data[i].bigImg    = list[i].small_image;
				data[i].vip_level = list[i].vip_level
				data[i].inviteRef = self;
			end
			self.myInViteFriendsAdapter:changeData(data);
		end
end

--[[
	function name	   : InviteFriendWindow.dtor
	description  	   : Destruct a class.
	param 	 	 	   : self
	last-modified-date : Dec. 6 2013
	create-time  	   : Oct.31 2013
]]
InviteFriendWindow.dtor = function ( self )
	self:removeAllChildren();
	FriendDataManager.getInstance():removeListener(self, self.onCallBackFunc);
	--GameConstant.m_inviteRoomWindow = nil;
end

----------------------------------------------------------回调函数-------------------------------------------------------------------------------------------------
--[[
	function name	   : InviteFriendWindow.onCallBackFunc
	description  	   : PHP或者socket请求返回.根据行为指令调用不同方法.
	param 	 	 	   : self
						 actionType  -- 行为指令
	last-modified-date : Dec. 6 2013
	create-time  	   : Dec. 6 2013
]]
InviteFriendWindow.onCallBackFunc = function(self,actionType,actionParam)
	if kFriendRequestByPHP == actionType then
		FriendDataManager.getInstance():requestFriendsIsOnlineSocket();
	elseif kFriendAllOnlineFriendsBySocket == actionType then 
		self:onRequestInvitingFriends();
	elseif kFriendSearchByPHP == actionType then --查找ID
		self:showRecommondList(actionParam);
	end
end

--[[
	function name	   : InviteFriendWindow.onRequestInvitingFriends
	description  	   : 邀请好友请求返回.
	param 	 	 	   : self
	last-modified-date : Dec. 6 2013
	create-time  	   : Dec. 6 2013
]]
InviteFriendWindow.onRequestInvitingFriends = function(self)

	local onlineFriend = {};

	if FriendDataManager.getInstance().m_Friends then

		for k, v in pairs(FriendDataManager.getInstance().m_Friends) do
			if v.online == true then -- 如果在线
				local isInTable = false;
				local playerInTable = PlayerManager.getInstance().playerList;
				for k1, v1 in pairs(playerInTable) do 
					if tonumber(v.mid) == tonumber(v1.mid) then
						isInTable = true;
						break;
					end
				end
				if not isInTable then
					onlineFriend[#onlineFriend + 1] = v;
				end
			end
		end

	end

	if #onlineFriend == kNumZero then 
		self.bg:removeChild(self.noFriendNode,true);
		self.noFriendNode = nil;
		self.noFriendNode = self:createNoOnLineFriends();
		self.noFriendNode:setAlign(kAlignCenter);
		self.bg:addChild(self.noFriendNode);
		FriendDataManager.getInstance():requestRecommondPlayer(self.roomlevel)
	else
		for i = 1 , #onlineFriend do
			for j = i + 1 , #onlineFriend do
				if tonumber(onlineFriend[i].money) < tonumber(onlineFriend[j].money) then
					local temp = onlineFriend[i];
					onlineFriend[i] = onlineFriend[j];
					onlineFriend[j] = temp;
				end
			end
		end
	
		if not self.myInViteFriendsAdapter then
			self.bg:removeChild(self.onlineFriendView,true);
			self.onlineFriendView = nil;
			self.onlineFriendView = self:createOnLineFriends(onlineFriend);
			self.onlineFriendView:setPos(31,85)
			--self.onlineFriendView:setAlign(kAlignCenter);
			self.bg:addChild(self.onlineFriendView);
		else
			local data = {};
			for i = 1 , #onlineFriend do 
				data[i] = {};
				data[i].btnId 		= i;
				data[i].mid   	  = onlineFriend[i].mid;
				if onlineFriend[i].alias and string.len(onlineFriend[i].alias) > 0 then
					data[i].name 	  = onlineFriend[i].alias;
				else
					data[i].name 	  = onlineFriend[i].mnick;
				end
				data[i].money 	  = onlineFriend[i].money;
				data[i].sex       = onlineFriend[i].sex;
				data[i].smallImg  = onlineFriend[i].small_image;
				data[i].bigImg    = onlineFriend[i].small_image;
				data[i].vip_level = onlineFriend[i].vip_level
				data[i].inviteRef = self;
			end
			self.myInViteFriendsAdapter:changeData(data);
		end
	end
end

------------------------------------------------------------------------界面相关-----------------------------------------------------------------------------------

--[[
	function name	   : InviteFriendWindow.createNoOnLineFriends
	description  	   : 创建没有在线好友界面.
	param 	 	 	   : self
	last-modified-date : Dec. 6 2013
	create-time  	   : Dec. 6 2013
]]
InviteFriendWindow.createNoOnLineFriends = function(self)
	local noFriendNode = new(Node);
	noFriendNode:setSize(800, 430);
	local coord = CreatingViewUsingData.inviteFriendView.noInvitedFriend;
	local m_noFriendText = UICreator.createText(coord.str,0,0,coord.w,coord.h,coord.align,30,coord.r,coord.g,coord.b);
	m_noFriendText:setAlign(kAlignCenter);
	--noFriendNode:addChild(m_noFriendText);
	local tipBg = UICreator.createImg( "Commonx/inviteTipBg.png", 0, 60 ,30, 30, 20, 20)
	tipBg:setAlign(kAlignTop)
	tipBg:setSize(760,54)
	noFriendNode:addChild(tipBg)

	tipBg:addChild(m_noFriendText)

	----recommond list

	return noFriendNode;
end

--[[
	function name	   : InviteFriendWindow.createOnLineFriends
	description  	   : 创建在线好友界面.{{mid="",name="",money="",sex="",smallImg="",bigImg="",isOnline=}}
	param 	 	 	   : self
	last-modified-date : Dec. 6 2013
	create-time  	   : Dec. 6 2013
]]
InviteFriendWindow.createOnLineFriends = function(self, onlineFriend,height)
	local onLineFriendNode = new(Node);
	onLineFriendNode:setSize(800, height or 430);
     
	local data = {};
	
	for i=1,#onlineFriend do 
		data[i] = {};
		data[i].btnId 		= i;
		data[i].mid   	  = onlineFriend[i].mid;
		if onlineFriend[i].alias and string.len(onlineFriend[i].alias) > 0 then
			data[i].name 	  = onlineFriend[i].alias;
		else
			data[i].name 	  = onlineFriend[i].mnick;
		end
		data[i].money 	  = onlineFriend[i].money;
		data[i].sex       = onlineFriend[i].sex;
		data[i].smallImg  = onlineFriend[i].small_image;
		data[i].bigImg    = onlineFriend[i].small_image;
		data[i].vip_level = onlineFriend[i].vip_level or 0
		data[i].inviteRef = self;
	end

	self.myInViteFriendsAdapter = new(CacheAdapter, InviteFriendItem, data);
	local coord = CreatingViewUsingData.inviteFriendView.inviteListView;
	self.inviteListView = new(ListView,0,0,800,height or 430);
	self.inviteListView:setAlign(kAlignCenter);
	self.inviteListView:setAdapter(self.myInViteFriendsAdapter);
	self.inviteListView:setScrollBarWidth(coord.scrollBarWidth);
	self.inviteListView:setMaxClickOffset(coord.maxClickOffset);
	onLineFriendNode:addChild(self.inviteListView);
	return onLineFriendNode;
end


InviteFriendWindow.updateFriend = function ( self )
	-- body
	self:onRequestInvitingFriends();
end

