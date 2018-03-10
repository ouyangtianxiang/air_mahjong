local fastBuyPopWindow = require(ViewLuaPath.."fastBuyPopWindow");
RechargeTip = class(SCWindow)

--[[
-- @param isShow        false -> 直接进行支付 true -> 弹框支付
-- @param roomlevel     房间Level
-- @param money 	    房间进入最低金额
-- @param quickTips     提示
-- @param recommend     推荐商品的金额数
-- @param matchQuitFlag 比赛场快充标示
--money:传入要显示的金额，有推荐优先推荐（recommend）
-- cardType :大奖赛判断道具卡（雀圣卡 ）
-- is_check_bankruptcy:是否在处理破产逻辑
-- is_check_giftpack:是否处理礼包逻辑
-- @param matchType     比赛场类型
--moneytype:根据这个参数显示金币逻辑还是钻石逻辑
--如果当前审核状态开启则统一选择这个推荐产品  ProductManager.getInstance():getBankruptAndNotEventProduct()
]]

--enum
RechargeTip.enum = {
help_wnd = 1,
user_wnd = 2,
friend_match_wnd = 3,
enter_game = 4,
enter_match = 5,
buy_pro = 6,
giftpack = 7,--点击礼包
default = 8,

};

--所有快充逻辑统一创建方法
RechargeTip.create = function (param_t)

    param_t = param_t or {};
    param_t.t = param_t.t or RechargeTip.enum.default;
    local rechargeTip = new(RechargeTip, param_t);

end

