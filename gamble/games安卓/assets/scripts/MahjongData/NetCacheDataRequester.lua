-- NetCacheDataRequester.lua
-- author: OnlynightZhang
-- desp: 缓存网络数据请求器

NetCacheDataRequester = {};

--PHP_CMD_REQUEST_NEW_HALL_CONFIG
function NetCacheDataRequester.requestNewHallConfig(  netCacheDataManager )
	--获取大厅配置
	local param_data = {};
	local lastTime = g_DiskDataMgr:getAppData(kHallConfigDictKey_Value.HallConfigTime, 1)
	if lastTime < 1 then
		lastTime = 1;
	end
	param_data.time = lastTime or 1;
	SocketManager.getInstance():sendPack( PHP_CMD_REQUEST_NEW_HALL_CONFIG, param_data)
end

-- 拉取破产补助
function NetCacheDataRequester.getBankraptcyConfig(  netCacheDataManager )
	SocketManager.getInstance():sendPack( PHP_CMD_GET_BANKRAPTCY_CONFIG, {})
end
--PHP_CMD_REQUEST_NOTICE_INFO
function NetCacheDataRequester.requestNoticeInfo(  netCacheDataManager )
	local param_data = {};
	param_data.mid = PlayerManager.getInstance():myself().mid;
	SocketManager.getInstance():sendPack( PHP_CMD_REQUEST_NOTICE_INFO, param_data)
end

--PHP_CMD_REQUEST_EXCHANGE_LIST
function NetCacheDataRequester.requestExchangeList( netCacheDataManager)
	local param_data = {};
	param_data.mid = PlayerManager.getInstance():myself().mid;
	param_data.username = "user_" .. param_data.mid;
	SocketManager.getInstance():sendPack( PHP_CMD_REQUEST_EXCHANGE_LIST, param_data)
end
--PHP_CMD_GET_PRODUCT_PROXY
function NetCacheDataRequester.getProductProxy(   netCacheDataManager )
	local pm = ProductManager.getInstance();
	-- if pm.nowGetProductProxy or #pm.m_productList > 0 then  --正在获取商品列表
	-- 	DebugLog("【正在获取商品列表】或者 已经拉到了商品列表");
	-- 	return;
	-- end
	local url = (GameConstant.CommonUrl or kNullStringStr) .. PlatformConfig.ProductURL; 
	-- url = url.."&veil=1"; -- 拉取测试商品
	
	pm.m_productFlag = false;
	pm.m_productSourceFlag = false;
	local param_data = {};
	param_data.mid = PlayerManager.getInstance():myself().mid;

	SocketManager.getInstance():sendPack( PHP_CMD_GET_PRODUCT_PROXY, param_data, url)

	pm.nowGetProductProxy = true;
end



--PHP_CMD_REQUEST_DETAIL_SIGN_INFO
function NetCacheDataRequester.requestSignInfo(  netCacheDataManager )
	netCacheDataManager:dispatchEvent( PHP_CMD_REQUEST_DETAIL_SIGN_INFO );
end
--PHP_CMD_REQUEST_FIRST_CHARGE_DATA
function NetCacheDataRequester.requestFirstChargeData(  netCacheDataManager )
    DebugLog("[NetCacheDataRequester]:requestFirstChargeData");
	netCacheDataManager:dispatchEvent( PHP_CMD_REQUEST_FIRST_CHARGE_DATA );
end
--PHP_CMD_REQUEST_SECOND_CONFIRM_WND_TEXT
function NetCacheDataRequester.requestSecondConfirmWndText(  netCacheDataManager )
	SocketManager.getInstance():sendPack( PHP_CMD_REQUEST_SECOND_CONFIRM_WND_TEXT, {} )
end




