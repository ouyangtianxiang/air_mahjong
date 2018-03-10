DebugLog("HallScene require start : "..(os.clock() * 1000));
require("gameBase/gameScene");
require("uiex/richText");
require("MahjongHall/HallConfigDataManager");
require("MahjongHttp/HttpModule")

require("Animation/Loading");
require("MahjongCommon/Banner");
require("Animation/AnimationAwardTips");

require("MahjongData/PlayerManager");

--local girlEyesPin_map = require("qnPlist/girlEyesPin")

------------------------------------------------
require("MahjongData/Prop");
require("MahjongRoom/RoomData");
require("MahjongData/BroadcastMsgManager");

require("MahjongCommon/Banner");
require("MahjongHall/Friend/FriendDataManager");
require("MahjongData/PromptMessage");
require("MahjongCommon/SCWindow");
require("MahjongData/NativeManager");
require("MahjongCommon/new_pop_wnd_mgr");
require("MahjongLogin/LoginMethod/BoyaaLogin");
require("MahjongData/BaseInfoManager");
require("MahjongHall/Help/FeeBackData");
require("MahjongData/NetCacheDataManager");

require("MahjongSocket/NetConfig")
require("MahjongHall/Friend/MailWindow");
-------------------------------------------------------------------------
local hallBottomView = require(ViewLuaPath.."hallBottomView");
local hallTopView = require(ViewLuaPath.."hallTopView");
local hallSocialView = require(ViewLuaPath.."hallSocialView");
require("MahjongHall/HallTopLayer")
require("MahjongHall/HallBottomLayer")

require("MahjongHall/LevelChooseLayer")
local chooseLevel = require(ViewLuaPath.."chooseLevel");
require("MahjongHall/HongBao/HongBaoModel")
local panda_1_flash_map = require("qnPlist/panda_1_flash")

local panda_2_flash_map = require("qnPlist/panda_2_flash")

require("MahjongRoom/FriendMatchRoom/FMRInviteManager")
require("MahjongCommon/FirstChargeView");
local a_addRoom_map = require("qnPlist/a_addRoom")

local a_createRoom_map = require("qnPlist/a_createRoom")




DebugLog("HallScene require end : "..(os.clock() * 1000));

HallScene = class(GameScene);
require("MahjongHall/HallAnimEx")


HallScene.CONTENT_DEFAULT 			= 0 --默认主界面

HallScene.CONTENT_CHOOSE_GAME 		= 1 --选场 游戏场界面
HallScene.CONTENT_CHOOSE_MATCH 		= 2 --选场 比赛场界面

HallScene.CONTENT_USER_INFO 		= 3 --个人信息
HallScene.CONTENT_HELP		 		= 4 --帮助
HallScene.CONTENT_MALL		 		= 5 --商城
HallScene.CONTENT_ACTIVITY 			= 6 --活动
HallScene.CONTENT_TASK 				= 7 --任务
HallScene.CONTENT_RANK 				= 8 --排行榜
HallScene.CONTENT_EXCHANGE 			= 9 --兑换
HallScene.CONTENT_BOX		 		= 10 --包厢


HallScene.subWindowLevel = 100; -- 二级界面的level值定义


HallScene_instance = nil;
-----------------------------------------------------------------------------------------------------------------------
HallScene.ctor = function(self, viewConfig, state)
    new_pop_wnd_mgr.get_instance():show_loading(true);
	--g_GameMonitor:addTblToUnderMemLeakMonitor("大厅",self)

	NetConfig.getInstance()
    FMRInviteManager.getInstance()
    ItemManager.getInstance()

	--self._stayContent  = self.CONTENT_DEFAULT
	HallScene_instance = self

    --是否在大厅主界面标识--这个标记本来是要做，弹出窗口只在大厅界面显示的，后来暂时不用了，先放在这里吧
    self.m_b_hall = true;
    self.m_b_anim_enter_play = false;
    self.m_b_anim_exit_play = false;

	NativeManager.getInstance();
	self.player = PlayerManager.getInstance():myself()
	self:initView()
	--self:registersEvents()
	DebugLog("HallScene ctor");
	self:registersEvents()
	DebugLog("HallScene ctor register events over");

	if GameConstant.isFirstRun and  sys_get_string("platform") ~= "win32"  then
    	native_to_java(kCloseLoadingProe);
	end

end

HallScene.init_request_after_netcache_requeset = function (self)
    DebugLog("[HallScene]:init_request_after_netcache_requeset");
    --由于  NetCacheDataManager onRequestTimestampFinishListener每十分钟就请求一次，所以这里只需要执行一次就可以
    if GlobalDataManager.getInstance():get_hall_init_after_net_cache() then
        return;
    end
    GlobalDataManager.getInstance():set_hall_init_after_net_cache(true)

    --请求老玩家礼包
    --self:requestVeteranPlayerGift();
    --请求公告
    --GlobalDataManager.getInstance():reqest_notice();
    --请求签到
    self:requestSignWnd( true );
end

HallScene.enterAnimOver = function ( self )

	self:initLogin()

	GameConstant.isDirtPlayGame = false;
	GameConstant.curGameSceneRef = self;
	self.m_topLayer:initRequests()
	self.m_bottomLayer:initRequests()
	--self.m_socialLayer:initRequests()


	    --继续报名比赛
    self:continueApplyMatch();

	if self:traceToRoom() then
		return;
	end

	if self:inviteJoinGame() then --如果是被邀请进入房间
		return;
	end

	if self:needToQuickStart() then --如果需要快速开始
		return;
	end

	if self:needToReconnect() then -- 切换后台引起的退出房间，要重连
		return;
	end

    --退出游戏后是否进入血流，或者血战
    if self:needToLastChooseLevelLayer() then
        return;
    end

	self:showPopupWindow(); -- 返回大厅时弹窗
	

	self:playTimeMatch();
	--self:checkHotUpdate();

	--创建广播条
	if not self.myBroadcast then
		self:createBroadcastMSG();
	end
	self:playBroadcastMsg();

	self:startButtonAnim()
	--self:excutePandaAnimationLogic()

    --fps
--    if DEBUGMODE == 1 then
--        require("mahjongDebug/debugInfo")
--	    DebugInfo.getInstance():showDebugInfo()
--    end
end

function HallScene:checkIsPopEvaluateWnd(  )
    if GameConstant.iosDeviceType>0 and GameConstant.iosPingBiFee then
        return
    end
	if GameConstant.noPopEvaluate then return end
	local isPop = true
	if not GameConstant.needEvaluate then
		isPop = false
	end
	GameConstant.needEvaluate = false
	local bankruptRate = GameConstant.trumptp  --破产概率
	local outRate = GameConstant.outp          --正常退出概率
	local randomNum = math.random(1, 100)

	if (tonumber(PlayerManager.getInstance():myself().money)) < GameConstant.bankruptMoney then --破产
		if randomNum > bankruptRate then
			isPop = false
		end
	else
		if randomNum > outRate then
			isPop = false
		end
	end
	DebugLog("概率.................." .. randomNum .. ", bankruptRate:" .. bankruptRate .. ", outRate:" .. outRate .. ", isPop:" .. tostring(isPop) .. ", 主动退出：" .. tostring(GameConstant.needEvaluate))

	if not isPop then return end

	local mid = PlayerManager.getInstance():myself().mid or ""
	local isEvaluated     = g_DiskDataMgr:getUserData(mid,'isEvaluated',0)
	local evaluateTime    = g_DiskDataMgr:getUserData(mid,'evaluateTime',0)
	local evaluateVersion = g_DiskDataMgr:getUserData(mid,'evaluateVersion',0)
	DebugLog("isEvaluated:" .. tostring(isEvaluated) .. ", time:" .. tostring(evaluateTime)
		.. ", ver:" .. evaluateVersion)
   --test
   --self:popEvaluateWnd()
    local myself = PlayerManager.getInstance():myself();
    if myself.isRegister ~= 1 then
        if evaluateVersion == 0 or evaluateVersion ~= GameConstant.Version then  --该版本还没有弹出
	        self:popEvaluateWnd()
        elseif isEvaluated == 0 then  --该版本已经弹出过但是还没有去评价
	        local lastDate = os.date("*t", evaluateTime)
	        local nowDate = os.date("*t", os.time())
	        if lastDate.year ~= nowDate.year or lastDate.month ~= nowDate.month or lastDate.day ~= nowDate.day then
		        self:popEvaluateWnd()
	        end
        end
    end


end

function HallScene:popEvaluateWnd(  )
	new_pop_wnd_mgr.get_instance():add_and_show(new_pop_wnd_mgr.enum.comment)
	local mid = PlayerManager.getInstance():myself().mid or ""
	g_DiskDataMgr:setUserData(mid,'evaluateTime', os.time())
	g_DiskDataMgr:setUserData(mid,'evaluateVersion', GameConstant.Version)
	DebugLog("save evaluate time:" .. os.time() .. ", version:"
		.. GameConstant.Version .. ", evaluate mid:" .. tostring(mid))
end

HallScene.resume = function(self)

	DebugLog("HallScene resume");
	self.super.resume(self);
	-- native_to_java("initPlatform");

	if not GameConstant.isFirstRun or sys_get_string("platform") == "win32" then
		self:preEnterHallState()
		self:playEnterHallAnim(self,self.enterAnimOver)
    end


    if GameConstant.disbandTableId and GameConstant.disbandTableId ~= PlayerManager.getInstance():myself().mid then
        GameConstant.disbandTableId = nil
        Banner.getInstance():showMsg("房主已解散房间!")
    end
end

HallScene.pause = function(self)
	DebugLog("HallScene pause")
	GameScene.pause(self)
	--self:unRegisterEvents()
end

HallScene.stop = function(self)
	DebugLog("HallScene stop")
	GameScene.stop(self)
	--self:unRegisterEvents()
end

HallScene.dtor = function(self)
	self:clearSwfAnims()
	--self:stopAllAnimations()注释by振宇
    for k,v in pairs(self._animations) do
	 	v.on_stop = nil
	end

	if self.m_hallGirl then 
		self.m_hallGirl:setEventTouch()
	end 
	if self.m_more_view then 
		self.m_more_view:setEventTouch()
	end



	HallScene_instance = nil
	if self.privateBox then
		delete(self.privateBox)
		self.privateBox = nil
	end

	DebugLog("HallScene dtor")
	self:unRegisterEvents()
	showOrHide_sprite_lua(0)

	delete(self.mmWordList)
	self.mmWordList = nil
end







function HallScene.recieveHongBaoNews( self, status, data  )
	DebugLog("HallScene.recieveHongBaoNews")
	---只有在首页时才显示  其他二级界面不显示
	if status == HongBaoModel.recieveNewHongBao then

		if self.myBroadcast then
			--local x,y = self.myBroadcast:getPos()
			--if self.myBroadcast:getVisible() then
		--------------------------------------------
				if self.hongbaoEntry then
					self.hongbaoEntry:updateId(data.hongbaoId)
				else
					require("MahjongHall/HongBao/HongBaoViewUnopenHall")
					self.hongbaoEntry =  new(HongBaoViewUnopenHall,data.hongbaoId)
					self.hongbaoEntry:addToRoot()
					self.hongbaoEntry:setOnWindowHideListener( self, function( self )
						self.hongbaoEntry = nil;
					end);
				end
		------------------------------------------------------------------------------
			--end
		end
	end

end



--创建喇叭广播节点
HallScene.createBroadcastMSG = function ( self )
	if self.myBroadcast then
		return
	end

	require("Animation/BroadcastAnimation");
			--self:createBroadcastMSG();
	local w,h,x,y = 552,360,0,14--360
	if self:getLevelChooseLayer() and self:getLevelChooseLayer():getVisible() then
		w,h,x,y = 830,630,0,150--630
	end
	self.myBroadcast = new(BroadcastAnimation, w,h);
	self.myBroadcast:setAlign(kAlignTop)
	self.myBroadcast:setPos(x,y)
	self.myBroadcast:setLevel(-1)
	self.myBroadcast:getWidget().scale_at_anchor_point = true
	self.myBroadcast:getWidget().anchor = Point(0.5,0.5)
	self.m_mainView:addChild(self.myBroadcast)

	self.myBroadcast:setOnClickedCallback(self, self.OnBroadcastBtnClick)
	--self:OnBroadcastBtnClick();
	--[[
		if self.broadcastRoot:checkAddProp(0) then
			--创建好后再制作一个渐变过度动画
			local anim = self.broadcastRoot:addPropScale(0, kAnimNormal, 300, 1, 0, 1, 0, 1, kCenterDrawing);
			anim:setDebugName("broadcastViewBg");
		end
	end
	]]--
end

-- 广播条点击事件
HallScene.OnBroadcastBtnClick = function(self)

	if not self:canEnterView() then
		return;
	end

	if 1 ~= GameConstant.isDisplayBroadcast then
		GameConstant.isDisplayBroadcast = 1;
		g_DiskDataMgr:setAppData('displayBroadcastMessage',GameConstant.isDisplayBroadcast)
	end

	-- -- 友盟上报喇叭使用次数
	umengStatics_lua(kUmengHallSpeaker);
	if self.broadcastPopWin then
		self.broadcastPopWin:createMsgItem();
	else
		require("MahjongCommon/BroadcastMsgPop");
		self.broadcastPopWin = new(BroadcastMsgPop);
		self.broadcastPopWin:setLevel(1000)
		self.m_mainView:addChild(self.broadcastPopWin);
	end
end
-----------------------------------------------------------------------------------------------------------------------
-- 是否需要热更新
--function HallScene.checkHotUpdate( self )
	-- if HOTUPDATE_SWITCH == 1 then
	-- 	-- 热更新
	-- 	require( "MahjongCommon/HotUpdateManager" );
	-- 	HotUpdateManager.getInstance():checkForHotUpdate();
	-- end
--end
-- 在普通场未打牌，满足淘汰赛资格，拉入定时赛
HallScene.playTimeMatch = function ( self )
	if 1 == GameConstant.timeMatchFlag then -- 普通场拉入定时赛
		GameConstant.timeMatchFlag = 0;
		--self:stopAllAnimations()
		GameState.changeState( nil, States.MatchRoom );
	end
end


HallScene.traceToRoom = function ( self )
	if GameConstant.traceFlag then
		GameConstant.traceFlag = false;
		self:processLoginRoom();
		return true;
	end
	return false;
end

HallScene.friendDataControlled = function(self)
	DebugLog( "HallScene.friendDataControlled" );
	GameConstant.isDirtPlayGame = true;
	self:processLoginRoom();
end

-- 被邀请
function HallScene.inviteJoinGame( self )
	if GameConstant.isInvited then
		GameConstant.isInvited = false;
        self:scheduleInviteJoinGame()
		return true;
	end
	return false;
end

-------------延迟1s执行切换
------因为好友对战的房间 和 普通的房间是不同的state  从普通房间被邀请到好友对战房间 必须走room->hall->friendRoom
function HallScene:scheduleInviteJoinGame( )
    self.m_inviteAnim = new(AnimInt , kAnimNormal , 0 , 1 , 1000 , 0);--0.5s

    self.m_inviteAnim:setDebugName("AnimInt -InviteJoinGame");
    self.m_inviteAnim:setEvent(self , function ( self )

        delete(self.m_inviteAnim)
        self.m_inviteAnim = nil

        self:doJoinGame()
    end);
end

function HallScene:doJoinGame( )
    if GameConstant.tempRoomData then
        GameConstant.isDirtPlayGame = true;
        RoomData.getInstance():setChangeRoomData(GameConstant.tempRoomData);
        GameConstant.tempRoomData = nil
    end
    DebugLog(tostring(RoomData.getInstance().roomId or 0)  .."isInvitedRoomId");
    self:processLoginRoom();
end



HallScene.gotoGameRoom = function ( self , allKeys )
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
            local params = {t = RechargeTip.enum.enter_game,
                            isShow = true, roomlevel = room.level, money= room.require,
                            is_check_bankruptcy = true,
                            is_check_giftpack = true,};
            self:showQuickChargeView( params );
        end
    else
        GameConstant.isDirtPlayGame = true;
        DebugLog("LevelChooseLayer.requestQuickStartGame ##################");
        self:onGoToRoom(needShowLevel)
        return true;
    end
end

-- 是否需要快速开始游戏
function HallScene.needToQuickStart( self )
	if GameConstant.teachRoomQuickStart then
		GameConstant.teachRoomQuickStart = false;
		self:requestQuickStartGame();
		return true;
	end

	return false;
end

