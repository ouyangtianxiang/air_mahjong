-- ExchangePopu.lua
-- Author: YifanHe
-- Date: 2014-02-27
-- Description: 兑换道具提示框
-----------------兑换卡片CID----------------------------
-- ItemManager.VIP_CID = 1; -- VIP卡
-- ItemManager.BUQIAN_CID = 2; -- 补签卡
-- ItemManager.WANJIN_CID = 3; -- 10000金币
-- ItemManager.GONGZAI_CID = 4; -- 公仔
-- ItemManager.TOUXIANG1_CID = 5; -- 头像框1
-- ItemManager.HUANSANZHANG_CID = 6; -- 换三张
-- ItemManager.XUELIU_CID = 7; -- 血流卡
-- ItemManager.TOUXIANG2_CID = 8; -- 头像卡2号
-- ItemManager.JIANFANGJIAN2W_CID = 9; -- 2W创建房间卡
-- ItemManager.JIANFANGJIAN5W_CID = 10; -- 5万创建房间卡
-- ItemManager.LABA_CID           = 22; -- 喇叭
--------------------------------------------------------
require("MahjongData/ItemManager");
local exchangePopu = require(ViewLuaPath.."exchangePopu");
require("MahjongCommon/RechargeTip")
require("MahjongHall/HongBao/HongBaoModel")


ExchangePopu = class(SCWindow);

ExchangePopu.ctor = function (self, cid, signRef, msgIndex)
	self.signRef  = signRef;
	self.msgIndex = msgIndex

	if self.signRef then
		self.signRef:addChild(self);
	else
		self:addToRoot();
	end

	self.cid = cid;
    self.m_total_money = 0;
	self:registerEvent();
	self:iniData( cid );
	self:initView();
	self:setViewContent();
	self:setViewEvent();
	self:showWnd();
end

function ExchangePopu.registerEvent( self )

	self.m_updateEvent = EventDispatcher.getInstance():getUserEvent();
	EventDispatcher.getInstance():register(SocketManager.s_phpMsg, self, self.onPhpMsgResponse);

	self.myData = PlayerManager.getInstance():myself();
end

function ExchangePopu.iniData( self, cid )
	--兑换数据
	self.exchangeInfoList = ProductManager.getInstance():getExchangeInfoList() or {};
	for k, v in pairs(self.exchangeInfoList) do
		if v.cid == cid then
			self.data = v;
			self.m_id = v.id;  --商品ID
			self.m_name = v.name;  --商品名称
			self.m_sptype = v.sptype;  --商品销售类型: 1 hot, 2 new, 3 超值, 4 限量  [5折扣(后端未启用)]
			self.m_image = v.image;  --商品图片URL
			self.m_money = v.money;  --价值多少金币
			self.m_chips = v.chips;  --价值多少积分
			self.m_coupons = v.coupons; -- 话费卷
			self.m_boyaacoin = v.boyaacoin;  --价值多少博雅币
			self.m_rewardmoney = v.rewardmoney;  --赠送金币
			self.m_moneytype = v.moneytype;  --0积分 1金币 2博雅币 3积分加金币
			self.m_goodsdes = v.goodsdes;  --商品描述
			self.m_goodstype = v.goodstype;  --商品类型: 1卡片 2金币 3实物
			self.m_cid = v.cid; --卡片ID
			self.m_discount = v.discount;  --折扣
			self.m_num = v.num;  --总量
			self.m_limitnum = v.limitnum;  --个人限购
			break;
		end
	end
end

