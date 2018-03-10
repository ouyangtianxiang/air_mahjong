require("MahjongCommon/BankraptcyClock");
require("Animation/FrameAnim");
--local frameLight_map = require("qnPlist/frameLight")

local bankruptcyWnd = require(ViewLuaPath.."bankruptcyWnd");

BankruptcyDlg = class(SCWindow);

BankruptcyDlg.ctor = function ( self , level , obj , closeListener, time, isUpperLimit )
    
	-- body
	self.cover:setEventTouch(self , function (self) end);
--	self:setCoverTransparent()
	--request 
	self.window = SceneLoader.load(bankruptcyWnd);
	self:addChild(self.window);

	self.m_time = time; -- 破产需要显示的时间

	self.bg = publ_getItemFromTree(self.window,{"img_win_bg"});
	self:setWindowNode( self.bg );
	--设置关闭事件
	publ_getItemFromTree(self.window,{"img_win_bg","btn_close"}):setOnClick(self, function ( self )
		GlobalDataManager.getInstance():showBankruptThings();
		self:hideWnd()
	end);

	if PlatformConfig.platformWDJ == GameConstant.platformType or PlatformConfig.platformWDJNet == GameConstant.platformType then 
		publ_getItemFromTree(self.window,{"img_win_bg","btn_close"}):setFile("Login/wdj/Hall/Commonx/close_btn.png");
		publ_getItemFromTree(self.window,{"img_win_bg","btn_close"}).disableFile = "Login/wdj/Hall/Commonx/close_btn_disable.png";
	end
    --当前的快速冲值显示index
    self.m_current_product_index = 1;
	self.mLevel = level;
    --当前的商品列表
    self.m_product_list = self.mLevel and self:get_list_level() or GlobalDataManager.getInstance():get_list_default();
	self.obj = obj;
	if self.obj then 
		self.obj:addChild(self);
	end
    self:setLevel( GameConstant.view_level.bankrupt  );
	if level then 

		if not self.m_product_list or #self.m_product_list < 1 then 
			publ_getItemFromTree(self.window,{"img_win_bg", "img_inner_bg", "img_inner_item", "btn_update"}):setVisible(false);
	    end

	else
		self.suggestedProduct = ProductManager.getInstance():getBankruptAndNotEventProduct();

		if not self.suggestedProduct then 
			Banner.getInstance():showMsg("正在获取数据，请稍候...")
			ProductManager.getInstance():getProductList();
			GlobalDataManager.getInstance():getTuiJianProduct();
			if self.obj then 
				self:removeFromSuper()--真尼瑪蛋疼
			end 
			return;
		end

		if not self.m_product_list or #self.m_product_list < 1 then 
			publ_getItemFromTree(self.window,{"img_win_bg", "img_inner_bg", "img_inner_item", "btn_update"}):setVisible(false);
	    end
	end


    local btnGet = publ_getItemFromTree(self.window,{"img_win_bg", "img_inner_bg", "view_time", "btn_get"});
    --支持灰色
    btnGet:setGray(true)
    --publ_getItemFromTree(btnGet, {"Image3"}):setFile("Common/subViewBtnG2.png", kRGBGray);
	--publ_getItemFromTree(btnGet, {"Image4"}):setFile("Common/subViewBtnG1.png", kRGBGray);
	--publ_getItemFromTree(btnGet, {"Image5"}):setFile("Common/subViewBtnG3.png", kRGBGray);

	self:setBtnGetEnable(false);

    --设置响应事件
   	local btnConfirm = publ_getItemFromTree(self.window,{"img_win_bg","btn_confirm"})
   	local btnText = publ_getItemFromTree(self.window,{"img_win_bg","btn_confirm", "Text1"})

	btnConfirm:setOnClick(self,self.onSure)
	if GameConstant.checkType == kCheckStatusOpen 
        or PlatformConfig.platformOPPO == GameConstant.platformType then --审核状态 or oppo
		btnText:setText("购买")
	end

	publ_getItemFromTree(self.window,{"img_win_bg", "img_inner_bg", "img_inner_item", "btn_update"}):setOnClick(self,self.onMore);
	publ_getItemFromTree(self.window,{"img_win_bg", "img_inner_bg", "view_time", "btn_get"}):setOnClick(self,self.onGetCoin);
	publ_getItemFromTree(self.window,{"img_win_bg", "img_inner_bg", "view_time", "btn_get"}):setOnClick(self,self.onGetCoin);
	publ_getItemFromTree(self.window,{"img_win_bg", "img_inner_bg", "img_inner_item", "view_tips", "view_phone1", "btn_tel_1"}):setOnClick(self,self.onTel1);
	publ_getItemFromTree(self.window,{"img_win_bg", "img_inner_bg", "img_inner_item", "view_tips", "view_phone2", "btn_tel_2"}):setOnClick(self,self.onTel2);

	--如果当前是审核状态
	if (GameConstant.checkType ~= 0) then
		publ_getItemFromTree(self.window,{"img_win_bg",  "btn_confirm"}):setPos(160, 38);
		publ_getItemFromTree(self.window,{"img_win_bg",  "btn_cancel"}):setVisible(true);
		publ_getItemFromTree(self.window,{"img_win_bg",  "btn_cancel"}):setOnClick(self,function(self)
			GlobalDataManager.getInstance():showBankruptThings();
			self:hideWnd();
		end);
	else
		publ_getItemFromTree(self.window,{"img_win_bg",  "btn_confirm"}):setPos(0, 38);
		publ_getItemFromTree(self.window,{"img_win_bg",  "btn_cancel"}):setVisible(false);
	end

	--设置动画
	--self.lightView 	= publ_getItemFromTree(self.window,{"img_win_bg", "img_inner_bg", "img_inner_item", "img_item_bg", "view_light"});
	--self.imgLightBg = publ_getItemFromTree(self.window,{"img_win_bg", "img_inner_bg", "img_inner_item", "img_item_bg", "img_light_bg"});
	
	--local lightFrame = self:createLightAnim();
	--self.lightView:addChild(lightFrame);
	--self.lightView:setVisible(true);
	
	--计时器
	self.clock = new (BankraptcyClock,publ_getItemFromTree(self.window,{"img_win_bg", "img_inner_bg", "view_time"}));

	--设置PHP事件
	EventDispatcher.getInstance():register(ProductManager.updateSceneEvent, self, self.onUpdateBuyInfoList);


	self.getBankruptcyCoinEvent = EventDispatcher.getInstance():getUserEvent();
	EventDispatcher.getInstance():register(self.getBankruptcyCoinEvent, self, self.onGetBankruptcyCoin);

	self.productList = {};
	self.productIndex= 0;
	self.money 		 = 0;
	GameConstant.isLevelProductFlag = false;

	if level then 
		local product = self.m_product_list and self.m_product_list[1]--ProductManager.getInstance():getRecommendProductByEvent(tonumber(level));
		if product then 
			self.p_account = product.pamount or 6;
			self:setBuyInfo(product);
		end
	else
		--加载购买信息
		self:initBuyInfo();
	end

	self:setLevel(20000);

	if not self:isShowUpperLimitTips( isUpperLimit ) then
		self:loadBankruptcyTime(time);
	end
	--self:requestBankruptcyInfo();

	self.obj = obj;
	if self.obj then 
		self.obj:addChild(self);
	end
	self.closeListener = closeListener;
	self:showWnd();
