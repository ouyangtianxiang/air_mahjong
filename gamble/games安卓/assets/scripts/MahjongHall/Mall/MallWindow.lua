-- MallWindow.lua
-- Author: YifanHe
-- Date: 2013-10-23
-- Last modification : 2013-10-31
-- Description: 商城界面，拥有商品、兑换界面、道具、VIP四个选项


require("ui/listView")
require("MahjongHall/Mall/MallListItem");
require("MahjongHall/Mall/PropListItem");


require("MahjongHall/Mall/MallCouponsDetailsView"); 

require("MahjongHall/hall_2_interface_base")

MallWindow = class(hall_2_interface_base);

State_Coins				= 2;
State_ExchangeProp      = 3;
State_Diamond      = 4;


MallWindow.ctor = function (self, stateTag , delegate )
	DebugLog("MallWindow.ctor " .. tostring(stateTag))
	MallWindow.instance = self;
	self.state = stateTag or State_Coins;
	DebugLog("MallWindow.ctor self.state = " .. tostring(self.state))
--	g_GameMonitor:addTblToUnderMemLeakMonitor("Mall",self)
	self.delegate = delegate

    --设置基类的基础配置
    self:set_tag(GameConstant.view_tag.mall);
    self:set_tab_title({"金币购买", "钻石购买", "道具购买"});
    self:set_tab_count(3);

    delegate.m_mainView:addChild(self)
    self:play_anim_enter();

end