RechargeTip.ctor = function (self, parametersTable, rootNode)
    DebugLog("[RechargeTip]:ctor");
    --此处是老代码
	if PlatformConfig.platformContest == GameConstant.platformType then
        DebugLog("PlatformConfig.platformContest == GameConstant.platformType");
		return;
	end


    parametersTable = parametersTable or {};
    self.rootNode = parametersTable.parent;
    self.m_type = parametersTable.t or RechargeTip.enum.default;
    self.m_is_check_bankruptcy = parametersTable.is_check_bankruptcy or false;
    self.m_is_check_giftpack = parametersTable.is_check_giftpack or false;




    --[Comment]
    --m_product_list 为冲值的产品列表
    --m_current_product_index 为当前所显示的product index
    --
    self.m_product_list = {};
    self.m_current_product_index = 1;

    self.matchCardProductList = {};
    self.matchType = matchType;
    self.cardType = parametersTable.cardType;
    self.level = parametersTable.roomlevel;
    self._noEnoughMoney = parametersTable.noEnoughMoney;
    self.m_recommend = parametersTable.recommend;
    self.m_moneytype = parametersTable.moneytype or GameConstant.sc_money_type.coin;

	parametersTable.money = self:getReqiureMoney( parametersTable );
    --获取当前筛选的商品
	self.suggested = self:get_current_product(parametersTable);--self:getSuggestMoney( parametersTable );

    -- 如果没有推荐金额就结束，以免报错
	if not self.suggested then
        DebugLog("self.suggested is nil");
		return;
	end


    --如果需要进行破产判断
    if self.m_is_check_bankruptcy and PlayerManager.getInstance():myself().money < GameConstant.bankruptMoney then
		GlobalDataManager.getInstance():showBankruptDlg(parametersTable.roomlevel ,self.rootNode or GameConstant.curGameSceneRef);
        DebugLog("弹出破产");
		return;
	end

    --如果是审核状态则开启二次确认的温馨提示
    if tonumber(GameConstant.checkType) == kCheckStatusOpen then
        local product = ProductManager.getInstance():getBankruptAndNotEventProduct();
        if product then
            self.nowAmount = product.pamount
            local text = "购买超值金币，畅想精彩游戏！你将购买"..product.pname .. "，资费" .. product.pamount .. "元！你确定要购买吗？\n客服电话:400-663-1888或0755-86166169";

            local view = PopuFrame.showNormalDialog( "温馨提示", text, GameConstant.curGameSceneRef, nil,nil,true, false,"购买","取消");
            view:setConfirmCallback(self, function ( self )
                self:payDirectly();
            end);
            view:setCallback(view, function ( view )
                
            end);
        end
        return
    end

    --如果需要弹出礼包
    if self.m_is_check_giftpack then
        --设置低倍场相关的参数
        if parametersTable.noEnoughMoney ~= nil then
            FirstChargeView.getInstance():setNoEnoughMoney( parametersTable.noEnoughMoney );

        end
        if parametersTable.roomlevel ~= nil then
            FirstChargeView.getInstance():setRoomLevel( parametersTable.roomlevel );
        end

        --审核关闭的状态才可以展示礼包
        if GameConstant.checkType == kCheckStatusClose then
            local probability_judgment = parametersTable.probability_giftpack or GlobalDataManager.getInstance():get_pop_charge_probability().giftpack;
            if GameConstant.platformType == PlatformConfig.platformChubao then --触宝联运
                probability_judgment = 1 
            end
            if probability_judgment >= 1 then--概率>=1 直接显示
                if FirstChargeView.getInstance():show() then
                    DebugLog("弹出礼包");
                    return;
                end
            else--概率0-1
                --先保证每天首次弹礼包--概率弹出礼包
                local current_time = os.time();
                local date = os.date("*t", current_time);
                local last_day = g_DiskDataMgr:getAppData(GameConstant.k_per_day_gift,0)

                --方便测试观看
                if 1 == DEBUGMODE then
                    local str = "Test [日期]: today:"..tostring(date.day).." last_day:"..tostring(last_day);
                    --Banner.getInstance():showMsg(str);
                    DebugLog(str);
                end

                if last_day ~= date.day then--每天首次弹快速充值
                    g_DiskDataMgr:setAppData(GameConstant.k_per_day_gift, date.day)
                else
                    local probability_judgment = probability_judgment*100;
                    local probability = math.random(1,100)
                    if 1 == DEBUGMODE then
                        local str = "Test [依据概率]:"..tostring(probability_judgment).." [此次概率]:"..tostring(probability);
                        --Banner.getInstance():showMsg(str);
                        DebugLog(str);
                    end

                    if probability <= probability_judgment then
                        if FirstChargeView.getInstance():show() then
                            DebugLog("弹出礼包");
                            return;
                        end
                    end
                end
            end
        end
    end


	GameConstant.isLevelProductFlag = false;
	self.window = SceneLoader.load(fastBuyPopWindow);
	self:addChild(self.window);
	if self.rootNode then
		self.rootNode:addChild(self);
	else
		self:addToRoot();
	end

    if self.cardType then
        --self:get_list_card_type();
	elseif self.level then
		if not GameConstant.isNewRecommendVipProduct then
			ProductManager.getInstance():parseRecommendLevelProduct();
		end
	else
		if not GameConstant.isNewRecommendVipProduct then
			ProductManager.getInstance():parseRecommendVipProduct();
		end
	end

	self.bg = publ_getItemFromTree(self.window,{"img_win_bg"});
	self:setWindowNode( self.bg );
	self:initView();
	self:setBuyListItem(self.suggested);

	local isMatchKickOut = self:isMatchKickOut( parametersTable );
	self:setViewContentAndEvent( isMatchKickOut, parametersTable ); -- 设置控件内容以及事件
	self:showOrHideLowLevelBtn( isMatchKickOut, parametersTable ); -- 是否显示低倍场按钮

     --如果为起凡，将联系方式改为QQ
    if GameConstant.platformType == PlatformConfig.platformDingkai then
        self.phoneNum = publ_getItemFromTree(self.window, {"img_win_bg", "img_win_inner_bg", "view_phone", "btn_phone1"});
        self.phoneNum:setVisible(false);
        publ_getItemFromTree(self.window, {"img_win_bg", "img_win_inner_bg", "view_phone", "btn_phone2"}):setVisible(false);
        self.QQ = publ_getItemFromTree(self.window, {"img_win_bg", "img_win_inner_bg", "view_phone", "view_text2", "Text2"});
        self.QQ:setText("QQ:2897738207");
        local x, y = self.QQ:getPos();
        self.QQ:setPos(x - 100, y);
    end
    --是否显示礼包按钮--需求已经去掉，后续再看是否添加
--    local btn_gift = publ_getItemFromTree(self.window, {"img_win_bg", "btn_gift"});
--    if btn_gift then
--        btn_gift:setVisible(FirstChargeView.getInstance().isOpenFirstChargeView == 1);
--        btn_gift:setOnClick(self, function (self)
--              FirstChargeView.getInstance():show();
--              self:hideWnd();
--              return;
--        end);
--    end

    DebugLog("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~:"..tostring(parametersTable.isShow))
	if not parametersTable.isShow then
		self:payDirectly();
		return;
	else
		self:showWnd();
	end

end

