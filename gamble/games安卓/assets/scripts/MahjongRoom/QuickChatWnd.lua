
local roomChatLayout = require(ViewLuaPath.."roomChatLayout");
local VIPAnimIconPin_map = require("qnPlist/VIPAnimIconPin")
require("Animation/UtilAnim/voiceAnim")
require("MahjongCommon/ExchangePopu");
-- require("MahjongData/BroadcastMsgManager");
local faceAnimNormal_map = require("qnPlist/faceAnimNormal")


QuickChatWnd = class(CustomNode);

QuickChatWnd.chatStr = {
    "速度些撒，都又少打两盘了",
    "催啥子，我在想割哪张",
    "你们太要不得了，咋只晓得按到我割喃",
    "你们耍的安逸哦，我也来参一个",
    "输家不开口，赢家不许走哈",
    "再打一盘我就走了哈，你们慢慢耍",
    "点花我也割了哈，不得再放你娃些了",
    "美女，你割啥子，我打给你哇"
};

QuickChatWnd.mandarinChatStr = {
    "大家好！很高兴见到各位！",
    "快点吧,我等到花儿都谢了！",
    "不要走！决战到天亮！",
    "你是帥哥还是美女？",
    "君子报仇,十盘不算晚!",
    "快放炮啊,我都等得不耐烦了!",
    "真不好意思,又胡啦!哈哈~",
    "打错了,呜呜~~"
};

QuickChatWnd.canSendFaceOrText = true;