MallWindow.on_enter = function (self)

	self.isFirstGetChangeHistory = true;

	--预加载金币信息
	self.userInfo = PlayerManager.getInstance():myself();


	local mallCommon = require(ViewLuaPath.."mallCommon");
	self.mainContent = SceneLoader.load(mallCommon);
	self.m_bg:addChild(self.mainContent);

	self.mallLayout = publ_getItemFromTree(self.mainContent, {"contentView"});



	--两个主要的ScrollView
	self.coinsList 			= publ_getItemFromTree(self.mallLayout, {  "goldScrollView"});
	self.exchangePropList   = publ_getItemFromTree(self.mallLayout, {  "propScrollView"});
    self.m_v_diamond = publ_getItemFromTree(self.mallLayout, {  "v_diamond"});
    self.m_v_diamond:setDirection(kHorizontal);
	self.coinsList:setDirection(kHorizontal)
	self.exchangePropList:setDirection(kHorizontal)
	--金币标签
	self.coinsTag     = self.m_btn_tab[1]
	self.coinsImg     = self.m_btn_tab[1].img
	self.coinsTextTag = self.m_btn_tab[1],t


	--购买道具
	self.exchangePropTag   = self.m_btn_tab[3]
	self.exchangePropImg   = self.m_btn_tab[3].img
	self.exchangePropText  = self.m_btn_tab[3].t

    self.btn_buy_diamond   = self.m_btn_tab[2]
    self.btn_buy_diamond.t   = self.m_btn_tab[2].t
    self.btn_buy_diamond.img   = self.m_btn_tab[2].img

    --设置三个按钮
    self.coinsTag:setLevel(1);
    self.exchangePropTag:setLevel(3);
    self.btn_buy_diamond:setLevel(2);
	self.coinsTag:setType(Button.Gray_Type)
	self.exchangePropTag:setType(Button.Gray_Type)
    self.btn_buy_diamond:setType(Button.Gray_Type)
    self.btn_buy_diamond.t:setText("钻石购买");
	--金币文字
	self.coinsBg   = publ_getItemFromTree(self.mallLayout, {   "bottom_pre_img","gold_bg_img"});
	self.coinsText = publ_getItemFromTree(self.coinsBg   , {"gold_num_text"});
	self.coinsText:setText(trunNumberIntoThreeOneFormWithInt(self.userInfo.money or 0));

    --钻石
    self.m_t_diamond = publ_getItemFromTree(self.mallLayout, {   "bottom_pre_img","diamond_bg", "t"});
    self.m_t_diamond:setText(trunNumberIntoThreeOneFormWithInt(self.userInfo.boyaacoin or 0));
	--博雅币文字(改成了话费券)
	self.boyaaBg   = publ_getItemFromTree(self.mallLayout, {   "bottom_pre_img", "telephone_fare_bg_img"});
	self.boyaaText = publ_getItemFromTree(self.boyaaBg   , {"telephone_fare_num_text"});
	self.boyaaText:setText(trunNumberIntoThreeOneFormWithInt(tostring(self.userInfo.coupons)));

	--博雅币文字(改成了话费券)
	self.boyaaBg   = publ_getItemFromTree(self.mallLayout, {   "bottom_pre_img", "telephone_fare_bg_img"});
	self.boyaaText = publ_getItemFromTree(self.boyaaBg   , {"telephone_fare_num_text"});

	self.boyaa_share_text = publ_getItemFromTree(self.mallLayout,{  "bottom_pre_img","tip_text"});

	--oppo的图片和资源
	self.oppo_bg_img = publ_getItemFromTree(self.mallLayout,{  "bottom_pre_img","oppo_bg_img"});
	self.oppo_bg_fare_img = publ_getItemFromTree(self.mallLayout,{  "bottom_pre_img","oppo_bg_fare_img"});
	self.oppo_text = publ_getItemFromTree(self.mallLayout,{  "bottom_pre_img","oppo_text1"});
	self.oppo_kebi = publ_getItemFromTree(self.mallLayout,{  "bottom_pre_img","oppo_bg_img","oppo_text"});



	self.couponsDetailsBtn = publ_getItemFromTree(self.boyaaBg, {"add_btn"});
	self.couponsDetailsBtn:setOnClick( self, function( self )
		umengStatics_lua(Umeng_MallAdd);
		if self.couponsDetailsView then
			self.couponsDetailsView:showWnd();
		else
			self.couponsDetailsView = new( MallCouponsDetailsView, self );
            if self.delegate then
                self.delegate:addChild(self.couponsDetailsView);
                self.couponsDetailsView:showWnd();
                self.couponsDetailsView:setOnWindowHideListener( self, function( self )
				    self.couponsDetailsView = nil;
			    end);
            end
			
		end
	end);

	DebugLog("MallWindow.ctor GameConstant.checkType==" .. GameConstant.checkType);
	if GameConstant.checkType == 0 then  --如果当前不是审核，就需要显示兑换
		self.exchangePropTag:setVisible(true)
		self.exchangePropText:setVisible(true)

		self.boyaaBg:setVisible(true) --兑换的话费券
	else
		--如果当前是审核状态，兑换，兑换，兑换记录，话费卷都不显示
		self.exchangePropTag:setVisible(false)
		self.exchangePropText:setVisible(false)
		self.boyaaBg:setVisible(false) --兑换的话费券
	end

	if GameConstant.iosDeviceType>0 and GameConstant.iosPingBiFee then
		DebugLog("self.boyaaBg:setVisible(false);");
		self.boyaaBg:setVisible(false);
	end

	self.delegate.m_mainView:addChild(self)

	if PlatformConfig.platformWDJ == GameConstant.platformType or
 	   PlatformConfig.platformWDJNet == GameConstant.platformType then
		self.coinsImg:setFile("Login/wdj/Hall/Commonx/tag_red.png");
		self.exchangePropImg:setFile("Login/wdj/Hall/Commonx/tag_red.png");
    end


    DebugLog('Profile clicked mall stop:'..os.clock(),LTMap.Profile)


    self:hideExchangeTag();


    EventDispatcher.getInstance():register(GlobalDataManager.updateSceneEvent, self, self.updataUIByGlobalEvent);
	EventDispatcher.getInstance():register(ProductManager.updateSceneEvent, self, self.creatCoinsListView);
	EventDispatcher.getInstance():register(ProductManager.getExchanegeCallbackEvent, self, self.updateExchangeList);




    self:set_tab_callback(self,self.tab_click);

    self:onClickTagWithTagType(self.state)
end