function ExchangePopu.initView( self )
	self.layout = SceneLoader.load(exchangePopu);
	self:addChild(self.layout);

	self.bgView = publ_getItemFromTree(self.layout, {"bg"});
	self:setWindowNode( self.layout );

	self.cancelBtn = publ_getItemFromTree(self.layout, {"closeBtn"});
	self.cancelBtn:setOnClick(self,function(self)
		self:hideWnd();
	end);

	if PlatformConfig.platformWDJ == GameConstant.platformType or 
	   PlatformConfig.platformWDJNet == GameConstant.platformType then 
        self.cancelBtn:setFile("Login/wdj/Hall/Commonx/close_btn.png");
        self.bgView:setFile("Login/wdj/Hall/Commonx/pop_window_small.png");
        publ_getItemFromTree(self.layout, {"frame", "iconBg"}):setFile("Login/wdj/Hall/HallMall/prop_bg.png");
        publ_getItemFromTree(self.layout, {"frame", "numBg"}):setFile("Login/wdj/Hall/HallMall/input_bg.png");
    end

	self.cardImg = publ_getItemFromTree(self.layout, {"frame", "iconBg", "icon"});
	self.cardText = publ_getItemFromTree(self.layout, {"frame", "iconBg","priceText"});
	self.totalText = publ_getItemFromTree(self.layout, {"frame", "totalText"});
	self.nowText = publ_getItemFromTree(self.layout, {"frame", "ownText"});
	self.numText = publ_getItemFromTree(self.layout, {"frame", "numBg", "numText"}); --商品数量
	self.minusBtn = publ_getItemFromTree(self.layout, {"frame", "minusBtn"}); -- 减号按钮
	self.plusBtn = publ_getItemFromTree(self.layout, {"frame", "plusBtn"}); -- 加号按钮
	self.exchangeBtn = publ_getItemFromTree(self.layout, {"confirmBtn"}); -- 兑换按钮
	self.textChangeNicknameTips = publ_getItemFromTree(self.layout, {"bg","text_change_nickname_tips"}); -- 兑换按钮

	--if self.cid == ItemManager.CHANGE_NICK_CID then
		self.textChangeNicknameTips:setVisible( self.cid == ItemManager.CHANGE_NICK_CID );
	--end
end

function ExchangePopu.setViewContent( self )
	self.payStr = "";  --价格说明文字
	self.typeStr = "";  --价格类型文字
	if self.m_moneytype == 0 then
		self.payStr = self.m_chips .. "积分";
		self.typeStr = "积分";
	elseif self.m_moneytype == 1 then
		self.payStr = self.m_money .. "金币";
		self.typeStr = "金币";
	elseif self.m_moneytype == 2 then--以前的博雅币现在改为钻石了
		self.payStr = self.m_boyaacoin .. "钻石";
		self.typeStr = "钻石";
	elseif self.m_moneytype == 3 then
		self.payStr = self.m_chips .. "积分与"..self.m_money.."金币";
		self.typeStr = "积分";
	elseif self.m_moneytype == 4 then
		self.payStr = self.m_coupons .. "话费卷";
		self.typeStr = "话费卷";
	end
	self.cardText:setText(self.payStr);

	--价格字
	local totalStr = "总价:";
	local nowStr = "现有:";
	if self.m_moneytype == 0 then
        self.m_total_money = self.m_chips;
		totalStr = totalStr .. self.m_chips;
		nowStr = nowStr .. self.myData.chips;
	elseif self.m_moneytype == 1 then
        self.m_total_money = self.m_money;
		totalStr = totalStr .. self.m_money;
		nowStr = nowStr .. self.myData.money;
	elseif self.m_moneytype == 2 then
        self.m_total_money = self.m_boyaacoin;
		totalStr = totalStr .. self.m_boyaacoin;
		nowStr = nowStr .. self.myData.boyaacoin;
	elseif self.m_moneytype == 3 then
        self.m_total_money = self.m_chips;
		totalStr = totalStr .. self.m_chips;
		nowStr = nowStr .. self.myData.chips;
	elseif self.m_moneytype == 4 then
        self.m_total_money = self.m_coupons;
		totalStr = totalStr .. self.m_coupons;
		nowStr = nowStr .. self.myData.coupons;
	end
	totalStr = totalStr .. self.typeStr;
	nowStr = nowStr .. self.typeStr;
	
	self.totalText:setText(totalStr);
	self.nowText:setText(nowStr);
	DebugLog("buy prop img name(ExchangePopu): " .. tostring(self.m_image))
	local isExist, localDir = NativeManager.getInstance():downloadImage(self.m_image);
	if isExist then
		self.cardImg:setFile( localDir );
	else
		-- if ItemManager.itemImgTable[self.m_cid] then
		-- 	self.cardImg:setFile(ItemManager.itemImgTable[self.m_cid]);
		-- else
		-- 	self.cardImg:setFile( "newHall/mall/coinIcon.png" );
		-- endz
		self.cardImg:setFile( "Commonx/windowsCoin.png" );
	end