-- 快速进入房间
HallScene.requestQuickStartGame = function(self, key, b_ignore_recharge)
	if not self:canEnterView() then
		return false;
	end

	GameConstant.go_to_high = nil

	-- if bankruptcy
	if PlayerManager.getInstance():myself().money < GameConstant.bankruptMoney then
		GlobalDataManager.getInstance():showBankruptDlg(nil , self);
		return false;
	end

	--这里创建所有节点是为了再点击签到包的时候快速开始，及单机里点击联机，此时节点不存在导致出错。
	--self:createAllViewNode();

    if self:showAllHallData() then

        --self.typeView = HallScene.CONTENT_NONE;

        local player = PlayerManager.getInstance():myself();

	    local needRequire = 0; -- 需要展示RequireMoney
        local allHallRequire = nil;

        local curRoomType = nil --当前玩法(房间类型 血战 or 血流 or 两牌房 or)
        local needShowLevel = nil;

        	local allKeys = {}
        	allKeys[1] = "xl"
        	allKeys[2] = "xz"
            if key then
                allKeys = key
            end
        	--allKeys[3] = "lfp"
        	--mahjongPrint(allKeys)
        	local iMoney = tonumber(player.money)
        	for k,v in pairs(allKeys) do
        		if v then
        			DebugLog("find hallData by " .. v)
        			local suc,hallData = HallConfigDataManager.getInstance():returnDataByKey(v,iMoney)
        			if suc and hallData then
        				--mahjongPrint(hallData)
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
            local room = nil
            if GameConstant.upperEnterRoomLevel then
            	room = HallConfigDataManager.getInstance():returnDataByLevel( GameConstant.upperEnterRoomLevel );
            end

            if not room then
            	DebugLog("bug吧，快速开始游戏，什么场都找不到？钱也足够，照逻辑不会进这里的");
            	--取最低级场
            	local xzRooms = HallConfigDataManager.getInstance():returnHallDataForXZ()
                if key and key[1] == "xl" then
                    xzRooms = HallConfigDataManager.getInstance():returnHallDataForXL()
                end
            	room = xzRooms[#xzRooms]

            end

            if room and not b_ignore_recharge then
            	local params = {t = RechargeTip.enum.enter_game,
                                isShow = true, roomlevel = room.level, money= room.require,
                                is_check_bankruptcy = true,
                                is_check_giftpack = true,};
            	self:showQuickChargeView( params );
            end

            GameConstant.upperEnterRoomFlag = nil;
            GameConstant.upperEnterRoomLevel = nil ;
        else
            GameConstant.isDirtPlayGame = true;
            DebugLog("HallScene.requestQuickStartGame ##################");
            --self:requireEnterRoom(needShowLevel);
            self:onGoToRoom(needShowLevel)
            GameConstant.upperEnterRoomLevel = nil ;
            GameConstant.upperEnterRoomFlag = nil;
            return true;
        end
    end
    return false;
end
HallScene.jugeEnterRoom = function( self, level )

	DebugLog(tostring(level))
	local curType = HallConfigDataManager.getInstance():returnTypeForLevel( level )

	--if curType and curType >= 1 and curType <= 4 then --游戏场
		--重新绘制大厅的场次
		--if not self.m_view.ngRoomItemList or #self.m_view.ngRoomItemList <= 0 then
		--	self.m_view:createNewGameRoomItem(HallConfigDataManager.getInstance():returnHallDataForTypelist(), true);
		--end
	--end

	local roomInfo = nil;
	DebugLog( "#########level = "..level );
	roomInfo = HallConfigDataManager.getInstance():returnDataByLevel(tonumber(level));


	if not roomInfo then
		DebugLog("HallScene.jugeEnterRoom inter room failed, not room info.");
		return false;
	end
	if PlayerManager.getInstance():myself().money < GameConstant.bankruptMoney then
		GlobalDataManager.getInstance():showBankruptDlg(level,self);
		return false;
	end

	local player = PlayerManager.getInstance():myself();
	local requireMoney = roomInfo.require;
	local uppermost = roomInfo.uppermost or 0;

	if GameConstant.platformType ~= PlatformConfig.platformContest then
		if uppermost ~= 0 and player.money > uppermost then
			DebugLog("场次限额："..uppermost);
			local str = "      作为一代大虾，您怎么能在低级场欺负小盆友呢？赶快去更高级别的场次，与高手战斗吧！";
			if not self.m_upperview then
				self.m_upperview = PopuFrame.showNormalDialog( "温馨提示", str, GameConstant.curGameSceneRef, nil, nil, true, false );
				self.m_upperview:setAutoRemove( false );
			end

			self.m_upperview:setConfirmCallback(self, function ( self )
				GameConstant.upperEnterRoomFlag = roomInfo.key; -- 标记是高级场次推荐
                self:gotoHignRoomByType(curType);
				delete( self.m_upperview);
				self.m_upperview = nil;
			end);
			self.m_upperview:setCancelCallback(self, function ( self )
				delete( self.m_upperview);
				self.m_upperview = nil;
			end);

			self.m_upperview:setCloseCallback(self, function ( self )
				delete( self.m_upperview);
				self.m_upperview = nil;
			end)
			self.m_upperview:show();

			return false;
		end
	end
	if player.money < requireMoney then
		self:needMoreMoney(roomInfo);
		return false;
	end
	return true;
end

HallScene.gotoHignRoomByType = function ( self,curType )
    local keyMap = {
        "xz",
        "xz",
        "xz",
        "xl",
        "lfp",
    }
    local num = tonumber(curType) or 1
    if keyMap[num] then
        local param = {}
        table.insert(param, keyMap[num])
        self:gotoGameRoom(param)
    end

end




HallScene.needMoreMoney = function( self, roomInfo )

    local params = {t = RechargeTip.enum.enter_game,
                    isShow = true, roomlevel = roomInfo.level, money= roomInfo.require,
                    recommend = roomInfo.recommend,
                    is_check_bankruptcy = true,
                    is_check_giftpack = true,};
	RoomData.getInstance().di = roomInfo.di;
	RoomData.getInstance().level = roomInfo.level;
	self:showQuickChargeView( params );
end

--  响应时间函数
HallScene.onGoToRoom = function (self , roomLevel)
	DebugLog("HallScene.onGoToRoom")
	self:toRoom(roomLevel);
end

-- 请求进入游戏场（非包厢），进入之前进行金币判断
HallScene.toRoom = function ( self, roomLevel, lastTypeStr )
	if not self:jugeEnterRoom(roomLevel) then -- 进入房间失败
		GameConstant.isDirtPlayGame = false;
		return false;
	end
	DebugLog("HallScene.toRoom")
	local roomData = RoomData.getInstance();
	roomData:clearData(); -- 清除数据

	GameConstant.curRoomLevel = roomLevel;  --全局保存当前房间的等级

	local param = {};
	if DEBUGMODE == 1 then
		if GameConstant.customLevel ~= "" then
			param.level = GameConstant.customLevel;
		else
			param.level = roomLevel;
		end
		Banner.getInstance():showMsg("当前进入房间的level为:" .. param.level);
	else
		param.level = roomLevel;
	end
	if GameConstant.platformType == PlatformConfig.platformContest then
		param.level = roomLevel or GameConstant.contestLevel;
	end
	DebugLog("HallScene.toRoom  StateMachine.getInstance():changeState(States.NormalRoom)")
	--self:stopAllAnimations()
	StateMachine.getInstance():changeState(States.Loading,nil,States.NormalRoom);
	return true;
end


-- 是否需要重连
function HallScene.needToReconnect( self )
	if GameConstant.isNeedReconnectGame then
		GameConstant.isNeedReconnectGame = false;
		self:reconnectGame();
        --如果重连的话 清除上次进入的2级界面
        GlobalDataManager.getInstance():setChooseLayerData();
		return true;
	end

	return false;
end

--是否进入上次进入的2级界面
function HallScene.needToLastChooseLevelLayer(self)
    local chooseLayerData = GlobalDataManager.getInstance():getChooseLayerData();
    if chooseLayerData and chooseLayerData.level and chooseLayerData.level ~= -1 then--self.m_lastTypeData = {level = roomLevel, str = lastTypeStr};
        if not chooseLayerData.str or chooseLayerData.str == "-1" then
            return false;
        end
        if chooseLayerData.str == "xz" then
            self:onClickedXzdd();
            return true;
        elseif chooseLayerData.str == "xl" then
            self:onClickedXlch();
            return true;
        end
    end
    return false;
end


-- 从后台切换回来，重新连接大厅
HallScene.reconnectGame = function ( self )
	self:openHallSocketAndLogin(); -- 重新连接大厅
	DebugLog("重新连接大厅");
end


HallScene.showAllHallData = function(self)
	if not SocketManager.getInstance().m_isRoomSocketOpen then
		Banner.getInstance():showMsg("正在拼命为您连接服务器");
		self:openHallSocketAndLogin();
		return false;
	end
	local xz_roomData = HallConfigDataManager.getInstance():returnHallDataForXZ();
	local xl_roomData = HallConfigDataManager.getInstance():returnHallDataForXL();
	if not xl_roomData or not xz_roomData or #xl_roomData <= 0 or #xz_roomData <= 0 then
		Banner.getInstance():showMsg("正在拼命为您拉取大厅配置");
		-- GlobalDataManager.getInstance():OnRequestHallConfigPHP();
		NetCacheDataManager.getInstance():activeNotifyReceiver(PHP_CMD_REQUEST_NEW_HALL_CONFIG);
		return false;
	end

	return true;
end


HallScene.initLogin = function ( self )
	if self:checkIsAlreadyLogined() then

		if self.m_topLayer then
			self.m_topLayer:updateUserInfo()
		end
--		if self.m_socialLayer then
--			self.m_socialLayer:onClickedcharmBtn()
--		end
		GlobalDataManager.getInstance():requireTaskNum();

	else
		SocketManager.getInstance():openSocket();
	end
	BroadcastMsgManager.getInstance(); --初始化消息队列
end

function HallScene:checkIsAlreadyLogined()
	return SocketManager.m_isRoomSocketOpen and (PlayerManager.getInstance():myself().mid > 0)
end






-- 请求签到窗口
function HallScene.requestSignWnd( self, isAutoShow )
	DebugLog( "HallScene.requestSignWnd "  .. tostring(isAutoShow));

        if not self.signWindow then
            require("MahjongHall/Sign/NewSignWindow");
	        self.signWindow = new(NewSignWindow , self, isAutoShow, false);

            self.signWindow:setOnWindowHideListener(self, function (self)
                self.signWindow = nil;
            end);
        else
            new_pop_wnd_mgr.get_instance():add_and_show( new_pop_wnd_mgr.enum.sign );
        end


end

---MallCouponsDetailsView 签到调用
function HallScene.pushSignWindow( self )
    DebugLog("HallScene.pushSignWindow");

    if not self.signWindow then
        require("MahjongHall/Sign/NewSignWindow");
        self.signWindow = new(NewSignWindow , self, false,true);
        self.signWindow:setOnWindowHideListener(self,function ( self )
            self.signWindow = nil;
        end)
    else
        self.signWindow:showWnd();
    end

end

function HallScene.showSignWindow( self )
	DebugLog( "HallScene.showSignWindow" );
	if self.signWindow then
		self.signWindow:showWnd();
	end
end

-- 显示窗口
HallScene.showPopupWindow = function( self )
	DebugLog("HallScene.showPopupWindow")
    local myself = PlayerManager.getInstance():myself();
    if not myself.mid or myself.mid <= 0 then
        return;
    end
    if myself.isRegister == 1 then
        --如果是新注册的用户-游戏界面返回大厅界面
        if new_pop_wnd_mgr.get_instance():get_back_to_hall_actively() then
            if not  GlobalDataManager.getInstance().m_new_register.b_pop_charge then
                self:needFirstChargeData();
            end
            if not GlobalDataManager.getInstance().m_new_register.b_pop_sign then
		        self:requestSignWnd( true );
            end
        end
    else
        self:checkIsPopEvaluateWnd()   --检测是否弹评价窗口
    end
end


HallScene.initView = function ( self, status )

	showOrHide_sprite_lua(1);
    self.m_mainView 	= self:getControl( HallScene.s_controls.mainView )
    self.m_menuView 	= self:getControl( HallScene.s_controls.menuView )
	self.m_hallImg		= self:getControl( HallScene.s_controls.hallBgImg )
	self.m_hallGirl		= self:getControl( HallScene.s_controls.hallGirl ) --- 532,84
    self.m_more_view    = self:getControl( HallScene.s_controls.surfaceView )--
    self.m_more_view:setVisible(false);
    self.m_more_view:setLevel(100)

    self.m_more_view.btnView = publ_getItemFromTree(self.m_more_view, {"v_2"});
    --self.m_more_view.btn_1    = publ_getItemFromTree(self.m_more_view, {"btn_1"});
    --self.m_more_view.btn_2    = publ_getItemFromTree(self.m_more_view, {"btn_2"});
    self.m_hallGirl.originPos = {x = 500, y =0};

    self.m_more_view:setEventTouch(self , function(self, finger_action, x, y, drawing_id_first, drawing_id_current)
			if kFingerUp == finger_action then

                if self.m_more_view.is_new_touch == 1  then
                    self.m_more_view.is_new_touch = 0;
                	self.m_more_view:setVisible(false);
				    self.m_teachNode:hide();
                    if self.m_more_view.mask then
                        self.m_more_view.mask:removeFromSuper();
                        self.m_more_view.mask = nil;
                    end
				    if x >895 and x < 1240 and y > 185 and y < 300 then
					    self:onClickedQuickStartBtn()
				    end
                else
                    self:playExitMoreAnim()
                end
			end
	end );

    self.m_friend_fight = self:getControl( HallScene.s_controls.friend_fight )
    self.m_btn_addRoom = self:getControl( HallScene.s_controls.btn_addRoom );
    self.m_btn_createRoom = self:getControl( HallScene.s_controls.btn_createRoom );

    self.m_hallGirl._height = 661
	if GameConstant.iosDeviceType>0 and GameConstant.iosDeviceType==2 then
		self.m_hallGirl:addPropScaleSolid(0, 1.3, 1.3, kCenterDrawing);
		self.m_hallGirl._height = 860
	end
	--girl add anim
	self:initGirlAnim()
	--烟雾
	local scale = System.getLayoutScale();

	self.m_hallImg:setSize(System.getScreenWidth()/scale,System.getScreenHeight()/scale);

    self.m_menuView.menu1 = self:getControl( HallScene.s_controls.btn_xzdd )
    self.m_menuView.menu2 = self:getControl( HallScene.s_controls.btn_xlch )
    self.m_menuView.menu3 = self:getControl( HallScene.s_controls.btn_match )



    self.m_leftBamboo    = self:getControl( HallScene.s_controls.leftBamboo )
    self.m_rightBamboo   = self:getControl( HallScene.s_controls.rightBamBoo )
    --单机
    self.m_btn_more = self:getControl( HallScene.s_controls.btn_more );
    --self.m_btn_more:setVisible(false);

    self.m_hallImg:setLevel(0)



    self.m_leftBamboo:setLevel(3)
    self.m_rightBamboo:setLevel(3)

    self.m_hallGirl:setLevel(4)
    self.m_mainView:setLevel(10)

    self.m_btn_more:setLevel(3);



    if GameConstant.platformType == PlatformConfig.platformDingkai then
        self:showOrHideTip(false);--是否显示 提示角标
    end



	if not status then -- default status

		self.m_topLayer = new(HallTopLayer,hallTopView,self)
		if self.m_topLayer then
	    	self.m_mainView:addChild(self.m_topLayer);
	    	self.m_topLayer:setAlign(kAlignTop)
		end

		self.m_bottomLayer = new(HallBottomLayer,hallBottomView,self)
		if self.m_bottomLayer then
			self.m_mainView:addChild(self.m_bottomLayer)
			self.m_bottomLayer:setAlign(kAlignBottom)
		end


        if self.m_friend_fight then
            self.m_friend_fight:setPos(60+200,0);
        end
		--
	end

	self:preEnterHallState()
--	self:stopPlayPandaAnimation()
	if PlatformConfig.platformWDJ == GameConstant.platformType or
       PlatformConfig.platformWDJNet == GameConstant.platformType then
        self:getControl(HallScene.s_controls.btn_addRoom):setFile("Login/wdj/Hall/hallCommon/btn_addRoom.png");
        self:getControl(HallScene.s_controls.btn_createRoom):setFile("Login/wdj/Hall/hallCommon/btn_createRoom.png");
        self:getControl(HallScene.s_controls.btn_lf):setFile("Login/wdj/Hall/hallCommon/btn_lf.png");
        self:getControl(HallScene.s_controls.btn_xzdd):setFile("Login/wdj/Hall/hallCommon/btn_xzdd.png");
        self:getControl(HallScene.s_controls.btn_xlch):setFile("Login/wdj/Hall/hallCommon/btn_xlch.png");
    end

	if GameConstant.checkType == kCheckStatusOpen then
		self:addCheckTypeScene();
	else
		self:removeCheckTypeScene();
	end
	--ios 默认不显示
		if GameConstant.iosDeviceType>0  then
			if GameConstant.iosPingBiFee then
				self:addCheckTypeScene();
			end
		end


	    --添加打包日志调试时间戳
    if DEBUGMODE == 1 then
        local t = require("test_timestamp");
        if t and GameConstant.iosDeviceType==0 then
            t = tostring(t);
            self.timeNode = new(Text, t, 0, 0, kAlignLeft, "", 30, 0xff , 0xeb , 0x7e)--255,250,110); -- 黄 系统
            self.timeNode:setPos(0, 100);
            self.timeNode:setLevel(99999)
            self.m_mainView:addChild(self.timeNode)
        end

        local profileNode = require('MahjongCommon/ProfileNode')
        self.profileNode = new(profileNode)
        self.profileNode:setPos(0,80)
        self.profileNode:setLevel(99999)
        self.m_mainView:addChild(self.profileNode)
    end
