--[[
不拥有弹出窗口的引用，只是对窗口弹出前做顺序的调整
规则:
    新注册用户: 首充，签到
    正常用户：强制更新，可选更新，老玩家礼包，公告，签到，评论，活动强推，首充
]]

require("MahjongData/GlobalDataManager");

new_pop_wnd_mgr = class();

new_pop_wnd_mgr.m_instance = nil;

new_pop_wnd_mgr.enum = {
    force_update = 1,--强制更新
    update = 2,--更新
    veteran_player = 3,--老玩家礼包
    notice = 4, --公告
    sign = 5, --签到
    comment = 6, --评论
    activity_push = 7,--活动强推
    first_charge = 8, --首充
    --hongbao = 9, --红包--特殊窗口添加即显示在最上面
    normal = 100, --非特殊要求窗口
};

new_pop_wnd_mgr.pop_index = {
    min = 0,
    new_register = {
        [new_pop_wnd_mgr.enum.first_charge] = 1,
        [new_pop_wnd_mgr.enum.sign] = 2,
    },
    normal = {
        [new_pop_wnd_mgr.enum.force_update] = 1,
        [new_pop_wnd_mgr.enum.update] = 2,
        [new_pop_wnd_mgr.enum.veteran_player] = 3,
        [new_pop_wnd_mgr.enum.notice] = 4,
        [new_pop_wnd_mgr.enum.sign] = 5,
        [new_pop_wnd_mgr.enum.comment] = 6,
        [new_pop_wnd_mgr.enum.activity_push] = 7,
    }
};

new_pop_wnd_mgr.get_instance = function ()
    if not new_pop_wnd_mgr.m_instance then
        DebugLog("[new_pop_wnd_mgr]: create m_instance");
        new_pop_wnd_mgr.m_instance = new(new_pop_wnd_mgr);
    end
    return new_pop_wnd_mgr.m_instance;
end

new_pop_wnd_mgr.ctor = function (self)
    DebugLog("[new_pop_wnd_mgr]:ctor");
    self.m_list = {};
    self.m_b_poped_first_charge = false; --新注册用户，已经弹出过首冲
    self.m_b_back_to_hall_actively = false; --游戏主动返回大厅标记

    self.m_wnd_order_index =  8; --窗口的优先级

    --窗口开始显示的控制变量
    --大厅登陆后，php消息发送后再开始窗口逻辑 
    --self.m_start_show = false;
    self.m_loading = nil; 
    
    --如果php消息5s内没返回，self.m_start_show也设置true    
--    Clock.instance():schedule_once(function()
--        self.m_start_show = true;    
--    end, 5);

    --定时器 每帧都检查是否有窗口显示的函数
    self.m_timer = Clock.instance():schedule(function ( dt )
        self:timer_to_show();
    end);
end

new_pop_wnd_mgr.dtor = function (self)
    DebugLog("[new_pop_wnd_mgr]:dtor");
    self.m_timer:cancel()
	self.m_timer = nil
    self.m_loading:removeFromSuper();
    self.m_loading = nil;
end

new_pop_wnd_mgr.set_wnd_start_show = function (self, b)
    self.m_start_show = b;
end

new_pop_wnd_mgr.get_wnd_start_show = function (self)
    return self.m_start_show;
end

--登陆2秒内不允许点击界面
new_pop_wnd_mgr.show_loading = function (self, v)
    if not self.m_loading then
        self.m_loading =  new(Node)--(Image, "Commonx/zhezhao.png");
        self.m_loading:setSize(1280/System.getLayoutScale(), 720/System.getLayoutScale())
        
        self.m_loading:addToRoot();

        self.m_loading:setLevel(GameConstant.view_level.max);

        self.m_loading:setEventTouch(self, function()
            --DebugLog(" ");
        end);
    end
    self.m_loading:setVisible(v);
    --如果php消息5s内没返回，self.show_loading也设置false 
    --防止意外情况下不消失屏蔽   
    Clock.instance():schedule_once(function()
        self:show_loading(false);    
    end, 5);
end


