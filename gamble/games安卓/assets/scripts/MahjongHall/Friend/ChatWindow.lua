-- heartBeat.lua
-- Author: YifanHe
-- Date: 2014-07-09
-- Last modification : 2014-07-09
-- Description: Chat window for friend subsystem.
local chatWindow = require(ViewLuaPath.."chatWindow");
require("MahjongHall/Friend/CustomScrollView")
require("MahjongHall/Friend/FriendChatItem")


ChatWindow = class(SCWindow);

--static member
ChatWindow.gFriendID = "";
--static method
ChatWindow.getFriendId = function ( )
	return ChatWindow.gFriendID;
end

ChatWindow.ctor = function ( self, mid, sex, headIconUrl, friendId, name, fsex, fheadIconUrl, closeListener, param)
	DebugLog("+++++++++++addListener")
	FriendDataManager.getInstance():addListener(self,self.onCallBackFunc);
	ChatWindow.gFriendID = tostring(friendId);
	self:setLevel(10000);
	self.layout = SceneLoader.load(chatWindow);
	self:addChild(self.layout);

	self.bg = publ_getItemFromTree(self.layout, {"bg"});
	self:setWindowNode( self.bg );

	self.mCloseListener = closeListener;
	self.mParam 		= param;

	self.cover:setEventTouch(self , function (self)
	end);
  	
	self.closeBtn   = publ_getItemFromTree(self.layout, {"bg", "closeBtn"});
	self.title      = publ_getItemFromTree(self.layout, {"bg", "title"});  --Need to show user name.
	self.chatEdit   = publ_getItemFromTree(self.layout, {"bg", "chatEditBg", "edit"});
	self.sendBtn    = publ_getItemFromTree(self.layout, {"bg", "send"});

	if PlatformConfig.platformWDJ == GameConstant.platformType or 
	   PlatformConfig.platformWDJNet == GameConstant.platformType then 
		self.closeBtn:setFile("Login/wdj/Hall/Commonx/close_btn.png");
		self.closeBtn.disableFile = "Login/wdj/Hall/Commonx/close_btn_disable.png";
		self.bg:setFile("Login/wdj/Hall/chat/bg.png");
	end


	self.chatEdit:setHintText("输入聊天消息");
	self.chatEdit:setScrollBarWidth(0);

    self.closeBtn:setOnClick(self,function(self)
    	
 --  		if 	self.mCloseListener then
   			-- popWindowUp(self, self.hideHandle, self.bg);
   			self:hideWnd();
--		end
   	end);

   	self.sendBtn:setOnClick(self, chatWindow.onclickSend);

   	self.title:setText(name);

   	self.mid 	 			= mid;
   	self.mSex 				= sex;
   	self.mHeadIconUrl		= headIconUrl--publ_downloadImg(headIconUrl) ;
   	self.mFriendId 			= friendId;
   	self.mFriendSex 		= fsex;
   	self.mFriendHeadIconUrl = fheadIconUrl--publ_downloadImg(fheadIconUrl);

    --创建聊天滚动视图 (UI)
   	local chatListNode = publ_getItemFromTree(self.layout, {"bg", "chat_content"});
	self.mChatScrollViewW, self.mChatScrollViewH = chatListNode:getSize();
	self.mChatScrollView = new(CustomScrollView, 0, 0, self.mChatScrollViewW, self.mChatScrollViewH, false);
	self.mChatScrollView:setDirection(kVertical);
	self.mChatScrollView:setScrollBarWidth(5);
	chatListNode:addChild(self.mChatScrollView);
	self.mChatScrollView:setSize(self.mChatScrollView:getSize());

	self.mChatScrollView:setLoadingVisible(false, false);

	self.mChatScrollView:setLoadingEvent(self, function ( self, isHead)
		if isHead then
			self.mChatScrollView:hideLoading(true);
			local message = FriendMessageManager.getInstance():loadMessageFromHistoryNewVersion(self.mid, self.mFriendId, self.mItemCount, 10);
			if #message > 0 then
				--加载历史数据
				--for i=1,#message do
				--	self:insertMsg(message[i], 1);
				--end
				self:loadMultiMsgs(message)
				self:slipToAppropriatePosWhenLoading();
			else
			end
		end
	end);

	self.mItemPosMap = {}; -- 标签位置映射

	self.mItemCount  = 0;  -- 标签数量(除提示标签外)

	--删除一些过期的数据
	FriendMessageManager.getInstance():deleteOutDateHistoryNewVersion(self.mid, self.mFriendId);

	--先加载一些
	local message = FriendMessageManager.getInstance():loadMessageFromHistoryNewVersion(self.mid, self.mFriendId, self.mItemCount, 10);
	--加载历史数据
	self:loadMultiMsgs(message)
	--for i=1,#message do
	--	self:insertMsg(message[i], 1);
	--end

	--聊天记录保存七天
	--local message  	= {};
	--message.tip   	= true;
	--message.speakID = 0;
	--message.state	= 1;
	--message.chat 	= "聊天记录保存七天";

	--self:insertMsg(message, 1);
	--self.mSaveTipsShow = true;

	self:slipToEnd();--移到下面

	self.mCurtime = GameConstant.chatTime or 0;
	self.mSendId = {};
	--添加定时器
	self.anim = self:addPropRotate(10,kAnimRepeat,1000,0,0,0,kCenterDrawing);
	self.anim:setEvent(self, self.onTimer);

	self:createOperatorMenu();
	self:showWnd();