end


HallScene.openHallSocketAndLogin = function (self)
	DebugLog("reconnect openHallSocketAndLogin");
	GameConstant.isReconnectGame = true;
	SocketManager.getInstance():openSocket(nil, true);
end

------
--net cache access
-- cache data manager 请求数据后回调函数
function HallScene:onCacheDataHttpListener( httpCmd, data, handleData )
	DebugLog( "HallScene:onCacheDataHttpListener httpCmd = "..httpCmd );
	mahjongPrint(data);

	local isSuccess = (data ~= nil);
	if self.cacheDataHttpCallBackFuncMap[httpCmd] then
		self.cacheDataHttpCallBackFuncMap[httpCmd]( self, isSuccess, data );
	end
end
------------------------------------------------------------------------------------------------------------------
--http access请求



HallScene.requestIsShowMobileGamer = function( self )
	--PHP_CMD_REQUEST_IS_SHOW_MOBILE_GAMER
	SocketManager.getInstance():sendPack(PHP_CMD_REQUEST_IS_SHOW_MOBILE_GAMER, nil);
end

--http事件处理
--请求活动地址响应
HallScene.requestActivityUrlCallback = function ( self, isSuccess, data )
	log( "HallScene.requestActivityUrlCallback" );
	-- body
	if not isSuccess or not data or not data.data then
		return ;
	end

	if not data.status or data.status ~= 1 then
		return ;
	end

	PlatformConfig.ACTIVITY_URL = data.data.listurl or "";
	PlatformConfig.PUSH_URL 	= data.data.numPushurl or "";
	--得到气泡的地址，获取活动数目
	-- GlobalDataManager.getInstance():requireGetActivityNum();
end



HallScene.uploadGeTuiCid = function(self,isSuccess,data)
	if isSuccess then
		if data.status then
			-- Banner.getInstance():showMsg("PHP记录个推ID成功!");
		end
		return;
	end
	self:requestGeTuiPHP();
end

HallScene.requestPrivateDiZhuList = function (self)
	if #GameConstant.privateDiZhuList > 0 then -- 低注已经拉取成功
		return;
	end
	local param_data = {};
	param_data.mid = self.player.mid;
	param_data.sitemid = SystemGetSitemid();
	if param_data.mid and tonumber(param_data.mid) ~= 0 then
		SocketManager.getInstance():sendPack(PHP_CMD_REQUEST_PRIVATE_DI_ZHU_LIST, param_data);
	end
end


HallScene.requestPrivateDiZhuListCallback = function ( self, isSuccess, data )
	if not isSuccess or not data then
		return;
	end
	if isSuccess and data then
		GameConstant.privateDiZhuList = {};
		GameConstant.privateLFPDiZhuList = {};
		if not data.status then
			for k, v in pairs(data) do
				local temp = {};
				temp.di = tonumber(v.basechip or 0);
				temp.XZRequire = tonumber(v.xzrequire or 0);
				temp.XLRequire = tonumber(v.require or 0);
				if temp.di > 0 then
					table.insert(GameConstant.privateDiZhuList , temp);
				end
			end
		elseif 1 == (data.status or 0) then
			local antes = data.data.antes;
			if antes then
				for k, v in pairs(antes) do
					local temp = {};
					temp.di = tonumber(v.basechip or 0);
					temp.XZRequire = tonumber(v.xzrequire or 0);
					temp.XLRequire = tonumber(v.require or 0);
					if temp.di > 0 then
						table.insert(GameConstant.privateDiZhuList , temp);
					end
				end
			end

			if tonumber(data.data.antes_lfp_open) == 1 then
				local antes_lfp = data.data.antes_lfp;
				for k, v in pairs(antes_lfp) do
					local temp = {};
					temp.di = tonumber(v.basechip or 0);
					temp.XZRequire = tonumber(v.xzrequire or 0);
					temp.XLRequire = tonumber(v.require or 0);
					if temp.di > 0 then
						table.insert(GameConstant.privateLFPDiZhuList , temp);
					end
				end
			end
		end
		--有了低注后显示到创建界面
		if self.privateBox then
			self.privateBox:refreshDiZhuList();
		end
	end
end



HallScene.onPhpMsgResponse = function ( self, param, cmd, isSuccess )
	if self.phpMsgResponseCallBackFuncMap[cmd] then
		self.phpMsgResponseCallBackFuncMap[cmd](self,isSuccess,param)
	end
end

HallScene.requestIsShowMobileGamerCallBack = function( self, isSuccess, data )
	if not isSuccess or not data then
		return;
	end

	local isShow = data.data.is_show
	if 1 == tonumber(isShow) then
		GameConstant.isShowMobileGamer = true;
	else
		GameConstant.isShowMobileGamer = false;
	end

	--self:updateView( HallScene.s_cmds.recreateMainView );
end
function  HallScene.requestFirstWndAndSignWnd( self )
    DebugLog("[HallScene]:requestFirstWndAndSignWnd");
	self:needRequestSignWnd()
	self:needFirstChargeData()
end
HallScene.isNeedRequestSign = true;
-- 当需要签到数据的时候会回调该函数
function HallScene.needRequestSignWnd( self )
	DebugLog( "HallScene.needRequestSignWnd" );
	if self.isNeedRequestSign then
		self.isNeedRequestSign = false;
		self:requestSignWnd( true );
	end
end

HallScene.isNeedRequestFirstCharge = true;
-- 当需要首冲数据的时候会回调该函数
function HallScene.needFirstChargeData( self )
    DebugLog("[HallScene]:needFirstChargeData: "..tostring(self.isNeedRequestFirstCharge));
	--获取首充大礼包配置
	if self.isNeedRequestFirstCharge then
		self.isNeedRequestFirstCharge = false;
        require("MahjongCommon/FirstChargeView");
        FirstChargeView.getInstance():requestFirstChargeData();
	end
end

-- function HallScene.updatePayConfig( self )
-- 	-- request pay configuration data
-- 	-- ###################这里不再请求，若在这里再次请求一次缓存，则极有可能引起stackoverflow问题
-- 	-- TrunkPayManager.getInstance():requestPayConfig();
-- end

HallScene.requestGeTuiPHP = function(self)
	local param = {};
	param.clientId  = GameConstant.GeTuiClientId;
	param.mid 	    = self.player.mid;
	param.version   = GameConstant.Version;
	param.api 		= GameConstant.api
	SocketManager.getInstance():sendPack(PHP_CMD_UPLOAD_GE_TUI_CID, param);
end

HallScene.requestActivityNeed = function ( self )
	if GameConstant.iosDeviceType>0  then
	local param = {};
	param.url = GameConstant.CommonUrl.."?m=iphoneactivity&p=getactivity";
	native_to_java("initWebView",json.encode(param));
	else
	local param = {};
	param.mid = PlayerManager.getInstance():myself().mid;
	param.version = GameConstant.Version;
	param.api = tostring(GameConstant.api)
	param.appid = GameConstant.appid;
	param.sitemid = PlayerManager.getInstance():myself().sitemid;
	param.userType = PlatformFactory.curPlatform.curLoginType or "1";
	param.imei = GameConstant.imei2;
	param.socket = NetConfig.getInstance():getCurSocketType() - 1;
	native_to_java("initWebView",json.encode(param));
	end
end



function HallScene:requestCacheData()
    DebugLog("[HallScene]:requestCacheData");
	-- 请求数据强确保receiver都在，否则收不到数据
	require("MahjongPay/SecondConfirmWnd");

	SecondConfirmWnd.getInstance();
	ProductManager.getInstance();

	self.isNeedRequestSign = true;
	self.isNeedRequestFirstCharge = true;
	-- 请求刷新时间戳
	NetCacheDataManager.getInstance():requestRefreshTimeOnLiginFinish();
end



--登录回调
HallScene.requestLoginCallBack = function ( self, isSuccess, data )
	DebugLog("HallScene.requestLoginCallBack ")
	if GameConstant.iosDeviceType>0 then
		if data then
			local extreatable = {};
			extreatable.data = data;
			extreatable.url = GameConstant.CommonUrl;
			native_to_java("LoginSuccessCallBack",json.encode(extreatable));
		end
	end
	if self:showBanInfoWnd( data ) then---------------------账号是否被封
		DebugLog("账号被封啦！")
		return;
	end


	require("MahjongData/ProductManager");
	-- 清除一次更新缓存的数据
	GlobalDataManager.updateInfoBuffer = nil;


	Loading.hideLoadingAnim();

	if isSuccess and data then
		if kNumOne == GetNumFromJsonTable(data,kStatus) then
			-- 如果是移动基地就请求是否显示游戏玩家活动入口
			if GameConstant.platformType == PlatformConfig.platformMobile then
				self.m_bottomLayer:requestIsShowMobileGamer();
			end
			--标记为已登陆
			GameConstant.isLogin = kAlreadyLogin;
			--debug版本显示域名
			if 1 == DEBUGMODE then
				-- Banner.getInstance():showMsg("【当前使用域名】" .. GameConstant.CommonUrl);
			end
			--设置自己的信息
			self.player:initPhpUserData(data.userinfo);
            native_to_java("native_reportMid", json.encode(data.userinfo))

			--设置是否显示喇叭的用户信息
			if self.player.isRegister == 1 then
				GameConstant.isDisplayBroadcast = 0;
			else
				GameConstant.isDisplayBroadcast = g_DiskDataMgr:getAppData('displayBroadcastMessage',1)
			end
			g_DiskDataMgr:setAppData('displayBroadcastMessage',GameConstant.isDisplayBroadcast)
			g_DiskDataMgr:setAppData(kLastLoginType, GameConstant.lastLoginType)

			local socketType = NetConfig.getInstance():getCurSocketType()
			local photoKey = "uploadHeadIconName" .. tostring(PlatformFactory.curPlatform:getCurrentLoginType())..tostring(socketType)
			GameConstant.uploadHeadIconName = g_DiskDataMgr:getAppData(photoKey,'')
			DebugLog("-----------------key:"..photoKey..",value:"..GameConstant.uploadHeadIconName)
			--
			if data.userinfo.openBoundMsg then
				local openBoundMsg = data.userinfo.openBoundMsg
				if openBoundMsg and string.len(openBoundMsg) > 0 then
					Banner.getInstance():showMsg(openBoundMsg);
				end
			end
			--是否需要显示新手教程
			if self.player.isRegister == 1 then
				-- 新手第一次返回大厅显示首冲
				GameConstant.showFreshmanFirstCharge = 1;
			end

			-- 清除所有窗口
			new_pop_wnd_mgr.get_instance():clear_wnd_list();

			local isNeed = self:showIsNeedTeach();
			GameConstant.isNeedShowFirstCharge = isNeed;

			if PlatformConfig.platformYiXin ~= GameConstant.platformType then
				checkWechatInstalled();
			end


			--请求道具列表
			GlobalDataManager.getInstance():onRequestMyItemList();

			--获取玩家VIP信息
			GlobalDataManager.getInstance():getMyVipInfo();

			--请求已完成的任务数目
			GlobalDataManager.getInstance():requireTaskNum();

			GlobalDataManager.getInstance():requestTrumpetMessage()

			GlobalDataManager.getInstance():getPayConfig();
			if GameConstant.iosDeviceType > 0 then 
                NetCacheDataRequester:getProductProxy(); 
            end
--			--请求系统消息
			GlobalDataManager.getInstance():requestSystemMessage()
			--请求活动相关信息
			self:requestActivityNeed();
            --拉取推荐信息
            GlobalDataManager.getInstance():getTuiJianProduct();

            g_DiskDataMgr:setAppData(kLocalToken..GameConstant.lastLoginType, data.userinfo.localtoken or "")
            g_DiskDataMgr:setAppData(kIsAdultVerify, kNumMinusOne)
            g_DiskDataMgr:setAppData(kMid, self.player.mid)

            DebugLog("HallScene.requestLoginCallBack is_pone:"..tostring((data.is_phone or -1)));
			--设置绑定
            if  GlobalDataManager.getInstance():getIsCellAcccountLogin() == false then
                local is_phone = tonumber(data.is_phone or 0);
                GlobalDataManager.getInstance():setBindCellAcccount(is_phone);
                --保存 绑定的手机号码
                GlobalDataManager.getInstance():setCellBindAccount(is_phone > 0 and tostring(is_phone) or "");
            end


			-- 请求大厅配置、破产配置、商品列表、推荐列表、主版本支付方式、首冲、更新、公告、IP和PORT
			DebugLog("HallSocialLayer.requestData")
			-- --读取历史动态数量
			FriendDataManager.getInstance():loadFriendNews(PlayerManager.getInstance():myself().mid);
			--接取好友动态数量
			FriendDataManager.getInstance():requestFriendNewsNum();
			--拉取好友列表
			FriendDataManager.getInstance():requestAllFriends();

            --请求更新信息
            GlobalDataManager.getInstance():requestUpdateVersionInfo(0);
            --请求老玩家礼包
            self:requestVeteranPlayerGift();

            

			--检查是否需要下载
			self.m_topLayer:checkForResDownload();
			showOrHide_sprite_lua(1);
			-- self:initHuTuiSdk();

			--上报个推ID
			if GameConstant.GeTuiClientId then
				self:requestGeTuiPHP();
			end

			local isAdultVerify = g_DiskDataMgr:getAppData(kIsAdultVerify, kNumMinusTwo)
			local mid           = g_DiskDataMgr:getAppData(kMid,kNumZero) 
			--重装游戏没有map或者就是之前认证失败
			if kNumMinusTwo == isAdultVerify or kNumMinusOne == isAdultVerify or mid ~= self.player.mid then
				if kNumZero == tonumber(self.player.isAdult) or kNumOne == tonumber(self.player.isAdult) then
					DebugLog("已经认证过,无需再认证");
					GameConstant.isAdult = tonumber(self.player.isAdult);
					g_DiskDataMgr:setAppData(kIsAdultVerify,self.player.isAdult)
					g_DiskDataMgr:setAppData(kMid,self.player.mid)
				end
			elseif (kNumOne == isAdultVerify or kNumZero == isAdultVerify) and (mid == self.player.mid) then
				DebugLog("已经认证过，无需再认证");
			end

			--只有登录时才去请求，其它时间有更新由server推送
			--self:requestFeeBackTipNum();
			self.m_topLayer:requestData()

			-- 请求动态配置
			BaseInfoManager.getInstance():requestConfig();

			-- 请求缓存数据
			self:requestCacheData();

			-- 设置本地推送
			self:setLocalPush();

			-- 请求比赛场配置
			GlobalDataManager.getInstance():requestMatchConfig();

			--弹出新手指引
			self:loginSuccess()

			SocketManager.getInstance():sendPack(PHP_CMD_REQUIRE_WEB_PAY, {} );

			GlobalDataManager.getInstance():requestFriendMatchConfig()
			GlobalDataManager.getInstance():requestVoiceConfig()

            local t = tonumber(GlobalDataManager.getInstance().m_enter_data.type) or 1 ;
            if t == 1 then
                self:checkNeedGotoFMR()
            elseif t == 2 then
                self:check_to_match()
            end

            if PlatformConfig.platformOPPO == GameConstant.platformType then
                -- self:checkVipExpTime();
                GlobalDataManager.getInstance():checkVipExpTime();
                self.m_topLayer:toRequestOppoOnlineTime();
            end


            if self.mmWordList then
            	self.mmWordList:requestConfig()
            end
		else
			---请求未登录公告
			GlobalDataManager.getInstance():requestUnLoginNoticeInfo()
			-----
			SocketManager.getInstance():syncClose();
			-- 重新显示登录框
			self:clickChangeLoginMethod();
		end
        self.m_topLayer:updateUserInfo(self.player);
        new_pop_wnd_mgr.get_instance():show_loading(false);
	end