-- 初始化控件
function RechargeTip.initView( self )

	self.btnUpdate = publ_getItemFromTree(self.window,{"img_win_bg","img_win_inner_bg", "img_item_bg", "btn_update" });
	self.btnConfirm = publ_getItemFromTree(self.window,{"img_win_bg","btn_comfirm"});
	self.btnClose = publ_getItemFromTree(self.window,{"img_win_bg","btn_close"});

	self.textTips = publ_getItemFromTree(self.window,{"img_win_bg","img_win_inner_bg", "view_tip", "text_tip"});
	self.textMatchTip1 = publ_getItemFromTree(self.window,{"img_win_bg","img_win_inner_bg", "view_tip", "text_tip1"});
	self.textMatchTip2 = publ_getItemFromTree(self.window,{"img_win_bg","img_win_inner_bg", "view_tip", "text_tip2"});
	self.textMatchTip3 = publ_getItemFromTree(self.window,{"img_win_bg","img_win_inner_bg", "view_tip", "text_tip3"});

	self.btnQuit = publ_getItemFromTree(self.window,{"img_win_bg","btn_quit"});
	self.btnBuy = publ_getItemFromTree(self.window,{"img_win_bg","btn_buy"});

	self.btn_phone1 = publ_getItemFromTree(self.window,{"img_win_bg","img_win_inner_bg", "view_phone", "btn_phone1" });
	self.text_phone1 = publ_getItemFromTree(self.window,{"img_win_bg","img_win_inner_bg", "view_phone", "btn_phone1", "text_phone1" });
	self.btn_phone2 = publ_getItemFromTree(self.window,{"img_win_bg","img_win_inner_bg", "view_phone", "btn_phone2" });
	self.text_phone2 = publ_getItemFromTree(self.window,{"img_win_bg","img_win_inner_bg", "view_phone", "btn_phone2", "text_phone2" });
	self.view_phone = publ_getItemFromTree(self.window,{"img_win_bg","img_win_inner_bg", "view_phone"});

	self.productName = publ_getItemFromTree(self.window,{"img_win_bg","img_win_inner_bg", "img_item_bg", "text_tip1" });
	self.productDesc = publ_getItemFromTree(self.window,{"img_win_bg","img_win_inner_bg", "img_item_bg", "text_tip2" });

    --类型图片
    self.money_type_img = publ_getItemFromTree(self.window,{"img_win_bg","img_win_inner_bg", "img_item_bg", "Image2" });

	--如果当前为审核状态，就需要取消按钮
    if tonumber(GameConstant.checkType) == kCheckStatusOpen then
		self.btnQuit:setVisible(true); --目前为取消
		self.btnBuy:setVisible(true);  --为确定
		self.btnConfirm:setVisible(false);
		DebugLog("如果当前需要取消按钮 ");
		publ_getItemFromTree(self.window,{"img_win_bg","btn_buy", "Text3"}):setText("购买");
	    self.textCancel = UICreator.createText("取消",0,0,continueW,continueH,kAlignCenter,30,255,255,255);
	    self.textCancel:setAlign(kAlignCenter);
        self.btnQuit:addChild(self.textCancel);
        self.btnQuit:setOnClick(self, function ( self )
        	self:hideWnd();
        end);

		self.btnBuy:setOnClick(self, self.onClickComfirmBtn );
    end
    if GameConstant.platformType == PlatformConfig.platformOPPO then 
        publ_getItemFromTree(self.window,{"img_win_bg","btn_buy", "Text3"}):setText("购买")
    end

    if PlatformConfig.platformWDJ == GameConstant.platformType or
	   PlatformConfig.platformWDJNet == GameConstant.platformType then
		self.btnClose:setFile("Login/wdj/Hall/Commonx/close_btn.png");
		self.btnClose.disableFile = "Login/wdj/Hall/Commonx/close_btn_disable.png";
	end

    if GameConstant.iosDeviceType>0 and GameConstant.iosPingBiFee then
        self.productDesc:setVisible(false)
    end
end

--[Comment]
--获取产品列表
RechargeTip.get_current_product_list = function (self, parametersTable)
    parametersTable = parametersTable or {};
    self.m_product_list = {};
    if self.m_moneytype == GameConstant.sc_money_type.diamond then
        self.m_product_list = self:get_list_diamond();
    elseif parametersTable.cardType then
        self.m_product_list = self:get_list_card_type();
	elseif parametersTable.roomlevel then
        self.m_product_list = self:get_list_level();
	else
		self.m_product_list = self:get_list_default();
	end

    return self.m_product_list;
