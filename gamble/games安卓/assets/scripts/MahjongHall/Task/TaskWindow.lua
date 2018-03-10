-- 任务界面
--local taskCommon = require(ViewLuaPath.."taskCommon");
require("ui/listView")
require("MahjongHall/Task/TaskListItem");
require("MahjongHall/Task/ViewPushMoreGame");
require("MahjongHall/Task/TaskBenefitItem")

require("MahjongHall/hall_2_interface_base")

TaskWindow = class(hall_2_interface_base);

TaskWindow.State_daily = 1 --日常任务
TaskWindow.State_grow  = 2 --成长任务
TaskWindow.State_more  = 4 --互推系统
TaskWindow.State_benefit  = 3 --免费福利

TaskWindow.ctor = function ( self , delegate )
    if not delegate then
        return;
    end
--    g_GameMonitor:addTblToUnderMemLeakMonitor("Task",self)
	self.delegate = delegate;

    --设置基类的基础配置
    self:set_tag(GameConstant.view_tag.task);
    self:set_tab_title({"免费福利", "日常任务", "成长任务", "更多游戏"});
    self:set_tab_count(4);
    delegate.m_mainView:addChild(self)
    self:play_anim_enter();

end

TaskWindow.on_enter = function (self)
	self.mid = PlayerManager.getInstance():myself().mid;

	EventDispatcher.getInstance():register(NativeManager._Event,self,self.onCallEvent);
    --php
    EventDispatcher.getInstance():register(SocketManager.s_phpMsg, self, self.onPhpMsgResponse);

	self.taskContentInfo = {};
    self.curBenefitTaskData = {};


	self.subView   = self.m_v

    self.benefitBtn = self.m_btn_tab[1];
	self.dailyTaskBtn = self.m_btn_tab[2];
	self.growTaskBtn  = self.m_btn_tab[3];
    self.moreGameBtn  = self.m_btn_tab[4]

    local funSetPos = function (obj)
        local tmp = 120;
    	local x,y = obj.dailyTaskBtn:getPos()
    	obj.dailyTaskBtn:setPos(x+tmp, y)

    	x,y = obj.growTaskBtn:getPos()
    	obj.growTaskBtn:setPos(x+tmp, y)

    	x,y = obj.benefitBtn:getPos()
    	obj.benefitBtn:setPos(x+tmp, y)

        obj.moreGameBtn:setVisible(false);
    end

    if PlatformConfig.platformTrunk == GameConstant.platformType or GameConstant.platformType==PlatformConfig.platformIOSMainVesion then
        if GameConstant.checkType == kCheckStatusOpen  then
            self.moreGameBtn:setVisible(false)
        else
            self.moreGameBtn:setVisible(true)
        end
		if GameConstant.iosDeviceType>0 then
			if GameConstant.iosPingBiFee then
	            self.moreGameBtn:setVisible(false)
	        else
				self.moreGameBtn:setVisible(true)
	        end
		end
    else
    	funSetPos(self);
    end

    if GameConstant.checkType == kCheckStatusOpen  then
        funSetPos(self);
    end


    self:set_tab_callback(self,self.tab_click);

    self.m_content = new(Node);
    self.m_content:setSize(1182, 540);
    self.m_content:setFillRegion(true, 20, 15, 20, 30);
    self.m_content:setPos(-5, -6);
    self.m_bg:addChild(self.m_content);
	self.tasklistView = new(ListView, 0, 0, 0, 0);
    self.m_content:addChild(self.tasklistView);
    self.tasklistView:setFillParent(true, true);

	if PlatformConfig.platformWDJ == GameConstant.platformType or
       PlatformConfig.platformWDJNet == GameConstant.platformType then
		self.dailyTagImg:setFile("Login/wdj/Hall/Commonx/tag_red.png");
		self.growTagImg:setFile("Login/wdj/Hall/Commonx/tag_red.png");
    end
    ---------------

    if GameConstant.taskType and GameConstant.taskType == TaskWindow.State_benefit then
        self:set_light_tab(1);
        self:requireBenefitData();
    elseif GameConstant.taskType and GameConstant.taskType == TaskWindow.State_daily
            or GameConstant.taskType and GameConstant.taskType == TaskWindow.State_grow then
        self:set_light_tab(GameConstant.taskType == TaskWindow.State_daily and 2 or 3);
        self:requireTaskData();
    else
        self:set_light_tab(1);
        self:requireBenefitData();
    end

    DebugLog('Profile clicked task stop:'..os.clock(),LTMap.Profile)
