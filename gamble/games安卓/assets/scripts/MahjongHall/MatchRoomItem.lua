local matchRoomItem = require(ViewLuaPath.."matchRoomItem");
MatchRoomItem = class(Node);

function MatchRoomItem.ctor(self,data,index)
    DebugLog("NewRoomItem.ctor")
    if not data then
        return;
    end
    self.bg = nil;
    self.index  = index;  --序号
    self.level = nil;   --场次
    self.di = nil;      --低注
    self.require = nil;      --报名限制（入场要求）
    self.limitOutCardTime = nil;    --出牌时间
    self.payTime     = nil;         --用户达到底线金币时，等待玩家充值时间
    self.tax         = nil;         --台费 
    self.matchName   = nil;         --赛场名称
    self.apply       = nil;         --报名费
    self.sub         = nil;         --角标 话费
    self.xuezhan          = nil;         --是否血战（玩法） 
    self.xueliu          = nil;         --是否血流（玩法）
    self.liangfan          = nil;         --是否两房牌（玩法）
    self.huansanzhang          = nil;         --是否换三张（玩法）
    self.huanliangzhan          = nil;         --是否换两张（玩法）
    self.dingque                = nil;           --是否定缺（玩法）
    self.offfline               = nil;          --金币下限，等同于破产，提示金币充值
    self.person                 = nil;          --人满开始的要求
    self.exceed                 = nil;          --入场金额上限
    self.cost                   = nil;          --多少话费场
    self.matchType              = nil;          --比赛类型 1：人满开赛  2：定时赛
    self.id                     = nil;          --比赛配置id,唯一标识
    self.recommend                   = nil;          --推荐商品金额
    self.starttime = nil;                   --定时赛才有这个字段，是开赛时间和结束时间

    --定义左右摆动弧度，及延迟时间
    local value1 = { startValue = 10, endValue = -10, delayTime = -1};
    local value2 = { startValue = -10, endValue = 10, delayTime = 0};
    local value3 = { startValue = 10, endValue = -10, delayTime = 100};
    local value4 = { startValue = -10, endValue = 10, delayTime = 1000};

    self.userDefineAnim ={ value1, value2, value3, value4};
    
    self:create();
    self:setData(data)
    EventDispatcher.getInstance():register(NativeManager._Event, self, self.nativeCallEvent);
end

function MatchRoomItem.create( self )
    self.m_item = SceneLoader.load(matchRoomItem)
    self:addChild(self.m_item)
    self.bgBtn = publ_getItemFromTree(self.m_item, {"Button1"} )
--    local modeindex = self.index % 4
--    self.bgBtn:setFile("Hall/chooseLevel/matchbg" .. tostring(modeindex) .. ".png")

--    self.awardText  = publ_getItemFromTree(self.m_item, {"Button1","Text1"})

--    self.roomNameImg = publ_getItemFromTree(self.m_item, {"Button1","Image2"})
--    self.roomNameImg:setFile("Hall/chooseLevel/match_default.png")

--    self.limitText = publ_getItemFromTree(self.m_item, {"Button1","View1","Text1"})
--    self.onlineUserText = publ_getItemFromTree(self.m_item, {"Button1","View2","Text1"})
--    self.onlineUserImg = publ_getItemFromTree(self.m_item, {"Button1","View2","Image3"})

    self.bgBtn:setOnClick(self, self.enterRoomClick);

    if DEBUGMODE == 1 then
        self.typeName = UICreator.createText("",0,0,0,0,kAlignTopLeft,40,255,255,255);
        self.bgBtn:addChild( self.typeName );
    end

    --

    DebugLog("-----------------------------------create");
end

