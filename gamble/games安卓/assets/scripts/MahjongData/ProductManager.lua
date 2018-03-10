-- ProductManager.lua
-- Author: YifanHe
-- Date: 2013-10-22
-- Last modification : 2013-10-23
-- Description: 用于管理商品数据，包括购买商品和兑换商品

ProductManager = class();

kTypeMoney = 0;   --金币
kTypeBYCoins = 1; --博雅币
kTypeProp = 2; -- 道具


local kTypeYIDONG = 1;
local kTypeLIANTONG = 2;
local kTypeDIANXIN = 3;

ProductManager.instance = nil;
ProductManager.getInstance = function()
	if not ProductManager.instance then
		ProductManager.instance = new(ProductManager);
	end
	return ProductManager.instance;
end

ProductManager.updateSceneEvent = EventDispatcher.getInstance():getUserEvent();
ProductManager.getExchanegeCallbackEvent = EventDispatcher.getInstance():getUserEvent();
ProductManager.getExchanegeHistoryCallbackEvent = EventDispatcher.getInstance():getUserEvent();

ProductManager.ctor = function (self)
	self.m_productListSource = {};     --存放商品信息json源数据
	self.m_exchangeInfoListSource = {};    --存放兑换信息json源数据
	self.m_productSourceFlag = false;  --是否已经有商品源数据
	self.m_exchangeSourceFlag = false;  --是否已经有兑换源数据
	self.m_productList = {};     --存放商品信息列表
	self.m_productListAll = {};
	self.m_exchangeInfoList = {};    --存放兑换信息列表
	self.m_productFlag = false;  --商品信息是否已经获取完成
	self.m_exchangeFlag = false; --兑换信息是否已经获取完成
	self.m_exchangeHistoryInfoList = {};    --存放历史兑换信息列表
	--self.m_event = EventDispatcher.getInstance():getUserEvent();
	self.cacheDataHttpEvent = EventDispatcher.getInstance():getUserEvent();

	EventDispatcher.getInstance():register(SocketManager.s_phpMsg, self, self.onHttpRequestsListenster);
	NetCacheDataManager.getInstance():register( self.cacheDataHttpEvent, ProductManager.cacheDataHttpCallBackFuncMap, self, self.onCacheDataHttpListener );
end

ProductManager.dtor = function (self)
	self.m_productList = {};
	self.m_productListAll = {};
	self.m_exchangeInfoList = {};
	self.m_exchangeHistoryInfoList = {}
	EventDispatcher.getInstance():unregister(SocketManager.s_phpMsg, self, self.onHttpRequestsListenster);
	NetCacheDataManager.getInstance():unregister(self.cacheDataHttpEvent,self,self.onCacheDataHttpListener);
end

ProductManager.clearProductList = function ( self )
	self.m_productList = {};
	self.m_productListAll = {};
	self.m_productSourceFlag = false;
	self.m_productListSource = nil;
end

--获取当前商品数据
--return:  self.m_productList [table]  商品列表
		-- id       [number]  -- 商品ID
		-- ptype 	[number]  -- 商品类型  0 金币
		-- pamount  [number]  -- 应付款项
		-- pchips   [number]  -- 所购金币数量
		-- pcoins   [number]  -- 所购博雅币数量
		-- pcard    [number]  -- 对等道具ID
		-- pnum     [number]  -- 数量
		-- pname  	[String]  -- 商品名称
		-- pimg     [String]  -- 图片下载地址
		-- pdesc    [String]  -- 商品描述
		-- psort	[number]  -- 排序
ProductManager.getProductList = function(self)
	if not self.m_productFlag or #self.m_productList <= 0 then
		if self.m_productSourceFlag then
			self:parseProductInfo();  --如果有数据但是没解析则解析后再返回
		else
			NetCacheDataManager.getInstance():activeNotifyReceiver(PHP_CMD_GET_PRODUCT_PROXY);
			return nil;
		end
	end
	return self.m_productList;
end

