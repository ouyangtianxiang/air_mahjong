local newMatchApplyLayout = require(ViewLuaPath.."newMatchApplyLayout");
require("MahjongBarrage/BarrageLayer")
require("MahjongRoom/GameResult/CertificateWindow");
require("MahjongHall/Friend/InviteFriendInFMRWindow");
local cardRecordView = require(ViewLuaPath.."cardRecordView");



-- stage = 1:报名阶段 2:预赛阶段 3:淘汰赛阶段 4:决赛阶段 5:比赛结束 8:定时赛预赛阶段 9:定时赛预赛结束排名阶段
MatchApplyWindow = class(SCWindow);

--提示信息
MatchApplyWindow.tipsContents = {
    "比赛中唯一的目的就是保持分数比别人高",
    "开赛时间越久，比赛越刺激",
    "出牌超时，系统自动进入托管",
    "预赛中低于底分将会被淘汰",
    "比赛中途断线，系统自动进入托管",
    "破产后在规定时间内补充金币可回到比赛",
    "破产后若不及时补充金币不论积分多少都将被淘汰",
    "胡牌后番数越高，比赛积分越高",
    "每局只要胡牌就能够获得积分",
    "比赛积分在比赛过程中只增不减",
    "自摸胡牌最高可得3倍积分奖励",
    "名次低于晋级人数也有机会晋级下一轮",
};


MatchApplyWindow.ctor = function(self, data, roomLevel)
    EventDispatcher.getInstance():register(NativeManager._Event, self, self.nativeCallEvent);
    back_event_manager.get_instance():remove_event(self);
    back_event_manager.get_instance():add_event(self,self.onBtnExitClick);

    --请求道具列表
	GlobalDataManager.getInstance():onRequestMyItemList();

    self:setVisible( false );
    self.desUpdateFlag = false;
    self.showHelpDetailFlag = false;
    self.popuNode = new(Node);
    self:addChild(self.popuNode);
    self.popuNode:setFillParent(true, true);

    self.matchAwardRecord = {};--比赛获奖记录
    self.m_last_match_award_list = {};--上次比赛发奖记录
    self.exchangeInfo = {};--比赛兑换信息

    self.myself             = PlayerManager.getInstance():myself();
    self.m_matchInfo        = nil;

    self.scale      = System.getLayoutScale();
    self.sw, self.sh     = System.getScreenWidth(), System.getScreenHeight();

    self.scaleW, self.scaleH    = self.sw /1280, self.sh/720;

    self.window = SceneLoader.load(newMatchApplyLayout);--(matchApplyView);

    self:setWindowNode(self.window);

    local w, h = self.window:getSize();
    self.window:setSize(w * self.scaleW / self.scale, h * self.scaleH / self.scale);
    self:addChild(self.window);

    publ_getItemFromTree(self.window,{"bgImage","win_left"}):setMirror(true,false)

    --禁止窗外关闭
    self.window:setEventTouch(self, function ( self )
    end);

    self:getCtrl();
    self:setControlClickEvent();

    --设置比赛数据
    self:setData(data);


    --获取比赛配置数据
    local level = self.m_data and self.m_data.level or roomLevel;
    if level then
        self.roomLevel = level;
        local roomData = HallConfigDataManager.getInstance():returnMatchDataByLevel(level);
        if roomData then
            self.matchData = roomData;
            self.id = tonumber(roomData.id);
            self.titleImg :setVisible(false);
            self.txtMatchName:setVisible(true);
            self.txtMatchName:setText(self.matchData.name);
        end
    end

    --大奖赛获取玩家是否报名
    if not self.m_data  then
        self:sendPackToServerCheckSign(roomLevel);
    end

    -- 请求比赛邀请的相关信息
    self:request_match_invite_share_info();

    --设置报名界面的数据，title以及下面的奖励图片
    self:setAwardView();

    local matchId = self.m_data and self.m_data.matchId or nil;
    local matchLevel = self.m_data and self.m_data.level or nil;
    --添加弹幕层
    self.barrageLayer = new(BarrageLayer, matchId, matchLevel);
    self.barrageLayer:setLevel(888888);
    self.barrageLayer:setAlign(kAlignCenter);
    self.barrageLayer:setPos(0,0);
    self.barrageLayer:setFillParent(true, true)
    self.bgImage :addChild(self.barrageLayer);


    --大奖赛 ：如果比赛已经开始且已报名，则自动进入比赛 (3-5s)
    self:auto_enter_match();
end

--进入页面:大奖赛 ：如果比赛已经开始且已报名，则自动进入比赛 (3-5s)
MatchApplyWindow.auto_enter_match = function (self)
    DebugLog("[MatchApplyWindow]:auto_enter_match");
    if self.m_data and self.m_data.matchType
        and self.m_data.matchType == GameConstant.matchTypeConfig.award  
        and self.m_data.stage and self.m_data.stage == GameConstant.match_stage.dingshisai_yusai then
            DebugLog("delay:"..tostring(delay));
            local delay = math.random(3, 5);
            Clock.instance():schedule_once(function ()
                    if not self.m_data then
                        DebugLog("self.m_data is nil");
                        return;
                    end 
                    --进入比赛
                    self:toGetTableInfo(self.m_data);
                    GameState.changeState( nil, States.MatchRoom );
            end, delay);
    end
end

-- 进入页面就拉去邀请信息
MatchApplyWindow.request_match_invite_share_info = function (self)
    DebugLog("[MatchApplyWindow]:request_match_invite_share_info");
    if  not self.roomLevel then
        return;
    end
    --比赛配置中的id
    local match_data = HallConfigDataManager.getInstance():returnMatchDataByLevel(self.roomLevel);
    if not match_data then
        DebugLog("match_data is nil :"..tostring(self.roomLevel));
        return;
    end

    local param = {};
    param.id = match_data.id or 0;
    param.match_type = self.m_data and self.m_data.matchType or GameConstant.matchTypeConfig.award;
    param.level = self.roomLevel or 0;
    GlobalDataManager.getInstance():requestMatchInviteShareInfo(param);
end

--设置报名界面的数据，title以及下面的奖励图片
MatchApplyWindow.setAwardView = function (self)
    DebugLog("MatchApplyWindow.setAwardView");
    local roomData = HallConfigDataManager.getInstance():returnMatchDataByLevel(self.roomLevel);
    if roomData then
        --此处需要重置matchdata
        self.matchData = roomData;
        self.id = tonumber(roomData.id);
    else
        for i = 1, #self.award do
            self.award[i].bg:setVisible(false);
        end
        DebugLog("roomData is nil");
        return;
    end
    for i = 1, #self.award do
        self.award[i].bg:setVisible(true);
    end
