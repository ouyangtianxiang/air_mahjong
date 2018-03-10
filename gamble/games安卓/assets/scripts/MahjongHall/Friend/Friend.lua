--[[
	className    	     :  Friend
	Description  	     :  To wrap the view of the friend.
	last-modified-date   :  Dec. 6 2013
	create-time 	   	 :  Oct.31 2013
	last-modified-author :  ClarkWu
	create-author        :　ClarkWu
]]
require("MahjongData/PlayerManager");
require("MahjongHall/Friend/FriendListItem");
require("MahjongHall/Friend/FriendNoticeItem");
require("ui/editTextView");

Friend = class(CustomNode);

State_MyFriend = kNumEleven;-- 我的好友界面
State_FriendNotice = kNumTwelve; -- 好友消息

--[[
	function name	   : Friend.ctor
	description  	   : Construct a class.
	param 	 	 	   : self
	last-modified-date : Dec. 5 2013
	create-time  	   : Oct.31 2013
]]
Friend.ctor = function(self)
    self.m_event = EventDispatcher.getInstance():getUserEvent();
    EventDispatcher.getInstance():register(NativeManager._Event, self, self.nativeCallEvent);
    GameConstant.friendRef = self;
    -- 当前点击的好友Id
    self.currentFriendId = 0;
    -- 默认的是否已经读过好友列表
    self.isAreadyReadListView = false;
    self.lastClickIndex = 0;

    -- 创建好友界面上部View
    self.bg = UICreator.createImg(CreatingViewUsingData.commonData.bg.fileName, CreatingViewUsingData.commonData.bg.x, CreatingViewUsingData.commonData.bg.y);
    self.bg:setFillParent(true, true);
    self.bg:setEventTouch(self, function(self)

    end );

    self.cover:setEventTouch(self, function(self)

    end );

    self.topViewNode = self:createTopViewNode();
    self:addChild(self.bg);
    self:addChild(self.topViewNode);

    -- 默认选择 --我的好友界面
    self.state = State_MyFriend;
    -- 最后一次有效选择的标签页
    self.clickTag = State_MyFriend;

    -- 如果有好友消息，先显示好友消息
    if FriendDataManager.getInstance().m_Friends_notices_length ~= 0 then
        self:onClickFriendNotice();
        return;
    end

    -- 请求好友列表
    FriendDataManager.getInstance():setCallBack(self, self.onCallBackFunc);
    FriendDataManager.getInstance():onRequestAllFriends();

    self.myFriendView = self:createMyFriend();
    self:addChild(self.myFriendView);
end

--[[
	function name	   : Friend.dtor
	description  	   : Destruct a class.
	param 	 	 	   : self
	last-modified-date : Dec. 4 2013
	create-time  	   : Oct.31 2013
]]
Friend.dtor = function(self)
    GameConstant.friendRef = nil;
    self.currentFriendId = 0;
    -- 默认的是否已经读过好友列表
    self.isAreadyReadListView = false;
    self.lastClickIndex = 0;
    EventDispatcher.getInstance():unregister(NativeManager._Event, self, self.nativeCallEvent);

    self:removeAllChildren();
    FriendDataManager.getInstance():setCallBack();
end

----------------------------------------------------------回调函数-----------------------------------------------------------------------------------------------------
--[[
	function name	   : Friend.onCallBackFunc
	description  	   : PHP或者socket请求返回.根据行为指令调用不同方法.
	param 	 	 	   : self
						 actionType  -- 行为指令
	last-modified-date : Dec. 4 2013
	create-time  	   : Dec. 4 2013
]]
Friend.onCallBackFunc = function(self, actionType)
    if kFriendRequestByPHP == actionType then
        self:onRequestFriends();
        if #FriendDataManager.getInstance().m_Friends ~= 0 then
            FriendDataManager.getInstance():requestFriendsIsOnlineSocket();
        end
    elseif kFriendDetailByPHP == actionType then
        self:onGetFriendDetail();
    elseif kFriendOnlinesBySocket == actionType then
        self:isOnlineState();
    elseif kFriendNotOnlineSocket == actionType then
        self:notOnlineState();
    elseif kFriendDeleteByPHP == actionType then
        self:deleteFriendReceive();
    elseif kFriendAddSuccessBySocket == actionType then
        self:addFriendSuccess();
    elseif kFriendAllOnlineFriendsBySocket == actionType then
        self:onRequestFriends();
    end
end

