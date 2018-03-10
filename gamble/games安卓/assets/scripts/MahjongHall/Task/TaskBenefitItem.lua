require("ui/node");
require("ui/image");
require("ui/text");
require("ui/button");
require("core/gameString");
require("MahjongHall/Friend/NewFriendView")
require("MahjongHall/Friend/MailWindow");
local taskListItem = require(ViewLuaPath.."taskListItem");
TaskBenefitItem = class(Node)

TaskBenefitItem.enum = {
    sign = 1,--登录抽奖
    bankrupt = 2,-- 破产补助
    share = 3,--每日分享
    comment = 4,--五星好评
    goldBox = 5,--牌局宝箱
    inviteFriend = 6,--邀请好友
    bind = 7,--绑定账号
    versionUpdate = 8,--版本更新
    friendFeedback = 9,--好友赠送
    moreGame = 10,--更多游戏
};


TaskBenefitItem.ctor = function(self, data)
	if not data then
		return;
	end


    EventDispatcher.getInstance():register(NativeManager._Event, self, self.nativeCallEvent);

    self.listItem = SceneLoader.load(taskListItem);
    self:addChild(self.listItem);
    self:setSize(self.listItem:getSize());

    self.timeSeq = 100;

    self.data = data;
    if self.data.type == self.enum.bankrupt then
        self.data.obj.benefitItem = self;
    end

    if self.data.type == self.enum.comment then
        self.data.obj.evaluateTaskId = data.taskid;
    end
    
    local taskName= data.title;
    local btnName = data.btntitle;
    local taskType = tonumber(data.type) or 0;
    local award = tonumber(data.award) or 0;
    local isAward = tonumber(data.isAward) or 0;
    local imgUrl = data.icon or "";
    local desc = data.desc or "";
    local status = tonumber(data.status) or 0;          ---任务状态1:进行中  2:已完成,--可以领奖 


    --设置icon
    local isExist , localDir = NativeManager.getInstance():downloadImage(imgUrl);
    self.localDir = localDir; -- 下载图片
    if isExist then -- 图片已下载
        publ_getItemFromTree(self.listItem, {"item_view","img_icon"}):setFile(self.localDir);
    end

    publ_getItemFromTree(self.listItem, {"item_view", "view_info", "view_info_2"}):setVisible(false)


    --设置任务描述
    local text_title = publ_getItemFromTree(self.listItem, {"item_view", "view_info", "view_info_1", "text_desc"});
    text_title:setText(GameString.convert2Platform(taskName) or " ");
    
    publ_getItemFromTree(self.listItem, {"item_view", "view_info", "view_desc"}):setVisible(true);
    local text_desc = publ_getItemFromTree(self.listItem, {"item_view", "view_info", "view_desc", "text"});
    local str_desc = stringFormatWithString(desc, 40, false);--长度限制 20个字
    text_desc:setText(GameString.convert2Platform(str_desc) or " ");
    self.text_desc = text_desc;

    local t_award = publ_getItemFromTree(self.listItem, {"item_view", "view_info", "view_info_1", "t"});
    if award > 0 then
        t_award:setVisible(true);
        local str = "奖励: "..stringFormatWithString(tostring(award), 10, false).."金币";
        t_award:setText(str);
    end
    --只有这三个显示reward text
    if taskType == self.enum.comment or taskType == self.enum.share or taskType == self.enum.inviteFriend then
        t_award:setVisible(true);
    else
        t_award:setVisible(false);
    end

    self.btn_get = publ_getItemFromTree(self.listItem, {"item_view", "btn_get"});
    self.btn_get.t = publ_getItemFromTree(self.btn_get, {"text_title"});
    self.btn_get.t:setText(self.data.btntitle or "去做任务");

    if taskType == self.enum.sign then
        self:setSign();
    elseif taskType == self.enum.bankrupt then
        self:setBankrupt();
    elseif taskType == self.enum.comment then
        self:setComment();
    elseif taskType == self.enum.goldBox then
        self:setGoldBox();
    elseif taskType == self.enum.inviteFriend then
        self:setInviteFriend();
    elseif taskType == self.enum.bind then
        self:setBind();
    elseif taskType == self.enum.versionUpdate then
        self:setVersionUpdate();
    elseif taskType == self.enum.friendFeedback then
        self:setFriendFeedback();
    elseif taskType == self.enum.moreGame then
        self:setMoreGame();
    elseif taskType == self.enum.share then
        self:setShare();
    end
end



TaskBenefitItem.setSign = function (self)
    
    self.btn_get:setFile("Commonx/yellow_bg_wide_btn.png");
    self.btn_get:setOnClick(self, function ( self )
        if HallScene_instance then
            DebugLog("TaskBenefitItem go to sign");
            HallScene_instance:pushSignWindow();
        end
    end);
end

--领取破产补助
TaskBenefitItem.takeBankrupt = function (self)
    umengStatics_lua(kUmengBankruptAwardCoinBtn);
	local param_data = {};
	param_data.mid = PlayerManager.getInstance():myself().mid;
	param_data.sitemid = SystemGetSitemid();

	SocketManager.getInstance():sendPack( PHP_CMD_GET_BANKRAPTCY_REMEDY,param_data )
