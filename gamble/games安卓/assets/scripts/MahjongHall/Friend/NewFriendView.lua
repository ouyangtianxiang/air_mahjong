local NewFriendViewLayout = require(ViewLuaPath.."NewFriendViewLayout");
require("MahjongCommon/SCWindow")
require("MahjongHall/Friend/FriendDataManager")
require("MahjongHall/Friend/FriendListItem")
local friendScoreItemLayout = require(ViewLuaPath.."friendScoreItemLayout");
require("ui/adapter")
require("MahjongHall/Friend/FriendPlayRecordItem")
require("MahjongCommon/PopuFrame")

require("MahjongHall/hall_2_interface_base")

local l_view_type = {main = 1, addFriend = 2, score = 3};
local l_tab_type = {main = 1, addFriend = 2, score = 3};
local l_af_tab_type = {phone = 1, wechat = 2, qq = 3, face2face = 4, boyaa = 5};
local l_const_str = {
phoneHint = "请输入手机号码或者文字",
face2faceHint = "请输入4个数字",
searchHint = "请输入玩家ID",
}

local l_friendlist_item_h = 108;--96+12
local l_php_send_max = 100;

local l_const_seq = {
sendPhpVerifyPhone = 100,
};

local l_const = {
face2faceNodeW = 120,
face2faceNodeH = 144,
}


local l_default_userinfo = {
    mnick = "",
    sex = kSexMan,
    level = 0,
    wintimes = 0,
    losetimes = 0,
    drawtimes = 0,
    large_image = "",
    small_image = "",
    gift_status = 0,
    like_status = 0,
    alias = "",
    likes = 0,
    charms = 0,
    charms_level = 0,
    charms_title = 0,
    vip_level = 0,
    mid = 0,
    money = 0,
};

NewFriendView = class(hall_2_interface_base);


NewFriendView.ctor = function (self, delegate, state)
    DebugLog("[NewFriendView ctor]", LTMap.Default);
    self.delegate = delegate;
    self.state = state or l_tab_type.main;
--    g_GameMonitor:addTblToUnderMemLeakMonitor("friend",self)
        --data
    self.m_data = {};

    self.m_data.m_friendsData = {};
    self.m_data.currentSelectMid = "0";
    self.m_data.currentSelectIndex = 1;
    self.m_data.chanelId = 0;
    self.m_data.sendPhpGetPhoneCounts = 0;--向php发送超过10次，停止继续发送
    self.m_data.allPhoneNumbers = {};
    self.m_data.viewType = l_view_type.main;--三个tab的视图
    if GameConstant.check_addressBook == nil then
        self.m_data.afViewType = l_af_tab_type.phone; --添加好友界面左边的5个item type
    end
    self:setDefaultUserDetailInfo();


    --设置基类的基础配置
    self:set_tag(GameConstant.view_tag.exchange);
    self:set_tab_title({"我的好友", "添加好友", "牌局记录"});
    self:set_tab_count(3);

    delegate.m_mainView:addChild(self)
    self:play_anim_enter();
    
end

NewFriendView.dtor = function (self)
    DebugLog("[NewFriendView dtor]");
    self.super.dtor(self);
    --离开好友界面清空面对面加好友，进入房间的列表
    FriendDataManager.getInstance().m_enterChanelData.players = {};
    FriendDataManager.getInstance():removeListener(self,self.onCallBackFunc);
    EventDispatcher.getInstance():unregister(SocketManager.s_phpMsg, self, self.onPhpMsgResponse);
    EventDispatcher.getInstance():unregister(NativeManager._Event, self, self.nativeCallEvent);
end


NewFriendView.set_show_view_addfriend = function ()

end