end

function ExchangePopu.setViewEvent( self )
	self.minusBtn:setOnClick(self, function(self)
		umengStatics_lua(Umeng_QianDaoBuyMinus);
		--数量文字
		local num = tonumber(self.numText:getText() or 1);  --当前显示数量
		if not num or num <= 1 then  --购买数量不能小于1
			num = 1; 
		else
			num = num - 1;
		end
		self.numText:setText(num);
		self:updateTotalText(num);  --更新总价文z字
	end);

	self.plusBtn:setOnClick(self, function(self)
		umengStatics_lua(Umeng_QianDaoBuyPlus);
		local boyaaCoin = self.myData.boyaacoin;
		local num = tonumber(self.numText:getText() or 1);  --当前显示数量
		DebugLog("num: " .. num )
		if not num then  
			num = 1; 
		elseif num >= 99 or ( num >= self:_calculateItemNum() ) then  --购买数量不能大于99或者持有博雅币数量
			-- num = num;  不变
			self:_showTips( num );
		else
			num = num + 1;
		end
		self.numText:setText(num);
		self:updateTotalText(num);  --更新总价文字
	end);
	
	self.exchangeBtn:setOnClick(self, self.onClickBuyBtn);
end

-- 没有足够的兑换货币
function ExchangePopu._showTips( self, num )
	local str = "金币";
	local outStr = "";
	if num >= 99 then
		outStr = "您已经拥有太多此类物品";
	else
		if self.m_moneytype == 0 then
			str = "积分";
		elseif self.m_moneytype == 1 then
			str = "金币";
		elseif self.m_moneytype == 2 then--以前的博雅币现在改为钻石了
			str = "钻石";
		elseif self.m_moneytype == 3 then
			str = "积分";
		elseif self.m_moneytype == 4 then
			str = "话费卷";
		end
		outStr = "您没有足够的"..str;
	end
	Banner.getInstance():showMsg( outStr );
end

-- 更新金币
function ExchangePopu.updateCoins( self )
	GlobalDataManager.getInstance():updateScene();
end

function ExchangePopu._calculateItemNum( self )

	local nums = 1;
	if self.m_moneytype == 0 then
		nums = self.myData.chips / ( self.m_chips or 1 );
	elseif self.m_moneytype == 1 then
		nums = self.myData.money / ( self.m_money or 1 );
	elseif self.m_moneytype == 2 then
		nums = self.myData.boyaacoin / ( self.m_boyaacoin or 1 );
	elseif self.m_moneytype == 3 then
		nums = self.myData.chips / ( self.m_chips or 1 );
	elseif self.m_moneytype == 4 then
		nums = self.myData.coupons / ( self.m_coupons or 1 );
	end

	return math.floor( nums );
end

ExchangePopu.updateTotalText = function( self , num)
	--总价
	local totalStr = "总价:";
	if self.m_moneytype == 0 then
		totalStr = totalStr .. num * tonumber(self.m_chips);
	elseif self.m_moneytype == 1 then
		totalStr = totalStr .. num * tonumber(self.m_money);
	elseif self.m_moneytype == 2 then
		totalStr = totalStr .. num * tonumber(self.m_boyaacoin);
	elseif self.m_moneytype == 3 then
		totalStr = totalStr .. num * tonumber(self.m_chips);
	elseif self.m_moneytype == 4 then 
		totalStr = totalStr .. num * tonumber(self.m_coupons)
	end
	totalStr = totalStr .. self.typeStr;
	self.totalText:setText(totalStr);
end

