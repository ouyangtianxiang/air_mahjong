local oppo_first_charge_view = require(ViewLuaPath.."oppo_first_charge_view");

OppoFirstChargeView = class(SCWindow);

OppoFirstChargeView.instance = nil;

OppoFirstChargeView.getInstance = function ( )
	if not OppoFirstChargeView.instance then
		OppoFirstChargeView.instance = new(OppoFirstChargeView);
	end
	return OppoFirstChargeView.instance;
end

OppoFirstChargeView.ctor = function(self)
	self.bankruptFlag = 0;
	self:addToRoot();
	self:setLevel(20000);

	-- 月度大礼包图片链接
	self.imgPathLeft = ""; -- 左边第一个图片链接
	self.imgPathMid = ""; -- 中间图片链接
	self.imgPathRight = ""; -- 右边图片链接

	EventDispatcher.getInstance():register(SocketManager.s_phpMsg, self, self.onPhpMsgResponse);
	EventDispatcher.getInstance():register(NativeManager._Event, self, self.nativeCallEvent);

	self:initView();
	
-- 	self.window = SceneLoader.load(oppo_first_charge_view);
-- 	self:addChild(self.window);

-- 	self.window_tmp = publ_getItemFromTree(self.window, {"img_win_bg"});
-- 	self.window_title = publ_getItemFromTree(self.window, {"img_win_bg" , "Image9"})

-- 	self:setAutoRemove( false );
-- 	self:setWindowNode( self.window_tmp );

-- 	local closeBtn = publ_getItemFromTree(self.window , OppoFirstChargeView.s_controlsMap["closeBtn"]);
-- 	closeBtn:setOnClick(self, function ( self )
-- 		self.bankruptFlag = 1;
-- 		self:hideWnd();
-- 	end);

-- 	if PlatformConfig.platformWDJ == GameConstant.platformType or 
-- 	   PlatformConfig.platformWDJNet == GameConstant.platformType then 
-- 		closeBtn:setFile("Login/wdj/Hall/Commonx/close_btn.png");
-- 		closeBtn.disableFile = "Login/wdj/Hall/Commonx/close_btn_disable.png";
-- 		-- self.window_tmp:setFile("Login/wdj/Hall/Commonx/pop_window_mid.png");
-- 	end

--     
--如果为起凡，将联系方式改为QQ
--     if GameConstant.platformType == PlatformConfig.platformDingkai then
--         self.phoneNum = publ_getItemFromTree(self.window, {"img_win_bg", "view_phone", "btn_phone1"});
--         self.phoneNum:setVisible(false);
--         publ_getItemFromTree(self.window, {"img_win_bg", "view_phone", "btn_phone2"}):setVisible(false);
--         self.QQ = publ_getItemFromTree(self.window, {"img_win_bg", "view_phone", "view_text2", "Text2"});
--         self.QQ:setText("QQ:2897738207");
--         local x, y = self.QQ:getPos();
--         self.QQ:setPos(x - 100, y);
--     end

-- 	self:initPhone();

	self:setVisible(false);
	self:setCoverTransparent()
	self.isNeedToShowView = true;

end