-- 设置数据,data的数据格式如下：
 --[data    :
 --     id                          --比赛配置id,唯一标识
 --   "index":1,                  --序号
 --    type
 --   "level":80,                 --场次
 --   "value":2000,               --低注
 --   "require":200000,           --报名限制（入场要求）
 --   "time":5,                   --出牌时间
 --   "paytime":100,              --用户达到底线金币时，等待玩家充值时间
 --   "tax":10000,               --台费 
 --   "name":"大师赛",             --赛场名称
 --   "apply":10000,              --报名费
 --   "sub":"话费",               --角标
 --   "xz":0,                     --是否血战（玩法）
 --   "xl":1,                     --是否血流（玩法）
 --   "lf":0,                     --是否两房牌（玩法）
 --   "hs":1,                     --是否换三张（玩法）
 --   "hl":0,                     --是否换两张（玩法）
 --   "dq":0,                     --是否定缺（玩法）
 --   "offline":20000             --金币下限，等同于破产，提示金币充值
 --   person                      --开赛人数
 --   exceed                      --入场金币上限
 --   kemp                        --冠军奖励
 --   starttime                   --定时赛开始时间和结束时间
 -- ]
function MatchRoomItem.setData( self, data)
    if not data then
        return;
    end

    self.dataFinish = true;
    self.id = tonumber(data.id);
    self.matchType        = tonumber(data.type);  
    self.index = tonumber(data.index);
    self.level = tonumber(data.level);
    self.di    = tonumber(data.value);
    self.require = tonumber(data.require);
    self.limitOutCardTime = data.time;
    self.payTime          = data.paytime;
    self.tax              = data.tax;
    self.matchName        = data.name;
    self.apply            = tonumber(data.apply);
    self.sub              = data.sub;
    self.xuezhan          = tonumber(data.xz);
    self.xueliu           = tonumber(data.xl);
    self.liangfan         = tonumber(data.lfp);
    self.huansanzhang     = tonumber(data.hsz);
    self.huanliangzhan    = tonumber(data.hlz);
    self.dingque          = tonumber(data.dq);
    self.exceed           = tonumber(data.exceed);
    self.offfline         = tonumber(data.offfline);
    self.person           = tonumber(data.person);
    self.recommend        = tonumber(data.recommend); --//推荐商品金额
    self.offline          = tonumber(data.offline)  
    self.kemp             = data.kemp;
    self.qian3            = data.qian3;
    self.showpic = data.showpic;
 
--    if 2 == self.matchType then
--        self.starttime        = data.starttime;
--        self.onlineUserImg:setFile("Hall/chooseLevel/time.png")
--    end

--    self.nameUrl = data.nameUrl



--    --self.sub   1:话费， 2：实物， 3：热门  4：活动 5血流 6免费  0，无
--    if self.sub and tonumber(self.sub) then

--        local isub = tonumber(self.sub)
--        if isub > 0 and isub < 7 then 
--            local path = "newHall/roomItem/activity";
--            path = path .. tonumber(self.sub) .. ".png"

--            if self.subImg then
--                self.subImg:setFile(path);
--            else
--                self.subImg = UICreator.createImg(path);
--                self.bgBtn:addChild(self.subImg);
--                self.subImg:setAlign(kAlignTopRight)
--                self.subImg:setPos(10,0)

--                local iCount = #self.userDefineAnim;
--                --math.randomseed(tostring(os.time()):reverse():sub(1,9)); -- 短时间内保证产生的随机数尽量不一致
--                local rdId = math.random();
--                if rdId <= 0.25 then
--                    rdId = 1;
--                elseif  rdId > 0.25 and rdId <= 0.5 then
--                    rdId = 2;
--                elseif  rdId > 0.5 and rdId <= 0.75 then
--                    rdId = 3;
--                else
--                    rdId = 4;
--                end

--                local width = select(1, self.subImg:getSize());
--                local RotateAnim =  self.subImg:addPropRotate(0, kAnimLoop, 1800, self.userDefineAnim[rdId].delayTime, 
--                        self.userDefineAnim[rdId].startValue, self.userDefineAnim[rdId].endValue, kCenterXY, width / 2, 0);
--                RotateAnim:setDebugName("MatchRoomItem RotateAnim");
--            end
--        end 
--    end
--    self.awardText:setText(self.kemp)

--    local requireStr = self.require .. "金币准入"

--    local max = 2000000000;
--    if self.require >= max or self.exceed >= max then
--        requireStr = trunNumberIntoThreeOneFormWithInt(self.require, true, true) .. "金币以上"
--    else
--        requireStr = trunNumberIntoThreeOneFormWithInt(self.require, true, true) .. "-"..trunNumberIntoThreeOneFormWithInt(self.exceed, true, true);
--        requireStr = (requireStr and requireStr.."金币")or "" ;
--    end