end

TaskWindow.on_exit = function (self)
    umengStatics_lua(Umeng_TaskBack);
    
    Loading.hideLoadingAnim();
    GlobalDataManager.getInstance():requireTaskNum(); -- 请求一次任务数据
    GlobalDataManager.getInstance():updateScene();
end

TaskWindow.tab_click = function (self, index)
    --1:免费福利，2日常任务，3成长任务，4更多 游戏
    local t = {TaskWindow.State_benefit, TaskWindow.State_daily, TaskWindow.State_grow, TaskWindow.State_more};
    local sta = t[index];
    if sta then
        self:clickTag(sta);    
    end
end 

TaskWindow.clickTag = function ( self,sta )
    DebugLog("TaskWindow.clickTag :"..tostring(sta));
    local t = {[TaskWindow.State_benefit] = 1, [TaskWindow.State_daily] = 2, [TaskWindow.State_grow] = 3, [TaskWindow.State_more] = 4};
    local index = t[sta];
    if index then
        self:set_light_tab(index);
    end

    local fun = function (self, state, data, moreGameData)
        self.tasklistView:setVisible(not ( TaskWindow.State_more == state ));
        if self.m_moreGameView then
            self.m_moreGameView:setVisible(TaskWindow.State_more == state);
        end
        GameConstant.taskType = state;
  	    self.state = state;
        if state == TaskWindow.State_daily or state == TaskWindow.State_grow then
            if not data then
                self:requireTaskData();
            else
                self:createList(data);
            end
        elseif state == TaskWindow.State_benefit then
            if not data or #data < 1 then
                self:requireBenefitData();
            else
                self:createBenefitList(data);
            end
        elseif state == TaskWindow.State_more then
            if moreGameData then
                if not self.m_moreGameView then
                    self:requireMoreGamesData();
                end
            end
        end

    end

	if sta and sta == TaskWindow.State_daily then
		fun(self,TaskWindow.State_daily, self.curDailyTaskData, nil);
	elseif sta and sta == TaskWindow.State_grow then
        fun(self,TaskWindow.State_grow, self.curGrowTaskData, nil);
    elseif sta and sta == TaskWindow.State_more then
        fun(self,TaskWindow.State_more, nil, {});
    elseif sta and sta == TaskWindow.State_benefit then
        fun(self,TaskWindow.State_benefit, self.curBenefitTaskData, nil);
	end
end


TaskWindow.requireTaskData = function ( self )
	local param_data = {};
	param_data.mid = PlayerManager.getInstance():myself().mid;
	param_data.time = self.taskContentInfo.lastTime or 0;
	Loading.showLoadingAnim("正在努力加载中...");
	SocketManager.getInstance():sendPack( PHP_CMD_REQUEST_TASK_LIST, param_data);
end

--php请求更多游戏
TaskWindow.requireMoreGamesData = function ( self )
	Loading.showLoadingAnim("正在努力加载中...");
	SocketManager.getInstance():sendPack(PHP_CMD_REQUSET_GET_MORE_GAMES, {})
end

--php请求免费福利列表
TaskWindow.requireBenefitData = function ( self )
    Loading.showLoadingAnim("正在努力加载中...");

    local param_data = {};
    param_data.version = GameConstant.Version;
	SocketManager.getInstance():sendPack(PHP_CMD_BENEFIT, param_data);
end



