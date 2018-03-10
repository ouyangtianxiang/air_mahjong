local newSignLayout = require(ViewLuaPath.."newSignLayout");
local a_wheelTurn_map = require("qnPlist/a_wheelTurn")

local a_wheelLight_map = require("qnPlist/a_wheelLight")

local a_wheelRewardLight_map = require("qnPlist/a_wheelRewardLight")

local a_wheelTurnYellow_map = require("qnPlist/a_wheelTurnYellow")



--转盘动画的配置
local l_wheel_a_config = {
    nodeRotate = 23,
    rewardLight = {seq = 100005,},--最后出奖励的动画
    wheel = {seq = 100000,},--转盘转动
    light = {seq = 100001,},--抽奖按钮上的光
    wheelSide = {seq = 100002,},--
    normal_arrow = {seq = 100003},
    arrow = {seq = 100006,
            seq_middle = 100007,
            seq_end = 100008,
        effictName = "BackOut",--"BounceOnceOut",
        turnAngle = 540,--180*3
        during = 2000,
    },
};

local l_const_str = {day = "day", three = "three", five = "five", seven = "seven",fifteen = "fifteen", month = "month"};

local l_img_default = {
    award = "Hall/sign/default.png", 
    a = "Hall/sign/default.png",
    signStateCanAward = "Hall/sign/signState_1.png",
    signStateHadAward = "Hall/sign/signState_2.png",
    signStateLight = "Hall/sign/light.png"};
local l_roll_type = {day = "day", three = "three", five = "five", seven = "seven",fifteen = "fifteen", month = "month"};
local l_bq_type = {bq = 1, vip = 2, bqBuy = 3};
local l_invalid_value = -1;

NewSignWindow = class(SCWindow);

NewSignWindow.m_data = {};


NewSignWindow.ctor = function ( self, delegate, isPopWnd, isMustShow)
    DebugLog("[NewSignWindow :ctor]");
        --审核状态关闭
    if GameConstant.checkType == kCheckStatusOpen then 
        return;
	end
--    g_GameMonitor:addTblToUnderMemLeakMonitor("Sign",self)
    --初始化
    self:init(delegate, isPopWnd, isMustShow);
    EventDispatcher.getInstance():register(NativeManager._Event, self, self.nativeCallEvent);
end

NewSignWindow.dtor = function (self)
    DebugLog("[NewSignWindow :dtor]");
    EventDispatcher.getInstance():unregister(SocketManager.s_phpMsg, self, self.onPhpMsgResponse);
    EventDispatcher.getInstance():unregister(NativeManager._Event, self, self.nativeCallEvent);
    new_pop_wnd_mgr.get_instance():remove_wnd_by_type( new_pop_wnd_mgr.enum.sign );
end

--function NewSignWindow.show( self )
--    --审核状态关闭
--    if GameConstant.checkType == kCheckStatusOpen then 
--        return;
--	end
--    --self.super.show(self);

--	--self:showWnd();

--end

NewSignWindow.remove_effect = function (self)
    for i = 1, #self.m_btnSign do
        if self.m_btnSign[i] then
            local common = require("libEffect.shaders.common")
            common.removeEffect(self.m_btnSign[i])   
        end
        
    end
end


--初始化
NewSignWindow.init = function(self, delegate, isPopWnd, isMustShow)
    self:setDebugName("NewSignWindow")
    self:set_pop_index(new_pop_wnd_mgr.get_instance():get_wnd_idx(new_pop_wnd_mgr.enum.sign));

    isMustShow = (isMustShow == true) or false;
    self.m_delegate = delegate
    self.m_data = {};
    self.m_data.hasBeenRecvPhpAwardMsg = false;
    self.m_data.isPopWnd = isPopWnd;
    self.m_data.isMustShow = isMustShow;
    self.m_data.lastRollType = l_roll_type.day;
    self.m_data.currentRollType = l_roll_type.day;
    self.m_data.awardId = l_invalid_value;
    self.m_data.awardIndex = l_invalid_value;--最后动画停留的位置
    self.m_data.awardObj = {
        msg="", --奖励信息
        --isCoin = false,--是不是金币奖励
        money = 0,--金币奖励
        vip = 0,--体验vip
        coupons = 0,--话费卷
        card = 0,--卡片类型
        num = 1,--数量默认为1 这个值在道具为多个的时候才用吧,其他都设置成1
        sign_of_month = 0,--最新签到次数
        type = 0,--抽奖在类型 day three, five ..
    };
    self.m_data.drawtimes = 0;
    self.m_data.downloadImgs = {};
    self.m_data.text_bq_count = 0;
    self.m_data.lq_count = 0;
    self.m_data.bqk_num = 0;
    self.m_data.signInfo = {
        day = {}, 
        three = {}, 
        five = {}, 
        seven = {}, 
        fifteen = {}, 
        month = {}};
    --初始化控件
    self:initWidgets();
    --触碰空白处关闭窗口
    self:setCoverEnable(true);
    --创建左边转盘的视图节点
    self:createWheelNode();
    
    DebugLog(" :self:"..tostring(self));
    -- php注册回调事件
    EventDispatcher.getInstance():register(SocketManager.s_phpMsg, self, self.onPhpMsgResponse);

    --发送php请求 签到信息配置
    self:requestDetailSignInfo();

end

--请求签到配置信息
NewSignWindow.requestDetailSignInfo = function( self )
    DebugLog("NewSignWindow.requestDetailSignInfo");

	local param = {};
    
    SocketManager.getInstance():sendPack(PHP_CMD_REQUEST_DETAIL_SIGN_INFO_IN_SIGN, param)
end

--请求签到
NewSignWindow.requestSign = function( self )
    DebugLog("NewSignWindow.requestSign");

	local param = {};
	param.type = self.m_data.currentRollType;

    SocketManager.getInstance():sendPack(PHP_CMD_REQUEST_SIGN, param)
end