--[[
	function name	   : Friend.onRequestFriends
	description  	   : 我的好友请求返回.
	param 	 	 	   : self
	last-modified-date : Dec. 11 2013
	create-time  	   : Dec. 4 2013
]]
Friend.onRequestFriends = function(self)
    if not self.friendListAdapter or #FriendDataManager.getInstance().m_Friends == 0 then
        self:removeChild(self.myFriendView, true);
        self.myFriendView = self:createMyFriend();
        self:addChild(self.myFriendView);
    else
        local mid = 0;
        if self.lastClickIndex > kNumOne then
            if FriendDataManager.getInstance():getFriendByBtnId(self.lastClickIndex) then
                mid = FriendDataManager.getInstance():getFriendByBtnId(self.lastClickIndex).mid;
            else
                self.lastClickIndex = self.lastClickIndex - 1;
                if FriendDataManager.getInstance():getFriendByBtnId(self.lastClickIndex) then
                    mid = FriendDataManager.getInstance():getFriendByBtnId(self.lastClickIndex).mid;
                end
            end
            GameConstant.oneFriendList = { };
        end
        local data = { };
        for i = 1, #FriendDataManager.getInstance().m_Friends do
            data[i] = { };
            data[i].btnId = i;
            data[i].mid = FriendDataManager.getInstance().m_Friends[i].mid;
            data[i].name = FriendDataManager.getInstance().m_Friends[i].name;
            data[i].money = FriendDataManager.getInstance().m_Friends[i].money;
            data[i].sex = FriendDataManager.getInstance().m_Friends[i].sex;
            data[i].smallImg = FriendDataManager.getInstance().m_Friends[i].smallImg;
            data[i].bigImg = FriendDataManager.getInstance().m_Friends[i].bigImg;
            data[i].isOnline = FriendDataManager.getInstance().m_Friends[i].isOnline;
            data[i].friendRef = self;
        end
        self.friendListAdapter:changeData(data);
        if mid == 0 then
            return;
        end
        if self.lastClickIndex > kNumOne then
            FriendDataManager.getInstance():setCallBack(self, self.onCallBackFunc);
            self.currentFriendId = mid;
            FriendDataManager.getInstance():requestPerFriendInformation(mid);
            if GameConstant.oneFriendList[mid .. ""] then
                GameConstant.oneFriendList[mid .. ""]:setFile(CreatingViewUsingData.friendView.selectFriend.fileName);
            else
                self.currentFriendId = FriendDataManager.getInstance().m_Friends[1].mid;
                GameConstant.oneFriendList[self.currentFriendId .. ""]:setFile(CreatingViewUsingData.friendView.selectFriend.fileName);
            end
        end
    end
end

--[[
	function name	   : Friend.onGetFriendDetail
	description  	   : 好友详细信息请求返回.
	param 	 	 	   : self
	last-modified-date : Dec. 5 2013
	create-time  	   : Dec. 5 2013
]]
Friend.onGetFriendDetail = function(self)
    -- 好友详细信息池
    if not FriendDataManager.getInstance():selectFriendByMid(self.currentFriendId) then
        DebugLog("好友信息异常");
        return;
    end
    DebugLog(FriendDataManager.getInstance():selectFriendByMid(self.currentFriendId).smallImg or "");
    DebugLog(FriendDataManager.getInstance():selectFriendByMid(self.currentFriendId).bigImg or "");
    if not FriendDataManager.getInstance().m_Friends_details[self.currentFriendId .. ""] then
        return;
    end
    local pic = FriendDataManager.getInstance().m_Friends_details[self.currentFriendId .. ""].bigImg;
    DebugLog(FriendDataManager.getInstance().m_Friends_details[self.currentFriendId .. ""].smallImg);
    DebugLog(FriendDataManager.getInstance().m_Friends_details[self.currentFriendId .. ""].bigImg);
    local imgPic = CreatingViewUsingData.commonData.girlPicLocate;

    if not self.headImg or not self.m_id or not self.m_level or not self.m_jushu or not self.m_shenglv then
        self.rightViewNode = self:createRightViewNode();
    end

    if pic == nil then
        self.headImg:setFile(CreatingViewUsingData.commonData.girlPicLocate);
        return;
    else
        local tempPicNum = string.find(pic, CreatingViewUsingData.commonData.regularJudge);
        if tempPicNum ~= nil then
            imgPic = string.sub(pic, string.find(pic, CreatingViewUsingData.commonData.regularJudge));
        end
        if imgPic == CreatingViewUsingData.commonData.boyPic or imgPic == CreatingViewUsingData.commonData.girlPic then
            if tonumber(FriendDataManager.getInstance().m_Friends_details[self.currentFriendId .. ""].sex) == 0 then
                self.headImg:setFile(CreatingViewUsingData.commonData.boyPicLocate);
            else
                self.headImg:setFile(CreatingViewUsingData.commonData.girlPicLocate);
            end
        else
            local isExist, localDir = NativeManager.getInstance():downloadImage(imageUrl);
            self.localDir = localDir;
            if not isExist then
                if tonumber(FriendDataManager.getInstance().m_Friends_details[self.currentFriendId .. ""].sex) == 0 then
                    self.headImg:setFile(CreatingViewUsingData.commonData.boyPicLocate);
                else
                    self.headImg:setFile(CreatingViewUsingData.commonData.girlPicLocate);
                end
            else
                self.headImg:setFile(self.localDir);
            end
        end
    end

    -- 保证与左侧同步
    if FriendDataManager.getInstance():selectFriendByMid(self.currentFriendId).isOnline == 0 then
        self.trackBtn:setPickable(false);
        self.trackBtn:setFile(CreatingViewUsingData.friendView.trackBtnGrayed.fileName);
    elseif FriendDataManager.getInstance():selectFriendByMid(self.currentFriendId).isOnline == kNumOne then
        self.trackBtn:setPickable(true);
        self.trackBtn:setFile(CreatingViewUsingData.commonData.confirmBtnBg.fileName);
    end
    self.m_id:setText(self.currentFriendId);
    self.m_level:setText(FriendDataManager.getInstance().m_Friends_details[self.currentFriendId .. ""].level);
    self.m_jushu:setText(FriendDataManager.getInstance().m_Friends_details[self.currentFriendId .. ""].jushu);
    self.m_shenglv:setText(FriendDataManager.getInstance().m_Friends_details[self.currentFriendId .. ""].shenglv);
end