--推荐n元以上的商品
ProductManager.getProductOverop = function( self, pamount , _type )
	local productList = self:getProductList();
	--还未获取到商品
	if not productList then
		return 0;
	end
	_type = _type or kTypeMoney;
	table.sort(productList, ProductManager.sortProductByPamount);
	local mostAmount = 0;
	--没找到符合条件的商品则推荐能找到的最大值
	for k , v in pairs(productList) do
		if _type == v.ptype then
			if v.pamount > mostAmount then
				mostAmount = v.pamount;
			end
			if v.pamount >= pamount and kTypeMoney == v.ptype then
				return v.pamount;
			end
		end
	end
	return mostAmount;
end

--通过Pamount查找对应商品
ProductManager.getProductByPamount = function(self, pamount , _type)
	local productList = self:getProductList();

	if not productList then
		productList = self.m_productList;
	end

	if not productList or not pamount then
		return nil;
	end

	table.sort(productList, ProductManager.sortProductByPamount);
	_type = _type or kTypeMoney;
	local result , next_1 = nil , nil;
	for k , v in pairs(productList) do
		if _type == v.ptype then
			if v.pamount >= pamount then
				result = v;
				break;
			end
			next_1 = v;
		end
	end

	if not result and GameConstant.isNewRecommendAmount and next_1 then
		result = next_1;
		for k = 1 , #GameConstant.isNewRecommendAmount do
			if GameConstant.isNewRecommendAmount[k] == result.pamount then
				table.remove(GameConstant.isNewRecommendAmount , k);
				break;
			end
		end
		local flag = false;
		for k = 1 , #GameConstant.isNewRecommendAmount do
			if GameConstant.isNewRecommendAmount[k] == pamount then
				flag = true;
				GameConstant.isNewRecommendAmount[k] = result.pamount;
				break;
			end
		end
		if not flag then
			table.insert(GameConstant.isNewRecommendAmount , result.pamount);
		end
	end
	return result;
end

--通过Pamount查找对应商品
ProductManager.getHideProductByPamount = function(self, pamount , _type)
	if not self:getProductList() or not pamount then
		return nil;
	end
	local result , next_1 = nil , nil;
	for k, v in pairs(self.m_productListAll) do
		if kTypeMoney == v.ptype then
			if v.pamount == pamount then
				result = v;
				break;
			end
			if not next_1 or (next_1.pamount < pamount and v.pamount >= pamount)
				or (math.abs(pamount - next_1.pamount) > math.abs(pamount - v.pamount)) then
				next_1 = v;
			end
		end
	end
	return result;
end

--获取兑换商品数据
-- "id"          :"4",商品ID
-- "name"        :"\u516c\u4ed4",商品名称
-- "sptype"      :"3",商品销售类型: 1 hot,2 new,3 超值，4 限量
-- "image"       :"http:\/\/tb.himg.baidu.com\/sys\/portraitn\/item\/d570bba8cfefd3d0c8cbc4eecbfdb9e94f2f",商品图片
-- "money"       :"100",价值多少金币
-- "chips"       :"0",价值多少积分
-- "boyaacoin"   :"0",价值多少博雅币
-- "rewardmoney" :"0",赠送金币
-- "moneytype"   :"1", 0积分1金币2博雅币3积分加金币
-- "goodsdes"    :"\u516c\u4ed4", （商品描述）
-- "goodstype"   :"3",（商品类型: 1 卡片 2 金币 3 实物）
-- "cid"         :null, 卡片ID
-- "discount"    :"0", 折扣
-- "num"         :"0", 总量
-- "limitnum"    :"47", 个人限购
-- "m_sort"      :"5" 排序
ProductManager.getExchangeInfoList = function(self)
	if self.m_exchangeFlag then
		return self.m_exchangeInfoList;
	end
end