--请求 补签
NewSignWindow.requestBq = function( self, num )
    if self.m_data.isBtnBuQian == false then
        return;
    end
    num = num or 1;
	local param = {};
	param.number = num;

    SocketManager.getInstance():sendPack(PHP_CMD_REQUEST_BUQIAN, param)
end

--初始化控件
NewSignWindow.initWidgets = function(self)
    self.m_layout = SceneLoader.load(newSignLayout);
    self:addChild(self.m_layout);

    self.m_bg = publ_getItemFromTree(self.m_layout, {"bg"});
    self:setWindowNode( self.m_bg );
	self:setCoverEnable(true);

    self.m_delegate:addChild(self);

    local img_titile = publ_getItemFromTree(self.m_bg, {"img_titile"});
    img_titile:setEventTouch(self, function (self)
        --DebugLog("ss");
    end);

    self.m_Wheelbg = publ_getItemFromTree(self.m_bg, {"wheel"});
    self.m_Wheelbg:setEventTouch(self, function (self)
        --DebugLog("ss");
    end);
    self.m_Wheelbg:setEventTouch(self, function (self)
        --DebugLog("ss");
    end);
    
    local fun = function (obj, finger_action, x, y, drawing_id_first, drawing_id_current)
        
        if finger_action == kFingerDown then
	    elseif finger_action == kFingerMove then
	    elseif finger_action == kFingerUp then
            if drawing_id_first ~= drawing_id_current then 
                return; 
            end 
            if self:isPlayingAnimation(true) then
                return;
            end
            if obj.b.bSelected == true then
                obj.ob.m_data.currentRollType = l_roll_type.day;
            else
                obj.ob.m_data.currentRollType = obj.b.showRollType;
            end
            obj.ob:updateView();
            for i = 1, #obj.ob.m_btnSign do
                if obj.b == obj.ob.m_btnSign[i] then
                    obj.b.bSelected = not obj.b.bSelected;
                else
                    obj.ob.m_btnSign[i].bSelected = false;
                end
            end
        end
    end

    local tmpRoll = {l_roll_type.three, l_roll_type.five, l_roll_type.seven, l_roll_type.fifteen, l_roll_type.month};
    --签到按钮
    self.m_btnSign = {};
    for i = 1, 5 do
        local btn = publ_getItemFromTree(self.m_bg, {"btn_sign_"..i});

        btn.showRollType = tmpRoll[i];
        btn.bSelected = false;
        local obj ={ob = self, b = btn};
        btn:setEventTouch(obj, fun);
        table.insert(self.m_btnSign, btn);

        local img = new(Image, l_img_default.signStateCanAward);
        if img then
            img:setAlign(kAlignTopRight);
            img:setPos(0,-1);
            img:setVisible(false);
            img:setLevel(2);
            btn:addChild(img);
            btn.stateImg = img;

        end

        local imgLight = new(Image, l_img_default.signStateLight);
        if imgLight then
            imgLight:setAlign(kAlignCenter);
            imgLight:setPos(1,-5);
            imgLight:setLevel(1);
            imgLight:setVisible(false);
            btn:addChild(imgLight);
            btn.stateLightImg = imgLight;
        end
    end
    --补签按钮
    self.m_btnAdditional = publ_getItemFromTree(self.m_bg, {"btn_additional"});
    self.m_btnAdditional.bqText = publ_getItemFromTree(self.m_btnAdditional, {"text"});
    self.m_btnAdditional.currentType = l_bq_type.bq;
    --开始游戏
    self.m_btnStartGame = publ_getItemFromTree(self.m_bg, {"btn_start_game"});
    --关闭按钮
    local btnClose = publ_getItemFromTree(self.m_bg, {"btn_close"});
    btnClose:setOnClick(self, function (self)
        DebugLog("[press btn close]");
        self:hideWnd();
    end);

    --text小提示
    self.m_textTips = publ_getItemFromTree(self.m_bg, {"text_bg", "text"});

    --补签按钮回调
    self.m_btnAdditional:setOnClick(self, self.buqianCallback);
    --开始游戏按钮回调
    self.m_btnStartGame:setOnClick(self, self.startGameCallback);

    local str = "提升VIP可获取更丰富的奖励";
    local tipText = publ_getItemFromTree(self.m_bg, {"text_bg", "text"});
    if tipText then
        tipText:setText(str);
    end
    
end