TaskWindow.onRequestShareCallBack = function(self,isSuccess,data)
	if not isSuccess or not data then
        return;
    end
	if isSuccess then
		if 1 == data.status then
             if self.curBenefitTaskData then
                for i=1,#self.curBenefitTaskData do
                    local task = self.curBenefitTaskData[i];
                    if TaskBenefitItem.enum.share == task.type then
                        --标记当前任务已完成
                        task.status = 1;
                        task.isAward = 0;
                        self:createBenefitList(self.curBenefitTaskData);
                        break;
                    end
                end
            end
		end
	end
end



function TaskWindow:requestUpdateEvaluateTaskCallback( isSuccess, data )
    if not isSuccess or not data then
        return
    end
    DebugLog("update evaluate task progress...")
    if isSuccess then
        if 1 == data.status then
            DebugLog("1 == data.status");
            if self.curBenefitTaskData then
                for i=1,#self.curBenefitTaskData do
                    local task = self.curBenefitTaskData[i];
                    if TaskBenefitItem.enum.comment == task.type then
                        --标记当前任务已完成
                        task.status = 1;
                        task.isAward = 0;
                        self:createBenefitList(self.curBenefitTaskData);
                        break;
                    end
                end
            end
        end
    end
end



TaskWindow.requestGetBindPhoneAwardCallback = function ( self, isSuccess, data )
    DebugLog("TaskWindow requestGetBindPhoneAwardCallback")
	if not isSuccess or not data then
        return;
    end
	if isSuccess then
        if 1 == data.status then
            DebugLog("1 == data.status");
            if self.curBenefitTaskData then
                for i=1,#self.curBenefitTaskData do
                    local task = self.curBenefitTaskData[i];
                    if TaskBenefitItem.enum.bind == task.type then
                        --标记当前任务已完成
                        task.status = 1;
                        task.isAward = 1;
                        self:createBenefitList(self.curBenefitTaskData);
                        --增加金币
                        local money = tonumber(data.data.money)or 0;
                        PlayerManager.getInstance():myself():addMoney(money);

                        --金币掉落动画
                        showGoldDropAnimation();
                        AnimationAwardTips.play("绑定成功，恭喜获得"..tostring(money).."金币。");
                        break;
                    end
                end
            end
        end
    end
end

TaskWindow.requestTaskRewardCallBack = function ( self, isSuccess, data )
    DebugLog("TaskWindow.requestTaskRewardCallBack");
	if not isSuccess or not data then
        return;
    end
	if isSuccess then
		if 1 ~= data.status then
			Banner.getInstance():showMsg(data.msg)
			return;
		end
		local rewardMoney = tonumber(data.data.reward_money) or 0
        local id = tonumber(data.data.taskid)
        PlayerManager.getInstance():myself():addMoney(rewardMoney)
        AnimationAwardTips.play(data.msg)
        self:updataListView(id)
        GlobalDataManager.getInstance():updateLocalCoin()

        if rewardMoney > 0 then
        	showGoldDropAnimation();
        end
	else
		Banner.getInstance():showMsg("领奖失败，请您稍后重试！");
	end
end

-- 领奖成功后更新列表：id领奖的taskid
TaskWindow.updataListView = function ( self, id )
    if self.curDailyTaskData then
    	for i=1,#self.curDailyTaskData do
            local task = self.curDailyTaskData[i];
            if id == task.taskId then
                table.remove(self.curDailyTaskData, i);
                self:createList(self.curDailyTaskData);
                break;
            end
        end
    end

    if self.curGrowTaskData  then
        for i=1,#self.curGrowTaskData do
            local task = self.curGrowTaskData[i];
            if id == task.taskId then
                table.remove(self.curGrowTaskData, i);
                self:createList(self.curGrowTaskData);
                break;
            end
        end
    end

    if self.curBenefitTaskData then
        for i=1,#self.curBenefitTaskData do
            local task = self.curBenefitTaskData[i];
            if id == task.taskid then
                --标记当前任务已完成
                task.status = 1;
                task.isAward = 1
                self:createBenefitList(self.curBenefitTaskData);
                break;
            end
        end
    end
end