ExchangePopu.onClickBuyBtn = function( self )
	--处理个人限购数量
	umengStatics_lua(Umeng_QianDaoBuyBuy);
	local myCardNum = ItemManager.getInstance():getCardNum(self.m_cid);
	if self.m_limitnum and self.m_limitnum ~= 0 and myCardNum >= self.m_limitnum then
		local msg = "您已经拥有太多此类物品";
		Banner.getInstance():showMsg(msg);
		return;
	end

	--发送一般兑换请求
	self:postExchange();
end

--购买逻辑
ExchangePopu.postExchange = function( self )
	if not self.data then
		return ;
	end
	local param_data = self.data or {};
	param_data.mallRef = nil;
	param_data.mid = PlayerManager.getInstance():myself().mid;
	-- param_data.sitemid = SystemGetSitemid();
	param_data.number = tonumber(self.numText:getText() or 1);
 

	-- param_data.money = PlayerManager.getInstance():myself().money or 0;
    
    local me = PlayerManager.getInstance():myself();
    local money = nil;


    if self.m_moneytype == 1 then
        money = tonumber(me.money) or 0;
    elseif self.m_moneytype == 2 then
        money = tonumber(me.boyaacoin) or 0;
    end
    if not money then
        DebugLog("money is nil");
        local str = "你的"..self.typeStr.."数量不足，无法购买该商品。";
        Banner.getInstance():showMsg(str);
        return;
    end

    if money < (self.m_total_money or 0) then
        local param_t = {t = RechargeTip.enum.buy_pro, isShow = true, money = self.m_total_money, moneytype = global_transform_money_type_2(self.m_moneytype, true) , prop_name = self.m_name,parent = self}
        RechargeTip.create(param_t)
        return;
    else
    	Loading.showLoadingAnim("兑换中...");
	    SocketManager.getInstance():sendPack( PHP_CMD_REQUEST_EXCHANGE , param_data)
    end
end

ExchangePopu.dispatchCouponsChange = function ( self )
	local temp = {};
	temp["type"] = GlobalDataManager.UI_UPDATA_EXCHANGE_TIP;
	EventDispatcher.getInstance():dispatch(GlobalDataManager.updateSceneEvent, temp);
end

