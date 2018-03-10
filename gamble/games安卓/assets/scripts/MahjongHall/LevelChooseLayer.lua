require("gameBase/gameLayer");
require("MahjongData/GlobalDataManager")
require("MahjongHall/HallConfigDataManager");
require("MahjongHall/Box/NewRoomItem")
require("MahjongHall/Box/XlchRoomItem")
require("MahjongHall/MatchRoomItem")
local quickStartGamePin_map = require("qnPlist/quickStartGamePin")

LevelChooseLayer = class(GameLayer)

--roomType = 1 ----游戏场 
--roomType = 2 ----比赛场
--roomType = 3 ----血流成河
LevelChooseLayer.ctor = function(self, viewConfig ,delegate,roomType)
    DebugLog("LevelChooseLayer ctor");
    self.roomType = roomType or 1
    self.delegate = delegate
--    g_GameMonitor:addTblToUnderMemLeakMonitor("LevelChooseLayer",self)
    self:init()
    self:onEnter()
end

LevelChooseLayer.dtor = function(self)
    DebugLog("LevelChooseLayer dtor");
    self:onExit()
    back_event_manager.get_instance():remove_event(self);
    self.delegate = nil
end

--LevelChooseLayer.getSize = function ( self )
--  return self.m_root:getSize()
--end



LevelChooseLayer.init = function (self)
    -- body
    self.m_b_invalid_back_event = false 
    
    self.m_ListView        = self:getControl( LevelChooseLayer.s_controls.listView )
    self.m_tabImg          = self:getControl( LevelChooseLayer.s_controls.tabImg )
    self.m_quickStartBtn   = self:getControl( LevelChooseLayer.s_controls.quickStartBtn )

    self.m_returnBtn       = self:getControl( LevelChooseLayer.s_controls.returnBtn)
    self.m_bgImg           = self:getControl( LevelChooseLayer.s_controls.BgImg )
    self.m_ListView:setDirection(kHorizontal)


    self.m_bgImg:setSize(System.getScreenScaleWidth() - 80,System.getScreenScaleHeight() - 170)

    self.m_returnBtn:setAudioEffectName("RETURN_CLICK")
    local dirs = {}
    for i=1,11 do 
        table.insert(dirs, quickStartGamePin_map[string.format("quickstart%d.png", i)])
    end 
    self.m_quickBtnEffect = UICreator.createImages(dirs)
    self.m_quickStartBtn:addChild(self.m_quickBtnEffect)
    self.m_quickBtnEffect:setPos(-2,-8)

    self.animIndex = 0

end

LevelChooseLayer.preEnterAnim = function ( self )
    self.m_bgImg:setPos(34 , 120-System.getScreenScaleHeight())
    self.m_returnBtn:setPos(10 , 20-200)
    

end

LevelChooseLayer.stableView = function ( self )
    self.m_bgImg:setPos(34,120)
    self.m_returnBtn:setPos(10,20)
end
LevelChooseLayer.onEnter = function(self)
    DebugLog("LevelChooseLayer onEnter");   

end

LevelChooseLayer.onExit = function (self)
    DebugLog("LevelChooseLayer onExit");

end

LevelChooseLayer.setRoomType = function(self, rt)
    self.roomType = rt or 1
    if self.roomType == 1 then 
        self.m_tabImg:setFile("Hall/chooseLevel/game_tag.png")
        self:setData(HallConfigDataManager.getInstance():returnHallDataForTypelist())
        if PlatformConfig.platformWDJ == GameConstant.platformType or 
           PlatformConfig.platformWDJNet == GameConstant.platformType then 
         self.m_tabImg:setFile("Login/wdj/Hall/chooseLevel/game_tag.png");
        end
    elseif self.roomType == 2 then 
        self.m_tabImg:setFile("Hall/chooseLevel/match_tag.png")
        self:setData(HallConfigDataManager.getInstance():returnMatchData())
    else --3
        self.m_tabImg:setFile("Hall/chooseLevel/xlch_tag.png")
        self:setData(HallConfigDataManager.getInstance():returnHallDataForXL())
    end   