--获取兑换商品列表
ProductManager.getExchangeList = function(self)
	log( "ProductManager.getExchangeList" );
	if self.nowGetExchangeList then  -- 正在获取列表
		DebugLog("【正在获取兑换列表】");
		return;
	end

	self.nowGetExchangeList = true;
	NetCacheDataManager.getInstance():activeNotifyReceiver( PHP_CMD_REQUEST_EXCHANGE_LIST );
end

--兑换列表回调
ProductManager.getExchangeListCallBack = function(self, isSuccess, data)
	Loading.hideLoadingAnim();
	self.nowGetExchangeList = false;
	if not isSuccess and not data then
	    return;
	end
	DebugLog("*********")
	--mahjongPrint(data)
	if isSuccess and data then
		if GetNumFromJsonTable(data, "status") == 0 then
			DebugLog("【获取兑换物品数据失败】");
			return;
		end
		self.m_exchangeInfoListSource = data.info;    --存放兑换信息json源数据
		self.m_exchangeSourceFlag = true;  --是否已经有兑换源数据
		if self.m_exchangeInfoListSource then
			self:parseExchangeInfo();
		end
	end
end

--解析兑换信息
ProductManager.parseExchangeInfo = function(self)
	if not self.m_exchangeSourceFlag then
		DebugLog("【还未获取到兑换数据】");
		return;
	end
	self.m_exchangeInfoList = {};
	if self.m_exchangeInfoListSource and #self.m_exchangeInfoListSource > 0 then
	    for k, v in pairs(self.m_exchangeInfoListSource) do
			local exchangeItem = {};
			exchangeItem.id = GetNumFromJsonTable(v, "id");
			exchangeItem.name = GetStrFromJsonTable(v, "name");
			exchangeItem.sptype = GetNumFromJsonTable(v, "sptype");
			exchangeItem.image = GetStrFromJsonTable(v, "image");
			exchangeItem.money = GetNumFromJsonTable(v, "money");
			exchangeItem.chips = GetNumFromJsonTable(v, "chips");
			exchangeItem.boyaacoin = GetNumFromJsonTable(v, "boyaacoin");
			exchangeItem.coupons = GetNumFromJsonTable(v, "coupons");
			exchangeItem.rewardmoney = GetNumFromJsonTable(v, "rewardmoney");
			exchangeItem.moneytype = GetNumFromJsonTable(v, "moneytype");
			exchangeItem.goodsdes = GetStrFromJsonTable(v, "goodsdes");
			exchangeItem.goodstype = GetNumFromJsonTable(v, "goodstype");
			exchangeItem.cid = GetNumFromJsonTable(v, "cid");
			exchangeItem.discount = GetNumFromJsonTable(v, "discount");
			exchangeItem.num = GetNumFromJsonTable(v, "num");
			exchangeItem.limitnum = GetNumFromJsonTable(v, "limitnum");
			exchangeItem.sort = GetNumFromJsonTable(v, "m_sort") or 0;

			--ios 屏蔽
			if GameConstant.iosDeviceType>0 then
				if GameConstant.iosPingBiFee then
					if exchangeItem.id==ItemManager.CHANGE_NICK_CID or exchangeItem.id==ItemManager.LABA_CID then
						table.insert(self.m_exchangeInfoList, exchangeItem);
					end
				else
					table.insert(self.m_exchangeInfoList, exchangeItem);
				end
			else
				table.insert(self.m_exchangeInfoList, exchangeItem);
			end
			if exchangeItem.image then
				NativeManager.getInstance():downloadImage(exchangeItem.image);--兑换图片预下载
			end
		end
		table.sort( self.m_exchangeInfoList, ProductManager.sortExchangeInfo);
		self.m_exchangeFlag = true;
		DebugLog("【兑换数据解析完成】");
		EventDispatcher.getInstance():dispatch(ProductManager.getExchanegeCallbackEvent);
	else
		DebugLog("兑换道具列表错误");
	end
end

--排序兑换信息
ProductManager.sortExchangeInfo = function(s1 , s2)
	local id_1 = s1.sort or 0;
	local id_2 = s2.sort or 0;
  	if id_1 < id_2 then
      	return true;
  	else
      	return false;
  	end
