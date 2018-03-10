---
--lua内存泄漏检测工具
--@module GameMonitor
--@author myc


--监控间隔配置（单位：秒） 
local print = DebugLog; 
local MonitorConfig =   
{  
    --内存泄露监控间隔  
    memLeaksInterval    = 1,  
}  
  
local GameMonitor = class();  
 
function GameMonitor:ctor()  
   --内存泄露弱引用表  
    self.__memLeakTbl   = {}
    self.__memLeakID    = {} 
    self.__id = 1;
    setmetatable(self.__memLeakTbl, {__mode='kv'})
    setmetatable(self.__memLeakID, {__mode='kv'})   
    --内存泄露监控器  
    self.__memLeakMonitor   = nil  
end  
 
---开始检测
--@usage g_GameMonitor:start();  
function GameMonitor:start()  
    self.__memLeakMonitor = self:__memLeaksMonitoring()  
end  
  
function GameMonitor:update(dt)  
    if self.__memLeakMonitor then
        self.__memLeakMonitor(dt)  
    end
end  
  
  
---------------------------------------------  
--公有方法  
--功能：       增加一个受监视的表  
--参数tblName:    该表的名字（字符串类型），名字的用途是方便人来记忆，字符串值总比OX002D0EFF之类的好记  
--参数tbl:        该表的引用  
--返回：       无  
--增加一个受监视的表 
--@usage g_GameMonitor:addTblToUnderMemLeakMonitor("test",textaaa);
function GameMonitor:addTblToUnderMemLeakMonitor(tblName, tbl)  
    if not self.__memLeakMonitor then
        return;
    end
    assert('string' == type(tblName), "Invalid parameters")  
    --必须以名字+地址的方式作为键值  
    --内存泄露经常是一句代码多次分配出内存而忘了回收，因此tblName经常是相同的
    self.__id = self.__id + 1; 
    local name = string.format("%s@%s id %s", tblName, tostring(tbl),tostring(self.__id))  
    if nil == self.__memLeakTbl[name] then  
        self.__memLeakTbl[name] = tbl
        self.__memLeakID[tostring(self.__id)] = tbl;
    end  
end


  
--内存泄露监控逻辑  
function GameMonitor:__memLeaksMonitoring()  
    local monitorTime   = MonitorConfig.memLeaksInterval  
    local interval      = MonitorConfig.memLeaksInterval  
    local str           = nil  
  
    return function(dt)  
        interval = interval + dt  
        if interval >= monitorTime then  
            interval = interval - monitorTime  
            --强制性调用gc  
            collectgarbage("collect")  
            collectgarbage("collect")
            local flag = false;  
            --打印当前内存泄露监控表中依然存在（没有被释放）的对象信息  
            str = "memory leak monitoring,rightnow these tables is still valid:"  
            for k, v in pairs(self.__memLeakTbl) do  
                str = str..string.format("  \n%s = %s", tostring(k), tostring(v))  
            	flag = true;
            end  
            str = str.."\nDoes it meet your expectation?"  
            if flag then
            	print(str);
            end
       end  
    end  
end

function GameMonitor:getObjById(id)  
    if not self.__memLeakMonitor then
        return;
    end
    id = tostring(id);
    return self.__memLeakID[id];
end  
 
function GameMonitor:findObject(obj, findDest,aaa)  
    if findDest == nil then  
        return false  
    end 

    if self.findedObjMap[findDest] ~= nil then  
        return false  
    else
        -- print(type(findDest))
        -- if type(findDest) == "userdata" then
        --     print("113 " .. tostring(findDest))
        -- else
        --     if aaa then
        --         print("aaa " .. aaa)
        --     end
        --     print("112 " .. tostring(findDest))
        -- end
        -- print(type(findDest))
        local ret = xpcall(function( ... )
            self.findedObjMap[findDest] = true  
        end, err)
        if not ret  then
            return false;
        end
    end
    
    
  
    local destType = type(findDest)
    if destType == "table" then  
        -- if findDest == _G.CMemoryDebug then  
        --     return false  
        -- end  
        for key, value in pairs(findDest) do
            -- print(" kye " .. key)
            if key == obj or value == obj then 
                print("Finded Object")  
                return true, key 
            end
            -- print("key " .. key)
            local ret, k = self:findObject(obj, key);
            if ret == true then  
                print("table key")  
                return true, key
            end
            local ret, k = self:findObject(obj, value, key);
            if ret == true then
                k = k or "";  
                print(tostring(k) .. " referenced by key:["..tostring(key).."]")  
                return true, key 
            end 
        end  
    elseif destType == "function" then  
        local uvIndex = 1  
        while true do  
            local name, value = debug.getupvalue(findDest, uvIndex)  
            if name == nil then  
                break  
            end  
            if self:findObject(obj, value) == true then  
                print("upvalue name:["..tostring(name).."]")  
                return true  
            end  
            uvIndex = uvIndex + 1  
        end  
    end  
    return false  
end

function GameMonitor:showReferences()
    if  self.__memLeakTbl == nil then
        return;
    end 
    for k,v in pairs(self.__memLeakTbl) do
        if v then
            self:findObjectInGlobal(v,k)
        end
    end
end   
  
function GameMonitor:findObjectInGlobal(obj,name)
    print(string.format("0-----------------------%s-------------------------0",name or ""))
    self.findedObjMap = self:createTable()  
    self:findObject(obj, _G)
    print("1---------------------------------------------------------1")
end

function GameMonitor:createTable()
    local proxy = {}
    local object = {};
    local mt = {
            -- __index = object,
            -- __newindex = function(t,k,v)
            --     if  k ~= nil then
            --         object[k] = v;
            --     end             
                      
            -- end,
            __mode = "k"
        }
    setmetatable(proxy,mt)
    return proxy
end

-- 使用内存检测工具

-- ---加载内存检测库 下面是自己的路径
-- local GameMonitor = require(frameworkName .. ".tools.GameMonitor");

-- ---初始化
-- g_GameMonitor = new(GameMonitor);
-- g_GameMonitor:start();


-- ---添加监听 第一个参数描述信息 第二个参数想要检测的对象
-- g_GameMonitor:addTblToUnderMemLeakMonitor("个人信息场景控制器",obj)

-- ---上面这个例子是进入个人信息场景，然后再退出个人信息场景 理论上应该释放掉个人信息场景的元素
-- ---退出个人信息场景之后 再按m键 日志就会显示出释放有内存泄露（按键自定义 下面是代码）
-- function NativeEvent.onWinKeyDown(key)
--     print_string(key)
--     if key == 77 or key == 107 then
--             g_GameMonitor:update(10)
--             g_GameMonitor:showReferences()
--         return;
--     end
-- end


return GameMonitor;