--创建大转盘节点
NewSignWindow.createWheelNode = function (self)

    self.m_wheelNode = new(Node);
    self.m_wheelNode.wheelBg = publ_getItemFromTree(self.m_bg, {"wheel"});
    self.m_wheelNode:setAlign(kAlignCenter);
    self.m_wheelNode:setRotate(l_wheel_a_config.nodeRotate);
    self.m_Wheelbg:addChild(self.m_wheelNode);

    --animation---所有的animation都在self.a里面
    self.a = {};

    --轮盘转动动画
    self.a.wheelTurn = {};
    self.a.wheelTurn.widget = self.m_wheelNode;

    local wheelTurn = {};
	for i=1,4 do
		table.insert(wheelTurn, a_wheelTurn_map[string.format("wheelTurn_%d.png",i)]);
	end	
	self.a.wheelTurn.greenImages = UICreator.createImages(wheelTurn);
    self.a.wheelTurn.greenImages:setAlign(kAlignCenter);
    self.a.wheelTurn.greenImages:setVisible(false);
    self.m_wheelNode:addChild(self.a.wheelTurn.greenImages);
    self.a.wheelTurn.images = self.a.wheelTurn.greenImages;

    local yellowWheelTurn = {};
	for i=1,4 do
		table.insert(yellowWheelTurn, a_wheelTurnYellow_map[string.format("wheelTurn_%d.png",i)]);
	end	
	self.a.wheelTurn.yellowImages = UICreator.createImages(yellowWheelTurn);
    self.a.wheelTurn.yellowImages:setAlign(kAlignCenter);
    self.a.wheelTurn.yellowImages:setVisible(false);
    self.m_wheelNode:addChild(self.a.wheelTurn.yellowImages);

    


    --转盘上的圆圈动画
    self.a.wheelSide = {};
    local side = new(Image, "Hall/sign/wheel_side.png");
    if side then
        side:setAlign(kAlignCenter);
        side:setLevel(100);
        side:setVisible(false);
        self.m_wheelNode:addChild(side);
        self.a.wheelSide.widget = side;
    end


    --local imgTmp = new(Image, l_img_default.a);
    local imgW= 82;
    local ajust = 70;
    local ajustTmp = -25;
    delete(imgTmp); 
    local radius, _ = self.m_Wheelbg:getSize();
    radius = (radius)/2-imgW-ajust;

    local xTmp = math.sqrt(radius*radius/2);
    
    DebugLog("xTmp:"..xTmp);
    local config = {
    {x = 0, y = -radius, rotate = 0, extraAust = ajustTmp},
    {x = xTmp, y = -xTmp, rotate = 45, extraAust = ajustTmp},
    {x = radius, y = 0, rotate = 45*2, extraAust = ajustTmp},
    {x = xTmp, y = xTmp, rotate = 45*3, extraAust = ajustTmp},
    {x = 0, y = radius, rotate = 45*4, extraAust = ajustTmp},
    {x = -xTmp, y = xTmp, rotate = 45*5, extraAust = ajustTmp},
    {x = -radius, y = 0, rotate = 45*6, extraAust = ajustTmp},
    {x = -xTmp, y = -xTmp, rotate = 45*7, extraAust = ajustTmp},
    };

    self.m_awardNode = {};
    -- 创建转盘上的奖品内容
    for i = 1, 8 do
        local img = new(Image, l_img_default.award);
        if img then
            img:setSize(82,80);
            img:setAlign(kAlignCenter);
            img:setPos(config[i].x, config[i].y);
            img:setRotate(45*(i-1));--(config[i].rotate);
            local text = new(Text, "", 0, 0, kAlignCenter, "", 30, 0xff , 0xff , 0xff)
            text:setAlign(kAlignTop);
            text:setLevel(2);
            --text:setSize(82,35);
            text:setPos(0, -48);
            if i >= 3 and i <= 6 then
                text:setRotate(180);
            end
            img.titleDec = text;
            img.index = i;
            img:addChild(text);
            self.m_wheelNode:addChild(img);
            table.insert(self.m_awardNode, img);
        end  
    end

    --创建箭头按钮
    local imgArrow = new(Image, "Hall/sign/arrow.png");
    imgArrow:setAlign(kAlignCenter);
    imgArrow:setVisible(false);
    self.m_wheelNode:addChild(imgArrow);
    if imgArrow then
        imgArrow:setRotate(-25);
    end

    --创建抽奖按钮
    self.m_btnLottery = new(Button, "Hall/sign/btn_lottery.png", nil, nil, nil, 0, 0, 0, 0);
    self.m_btnLottery:setAlign(kAlignCenter);
    self.m_btnLottery:setRotate(0-l_wheel_a_config.nodeRotate);
    self.m_btnLottery:setOnClick(self, NewSignWindow.lottoryAwardCallback);
    self.m_wheelNode:addChild(self.m_btnLottery);

    --抽奖次数
    local text = new(Text, "(x0)", 0, 0, kAlignCenter, "", 30, 0xff , 0xea , 0x00)
    text:setAlign(kAlignBottom);
    text:setPos(0, 40);
    self.m_btnLottery.rollTimesText = text;
    self.m_btnLottery:addChild(text);


    --抽奖上的小灯动画
    self.a.wheelLight = {};
    self.a.wheelLight.widget = self.m_btnLottery;
    local lightImgs = {};
	for i=1,2 do
		table.insert(lightImgs, a_wheelLight_map[string.format("wheelLight_%d.png",i)]);
	end	
    self.a.wheelLight.images = UICreator.createImages(lightImgs);
    self.a.wheelLight.images:setAlign(kAlignCenter);
    self.m_btnLottery:addChild(self.a.wheelLight.images);
    self.a.wheelLight.images:setImageIndex(0);

    --箭头动画
    self.a.arrow = {};
    self.a.arrow.widget = imgArrow;

end

--获取转盘最后转到的角度
NewSignWindow.getEndRottate = function (self)
    local defaultIndex = 5;--箭头的index
    local index = 0;
    --for testself.m_data.awardId = 2291;
    for i = 1, #self.m_awardNode do
        if self.m_data.awardId  == self.m_awardNode[i].currentPackId then
            index = self.m_awardNode[i].index;
            self.m_data.awardIndex = index;
        end
    end
    if index == 0 then
        DebugLog("NewSignWindow.getEndRottate error :index == 0");
        return 0;
    else
        index = index+8;
        local rotate = 45*(index - defaultIndex-1);
        DebugLog("NewSignWindow.getEndRottate :rotate:"..rotate);
        return rotate;
    end
end


--点击按钮就播放，如果收到php返回消息则播放获奖动画
NewSignWindow.playNormalRollAnimation = function (self)
--    self:playAnimationWheelTurn(false);
--    self:playAnimationLotteryLight(false);
--    self:playAnimationWheelSide(false);
--    --重置箭头按钮，设置可见
--    self.a.arrow.widget:setRotate(0);
--    self.a.arrow.widget:setVisible(true);

--    self:playAnimationWheelTurn(true);
--    self:playAnimationLotteryLight(true);
--    self:playAnimationWheelSide(true);

--   self.a.arrow.widget:removeProp(l_wheel_a_config.normal_arrow.seq);
--    local prop =  self.a.arrow.widget:addPropRotate(
--                                        l_wheel_a_config.normal_arrow.seq,
--                                        kAnimRepeat,
--                                        5000,0,0,
--                                        360,
--                                        kCenterDrawing);
--    prop:setEvent(self, function ( self )
--        if self.m_bPlayingAnimation == false then
--            self.a.arrow.widget:removeProp(l_wheel_a_config.normal_arrow.seq);
--            self.a.arrow.widget:setRotate(0);
--        end
--        if self.m_data.hasBeenRecvPhpAwardMsg == true then

--            self:playAewardRollAnimation();
--        end
--    end);
end