--    --下载title图片
--    if self.matchData then
----        local isExist, localDir = NativeManager.getInstance():downloadImage(self.matchData.nameUrl);
----        self.nameUrlDir = localDir;
----        if isExist then
----            self.titleImg :setFile(self.nameUrlDir);
----        end
--    end

    --设置奖品图片
    if self.matchData and self.matchData.qian3 and type(self.matchData.qian3) == "table" then
        if self.matchData.qian3 and #self.matchData.qian3 >= 3 then
            for i = 1, 3 do--#self.matchData.qian3 do
                if self.matchData.qian3[i] or self.matchData.qian3[i].pic then
                    local isExist, localDir = NativeManager.getInstance():downloadImage(self.matchData.qian3[i].pic);
                    DebugLog("pic::"..tostring(self.matchData.qian3[i].pic).."localDir::"..tostring(localDir).."isExist:"..tostring(isExist));

                    self.award[i].picName= localDir;
                    if true then--isExist then
                        self.award[i].pic:setVisible(true);
                        self.award[i].pic:setFile(localDir);
                    end
                    local t = stringFormatWithString(self.matchData.qian3[i].t,20,false)
                    self.award[i].t:setText(t);
                end
            end
        else
            DebugLog("self.matchData.qian3 is nil or #self.matchData.qian3 < 3");
        end
    end
end

--设置数据
MatchApplyWindow.setData = function (self, data)

    --大奖赛用的是否报名的标记
    self.hadJoinMatch = (data and data.matchType and true) or false;

    local btn_set = function (b_dajiangsai)
        if b_dajiangsai then
            if not self.m_data then
                self.m_btnJoin:setVisible(not self.hadJoinMatch);
            end
            self.m_btnJoin.t:setText(self.hadJoinMatch and "取消报名" or "报名比赛");
            self.btnHelp:setPos(325, -10);
            self.btn_exchangeInfo:setVisible(true);
        else
            self.btnGame:setVisible(false);
            self.m_btnJoin:setVisible(false);
            self.btn_exchangeInfo:setVisible(false);
            self.btnHelp:setPos(508, -10);
        end
    end 

    if not data then
        btn_set(true);
        return;
    end

    self.m_data = data;

    btn_set(self.m_data.matchType == GameConstant.matchTypeConfig.award);


    self.time = self.m_data.serverTime;
    self.pushKey = os.date("push%m%d%H%M", self.m_data.startTime)

    self.tip:setVisible(true);

    --显示当前参数人数及奖励
    self:toUpdateJoiner(self.m_data);
    if GameConstant.matchTypeConfig.award == self.m_data.matchType or GameConstant.matchTypeConfig.playTime == self.m_data.matchType then
        self:start_timer();
    end
end

-- 1秒定时器
MatchApplyWindow.start_timer = function (self)

    self:stop_timer();
    --定时器
    self.m_timer = Clock.instance():schedule(function ( dt )
        self:updateTime();
    end, 1);
end

MatchApplyWindow.stop_timer = function (self)
    if self.m_timer then
        self.m_timer:cancel()
	    self.m_timer = nil
    end
end




MatchApplyWindow.updateTime = function ( self )
    DebugLog("MatchApplyWindow.updateTime");
    self.time = self.time + 1;
    if self.time < self.m_data.startTime and self.m_data.stage == GameConstant.match_stage.baoming then --未开始预赛
        
        self:util_str_format_2();
         
        local time = self.m_data.startTime - self.time;
        if time == 1 then --赛前1秒
            self.m_btnJoin:setVisible(false);
            self.btnGame:setVisible(true)
            self.btnGame:setGray(false)
            self.btnGame:setPickable(true)
            self:stop_timer();
        end
        if time < 1 then
            self.tip:setVisible(false);
            self:stop_timer();
        end
    elseif self.time > self.m_data.startTime and self.time < self.m_data.yuSaiEndTime then -- 正在预赛
        self:stop_timer();

        self:util_str_format_1();
    elseif self.time < self.m_data.startTime then --决赛/淘汰赛
        self:stop_timer();

        local time = self.m_data.startTime - self.time;
        local str1, str2 = self:getTime(time);
        local str = "#cffffff#s26距离比赛开始还有 #cfffc05#s30"..tostring(str1).." #cffffff#s26"..tostring(str2);
        self:set_tip_rich_text(str ); 
    end
    if self.m_data and GameConstant.matchTypeConfig.award ~= self.m_data.matchType then
        self.btnGame:setVisible(false)
    end
end

MatchApplyWindow.broadcastMsg = function( self )
    DebugLog("MatchApplyWindow.broadcastMsg");

    if not self.myBroadcast then
        self:createBroadcastMSG();
    end
    self.myBroadcast:play();
    if self.broadcastPopWin and self.broadcastPopWin:getVisible() then
        self.broadcastPopWin:flushMesItem();
    end
end
MatchApplyWindow.createBroadcastMSG = function ( self )
    DebugLog("MatchApplyWindow.createBroadcastMSG")
    require("Animation/BroadcastAnimation");
    self.myBroadcast = new(BroadcastAnimation,830,630);
    self.myBroadcast:setAlign(kAlignTop)
    self.myBroadcast:setPos(0,120)
    self:addChild(self.myBroadcast)
    self.myBroadcast:setOnClickedCallback(self, self.OnBroadcastBtnClick)

end
-- 广播条点击事件
MatchApplyWindow.OnBroadcastBtnClick = function(self)
    -- -- 友盟上报喇叭使用次数
    umengStatics_lua(kUmengHallSpeaker);
    if 1 ~= GameConstant.isDisplayBroadcast then
        GameConstant.isDisplayBroadcast = 1;
        g_DiskDataMgr:setAppData('displayBroadcastMessage',GameConstant.isDisplayBroadcast)
    end
    if self.broadcastPopWin then
        self.broadcastPopWin:createMsgItem();
    else
        require("MahjongCommon/BroadcastMsgPop");
        self.broadcastPopWin = new(BroadcastMsgPop);
        self:addChild(self.broadcastPopWin);
    end
end

--按钮时间 显示/隐藏 弹幕
MatchApplyWindow.event_ctrol_barrage = function (self)
    if self.barrageLayer and self.barrageLayer.event_ctrol_barrage then
        self.m_btnBarrage.isOpen = not self.m_btnBarrage.isOpen;
        if self.m_btnBarrage.isOpen then
            self.m_btnBarrage:setFile("apply/btnBarrageOpen.png");
        else
            self.m_btnBarrage:setFile("apply/btnBarrageClose.png");
        end
        self.barrageLayer.event_ctrol_barrage(self.barrageLayer);
    end

end

--显示人数和奖励金币
MatchApplyWindow.toUpdateJoiner = function(self, data)
    if not data or not self.m_data then
        return;
    end


    if data.matchType ~= self.m_data.matchType then
        return;
    end
    self.m_data = data;
    self.time = self.m_data.serverTime;

    if GameConstant.matchTypeConfig.playerNum == self.m_data.matchType 
        or GameConstant.matchTypeConfig.playTime == self.m_data.matchType then
        --人满赛或者新定时赛
            self:config_match_renman_and_xindingshi();
    elseif GameConstant.matchTypeConfig.award == self.m_data.matchType then
        --大奖赛
        self:config_match_award();
    end
end

--未报名比赛，server给的提示；
MatchApplyWindow.showServerTipWhenNoJoinGame = function (self, str, level)
    if not str or not level then
        self:set_tip_rich_text("" ); 
        return;
    elseif str and ((self.m_data and self.m_data.level and self.m_data.level == level) or not self.m_data) then
        self.tip:setVisible(true);

        self.m_btnJoin:setVisible(true)
        self.m_btnJoin:setPickable(true)
        self.m_btnJoin:setGray(false)
        local str = "#cffffff#s26"..str
        self:set_tip_rich_text(str ); 
    else
        self:set_tip_rich_text("" ); 
    end