--[[
	function name	   : Friend.isOnlineState
	description  	   : 请求是否在线返回.(在线)
	param 	 	 	   : self
	last-modified-date : Dec. 5 2013
	create-time  	   : Dec. 5 2013
]]
Friend.isOnlineState = function(self)
    if tonumber(FriendDataManager.getInstance().requestId) ~= tonumber(self.currentFriendId) then
        FriendDataManager.getInstance().requestId = 0;
        return;
    end
    GameConstant.m_leftOnlineIcon[self.currentFriendId .. ""]:setFile(CreatingViewUsingData.friendView.isOnlinePic.onlineName);
    self.trackBtn:setPickable(true);
    self.trackBtn:setFile(CreatingViewUsingData.commonData.confirmBtnBg.fileName);
    FriendDataManager.getInstance().requestId = 0;
end

--[[
	function name	   : Friend.isOnlineState
	description  	   : 请求是否在线返回.(不在线)
	param 	 	 	   : self
	last-modified-date : Dec. 5 2013
	create-time  	   : Dec. 5 2013
]]
Friend.notOnlineState = function(self)
    if FriendDataManager.getInstance().requestId ~= self.currentFriendId then
        FriendDataManager.getInstance().requestId = 0;
        return;
    end
    GameConstant.m_leftOnlineIcon[self.currentFriendId .. ""]:setFile(CreatingViewUsingData.friendView.isOnlinePic.nolineName or "");
    self.trackBtn:setPickable(true);
    self.trackBtn:setFile(CreatingViewUsingData.friendView.trackBtnGrayed);
    FriendDataManager.getInstance().requestId = 0;
end

--[[
	function name	   : Friend.deleteFriendReceive
	description  	   : 删除好友返回.
	param 	 	 	   : self
	last-modified-date : Dec. 6 2013
	create-time  	   : Dec. 6 2013
]]
Friend.deleteFriendReceive = function(self)
    FriendDataManager.getInstance():onRequestAllFriends();
end

--[[
	function name	   : Friend.deleteFriendReceive
	description  	   : 添加好友返回.
	param 	 	 	   : self
	last-modified-date : Dec. 6 2013
	create-time  	   : Dec. 6 2013
]]
Friend.addFriendSuccess = function(self)
    FriendDataManager.getInstance():onRequestAllFriends();
end

----------------------------------------------------------界面相关---------------------------------------------------------------------------------------------------
--[[
	function name	   : Friend.createTopViewNode
	description  	   : 创建好友界面的顶部.
	param 	 	 	   : self
	last-modified-date : Dec. 4 2013
	create-time  	   : Oct.31 2013
]]
Friend.createTopViewNode = function(self)
    local node = new(Node);

    local topImg = UICreator.createImg(CreatingViewUsingData.commonData.topBg.fileName, 0, 0);
    topImg:setSize(getAdapt(SCREEN_WIDTH), topImg.m_height);

    local returnBtn = UICreator.createBtn(CreatingViewUsingData.commonData.topReturnBtn.fileName, CreatingViewUsingData.commonData.topReturnBtn.x, CreatingViewUsingData.commonData.topReturnBtn.y);
    returnBtn:setOnClick(self, self.onCancelCallBack);

    local m_split = UICreator.createImg(CreatingViewUsingData.commonData.topSplitImg.fileName, CreatingViewUsingData.commonData.topSplitImg.x, CreatingViewUsingData.commonData.topSplitImg.y);

    -- 绘制当前选择框
    self.currentTag = UICreator.createBtn(CreatingViewUsingData.commonData.selectTextBg.fileName, CreatingViewUsingData.commonData.selectTextBg.x, CreatingViewUsingData.commonData.selectTextBg.y);


    -- 绘制我的好友界面
    self.myFriendViewBtn = UICreator.createBtn(CreatingViewUsingData.commonData.blankBg.fileName, CreatingViewUsingData.friendView.rightTextBg.x1, CreatingViewUsingData.friendView.rightTextBg.y1);

    self.myFriendViewBtn:setSize(CreatingViewUsingData.friendView.rightTextBg.w, CreatingViewUsingData.friendView.rightTextBg.h);

    self.myFriendViewBtn:setOnClick(self, self.onClickMyFriend);
    local rightFCoord = CreatingViewUsingData.friendView.rightMyFriend;
    self.myFriendViewText = UICreator.createText(rightFCoord.str, rightFCoord.x, rightFCoord.y, rightFCoord.w, rightFCoord.h, rightFCoord.align, rightFCoord.size, rightFCoord.r, rightFCoord.g, rightFCoord.b);
    self.friendNoticeBtn = UICreator.createBtn(CreatingViewUsingData.commonData.blankBg.fileName, CreatingViewUsingData.friendView.rightTextBg.x2, CreatingViewUsingData.friendView.rightTextBg.y2);
    self.friendNoticeBtn:setOnClick(self, self.onClickFriendNotice);
    rightFCoord = CreatingViewUsingData.friendView.rightFriendNotice;
    self.friendNoticeText = UICreator.createText(rightFCoord.str, rightFCoord.x, rightFCoord.y, rightFCoord.w, rightFCoord.h, rightFCoord.align, rightFCoord.size, rightFCoord.r, rightFCoord.g, rightFCoord.b);
    self.friendNoticeBtn:setSize(CreatingViewUsingData.friendView.rightTextBg.w, CreatingViewUsingData.friendView.rightTextBg.h);

    node:addChild(topImg);
    node:addChild(returnBtn);
    node:addChild(m_split);
    node:addChild(self.currentTag);
    makeTheControlAdaptResolution(self.currentTag, 1);
    node:addChild(self.myFriendViewBtn);
    makeTheControlAdaptResolution(self.myFriendViewBtn, 1);
    node:addChild(self.myFriendViewText);
    makeTheControlAdaptResolution(self.myFriendViewText, 1);
    node:addChild(self.friendNoticeBtn);
    makeTheControlAdaptResolution(self.friendNoticeBtn, 1);
    node:addChild(self.friendNoticeText);
    makeTheControlAdaptResolution(self.friendNoticeText, 1);
    return node;