--播放点击抽奖按钮，产生的动画
NewSignWindow.playAewardRollAnimation = function (self)
    DebugLog("NewSignWindow.playAewardRollAnimation");

    self.m_bPlayingAnimation = true;

    self:playAnimationWheelTurn(false);
    self:playAnimationLotteryLight(false);
    self:playAnimationWheelSide(false);
    --重置箭头按钮，设置可见
    self.a.arrow.widget:setRotate(0);
    self.a.arrow.widget:setVisible(true);

    self:playAnimationWheelTurn(true);
    self:playAnimationLotteryLight(true);
    self:playAnimationWheelSide(true);
    self:playAnimationArrow();
end

--抽奖按钮回调
NewSignWindow.lottoryAwardCallback = function (self)
    DebugLog("NewSignWindow.lottoryAwardCallback");
    
    if not self:isPlayingAnimation(true) then
        self:requestSign();
    end
end

--补签按钮回调
NewSignWindow.buqianCallback = function (self)
    DebugLog("[buqianCallback btn]:bqType:"..(self.m_btnAdditional.currentType or-1));
    if self:isPlayingAnimation(true) then
        return;
    end

    self.m_data.isBtnBuQian = true;
    local bqType = self.m_btnAdditional.currentType;
    if bqType == l_bq_type.bq then
        
        self:requestBq();
    elseif bqType == l_bq_type.vip then
        self:eventVip();
    elseif bqType == l_bq_type.bqBuy then
        require("MahjongCommon/ExchangePopu");
	    self.exchangePopu = new(ExchangePopu, ItemManager.BUQIAN_CID, self);
    end
end

--开始游戏按钮回调
NewSignWindow.startGameCallback = function (self)
    DebugLog("[atartGameCallback btn]")
    if HallScene_instance and HallScene_instance.onClickedQuickStartBtn then
        HallScene_instance:onClickedQuickStartBtn();
    end
    
end

--播放箭头扫光动画
NewSignWindow.playAnimationArrow = function (self)
    
    local endRotate = self:getEndRottate();
    if endRotate <= 0 then
        DebugLog("error, endRotate must > 0");
        return;
    end

    --重置箭头按钮，设置可见
    self.a.arrow.widget:setRotate(0);
    self.a.arrow.widget:setVisible(true);

    local total_time = 800;
    local v = total_time/360;
    local tmp = 5;
    local endRotateFinal = endRotate + l_wheel_a_config.nodeRotate;
    local fun_endExtra = function ()
        local seq_endExtra = EventDispatcher.getInstance():getUserEvent();
        local prop_endExtra =  self.a.arrow.widget:addPropRotate(
                                            seq_endExtra,
                                            kAnimNormal,
                                            200,0,0,
                                            (tmp),
                                            kCenterDrawing);
        prop_endExtra:setEvent(self, function ( self )
                self.a.arrow.widget:removeProp(seq_endExtra);
                self.a.arrow.widget:setRotate(endRotateFinal);
                self.a.arrow.widget:setVisible(false);
                self:playAnimationWheelTurn(false);
                self:playAnimationWheelSide(false);
                self:playAnimationAward(self.m_data.awardIndex);
            end);
    end

    local fun_end = function ()
        local seq_end = l_wheel_a_config.arrow.seq_end--EventDispatcher.getInstance():getUserEvent();
        local prop_end =  self.a.arrow.widget:addPropRotate(seq_end,kAnimNormal,300,0,0,-(tmp*2),kCenterDrawing);
        prop_end:setEvent(self, function ( self )
                self.a.arrow.widget:removeProp(seq_end);
                self.a.arrow.widget:setRotate(endRotateFinal-tmp);
                fun_endExtra();
            end);
    end

    local fun_middle = function ()
        local seq_middle = l_wheel_a_config.arrow.seq_middle--EventDispatcher.getInstance():getUserEvent();
        local prop_middle =  self.a.arrow.widget:addPropRotate(
                                                seq_middle,
                                                kAnimNormal,
                                                v*(endRotateFinal+tmp),0,0,
                                                endRotateFinal+tmp,kCenterDrawing);
            prop_middle:setEvent(self, function ( self )
                self.a.arrow.widget:removeProp(seq_middle);
                self.a.arrow.widget:setRotate(endRotateFinal+tmp);
                fun_end();
            end);
    end

    self.a.arrow.widget:removeProp(l_wheel_a_config.arrow.seq);
    local prop_start =  self.a.arrow.widget:addPropRotate(l_wheel_a_config.arrow.seq,kAnimRepeat,total_time,0,0,360,kCenterDrawing);

    local index = 1;
    prop_start:setEvent(self, function ( self )
        index = index + 1;
        if index > 3 then
            self.a.arrow.widget:removeProp(l_wheel_a_config.arrow.seq);
            fun_middle();
        end
    end); 
     
end
--播放转盘转动动画
NewSignWindow.playAnimationWheelTurn = function (self, bPlay)
    if bPlay == nil then
        bPlay = false;
    end
    if bPlay == true then
        self.a.wheelTurn.images:setVisible(true);
        self.a.wheelTurn.widget:removeProp(l_wheel_a_config.wheel.seq);
        local prop = self.a.wheelTurn.widget:addPropTranslate(l_wheel_a_config.wheel.seq,kAnimRepeat,200, 0, 0, 0, 0, 0)
		local index = 0
		prop:setEvent(self, function ( self )
            self.a.wheelTurn.images:setImageIndex(index);
			index = index + 1
			if index > 3  then
                index = 0; 
			end 
		end);
    else
         self.a.wheelTurn.images:setVisible(false);
         self.a.wheelTurn.widget:removeProp(l_wheel_a_config.wheel.seq);
    end

end