end

--[Comment]
--比赛报名界面 根据card type 来挑选产品列表
RechargeTip.get_list_card_type = function (self)
    local list = {};
    local productList = ProductManager.getInstance().m_productListSource;
	for i = 1,#productList do
        local extra_present =  productList[i].extra_present;
        if extra_present and #extra_present >= 1 then
            for j = 1, #extra_present do
                if tonumber(extra_present[j].gid) and tonumber(extra_present[j].gid) == self.cardType then
                    table.insert(list, productList[i]);
                    break;
                end
            end
        end
    end
    if #list > 0 then
        --根据pamount 排序
        local sort_paymount = function (v1 , v2)
	        return (tonumber(v1.pamount) or 0) < (tonumber(v2.pamount) or 0)
        end
        table.sort(list, sort_paymount);
    end
    return list;

end

--获取钻石列表
RechargeTip.get_list_diamond = function (self)

    local list = GlobalDataManager.getInstance():get_list_diamond();

    local ret_list = {};
    local list_key = {};
    --去除重复价格的列表
    for i = 1, #list do
        if not list_key[list[i].pamount] then
            list_key[list[i].pamount] = true;
            local tmp = Copy(list[i])
            table.insert(ret_list, tmp);
        end
    end
    return ret_list;
end

--[Comment]
--根据level 来挑选 产品列表
RechargeTip.get_list_level = function (self)

    local list = GlobalDataManager.getInstance():get_list_level();

    local product = nil;
    for i = 1, #list do
        local level = tonumber(list[i]._level);
        if level and level == self.level then
            product = list[i];
            break;
        end
    end

    local ret_list = {};
    local list_key = {};
    --去除重复价格的列表
    for i = 1, #list do
        if product then
            if product.pamount == list[i].pamount and tonumber(self.level) == tonumber(list[i]._level) then
                 list_key[list[i].pamount] = true;
                local tmp = Copy(list[i])
                table.insert(ret_list, tmp);
            elseif product.pamount ~= list[i].pamount and not list_key[list[i].pamount] then
                list_key[list[i].pamount] = true;
                local tmp = Copy(list[i])
                table.insert(ret_list, tmp);
            end
        else
            if not list_key[list[i].pamount] then
                list_key[list[i].pamount] = true;
                local tmp = Copy(list[i])
                table.insert(ret_list, tmp);
            end
        end
    end
    return ret_list;
end

--[Comment]
--
RechargeTip.get_list_default = function (self)
    local list = GlobalDataManager.getInstance():get_list_default();

    local ret_list = {};
    local list_key = {};
    --去除重复价格的列表
    for i = 1, #list do
        if not list_key[list[i].pamount] then
            list_key[list[i].pamount] = true;
            local tmp = Copy(list[i])
            table.insert(ret_list, tmp);
        end
    end
    return ret_list;
end

-- 获取入场需要金额
function RechargeTip.getReqiureMoney( self, parametersTable )
    --如果是钻石
    if parametersTable and self.m_moneytype == GameConstant.sc_money_type.diamond then
        return  parametersTable.money or 0;
    end
	local requireMoney = 0;
	if parametersTable.roomlevel and not parametersTable.money then
		if not parametersTable.recommend then
			--比赛场的时候，recommend代表多少钱
			requireMoney = getMatchHallConfigRequireMoneyByLevel(parametersTable.roomLevel);
		else
			requireMoney = getHallConfigRequireMoneyByLevel(parametersTable.roomlevel);
		end
		return requireMoney;
	else
		return parametersTable.money;
	end
end

-- 获取推荐金额
function RechargeTip.getSuggestMoney( self, parametersTable )
	local suggested = nil;
    if parametersTable.cardType then
        self:get_list_card_type();
        if #self.matchCardProductList >= 1 then
            suggested =self.matchCardProductList[1];
        end
	elseif parametersTable.roomlevel then
		if not parametersTable.recommend then
			suggested = ProductManager.getInstance():getRecommendProductByEvent(parametersTable.roomlevel);
		else
			--比赛场的时候，recommend代表推荐商品的金额数
			suggested = ProductManager.getInstance():getProductByPamount(parametersTable.recommend);
		end
	else
		suggested = ProductManager.getInstance():getBankruptAndNotEventProduct();
	end
	return suggested;
end