end

--[[
	function name	   : Friend.onClickFriendNotice
	description  	   : 创建好友消息界面(点击好友消息事件创建).
	param 	 	 	   : self
	last-modified-date : Dec. 5 2013
	create-time  	   : Oct.31 2013
]]
Friend.onClickFriendNotice = function(self)
    if self.loading then
        delete(self.loading);
        self.loading = nil;
    end
    if self.state == State_MyFriend then
        umengStatics_lua(kUmengFriendNotice);
        local offest = getAdapt(self.friendNoticeBtn.m_x - self.currentTag.m_x);
        self.animIndex = self.currentTag:addPropTranslate(kNumOne, kAnimNormal, 200, 0, 0, offest, 0, 0);
        self.animIndex:setEvent(self, self.moveDone);
    else
        return;
    end

    if self.myFriendView then
        self.myFriendView:setVisible(false);
    end

    if not self.friendNoticeView then
        self.friendNoticeView = self:createFriendNotice();
        self:addChild(self.friendNoticeView);
    else
        self.friendNoticeView:setVisible(true);
    end

    self.state = State_Moving;
    self.clickTag = State_FriendNotice;
end

--[[
	function name	   : Friend.onClickMyFriend
	description  	   : 创建我的好友界面(点击我的好友事件创建).
	param 	 	 	   : self
	last-modified-date : Dec. 5 2013
	create-time  	   : Oct.31 2013
]]
Friend.onClickMyFriend = function(self)
    if self.state == State_Moving then
        return;
    end
    FriendDataManager.getInstance():setCallBack(self, self.onCallBackFunc);
    if self.state == State_FriendNotice then
        umengStatics_lua(kUmengMyFriend);
        local offest = getAdapt(self.myFriendViewBtn.m_x - self.currentTag.m_x);
        self.animIndex = self.currentTag:addPropTranslate(kNumOne, kAnimNormal, 200, 0, 0, offest, 0, 0);
        self.animIndex:setEvent(self, self.moveDone);
    else
        return;
    end

    if not self.myFriendView then
        -- 请求好友列表
        FriendDataManager.getInstance():onRequestAllFriends();

        self.myFriendView = self:createMyFriend();
        self:addChild(self.myFriendView);
    else
        self.myFriendView:setVisible(true);
    end

    if self.friendNoticeView then
        self.friendNoticeView:setVisible(false);
    end
    self.state = State_Moving;
    self.clickTag = State_MyFriend;
end

--[[
	function name	   : Friend.moveDone
	description  	   : 我的好友和好友消息的动画切换.
	param 	 	 	   : self
	last-modified-date : Dec. 5 2013
	create-time  	   : Oct.31 2013
]]
Friend.moveDone = function(self)
    self.currentTag:removeProp(kNumOne);
    local coord = CreatingViewUsingData.friendView.rightMyFriend;
    local coord2 = CreatingViewUsingData.friendView.rightFriendNotice;
    if self.clickTag == State_MyFriend then
        self.myFriendViewText:setText(coord.str, coord.w, coord.h, coord.r, coord.g, coord.b);
        self.friendNoticeText:setText(coord2.str, coord2.w, coord2.h, coord2.r, coord2.g, coord2.b);
        self.currentTag:setPos(CreatingViewUsingData.friendView.rightTextBg.x1, CreatingViewUsingData.friendView.rightTextBg.y1);
        self.state = State_MyFriend;

    elseif self.clickTag == State_FriendNotice then
        self.currentTag:setPos(CreatingViewUsingData.friendView.rightTextBg.x2, CreatingViewUsingData.friendView.rightTextBg.y2);
        self.state = State_FriendNotice;
        self.myFriendViewText:setText(coord.str, coord.w, coord.h, coord2.r, coord2.g, coord2.b);
        self.friendNoticeText:setText(coord2.str, coord2.w, coord2.h, coord.r, coord.g, coord.b);
    end
    makeTheControlAdaptResolution(self.currentTag, 1);
end

--[[
	function name	   : Friend.createMyFriend
	description  	   : 我的好友界面创建方法.
	param 	 	 	   : self
	last-modified-date : Dec. 5 2013
	create-time  	   : Oct.31 2013
]]
Friend.createMyFriend = function(self)
    local myFriendNode = new(Node);
    myFriendNode:setSize(MahjongLayout_W, MahjongLayout_H);
    makeTheControlAdaptResolution(myFriendNode);
    -- 无好友
    if #FriendDataManager.getInstance().m_Friends == 0 then

        local contentView = UICreator.createImg(CreatingViewUsingData.friendView.friendBg.noFileName);
        contentView:setPos(CreatingViewUsingData.friendView.friendBg.x, CreatingViewUsingData.friendView.friendBg.y);
        myFriendNode:addChild(contentView);
        -- makeTheControlAdaptResolution(contentView);

        self.noFriendsView = self:createNoFriendList();
        myFriendNode:addChild(self.noFriendsView);
        -- makeTheControlAdaptResolution(self.noFriendsView);
        return myFriendNode;
    else
        local contentView = UICreator.createImg(CreatingViewUsingData.friendView.friendBg.fileName);
        contentView:setPos(CreatingViewUsingData.friendView.friendBg.x, CreatingViewUsingData.friendView.friendBg.y);
        myFriendNode:addChild(contentView);
        -- makeTheControlAdaptResolution(contentView);
        self.leftViewNode = self:createLeftViewNode();
        -- makeTheControlAdaptResolution(self.leftViewNode);

        if not self.headImg or not self.m_id or not self.m_level or not self.m_jushu or not self.m_shenglv then
            self.rightViewNode = self:createRightViewNode();
        end

        myFriendNode:addChild(self.leftViewNode);
        self.rightViewNode:setPos(CreatingViewUsingData.friendView.rightFriend.x, CreatingViewUsingData.friendView.rightFriend.y);
        -- makeTheControlAdaptResolution(self.rightViewNode);
        myFriendNode:addChild(self.rightViewNode);
    end
    local zhezhaoNode = UICreator.createImg(CreatingViewUsingData.friendView.zhezhao.fileName);

    zhezhaoNode:setPos(CreatingViewUsingData.friendView.zhezhao.x, CreatingViewUsingData.friendView.zhezhao.y);
    myFriendNode:addChild(zhezhaoNode);
    return myFriendNode;