--播放动画抽奖按钮上的光l
NewSignWindow.playAnimationLotteryLight= function (self, bPlay)
    if bPlay == nil then
        bPlay = false;
    end
    if bPlay then
        self.a.wheelLight.widget:removeProp(l_wheel_a_config.light.seq);
        local prop = self.a.wheelLight.widget:addPropTranslate(l_wheel_a_config.light.seq,kAnimRepeat,500, 0, 0, 0, 0, 0)
		local index = 0
		prop:setEvent(self, function ( self )
            --DebugLog("self.a.wheelLight.images:setImageIndex(index):"..index);
            self.a.wheelLight.images:setImageIndex(index);
			index = index + 1
			if index > 1  then
                index = 0; 
			end 
		end);
    else
        self.a.wheelLight.widget:removeProp(l_wheel_a_config.light.seq);
        self.a.wheelLight.images:setImageIndex(1);
    end

end

--播放转盘圆边动画
NewSignWindow.playAnimationWheelSide = function (self, bPlay)
    if bPlay == nil then
        bPlay = false;
    end
    if bPlay then
        self.a.wheelSide.widget:removeProp(l_wheel_a_config.wheelSide.seq);
        local prop =  self.a.wheelSide.widget:addPropRotate(
                                    l_wheel_a_config.wheelSide.seq,
                                    kAnimRepeat,
                                    2000,0,0,
                                    360,
                                    kCenterDrawing);
    else
        self.a.wheelSide.widget:removeProp(l_wheel_a_config.wheelSide.seq);
    end
    self.a.wheelSide.widget:setVisible(bPlay and true or false);
end

--播放 中奖信息，撒金币
NewSignWindow.playAwardMsgAnimation = function (self, obj)
    if not obj or type(obj) ~= "table" then
        return;
    end
    if obj.money > 0 then
        showGoldDropAnimation();
    end
    AnimationAwardTips.play(obj.msg);
end

--播放转动结束后转到的中奖项动画
NewSignWindow.playAnimationAward= function (self, idx)
        if not idx then
            return;
        end
        --转动结束后中奖项动画
        local wheelAward = {};
        wheelAward.widget = self.m_awardNode[idx ];
        if not wheelAward.widget then
            return;
        end
        local awardImgs = {};
	    for i=1,9 do
		    table.insert(awardImgs, a_wheelRewardLight_map[string.format("wheelRewardLight_%d.png",i)]);
	    end	

        wheelAward.images = UICreator.createImages(awardImgs);
        wheelAward.images:setLevel(1);
        wheelAward.images:setAlign(kAlignCenter);
        local iTmp = 2;
        wheelAward.images:setAlign(kAlignTop);
        wheelAward.images:setPos(0, -64);
        wheelAward.images:setRotate(180);
        wheelAward.images:setImageIndex(0);
        wheelAward.widget:addChild(wheelAward.images);
	if wheelAward  then 
        wheelAward.widget:removeProp(l_wheel_a_config.rewardLight.seq);
        wheelAward.prop = wheelAward.widget:addPropTranslate(l_wheel_a_config.rewardLight.seq,kAnimRepeat,50, 0, 0, 0, 0, 0)
		local index = 5
		wheelAward.prop:setEvent(self, function ( self )
            if index > 8 then
                wheelAward.images:setImageIndex(8);
            else
                wheelAward.images:setImageIndex(index);
            end
            
            DebugLog("hyq...animation:index:"..index);
			index = index + 1
			if index > 15  then
                wheelAward.widget:removeProp(l_wheel_a_config.rewardLight.seq);
                wheelAward.images:removeFromSuper();
                self:playAnimationLotteryLight(false);
                self:playAwardMsgAnimation(self.m_data.awardObj);
                self:updatePlayerData(self.m_data.awardObj);
                self.m_bPlayingAnimation = false;
			end 
		end);
		wheelAward.prop:setDebugName("Animation wheelAward light turn");
	end
end

--签到按钮状态更新
NewSignWindow.resetSignBtnSelected = function(self)
       --5个签到按钮
    for i = 1, #self.m_btnSign do
        self.m_btnSign[i].bSelected = false;
    end
end

--是否在播放抽奖动画
NewSignWindow.isPlayingAnimation = function (self, bShowMsg)
    if self.m_bPlayingAnimation == true then
        if bShowMsg == true then
            Banner.getInstance():showMsg("亲，还在抽奖..");
        end
        return true;
    else
        return false;
    end
end

--刷新界面
NewSignWindow.updateView = function(self)
    DebugLog("NewSignWindow.updateView");

    --转盘上的奖品内容
    self:updateAwardImg(true);
  
    --转盘抽奖按钮
    local drawtimes = self.m_data.drawtimes;
    
    if self.m_data.currentRollType == l_roll_type.day then

        drawtimes = self.m_data.drawtimes;
        self.a.wheelTurn.images = self.a.wheelTurn.greenImages;
        self.a.wheelTurn.yellowImages:setVisible(false);
        self.m_wheelNode.wheelBg:setFile("Hall/sign/wheel_bg.png");
        self.a.wheelSide.widget:setFile("Hall/sign/wheel_side.png");
        self.a.arrow.widget:setFile("Hall/sign/arrow.png");
    else
        self.m_wheelNode.wheelBg:setFile("Hall/sign/wheel_yellow_bg.png");
        self.a.wheelSide.widget:setFile("Hall/sign/wheel_side_yellow.png");
        self.a.arrow.widget:setFile("Hall/sign/arrow_yellow.png");
        self.a.wheelTurn.images = self.a.wheelTurn.yellowImages;
        self.a.wheelTurn.greenImages:setVisible(false);

        local data = self:getCurrentRollData(self.m_data.currentRollType);
        if data  then
            if data.canBeAward ==1 then
                drawtimes = 1;
            else
                drawtimes = 0;
            end
        end
    end
     local strRollTimes = "(X"..tostring(drawtimes)..")";
    if drawtimes and drawtimes <= 0 then
        self.m_btnLottery:setIsGray(true);
        self.m_btnLottery:setPickable(false);
        self.m_btnLottery.rollTimesText:setText("(X0)");
    else
        self.m_btnLottery:setIsGray(false);
        self.m_btnLottery:setPickable(true);
        self.m_btnLottery.rollTimesText:setText(strRollTimes);
    end

    --5个签到按钮
    for i = 1, #self.m_btnSign do
        self.m_btnSign[i]:setIsGray(false);
        self.m_btnSign[i].bShowGray = false;
        self.m_btnSign[i].stateLightImg:setVisible((self.m_btnSign[i].showRollType == self.m_data.currentRollType) or false);
        local d = self.m_data.signInfo[self.m_btnSign[i].showRollType];
        local img = self.m_btnSign[i].stateImg;
        if d.canBeAward == 1 then
            img:setFile(l_img_default.signStateCanAward);
            img:setVisible(true);
        end
        if d.isAward == 1 then
            img:setFile(l_img_default.signStateHadAward);
            img:setVisible(true);
        end
        if not (d.canBeAward == 1 or d.isAward == 1)then
            img:setVisible(false);
            self.m_btnSign[i]:setIsGray(true);
            self.m_btnSign[i].bShowGray = true;
        end
    end
    
    --补签按钮刷新
    self:updateBtnBq();
    