OppoFirstChargeView.initView = function(self)
	self.window = SceneLoader.load(oppo_first_charge_view);
	self:addChild(self.window);

	self:setAutoRemove( false );
	self:setWindowNode(self.window);

	self.m_closeBtn = publ_getItemFromTree(self.window , {"bg","close_btn"});
	self.m_closeBtn:setOnClick(self,function(self)
		self.bankruptFlag = 1;
		self:hideWnd();
	end);

	self.m_titleBg = publ_getItemFromTree(self.window, {"bg","title_bg"});

	self.m_not_oppo_titleView = publ_getItemFromTree(self.window, {"bg","title_view","not_oppo_view"});
	self.m_not_oppo_titlePamount = publ_getItemFromTree(self.window, {"bg","title_view","not_oppo_view","pamount"});
	self.m_not_oppo_awardThings = publ_getItemFromTree(self.window, {"bg","title_view","not_oppo_view","title_bg","Text1"});

	self.m_oppo_titleView = publ_getItemFromTree(self.window, {"bg","title_view","oppo_view"});
	self.m_oppo_titlePamount = publ_getItemFromTree(self.window, {"bg","title_view","oppo_view","pamount"});
	self.m_oppo_title_awardThings = publ_getItemFromTree(self.window, {"bg","title_view","oppo_view","title_bg","Text1"});

	self.m_oppo_discountPamount = publ_getItemFromTree(self.window, {"bg","title_view","oppo_view","oppo_bg","pamount"});

	self.m_image1Pic = publ_getItemFromTree(self.window, {"bg","item_view","Image1","p"});
	self.m_image1Text = publ_getItemFromTree(self.window, {"bg","item_view","Image1","Text"});

	-- self.m_image2Pic = publ_getItemFromTree(self.window, {"bg","item_view","Image2","p"});
	-- self.m_image2Text = publ_getItemFromTree(self.window, {"bg","item_view","Image2","Text"});

	self.m_image3Pic = publ_getItemFromTree(self.window, {"bg","item_view","Image3","p"});
	self.m_image3Text = publ_getItemFromTree(self.window, {"bg","item_view","Image3","Text"});

	self.m_oneBtn_confirmBtn = publ_getItemFromTree(self.window, {"bg","btn_view","confirm_btn"});
	self.m_oneBtn_confirmText = publ_getItemFromTree(self.window, {"bg","btn_view","confirm_btn","Text"});

	self.m_twoBtn_leftBtn = publ_getItemFromTree(self.window, {"bg","btn_view","origin_confirm_btn"});
	self.m_twoBtn_leftText = publ_getItemFromTree(self.window, {"bg","btn_view","origin_confirm_btn","Text"});

	self.m_twoBtn_rightBtn = publ_getItemFromTree(self.window, {"bg","btn_view","discount_confirm_btn"});
	self.m_twoBtn_rightText = publ_getItemFromTree(self.window, {"bg","btn_view","discount_confirm_btn","Text"});

end

-- 从外部获取房间level
function OppoFirstChargeView.setRoomLevel( self, roomlevel )
	self.m_roomLevel = roomlevel;
end

-- -- 点击去低级场
function OppoFirstChargeView.onClickLowLevelBtn( self )
	if not self.m_roomLevel or self.m_roomLevel <=0 then
		DebugLog( "未传递level值" );
		return;
	end

		-- 请求换桌
	local param = {};
	param.mid = PlayerManager.getInstance():myself().mid;
	SocketManager.getInstance():sendPack(CLIENT_COMMAND_REQ_LOGOUT, param);
	--self:hideWnd();

	--if RoomScene_instance then
	--	RoomScene_instance:exitGame();
	--end

	--requestJoinLowLevelRoom( self._roomLevel );
	self.m_roomLevel = 0;
	self:hideWnd();
end

function OppoFirstChargeView.setNoEnoughMoney( self, enough )
	self.m_notEnoughMoney = enough;
end

-- -- 是否显示去低倍场按钮
-- function OppoFirstChargeView.showOrHideLowLevelBtn( self, award, money )
-- 	--能找到更低的场次
-- 	local hasLowLevel = nil 

-- 	local playerMoney = PlayerManager.getInstance():myself().money;
--     DebugLog("self._roomLevel")
--   	DebugLog(type(self._roomLevel))

--   	local slevel = tostring(self._roomLevel)
--    	DebugLog(slevel .."              = slevel")
--     local curType = HallConfigDataManager.getInstance():returnTypeForLevel(slevel)
-- 	--DebugLog(curType)
-- 	local curKey = HallConfigDataManager.getInstance():returnKeyByType(curType)
--     --DebugLog("key: " .. curKey)