QuickChatWnd.ctor = function(self)
    -- self.cover:setFile("Commonx/blank.png"); -- 透明底图

    self.layout = SceneLoader.load(roomChatLayout);
    self:addChild(self.layout);
    self.bg = publ_getItemFromTree(self.layout, { "bg" });
    self.bg:setEventTouch(self, function(self)
        -- nothing
    end );

    self.faceBg = publ_getItemFromTree(self.layout, { "faceBg" });
    self.chatBg = publ_getItemFromTree(self.layout, { "chatBg" });
    self.sendBtn = publ_getItemFromTree(self.layout, { "send" });
    self.editText = publ_getItemFromTree(self.layout, { "inputBg", "inputText" });
    self.editText:setScrollBarWidth(0);
    self.editText:setHintText("点击输入内容", 0x50, 0x32, 0x14);

    self.t1 = publ_getItemFromTree(self.layout, { "tag1_focus" });
    self.t1Unfocus = publ_getItemFromTree(self.layout, { "tag1_unfocus" });
    self.t2 = publ_getItemFromTree(self.layout, { "tag2_focus" });
    self.t2Unfocus = publ_getItemFromTree(self.layout, { "tag2_unfocus" });
    self.t3 = publ_getItemFromTree(self.layout, { "tag3_focus" });
    self.t3Unfocus = publ_getItemFromTree(self.layout, { "tag3_unfocus" });
    self.t4 = publ_getItemFromTree(self.layout, { "tag4_focus" });
    self.t4Unfocus = publ_getItemFromTree(self.layout, { "tag4_unfocus" });

    self.addPopu = publ_getItemFromTree(self.layout, { "inputPopu" });
    self.addPopuEditText = publ_getItemFromTree(self.layout, { "inputPopu", "addinput" });
    self.addPopuAddBtn = publ_getItemFromTree(self.layout, { "inputPopu", "add" });
    self.addPopu:setVisible(false);
    self.addPopuAddBtn:setOnClick(self, function(self)
        if QuickChatWnd.addNormalAction(self, self.addPopuEditText:getText()) then
            self:recreateChatNode();
        end
        self.addPopu:setVisible(false);
    end );

    -- self.editText.m_drawing:setEventTouch(self, function(self, finger_action, x, y, drawing_id_first, drawing_id_current)
    --     TextView.onEventTouch(self.editText, finger_action, x, y, drawing_id_first, drawing_id_current);
    --     if finger_action == kFingerDown then
    --         self.editText.m_startX = x;
    --         self.editText.m_startY = y;
    --         self.editText.m_touching = true;
    --     elseif finger_action == kFingerUp then
    --         if not self.editText.m_touching then return end;

    --         self.editText.m_touching = false;

    --         local diffX = math.abs(x - self.editText.m_startX);
    --         local diffY = math.abs(y - self.editText.m_startY);
    --         if diffX > self.editText.m_maxClickOffset
    --             or diffY > self.editText.m_maxClickOffset
    --             or(not self.editText.m_enable)
    --             or(drawing_id_first ~= drawing_id_current) then
    --             return;
    --         end

    --         EditTextGlobal = self.editText;

    --         local x, y = self:getAbsolutePos();
    --         local actualX = x * System.getLayoutScale();
    --         local actualY = y * System.getLayoutScale();


    --         local w, h = self:getSize();
    --         local actualW = w * System.getLayoutScale();
    --         -- local actualH= h * System.getLayoutScale();
    --         local actualH = 0;
    --         if System.getPlatform() == kPlatformAndroid then
    --             actualH =(h + 12) * System.getLayoutScale();
    --             actualY =(y + 12) * System.getLayoutScale();
    --         else
    --             actualH = h * System.getLayoutScale();
    --         end

    --         self.editText:setVisible(false);

    --         local str = self.editText:getText(self.editText);
    --         if "点击输入内容" == str then
    --             str = "";
    --         end

    --         ime_open_edit(str,
    --         "",
    --         kEditBoxInputModeAny,
    --         kEditBoxInputFlagInitialCapsSentence,
    --         kKeyboardReturnTypeDone,
    --         self.editText.m_maxLength or -1, "global", self.editText.m_fontName or "",(self.editText.m_res.m_fontSize or 24) * System.getLayoutScale(),
    --         self.editText.m_textColorR, self.editText.m_textColorG, self.editText.m_textColorB,
    --         actualX, actualY, actualW, actualH);
    --         EditTextGlobal.setText(EditTextGlobal, "");
    --     end
    -- end );

    -- self.editText:setOnTextChange(self, function(self)
    --     local str = stringFormatWithString(self.editText:getText(), GameConstant.chatMaxCharNum, true);
    --     if not str or "" == str then
    --         str = "点击输入内容";
    --         self.editText:setText(str, nil, nil, 0x50, 0x32, 0x14);
    --     else
    --         self.editText:setText(str, nil, nil, 0x4b, 0x2b, 0x1c);
    --     end


    -- end );

    self.sendBtn:setOnClick(self, function(self)
        local str = self.editText:getText();
        if "点击输入内容" ~= str and str ~= ""  and self:sendcheckAndMsg(str) then
            self:hide();
        else
            Banner.getInstance():showMsg("您发送的信息为空。");
        end
    end );

    self.maxSaveMsgNum = 20;
    -- 常用语保存的最大数目
    self.chatLog = { };
    -- 聊天记录（仅保存当前局）
    self.curMsg = { };
    -- 当前的常用语

    self.curPlayerMid = tonumber(GameConstant.isSingleGame and GameConstant.myMid or PlayerManager.getInstance():myself().mid or 0);
    self.hasSaveMsg = g_DiskDataMgr:getUserData(self.curPlayerMid,'saveChatMsg',0)
    -- 本地是否有保存常用语

    if self.hasSaveMsg == 0 or self.curPlayerMid < 1 then
        -- 未有记录或是未登录
        local language = g_DiskDataMgr:getAppData("language", kSichuanese)
        if language == kMandarin then
            self.curMsg = publ_deepcopy(QuickChatWnd.mandarinChatStr);
        else
            self.curMsg = publ_deepcopy(QuickChatWnd.chatStr);

        end
    else
        self:loadMsg();
        -- 加载本地保存的常用语
    end

    self:createFacePanel();
    -- 表情
    self:createChatPanel();
    -- 常用语
    self:changeShowFace(true);
    self:changeShowMsg(true);
    self.t1Unfocus:setType(Button.Gray_Type)
    self.t2Unfocus:setType(Button.Gray_Type)
    self.t3Unfocus:setType(Button.Gray_Type)
    self.t4Unfocus:setType(Button.Gray_Type)
    self.t1Unfocus:setOnClick(self, function(self)
        self:changeShowFace(true);
    end );
    self.t2Unfocus:setOnClick(self, function(self)
        self:changeShowFace(false);
    end );
    self.t3Unfocus:setOnClick(self, function(self)
        self:changeShowMsg(true);
    end );
    self.t4Unfocus:setOnClick(self, function(self)
        self:changeShowMsg(false);
    end );
    -- local anim = self:addPropScale(0 , kAnimNormal , 200 , -1 , 0.8 , 1.0 , 0.8 , 1.0 , kCenterDrawing);
    -- anim:setEvent(self , function( self )
    -- self:removeProp(0);
    self:setCoverTransparent()

    if PlatformConfig.platformWDJ == GameConstant.platformType or
        PlatformConfig.platformWDJNet == GameConstant.platformType then
        self.addPopu:setFile("Login/wdj/Room/chat/add_exp_bg.png");
        self.bg:setFile("Login/wdj/Room/chat/bg.png");
        self.t1:setFile("Login/wdj/Room/chat/selectTab.png");
        self.t2:setFile("Login/wdj/Room/chat/selectTab.png");
        self.t3:setFile("Login/wdj/Room/chat/selectTab.png");
        self.t4:setFile("Login/wdj/Room/chat/selectTab.png");
        self.t1Unfocus:setFile("Login/wdj/Room/chat/unselectTab.png");
        self.t2Unfocus:setFile("Login/wdj/Room/chat/unselectTab.png");
        self.t3Unfocus:setFile("Login/wdj/Room/chat/unselectTab.png");
        self.t4Unfocus:setFile("Login/wdj/Room/chat/unselectTab.png");
    end
    -- end);
