-- **2级界面公共基类**


require("ui/node");
local layout_hall_2_interface_base = require(ViewLuaPath.."layout_hall_2_interface_base")



hall_2_interface_base = class(Node)

hall_2_interface_base.ctor = function (self)
    self:init();
end

hall_2_interface_base.dtor = function (self)
    back_event_manager.get_instance():remove_event(self);
    hall_2_interface_mgr.get_instance():remove_interface(self);
end

--二级界面tag标识 get/set
hall_2_interface_base.get_tag = function (self)
    return self.m_tag;
end
hall_2_interface_base.set_tag = function (self, tag)
    if tag then
        self.m_tag = tag; 
        global_set_current_view_tag(self.m_tag);   
    end
end

hall_2_interface_base.get_playing_anim = function (self)
    return self.m_b_play;
end

hall_2_interface_base.set_playing_anim = function (self, b)
    self.m_b_play = b;
end

--设置tab的位置--1-4
hall_2_interface_base.set_tab_count = function (self, n)
    local config = {
        [1] = {
            v = {true, false, false, false},
            p = {{x = 0,y = -76}}
        },
        [2] = {
            v = {true, true, false, false},
            p = {{x = -112,y = -76}, {x = 129,y = -76}}
        },
        [3] = {
            v = {true, true, true, false},
            p = {{x = -241,y = -76}, {x = 0,y = -76}, {x = 240,y = -76}}
        },
        [4] = {
            v = {true, true, true, true},
            p = {{x = -367,y = -76}, {x = -126,y = -76}, {x = 113,y = -76}, {x = 353,y = -76}}
        },
    };
    n = tonumber(n)
    if not n or (n < 1 or n > 4) then
        return;
    end

    local config_tmp = config[n];
    for i = 1, 4 do
         local v = config_tmp.v[i]
         self.m_btn_tab[i]:setVisible(v);

         local p = config_tmp.p[i]
         if p then
            self.m_btn_tab[i]:setPos(p.x, p.y);   
         end
    end
end

--init
hall_2_interface_base.init = function (self)
    self:init_widget();

    self.m_tag = -1;
    self.m_b_play = false;
    self.m_callback_enter = {};
    self.m_callback_exit = {};

    globalAddEnterAnimInterface(self,self.m_v, self.m_btn_return)
    globalAddExitAnimInterface(self,self.m_v,self.m_btn_return,HallScene_instance.m_hallImg)
     
    self.m_bg:setSize(System.getScreenScaleWidth() - 80,System.getScreenScaleHeight() - 140)
end

hall_2_interface_base.init_widget = function (self)
    --加载界面
    self.m_layout = SceneLoader.load(layout_hall_2_interface_base);
    self:addChild(self.m_layout);
    
    self.m_btn_return = publ_getItemFromTree(self.m_layout, {  "btn_return"});
    self.m_v = publ_getItemFromTree(self.m_layout, {  "v"});
    self.m_bg = publ_getItemFromTree(self.m_v, {  "bg"});

    --4个标签按钮
    self.m_btn_tab = {};
    for i = 1, 4 do
        local btn = publ_getItemFromTree(self.m_bg, {  "btn_"..i});
        btn:setType(Button.Gray_Type);
        btn.index = i;
        btn.t = publ_getItemFromTree(btn, {  "t"});
        btn.img = publ_getItemFromTree(btn, {  "img"}); 
        table.insert(self.m_btn_tab, btn); 
        
        btn:setOnClick(self, function (self)
            self:on_tab_click(btn.index);

        end);      
    end

    --返回按钮事件
    self.m_btn_return:setOnClick(self, function (self)
        self:play_anim_exit();
    end);
end

-- 设置tab title
hall_2_interface_base.set_tab_title = function (self, title)

    if not title or type(title) ~= "table" then
        return;
    end

    for i = 1, #title do
        local btn = self.m_btn_tab[i];
        if btn and btn.t and type(title[i]) == "string" then
            btn.t:setText(title[i]);
        end        
    end
end

hall_2_interface_base.set_light_tab = function (self, index)
    for i = 1, #self.m_btn_tab do
        self.m_btn_tab[i].img:setVisible(index == i); 
    end
end

--n 4个tab按钮中的一个
--callback ={obj, func}
hall_2_interface_base.set_tab_callback = function (self,  _obj, _func)
    self.m_tab_click_callback = {obj = _obj, func = _func};
end

