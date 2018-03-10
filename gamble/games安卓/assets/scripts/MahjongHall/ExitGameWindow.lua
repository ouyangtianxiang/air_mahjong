local exitLayout = require(ViewLuaPath.."exitLayout");

ExitGameWindow = class(SCWindow);

ExitGameWindow.m_data = {};

ExitGameWindow.ctor = function ( self, minute)
    DebugLog("[ExitGameWindow :ctor]");
    minute = minute or 0;
    self:init(minute);
    self:showWnd();
end

ExitGameWindow.dtor = function (self)
    DebugLog("[ExitGameWindow :dtor]");
    EventDispatcher.getInstance():unregister(SocketManager.s_phpMsg, self, self.onPhpMsgResponse);
end

--init
ExitGameWindow.init = function(self, second )
    --local totalSecond = 60*10;
    if second ~= -5 then 
        second = second<0 and 0 or second;
    end

    self.m_layout = SceneLoader.load(exitLayout);
    self:addChild(self.m_layout);
    self:setCoverEnable(true)
    self.m_bg = publ_getItemFromTree(self.m_layout, {"bg"});
    self:setWindowNode( self.m_bg );

    --text
    local middle = publ_getItemFromTree(self.m_bg, {"middle"});
    local text_1 = publ_getItemFromTree(middle, {"t"});
    local text_2 = publ_getItemFromTree(middle, {"t1"});
    local text_3 = publ_getItemFromTree(middle, {"t2"});
    local text_4 = publ_getItemFromTree(middle, {"t3"});
    local text_minute =  publ_getItemFromTree(middle, {"minute"});
    local text_view = publ_getItemFromTree(middle, {"text_view"});
    local gold_box = publ_getItemFromTree(middle, {"gold_box"});
    --btn
    local btn_close = publ_getItemFromTree(self.m_bg, {"btn_close"});
    local btn_exit = publ_getItemFromTree(self.m_bg, {"btn_exit"});
    local btn_start_game = publ_getItemFromTree(self.m_bg, {"btn_start_game"});

    --关闭界面
    btn_close:setOnClick(self, function (self)
        self:hideWnd();
    end);

    --退出游戏
    btn_exit:setOnClick(self, self.exitGameCallback);
    --开始游戏
    btn_start_game:setOnClick(self, self.startGameCallback);

    --init data
    self.m_data = {};

    if second ~= -5 then
    --在线时长为0或者负数时则显示可以领取在线宝箱，大于0则显示剩余分钟
        self.m_data.isOnlineTotalTimeLess10Min = second <= 10*60;
        self.m_data.minute = math.ceil(second/60);---minut
    end
    -- DebugLog("sssssssssssss:"..totalSecond);
    local data = GlobalDataManager.getInstance():getLastGameData();
    if not data or not data.chestNeedJu then
        self.m_data.playNums = 5;
    else
        self.m_data.playNums = data.chestNeedJu;
    end
    local funVisible = function (bVisible)
        text_1:setVisible(bVisible);
        text_2:setVisible(bVisible);
        text_3:setVisible(bVisible);
        text_4:setVisible(bVisible);
        text_minute:setVisible(bVisible);
        gold_box:setVisible(bVisible);
        text_view:setVisible(not bVisible);
    end

    if second == 0 then
        local str = "亲,时间到了..";
        text_1:setText(str);
        text_3:setText("现在领取在线宝箱");
        text_1:setVisible(true);
        text_2:setVisible(false);
        text_3:setVisible(true);
        text_4:setVisible(true);
        text_minute:setVisible(false);
        gold_box:setVisible(true);
        text_view:setVisible(false);
        publ_getItemFromTree(btn_start_game, {"text"}):setText("开始游戏");
    elseif self.m_data.isOnlineTotalTimeLess10Min == true then
        funVisible(true);
        text_minute:setText(tonumber(self.m_data.minute));
        publ_getItemFromTree(btn_start_game, {"text"}):setText("开始游戏");
        
    else
        funVisible(false);
        publ_getItemFromTree(btn_start_game, {"text"}):setText("牌局抽奖");
        local str = "";
        if self.m_data.playNums <= 0 then
             str = "亲，您已经可以开启牌局宝箱了！话费，金币，道具奖励任你抽，你确定要放弃这次机会并退出游戏吗？";
        else 
            str= "亲，您再玩"..tonumber(self.m_data.playNums)..
                "局就可以开启牌局宝箱了！话费，金币，道具奖励任你抽，你确定要放弃这次机会并退出游戏吗？";
        end
      
        text_view:setText(str);
    end

    self.m_phpEvent = EventDispatcher.getInstance():getUserEvent();
    EventDispatcher.getInstance():register(SocketManager.s_phpMsg, self, self.onPhpMsgResponse);
    
    self:requireChestStatus();
