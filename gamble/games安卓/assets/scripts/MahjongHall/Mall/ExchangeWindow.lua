-- ExchangeWindow.lua
-- Author: YifanHe
-- Date: 2013-10-23
-- Last modification : 2013-10-31
-- Description: 商城界面，拥有商品、兑换界面、道具、VIP四个选项


require("ui/listView")
require("MahjongHall/Mall/MallListItem");
require("MahjongHall/Mall/ExchangeHistoryListItem");

require("MahjongHall/Mall/ExchangeListItem");

require("MahjongHall/Rank/exchange_rank_item");

require("MahjongHall/Mall/MallCouponsDetailsView");

require("MahjongHall/hall_2_interface_base")

ExchangeWindow = class(hall_2_interface_base);

State_Exchange 			= 2;
State_ExchangeHistory 	= 3;
State_ExchangeRank 	= 4;


ExchangeWindow.m_phpEvent = EventDispatcher.getInstance():getUserEvent(); -- php注册回调事件

ExchangeWindow.ctor = function (self, stateTag , delegate)
	ExchangeWindow.instance = self;
	self.state = stateTag or State_Exchange;
	self.delegate =delegate
--	g_GameMonitor:addTblToUnderMemLeakMonitor("Exchange",self)
    --设置基类的基础配置
    self:set_tag(GameConstant.view_tag.exchange);
    self:set_tab_title({"实物兑换", "兑换排行榜", "兑换记录"});
    self:set_tab_count(3);

    delegate.m_mainView:addChild(self)
    self:play_anim_enter();
end