end

--配置人满赛和新定时赛相关的显示
MatchApplyWindow.config_match_renman_and_xindingshi = function (self)
    if not self.m_data then
        return;
    end
    self.tip:setVisible(true);
    --定时赛
    if self.m_data.matchType == GameConstant.matchTypeConfig.playTime then
        self:util_str_format_2();
    else
    --人满赛
        local str = "#cffffff#s26已报名: "..tostring(self.m_data.currentPerson) .. "/" .. tostring(self.m_data.limitPerson).."      马上要开赛咯！"
        self:set_tip_rich_text(str ); 
    end
end

--设置提示rich text
MatchApplyWindow.set_tip_rich_text = function (self, str)

    if self.m_rich_text and str then
        local w_rich_text = self.tip:getSize();
        w_rich_text = w_rich_text - 60
        self.m_rich_text:setText(str, w_rich_text);
    end
end

MatchApplyWindow.util_str_format_1 = function (self)
    if not self.m_data then
        return;
    end

    local time = self.m_data.yuSaiEndTime - self.time;
    local str1, str2 = self:getTime(time);
    local str3 = "本场积分:" .. self.m_data.jifen .. " 排名:" .. self.m_data.rank;
    local str4 = "比赛将在" .. str1 .. str2.."后结束预赛。";
    local str = "#cffffff#s24"..str3.."#l"..str4;
    self:set_tip_rich_text(str );
end

MatchApplyWindow.util_str_format_2 = function (self)
    if not self.m_data then
        return;
    end

    local time = self.m_data.startTime - self.time;
    local str1, str2 = self:getTime(time);

    local str = "#cffffff#s26距离比赛开始还有 #cfffc05#s30"..tostring(str1).." #cffffff#s26"..tostring(str2).." ".."已报名: "..tostring(self.m_data.currentPerson);
    self:set_tip_rich_text(str ); 
end

--配置大奖赛相关的显示
MatchApplyWindow.config_match_award = function (self)
       

    --报名按钮
    local funSetBtnJoin = function (self, v)
        self.m_btnJoin:setVisible(true)
        self.m_btnJoin:setPickable(v)
        self.m_btnJoin:setGray(not v)
    end
    --参赛按钮
    local funSetBtnGame = function (self, v)
        self.btnGame:setVisible(true)
        self.btnGame:setPickable(v)
        self.btnGame:setGray(not v)
    end
        self.tip:setVisible(true);


    if self.time < self.m_data.startTime and 1 == self.m_data.stage then --未开始预赛
        --可以点击按钮报名
        funSetBtnJoin(self,true);
        --不可以点击按钮参赛
        funSetBtnGame(self,false);

        self:util_str_format_2();
    elseif self.time >= self.m_data.startTime and self.time < self.m_data.yuSaiEndTime then -- 正在预赛
        self.m_btnJoin:setVisible(false);
        funSetBtnGame(self,true);

        self:util_str_format_1();
    elseif self.time >= self.m_data.yuSaiEndTime and self.time < self.m_data.taoTaiStartTime then -- 预赛完等淘汰
        self.m_btnJoin:setVisible(false);
        funSetBtnGame(self,false);
        local str1 = "";
        if 0 == self.m_data.tableNum then
            str1 = "预赛已结束";
        else
            str1 = "预赛即将结束，还有" .. self.m_data.tableNum .. "桌正在游戏";
        end
        local str2 = string.sub(os.date("%X", self.m_data.taoTaiStartTime), 0, 5)  .. "将决定晋级名单(前" .. self.m_data.jinJiNum .. "名晋级)";

        local str = "#cffffff#s24"..str1.."#l"..str2;
        self:set_tip_rich_text(str );
    elseif self.time < self.m_data.startTime and 5 ~= self.m_data.stage then -- 淘汰/决赛
        self.m_btnJoin:setVisible(false);
        funSetBtnGame(self,false);

        local time = self.m_data.startTime - self.time;
        local str1, str2 = self:getTime(time);
        local str3 = "";
        if 3 == self.m_data.stage then
            str3 = "淘汰赛";
        elseif 4 == self.m_data.stage then
            str3 = "决赛";
        end
        local str5 = "正在进行" .. str3;
        local str6 = "距离下轮比赛开赛还有 " .. str1 .. " " .. str2;
        local str = "#cffffff#s24"..str5.."#l"..str6;
        self:set_tip_rich_text(str );
    elseif self.time < self.m_data.startTime and 5 == self.m_data.stage then -- 本轮比赛已结束

        funSetBtnJoin(self,false);
        self.btnGame:setVisible(false)

        local time = self.m_data.startTime - self.time;
        local str1, str2 = self:getTime(time);
        local str = "#cffffff#s26距离比赛开始还有 #cfffc05#s30"..str1.." #cffffff#s26"..str2;
        self:set_tip_rich_text(str );
    else
        --跳出这几种状态就不显示tip
        self.tip:setVisible(false);
    end
end


MatchApplyWindow.getTime = function ( self, time )
    --DebugLog("MatchApplyWindow.getTime:time"..time);
    local str1 = "";
    local str2 = "";
    local num = math.floor(time / 86400);----60*60**24);
    if num >= 1 then
        str1 = "" .. num;
        str2 = "天";
    else
        num = math.floor(time / 3600);
        if num >= 1 then
            str1 = "" .. num;
            str2 = "小时";
        else
            if time >= 60 then
                num = math.ceil(time / 60);
            else
                num = math.floor(time / 60);
            end
            
            if num > 0 then
                --DebugLog("MatchApplyWindow.getTime:num"..num);
                str1 = "" .. num;
                str2 = "分钟";
            else
                str1 = "" .. time;
                str2 = "秒";
            end
        end
    end
    return str1,str2;
end