end

-- 加载常用语
QuickChatWnd.loadMsg = function(self)
    DebugLog("QuickChatWnd.loadMsg")
    local len = g_DiskDataMgr:getFileKeyValue('chatNormalDialog'..self.curPlayerMid, 'chatLen', 0)
    self.curMsg = { };
    for i = 1, len do
        local msg = g_DiskDataMgr:getFileKeyValue('chatNormalDialog'..self.curPlayerMid, 'chatItem_'..i, '')
        table.insert(self.curMsg, msg);
    end

    -- 根据语言类型替换
    local tempStrTable = g_DiskDataMgr:getAppData("language", kSichuanese) == kMandarin and QuickChatWnd.mandarinChatStr or
    QuickChatWnd.chatStr;

    for k, v in pairs(tempStrTable) do
        self.curMsg[k] = v;
    end

end

-- 保存常用语
QuickChatWnd.saveMsg = function(self)
    DebugLog("QuickChatWnd.saveMsg")
    if self.curPlayerMid < 1 then
        return;
    end
    g_DiskDataMgr:clearFile('chatNormalDialog'..self.curPlayerMid)
    local index = 0;
    for k, v in pairs(self.curMsg) do
        index = index + 1;
        g_DiskDataMgr:setFileKeyValue('chatNormalDialog'..self.curPlayerMid, 'chatItem_'..index, v)
    end
    g_DiskDataMgr:setFileKeyValue('chatNormalDialog'..self.curPlayerMid, 'chatLen', index)
    g_DiskDataMgr:setUserData(self.curPlayerMid,'saveChatMsg',1)
    -- 本地是否有保存常用语
end

-- 改变显示表情
QuickChatWnd.changeShowFace = function(self, isNormalFace)
    self.addPopu:setVisible(false);
    if isNormalFace then
        self.t1:setVisible(true);
        self.t1Unfocus:setVisible(false);
        self.t2:setVisible(false);
        self.t2Unfocus:setVisible(true);
        self.faceView:setVisible(true);
        if self.vipFaceView then
            self.vipFaceView:setVisible(false);
        end
    else
        self.t1:setVisible(false);
        self.t1Unfocus:setVisible(true);
        self.t2:setVisible(true);
        self.t2Unfocus:setVisible(false);
        self.faceView:setVisible(false);
        if not self.vipFaceView then
            self:openVipFaceTag();
        end
        self.vipFaceView:setVisible(true);
    end
end

-- 改变显示的语句
QuickChatWnd.changeShowMsg = function(self, isNormalMsg)
    self.addPopu:setVisible(false);
    if isNormalMsg then
        self.t3:setVisible(true);
        self.t3Unfocus:setVisible(false);
        self.t4:setVisible(false);
        self.t4Unfocus:setVisible(true);
        self.chatNode:setVisible(true);
        if self.chatLogNode then
            self.chatLogNode:setVisible(false);
        end
    else
        self.t3:setVisible(false);
        self.t3Unfocus:setVisible(true);
        self.t4:setVisible(true);
        self.t4Unfocus:setVisible(false);
        self.chatNode:setVisible(false);
        if not self.chatLogNode then
            self:openChatLogTag();
        end
        self.chatLogNode:setVisible(true);
    end
