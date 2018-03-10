--local friendItem = require(ViewLuaPath.."friendItem");

FriendChatItem = class(Node);

FriendChatItem.K_FRIEND_CHAT = 0;
FriendChatItem.K_MINE_CHAT = 1;
FriendChatItem.K_TIME = 2;
FriendChatItem.K_TIPS = 3;

-- 好友 元素
FriendChatItem.ctor = function(self, width, id, text, typeItem, sex, headIconDir)
    DebugLog("FriendChatItem.ctor ".. text)
    self:setSize(width, 0);

    self.mSex = sex;
    self.mHeadIconDir = headIconDir;
    -- 本地文件名，非URL
    self.mText = text;
    self.mId = id;

    self.isEditState = false;
    self.isSelected  = false;

    self.typeItem = typeItem

    if typeItem == FriendChatItem.K_FRIEND_CHAT then

        local headIcon = self:createHeadIcon(self.mSex, self.mHeadIconDir);
        self:addChild(headIcon);
        headIcon:setPos(10, 0);

        self.mLeftChat = self:createLeftChat(text);
        self.mLeftChat:setPos(120, 18);
        self:addChild(self.mLeftChat);

        self:createSelecedMenu()

    elseif typeItem == FriendChatItem.K_MINE_CHAT then

        local headIcon = self:createHeadIcon(self.mSex, self.mHeadIconDir);
        self:addChild(headIcon);

        headIcon:setPos(width - 110, 0);

        self.mRightChat = self:createRightChat(text);
        local w, h = self.mRightChat:getSize();
        self.mRightChat:setPos(width - 120 - w, 18);
        self:addChild(self.mRightChat);
        self:createSelecedMenu()
    elseif typeItem == FriendChatItem.K_TIME then
        local time = self:createChatTime(text);
        local w, h = time:getSize();
        time:setPos(0, 20);
        self:addChild(time);
    elseif typeItem == FriendChatItem.K_TIPS then
        local tips = self:createChatTips(text);
        local w, h = tips:getSize();
        self:addChild(tips);
    end

    local w, h = self:getSize();

    self:setSize(w, h + 30);

    EventDispatcher.getInstance():register(NativeManager._Event, self, self.nativeCallEvent);
end


FriendChatItem.dtor = function(self)
    EventDispatcher.getInstance():unregister(NativeManager._Event, self, self.nativeCallEvent);
end


FriendChatItem.createSelecedMenu = function ( self )
    self.selectImg  = UICreator.createImg("Hall/chat/unselect.png",20,35);--(108/2 - 38/2)
    self.selectImg:setEventTouch(self,self.onClickSelect)
    self:addChild(self.selectImg)
    self.selectImg:setVisible(false)
end

FriendChatItem.onClickSelect = function (self, finger_action, x, y, drawing_id_first, drawing_id_current)
    if finger_action == kFingerUp then
        self:setSelectedState(not self.isSelected)
    end
end

FriendChatItem.setEditState = function ( self, isEdit )
    if self.isEditState ~=  isEdit  and  (self.typeItem == FriendChatItem.K_MINE_CHAT or self.typeItem == FriendChatItem.K_FRIEND_CHAT) then
        self.isEditState = isEdit
        self.selectImg:setVisible(isEdit)
        -----调整坐标
        if self.typeItem == FriendChatItem.K_FRIEND_CHAT then
            local headIcon = self:getChildByName("headIcon");
                --headIcon:setPos(10, 0);
                --self.mLeftChat:setPos(120, 18);
            local rightAddPos = 65 --右移
            if not isEdit then
                rightAddPos = 0
            end
            headIcon:setPos(10+rightAddPos,0)
            self.mLeftChat:setPos(120+rightAddPos,18)
        end
    end
end

FriendChatItem.setSelectedState = function ( self, isSelected )
    if self.isSelected ~= isSelected and self.isEditState then  -- 编辑状态 才可操作 是否选择
        self.isSelected = isSelected
        if self.isSelected then
            self.selectImg:setFile("Hall/chat/select.png");
        else
            self.selectImg:setFile("Hall/chat/unselect.png");
        end
    end
end

-- 设置 loading 状态
-- state : 0 正在发关 1 已发送 -1 发送失败
FriendChatItem.setState = function(self, state)
    -- body
    if state == 0 then
        if self.mImgLoading == nil then
            self.mImgLoading = UICreator.createImg("friend/loading.png");
            self:addChild(self.mImgLoading);
        else
            self.mImgLoading:setFile("friend/loading.png");
        end

        if not DrawingBase.checkAddProp(self.mImgLoading, 1) then
            self.mImgLoading:removeProp(1);
        end
        self.mImgLoading:addPropRotate(1, kAnimRepeat, 500, 0, 0, 360, kCenterDrawing, 0, 0);

        -- 设置坐标
        if self.mLeftChat then
            local x, y = self.mLeftChat:getPos();
            local w, h = self.mLeftChat:getSize();
            local lw, lh = self.mImgLoading:getSize();

            self.mImgLoading:setPos(x + w + 5, y +(h - lh) / 2);
        elseif self.mRightChat then
            local x, y = self.mRightChat:getPos();
            local w, h = self.mRightChat:getSize();
            local lw, lh = self.mImgLoading:getSize();

            self.mImgLoading:setPos(x - lw - 5, y +(h - lh) / 2);
        end



    elseif state == 1 then
        if self.mImgLoading ~= nil then
            self:removeChild(self.mImgLoading, true);
            self.mImgLoading = nil;
        else
        end
    elseif state == -1 then
        if self.mImgLoading == nil then
            self.mImgLoading = UICreator.createImg("friend/samll_waring.png");
            self:addChild(self.mImgLoading);
        else
            self.mImgLoading:setFile("friend/samll_waring.png");
        end

        if not DrawingBase.checkAddProp(self.mImgLoading, 1) then
            self.mImgLoading:removeProp(1);
        end

        -- 设置坐标
        if self.mLeftChat then
            local x, y = self.mLeftChat:getPos();
            local w, h = self.mLeftChat:getSize();
            local lw, lh = self.mImgLoading:getSize();

            self.mImgLoading:setPos(x + w + 5, y +(h - lh) / 2);
        elseif self.mRightChat then
            local x, y = self.mRightChat:getPos();
            local w, h = self.mRightChat:getSize();
            local lw, lh = self.mImgLoading:getSize();

            self.mImgLoading:setPos(x - lw - 5, y +(h - lh) / 2);

            self.mRightChat:setPickable(true);
            self.mRightChat:setOnClick(self, function(self)
                -- body
                self.mRightChat:setPickable(false);

                if self.mClickFunc then
                    self.mClickFunc(self.mClickObj, self);
                end
            end );
        end

    end