--设置各个控件的按钮事件
MatchApplyWindow.setControlClickEvent = function(self)
    --退出按钮
    self.btnExit:setOnClick(self, function(self)
         self:onBtnExitClick();
    end);

    -- 帮助按钮
    self.btnHelp:setOnClick(self, function(self)
        if self.desUpdateFlag then
            self.desc = nil;
            self.desUpdateFlag = false;
        end
        self.showHelpDetailFlag = true;
        if not self.desc then
            self:requestHelpDetail();
        else
            self:showHelpDetail(self.desc);
        end
    end);

    self.btnTip:setOnClick(self, function( self )
        DebugLog("按钮点击：参赛提醒；");
        if not self.pushKey  then
            DebugLog("self.pushKey is nil");
            return;
        end
        g_DiskDataMgr:setAppData(self.pushKey,1)
        DebugLog("kMap set " .. self.pushKey .. " 1" )
        self:setLocalPushOnce();
        self.btnGame:setVisible(true)
        self.btnTip:setVisible(false)
        Banner.getInstance():showMsg("开赛提醒设置成功，记得来哦~");
    end)

    self.btnGame:setOnClick(self, function ( self )
        DebugLog("按钮点击：参赛；");
        if self.time < self.m_data.startTime and 1 == self.m_data.stage then --未开始预赛
            Banner.getInstance():showMsg("比赛将于" .. string.sub(os.date("%X", self.m_data.startTime), 0, 5) .. "开始，请耐心等待");
        elseif self.time > self.m_data.startTime and self.time < self.m_data.yuSaiEndTime then -- 正在预赛
            -- to join game
            -- 判断钱
            local flag = HallScene_instance:jugeEnterMatchRoom(self.m_data.level);
            if flag then
                self:toGetTableInfo(self.m_data);
                GameState.changeState( nil, States.MatchRoom );
            end
        elseif self.time >= self.m_data.yuSaiEndTime and self.time < self.m_data.taoTaiStartTime then -- 预赛完
            Banner.getInstance():showMsg("预赛已结束，等待系统确定晋级名单");
        elseif self.time < self.m_data.startTime and 5 ~= self.m_data.stage then -- 淘汰/决赛
            local str = "";
            if 3 == self.m_data.stage then
                str = "淘汰赛";
            elseif 4 == self.m_data.stage then
                str = "决赛";
            end
             Banner.getInstance():showMsg("预赛已结束，正在进行" .. str);
        elseif self.time < self.m_data.startTime and  5 == self.m_data.stage then
            Banner.getInstance():showMsg("比赛将于明天" .. string.sub(os.date("%X", self.m_data.startTime), 0, 5) .. "开始，请耐心等待");
        end

    end);
end

--发送命令请求规则信息
MatchApplyWindow.requestHelpDetail = function(self)
    local param = {};
    param.id = self.id;
    SocketManager.getInstance():sendPack( PHP_CMD_REQUEST_HELP_DETAIL, param);
end

--发送命令请求比赛获奖记录
MatchApplyWindow.requestMatchRecord = function(self)
    if not self.roomLevel then
        DebugLog("self.roomLevel is nil");
        return;
    end
    Loading.showLoadingAnim("加载中...");

    local param = {};
    param.level = self.roomLevel;
    SocketManager.getInstance():sendPack( PHP_CMD_GET_MATCH_AWARD_RECORD, param);
end

--发送命令请求 兑换信息填写
MatchApplyWindow.requestSetExchangeInfo = function(self, name, phone, addr)
    local param = {};
    param.name = name or "";
    param.phone = phone or 0;
    param.addr = addr or "";
    SocketManager.getInstance():sendPack( PHP_CMD_SET_MATCH_EXCHANGE_INFO, param);
end

--发送命令请求 兑换信息填写
MatchApplyWindow.requestGetExchangeInfo = function(self)
    local param = {};
    param.mid = PlayerManager.getInstance():myself().mid;
    SocketManager.getInstance():sendPack( PHP_CMD_GET_MATCH_EXCHANGE_INFO, param);
end

--发送命令请求 上次比赛发奖记录
MatchApplyWindow.requrest_last_match_award_list = function (self)
    DebugLog("[MatchApplyWindow]:requrest_last_match_award_list");
    if not self.roomLevel then
        DebugLog("self.roomLevel is nil");
        return;
    end
    Loading.showLoadingAnim("加载中...");

    local param = {};
    param.level = self.roomLevel;
    --param.id = HallConfigDataManager.getInstance():get_php_id_by_level(self.roomLevel);  --榕生又说不用了，先注释把
    SocketManager.getInstance():sendPack( PHP_CMD_REQUEST_LAST_MATCH_AWARD_LIST, param);
end

--获取比赛规则信息
MatchApplyWindow.requestHelpDetailCallBack = function(self, isSuccess, data, jsonData)
    if not isSuccess or not data then
        return;
    end

    if data.status ~= 1 then
        return;
    end
    self.desc = data.data.desc
    if self.desc and "" ~= self.desc and self.showHelpDetailFlag then
        self:showHelpDetail(self.desc);
        self.showHelpDetailFlag = false;
    end
end

--获取比赛获奖记录
MatchApplyWindow.requestMatchRecordCallBack = function(self, isSuccess, data, jsonData)
    DebugLog("MatchApplyWindow.requestMatchRecordCallBack :"..tostring(isSuccess)..tostring(data)..tostring(jsonData));
--    if not isSuccess or not data then
--        return;
--    end

--    if data.status ~= 1 then
--        return;
--    end
    Loading.hideLoadingAnim();
    if data and data.data and data.status == 1 then
        self.matchAwardRecord = {};
        for i = 1, #data.data do
            local d = data.data[i];
            local tmp = {};
            tmp.rank = tonumber(d.rank) or 0;
            tmp.match_id = tonumber(d.match_id) or 0;
            tmp.endtime = d.endtime;
            tmp.level = tonumber(d.level) or 0;
            tmp.award = d.award or "";
            tmp.name = d.name or "";
            tmp.parentNode = self;
            table.insert(self.matchAwardRecord, tmp);
        end
    end
    self:updateMatchAwardRecordWindow()
end

--获取上场比赛发奖记录
MatchApplyWindow.requestLastMatchRecordCallBack = function(self, isSuccess, data, jsonData)
    DebugLog("[MatchApplyWindow]:requestLastMatchRecordCallBack");

    Loading.hideLoadingAnim();

    self.m_last_match_award_list = {};
    if data and data.data and data.status == 1 then
        --self.m_last_match_award_list
        for i = 1, #data.data do
            local d = {};
            d.rank = tonumber(data.data[i].rank) or 0;
            d.name = data.data[i].mnick or "";
            d.award = data.data[i].award or "";
            table.insert(self.m_last_match_award_list, d);
        end
        if #self.m_last_match_award_list > 0 then
            --排序
            function t_sort(s1 , s2)
	            return s1.rank < s2.rank
            end
            table.sort(self.m_last_match_award_list, t_sort);
        end
    end
   self:update_last_match_award_window();
end

MatchApplyWindow.requestSetExchangeInfoCallBack = function (self, isSuccess, data, jsonData)
    if data and data.msg  then
        Banner.getInstance():showMsg(data.msg);
    end


    if not isSuccess or not data then
        return;
    end

    if data.status ~= 1 then
        return;
    end
    --Banner.getInstance():showMsg("您的兑换信息已提交成功");
end



MatchApplyWindow.requestGetExchangeInfoCallBack = function (self, isSuccess, data, jsonData)

    if data and data.data and data.status == 1 then
--     "id": "1",
--        "mid": "12638108",
--        "name": "花爷",
--        "phone": "15919431397",
--        "addr": "博雅互动携手乐视发布新作 开启棋牌赛事直播新模式"
        if data.data.phone then
            GlobalDataManager.getInstance():setExchangeDictInfo(data.data.phone, data.data.name, data.data.addr);
        end

    end
    self:showExchangeWindow();
end

--显示比赛规则
MatchApplyWindow.showHelpDetail = function(self, desc)
    self:removeHelpView();
    require("MatchApply/MatchHelpView");
    self.helpView = new(MatchHelpView, desc);
    self:addChild(self.helpView);
    self.helpView:setLevel(1002);
end