-- 	local btnMid = self:getControlFromConfigTab( "midBtn" );
-- 	local btnConfirm = self:getControlFromConfigTab( "btnConfirm" );
-- 	local btnLowLevel = self:getControlFromConfigTab( "btnLowLevel" );


--     if not curKey then 
-- 		DebugLog( "不显示去低倍场按钮" );
-- 		btnLowLevel:setVisible( false );	
-- 		btnConfirm:setVisible( false );
-- 		btnMid:setVisible( true );
-- 		self._roomLevel = 0;    	
--     	return 
--     end 
    
--     local suc,hallData = HallConfigDataManager.getInstance():returnDataByKey(curKey,tonumber(playerMoney))
--     if not suc or not hallData then 
-- 		DebugLog( "不显示去低倍场按钮" );
-- 		btnLowLevel:setVisible( false );	
-- 		btnConfirm:setVisible( false );
-- 		btnMid:setVisible( true );
-- 		self._roomLevel = 0;    	
--     	return
--     end

	
-- 	if GameConstant.isShowLowLevelBtn and 
-- 	 	RoomScene_instance and 
-- 		self._noEnoughMoney and ( playerMoney >= GameConstant.bankruptMoney ) then

-- 		self._noEnoughMoney = false;

-- 		btnMid:setVisible( false );
-- 		btnConfirm:setVisible( true );
-- 		btnLowLevel:setVisible( true );
-- 		publ_getItemFromTree(self.window , OppoFirstChargeView.s_controlsMap["btnLowLevelText"]):setText("去低倍场");

-- 		btnConfirm:setOnClick( self, function( self )
-- 			self:onClickConfirmBtn( award, money );
-- 		end);

-- 		btnLowLevel:setOnClick( self, self.onClickLowLevelBtn );
-- 	else
-- 		DebugLog( "不显示去低倍场按钮" );
-- 		btnLowLevel:setVisible( false );	
-- 		btnConfirm:setVisible( false );
-- 		btnMid:setVisible( true );
-- 		self._roomLevel = 0;
-- 	end
-- end

OppoFirstChargeView.nativeCallEvent = function(self,param, _detailData)
	DebugLog("OppoFirstChargeView:nativeCallEvent  ++++++");
	if kDownloadImageOne == param then
		if _detailData == self.imgPathLeft then
			DebugLog("OppoFirstChargeView:nativeCallEvent  ++++++self.imgPathLeft==" .. self.imgPathLeft);
			self.m_image1Pic:setFile( self.imgPathLeft );
		elseif _detailData == self.imgPathMid then
			-- self.m_image2Pic:setFile( self.imgPathMid );
		elseif _detailData == self.imgPathRight then
			self.m_image3Pic:setFile( self.imgPathRight );
		end
	end
end

OppoFirstChargeView.dtor = function(self)
	DebugLog("OppoFirstChargeView dtor");
	EventDispatcher.getInstance():unregister(SocketManager.s_phpMsg, self, self.onPhpMsgResponse);

	EventDispatcher.getInstance():unregister(NativeManager._Event, self, self.nativeCallEvent);

	Loading.hideLoadingAnim();
	self:removeAllChildren();
end

--请求首充大礼包
OppoFirstChargeView.requestFirstChargeData = function(self)
	local param = {};
	param.mid = PlayerManager.getInstance():myself().mid;
	SocketManager.getInstance():sendPack( PHP_CMD_REQUEST_FIRST_CHARGE_DATA, param)
	
end

