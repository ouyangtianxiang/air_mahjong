local taskListItem = require(ViewLuaPath.."taskListItem");
TaskListItem = class(Node)


TaskListItem.ctor = function(self, data)
	if not data then
		return;
	end

    EventDispatcher.getInstance():register(NativeManager._Event, self, self.nativeCallEvent);

    self.listItem = SceneLoader.load(taskListItem);
    self:addChild(self.listItem);
    self:setSize(self.listItem:getSize());

    self.data = data;
    local taskName=data.taskName;
    local taskId = data.taskId or 0;
    local reward = data.reward or 0;
    local goal = tonumber(data.goal) or -1;         --任务目标
    local imgUrl = data.img or "";
    local desc=data.desc or "";
    local in_room=data.in_room or 0;
    local jump = data.jump or -4; -- -4跳到大厅，其它值：对应场次level，无具体场次要求为-1，支付类为-2
    local status = data.status;          ---任务状态1:进行中  2:已完成，可以领奖 
    local process = tonumber(data.process) or -1;   -------任务进度

    --设置icon
    local isExist , localDir = NativeManager.getInstance():downloadImage(imgUrl);
    self.localDir = localDir; -- 下载图片
    if isExist then -- 图片已下载
        publ_getItemFromTree(self.listItem, {"item_view","img_icon"}):setFile(self.localDir);
    end

    if data.needmsg == 1 then 
         publ_getItemFromTree(self.listItem, {"item_view", "view_info", "view_info_2"}):setVisible(false)
         publ_getItemFromTree(self.listItem, {"item_view", "view_info", "view_desc"}):setVisible(true)
         publ_getItemFromTree(self.listItem, {"item_view", "view_info", "view_desc", "text"}):setText(data.msg)
    end 


    --设置任务描述
    -- publ_getItemFromTree(self.listItem, {"item_view", "view_info", "view_info_1", "text_desc"}):setText(GameString.convert2Platform(desc .. "(" .. (taskName or "") .. ")") or " ");
    publ_getItemFromTree(self.listItem, {"item_view", "view_info", "view_info_1", "text_desc"}):setText(GameString.convert2Platform(desc) or " ");
    --设置任务进度
    publ_getItemFromTree(self.listItem, {"item_view", "view_info", "view_info_2", "img_progress_bg", "text_progress"}):setText(process .. "/" .. goal);
    local progressImg = publ_getItemFromTree(self.listItem, {"item_view", "view_info", "view_info_2", "img_progress_bg", "img_progress"});
    local progressImgW, progressImgH = progressImg:getSize();
    progressImg:setClip(0,0,process * progressImgW / goal,progressImgH);
    --设置任务奖励
    publ_getItemFromTree(self.listItem, {"item_view", "view_info", "view_info_2", "text_award_value"}):setText(trunNumberIntoThreeOneFormWithInt(reward,false));

    --设置任务状态
    if status == 1 then         ---进行中
        publ_getItemFromTree(self.listItem, {"item_view", "btn_get"}):setFile("Commonx/yellow_bg_wide_btn.png");
        publ_getItemFromTree(self.listItem, {"item_view", "btn_get", "text_title"}):setText(GameString.convert2Platform("去做任务"));

         local param = {};
        param.isJump = "1";
        param.jump = jump;
        publ_getItemFromTree(self.listItem, {"item_view", "btn_get"}):setOnClick(self, function ( self )
            if data.callbackFun then
                DebugLog(taskId);
                DebugLog(desc);
                DebugLog(jump);
                data.callbackFun(data.obj, param);
            end
        end);

    elseif status == 2 then     -- 已完成

        publ_getItemFromTree(self.listItem, {"item_view", "btn_get"}):setFile("Commonx/green_big_wide_btn.png");

        publ_getItemFromTree(self.listItem, {"item_view", "btn_get", "text_title"}):setText(GameString.convert2Platform("领取奖励"));
        publ_getItemFromTree(self.listItem, {"item_view", "btn_get"}):setOnClick(self, function ( self )
            if data.callbackFun then
                data.callbackFun(data.obj, data);
            end
        end);

    else
        publ_getItemFromTree(self.listItem, {"item_view", "btn_get"}):setVisible(false);
    end

    if PlatformConfig.platformWDJ == GameConstant.platformType or 
        PlatformConfig.platformWDJNet == GameConstant.platformType then 
        publ_getItemFromTree(self.listItem, {"item_view","view_info","view_info_2","img_progress_bg"}):setFile("Login/wdj/Hall/task/progress.png");
        publ_getItemFromTree(self.listItem, {"item_view","img_line"}):setFile("Login/wdj/Hall/task/item_bg.png");

    end
end

TaskListItem.dtor = function(self)
    EventDispatcher.getInstance():unregister(NativeManager._Event, self, self.nativeCallEvent);
	self:removeAllChildren();
end

TaskListItem.nativeCallEvent = function(self, _param, _detailData)
    if _param == kDownloadImageOne then
        if _detailData == self.localDir then
            if self.listItem then
                local img_icon = publ_getItemFromTree(self.listItem, { "item_view", "img_icon" });
                if img_icon then
                    img_icon:setFile(self.localDir);
                end
            end
        end
    end
end

