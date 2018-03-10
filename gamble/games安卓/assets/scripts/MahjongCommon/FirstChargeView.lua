local layout_first_charge_view = require(ViewLuaPath.."layout_veteranPlayerAward");--"firstChargeView");

FirstChargeView = class(SCWindow);
FirstChargeView.instance = nil;

FirstChargeView.getInstance = function ( )
	if not FirstChargeView.instance then
		FirstChargeView.instance = new(FirstChargeView);
	end
	return FirstChargeView.instance;
end

--[Comment]
--目前这个界面有2个type：月度大礼包和新人大礼包
FirstChargeView.ctor = function ( self )
	DebugLog("FirstChargeView.ctor")

    --init
    self:init();
end

--[Comment]
--init
FirstChargeView.init =function (self)
    DebugLog("FirstChargeView.init ");
    self:setVisible(false);
	self:addToRoot();
	self:setLevel(20000);

	EventDispatcher.getInstance():register(SocketManager.s_phpMsg, self, self.onPhpMsgResponse);

	EventDispatcher.getInstance():register(NativeManager._Event, self, self.nativeCallEvent);

	self.window = SceneLoader.load(layout_first_charge_view);
	self:addChild(self.window);

    --bg
    self.m_bg = publ_getItemFromTree(self.window, {"bg"});
    self:setAutoRemove( false );
	self:setWindowNode( self.m_bg );

    --title 图片
	self.m_title = publ_getItemFromTree(self.window, {"bg" , "title"})

    --tip
    self.m_tip = publ_getItemFromTree(self.window, {"bg" , "t"});

    --关闭按钮
	self.m_btn_close = publ_getItemFromTree(self.window , {"bg", "btn_close"});
    self.m_btn_close:setVisible(true);
	self.m_btn_close:setOnClick(self, function ( self )
		self:hideWnd();
	end);

    self.m_v = publ_getItemFromTree(self.window, {"bg", "v"});
    self.m_v.items = {};
    for i = 1, 4 do
        local img = publ_getItemFromTree(self.m_v, {"item_"..i, "img"});
        local tt = publ_getItemFromTree(self.m_v, {"item_"..i, "tt"});
        tt:setScrollBarWidth(0);
        local zeng = publ_getItemFromTree(self.m_v, {"item_"..i, "zeng"});
        if i == 1 then
            zeng:setVisible(false);
        end
		img:setSize( 100, 100 );
        table.insert(self.m_v.items, {gift_img = img, gift_t = tt});
    end

		--ios 屏蔽
		if GameConstant.iosDeviceType>0 and GameConstant.iosPingBiFee then
			local plus = publ_getItemFromTree(self.m_v, {"add3"});
			local item = publ_getItemFromTree(self.m_v, {"item_4"});
			item:setVisible(false);
			plus:setVisible(false);
		end

    --领取奖励按钮
	self.m_btn_award = publ_getItemFromTree(self.window , {"bg", "btn_award"});
    self.m_btn_award.t = publ_getItemFromTree(self.m_btn_award , {"t"});

    --按钮
	self.m_btn_1 = publ_getItemFromTree(self.window , {"bg", "btn_1"});
    self.m_btn_1.t = publ_getItemFromTree(self.m_btn_1 , {"t"});

    --按钮
	self.m_btn_2 = publ_getItemFromTree(self.window , {"bg", "btn_2"});
    self.m_btn_2.t = publ_getItemFromTree(self.m_btn_2 , {"t"});
end

-- 从外部获取房间level
function FirstChargeView.setRoomLevel( self, roomlevel )
	self._roomLevel = roomlevel;
end

-- 点击去低级场
function FirstChargeView.onClickLowLevelBtn( self )
	if not self._roomLevel or self._roomLevel <=0 then
		DebugLog( "未传递level值" );
		return;
	end

	-- 请求换桌
	local param = {};
	param.mid = PlayerManager.getInstance():myself().mid;
	SocketManager.getInstance():sendPack(CLIENT_COMMAND_REQ_LOGOUT, param);

	self._roomLevel = 0;
	self:hide();