new_pop_wnd_mgr.increase_wnd_order_index = function (self)
    self.m_wnd_order_index = self.m_wnd_order_index + 1;
    return self.m_wnd_order_index;
end

new_pop_wnd_mgr.decrease_wnd_order_index = function (self)
    self.m_wnd_order_index = self.m_wnd_order_index - 1;
    return self.m_wnd_order_index;
end

--获取list 大小
new_pop_wnd_mgr.get_list_size = function (self)
    return #self.m_list;
end



--是否是新玩家
new_pop_wnd_mgr.b_new_player = function (self)
    local myself = PlayerManager.getInstance():myself();

    return myself and myself.isRegister == 1;
end

new_pop_wnd_mgr.clear_wnd_list = function (self)
    DebugLog("[new_pop_wnd_mgr]:clear_wnd_list");
    self.m_list = {};
end

--检查窗口是否可以添加
new_pop_wnd_mgr.check_wnd_can_add = function(self, obj)
    --DebugLog("[new_pop_wnd_mgr]:check_wnd_can_add");

    if not obj then
        return false;
    end

    local t = obj.t;
    local b_play_anim = obj.b_play_anim == nil or obj.b_play_anim;--默认为true
    local wnd = obj.wnd
    if (t ~= new_pop_wnd_mgr.enum.normal) then --非正常窗口
        if self:b_new_player() then
            --如果不是从游戏中返回大厅则不添加；
            if not self.m_b_back_to_hall_actively then
                return false;
            end
        end
    end
    return true;
end


--检查窗口是否可以显示--非主界面不能显示签到，公告等界面
new_pop_wnd_mgr.check_wnd_can_show = function(self, obj)

    if not obj or not obj.wnd then
        return false;
    end

    --是否正在显示
    if self:check_had_wnd_showing(obj) then
        return false;
    end

    return true;
end

--检查 窗口是否添加过
new_pop_wnd_mgr.check_wnd_added = function (self, wnd_index)
    --DebugLog("[new_pop_wnd_mgr]:check_wnd_added"); 

    for i = 1, #self.m_list do
        if wnd_index == self.m_list[i].wnd_idx  then
            return true;
        end
    end
    return false;
end

new_pop_wnd_mgr.deal_with_special_logic = function (self)

end

--add window
new_pop_wnd_mgr.add_window = function (self, obj)
    DebugLog("[new_pop_wnd_mgr]:add_window");
    if not obj then
        return;
    end

    local pop_index = obj.pop_index;
    local t = obj.t;
    local b_play_anim = obj.b_play_anim == nil or obj.b_play_anim;--默认为true
    local wnd = obj.wnd
  
    --检查是否可以添加
    if not self:check_wnd_can_add(obj) then
        return;
    end

    local wnd_index = pop_index or self:get_wnd_idx(t);
    if wnd_index  then
        if self:check_wnd_added(wnd_index) then
            return wnd_index;
        else
            local item = {}
            item.wnd = wnd;
            item.wnd_idx = wnd_index;
            item.is_showing = false;
            item.b_play_anim = b_play_anim;
            item.type = t;

            table.insert(self.m_list, item);
            if t ~= new_pop_wnd_mgr.enum.normal then --and t ~= new_pop_wnd_mgr.enum.hongbao then
                self:create_wnd_by_item(item);
            end
            return wnd_index;
        end


    end

end

--add and show
new_pop_wnd_mgr.add_and_show = function (self, wnd_type)
    DebugLog("[new_pop_wnd_mgr]:add_and_show");
    self:add_window({t = wnd_type});
    self:show_wnd();
end

new_pop_wnd_mgr.util_remove = function (self, param, b_type)
    if #self.m_list < 1 then
        return;
    end
    local index = 1;
    while #self.m_list > 0 and index <= #self.m_list do
        local compare_param = b_type and self.m_list[index].type or self.m_list[index].wnd_idx;
        if param == compare_param  then
            table.remove(self.m_list, index);
        else
            index = index + 1;
        end            
    end
end

--remove window
new_pop_wnd_mgr.remove_wnd_by_type = function (self, t)
    DebugLog("[new_pop_wnd_mgr]:remove_wnd_by_type");

    self:util_remove(t, true);
