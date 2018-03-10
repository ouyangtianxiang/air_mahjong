--处理按返回键关闭当前窗口的逻辑
back_event_manager = class()

back_event_manager.ctor = function (self)
    self.m_list = {};
end

back_event_manager.dtor = function (self)

end

back_event_manager.get_instance = function ()
    if not back_event_manager.m_instance then
        DebugLog("[back_event_manager]: create m_instance");
        back_event_manager.m_instance = new(back_event_manager);
    end
    return back_event_manager.m_instance;
end

back_event_manager.get_display_size = function (self)
    local index = 0;
    for i = 1, #self.m_list do
        if self.m_list[i].o and self.m_list[i].o:getVisible() then
            index = index + 1;
        end
    end
    return index;
end

back_event_manager.add_event = function (self, obj, func)
    if not obj or not func then
        return;
    end

    if self:check_can_add(obj) then
        table.insert(self.m_list, {o = obj, f = func});
    end
end

back_event_manager.remove_event = function (self, obj)
    if not obj then
        return;
    end

    if #self.m_list < 1 then
        return;
    end

    local index = 1;
    while #self.m_list > 0 and index <= #self.m_list do
        if obj == self.m_list[index].o  then
            table.remove(self.m_list, index);
        else
            index = index + 1;
        end            
    end
end

back_event_manager.check_can_add = function (self, obj)
    if not obj then
        return false;
    end
    for i = 1, #self.m_list do
        if obj == self.m_list[i].o then
            return false;
        end
    end
    return true;
end

back_event_manager.excute = function (self)
    local index = #self.m_list;
    while index > 0 do

        local item = self.m_list[index]; 
        local fun_remove = function ()
            table.remove(self.m_list, index);
            item.f(item.o);
        end  
        if item and item.o and item.f then
            --如果窗口是隐藏的直接remove掉
            if item.o:getVisible() then
                --item.o 的属性m_b_invalid_back_event 
                --属性为true时，返回键无效
                if not item.o.m_b_invalid_back_event then
                    --如果需要判断播放动画的逻辑
                    if item.o.get_playing_anim then
                        if not item.o:get_playing_anim() then
                            fun_remove();
                            return;
                        end
                    else
                        fun_remove();
                        return;
                    end                
                end
            end
        else
            table.remove(self.m_list, index);
        end
        index = index - 1;    
    end     
end