end

BankruptcyDlg.get_list_level = function (self)

    local list = GlobalDataManager.getInstance():get_list_level();

    local product = nil;
    for i = 1, #list do
        local level = tonumber(list[i]._level);
        if level and level == self.mLevel then
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

BankruptcyDlg.isShowUpperLimitTips = function( self, isUpperLimit )
	if isUpperLimit then
		local upperLimitView = publ_getItemFromTree(self.window,{"img_win_bg", "img_inner_bg", "view_upper_limit"});
		local timeView = publ_getItemFromTree(self.window,{"img_win_bg", "img_inner_bg", "view_time"});
		upperLimitView:setVisible( true );
		timeView:setVisible( false );
	end

	return isUpperLimit;
end

BankruptcyDlg.dtor = function ( self )
	-- body
	EventDispatcher.getInstance():unregister(ProductManager.updateSceneEvent, self, self.onUpdateBuyInfoList);
	--EventDispatcher.getInstance():unregister(self.getBankruptcyTimeEvent, self, self.onUpdateBankruptcy);
	EventDispatcher.getInstance():unregister(self.getBankruptcyCoinEvent, self, self.onGetBankruptcyCoin);
	self:removeAllChildren();
end

BankruptcyDlg.hideHandle = function ( self )
	self:hideWnd();
