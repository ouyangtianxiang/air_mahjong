

local ProfileNode = class(Node);

function ProfileNode:ctor( )
    DebugLog('ProfileNode:ctor',LTMap.Profile)
	--local tip = 'fps:'..Clock.fps..','
    self.m_text = new(Text, "", 0, 0, kAlignLeft, "", 24, 0xff , 0xeb , 0x7e)--255,250,110); -- 黄 系统
    self.m_text:setPos(0, 0);
    self:addChild(self.m_text)

    --
    local tmp_m = 1024*1024;
    local tmp_count = 0;
    local tmp = {};
    local fps = 0
    self.m_clockHandle = Clock.instance():schedule(function ( dt )
        tmp_count = tmp_count + 1;

        --android要自己算
--        if isPlatform_Win32() then
--            fps = Clock.instance().fps;     
--        else
            if tmp_count > 10 then
                tmp_count = 0;
               
                local len = #tmp;
                local total = 0;
                for i = 1, len do
                    total = total + tmp[i];    
                end
                fps = total/len;
                tmp = {};
            else
                table.insert(tmp, 1/dt);
            end 
        --end
         
    	self.m_text:setText(
            'fps:'..string.format("%.1f", fps)..
            ',tm:'..string.format("%.2fMb", MemoryMonitor.instance().texture_size/tmp_m)..
            ',lm:'..string.format("%.2fMb", collectgarbage("count")/1024)..
            ',am:'..string.format("%.2fMb", Application.instance():getTotalMemory()/tmp_m))
    end)

end 
function ProfileNode:dtor()
    DebugLog('ProfileNode:dtor',LTMap.Profile)
	self.m_clockHandle:cancel()
	self.m_clockHandle = nil

	--self.m_text:removeFromeSuper(true)
	--self.m_text = nil 

end

return ProfileNode