--请求首充大礼包回调
OppoFirstChargeView.requestFirstChargeDataCallBack = function(self,isSuccess, data)

	self.isOpenFirstChargeView = 0;

	if not isSuccess or not data then
		return;
	end

	local status = data.status or -1;
	local dataInfo = data.data;
	if 1 ~= status or not data then
		return;
	end

	self.isOpenFirstChargeView = data.data.open or 0;

	self:setMonthGiftMark( dataInfo );

	self.firstChargeData = dataInfo;

	self.m_money = dataInfo.price or 6;
	-- DebugLog( "OppoFirstChargeView.requestFirstChargeDataCallBack ++++++++有数据" );
	self:isDownloadImg( self.isOpenFirstChargeView, self.firstChargeData );
	-- -- DebugLog( "self.firstChargeData" );
	-- -- mahjongPrint( self.firstChargeData );
	if 1 == self.isOpenFirstChargeView then
		new_pop_wnd_mgr.get_instance():add_and_show( new_pop_wnd_mgr.enum.first_charge );
	else
		self:hide();
	end

	if PlatformConfig.platformOPPO == GameConstant.platformType then 
		SocketManager.getInstance():sendPack(PHP_CMD_OPPO_REQEUST_FIRSTCHARGE_EQUAL,nil);
	end
end

OppoFirstChargeView.setMonthGiftMark = function(self, dataInfo )
	local paytype = GetNumFromJsonTable(dataInfo , "paytype" , 0);
	if paytype == 1 then
		self.isMonthGiftPacks = true;
	else
		self.isMonthGiftPacks = false;
	end
	if self.isOpenFirstChargeView == 0 then
		self.isMonthGiftPacks = false;
	end
end

OppoFirstChargeView.clearData = function(self)
	self.firstChargeData = nil;
	self.isOpenFirstChargeView = 0;
end

OppoFirstChargeView.isDownloadImg = function(self,isMonthGiftPacks, data )
	DebugLog("OppoFirstChargeView.isDownloadImg ++++");
	if not data or ( data and not data.goods ) then
		return;
	end
DebugLog("OppoFirstChargeView.isDownloadImg 准备++++");
	if isMonthGiftPacks then
		local index = 1;
		local leftPath = "";
		local midPath = "";
		local rightPath = "";
		for k,item in pairs(data.goods) do
			if type( item ) == "table" then
				if index == 1 then
					
					leftPath = item.img and item.img or "";
					DebugLog("leftPath index == 1===" .. leftPath .. " ++++++");
				elseif index == 2 then

					midPath = item.img and item.img or "";
					DebugLog("leftPath index == 2===" .. midPath .. " ++++++");
				elseif index == 3 then
					rightPath = item.img and item.img or "";
					DebugLog("leftPath index == 3===" .. rightPath .. " ++++++");
				end
			end

			index = index + 1;
		end

		local isExist = false;
		DebugLog("leftPath ===" .. leftPath .. " ++++++");
		isExist, self.imgPathLeft = NativeManager.getInstance():downloadImage(leftPath);

		if isExist then
			DebugLog("leftPath 文件存在===");
			self.m_image1Pic:setFile( self.imgPathLeft );
		else
			DebugLog("leftPath 文件不存在===");
			self.m_image1Pic:setFile( "newHall/task/task.png" );
		end

		isExist, self.imgPathMid = NativeManager.getInstance():downloadImage(midPath);
		if isExist then
			DebugLog("imgPathMid 文件存在===");
			-- self.m_image2Pic:setFile( self.imgPathMid );
		else
			DebugLog("imgPathMid 文件不存在===");
			-- self.m_image2Pic:setFile( "newHall/task/task.png" );
		end

		isExist, self.imgPathRight = NativeManager.getInstance():downloadImage(rightPath);

		if isExist then
			DebugLog("imgPathRight 文件存在===");
			self.m_image3Pic:setFile( self.imgPathRight );
		else
			DebugLog("imgPathRight 文件不存在===");
			self.m_image3Pic:setFile( "newHall/task/task.png" );
		end

		self.m_image1Pic:setSize( 118, 118 );
		-- self.m_image2Pic:setSize( 118, 118 );
		self.m_image3Pic:setSize( 118, 118 );
	else
	end
end

-- 成功显示时返回true，失败显示时返回false
OppoFirstChargeView.show = function(self)
	if self.isOpenFirstChargeView == 1 then
		self:refreshView();
		return true;
	else
		return false;
	end