--[Comment]
--initWidgets
NewFriendView.initWidgets = function (self)

    self.m_layout_friendview = SceneLoader.load(NewFriendViewLayout);
    self.m_bg:addChild(self.m_layout_friendview);

    self.m_widget = {};
    self.m_widget.view_move = publ_getItemFromTree(self.m_layout_friendview, {"main"});



    self.m_widget.btn_main = self.m_btn_tab[1]
    self.m_widget.btn_main.selectedImg = self.m_btn_tab[1].img
    self.m_widget.btn_addFriend = self.m_btn_tab[2]
    self.m_widget.btn_addFriend.selectedImg = self.m_btn_tab[2].img
    self.m_widget.btn_score = self.m_btn_tab[3]
    self.m_widget.btn_score.selectedImg = self.m_btn_tab[3].img
    --view main
    self.m_widget.view_main = publ_getItemFromTree(self.m_layout_friendview, {"view_main"});
    self.m_widget.view_main.t_nofriend = publ_getItemFromTree(self.m_widget.view_main, {"t_nofriend"});
    self.m_widget.view_main.userinfo = publ_getItemFromTree(self.m_widget.view_main, {"userinfo"});
    self.m_widget.view_main.userinfo.head_bg = publ_getItemFromTree(self.m_widget.view_main.userinfo, {"head_bg"});
    self.m_widget.view_main.userinfo.head = publ_getItemFromTree(self.m_widget.view_main.userinfo, {"head_bg", "head"});
    self.m_widget.view_main.userinfo.name = publ_getItemFromTree(self.m_widget.view_main.userinfo, {"v_name", "name"});
    self.m_widget.view_main.userinfo.id = publ_getItemFromTree(self.m_widget.view_main.userinfo, {"head_bg","text_id"});
    self.m_widget.view_main.userinfo.genderImg = publ_getItemFromTree(self.m_widget.view_main.userinfo, {"v_gender", "gender","img"});
    self.m_widget.view_main.userinfo.genderText = publ_getItemFromTree(self.m_widget.view_main.userinfo, {"v_gender","gender","t"});
    self.m_widget.view_main.userinfo.level = publ_getItemFromTree(self.m_widget.view_main.userinfo, {"v_level","level","t"});
    self.m_widget.view_main.userinfo.coin = publ_getItemFromTree(self.m_widget.view_main.userinfo, {"v_coin","coin","t"});
    self.m_widget.view_main.userinfo.winStr = publ_getItemFromTree(self.m_widget.view_main.userinfo, {"v_win","win","t"});
    self.m_widget.view_main.userinfo.charmStr = publ_getItemFromTree(self.m_widget.view_main.userinfo, {"charm_bg","t", "t"});
    self.m_widget.view_main.userinfo.charmLevelImg = publ_getItemFromTree(self.m_widget.view_main.userinfo, {"charm_bg","level"});
    self.m_widget.view_main.userinfo.laudImg = publ_getItemFromTree(self.m_widget.view_main.userinfo, {"head_bg","laud_bg", "laud_img"});
    self.m_widget.view_main.userinfo.laudText = publ_getItemFromTree(self.m_widget.view_main.userinfo, {"head_bg","laud_bg", "laud_text"});
    self.m_widget.view_main.userinfo.laudCount = publ_getItemFromTree(self.m_widget.view_main.userinfo, {"head_bg","laud_bg", "laud_count"});
    self.m_widget.view_main.userinfo.vip = publ_getItemFromTree(self.m_widget.view_main.userinfo, {"head_bg", "vip_img"});
    self.m_widget.view_main.userinfo.remark = publ_getItemFromTree(self.m_widget.view_main.userinfo, {"v_name", "remark"});
    self.m_widget.view_main.userinfo.btn_chat = publ_getItemFromTree(self.m_widget.view_main.userinfo, { "btn_chat"});
    self.m_widget.view_main.userinfo.btn_location = publ_getItemFromTree(self.m_widget.view_main.userinfo, { "btn_location"});
    self.m_widget.view_main.userinfo.btn_delete = publ_getItemFromTree(self.m_widget.view_main.userinfo, { "btn_delete"});
    self.m_widget.view_main.userinfo.btn_laud = publ_getItemFromTree(self.m_widget.view_main.userinfo, { "head_bg","btn_laud"});

    --listview
    self.m_widget.view_main.m_listview = publ_getItemFromTree(self.m_widget.view_main, {"list_view_friend"});
    self.m_widget.view_main.m_listview:setSize(368,System.getScreenScaleHeight()-  252)


    --view add friend
    self.m_widget.view_addFriend = publ_getItemFromTree(self.m_layout_friendview, {"view_add_friend"});
    self.m_widget.view_addFriend.v = publ_getItemFromTree(self.m_widget.view_addFriend, {"v"});
    self.m_widget.view_addFriend.item_phone = publ_getItemFromTree(self.m_widget.view_addFriend.v, {"item_1"});
    self.m_widget.view_addFriend.item_wechat = publ_getItemFromTree(self.m_widget.view_addFriend.v, {"item_2"});
    self.m_widget.view_addFriend.item_qq = publ_getItemFromTree(self.m_widget.view_addFriend.v, {"item_3"});
    self.m_widget.view_addFriend.item_face2face = publ_getItemFromTree(self.m_widget.view_addFriend.v, {"item_4"});
    self.m_widget.view_addFriend.item_boyaa = publ_getItemFromTree(self.m_widget.view_addFriend.v, {"item_5"});

    if GameConstant.check_addressBook ~= nil then --后台开关隐藏通讯录
        self.m_widget.view_addFriend.item_boyaa:setPos(self.m_widget.view_addFriend.item_face2face:getPos())
        self.m_widget.view_addFriend.item_face2face:setPos(self.m_widget.view_addFriend.item_qq:getPos())
        self.m_widget.view_addFriend.item_qq:setPos(self.m_widget.view_addFriend.item_wechat:getPos())
        self.m_widget.view_addFriend.item_wechat:setPos(self.m_widget.view_addFriend.item_phone:getPos())
        self.m_widget.view_addFriend.item_phone:setVisible(false)
    end

    self.m_widget.view_addFriend.v_phone = publ_getItemFromTree(self.m_widget.view_addFriend, {"v_1"});
    self.m_widget.view_addFriend.v_wechat = publ_getItemFromTree(self.m_widget.view_addFriend, {"v_2"});
    self.m_widget.view_addFriend.v_qq = publ_getItemFromTree(self.m_widget.view_addFriend, {"v_3"});
    self.m_widget.view_addFriend.v_face2face = publ_getItemFromTree(self.m_widget.view_addFriend, {"v_4"});
    self.m_widget.view_addFriend.v_boyaa = publ_getItemFromTree(self.m_widget.view_addFriend, {"v_5"});

    self.m_widget.view_addFriend.v_phone.searchEditText = publ_getItemFromTree(self.m_widget.view_addFriend.v_phone, {"v", "img", "EditText1"});
    self.m_widget.view_addFriend.v_phone.scrollview = publ_getItemFromTree(self.m_widget.view_addFriend.v_phone, {"scrollview"});
    self.m_widget.view_addFriend.v_phone.tip = publ_getItemFromTree(self.m_widget.view_addFriend.v_phone, {"tip"});

    self.m_widget.view_addFriend.v_face2face.edit_text = publ_getItemFromTree(self.m_widget.view_addFriend.v_face2face, {"v", "img", "edit_text"});
    self.m_widget.view_addFriend.v_face2face.btn_confirm = publ_getItemFromTree(self.m_widget.view_addFriend.v_face2face, {"v", "confirm"});
    self.m_widget.view_addFriend.v_face2face.btn_add_selected = publ_getItemFromTree(self.m_widget.view_addFriend.v_face2face, { "add_all"});
    self.m_widget.view_addFriend.v_face2face.scrollview = publ_getItemFromTree(self.m_widget.view_addFriend.v_face2face, { "ScrollView"});


    self.m_widget.view_addFriend.v_boyaa.searchView = publ_getItemFromTree(self.m_widget.view_addFriend.v_boyaa, {"v_1"});
    self.m_widget.view_addFriend.v_boyaa.edit_text = publ_getItemFromTree(self.m_widget.view_addFriend.v_boyaa, {"v", "img", "edit_text"});
    self.m_widget.view_addFriend.v_boyaa.btn_search = publ_getItemFromTree(self.m_widget.view_addFriend.v_boyaa, {"v", "search"});
    self.m_widget.view_addFriend.v_boyaa.btn_add = publ_getItemFromTree(self.m_widget.view_addFriend.v_boyaa, { "v_1", "add"});
    self.m_widget.view_addFriend.v_boyaa.head = publ_getItemFromTree(self.m_widget.view_addFriend.v_boyaa, { "v_1", "head", "img"});
    self.m_widget.view_addFriend.v_boyaa.name = publ_getItemFromTree(self.m_widget.view_addFriend.v_boyaa, { "v_1", "head", "name"});
    self.m_widget.view_addFriend.v_boyaa.coin = publ_getItemFromTree(self.m_widget.view_addFriend.v_boyaa, { "v_1", "head", "coin"});
    self.m_widget.view_addFriend.v_boyaa.tipText = publ_getItemFromTree(self.m_widget.view_addFriend.v_boyaa, { "v", "tip"});
    self.m_widget.view_addFriend.v_boyaa.searchView:setVisible(false);

    --设置最多输入12个字
    self.m_widget.view_addFriend.v_boyaa.edit_text:setMaxLength(12);
    self.m_widget.view_addFriend.v_boyaa.edit_text:setHintText(l_const_str.searchHint);
    self.m_widget.view_addFriend.v_boyaa.edit_text:setOnTextChange(self, self.textOnChangeSearchByID);
    self.m_widget.view_addFriend.v_boyaa.tipText:setText("也可以告诉好友你的ID:"..tostring(PlayerManager.getInstance():myself().mid));
    self.m_widget.view_addFriend.v_boyaa.edit_text:setText("");
    self.m_widget.view_addFriend.v_boyaa.edit_text:setHintText(l_const_str.searchHint);


    --设置最多输入4个字
    self.m_widget.view_addFriend.v_face2face.edit_text:setMaxLength(4);
    self.m_widget.view_addFriend.v_face2face.edit_text:setOnTextChange(self, self.textOnChangeFace2Face);
    self.m_widget.view_addFriend.v_face2face.edit_text:setText("");
    self.m_widget.view_addFriend.v_face2face.edit_text:setHintText(l_const_str.face2faceHint);

    --设置最多输入12个字
    self.m_widget.view_addFriend.v_phone.searchEditText:setMaxLength(12);
    self.m_widget.view_addFriend.v_phone.searchEditText:setText("");
    self.m_widget.view_addFriend.v_phone.searchEditText:setHintText(l_const_str.phoneHint);
    self.m_widget.view_addFriend.v_phone.searchEditText:setOnTextChange(self, self.textOnChange);

    --search by id onclick
    self.m_widget.view_addFriend.v_boyaa.btn_search:setOnClick(self, NewFriendView.eventSearch);
    self.m_widget.view_addFriend.v_boyaa.btn_add:setOnClick(self, NewFriendView.eventAdd);

    --view score
    self.m_widget.view_score = publ_getItemFromTree(self.m_layout_friendview, {"view_score"});
    self.m_widget.view_score.scrollview = publ_getItemFromTree(self.m_widget.view_score, {"scrollview"});
    self.m_widget.view_score.tip = publ_getItemFromTree(self.m_widget.view_score, {"tip"});

    --view face2face button onclick
    self.m_widget.view_addFriend.v_face2face.btn_confirm:setOnClick(self, self.eventFace2FaceEnterChanel);
    self.m_widget.view_addFriend.v_face2face.btn_add_selected:setOnClick(self, self.eventFace2FaceAddFriendSelected);

    --userinfo onclick
    self.m_widget.view_main.userinfo.remark:setOnClick(self, self.eventRemark);
    self.m_widget.view_main.userinfo.btn_chat:setOnClick(self, self.eventChat);
    self.m_widget.view_main.userinfo.btn_location:setOnClick(self, self.eventLocation);
    self.m_widget.view_main.userinfo.btn_delete:setOnClick(self, self.eventDelete);
    self.m_widget.view_main.userinfo.btn_laud:setOnClick(self, self.eventLaud);

    --addfriend item onclick
    self.m_widget.view_addFriend.item_phone:setEventTouch({o = self, btn = self.m_widget.view_addFriend.item_phone , state = l_af_tab_type.phone},
                                                           NewFriendView.eventAddFriendItemTouch);
    self.m_widget.view_addFriend.item_wechat:setEventTouch({o = self, btn = self.m_widget.view_addFriend.item_wechat, state = l_af_tab_type.wechat },
                                                           NewFriendView.eventAddFriendItemTouch);
    self.m_widget.view_addFriend.item_qq:setEventTouch({o = self, btn = self.m_widget.view_addFriend.item_qq , state = l_af_tab_type.qq},
                                                           NewFriendView.eventAddFriendItemTouch);
    self.m_widget.view_addFriend.item_face2face:setEventTouch({o = self, btn = self.m_widget.view_addFriend.item_face2face, state = l_af_tab_type.face2face },
                                                           NewFriendView.eventAddFriendItemTouch);
    self.m_widget.view_addFriend.item_boyaa:setEventTouch({o = self, btn = self.m_widget.view_addFriend.item_boyaa, state = l_af_tab_type.boyaa },
                                                           NewFriendView.eventAddFriendItemTouch);


    --注册好友消息管理的监听事件
    FriendDataManager.getInstance():addListener(self,self.onCallBackFunc);
    EventDispatcher.getInstance():register(SocketManager.s_phpMsg, self, self.onPhpMsgResponse);
    EventDispatcher.getInstance():register(NativeManager._Event, self, self.nativeCallEvent);

    if PlatformConfig.platformYiXin == GameConstant.platformType then
        publ_getItemFromTree(self.m_widget.view_addFriend.v, {"item_2","icon"}):setFile("Login/yx/Login/yixin_addFriend.png");
        publ_getItemFromTree(self.m_widget.view_addFriend.v, {"item_2","t"}):setText("添加易信好友");


        local qqx,qqy = self.m_widget.view_addFriend.item_qq:getPos();
        local face2facex,face2facey = self.m_widget.view_addFriend.item_face2face:getPos();
        self.m_widget.view_addFriend.item_face2face:setPos(qqx,qqy);
        self.m_widget.view_addFriend.item_boyaa:setPos(face2facex,face2facey);
        return;
    end

    if PlatformConfig.platformTrunk ~= GameConstant.platformType and
        PlatformConfig.platformBaiDuCps ~= GameConstant.platformType and
        PlatformConfig.platformMMCps ~= GameConstant.platformType and
        PlatformConfig.platformIOSMainVesion ~= GameConstant.platformType
        then
            self.m_widget.view_addFriend.item_wechat:setVisible(false);
            local wechatx,wechaty = self.m_widget.view_addFriend.item_wechat:getPos();
            local qqx,qqy = self.m_widget.view_addFriend.item_qq:getPos();
            local face2facex,face2facey = self.m_widget.view_addFriend.item_face2face:getPos();
            self.m_widget.view_addFriend.item_qq:setPos(wechatx,wechaty);
            self.m_widget.view_addFriend.item_face2face:setPos(qqx,qqy);
            self.m_widget.view_addFriend.item_boyaa:setPos(face2facex,face2facey);
    end

    if not PlatformFactory.curPlatform:needToShareWindow() then
        self.m_widget.view_addFriend.item_qq:setVisible(false);
        local qqx,qqy = self.m_widget.view_addFriend.item_qq:getPos();
        local face2facex,face2facey = self.m_widget.view_addFriend.item_face2face:getPos();
        self.m_widget.view_addFriend.item_face2face:setPos(qqx,qqy);
        self.m_widget.view_addFriend.item_boyaa:setPos(face2facex,face2facey);
    end
end


NewFriendView.on_enter = function (self)
    self:initWidgets();
    


    FriendDataManager.getInstance():requestAllFriends();

    --刷新视图
    self:refreshView();


    self:set_tab_callback(self,self.tab_click);
    
    DebugLog('Profile clicked friend stop:'..os.clock(),LTMap.Profile)

end

NewFriendView.on_exit = function (self)

end

NewFriendView.tab_click = function (self, index)
    --1:我的好友，2:添加好友，3:牌局记录

    if index == 1 then
        self.m_data.currentSelectIndex = 1;
        self.m_data.viewType = l_view_type.main;
    elseif index == 2 then
        self.m_data.viewType = l_view_type.addFriend;
        if GameConstant.check_addressBook == nil then
            self.m_data.afViewType = l_af_tab_type.phone;
        end
    elseif index == 3 then
       self.m_data.viewType = l_view_type.score;
    end
    self:refreshView();
end


--调取通讯录
NewFriendView.nativeGetPhoneNumbers = function (self)
    Loading.showLoadingAnim("正在获取通讯录...");

end

--面对面视图里选择要添加的好友 触摸事件
NewFriendView.eventSelectFriendToAdd = function (obj, finger_action, x, y, drawing_id_first, drawing_id_current)

    if finger_action == kFingerDown then
	elseif finger_action == kFingerMove then
	elseif finger_action == kFingerUp then
        if drawing_id_first ~= drawing_id_current then
            return;
        end
        if not obj.o then
            return;
        end
        local btn = obj.btn;
        btn.isSelected = not btn.isSelected;
        btn.imgSelected:setVisible(btn.isSelected == true);
    end
end