--[Comment]
--获取当前商品
RechargeTip.get_current_product = function (self, parametersTable)
    if GameConstant.checkType == kCheckStatusOpen then --审核
        return ProductManager.getInstance():getBankruptAndNotEventProduct()
    end
    parametersTable = parametersTable or {};
	local current_product = nil;
    local product_list = self:get_current_product_list(parametersTable);
    if not product_list or #product_list < 1 then
        DebugLog("list is nil");
        return nil;
    end

--    --根据pamount 排序
--    local sort_paymount = function (v1 , v2)
--	    return (tonumber(v1.pamount) or 0) < (tonumber(v2.pamount) or 0)
--    end
--    table.sort(product_list, sort_paymount);
    if self.m_moneytype == GameConstant.sc_money_type.diamond then
        --by 欧阳 因为目前所有的钻石充值需求用列表中的第一个都可以满足，所以取第一个
        if #product_list > 0 then
            current_product = product_list[1]
            self.m_current_product_index = 1;
        end
    elseif parametersTable.cardType then
        current_product = product_list[1];
	elseif parametersTable.roomlevel then
		if not parametersTable.recommend then
             --如果有推荐level，取对应推荐level的商品
            for i = 1, #product_list do
                local level = tonumber(product_list[i]._level);
                if level and level == parametersTable.roomlevel then
                    current_product = product_list[i];
                    self.m_current_product_index = i;
                    break;
                end
            end
            --如果没找到，取第一个
            if not current_product then
                current_product = product_list[1]
                self.m_current_product_index = 1;
            end
		else
            --如果有推荐金额，取对应推荐金额的商品
            for i = 1, #product_list do
                if product_list[i].pamount and product_list[i].pamount == parametersTable.recommend then
                    current_product = product_list[i];
                    self.m_current_product_index = i;
                    break;
                end
            end
            --如果没找到，取第一个
            if not current_product then
                current_product = product_list[1]
                self.m_current_product_index = 1;
            end
		end
	else
        local my_vip_level = PlayerManager.getInstance():myself().vipLevel;
        local pamount = nil;
        for k,v in pairs(GameConstant.vip_tuiJianProduct) do
            if tonumber(k) == my_vip_level then
                pamount = tonumber(v);
                break;
            end
        end
        --如果有推荐vip，取对应推荐vip的商品
        for i = 1, #product_list do
            if product_list[i].pamount == pamount then
                current_product = product_list[i];
                self.m_current_product_index = i;
                break;
            end
        end
        --如果没找到，取第一个
        if not current_product then
            current_product = product_list[1]
            self.m_current_product_index = 1;
        end
	end
	return current_product;
end

-- 是否是在比赛中钱不够被踢时充值
function RechargeTip.isMatchKickOut( self , parametersTable )
	self.matchQuitFlag = parametersTable.matchQuitFlag and true;
	if MatchRoomScene_instance and parametersTable.matchQuitFlag then
		return true;
	else
		return false;
	end
end

-- 控制控件的显示或影藏
function RechargeTip.showOrHideMatchView( self, isMatchKickOut )
	if isMatchKickOut then
		self.btnConfirm:setVisible(false);
		self.btnClose:setVisible(false);
		self.textTips:setVisible(false);
		self.btnQuit:setVisible(true);
		self.btnBuy:setVisible(true);

		local str = "当前排名" .. ( GameConstant.matchResultStatus.rank or "" ) .. "/" .. ( GameConstant.matchResultStatus.playingPeopleNum or "" );
		self.textMatchTip1:setText(str);
		self.textMatchTip1:setVisible(true);
		self.textMatchTip2:setVisible(true);
		self.btnBuy:setOnClick(self, self.onClickBuyBtn);
		self.btnQuit:setOnClick(self, self.onClickGiveUpBtn);

		local continueW, continueH = self.btnQuit:getSize();
		self.textQuit = UICreator.createText("认输( 8 )",0,0,continueW,continueH,kAlignCenter,30,255,255,255);
		self.textQuit:setAlign(kAlignCenter);
		self.btnQuit:addChild(self.textQuit);
		self.time = 8;
		self.str = "认输";
		self:timer();
	else
		if MatchRoomScene_instance or HallScene_instance and HallScene_instance.matchApplyWindow or GameConstant.matchTypeConfig.award == self.matchType then
			self.btnConfirm:setVisible(true);
			self.btnClose:setVisible(true);
			self.textTips:setVisible(true);
			self.textMatchTip1:setVisible(false);
			self.textMatchTip2:setVisible(false);
            self.textMatchTip3:setVisible(false)