end

function OppoFirstChargeView:onWindowShow()
	self.super.onWindowShow( self );

	local image1 = publ_getItemFromTree(self.window , {"bg","item_view","Image1","p"});
	local image2 = publ_getItemFromTree(self.window , {"bg","item_view","Image2","p"});
	local image3 = publ_getItemFromTree(self.window , {"bg","item_view","Image3","p"});
	local m_addAnim1 = image1:addPropScale(0 , kAnimNormal , 200 , 100 , 1.0 , 1.2 , 1.0 , 1.2 , kCenterDrawing);
	image2:addPropScale(0 , kAnimNormal , 200 , 100 , 1.0 , 1.2 , 1.0 , 1.2 , kCenterDrawing);
	image3:addPropScale(0 , kAnimNormal , 200 , 100 , 1.0 , 1.2 , 1.0 , 1.2 , kCenterDrawing);
	m_addAnim1:setEvent(self , function( self )
		image1:removeProp(0);
		image2:removeProp(0);
		image3:removeProp(0);
		local addAnim_2 = image1:addPropScale(0 , kAnimNormal , 200 , 0 , 1.2, 1.0 , 1.2 , 1.0 , kCenterDrawing);
		image2:addPropScale(0 , kAnimNormal , 200 , 0 , 1.2, 1.0 , 1.2 , 1.0 , kCenterDrawing);
		image3:addPropScale(0 , kAnimNormal , 200 , 0 , 1.2, 1.0 , 1.2 , 1.0 , kCenterDrawing);
		addAnim_2:setEvent(self , function( self )
			image1:removeProp(0);
			image2:removeProp(0);
			image3:removeProp(0);
		end);
	end);
end

function OppoFirstChargeView:onWindowHide()
	self.super.onWindowHide( self );
	new_pop_wnd_mgr.get_instance():hide_and_show( new_pop_wnd_mgr.enum.first_charge );
	if 1 == self.bankruptFlag and PlayerManager.getInstance():myself().money < GameConstant.bankruptMoney and RoomScene_instance then
		GlobalDataManager.getInstance():showBankruptDlg(nil,RoomScene_instance);
		self.bankruptFlag = 0;
	end
end