end

--获取当前签到转盘上的数据
NewSignWindow.getCurrentRollData = function (self, rollType)
    if rollType == l_roll_type.day then
        return self.m_data.signInfo.day;
    elseif rollType == l_roll_type.three then
        return self.m_data.signInfo.three;
    elseif rollType == l_roll_type.five then
        return self.m_data.signInfo.five;
    elseif rollType == l_roll_type.seven then
        return self.m_data.signInfo.seven;
    elseif rollType == l_roll_type.fifteen then
        return self.m_data.signInfo.fifteen;
    elseif rollType == l_roll_type.month then
        return self.m_data.signInfo.month;
    else
        return nil;
    end
end


--刷新奖品界面
NewSignWindow.updateAwardImg = function(self, isUpdateText)

    DebugLog("NewSignWindow.updateAwardImg ...1");
    local data = self:getCurrentRollData(self.m_data.currentRollType);
    if not data then
        DebugLog("NewSignWindow.updateAwardImg data is nil");
        return;
    end
    DebugLog("NewSignWindow.updateAwardImg ...2");
    for i = 1, #data do
        local node = self.m_awardNode[i];
        if node then
            DebugLog("NewSignWindow.updateAwardImg ...3");
            if isUpdateText and node.titleDec then
                node.titleDec:setText(data[i].name);
            end
            node.currentPackId = data[i].id or 0;
            if data[i].isExist then 
                node:setFile(data[i].imageName)
            else
                node:setFile(l_img_default.award)
            end
        end
    end
end

--刷新奖品界面
NewSignWindow.updateAwardImgByNativeDownloadEvent = function(self, filename)
    local data = self:getCurrentRollData(self.m_data.currentRollType)
    if not data then
        DebugLog("NewSignWindow.updateAwardImg data is nil");
        return;
    end

    --设置下载成功标示
    for key, tbl in pairs(self.m_data.signInfo) do  
        for i, imageData in ipairs(tbl) do 
            if type(imageData) == "table" and imageData.imageName == filename then                 
                imageData.isExist = true
            end
        end
    end

    --设置对应的图片
    for i = 1, #data  do
        local node = self.m_awardNode[i];
        if node then
            if data[i].imageName == filename then
                node:setFile(filename)
            end
        end
    end
end

--判断接收的java回调的下载图片是不是当前界面下载的
NewSignWindow.isInDowndingImgs =function (self, imgName)
    local imgs = self.m_data.downloadImgs or {};
    for i = 1, #imgs do
        if imgName == imgs[i] then
            return true;
        end
    end
    return false;
end


NewSignWindow.initSignDetailData = function (self, data)

end

--提升vip相关的操作
NewSignWindow.eventVip = function (self)
    
    local me = PlayerManager.getInstance():myself();
    local bVipFirst= (me.vipLevel <= 0);
	if bVipFirst == true then
		umengStatics_lua(Umeng_UserBeVIP);
	else
		umengStatics_lua(Umeng_UserLevelVIP);
	end
    --首充
	if GameConstant.checkType ~= kCheckStatusOpen then 
		if FirstChargeView.getInstance():show() then
			return;
		end 
	end

    local product = ProductManager.getInstance():getBankruptAndNotEventProduct();
    if not product then 
		return; 
	end
		--如果当前为审核状态，就需要二次弹框
	if tonumber(GameConstant.checkType) ~= kCheckStatusClose then
		local text = "购买超值金币，畅想精彩游戏！你将购买"..product.pname .. "，资费" .. product.pamount .. "元！你确定要购买吗？\n客服电话:400-663-1888或0755-86166169";

		local view = PopuFrame.showNormalDialog( "温馨提示", text, GameConstant.curGameSceneRef, nil,nil,true, false,"确定","取消");
		view:setConfirmCallback(self, function ( self )
			PlatformFactory.curPlatform:pay(product);
		end);
		view:setCallback(view, function ( view, isShow )
			if not isShow then
				
			end
		end);
	else
		PlatformFactory.curPlatform:pay(product);
	end

end

--更新补签按钮的显示
NewSignWindow.updateBtnBq = function (self)
    if not self.m_data.text_bq_count or not self.m_data.lq_count then
        return;
    end
    --当漏签次数为0时，则按钮变成提升VIP，点击弹出快速购买界面。推荐金币按VIP等级推荐
    if self.m_data.lq_count <=0 then
        self.m_btnAdditional.currentType = l_bq_type.vip;
        self.m_btnAdditional.bqText:setText("提升VIP");
    else
        --当漏签次数不为0，而补签卡为0时，则按钮显示为【补签】，点击则弹出购买补签卡界面。购买一定数量后，则自动补签对应的次数。
        if self.m_data.bqk_num <=0 then
            self.m_btnAdditional.currentType = l_bq_type.bqBuy;
            self.m_btnAdditional.bqText:setText("补签");
        else
            self.m_btnAdditional.currentType = l_bq_type.bq;
            self.m_btnAdditional.bqText:setText("补签("..self.m_data.text_bq_count..")");
        end
    end