end

-- 返回兑换列表中的某一个item
ProductManager.getExchangeListItem = function( self, cid )
	if not cid then
		return;
	end

	for k,item in pairs(self.m_exchangeInfoList) do
		if tonumber( item.cid ) == tonumber( cid ) then
			return item;
		end
	end
end

--排序商品信息
ProductManager.sortProductInfo = function(s1,s2)
	local id_1 = s1.psort or 0;
	local id_2 = s2.psort or 0;
	if id_1 < id_2 then
	    return true;
	else
		return false;
	end
end

--根据金额排序
ProductManager.sortProductByPamount = function(s1,s2)
  	if s1.pamount < s2.pamount then
      	return true;
  	else
      	return false;
  	end
end

ProductManager.getExchangeHistoryInfoList = function(self)
	return self.m_exchangeHistoryInfoList;
end

--获取历史兑换商品列表
ProductManager.getExchangeHistoryList = function(self)

	local param_data = {};
	param_data.mid = PlayerManager.getInstance():myself().mid;
	param_data.username = "user_" .. param_data.mid;
	local signature = Joins(param_data, "");
    param_data.sig = md5_string(signature);
    SocketManager.getInstance():sendPack(PHP_CMD_REQUEST_EXCHANGE_HISTORY_LIST, param_data)