MatchApplyWindow.show = function(self)
    --有还未播放的广播则继续播放
    if not BroadcastMsgManager.getInstance():isEmpty() then
        self:broadcastMsg();
    end

    --设置不显示强推
    GameConstant.isInApplyWindow = true;
    EventDispatcher.getInstance():register(SocketManager.s_phpMsg, self, self.onPhpMsgResponse);

    self:setVisible(true);
    --标记当前页面
    global_set_current_view_tag(GameConstant.view_tag.match_apply);
end


MatchApplyWindow.dtor = function ( self )

    EventDispatcher.getInstance():unregister(SocketManager.s_phpMsg, self, self.onPhpMsgResponse);
    EventDispatcher.getInstance():unregister(NativeManager._Event, self, self.nativeCallEvent);
    self.m_data = nil;
    self.m_matchInfo   = nil;
    delete(self.myBroadcast);
    self.myBroadcast = nil;
    self:removeAllChildren();
    if self.m_timer then
        self.m_timer:cancel()
	    self.m_timer = nil
    end
end

--按下回退按钮
MatchApplyWindow.backEvent = function(self)
    self:onBtnExitClick();
end

--获取控件
MatchApplyWindow.getCtrl = function(self)
    self.bgImage    = publ_getItemFromTree(self.window, {"bgImage"});
    self.topImage   = publ_getItemFromTree(self.window, MatchApplyWindow.s_controlsMap["topImg"]);
    self.viewBottom = publ_getItemFromTree(self.window, MatchApplyWindow.s_controlsMap["viewBottom"]);

    self.btnHelp = publ_getItemFromTree(self.window, MatchApplyWindow.s_controlsMap["btnHelp"]);
    self.btnGame = publ_getItemFromTree(self.window, MatchApplyWindow.s_controlsMap["btnGame"]);
    self.btnTip  = publ_getItemFromTree(self.window, MatchApplyWindow.s_controlsMap["btnTip"]);

    self.btnExit = publ_getItemFromTree(self.window, MatchApplyWindow.s_controlsMap["btnExit"]);
    self.txtMatchName = publ_getItemFromTree(self.window, MatchApplyWindow.s_controlsMap["txtMatchName"]);

    self.tip = publ_getItemFromTree(self.window, {"bgImage", "v", "tip"});

    self.m_btnBarrage = publ_getItemFromTree(self.window, {"bgImage", "btnBarrage"});
    self.m_btnBarrage.isOpen = true;
    self.m_btnBarrage:setOnClick(self, self.event_ctrol_barrage);

    if PlatformConfig.platformWDJ == GameConstant.platformType or
       PlatformConfig.platformWDJNet == GameConstant.platformType then
        self.topImage:setFile("Login/wdj/apply/top.png");
    end

    --奖品
    self.award = {};
    for i = 1, 3 do
        local tmp = {};
        tmp.bg = publ_getItemFromTree(self.window, {"bgImage", "v", "win_"..i});
        tmp.pic =  publ_getItemFromTree(self.window, {"bgImage", "v", "win_"..i, "award"});
        tmp.t =  publ_getItemFromTree(self.window, {"bgImage", "v", "win_"..i, "award_t", "t"});
        table.insert(self.award, tmp);
    end

    self.titleImg = publ_getItemFromTree(self.window, {"bgImage", "topImg", "img"});
    --获奖记录按钮
    self.btn_record = publ_getItemFromTree(self.window, {"bgImage", "btn_record"});
    self.btn_record:setOnClick(self, function (self)
        self:createMatchRecord();
        self:requrest_last_match_award_list();
    end);

    --兑换信息填写按钮
    self.btn_exchangeInfo = publ_getItemFromTree(self.window, {"bgImage", "btn_info"});
    self.btn_exchangeInfo:setOnClick(self, function (self)
        self:requestGetExchangeInfo();
    end);



    --大奖赛 报名按钮
    self.m_btnJoin = publ_getItemFromTree(self.window, {"bgImage", "viewBottom","btnJoin"});
    self.m_btnJoin.t = publ_getItemFromTree(self.m_btnJoin, {"Text1"});

    self.m_btnJoin:setOnClick(self, function (self)
        DebugLog("btn join on click");
        --退出比赛
        if self.hadJoinMatch then
            --发送命令进行退赛
            self:sendToServerExitMatch();
            g_DiskDataMgr:setAppData(self.pushKey,0)
            return;
        end
        --报名比赛
        if HallScene_instance then--大奖赛 要进入界面后报名
            if not self.matchData or not self.matchData.applyprop then
                Banner.getInstance():showMsg("服务器数据拉取错误");
                return;
            end
            local num = ItemManager.getInstance():getCardNum(self.matchData.applyprop.type);

            if not num  or num < (self.matchData and self.matchData.applyprop.num or 0) then
                local proStr = self.matchData.applyprop.type == ItemManager.MATCH_WEEK_CARD and "周赛卡" or "雀圣卡"
                --记得添加金币冲值界面--根据php给的字段
                require("MahjongCommon/RechargeTip");
                local param_t = {t = RechargeTip.enum.enter_match,
                                cardType = self.matchData.applyprop.type, 
                                isShow = true,
                                is_check_bankruptcy = false, 
                                is_check_giftpack = false,};
                RechargeTip.create(param_t) 
                if not rechargeTip or not rechargeTip.suggested  then
                    Banner.getInstance():showMsg("您的道具不足，购买金币赠送报名卡");
                end
                
		        return;
            elseif not HallScene_instance:jugeEnterMatchRoom(self.roomLevel) then
                return;
            else
                HallScene_instance:beginGotoApplyMatchRoom(self.roomLevel, self.matchData.type);
--                self.btnTip:setVisible(true);
	        end
        end
    end);

    --兑换信息填写按钮
    self.btn_invite = publ_getItemFromTree(self.window, {"bgImage", "btn_invite"});
    self.btn_invite:setOnClick(self, self.event_invite);

    --报名界面下面的提示语
    local w_rich_text = self.tip:getSize();
    self.m_rich_text = new(RichText, "", 100, 0, kAlignCenter, nil, 26, 0xff, 0xff, 0xff, true);
	self.m_rich_text:setPos(0,0)
	self.tip:addChild(self.m_rich_text)

    --创建广播条
    self:createBroadcastMSG();

end