end
---------------------------------------------------------------------------------------------------------------------------------------
--socket access事件处理
HallScene.onSocketPackEvent = function ( self, param, cmd )
	if self.socketEventFuncMap[cmd] then
		DebugLog("HallScene deal socket cmd "..cmd);
		self.socketEventFuncMap[cmd](self, param);
	end
end


--------创建私人房失败错误码-------
HallScene.xl= 0x1;  -----没有血流卡
HallScene.hsz= 0x2; ---没有换三张卡
HallScene.lw= 0x4;  ---没有两万卡
HallScene.ww= 0x8;  --没有五万卡
HallScene.fcm= 0x10; --防沉迷创建失败

HallScene.createPrivateRoom = function ( self, t )
	if 1 == t.result then
		local rd = RoomData.getInstance();
		rd.roomIp = t.ip;
		rd.roomPort = t.port;
		rd.roomId = t.roomID;
		rd.fan = t.baseChip;
		--rd.playType = t.playType;
		rd:setPlayType(t.playType)
		rd.isSwapCard = t.isSwap;
		rd:setInFetionRoom(tonumber(t.inFetionRoom));
		rd:setPrivateRoomInfo(tonumber(t.baseChip)); -- 设置私人房间数据
		self:processLoginRoom();
		--GlobalDataManager.getInstance():onRequestMyItemList(); -- 重新拉取卡片
	elseif 0 == t.result then
		local reason = t.reason;
		local msg=" ";
		if bit.band(reason,self.xl)==self.xl then
			msg = GameString.convert2Platform("您没有血流卡");
		elseif bit.band(reason,self.hsz)==self.hsz then
			msg = GameString.convert2Platform("您没有换三张卡");
		elseif bit.band(reason,self.lw)==self.lw then
			msg = GameString.convert2Platform("您没有两万卡");
		elseif bit.band(reason,self.ww)==self.ww then
			msg = GameString.convert2Platform("您没有五万卡");
		elseif bit.band(reason,self.fcm) == self.fcm then
			msg = GameString.convert2Platform("你现在处于防沉迷状态，不能创建房间");
		else
			msg = "创建房间失败";
		end
		Banner.getInstance():showMsg(msg);
	end
end

HallScene.OPERATE_FAILED = 0
HallScene.OPERATE_SUCCESS = 1
HallScene.ERROR_ROOM_NOT_EXIST = 1
HallScene.ERROR_MAX_USERCOUNT = 2
HallScene.ERROR_PASSWORD = 3

HallScene.enterPrivateRoom = function ( self, data )
	if data.result == self.OPERATE_FAILED then
		if data.errorCode == self.ERROR_ROOM_NOT_EXIST then
			-- DebugLog("  =   HallScene.ERROR_ROOM_NOT_EXIST ====");
			Banner.getInstance():showMsg(GameString.convert2Platform("房间不存在！"));
			self:requestPrivateRoomList(); -- 刷新一次
		elseif data.errorCode == self.ERROR_MAX_USERCOUNT then
			-- DebugLog("  =   HallScene.ERROR_MAX_USERCOUNT ==== ");
			Banner.getInstance():showMsg(GameString.convert2Platform("房间玩家已满！"));
			self:requestPrivateRoomList(); -- 刷新一次
		elseif data.errorCode == self.ERROR_PASSWORD then
			-- DebugLog("  =   HallScene.ERROR_PASSWORD ==== ");
			Banner.getInstance():showMsg(GameString.convert2Platform("密码错误！"));
		else
			Banner.getInstance():showMsg(GameString.convert2Platform("进入房间失败！"));
		end
	else
		data.isInGame = 1;
		-- 进入房间
		RoomData.getInstance():setRoomAddr(data);
		--self:stopAllAnimations()
		StateMachine.getInstance():changeState(States.Loading,nil,States.NormalRoom);

	end
	return t;
end


function HallScene:checkNeedGotoFMR( )
    DebugLog("HallScene:checkNeedGotoFMR:fid:"..tostring(GlobalDataManager.getInstance().m_enter_data.fid))
    if not self:canEnterView() then
        return;
    end
	local fid        = GlobalDataManager.getInstance().m_enter_data.fid--GameConstant.fid
    GlobalDataManager.getInstance().m_enter_data.fid = nil
	if not fid then
		return
	end
	DebugLog("1HallScene:checkNeedGotoFMR:fid:"..tostring(fid))

    --require("MahjongRoom/FriendMatchRoom/FMRInviteManager")
    FMRInviteManager.getInstance():queryCanEnterRoom( tonumber(fid),
                                 FMRInviteManager.INVITE_FROM_HALL ,
                                                               self,
                                          self.onJoinSuccedCallback,
                                          self.onJoinFailedCallback )

end

--根据外面传入的参数进入比赛
HallScene.check_to_match = function (self)
    DebugLog("[HallScene]:check_to_match");
    if not self:canEnterView() then
        return;
    end

    local t = GlobalDataManager.getInstance().m_enter_data.type;
    local fid =  GlobalDataManager.getInstance().m_enter_data.fid
    local level =  tonumber(GlobalDataManager.getInstance().m_enter_data.level) or 0
    local matchType =  tonumber(GlobalDataManager.getInstance().m_enter_data.matchType) or 0

    GlobalDataManager.getInstance().m_enter_data = {};

    DebugLog("type:"..tostring(t));
    DebugLog("fid:"..tostring(fid));
    DebugLog("level:"..tostring(level));
    DebugLog("matchType:"..tostring(matchType));



    if not level or not matchType then
        return;
    end

    self:onGoToMatchRoom(level, matchType );


end

function HallScene:joinFriendMatchRoomRequest( fid )
    if (type(fid) == "string" and string.len(fid) == 6) or ( type(fid) == "number" and fid >99999 and fid < 1000000) then
        local param = {};
        local player = PlayerManager.getInstance():myself();
        local uesrInfo = player:getUserData();

        local config = GlobalDataManager.getInstance().fmRoomConfig
        param.level     = config.level --or 20;
        param.money     = player.money;
        param.userInfo  = json.encode(uesrInfo);
        param.mtk       = player.mtkey;
        param.from      = player.api;
        param.version   = 1;
        param.versionName     = GameConstant.Version;
        --param.changeTableFlag = changeTableFlag;

        param.roomNum   = tonumber(fid) or 0
        param.isJoinRoom = true
        RoomData.getInstance():setPrivateRoomData(param);
        --self:stopAllAnimations()
        StateMachine.getInstance():changeState(States.Loading,nil,States.FriendMatchRoom);
    end

end
--[[
	function name	   : HallScene.fcmNotify
	description  	   : 防沉迷信息返回.
	param 	 	 	   : self
	last-modified-date : Dec. 16 2013
	create-time  	   : Nov. 6  2013
]]
HallScene.fcmNotify = function(self,data)
	DebugLog("防沉迷返回");
	local isT = data.isT;
	local isWhyStr = data.isWhyStr;
	local playerGameTime = data.playerGameTime;
	local surplusTime = data.surplusTime;
	local confirmText;

	playerGameTime = math.floor(playerGameTime/kNumOneHourSecond);
	surplusTime = math.floor(surplusTime/kNumOneHourSecond);

	confirmText =CreatingViewUsingData.commonData.certainText;

	if tonumber(isT) == kNumOne then
		--self:exitGame();
		confirmText = CreatingViewUsingData.avoidWallowView.knowText;
	end

	if isWhyStr == nil or isWhyStr == kNullStringStr  then
		isWhyStr=string.format(CreatingViewUsingData.avoidWallowView.fcmMessage,playerGameTime,playerGameTime,surplusTime);
	end

	local view = PopuFrame.showNormalDialogForCenter( CreatingViewUsingData.avoidWallowView.fcmTitle, content,self, nil, nil, true);
	view.confirmBtn:setText(confirmText);
	view:setNotOnClickFeeling(true);
	if view then
		view:setCallback(view, function ( view, isShow )
			if not isShow then
				
			end
		end);
	end
end


HallScene.kickOut = function (self)
	self.player.mid = 0;
	self.player.nickName = "";
	if self.m_topLayer then
		self.m_topLayer:updateUserInfo(self.player)
	end
--	if self.m_socialLayer then
--		self.m_socialLayer:clearViews()
--	end
	--self:updateView( HallScene.s_cmds.updataUserInfo, self.player );
	SocketManager.getInstance():syncClose();
	Banner.getInstance():showMsg("对不起，您的帐号在异地登录，请重新登录");
end

HallScene.broadcastSystemConMsg = function (self , data)
	if not data then
		return;
	end
	Banner.getInstance():showMsg(tostring(data.sysMsg));
end


HallScene.serverNoticeMsg = function (self , data)
	if not data then
		return;
	end
	local title = data.title or "温馨提示";
	local content = data.msg or "";
    local state = tonumber(data.state) or 0 --比赛淘汰温馨提示框，小框；
	local view = PopuFrame.showNormalDialogForCenter(title, content,nil, nil, nil, true, state == 3 and false or true);
	if view then
		view:setConfirmCallback(view, function ( view, isShow )
			if not isShow then
				
                if HallScene_instance.quitPopWin and state == 3 then
                    HallScene_instance.quitPopWin:onClickBackToHallBtn();
                    HallScene_instance.quitPopWin:hideWnd();
                end
			end
		end);
	end
end

HallScene.serverRetiredReconnected = function ( self )
	SocketManager.getInstance():openSocket()
end


HallScene.requestPrivateRoomList = function ( self )
	DebugLog("HallScene.requestPrivateRoomList")
	local data = {};
	data.liangFangPaiFlag = 2;
	SocketManager.getInstance():sendPack( CMD_CLIENT_LIST_PRIVATE_ROOM3, data );
end


HallScene.getPrivateRoomList = function(self, data)
	DebugLog("HallScene.getPrivateRoomList ")
	if not data then
		return;
	end

	self.privateRoomData = data or {};
	table.sort(self.privateRoomData, function(s1, s2)
		if s1.baseChip > s2.baseChip then
			return true;
		end
		return false;
	end )
	if self.privateBox then
		self.privateBox:createPrivateRoomListView(self.privateBox:parsePrivateRoomData(self.privateRoomData));
	end
end



-- 点击包厢列表，进入包厢
HallScene.onHallClick = function(self, data)
    --现在没有包厢了，注释
--	local requireMoney,requireVip = getHallConfigRequireMoneyByLevel(GameConfig.privateRoomLevel, data.baseChip, data.playType);
--	RoomData.getInstance():setPrivateRoomInfo(tonumber(data.baseChip));
--	-- 设置私人房间数据
--	RoomData.getInstance().requireMoney = requireMoney;
--	local player = PlayerManager.getInstance():myself();
--	if player.money < GameConstant.bankruptMoney then
--		--globalShowBankruptcyDlg(GameConfig.privateRoomLevel);
--		GlobalDataManager.getInstance():showBankruptDlg(GameConfig.privateRoomLevel,self);
--		GameConstant.isDirtPlayGame = false;
--		return;
--	end

--	if player.money < requireMoney then
--		RoomData.getInstance().baseChip = data.baseChip;
--		RoomData.getInstance().level = GameConfig.privateRoomLevel;

--        local params = {t = RechargeTip.enum.enter_game,
--                        isShow = true, roomlevel = GameConfig.privateRoomLevel, money= requireMoney,
--                        is_check_bankruptcy = false,
--                        is_check_giftpack = false,};
--		self:showQuickChargeView( params );
--		return;
--	end
--	if requireVip and requireVip ~= 0 and player.vipLevel <= requireVip then
-- 		local msg = "VIP等级不足,无法进入该房间！";
--  		Banner.getInstance():showMsg(msg);
-- 		return;
--	end
--	if data.hasPassWord ~= 0 then
--		-- 有密码
--		data.inputpassWord = nil;
--		self:showInputPasswordWindow(data);
--		return;
--	end
--	GameConstant.isDirtPlayGame = false;
--	self:requestLoginPrivateRoom(data)

end

HallScene.showInputPasswordWindow = function(self, data)
	require("MahjongHall/Box/InputPswWindow");

	if self.inputPswWindow then
		self.m_root:removeChild(self.inputPswWindow, true);
		self.inputPswWindow = nil;
	end
	if not self.inputPswWindow then
		self.inputPswWindow = new(InputPswWindow);
		self.inputPswWindow:setConfirmCallback(self, function(self, psw)
			data.inputpassWord = psw;
			self:requestLoginPrivateRoom(data)
			--self:requestCtrlCmd(HallController.s_cmds.requestLoginPrivateRoom, data);
		end );
		-- self.inputPswWindow:setPos(200, 100);
		self.m_root:addChild(self.inputPswWindow);
	end
	self.inputPswWindow:show();
end



HallScene.requestLoginPrivateRoom = function ( self, data )
	local param = {};
	param.roomid = data.roomId;
	RoomData.getInstance().roomId = data.roomId; -- 给房间id赋值
	param.password = data.inputpassWord or "";
	SocketSender.getInstance():send( CMD_CLIENT_ENTER_PRIVATE_ROOM, param);
end

HallScene.quickEnterLFP = function(self)
	local curMoney = PlayerManager.getInstance():myself().money
	local lfp_data = HallConfigDataManager.getInstance():returnLFPData(curMoney);
	if lfp_data then
		self:onGoToRoom(lfp_data.level)
		--self:requireEnterRoom(lfp_data.level);
	else
		local data = HallConfigDataManager.getInstance():returnMinHallDataForLFP()
		if data then
			DebugLog("data.require: " .. tostring(data.require))
			DebugLog("data.level: " .. tostring(data.level))

            local params = {t = RechargeTip.enum.enter_game,
                            isShow = true, roomlevel = data.level, money= data.require,
                            is_check_bankruptcy = true,
                            is_check_giftpack = true,};
			self:showQuickChargeView( params );
		end
	end
end

HallScene.logOutSuccess = function ( self )
	if  RoomData.getInstance().roomId then
		-- 注意：这个命令在登出之后再次重新登录时，会返回一次，这时候要重新发送登录命令
		self:processLoginRoom();
	end
end

-- socket回调 服务器回应进入游戏请求
HallScene.joinGameRet = function (self , data)
	if data and data.ip and 0 < data.port and 0 < data.roomId then
		RoomData.getInstance():setRoomAddr(data);
		self:processLoginRoom();
	else
		Banner.getInstance():showMsg("对不起，进入房间失败，请稍后重试！");
		GameConstant.isDirtPlayGame = false;
	end
end

HallScene.showApplyWindow = function(self, data,roomlevel)
	DebugLog("HallScene.showApplyWindow")
	require("MatchApply/MatchApplyWindow");

	if self.myBroadcast then
		self.myBroadcast:removeFromSuper()
		self.myBroadcast = nil;
		BroadcastMsgManager.getInstance():push();
	end

	self.matchApplyWindow = new(MatchApplyWindow, data,roomlevel);
	self.matchApplyWindow:setCloseCallBack(self, function()
		if self.m_mainView:getChildren(self.matchApplyWindow) then
			self.m_mainView:removeChild(self.matchApplyWindow);
			delete(self.matchApplyWindow);
		end
        self.matchApplyWindow = nil;

		self:getLevelChooseLayer():setRoomType(2)
		self:getLevelChooseLayer():setVisible(true)

		self:setLevelChooseViewState()

		self:showMatchWindow()

		--有还未播放的广播则继续播放
		self:playBroadcastMsg();

        Clock.instance():schedule_once(function()
            if HallScene_instance and not self.matchApplyWindow and not self.myBroadcast then
			    self:createBroadcastMSG();
		    end
        end,1)
	end);

	self.m_mainView:addChild(self.matchApplyWindow);
	self.matchApplyWindow:setLevel(HallScene.subWindowLevel);
	self.matchApplyWindow:show();
	--报名界面显示出来后应该隐藏掉比赛场选场界面，以免报名界面和选场界面共存
	if self:getLevelChooseLayer() and self:getLevelChooseLayer():getVisible() then
		self:getLevelChooseLayer():setVisible(false);
	end