MallWindow.on_exit = function (self)

 	umengStatics_lua(Umeng_MallBack);
	Loading.hideLoadingAnim();

	GlobalDataManager.getInstance():updateLocalCoin();

end

MallWindow.tab_click = function (self, index)
    --1:金币购买，2:钻石购买，3:道具购买
    
    self:hideAllLoding();

    if index == 1 then
		self:showCoinsLoding(true);
		umengStatics_lua(Umeng_MallFastChargeTag);
		self:onClickTagWithTagType(State_Coins);
    elseif index == 2 then
		self:showCoinsLoding(true);
		ProductManager.getInstance():getExchangeList();
		self:onClickTagWithTagType(State_Diamond);
    elseif index == 3 then
		self:showExchangeLoding(true);
		umengStatics_lua(Umeng_MallExchangeTag);
		ProductManager.getInstance():getExchangeList();
		self:onClickTagWithTagType(State_ExchangeProp);
    end
end 


MallWindow.hideExchangeTag = function(self)
    local  bShow = true;
    if GameConstant.platformType == PlatformConfig.platformDingkai then
        bShow = false;
        publ_getItemFromTree(self.coinsBg, {"Image3"}):setFile("payPopu/qifan_coin.png");
        --金币 (改成了起凡币)
	    self.coinsText:setText(trunNumberIntoThreeOneFormWithInt(tostring(self.userInfo.dingkaiCoin)));
        --设置话费卷显示
	    self.boyaaText:setText(trunNumberIntoThreeOneFormWithInt(tostring(self.userInfo.coupons)));
    else
        bShow = true;
    end
end

MallWindow.dtor = function (self)
    self.super.dtor(self);
    MallWindow.instance = nil;

    EventDispatcher.getInstance():unregister(GlobalDataManager.updateSceneEvent, self, self.updataUIByGlobalEvent);
    EventDispatcher.getInstance():unregister(ProductManager.updateSceneEvent, self, self.creatCoinsListView);
    EventDispatcher.getInstance():unregister(ProductManager.getExchanegeCallbackEvent, self, self.updateExchangeList);

    self:removeAllChildren();
end

MallWindow.updataUIByGlobalEvent = function ( self, param )
    DebugLog("MallWindow.updataUIByGlobalEvent");
	if not param or GlobalDataManager.UI_UPDATA_MONEY == param.type then -- 更新金币（not param 时也更新，为了兼容老代码）
		self:updateCoin();
	end
end

MallWindow.updateCoin = function( self )
	local player = PlayerManager.getInstance():myself();
	if player.mid < 0 then
		return; -- 未登录
	end
	money = trunNumberIntoThreeOneFormWithInt(player.money) or 0;
	self.coinsText:setText(money);
    self.m_t_diamond:setText(trunNumberIntoThreeOneFormWithInt(player.boyaacoin) or 0);

	if GameConstant.platformType == PlatformConfig.platformDingkai then
	 	--设置话费卷显示
	    self.boyaaText:setText(trunNumberIntoThreeOneFormWithInt(tostring(player.coupons)));
	    --起凡币

	    local dingkaiCoin = player.dingkaiCoin;
	    if kNullStringStr == dingkaiCoin or not player.dingkaiCoin then
	    	dingkaiCoin = 0;
	    end
	    self.coinsText:setText(tostring(dingkaiCoin or 0));
	 else
	 	self.boyaaText:setText(tostring(player.coupons));
	 end

end

MallWindow.updateExchangeList = function( self )
	if self.state == State_ExchangeProp then
		self:creatExchangeListView(2)
	end

	self:showExchangeLoding(false);
end