end

new_pop_wnd_mgr.remove_wnd_by_pop_index = function (self, pop_index)
    DebugLog("[new_pop_wnd_mgr]:remove_wnd_by_pop_index");

    self:util_remove(pop_index, false);
end

--定时器，如果列表中有要显示的window，则显示
new_pop_wnd_mgr.timer_to_show = function (self)
    self:show_wnd();
end

--remove and show
new_pop_wnd_mgr.hide_and_show = function (self, t)
    DebugLog("[new_pop_wnd_mgr]:remove_and_show");
    self:remove_wnd_by_type(t);
    self:show_wnd();
end

--检查是列表中是否有正在显示的窗口
new_pop_wnd_mgr.check_had_wnd_showing = function (self, obj)
    if not obj then
        return false;
    end

    if obj.type == self.enum.normal then
        if obj.is_showing == true then
            return true;
        end
    else
        --如果是公告等特殊窗口只能在大厅界面显示
        local view_tag = global_get_current_view_tag();
        if view_tag ~= GameConstant.view_tag.hall then
            self:remove_wnd_by_type(obj.type);
            return true;
        end
        --按排序的特殊弹窗，只要有一个是正在显示的，其他的就不能显示
        for i = 1, #self.m_list do
            if self.m_list[i].is_showing == true then
                return true;
            end
        end
    end

    return false;
end

new_pop_wnd_mgr.show_wnd = function (self)

--    --窗口逻辑控制变量
--    if not self.m_start_show then
--        return;
--    end

    --列表中没有item
    if #self.m_list < 1 then
        return;
    end
    --排序
    self:sort_wnd();
    for i = 1, #self.m_list do
        local item = self.m_list[i];
        if self:check_wnd_can_show(item) then

            item.is_showing = true;
            if item.b_play_anim then
                item.wnd:playShowAnim();
            else
                CustomNode.show(item.wnd);
            end 
        end
    end
end