end

ChatWindow.loadMultiMsgs = function ( self, message )
--[[
	if #message <= 0 then 
		return 
	end 

	--去掉尾部时间  无效
	while(#message > 0 and message[#message].isTime)
	do 
		table.remove(message)
	end 

	local startIndex = 1
	local timeMesIndexs = {}
	for i = 1,#message do 
		if message[i].isTime then 
			table.insert(timeMesIndexs,i)
		end 
	end 

	table.insert(timeMesIndexs,#message+1)
	for i = #timeMesIndexs,2,-1 do 
		message[timeMesIndexs[i] ] = message[timeMesIndexs[i-1] ]
		startIndex = 2
	end 
]]--
	for i=1,#message do
		self:insertMsg(message[i],1)
	end
    --modify by NoahHan 最后一个item如果是时间 则不显示；
    if self.mItemPosMap and #self.mItemPosMap > 0 then
        local lastItem = self.mItemPosMap[#self.mItemPosMap].item;
        if lastItem  and lastItem.typeItem ==  FriendChatItem.K_TIME then
            lastItem:setVisible(false);
        end
    end
end

ChatWindow.createOperatorMenu = function ( self )
	local chatListNode = publ_getItemFromTree(self.layout, {"bg", "chat_content"});
	--UICreator.createTextBtn = function ( imgDir, x, y, str, fontSize, r, g, b)
	--UICreator.createText = function ( str, x, y, width,height, align ,fontSize, r, g, b )
	--UICreator.createImg = function ( imgDIr, x, y ,leftWidth, rightWidth, topWidth, bottomWidth)
	self.cancelBtn = UICreator.createText("取消",0,-60,100,60,kAlignCenter,26, 0x2a, 0xa0, 0x00)
	self.cancelBtn:setEventTouch(self,self.onClickCancel);
	chatListNode:addChild(self.cancelBtn)

	self.title = UICreator.createText("聊天记录保存14天",310,-60,100,60,kAlignCenter,26, 0x4b, 0x2b, 0x1c)
	chatListNode:addChild(self.title)	

	self.selectAllText = UICreator.createText("全选",600,-60,100,60,kAlignCenter,26, 0x2a, 0xa0, 0x00)
	chatListNode:addChild(self.selectAllText)

	self.selectAllImg  = UICreator.createImg("Hall/chat/unselect.png",690,-49);
	self.selectAllImg:setEventTouch(self,self.onClickSelect)
	chatListNode:addChild(self.selectAllImg)

	self.editImg  = UICreator.createImg("Hall/chat/trash_unselect.png",760,-49);
	self.editImg:setEventTouch(self,self.onClickEdit)
	chatListNode:addChild(self.editImg)
	self.isEditState = true;

	self:setEditState(false)
end
ChatWindow.setEditState = function ( self, bValue )
	if self.isEditState == bValue then 
		return 
	end 
	self.isEditState = bValue
	self.cancelBtn:setVisible(bValue)
	self.title:setVisible(bValue)
	self.selectAllText:setVisible(bValue)
	self.selectAllImg:setVisible(bValue)
	self:setAllItemEditState(bValue)	
	if bValue then 
		self.editImg:setFile("Hall/chat/trash_select.png")
	else 
		self.editImg:setFile("Hall/chat/trash_unselect.png")
	end 
end


ChatWindow.setAllItemEditState = function ( self, bValue )
	for i = 1, #self.mItemPosMap do
		self.mItemPosMap[i].item:setEditState(bValue);
	end
end

ChatWindow.setAllItemSelect = function ( self, bValue )
	for i = 1, #self.mItemPosMap do
		self.mItemPosMap[i].item:setSelectedState(bValue);
	end
end

ChatWindow.onClickEdit = function (self, finger_action, x, y, drawing_id_first, drawing_id_current)
	if finger_action == kFingerUp then
		if self.isEditState then --删除选择节点
			self:removeSelectedChatMessage() 
		end
        self.isSelectedAll = false;
        self.selectAllImg:setFile("Hall/chat/unselect.png"); 
        self:setAllItemSelect(false)
		self:setEditState(not self.isEditState)
	end 
end

ChatWindow.removeSelectedChatMessage = function ( self )
	--remove item
	local idList = {}--self.mId

	local index = 1
	while(#self.mItemPosMap > 0  and  index <= #self.mItemPosMap)
	do 
		if self.mItemPosMap[index].item.isSelected then 
			table.insert(idList,self.mItemPosMap[index].item.mId)
			
			self.mChatScrollView:removeChild(self.mItemPosMap[index].item, true);
			table.remove(self.mItemPosMap, index);
		else 
			index = index + 1
		end 
	end 

	--删除无效时间项
	local hasData = false -- 
	for i = #self.mItemPosMap, 1, -1 do 
		if self.mItemPosMap[i].item.typeItem == FriendChatItem.K_TIME then 
			if hasData then --跳过
				hasData = false
			else --该时间下 0条消息   可以删除该时间
				table.insert(idList,self.mItemPosMap[i].item.mId)
				
				self.mChatScrollView:removeChild(self.mItemPosMap[i].item, true);
				table.remove(self.mItemPosMap, i);	
			end
		else
			hasData = true;
		end 
	end 

	if #idList <= 0 then 
		return 
	end 

	--重置UI坐标
	local y = 0;
	for i = 1, #self.mItemPosMap do
		self.mItemPosMap[i].item:setPos(0, y);
		local _, itemH = self.mItemPosMap[i].item:getSize();
		y = y + itemH;
		if self.mItemPosMap[i].item.itemType == FriendChatItem.K_MINE_CHAT or 
			self.mItemPosMap[i].item.itemType == FriendChatItem.K_FRIEND_CHAT then 
		end 
	end
	self.mItemCount = #self.mItemPosMap
	--remove history
	FriendMessageManager.getInstance():deleteHistoryForIds(self.mid, self.mFriendId,idList)

	self.mChatScrollView:update();
end
ChatWindow.onClickSelect = function (self, finger_action, x, y, drawing_id_first, drawing_id_current)
	if finger_action == kFingerUp then
		if self.isSelectedAll then 
			self.isSelectedAll = false;
			self.selectAllImg:setFile("Hall/chat/unselect.png");
		else 
			self.isSelectedAll = true;
			self.selectAllImg:setFile("Hall/chat/select.png");
		end 
		self:setAllItemSelect(self.isSelectedAll)
	end 
end
ChatWindow.onClickCancel = function (self, finger_action, x, y, drawing_id_first, drawing_id_current)
	if finger_action == kFingerUp then
		self.isSelectedAll = false;
        self:setAllItemSelect(false)
		self.selectAllImg:setFile("Hall/chat/unselect.png");
		self:setEditState(false);
	end 
end

ChatWindow.dtor = function ( self )
	ChatWindow.gFriendID = "";
	DebugLog("------------removeListener")
	FriendDataManager.getInstance():removeListener(self, self.onCallBackFunc);
	self:removeAllChildren();
	--保存聊天记录
	DebugLog("ChatWindow.dtor")
end

ChatWindow.removeMsg = function ( self, pos)
	local pos 	= pos and pos or #self.mItemPosMap + 1;
	self.mChatScrollView:removeChild(self.mItemPosMap[pos].item, true);

	table.remove(self.mItemPosMap, pos);

	local y = 0;
	for i = 1, #self.mItemPosMap do
		self.mItemPosMap[i].item:setPos(0, y);
		local _, itemH = self.mItemPosMap[i].item:getSize();
		y = y + itemH;
	end

	self.mChatScrollView:update();
end


--添加 聊天内容
ChatWindow.insertMsg = function ( self, message, pos)
	DebugLog("ChatWindow.insertMsg")
	mahjongPrint(message)
	-- body
	local pos 	= pos and pos or #self.mItemPosMap + 1;

	local itemType 		= FriendChatItem.K_TIME;
	local sex 			= nil;
	local headIconDir 	= nil;
	--日期 或 tips
	if tonumber(message.speakID) == 0 then
		if message.tip  then -- tips
			itemType = FriendChatItem.K_TIPS;
		else -- 日期
			itemType = FriendChatItem.K_TIME;
		end
	else -- 对话
		if tonumber(message.speakID) == tonumber(self.mFriendId) then 		--小伙伴说的话
			itemType 	= FriendChatItem.K_FRIEND_CHAT;
			sex 	 	= self.mFriendSex;
			headIconDir = self.mFriendHeadIconUrl;
		else											--自己说的话
			itemType = FriendChatItem.K_MINE_CHAT;
			sex 	 	= self.mSex;
			headIconDir = self.mHeadIconUrl;
		end
	end

	local item = new (FriendChatItem, self.mChatScrollViewW , message.id, message.chat, itemType, sex, headIconDir);
	item:setState(message.state);
    item:setVisible(true);
	if message.state == -1 then
		item:setOnClick(self, self.onReSend);
	end
	self.mChatScrollView:addChild(item);
	local itemInfor = {};
	itemInfor.id 	= message.id;
	itemInfor.item 	= item;
	table.insert(self.mItemPosMap, pos, itemInfor);

	--reposition
	local y = 0;
	for i = 1, #self.mItemPosMap do
		self.mItemPosMap[i].item:setPos(0, y);
		local _, itemH = self.mItemPosMap[i].item:getSize();
		y = y + itemH;
	end

	self.mItemCount = #self.mItemPosMap
	self.mChatScrollView:update();
end

ChatWindow.slipToEnd = function ( self )
	-- body
	self.mChatScrollView:setScollOffset(self.mChatScrollView:getFrameLength() - self.mChatScrollView:getViewLength());
end


ChatWindow.slipToAppropriatePosWhenLoading = function( self )
end

--发送消息
chatWindow.onclickSend = function ( self )
	-- body
	local text = publ_trim(self.chatEdit:getText());
	--如果是空字符串
	if not text or getStringLen(text) <= 0 then
		return;
	end

	if getStringLen(text) > 100 then
		Banner.getInstance():showMsg("当前内容已超出100字上限，请删减后再发送");
		return;
	end

	local curTime = os.time();
	if curTime - self.mCurtime > 60 * 3 then -- 若超出3分钟
		local message  = {};

		message.id 		= FriendMessageManager.getInstance():getUniqueId();
		message.speakID = 0;
		message.state	= 1;
		message.chat 	= getDateStringFromTime(curTime);
		message.isTime  = true;

		self:insertMsg(message);

		FriendMessageManager.getInstance():saveAMessageToFileNewVersion(self.mid, self.mFriendId, message);

		GameConstant.chatTime = curTime
		self.mCurtime 		  = curTime;
	end

	local message  = {};
	message.speakID = self.mid;
	message.id  	= FriendMessageManager.getInstance():getUniqueId();
	message.state	= 0;
	message.chat 	= text;

	self:insertMsg(message);
	self:slipToEnd();

	FriendDataManager.getInstance():sendMsgToFriendBySocket(self.mFriendId, message.id , message.chat);

	message.state	= -1; -- 使之处于失败状态
	
	FriendMessageManager.getInstance():saveAMessageToFileNewVersion(self.mid, self.mFriendId, message);

    self.chatEdit:setText("");
	self.chatEdit:setHintText("输入聊天消息，不超过100字");
    

    local state = {};
    state.time 	= curTime;
    state.id 	= message.id;
    self.mSendId[#self.mSendId + 1] = state;
end

ChatWindow.onRecvMsg = function ( self,  message)
	
	-- body
	--如果是空消息
	if not message or tonumber(message.speakID) ~= tonumber(self.mFriendId) then
		return;
	end

	self:insertMsg(message);
	self:slipToEnd();

end

--msgID 在这里是以时间为标识
ChatWindow.onSendState = function ( self, friendId, msgId, state)

	
	if tonumber(friendId) == tonumber(self.mFriendId) then

		for i = 1, #self.mSendId do
			if tonumber(msgId) == tonumber(self.mSendId[i].id) then
				table.remove(self.mSendId, i);
				break;
			end
		end

		local y = 0;
		for i = 1, #self.mItemPosMap do
			if tonumber(self.mItemPosMap[i].id) == tonumber(msgId) then
				self.mItemPosMap[i].item:setState(1);
				if state == 0 or state == 1 then
					self.mItemPosMap[i].item:setState(1);
				elseif state == -1 then
					self.mItemPosMap[i].item:setState(-1);
					self.mItemPosMap[i].item:setOnClick(self, self.onReSend);
				end
				break;
			end
		end
	end
end
ChatWindow.onTimer = function ( self )
	-- body
	local curTime = os.time();

	for i = 1, #self.mSendId do
		if curTime - self.mSendId[i].time > 15 then
			self:onSendState(self.mFriendId, self.mSendId[i].id, -1);
			table.remove(self.mSendId, i);
			break;
		end
	end
		
end

ChatWindow.onReSend = function (self, item)
	-- body

	item:setState(0);
	local state = {};
    state.time 	= os.time();
    state.id 	= item:getId();
    self.mSendId[#self.mSendId + 1] = state;

	FriendDataManager.getInstance():sendMsgToFriendBySocket(self.mFriendId, item:getId() , item:getText());
end

ChatWindow.hide = function ( self )
	self:setVisible(false);
end


ChatWindow.onCallBackFunc = function (self, actionType, actionParam)
	DebugLog("chatWindow.onCallBackFunc ")
	DebugLog(actionType)
	if kFriendRecvSendStateBySockect == actionType then --接收好友的聊天消息
		self:onSendState(actionParam.friendId, actionParam.msgId, actionParam.result);
	elseif kFriendRecvMsgBySockect == actionType then
		self:onRecvMsg(actionParam);
	end
end