end



HallScene.setAnimOverView = function ( self )
	DebugLog("HallScene.setAnimOverView")
	--self:stopAllSceneAnim()



	if self.m_topLayer then
		self.m_topLayer:setVisible(true)
		self.m_topLayer:setPos(0,0)
		self.m_topLayer:viewInHallMain()
	end

	if self.m_bottomLayer then
		self.m_bottomLayer:setVisible(true)
		self.m_bottomLayer:setPos(0,0)--bottom
	end

    if self.m_friend_fight then
        self.m_friend_fight:setVisible(true)
        self.m_friend_fight:setPos(60,0);
    end

	if self.m_hallGirl then
		self.m_hallGirl:setVisible(true)
		self.m_hallGirl:setPos( self.m_hallGirl.originPos.x, self.m_hallGirl.originPos.y) --bottom left
	end

	if self.m_hallImg then
		self.m_hallImg:setFile("Hall/hallComon/hallBgMid.jpg")
		DebugLog("removeEffect")
		if self.m_hallImg.resResultId ~= nil and self.m_hallImg.finalizer ~= nil then
			Blur.removeLastRes(self.m_hallImg.resResultId,self.m_hallImg.finalizer)
			self.m_hallImg.resResultId = nil
			self.m_hallImg.finalizer   = nil
		end
		local common = require("libEffect/shaders/common")
		common.removeEffect(self.m_hallImg)
	end

	if self:getLevelChooseLayer() then
		self:getLevelChooseLayer():setVisible(false)
	end

	if self.myBroadcast then
		self.myBroadcast:setPos(0,14)
		self.myBroadcast:resetSize( 552,360)
		self.myBroadcast:setVisible(true)
	end

	if self.m_menuView then
		self.m_menuView:setPos(60,0)
		self.m_menuView:setVisible(true)
	end

    if self.m_btn_more then
        self.m_btn_more:setVisible(true);
        self.m_btn_more:setPos(0,0)	
    end
end


--是否显示比赛场界面
HallScene.showMatchWindow = function(self)

	if not SocketManager.getInstance().m_isRoomSocketOpen then
		Banner.getInstance():showMsg("正在拼命为您连接服务器");
		self:openHallSocketAndLogin();
		return false;
	end
	if not self:showMatchRoomListItem() then
		Banner.getInstance():showMsg("正在拼命为您拉取比赛配置");
		self:openHallSocketAndLogin();
		return false;
	end


	--self:showMatchRoomListItem();
	return true;
end

--是否显示比赛场配置信息
HallScene.showMatchRoomListItem = function(self)
	local matchRoomData = HallConfigDataManager.getInstance():returnMatchData();
	--self:updateView( HallScene.s_cmds.createMatchRoomItem, matchRoomData); --绘制房间item信息
	if matchRoomData and #matchRoomData > 0 then

		return true;
	else
		GlobalDataManager.getInstance():requestMatchConfig();
	end
	return false;
end

-- 比赛列表或比赛奖励有更新时推送
HallScene.phpNotice = function ( self, data )
    if not data then
        return;
    end
    DebugLog("ttttt HallScene.phpNotice")
    if data.cmdRequest == SERVER_MATCHLIST_RES or data.cmdRequest == SERVER_MATCHLIST_TIME_RES then -- 比赛场次列表
        --获取比赛场次配置
        local tmp = json.mahjong_decode_node(data.info);
        if 1 == data.perationType then
            DebugLog("add");
            HallConfigDataManager.getInstance():addMatchList(tmp);
        elseif 2 == data.perationType then
            HallConfigDataManager.getInstance():deleteMatchList(data.perationId);
            DebugLog("delet");
        elseif 3 == data.perationType then
            DebugLog("change");
            HallConfigDataManager.getInstance():deleteMatchList(data.perationId);
            HallConfigDataManager.getInstance():addMatchList(tmp);
        end


	    if HallScene.CONTENT_PLAYSPACE_GAME == GameConstant.HallViewType then
	    	self:showMatchWindow();
	    end
    elseif data.cmdRequest == SERVER_MATCHAWARD_RES then  -- 比赛描述
    	if self.matchApplyWindow then
	        if data.perationId == self.matchApplyWindow.id then
	            self.matchApplyWindow.desUpdateFlag = true;
	        end
	    end
	elseif data.cmdRequest == SERVER_MAIL_SYS_CANCEL then --- 邮件撤销消息
		local playeId = PlayerManager.getInstance():myself().mid
		local msgId   = data.msgId
		local data    = GlobalDataManager.getInstance().systemData
		SystemMessageData.deleteMsgById(playeId,msgId,data)
		EventDispatcher.getInstance():dispatch(MailWindow.updateSystemListView);
    end
end

HallScene.receiveMatchSignUpRes = function ( self, data )
--matchApplyWindow里都没有这个方法，谢谢，注释
--	if self.matchApplyWindow then
--		self.matchApplyWindow:receiveMatchSignUpRes(data);
--	end
end

--玩家报名参加比赛结果回调
HallScene.serverSingUpMatchReceived = function(self, data)
--    MATCH_READY = 1,               //报名
--    MATCH_YUSAI = 2,               //人满赛预赛
--    MATCH_TAOTAISAI = 3,           //淘汰赛：人满赛 定时赛
--    MATCH_JUESAI = 4,              //决赛：人满赛 定时赛
--    MATCH_STOP  = 5,               //结束：人满赛 定时赛
--    MATCH_ER_START=7,              //二人的比赛阶段
--    MATCH_DINGSHI_YUSAI = 8,        //定时赛预赛
--    MATCH_DINGSHI_PAIMING = 9,     //定时赛排名阶段
	if not data then
		Banner.getInstance():showMsg("非常抱歉，您报名该比赛失败");
		log( "HallScene.serverSingUpMatchReceived" );
		return;
	end
	DebugLog("~~~~~~~~~~~~~~~~~~~~~~~~")
	mahjongPrint(data)
	if SERVER_SIGNUP_MATCH_RES == data.cmdRequest then---0x004  --玩家报名结果
		if data.result ~= 0 then
            if self.friendView then
                self.friendView:hide()
            end
			--Banner.getInstance():showMsg(data.meg);
			--进入到报名界面
			if self.matchApplyWindow then
				self.m_mainView:removeChild(self.matchApplyWindow, true);
				self.matchApplyWindow = nil;
			end

			if self.broadcastPopWin then
				self.broadcastPopWin:removeFromSuper()
				self.broadcastPopWin = nil;
			end
			self:showApplyWindow(data)
			--self:updateView( HallScene.s_cmds.showApplyWindow, data);
		else
			--报名失败
			Banner.getInstance():showMsg(data.meg);
		end
	elseif data.cmdRequest == SERVER_MATCHSTART_CLIENT then--0x005  --通知玩家比赛开始
		if self.matchApplyWindow then
			self.matchApplyWindow:toGetTableInfo(data);
            self.matchApplyWindow:auto_enter_match();
		end
    elseif data.cmdRequest == CLIENT_QUIT_MATCH_RES then--0x002  --玩家退赛结果
        --退出比赛回调
        if self.matchApplyWindow then
        	if 1 == self.traceToRoomFlag then
        		self.traceToRoomFlag = 0;
        		self:processLoginRoom();
        	else
        		self.matchApplyWindow:receiveMatchSignOut(data);
        	end
        end
    elseif data.cmdRequest == SERVER_BROADCAST_MATCH_STATUS then--0x00B  --广播现在比赛的状态
        --通知比赛是否开始，当前报名人数
        if self.matchApplyWindow then
       		self.matchApplyWindow:toUpdateJoiner(data);
            --服务器通知状态的时候，如果在大奖赛的预赛阶段，则自动进入比赛房间
            if tonumber(data.stage) == GameConstant.match_stage.dingshisai_yusai  then
                self.matchApplyWindow:auto_enter_match();
            end
       	end
    elseif data.cmdRequest == SERVER_BROADCAST_MATCH_INFO then--0x00E刷新比赛状态（绿色横条）
    	if self.matchApplyWindow then
        	self.matchApplyWindow.m_matchInfo = data;
        end
	elseif SVR_CLI_DINGSHI_PAIMING_RESULT == data.cmdRequest then--0x01F 
        -- 定时赛排名结束，广播客户端排名结果 和00f格式完全相同，用来判断排名结束 晋级或淘汰 
		if 2 == data.matchType and 3 == data.matchStage then
			if 1 == data.isTaotai then
				self:showQuitPopWin(data, true);
			else
				GameConstant.matchName = data.matchName;
				GameConstant.curRoomLevel = data.level;
				GameConstant.matchId = data.matchId;
				PlayerManager:getInstance():myself().isInGame = false;
				--self:stopAllAnimations()
	            GameState.changeState( nil, States.MatchRoom );
			end
		end
    elseif SERVER_BROADCAST_MATCH_DELAY_TO_NEXT_START == data.cmdRequest then--通知玩家比赛顺延到下个时间点开始
        if data.meg then
            Banner.getInstance():showMsg(data.meg);
        end

        if self.matchApplyWindow then
			self.m_mainView:removeChild(self.matchApplyWindow, true);
			self.matchApplyWindow = nil;
		end

		if self.broadcastPopWin then
			self.broadcastPopWin:removeFromSuper()
			self.broadcastPopWin = nil;
		end
		self:showApplyWindow(data)
    elseif CLIENT_IS_SIGNUP_MATCH_REQ == data.cmdRequest then----玩家请求报名比赛状态，如果成功Server返回报名成功SERVER_SIGNUP_MATCH_RES这个命令字

    elseif CLIENT_VIEW_MATCH_REQ == data.cmdRequest		then	          --玩家请求观看比赛，但不是报名比赛
        -- 服务器返回一个level和一个字符串
        if self.matchApplyWindow then
            self.matchApplyWindow:showServerTipWhenNoJoinGame(data.meg,data.level);
        end
	end
end

----大奖赛进入房间后，发个消息查看是否报过名
--HallScene.sendPackToServerCheckSign = function(self)

--    --发送命令进行退赛
--    local param = {};

--    param.level_0 = self.m_data.level;
--    param.param = -1;
--    param.cmdRequest = CLIENT_IS_SIGNUP_MATCH_REQ;
--    param.uid = self.myself.mid;
--    param.level = self.m_data.level;

--    SocketSender.getInstance():send( SERVER_MATCHSERVER_CMD, param);-- 退出比赛
--end

-- 认输弹窗
HallScene.showQuitPopWin = function ( self, data, hallFlag )
	if self.quitPopWin then
		self.m_mainView:removeChild(self.quitPopWin, true);
		self.quitPopWin = nil;
	end

	require("MahjongRoom/QuitPopWin");
	self.quitPopWin = new(QuitPopWin, data, self.m_mainView, hallFlag);
	self.quitPopWin:setLevel(600);
end


-- 登录大厅成功
HallScene.socketLoginSuccess = function (self , data)
	DebugLog("大厅socket重连成功  ");
    GlobalDataManager.getInstance():onRequestMyItemList();
	if GameConstant.singleToOnline then
		DebugLog("GameConstant.singleToOnline true")
		GameConstant.singleToOnline = false;
		if PlayerManager.getInstance():myself().mid < 0 then
			Banner.getInstance():showMsg("请先登录后再进行联网游戏");
		else
			DebugLog("【单机游戏】请求联网游戏");
			self:onClickedQuickStartBtn();
		end
		return;
	end
	if 1 == data.isInGame then
		GameConstant.matchChangeTableFlag = 1;
		RoomData.getInstance():setRoomAddr(data);
		self:processLoginRoom();
	end
end
-- socket的状态
HallScene.onSocketStateEvent = function (self , eventType)
	DebugLog("eventType "..eventType);
	if eventType == kSocketConnected then
		DebugLog("eventType : kSocketConnected");
	elseif eventType == kSocketReconnecting then
		DebugLog("eventType : kSocketReconnecting");
	elseif eventType == kSocketConnectivity then
		DebugLog("eventType : kSocketConnectivity");
	elseif eventType == kSocketConnectFailed then
		DebugLog("eventType : kSocketConnectFailed");
		Banner.getInstance():showMsg("网络连接失败，请检查您的网络");
		if SocketManager.getInstance().m_isRoomSocketOpening or SocketManager.getInstance().m_isRoomSocketOpen then 
			self:whenSocketClose();
		end 
	elseif eventType == kSocketRecvPacket then
		DebugLog("eventType : kSocketRecvPacket");
	elseif eventType == kSocketUserClose then
		DebugLog("eventType : kSocketUserClose");
		self:whenSocketClose();
		if GameConstant.isNeedReconnectGame then -- 切换后台引起的关闭socket事件
			GameConstant.whenResumeInHall = true;
			GameConstant.isNeedReconnectGame = false;
		end
	end
end

HallScene.whenSocketClose = function (self)
	GameConstant.HallViewType = nil
	SocketManager.m_isRoomSocketOpening = false
	SocketManager.m_isRoomSocketOpen = false

	--self:showHallWindowViewType()
	self.m_topLayer:updateUserInfo(self.player)
	self:removeMatchApply()

	--关闭所有弹窗,除了登录窗口
	local hasLoginView = false
	if self.m_mainView:getChildByName("login_view") then
		hasLoginView = true
	end

	self:closeAllPopuWnd()

	if hasLoginView then
		self:addLoginView()
	end
end


-- 从房间退回大厅时应该显示的界面
HallScene.showHallWindowViewType = function(self)
	--self:anim
end

HallScene.friendDataControlled = function(self)
	DebugLog( "HallScene.friendDataControlled" );
	GameConstant.isDirtPlayGame = true;
	self:processLoginRoom();
end
---------------------------------------------------------------------------------------------------------------------------------------
--view access
--是否登录
HallScene.canEnterView = function(self)
	if self.player.mid > 0 then
		if not SocketManager.getInstance().m_isRoomSocketOpen then
			Banner.getInstance():showMsg("正在拼命为您连接服务器");
			self:openHallSocketAndLogin();
			return false;
		end
		return true;
	else
		Banner.getInstance():showMsg("您还没有登录，请先登录!");
		self:addLoginView()
	end
	return false;
end

HallScene.addLoginView = function ( self )
    if self.loginView then
        --添加窗口前先删除view modify by noahhan
        self.loginView:closeSelf();
    end
	self.loginView = PlatformFactory.curPlatform:getLoginView(self);
    self.loginView:setOnWindowHideListener(self, function( self )
        self.loginView = nil;
    end)
	self.loginView:setName("login_view")
	self.m_mainView:addChild(self.loginView);
end
-- 切换帐号
HallScene.clickChangeLoginMethod = function(self)
	DebugLog("HallScene.clickChangeLoginMethod")
    
	if self.settingWindow then
		self.settingWindow:hide();
		if self.settingWindow then
			delete(self.settingWindow);
			self.settingWindow = nil;
		end
	end
	self:addLoginView()
	local player = PlayerManager.getInstance():myself();
	if player then
		player:resetPlayerData();
	end
end

HallScene.loginSuccess = function(self)
	-- 新手引导
	-- 新注册
	DebugLog("HallScene.loginSuccess")
	if self.player.isRegister == 1 then
		require("teach/TeachManager");
		DebugLog("HallScene.loginSuccess           teach TeachManager ")
		local scale = System.getLayoutScale();
		local screenW, screenH = System.getScreenWidth() / scale, System.getScreenHeight() / scale;

		self.m_teachNode = new(TeachManager, screenW / 2 -40, screenH / 2 + 70, screenW, screenH);

        self.m_more_view.btnView:setVisible(false);
        --self.m_more_view.btn_2:setVisible(false);
		local viewCover = self.m_more_view;
        viewCover.is_new_touch = 1;  --此变量标识点击遮罩层时走新手的逻辑还是走更多界面的逻辑
--		viewCover:setTransparency( 1.1 );
--        viewCover:setFile("Commonx/zhezhao.png");
		viewCover:setVisible(true)
		viewCover:addChild(self.m_teachNode);

		viewCover:setVisible(true);