-- 领奖
TaskWindow.listItemcallBack = function ( self, data )
	DebugLog("TaskWindow listItemcallBack 1");
	if "1" == data.isJump then -- 去做任务
		DebugLog("TaskWindow listItemcallBack 2");
		if GameConstant.curGameSceneRef ~= HallScene_instance then
			self:hide();
			return;
		end
		local jump = tonumber(data.jump); -- -4跳到大厅，其它值：对应场次level，无具体场次要求为-1，支付类为-2
		if -4 == jump then--分享
			if not GameConstant.shareMessage then
				return;
			end
			-- 添加微信朋友圈分享内容
			if GameConstant.isWechatInstalled then
				GameConstant.shareMessage.style = 1;
				native_to_java(kShareMessage,json.encode(GameConstant.shareMessage));
			elseif GameConstant.isQQInstalled then
				GameConstant.shareMessage.style = 2;
				native_to_java(kShareMessage,json.encode(GameConstant.shareMessage));
            else
                Banner.getInstance():showMsg("尚未安装qq或者微信");
			end

		elseif -1 == jump then--无场次要求
			self:hide();
			GameConstant.curGameSceneRef:requestQuickStartGame();
		elseif -2 == jump then--支付类
			self:hide();
			GameConstant.curGameSceneRef:enterMallWindow();
		elseif -3 == jump then --签到
			self:hide();
			GameConstant.curGameSceneRef:pushSignWindow();
        elseif -5 == jump then --去评价
            self:handleEvaluate()
		elseif jump then
			self:hide();
			GameConstant.curGameSceneRef:toRoom( jump );
		end
		return;
	end
	local param_data = {};
	param_data.mid = PlayerManager.getInstance():myself().mid;
    param_data.taskid = data.taskId;
    DebugLog("request award: ")
    mahjongPrint(param_data)
    Loading.showLoadingAnim("正在努力加载中...");--loading.show要放在http execute之前，这样execute失败时 才会取消掉动画  不然一直转圈
	SocketManager.getInstance():sendPack( PHP_CMD_REQUEST_TASK_REWARD, param_data);

end

function TaskWindow:handleEvaluate(  )
    native_to_get_value(kGetMarketNum);
    local marketNum = dict_get_int(kGetMarketNum, kGetMarketNum .. kResultPostfix, 0)
    if marketNum ~= 0 then

        publ_launchTargetMarket()

        self.requestUpdateEvaluateAnim = new(AnimInt , kAnimNormal, 0, 1, 1000, 0)
        self.requestUpdateEvaluateAnim:setEvent(self , self.delayRequestUpdateEvaluateTimer)


    end
end

--延时处理
function TaskWindow:delayRequestUpdateEvaluateTimer(  )
    local param = {}
    param.taskid = self.evaluateTaskId
    SocketManager.getInstance():sendPack(PHP_CMD_REQUEST_UPDATE_EVALUATE_TASK, param)
    delete(self.requestUpdateEvaluateAnim)
end

-- 创建列表
TaskWindow.parseDataAndCreateListView = function ( self )

	DebugLog("TaskWindow.parseDataAndCreateListView")
	-- 任务内容
	local taskContentInfo = self.taskContentInfo;
	local taskContent = taskContentInfo.allTaskContent;

	-- 任务状态
	local taskStatusInfo = self.taskStatusInfo;
	local dailyTaskStatus = taskStatusInfo.taskStatus;

	self.curDailyTaskData = {};
	self.curGrowTaskData  = {};

	local rewardMap = {}
	mahjongPrint(dailyTaskStatus)

	for k,v in pairs(dailyTaskStatus) do
		local recordData = publ_deepcopy(v);
		local num=tonumber(v.taskId);
		for m,t in pairs(taskContent) do
			if num == t.taskId then
				for key , value in pairs(t) do
					recordData[key] = value;
				end
			end
		end
		if 0 ~= v.reward  then -- 服务器传了金币过来，刷新金币
			recordData.reward = v.reward;
		end
		recordData.w = 770 - 4;
		recordData.h = 100;
		recordData.obj = self;
		recordData.callbackFun = TaskWindow.listItemcallBack;

		if tonumber(recordData.task_type) == 2 then --1表示每日任务 2表示成长任务
			table.insert(self.curGrowTaskData, recordData);
		else
			table.insert(self.curDailyTaskData, recordData);
		end
	end