end

--[[
	function name	   : Friend.createNoFriendList
	description  	   : 我的好友界面创建方法(无好友的方法).
	param 	 	 	   : self
	last-modified-date : Dec. 5 2013
	create-time  	   : Oct.31 2013
]]
Friend.createNoFriendList = function(self)
    -- 没有好友的情况下，当前FriendId = 0
    self.currentFriendId = 0;
    -- 没有好友的情况下，需要重读listView
    self.isAreadyReadListView = false;

    if self.friendListAdapter then
        self.friendListAdapter = nil;
    end
    if self.headImg or self.m_id or self.m_level or self.m_jushu or self.m_shenglv then
        if self.headImg then
            self.headImg = nil;
        end

        if self.mid then
            self.mid = nil;
        end
        if self.m_jushu then
            self.m_jushu = nil;
        end
        if self.m_shenglv then
            self.m_shenglv = nil;
        end
    end

    local noFriendNode = new(Node);
    noFriendNode:setSize(MahjongLayout_W, MahjongLayout_H);
    local noFriendPic = UICreator.createImg(CreatingViewUsingData.friendView.noFriendGirlPic.fileName);
    noFriendPic:setPos(CreatingViewUsingData.friendView.noFriendGirlPic.x, CreatingViewUsingData.friendView.noFriendGirlPic.y);
    noFriendNode:addChild(noFriendPic);

    local coord = CreatingViewUsingData.friendView.noFriendText;

    local noFriendText1 = UICreator.createText(coord.str1, coord.x, coord.y1, coord.w, coord.h, coord.align, coord.size, coord.r, coord.g, coord.b);
    local noFriendText2 = UICreator.createText(coord.str2, coord.x, coord.y2, coord.w, coord.h, coord.align, coord.size, coord.r, coord.g, coord.b);

    local input_bg = UICreator.createImg(CreatingViewUsingData.friendView.noFriendInputBg.fileName);
    input_bg:setPos(CreatingViewUsingData.friendView.noFriendInputBg.x, CreatingViewUsingData.friendView.noFriendInputBg.y);

    coord = CreatingViewUsingData.friendView.noFriendEditText;
    self.m_no_friendEdit = new(EditTextView, kNullStringStr, coord.w, coord.h, coord.align, nil, coord.size, coord.r, coord.g, coord.b);
    self.m_no_friendEdit:setHintText(coord.hintText, coord.r, coord.g, coord.b);
    self.m_no_friendEdit:setPos(coord.x, coord.y);
    coord = CreatingViewUsingData.friendView.noFriendAddBtn;
    self.addBtn = UICreator.createTextBtn(CreatingViewUsingData.friendView.noFriendAddBtn.fileName, coord.x, coord.y, coord.str, coord.size, coord.r, coord.g, coord.b);
    self.addBtn:setOnClick(self, self.onClickAddFriend);
    noFriendNode:addChild(noFriendText1);
    noFriendNode:addChild(noFriendText2);
    noFriendNode:addChild(input_bg);
    noFriendNode:addChild(self.m_no_friendEdit);
    noFriendNode:addChild(self.addBtn);
    return noFriendNode;
end

--[[
	function name	   : Friend.createLeftViewNode
	description  	   : 我的好友界面创建方法(左侧界面).
	param 	 	 	   : self
	last-modified-date : Dec. 5 2013
	create-time  	   : Oct.31 2013
]]
Friend.createLeftViewNode = function(self)
    local leftNode = new(Node);
    leftNode:setSize(MahjongLayout_W, MahjongLayout_H);
    local bottomImg = UICreator.createImg(CreatingViewUsingData.friendView.addFriendFrame.fileName);
    local input_bg = UICreator.createImg(CreatingViewUsingData.friendView.leftInputBg.fileName);
    local coord = CreatingViewUsingData.friendView.leftInputEditText;
    self.m_edit = new(EditTextView, kNullStringStr, coord.w, coord.h, coord.align, nil, coord.size, coord.r, coord.g, coord.b);
    self.m_edit:setHintText(coord.hintText, coord.r, coord.g, coord.b);
    self.m_edit:setPos(coord.x, coord.y);

    coord = CreatingViewUsingData.friendView.leftAddBtn;
    self.addBtn = UICreator.createTextBtn(coord.fileName, coord.x, coord.y, coord.str, coord.size, coord.r, coord.g, coord.b);
    self.addBtn:setOnClick(self, self.onClickAddFriend);
    -- 创建左侧列表
    self.friendListViewNode = self:createLeftFriendListView();

    bottomImg:setPos(CreatingViewUsingData.friendView.addFriendFrame.x, CreatingViewUsingData.friendView.addFriendFrame.y);
    input_bg:setPos(CreatingViewUsingData.friendView.leftInputBg.x, CreatingViewUsingData.friendView.leftInputBg.y);
    leftNode:addChild(bottomImg);
    leftNode:addChild(self.friendListViewNode);
    leftNode:addChild(input_bg);
    leftNode:addChild(self.m_edit);
    leftNode:addChild(self.addBtn);
    return leftNode;