end

-- 添加常用语
QuickChatWnd.addNormalAction = function(self, msg)
    if self.curPlayerMid < 1 then
        Banner.getInstance():showMsg("常用语功能登录后才能使用！");
        return false;
    end
    if not PlayerManager.getInstance():myself():checkVipStatu(Player.VIP_CYY) then
        Banner.getInstance():showMsg("充值成为vip,使用诸多特权！");
        return false;
    end

    if #self.curMsg >= self.maxSaveMsgNum then
        Banner.getInstance():showMsg("最多保存" .. self.maxSaveMsgNum .. "条常用语！");
        return false;
    end
    if not msg then
        DebugLog(" add msg error , msg is nil ! ");
        return false;
    end
    local msg1 = publ_trim(msg);
    if string.len(msg1) < 1 then
        DebugLog(" add msg error , msg len is 0 ! ");
        return false;
    end
    for k, v in pairs(self.curMsg) do
        if GameString.convert2Platform(publ_trim(v)) == GameString.convert2Platform(publ_trim(msg)) then
            DebugLog(" add msg error , has the same msg ! ");
            return false;
        end
    end
    table.insert(self.curMsg, msg);
    self.hasChangeSaveMsg = true;
    return true;
end

-- 移除常用语
QuickChatWnd.removeAction = function(self, msg)
    if not PlayerManager.getInstance():myself():checkVipStatu(Player.VIP_CYY) then
        Banner.getInstance():showMsg("充值成为vip,使用诸多特权！");
        return false;
    end
    for k, v in pairs(self.curMsg) do
        if v == msg then
            table.remove(self.curMsg, k);
            self.hasChangeSaveMsg = true;
            return true;
        end
    end
    return false;
end

function QuickChatWnd.openVipFaceTag(self)
    self.vipFaceView = new(ScrollView, 0, 0, self.faceBg.m_width, self.faceBg.m_height, false);
    self.vipFaceView:setDirection(kVertical);
    self.faceBg:addChild(self.vipFaceView);
    self:createVipFaceNode();
    self.vipFaceView:addChild(self.vipFaceNode);
end

QuickChatWnd.createFacePanel = function(self)
    self.faceView = new(ScrollView, 0, 0, self.faceBg.m_width, self.faceBg.m_height, false);
    self.faceView:setDirection(kVertical);
    self.faceBg:addChild(self.faceView);
    self:createNormalFaceNode();
    self.faceView:addChild(self.faceNode);
end

-- vip表情节点
QuickChatWnd.createVipFaceNode = function(self)
    self.vipFaceNode = new(Node);
    local x, y = 0, 0;
    for i = 1, 23 do
        local faceBtn = UICreator.createBtn(VIPAnimIconPin_map["vip" .. i .. ".png"], x + 13, y);
        faceBtn:setSize(100, 100);
        if (1 ~= GameConstant.faceIsCanUse) then
            faceBtn:setColor(171, 172, 175);
        end
        faceBtn:setEventTouch(self, function(self, finger_action, x, y, drawing_id_first, drawing_id_current)
            faceBtn.m_showEnbaleFunc(faceBtn, true);
            if (1 ~= GameConstant.faceIsCanUse) then
                faceBtn:setColor(171, 172, 175);
            end
            if kFingerDown == finger_action then
                GameEffect.getInstance():play("BUTTON_CLICK");
                self.bFingerMove = false;
                self.fingerMoveDist = y;
                faceBtn.m_showEnbaleFunc(faceBtn, false);
            elseif kFingerMove == finger_action then
                if math.abs(y - self.fingerMoveDist) > 10 then
                    self.bFingerMove = true;
                end
                faceBtn.m_showEnbaleFunc(faceBtn, false);
            elseif not self.bFingerMove then
                if not PlayerManager.getInstance():myself():checkVipStatu(Player.VIP_BQB) then
                    Banner.getInstance():showMsg("充值成为vip,使用诸多特权！");
                    return false;
                end
                self:faceClick(i, true);
            end
        end );
        self.vipFaceNode:addChild(faceBtn);
        if i % 3 == 0 then
            y = y + 100;
            x = 0;

            local line = UICreator.createImg("Room/chat/quick_lb_line.png", x, y);
            line:setSize(381, 2);
            self.vipFaceNode:addChild(line);
            if PlatformConfig.platformWDJ == GameConstant.platformType or
                PlatformConfig.platformWDJNet == GameConstant.platformType then
                line:setFile("Login/wdj/Room/chat/quick_lb_line.png");
            end
        else
            x = x + 127;
        end
    end

    -- 如果表情的数量不被3整除的话
    y = y + 100;


    local line = UICreator.createImg("Room/chat/quick_pt_line.png", 127, 0)
    line:setSize(2, y);
    self.vipFaceNode:addChild(line);
    line = UICreator.createImg("Room/chat/quick_pt_line.png", 254, 0)
    line:setSize(2, y);
    self.vipFaceNode:addChild(line);
    if PlatformConfig.platformWDJ == GameConstant.platformType or
        PlatformConfig.platformWDJNet == GameConstant.platformType then
        line:setFile("Login/wdj/Room/chat/quick_pt_line.png");
    end

    self.vipFaceNode:setSize(284, y);