end

TaskWindow.defaultClick = function( self )
	DebugLog("TaskWindow.defaultClick")

	return true
end

function sortFun( s1, s2 )
	if s1.top ~= s2.top then
		return (s1.top == 1)
	elseif  s1.status ~= s2.status then
		return s1.status == 2
	else
		return s1.task_index < s2.task_index
	end
end

TaskWindow.createList = function ( self, data )
	--self.nodeList:removeAllChildren();
	if data and #data > 0 then
		table.sort(data, sortFun);
		local adapter = new(CacheAdapter, TaskListItem, data);
		self.tasklistView:setAdapter(adapter);
	else
		self.tasklistView:setAdapter(nil);
	end
end

--更新免费福利界面绑定按钮
TaskWindow.setBenefitBindItemStateAward = function (self)
    local views = self.tasklistView.m_views;
    for i = 1, #views do
        if views[i] and views[i].data and views[i].data.type == TaskBenefitItem.enum.bind then
            views[i].data.status = 1;
            views[i].data.isAward = 0;
            views[i]:setBind();
        end
    end
end

--创建免费福利列表
TaskWindow.createBenefitList = function ( self, data )
    local showData = {}
	if data and #data > 0 then
        local tmp, tmp_1, tmp_2, tmp_3 = {},{},{},{}
        --把可以领奖的放在上面
        for k, v in ipairs(data) do
            if v.status == 1 or (v.type == TaskBenefitItem.enum.bankrupt and v.status == 0)then
                table.insert(tmp_1, v)
            elseif v.isAward  == 1 then
                table.insert(tmp_3, v)
            else
                table.insert(tmp_2, v)
            end
        end
        local util = function(t1, t2)
            for i = 1, #t2 do
                table.insert(t1, t2[i])
            end
        end
        util(tmp, tmp_1);
        util(tmp, tmp_2);
        util(tmp, tmp_3);
        data = tmp;

        for k, v in pairs(data) do
            if tonumber(v.type) == TaskBenefitItem.enum.bind then
                if not(GameConstant.checkType == kCheckStatusOpen
                    or (PlatformConfig.platformTrunk ~= GameConstant.platformType and
                    PlatformConfig.platformBaiDuCps ~= GameConstant.platformType and
                    PlatformConfig.platformMMCps ~= GameConstant.platformType)) then --绑定手机
                    table.insert(showData, v)
                end
            elseif tonumber(v.type) == TaskBenefitItem.enum.versionUpdate then
                if GameConstant.checkType == kCheckStatusClose then                  --版本更新
                    table.insert(showData, v)
                end
            elseif tonumber(v.type) == TaskBenefitItem.enum.moreGame then            --更多游戏
                 if not(GameConstant.checkType == kCheckStatusOpen
                    or (PlatformConfig.platformTrunk ~= GameConstant.platformType)) then
                    table.insert(showData, v)
                end
            else
                table.insert(showData, v)
            end
        end
        self.tasklistView:setAdapter(nil);
		local adapter = new(CacheAdapter, TaskBenefitItem, showData);
		self.tasklistView:setAdapter(adapter);
	else
		self.tasklistView:setAdapter(nil);
	end
end

-- old sort
function taskSort(s1,s2)
	return s2.key > s1.key;
end