--添加好友左侧的tab item 触摸事件
NewFriendView.eventAddFriendItemTouch = function (obj, finger_action, x, y, drawing_id_first, drawing_id_current)

    if finger_action == kFingerDown then
	elseif finger_action == kFingerMove then
	elseif finger_action == kFingerUp then
        if drawing_id_first ~= drawing_id_current then
            return;
        end
        if not obj.o then
            return;
        end
        local btn = obj.btn;
        local state = obj.state;

        if state then
            --如果是qq或者微信，则每次点击都要弹出，其余则要下次选择才能弹出
            if obj.o.inviteWeChatFriend and state == l_af_tab_type.wechat then
                obj.o:inviteWeChatFriend();
                return;
            end
            if obj.o.inviteQQFriend and state == l_af_tab_type.qq then
                 obj.o:inviteQQFriend();
                 return;
            end
            --当前的state，再点击return
            if obj.o.m_data.afViewType and obj.o.m_data.afViewType == state then
                return;
            else
                obj.o.m_data.afViewType = state;
            end
        end

        if  obj.o.refreshViewAddFriend  then
            obj.o:refreshViewAddFriend();
        end
        if obj.o.refreshFace2FaceScrollView and state == l_af_tab_type.face2face then
            obj.o:refreshFace2FaceScrollView();
        end
        if obj.o.resetAddFriendByIdView and state == l_af_tab_type.boyaa then
            obj.o:resetAddFriendByIdView();
        end

        --如果没在通讯录界面应该停止发送验证php
        if state ~= l_af_tab_type.phone then
            obj.o:stopSendPhoneNumbersVerify();
        end
    end
end

--初始化user detail info
NewFriendView.setDefaultUserDetailInfo = function (self)
    self.m_data.userinfo = {};
    self:setUserDetailInfo(l_default_userinfo);
    self.m_data.currentSelectMid = "0";
end

--初始化user detail info
NewFriendView.setUserDetailInfo = function (self, data)
    DebugLog("NewFriendView.setUserDetailInfo");
    if not self.m_data.currentSelectMid then
        DebugLog("self.m_data.currentSelectMid is nil");
        return;
    end
    local d = nil;
    for i = 1, #data do
        if data[i].mid and (tostring(data[i].mid) == tostring(self.m_data.currentSelectMid)) then
            d = data[i];
        end
    end
    if not d then
        DebugLog("NewFriendView.setUserDetailInfo d is nil");
        return;
    end

    self.m_data.userinfo = {};

    self.m_data.userinfo.name =  tostring(d.mnick);
    self.m_data.userinfo.gender = tonumber(d.sex) or kSexMan;
    self.m_data.userinfo.level = d.level;
    self.m_data.userinfo.coin = tonumber(d.money) or 0;
    self.m_data.userinfo.wintimes = d.wintimes;
    self.m_data.userinfo.losetimes = d.losetimes;
    self.m_data.userinfo.drawtimes = d.drawtimes;
    self.m_data.userinfo.winStr = "";
    self.m_data.userinfo.large_image = d.large_image;
    self.m_data.userinfo.small_image = d.small_image;
    self.m_data.userinfo.gift_status = d.gift_status;
    self.m_data.userinfo.like_status = d.like_status;
    self.m_data.userinfo.alias = d.alias;
    if self.m_data.userinfo.alias and string.len(tostring(self.m_data.userinfo.alias)) > 0 then
        self.m_data.userinfo.name = tostring(self.m_data.userinfo.alias);
    end
    self.m_data.userinfo.likes = d.likes;
    self.m_data.userinfo.charms = d.charms;
    self.m_data.userinfo.charms_level = d.charms_level;
    self.m_data.userinfo.charms_title = d.charms_title;
    self.m_data.userinfo.vip_level = tonumber(d.vip_level) or 0;
    self.m_data.userinfo.mid = tonumber(d.mid) or -1;
    self.m_data.userinfo.money = tonumber(d.money) or -1;
end


--刷新界面：好友详细信息
NewFriendView.updateViewFriendInfo = function (self ,imageName)
    DebugLog("[NewFriendView updateViewFriendInfo]");

    if not self.m_data.userinfo or not self.m_data.userinfo.name then 

        return;
    end
    local w_userinfo = self.m_widget.view_main.userinfo;
    w_userinfo.name:setText(stringFormatWithString(self.m_data.userinfo.name, 12, true) );

    local isExist, localDir = NativeManager.getInstance():downloadImage(self.m_data.userinfo.large_image);
	self.mHeadIconDir = localDir;
    if not isExist then
        local tmpDir = nil;
    	if tonumber(sex) == kSexMan then
            tmpDir = "Commonx/default_man.png";
	    else
            tmpDir = "Commonx/default_woman.png";
    	end
        setMaskImg(self.m_widget.view_main.userinfo.head,"Hall/userinfo/head_mask.png",tmpDir)
    else
        setMaskImg(self.m_widget.view_main.userinfo.head,"Hall/userinfo/head_mask.png",localDir)
    end

    if self.m_data.userinfo.gender == kSexMan then
        w_userinfo.genderText:setText("男");
        w_userinfo.genderImg:setFile("Commonx/male.png");
    else
        w_userinfo.genderText:setText("女");
        w_userinfo.genderImg:setFile("Commonx/female.png");
    end
    --设置头像
    self.m_widget.view_main.userinfo.head:setFile(localDir);
    if imageName and imageName == localDir then
        setMaskImg(self.m_widget.view_main.userinfo.head,"Hall/userinfo/head_mask.png",localDir)
    end

    w_userinfo.level:setText("Lv."..self.m_data.userinfo.level);
    w_userinfo.coin:setText(trunNumberIntoThreeOneFormWithInt(self.m_data.userinfo.money or 0, true));
    w_userinfo.winStr:setText(self.m_data.userinfo.winStr);
    w_userinfo.id:setText("ID:"..self.m_data.userinfo.mid);

    local vipLevel = self.m_data.userinfo.vip_level;
    if vipLevel <= 0 then
		w_userinfo.vip:setVisible(false);
	else
		if vipLevel >= 10 then
			vipLevel = 10
		end
        local hall_user_infoPin_map = require("qnPlist/hall_user_infoPin")
		w_userinfo.vip:setFile(hall_user_infoPin_map["VIP"..vipLevel..".png"]);
	end
    w_userinfo.laudText:setText("赞");
    w_userinfo.laudCount:setText(tostring(self.m_data.userinfo.likes));
	w_userinfo.charmStr:setText(tostring(self.m_data.userinfo.charms));

	w_userinfo.charmLevelImg:setFile("Hall/popinfo/charmLv" .. self.m_data.userinfo.charms_level .. ".png");
	if tonumber(self.m_data.userinfo.like_status) == 1 then

		w_userinfo.laudImg:setFile("Hall/popinfo/zan2.png");
		w_userinfo.laudText:setText("已赞");
        w_userinfo.btn_laud.IsHadLaud = true;
    else
        w_userinfo.laudImg:setFile("Hall/popinfo/zan1.png");
		w_userinfo.laudText:setText("赞");
        w_userinfo.btn_laud.IsHadLaud = false;
	end

    local coord = CreatingViewUsingData.roomUserInfoView.coinText;
	coord = CreatingViewUsingData.roomUserInfoView.winLostText;

	local gameInfoStr = self.m_data.userinfo.wintimes .. coord.win ..
					    self.m_data.userinfo.losetimes .. coord.lost ..
					    self.m_data.userinfo.drawtimes .. coord.ping;
	w_userinfo.winStr:setText(stringFormatWithString(gameInfoStr,16,true));
    self.m_widget.view_main.userinfo.btn_delete:setPickable(true);
	self.m_widget.view_main.userinfo.btn_delete:setIsGray(false);
    if self.m_data.userinfo.mid and tostring(self.m_data.userinfo.mid) then
        local item = self.m_widget.friendItems[tostring(self.m_data.userinfo.mid)];
        if item then
            item:setMoney(self.m_data.userinfo.money or 0);
            self:setFreeStatus(self.m_data.userinfo.mid, self.m_data.userinfo.gift_status);
        end
    end
end

--更新面对面加好友界面scrollview 的头像
NewFriendView.updateFace2FaceScrollViewHeadImg = function (self, imgName)
    DebugLog("updateFace2FaceScrollViewHeadImg"..tostring(imgName));

    local allNodes = self.m_widget.view_addFriend.v_face2face.scrollview.allNodes;
    if not allNodes then
        return;
    end
    for i = 1, #allNodes do
        local node = allNodes[i];
        DebugLog("node.head.localDir:"..tostring(node.head.localDir));
        if node and node.head and imgName and node.head.localDir == imgName then
            node.head:setFile(node.head.localDir);
        end
    end

end