end

function FirstChargeView.setNoEnoughMoney( self, enough )
	self._noEnoughMoney = enough;
end

-- 是否显示去低倍场按钮
function FirstChargeView.showOrHideLowLevelBtn( self, award, money )


	--能找到更低的场次
	local hasLowLevel = nil

	local playerMoney = PlayerManager.getInstance():myself().money;
    DebugLog("self._roomLevel")
  	DebugLog(type(self._roomLevel))

  	local slevel = tostring(self._roomLevel)
   	DebugLog(slevel .."              = slevel")
    local curType = HallConfigDataManager.getInstance():returnTypeForLevel(slevel)
	--DebugLog(curType)
	local curKey = HallConfigDataManager.getInstance():returnKeyByType(curType)
    --DebugLog("key: " .. curKey)

	local btnMid = self.m_btn_award--self:getControlFromConfigTab( "midBtn" );
	local btnConfirm = self.m_btn_2--self:getControlFromConfigTab( "btnConfirm" );
	local btnLowLevel = self.m_btn_1--self:getControlFromConfigTab( "btnLowLevel" );

    if not curKey then
		DebugLog( "不显示去低倍场按钮" );
		btnLowLevel:setVisible( false );
		btnConfirm:setVisible( false );
		btnMid:setVisible( true );
		self._roomLevel = 0;
    	return
    end

    local suc,hallData = HallConfigDataManager.getInstance():returnDataByKey(curKey,tonumber(playerMoney))
    if not suc or not hallData then
		DebugLog( "不显示去低倍场按钮" );
		btnLowLevel:setVisible( false );
		btnConfirm:setVisible( false );
		btnMid:setVisible( true );
		self._roomLevel = 0;


    	return
    end


	if GameConstant.isShowLowLevelBtn and
	 	RoomScene_instance and
		self._noEnoughMoney and ( playerMoney >= GameConstant.bankruptMoney ) then

		self._noEnoughMoney = false;

		btnMid:setVisible( false );
		btnConfirm:setVisible( true );
		btnLowLevel:setVisible( true );
		btnLowLevel.t:setText("去低倍场");

		btnConfirm:setOnClick( self, function( self )
			self:onClickConfirmBtn( award, money );
		end);

		btnLowLevel:setOnClick( self, self.onClickLowLevelBtn );
	else
		DebugLog( "不显示去低倍场按钮" );
		btnLowLevel:setVisible( false );
		btnConfirm:setVisible( false );
		btnMid:setVisible( true );
		self._roomLevel = 0;
	end

end

function FirstChargeView:nativeCallEvent(param, _detailData)
	DebugLog("FirstChargeView:nativeCallEvent  ++++++");
	if kDownloadImageOne == param then
--		if _detailData == self.imgPathLeft then
--			DebugLog("FirstChargeView:nativeCallEvent  ++++++self.imgPathLeft==" .. self.imgPathLeft);
--			self:getControlFromConfigTab( "giftLeftImg" ):setFile( self.imgPathLeft );
--		elseif _detailData == self.imgPathMid then
--			self:getControlFromConfigTab( "giftMidImg" ):setFile( self.imgPathMid );
--		elseif _detailData == self.imgPathRight then
--			self:getControlFromConfigTab( "giftRightImg" ):setFile( self.imgPathRight );
--		end
        for i = 1, #self.m_v.items do
            if self.m_v.items[i].img_path == _detailData then
                self.m_v.items[i].gift_img:setFile(_detailData);
                break;
            end
        end
	end
end

-- id: the id of the control,type STRING
--function FirstChargeView.getControlFromConfigTab( self, id )
--	return publ_getItemFromTree( self.window, FirstChargeView.s_controlsMap[id] );
--end

