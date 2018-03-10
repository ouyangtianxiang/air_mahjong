--[[
	className    	     :  BarrageLayer
	Description  	     :  弹幕layer-
	last-modified-date   :  3-25-2016
	create-time 	     :  3-25-2016
	last-modified-author :  NoahHan
	create-author        :  NoahHan
--]]

require("ui/node")
require("Define")
require("MahjongBarrage/BarrageDataManager")
require("MahjongHall/HallConfigDataManager")

local l_const_str = {["hint_text"] = "请输入文字.."};
----弹幕移动的固定距离
--local l_msg_move_distance = 720;
--弹幕移动需要的时间
local l_msg_move_time = 5000;

local l_font_size = 30;
local l_interval_msg_move = 3000;
local l_interval_timer = 16--1000/60;
local l_msg_move_per_frame = 3--5;--值越大越快
--每个消息移动的时间间隔
local l_interval_per_msg = 200;
local l_font_config_count = 8;
local l_font_row_count = 4;
--字体配置
local l_font_config = {
        me = {size = 30, color = { r = 0xff, g = 0x00, b = 0x00}},
        default = {size = 30, color = { r = 0x00, g = 0x00, b = 0x00}},
        [1] = {size = 30, color = { r = 0x00, g = 0xf7, b= 0xd1}},
        [2] = {size = 38, color = { r = 0xd6, g = 0x60, b= 0x0d}},
        [3] = {size = 40, color = { r = 0x1c, g = 0x00, b= 0x00}},
        [4] = {size = 30, color = { r = 0xeb, g = 0x0a, b= 0x54}},
        [5] = {size = 32, color = { r = 0x69, g = 0xf0, b= 0x26}},
        [6] = {size = 38, color = { r = 0xba, g = 0x00, b= 0xff}},
        [7] = {size = 32, color = { r = 0xfe, g = 0xf1, b= 0x59}},
        [8] = {size = 38, color = { r = 0x00, g = 0x42, b= 0xff}},
};

--字体位置
local l_font_random_pos = {
    [1] = {x = System.getScreenWidth()/2, y = -140},
    [2] = {x = System.getScreenWidth()/2, y = -50},
    [3] = {x = System.getScreenWidth()/2, y = 40},
    [4] = {x = System.getScreenWidth()/2, y = 130},
};

--test
local l_test_count = 0;

--
local l_para = {noraml = 0,
                retset = -1, 
                resetCurrentIndex =  -2};


BarrageLayer = class(Node);

BarrageLayer.ctor = function (self, matchId, matchLevel)
    DebugLog("[BarrageLayer: ctor]matchId:"..(matchId or 0));

    --初始化
    self:init(matchId, matchLevel);
    --开启定时器 发送弹幕
    self:startTimer();
end

BarrageLayer.dtor = function (self)
    DebugLog("[BarrageLayer: dtor]");
    if self.m_editText then
        --event_backpressed();
--        EventDispatcher.getInstance():dispatch(Event.Back);
--        self.m_editText:removeFromSuper();
--        self.m_editText = nil;
    end
    EventDispatcher.getInstance():unregister(SocketManager.s_serverMsg, self, self.onSocketPackEvent);
    EventDispatcher.getInstance():unregister(SocketManager.s_phpMsg, self, self.onPhpMsgResponse);
end

--初始化
BarrageLayer.init = function (self, matchId, matchLevel)
    --初始化控件
    self:initWidgets();

    self.m_data = {msg = {}, bOpenView = true, bMsgMoving = {}, event = -1, preMsgDistance={}};
    self.m_data.matchId = matchId or 0;
    self.m_data.matchLevel = matchLevel or 0;
    self.m_data.matchData = HallConfigDataManager.getInstance():returnDataByLevel(self.m_data.matchLevel);
    for i = 1, l_font_row_count do
        table.insert(self.m_data.bMsgMoving,false);
    end
    self.m_editText:setText("");
    self.m_editText:setMaxLength(14);
    self.m_editText:setHintText(l_const_str.hint_text);

    --socket 注册事件
    EventDispatcher.getInstance():register(SocketManager.s_serverMsg, self, self.onSocketPackEvent);
    -- php注册回调事件
    EventDispatcher.getInstance():register(SocketManager.s_phpMsg, self, self.onPhpMsgResponse);

    self:sendPhpGetRandBarrageMsg();
end