ExchangeWindow.on_enter = function (self)

	self.isFirstGetChangeHistory = true;

	--预加载金币信息
	self.userInfo = PlayerManager.getInstance():myself();


	local mallCommon = require(ViewLuaPath.."mallCommon");
	self.mainContent = SceneLoader.load(mallCommon);
	self.m_bg:addChild(self.mainContent);

	self.mallLayout = publ_getItemFromTree(self.mainContent, {"contentView"});




    --因为和商城界面是公用的，所有要设置下view
    self.m_dimond_list = publ_getItemFromTree(self.mallLayout, {   "v_diamond"});
    if self.m_dimond_list then
        self.m_dimond_list.testname = "self.m_dimond_list";
        self.m_dimond_list:setVisible(false);
        self.m_dimond_list:setPos(0, -100);
    end

	--两个主要的ScrollView
	self.exchangeList 			= publ_getItemFromTree(self.mallLayout, {   "goldScrollView"});
	self.exchangeHistoryList    = publ_getItemFromTree(self.mallLayout, {   "propScrollView"});
    self.exchangeHistoryList:setVisible(false);

    self.exchangeList.testname = "self.exchangeList";
    self.exchangeList.exchangeHistoryList = "self.exchangeHistoryList";

	self.exchangeList:setDirection(kHorizontal)
	self.exchangeHistoryList:setDirection(kVertical)




	--兑换标签 实物
	self.exchangeTag     = self.m_btn_tab[1]
	self.exchangeImg     = self.m_btn_tab[1].img
	self.exchangeText    = self.m_btn_tab[1].t
	self.exchangeText:setText("实物兑换")
	self.exchangeImg:setFile("Commonx/tag_blue.png")


	--兑换记录标签
	self.exchangeHistoryTag   = self.m_btn_tab[3]
	self.exchangeHistoryImg   = self.m_btn_tab[3].img
	self.exchangeHistoryText  = self.m_btn_tab[3].t
	self.exchangeHistoryText:setText("兑换记录")
	self.exchangeHistoryImg:setFile("Commonx/tag_blue.png")

	self.exchangeTag:setType(Button.Gray_Type)
	self.exchangeHistoryTag:setType(Button.Gray_Type)

    --兑换排行榜
    self.m_btn_rank = self.m_btn_tab[2]
    self.m_btn_rank.img = self.m_btn_tab[2].img

    self.m_btn_rank.img:setFile("Commonx/tag_blue.png")
    self.m_btn_rank:setVisible(true);
    self.m_btn_rank:setType(Button.Gray_Type)


    --设置三个tab按钮的位置

    self.exchangeTag:setLevel(1);
    self.exchangeHistoryTag:setLevel(3);
    self.m_btn_rank:setLevel(2);

    self.m_bottom_img = publ_getItemFromTree(self.mallLayout, {   "bottom_pre_img"});

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


	self.couponsDetailsBtn = publ_getItemFromTree(self.boyaaBg, {"add_btn"});
	self.couponsDetailsBtn:setOnClick( self, function( self )
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

	self.tipText1 = publ_getItemFromTree(self.mallLayout,{  "Image1","tip_text1"})

	self.delegate.m_mainView:addChild(self);
	
    --排行榜界面控件
    self.m_v_rank = publ_getItemFromTree(self.mallLayout,{  "v_rank"});
    self.m_v_rank:setVisible(false);
    self.m_v_rank.testname = "self.m_v_rank";
    self.m_v_rank.top_view = publ_getItemFromTree(self.m_v_rank,{"top_view"});
    self.m_v_rank.bottom_view = publ_getItemFromTree(self.m_v_rank,{"bottom_view"});
    self.m_v_rank.listview = publ_getItemFromTree(self.m_v_rank,{"top_view", "listview"}); 
    self.m_v_rank.tip = publ_getItemFromTree(self.m_v_rank,{"t_tip"}); 
    self.m_v_rank:setVisible(false);
	---------------

    DebugLog('Profile clicked exchange stop:'..os.clock(),LTMap.Profile)
    --show

    self:hideExchangeTag();

    EventDispatcher.getInstance():register(GlobalDataManager.updateSceneEvent, self, self.updataUIByGlobalEvent);
	EventDispatcher.getInstance():register(ProductManager.getExchanegeCallbackEvent, self, self.updateExchangeList);
	EventDispatcher.getInstance():register(ProductManager.getExchanegeHistoryCallbackEvent, self, self.updateExchangeHistoryList);
	EventDispatcher.getInstance():register(self.m_phpEvent, self, self.onHttpRequestsListenster);
    EventDispatcher.getInstance():register(SocketManager.s_phpMsg, self, self.onPhpMsgResponse);


    self:set_tab_callback(self,self.tab_click);

    self:onClickTagWithTagType(self.state);
end

ExchangeWindow.on_exit = function (self)

	umengStatics_lua(Umeng_MallBack);
	EventDispatcher.getInstance():unregister(self.m_phpEvent, self, self.onHttpRequestsListenster);
	Loading.hideLoadingAnim();

	GlobalDataManager.getInstance():updateLocalCoin();

end

ExchangeWindow.tab_click = function (self, index)
    --1:金币购买，2:钻石购买，3:道具购买
    
    self:hideAllLoding();

    if index == 1 then
		self:showExchangeLoding(true);
		umengStatics_lua(Umeng_MallExchangeTag);
		ProductManager.getInstance():getExchangeList();
		self:onClickTagWithTagType(State_Exchange);
    elseif index == 2 then
        self:onClickTagWithTagType(State_ExchangeRank);
        if self.m_rank_data then
            self:refresh_rank_view();
        else
            self:send_php_get_rank();
        end
    elseif index == 3 then
        umengStatics_lua(Umeng_MallExchangeHistoryTag);
		if self.isFirstGetChangeHistory then --如果第一次点击发送一次请求，其他时间不再发送请求。
			self:showExchangeHistoryLoading(true);
			ProductManager.getInstance():getExchangeHistoryList();
			self.isFirstGetChangeHistory = false;
		end
		self:onClickTagWithTagType(State_ExchangeHistory);
    end
end

ExchangeWindow.hideExchangeTag = function(self)
    local  bShow = true; 
    if GameConstant.platformType == PlatformConfig.platformDingkai then
        bShow = false; 
        publ_getItemFromTree(self.mallLayout, {"bottomView","boyaaBg","boyaaImg"}):setFile("payPopu/qifan_coin.png");

        --博雅币文字(改成了起凡币)
	    self.boyaaText = publ_getItemFromTree(self.mallLayout, {"bottomView", "boyaaBg", "boyaaText"});
	    self.boyaaText:setText(trunNumberIntoThreeOneFormWithInt(tostring(self.userInfo.dingkaiCoin)));

        --设置话费卷显示
        self.rollText = publ_getItemFromTree(self.mallLayout, {"bottomView", "rollBg", "rollText"});
	    self.rollText:setText(trunNumberIntoThreeOneFormWithInt(tostring(self.userInfo.coupons)));
    else
        bShow = true;       
    end
end

ExchangeWindow.dtor = function (self)
    self.super.dtor(self);

	ExchangeWindow.instance = nil;

	EventDispatcher.getInstance():unregister(self.m_phpEvent, self, self.onHttpRequestsListenster);
	EventDispatcher.getInstance():unregister(GlobalDataManager.updateSceneEvent, self, self.updataUIByGlobalEvent);
	EventDispatcher.getInstance():unregister(ProductManager.getExchanegeCallbackEvent, self, self.updateExchangeList);
	EventDispatcher.getInstance():unregister(ProductManager.getExchanegeHistoryCallbackEvent, self, self.updateExchangeHistoryList);
    EventDispatcher.getInstance():unregister(SocketManager.s_phpMsg, self, self.onPhpMsgResponse);
	self:removeAllChildren();
end

ExchangeWindow.updataUIByGlobalEvent = function ( self, param )
	if not param or GlobalDataManager.UI_UPDATA_MONEY == param.type then -- 更新金币（not param 时也更新，为了兼容老代码）
		self:updateCoin();
	end
end

ExchangeWindow.updateCoin = function( self )
	local player = PlayerManager.getInstance():myself();
	if player.mid < 0 then
		return; -- 未登录
	end
	money = trunNumberIntoThreeOneFormWithInt(player.money) or 0;
	self.coinsText:setText(money);
    self.m_t_diamond:setText(trunNumberIntoThreeOneFormWithInt(player.boyaacoin) or 0);

	if GameConstant.platformType == PlatformConfig.platformDingkai then
	 	--设置话费卷显示       
        self.rollText = publ_getItemFromTree(self.mallLayout, {"bottomView", "rollBg", "rollText"});      
	    self.rollText:setText(trunNumberIntoThreeOneFormWithInt(tostring(player.coupons)));
	    --起凡币
	    
	    local dingkaiCoin = player.dingkaiCoin;
	    if kNullStringStr == dingkaiCoin or not player.dingkaiCoin then
	    	dingkaiCoin = 0;
	    end
	    self.boyaaText:setText(tostring(dingkaiCoin or 0));
	 else
	 	self.boyaaText:setText(tostring(player.coupons));
	 end

 	--如果当前兑换成功，进行请求一次兑换记录
	--ProductManager.getInstance():getExchangeHistoryList();
	if GameConstant.platformType == PlatformConfig.platformOPPO then -- oppo要更新元宝数目
		-- self.nbaoText:setText("可币:"..(OppoPlatform.curKeBi or 0) / 100);
	end
end

ExchangeWindow.updateExchangeList = function( self )
	if self.state == State_Exchange then
		self:creatExchangeListView(1);
	end
	self:showExchangeLoding(false);
end

ExchangeWindow.updateExchangeHistoryList = function( self )
	if self.state == State_ExchangeHistory then
		self:createExchangeHistoryListView();
	end
	self:showExchangeHistoryLoading(false);
end



--更新界面金币、博雅币、积分
ExchangeWindow.updateUserInfo = function(self)
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

ExchangeWindow.counter = 0;


--创建兑换商品数据列表
ExchangeWindow.creatExchangeListView = function (self, changeType)
	log( "ExchangeWindow.creatExchangeListView" );
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
	----------------------------------------------------
	local parent = self.exchangeList

	local scrollerW , scrollerH = parent:getSize();
	local itemW, itemH = 258, 354;
	local sy = (scrollerH - itemH)/2
	local curIndex = 1
	parent:removeAllChildren();  --清理数据
	if self.exchangeInfoList and #self.exchangeInfoList > 0 then
		 --实物兑换
		for i = 1, #self.exchangeInfoList do
			if self.exchangeInfoList[i].moneytype == 4 then 
				--local item = new(ExchangeListItem, self.exchangeInfoList[i], self);
				local item = new(ExchangeListItem, self.exchangeInfoList[i], self);
				item:setPos( (curIndex - 1) * (itemW + 0), sy);
				item:setSize(itemW, itemH);			
				parent:addChild(item);
				curIndex = curIndex + 1
			end 
		end

	end 

	if curIndex == 1 then 
		parent:removeAllChildren();
		local tip = UICreator.createText("暂无可以兑换的物品。", 0, 0, 0, 0, kAlignCenter, 20, 255, 255, 255);
		tip:setAlign(kAlignCenter);
		parent:addChild(tip);
	end 

	parent:setSize(parent:getSize());  --修复引擎bug
	parent:setVisible(true)
end


--兑换的等待转圈
ExchangeWindow.showExchangeLoding = function ( self, visible )
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

--兑换记录的等待转圈
ExchangeWindow.showExchangeHistoryLoading = function (self, visible)
	
	if visible then
		if not self.exchangeHistoryLoading then
			self.exchangeHistoryLoading = new(SCSprite, SpriteConfig.TYPE_LOADING_ANIM);
			self.exchangeHistoryLoading:setPlayMode(kAnimRepeat);
			self.exchangeHistoryLoading:setSize(100,100);
			self.exchangeHistoryLoading:setAlign(kAlignCenter);
			self.exchangeHistoryLoading:play();
			self.mallLayout:addChild(self.exchangeHistoryLoading);
		end
		self.exchangeHistoryLoading:setVisible(true);
	else
		if self.exchangeHistoryLoading then
			self.exchangeHistoryLoading:setVisible(false);  --获取到数据时隐藏loading
		end
	end

end

ExchangeWindow.hideAllLoding = function ( self )
	-- body
	--兑换历史
	if self.exchangeHistoryLoading then
		self.exchangeHistoryLoading:setVisible(false);  --获取到数据时隐藏loading
	end

	--兑换
	if self.exchangeLoading then
		self.exchangeLoading:setVisible(false);  --获取到数据时隐藏loading
	end
end

--创建兑换商品记录数据列表
ExchangeWindow.createExchangeHistoryListView = function (self)
	--是否有兑换数据

	local exchangeHitoryInfoList = ProductManager.getInstance():getExchangeHistoryInfoList();

	local w, h = self.exchangeHistoryList:getSize();

	if #exchangeHitoryInfoList == 0 then
		self.exchangeHistoryList:removeAllChildren();
		local tip = UICreator.createText("暂无兑换记录", 0, 0, 0, 0, kAlignCenter, 26, 255, 255, 255);
		tip:setAlign(kAlignCenter);
		self.exchangeHistoryList:addChild(tip);
	else
		self.exchangeHistoryList:removeAllChildren();
		local w, h = self.exchangeHistoryList:getSize();
		for i = 1, #exchangeHitoryInfoList do
			local item = new(ExchangeHistoryListItem, w, 120, exchangeHitoryInfoList[i], self);
			item:setPos(0,(i - 1) * 120);
			self.exchangeHistoryList:addChild(item);
		end
	end
	self.exchangeHistoryList:setSize(self.exchangeHistoryList:getSize());  --修复引擎bug
	self.exchangeHistoryList:setVisible(true);
end

------------- 按钮响应事件 ---------------
ExchangeWindow.onClickTagWithTagType = function ( self , tagType )
   
	self.exchangeList:setVisible(false);
	self.exchangeHistoryList:setVisible(false);
    self.m_v_rank:setVisible(false);

	if State_Exchange == tagType then

		self.exchangeImg:setVisible(true);
		self.exchangeHistoryImg:setVisible(false);
        self.m_btn_rank.img:setVisible(false);
		self.state = State_Exchange;
		self:creatExchangeListView(1);
		self.tipText1:setVisible(true)

	elseif State_ExchangeHistory == tagType then
        if self.exchangeList then
            self.exchangeList:removeAllChildren();
        end
        self.m_btn_rank.img:setVisible(false);
		self.exchangeImg:setVisible(false);
		self.exchangeHistoryImg:setVisible(true);
		self.state = State_ExchangeHistory;
		self:createExchangeHistoryListView();
		self.tipText1:setVisible(false)
    elseif State_ExchangeRank == tagType then
        if self.exchangeHistoryList then
            self.exchangeHistoryList:removeAllChildren();
        end
        if self.exchangeList then
            self.exchangeList:removeAllChildren();
        end
        self.state = State_ExchangeRank;
        self.tipText1:setVisible(false);
        self.m_btn_rank.img:setVisible(true);
        self.exchangeImg:setVisible(false);
        self.exchangeHistoryImg:setVisible(false);
	end
    --设置排行盘界面的默认显示
    self:show_exchange_rank_default(State_ExchangeRank == tagType and true or false);
end

--切换兑换排行榜界面设置默认显示
ExchangeWindow.show_exchange_rank_default = function (self, b_visible)
    b_visible =  b_visible == true and true or false;

   -- self.m_v_rank:setVisible(b_visible);
    self.m_bottom_img:setVisible(not b_visible);
end

--刷新兑换排行榜界面
ExchangeWindow.refresh_rank_view = function (self)
    DebugLog("[ExchangeWindow]:refresh_rank_view");
    if not self.state or State_ExchangeRank ~= self.state  then
        return;
    end
    if not self.m_rank_data then
        self.m_v_rank.tip:setVisible(true);
        DebugLog("self.m_rank_data is nil");
        return;
    end
    self.m_v_rank:setVisible(true);
    --设置tip显示
    self.m_v_rank.tip:setVisible(false);

    self.m_v_rank.listview:setAdapter(nil);
    if self.m_rank_data.list and #self.m_rank_data.list > 0 then
        local adapter = new(CacheAdapter, exchange_rank_item, self.m_rank_data.list);
		self.m_v_rank.listview:setAdapter(adapter);
    end
    self.m_v_rank.bottom_view:removeAllChildren();
    if self.m_rank_data.me then
        self.m_v_rank.my_item = new(exchange_rank_item, self.m_rank_data.me)--SceneLoader.load(rankListItem2, self.m_rank_data.me );
        self.m_v_rank.my_item:setAlign(kAlignCenter);
        self.m_v_rank.my_item:setPos(0, 0);
        self.m_v_rank.bottom_view:addChild(self.m_v_rank.my_item);
    end

end


--发送php请求:兑换排行榜
ExchangeWindow.send_php_get_rank = function (self)
    Loading.showLoadingAnim("加载中...");
    SocketManager.getInstance():sendPack(PHP_CMD_REQUEST_HFQ_RANK, {});
end

--php请求回调:兑换排行榜
ExchangeWindow.get_rank_callback = function (self, isSuccess, data, jsonData)
	DebugLog("[ExchangeWindow]:get_rank_callback")

	if not isSuccess or not data or not data.data then
        DebugLog("data is nil");
		return;
	end
    self.m_rank_data = nil;
    if data.status == 1 then
    --添加vip level
        self.m_rank_data = {};
        self.m_rank_data.me = {};
        self.m_rank_data.list = {};
        if data.data.mine then
            local d = {};
            d.viplevel = tonumber(data.data.mine.viplevel) or 0;
            d.rank = tonumber(data.data.mine.rank) or 0;
            d.is_me = true;
            d.nick = data.data.mine.mnick or "";
            d.sex = tonumber(data.data.mine.sex) or 0;
            d.head_url = data.data.mine.icon or "";
            d.mid = tonumber(data.data.mine.mid) or 0;
            d.exchange_num = tonumber(data.data.mine.num) or 0;
            self.m_rank_data.me = d;
        end
        local list = data.data.list or {};
        for i =1, #list do
            local d = {};
            d.viplevel = tonumber(list[i].viplevel) or 0;
            d.rank = 1;
            d.nick = list[i].mnick or "";
            d.sex = tonumber(list[i].sex) or 0;
            d.head_url = list[i].icon or "";
            d.mid = tonumber(list[i].mid) or 0;
            d.exchange_num = tonumber(list[i].num) or 0;
            table.insert(self.m_rank_data.list, d);
        end
        if #self.m_rank_data.list > 0 then
            --排序
            function t_sort(s1 , s2)
	            return s1.exchange_num > s2.exchange_num
            end
            table.sort(self.m_rank_data.list, t_sort);

            for i = 1, #self.m_rank_data.list do
                self.m_rank_data.list[i].rank = i;
            end
        end


        Loading.hideLoadingAnim();
        self:refresh_rank_view();
    end 
end


ExchangeWindow.setHideCallbackAction = function ( self,obj,func )
	self.hideOverHandler = obj
	self.hideOverFunc    = func 
end

ExchangeWindow.onHttpRequestsListenster = function ( self, command, ... )
	if self.httpRequestMap[command] then
		DebugLog("ExchangeWindow deal http cmd "..command);
     	self.httpRequestMap[command](self,...);
	end 
end

ExchangeWindow.onPhpMsgResponse = function ( self, param, cmd, isSuccess,... )
	if self.httpRequestMap[cmd] then 
		self.httpRequestMap[cmd](self,isSuccess,param,...)
	end
end

ExchangeWindow.httpRequestMap = {
    [PHP_CMD_REQUEST_HFQ_RANK] = ExchangeWindow.get_rank_callback;
}