TaskWindow.requestTaskListCallBack = function ( self, isSuccess, data )
	DebugLog( "TaskWindow.requestTaskListCallBack" );
	mahjongPrint( data );
	if not isSuccess or not data then
        return;
    end
	if isSuccess then
		------------任务状态----------------
		self.taskStatusInfo = {
			taskStatus = {};
		}
        if data.user_task then
            for k , v in pairs(data.user_task) do
			    local taskId = tonumber(v.id)
			    local statusTb = {
				    key = tonumber(k),
				    taskId = taskId,
				    process = tonumber(v.process),
				    status = tonumber(v.status),
				    reward = tonumber(v.reward or 0),
			    };
			    self.taskStatusInfo.taskStatus[k]=statusTb;
		    end
        end


		---------------------任务内容--------------------
		if data.time and data.time ~= nil then
			self.taskContentInfo = {
				allTaskContent = {},
				lastTime = tonumber(data.time) or 0,
				img_prefix=data.img_prefix,
			}
			DebugLog( "self.taskContentInfo.lastTime = "..self.taskContentInfo.lastTime );
			local taskContent = self.taskContentInfo;
            if data.list then
			    for k , v in pairs(data.list) do
				    local taskId = tonumber(k);
				    local contentTb = {
					    taskId = taskId;
					    taskName = GameString.convert2Platform(v.type_name),--任务类别 每日任务 or 成长任务
					    goal = tonumber(v.goal),						--任务目标
					    desc = GameString.convert2Platform(v.desc),			--任务标题
					    reward = v.reward,									--奖励金币数
					    in_room = v.in_room	,							--是否在房间中(左侧栏)显示
					    jump = tonumber(v.jump),--------------对应场次level，无具体场次要求为-1，支付类为-2, 签到为-3， 分享为-4

					    type_name = v.type_name,--任务类别 每日任务 or 成长任务

					    play_type  = v.type,--0随机，1血流，2血战
					    task_type  = v.task_type,--1表示每日任务 2表示成长任务
					    task_index = v.index,--排序
					    needmsg    = v.needmsg,--是否展示描述
					    msg        = v.msg,--描述内容(展示描述，不展示进度)
					    top        = v.top,

					    img = self.taskContentInfo.img_prefix .. taskId ..".png",
					    NativeManager.getInstance():downloadImage(img),
				    };
				    if contentTb.jump == -4 then
					    self.shareTaskId = contentTb.taskId;
				    end
                    if contentTb.jump == -5 then
                        self.evaluateTaskId = contentTb.taskId
                    end
				    taskContent.allTaskContent[k] = contentTb;
			    end
            end
		end
		self:parseDataAndCreateListView();
	else
		Banner.getInstance():showMsg("获取任务数据失败，请稍后再试！");
	end

    self:clickTag(GameConstant.taskType or self.State_daily);
	DebugLog( "self.taskContentInfo.lastTime = "..tostring(self.taskContentInfo.lastTime) );
end

TaskWindow.onCallEvent = function(self, param, data)
    DebugLog("TaskWindow.onCallEvent");
	if kMutiShare == param then
        DebugLog("kMutiShare");
		local param_data = {};
		param_data.mid 		= PlayerManager.getInstance():myself().mid;
		SocketManager.getInstance():sendPack( PHP_CMD_REQUEST_NOTICE_PHP_SHARE, param_data);

	end
end

--显示/隐藏互推界面--界面重新创建，但是数据只拉取一次
TaskWindow.showMoreGameView = function (self, bShow, data)
    bShow = bShow or true;

    if bShow == false or not data then
        return;
    end
    if self.state ~= TaskWindow.State_more then
        return;
    end
    if bShow == true and data then
        if self.m_moreGameView then
            self.m_moreGameView:removeFromSuper();
            self.m_moreGameView = nil;
        end

        self.m_moreGameView = new(ViewPushMoreGame, self.curMoreGameData);
        self.m_content:addChild(self.m_moreGameView);
    end
end

TaskWindow.dtor = function ( self )
	DebugLog("TaskWindow.dtor........................................................")

    self.super.dtor(self);

	self.taskContentInfo = nil
	self.curDailyTaskData = nil
	self.curGrowTaskData = nil
	self.tasklistView:setAdapter(nil)

	EventDispatcher.getInstance():unregister(SocketManager.s_phpMsg, self, self.onPhpMsgResponse);
	EventDispatcher.getInstance():unregister(NativeManager._Event,self,self.onCallEvent);
	GlobalDataManager.getInstance():updateScene();
	self:removeAllChildren();