end


-- 常用表情
QuickChatWnd.createNormalFaceNode = function(self)
    self.faceNode = new(Node);
    local x, y = 0, 0;
    for i = 1, 27 do
        local faceBtn = UICreator.createBtn(faceAnimNormal_map["face" .. i .. ".png"], x + 13, y);
        if (1 ~= GameConstant.faceIsCanUse) then
            faceBtn:setColor(171, 172, 175);
        end
        faceBtn:setEventTouch(self, function(self, finger_action, x, y, drawing_id_first, drawing_id_current)
            faceBtn.m_showEnbaleFunc(faceBtn, true);
            if (1 ~= GameConstant.faceIsCanUse) then
                faceBtn:setColor(171, 172, 175);
            end
            if kFingerDown == finger_action then
                GameEffect.getInstance():play("BUTTON_CLICK");
                self.bFingerMove = false;
                self.fingerMoveDist = y;
                faceBtn.m_showEnbaleFunc(faceBtn, false);
            elseif kFingerMove == finger_action then
                if math.abs(y - self.fingerMoveDist) > 10 then
                    self.bFingerMove = true;
                end
                faceBtn.m_showEnbaleFunc(faceBtn, false);
            elseif not self.bFingerMove then
                self:faceClick(i);
            end
        end );
        self.faceNode:addChild(faceBtn);
        if i % 3 == 0 then
            y = y + 100;
            x = 0;

            if i ~= 27 then
                local line = UICreator.createImg("Room/chat/quick_lb_line.png", x, y);
                line:setSize(381, 2);
                self.faceNode:addChild(line);
                if PlatformConfig.platformWDJ == GameConstant.platformType or
                    PlatformConfig.platformWDJNet == GameConstant.platformType then
                    line:setFile("Login/wdj/Room/chat/quick_lb_line.png");
                end
            end
        else
            x = x + 127;
        end
    end
    local line = UICreator.createImg("Room/chat/quick_pt_line.png", 127, 0)
    line:setSize(2, y);
    self.faceNode:addChild(line);
    line = UICreator.createImg("Room/chat/quick_pt_line.png", 254, 0)
    line:setSize(2, y);
    if PlatformConfig.platformWDJ == GameConstant.platformType or
        PlatformConfig.platformWDJNet == GameConstant.platformType then
        line:setFile("Login/wdj/Room/chat/quick_pt_line.png");
    end
    self.faceNode:addChild(line);

    self.faceNode:setSize(284, y);
end

QuickChatWnd.recreateChatNode = function(self)
    local isVisible = self.chatNode and self.chatNode:getVisible();
    self:removeChatNode();
    self:createChatNode();
    self.chatNode:setVisible(isVisible);
end

QuickChatWnd.recreateChatLogNode = function(self)
    local isVisible = self.chatLogNode and self.chatLogNode:getVisible();
    self:removeChatLogNode();
    self:createChatLogNode();
    self.chatLogNode:setVisible(isVisible);