--            if self.cardType then
--                local proStr = self.cardType == ItemManager.MATCH_WEEK_CARD and "周赛卡" or "雀圣卡"
--		        proStr = ("您的道具"..proStr.."不足，购买金币赠送报名卡");
--                self.textMatchTip3:setText(proStr);
--            end


			self.btnQuit:setVisible(false);
    		self.btnBuy:setVisible(false);
			self.view_phone:setVisible(false);

		end
	end
end

-- 去低级场
function RechargeTip.showOrHideLowLevelBtn( self, isMatchKickOut , parametersTable )

	--能找到更低的场次
	local hasLowLevel = nil

	local playerMoney = PlayerManager.getInstance():myself().money;

  	DebugLog("self.level")
  	DebugLog(type(self.level))

  	local slevel = tostring(self.level)
  	DebugLog(slevel .." = slevel")
    local curType = HallConfigDataManager.getInstance():returnTypeForLevel( slevel )
	local curKey = HallConfigDataManager.getInstance():returnKeyByType(curType)
    if not curKey then
    	return
    end

    local suc,hallData = HallConfigDataManager.getInstance():returnDataByKey(curKey,tonumber(playerMoney))
    if not suc or not hallData then
    	return
    end

	--标识是否是两房牌
	--local isInLFPFlag = HallConfigDataManager.getInstance():returnHallDataForLFPByLevel(self._roomLevel);
	local playerMoney = PlayerManager.getInstance():myself().money;
	if (not isMatchKickOut) and GameConstant.isShowLowLevelBtn and
		RoomScene_instance and self._noEnoughMoney
		and ( playerMoney >= GameConstant.bankruptMoney ) then

		self._noEnoughMoney = false;
		self.btnConfirm:setVisible(false);

		-- 使用与比赛场相同的按钮，避免重复代码
		self.btnQuit:setVisible(true);
		self.btnBuy:setVisible(true);

		self.btnBuy:setOnClick(self, self.onClickBuyBtn);
		self.btnQuit:setOnClick(self, self.onClickLowLevelBtn);

		self.textLowLevel = UICreator.createText("去低倍场",0,0,continueW,continueH,kAlignCenter,30,255,255,255);
		self.textLowLevel:setAlign(kAlignCenter);
		if self.textCancel and self.textCancel:getVisible() then
			self.textCancel:setVisible(false)
		end
		self.btnQuit:addChild(self.textLowLevel);
	end
end

-- 点击低倍场按钮
function RechargeTip.onClickLowLevelBtn( self )
	DebugLog( "RechargeTip.onClickLowLevelBtn" );
	if not self.level or self.level <= 0 then
		DebugLog( "未传递level值" );
		return;
	end

	-- 请求换桌
	local param = {};
	param.mid = PlayerManager.getInstance():myself().mid;
	SocketManager.getInstance():sendPack(CLIENT_COMMAND_REQ_LOGOUT, param);
	self:hideWnd();
end

