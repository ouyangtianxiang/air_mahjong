
require("MahjongCommon/new_pop_wnd_mgr");

--[Comment]
--ui布局文件
local layout_veteranPlayerAward = require(ViewLuaPath.."layout_veteranPlayerAward");

--[Comment]
--老玩家奖励界面
VeteranPlayerAwardWindow = class(SCWindow);

--[Comment]
--ctor
VeteranPlayerAwardWindow.ctor = function ( self, data)
    DebugLog("[VeteranPlayerAwardWindow :ctor]");
    self:set_pop_index(new_pop_wnd_mgr.get_instance():get_wnd_idx(new_pop_wnd_mgr.enum.veteran_player));
    --data
    self.m_data = data;
    self.m_bAwarded = false;
    self.m_b_invalid_back_event = true;
    --初始化
    VeteranPlayerAwardWindow.init(self);

end

--[Comment]
--dtor
VeteranPlayerAwardWindow.dtor = function (self)
    DebugLog("[VeteranPlayerAwardWindow :dtor]");

    EventDispatcher.getInstance():unregister(NativeManager._Event, self, self.nativeCallEvent);
    EventDispatcher.getInstance():unregister(SocketManager.s_phpMsg, self, self.onPhpMsgResponse);

    --new_pop_wnd_mgr.get_instance():hide_and_show(new_pop_wnd_mgr.enum.veteran_player);
end

--[Comment]
--init
VeteranPlayerAwardWindow.init = function (self)
    DebugLog("[VeteranPlayerAwardWindow: init]");

    --初始化控件
    self:init_widgets();

    --bind  event
    EventDispatcher.getInstance():register(NativeManager._Event, self, self.nativeCallEvent);
    EventDispatcher.getInstance():register(SocketManager.s_phpMsg, self, self.onPhpMsgResponse);

    --设置窗口的cover点击不关闭窗口
    self.cover:setEventTouch(self , function (self)
		DebugLog("cover touch");
	end);

    --设置tip
    if self.m_data.desc then
        self.m_tip:setText(self.m_data.desc);
    end
    --设置礼包图片和文字
    if self.m_data.list and type(self.m_data.list) == "table" then

        for i = 1, #self.m_data.list do
            if i > #self.m_node_awrd.items then
                break;
            end
            self.m_node_awrd.items[i].award_img:setSize(100,100);
            self.m_node_awrd.items[i].award_img:setPos(0, -20);
            local v = self.m_data.list[i];
            DebugLog("v.pic:"..tostring(v.pic));
            local isExist, img_path = NativeManager.getInstance():downloadImage(v.pic);
            self.m_node_awrd.items[i].img_path = img_path;
            if isExist then
                DebugLog("img_path:"..tostring(img_path));
                self.m_node_awrd.items[i].award_img:setFile(img_path);
            end
            self.m_node_awrd.items[i].award_text:setText(v.name or "");
        end
    end

    --设置按钮文字
    if self.m_data.btn_title then
        self.m_btn_award.t:setText(self.m_data.btn_title);
    end

--    --显示窗口
--    self:showWnd();
end