end

QuickChatWnd.removeChatNode = function(self)
    if not self.chatNode then
        return;
    end
    self.chatBg:removeChild(self.chatNode, true);
end

QuickChatWnd.removeChatLogNode = function(self)
    if not self.chatLogNode then
        return;
    end
    self.chatBg:removeChild(self.chatLogNode, true);
    self.chatLogNode = nil;
end

QuickChatWnd.createChatNode = function(self)
    self:createChatList();
    self.chatBg:addChild(self.chatNode);
end

function QuickChatWnd.openChatLogTag(self)
    self:createChatLogNode();
end

QuickChatWnd.createChatLogNode = function(self)
    self:createChatLogList();
    self.chatBg:addChild(self.chatLogNode);
end

QuickChatWnd.createChatPanel = function(self)
    self:createChatNode();
end

-- 常用语节点
QuickChatWnd.createChatList = function(self)

    local data = { };
    for k, v in pairs(self.curMsg) do
        local d = { };
        d.msg = v;
        d.cType = ChatItem.typeChatMsg;
        d.obj = self;
        table.insert(data, d);
    end
    local d = { };
    d.cType = ChatItem.typeChatAddMsg;
    d.obj = self;
    table.insert(data, d);
    if #data < 1 then
        return;
    end
    local adapter = new(CacheAdapter, ChatItem, data);
    self.chatNode = new(ListView, 0, 0, 380, 350);
    -- 常用语
    self.chatNode:setAlign(kAlignTopLeft);
    self.chatNode:setAdapter(adapter);
    self.chatNode:setScrollBarWidth(0);
    self.chatNode:setMaxClickOffset(5);
end


-- 聊天记录节点
QuickChatWnd.createChatLogList = function(self)
    self.chatLogNode = new(Node);
    local data = { };
    for k, v in pairs(self.chatLog) do
        local d = { };
        d.logType = v.type or "chat" 
        d.msg     = v.msg or "";
        d.cType   = ChatItem.typeChatLog;
        d.filename= v.filename
        d.seconds = v.seconds
        d.time    = v.time
        d.name    = v.name 
        d.obj = self;
        table.insert(data, 1, d);
    end
    if #data < 1 then
        return;
    end
    local adapter = new(CacheAdapter, ChatItem, data);
    self.chatLogNode = new(ListView, 0, 0, 380, 350);
    -- 常用语
    self.chatLogNode:setAlign(kAlignTopLeft);
    self.chatLogNode:setAdapter(adapter);
    self.chatLogNode:setScrollBarWidth(0);
    self.chatLogNode:setMaxClickOffset(5);
end

QuickChatWnd.normalFace = 100; -- 普通表情
QuickChatWnd.huliFace = 0; -- 狐狸表情
QuickChatWnd.meiziFace = 400;-- 妹子表情

QuickChatWnd.faceClick = function(self, num, isVip)
    DebugLog("click face " .. num);
    self:hide();

    if not isPlatform_Win32() and GameConstant.iosDeviceType<=0 and not publ_IsResDownLoaded(GameConstant.DOWNLOAD_RES_TYPE_FACE) then
        if GameConstant.isDownloading then
            Banner.getInstance():showMsg("下载中，您可以先进行游戏");
            return;
        end
        GlobalDataManager.getInstance():downloadRes(GameConstant.DOWNLOAD_RES_TYPE_FACE, true);
    else
        DebugLog("show face");
        local faceValue = -1;
        if isVip then
            if (num > 0 and num < 13) then
                faceValue = QuickChatWnd.meiziFace + num;
            elseif (num > 12 and num < 24) then
                faceValue = QuickChatWnd.huliFace + num - 12;
            end
        else
            faceValue = QuickChatWnd.normalFace + num;
        end

        if faceValue == -1 then
            DebugLog("send msg error : faceValue error.");
            return;
        end

        if 1 ~= GameConstant.faceIsCanUse then
            local msg = "表情资源需要下载后使用，请您到设置界面下载";
            Banner.getInstance():showMsg(msg);
            return;
        end


        if not QuickChatWnd.canSendFaceOrText then
            local t = { };
            t.userId = self.curPlayerMid;
            t.faceType = faceValue;
            EventDispatcher.getInstance():dispatch(SocketManager.s_serverMsg, t, CLIENT_COMMAND_SEND_FACE);
        else
            -- 发送网络命令
            local t = { };
            t.faceType = faceValue;
            SocketSender.getInstance():send(CLIENT_COMMAND_SEND_FACE, t);
        end
    end