end

TaskBenefitItem.setBankrupt = function (self)
    local str, str_desc = "", "";
--    --未破产
    local status = tonumber(self.data.status) or -1;
    if status == -1 then
        --str = "未破产";
        str_desc = "破产后可以领取金币补助";
        self.btn_get:setIsGray(true);
        self.btn_get:setPickable(false);
    elseif status == -2 then
        --str = "已领取";
        str_desc = "破产补助已领完";
        self.btn_get:setIsGray(true);
        self.btn_get:setPickable(false);
    elseif status == 0 then
        --str = "领取奖励";
        str_desc = "当前可领取破产补助";
        self.btn_get:setFile("Commonx/green_big_wide_btn.png");
    elseif status > 0 then
        --str = "领取补助";
        self.btn_get:setFile("Commonx/yellow_bg_wide_btn.png");
        --定时器
        self:loadTime(status);
    end
    if status <= 0 then
        self:stopTime();
    end
    str = "领取奖励";
    self.text_desc:setText(str_desc);
    self.btn_get.t:setText(str);

    self.btn_get:setOnClick(self, function ( self )
        local status = tonumber(self.data.status) or -1;
        if status > 0 and HallScene_instance then
            GlobalDataManager.getInstance():showBankruptDlg(nil,self.data.obj, self.bankruptCloseCallFun);
        elseif status == 0 then
            self:takeBankrupt();
            str = "未破产";
            str_desc = "破产后可以领取金币补助";
            self.btn_get:setIsGray(true);
            self.btn_get:setPickable(false);
            if HallScene_instance and HallScene_instance.m_bottomLayer and HallScene_instance.m_bottomLayer.taskWindow then
                local data = HallScene_instance.m_bottomLayer.taskWindow.curBenefitTaskData;
                if data then
                    for i = 1, #data do
                        if data[i].type == TaskBenefitItem.enum.bankrupt then
                            data[i].status = -1;
                            break;
                        end
                    end
                end
            end
        end
    end);

end

TaskBenefitItem.bankruptCloseCallFun = function (obj)

    if not obj or not obj.benefitItem then
        return;
    end
    --因为破产的弹出框界面也有领取破产补助，所以如果在那个界面，领取过补助，关闭窗口回来后要判断下 是否还是破产的状态
    if (tonumber(PlayerManager.getInstance():myself().money)) >= GameConstant.bankruptMoney then
        if obj.benefitItem.data then
            obj.benefitItem.data.status = -1;
        end
        if obj.benefitItem.setBankrupt then
            obj.benefitItem:setBankrupt();
        end
    end

end
--
TaskBenefitItem.uitl_get_award = function (self)
    DebugLog("TaskBenefitItem.uitl_get_award");

	local param_data = {};
	param_data.mid = PlayerManager.getInstance():myself().mid;
    param_data.taskid = self.data.taskid;
    DebugLog("request award: ")
    mahjongPrint(param_data)
    --Loading.showLoadingAnim("正在努力加载中...");
	SocketManager.getInstance():sendPack( PHP_CMD_REQUEST_TASK_REWARD, param_data);
end

TaskBenefitItem.get_award_bind_phone = function (self)
    DebugLog("TaskBenefitItem.get_award_bind_phone");

	local param_data = {};
	param_data.mid = PlayerManager.getInstance():myself().mid;
    mahjongPrint(param_data)
    --Loading.showLoadingAnim("正在努力加载中...");
	SocketManager.getInstance():sendPack( PHP_CMD_GET_AWARD_BIND_PHONE, param_data);
end


--
TaskBenefitItem.util_set_btn_state = function (self)
    local str = "";
    if self.data.isAward == 1 then
        str = "已领取";
        self.btn_get:setIsGray(true);
        self.btn_get:setPickable(false);
    else
        if self.data.status == 1 then
            str = "领取奖励";
            self.btn_get:setFile("Commonx/green_big_wide_btn.png");
        else
            str = self.data.btntitle or "去做任务";
            self.btn_get:setFile("Commonx/yellow_bg_wide_btn.png");
        end
    end

    self.btn_get.t:setText(str);
end

TaskBenefitItem.setComment = function (self)
    self:util_set_btn_state();
    self.btn_get:setOnClick(self, function ( self )
        if self.data.obj and self.data.obj.handleEvaluate then
            DebugLog("TaskBenefitItem go to comment");
            --领取奖励
            if self.data.status == 1 and self.data.isAward == 0 then
                self:uitl_get_award();
                return;
            else 
                --去做任务
                self.data.obj:handleEvaluate();
            end
        end;
    end);
end

TaskBenefitItem.setGoldBox = function (self)

    self.btn_get:setFile("Commonx/yellow_bg_wide_btn.png");
    self.btn_get:setOnClick(self, function ( self )
        DebugLog("TaskBenefitItem go to game box");
        if HallScene_instance then
            HallScene_instance:requestQuickStartGame(); 
        end
    end);