--		viewCover:setEventTouch(self, function(self, finger_action, x, y, drawing_id_first, drawing_id_current)
--			DebugLog("x: .." ..x .." y:" .. y)
--			if finger_action == kFingerUp then
--				self.m_more_view:setVisible(false);
--				self.m_teachNode:hide();
--                if self.m_more_view.mask then
--                    self.m_more_view.mask:removeFromSuper();
--                    self.m_more_view.mask = nil;
--                end

--				if x >895 and x < 1240 and y > 185 and y < 300 then
--					self:onClickedQuickStartBtn()
--				end
--			end
--		end );
		--self.m_teachNode:addToRoot()
		self.m_teachNode:show(TeachManager.KUAI_SHU_KAI_SHI_TIP);
	end
end
HallScene.closeAllPopuWnd  = function ( self )
	new_pop_wnd_mgr.get_instance():pop_all_wnd();
    hall_2_interface_mgr.get_instance():close_all_interface();

	self:setAnimOverView()
end
HallScene.removeMatchApply = function(self,param)
	self.m_mainView:removeChild(self.matchApplyWindow,true);
   	if self.matchApplyWindow then
	 	delete(self.matchApplyWindow);
	  	self.matchApplyWindow = nil;
   	end
end


HallScene.showBanInfoWnd = function( self, data )
	if not data then
		return false;
	end

	if data.status and tonumber( data.status) == -110 then
		local msg = data.msg or "您的账号由于某些原因已被查封";

		require( "MahjongCommon/BanInfoWnd" );
		local banWnd = new( BanInfoWnd, msg, self );
		banWnd:showWnd();
		Loading.hideLoadingAnim();
		return true;
	end
	return false;
end

HallScene.showIsNeedTeach = function(self)
	local isNeed = g_DiskDataMgr:getUserData(self.player.mid or 0, kIsNeedTeach, 0)
	if (not isNeed or 0 == isNeed) and 1 == self.player.isRegister then
		DebugLog("HallScene.showIsNeedTeach add and show NeedTeachView");
	end
	return isNeed;
end











HallScene.showOrHideTip = function(self, bShow)
	--self.m_topLayer
	--self:getControl(HallScene.s_controls.settingTip):setVisible(bShow);
end

HallScene.setLocalPush = function( self )
	DebugLog( "HallScene.setLocalPush" );
	local params = {};
	params.isRegister = self.player.isRegister;
	params.mid = self.player.mid;
    params.mtime = self.player.mtime
	native_to_java( kSetLocalPush, json.encode(params) );
end

HallScene.initHuTuiSdk = function(self)
	local param = {};
	param.mid = self.player.mid;
	param.nickName = self.player.nickName;
	param.level = self.player.level;

	-- native_to_java("inithutui",json.encode(param));
end


HallScene.processLoginRoom = function (self)
	-- RoomData.getInstance().isEnterRoom = true;
	-- 进入游戏
	--self:stopAllAnimations()
	if RoomData.getInstance().isMatch then
		GameState.changeState( nil, States.MatchRoom );
	elseif RoomData.getInstance().isFriendMatch then
		GameState.changeState( nil, States.FriendMatchRoom );
	else
		GameState.changeState( nil, States.NormalRoom );
	end
end
--------------------------------------------------------------------------------------------------------------
function HallScene.testKeyEvent( self, key )
	if DEBUGMODE ~= 1 then
		return;
	end
	DebugLog( "key = "..key );
	if key == 84 then -- T 按键

			require("MahjongHall/Mall/MiuiSmsSettingWnd");
			local miuismsWnd = new( MiuiSmsSettingWnd, self );
			miuismsWnd:showWnd();

	elseif key == 85 then
		--GameResMemory:printResInfo()
    elseif key == 49 then -------1
        local shareImg = new(Image,"shareBg.png")

        local icon = new(Image,"shareBg2.png")
        icon:setPos(320,100)
        shareImg:addChild(icon)

        local share_w  = shareImg:getWidget()
        share_w:update()
        -- 创建fbo，传入size，第二个参数可选，可传入现成的贴图。
        local fbo = FBO.create(Point(720,1280))
        fbo:render(share_w)
        -- 将fbo内容保存成rgba格式的png文件（目前只支持png格式）。
        fbo:save('xxxxxxxxxxx.png')
        -- DebugLog("fbo apply................")
        -- TextureCache.instance():dump()
        fbo:__gc()
        -- Clock.instance():schedule_once(function (  )
            -- DebugLog("fbo apply................")
            -- TextureCache.instance():dump()
        -- end, 1)
    elseif key == 77 then --m
        self:closeAllPopuWnd()

	end
end


-- 获取场次等级和人数
HallScene.sendGetRoomLevelAndNum = function ( self, data , data2 )
	local t = {};
	for k,v in pairs(data) do
		table.insert(t, v.level); -- 房间等级信息
	end

	if data2 then
		for k,v in pairs(data2) do
			table.insert(t,v.level);
		end
	end
	SocketSender.getInstance():send(HALL_CLIENT_GET_ROOM_LEVER_NUM, t); -- 获取大厅人数
end

HallScene.updataOnlinePlayerNum = function(self, t)
	DebugLog("HallScene.updataOnlinePlayerNum !@#!@#!@#")

	local xlData   = HallConfigDataManager.getInstance():returnHallDataForXL()
	if xlData and #xlData == tonumber(t.listcnt) then --xl数据
		if not self:getLevelChooseLayer() or self:getLevelChooseLayer().roomType ~= 3 then
			return
		end

		for i=1,t.listcnt do
			local level 		= tonumber(t["level"..i])
			local onlineCount	= t["onlineCount"..i]
			local item = self:getLevelChooseLayer():getRoomItemByLevel(level)
			if item then
				item:setOnlineNum(onlineCount);
                HallConfigDataManager.getInstance().m_onlineCnt["xl"][level] = onlineCount;
			end
		end

	else--xz数据
		if not self:getLevelChooseLayer() or self:getLevelChooseLayer().roomType ~= 1 then
			return
		end
		local onlineDatas = {}
		local typelist = HallConfigDataManager.getInstance():returnHallDataForTypelist()

		if not typelist then
			return
		end
		------------------------------------------------初始化人数为0
		for k,v in pairs(typelist) do
			onlineDatas[v.type] = 0;
		end

		------------------------------------------------累加
		local roomNum = t.listcnt;
		for i = 1, roomNum do
			local level 	  = tonumber(t["level" .. i]);
			local onlineCount = tonumber(t["onlineCount" .. i]);
			local curType     = HallConfigDataManager.getInstance():returnTypeForLevel(level)
			if curType  then
				if not onlineDatas[curType] then
					onlineDatas[curType] = 0
				end
				onlineDatas[curType] =  onlineDatas[curType] + onlineCount
			end
		end
		-------------------------------------------------
		for v,t in pairs(typelist) do
			local item = self:getLevelChooseLayer():getNewGameRoomItemByType(t.type)
			if item then
				item:setOnlineNum(onlineDatas[t.type]);
                 HallConfigDataManager.getInstance().m_onlineCnt["xz"][t.type] = onlineDatas[t.type];
			end
		end

	end

end

-- 显示退出游戏框
HallScene.showLogoutView = function(self)
	if PlatformFactory.curPlatform:isUsePlatformExit() then
        if PlatformConfig.platformOPPO == GameConstant.platformType then
            if GameConstant.checkType == kCheckStatusClose then
                if GameConstant.backCheckType == kCheckStatusClose then
                    require("MahjongHall/ExitGameWindow")
                    -- Banner.getInstance():showMsg("剩余" .. ((self.m_topLayer.m_calcuOnlineTime or 0)));
                    local ExitGameWindow = new(ExitGameWindow, self.m_topLayer.m_calcuOnlineTime);
                    self:addChild(ExitGameWindow);--.m_mainView:addChild(ExitGameWindow);
                    return;
                end
            end
        end

		native_muti_exit()
		return;
	end
    if self.logoutView then
        self.logoutView:hideWnd();
        self.logoutView:setOnWindowHideListener( self, function( self )
        	self.logoutView = nil;
        end);
    else
        require("MahjongCommon/LogoutView");
        self.logoutView = new(LogoutView, self);
        self:addChild(self.logoutView);--.m_mainView:addChild(self.logoutView);
        self.logoutView:setLevel(10001);
    end
end

--------------------------------------------------------------------------------------------------------------
--back event
HallScene.backEvent = function ( self )
	DebugLog("HallScene.backEvent")

	-- pop window
    if back_event_manager.get_instance():get_display_size() < 1 then
        self:showLogoutView();
    else
        back_event_manager.get_instance():excute();
    end
end
--------------------------------------------------------------------------------------------------------------
--native event
HallScene.callEvent = function ( self, param, json_data )
	if param == kActivityGoFunction then-----------------活动跳转
		local jump = json_data.target or ""; -- 跳转常量
		DebugLog("kActivityGoFunction  jump==" .. jump);
        -- mahjongPrint(json_data)
		if jump == "activityNumber" then
            DebugLog("activityNumber :GameConstant.checkType:"..tostring(GameConstant.checkType));
			if GameConstant.iosDeviceType>0 and GameConstant.iosPingBiFee  then
			    if self.m_bottomLayer then
					self.m_bottomLayer:updataActivityNum(0);
				end
				return
			end
			if json_data.count and json_data.count ~= "" then
					local count = tonumber(json_data.count) or 0; -- 活动数量
                    DebugLog("activityNumber :json_data.count:"..tostring(json_data.count));
                    DebugLog("activityNumber :count:"..tostring(count));
                    GlobalDataManager.getInstance():set_activity_count(count);
					if self.m_bottomLayer then
						self.m_bottomLayer:updataActivityNum(GameConstant.checkType == kCheckStatusOpen and 0 or count)
					end
				return 
			end
		end

		if jump =="redpacket" then
			if not HongBaoModel.getInstance():checkIsSuitSendCondition() then
				Banner.getInstance():showMsg("您的金币不够发红包哦！")
				return
			end
			--检查红包道具数量
			local hongbaoNum = GameConstant.changeNickTimes.rednum
			if hongbaoNum <= 0 then
				--check 道具商城是否有该道具
				if not ProductManager.getInstance():getExchangeListItem(ItemManager.HONG_BAO_CID) then
					Banner.getInstance():showMsg("红包道具不存在,请去商城界面查看购买！")
					return
				end

				require("MahjongCommon/ExchangePopu");
				self.exchangePopu = new(ExchangePopu, ItemManager.HONG_BAO_CID, self );
				self.exchangePopu:setOnWindowHideListener( self, function( self )
					self.exchangePopu = nil;
				end);
				self.exchangePopu:showWnd();
			else
				HongBaoViewManager.getInstance():showHongBaoSendView()
			end
			return
		end
		local jump_param = json_data.desc or ""; -- 参数
		-- if json_data.count and json_data.count ~= "" and
		-- 	jump ~= "recharge" then
		-- 	local count = tonumber(json_data.count) or 0; -- 活动数量
		-- 	if self.m_bottomLayer then
		-- 		self.m_bottomLayer:updataActivityNum(count)
		-- 	end
		-- 	return;
		-- end


		-- 强推
		if json_data.url and json_data.url ~= ""
			and json_data.rate and json_data.rate ~= "" then
			local param = {};
			param.url = json_data.url or "";
			param.rate = json_data.rate or 0;
			param.target = json_data.target or "1";
			param.sort = json_data.sort or "0";
			param.act_image = json_data.act_image or "";
			param.showtext = json_data.showtext or 0;
			param.percent = json_data.percent or 0;
			GlobalDataManager.getInstance():getActivityNumSuccess(true,param);
			return;
		end

		if jump == kBuyCoinsForActivityMM and tonumber(jump_param) then
			if GameConstant.simType == 1 then
				local productManager = ProductManager.getInstance();
				local product = productManager:getHideProductByPamount( tonumber(jump_param) );
				if product then
					product.payScene = {};
					product.payScene.id = MallCoinBuyForPay;
					require("MahjongPay/PayManager/PayForActivity");
					local manager = PayForActivity.getInstance();
					manager:pay( product );
				else
					DebugLog("未配置商品");
				end
			else
				Banner.getInstance():showMsg("仅移动手机用户可参与该活动");
			end
		end

		if kGame == jump and tonumber(jump_param) and  tonumber(jump_param) > 0 then -- 请求进入游戏
			self:toRoom(tonumber(jump_param));
		else
			self:activityJump(jump,json_data)
		end

	elseif kcheckLoginTypeAndMid == param then
		DebugLog( "kcheckLoginTypeAndMid ".. json_data.state );
		if 1 == tonumber(json_data.state or 0) then
			DebugLog( "show first chargeview" );
			GameConstant.isNeedShowFirstChargeToday = true;
			new_pop_wnd_mgr.get_instance():add_and_show( new_pop_wnd_mgr.enum.first_charge );
		else
			GameConstant.isNeedShowFirstChargeToday = false;
		end

	elseif kcheckLoginTypeAndMid == param then
		DebugLog( "kcheckLoginTypeAndMid ".. json_data.state );
		if 1 == tonumber(json_data.state or 0) then
			DebugLog( "show first chargeview" );
			GameConstant.isNeedShowFirstChargeToday = true;
			new_pop_wnd_mgr.get_instance():add_and_show( new_pop_wnd_mgr.enum.first_charge );
		else
			GameConstant.isNeedShowFirstChargeToday = false;
		end
	end
end


HallScene.activityJump = function(self, jump, param)
	DebugLog("jump : " .. jump);
	GameConstant.activityJumpToOtherView = true
	--DebugLog("param : " ..(param or ""));

	local json_data = param;
	if kHall == jump then  --大厅
		self:closeAllPopuWnd();
		--直接关闭就可以了
		local param = param.desc or "";
		if param == "" then
			--直接关闭
		elseif param == "game" then --游戏场
			self:onClickedGameBtn()
		elseif param == "match" then --比赛场
			self:onClickedMatchBtn()
        elseif param == "xzdd" then
            self:onClickedXzdd()
        elseif param == "disastrous" then
            self:onClickedXlch()
		end
	elseif kRoom == jump then
		self:closeAllPopuWnd();
		local parmae = param.desc or kGame;  --默认是快速开始
		if parmae == kGame then
			self:requestQuickStartGame(); --快速开始
		elseif parmae == kBox then
--			self:enterCompartmentFromHallMain()
		elseif parmae == "match" then  --比赛
			self:onClickedMatchBtn()
		end
	elseif kTask == jump then --任务
		self:closeAllPopuWnd();
		self.m_bottomLayer:onClickedTaskBtn()
	elseif kStore == jump then  --商场
		self:closeAllPopuWnd();
		self.m_bottomLayer:onClickedMallBtn();
	elseif kFeedback == jump then  --反馈
		self:closeAllPopuWnd();
		self.m_topLayer:clickFeedBackAndHelp();
	elseif kRank == jump then  --排行榜
		self:closeAllPopuWnd();
		self.m_bottomLayer:onClickedRankBtn();
	elseif kFriend == jump then  --好友
		self:closeAllPopuWnd();
		self.m_bottomLayer:onClickedFriendBtn()
		--self.m_socialLayer:onClickedFriendBtn()
	elseif kInfo == jump then    --用户信息
		self:closeAllPopuWnd();
		self.m_topLayer:onClickedPlayerInfoBtn()
	elseif kSign == jump then	 --签到
		self:closeAllPopuWnd();
		self:requestSignWnd(true);
	elseif kBypass == jump then  --博雅通行证登陆
		self:closeAllPopuWnd();
		--HallScene.OnBoyaaLoginClick(self);
	elseif kGame == jump then    --快速开始游戏
		self:closeAllPopuWnd();
		self:requestQuickStartGame();
	elseif kBox == jump then     --包厢
		-- self:closeAllPopuWnd();
		-- self:enterCompartmentFromHallMain();
	elseif kQuickBuy == jump then   --快速购买
		self:closeAllPopuWnd();
		getQuickRechargeView(self);
	elseif kPropStore == jump then   --兑换
		self:closeAllPopuWnd();
		self.m_bottomLayer:onClickedExchangeBtn();
	elseif kBuy == jump then
		self:closeAllPopuWnd();
		local parmae = json_data.count or "0";  --默认是快速开始
		if not parmae or parmae == "0" then  --没有参数就快速购买
			getQuickRechargeView(self);
		else
			--通过传过来的金额进行购买
			local product= ProductManager.getInstance():getProductByPamount(tonumber(parmae));
			if not product then
				Banner.getInstance():showMsg("没有该商品，请重新购买！");
				return;
			else
			    -- 开始支付
				PlatformFactory.curPlatform:pay(product);
			end
		end
    elseif kCreateBattle == jump then
        self:closeAllPopuWnd()
        self:onClickedCreateRoom()
	elseif "QQGroup" == jump then --qq加群
		GameConstant.activityJumpToOtherView = false
        local qqcode = param.qqcode or "";
        if not qqcode or qqcode == "" then
            return ;
        end
        callAddGroup(qqcode)
    elseif jump == "wxfield" then --微信支付
        GameConstant.activityJumpToOtherView = false
        param.pluginId = PluginUtil:convertPayId2Plugin(tonumber(PlatformConfig.NewWeChatPay))
        mahjongPrint(param, "jaon_data")
        native_to_java(kMutiPay, json.encode(param))
    elseif "" == jump then

	end
