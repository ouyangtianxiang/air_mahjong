
local updateWnd = require(ViewLuaPath.."updateWnd");

NewUpdateWindow = class(SCWindow);

NewUpdateWindow.isShowUpdateWndAuto = false;
NewUpdateWindow.hasShown = false;

--NewUpdateWindow.instance = nil;

-- NewUpdateWindow.getInstance = function ( )
-- 	if not NewUpdateWindow.instance then
-- 		NewUpdateWindow.instance = new(NewUpdateWindow);
-- 	end
-- 	return NewUpdateWindow.instance;
-- end

NewUpdateWindow.ctor = function ( self )

    self:set_pop_index(new_pop_wnd_mgr.get_instance():get_wnd_idx(new_pop_wnd_mgr.enum.update));

	self:setLevel(10000);

	self.layout = SceneLoader.load(updateWnd);
	self:addChild(self.layout);

	self.bg = publ_getItemFromTree(self.layout, {"bg"});
	self:setWindowNode( self.bg );
	self:setAutoRemove( false );

	self.m_scorllText = publ_getItemFromTree(self.layout, {"bg", "frame", "scrollText" });
	--self.m_titleText = publ_getItemFromTree(self.layout, {"bg", "frame", "index" });

	self.getRewardObj = nil;
	self.getRewardFun = nil;
	self.isForceUpdate = false;
    --测试按钮，点击10次显示小版本号
    self.m_show_version  = publ_getItemFromTree(self.layout, {"btn_show_ver" });
    if self.m_show_version then
       self.m_show_version.t = publ_getItemFromTree(self.m_show_version, {"t" });
       self.m_show_version.t:setText("");
       self.m_show_version.touch_times = 0;
       self.m_show_version:setOnClick(self, function ( self )
           self.m_show_version.touch_times = self.m_show_version.touch_times + 1;
           if self.m_show_version.touch_times > 9 then
                self.m_show_version.t:setText("mini_ver:"..Version.mini_ver);
           end
       end)
    end

	self.getRewardBtn  = publ_getItemFromTree(self.layout, {"bg", "getReward" });
	self.getRewardText = publ_getItemFromTree(self.layout, {"bg", "getReward", "text" });

	self.verOld = publ_getItemFromTree(self.layout, { "bg", "frame","curVersionNum" });
	self.verNew = publ_getItemFromTree(self.layout, { "bg", "frame","latestVersionNum" });
	self.verSize = publ_getItemFromTree(self.layout,{ "bg", "frame","versionSizeNum"});
	if GameConstant.iosDeviceType>0 then
		self.verSize:setVisible(false);
		local versionSize = publ_getItemFromTree(self.layout,{ "bg", "frame","versionSize"});
		versionSize:setVisible(false);
	end
	self.verRewardTips = publ_getItemFromTree(self.layout,{ "bg", "frame","tips"});
	self.getRewardBtn:setOnClick(self, function ( self )
		umengStatics_lua(Umeng_UpdateReward);
		if self.getRewardFun then
			self:setRewardStatu(0 , 0);
			self.getRewardFun(self.getRewardObj);
		end
	end);

	self.m_currentDegree = publ_getItemFromTree(self.layout, {"bg", "process" });
	self.m_processBg = publ_getItemFromTree(self.layout, {"bg", "process_bg" });


	self.closeBtn = publ_getItemFromTree(self.layout, {"bg", "closeBtn" });
	self.closeBtn:setOnClick(self, function ( self )
		umengStatics_lua(Umeng_UpdateClose);
		self:hideWnd();
		self.showing = false;
	end);

	if PlatformConfig.platformWDJ == GameConstant.platformType or
        PlatformConfig.platformWDJNet == GameConstant.platformType then
		self.closeBtn:setFile("Login/wdj/Hall/Commonx/close_btn.png");
		self.closeBtn.disableFile = "Login/wdj/Hall/Commonx/close_btn_disable.png";
		self.bg:setFile("Login/wdj/Hall/Commonx/pop_window_mid.png");
		self.m_currentDegree:setFile("Login/wdj/update/process.png");
		publ_getItemFromTree(self.layout, {"bg", "process_bg" }):setFile("Login/wdj/update/process_bg.png");
	end

	self.updateBtn = publ_getItemFromTree(self.layout, {"bg", "getUpdate" });
	self.updateBtn:setOnClick(self, function ( self )
		umengStatics_lua(Umeng_UpdateUpdate);
        if not (GameConstant.iosDeviceType>0) then
            self.updateBtn:setVisible(false);
    		self.getRewardBtn:setVisible(true);
        end
		if self.updateFun then
			self.updateFun(self.updateObj);
		end
	end);


	self.cover:setEventTouch(self , function (self)
		DebugLog("背景不能删除");
	end);
	--初始化进来就加载数据，因为每次隐藏就删除了自己
	-- ###################### 勿修改这里，这是从外部设置数据，请勿在内部调用该方法！！！！！！！
	-- self:setData(GlobalDataManager.updateInfoBuffer);

	if GlobalDataManager.CurrentUpdataProcees ~= 0 then
		self:setProgress(GlobalDataManager.CurrentUpdataProcees, GameConstant.totalSizeTemp);
	else
		self:setProgress(0);
	end

	-- self:addToRoot();