--初始化控件
BarrageLayer.initWidgets = function(self)
    local BarrageViewXml = require(ViewLuaPath.."BarrageViewXml");
    
    --加载ui
    self.m_layout = SceneLoader.load(BarrageViewXml);
    self:addChild(self.m_layout);

    --bg
    self.m_bg = publ_getItemFromTree(self.m_layout, {"img", "bg"});
    self.m_bgImg = publ_getItemFromTree(self.m_layout, {"img"});

    --customnode
    self.m_allTextNode = new(Node);
    self.m_allTextNode:setAlign(kAlignCenter)
    self.m_allTextNode:setPos(0, 0);
    self:addChild(self.m_allTextNode); 

    -- local ttt = UICreator.createImg("Commonx/female.png")
    -- ttt:setPos(0,0)
    -- ttt:setAlign(kAlignCenter)
    -- ttt:setLevel(9999)
    -- self:addChild(ttt)

    --按钮
    local btnSend = publ_getItemFromTree(self.m_layout, {"img", "bg", "imgEditText","btnSend"});
    btnSend:setOnClick(self, self.eventSendMsg);

--    self.m_btnBarrage = publ_getItemFromTree(self.m_layout, {"btnBarrage"});
--    self.m_btnBarrage:setOnClick(self, self.event_ctrol_barrage);

    --editText BG
    local editTextBg = publ_getItemFromTree(self.m_layout, {"img", "bg", "imgEditText"});
    editTextBg:setTransparency(0.8);
    --editTextBg:setColor(0x00,0x00,0x00);

    --edittext
    self.m_editText = publ_getItemFromTree(self.m_layout, {"img", "bg", "imgEditText",  "editText"});
    self:editTextSetOnTextChange(self.m_editText);

end



--按钮事件 发送弹幕消息
BarrageLayer.eventSendMsg = function (self)
    DebugLog("[BarrageLayer: eventSendMsg]");
    

    local msg = self.m_editText:getText();

    self.m_editText:setText("");
    self.m_editText:setHintText(l_const_str.hint_text);
    if not msg then
        return;
    end
    local msg = publ_trim(msg);
    --检测msg是否有效
    if not msg  or  string.len(msg) < 1 then
        Banner.getInstance():showMsg("请输入有效文字,并且不要超过14个字。");
        return;
    end

    if self.m_data.matchId == 0 or self.m_data.matchLevel == 0 then
        Banner.getInstance():showMsg("报名比赛才能发送弹幕消息");
    else
        --send
        self:sendPhpBarrageMsg(msg);
    end 
end