--[Comment]
--init_widgets
VeteranPlayerAwardWindow.init_widgets = function (self)

    self:addToRoot();
    self:setVisible(false);
    self.m_layout = SceneLoader.load(layout_veteranPlayerAward);
    self:addChild(self.m_layout);

    self:setWindowNode( self.m_layout );

    --背景
    self.m_bg = publ_getItemFromTree(self.m_layout, {"bg"});
    --领取奖励按钮
    self.m_btn_award = publ_getItemFromTree(self.m_bg, {"btn_award"});
    self.m_btn_award.t = publ_getItemFromTree(self.m_btn_award, {"t"});
    --title 图片
    self.m_title = publ_getItemFromTree(self.m_bg, {"title"});
    self.m_title:setFile("veteranPlayerAward/title_1.png");
    --tip text
    self.m_tip = publ_getItemFromTree(self.m_bg, {"t"});

    --awardnode
    self.m_node_awrd = publ_getItemFromTree(self.m_bg, {"v"});
    --奖品图片和描述
    self.m_node_awrd.items = {};
    for i = 1, 4 do
        local img = publ_getItemFromTree(self.m_node_awrd, {("item_"..i), "img"});
        local t = publ_getItemFromTree(self.m_node_awrd, {("item_"..i), "tt"});
        t:setScrollBarWidth(0);
        table.insert(self.m_node_awrd.items, {award_img = img, award_text = t});
    end
    --ios 屏蔽
    if GameConstant.iosDeviceType>0 and GameConstant.iosPingBiFee then
      local plus = publ_getItemFromTree(self.m_v, {"add3"});
      local item = publ_getItemFromTree(self.m_v, {"item_4"});
      item:setVisible(false);
      plus:setVisible(false);
    end
    self.m_btn_award:setOnClick(self, function (self)
        DebugLog("btn click get award");
        if self.m_bAwarded == true then
            self.m_btn_award:setPickable(false);
            --领取过奖励则快速开始
            if HallScene_instance then
                HallScene_instance:onClickedQuickStartBtn();
            end
            self:hideWnd();
        else
            self.m_bAwarded = true;
            self.m_btn_award.t:setText("快速开始");

            --领取奖励
            self:requestVeteranPlayerGiftAward();
        end
    end);




end

--发送老玩家礼包请求
VeteranPlayerAwardWindow.requestVeteranPlayerGiftAward = function (self)
	local param_data = {};
	param_data.mid =  PlayerManager.getInstance():myself().mid;
    SocketManager.getInstance():sendPack(PHP_CMD_REQEUST_VETERAN_PALYER_GIFT_AWARD, param_data);
end

--老玩家礼包领奖
VeteranPlayerAwardWindow.VeteranPlayerGiftAwardCallback = function(self, isSuccess, data )
    DebugLog("VeteranPlayerAwardWindow:VeteranPlayerGiftAwardCallback");
    --Banner.getInstance():showMsg("酸酸的飞机螺丝钉飞机落地式军服的思路分的思路附sdf近的思路解放路第三方撒旦解放了第三届分的历史房贷首付款独守空sssssss房11111111111111111")--(data.msg);
    if  not data  then
        DebugLog(" not success");
--        --关闭窗口
--        self:hideWnd();
        return
    end

    if data.status == 1 then
--        self.m_bAwarded = true;
--        self.m_btn_award.t:setText("快速开始");
    end
    if data.msg then
        --Banner.getInstance():showMsg(data.msg);
        AnimationAwardTips.play(data.msg);
	    showGoldDropAnimation();
    end
--    --关闭窗口
--    self:hideWnd();
end


--java事件回调
VeteranPlayerAwardWindow.nativeCallEvent = function (self, param, _detailData)
	DebugLog("VeteranPlayerAwardWindow:nativeCallEvent :"..tostring(_detailData));
	if kDownloadImageOne == param then

        for i = 1, #self.m_node_awrd.items do
            DebugLog("self.m_node_awrd.items.img_path:"..tostring(self.m_node_awrd.items[i].img_path ));
            if self.m_node_awrd.items[i].img_path == _detailData then
                self.m_node_awrd.items[i].award_img:setFile(_detailData);
                break;
            end
        end
	end
end

--php回调
VeteranPlayerAwardWindow.onPhpMsgResponse = function ( self, param, cmd, isSuccess )
	if self.phpMsgResponseCallBackFuncMap[cmd] then
		self.phpMsgResponseCallBackFuncMap[cmd](self,isSuccess,param)
	end
end

--php回调函数列表
VeteranPlayerAwardWindow.phpMsgResponseCallBackFuncMap =
{
	[PHP_CMD_REQEUST_VETERAN_PALYER_GIFT_AWARD] 		= VeteranPlayerAwardWindow.VeteranPlayerGiftAwardCallback,
}