end



ExitGameWindow.updateChestView = function (self, needChest)

    if not self.m_bg then
        return;
    end
    local middle = publ_getItemFromTree(self.m_bg, {"middle"});
    local text_view = publ_getItemFromTree(middle, {"text_view"});
    
    if not text_view then
        return ;
    end

    self.m_data.playNums = needChest or 5;

    local str = "";
    if self.m_data.playNums <= 0 then
            str = "亲，您已经可以开启牌局宝箱了！话费，金币，道具奖励任你抽，你确定要放弃这次机会并退出游戏吗？";
    else 
        str= "亲，您再玩"..tonumber(self.m_data.playNums)..
            "局就可以开启牌局宝箱了！话费，金币，道具奖励任你抽，你确定要放弃这次机会并退出游戏吗？";
    end
      
    text_view:setText(str);
end


--按钮事件:退出游戏
ExitGameWindow.exitGameCallback = function (self)
    native_muti_exit();
    self:hide();
end

--按钮事件:开始游戏
ExitGameWindow.startGameCallback = function (self)
    if not HallScene_instance then
        return;
    end
    local me = PlayerManager.getInstance():myself();
    --破产
	if me.money < GameConstant.bankruptMoney then
		GlobalDataManager.getInstance():showBankruptDlg(nil , self);
		return;
	end
    --在线时长小于10分钟快速进入游戏
    local data = GlobalDataManager.getInstance():getLastGameData();
    if self.m_data.isOnlineTotalTimeLess10Min == true or not data then
        HallScene_instance:requestQuickStartGame();
        return;
    end

    local chestNeedJu = data.chestNeedJu or 5;
    if  chestNeedJu > 0 
        or data.level == nil then
        HallScene_instance:requestQuickStartGame();
        return ;
    end   

    local hallData = HallConfigDataManager.getInstance():returnDataByLevel(data.level);
    if me.money >= tonumber(hallData.require)  then 
        HallScene_instance:onGoToRoom(data.level)
    else 
        HallScene_instance:requestQuickStartGame();	
    end
    


end


ExitGameWindow.requireChestStatus = function (self)
    local params = {};
    params.level = GameConstant.curRoomLevel;
    --local event = EventDispatcher.getInstance():getUserEvent();
    SocketManager.getInstance():sendPack(PHP_CMD_REQUIRE_CHEST_STATUS,params);
    -- HttpModule.getInstance():execute(HttpModule.s_cmds.requireChestStatus, params, self.m_phpEvent);
end

ExitGameWindow.requireChestStatusCallBack = function ( self, isSuccess,data )
    if not isSuccess or not data then
        return;
    end

    if status and tonumber(data.status) == 1 then
--      local t = {};
--      t.open    = tonumber(data.data.open:get_value());
--      t.need    = tonumber(data.data.need:get_value());
--      t.process = tonumber(data.data.process:get_value());
--      t.award   = tonumber(data.data.award:get_value());
--      t.boxType = tonumber( data.data.boxtype:get_value() or 0 ) or 0;
--      RoomData.getInstance().boxType = t.boxType;
        local chestProcessJu = tonumber(data.data.process);
        local chestNeedJu = tonumber(data.data.need);
--        GlobalDataManager.getInstance():setLastChestNeedJu(self.chestNeedJu - self.chestProcessJu);
--      self:updateChestImg(1)
--      if 0 == tonumber(data.data.open:get_value()) then
--          self.chestProcessJu = -1;
--      elseif t and 1 == tonumber(data.data.open:get_value()) then
--          self:showChestStartup(t);
--      end
        local needChest = chestNeedJu - chestProcessJu;
        self:updateChestView(needChest);
    end
end

ExitGameWindow.onPhpMsgResponse = function ( self, param, cmd, isSuccess )
    if self.httpSocketRequestsCallBackFuncMap[cmd] then 
        self.httpSocketRequestsCallBackFuncMap[cmd](self,isSuccess,param)
    end
end

ExitGameWindow.httpSocketRequestsCallBackFuncMap = 
{
    [PHP_CMD_REQUIRE_CHEST_STATUS] =  ExitGameWindow.requireChestStatusCallBack,
};