OppoFirstChargeView.refreshView = function(self)
	DebugLog(self.isOpenFirstChargeView)

	if self.m_visible or 1 ~= self.isOpenFirstChargeView then
		return;
	end

	if not self.firstChargeData then
		Loading.showLoadingAnim();
		self:requestFirstChargeData();
		return;
	end

	local pdata;

	mahjongPrint(self.firstChargeData)

	-- DebugLog(self.isMonthGiftPacks)
	-- Banner.getInstance():showMsg(self.isMonthGiftPacks);

	if self.isMonthGiftPacks then
		-- self.m_:setFile("fastBuy/month_title.png");
		
	else
		-- self.window_title:setFile("fastBuy/new_title.png");
		pdata = ProductManager.getInstance().m_productListAll; --月度大礼包不需要拉取
		if not pdata then
			return;
		end
	end
	
	local data = self.firstChargeData;

	-- DebugLog("---***!!!@@@-----------")

	self:isDownloadImg(true, data);


	-- 产品说只有两个，否则发版本
	if data.title == "新人大礼包" then 
		self.m_titleBg:setFile("Login/oppo/firstcharge/new_player.png");
	else
		self.m_titleBg:setFile("Login/oppo/firstcharge/first_pay.png");
	end

	local money = data.price or 6;

	local awardText = data.gift_title or "20元超值豪华大礼包";

	self.m_not_oppo_titlePamount:setText(money);
	self.m_not_oppo_awardThings:setText(awardText);

	self.m_oppo_titlePamount:setText(money);
	self.m_oppo_title_awardThings:setText(awardText);

	local product1 = data.goods[1].name;
	local product2 = data.goods[2].name;
	local product3 = data.goods[3].name;

	self.m_image1Text:setText(product1);
	-- self.m_image2Text:setText(product2);
	self.m_image3Text:setText(product3);

	if not PayController:containsPamountSmsPay(money) then 
		self:showWnd();
		return;
	end

	local button_title = data.btn_title or "购买";
	self.m_oneBtn_confirmText:setText(button_title);

	-- local award = GetNumFromJsonTable(data , "award" , 0);
	-- local textStr = GetStrFromJsonTable(data , "btn_title","领  取");
	-- local desc_v2 = data.desc_v2 or "";
	-- local moneydesc;
	-- if self.isMonthGiftPacks then
	-- 	--月度大礼包
	-- 	moneydesc = data.goods[1].name
	-- else
	-- 	for k, v in pairs(pdata) do
	-- 		if tonumber(v.pamount) == tonumber(money) then
	-- 			moneydesc = v.pname;
	-- 		end
	-- 	end
	-- end
	
	-- local giftdesc1 = data.goods[1].num .. "金币" ;

	-- local giftdesc2;
	-- local giftdesc3;
	-- if self.isMonthGiftPacks then
	-- 	--月度大礼包
	-- 	giftdesc2 = data.goods[2].name
	-- 	giftdesc3 = data.goods[3].name

	-- else
	-- 	giftdesc2 = data.goods[2].name .. "+" ..  data.goods[3].name
	-- end
	
	-- local vipdesc = data.vipdesc or "终身至尊VIP"

	-- self.text1 = publ_getItemFromTree(self.window, {"img_win_bg", "Text1"});
	-- local text4 = publ_getItemFromTree(self.window, {"img_win_bg", "Text4"}); -- 60,000金币
	-- local text5 = publ_getItemFromTree(self.window, {"img_win_bg", "Text5"}); -- 100,000金币
	-- --local text6 = publ_getItemFromTree(self.window, {"img_win_bg", "Text6"}); -- +补签卡+龙戒
	-- local text7 = publ_getItemFromTree(self.window, {"img_win_bg", "Text7"}); -- 终身至尊VIP

	

	-- local bold = {};
	-- local pos = {};
	-- local ptr = 1;
	-- local tmp_text = "";
	-- local node;
	-- self.text1:removeAllChildren();

	-- if #(data.bold) > 0 then
	-- 	for i =1, #(data.bold) do
	-- 		table.insert(bold, data.bold[i])
	-- 	end
	-- 	while ptr < string.len(desc_v2) do
	-- 		if #bold > 0 then
	-- 			local a, b = string.find(desc_v2, bold[1]);
	-- 			if ptr == a then
	-- 				tmp_text = string.sub(desc_v2, ptr, b);
	-- 				ptr = b + 1;
	-- 				table.remove(bold, 1);
	-- 				node = self:createNode(tmp_text, 34, 0xff, 0xdc, 0x00);
	-- 			else
	-- 				tmp_text = string.sub(desc_v2, ptr, a-1);
	-- 				ptr = a;
	-- 				node = self:createNode(tmp_text, 30, 0xff, 0xc5, 0x87);---normal font
	-- 			end
	-- 		else
	-- 			tmp_text = string.sub(desc_v2, ptr, string.len(desc_v2));
	-- 			ptr = string.len(desc_v2);
	-- 			node = self:createNode(tmp_text, 30, 0xff, 0xc5, 0x87);
	-- 		end
	-- 		DebugLog("ttt " .. tmp_text);
	-- 		self:addNode(node);
	-- 	end
	-- else
	-- 	node = self:createNode(desc_v2, 30, 0xff, 0xc5, 0x87);
	-- 	self:addNode(node);
	-- end

	-- self:createNodes();
	-- text4:setText(moneydesc);
	-- text5:setText(giftdesc2);
	-- if self.isMonthGiftPacks then
	-- 	--text6:setVisible( false );
	-- 	text7:setText(giftdesc3);
	-- else
	-- 	--text6:setText(giftdesc2);
	-- 	--text6:setVisible( true );
	-- 	text7:setText(vipdesc);
	-- end

	

	-- local midBtn = publ_getItemFromTree(self.window , OppoFirstChargeView.s_controlsMap["midBtn"]);
	-- midBtn:setOnClick(self, function ( self )
	-- 	self:onClickConfirmBtn( award, money );
	-- end);
	-- local midBtnName = publ_getItemFromTree(self.window , OppoFirstChargeView.s_controlsMap["midBtnName"]);
	-- if 1 == award then
	-- 	textStr = "领  取";
	-- end
	-- midBtnName:setText(textStr);
	-- self:showOrHideLowLevelBtn( award, money );
	self:showWnd();
	
	-- if GameConstant.checkType ~= 0 then 
	-- 	publ_getItemFromTree(self.window,{"img_win_bg","btn_mid"}):setVisible(false);
	-- 	publ_getItemFromTree(self.window,{"img_win_bg","btn_low_level"}):setVisible(true);
	-- 	publ_getItemFromTree(self.window,{"img_win_bg","btn_confirm"}):setVisible(true);
	-- 	publ_getItemFromTree(self.window,{"img_win_bg","btn_low_level","btn_confirm_text"}):setText("取消");

	-- 	publ_getItemFromTree(self.window,{"img_win_bg","btn_low_level"}):setOnClick(self,self.hide);
	-- 	publ_getItemFromTree(self.window,{"img_win_bg","btn_confirm"}):setOnClick(self,function(self)
	-- 		umengStatics_lua(UMENG_FIRST_CHARGE_BUY_CLICK); --上报购买
	-- 		-- 购买
	-- 		local scene = {};
	-- 		scene.scene_id = PlatformConfig.HallBuyForPay;

	-- 		local data = self.firstChargeData;
	-- 		local money = GetNumFromJsonTable(data , "price" , 6);
			
	-- 		GlobalDataManager.getInstance():quickPay(money , scene);
	-- 		self:hideWnd();
	-- 	end);

	-- end 
	return true;