--    if tonumber(self.require) == 0 then 
--        requireStr = "任意金币准入"
--    end 
--    self.limitText:setText(requireStr);

--    if 1 == self.matchType then
--        if self.person then
--            self.onlineUserText:setText((self.person or 0) .. "人满即开");
--        end
--    elseif 2 ==  self.matchType then
--        if self.starttime then
--            self.onlineUserText:setText(self.starttime);
--        end
--    end

    if DEBUGMODE == 1 then
        self.typeName:setText( data.level );
    end

    --
    local w, h = 266,322;
    self.bgBtn:setSize(w, h);
    self.m_item:setSize(w, h);
    --1：人满赛 2：定时赛 3：大奖赛-默认显示图片
    --if self.matchType >= 1 and self.matchType <= 3 then
    self.bgBtn:setFile("Hall/chooseLevel/match_default_1.png");
    --end
    --网络下载图片
    local isExist, localDir = NativeManager.getInstance():downloadImage(self.showpic);
    self.showpicName = localDir;
    if isExist then
        self.bgBtn:setFile(localDir);
    end
end

function MatchRoomItem.setCallback( self, obj, fun )
    self.obj = obj;
    self.callback = fun;
end

function MatchRoomItem.enterRoomClick( self )
    self:reportRoomItemClick();
    if self.obj and self.callback then
        self.callback(self.obj);
    end
end

function MatchRoomItem.reportRoomItemClick( self )
    local roomItemTable = {Umeng_ScreenChuJi , Umeng_ScreenZhongJi,Umeng_ScreenGaoJi,Umeng_ScreenDaShi,Umeng_ScreenXueZhan,Umeng_ScreenXueLiu}; --这里需要改动
    if roomItemTable[self.index] then
        DebugLog(roomItemTable[self.index]);
        umengStatics_lua(roomItemTable[self.index]);
    end
end

function MatchRoomItem.getType( self )
    return nil
end 

function MatchRoomItem.setApplyLimitNum( self, num )
    if not num then
        return;
    end
    self.require = num;
    self:setApplyLimitText();
    --self.ApplyLimitNum:setText((self.require or 0) .. "金币");
end

--私有的设置进入比赛要求限制
function MatchRoomItem.setApplyLimitText(self)

    local applyLimitWan = self.require / 10000;
    if self.exceed == 0 then
        self.ApplyLimitNumText:setText((applyLimitWan or 0) .. "万金币以上");
    else
        local exceedWan = self.exceed / 10000;
        self.ApplyLimitNumText:setText((applyLimitWan or 0) .. "万金币-" .. (exceedWan or 0) .. "万金币");
    end
end

function MatchRoomItem.getDi( self )
    if not self.dataFinish then
        DebugLog("  get di failed, room item data is nil");
        return 0;
    end
    return self.di;
end

function MatchRoomItem.getLevel( self )
    if not self.dataFinish then
        DebugLog("  get level failed, room item data is nil");
        return 0;
    end
    return self.level;
end

function MatchRoomItem.getPayTime( self )
    if not self.dataFinish then
        DebugLog("  get limit time failed, room item data is nil");
        return 0;
    end
    return self.payTime;
end

function MatchRoomItem.getOutCardTime( self )
    if not self.dataFinish then
        DebugLog("  get limit time failed, room item data is nil");
        return 0;
    end
    return self.limitOutCardTime;
end

function MatchRoomItem.dtor( self )
    self.tagArray = nil;
    EventDispatcher.getInstance():unregister(NativeManager._Event, self, self.nativeCallEvent);
    self:removeAllChildren();
end

function MatchRoomItem.nativeCallEvent(self, param, _detailData)
    if kDownloadImageOne == param then
        DebugLog("MatchRoomItem.nativeCallEvent:"..tostring(_detailData)..":"..tostring(self.showpic));
        if _detailData and _detailData == self.showpicName then
            self.bgBtn:setFile(self.showpicName);
        end
    end
end