--
MatchApplyWindow.showExchangeWindow = function (self)
        require("MahjongPopu/ExchangeGoodsWindow");

        local exchangeGoodsWindow = new(ExchangeGoodsWindow);
        self:addChild(exchangeGoodsWindow);
        self.exchangeGoodsWindow = exchangeGoodsWindow;
        exchangeGoodsWindow:setOKCallBack(self, function(self)
            local exchangeGoodsWindow = self.exchangeGoodsWindow;
            local strPhoneNum   = exchangeGoodsWindow:getPhoneNum() or "";
            local strAddress    = exchangeGoodsWindow:getAddress() or "";
            local strName       = exchangeGoodsWindow:getName() or "";

            if not strPhoneNum or strPhoneNum == "" then
                Banner.getInstance():showMsg("请填写您的手机号码");
                return ;
            end

            if not tonumber(publ_trim(strPhoneNum)) then
                Banner.getInstance():showMsg("请填写11位有效手机号码");
                return;
            end

            if string.len(publ_trim(strPhoneNum)) ~= 11 then
                Banner.getInstance():showMsg("请填写11位有效手机号码");
                return;
            end

            if not strName or strName == "" or publ_trim(strName) == "" then
                Banner.getInstance():showMsg("请填写您的姓名");
                return ;
            end

            if string.len(publ_trim(getStringLen(strName))) > 10 then
                Banner.getInstance():showMsg("请填写不超过10个字符的姓名");
                return ;
            end
            if string.len(publ_trim(getStringLen(strAddress))) < 1 or strAddress == ""  then
                Banner.getInstance():showMsg("请填写正确的地址");
                return ;
            end


            GlobalDataManager.getInstance():setExchangeDictInfo(strPhoneNum, strName, strAddress);
            self:requestSetExchangeInfo(strName, strPhoneNum, strAddress);

            exchangeGoodsWindow:hideWnd();
            self.exchangeGoodsWindow = nil;
    end);
    local phone, name, ad = GlobalDataManager.getInstance():getExchangeDictInfo();
    exchangeGoodsWindow:setName(name or "");
    exchangeGoodsWindow:setAddress(ad or "");
    exchangeGoodsWindow:setPhoneNum(phone or "");
end


--大奖赛进入房间后，发个消息查看是否报过名
MatchApplyWindow.sendPackToServerCheckSign = function(self, roomLevel)
    DebugLog("MatchApplyWindow.sendPackToServerCheckSign");
    local level = self.m_data and self.m_data.level or roomLevel;
    if not level then
        DebugLog("level is nil");
        return;
    end

    --发送命令
    local param = {};

    param.level_0 = level;
    param.param = -1;
    param.cmdRequest = CLIENT_IS_SIGNUP_MATCH_REQ;
    param.uid = self.myself.mid;
    param.level = level;

    SocketSender.getInstance():send( SERVER_MATCHSERVER_CMD, param);
end

--大奖赛进入房间后，-玩家请求观看比赛，但不是报名比赛
MatchApplyWindow.sendPackToServerViewMatch = function(self, roomLevel)
    DebugLog("MatchApplyWindow.sendPackToServerViewMatch");
    local level = roomLevel;--self.m_data and self.m_data.level or roomLevel;
    if not level then
        DebugLog("level is nil");
        return;
    end

    --发送命令
    local param = {};

    param.level_0 = level;
    param.param = -1;
    param.cmdRequest = CLIENT_VIEW_MATCH_REQ;
    param.uid = self.myself.mid;
    param.level = level;

    SocketSender.getInstance():send( SERVER_MATCHSERVER_CMD, param);
end

--发送命令进行退赛
MatchApplyWindow.sendToServerExitMatch = function (self)
    DebugLog("MatchApplyWindow.sendToServerExitMatch");

    --发送命令进行退赛
    local param = {};

    param.level_0 = self.m_data.level;
    param.param = -1;
    param.cmdRequest = CLIENT_QUIT_MATCH_REQ;
    param.uid = self.myself.mid;
    param.matchType =  self.m_data.matchType;
    param.level = self.m_data.level;
    param.api = PlatformFactory.curPlatform.api;
    param.matchId = self.m_data.matchId;

    SocketSender.getInstance():send( SERVER_MATCHSERVER_CMD, param);-- 退出比赛
end

--确定退出比赛，回到比赛场进行选择房间
MatchApplyWindow.onGoBackSelectPlaySpace = function(self)
    --如果是大奖赛且已经报名参加 了比赛，则不发送退出比赛消息
    if not self.m_data  or (self.m_data.matchType == GameConstant.matchTypeConfig.award and self.hadJoinMatch) then
        BroadcastMsgManager.getInstance():push();
        self:hideWnd();
        if self.FuncObj and self.obj then
            self.FuncObj(self.obj);
        end
        return;
    end
    --发送命令进行退赛
    self:sendToServerExitMatch();
end



--退出比赛回调
MatchApplyWindow.receiveMatchSignOut = function(self, data)
    if not data then
        return;
    end

    if data.cmdRequest == CLIENT_QUIT_MATCH_RES then

        if data.result ~= 2 then
            --不论成功或者失败,只要状态不是2 就给退出比赛
            if self.logoutView then
                popWindowUp(self.logoutView, nil, self.logoutView.bg);
            end

            BroadcastMsgManager.getInstance():push();
            --隐藏自己
            self:hideWnd();

            if self.FuncObj and self.obj then
                self.FuncObj(self.obj);
            end

        end
        --Banner.getInstance():showMsg(data.meg);
    end
end

MatchApplyWindow.onBtnExitClick = function(self)
    local str1 = "";
    local str2 = "";
    local str3 = "";

    if self.helpView then
        popWindowUp(self.helpView, nil, self.helpView.img_win_bg);
        self:removeHelpView();
    end


    if self.exchangePopu then
        self.exchangePopu:hideWnd();
        self:removeChild(self.exchangePopu, true);
        self.exchangePopu = nil;
    end

    if self.m_data and (GameConstant.matchTypeConfig.playerNum == self.m_data.matchType or GameConstant.matchTypeConfig.playTime == self.m_data.matchType) then -- 人满赛
        local limit = self.m_data.limitPerson;
        local current= self.m_data.currentPerson;
        local neddMoreJoinerCount = tonumber(limit) - tonumber(current);
        if GameConstant.matchTypeConfig.playerNum == self.m_data.matchType then
            str1 = "客官,离比赛开始只差"  .. neddMoreJoinerCount .. "人，";
            str2 = "您确定要退出比赛吗？";
            str3 = "";
        elseif GameConstant.matchTypeConfig.playTime == self.m_data.matchType then
            if self.time < self.m_data.startTime and 1 == self.m_data.stage then --未开始预赛
                local time = self.m_data.startTime - self.time;
                local s1, s2 = self:getTime(time);
                str1 = "客官,距离比赛开始还有" .. s1 .. s2;
                str2 = "您确定要退出比赛吗？";
                str3 = "";
            end
        end
    elseif self.m_data and self.matchData and self.matchData.type == GameConstant.matchTypeConfig.award then -- 大奖赛--旧定时赛
        if self.time < self.m_data.startTime and 1 == self.m_data.stage then --未开始预赛
            DebugLog("ttt onBtnExitClick 1")
            self:onGoBackSelectPlaySpace();
            return;
        elseif self.time >= self.m_data.startTime and self.time < self.m_data.yuSaiEndTime then -- 正在预赛
            DebugLog("ttt onBtnExitClick 2")
            str1 = "本场积分:" .. self.m_data.jifen .. "  排名:" .. self.m_data.rank;
            str2 = self.m_data.matchName .. "正在进行中，确定要退出吗？";
            str3 = "";
        elseif self.time >= self.m_data.yuSaiEndTime and self.time < self.m_data.taoTaiStartTime then -- 预赛结束等排名
            DebugLog("ttt onBtnExitClick 3")
            str1 = "本场积分:" .. self.m_data.jifen .. "  排名:" .. self.m_data.rank;
            str2 = "请确保" .. string.sub(os.date("%X", self.m_data.taoTaiStartTime), 0, 5) .. "在线且未开始其他游戏，否";
            str3 = "则将视为放弃晋级资格";
        elseif self.time < self.m_data.startTime then -- 淘汰赛/决赛
            DebugLog("ttt onBtnExitClick 4")
            self:onGoBackSelectPlaySpace();
            return;
        else
            DebugLog("ttt onBtnExitClick 5")
            self:onGoBackSelectPlaySpace();
            return;
        end
    else
        self:onGoBackSelectPlaySpace();
        return;
    end

    if self.logoutView then
        self.logoutView:showWnd();
    else
        require("MatchApply/MatchLogoutView");
        self.logoutView = new(MatchLogoutView, self, str1, str2, str3);
        self:addChild(self.logoutView);
        self.logoutView:setLevel(10001);
        self.logoutView:setOnWindowHideListener( self, function( self )
        	self.logoutView = nil;
        end);
    end