end

function NewUpdateWindow.onWindowHide( self )
	self.super.onWindowHide(self);
	self.showing = false;
	if self.isForceUpdate then
		new_pop_wnd_mgr.get_instance():hide_and_show( new_pop_wnd_mgr.enum.force_update );
	else
		new_pop_wnd_mgr.get_instance():hide_and_show( new_pop_wnd_mgr.enum.update );
	end

	delete( GlobalDataManager.NewUpDateWnd);
	GlobalDataManager.NewUpDateWnd = nil;
end

NewUpdateWindow.setOnGetReward = function ( self, obj, fun )
	self.getRewardObj = obj;
	self.getRewardFun = fun;
end

NewUpdateWindow.setOnUpdate = function ( self, obj, fun )
	self.updateObj = obj;
	self.updateFun = fun;
end

NewUpdateWindow.setProgressVisible = function ( self, visible )
    DebugLog("setProgressVisible " .. tostring(visible))
	self.m_currentDegree:setVisible(visible);
	self.m_processBg:setVisible(visible)
end

NewUpdateWindow.hide = function ( self )
	CustomNode.hide(self);
end

function NewUpdateWindow.setData( self, data )
	DebugLog( "NewUpdateWindow.setData" );
	self:addToRoot();
	if not data then
		--以免初始化的时候GlobalDataManager.updateInfoBuffer还是nil
		self:hideWnd();
		return;
	end
	self.showing = true;

	local force_level,_,normal_level = PlatformFactory.curPlatform:getPlatformLevel();
	if 1 == tonumber(data.force) then
		self.isForceUpdate = true;
		self:setLevel(force_level);
	else
		self.isForceUpdate = false;
		self:setLevel(normal_level);
	end
	if self.isForceUpdate and 1 == tonumber(data.flag) then
		self.closeBtn:setVisible(false);
		self.forceUpdate = true;
	else
		self.closeBtn:setVisible(true);
	end
	--self:setShowTitle(data.title or "");
	self:setShowContent(data.content or "");
	self:setMoneyText(data.update_money or 0, data.update_bycoin or 0);


	self.verOld:setText(GameConstant.Version);
	local newVersion = data.version
	if not newVersion or string.len(newVersion) <=0 then
		newVersion = GameConstant.Version;
	end
	self.verNew:setText(newVersion);

	if GameConstant.Version == newVersion then
		self:setProgressVisible(false);
	end

	if GameConstant.iosDeviceType>0 then
		self:setProgressVisible(false);
	end
    self:set_package_size(GameConstant.totalSizeTemp);

    DebugLog("[NewUpdateWindow]:setData GameConstant.totalSizeTemp:"..tostring(GameConstant.totalSizeTemp));
	DebugLog("******data flag: " .. data.flag)
	if 1 == tonumber(data.flag) then
		self.updateBtn:setVisible(true);
		self.getRewardBtn:setVisible(false);
	else
		self.updateBtn:setVisible(false);
		self.getRewardBtn:setVisible(true);
		self:setProgress(100);
	end

	local isReward = tonumber(data.award_status or 0);
	local updateFlag = tonumber(data.flag or 0);

	self:setRewardStatu(isReward , updateFlag);
	self:setOnGetReward(GlobalDataManager.getInstance() , GlobalDataManager.onGetUpdateReward);
	self:setOnUpdate(GlobalDataManager.getInstance() , GlobalDataManager.onClickUpdate);

	if self.isForceUpdate then
		new_pop_wnd_mgr.get_instance():add_and_show( new_pop_wnd_mgr.enum.force_update );
	else
		if GlobalDataManager.curRequireUpdateType == 1 then
			self:showWnd();
		else
			if NewUpdateWindow.isShowUpdateWndAuto then
				NewUpdateWindow.isShowUpdateWndAuto = false;
				new_pop_wnd_mgr.get_instance():add_and_show( new_pop_wnd_mgr.enum.update );
			end
		end
	end