end
--初始化数据AwardInfo
NewSignWindow.initAwardInfo = function (self, award)
    if not award then
        return;
    end
    self.m_data.signInfo.day = {};
    self.m_data.signInfo.three = {};
    self.m_data.signInfo.five = {};
    self.m_data.signInfo.seven = {};
    self.m_data.signInfo.fifteen = {};
    self.m_data.signInfo.month = {};
    for i = 1, #award do
        local d = award[i];
        local dTmp = {};
        dTmp.name = d.name
        dTmp.imgUrl = d.img
        table.insert(self.m_data.downloadImgs, dTmp.imgUrl);
        dTmp.id = tonumber(d.id);
        for j = 1, #d.pack do
            local str = tostring(d.pack[j]);
            if str == l_const_str.day then
                table.insert(self.m_data.signInfo.day, dTmp);
            elseif str == l_const_str.three then
                table.insert(self.m_data.signInfo.three, dTmp);
            elseif str == l_const_str.five then
                table.insert(self.m_data.signInfo.five, dTmp);
            elseif str == l_const_str.seven then
                table.insert(self.m_data.signInfo.seven, dTmp);
            elseif str == l_const_str.fifteen then
                table.insert(self.m_data.signInfo.fifteen, dTmp);
            elseif str == l_const_str.month then
                table.insert(self.m_data.signInfo.month, dTmp);
            end
        end
    end
    --test
--    local test_fun = function (obj, name)
--        for i = 1, #obj do
--            DebugLog("test_fun:"..name..":"..obj[i].id) 
--        end
--    end
--    test_fun(self.m_data.signInfo.day, "day");
--    test_fun(self.m_data.signInfo.three, "day");
--    test_fun(self.m_data.signInfo.five, "five");
--    test_fun(self.m_data.signInfo.seven, "seven");
--    test_fun(self.m_data.signInfo.fifteen, "fifteen");
--    test_fun(self.m_data.signInfo.month, "month");
--    DebugLog("");
end

--初始化数据giftPacks
NewSignWindow.initGifgPackData = function (self, giftPacks)
    if not giftPacks then
        return;
    end
    for i = 1, #giftPacks do
        local d = giftPacks[i];
        local str = tostring(d.packId);
        local isAward = tonumber(d.isAward);
        local canBeAward = tonumber(d.canBeAward);
        if str == l_const_str.day then
            self.m_data.signInfo.day.isAward = isAward;
            self.m_data.signInfo.day.canBeAward = canBeAward;
        elseif str == l_const_str.three then
            self.m_data.signInfo.three.isAward = isAward;
            self.m_data.signInfo.three.canBeAward = canBeAward;
        elseif str == l_const_str.five then
            self.m_data.signInfo.five.isAward = isAward;
            self.m_data.signInfo.five.canBeAward = canBeAward;
        elseif str == l_const_str.seven then
            self.m_data.signInfo.seven.isAward = isAward;
            self.m_data.signInfo.seven.canBeAward = canBeAward;
        elseif str == l_const_str.fifteen then
            self.m_data.signInfo.fifteen.isAward = isAward;
            self.m_data.signInfo.fifteen.canBeAward = canBeAward;
        elseif str == l_const_str.month then
            self.m_data.signInfo.month.isAward = isAward;
            self.m_data.signInfo.month.canBeAward = canBeAward;
        end
    end

end 

--
NewSignWindow.isHaveDrawtimesAndSetCurrentRollType = function (self)
    self.m_data.currentRollType = l_roll_type.day;
    if self.m_data.drawtimes > 0 then
        return true;
    else--if self.m_data.drawtimes <= 0 then
        if self.m_data.signInfo.three.canBeAward == 1 then
            times = 1;
            self.m_data.currentRollType = l_roll_type.three;
            return true;
        elseif self.m_data.signInfo.five.canBeAward == 1 then
            times = 1;
            self.m_data.currentRollType = l_roll_type.five;
            return true;
        elseif self.m_data.signInfo.seven.canBeAward == 1 then
            times = 1;
            self.m_data.currentRollType = l_roll_type.seven;
            return true;
        elseif self.m_data.signInfo.fifteen.canBeAward == 1 then
            times = 1;
            self.m_data.currentRollType = l_roll_type.fifteen;
            return true;
        elseif self.m_data.signInfo.month.canBeAward == 1 then
            times = 1;
            self.m_data.currentRollType = l_roll_type.month;
            return true;
        end
    end
    return false;
end


--初始化数据SignDetailInfo
NewSignWindow.initSignDetailInfo = function (self, data)
    if not data then
        
        return;
    end
    self.detailSignInfo = data;
    self.m_data.isBtnBuQian = false;
    self.m_data.drawtimes = data.data.drawtimes
    self.m_data.bqk_num = data.data.bqk_num or 0;
    self.m_data.lq_count = data.data.lq_count or 0;
    --补签按钮上的可补签显示 
    self.m_data.text_bq_count = ((self.m_data.lq_count < self.m_data.bqk_num ) and self.m_data.lq_count) or self.m_data.bqk_num;
    

    self:initAwardInfo(data.data.award);
    self:initGifgPackData(data.data.giftPacks);
    
    self:isHaveDrawtimesAndSetCurrentRollType();
   
end

--初始化数据
NewSignWindow.initData = function (self, data)

    self:initSignDetailInfo(data);

    --下载全部获奖图片
    for key, tbl in pairs(self.m_data.signInfo) do
        for _, imageData in ipairs(tbl) do 
            if type(imageData) == "table" then 
                local isExist, localDir = NativeManager.getInstance():downloadImage(imageData.imgUrl)
                imageData.imageName = localDir
                imageData.isExist = isExist
            end
        end
    end

end