end

--[[
	function name	   : Friend.createRightViewNode
	description  	   : 我的好友界面创建方法(右侧界面).
	param 	 	 	   : self
	last-modified-date : Dec. 5 2013
	create-time  	   : Oct.31 2013
]]
Friend.createRightViewNode = function(self)
    local rightNode = new(Node);
    rightNode:setSize(MahjongLayout_W, MahjongLayout_H);
    local headIcon = UICreator.createImg(CreatingViewUsingData.friendView.rightFrame.fileName);
    local coord = CreatingViewUsingData.friendView.rightId;
    local idTitle = UICreator.createText(coord.str, coord.x1, coord.y, coord.w, coord.h, coord.align, coord.size, coord.r, coord.g, coord.b);
    if self.headImg or self.m_id or self.m_level or self.m_jushu or self.m_shenglv then
        if self.headImg then
            delete(self.headImg);
            self.headImg = nil;
        end
        if self.mid then
            delete(self.mid);
            self.mid = nil;
        end
        if self.m_jushu then
            delete(self.m_jushu);
            self.m_jushu = nil;
        end
        if self.m_shenglv then
            delete(self.m_shenglv);
            self.m_shenglv = nil;
        end
        self.headImg = UICreator.createImg(CreatingViewUsingData.commonData.girlPicLocate);
        coord = CreatingViewUsingData.friendView.rightId;
        self.m_id = UICreator.createText(kNullStringStr, coord.x2, coord.y, coord.w, coord.h, coord.align, coord.size, coord.r, coord.g, coord.b);
        coord = CreatingViewUsingData.friendView.rightLevel;
        self.m_level = UICreator.createText(kNullStringStr, coord.x2, coord.y, coord.w, coord.h, coord.align, coord.size, coord.r, coord.g, coord.b);
        coord = CreatingViewUsingData.friendView.rightJuShu;
        self.m_jushu = UICreator.createText(coord.defaultstr, coord.x2, coord.y, coord.w, coord.h, coord.align, coord.size, coord.r, coord.g, coord.b);
        coord = CreatingViewUsingData.friendView.rightShengLv;
        self.m_shenglv = UICreator.createText(coord.defaultstr, coord.x2, coord.y, coord.w, coord.h, coord.align, coord.size, coord.r, coord.g, coord.b);
    end


    coord = CreatingViewUsingData.friendView.rightTrackBtn;
    self.trackBtn = UICreator.createTextBtn(CreatingViewUsingData.commonData.confirmBtnBg.fileName, coord.x, coord.y, coord.str, coord.size, coord.r, coord.g, coord.b);
    coord = CreatingViewUsingData.friendView.rightLevel;
    local levelTitle = UICreator.createText(coord.str, coord.x1, coord.y, coord.w, coord.h, coord.align, coord.size, coord.r, coord.g, coord.b);
    coord = CreatingViewUsingData.friendView.rightJuShu;
    local jushuTitle = UICreator.createText(coord.str, coord.x1, coord.y, coord.w, coord.h, coord.align, coord.size, coord.r, coord.g, coord.b);
    coord = CreatingViewUsingData.friendView.rightShengLv;
    local shenglvTitle = UICreator.createText(coord.str, coord.x1, coord.y, coord.w, coord.h, coord.align, coord.size, coord.r, coord.g, coord.b);
    coord = CreatingViewUsingData.friendView.rightDeleteBtn;
    local deleteBtn = UICreator.createTextBtn(CreatingViewUsingData.commonData.cancelBg.fileName, coord.x, coord.y, coord.str, coord.size, coord.r, coord.g, coord.b);

    self.trackBtn:setOnClick(self, Friend.onClickTrackFriend);
    deleteBtn:setOnClick(self, Friend.onClickDeleteFriend);

    headIcon:setPos(CreatingViewUsingData.friendView.rightFrame.x, CreatingViewUsingData.friendView.rightFrame.y);
    self.headImg:setPos(CreatingViewUsingData.friendView.rightImg.x, CreatingViewUsingData.friendView.rightImg.y);
    self.headImg:setSize(CreatingViewUsingData.friendView.rightImg.w, CreatingViewUsingData.friendView.rightImg.h);
    rightNode:addChild(headIcon);
    rightNode:addChild(self.headImg);
    rightNode:addChild(idTitle);
    rightNode:addChild(self.m_id);
    rightNode:addChild(levelTitle);
    rightNode:addChild(self.m_level);
    rightNode:addChild(jushuTitle);
    rightNode:addChild(self.m_jushu);
    rightNode:addChild(shenglvTitle);
    rightNode:addChild(self.m_shenglv);
    rightNode:addChild(self.trackBtn);
    rightNode:addChild(deleteBtn);
    return rightNode;
end