--function FirstChargeView.initPhone( self )
--	local btn_phone1 = publ_getItemFromTree(self.window,{"img_win_bg","view_phone", "btn_phone1" });
--	local text_phone1 = publ_getItemFromTree(self.window,{"img_win_bg", "view_phone", "btn_phone1", "text_phone1" });
--	local btn_phone2 = publ_getItemFromTree(self.window,{"img_win_bg", "view_phone", "btn_phone2" });
--	local text_phone2 = publ_getItemFromTree(self.window,{"img_win_bg", "view_phone", "btn_phone2", "text_phone2" });

--	btn_phone1:setOnClick( self, function( self )
--		local phone = text_phone1:getText();
--		self:hideWnd();
--		callPhone( phone );
--	end);

--	btn_phone2:setOnClick( self, function( self )
--		local phone = text_phone2:getText();
--		self:hideWnd();
--		callPhone( phone );
--	end);
--end

FirstChargeView.dtor = function ( self )
	DebugLog("FirstChargeView.dtor")
	EventDispatcher.getInstance():unregister(SocketManager.s_phpMsg, self, self.onPhpMsgResponse);

	EventDispatcher.getInstance():unregister(NativeManager._Event, self, self.nativeCallEvent);

	Loading.hideLoadingAnim();
	self:removeAllChildren();
end

--请求首充大礼包
FirstChargeView.requestFirstChargeData = function ( self )
    DebugLog("[FirstChargeView]requestFirstChargeData");
	local param = {};
	param.mid = PlayerManager.getInstance():myself().mid;
	SocketManager.getInstance():sendPack( PHP_CMD_REQUEST_FIRST_CHARGE_DATA, param)

end

--请求首充大礼包回调
FirstChargeView.requestFirstChargeDataCallBack = function ( self ,isSuccess, data)
    DebugLog("[FirstChargeView]:requestFirstChargeDataCallBack");
	self.isOpenFirstChargeView = 0;
	self.firstChargeData = nil;
	if not isSuccess or not data then
        DebugLog("data is nil");
		return;
	end
	local status = GetNumFromJsonTable(data , "status" , -1);
	local dataInfo = data.data;
	if 1 ~= status or not data then
        DebugLog("1 ~= status or not data");
		return;
	end

	self.isOpenFirstChargeView = GetNumFromJsonTable(dataInfo , "open" , 0);
	self:setMonthGiftMark( dataInfo );

	self.firstChargeData = dataInfo;
	DebugLog( "FirstChargeView.requestFirstChargeDataCallBack ++++++++有数据" );

    --下载图片
    self:downloadImgs();

	if 1 == self.isOpenFirstChargeView then
		new_pop_wnd_mgr.get_instance():add_and_show( new_pop_wnd_mgr.enum.first_charge );
	else
		self:hide();
	end
end

function FirstChargeView:setMonthGiftMark( dataInfo )
--	local paytype = GetNumFromJsonTable(dataInfo , "paytype" , 0);
--	if paytype == 1 then
--		self.isMonthGiftPacks = true;
--	else
--		self.isMonthGiftPacks = false;
--	end
--	if self.isOpenFirstChargeView == 0 then
--		self.isMonthGiftPacks = false;
--	end
end

--[Comment]
--下载图片
FirstChargeView.downloadImgs =function (self)
    DebugLog("FirstChargeView.downloadImgs");
    if not self.firstChargeData or not self.firstChargeData.goods then
        DebugLog("data is nil...");
        return;
    end
    local index = 1;
    for k,v in pairs(self.firstChargeData.goods) do
        if v.img and index <= #self.m_v.items then
            local isExist, img_path = NativeManager.getInstance():downloadImage(v.img);
            self.m_v.items[index].img_path = img_path;
            if isExist then
                self.m_v.items[index].gift_img:setFile(img_path);
            end
            self.m_v.items[index].gift_t:setText(v.name or "");
        end
        index = index + 1;
    end