end

MatchApplyWindow.traceToRoom = function ( self )
    if 1 == self.m_data.matchType or (self.time < self.m_data.startTime and 1 == self.m_data.stage) or (self.time < self.m_data.startTime) then
        self:onGoBackSelectPlaySpace();
    end
end



MatchApplyWindow.removeHelpView = function( self )
    if self.helpView then
        self:removeChild(self.helpView, true);
        self.helpView = nil;
    end
end

--广播比赛开始
MatchApplyWindow.toGetTableInfo = function ( self, data )
    if not data then
        return;
    end
    GameConstant.curRoomLevel = data.level;
    GameConstant.matchId = data.matchId;
    GameConstant.matchType = tonumber(data.matchType) or 0;

    if GameConstant.matchType == GameConstant.matchTypeConfig.playerNum or GameConstant.matchType == GameConstant.matchTypeConfig.playTime then
        if self.barrageLayer then
            self.barrageLayer:removeFromSuper();
            self.barrageLayer = nil;
        end
        GameState.changeState( nil, States.MatchRoom );
    end
end

--关闭当前窗口又父节点执行操作，因为需要重新启动定时器
MatchApplyWindow.setCloseCallBack = function(self, obj, FuncObj)
    self.obj = obj;
    self.FuncObj = FuncObj;
end

--本地推送 比赛提醒通知
MatchApplyWindow.setLocalPushOnce = function( self )
    DebugLog( "MatchApplyWindow.setLocalPushOnce" );
    local name = self.m_data.matchName or ""

    local params     = {}
    params.once      = 1
    params.title     = PlatformFactory.curPlatform:getApplicationShareName();
    params.content   = "您报名的 " .. name .." 即将开赛，赶紧来打比赛了!"
    params.delayTime = self.m_data.startTime - self.time --开赛时提醒  --小米手机可能有误差 5分钟内随机
    mahjongPrint(params)
    native_to_java( kSetLocalPush, json.encode(params) )
end

--邀请好友按钮 事件
MatchApplyWindow.event_invite = function (self)
    DebugLog("[MatchApplyWindow]:event_invite");

    local matchtype,level,name = nil, nil, nil
    if self.m_data and self.m_data.matchType and self.roomLevel then
        matchtype,level =  self.m_data.matchType, self.roomLevel;
    elseif self.roomLevel then
        matchtype,level =  GameConstant.matchTypeConfig.award, self.roomLevel;
    else
        DebugLog("data is error");

    end
    if not matchtype or not level then
        return;
    end

    name = self.matchData and self.matchData.name or "";

    if not self.m_inviteRoomWindow then
		self.m_inviteRoomWindow = new(InviteFriendInFMRWindow, 0, {match_type = matchtype, match_level = level, match_name = name,})
		self:addChild(self.m_inviteRoomWindow);
		self.m_inviteRoomWindow:setOnWindowHideListener(self, function( self )
			self.m_inviteRoomWindow = nil
		end);
		self.m_inviteRoomWindow:showWnd()
	end
end

--创建获奖记录视图
MatchApplyWindow.createMatchRecord = function (self)


    if self.recordWindow then
        self:removeChild(self.recordWindow);
        self.recordWindow = nil;
    end
    local window = new(SCWindow);

    self:addChild(window);
    window:setCoverEnable(false)
    self.recordWindow = window;
    self.recordWindow:setOnWindowHideListener(self, function( self )
		self.recordWindow = nil
	end);


    window.m_layout = SceneLoader.load(cardRecordView);
    window:addChild(window.m_layout);
    window:setWindowNode(window.m_layout);
    window:showWnd();

    publ_getItemFromTree(window.m_layout, {"bg", "closeBtn"}):setOnClick(self, function (self)
        self.recordWindow:hideWnd();
    end);
    local v_top =  publ_getItemFromTree(window.m_layout, {"bg", "v_top"});
    local btn_1 =  publ_getItemFromTree(v_top, {"btn_1"});
    local btn_2 =  publ_getItemFromTree(v_top, {"btn_2"});


    --上次比赛法将记录
    btn_1:setOnClick(self, function (self)
        btn_1:setFile("apply/record_tab_1.png");
        btn_2:setFile("apply/record_tab_2_1.png");

        if self.m_last_match_award_list and #self.m_last_match_award_list > 0 then
            self:update_last_match_award_window();
        else
            self:requrest_last_match_award_list();
        end
    end);

    --我的获奖记录
    btn_2:setOnClick(self, function (self)
        btn_1:setFile("apply/record_tab_1_1.png");
        btn_2:setFile("apply/record_tab_2.png");
        if self.matchAwardRecord and #self.matchAwardRecord > 0 then
            self:updateMatchAwardRecordWindow();
        else
            self:requestMatchRecord();
        end
    end);


    local bg = publ_getItemFromTree(window.m_layout, {"bg"});
    local title = publ_getItemFromTree(window.m_layout, {"bg", "title"});
    local scrollview = publ_getItemFromTree(window.m_layout, {"bg", "ScrollView1"});
    local btn_my_record = publ_getItemFromTree(window.m_layout, {"bg", "v_"});

    title:setText("获奖记录");

    if v_top then
        v_top:setVisible(true);
    end

    local listview_w , listview_h = scrollview:getSize();

    local x_listview , y_listview = scrollview:getPos();
    local listview = new(ListView, 0, 60, 820, listview_h-60);
    listview:setAlign(kAlignCenter);
    bg:addChild(listview);
    self.m_listview_record = listview;

    window:showLoadingAnim()
end