hall_2_interface_base.on_tab_click = function (self, index)
    DebugLog("on_tab_click index:"..index);
    for i = 1, #self.m_btn_tab do
        self.m_btn_tab[i].img:setVisible(index == i); 
    end
    local btn = self.m_btn_tab[index];
    if self.m_tab_click_callback and self.m_tab_click_callback.obj and self.m_tab_click_callback.func then
        self.m_tab_click_callback.func(self.m_tab_click_callback.obj, index);
    end
end

hall_2_interface_base.hide = function (self)
    self:play_anim_exit();
end
hall_2_interface_base.hideWnd = function (self)
    self:play_anim_exit();
end

hall_2_interface_base.show = function (self)
    self:play_anim_enter();
end

hall_2_interface_base.showWnd = function (self)
    self:play_anim_enter();
end

--set 定制派生 界面 的退场回调
hall_2_interface_base.set_callback_exit = function (self, _obj, _func)

    if _obj and _func then
        self.m_callback_exit = {obj = _obj, func = _func};
    end
end

--set 定制派生 界面 的进场回调
hall_2_interface_base.set_callback_enter = function (self, _obj, _func)
    
    if _obj and _func then
        self.m_callback_enter = {obj = _obj, func = _func};
    end
end

hall_2_interface_base.on_enter = function (self)

end

hall_2_interface_base.on_exit = function (self)
end

hall_2_interface_base.on_before_exit = function (self)
    return true;
end


--进场动画
hall_2_interface_base.play_anim_enter = function (self) 
    
    --标记当前页面
    if self.m_tag then
        global_set_current_view_tag(self.m_tag);
    end

    hall_2_interface_mgr.get_instance():add_interface(self);
    
                                              
    self:playEnterAnim(function (self)
        --添加返回按钮事件
        back_event_manager.get_instance():add_event(self, function(self)
            self:play_anim_exit();
        end)

        self:on_enter();

        --定制派生 界面 的进场回调
        if self.m_callback_enter and self.m_callback_enter.func and self.m_callback_enter.obj then
            self.m_callback_enter.func(self.m_callback_enter.obj);
        end
    end);
end

--退场动画
hall_2_interface_base.play_anim_exit = function (self, obj, func, b_go_hall)
    --退出前是否需要有条件退出
    if not self:on_before_exit() then
        return;
    end
    --移除返回按键事件
    back_event_manager.get_instance():remove_event(self);
    hall_2_interface_mgr.get_instance():remove_interface(self);

    --默认离开后进入大厅
    b_go_hall = (b_go_hall == nil) or b_go_hall;

    self:playExitAnim(function (self)
        
        if b_go_hall and HallScene_instance then
            --播放大厅进入动画
            HallScene_instance:preEnterHallState()
            HallScene_instance:playEnterHallAnim()
        end

        self:on_exit();

        --定制派生 界面 的 退场回调
        if self.m_callback_exit and self.m_callback_exit.func and self.m_callback_exit.obj then
            self.m_callback_exit.func(self.m_callback_exit.obj);
        end

        if obj and func then
            func(obj);
        end

        --clean --因为这个类不能加入到root里，所以remove时不需要调用
        if self.m_parent then
		    self.m_parent:removeChild(self , true);
        end
    end);
end


hall_2_interface_mgr = class();

hall_2_interface_mgr.get_instance = function ()
    if not hall_2_interface_mgr.m_instance then
        DebugLog("[hall_2_interface_mgr]: create m_instance");
        hall_2_interface_mgr.m_instance = new(hall_2_interface_mgr);
    end
    return hall_2_interface_mgr.m_instance;
end

hall_2_interface_mgr.ctor = function (self)
    DebugLog("[hall_2_interface_mgr]: ctor");
    self.m_list = {};
end

hall_2_interface_mgr.dtor = function (self)
    DebugLog("[hall_2_interface_mgr]: dtor");
end

hall_2_interface_mgr.add_interface = function (self, interface)
    if typeof(interface, hall_2_interface_base) then
        table.insert(self.m_list, interface);
    end
end

hall_2_interface_mgr.remove_interface = function (self, interface)
    if #self.m_list < 1 then
        return;
    end
    local index = 1;
    while #self.m_list > 0 and index <= #self.m_list do
        if self.m_list[index] == interface  then
            table.remove(self.m_list, index);
        else
            index = index + 1;
        end            
    end
end

hall_2_interface_mgr.close_all_interface = function (self)
    local index = 1;
    while #self.m_list > 0 and index <= #self.m_list do
        local interface = self.m_list[index];
        if interface then
            if interface.m_parent then
		        interface.m_parent:removeChild(interface , true);
            else
                interface:removeFromSuper();
            end
        end
        table.remove(self.m_list, index);           
    end
end