end

--http 数据回调
TaskWindow.requestMoreGamesCallBack = function (self, isSuccess, data)
	DebugLog("[TaskWindow.requestLoginCallBack]")
    if isSuccess and data then
		mahjongPrint(data)
        --标记已发送过一次php 下次请求不再发，直接用缓存
       -- GameConstant.isSendPhpMoreGames = true;
        if 1 ~= tonumber(data.status or 0) then
            Banner.getInstance():showMsg(data.msg or "");
            return;
	    end

        self.curMoreGameData = {};
        local len = #data.data;
        for i = 1, len do
            local dd = data.data[i];
            local d = {};
            d.gameid = dd.gameid
            d.desc = dd.desc
            d.gname = dd.gname
            d.sort = dd.sort
            d.qrcode = dd.qrcode
            d.shortdesc = dd.shortdesc
            d.url = dd.url
            d.dl = dd.dl
            d.icon = dd.icon
            d.hasBeenAwarded = dd.hasBeenAwarded
            d.pkgsize = tonumber(dd.pkgsize)
            d.pkgname = dd.pkgname
            d.awards = dd.awards
            table.insert(self.curMoreGameData, d);
        end
        self:showMoreGameView( true, self.curMoreGameData);
    end

end

--http 数据回调
TaskWindow.requestBenefitCallBack = function (self, isSuccess, data)
	DebugLog("[TaskWindow.requestBenefitCallBack]")

    self.curBenefitTaskData = {};
    if isSuccess and data and data.data then
        mahjongPrint(data)

        for i = 1, #data.data do
            local recvData = data.data[i];
            local d = {};
            d.title =  recvData.title;
            d.desc = recvData.desc;
            d.icon = recvData.icon;
            d.award = tonumber(recvData.award) or 0;
            d.status = tonumber(recvData.status) or 0;
            d.isAward = tonumber(recvData.isAward) or 0;
            d.type = recvData.type;
            d.taskid = tonumber(recvData.taskid) or 0;
            d.btntitle = recvData.btntitle or "";
            d.obj = self;
			--ios 屏蔽
			if GameConstant.iosDeviceType>0 then
				if GameConstant.iosPingBiFee then
					if d.type==2 or d.type==7 or d.type==9 then
						table.insert(self.curBenefitTaskData, d);
					end
				else
					table.insert(self.curBenefitTaskData, d);
				end
			else
				table.insert(self.curBenefitTaskData, d);
			end
        end

        self:clickTag(TaskWindow.State_benefit)
    end
end


TaskWindow.onPhpMsgResponse = function( self, param, cmd, isSuccess,...)
	Loading.hideLoadingAnim();
	if self.phpMsgResponseCallBackFuncMap[cmd] then
		self.phpMsgResponseCallBackFuncMap[cmd](self,isSuccess,param,...)
	end
end

--global parameters to request the http,saving for a map.
TaskWindow.phpMsgResponseCallBackFuncMap =
{
    [PHP_CMD_BENEFIT] =  TaskWindow.requestBenefitCallBack,
	[PHP_CMD_REQUSET_GET_MORE_GAMES] = TaskWindow.requestMoreGamesCallBack,
	[PHP_CMD_REQUEST_TASK_LIST]		 = TaskWindow.requestTaskListCallBack,
	[PHP_CMD_REQUEST_TASK_REWARD]	 = TaskWindow.requestTaskRewardCallBack,
	[PHP_CMD_REQUEST_NOTICE_PHP_SHARE] = TaskWindow.onRequestShareCallBack,
    [PHP_CMD_REQUEST_UPDATE_EVALUATE_TASK] = TaskWindow.requestUpdateEvaluateTaskCallback,
    [PHP_CMD_GET_AWARD_BIND_PHONE] = TaskWindow.requestGetBindPhoneAwardCallback,
};