--刷新 上次比赛发奖记录界面
MatchApplyWindow.update_last_match_award_window = function (self)
    DebugLog("[MatchApplyWindow]:update_last_match_award_window");
    if not self.recordWindow then
        DebugLog("self.recordWindow is nil");
        return;
    end
    if self.m_listview_record then
        self.m_listview_record:removeAllChildren();
    end

    local listItem = class(Node)

    listItem.ctor = function(self, data)
        self.data = data;

        local bg = new(Image, "apply/item_record.png");
        bg:setAlign(kAlignCenter);
        self:addChild(bg);

        local tmpSTr = "";
        local t_rank = new(Text, "第 "..tostring(data.rank).." 名：", 0, 0, kAlignLeft, "", 30, 0x66, 0x44, 0x33)
        t_rank:setAlign(kAlignLeft);
        t_rank:setPos(30,0);
        self:addChild(t_rank);

        tmpSTr = stringFormatWithString(data.name or "", 14, false);
        local t_name = new(Text, tmpSTr, 0, 0, kAlignLeft, "", 30, 0x66, 0x44, 0x33)
        t_name:setAlign(kAlignLeft);
        t_name:setPos(160,0);
        self:addChild(t_name);

        tmpSTr = stringFormatWithString("奖励："..data.award or "", 22, false);
        local t_award = new(Text, tmpSTr, 0, 0, kAlignLeft, "", 30, 0xcc, 0x44, 0x00)
        t_award:setAlign(kAlignLeft);
        t_award:setPos(450,0);
        self:addChild(t_award);

        self:setSize(802, 90);
    end
    listItem.dtor = function(self)
    end

    local window = self.recordWindow
    window:hideLoadingAnim()
    local bg = publ_getItemFromTree(window.m_layout, {"bg"});
    local title = publ_getItemFromTree(window.m_layout, {"bg", "title"});
    local scrollview = publ_getItemFromTree(window.m_layout, {"bg", "ScrollView1"});
    local v_top =  publ_getItemFromTree(window.m_layout, {"bg", "v_top"});
    if v_top then
        v_top:setVisible(true);
    end

    local listview = self.m_listview_record;

    if self.m_last_match_award_list and #self.m_last_match_award_list <= 0 then
        local tipBg = new(Image,  "apply/reward_blank_2.png")
        tipBg:setAlign(kAlignCenter);
        self.m_listview_record:addChild(tipBg);
        local t = new(Text, "暂无获奖记录", 0, 0, kAlignLeft, "", 30, 0x4b, 0x2b, 0x1c)
        t:setAlign(kAlignCenter);
        tipBg:addChild(t);

        listview:setAdapter(nil);
    else
        local adapter = new(CacheAdapter, listItem, self.m_last_match_award_list);
        listview:setAdapter(adapter);
    end
end

--刷新 我的获奖记录界面
MatchApplyWindow.updateMatchAwardRecordWindow = function (self)
    if self.recordWindow then
        if self.m_listview_record then
            self.m_listview_record:removeAllChildren();
        end

        local listItem = class(Node)

        listItem.ctor = function(self, data)
            self.data = data;

            local bg = new(Image, "apply/item_record.png");
            bg:setAlign(kAlignCenter);
            self:addChild(bg);

            local tmpSTr = tostring(data.endtime);
            tmpSTr = getDateStringFromTime(tmpSTr);
            tmpSTr = stringFormatWithString(tmpSTr, 14, true);
            local time = new(Text, tmpSTr, 0, 0, kAlignLeft, "", 30, 0x66, 0x44, 0x33)
            time:setAlign(kAlignLeft);
            time:setPos(30,0);
            self:addChild(time);

            local awrdText = new(Text, "获得第"..data.rank.."名", 0, 0, kAlignLeft, "", 30, 0xcc, 0x44, 0x00)
            awrdText:setAlign(kAlignLeft);
            awrdText:setPos(356,0);
            self:addChild(awrdText);

            local btn = new(Button, "Commonx/green_small_btn.png", nil, nil, nil, 0, 0, 0, 0);
            btn:setAlign(kAlignRight);
            btn:setPos(30, 3);
            self:addChild(btn);

            local text = new(Text, "查  看", 0, 0, kAlignLeft, "", 32, 0xff , 0xff , 0xff)
            text:setAlign(kAlignCenter);
            text:setPos(0, -5);
            btn:addChild(text);
            btn.data = data;

            btn:setOnClick(self, function (self)
                if self.data and self.data.parentNode and self.data.parentNode.recordWindow then
                    self.data.parentNode.recordWindow:setVisible(false);
                end
                local data = {name = self.data.name, rank = self.data.rank, awardString = self.data.award, is_large_award = self.data.is_large_award, time = self.data.endtime};
                HallScene_instance.matchApplyWindow.certificateWnd = new(CertificateWindow, data);
                HallScene_instance.matchApplyWindow.certificateWnd:show();
                HallScene_instance.matchApplyWindow.certificateWnd :setLevel(10000);
                HallScene_instance.matchApplyWindow.certificateWnd:matchApplySet();
            end);

            self:setSize(802, 90);
        end
        listItem.dtor = function(self)
        end

        local window = self.recordWindow
        window:hideLoadingAnim()

        local listview = self.m_listview_record;


        if self.matchAwardRecord and #self.matchAwardRecord <= 0 then
            local tipBg = new(Image,  "apply/reward_blank_2.png")
            tipBg:setAlign(kAlignCenter);
            self.m_listview_record:addChild(tipBg);
            local t = new(Text, "暂无获奖记录", 0, 0, kAlignLeft, "", 30, 0x4b, 0x2b, 0x1c)
            t:setAlign(kAlignCenter);
            tipBg:addChild(t);

            listview:setAdapter(nil);
        else
            local adapter = new(CacheAdapter, listItem, self.matchAwardRecord);
            listview:setAdapter(adapter);
        end


    end
end

function MatchApplyWindow.nativeCallEvent(self, param, _detailData)

    if kDownloadImageOne == param then
        DebugLog("MatchApplyWindow.nativeCallEvent:".._detailData);
        if _detailData and (_detailData == self.nameUrlDir) then
            self.titleImg :setFile(_detailData);
        end
        for i = 1, #self.award do
            if self.award[i].picName == _detailData then
                self.award[i].pic:setFile(_detailData);
            end
        end
    end
end



--http回调
MatchApplyWindow.onPhpMsgResponse = function ( self, param, cmd, isSuccess,... )
    if self.httpRequestsCallBackFuncMap[cmd] then
        self.httpRequestsCallBackFuncMap[cmd](self,isSuccess,param,...)
    end
end

MatchApplyWindow.httpRequestsCallBackFuncMap =
{
    [PHP_CMD_REQUEST_HELP_DETAIL]   = MatchApplyWindow.requestHelpDetailCallBack,
    [PHP_CMD_GET_MATCH_AWARD_RECORD] = MatchApplyWindow.requestMatchRecordCallBack,
    [PHP_CMD_SET_MATCH_EXCHANGE_INFO] = MatchApplyWindow.requestSetExchangeInfoCallBack,
    [PHP_CMD_GET_MATCH_EXCHANGE_INFO] = MatchApplyWindow.requestGetExchangeInfoCallBack,
    [PHP_CMD_REQUEST_LAST_MATCH_AWARD_LIST] =  MatchApplyWindow.requestLastMatchRecordCallBack,
};

MatchApplyWindow.s_controlsMap =
{
    ["bgImage"]                  = {"bgImage"},
    ["topImage"]                 = {"bgImage", "topImg"},
    ["viewBottom"]               = {"bgImage", "viewBottom"},

    ["btnHelp"]                  = {"bgImage", "viewBottom", "btnHelp"},
    ["btnGame"]                  = {"bgImage", "viewBottom", "btnGame"},
    ["btnTip"]                   = {"bgImage", "viewBottom", "btnTip"},
    ["btnExit"]                  = {"bgImage", "btnExit"},
    ["txtMatchName"]             = {"bgImage", "topImg", "txtMatchName"},
    ["topImg"]                   = {"bgImage", "topImg"},

};