end

function FirstChargeView.isDownloadImg( self, isMonthGiftPacks, data )
--	DebugLog("FirstChargeView.isDownloadImg ++++");
--	if not data or ( data and not data.goods ) then
--		return;
--	end
--    DebugLog("FirstChargeView.isDownloadImg 准备++++");
--	if isMonthGiftPacks then
--		local index = 1;
--		local leftPath = "";
--		local midPath = "";
--		local rightPath = "";
--		for k,item in pairs(data.goods) do
--			if type( item ) == "table" then
--				if index == 1 then

--					leftPath = item.img and item.img or "";
--					DebugLog("leftPath index == 1===" .. leftPath .. " ++++++");
--				elseif index == 2 then

--					midPath = item.img and item.img or "";
--					DebugLog("leftPath index == 2===" .. midPath .. " ++++++");
--				elseif index == 3 then
--					rightPath = item.img and item.img or "";
--					DebugLog("leftPath index == 3===" .. rightPath .. " ++++++");
--				end
--			end

--			index = index + 1;
--		end

--		local isExist = false;
--		DebugLog("leftPath ===" .. leftPath .. " ++++++");
--		isExist, self.imgPathLeft = NativeManager.getInstance():downloadImage(leftPath);

--		if isExist then
--			DebugLog("leftPath 文件存在===");
--			self:getControlFromConfigTab( "giftLeftImg" ):setFile( self.imgPathLeft );
--		else
--			DebugLog("leftPath 文件不存在===");
--			self:getControlFromConfigTab( "giftLeftImg" ):setFile( "newHall/task/task.png" );
--		end

--		isExist, self.imgPathMid = NativeManager.getInstance():downloadImage(midPath);
--		if isExist then
--			DebugLog("imgPathMid 文件存在===");
--			self:getControlFromConfigTab( "giftMidImg" ):setFile( self.imgPathMid );
--		else
--			DebugLog("imgPathMid 文件不存在===");
--			self:getControlFromConfigTab( "giftMidImg" ):setFile( "newHall/task/task.png" );
--		end

--		isExist, self.imgPathRight = NativeManager.getInstance():downloadImage(rightPath);
--		if isExist then
--			DebugLog("imgPathRight 文件存在===");
--			self:getControlFromConfigTab( "giftRightImg" ):setFile( self.imgPathRight );
--		else
--			DebugLog("imgPathRight 文件不存在===");
--			self:getControlFromConfigTab( "giftRightImg" ):setFile( "newHall/task/task.png" );
--		end

--        local w, h = 100, 100;
--		self:getControlFromConfigTab( "giftLeftImg" ):setSize( w, h );
--		self:getControlFromConfigTab( "giftMidImg" ):setSize( w, h );
--		self:getControlFromConfigTab( "giftRightImg" ):setSize( w, h );
--	else
--	end
end

-- 成功显示时返回true，失败显示时返回false
function FirstChargeView.show( self )
	DebugLog("[FirstChargeView]: show:"..tostring(self.isOpenFirstChargeView))
	if self.isOpenFirstChargeView == 1 then
		self:refreshView();
		return true;
	else
		return false;
	end
end

function FirstChargeView.onWindowShow( self )
	self.super.onWindowShow( self );
    for i = 1, 4 do
        local img = self.m_v.items[i].gift_img
        local anim = img:addPropScale(0 , kAnimNormal , 200 , 100 , 1.0 , 1.2 , 1.0 , 1.2 , kCenterDrawing);
        anim:setEvent(self , function( self )
		    img:removeProp(0);
		    local anim_2 = img:addPropScale(0 , kAnimNormal , 200 , 0 , 1.2, 1.0 , 1.2 , 1.0 , kCenterDrawing);
		    anim_2:setEvent(self , function( self )
			    img:removeProp(0);
		    end);
	    end);
    end