end
--1100*360
function LevelChooseLayer:getPosAndOffByLen( len )
    if len == 1 then 
        return 417,0-----1100/2 - 266/2
    elseif len == 2 then 
        return 190,455
    elseif len == 3 then 
        return 76,342
    else
        return 0,280 
    end 
end

LevelChooseLayer.resetListView = function (self, num)
    local itemWidth,itemHeight = 266,360
    local listNum = tonumber(num);
    local list_w, list_h = self.m_ListView:getSize()
    if  listNum or listNum < 5 then
        
    else

        list_w = itemWidth*listNum;
    end
    self.m_ListView:setSize(list_w, list_h);
    
end

LevelChooseLayer.setXLData = function ( self, data,y )
    self.m_ListView:removeAllChildren()
    if not data then 
        return 
    end 
    
  
    self.xlchRoomItemList = {}
    local itemWidth,itemHeight = 266,360
    --local itemCount = 1
    local sx,wi = self:getPosAndOffByLen(#data)
    --微调坐标
    wi = wi - 2;
    local count = 0
    for i=#data,1,-1 do--xlch
        local item = new(XlchRoomItem,data[i])
        local onlineCnt = HallConfigDataManager.getInstance().m_onlineCnt["xl"][item.level] or 0;
        item:setOnlineNum(onlineCnt);
        item:setCallback(self,function ( self )
            GameConstant.isDirtPlayGame = false
            self.delegate:onGoToRoom(item.level)
            --GlobalDataManager.getInstance():setChooseLayerData(item.level , "xl");
        end)
        self.xlchRoomItemList[#self.xlchRoomItemList+1] = item
        item:setPos( sx + count*wi,y)
        item:setSize(itemWidth,itemHeight)
        self.m_ListView:addChild(item)
        count = count + 1
        --itemCount = itemCount + 1
    end 

    self.delegate:sendGetRoomLevelAndNum(HallConfigDataManager.getInstance():returnHallDataForXL());--获取场次和人数          
    --self.m_ListView:setSize(self.m_ListView:getSize());  --修复引擎bug    
--    if data then
--        self:resetListView(#data);
--    end
end

LevelChooseLayer.setXZData = function ( self, data,y )
    self.gameRoomItemList = {}

    local len = 0
    for i=1,#data do
        if data[i].type ~= 4 then --非血流 
            len = len + 1
        end 
    end
    local sx,wi = self:getPosAndOffByLen(len)
    --微调坐标
    wi = wi - 2;
    local itemWidth,itemHeight = 266,355
    local itemCount = 1
    for i=1,#data do
        if data[i].type ~= 4 then --非血流
            local item = nil
            item = new(NewRoomItem,data[i])
            local onlineCnt = HallConfigDataManager.getInstance().m_onlineCnt["xz"][item.type] or 0;
            item:setOnlineNum(onlineCnt);
            item:setCallback(self, function ( self )
                GameConstant.isDirtPlayGame = false;
                self.delegate:requireEnterNewGameRoom(item.type);
                --GlobalDataManager.getInstance():setChooseLayerData(item.type , "xz");
            end)
            self.gameRoomItemList[#self.gameRoomItemList+1] = item
            item:setPos(sx + (itemCount-1)*wi,y)--
            item:setSize(itemWidth, itemHeight);
            self.m_ListView:addChild(item)
            itemCount = itemCount + 1 
        end 
          
    end
    self.delegate:sendGetRoomLevelAndNum(HallConfigDataManager.getInstance():returnHallDataForXZ());--获取场次和人数          
end

LevelChooseLayer.setMatchData = function ( self, data,y )
    local itemWidth,itemHeight = 266,355
    local itemCount = 1
    local item = nil 
    
    local len = 0
    for i=1,#data do
        if data[i].free == 1 and PlayerManager.getInstance():myself().money >= GameConstant.displayScoreMatchLimit then 
        else 
            len = len + 1
        end 
    end
    local sx,wi = self:getPosAndOffByLen(len)
    
    table.sort(data,function(a,b) return a.index < b.index end );
    for i=1,#data do
--        if data[i].free == 1 and PlayerManager.getInstance():myself().money >= GameConstant.displayScoreMatchLimit then 
--            item = nil
--        else 
            item = new(MatchRoomItem,data[i],i)
            local obj = {o = self, btn = item}
            item:setCallback(obj, function ( obj )
                GameConstant.isDirtPlayGame = false;
                GameConstant.payTime = obj.btn:getPayTime(); 
                obj.o.delegate:onGoToMatchRoom(obj.btn.level, obj.btn.matchType);
            end);
        --end 
        item:setPos(sx -2 + (itemCount-1)*wi,y)--
        item:setSize(itemWidth, itemHeight);
        self.m_ListView:addChild(item)
        itemCount = itemCount + 1                      
    end
end

LevelChooseLayer.setData = function ( self,data )
    self.m_ListView:removeAllChildren()
    self.m_ListView:gotoTop();
    --listview 滑动宽度变化时，remove所有的控件，宽度未随着变化，所以这里手动重置
    self.m_ListView.m_nodeW = 0;
    self.m_ListView.m_nodeH = 0;


    self.gameRoomItemList = {}
    self.xlchRoomItemList = {}
    
    local w,h = self.m_ListView:getSize()
    local y   = (h - 360)/2
    if not data then 
        return 
    end 
    
    if self.roomType == 3 then
        self:setXLData(data,y)
        --return
    elseif self.roomType == 1 then 
        self:setXZData(data,y)
        --return 
    elseif self.roomType == 2 then 
        self:setMatchData(data,y)
    end 
    
    --self.m_ListView:setSize(self.m_ListView:getSize());  --修复引擎bug
end

LevelChooseLayer.getNewGameRoomItemByType = function(self, curType)
    if self.gameRoomItemList then 
        for i=1,#self.gameRoomItemList do 
            local lt = self.gameRoomItemList[i]:getType();
            if lt and tonumber(lt) == tonumber(curType) then
                return self.gameRoomItemList[i];
            end
        end
    end 
    return nil;
end 

LevelChooseLayer.getRoomItemByLevel = function ( self, level )
    if self.xlchRoomItemList then 
        for i=1,#self.xlchRoomItemList do
            local lt = self.xlchRoomItemList[i]:getLevel()
            if lt and tonumber(lt) == tonumber(level) then 
                return self.xlchRoomItemList[i];
            end 
        end
    end 
    return nil
end
-----------------------------------------------------------------------------------------------------------------------------------
--params = Player

-----------------------------------------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------------------------------------------
--net request

--net event

LevelChooseLayer.gotoGameRoom = function ( self , allKeys )
    local allKeys = allKeys or  {"xz"}
    --allKeys[1] = "xl"
    --allKeys[2] = "xz"
    local player = PlayerManager.getInstance():myself();

    local needRequire = 0; -- 需要展示RequireMoney
    local needShowLevel = nil;

    local iMoney = tonumber(player.money)
    for k,v in pairs(allKeys) do
        if v then 
            DebugLog("find hallData by " .. v)
            local suc,hallData = HallConfigDataManager.getInstance():returnDataByKey(v,iMoney)
            if suc and hallData then 
                if needRequire then 
                    --发现更接近的
                    if iMoney - tonumber(hallData.require)  <  iMoney - tonumber(needRequire) then 
                        needRequire = hallData.require
                        needShowLevel = hallData.level
                    end
                else
                    needRequire = hallData.require
                    needShowLevel = hallData.level
                end
            end
        end
    end

    -- 房间没找到
    if not needShowLevel then 
        
        local hasXZ = false
        for k,v in pairs(allKeys) do
            if v and v == "xz" then
                hasXZ = true
                break 
            end 
        end

        local roomsData = nil
        if hasXZ then 
            roomsData = HallConfigDataManager.getInstance():returnHallDataForXZ()
        else 
            roomsData = HallConfigDataManager.getInstance():returnHallDataForXL()
        end 
        
        local room = roomsData[#roomsData]
        if room then 
            local params = {isShow = true, roomlevel = room.level, money= room.require,
                            is_check_bankruptcy = true, 
                            is_check_giftpack = true,};
            self.delegate:showQuickChargeView( params );
        end
    else
        GameConstant.isDirtPlayGame = true;
        DebugLog("LevelChooseLayer.requestQuickStartGame ##################");
        self.delegate:onGoToRoom(needShowLevel)
        return true;
    end   
end

LevelChooseLayer.gotoMatchRoom = function ( self )
    DebugLog("LevelChooseLayer.gotoMatchRoom!!")
    local matchList = HallConfigDataManager.getInstance():getDescendMatchListByRequire();
    local player = PlayerManager.getInstance():myself();
    if not matchList then
        return;
    end

    for i=1, #matchList do
        if player.money >= matchList[i].require then
            local level = matchList[i].level;
            local matchType =  matchList[i].type;
            self.delegate:onGoToMatchRoom(level, matchType);
            return;
        end
    end

    self.delegate:jugeEnterMatchRoom(matchList[1].level)
end
-----------------------------------------------------------------------------------------------------------------------------------

LevelChooseLayer.onClickedRoomItemBtn = function ( self )
    DebugLog("LevelChooseLayer.onClickedRoomItemBtn ")
end


LevelChooseLayer.onClickedQuickStartBtn = function ( self )
    DebugLog("LevelChooseLayer.onClickedQuickStartBtn")
    if self.roomType == 1 then 
        self:gotoGameRoom({"xz"})
    elseif self.roomType == 2 then 
        self:gotoMatchRoom()
    else 
        self:gotoGameRoom({"xl"})
    end   
end

LevelChooseLayer.onClickedReturnBtn = function ( self )
    DebugLog("LevelChooseLayer.onClickedReturnBtn ")
    
    self:playExitAnim(self,function (self )
        Clock.instance():schedule_once(function()
		    self.delegate:preEnterHallState()
            self.delegate:playEnterHallAnim()          
        end)
        
    end)
    return true
end

LevelChooseLayer.playExitAnim = function ( self,obj,func )
    back_event_manager.get_instance():remove_event(self);
    if self.delegate.myBroadcast then 
        self.delegate.myBroadcast:setVisible(false)
    end 
    self.delegate:playExitLevelChooseAnim(self,function ( self )
        self:setData(nil)
        self:setVisible(false)
        if func then 
            func(obj)
        end
    end)
end
-------------------------------------------------------------------------------------------------------------------------------------

-- 定义可操作控件的标识
LevelChooseLayer.s_controls =
{
    tabImg             = 1,
    listView           = 2,
    quickStartBtn      = 3,
    returnBtn          = 4,

    BgImg              = 5,

}

-- 可操作控件在布局文件中的位置
LevelChooseLayer.s_controlConfig =
{
    [LevelChooseLayer.s_controls.tabImg]               = { "bg", "Image1" },
    [LevelChooseLayer.s_controls.listView]             = { "bg", "ListView1" },
    [LevelChooseLayer.s_controls.quickStartBtn]        = { "bg", "Button1" },
    [LevelChooseLayer.s_controls.returnBtn]            = { "return_btn" },
    [LevelChooseLayer.s_controls.BgImg]                = { "bg" },
}

-- 可操作控件的响应函数
LevelChooseLayer.s_controlFuncMap =
{
    [LevelChooseLayer.s_controls.quickStartBtn]     = LevelChooseLayer.onClickedQuickStartBtn,
    [LevelChooseLayer.s_controls.returnBtn]         = LevelChooseLayer.onClickedReturnBtn,
}
-- 可接受的更新界面命令
LevelChooseLayer.s_cmds =
{
    --updataUserInfo = 1,

};

-- 命令响应函数
LevelChooseLayer.s_cmdConfig =
{
    --[LevelChooseLayer.s_cmds.updataUserInfo] = LevelChooseLayer.updataUserInfo,

};

LevelChooseLayer.httpRequestsCallBackFuncMap =
{


};