--好友排序 在线>离线 社交关系(通讯录添加的好友) > 游戏关系 关系相同 按照金币数量排序
NewFriendView.sortFriend = function (self)

    local allFriends = FriendDataManager.getInstance().m_Friends;
    local tableOnline = {};
    local tableNotOnline = {};
    for k, v in pairs(allFriends) do
        if v.online == true then
            table.insert(tableOnline, v);
        else
            table.insert(tableNotOnline, v);
        end
    end
    local func_unit = function(t)
        local ret = {};
        if not t or (#t < 1) then
            return ret;
        end
        local tPhoneAdd = {};
        local tNotPhoneAdd = {};
        for i = 1, #t do
            if t[i].isPhoneAdd == 1 then
                table.insert(tPhoneAdd, t[i]);
            else
                table.insert(tNotPhoneAdd, t[i]);
            end
        end
        function moneySort(s1 , s2)
	        return (tonumber(s1.money) or 0) > (tonumber(s2.money) or 0)
        end
        if #tPhoneAdd > 1 then
            table.sort(tPhoneAdd, moneySort);
        end
        if #tNotPhoneAdd > 1 then
            table.sort(tNotPhoneAdd, moneySort);
        end
        for i = 1, #tPhoneAdd do
            table.insert(ret, tPhoneAdd[i]);
        end
        for i = 1, #tNotPhoneAdd do
            table.insert(ret, tNotPhoneAdd[i]);
        end
        return ret;
    end
    tableOnline = func_unit(tableOnline);
    tableNotOnline = func_unit(tableNotOnline);
    allFriends = {};
    for i = 1, #tableOnline do
        table.insert(allFriends, tableOnline[i]);
    end
    for i = 1, #tableNotOnline do
        table.insert(allFriends, tableNotOnline[i]);
    end
    self.m_data.m_friendsData = {};
    for i = 1, #allFriends do
        if allFriends[i] and allFriends[i].mid then
            self.m_data.m_friendsData[ #self.m_data.m_friendsData + 1] = allFriends[i];
        end

    end
end

--追踪触摸事件
NewFriendView.eventLocation = function (self)
    local currentSelctedData = FriendDataManager.getInstance().m_Friends[self.m_data.currentSelectMid];
    if not currentSelctedData then
        DebugLog("NewFriendView.eventLocation currentSelctedData is nil");
        return;
    end
    if MatchRoomScene_instance then
    	Banner.getInstance():showMsg("在比赛场无法使用追踪功能");
    	return;
    end

    if PlayerManager.getInstance():myself().isInGame then
    	Banner.getInstance():showMsg("请在游戏结束后再追踪！");
    else
    	FriendDataManager.getInstance():trackFriendSocket(tonumber(PlayerManager:getInstance():myself().mid),tonumber(currentSelctedData.mid));

    end
end

--删除触摸事件
NewFriendView.eventDelete = function (self)
    local currentSelctedData = FriendDataManager.getInstance().m_Friends[self.m_data.currentSelectMid];
    if not currentSelctedData then
        DebugLog("NewFriendView.eventDelete currentSelctedData is nil");
        return;
    end
    if currentSelctedData.mid == nil then
		Banner.getInstance():showMsg("数据异常,mid为空,无法删除!")
		return
	end

    local content = "您确定要删除该好友吗？"
	local view = PopuFrame.showNormalDialogForCenter( "温馨提示",
														content,
											  				self,
											  					0,
											  					0,
											  				false,
											  				false,
											  				"确定",
											  				"取消");
	view:setConfirmCallback(self,function (self )
		self.m_widget.view_main.userinfo.btn_delete:setPickable(false);
	    self.m_widget.view_main.userinfo.btn_delete:setIsGray(true);
	    FriendDataManager.getInstance():deleteFriendSocket(currentSelctedData.mid, currentSelctedData.mnick);
	    Loading.showLoadingAnim("正在删除好友...");
	end)
end

--聊天触摸事件
NewFriendView.eventChat = function (self)

    local currentSelctedData = FriendDataManager.getInstance().m_Friends[self.m_data.currentSelectMid];
    if not currentSelctedData then
        DebugLog("NewFriendView.eventChat currentSelctedData is nil");
        return;
    end
	local str = "@" .. currentSelctedData.mnick;
	DebugLog(currentSelctedData.mnick .. ";mid:" ..tostring(currentSelctedData.mid))

	local friends = FriendDataManager.getInstance().m_Friends;
	local name = friends[tostring(currentSelctedData.mid)].alias;

	if not name or string.len(name) <= 0 then
		name = friends[tostring(currentSelctedData.mid)].mnick;
	end
	local chatwnd = new(ChatWindow,
                        PlayerManager.getInstance():myself().mid,
                        PlayerManager.getInstance():myself().sex,
                        PlayerManager.getInstance():myself().small_image,
					    currentSelctedData.mid,
                        name,
                        friends[tostring(currentSelctedData.mid)].sex,
                        friends[tostring(currentSelctedData.mid)].small_image);
	self:addChild(chatwnd);
end


--点赞触摸事件
NewFriendView.eventLaud = function (self)
    local currentSelctedData = FriendDataManager.getInstance().m_Friends[self.m_data.currentSelectMid];
    if not currentSelctedData then
        DebugLog("NewFriendView.eventRemark currentSelctedData is nil");
        return;
    end
    local w_userinfo = self.m_widget.view_main.userinfo;
    if w_userinfo.btn_laud.IsHadLaud == false then
        w_userinfo.btn_laud.IsHadLaud = true;

		local post_data 		= {};
	    post_data.mid 			= PlayerManager:getInstance():myself().mid;
	    post_data.fmid 			= currentSelctedData.mid;

	    SocketManager.getInstance():sendPack( PHP_CMD_LIKE_IT,post_data);
	end
end

--分享按钮 触摸事件
NewFriendView.eventShare = function (obj)
    DebugLog("NewFriendView.eventShare");

end

--邀请或者添加好友触摸事件
NewFriendView.eventInviteOrAddFriend = function (obj)
    DebugLog("NewFriendView.eventInviteOrAddFriend");
    if not obj then
        DebugLog("NewFriendView.eventInviteOrAddFriend ob is nil");
        return;
    end
    if not obj.b and not obj.b.data  then --and not obj.o then
        DebugLog("NewFriendView.eventInviteOrAddFriend data is nil");
        return;
    end
    local name = obj.b.data.name or -1;
    local phoneNo = obj.b.data.phoneNo or -1;
    local mid = obj.b.data.mid or 0;
    if mid == 0 then
        --obj.o:sendInviteSms(name, phoneNo);
        local param = {};
        param.name = name or "";
        param.phone = phoneNo or "";
        SocketManager.getInstance():sendPack(PHP_CMD_REQUEST_INVITE_SMS, param)
        Banner.getInstance():showMsg("短信已发送,请注意查收..");

    else
        Banner.getInstance():showMsg("添加好友消息已发出,请注意查看消息..");
        --添加好友
        FriendDataManager.getInstance():addFriendSocket(mid, name, name , 1);
    end
end

--通过id查找 按钮触摸事件
NewFriendView.eventSearch = function (self)
    DebugLog("NewFriendView.eventSearch");
    local TextId= self.m_widget.view_addFriend.v_boyaa.edit_text:getText();
	local numId	= tonumber(TextId);
	if numId then
		Loading.showLoadingAnim("正在查找ID...");
		self.m_data.isSearchById = true;
		FriendDataManager.getInstance():QueryUserInfo(PHP_CMD_QUERY_USER_INFO,{numId})
	else
		Banner.getInstance():showMsg("输入错误，请输入正确的数字ID");
	end
    self.m_widget.view_addFriend.v_boyaa.edit_text:setText("");
    self.m_widget.view_addFriend.v_boyaa.edit_text:setHintText(l_const_str.searchHint);

end

--通过id查找 后添加好友 按钮触摸事件
NewFriendView.eventAdd = function (self)
    DebugLog("NewFriendView.eventAdd");
    if self.m_widget.view_addFriend.v_boyaa.btn_add.toAddMid then
        self.m_widget.view_addFriend.v_boyaa.btn_add:setPickable(false);
	    self.m_widget.view_addFriend.v_boyaa.btn_add:setIsGray(true);
        local mid = self.m_widget.view_addFriend.v_boyaa.btn_add.toAddMid
        local mnick = self.m_widget.view_addFriend.v_boyaa.name:getText();
	    FriendDataManager.getInstance():addFriendSocket(mid, mnick, "" );
    end
end


--面对面加好友 添加已选按钮
NewFriendView.eventFace2FaceAddFriendSelected = function (self)
    DebugLog("NewFriendView.eventFace2FaceAddFriendSelected");
    local allNodes = self.m_widget.view_addFriend.v_face2face.scrollview.allNodes;
    if not allNodes then
        return;
    end
    local selectedMid = {};
    for i = 1, #allNodes do
        local node = allNodes[i];
        if node and node.isSelected == true and node.mid then
            table.insert(selectedMid, node.mid);
        end
    end
    if #selectedMid <=0 then
        Banner.getInstance():showMsg("请选择要添加的好友!")
    else
        --像服务器发送信息
        FriendDataManager.getInstance():face2FaceAddFriend(selectedMid);
        Banner.getInstance():showMsg("添加好友消息，已发送!")
        for i = 1, #allNodes do
            local node = allNodes[i];
            if node and node.isSelected == true and node.mid then
                FriendDataManager.getInstance().m_enterChanelData.SendedPlayers[tostring(node.mid)] = tostring(node.mid);
                FriendDataManager.getInstance().m_enterChanelData.players[tostring(node.mid)] = nil;
                allNodes[tostring(node.mid)] = nil;
                node:removeFromSuper();
                node = nil;
            end
        end
    end

end

--面对面加好友 确定按钮
NewFriendView.eventFace2FaceEnterChanel = function (self)
    DebugLog("NewFriendView.eventFace2FaceEnterChanel");
    local text = self.m_widget.view_addFriend.v_face2face.edit_text:getText();
    if not tonumber(text) then
        Banner.getInstance():showMsg("输入错误，请输入正确的数字ID");
        return;
    end
    local len = string.len(publ_trim(text));
    if len ~= 4 or tonumber(text) <= 1000 then
        Banner.getInstance():showMsg("输入错误，输入4位数字ID且要大于1000");
        return;
    end
    Banner.getInstance():showMsg("搜索好友中..");

    FriendDataManager.getInstance():face2FaceEnterChanel(text);

end

--修改备注名触摸事件
NewFriendView.eventRemark = function ( self )
    local currentSelctedData = FriendDataManager.getInstance().m_Friends[self.m_data.currentSelectMid];
    if not currentSelctedData then
        DebugLog("NewFriendView.eventRemark currentSelctedData is nil");
        return;
    end
	-- body
	if self.mRemarkWnd then
		return;
	end
	require("MahjongHall/Friend/FriendRemarkWindow")
	self.mRemarkWnd = new(FriendRemarkWindow, currentSelctedData.alias);
	self:addChild(self.mRemarkWnd);

	self.mRemarkWnd:setOnConfirm(function ( self, text )
		local name = text;
		if not name or string.len(name) <= 0 then
			Banner.getInstance():showMsg("昵称不能为空!")
			return
		end

		-- body
		FriendDataManager.getInstance():requestModifyFriendAlias(self.m_data.currentSelectMid, text)
		self:removeChild(self.mRemarkWnd, true);
		self.mRemarkWnd = nil;

		--更新右侧
		--昵称

		if not name or string.len(name) <= 0 then
			name = currentSelctedData.mnick;
		end
        self.m_widget.view_main.userinfo.name:setText(stringFormatWithString(name, 22, true));

	end,self);

	self.mRemarkWnd:setOnClose(function ( self )
		-- body
		self:removeChild(self.mRemarkWnd, true);
		self.mRemarkWnd = nil;
	end,self);
end

--刷新好友列表
NewFriendView.updateFriendListView = function (self)
    DebugLog("NewFriendView.updateFriendListView");

    local friendData = FriendDataManager.getInstance().m_Friends;

    if not self.m_widget.friendItems  then
        return;
    end

    --要先排序s
    self:sortFriend();
    --设置item的位置，选中状态，是否在线
    for i = 1, #self.m_data.m_friendsData do
        local d = self.m_data.m_friendsData[i];
        local item ,index = self:getItemByMid(d.mid);
        if item then
            local tmp = self.m_widget.friendItems[i];
            item:setOnline(d.online or false);
        end
        item:setBg(self.m_data.currentSelectMid == item.mid and "Hall/HallSocial/itemBgSelected.png" or "Hall/HallSocial/itemBg.png");
    end

end

--获取好友的详细信息
NewFriendView.onClickedFriendItemBtn = function ( self, id )
    DebugLog("onClickedFriendItemBtn:"..tostring(id));
    if not id then
        DebugLog("NewFriendView.onClickedFriendItemBtn id is nil");
        return;
    end
	DebugLog(id .. "  clicked!")
    --切换另一界面前先清空界面
    self.m_data.userinfo = {};
    self:setUserDetailInfo(l_default_userinfo);

    self:updateViewFriendInfo();
    self.m_data.currentSelectIndex = self:getCurrentSelectedIndex(id);
	self.m_data.currentSelectMid = id;

    self:updateFriendListView();
	FriendDataManager.getInstance():QueryUserInfo(PHP_CMD_QUERY_USER_INFO_POP_FRIEND,{id})
end

NewFriendView.setFreeStatus = function ( self, friendId , status )
	DebugLog("NewFriendView.setFreeStatus")
	-- body
	if friendId and status then
		--设置已免费赠送(data)
		if FriendDataManager.getInstance().m_Friends[friendId] then
			FriendDataManager.getInstance().m_Friends[friendId].gift_status = status;
		end
        if not self.m_widget.friendItems  then
            return;
        end
        for i = 1, #self.m_widget.friendItems do
            local item = self.m_widget.friendItems[i];
            if friendId == item.mid then
                item:setFreeIcon( status )
            end
        end
		-- umeng 反馈
		umengStatics_lua(UMENG_SEND_FRIEND_MONEY);
	end
end

--免费赠送金币
NewFriendView.onClickedFriendItemFreeBtn = function ( self, id )
	if not id then
        DebugLog("NewFriendView.onClickedFriendItemFreeBtn id is nil");
        return;
    end
    DebugLog(id .. " free clicked!")
	FriendDataManager.getInstance():giveMoney( id )
end

--删除好友
NewFriendView.deleteFriendItem = function ( self, badFriendId )
	DebugLog("NewFriendView.deleteFriendItem :" ..badFriendId)
	Loading.hideLoadingAnim();
    if not self.m_widget.friendItems then
		return
	end
    self.m_widget.view_main.userinfo.btn_delete:setPickable(true);
	self.m_widget.view_main.userinfo.btn_delete:setIsGray(false);
    local nextSelctIdIdx = 1;
	for i = 1, #self.m_widget.friendItems do
		DebugLog("curmid: "..self.m_widget.friendItems[i].mid)
		if self.m_widget.friendItems[i].mid == badFriendId then
			DebugLog("curmid == badFriendId ")
            self.m_widget.view_main.m_listview:removeChild(self.m_widget.friendItems[i],true);
			table.remove(self.m_widget.friendItems, i);
            table.remove(self.m_data.m_friendsData, i)
            self.m_widget.friendItems[tostring(badFriendId)] = nil;

            nextSelctIdIdx = i;
			break;
		end
	end

    for i = 1, #self.m_widget.friendItems do
        local item = self.m_widget.friendItems[i];
        item:setPos(0, l_friendlist_item_h*(i-1));
    end

	if #self.m_widget.friendItems == 0 then -- 没有朋友
		self.m_widget.view_main.m_listview:removeAllChildren()
        self.m_widget.view_main.userinfo:setVisible(false);
        self.m_widget.view_main.t_nofriend:setVisible(true);
	else
        self:setCurrentSelcet();
    end
end

NewFriendView.updateFriendViewRemarks = function ( self, params )
	DebugLog("NewFriendView.updateFriendViewRemarks")
	if not params then
		return
	end
    for i = 1, #self.m_widget.friendItems do
        local item = self.m_widget.friendItems[i];
        if tostring(item.mid) == tostring(params.friendId) then
            item:setName(params.alias)
        end
    end
end

NewFriendView.updateItemMoney = function ( self, friendId, money )
	-- body
	-- 先排序
	--self:sort();
	for i = 1, #self.m_widget.friendItems do
		if  tonumber(friendId) == tonumber(self.m_widget.friendItems[i].mid) then
			self.m_widget.friendItems[i]:setMoney("" .. money);
			break;
		end
	end
end


--切换视图
NewFriendView.refreshView = function (self)
    self.m_widget.btn_main.selectedImg:setVisible(self.m_data.viewType == l_view_type.main);
    self.m_widget.btn_addFriend.selectedImg:setVisible(self.m_data.viewType == l_view_type.addFriend);
    self.m_widget.btn_score.selectedImg:setVisible(self.m_data.viewType == l_view_type.score);
    self.m_widget.view_main:setVisible(self.m_data.viewType == l_view_type.main);
    self.m_widget.view_addFriend:setVisible(self.m_data.viewType == l_view_type.addFriend);
    self.m_widget.view_score:setVisible(self.m_data.viewType == l_view_type.score);

    --如果没在通讯录界面应该停止发送验证php
    if self.m_data.viewType ~= l_view_type.addFriend or self.m_data.afViewType ~= l_af_tab_type.phone then
        self:stopSendPhoneNumbersVerify();
    end
    --刷新添加好友界面
    if self.m_data.viewType == l_view_type.addFriend then
        self:refreshViewAddFriend();
    elseif self.m_data.viewType == l_view_type.score then
        self:sendPhpGetFriendPlayRecord();
    end

end

--重置添加通讯录好友界面
NewFriendView.resetAddfriendPhoneView = function (self)
    if  self.m_widget.view_addFriend.v_phone then
        self.m_widget.view_addFriend.v_phone.scrollview:removeAllChildren();
        self.m_widget.view_addFriend.v_phone.searchEditText:setText("");
        self.m_widget.view_addFriend.v_phone.searchEditText:setHintText(l_const_str.phoneHint);
    end
end

--获取通讯录
NewFriendView.getNativePhoneNumbers = function (self)
   native_to_java(kGetAllPhoneNumbers , "");
end

--切换视图 添加好友界面
NewFriendView.refreshViewAddFriend = function (self)


    --读取通讯录获取电话号码
    if (self.m_data.afViewType == l_af_tab_type.phone) then
        local count = 0;
        local bGet = false;
        for k, v in pairs(self.m_data.allPhoneNumbers) do
            count = count + 1;
            if v.sendedSign == 0 then
                bGet = true;
                break;
            end
        end
        if count == 0 then
            bGet = true;
        end
        --通讯录缓存
        if bGet == true then
            self:resetAddfriendPhoneView();
            self:getNativePhoneNumbers();
        end

    end

    local fun = function (item, b)
        if not item then
            return;
        end
        item:setFile(b and "Hall/HallSocial/itemBgSelected.png" or "Hall/HallSocial/itemBg.png");
    end

    if self.m_data.afViewType ~= l_af_tab_type.boyaa then
        self.m_data.isSearchById = false;
    end

    fun(self.m_widget.view_addFriend.item_phone, self.m_data.afViewType == l_af_tab_type.phone)
    fun(self.m_widget.view_addFriend.item_wechat, self.m_data.afViewType == l_af_tab_type.wechat)
    fun(self.m_widget.view_addFriend.item_qq, self.m_data.afViewType == l_af_tab_type.qq)
    fun(self.m_widget.view_addFriend.item_face2face, self.m_data.afViewType == l_af_tab_type.face2face)
    fun(self.m_widget.view_addFriend.item_boyaa, self.m_data.afViewType == l_af_tab_type.boyaa)

    self.m_widget.view_addFriend.v_phone:setVisible(self.m_data.afViewType == l_af_tab_type.phone);
    self.m_widget.view_addFriend.v_wechat:setVisible(self.m_data.afViewType == l_af_tab_type.wechat);
    self.m_widget.view_addFriend.v_qq:setVisible(self.m_data.afViewType == l_af_tab_type.qq);
    self.m_widget.view_addFriend.v_face2face:setVisible(self.m_data.afViewType == l_af_tab_type.face2face);
    self.m_widget.view_addFriend.v_boyaa:setVisible(self.m_data.afViewType == l_af_tab_type.boyaa);
end

--刷新面对面加好友view
NewFriendView.refreshFace2FaceScrollView = function (self)
    self:createFace2FaceScrollView();
end

--刷新通过id加好友页面
NewFriendView.resetAddFriendByIdView = function (self)
    self.m_widget.view_addFriend.v_boyaa.tipText:setText("也可以告诉好友你的ID:"..tostring(PlayerManager.getInstance():myself().mid));
    self.m_widget.view_addFriend.v_boyaa.edit_text:setText("");
    self.m_widget.view_addFriend.v_boyaa.edit_text:setHintText(l_const_str.searchHint);
    self.m_widget.view_addFriend.v_boyaa.searchView:setVisible(false);
end

--初始化好友
NewFriendView.initFriendList = function ( self )
	DebugLog("NewFriendView.initFriendList")
    local friendsData 	 = FriendDataManager.getInstance().m_Friends;

    self:sortFriend();
end


--创建好友列表视图
NewFriendView.createFriendListView = function ( self )
	DebugLog("NewFriendView.createFriendListView")

    --切换另一界面前先清空界面
    self:setDefaultUserDetailInfo();

    self:sortFriend();

	self.m_widget.view_main.m_listview:removeAllChildren()

    local bNone = true;
    local itemH = l_friendlist_item_h;
    self.m_widget.friendItems = {};
    for i = 1, #self.m_data.m_friendsData do
        bNone = false;
        local v = self.m_data.m_friendsData[i];
        local item = new(FriendListItem, v)
        item.mid = v.mid;
        item.m_bgBtn:setType(Button.Gray_Type);
        item:setPos(0, itemH*(i-1));
        item:setOnClick(self, v.mid ,self.onClickedFriendItemBtn)
        item:setOnFreeClick(self, v.mid ,self.onClickedFriendItemFreeBtn)
  	    item:setOnline(v.online);
        self.m_widget.view_main.m_listview:addChild(item);
        table.insert(self.m_widget.friendItems, item);
        if v.mid and tostring(v.mid) then
            self.m_widget.friendItems[tostring(v.mid)] = item;
        end
    end
    local w, h = self.m_widget.view_main.m_listview:getSize();
    self.m_widget.view_main.m_listview:setSize(self.m_widget.view_main.m_listview:getSize())
    self.m_widget.view_main.userinfo:setVisible(not bNone);
    self.m_widget.view_main.t_nofriend:setVisible(bNone);

    self:updateFriendListView();
    FriendDataManager.getInstance():QueryUserInfo(PHP_CMD_QUERY_USER_INFO_POP_FRIEND,{self.m_data.currentSelectMid })

end


NewFriendView.getCurrentSelectedIndex = function (self, mid)
    for i = 1, #self.m_data.m_friendsData do
        if mid and (tostring(mid) == tostring(self.m_data.m_friendsData[i].mid)) then
            return i;
        end
    end
    return 1;
end
--
NewFriendView.getItemByMid = function (self, mid)
    for i = 1, #self.m_widget.friendItems do
        local item = self.m_widget.friendItems[i];
        if item and mid and tostring(mid) == tostring(item.mid) then
            return item, i;
        end
    end
    return nil;
end


--创建牌局记录view
NewFriendView.createFriendScoreView = function (self)
    DebugLog("NewFriendView.createFriendScoreView");

    local view = self.m_widget.view_score.scrollview;
    --创建前，先clean view
    view:removeAllChildren();

    view:setAdapter(nil)
    if #GlobalDataManager.getInstance().m_Record.friendList > 0 then

        local adapter = new(CacheAdapter, FriendPlayRecordItem, GlobalDataManager.getInstance().m_Record.friendList);
        view:setAdapter(adapter)
    end

    self.m_widget.view_score.tip:setVisible(not (#GlobalDataManager.getInstance().m_Record.friendList > 0));
end

--截图
NewFriendView.screenShot = function (self)
    if not self.m_data.isScreenShot then
        self.m_data.isScreenShot = true;
        DebugLog("NewFriendView.createFriendScoreView 发送截图请求");
        math.randomseed( tonumber(tostring(os.time()):reverse():sub(0,#kShareTextContent)) )
	    local rand = math.random();
	    local index = math.modf( rand*1000%6 );
	    local player = PlayerManager.getInstance():myself();

	    local data = {};
	    data.title = PlatformFactory.curPlatform:getApplicationShareName();
	    data.content = kShareTextContent[ index or 1 ];
	    data.username = player.nickName or "川麻小王子";
	    data.url = GameConstant.shareMessage.url or ""
        native_to_java( kScreenShot , json.encode( data ) );-- 向java发起截图请求
    end
end

--停止发送通讯录验证
NewFriendView.stopSendPhoneNumbersVerify = function (self)
    Loading.hideLoadingAnim();
    self.m_data.sendPhpGetPhoneCounts = 0;
    self:removeProp(l_const_seq.sendPhpVerifyPhone);
    if self.m_data.viewType == l_view_type.addFriend and self.m_data.afViewType == l_af_tab_type.phone then
        self:createAddFriendsPhoneView();
    end

end

--发送php获取好友对战记录
NewFriendView.sendPhpGetFriendPlayRecord = function (self)
    DebugLog("NewFriendView.sendPhpGetFriendPlayRecord");
    local param = {};
    param.mid = PlayerManager:getInstance():myself().mid;
    param.timestamp = GlobalDataManager.getInstance().m_Record.friendTimerstamp;
    if GlobalDataManager.getInstance().m_Record.friendTimerstamp == 0 then
        GlobalDataManager.getInstance().m_Record.friendList = {};
    end
    SocketManager.getInstance():sendPack(PHP_CMD_REQUEST_GET_FRIEND_RECORD, param)
end

--发送通讯录号码验证
NewFriendView.sendPhoneNumbersVerify = function (self)
    DebugLog("NewFriendView.sendPhoneNumbersVerify");
    Loading.showLoadingAnim();
    self.m_widget.view_addFriend.v_phone.tip:setVisible(false);
    local fun_send = function ()
        DebugLog("NewFriendView.fun_send");
        local param = {};
	    param.phone = {};
        local bSend = false;
        local data = self.m_data.allPhoneNumbers;
        local i = 1;
        for k, v in pairs(self.m_data.allPhoneNumbers) do
            if i > l_php_send_max then
                break;
            end
            if v.phoneNo and v.isSended ~= true and v.sendedSign == 0 then
                bSend = true;
                v.sendedSign = 1;
                param.phone[tostring(v.phoneNo)] = v.name;
                i = i + 1;
            end

        end
        if bSend == true then
            SocketManager.getInstance():sendPack(PHP_CMD_REQUEST_PHONE_NUMBER_VERIFY, param)
        else
            self:stopSendPhoneNumbersVerify();
        end

    end

    self:removeProp(l_const_seq.sendPhpVerifyPhone);
    DebugLog("NewFriendView.sendPhoneNumbersVerify11111111111111");
    local prop = self:addPropTranslate(l_const_seq.sendPhpVerifyPhone,kAnimRepeat,1000, 0, 0, 0, 0, 0)
	prop:setEvent(self, function ( self )
        if self.m_data.sendPhpGetPhoneCounts > 10 then
            self:stopSendPhoneNumbersVerify();
            return;
        end
        self.m_data.sendPhpGetPhoneCounts = self.m_data.sendPhpGetPhoneCounts +1;
        for k, v in pairs(self.m_data.allPhoneNumbers) do
            DebugLog("NewFriendView.sendPhoneNumbersVerify"..tostring(v.phoneNo)..":"..tostring(v.isSended));
            if v.phoneNo and v.isSended ~= true then
                fun_send();
                return;
            end
        end
        self:stopSendPhoneNumbersVerify();
	end);


end

--邀请微信好友
NewFriendView.inviteWeChatFriend = function (self)
    DebugLog("NewFriendView.inviteWeChatFriend");
    if not GameConstant.shareQQWechatMessage then
        Banner.getInstance():showMsg("邀请配置消息拉取失败..");
        return;
    end

    --邀请好友时 上报给php
    self:sendPhpInviteFriend();

    --处理易信添加好友
    local param = {};

    if  PlatformConfig.platformYiXin == GameConstant.platformType then
        param.style = 6
    else
        param.style = 3
    end
    param.url = GameConstant.shareQQWechatMessage.url or ""
    param.logo = GameConstant.shareQQWechatMessage.logo or "";
    param.message = GameConstant.shareQQWechatMessage.desc or "";

    native_to_java("shareOnlyMessage", json.encode(param));
    mahjongPrint(param);
    DebugLog("----------------");
end

--邀请qq好友
NewFriendView.inviteQQFriend = function (self)
    DebugLog("NewFriendView.inviteQQFriend");
    if not GameConstant.shareQQWechatMessage then
        Banner.getInstance():showMsg("邀请配置消息拉取失败..");
        return;
    end

    --邀请好友时 上报给php
    self:sendPhpInviteFriend();

    local param = {};
    param.style = 4;
    param.url = GameConstant.shareQQWechatMessage.url or "";
    param.logo = GameConstant.shareQQWechatMessage.logo or "";
    param.message = GameConstant.shareQQWechatMessage.desc or "";
    param.title = GameConstant.shareQQWechatMessage.title or "";
    native_to_java("shareOnlyMessage", json.encode(param));
    mahjongPrint(param);
    DebugLog("----------------");
end


--发送邀请短信php
NewFriendView.sendInviteSms = function (self, name, phone)
    DebugLog("NewFriendView.sendInviteSms");

    local param = {};
    param.name = name or "";
    param.phone = phone or "";

    SocketManager.getInstance():sendPack(PHP_CMD_REQUEST_INVITE_SMS, param)

    Banner.getInstance():showMsg("短信已发送,请注意查收..");

end



--赞的回调
NewFriendView.onFavourCallback = function ( self, isSuccess, data, jsonData)
	DebugLog("NewFriendView.onFavourCallback")
	mahjongPrint(data)
	if not isSuccess or not data or not data.data then
        self.m_widget.view_main.userinfo.btn_laud.IsHadLaud = false;
		return;
	end
    local currentSelctedData = FriendDataManager.getInstance().m_Friends[self.m_data.currentSelectMid];
    if not currentSelctedData then
        self.m_widget.view_main.userinfo.btn_laud.IsHadLaud = false;
        DebugLog("NewFriendView.onFavourCallback currentSelctedData is nil");
        return;
    end


	DebugLog("self.m_mid:".. tostring(currentSelctedData.m_mid) .. ",fmid:"..data.data.fmid)
	if tonumber(data.status) == 1 and tonumber(currentSelctedData.mid) == tonumber(data.data.fmid) then

		self.m_widget.view_main.userinfo.laudImg:setFile("Hall/popinfo/zan2.png");
		self.m_widget.view_main.userinfo.laudText:setText("已赞");
        self.m_widget.view_main.userinfo.laudCount:setText(tonumber(self.m_widget.view_main.userinfo.laudCount:getText()) + 1);
		self.m_widget.view_main.userinfo.charmStr:setText(tonumber(self.m_widget.view_main.userinfo.charmStr:getText()) + tonumber(data.data.charm));

	else
		Banner.getInstance():showMsg(data.msg);
	end

end

--好友对战的记录
NewFriendView.friendPlayRecordCallback = function (self, isSuccess, data, jsonData)
	DebugLog("NewFriendView.friendPlayRecordCallback")

	if not isSuccess or not data or not data.data then
        DebugLog("data is nil");
		return;
	end
    --保存时间撮
    GlobalDataManager.getInstance().m_Record.friendTimerstamp = data.data.lastupdate or 0;


    local dd = (data.data and data.data.list) or {};
    for i = 1, #dd do
        if i > 100 then
            table.remove(GlobalDataManager.getInstance().m_Record.friendList, 1)
        end

        local dTmp = {};
        dTmp.time = dd[i].timestamp;
        dTmp.sortNum = tonumber(dd[i].timestamp) or 0;
        dTmp.type = tonumber(dd[i].playtype) or ""
        local play = {};
        local playMe = {};
        playMe.name = dd[i].me.nick or "";
        playMe.money = dd[i].me.money or "";
        table.insert(play, playMe);
        for j = 1, #dd[i].play do
            local t = {};
            t.name = dd[i].play[j].nick or "";
            t.money = dd[i].play[j].money or "";
            table.insert(play, t);
        end
        dTmp.play = play;
        GlobalDataManager.getInstance().m_Record.friendList[#GlobalDataManager.getInstance().m_Record.friendList+1] = dTmp;
    end
    --排序
    function timeSort(s1 , s2)
	    return (tonumber(s1.time) or 0) > (tonumber(s2.time) or 0)
    end
    if #GlobalDataManager.getInstance().m_Record.friendList > 1 then
        table.sort(GlobalDataManager.getInstance().m_Record.friendList, timeSort);
    end
    --绘制
    self:createFriendScoreView();
end

--发送邀请短信php回调
NewFriendView.sendInviteSmsCallback = function ( self, isSuccess, data, jsonData)
	DebugLog("NewFriendView.sendInviteSmsCallback")
	mahjongPrint(data);
	if not isSuccess or not data then
		return;
	end
    if tonumber(data.status) == 1 then

    end
    --邀请好友时 上报给php
    self:sendPhpInviteFriend();
end

--查询手机号码是否注册过php回调
NewFriendView.phoneNumberVerifyCallback = function ( self, isSuccess, data, jsonData)
	DebugLog("NewFriendView.phoneNumberVerifyCallback")

	mahjongPrint(data);
	if not isSuccess or not data then
		return;
	end
    if tonumber(data.status) == 1 then
        for k, v in pairs(data.data or {}) do
            local number = tonumber(k);
            if number then
                local mid = tonumber(v.mid) or 0;
                local isfriend = tonumber(v.isfriend) or 0;
                --自己也不添加
                if tostring(mid) == tostring(PlayerManager.getInstance():myself().mid) then
                    isfriend = 1;
                end
                self.m_data.allPhoneNumbers[number].mid = mid;
                self.m_data.allPhoneNumbers[number].isfriend = isfriend
                self.m_data.allPhoneNumbers[number].isSended = true;

            end
        end
        for k, v in pairs(self.m_data.allPhoneNumbers) do
            DebugLog(":::"..v.name..":"..v.phoneNo..":"..tostring(v.isSended));
        end
        if data.data  then
            self:createAddFriendsPhoneView();
        end
    end

end

NewFriendView.textOnChange = function ( self )
    local widget = self.m_widget.view_addFriend.v_phone.searchEditText;
    if not widget then
        return;
    end
	local str = publ_trim(widget:getText());
	local len = string.len(str);
    if len < 1 then
        widget:setText("");
        widget:setHintText(l_const_str.phoneHint);
        self:createAddFriendsPhoneView();
    else
        self:createAddFriendsPhoneView(str);
    end
end

--通过玩家id查找 edittext onchange
NewFriendView.textOnChangeSearchByID = function ( self )
    local widget = self.m_widget.view_addFriend.v_boyaa.edit_text;
    if not widget then
        return;
    end
	local str = publ_trim(widget:getText());
	local len = string.len(str);
    if len < 1 then
        widget:setText("");
        widget:setHintText(l_const_str.searchHint);
    else
    end
    --检测只能输入数字
end

NewFriendView.textOnChangeFace2Face = function ( self )
    local widget = self.m_widget.view_addFriend.v_face2face.edit_text;
    if not widget then
        return;
    end
	local str = publ_trim(widget:getText());
	local len = string.len(str);
    if len < 1 then
        widget:setText("");
        widget:setHintText(l_const_str.face2faceHint);
    else
    end
    --检测只能输入数字
end

NewFriendView.isHaveStr = function (self, srcText, searchText)
    if not searchText or not srcText then
        return false;
    end
    srcText = tostring(srcText);
    searchText = tostring(searchText);
    return string.find(srcText, searchText) ~= nil
end

--创建一个node 面对面加好友
NewFriendView.createNodeByInfo = function (self, data)
    if not data or not data.mid then
        return nil;
    end
    local nameStr = "";
    local headLocalDir = "Commonx/default_man.png";
    local headDownloadDir = nil;
    local userdata = data.userdata;
    if userdata then
	    if userdata.alias and string.len(userdata.alias) > 0 then
		    nameStr = userdata.alias;
	    else
		    nameStr = userdata.mnick;
	    end
        local isExist,localDir = NativeManager.getInstance():downloadImage( userdata.small_image );
        headDownloadDir = localDir;
	    DebugLog("updateFace2FaceScrollView , 图片:"..localDir  );
	    if not isExist then
		    if tonumber(userdata.sex) == kSexMan then
			    localDir = "Commonx/default_man.png";
		    else
			    localDir = "Commonx/default_woman.png";
		    end
	    end
        headLocalDir = localDir;
    end

    --创建时是隐藏的
    local node = new(Node);
    node:setVisible(userdata and true or false);
    node.mid = data.mid;
    node:setSize(l_const.face2faceNodeW, l_const.face2faceNodeH);
    node:setAlign(kAlignTopLeft);
    node.isSelected = true;

    local headBg = new(Image, "Hall/friend/icon_1.png")
    headBg:setAlign(kAlignTop);

    node:addChild(headBg);

    local head = new(Image, headLocalDir)
    head:setAlign(kAlignCenter);
    local sizetmp = 105;
    head:setSize(sizetmp,sizetmp);
    head.localDir = headDownloadDir--headLocalDir;
    headBg:addChild(head);
    node.head = head;


    local headUnSelected = new(Image, "Hall/friend/icon_3.png")
    headUnSelected:setAlign(kAlignCenter);
    headBg:addChild(headUnSelected);
    node.imgUnSelected = headUnSelected;

    local headSelected = new(Image, "Hall/friend/icon_2.png")
    headSelected:setAlign(kAlignCenter);
    headBg:addChild(headSelected);
    node.imgSelected = headSelected;


    nameStr = stringFormatWithString(nameStr,10,true)
    local name = new(Text, nameStr, 0, 0, kAlignLeft, "", 24, 0xfb , 0xed , 0xd2)
    name:setAlign(kAlignBottom);
    node:addChild(name);
    node.name = name;

    node.imgSelected:setVisible(node.isSelected == true);
    --设置item的触摸事件
    node:setEventTouch({o = self, btn = node,}, NewFriendView.eventSelectFriendToAdd);
    return node;
end


--创建面对面添加好友的scrollview
NewFriendView.createFace2FaceScrollView = function (self)
    DebugLog("NewFriendView createFace2FaceScrollView");

    --创建之前，先清除view
    self.m_widget.view_addFriend.v_face2face.scrollview:removeAllChildren();
    self.m_widget.view_addFriend.v_face2face.scrollview.allNodes = {};
    self.m_widget.view_addFriend.v_face2face.scrollview:setScrollBarWidth(5);


    if FriendDataManager.getInstance().m_enterChanelData.retNo
    and tonumber(FriendDataManager.getInstance().m_enterChanelData.retNo)
    and tonumber(FriendDataManager.getInstance().m_enterChanelData.retNo) == 1 then
        --人数已满--retNo这个变量只做一次应用，提示完设置0
        Banner.getInstance():showMsg("该小组已满,请输入其他数字建立小组.");
        FriendDataManager.getInstance().m_enterChanelData.retNo = 0;
        return;
    end
    local blankX, blankY = 70, 16;
    local w, h = l_const.face2faceNodeW, l_const.face2faceNodeH;
    local allChanelPlayers = FriendDataManager.getInstance().m_enterChanelData.players;
    local i = 1;
    for k, v in pairs(allChanelPlayers) do
        if v then
            local node = self:createNodeByInfo(v);
            node:setPos( math.fmod((i-1), 4)*(w+blankX), math.floor((i-1)/4)*(h+blankY));
            self.m_widget.view_addFriend.v_face2face.scrollview:addChild(node);
            table.insert(self.m_widget.view_addFriend.v_face2face.scrollview.allNodes, node);
            self.m_widget.view_addFriend.v_face2face.scrollview.allNodes[tostring(v.mid)] = node;
            i = i + 1;
        end
    end

end

--更新面对面添加好友的scrollview的显示
NewFriendView.updateFace2FaceScrollView = function (self , data)
    DebugLog("NewFriendView.updateFace2FaceScrollView");
    if not data or type(data) ~= "table" then
        DebugLog("NewFriendView.updateFace2FaceScrollView data is nil");
        return;
    end

    local allChanelPlayers = FriendDataManager.getInstance().m_enterChanelData.players;
    for i = 1, #data do
        local node = self.m_widget.view_addFriend.v_face2face.scrollview.allNodes[tostring(data[i].mid)]
        if node then
            --显示节点
            node:setVisible(true);
            if allChanelPlayers[tostring(data[i].mid)] then
                allChanelPlayers[tostring(data[i].mid)].userdata = data[i];
            end

            local name = "";
		    if data[i].alias and string.len(data[i].alias) > 0 then
			    name = data[i].alias;
		    else
			    name = data[i].mnick;
		    end
            --长度限制
            name = stringFormatWithString(name,10,true)
            node.name:setText(name);


            local isExist,localDir = NativeManager.getInstance():downloadImage( data[i].small_image );
		    DebugLog("updateFace2FaceScrollView , 图片:"..localDir  );
		    node.head.localDir = localDir;
            if isExist and localDir then
                node.head:setFile(localDir)
		    end

        end
    end
end

FriendPhoneItem = class(Node);
FriendPhoneItem.ctor = function (self,data)

    if not data then
        return;
    end
        local w, h = 729, 80;
        local node = self;--new(Node);
        node:setAlign(kAlignTopLeft);
        node:setSize(w, h);

        local line = new(Image, "Commonx/split_hori.png")
        line:setAlign(kAlignBottom);
        local lineW, lineH = line:getSize();
        line:setSize(w,lineH);
        node:addChild(line);
        local msg = data.name or "";
        msg = stringFormatWithString(msg,12,true)
        local name = new(Text, msg, 0, 0, kAlignLeft, "", 30, 0xff , 0xff , 0xff)
        name:setAlign(kAlignLeft);
        name:setPos(0, 0);
        node:addChild(name);

        msg = data.phoneNo or "";
        msg = stringFormatWithString(tostring(msg),11,true)
        local phoneNo = new(Text, msg, 0, 0, kAlignLeft, "", 30, 0xff , 0xc5 , 0x87)
        phoneNo:setAlign(kAlignLeft);
        phoneNo:setPos(242, 0);
        node:addChild(phoneNo);

        local file = data.mid == 0 and "Commonx/green_small_btn.png" or "Commonx/red_small_btn.png";
        local btn = new(Button, file, nil, nil, nil, 0, 0, 0, 0);
        btn.data = data;
        btn:setAlign(kAlignRight);
        btn:setPos(10, 3)
        node:addChild(btn);
        node.btn = btn;
        local obj = { b = btn};
        btn:setOnClick(obj, NewFriendView.eventInviteOrAddFriend);

        msg = data.mid == 0 and "邀 请" or "添加"; --0表示未注册
        local text = new(Text, msg, 0, 0, kAlignLeft, "", 30, 0xff , 0xff , 0xff)
        text:setAlign(kAlignCenter);
        text:setPos(0, -8);
        btn:addChild(text);
end

--创建可以邀请或者添加的通讯录好友
NewFriendView.createAddFriendsPhoneView = function (self, searchText)
    DebugLog("NewFriendView createAddFriendsPhoneView");
    --创建之前，先清除view

    local w, h = 729, 80;
    local data = {};
    for k,v in pairs(self.m_data.allPhoneNumbers) do
        if v.name and v.phoneNo and v.isfriend and v.mid  then
            if v.isfriend ~= 1 then--已成为好友不必显示
                if searchText then
                    if self:isHaveStr(v.name, searchText) or self:isHaveStr(v.phoneNo, searchText) then
                        table.insert(data, v);
                    end
                else
                    table.insert(data, v);
                end
            end
        end
    end
    self.m_widget.view_addFriend.v_phone.scrollview:setAdapter(nil)
    if #data > 0 then

        require("ui/adapter")
        local adapter = new(CacheAdapter, FriendPhoneItem, data);
        self.m_widget.view_addFriend.v_phone.scrollview:setAdapter(adapter)
    end
    local views = self.m_widget.view_addFriend.v_phone.scrollview.m_views;
    for i = 1, #views do
        if views[i] and views[i].btn then
            local obj = {o = self, b = views[i].btn};
            views[i].btn:setOnClick(obj, NewFriendView.eventInviteOrAddFriend);
        end
    end

    self.m_widget.view_addFriend.v_phone.tip:setVisible(not (#data > 0) );
end

--更新查找id 界面 被查找对象的头像
NewFriendView.updateViewSearchByIDHead = function (self, imageName)
    self.m_widget.view_addFriend.v_boyaa.head:setFile(imageName);
end

--更新查找好友界面
NewFriendView.updateSearchByIdView = function (self, data)
    if not data or type(data) ~= "table" then
        self:resetAddFriendByIdView();
        return;
    end

    if #data <= 0 then
        Banner.getInstance():showMsg("没有搜索到该id");
    end

    if #data > 0 then
        self.m_widget.view_addFriend.v_boyaa.btn_add:setPickable(true);
	    self.m_widget.view_addFriend.v_boyaa.btn_add:setIsGray(false);
		local name = "";
		if data[1].alias and string.len(data[1].alias) > 0 then
			name = data[1].alias;
		else
			name = data[1].mnick;
		end
        --长度限制
        name = stringFormatWithString(name,16,true)

		local money 	  = trunNumberIntoThreeOneFormWithInt(data[1].money,true);
        self.m_widget.view_addFriend.v_boyaa.name:setText(name);
        self.m_widget.view_addFriend.v_boyaa.coin:setText(money.."金币");
        self.m_widget.view_addFriend.v_boyaa.btn_add.toAddMid 	  = data[1].mid;

        local isExist,localDir = NativeManager.getInstance():downloadImage( data[1].large_image );
		DebugLog("searchIconImg , 被搜索人的图片:"..localDir  );
		if not isExist then
			if tonumber(data[1].sex) == kSexMan then
				localDir = "Commonx/default_man.png";
			else
				localDir = "Commonx/default_woman.png";
			end
		end
        self.m_widget.view_addFriend.v_boyaa.head:setFile(localDir);
        self.m_widget.view_addFriend.v_boyaa.searchView:setVisible(true);
    end

end


--处理进入频道的消息
NewFriendView.dispatchMsgFace2FaceEnterChanel = function ( self, data )
    DebugLog("NewFriendView.dispatchMsgFace2FaceEnterChanel");
    if not data then
        DebugLog("data is nil");
        return;
    end
    if self.m_data.afViewType ~= l_af_tab_type.face2face then
        DebugLog("self.m_data.afViewType ~= l_af_tab_type.face2face");
        return;
    end
    local friendInstance = FriendDataManager.getInstance();
    local playerList = {};
    friendInstance.m_enterChanelData.retNo = data.retNo;
    --过滤当前输入的频道号
    if data.chanelId and tostring(friendInstance.m_enterChanelData.inputChanelId) ==  tostring(data.chanelId) then
        friendInstance.m_enterChanelData.chanelId = data.chanelId;
        local num = data.num;
        for i = 1, #data.list do
            local tmp = {}
            tmp.mid = data.list[i];
            tmp.userdata = nil;
            --如果进入房间的是自己或者已经是好友不显示
            if tostring(tmp.mid) ~= tostring(PlayerManager.getInstance():myself().mid)
            and not friendInstance.m_Friends[tostring(tmp.mid)]
            and not friendInstance.m_enterChanelData.SendedPlayers[tostring(tmp.mid)] then
                friendInstance.m_enterChanelData.players[tostring(tmp.mid)] = tmp;
            end

        end
        self:createFace2FaceScrollView();
        if data.list then
            friendInstance:QueryUserInfo(PHP_CMD_QUERY_USER_INFO, data.list)
        end
    end
end

--设置当前选择的好友
NewFriendView.setCurrentSelcet = function (self)
    DebugLog("NewFriendView.setCurrentSelcet");

    if self.m_data.currentSelectIndex <= #self.m_data.m_friendsData then
        self:onClickedFriendItemBtn(self.m_data.m_friendsData[self.m_data.currentSelectIndex].mid);
    else
        if #self.m_data.m_friendsData >= 1 then
            self.m_data.currentSelectIndex = 1;
            self:onClickedFriendItemBtn(self.m_data.m_friendsData[self.m_data.currentSelectIndex].mid);
        end
    end
    if self.m_data.currentSelectIndex == 1 then
        self.m_widget.view_main.m_listview:gotoTop();
    end
end

--邀请qq或者微信好友时发送 php信息
NewFriendView.sendPhpInviteFriend = function (self)
    DebugLog("NewFriendView.sendPhpInviteFriend");

    local param = {};
    param.mid = PlayerManager:getInstance():myself().mid;
    SocketManager.getInstance():sendPack(PHP_CMD_INVITE_FRIEND, param)
end


--FriendDataManager的监听回调
NewFriendView.onCallBackFunc = function (self, actionType, actionParam)
	DebugLog("NewFriendView.onCallBackFunc :")
	DebugLog(actionType)

    if kTrackFriendByPHP == actionType then--追踪
		if actionParam then
            if HallScene_instance then
                GameConstant.curRoomLevel = actionParam.level;
			    RoomData.getInstance():setRoomAddr(actionParam);
			    if HallScene_instance.matchApplyWindow then
				    HallScene_instance.traceToRoomFlag = 1;
				    HallScene_instance.matchApplyWindow:traceToRoom();
			    else
				    HallScene_instance:processLoginRoom();
			    end
            end
		end
    elseif kInvitingFriendInHall == actionType then
		self.delegate:friendDataControlled()
    elseif kFriendRequestByPHP == actionType then --好友列表
		self:createFriendListView()
	elseif kFriendDetailByPHP == actionType then --好友的detail info
            self:setUserDetailInfo(actionParam);
            self:updateViewFriendInfo();
    elseif kFriendGiveRequestByPHP == actionType then ---赠送好友金币  消息返回
		self:setFreeStatus(actionParam.id, actionParam.status);
    elseif kFriendModifyAliasRequestByPHP == actionType then --修改备注 {friendId ,alias}
		self:updateFriendViewRemarks(actionParam)
    elseif kFriendDeleteByPHP == actionType then --删除好友
		self:deleteFriendItem(actionParam)
    elseif kFriendAddSuccessBySocket == actionType then --添加好友成功
        FriendDataManager.getInstance():requestAllFriends();
    elseif kFriendMoneyUpdateByPHP == actionType then --更新金币
		self:updateItemMoney(actionParam.friendId, actionParam.money );
    elseif kFriendAllOnlineFriendsBySocket == actionType
    or kFriendComeBySocket == actionType
    or kFriendGoneBySocket == actionType then --查询所有的在线好友
        DebugLog("查询在线好友:".. tostring(self.m_data.currentSelectMid));
        self:createFriendListView();
        --更新右侧详细信息
        self:setCurrentSelcet();
    elseif kFriendSearchByPHP == actionType  then--查找好友by id
        if self.m_data.afViewType == l_af_tab_type.boyaa then
            if self.m_data.isSearchById then
                self:updateSearchByIdView(actionParam);
            end
        elseif self.m_data.afViewType == l_af_tab_type.face2face then
            self:updateFace2FaceScrollView(actionParam);
        end

    elseif kFriendFace2FaceEnterChanel == actionType then--面对面加好友:进入频道
        self:dispatchMsgFace2FaceEnterChanel(actionParam);

    elseif kFriendFace2FaceLeaveChanel == actionType then--面对面加好友:离开频道

    elseif kFriendFace2FaceAddFriend == actionType then--面对面加好友:添加好友
        self:createFace2FaceScrollView();
    elseif kFriendFace2FaceNoticeAddFriend == actionType then--面对面加好友:[通知消息]有人加你为好友了
        DebugLog("kFriendFace2FaceNoticeAddFriend == actionType");
        FriendDataManager.getInstance():requestAllFriends();
	end
end

NewFriendView.nativeCallEvent = function(self, param, data)
    if param == kDownloadImageOne then
        local imageName = data
        DebugLog("kDownloadImageOne == param imageName:"..imageName);
        if self.m_data.viewType == l_view_type.main then
            self:updateViewFriendInfo(imageName);
        elseif self.m_data.viewType == l_view_type.addFriend then
            if self.m_data.afViewType == l_af_tab_type.face2face then
                self:updateFace2FaceScrollViewHeadImg(imageName);
            elseif self.m_data.afViewType == l_af_tab_type.boyaa then
                self:updateViewSearchByIDHead(imageName);
            end
        end
    elseif param == kGetAllPhoneNumbers then                --获取电话号码
        if data == nil then 
            return
        end
        self.m_data.allPhoneNumbers = {};
        if GameConstant.iosDeviceType > 0 then
            local status = data.status;
            DebugLog("kGetAllPhoneNumbers:"..status);
            if data.list then
                data = data.list;
            else
                data = {};
            end
        end
        for k,v in pairs(data) do
            DebugLog(""..k..tostring(v.name)..tostring(v.number));
            local number = tonumber(v.number);
            if number then
                self.m_data.allPhoneNumbers[number] = {};
                self.m_data.allPhoneNumbers[number].mid = 0;
                self.m_data.allPhoneNumbers[number].isfriend = 0;
                self.m_data.allPhoneNumbers[number].name = tostring(v.name);
                self.m_data.allPhoneNumbers[number].phoneNo = number;
                self.m_data.allPhoneNumbers[number].sendedSign = 0;--是否发送过的标记
            end
        end
        --拉取通讯录
        self:sendPhoneNumbersVerify();
    end
end


NewFriendView.onPhpMsgResponse = function ( self, param, cmd, isSuccess,... )
	if self.httpRequestsCallBackFuncMap[cmd] then
		self.httpRequestsCallBackFuncMap[cmd](self,isSuccess,param,...)
	end
end

NewFriendView.httpRequestsCallBackFuncMap =
{
    [PHP_CMD_REQUEST_GET_FRIEND_RECORD] = NewFriendView.friendPlayRecordCallback,
	[PHP_CMD_LIKE_IT]           =  NewFriendView.onFavourCallback,
    [PHP_CMD_REQUEST_PHONE_NUMBER_VERIFY] = NewFriendView.phoneNumberVerifyCallback,
    [PHP_CMD_REQUEST_INVITE_SMS] = NewFriendView.sendInviteSmsCallback,
};