--[[
	function name	   : Friend.createLeftFriendListView
	description  	   : 我的好友界面创建方法(左侧界面).
	param 	 	 	   : self
	last-modified-date : Dec. 5 2013
	create-time  	   : Oct.31 2013
]]
Friend.createLeftFriendListView = function(self)
    local friendListNode = new(Node);
    local coord = CreatingViewUsingData.friendView.friendListView;
    friendListNode:setPos(coord.startX, coord.startY);
    local data = { };
    for i = 1, #FriendDataManager.getInstance().m_Friends do
        data[i] = { };
        data[i].btnId = i;
        data[i].mid = FriendDataManager.getInstance().m_Friends[i].mid;
        data[i].name = FriendDataManager.getInstance().m_Friends[i].name;
        data[i].money = FriendDataManager.getInstance().m_Friends[i].money;
        data[i].sex = FriendDataManager.getInstance().m_Friends[i].sex;
        data[i].smallImg = FriendDataManager.getInstance().m_Friends[i].smallImg;
        data[i].bigImg = FriendDataManager.getInstance().m_Friends[i].bigImg;
        data[i].isOnline = FriendDataManager.getInstance().m_Friends[i].isOnline;
        data[i].friendRef = self;
    end
    self.friendListAdapter = new(CacheAdapter, FriendListItem, data);

    self.friendListView = new(ListView, coord.x, coord.y, coord.w, coord.h);
    self.friendListView:setAlign(coord.align);
    self.friendListView:setAdapter(self.friendListAdapter);
    self.friendListView:setScrollBarWidth(coord.scrollBarWidth);
    self.friendListView:setMaxClickOffset(coord.maxClickOffset);
    friendListNode:addChild(self.friendListView);
    return friendListNode;
end

--[[
	function name	   : Friend.createFriendNotice
	description  	   : 好友消息界面的创建.
	param 	 	 	   : self
	last-modified-date : Dec. 5 2013
	create-time  	   : Oct.31 2013
]]
Friend.createFriendNotice = function(self)
    local friendNoticeNode = new(Node);
    friendNoticeNode:setSize(MahjongLayout_W, MahjongLayout_H);
    makeTheControlAdaptResolution(friendNoticeNode);

    local coord = CreatingViewUsingData.friendView.friendNoticeBg;
    local contentView = UICreator.createImg(coord.fileName);
    contentView:setPos(coord.x, coord.y);
    friendNoticeNode:addChild(contentView);

    if FriendDataManager.getInstance().m_Friends_notices_length == 0 then
        local node = new(Node);
        coord = CreatingViewUsingData.friendView.noFriendNotices;
        local text = UICreator.createText(coord.str, coord.x, coord.y, coord.w, coord.h, coord.align, coord.size, coord.r, coord.g, coord.b);
        node:addChild(text);
        friendNoticeNode:addChild(node);
    else
        local data = { };
        for i = 1, FriendDataManager.getInstance().m_Friends_notices_length do
            if not FriendDataManager.getInstance().m_Friend_notices[i] then
                return;
            end
            data[i] = { };
            data[i].mid = FriendDataManager.getInstance().m_Friend_notices[i].mid;
            data[i].name = FriendDataManager.getInstance().m_Friend_notices[i].name;
            data[i].type = FriendDataManager.getInstance().m_Friend_notices[i].type;
            data[i].notice_key = FriendDataManager.getInstance().m_Friend_notices[i].notice_key;
            data[i].action = FriendDataManager.getInstance().m_Friend_notices[i].action;
            data[i].smallImg = FriendDataManager.getInstance().m_Friend_notices[i].smallImg;
            data[i].friendRef = self;
        end
        self.friendNoticeAdapter = new(CacheAdapter, FriendNoticeItem, data);
        coord = CreatingViewUsingData.friendView.friendNoticeListView;
        self.friendNoticeListView = new(ListView, coord.x, coord.y, coord.w, coord.h);
        self.friendNoticeListView:setAlign(coord.align);
        self.friendNoticeListView:setAdapter(self.friendNoticeAdapter);
        self.friendNoticeListView:setScrollBarWidth(coord.scrollBarWidth);
        self.friendNoticeListView:setMaxClickOffset(coord.maxClickOffset);

        friendNoticeNode:addChild(self.friendNoticeListView);
    end
    return friendNoticeNode;
end

-----------------------------------------------------------------按键监听--------------------------------------------------------------------------------------------
--[[
	function name      : Friend.setCallBack
	description  	   : To set the callback method of the view of friend.
	param 	 	 	   : self
						 obj     Table 		--  回调对象
						 fun     Function   --  回调函数
	last-modified-date : Dec. 3 2013
	create-time		   : Dec. 3 2013
]]
Friend.setCallBack = function(self, obj, fun)
    self.callbackObj = obj;
    self.callbackFun = fun;
end

--[[
	function name      : Friend.onCallingBack
	description  	   : 响应对应的回调方法.
	param 	 	 	   : self
	last-modified-date : Dec. 3 2013
	create-time		   : Dec. 3 2013
]]
Friend.onCallingBack = function(self)
    if self.callbackFun then
        self.callbackFun(self.callbackObj);
    end
end


-- 设置释放函数
Friend.setCancelCallBack = function(self, obj, fun)
    self.cancelCallBackObj = obj;
    self.cancelCallBackFun = fun;
end

-- 响应释放函数
Friend.onCancelCallBack = function(self)
    if self.cancelCallBackFun then
        self.cancelCallBackFun(self.cancelCallBackObj);
    end
end

--[[
	function name	   : Friend.OnIgnoreOrAgreeEvent
	description  	   : 忽略和同意按键监听.
	param 	 	 	   : self
	last-modified-date : Dec. 5 2013
	create-time  	   : Oct.31 2013
]]
Friend.OnIgnoreOrAgreeEvent = function(self)
    if FriendDataManager.getInstance().m_Friends_notices_length == 0 then
        self:removeChild(self.friendNoticeView, true);
        self.friendNoticeView = self:createFriendNotice();
        self:addChild(self.friendNoticeView);
    else
        local data = { };
        for i = 1, FriendDataManager.getInstance().m_Friends_notices_length do
            data[i] = { };
            data[i].mid = FriendDataManager.getInstance().m_Friend_notices[i].mid;
            data[i].name = FriendDataManager.getInstance().m_Friend_notices[i].name;
            data[i].type = FriendDataManager.getInstance().m_Friend_notices[i].type;
            data[i].notice_key = FriendDataManager.getInstance().m_Friend_notices[i].notice_key;
            data[i].action = FriendDataManager.getInstance().m_Friend_notices[i].action;
            data[i].smallImg = FriendDataManager.getInstance().m_Friend_notices[i].smallImg;
            data[i].friendRef = self;
        end
        self.friendNoticeAdapter:changeData(data);
    end

    self:onCallingBack();