end

QuickChatWnd.chatClick = function(self, str)
    if self:sendcheckAndMsg(str) then
        self:hide();
    end
end

-- 检测字符串是否合法，并且发送
QuickChatWnd.sendcheckAndMsg = function(self, str)
    if not str or #publ_trim(str) < 1 then
        DebugLog("发送聊天信息失败，字符不合法。");
        return false;
    end
    if not QuickChatWnd.canSendFaceOrText then
        local t = { };
        t.userId = self.curPlayerMid;
        t.chatinfo = str;
        EventDispatcher.getInstance():dispatch(SocketManager.s_serverMsg, t, CLIENT_COMMAND_USER_CHAT);
        return true;
    else
        -- 发送网络命令
        local t = { };
        t.msg = str;
        self.editText:setText("");
        SocketSender.getInstance():send(CLIENT_COMMAND_USER_CHAT, t);
        return true;
    end
end

QuickChatWnd.show = function(self, chatLogs)
    self.chatLog = chatLogs or { };
    self:recreateChatLogNode();
    self.addPopu:setVisible(false);
    CustomNode.show(self);
end

QuickChatWnd.hide = function(self)
    CustomNode.hide(self);
end

QuickChatWnd.dtor = function(self)
    if self.hasChangeSaveMsg then
        -- 有修改过常用语，则保存起来
        self.hasChangeSaveMsg = false;
        self:saveMsg();
    end
    -- self:hide();
    self:removeAllChildren();
end


--开始播放
function QuickChatWnd:startPlay( filename )
    self:stopAllPlayVoice(filename)

    local tbl = {}
    tbl.filePath = filename or ""
    native_to_java(kStartPlayVoice, json.encode(tbl))
    RoomScene_instance:pauseGameSound()
    ---停止之前播放中的

    RoomScene_instance:stopAllPlayVoiceOnDesk()

end

function QuickChatWnd:stopAllPlayVoice( notfile )
    if self.chatLogNode then --self.m_views[i]
        if self.chatLogNode.m_views then 
            for i=1,#self.chatLogNode.m_views do
                local ci = self.chatLogNode.m_views[i]
                if ci and ci.voiceAnim and ci.voiceAnim:isPlaying()then 
                    if notfile and ci.voiceAnim._curFile and notfile == ci.voiceAnim._curFile then 
                    else 
                        ci.voiceAnim:stop()
                    end 
                end 
            end
        end 
    end 
end
-- 聊天记录和常用语列表的子项节点
ChatItem = class(Node)

ChatItem.typeChatMsg = 1; -- 常用语
ChatItem.typeChatAddMsg = 2; -- 添加常用语
ChatItem.typeChatLog = 3; -- 聊天记录