-- show
new_pop_wnd_mgr.create_wnd_by_item = function (self, item)
    DebugLog("[new_pop_wnd_mgr]:create_wnd_by_item");
    if GameConstant.iosDeviceType > 0 and GameConstant.iosPingBiFee then
        return;
    end
    if not item then
        return;
    end

    if item.type == self.enum.force_update then
    	if GlobalDataManager.NewUpDateWnd then
            item.wnd = GlobalDataManager.NewUpDateWnd;
            item.wnd:set_pop_index(self:get_wnd_idx(self.enum.force_update));
			GlobalDataManager.NewUpDateWnd:showWnd();
		end
    elseif item.type == self.enum.update then
    	if GlobalDataManager.NewUpDateWnd then
            item.wnd = GlobalDataManager.NewUpDateWnd
            item.wnd:set_pop_index(self:get_wnd_idx(self.enum.update));
			GlobalDataManager.NewUpDateWnd:showWnd();
		end
    elseif item.type == self.enum.veteran_player then
        if HallScene_instance then
            HallScene_instance:showVeteranPlayerAwardWindow();
            if HallScene_instance.m_veteran_player_award_window then
                item.wnd = HallScene_instance.m_veteran_player_award_window;
                item.wnd:set_pop_index(self:get_wnd_idx(self.enum.veteran_player));
            end
        end
    elseif item.type == self.enum.notice then
        GlobalDataManager.getInstance():showNoticeWindow();
        if HallScene_instance and HallScene_instance.popuview then
            item.wnd = HallScene_instance.popuview;
            item.wnd:set_pop_index(self:get_wnd_idx(self.enum.notice));
        end
    elseif item.type == self.enum.sign then
        if HallScene_instance then
            HallScene_instance:requestSignWnd();
            if HallScene_instance.signWindow then
                item.wnd = HallScene_instance.signWindow;
                item.wnd:set_pop_index(self:get_wnd_idx(self.enum.sign));
            end
        end
        if self:b_new_player() then
            GlobalDataManager.getInstance().m_new_register.b_pop_sign = true;
        end
    elseif item.type == self.enum.comment then
    		local str = "没有金币？不要愁，现在去应用商店评价博雅四川麻将，就可以获得丰厚金币奖励。"
			DebugLog("new_pop_wnd_mgr.enum.comment")
			--local view = PopuFrame.showNormalDialog("系统提示", str, GameConstant.curGameSceneRef, nil, nil, true, false, "去评价")
            local view = new(PopuFrame, GameConstant.curGameSceneRef,true,  true,  false, "去评价");
            local title = "系统提示";
	        infoStr = "去评价";
	        title = GameString.convert2Platform(title);
	        local infoStr = GameString.convert2Platform(str);

	        view:setTitle( title);
	        view:setContentText(infoStr);

			view:setConfirmCallback(self, function ( self )
				native_to_get_value(kGetMarketNum);
				local marketNum = dict_get_int(kGetMarketNum, kGetMarketNum .. kResultPostfix, 0)
		        if marketNum ~= 0 then
		            publ_launchTargetMarket()
					local mid = PlayerManager.getInstance():myself().mid or ""
                    g_DiskDataMgr:setUserData(mid,'isEvaluated',1)
		            self.requestEvaluateAnim = new(AnimInt , kAnimNormal, 0, 1, 800, 0)
					self.requestEvaluateAnim:setEvent(self , function (self)
                    	SocketManager.getInstance():sendPack(PHP_CMD_REQUEST_EVALUATE_AWARD, {})
	                    delete(self.requestEvaluateAnim)
                        self.requestEvaluateAnim = nil;
                    end)
		        end
			end)
            item.wnd = view
            item.wnd:set_pop_index(self:get_wnd_idx(self.enum.comment));
     
    elseif item.type == self.enum.activity_push then
    elseif item.type == self.enum.first_charge then
        if HallScene_instance and  self:b_new_player() then
            self.m_b_poped_first_charge = true;
            item.wnd = FirstChargeView.getInstance();
            item.wnd:set_pop_index(self:get_wnd_idx(self.enum.first_charge));

            HallScene_instance:showFirstChargeView();
            GlobalDataManager.getInstance().m_new_register.b_pop_charge = true;
        end
    end

end

--弹出的顺序
new_pop_wnd_mgr.get_wnd_idx = function (self, t)
    DebugLog("[new_pop_wnd_mgr]:get_wnd_idx");

    local t_index = nil;

    --非特殊窗口添加，顺序自增
    if t == new_pop_wnd_mgr.enum.normal then
        t_index = self:increase_wnd_order_index();    
    else
        if self:b_new_player() then
            t_index = self.pop_index.new_register[t]
        else
            t_index = self.pop_index.normal[t];
        end
    end

    return t_index 
end

--弹出min的顺序
new_pop_wnd_mgr.get_min_wnd_idx = function (self)
    return self.pop_index.min;
end


--sort
new_pop_wnd_mgr.sort_wnd = function (self)

    --DebugLog("[new_pop_wnd_mgr]:sort_wnd");
    function tmp_sort(s1 , s2)
	    return s1.wnd_idx < s2.wnd_idx
    end
    if #self.m_list > 1 then
        table.sort(self.m_list, tmp_sort);
    end
end


--主动返回大厅标记 set
new_pop_wnd_mgr.set_back_to_hall_actively =function (self, b)
    self.m_b_back_to_hall_actively = b;
end

--主动返回大厅标记 get
new_pop_wnd_mgr.get_back_to_hall_actively = function ( self )
	return self.m_b_back_to_hall_actively ;
end

new_pop_wnd_mgr.pop_all_wnd = function (self)
    if #self.m_list < 1 then
        return;
    end
    local index = #self.m_list;
    while index > 0  do
        if self.m_list[index].wnd then
            self.m_list[index].wnd:hideWnd();
        end
        table.remove(self.m_list, index);
        index = index - 1;          
    end
end

----关闭窗口
--new_pop_wnd_mgr.pop_wnd = function (self)

--end

----关闭窗口
--new_pop_wnd_mgr.pop_all_wnd = function (self)

--end