ExchangePopu.requestExchangeCallBack = function(self, isSuccess, data)
	DebugLog("ExchangePopu.requestExchangeCallBack")
	Loading.hideLoadingAnim();

    if not isSuccess then --
        if data and data.msg then --正常传的data.msg
            Banner.getInstance():showMsg( data.msg );
        elseif type( data ) == "string" then --老代码 貌似传的的是data 是string兼容下 
            Banner.getInstance():showMsg(data);
        end
    end

	if not data then
		return;
	end

    local function exchangeFail(self, d)
        DebugLog("exchangeFail");
        local param_t = {t = RechargeTip.enum.buy_pro, isShow = true, money = self.m_total_money, moneytype = global_transform_money_type_2(self.m_moneytype, true), prop_name = self.m_name,parent = self}
        RechargeTip.create(param_t)
		self:hideWnd();
    end
    if not isSuccess or  GetNumFromJsonTable(data, "status") ~= 1 then
        exchangeFail(self, data);
        return;
    end
	if isSuccess then
        
		local msg = GetStrFromJsonTable(data, "msg");
		Banner.getInstance():showMsg(msg);
		if GetNumFromJsonTable(data, "status") == 1 then
			local ctype = GetNumFromJsonTable(data, "ctype"); --1加 2减 （chips）
			local chips = GetNumFromJsonTable(data, "chips"); --积分
			local mtype = GetNumFromJsonTable(data, "mtype"); --1加 2减 （money）
			local money = GetNumFromJsonTable(data, "money"); --金币
			local btype = GetNumFromJsonTable(data, "btype"); --1加 2减 （boyaacoin）
			local boyaacoin = GetNumFromJsonTable(data, "boyaacoin"); --博雅币
			local cptype = GetNumFromJsonTable(data, "cptype");
			local coupons = GetNumFromJsonTable(data, "coupons");
			local goodsid = GetNumFromJsonTable(data, "goodsid");
			local myself = PlayerManager.getInstance():myself();
			
			--处理积分变化
			if ctype == 1 then
				myself.chips = myself.chips + chips;
			elseif ctype == 2 then
				myself.chips = myself.chips - chips;
			end

			--处理金币变化
			if mtype == 1 then
				myself.money = myself.money + money;
			elseif mtype == 2 then
				myself.money = myself.money - money;
			end

			--处理博雅币变化
			if btype == 1 then
				myself.boyaacoin = myself.boyaacoin + boyaacoin;
			elseif btype == 2 then
				myself.boyaacoin = myself.boyaacoin - boyaacoin;
			end

			--处理话费变化
			if cptype and cptype == 1 then
				myself.coupons = myself.coupons + coupons;
				self:dispatchCouponsChange()
			elseif cptype and cptype == 2 then
				myself.coupons = myself.coupons - coupons;
				self:dispatchCouponsChange()
			end

			if self.signRef and self.signRef.boyaaText then
				self.signRef.boyaaText:setText(trunNumberIntoThreeOneFormWithInt(tostring(myself.coupons)));
			end

			EventDispatcher.getInstance():dispatch(self.m_updateEvent);
			GlobalDataManager.getInstance():onRequestMyItemList(); -- 重新拉去道具
			--updateChangeNicknameTimes( data );

			self:hideWnd();

			BaseInfoManager.getInstance():refreshCards();

			if goodsid then
				if tonumber( goodsid ) == ItemManager.CHANGE_NICK_CID then
					EventDispatcher.getInstance():dispatch(GlobalDataManager.exchangeCNNSEvent);
				elseif tonumber( goodsid ) == ItemManager.BUQIAN_CID then
					if HallScene_instance and HallScene_instance.signWindow then 
                        --modify by NoahHan 20160421
                        if HallScene_instance.signWindow.requestBq then
                            HallScene_instance.signWindow:requestBq(tonumber(self.numText:getText() or 1));
                        end
					end 
					EventDispatcher.getInstance():dispatch(GlobalDataManager.myItemListUpdated);
				elseif tonumber( goodsid ) == ItemManager.HONG_BAO_CID then 
					GameConstant.changeNickTimes.rednum = GameConstant.changeNickTimes.rednum + money

					EventDispatcher.getInstance():dispatch(HongBaoModel.HongBaoMsgs,HongBaoModel.exchangeHongBaoEvent);
				elseif tonumber( goodsid ) == ItemManager.LABA_CID then 
					if self.signRef and self.msgIndex then 
						if self.signRef.broadcastPopWin then --大厅或房间
							self.signRef.broadcastPopWin:sendMsgByIndex(self.msgIndex)
						elseif self.signRef.matchApplyWindow and self.signRef.matchApplyWindow.broadcastPopWin then --比赛等待界面
							self.signRef.matchApplyWindow.broadcastPopWin:sendMsgByIndex(self.msgIndex)
						end 
					end 
					if RoomScene_instance and not FriendMatchRoomScene_instance then --房间内不要走php刷新金币,要走server刷金币 否则会有金币流问题
						SocketSender.getInstance():send(CLIENT_COMMAND_GET_NEW_MONEY, {["mid"] = PlayerManager.getInstance():myself().mid});
						return 
					end 
				end
			end

			self:updateCoins();
		end
	else
	end
end


ExchangePopu.onPhpMsgResponse = function ( self, param, cmd, isSuccess )
	if self.phpMsgResponseCallBackFuncMap[cmd] then 
		self.phpMsgResponseCallBackFuncMap[cmd](self,isSuccess,param)
	end
end

--回调函数映射表
ExchangePopu.phpMsgResponseCallBackFuncMap =
{
	[PHP_CMD_REQUEST_EXCHANGE] = ExchangePopu.requestExchangeCallBack
};

function ExchangePopu.onWindowHide( self )
	self.super.onWindowHide( self );
	umengStatics_lua(Umeng_QianDaoBuyClose);
end

ExchangePopu.dtor = function (self)
	EventDispatcher.getInstance():unregister(SocketManager.s_phpMsg, self, self.onPhpMsgResponse);

	self:removeAllChildren();
end