NewSignWindow.nativeCallEvent = function(self, param, _detailData)
    if kDownloadImageOne == param then
        self:updateAwardImgByNativeDownloadEvent(_detailData);
    end
end

-- 获取签到详细信息回调
NewSignWindow.requestDetailSignInfoCallback = function ( self , isSuccess, data )
	DebugLog( "NewSignWindow.requestDetailSignInfoCallback" );

    if not data then
        DebugLog("data is nil");
        return;
    end

    if isSuccess then
        mahjongPrint(data)
    end
    --审核状态关闭
    if GameConstant.checkType == kCheckStatusOpen then 
		self:hideWnd();
        return;
	end
	if not self.m_data.isPopWnd then
		Loading.hideLoadingAnim();
	end
	if not isSuccess or not data then
		DebugLog("not isSuccess or not data")
		self:hideWnd();
		return ;
	end

	if 1 == tonumber(data.status) then
        --更新数据
		self:initData(data);
	end
    
    --刷新界面
    self:updateView();
    if self.m_data.isMustShow == true then
        DebugLog("NewSignWindow requestDetailSignInfoCallback:self.m_data.isMustShow");
        self:showWnd();
    else
        --抽奖次数为0时不显示签到
        if not self:isHaveDrawtimesAndSetCurrentRollType() then
            DebugLog("NewSignWindow requestDetailSignInfoCallback:hide");
            self:hideWnd();
        else
            if self.m_data.isPopWnd then
                DebugLog("NewSignWindow requestDetailSignInfoCallback:self.m_data.isPopWnd == true");
                new_pop_wnd_mgr.get_instance():add_and_show( new_pop_wnd_mgr.enum.sign );
            else
                DebugLog("NewSignWindow requestDetailSignInfoCallback:showWnd");
                --显示界面
                self:showWnd();
            end
        end
    end
   
end

--请求抽奖php回调
NewSignWindow.requestSignCallback = function ( self , isSuccess, data)
	DebugLog( "NewSignWindow.requestSignCallback" );

    if not data then
        DebugLog("data is nil");
        return;
    end
  
    if isSuccess then
        mahjongPrint(data)
    end
    local msg = data.msg
    
    self.m_data.hasBeenRecvPhpAwardMsg = false;

	if 1 == tonumber(data.status) then
        --设置收到php返回消息为true
        self.m_data.hasBeenRecvPhpAwardMsg = true;
        self.m_data.drawtimes = data.data.drawtimes
        self.m_data.awardId = tonumber(data.data.id)
        self.m_data.awardObj.msg = msg;
        self.m_data.awardObj.money = tonumber(data.data.money)
        self.m_data.awardObj.coupons = tonumber(data.data.coupons)
        self.m_data.awardObj.card = tonumber(data.data.card)
        self.m_data.awardObj.sign_of_month = tonumber(data.data.sign_of_month)
        self.m_data.awardObj.num = tonumber(data.data.num)
        self.m_data.awardObj.type = data.data.type
        self.m_data.awardObj.vip = tonumber(data.data.vip)
        
        self:initGifgPackData(data.data.giftPacks);
--        --刷新界面
        self:updateView();
        self:playAewardRollAnimation();
       
    else
        if msg ~= nil and kNullStringStr ~= msg then 
		    Banner.getInstance():showMsg(msg);
	    end
        self:requestDetailSignInfo();
	end

end

--更新palyer的信息数据
NewSignWindow.updatePlayerData = function (self, awardObj)--(self, money, coupons, vip)
   
    local money, coupons, vip = awardObj.money, awardObj.coupons, awardObj.vip
    local cardid, num = awardObj.card, awardObj.num;
    if vip and vip > 0 then
        PlayerManager.getInstance():myself().vipLevel = vip;
    end

	PlayerManager.getInstance():myself():addMoney(money);
    PlayerManager.getInstance():myself():addCoupons(coupons);

	if cardid then
        if tonumber( cardid ) == ItemManager.BUQIAN_CID then
            self.m_data.bqk_num = self.m_data.bqk_num+num;
			self.m_data.text_bq_count = self.m_data.text_bq_count + num;
            self:updateBtnBq();
		end
	end
end

--请求抽奖php回调
NewSignWindow.requestBqCallback = function ( self , isSuccess, data)
	DebugLog( "NewSignWindow.requestBqCallback" );

    if not data then
        DebugLog("data is nil");
        return;
    end

    if isSuccess then
        mahjongPrint(data)
    end
    local msg = data.msg
    

	if 1 == tonumber(data.status) then
        
        local sign_info = data.data.sign_info;
        self.m_data.drawtimes = data.data.drawtimes
        self.m_data.bqk_num = sign_info.bqk_count or 0;--sign_count today_sign
        self.m_data.lq_count = sign_info.lq_count or 0;
        --补签按钮上的可补签显示 
        self.m_data.text_bq_count = ((self.m_data.lq_count < self.m_data.bqk_num ) and self.m_data.lq_count) or self.m_data.bqk_num;
    

        self:initGifgPackData(data.data.giftPacks);

        --刷新界面
        self:updateView();
    else
        
	end
    if msg ~= nil and kNullStringStr ~= msg then 
		Banner.getInstance():showMsg(msg);
	end
end

--php 回调
NewSignWindow.phpMsgResponseCallBackFuncMap = 
{
    [PHP_CMD_REQUEST_DETAIL_SIGN_INFO_IN_SIGN] = NewSignWindow.requestDetailSignInfoCallback,--签到配置信息
    [PHP_CMD_REQUEST_SIGN] = NewSignWindow.requestSignCallback,--请求抽奖
    [PHP_CMD_REQUEST_BUQIAN] = NewSignWindow.requestBqCallback,--请求补签
};
--php 回调
NewSignWindow.onPhpMsgResponse = function( self, param, cmd, isSuccess)
    if self.phpMsgResponseCallBackFuncMap[cmd] then 
		self.phpMsgResponseCallBackFuncMap[cmd](self,isSuccess,param)
	end
end