end


BankruptcyDlg.setBtnGetEnable = function ( self, enable )
	-- body
	local btnGet = publ_getItemFromTree(self.window,{"img_win_bg", "img_inner_bg", "view_time", "btn_get"});
	btnGet:setGray(not enable)

	if enable then 
		publ_getItemFromTree(btnGet, {"text_title"}):setColor(255, 255, 255);
	else
		publ_getItemFromTree(btnGet, {"text_title"}):setColor(255, 255, 255);
	end
	btnGet:setPickable(enable);
end

--加载购买列表信息
BankruptcyDlg.initBuyInfo = function ( self )

    if not self.m_product_list or not self.m_product_list[1] then
        DebugLog("[BankruptcyDlg]:initBuyInfo data is nil");
        return;
    end
	self:setBuyInfo(self.m_product_list and self.m_product_list[1])
	self.p_account = self.m_product_list and self.m_product_list[1].pamount or 0
end

--加载时间
BankruptcyDlg.loadBankruptcyTime = function ( self ,time)
	if time <= 0 then
		self:onWaittingTimeOut();
	else
		self.clock:start(time,self,self.onWaittingTimeOut);
	end
end

--使能闪烁定时
BankruptcyDlg.enableGlow = function ( self ,bEnable)
	-- body
	if bEnable then 
		self.coinGlow:setVisible(true);
		if self.glowAnim then
			self.coinGlow:removeProp(1);
			self.glowAnim = nil;
		end 
		
		self.glowAnim  = self.coinGlow:addPropTranslate(1,kAnimRepeat,500,0,0,0,0,0);
		self.glowAnim:setEvent(self,BankruptcyDlg.glowing);
    	    
	else
		if self.glowAnim then
			self.coinGlow:removeProp(1);
			self.glowAnim = nil;
		end 
		self.coinGlow:setVisible(false);
	end
	
end
--闪烁定时回调
BankruptcyDlg.glowing = function ( self )
	self.coinGlow:setVisible(not self.coinGlow:getVisible());
end


--设置购买信息
BankruptcyDlg.setBuyInfo = function ( self, product)
	-- body
	if not product then 
		return ;
	end

	local tip = (product.pname or "") .. " = " .. GameString.convert2Platform("￥") .. tonumber(product.pamount or 0);

	publ_getItemFromTree(self.window,{"img_win_bg", "img_inner_bg", "img_inner_item", "img_item_bg", "text_tip1"}):setText(tip);
	publ_getItemFromTree(self.window,{"img_win_bg", "img_inner_bg", "img_inner_item", "img_item_bg", "text_tip2"}):setText(product.pdesc or "");
	
end

BankruptcyDlg.hide = function ( self )
	umengStatics_lua(kUmengBankruptCloseBtn);
	if  self.closeListener then
		self.closeListener(self.arg);
	end
	self:setVisible(false);
	self:removeFromSuper();
end

--等待时间 timeout响应事件
BankruptcyDlg.onWaittingTimeOut = function ( self )
	-- body

	self:setBtnGetEnable(true);

end

--领取金币按钮 响应事件
BankruptcyDlg.onGetCoin = function ( self )
	-- body
	umengStatics_lua(kUmengBankruptAwardCoinBtn);

	self:setBtnGetEnable(false);


	local param_data = {};
	param_data.mid = PlayerManager.getInstance():myself().mid;
	param_data.sitemid = SystemGetSitemid();

	SocketManager.getInstance():sendPack( PHP_CMD_GET_BANKRAPTCY_REMEDY,param_data )

end

--获取更多按钮 响应事件
BankruptcyDlg.onMore = function ( self )
	umengStatics_lua(kUmengBankruptChangeBtn);
--	if self.mLevel then 
--		local product = ProductManager.getInstance():getLevelRecommendProductByNextAmount(self.p_account);
--		if not product then 
--			return ;
--		end
--		self.p_account = product.pamount or 6;

--		self:setBuyInfo(product);
--	else
--		local product = ProductManager.getInstance():getVipRecommendProductByNextAmount(self.p_account);
--		if not product then 
--			return ;
--		end
--		self.p_account = product.pamount or 6;