end


FriendChatItem.addChild = function(self, child)
    -- body
    DrawingBase.addChild(self, child);

    local childW, childH = child:getSize();
    local w, h = self:getSize();

    self:setSize(w, math.max(h, childH));

end

-- 创建头像
FriendChatItem.createHeadIcon = function(self, sex, headIconDir)
    local isExist, localDir = NativeManager.getInstance():downloadImage(headIconDir);
    DebugLog("isExist:"..tostring(isExist));
    DebugLog("headIconDir:"..tostring(headIconDir));
    DebugLog("localDir:"..tostring(localDir));
    if not isExist then
        -- 图片未下载
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

    local img_photo = UICreator.createImg("Hall/chat/head_bg.png");
    img_photo:setName("headIcon");
    --img_photo:setSize(100, 100);
    setMaskImg(img_photo,"Hall/chat/headMask.png",localDir)
    return img_photo;
end

-- 创建聊天内容

FriendChatItem.createLeftChat = function(self, text)
    DebugLog("FriendChatItem.createLeftChat ".. text)
    -- body
    -- 计算文字宽高
    local chatText = new(Text, text, 0, 0, kAlignTopLeft, "", 30, 90, 30, 20);

    -- 说明只有一行
    if chatText.m_res.m_width > 500 then
        chatText = new(TextView, text, 500, 0, kAlignTopLeft, "", 30, 90, 30, 20);
    end
    chatText:setSize(chatText.m_res.m_width, chatText.m_res.m_height);

    local chatBg = new(Image, "Hall/chat/chatLeft.png", nil, nil, 30, 30, 50, 14);

    local w, h = chatText:getSize();
    local textH = h
    if h < 64 then
        h = 64
    end
    chatBg:setSize(w + 40 + 30, h+20);
    chatText:setPos(40, (h+20)/2 - textH/2 );
    chatBg:addChild(chatText);

    return chatBg;
end

FriendChatItem.createRightChat = function(self, text)
    -- body

    -- 计算文字宽高
    local chatText = new(Text, text, 0, 0, kAlignTopLeft, "", 30, 90, 30, 20);

    if chatText.m_res.m_width > 500 then
        chatText = new(TextView, text, 500, 0, kAlignTopLeft, "", 30, 90, 30, 20);
    end

    chatText:setSize(chatText.m_res.m_width, chatText.m_res.m_height);

    local chatBg = new(Button, "Hall/chat/chatRight.png", nil, nil, nil, 30, 30, 50, 14);

    chatBg:setPickable(false);

    local w, h = chatText:getSize();
    local textH = h
    if h < 64 then
        h = 64
    end
    chatBg:setSize(w + 30 + 40, h + 20);
    chatText:setPos(30, (h+20)/2 - textH/2 );
    chatBg:addChild(chatText);

    return chatBg;
end

FriendChatItem.createChatTime = function(self, text)
    chatText = new(Text, text, 0, 0, kAlignCenter, nil, 26, 0x94, 0x32, 0x00);
    --timeBg = new(Image, "friend/chat_time_bg.png");
    chatText:setAlign(kAlignCenter);
    --timeBg:addChild(chatText);
    return chatText;
end

FriendChatItem.createChatTips = function(self, text)
    chatText = new(Text, text, 0, 0, kAlignCenter, nil, 26, 0x4b, 0x2b, 0x1c);
    chatText:setAlign(kAlignCenter);
    return chatText;
end

FriendChatItem.setOnClick = function(self, obj, func)
    -- body\
    self.mClickObj = obj;
    self.mClickFunc = func;
end

FriendChatItem.getText = function(self)
    -- body
    return self.mText or "";
end
FriendChatItem.getId = function(self)
    -- body
    return self.mId or 0;
end


FriendChatItem.nativeCallEvent = function(self, _param, _detailData)
    if _param == kDownloadImageOne then
        if _detailData == self.mHeadIconDir then
            local headIcon = self:getChildByName("headIcon");
            if headIcon then
                setMaskImg(headIcon,"Hall/hallRank/head_mask.png",self.mHeadIconDir)
                --headIcon:setFile(self.mHeadIconDir);
                --headIcon:setSize(100, 100);
            end
        end
    end
end
