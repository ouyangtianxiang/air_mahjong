--[[
	className    	     :  BarrageDataManager
	Description  	     :  弹幕数据管理-- 单例类
	create-time 	     :  3-25-2016
	create-author        :  NoahHan
--]]


--local BarrageData = {["content"] = nil, ["bMyself"]=false};


BarrageDataManager = class();

BarrageDataManager.ctor = function (self)
    self.m_data = {};   
end

BarrageDataManager.dtor = function (self)

end

--单例
BarrageDataManager.Instance = function (self)
    if self.m_instance == nil then
        self.m_instance = new(BarrageDataManager);
    end
    return self.m_instance;
end

--根据服务器返回的消息创建一个msg
BarrageDataManager.createMsg = function (self, msg)
    local m = {};
    m.bMyself = (tonumber(msg.uid) or -1) == (PlayerManager.getInstance():myself().mid or -2);
    m.content = msg.msg or "";
    m.level = tonumber(msg.level) or -1;
    m.matchType = tonumber(msg.flag) or -1;
    m.matchid = msg.matchid or -1;
    m.num = tonumber(msg.num) or 0;
    m.num = bMyself and 1 or m.num;
    return m;
end
--插入数据
BarrageDataManager.push_msg = function(self, msg)
    if msg == nil then
        return;
    end

    local m = self:createMsg(msg);
    local count = tonumber(m.num); 
    for i = 1, count do
        self.m_data[#self.m_data+1] = m;
    end   

    
end

--弹出数据
BarrageDataManager.pop_msg = function (self)
    local msg = nil;
    if self.m_data and #self.m_data >= 1 then
        msg = self.m_data[1];
        table.remove(self.m_data, 1);
    end
    return msg;
end

BarrageDataManager.isEmpty = function (self)
    return #self.m_data == 0;
end