--		self:setBuyInfo(product);
--	end



    local product_list = self.m_product_list;--self.mLevel and GlobalDataManager.getInstance():get_list_level() or GlobalDataManager.getInstance():get_list_default();
    if not product_list or #product_list < 1 then
        DebugLog("list is nil");
        return nil;
    end

    if #product_list < 1 then
        return;
    end
    self.m_current_product_index = self.m_current_product_index + 1;
    if self.m_current_product_index > #product_list then
        self.m_current_product_index = 1;
    end
    local pdoduct = product_list[self.m_current_product_index];
    self:setBuyInfo(pdoduct);
--    for i = 1, #product_list do
--        if product_list[i].pamount and product_list[i].pamount == self.p_account then
--            self:setBuyInfo(product_list[i]);
--            break;
--        end
--    end
    
end

--确定按扭 响应事件
BankruptcyDlg.onSure = function ( self )
	-- body
	self.p_account = self.p_account or 6;
	if self.p_account >= 0 then

		umengStatics_lua(kUmengBankruptPayBtn);

		local product = ProductManager.getInstance():getProductByPamount(self.p_account);
		if not product then
			return;
		end
		--支付上报数据
		local levelType,level,basechip = getRoomInformWhenInRoom();
		RoomData.getInstance().di = 0;
		RoomData.getInstance().level = 0;
		local payScene = {};
		payScene.scene_id = PlatformConfig.BankRuptBuyForPay;
		payScene.levelType = levelType;
		payScene.level = level;
		payScene.basechip = basechip;
		payScene.bankrupt = 1;

		GlobalDataManager.getInstance():quickPay(self.p_account,payScene);
			
		GlobalDataManager.getInstance():gotoScoreMatch();
		self:hideWnd();
	else
		Banner.getInstance():showMsg("正在更新商品，请稍候...");
	end
end

--php 更新购买列表 回调
BankruptcyDlg.onUpdateBuyInfoList = function ( self)
	-- body
	self:initBuyInfo();
end

--php 返回破产时间和额外赠送
--BankruptcyDlg.onUpdateBankruptcy = function ( self ,command, isSuccess, data)
--	if isSuccess and data then
--		local status = data.status or 0;
--		local time 	 = data.data.time or 0;
--
--		if 1 == status then
--			self:loadBankruptcyTime(time,GameString.convert2Platform(data.msg or ""));
--		else
--			Banner.getInstance():showMsg(GameString.convert2Platform(data.msg or ""));
--			if -2 == status then  --已经超过破产次数
--				--self.callFunc(self.callObj);
--				self:hide();
--			end
--		end
--	end
--end

--php 返回破产补助
BankruptcyDlg.onGetBankruptcyCoin = function ( self , command ,isSuccess, data )
	-- body
	--{"status":1,"money":1000,"reward":1000,"notice":"","vipBonus":0}
	if isSuccess and data then
		local status = data.status or 0;
		if 1 == status then
			PlayerManager.getInstance():myself():addMoney(data.money or 0);
			--播发掉金币动画
			showGoldDropAnimation();
			self:hideWnd();
			--通知其他完成金币变化
			--如果在游戏中
			if RoomScene_instance and not FriendMatchRoomScene_instance then
				SocketSender.getInstance():send(CLIENT_COMMAND_GET_NEW_MONEY, {["mid"] = PlayerManager.getInstance():myself().mid});
			end
			AnimationAwardTips.play(data.msg or "");
		elseif 2 == status then
			local time 	 = data.data.time or 0;
			self:loadBankruptcyTime(time,nil);
			AnimationAwardTips.play(data.msg or "");
		else
			self:hideWnd();
			Banner.getInstance():showMsg( data.msg or "" );
		end
	else
		--可重新获取
		self:setBtnGetEnable(true);
		local msg = nil;
		if data and data.msg then
			msg = data.msg
		else
			msg = "不要点这么急啦！";
		end

		if type( data ) == "string" then
		    msg = data;
		end

		Banner.getInstance():showMsg(msg);
		-- AnimationAwardTips.play( msg );
	end
end
BankruptcyDlg.onTel1 = function ( self )
	callPhone("4006631888");
end
BankruptcyDlg.onTel2 = function ( self )
	callPhone("075586166169");
end