end

OppoFirstChargeView.requestFirstPayEqualCallBack = function(self,isSuccess,data)
	if isSuccess then 
		local status = data.status or 0;
		if tonumber(status) == 1 then 
			local pay_mode = data.data.pmode;
			local pay_money = tonumber(data.data.first_pay_money or 0);
			if pay_money > 0 then 
				self:executeOppoShow(pay_mode,pay_money);

				self.m_oppo_titleView:setVisible(true);
				self.m_not_oppo_titleView:setVisible(false);

				return;
			end
		end

		self.m_oppo_titleView:setVisible(false);
		self.m_not_oppo_titleView:setVisible(true);

		self:showNormalBtn();

		-- self.isShowOppoFlag = false;
		-- self:showOrHideLowLevelBtn( self.m_award, self.m_money );
		-- self:showWnd();
	end
end

OppoFirstChargeView.showNormalBtn = function(self)
	
	local playerMoney = PlayerManager.getInstance():myself().money;
	if GameConstant.isShowLowLevelBtn and RoomScene_instance and self.m_notEnoughMoney and ( playerMoney >= GameConstant.bankruptMoney ) then

		self.m_notEnoughMoney = false;
		self.m_twoBtn_rightBtn:setVisible(true);
		self.m_twoBtn_leftBtn:setVisible(true);

		self.m_oneBtn_confirmBtn:setVisible(false);

		self.m_twoBtn_leftText:setText("去低倍场");

		local button_title = self.firstChargeData.button_title or "购买";
		self.m_twoBtn_rightText:setText(button_title);

		self.m_twoBtn_rightBtn:setOnClick(self,function(self)
			local product = ProductManager.getInstance():getProductByPamount(tonumber(self.m_money));
		
			if not product then 
				return ;
			end

			PayController:payForGoods(true, product, true);
			self:hideWnd();
		end);

		self.m_twoBtn_leftBtn:setOnClick(self,self.onClickLowLevelBtn);

		return;
	end

	self.m_twoBtn_rightBtn:setVisible(false);
	self.m_twoBtn_leftBtn:setVisible(false);

	self.m_oneBtn_confirmBtn:setVisible(true);

	self.m_oneBtn_confirmBtn:setOnClick(self,function(self)
		local product = ProductManager.getInstance():getProductByPamount(tonumber(self.m_money));
		
		if not product then 
			return ;
		end

		PayController:payForGoods(true, product, true);
			self:hideWnd();
	end);