end


HallScene.createRoom = function(self)

end

HallScene.requestCreateRoom = function ( self, data )

end

HallScene.showQuickChargeView = function( self, param_t )
	RechargeTip.create(param_t)

end

HallScene.showFirstChargeView = function(self)
    require("MahjongCommon/FirstChargeView");

    if 1 == FirstChargeView.getInstance().isOpenFirstChargeView then
        FirstChargeView.getInstance():show();
    end
    return 1 == FirstChargeView.getInstance().isOpenFirstChargeView;
end


--有还未播放的广播则继续播放
HallScene.playBroadcastMsg = function (self)

	if not BroadcastMsgManager.getInstance():isEmpty() then
		DebugLog("HallScene.playBroadcastMsg  @@@@");
		self:broadcastMsg();
	end
end



HallScene.broadcastMsg = function( self )
	if self.matchApplyWindow then
		self.matchApplyWindow:broadcastMsg();
	else
		if not self.myBroadcast then
			self:createBroadcastMSG();
		end
		self.myBroadcast:play();
		if self.broadcastPopWin and self.broadcastPopWin:getVisible() then
			self.broadcastPopWin:flushMesItem();
		end
	end
end



-- 请求进入新游戏场房间
HallScene.requireEnterNewGameRoom = function(self, roomType)
	DebugLog("HallScene.requireEnterNewGameRoom")
	GameConstant.go_to_high = nil
	local  money = PlayerManager.getInstance():myself().money
	local  vipLevel = PlayerManager.getInstance():myself().vipLevel
	DebugLog("money:"..money.." ;type: "..roomType)
	local ret,hd = HallConfigDataManager.getInstance():returnMaxRequireHallDataForType(roomType,money,vipLevel)
	if ret then
		self:toRoom(hd.level)
	else
		if hd then
			if tonumber(money) >= tonumber(hd.require) then
				Banner.getInstance():showMsg("VIP等级不足,无法进入该房间!")
			else
				self:needMoreMoney(hd)
			end
		end
	end
end


--
HallScene.onGotoScoreMatch = function ( self )
	local matchData = HallConfigDataManager.getInstance():returnMatchData()
	for i=1,#matchData do
		if matchData[i].free == 1 then
			self:onGoToMatchRoom(matchData[i].level, matchData[i].type)
		end
	end
end
--进入报名界面"
HallScene.onGoToMatchRoom = function(self, roomLevel, matchType)
	--新定时赛 点击item前判断金币限制--所以这里要注释掉和人满赛一样对金币 限制检查
    DebugLog("[HallScene]:onGoToMatchRoom level:"..tostring(roomLevel).." matchtype:" ..tostring(matchType));


    if matchType == GameConstant.matchTypeConfig.award then
    	if self.matchApplyWindow then
			self.m_mainView:removeChild(self.matchApplyWindow, true);
			self.matchApplyWindow = nil;
		end

		if self.broadcastPopWin then
			self.broadcastPopWin:removeFromSuper()
			self.broadcastPopWin = nil;
		end
        self:showApplyWindow(nil, roomLevel);
    else
    	if not self:jugeEnterMatchRoom(roomLevel) then -- 进入房间失败
		    GameConstant.isDirtPlayGame = false;
		    return false;
	    end
    	--应该发命令进行报名，如果成功则进入报名界面，没有成功应该提示用户
	    self:beginGotoApplyMatchRoom(roomLevel, matchType);
    end

end

--开始申请报名
HallScene.beginGotoApplyMatchRoom = function(self, roomLevel, matchType)
	if not roomLevel then
		return;
	end

	local param = {};
	param.level_0 = roomLevel;
	param.param = -1;
	param.cmdRequest = CLIENT_SIGNUP_MATCH_REQ;
	param.uid = self.player.mid;
	param.matchType =  matchType;  -- 1为人满开赛，2为定时赛
	param.level = roomLevel;
	param.api = PlatformFactory.curPlatform.api;
	SocketSender.getInstance():send( SERVER_MATCHSERVER_CMD, param);-- 报名
end

--判断是否可以进入比赛房间
HallScene.jugeEnterMatchRoom   = function(self, roomLevel)
	DebugLog("判断是否符合条件进入比赛场， jugeEnterMatchRoom");
	if not roomLevel then
        DebugLog("error roomLevel:"..tostring(roomLevel));
		return false;
	end

	local roomInfo = HallConfigDataManager.getInstance():returnMatchDataByLevel( roomLevel)

	if not roomInfo then --没有找到该比赛场次的配置信息
        DebugLog("roomInfo is nil");
		return false;
	end

	if PlayerManager.getInstance():myself().money < GameConstant.bankruptMoney and roomInfo.free ~= 1 then
		--globalShowBankruptcyDlg(level);--金币下限，等同于破产，提示金币充值,小于进入游戏的要求
		GlobalDataManager.getInstance():showBankruptDlg(roomLevel,self.m_view);
		return false;
	end

	local player = PlayerManager.getInstance():myself();
	local requireMoney = roomInfo.require; -- 入场最低要求
	local limitMoney = roomInfo.exceed;   -- 入场最高要求
	if GameConstant.platformType ~= PlatformConfig.platformContest then
		if limitMoney ~= 0 and player.money > limitMoney then
			DebugLog("比赛报名限制额："..limitMoney);
			local str = "你的金币高于场区上限" ..limitMoney .. ", 是否要进入更高底注的比赛场？";
			require("MatchApply/MatchSmallPopuFrame");
			self.m_upperview  = MatchSmallPopuFrame.showNormalDialog( "温馨提示", str, GameConstant.curGameSceneRef);
			self.m_upperview:setConfirmCallback(self, function ( self )
				self:suitMoneyToMatchRoom();--进入符合条件的场进行比赛
			end);
			return false;
		end
	end

	if player.money < requireMoney then
		self:needMoreMoney(roomInfo);
		return false;
	end

	return true;
end
-- 请求更新
HallScene.OnUpdateClick = function(self)
	if not self:canEnterView() then
		return;
	end
	GlobalDataManager.getInstance():requestUpdateVersionInfo( 1 ); -- 更新
end
--通过金币选择合适的比赛场进入
HallScene.suitMoneyToMatchRoom = function(self)
	local player = PlayerManager.getInstance():myself();
	local level = nil;
	local matchType = nil;

	local match_data = HallConfigDataManager.getInstance():returnMatchData();
	for k=1,#match_data do
		if match_data[k] and player.money >= match_data[k].require and player.money <= match_data[k].exceed then
			level = match_data[k].level;
			matchType = match_data[k].type;
			if 2 == matchType then
				break;
			end
		end
	end
	self:beginGotoApplyMatchRoom(level,matchType);
end
-------------------------------------------------------------------------------------------------------------------------------------
-- function HallScene:onGoToFriendMatchRoom( )
-- 	------------------
-- 	StateMachine.getInstance():changeState(States.FriendMatchRoom);
-- end

HallScene.onClickedGameBtn = function ( self )
	self:onClickedXzdd()

end


--[Comment]
--更多按钮点击
HallScene.onClickedMoreBtn = function (self)
    DebugLog("[HallScene] onClickedMoreBtn");
     self:playEnterMoreAnim();
end


HallScene.onClickedMatchBtn = function ( self )
    --审核状态关闭
    if GameConstant.checkType == kCheckStatusOpen then
		Banner.getInstance():showMsg("暂未开放.");
        return;
	end
	if not self:canEnterView() then
		return
	end
	if GameConstant.iosDeviceType>0 and GameConstant.iosPingBiFee then
	Banner.getInstance():showMsg("暂未开放.");
	return;
	end
	umengStatics_lua(Umeng_HallMatchBtn);
	self:playExitHallAnim(self,function (self)
		self:enterMatchRoomList()
	end)

end

HallScene.enterMatchRoomList = function ( self )

	self:getLevelChooseLayer():setRoomType(2)
	self:getLevelChooseLayer():setVisible(true)
	self:getLevelChooseLayer():preEnterAnim()
	self.m_topLayer:preEnterAnim2()

    --标记当前页面
    global_set_current_view_tag(GameConstant.view_tag.match_list);
	self:playEnterLevelChooseAnim()
end



HallScene.onClickedQuickStartBtn = function ( self , key)
	--self:onClickedXzdd()
	self:requestQuickStartGame(key)
end




HallScene.enterCompartmentFromHallMain = function ( self )

end
HallScene.onClickedLfpBtn = function ( self )

	if not self:canEnterView() then
		return;
	end
	umengStatics_lua(Umeng_HallLfpBtn);
	self:quickEnterLFP();
end

HallScene.onClickedSingleBtn = function ( self )
	umengStatics_lua(Umeng_HallSingleBtn);
	GameConstant.isSingleGame = true;
	self:requireSingleGame();
end

--按钮 事件：好友对战:加入房间
HallScene.onClickedAddRoom = function ( self )
    umengStatics_lua(Umeng_HallRoomEnter)
	if not self:canEnterView() then
		return
	end

	local config = GlobalDataManager.getInstance().fmRoomConfig
	if not config then
		Banner.getInstance():showMsg("还未拉取到配置，请稍候...")
	end

    if self._joinGameWin then
        return
    end
	require("MahjongHall/FriendMatch/joinGameWindow")
    self._joinGameWin = new(JoinGameWindow, config.level)
	--local win =
	self._joinGameWin:setLevel(1000)
	self._joinGameWin:addToRoot()
	self._joinGameWin:showWnd()
    self._joinGameWin:setOnWindowHideListener(self,function ( self )
        self._joinGameWin = nil
    end)
end
--onClickedCreateRoom
--按钮 事件：好友对战:创建房间
HallScene.onClickedCreateRoom = function ( self )
	DebugLog("HallScene.onClickedCreateRoom")
    umengStatics_lua(Umeng_HallRoomCreate)
	if not self:canEnterView() then
		return
	end
	DebugLog("HallScene.onClickedCreateRoom...")
	require("MahjongHall/FriendMatch/createFriendRoom")
    if self.m_create_room then
        self.m_mainView:removeChild(self.m_create_room, true); 
        self.m_create_room = nil;       
    end
     

	self.m_create_room = new(CreateFriendRoom, GlobalDataManager.getInstance().fmRoomConfig )
    self.m_mainView:addChild(self.m_create_room);
	self.m_create_room:showWnd()

    self.m_create_room:setOnWindowHideListener(self,function ( self )
        self.m_create_room = nil
    end)
end

-- HallScene.testPlayAnimBankrupt = function ( self )
--     require("Animation/PlayCardsAnim/animationBankrupt");
--     local node =new(Node)
--     node:addToRoot()
--     local view = new(AnimationBankrupt, {300,300}, node);
--     view:play();
-- end

-- function HallScene:testPlayAnimWind( ... )
--     require("Animation/PlayCardsAnim/animationWind");
--     local node =new(Node)
--     node:addToRoot()
--     local view = new(AnimationWind, {300,300});
--     node:addChild(view)
--     view:play();
-- end
---

--点击血流和续展的处理逻辑
HallScene.excute_logic_xz_xl = function (self, b_xz)
    DebugLog("[HallScene]:logic_xz_xl");

    --破产检查
    if PlayerManager.getInstance():myself().money < GameConstant.bankruptMoney then
		GlobalDataManager.getInstance():showBankruptDlg(nil , self);
		return true;
	end

    local key_day = 0;
    local key_times = 0;
    local control_times = 0;
    local parm = "";

    --血战。血流不同的参数
    if b_xz then
        parm = "xz";
        key_day = GameConstant.k_per_day_xz;
        key_times =  GameConstant.k_per_day_xz_n;
        control_times = GlobalDataManager.getInstance():get_control_xz();
    else
        parm = "xl";
        key_day = GameConstant.k_per_day_xl;
        key_times =  GameConstant.k_per_day_xl_n;
        control_times = GlobalDataManager.getInstance():get_control_xl();
    end


    local current_time = os.time();
    local date = os.date("*t", current_time);
    local last_day = g_DiskDataMgr:getAppData(key_day, 0)
    if last_day ~= date.day then--
    	g_DiskDataMgr:setAppData(key_day, date.day)
    	--如果是新的一天的数据清零
    	g_DiskDataMgr:setAppData(key_times, 0)
    end
    --获取旧的数据
    local last_times = g_DiskDataMgr:getAppData(key_times,0)
    --设置新的数据
    g_DiskDataMgr:setAppData(key_times, last_times+1)
--    if DEBUGMODE == 1 then--方便测试观看
--        Banner.getInstance():showMsg("last_day:"..tostring(last_day).." date.day:"..tostring(date.day))
--        Banner.getInstance():showMsg("last_times:"..tostring(last_times).." control_times:"..tostring(control_times))
--    end
    DebugLog("last_times:"..tostring(last_times).." control_times:"..tostring(control_times));
    if control_times > last_times then
        if self:requestQuickStartGame({parm}, true) then
            return true;
        end
    end

    return false;
end

--按钮 事件：血战到底
HallScene.onClickedXzdd = function ( self )

	if not self:canEnterView() then
		return
	end

    if self:excute_logic_xz_xl(true) then
        return;
    end
    --标记当前页面
    global_set_current_view_tag(GameConstant.view_tag.xz);

	umengStatics_lua(Umeng_HallGameBtn);
	DebugLog("ResultViewUmengError: HallScene,onClickedGameBtn,playExitAnim")
	self:playExitHallAnim(self,function (self)
		self:getLevelChooseLayer():setRoomType(1)
		self:getLevelChooseLayer():setVisible(true)
		self:getLevelChooseLayer():preEnterAnim()
		self.m_topLayer:preEnterAnim2()

		self:playEnterLevelChooseAnim(self,self.playLevelChooseAnimOverCallback)
	end)
end

--按钮 事件：血流成河
HallScene.onClickedXlch = function ( self )

	if not self:canEnterView() then
		return
	end

    if self:excute_logic_xz_xl(false) then
        return;
    end
    --标记当前页面
    global_set_current_view_tag(GameConstant.view_tag.xl);

	self:playExitHallAnim(self,function (self)


		self:getLevelChooseLayer():setRoomType(3)
		self:getLevelChooseLayer():setVisible(true)
		self:getLevelChooseLayer():preEnterAnim()
		self.m_topLayer:preEnterAnim2()

		self:playEnterLevelChooseAnim()
	end)
end

function HallScene:getLevelChooseLayer( )
	if not self.m_levelChooseLayer then
		require("MahjongHall/LevelChooseLayer")
		local chooseLevel = require(ViewLuaPath.."chooseLevel");
		self.m_levelChooseLayer = new(LevelChooseLayer,chooseLevel,self)
		self.m_mainView:addChild(self:getLevelChooseLayer())
		self.m_levelChooseLayer:setVisible(false)
	end
	return self.m_levelChooseLayer
end

--按钮 事件：两房
HallScene.onClickedLf = function ( self )
	if not self:canEnterView() then
		return;
	end

    umengStatics_lua(Umeng_HallLfpBtn);
	self:quickEnterLFP();
end

HallScene.requireSingleGame = function ( self )
    SocketManager.getInstance().m_ipPortManager:reportUmengFailedIpPort(nil, nil,2)

	GameState.changeState( nil, States.SingleRoom );
end


HallScene.addCheckTypeScene = function(self)
	self.m_bottomLayer:showCheckSceneBtn();
	self.m_bottomLayer:updataActivityNum(0);
end

HallScene.removeCheckTypeScene = function(self)
	self.m_bottomLayer:removeCheckSceneBtn();
end

HallScene.requestMallDataCallBack = function(self,isSuccess,data)
	if isSuccess then
		local status = tonumber(data.status)
		if status == 1 then
			local isopen = tonumber(data.data.open) or 0

			if isopen == 1 then
				local url = data.data.url or ""
				GameConstant.m_pay_url = url;
			end
		end
	end
end