end

function FirstChargeView.onWindowHide( self )
	self.super.onWindowHide( self );
	new_pop_wnd_mgr.get_instance():hide_and_show( new_pop_wnd_mgr.enum.first_charge );
	if RoomScene_instance and PlayerManager.getInstance():myself().money < GameConstant.bankruptMoney then
		GlobalDataManager.getInstance():showBankruptDlg(nil,RoomScene_instance);
	end
end

FirstChargeView.clearData = function( self )
    DebugLog("[FirstChargeView]:clearData")
	self.firstChargeData = nil;
	self.isOpenFirstChargeView = 0;
end

FirstChargeView.refreshView = function ( self )
	DebugLog("[FirstChargeView]:refreshView")
	if self.m_visible or 1 ~= self.isOpenFirstChargeView then
        DebugLog("FirstChargeView.refreshView:"..tostring(self.m_visible).." :"..tostring(self.isOpenFirstChargeView));
		return;
	end

	if not self.firstChargeData then
        DebugLog("not self.firstChargeData")
		Loading.showLoadingAnim();
		self:requestFirstChargeData();
		return;
	end


	local data = self.firstChargeData;

	DebugLog(data);


    --下载图片
    self:downloadImgs();

    --设置title图片
    local paytype = tonumber(self.firstChargeData.paytype);
    --paytype: 新人大礼包为nil 月度大礼包为1
    self.m_title:setFile(paytype == 1 and "veteranPlayerAward/title_4.png" or "veteranPlayerAward/title_3.png");

    --设置tip
    self.m_tip:setText(data.desc_v2 or "");


	local money = tonumber(data.price) or 6;
	local award = tonumber(data.award) or 0;
    local textStr = data.btn_title or "领 取";
    --低倍场按钮显示
    self:showOrHideLowLevelBtn( award, money );
    --设置奖励按钮事件
	self.m_btn_award:setOnClick(self, function ( self )
		self:onClickConfirmBtn( award, money );
	end);

    if 1 == award then
		textStr = "领 取";
	end
    --设置按钮上的文字
    self.m_btn_award.t:setText(textStr);

    --如果是审核
    if GameConstant.checkType == kCheckStatusOpen then
        --btn_1 取消， btn_2 购买
    	self.m_btn_award:setVisible(false);
		self.m_btn_1:setVisible(true);
		self.m_btn_2:setVisible(true);
		self.m_btn_1.t:setText("取 消");
        self.m_btn_1:setOnClick(self,self.hide);
		self.m_btn_2:setOnClick(self,function(self)
			umengStatics_lua(UMENG_FIRST_CHARGE_BUY_CLICK); --上报购买
			-- 购买
			local scene = {};
			scene.scene_id = PlatformConfig.HallBuyForPay;

			local data = self.firstChargeData;
			local money = GetNumFromJsonTable(data , "price" , 6);

			GlobalDataManager.getInstance():quickPay(money , scene);
			self:hideWnd();
		end);
    end

    --显示窗口
    self:showWnd();
	return true;
end

FirstChargeView.createNodes = function ( self )
	local width 		= 0;
	local children = self.text1:getChildren();

	for i = 1, #children do
		local w, h = children[i]:getSize();
		width = width + w;
	end

	local w, h = self.text1:getSize();
	self.text1:setSize(width, h);
end

FirstChargeView.addNode = function ( self, node )
	local pos = 0
	local children = self.text1:getChildren();
	for i = 1, #children do
		local w, h = children[i]:getSize();
		pos = pos + w;
	end
	node:setAlign(kAlignLeft);
	node:setPos(pos , 0);
	self.text1:addChild(node);
end

FirstChargeView.createNode = function ( self, text, size, r, g, b )
	local node = UICreator.createText(text, 0, 0, 0, 0, kAlignLeft , size, r, g, b );
	node:setAlign(kAlignLeft);
	return node;