end

OppoFirstChargeView.executeOppoShow = function(self,paymode,payMoney)
	if tonumber(payMoney or 0) > 0 then 
		local discount = math.floor(payMoney / self.m_money * 10);
		self.m_oppo_discountPamount:setText(payMoney);

		self.m_oppo_money = payMoney;
		self.isShowOppoFlag = true;

		self.m_twoBtn_rightBtn:setVisible(true);
		self.m_twoBtn_leftBtn:setVisible(true);

		self.m_twoBtn_leftText:setText("原价购买");
		self.m_twoBtn_rightText:setText(discount .. "折秒杀");

		if not PayController:containsPamountSmsPay(self.m_money) then 
			self.m_twoBtn_rightBtn:setVisible(false);
			self.m_twoBtn_leftBtn:setVisible(false);

			self.m_oneBtn_confirmBtn:setVisible(true);
			self.m_oneBtn_confirmText:setText(discount .. "折秒杀");

			self.m_oneBtn_confirmBtn:setOnClick(self,function(self)
					local product = ProductManager.getInstance():getProductByPamount(tonumber(self.m_oppo_money));
					if not product then 
						return ;
					end

					local payScene = {};
					payScene.scene_id = PlatformConfig.oppoFirstCharge;
					PayController:callThirdPay(product,PlatformConfig.OppoPay);
					self:hideWnd();

			end)
			return;
		end

		self.m_twoBtn_rightBtn:setOnClick(self,function(self)

			local product = ProductManager.getInstance():getProductByPamount(tonumber(self.m_oppo_money));
			if not product then 
				return ;
			end

			local payScene = {};
			payScene.scene_id = PlatformConfig.oppoFirstCharge;
			PayController:callThirdPay(product,PlatformConfig.OppoPay);
			self:hideWnd();
		end);

		self.m_twoBtn_leftBtn:setOnClick(self,function(self)
			local product = ProductManager.getInstance():getProductByPamount(tonumber(self.m_money));
			if not product then 
				return ;
			end

			PayController:payForGoods(true, product, false);
			self:hideWnd();
		end);

		self.m_oneBtn_confirmBtn:setVisible(false);

	end
	-- self:showOrHideLowLevelBtn( self.m_award, self.m_money );

end



OppoFirstChargeView.hide = function ( self )
	Loading.hideLoadingAnim();
	self:setVisible(false);
	self.isNeedToShowView = false;	
end

OppoFirstChargeView.hideWnd = function ( self )
	self.super.hideWnd(self)	
	return true
end

OppoFirstChargeView.onPhpMsgResponse = function(self,param, cmd, isSuccess )
	if self.phpMsgResponseCallBackFuncMap[cmd] then 
		self.phpMsgResponseCallBackFuncMap[cmd](self,isSuccess,param)
	end
end

OppoFirstChargeView.phpMsgResponseCallBackFuncMap = {
	[PHP_CMD_REQUEST_FIRST_CHARGE_DATA]  = OppoFirstChargeView.requestFirstChargeDataCallBack,
	[PHP_CMD_OPPO_REQEUST_FIRSTCHARGE_EQUAL] = OppoFirstChargeView.requestFirstPayEqualCallBack

};