--更新界面金币、博雅币、积分
MallWindow.updateUserInfo = function(self)
    DebugLog("MallWindow.updateUserInfo");
	self.coinsText:setText(trunNumberIntoThreeOneFormWithInt(self.userInfo.money));
    self.m_t_diamond:setText(trunNumberIntoThreeOneFormWithInt(self.userInfo.boyaacoin));
	if GameConstant.platformType == PlatformConfig.platformDingkai then
	 	--设置话费卷显示
        self.rollText = publ_getItemFromTree(self.mallLayout, {"bottomView", "rollBg", "rollText"});
	    self.rollText:setText(trunNumberIntoThreeOneFormWithInt(tostring(self.userInfo.coupons)));
	    --起凡币

	    local dingkaiCoin = self.userInfo.dingkaiCoin;
	    if kNullStringStr == dingkaiCoin or not self.userInfo.dingkaiCoin then
	    	dingkaiCoin = 0;
	    end
	    self.boyaaText:setText(tostring(dingkaiCoin or 0));
	 else
	 	self.boyaaText:setText(tostring(self.userInfo.coupons));
	 end
	 --如果当前兑换成功，进行请求一次兑换记录
	 --ProductManager.getInstance():getExchangeHistoryList();
end

MallWindow.counter = 0;

--创建金币商品数据列表
MallWindow.creatCoinsListView = function (self, is_v_diamond)
	self.productList = ProductManager.getInstance():getProductList();
	if self.productList and #self.productList > 1 then
		table.sort(self.productList, ProductManager.sortProductInfo);
	end

	--没有数据时显示loading
	if not self.productList then
		log( MallWindow.counter );
		if self.coinsLoading then
			self.coinsLoading:setVisible(false);
		end
		if self.state ~= State_Coins then
			self.coinsLoading:setVisible(false);
		end
		return;
	else
		if self.coinsLoading then
			self.coinsLoading:setVisible(false);
		end
	end
    local state = is_v_diamond and State_Diamond or State_Coins;
    local listview = is_v_diamond and self.m_v_diamond or self.coinsList;
    local v_type = is_v_diamond and 1 or 0;
	listview:removeAllChildren();  --清理数据
	local scrollerW , scrollerH = listview:getSize();
	local itemW, itemH = 258, 354;
	local sy = (scrollerH - itemH)/2
	local productShowLists = {};
	for i = 1, #self.productList do
		if tonumber(self.productList[i].ptype) == v_type then
			table.insert(productShowLists,self.productList[i]);
		end
	end

	for i = 1, #productShowLists do
		local item = nil;
		-- if tonumber(self.productList[i].pcard) == 0 then
			item = new(MallListItem,productShowLists[i]);
		-- end
		if item then
			item:setPos( (i - 1) * (itemW + 0), sy);
			item:setSize(itemW, itemH);
			listview:addChild(item);
		end
	end
	listview:setSize(listview:getSize());  --修复引擎bug

	if self.state ~= state then
		listview:setVisible(false);
	else
		listview:setVisible(true);
	end
end

--金币商品的等待转圈
MallWindow.showCoinsLoding = function ( self, visible)
	-- body
	if visible then
		if not self.coinsLoading then
			self.coinsLoading = new(SCSprite, SpriteConfig.TYPE_LOADING_ANIM);
			self.coinsLoading:setPlayMode(kAnimRepeat);
			self.coinsLoading:setSize(100,100);
			self.coinsLoading:setAlign(kAlignCenter);
			self.coinsLoading:play();
			self.mallLayout:addChild(self.coinsLoading);
		end
		self.coinsLoading:setVisible(true);
	else
		if self.coinsLoading then
			self.coinsLoading:setVisible(false);
		end
	end
end

--创建钻石购买列表
MallWindow.create_list_buy_diamond = function (self)--, changeType)
    DebugLog("[MallWindow]:create_list_buy_diamond");
    local is_v_diamond = true;
    self:creatCoinsListView(is_v_diamond);
end