ChatItem.ctor = function(self, data)
    if not data then
        return;
    end
    DebugLog("ChatItem.ctor")
    self.msg = "";
    self.obj = data.obj;
    if data.cType == ChatItem.typeChatMsg then
        self.msg = data.msg;
        self:setSize(350, 60);
        local btn = self:createMsg(data.msg, true);
        btn:setOnClick(self, ChatItem.sendMsg);
        local flg = true;
        for k, v in pairs(QuickChatWnd.chatStr) do
            DebugLog(v .. " " .. tostring(v == data.msg) .. " " .. data.msg)

            if v == data.msg then
                flg = false;
                break;
            end
        end
        DebugLog("flg: " .. tostring(flg))
        if flg then
            for k, v in pairs(QuickChatWnd.mandarinChatStr) do
                DebugLog(v .. " " .. tostring(v == data.msg) .. " " .. data.msg)
                if v == data.msg then
                    flg = false;
                    break;
                end
            end
        end
        DebugLog("flg: " .. tostring(flg))
        if flg then
            local delBtn = UICreator.createBtn("Room/chat/delete.png", 317, 12);
            self:addChild(delBtn);
            delBtn:setOnClick(self, ChatItem.delMsg);
        end
    elseif data.cType == ChatItem.typeChatLog then
        
        self.msg  = data.msg or "";
        self.type = data.logType 
        --self.file = data.file 
        self.time = data.seconds or 1
        self:setSize(350, 90);
        local chatLogItem    = require(ViewLuaPath.."chatLogItem" )
        local uilayout       = SceneLoader.load(chatLogItem);
        self:addChild(uilayout)    
        publ_getItemFromTree(uilayout,{"nameTime"}):setText(data.name .. "  "..os.date("%H:%M:%S",data.time))
        if self.type == "voice" then 
            self.voiceAnim =  new(VoicePlayAnim,"voicePlayTip",data.filename)
            self.voiceAnim:setSeconds(self.time or 1)
            self.voiceAnim:setCurFile(data.filename)
            self.voiceAnim:setPlayCallback(self.obj,self.obj.startPlay)
            --self.voiceAnim:setAlign(kAlignLeft)
            self.voiceAnim:setPos(10,0)
            publ_getItemFromTree(uilayout,{"view1"}):addChild(self.voiceAnim)
        else 
            publ_getItemFromTree(uilayout,{"view1"}):setEventTouch(self, function(self, finger_action, x, y, drawing_id_first, drawing_id_current)
                if kFingerUp == finger_action then
                    self:sendMsg()
                end
            end )              
            publ_getItemFromTree(uilayout,{"content"}):setText(data.msg,350,50)--0x6d2a00
            local addBtn = UICreator.createBtn("Room/chat/add.png", 317, 60-21);
            self:addChild(addBtn);
            addBtn:setOnClick(self, ChatItem.addMsg);
        end 

    elseif data.cType == ChatItem.typeChatAddMsg then
        self:setSize(350, 60);
        local btn = UICreator.createBtn("Room/chat/addListItem.png", 0, 12);
        btn:setPos(nil, 3);
        btn:setSize(350, btn.m_height - 7);
        self:addChild(btn);
        if PlatformConfig.platformWDJ == GameConstant.platformType or
            PlatformConfig.platformWDJNet == GameConstant.platformType then
            btn:setFile("Login/wdj/Room/chat/addListItem.png");
        end
        btn:setOnClick(self, ChatItem.showAddPopu);
    end
end




-- 发送常用语
ChatItem.sendMsg = function(self)
    self.obj:chatClick(self.msg);
end

-- 添加常用语
ChatItem.addMsg = function(self)
    if self.obj:addNormalAction(self.msg) then
        self.obj:recreateChatNode();
    end
end

-- 删除常用语
ChatItem.delMsg = function(self)
    if self.obj:removeAction(self.msg) then
        self.obj:recreateChatNode();
    end
end

-- 显示添加常用语弹窗
ChatItem.showAddPopu = function(self)
    if not PlayerManager.getInstance():myself():checkVipStatu(Player.VIP_CYY) then
        Banner.getInstance():showMsg("充值成为vip,使用诸多特权！");
        return false;
    end
    self.obj.addPopu:setVisible(true);
    self.obj.addPopuEditText:setText("");
end

ChatItem.createMsg = function(self, msg, isBtn)
    local btn = nil;
    if isBtn then
        btn = UICreator.createBtn("Room/chat/exp_bg.png", 0, 10)
        -- btn = UICreator.createBtn9Grid("Room/chat/exp_bg.png", 0, 10, 20, 20, 25, 25);
        -- else
        -- btn = UICreator.createBtn9Grid("Room/chat/exp_bg.png", 0, 10, 20, 20, 25, 25);
    end
    btn:setSize(350, 50);
    self:addChild(btn);
    msg = stringFormatWithString(msg, 28, true);
    local text = UICreator.createText(msg, 0, 0, 310, 32, kAlignCenter, 24, 118, 61, 43);
    text:setAlign(kAlignCenter);

    if PlatformConfig.platformWDJ == GameConstant.platformType or
        PlatformConfig.platformWDJNet == GameConstant.platformType then
        btn:setFile("Login/wdj/Room/chat/exp_bg.png");
    end
    btn:addChild(text);
    return btn;
end

ChatItem.dtor = function(self)
    self:removeAllChildren();
end