end

--设置包大小
NewUpdateWindow.set_package_size = function (self, total_size)

    total_size = tonumber(total_size)
    if not total_size then
    	self.verSize:setVisible(false);
		local versionSize = publ_getItemFromTree(self.layout,{ "bg", "frame","versionSize"});
		versionSize:setVisible(false);
        return;
    end
    DebugLog("[NewUpdateWindow]:set_package_size:"..tostring(total_size));
    total_size = math.floor(total_size/(1024*1024)) or 0
    self.verSize:setText(tostring(total_size).." M");
end

NewUpdateWindow.setRewardStatu = function ( self, _isReward , _updateFlag)
	-- self.getRewardImg:setFile("Common/windowsBtnG.png", kRGBGray);
	DebugLog("*****Reward Button Status: " .. tostring(_isReward) .. tostring(_updateFlag))
	if 1 ==  _isReward then
		self.getRewardBtn:setIsGray(false);
		self.getRewardText:setText("领奖");
		self.getRewardBtn:setPickable(true);
	elseif 1 == _updateFlag then
		--self.getRewardBtn:setFile("Common/windowsBtnG.png", kRGBGray);
		self.getRewardBtn:setIsGray(true);
		self.getRewardText:setText("更新领奖");
		self.getRewardBtn:setPickable(false);
	else
		--self.getRewardBtn:setFile("Common/windowsBtnG.png", kRGBGray);
		self.getRewardBtn:setIsGray(true);
		self.getRewardText:setText("已领奖");
		self.getRewardBtn:setPickable(false);
	end
end

NewUpdateWindow.setMoneyText = function ( self, money, byCoin )
    local str = "(赠送";
	if money and money > 0 then
        str = str..money.."金币";
		--self.verRewardTips:setText("(赠送" ..money.."金币)")
	end
	if byCoin and byCoin > 0 then
        str = " "..str..byCoin.."钻石"
		--self.verRewardTips:setText("(赠送" ..byCoin.."钻石)")
	end
    str = str .. ")"
    self.verRewardTips:setText(str)
end

NewUpdateWindow.dtor = function ( self )
	self:removeAllChildren();
end


NewUpdateWindow.setShowContent = function (self,content)
	if(content == nil) then
		return;
	end
	self.m_scorllText:setText(content);
end

NewUpdateWindow.setProgress = function(self, progress, totalSize)  --338
	DebugLog("progress:" .. tostring(progress))
	--if not self:getVisible() then
	--	return;
	--end

	local progressImgW, progressImgH = self.m_currentDegree:getSize();
	local x, y = self.m_currentDegree:getPos();
    self.m_currentDegree:setClip(x, y, progress * progressImgW / 100 , progressImgH);

	if totalSize and 0 ~= totalSize then
		DebugLog("progress:totalSize=" .. tostring(totalSize))
	--	totalSize = totalSize/1024; -- KB单位
	--	local cur = math.ceil(totalSize * progress/100);
	--	local max = math.ceil(totalSize);
		--self.size:setVisible(true);
		--self.size:setText(cur.."/"..max.."KB");
	else
		if progress == 100 then
		 	self:setRewardStatu(1 , 0);
		end
		--self.size:setVisible(false);
	end
end