end

TaskBenefitItem.setInviteFriend = function (self)

    self:util_set_btn_state();
    self.btn_get:setOnClick(self, function ( self )
        DebugLog("TaskBenefitItem go to invite friend");

        --领取奖励
        if self.data.status == 1 and self.data.isAward == 0 then
            self:uitl_get_award();
            return;
        end

        --去做任务
        if not HallScene_instance then
            return;
        end

        self.data.obj:play_anim_exit( HallScene_instance,function ( ref )

            ref.friendView = new(NewFriendView, ref)
      
            ref.friendView:set_callback_exit(ref, function(obj, bs)
                obj.friendView = nil;
            end );

            ref.friendView.m_data.viewType = 2
--            ref.friendView:refreshView()
        end, false)
        
   end);
end

TaskBenefitItem.setBind = function (self)
    self:util_set_btn_state();
    self.btn_get:setOnClick(self, function ( self )
        DebugLog("TaskBenefitItem go to bind");
        --领取奖励
        if self.data.status == 1 and self.data.isAward == 0 then
            self:get_award_bind_phone();
            return;
        end

        require("MahjongLogin/LoginMethod/CellphoneLogin")
        CellphoneLoginWindow:showViewBind();
    end);
end

TaskBenefitItem.setVersionUpdate = function (self)

    self.btn_get:setFile("Commonx/yellow_bg_wide_btn.png");
    self.btn_get:setOnClick(self, function ( self )
        DebugLog("TaskBenefitItem go to version update");
        GlobalDataManager.getInstance():requestUpdateVersionInfo( 1 );
    end);

end

TaskBenefitItem.setFriendFeedback = function (self)
    
    self.btn_get:setFile("Commonx/yellow_bg_wide_btn.png");
    self.btn_get:setOnClick(self, function ( self )
        DebugLog("TaskBenefitItem go to friend feedback");
        if not HallScene_instance then
            return;
        end
        self.data.obj:play_anim_exit(HallScene_instance,function ( ref )

            ref.mailWindow = new(MailWindow, ref)
            --ref.mailWindow:show();
            ref.mailWindow:set_callback_exit(ref, function(obj, bs)
                ref.mailWindow = nil;
            end);

        end, false )
    end);
end

TaskBenefitItem.setMoreGame = function (self)

    self.btn_get:setFile("Commonx/yellow_bg_wide_btn.png");
    self.btn_get:setOnClick(self, function ( self )
        DebugLog("TaskBenefitItem go to more game");
        self.data.obj:clickTag(TaskWindow.State_more);
    end);
end

TaskBenefitItem.setShare = function (self)
    self:util_set_btn_state();
    self.btn_get:setOnClick(self, function ( self )
        DebugLog("TaskBenefitItem go to share");
        --领取奖励
        if self.data.status == 1 and self.data.isAward == 0 then
            self:uitl_get_award();
            return;
        else
            --去做任务
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
        end
    end);
end


TaskBenefitItem.loadTime = function ( self, time )
	-- body
	self.time = time;
	self.sysTime = os.time();

	self:update();
	local timer = self:addPropTranslate(self.timeSeq, kAnimRepeat, 1000, 0, 0, 0, 0, 0);
	timer:setDebugName(" TaskBenefitItem||timer ");
	timer:setEvent(self, self.run);
end

TaskBenefitItem.stopTime = function (self)
    self:removeProp(self.timeSeq);
end

TaskBenefitItem.run = function ( self )
	local deltaSysTime = os.time() - self.sysTime ;
	--校正时间
	if deltaSysTime >= 3 then
		self.time 	 = self.time - deltaSysTime;
	end

	self.sysTime = self.sysTime + deltaSysTime;

	if self.time <= 0 then

		self.time = 0;
		self:update();
		
        self.data.status = 0;
        self:setBankrupt();

        self:removeProp(self.timeSeq);
		return ;
	end

	self:update();
	self.time = self.time - 1;
end

TaskBenefitItem.update = function ( self )
	local mm = math.floor(self.time / 600);
	local m  = math.floor((self.time - mm * 600) / 60);
	local ss = math.floor((self.time - mm * 600 - m * 60 ) / 10);
	local s  = math.floor((self.time - mm * 600 - m * 60 - ss * 10));
    local str = "";
    if mm > 0 or m > 0 then
        str = mm..m.."分";
    end

	str = str..ss..s.."秒后可以领取破产补助";
    self.text_desc:setText(str);
end

TaskBenefitItem.dtor = function(self)
    EventDispatcher.getInstance():unregister(NativeManager._Event, self, self.nativeCallEvent);
	self:removeAllChildren();
end

TaskBenefitItem.nativeCallEvent = function(self, _param, _detailData)
    if _param == kDownloadImageOne then
        if _detailData == self.localDir then
            publ_getItemFromTree(self.listItem, { "item_view", "img_icon" }):setFile(self.localDir);
        end
    end
end