end
ProductManager.getExchangeHistoryListCallBack = function(self, isSuccess, data)
	DebugLog("XXXXXXXXXXXXXXXXXXXXXXXXXXXX")
	if isSuccess and data then
		local status = data.status ;
		--成功
		if status == 1 then
			self.m_exchangeHistoryInfoList = {};
			local packageforArray = data.data  and data.data or {};
			if packageforArray then
				for k, v in pairs(packageforArray) do
					local result = {};
					result.gname 		= v.gname ;
					result.image 		= v.img ;
					result.goodsdes		= v.goodsdes ;
					result.num			= tonumber(v.num );
					result.time 		= v.time ;
					result.status 		= v.status ;
					result.name 		= v.name ;
					result.phone 		= v.phone ;
					result.address 		= v.address ;
					self.m_exchangeHistoryInfoList[#self.m_exchangeHistoryInfoList + 1] = result;
				end
			end
		end
	end
	EventDispatcher.getInstance():dispatch(ProductManager.getExchanegeHistoryCallbackEvent);
end

ProductManager.sortRecommendProductInfo = function(s1,s2)
	local amount1 = s1.pamount or 0;
	local amount2 = s2.pamount or 0;
	if amount1 < amount2 then
	    return true;
	end
	return false;
end

--拉取当前版本和登录方式下的产品列表
ProductManager.getProductProxy = function(self)
	if self.nowGetProductProxy or #self.m_productList > 0 then  --正在获取商品列表
		DebugLog("【正在获取商品列表】或者 已经拉到了商品列表");
		return;
	end

	local url = (GameConstant.CommonUrl or kNullStringStr) .. PlatformConfig.ProductURL;

	self.m_productFlag = false;
	self.m_productSourceFlag = false;
	local param_data = {};
	param_data.mid = PlayerManager.getInstance():myself().mid;
	SocketManager.getInstance():sendPack(PHP_CMD_GET_PRODUCT_PROXY, param_data,url)
	self.nowGetProductProxy = true;
end

--产品接口回调(使用时需要手动调用解析)
ProductManager.getProductListCallBack = function(self, isSuccess, data)
	log( "ProductManager.getProductListCallBack" );
	self.nowGetProductProxy = false;
	if not isSuccess and not data then
	    return;
	end
	if isSuccess and data and data.status and tonumber(data.status ) == 1 then
		self.m_productListSource = data.data ;     --存放商品信息json源数据
		self.m_productSourceFlag = true;  --是否已经有商品源数据
		self:parseProductInfo();
		EventDispatcher.getInstance():dispatch(ProductManager.updateSceneEvent);
		if GameConstant.iosDeviceType>0 then
			native_to_java("ProductListCallBack", json.encode(data.data))
		end
	end
end

--解析商品信息
ProductManager.parseProductInfo = function(self)
	if not self.m_productSourceFlag then
		DebugLog("【还未获取到商品数据】");
		return;
	end
	self.m_productList = {};

	if type( self.m_productListSource ) ~= "table" then
		self.m_productListSource = {};
	end

	for k, v in pairs(self.m_productListSource) do
		repeat
			local product = {};
			product.id = GetNumFromJsonTable(v, "id");              --商品ID
			product.ptype = GetNumFromJsonTable(v, "ptype");        --商品类型 0：金币
			product.pamount = GetNumFromJsonTable(v, "pamount");    --应付款项
			product.pcoins = GetNumFromJsonTable(v, "pcoins");      --对等博雅币
			product.pchips = GetNumFromJsonTable(v, "pchips");      --对等金币
			product.pcard = GetNumFromJsonTable(v, "pcard");        --对等道具ID
			product.pnum = GetNumFromJsonTable(v, "pnum");          --数量
			product.pname = GameString.convert2Platform(GetStrFromJsonTable(v, "pname"));    --商品名称
			product.pimg = GetStrFromJsonTable(v, "pimg");    		--商品图片
			product.pdesc = GetStrFromJsonTable(v, "pdesc");    	--商品描述
			product.psort = GetNumFromJsonTable(v, "psort");      	--排序ID
            product.extra_present = GetNumFromJsonTable(v, "extra_present");--判断是否存在雀圣卡，周赛卡等信息
			if GameConstant.iosDeviceType>0 then
				product.iden = GetStrFromJsonTable(v, "iden");    	--iden
			end

			if product.pimg ~= "" then
				NativeManager.getInstance():downloadImage(product.pimg);--商品图片预下载
			end

			--ios 屏蔽
			if GameConstant.iosDeviceType>0 and GameConstant.iosPingBiFee then
				--ios 审核屏蔽的时候屏蔽掉998的商品
				if product.pamount<=648 then
					table.insert(self.m_productListAll , product );
					table.insert(self.m_productList, product);
				end
			else
					table.insert(self.m_productListAll , product );
					table.insert(self.m_productList, product);
			end
			until true;
	end
	table.sort( self.m_productList, ProductManager.sortProductInfo);
	self.m_productFlag = true;
	DebugLog("【商品数据解析完成】");
end

-- 破产和非进入场次充值推荐商品
ProductManager.getBankruptAndNotEventProduct = function ( self )
	DebugLog("非进入场次充值推荐商品入口 getBankruptAndNotEventProduct");
	if not GameConstant.suitableVipProduct then

		self:parseRecommendVipProduct();
		return nil;
	elseif #GameConstant.suitableVipProduct == 1 then
		return GameConstant.suitableVipProduct[1];
	else
		return GameConstant.isNewRecommendVipProduct[1];
	end
end

ProductManager.getVipRecommendProductByNextAmount = function(self,currentAmount)
	DebugLog("getVipRecommendProductByNextAmount" .. currentAmount)
	if not currentAmount or currentAmount == 0 then
		return;
	end
	mahjongPrint(GameConstant.isNewVipRecmmonedAmount)

	if GameConstant.isNewVipRecmmonedAmount then
		for k = 1 , #GameConstant.isNewVipRecmmonedAmount do
			--顺着来
			if not GameConstant.isLevelProductFlag then
				if GameConstant.isNewRecommendVipProduct[k].pamount == currentAmount and k+1 <= #GameConstant.isNewRecommendVipProduct then
					return GameConstant.isNewRecommendVipProduct[k+1];
				--到最大长度
				elseif GameConstant.isNewRecommendVipProduct[k].pamount == currentAmount and k+1 > #GameConstant.isNewRecommendVipProduct then
					GameConstant.isLevelProductFlag = true;
					return GameConstant.isNewRecommendVipProduct[k-1];
				end
			--倒着来
			else
				if GameConstant.isNewRecommendVipProduct[k].pamount  == currentAmount and k-1 > 0 then
					return GameConstant.isNewRecommendVipProduct[k-1];
				--到最大长度
				elseif GameConstant.isNewRecommendVipProduct[k].pamount == currentAmount and k-1 <= 0 then
					GameConstant.isLevelProductFlag = false;
					return GameConstant.isNewRecommendVipProduct[k+1];
				end
			end
		end

		if GameConstant.isNewRecommendVipProduct[1] then
			return GameConstant.isNewRecommendVipProduct[1];
		-- else
		-- 	return self:recommendProduct(currentAmount);
		end
	else
		GlobalDataManager.getInstance():getTuiJianProduct();
	end
end

ProductManager.getLevelRecommendProductByNextAmount = function(self,currentAmount)
DebugLog("ProductManager.getLevelRecommendProductByNextAmount :::" .. currentAmount)
	if not currentAmount or currentAmount == 0 then
		return;
	end
	if GameConstant.isNewLevelRecommendAmount then
		for k = 1 , #GameConstant.isNewLevelRecommendAmount do
			--顺着来
			if not GameConstant.isLevelProductFlag and GameConstant.isNewRecommendLevelProduct[k] then
				if GameConstant.isNewRecommendLevelProduct[k].pamount == currentAmount then
					return GameConstant.isNewRecommendLevelProduct[k+1];
				--到最大长度
				elseif k + 1 == #GameConstant.isNewLevelRecommendAmount then
					GameConstant.isLevelProductFlag = true;
					return GameConstant.isNewRecommendLevelProduct[k];
				end
			--倒着来
			else
				if GameConstant.isNewRecommendLevelProduct[k] and GameConstant.isNewRecommendLevelProduct[k].pamount  == currentAmount and k-1 > 0 then
					return GameConstant.isNewRecommendLevelProduct[k-1];
				--到最大长度
				elseif GameConstant.isNewRecommendLevelProduct[k] and GameConstant.isNewRecommendLevelProduct[k].pamount == currentAmount and k-1 <= 0 then
					GameConstant.isLevelProductFlag = false;
					return GameConstant.isNewRecommendLevelProduct[k+1];
				end
			end
		end

		if GameConstant.isNewRecommendVipProduct[1] then
			return GameConstant.isNewRecommendVipProduct[1];
		end
	else
		GlobalDataManager.getInstance():getTuiJianProduct();
	end
end

ProductManager.parseRecommendLevelProduct = function(self)
	if not self.m_productList or not GameConstant.isNewLevelRecommendAmount or #GameConstant.isNewLevelRecommendAmount < 1 then
		GlobalDataManager.getInstance():getTuiJianProduct();
		return;
	end

	GameConstant.isNewRecommendLevelProduct = {};

	for i=1,#GameConstant.isNewLevelRecommendAmount do
		for j=1,#self.m_productList do
			if self.m_productList[j].pamount and tonumber(self.m_productList[j].pamount) == tonumber(GameConstant.isNewLevelRecommendAmount[i]) then
				table.insert(GameConstant.isNewRecommendLevelProduct,self.m_productList[j]);
				break;
			end
		end
	end
end

ProductManager.parseRecommendVipProduct = function(self)
	if not self.m_productList then
		self:getProductList();
		return;
	end
--	if not GameConstant.isNewVipRecmmonedAmount or #GameConstant.isNewVipRecmmonedAmount < 1 then
--		GlobalDataManager.getInstance():getTuiJianProduct();
--		return;
--	end
	GameConstant.isNewRecommendVipProduct = {};

	if tonumber(PlayerManager.getInstance():myself().vipLevel) >= 0 then
		GameConstant.suitableVipProduct = {};
		DebugLog("vip-->")
		mahjongPrint(GameConstant.vip_tuiJianProduct)
		for k, v in pairs(GameConstant.vip_tuiJianProduct) do
			DebugLog("PlayerManager.getInstance():myself().vipLevel)" .. PlayerManager.getInstance():myself().vipLevel)
            DebugLog(k);
			if(tonumber(k) == tonumber(PlayerManager.getInstance():myself().vipLevel)) then
				local product = self:getProductByPamount(tonumber(v ));
				DebugLog(product and "有" or "nil")
				if product then
					table.insert(GameConstant.suitableVipProduct,product);
					break;
				end
			end
		end
		mahjongPrint(GameConstant.suitableVipProduct)
	end

	for i=1,#GameConstant.isNewVipRecmmonedAmount do
		for j=1,#self.m_productList do
			if self.m_productList[j].pamount and tonumber(self.m_productList[j].pamount) == tonumber(GameConstant.isNewVipRecmmonedAmount[i]) then
				table.insert(GameConstant.isNewRecommendVipProduct,self.m_productList[j]);
				break;
			end
		end
	end
end

--通过场次来推荐商品
ProductManager.getRecommendProductByEvent = function ( self , roomlevel )
	if not self:getProductList() or not roomlevel then
		return  nil;
	end
	local product = self:recommendProduct(0);

	local amount = product and product.pamount or 6;
	if GameConstant.level_tuiJianProduct then
		for k , v in pairs(GameConstant.level_tuiJianProduct) do
			if tonumber(k) == roomlevel then
				amount = tonumber(v ) or amount;
				break;
			end
		end
	end

	if DEBUGMODE == 1 then
		Banner.getInstance():showMsg("商品推荐 场次level:" .. roomlevel ..  "  推荐金额:" .. amount );
	end
	return self:getProductByPamount(amount);
end


--推荐快捷支付商品推荐算法
ProductManager.recommendProduct = function (self , money)
	if not self:getProductList() then
		return nil;
	end
	--找出最相近的商品
	return self:getNearestProduct(money or 0);
end

--找最接近的商品
ProductManager.getNearestProduct = function ( self , money, flag )
	local reslut = nil;
	local maxProduct = nil;
	for k,v in pairs(self.m_productList) do
		--该商品是金币
		if kTypeMoney == v.ptype then
			if not maxProduct or (v.pchips > maxProduct.pchips) then
				maxProduct = v;
			end
			--找到最接近所需金币的商品
			if v.pchips >= money and (not reslut or (v.pamount <= reslut.pamount)) then
				reslut = v;
			end
		end
	end
	if not reslut then
		reslut = maxProduct;
	end
	return reslut;
end

ProductManager.getProductByPcard = function(self)
	if not self.m_productList then
		return;
	end
	for i = 1,#self.m_productList do
		if tonumber(self.m_productList[i].pcard) == 1000 then
			return self.m_productList[i];
		end
	end
	return nil;
end

function ProductManager:onCacheDataHttpListener( httpCmd, data, handleData )
	log( "ProductManager:onCacheDataHttpListener httpCmd = "..httpCmd );
	local isSuccess = (data ~= nil);
	if ProductManager.cacheDataHttpCallBackFuncMap[httpCmd] then
		ProductManager.cacheDataHttpCallBackFuncMap[httpCmd]( self, isSuccess, data );
	end
end

--接口回调分发机制
ProductManager.onHttpRequestsListenster = function ( self, param, cmd, isSuccess,... )
	if self.httpRequestsCallBackFuncMap[cmd] then
		self.httpRequestsCallBackFuncMap[cmd](self,isSuccess,param,...)
	end
end

--回调函数映射表
ProductManager.httpRequestsCallBackFuncMap =
{

	[PHP_CMD_REQUEST_EXCHANGE_HISTORY_LIST] = ProductManager.getExchangeHistoryListCallBack

};


-- 缓存处理函数
ProductManager.cacheDataHttpCallBackFuncMap = {
	[PHP_CMD_REQUEST_EXCHANGE_LIST] 	= ProductManager.getExchangeListCallBack,
	[PHP_CMD_GET_PRODUCT_PROXY] 		= ProductManager.getProductListCallBack,
};