end

--[[
	function name	   : Friend.onClickAddFriend
	description  	   : 添加好友按键监听.
	param 	 	 	   : self
	last-modified-date : Dec. 5 2013
	create-time  	   : Oct.31 2013
]]
Friend.onClickAddFriend = function(self)
    if #FriendDataManager.getInstance().m_Friends ~= 0 then
        self:judgeFriendId(self.m_edit:getText());
    else
        self:judgeFriendId(self.m_no_friendEdit:getText());
    end
    self.addBtn:setEnable(false);
    local animData = CreatingViewUsingData.friendView.addFriendAnim;
    self.animIndex = new(AnimInt, kAnimNormal, animData.from, animData.to, animData.time, animData.delay);
    self.animIndex:setEvent(self, self.changeEnabled);
end

--[[
	function name	   : Friend.changeEnabled
	description  	   : 添加好友按键动画.(3秒压下效果)
	param 	 	 	   : self
	last-modified-date : Dec. 6 2013
	create-time  	   : Oct.31 2013
]]
Friend.changeEnabled = function(self)
    self.addBtn:setEnable(true);
    delete(self.animIndex);
    self.animIndex = nil;
end

--[[
	function name	   : Friend.onClickTrackFriend
	description  	   : 追踪好友事件监听.
	param 	 	 	   : self
	last-modified-date : Dec. 5 2013
	create-time  	   : Oct.31 2013
]]
Friend.onClickTrackFriend = function(self)
    umengStatics_lua(kUmengTrackFriend);
    local friendId = self.currentFriendId;
    local userId = PlayerManager.getInstance():myself().mid;
    FriendDataManager.getInstance():trackFriendSocket(userId, friendId);
end

--[[
	function name	   : Friend.onClickDeleteFriend
	description  	   : 删除好友事件监听.
	param 	 	 	   : self
	last-modified-date : Dec. 5 2013
	create-time  	   : Oct.31 2013
]]
Friend.onClickDeleteFriend = function(self)
    umengStatics_lua(kUmengDeleteFriend);

    local loc_deleteFriend = FriendDataManager.getInstance():selectFriendByMid(self.currentFriendId);
    if loc_deleteFriend == nil then
        Banner.getInstance():showMsg(PromptMessage.deleteFriendFailed);
        return;
    end

    local name = loc_deleteFriend.name;
    local content = CreatingViewUsingData.friendView.deleteFriendStr.prompt1 .. name .. CreatingViewUsingData.friendView.deleteFriendStr.prompt2;
    local view = PopuFrame.showNormalDialogForCenter(CreatingViewUsingData.commonData.popuFrame.title, content, nil, nil, nil, false);
    view:setConfirmCallback(self, function(self)
        FriendDataManager.getInstance():setCallBack(self, self.onCallBackFunc);
        FriendDataManager.getInstance():deleteFriendSocket(loc_deleteFriend.mid, loc_deleteFriend.name);
    end );
    view:setNotOnClickFeeling(true);
    -- view:setCallback(view, function ( view, isShow )
    -- 	if not isShow then
    -- 		
    -- 	end
    -- end);
end

--[[
	function name	   : Friend.judgeFriendId
	description  	   : 判断好友是否输入正则限制.
	param 	 	 	   : self
						 idText    -- 输入的好友Id号
	last-modified-date : Dec. 5 2013
	create-time  	   : Oct.31 2013
]]
Friend.judgeFriendId = function(self, idText)
    local msg = kNullStringStr;
    local coord = CreatingViewUsingData.friendView.leftInputEditText;
    if coord.hintText == idText or string.len(publ_trim(idText)) == 0 then
        msg = PromptMessage.friendMidInputIsNullError;
    elseif string.match(idText, CreatingViewUsingData.commonData.regularJudgeAdd) == nil then
        msg = PromptMessage.friendInputIllegal;
    elseif tonumber(PlayerManager.getInstance():myself().mid) == tonumber(idText) then
        msg = PromptMessage.notAddYourselfError;
    elseif #FriendDataManager.getInstance().m_Friends >= kMaxFriendNum then
        msg = PromptMessage.fullFriendException;
    else
        if FriendDataManager.getInstance():selectFriendByMid(idText) then
            msg = PromptMessage.isAlreadyFriendException;
        end
    end
    if msg ~= kNullStringStr then
        Banner.getInstance():showMsg(msg);
        return;
    end
    msg = PromptMessage.sendMessageSuccess;
    Banner.getInstance():showMsg(msg);

    FriendDataManager.getInstance():addFriendSocket(tonumber(idText));

    if #FriendDataManager.getInstance().m_Friends ~= 0 then
        self.m_edit:setText(kNullStringStr);
        self.m_edit:setHintText(coord.hintText, coord.r, coord.g, coord.b);
    else
        self.m_no_friendEdit:setText(kNullStringStr);
        self.m_no_friendEdit:setHintText(coord.hintText, coord.r, coord.g, coord.b);
    end
end