end


function FirstChargeView.onClickConfirmBtn( self, award, money )
	if 1 == award then
		umengStatics_lua(UMENG_FIRST_CHARGE_GET_CLICK); --上报领取
		-- 领奖
		-- Loading.showLoadingAnim("正在努力加载中...");
	else
		umengStatics_lua(UMENG_FIRST_CHARGE_BUY_CLICK); --上报购买
		-- 购买
		local scene = {};
		scene.scene_id = PlatformConfig.HallBuyForPay;
		GlobalDataManager.getInstance():quickPay(money , scene);
		self:hideWnd();
	end
end

FirstChargeView.hide = function ( self )
	DebugLog("FirstChargeView.hide")
	Loading.hideLoadingAnim();
	self:setVisible(false);
    self.super.hide(self)
end

FirstChargeView.hideWnd = function ( self )
	DebugLog("FirstChargeView.hideWnd")
	self.super.hideWnd(self)
	return true
end




FirstChargeView.requestFirstChargeAwardCallBack = function ( self , isSuccess , data)
    DebugLog("[FirstChargeView]:requestFirstChargeAwardCallBack");
	Loading:hideLoadingAnim();
	if not isSuccess or not data then
		Banner.getInstance():showMsg("领奖失败，请稍后重试！");
		return;
	end
	local myself = PlayerManager.getInstance():myself();
	self.isOpenFirstChargeView = 0;
	self.firstChargeData = nil;
	local status = GetNumFromJsonTable(data , "status" , -1);
	local msg = GetStrFromJsonTable(data , "msg");
	-- DebugLog(GetNumFromJsonTable(data.data , "allmoney"));
	myself.money = GetNumFromJsonTable(data.data , "allmoney") or myself.money;
	if 1 == status then
		AnimationAwardTips.play(msg or "领取成功");
		showGoldDropAnimation();
	else
		-- Banner.getInstance:showMsg(msg or "领奖失败");
	end
	GlobalDataManager.getInstance():updateLocalCoin();
	self:requestFirstChargeData();
	GlobalDataManager.getInstance():updateScene();
	self:hide();
end

FirstChargeView.phpMsgResponseCallBackFuncMap = {
	[PHP_CMD_REQUEST_FIRST_CHARGE_AWARD] = FirstChargeView.requestFirstChargeAwardCallBack,
	[PHP_CMD_REQUEST_FIRST_CHARGE_DATA]  = FirstChargeView.requestFirstChargeDataCallBack,
};

FirstChargeView.onPhpMsgResponse = function ( self, param, cmd, isSuccess )
	if self.phpMsgResponseCallBackFuncMap[cmd] then
		self.phpMsgResponseCallBackFuncMap[cmd](self,isSuccess,param)
	end
end

FirstChargeView.s_controlsMap = {
--	["midBtn"]     		= {"img_win_bg","btn_mid"},
--	["midBtnName"] 		= {"img_win_bg","btn_mid","text_name"},
--	["closeBtn"]   		= {"img_win_bg","btn_close"},
--	["btnConfirm"]		= {"img_win_bg","btn_confirm"},
--	["btnLowLevel"]		= {"img_win_bg","btn_low_level"},
--	["btnLowLevelText"] = {"img_win_bg","btn_low_level", "btn_confirm_text"},
--	["giftLeftImg"] = {"img_win_bg", "v", "item_1", "img"},--{ "img_win_bg", "Image1", "left" },
--	["giftMidImg"] = {"img_win_bg", "v", "item_2", "img"},--{ "img_win_bg", "Image2" , "mid" },
--	["giftRightImg"] = {"img_win_bg", "v", "item_3", "img"},--{ "img_win_bg", "Image6", "right" },
--    ["gift_4"] = {"img_win_bg", "v", "item_4", "img"},--{ "img_win_bg", "Image6", "right" },
}