-- 显示控件内容以及设置事件
function RechargeTip.setViewContentAndEvent( self, isMatchKickOut, parametersTable )
    local tmp_str_1 = "您需要拥有"
    parametersTable = parametersTable or {};
	local tip = "购买超值金币，体验精彩游戏！";
    if self.m_type == self.enum.buy_pro then
        local str = tmp_str_1..(parametersTable.money or 0)..(self.m_moneytype == GameConstant.sc_money_type.diamond and "钻石" or "金币").."才能购买"..(parametersTable.prop_name or "该道具").."。"
        tip = GameString.convert2Platform(str);
    elseif self.m_type == self.enum.friend_match_wnd then
        local str = tmp_str_1..(parametersTable.money or 0)..(self.m_moneytype == GameConstant.sc_money_type.diamond and "钻石" or "金币").."才可以创建房间。"
        tip = GameString.convert2Platform(str);
    else
        if self.m_moneytype == GameConstant.sc_money_type.diamond then
            tip = "购买超值钻石，体验精彩游戏！";
            self.money_type_img:setFile("Hall/HallMall/diamond_default.png");
            self.money_type_img:setSize(168,144);
            self.money_type_img:setPos(25,-5);
        end

	    if parametersTable and parametersTable.roomlevel then
            --根据level获取数据
            local cfg_data = HallConfigDataManager.getInstance():returnDataByLevel(parametersTable.roomlevel);
            local name = nil;
            if cfg_data then
                name = cfg_data.name;
            end
		    if parametersTable.recommend then
			    --比赛场的时候，recommend代表多少钱
    --			local player = PlayerManager.getInstance():myself();
    --			local needMoney = tonumber(parametersTable.money) - tonumber(player.money);
    --			local str = "您至少还需要"..trunNumberIntoThreeOneFormWithInt(needMoney or 0).."金币才能进入"..(name or "比赛场").."。";
                local str = tmp_str_1.. trunNumberIntoThreeOneFormWithInt(tonumber(parametersTable.money) or 0) .."金币才能进入"..(name or "比赛场").."。";
			    tip = GameString.convert2Platform(str);
		    elseif not (GameConstant.curGameSceneRef == RoomScene_instance) then
			    local str = tmp_str_1.. trunNumberIntoThreeOneFormWithInt(tonumber(parametersTable.money) or 0) .."金币才能进入"..(name or "游戏场").."。";
			    tip = GameString.convert2Platform(str);
		    elseif GameConstant.curGameSceneRef == RoomScene_instance then
			    tip = "购买超值金币，体验精彩游戏！";
		    end
	    end
        if self.cardType then
            local proStr = self.cardType == ItemManager.MATCH_WEEK_CARD and "周赛卡" or "雀圣卡"
		    tip = ("您的道具"..proStr.."不足，购买金币赠送报名卡");

        end
        if parametersTable and self.m_moneytype == GameConstant.sc_money_type.diamond then
            local str = tmp_str_1.. trunNumberIntoThreeOneFormWithInt(tonumber(parametersTable.money) or 0) .."钻石才能进入创建房间。";
		    tip = GameString.convert2Platform(str);
        end
    end
    --如果是钻石，则设置钻石相关的图标
    if self.m_moneytype == GameConstant.sc_money_type.diamond then
        self.money_type_img:setFile("Hall/HallMall/diamond_default.png");
        self.money_type_img:setSize(168,144);
        self.money_type_img:setPos(25,-5);
    end
    --设置提示文字
	self.textTips:setText(tip);
	self:showOrHideMatchView( isMatchKickOut );

	--更多金币
	self.btnUpdate:setOnClick(self,self.onClickMore);
	self.btnConfirm:setOnClick(self, self.onClickComfirmBtn);

	self.btn_phone1:setOnClick( self, function( self )
		local phone = self.text_phone1:getText();
		self:hideWnd();
		callPhone( phone );
	end);

	self.btn_phone2:setOnClick( self, function( self )
		local phone = self.text_phone2:getText();
		self:hideWnd();
		callPhone( phone );
	end);

	--设置关闭事件
	self.btnClose:setOnClick(self, function ( self )
		umengStatics_lua(kUmengFastBuyCloseBtn);
		self:hideWnd();
	end);
end

-- 直接支付
function RechargeTip.payDirectly( self )
	self:onClickBuyBtn();
	self:hide();
end

function RechargeTip.onWindowHide( self )
	self.super.onWindowHide(self);
	--new_pop_wnd_mgr.get_instance():hide_and_show( new_pop_wnd_mgr.windows.RechargeTip );
end

-- 1秒定时器
RechargeTip.timer = function (self)
	if self.kickTimeAnim then
		return;
	end
	self.kickTimeAnim = self.btnQuit:addPropRotate(100,kAnimRepeat,1000,0,0,0,kCenterDrawing);
	self.kickTimeAnim:setDebugName("RechargeTip|self.kickTimeAnim");
	self.kickTimeAnim:setEvent(self, self.updateTime);
end

-- 刷新倒计时
RechargeTip.updateTime = function ( self )
	if 0 == self.time then
		self.textQuit:setText(self.str .. "( " .. self.time .. " )");
		if self.kickTimeAnim then
			delete(self.kickTimeAnim);
			self.kickTimeAnim = nil;
		end
		self:onClickGiveUpBtn();
	elseif 0 < self.time then
		self.time = self.time - 1;
		self.textQuit:setText(self.str .. "( " .. self.time .. " )");
	end
end

-- 比赛中认输按钮点击事件
RechargeTip.onClickGiveUpBtn = function ( self )

	if self.kickTimeAnim then
		delete(self.kickTimeAnim);
		self.kickTimeAnim = nil;
	end
	-- 通知SERVER有人认输
	local param = {};
	param.level = GameConstant.curRoomLevel;
	param.param = -1;
	param.cmdRequest = CLIENT_RENSHU_REQ;
	param.mid = PlayerManager.getInstance():myself().mid;
	param.matchId = GameConstant.matchResultStatus.matchId;
	SocketManager.getInstance():sendPack(SERVER_MATCHSERVER_CMD, param);
	self:hideWnd();