--领取奖励
function HallScene:requestEvaluateAwardCallback( isSuccess, data )
    if not isSuccess or not data or not data.data then
        return
    end
    local money = data.data.reward_money or 0
    if money > 0 then
    	PlayerManager.getInstance():myself().money = tonumber(PlayerManager.getInstance():myself().money) + tonumber(money);
    	AnimationAwardTips.play(string.format("您获得%d金币", money))
    	showGoldDropAnimation()
    	EventDispatcher.getInstance():dispatch(GlobalDataManager.updateSceneEvent);
	end
end

--显示老玩家礼包窗口
HallScene.showVeteranPlayerAwardWindow = function (self)
    if self.m_veteran_player_award_window then
        self.m_veteran_player_award_window:showWnd();
    end
end

--发送老玩家礼包请求
HallScene.requestVeteranPlayerGift = function (self)
	local param_data = {};
	param_data.mid = self.player.mid;
    SocketManager.getInstance():sendPack(PHP_CMD_REQEUST_VETERAN_PALYER_GIFT, param_data);
end



--老玩家礼包
function HallScene:requestVeteranPlayerGiftCallback( isSuccess, data )
    DebugLog("HallScene:requestVeteranPlayerGiftCallback");
    if not isSuccess or not data or not data.data then
        DebugLog(" not success");
        return
    end

    if data.status == 1 then
        require("MahjongPopu/VeteranPlayerAwardWindow");
        if self.m_veteran_player_award_window then
            self.m_veteran_player_award_window:removeFromSuper();
            self.m_veteran_player_award_window = nil;
        end
        self.m_veteran_player_award_window = new(VeteranPlayerAwardWindow, data.data);
        self.m_veteran_player_award_window:setOnWindowHideListener(self, function (self)
            self.m_veteran_player_award_window = nil;
        end);
       new_pop_wnd_mgr.get_instance():add_and_show(new_pop_wnd_mgr.enum.veteran_player)
    end

end


--继续报名比赛
HallScene.continueApplyMatch = function ( self)
	DebugLog("HallScene.continueApplyMatch")
	DebugLog("!@#GameConstant.continueMatchFlag = " ..tostring(GameConstant.continueMatchFlag))

	if 1 == GameConstant.gotoScoreMatch then
		self:onGotoScoreMatch()
		GameConstant.gotoScoreMatch = 0
        DebugLog("1 == GameConstant.gotoScoreMatch");
		return
	end

	GameConstant.gotoScoreMatch = 0
	if 1 == GameConstant.continueMatchFlag then -- 继续报名按钮触发的
		GameConstant.continueMatchFlag = 0;
		local matchList = HallConfigDataManager.getInstance():getDescendMatchListByRequire();
		if not matchList then
            DebugLog("matchList is nil");
			return;
		end
        --使用保存的matchid解
        local str_matchid = tostring(GameConstant.matchId)--"20160811165914|2|86|8526|8613|0000|2|8616";
        if not str_matchid then
            DebugLog("str_matchid is nil");
            return;
        end
        local tmp = string.split(str_matchid, "|")
        local go_match_type = nil;
        if tmp and #tmp >= 2 then
           go_match_type = tonumber(tmp[2]);
        end

        DebugLog("self.player.money:"..tostring(self.player.money));
        DebugLog("GameConstant.matchType:"..tostring(GameConstant.matchType));
        DebugLog("go_match_type:"..tostring(go_match_type));

		for i=1, #matchList do
            DebugLog("free: "..tostring(matchList[i].free).."Limit :"..tostring(GameConstant.displayScoreMatchLimit).."require:"..tostring(matchList[i].require).."exceed"..tostring(matchList[i].exceed));
			if (matchList[i].free == 1 and self.player.money <= GameConstant.displayScoreMatchLimit)
			      or (matchList[i].free ~= 1 and self.player.money >= matchList[i].require and self.player.money <= matchList[i].exceed) then

				local level = matchList[i].level;
				local matchType =  matchList[i].type;
				DebugLog("HallController.continueApplyMatch  matchList有数据 继续报名比赛场 level ==" .. level .. "  , matchType ==" .. matchType);
                --继续报名同type比赛
                if go_match_type and go_match_type ~= 0 and go_match_type == matchType then
                    self:onGoToMatchRoom( level, matchType );
                    break
                end
				--self:onGoToMatchRoom( level, matchType );
				--break;
			end
		end
	end
end

--在大厅收到 房间内的消息 需要重连进入房间
function HallScene:isInRoomGame( data  )
    -- body
    SocketManager.getInstance():socketCloseAndOpen()
end



function HallScene:onJoinSuccedCallback( fid, from )
    self:joinFriendMatchRoomRequest( fid )

    if self._joinGameWin then
        self._joinGameWin:hideWnd(true)
    end
end


function HallScene:onJoinFailedCallback( from )
    if self._joinGameWin then
        self._joinGameWin:joinFailed()
    end
end

HallScene.registersEvents = function ( self )
	DebugLog("HallScene.registersEvents")
	EventDispatcher.getInstance():register(SocketManager.s_phpMsg, self, self.onPhpMsgResponse);

	EventDispatcher.getInstance():register(SocketManager.s_serverMsg, self, self.onSocketPackEvent);
	EventDispatcher.getInstance():register(BaseLogin.loginResuleEvent,self,self.requestLoginCallBack);
	EventDispatcher.getInstance():register(NativeManager._Event, self, self.callEvent);
	EventDispatcher.getInstance():register(SocketManager.s_serverState, self, self.onSocketStateEvent);
	EventDispatcher.getInstance():register(Event.Back, self, self.backEvent);
	EventDispatcher.getInstance():register(BroadcastMsgManager.updateSceneEvent, self, self.broadcastMsg);
	EventDispatcher.getInstance():register(GlobalDataManager.addCheckSceneEvent,self,self.addCheckTypeScene);
	EventDispatcher.getInstance():register(GlobalDataManager.removeCheckSceneEvent,self,self.removeCheckTypeScene);

	EventDispatcher.getInstance():register(HongBaoModel.HongBaoMsgs, self, self.recieveHongBaoNews);

	self.cacheDataHttpEvent = EventDispatcher.getInstance():getUserEvent();
	NetCacheDataManager.getInstance():register( self.cacheDataHttpEvent, self.cacheDataHttpCallBackFuncMap, self, self.onCacheDataHttpListener );
end

HallScene.unRegisterEvents = function ( self )
	DebugLog("HallScene.unRegisterEvents")
	EventDispatcher.getInstance():unregister(HongBaoModel.HongBaoMsgs, self, self.recieveHongBaoNews);

	EventDispatcher.getInstance():unregister(SocketManager.s_phpMsg, self, self.onPhpMsgResponse);
	EventDispatcher.getInstance():unregister(SocketManager.s_serverMsg, self, self.onSocketPackEvent);
	EventDispatcher.getInstance():unregister(BroadcastMsgManager.updateSceneEvent, self, self.broadcastMsg);
	EventDispatcher.getInstance():unregister(BaseLogin.loginResuleEvent,self,self.requestLoginCallBack);
	EventDispatcher.getInstance():unregister(NativeManager._Event, self, self.callEvent);
	EventDispatcher.getInstance():unregister(SocketManager.s_serverState, self, self.onSocketStateEvent);
	EventDispatcher.getInstance():unregister(Event.Back, self, self.backEvent);
	EventDispatcher.getInstance():unregister(GlobalDataManager.addCheckSceneEvent,self,self.addCheckTypeScene);
	EventDispatcher.getInstance():unregister(GlobalDataManager.removeCheckSceneEvent,self,self.removeCheckTypeScene);
	NetCacheDataManager.getInstance():unregister( self.cacheDataHttpEvent, self, self.onCacheDataHttpListener );
end

--------------------------------------------------------------------------------------------------------------------------------------------
-- 定义可操作控件的标识
HallScene.s_controls =
{
--	gameBtn 			= 1,
--	matchBtn 			= 2,
--	moreBtn 			= 3,
--	quickStartBtn 		= 4,
    btn_xzdd            = 1,--血战到底
    btn_xlch            = 2,--血流成河
    btn_match           = 3,--比赛
    btn_lf              = 4,--两房

	mainView            = 5,
	surfaceView			= 6,

	menuView			= 7,
	hallBgImg			= 8,
	hallGirl            = 9,
--	menuBgImg           = 10,



--	moreMenus			= 13,
	compartmentBtn      = 14,
	lfpBtn             = 15,
--	singleBtn           = 16,

	leftBamboo          = 17,
	rightBamBoo         = 18,
	--bottomImg           = 19,
    btn_single          = 20,--单机
    btn_addRoom         = 21,--加入房间

    btn_createRoom      = 22,--创建对战btn_createRoom
    friend_fight        = 23,
    a_addRoomBody        = 24,
    a_createRoomBody        = 25,
    btn_more  = 26,


}

-- 可操作控件在布局文件中的位置
HallScene.s_controlConfig =
{
	[HallScene.s_controls.btn_xzdd] 						= {"main_view", "v_1", "btn_xzdd"},--{"main_view", "menu", "btn_xzdd"},
    [HallScene.s_controls.btn_xlch] 						= {"main_view", "v_1", "btn_xlch"},--{"main_view", "menu", "btn_xlch"},
    [HallScene.s_controls.btn_match] 						= {"main_view", "v_1", "btn_match"},--{"main_view", "menu", "menu_bg", "btn_match"},
    [HallScene.s_controls.btn_lf] 						    = {"main_view", "menu", "menu_bg", "btn_lf"},
    [HallScene.s_controls.btn_single] 						= {"surface_view","v_2" ,"btn_2"},
    [HallScene.s_controls.btn_addRoom] 						= {"friend_fight", "btn_addRoom"},
    [HallScene.s_controls.btn_createRoom] 				    = {"friend_fight", "btn_createRoom"},

    [HallScene.s_controls.a_addRoomBody] 						= {"friend_fight", "btn_addRoom", "body"},
    [HallScene.s_controls.a_createRoomBody] 						= {"friend_fight", "btn_createRoom", "body"},

--	[HallScene.s_controls.matchBtn] 					= {"main_view", "menu", "menu_bg","match_btn"},
    [HallScene.s_controls.btn_more]						= {"btn_more" },
--	[HallScene.s_controls.quickStartBtn] 				= {"main_view", "menu", "quick_start_btn" },

	[HallScene.s_controls.mainView] 					= {"main_view"},
	[HallScene.s_controls.surfaceView] 					= {"surface_view"},
	[HallScene.s_controls.menuView]						= {"main_view" , "v_1"},
	[HallScene.s_controls.hallBgImg]					= {"bg"},
	[HallScene.s_controls.hallGirl]						= {"girl"},
--	[HallScene.s_controls.menuBgImg]					= {"main_view", "menu", "menu_bg"},

--	[HallScene.s_controls.moreMenus]					= {"more_view"},

--	[HallScene.s_controls.compartmentBtn]				= {"more_view","moreMenus","compartment_btn"},
	[HallScene.s_controls.lfpBtn]						= {"surface_view","v_2" ,"btn_1"},
--	[HallScene.s_controls.singleBtn]					= {"more_view","moreMenus","single_btn"},
	[HallScene.s_controls.leftBamboo]					= {"left"},
	[HallScene.s_controls.rightBamBoo]					= {"right"},
	--[HallScene.s_controls.bottomImg]					= {"bottom"},
    [HallScene.s_controls.friend_fight]                 ={"friend_fight"},
}

-- 可操作控件的响应函数
HallScene.s_controlFuncMap =
{
--	[HallScene.s_controls.gameBtn] 					= HallScene.onClickedGameBtn,
	[HallScene.s_controls.btn_match] 				= HallScene.onClickedMatchBtn,
    [HallScene.s_controls.btn_more] 					= HallScene.onClickedMoreBtn,
--	[HallScene.s_controls.quickStartBtn] 			= HallScene.onClickedQuickStartBtn,
--	[HallScene.s_controls.compartmentBtn]			= HallScene.onClickedCompartmentBtn,
	[HallScene.s_controls.lfpBtn]					= HallScene.onClickedLfpBtn,
	[HallScene.s_controls.btn_single]				= HallScene.onClickedSingleBtn,
    [HallScene.s_controls.btn_addRoom]				= HallScene.onClickedAddRoom,
    [HallScene.s_controls.btn_createRoom]			= HallScene.onClickedCreateRoom,--onClickedCreateRoom
    [HallScene.s_controls.btn_xzdd]				= HallScene.onClickedXzdd,
    [HallScene.s_controls.btn_xlch]				= HallScene.onClickedXlch,
    [HallScene.s_controls.btn_lf]				= HallScene.onClickedLf,
}

-- 可接受的更新界面命令
HallScene.s_cmds =
{
	--updataUserInfo = 1,

}

-- 命令响应函数
HallScene.s_cmdConfig =
{
	--[HallSocialLayer.s_cmds.updataUserInfo] = HallSocialLayer.updataUserInfo,

}


HallScene.phpMsgResponseCallBackFuncMap =
{
	[PHP_CMD_REQUEST_PRIVATE_DI_ZHU_LIST] 		= HallScene.requestPrivateDiZhuListCallback,
	[PHP_CMD_UPLOAD_GE_TUI_CID] 				= HallScene.uploadGeTuiCid,
	[PHP_CMD_REQUIRE_WEB_PAY] 					= HallScene.requestMallDataCallBack,
	[PHP_CMD_REQUEST_EVALUATE_AWARD]            = HallScene.requestEvaluateAwardCallback,
    [PHP_CMD_REQEUST_VETERAN_PALYER_GIFT] = HallScene.requestVeteranPlayerGiftCallback,
}

-- 缓存处理函数
HallScene.cacheDataHttpCallBackFuncMap =
{
	[PHP_CMD_REQUEST_DETAIL_SIGN_INFO] 			=  HallScene.needRequestSignWnd;
	[PHP_CMD_REQUEST_FIRST_CHARGE_DATA] 		=  HallScene.needFirstChargeData;
};

HallScene.socketEventFuncMap = {
	[HALL_SERVER_COMMAND_LOGIN_SUCCESS] = HallScene.socketLoginSuccess,
	[HALL_CLIENT_GET_ROOM_LEVER_NUM] = HallScene.updataOnlinePlayerNum,
	[HALL_SERVER_RESPOND_JOIN_GAME2] = HallScene.joinGameRet,
	[SERVER_COMMAND_LOGOUT_SUCCESS] = HallScene.logOutSuccess,
	[SERVER_CMD_RES_CREATE_ROOM] = HallScene.createPrivateRoom,
	[SERVER_CMD_LIST_PRIVATE_ROOM3] = HallScene.getPrivateRoomList,
	[HALL_SERVER_RESPOND_ENTER_ROOM] = HallScene.enterPrivateRoom,
	--防沉迷
	[SERVER_COMMAND_FCM_NOTIFY] = HallScene.fcmNotify,
	-- 被踢出
	[HALL_SERVER_COMMAND_KICK_OUT] = HallScene.kickOut,
	[SERVER_BROADCAST_SYSCONMSG] = HallScene.broadcastSystemConMsg,
	[SERVER_COMMAND_MSG_NOTIFY] = HallScene.serverNoticeMsg,
	[SERVER_CMD_RETIRED_RECONNECTED] = HallScene.serverRetiredReconnected,
	[SERVER_MATCHSERVER_CMD]        = HallScene.serverSingUpMatchReceived,    --玩家报名参加比赛
	[SERVER_MATCHUPDATE_CMD]        = HallScene.phpNotice,
	[SERVER_MATCH_SIGNUP_RES]       = HallScene.receiveMatchSignUpRes,  --返回房间结果
	--[SERVER_COMMAND_LOGIN_SUCCESS] = HallScene.joinGameSuccess,-- 登陆房间
    -------------------------------
    [SERVER_COMMAND_LOGIN_SUCCESS]  = HallScene.isInRoomGame,--在大厅收到登录房间成功的消息 需要重连 进入房间
    [SERVER_BROADCAST_OUT_CARD]     = HallScene.isInRoomGame,--在大厅收到 广播出牌 的消息 需要重连 进入房间
    [SERVER_BROADCAST_START_GAME]   = HallScene.isInRoomGame,--在大厅收到 牌局开始 的消息 需要重连 进入房间

    [PHP_CMD_OPPO_REQUEST_VIP_EXP_REMIND] = HallScene.vipExpRemindCallBack, -- OPPO vip奖励提醒回调


    --[SERVER_CMD_RESPONSE_JOIN_BATTLE_PRE] = HallScene.processJoinBattlePre,
}