--创建兑换商品数据列表
MallWindow.creatExchangeListView = function (self, changeType)
	log( "MallWindow.creatExchangeListView" );
	--是否有兑换数据
	if not ProductManager.getInstance().m_exchangeFlag then
		if self.exchangeLoading then
			self.exchangeLoading:setVisible(false);
		else
			self.exchangeLoading = new(SCSprite, SpriteConfig.TYPE_LOADING_ANIM);
			self.exchangeLoading:setPlayMode(kAnimRepeat);
			self.exchangeLoading:setSize(100,100);
			self.exchangeLoading:setAlign(kAlignCenter);
			self.exchangeLoading:play();
			self.mallLayout:addChild(self.exchangeLoading);
		end
		ProductManager.getInstance():getExchangeList(); --当前没有请求过 发送一次请求
		return;
	end

	if self.exchangeLoading then
		self.exchangeLoading:setVisible(false);  --获取到数据时隐藏loading
	end

	----注意:这里如果不用深拷贝  会由于下面v.mallRef = self导致内存泄露
	self.exchangeInfoList = publ_deepcopy(ProductManager.getInstance():getExchangeInfoList())
	for k, v in pairs(self.exchangeInfoList) do
		v.mallRef = self;
	end

	local parent = self.exchangePropList

	local scrollerW , scrollerH = parent:getSize();
	local itemW, itemH = 258, 354;
	local sy = (scrollerH - 354)/2
	local curIndex = 1
	parent:removeAllChildren();  --清理数据
	DebugLog("____________________________________________________")
	if self.exchangeInfoList and #self.exchangeInfoList > 0 then

		 --道具兑换
		for i = 1, #self.exchangeInfoList do
			if self.exchangeInfoList[i].moneytype ~= 4 then
				local item = new(PropListItem, self.exchangeInfoList[i], self);
				item:setPos( (curIndex - 1) * (itemW + 15), sy);
				item:setSize(itemW, itemH);
				parent:addChild(item);
				curIndex = curIndex + 1
			end
		end

	end

	if curIndex == 1 then
		parent:removeAllChildren();
		local tip = UICreator.createText("暂无可以购买的道具。", 0, 0, 0, 0, kAlignCenter, 20, 255, 255, 255);
		tip:setAlign(kAlignCenter);
		parent:addChild(tip);
	end

	parent:setSize(parent:getSize());  --修复引擎bug
	parent:setVisible(true)
end


--兑换的等待转圈
MallWindow.showExchangeLoding = function ( self, visible )
	-- body
	if visible then
		if not self.exchangeLoading then
			self.exchangeLoading = new(SCSprite, SpriteConfig.TYPE_LOADING_ANIM);
			self.exchangeLoading:setPlayMode(kAnimRepeat);
			self.exchangeLoading:setSize(100,100);
			self.exchangeLoading:setAlign(kAlignCenter);
			self.exchangeLoading:play();
			self.mallLayout:addChild(self.exchangeLoading);
		end
		self.exchangeLoading:setVisible(true);
	else
		if self.exchangeLoading then
			self.exchangeLoading:setVisible(false);
		end
	end
end



MallWindow.hideAllLoding = function ( self )
	--金币列表
	if self.coinsLoading then
		self.coinsLoading:setVisible(false);  --获取到数据时隐藏loading
	end

	--兑换
	if self.exchangeLoading then
		self.exchangeLoading:setVisible(false);  --获取到数据时隐藏loading
	end
end


------------- 按钮响应事件 ---------------
MallWindow.onClickTagWithTagType = function ( self , tagType )
	DebugLog("MallWindow.onClickTagWithTagType " .. tostring(tagType))
	self.coinsList:setVisible(false);
	self.exchangePropList:setVisible(false);
    self.m_v_diamond:setVisible(false);

    local t = {[State_Coins] = 1, [State_Diamond] = 2, [State_ExchangeProp] = 3};
    local index = t[tagType];
    if index then
        self:set_light_tab(index);
    end

	if State_Coins == tagType then
		umengStatics_lua(Umeng_MallFastChargeTag);

		self.state = State_Coins;
		self:creatCoinsListView();
	elseif State_ExchangeProp == tagType then
		umengStatics_lua(Umeng_MallExchangeTag);

		self.state = State_ExchangeProp;
		self:creatExchangeListView(2);
    elseif State_Diamond == tagType then

        self.state = State_Diamond;
        self:create_list_buy_diamond();
	end
end