end

RechargeTip.onClickBuyBtn = function ( self )
	if self.kickTimeAnim then
		delete(self.kickTimeAnim);
		self.kickTimeAnim = nil;
	end

	if MatchRoomScene_instance and self.matchQuitFlag then
		if not GameConstant.payTime then
			GameConstant.payTime = 20;
		end
		local msg = "请在" .. GameConstant.payTime .. "秒内完成充值，否则将被淘汰出局";
		Banner.getInstance():showMsg(msg);
	end

	GameConstant.hasReallyPay = false; -- 请求支付前重置为false
	--支付上报数据
	local levelType,level,basechip = getRoomInformWhenInRoom();
	local payScene = {};
	payScene.scene_id = PlatformConfig.RechargeBuyForPay;
	payScene.levelType = levelType;
	payScene.level = level;
	payScene.basechip = basechip;
	payScene.bankrupt = 0;

    local moneytype = global_transform_money_type(self.m_moneytype, false);
	GlobalDataManager.getInstance():quickPay(self.nowAmount,payScene, moneytype);

	self:hideWnd();
end


--购买按钮事件响应
RechargeTip.onClickComfirmBtn = function( self )
	DebugLog("ok:"..(self.nowAmount or 0));
	if PlayerManager.getInstance():myself().money < GameConstant.bankruptMoney then
		GameConstant.brankInRoomFlg = true; -- 用于玩家在SDK中放弃支付时，重新打开破产界面
	end
	GameConstant.hasReallyPay = false; -- 请求支付前重置为false

	--支付上报数据
	local levelType,level,basechip = getRoomInformWhenInRoom();
	local payScene = {};
	payScene.scene_id = PlatformConfig.RechargeBuyForPay;
	payScene.levelType = levelType;
	payScene.level = level;
	payScene.basechip = basechip;
	payScene.bankrupt = 0;
	local moneytype = global_transform_money_type(self.m_moneytype, false);
	GlobalDataManager.getInstance():quickPay(self.nowAmount,payScene, moneytype);
	self:hideWnd();
end

RechargeTip.setBuyListItem = function (self , product)
	if not product then
		return;
	end

	self.nowAmount = product.pamount;
	local tip = (product.pname or "") .. " = " .. GameString.convert2Platform("￥") .. tonumber(product.pamount or 0);
	self.productName:setText(tip);
	self.productDesc:setText(product.pdesc or "");
end

RechargeTip.onClickMore = function(self)
	local showProduct;

    if #self.m_product_list < 1 then
        return;
    end
    self.m_current_product_index = self.m_current_product_index + 1;
    if self.m_current_product_index > #self.m_product_list then
        self.m_current_product_index = 1;
    end
    showProduct = self.m_product_list[self.m_current_product_index];

--    if self.cardType then
--        if #self.matchCardProductList <= 0 then
--            return;
--        end
--        self.m_current_product_index = self.m_current_product_index + 1;
--        if self.m_current_product_index > #self.matchCardProductList then
--            self.m_current_product_index = 1;
--        end
--        showProduct = self.matchCardProductList[self.m_current_product_index];
--	elseif self.level then
--		showProduct = ProductManager.getInstance():getLevelRecommendProductByNextAmount(self.nowAmount);
--	else
--		showProduct = ProductManager.getInstance():getVipRecommendProductByNextAmount(self.nowAmount);
--	end

	if not showProduct then
		return;
	end
	self:setBuyListItem(showProduct);
	self:makeAnimation();
end

-- 显示切换商品效果
function RechargeTip.makeAnimation(self)
	local control = publ_getItemFromTree(self.window,{"img_win_bg","img_win_inner_bg", "img_item_bg"});
end

RechargeTip.hide = function (self)
	-- self:removeFromSuper();
	self:setVisible(false);
end

RechargeTip.dtor = function (self)
	DebugLog("RechargeTip dtor");

	if self.kickTimeAnim then
		delete(self.kickTimeAnim);
		self.kickTimeAnim = nil;
	end
	self:removeAllChildren();
end

RechargeTip.onClickCertainBtn = function (self)
	umengStatics_lua(kUmengRoomFastBuyCloseBtn);
	self:hide();
end