--获取随机的间隔
BarrageLayer.getRandomInterval = function (self)
    local t = {2000,1000,500,3000, default = 0};
    local tmp = t[math.random(1, #t)];
    tmp = tmp or t.default;
    
    return l_interval_per_msg + tmp;
end
--msg action 从屏幕右边匀速边飘到左边，然后remove
BarrageLayer.actionMoveMsg = function (self, msg, index)
    DebugLog("[BarrageLayer:actionMoveMsg ] :"..index.." "..msg.content);

    --队列中msg moving的标识
    self:setMsgIsMoving(index, true);
    local pos_x, pos_y = l_font_random_pos[index].x , l_font_random_pos[index].y;
    --获取随机的字体配置
    local config = self:getRandomFontConfig(msg.bMyself);
    --创建text
    local text = new(Text, 
                    msg.content, 0,  0, kAlignLeft,"", 
                    config.size, config.color.r , config.color.g , config.color.b); 
    text:setPos(pos_x, pos_y);
    text:setAlign(kAlignLeft);
    self.m_allTextNode:addChild(text);

    --是自己才加框
    if msg.bMyself then
        local w,h = text:getSize();
        local graphs = require("libEffect/shaders/vectorGraph")
        local rect = new(graphs.Rectangle, w+10,h+10)--135
        rect:setPos(0,0);--(pos_x, pos_y)
        rect:setLevel(-1)--efc28d
        rect:setColor(0xff,0x00,0x00)
        rect:setFill(false);
        text:addChild(rect)
        text:setSize(w+12,h+12)
        rect:on_update()
    end

    
    --msg的宽
    local msgDistance, h = text:getSize();
    --屏幕距离
    local fixedWidth = System.getScreenWidth();
    --msg实际move的距离
    local msgMoveDistance = fixedWidth + msgDistance;
    --转化为teext相对 align的msg move的距离
    local move_x, move_y = 0 - msgMoveDistance, 0;
    --正常的速度
    local speed = fixedWidth / l_msg_move_time;
    --移动msg宽度所需要的时间
    local tMsgMove =  msgDistance/speed;
    --msg从左到右移动需要的时间
    local costTime = l_msg_move_time + tMsgMove;

    --
    local vEvent = EventDispatcher.getInstance():getUserEvent();
    local duration = tMsgMove + self:getRandomInterval();
    local anim = self:addPropTranslate(vEvent, kAnimNormal, duration, 0, 0, 0, 0, 0);
    local tmpObj = {obj = self, event = vEvent, idx = index};
    anim:setEvent(tmpObj, function (data)
        --DebugLog("[BarrageLayer actionMoveMsg] vEvent:"..data.event.." idx:"..data.idx);
        data.obj:removeProp(data.event);
        data.obj:setMsgIsMoving(data.idx, false);
    end);

    --移动text
    local moveByEvent = EventDispatcher.getInstance():getUserEvent();
    local data = {obj = text}--, t = 0, idx = index};
    text:moveBy(moveByEvent, move_x, move_y, costTime, 0, data, function (data)
        local obj = data.obj;
        --, t, idx = data.obj, data.t, data.idx;
        if obj then
            obj:removeFromSuper();
        end
    end);

    --DebugLog("moveByEvent:"..moveByEvent.." vEvent:");
end

--按钮时间 显示/隐藏 弹幕
BarrageLayer.event_ctrol_barrage = function (self)
    DebugLog("[BarrageLayer: event_ctrol_barrage]");

    self:showBarrageView(not self.m_data.bOpenView);

end

--事件 edittext 内容改变
BarrageLayer.editTextSetOnTextChange = function (self, widget)
    if not typeof(widget, EditText) then
        DebugLog("widget is not editText..");
        return
    end

    widget:setOnTextChange(self, function ( self )
	    local str = publ_trim(widget:getText());
	    local len = string.len(str);
   
        --判断传入的字符是否有效
        local bInvalid = false;--self:VerifyStrInvalid(str);

        --设置输入文本
	    if len ~= 0 and not bInvalid then 
		    widget:setText(str);
	    else
            widget:setText("");
		    widget:setHintText(l_const_str.hint_text);
	    end
	end);
end

--启动弹幕定时器
BarrageLayer.startTimer = function (self)

    self:stopTimer();
    
    self.m_data.event = EventDispatcher.getInstance():getUserEvent();
    local anim = self:addPropTranslate(self.m_data.event, kAnimRepeat, l_interval_timer, 0, 0, 0, 0, 0);
    anim:setEvent(self, self.callbackTimer);
end

--关闭弹幕定时器
BarrageLayer.stopTimer = function (self)
    if not self.m_data.event or self.m_data.event == -1 then
        return;
    end
    self:removeProp(self.m_data.event);

    for k, v in pairs (self.m_data.msg) do
        if v then
            v:removeFromSuper();
        end
    end
    self.m_data.msg = nil; 
    self.m_data.msg = {};
end



--获取随机的可以movingmsg的row index
BarrageLayer.getCanMsgMovingRowIndex = function (self)
    --return 1;
    return math.random(1, #self.m_data.bMsgMoving);
end

--判断消息是否可以在该比赛场播放
BarrageLayer.verifyMsgCanSend = function (self, msg)
    if not msg then
        return false;
    end

end

--获取弹幕的消息
BarrageLayer.getBarrageMsg = function (self)

    local msg = BarrageDataManager:Instance():pop_msg()
    if not msg then
        return nil;
    end
    local msgMatchType = msg.matchType;
    local msgMatchId = msg.matchid;

    if not (msgMatchType or msgMatchId) then
        return nil
    end

    local hallMatchData = HallConfigDataManager.getInstance():returnDataByLevel(self.m_data.matchLevel);
    if not hallMatchData then
        return nil
    end
    
    --0只针对这场比赛，1同个level比赛播放弹幕，2同种比赛，不同level播放弹幕，3无限制
    if msgMatchType == 0 then
        if self.m_data.matchId ~= msgMatchId then
            return nil
        end
    elseif msgMatchType ==  1 then
        if hallMatchData.level ~= msg.level then
            return nil;
        end
    elseif msgMatchType == 2 then
        local msgMatchData = HallConfigDataManager.getInstance():returnDataByLevel(msg.level);
        if not msgMatchData or (hallMatchData.type ~= msgMatchData.type )then
            return nil;
        end 
    end

    return msg;
end

--弹幕定时器回调
BarrageLayer.callbackTimer = function (self)
    
    --创建弹幕text
    self:createBarrageText();
    --刷新弹幕text的位置
    self:updateBarrageText();

end

--刷新弹幕text的位置
BarrageLayer.updateBarrageText = function (self)
    for k, v in pairs (self.m_data.msg) do
        local pos_x, pos_y = v:getPos();
        if v.endPos < 0 then
            v:removeFromSuper();
            table.remove(self.m_data.msg, k)
        else
            v.endPos = v.endPos - l_msg_move_per_frame;
            v:setPos(pos_x-l_msg_move_per_frame, pos_y);
        end 
    end
end

--创建barrage text
BarrageLayer.createBarrageText = function (self, msg)
    --获取msg可能出现在随机行的index
    local index = self:getCanMsgMovingRowIndex();
    if not index  then
        return;
    end
    if self:getMsgIsMoving(index) then
        local distance = self.m_data.preMsgDistance[index] or 0;
        if distance > 0 then
            self.m_data.preMsgDistance[index] = distance - l_msg_move_per_frame;
        else
            self:setMsgIsMoving(index, false)
        end
        return;
    end


    --获取msg
    local msg = self:getBarrageMsg();
    if not msg then
        return;
    end
    
    --队列中msg moving的标识
    self:setMsgIsMoving(index, true);
    local pos_x, pos_y = l_font_random_pos[index].x , l_font_random_pos[index].y;
    --获取随机的字体配置
    local config = self:getRandomFontConfig(msg.bMyself);
    --下一个text出现的距离
    local t = {200, 50,100,150, default = 50};
    --起始的随机距离
    local distance_random_begin = t[math.random(1, #t)];



    --创建text
    local text = new(Text, 
                    msg.content, 0,  0, kAlignLeft,"", 
                    config.size, config.color.r , config.color.g , config.color.b); 
    --text:setPos(0,0);
    text:setAlign(kAlignCenter);
    --self.m_allTextNode:addChild(text);

    --创建Node
    local w,h  = text:getSize()
    local node = new(Node)
    node:setSize(w+12,h+12)
    node:setPos(pos_x+distance_random_begin, pos_y)
    node:setAlign(kAlignLeft)
    self.m_allTextNode:addChild(node)
    node:addChild(text)

--    --是自己才加框
--    if msg.bMyself then
--        --local w,h = text:getSize();
--        local graphs = require("libEffect/shaders/vectorGraph");
--        local rect = new(graphs.Rectangle, w+20,h+10);--135
--        rect:setPos(0,0);--(pos_x, pos_y)
--        rect:setLevel(-1)--efc28d
--        rect:setColor(0xff,0x00,0x00);
--        rect:setAlign(kAlignCenter);
--        rect:setFill(false);
--        node:addChild(rect);
--        --text:setSize(w+12,h+12)
--        rect:on_update()
--    end

    --msg的宽
    local msgDistance, h = node:getSize();
    --屏幕距离
    local fixedWidth = System.getScreenWidth();

    --local tTmp = { 50}--200, 50,100,150, default = 50};
    node.endPos = (fixedWidth + distance_random_begin + msgDistance);
    self.m_data.preMsgDistance[index] = distance_random_begin+ t[math.random(1, #t)]+msgDistance;
    table.insert(self.m_data.msg, node);

    DebugLog("barrage text index:"..index.." preMsgDistance:"..self.m_data.preMsgDistance[index]);
end


--消息moving标识 get/set
BarrageLayer.getMsgIsMoving = function (self, index)
    return self.m_data.bMsgMoving[index];
end
BarrageLayer.setMsgIsMoving = function (self, index, bMsgMoving)
    self.m_data.bMsgMoving[index] = bMsgMoving;
end

--测试数据
BarrageLayer.initTestData = function (self)

--    local str = {"sdfs搜索发送","hello,world","睡懒觉了的书法家。lkl;开始大幅亏损的适当放宽了上岛咖啡","sdf",
--    "haode 所带来的世界疯了","四川麻将江苏两地警方来的世界疯了的事 ","joi交流交流极度疯狂","joi交流交流极度疯狂",
--    "斯蒂芬第三方i寂寞","空空山东警方is闹洞房了穆斯林就"
--    };--num:10
--   -- for i = 1, 10 do
--        local msg = {};
--        msg.uid = 1;
--        msg.msg = "sdf"--str[i] or " ";
--        msg.level = 1;
--        msg.flag = 1;
--        msg.matchid = 1;
--        msg.num = 1;--5;

--        BarrageDataManager:Instance():push_msg(msg);
--    --end

end

----设置字体
--BarrageLayer.setTextByConfig = function (self, text, config)
--    if not typeof(text, Text) or type(color) ~= "table" then
--        return;
--    end
--    local c = config.color;
--    text:setColor(c.r, c.g, c.b);
--end

--获得随机的字体config
BarrageLayer.getRandomFontConfig = function (self, bMyself)
    if bMyself == nil then
        bMyself = false;
    end

    local index = math.random(1, l_font_config_count); 
    DebugLog("[BarrageLayer:getRandomFontConfig ] :"..index);
    if bMyself then
        return l_font_config.me;
    else
        return l_font_config[index] or l_font_config.default;
    end
    
end

--清除所有的弹幕text
BarrageLayer.clearAllBarrageText = function (self)
    self.m_allTextNode:removeAllChildren();
end


--开启关闭弹幕
BarrageLayer.showBarrageView = function (self, v)

    --更新数据
    self.m_data.bOpenView = v;
    --更新定时器
    if v then
        self:startTimer();
        --self.m_btnBarrage:setFile("apply/btnBarrageOpen.png");
    else
        --self.m_btnBarrage:setFile("apply/btnBarrageClose.png");
        self:stopTimer();
        self:clearAllBarrageText();
    end
    --设置界面隐藏
    self.m_bgImg:setVisible(v);
end

BarrageLayer.socketBarrageMsgCallback = function (self , data)
    
    local data = json.mahjong_decode_node(data.msg);
    local content = data.msg or -1;
    DebugLog("[BarrageLayer socketBarrageMsgCallback]"..content);
    --插入数据
    BarrageDataManager:Instance():push_msg(data);
    
end
--uitil获取弹幕消息
BarrageLayer.uitlSendPhpGetRandBarrageMsg = function (self, msg, isRandMsg)
    local param_data = {}
    if self.m_data.matchLevel then
        local roomData = HallConfigDataManager.getInstance():returnMatchDataByLevel(self.m_data.matchLevel);
        if roomData then 
            param_data.id = tonumber(roomData.id);
        end
    end
    param_data.matchid = self.m_data.matchId;
    if isRandMsg == false then
        param_data.msg = tostring(msg);
    end
    param_data.level = self.m_data.matchLevel;
    local cmd = (isRandMsg and PHP_CMD_REQUSET_MATCH_SEND_RAND_BARRAGE_MSG) or PHP_CMD_REQUSET_MATCH_SEND_BARRAGE_MSG
    --send
    SocketManager.getInstance():sendPack(cmd, param_data)
end

--发送弹幕消息
BarrageLayer.sendPhpBarrageMsg = function (self, msg)
    
    self:uitlSendPhpGetRandBarrageMsg(msg, false);
end

--获取随机弹幕消息
BarrageLayer.sendPhpGetRandBarrageMsg = function (self)
   self:uitlSendPhpGetRandBarrageMsg("", true);
end


--http回调
BarrageLayer.sendPhpCallback = function ( self, isSuccess, data )
	log( "[BarrageLayer:sendPhpCallback]" );
	if not isSuccess or not data then
        --Banner.getInstance():showMsg("发送失败！");
		return;
	end
    local tips   = nil
    local status = tonumber(data.status or 0)
    if status == 1 then
        --tips = "发送成功！" 
    else 
        tips = "发送失败！"
        --Banner.getInstance():showMsg(tips or "");
    end 
    
end

--socket access事件处理
BarrageLayer.onSocketPackEvent = function ( self, param, cmd )
	if self.socketEventFuncMap[cmd] then
		DebugLog("BarrageLayer deal socket cmd "..cmd);
		self.socketEventFuncMap[cmd](self, param);
	end
end

BarrageLayer.socketEventFuncMap = {
	[SERVER_MATCH_MSG_BARRAGE] = BarrageLayer.socketBarrageMsgCallback,
}

BarrageLayer.onPhpMsgResponse = function( self, param, cmd, isSuccess)
	if self.phpMsgResponseCallBackFuncMap[cmd] then 
		self.phpMsgResponseCallBackFuncMap[cmd](self,isSuccess,param)
	end
end


BarrageLayer.phpMsgResponseCallBackFuncMap =
{
    [PHP_CMD_REQUSET_MATCH_SEND_BARRAGE_MSG] = BarrageLayer.sendPhpCallback,
    --[PHP_CMD_REQUSET_MATCH_SEND_RAND_BARRAGE_MSG] = BarrageLayer.sendPhpCallback,
    
};