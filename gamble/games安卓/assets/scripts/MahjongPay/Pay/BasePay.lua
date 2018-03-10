--[[
	className    	     :  BasePay
	Description  	     :  To wrap all the methods of login,this is an abstract class.
				    	    which duplicate this method,must implement its all methods.
	last-modified-date   :  Nov.29 2013
	create-time 	   	 :  Oct.29 2013
	last-modified-author :  ClarkWu
	create-author        :  ClarkWu
]]
BasePay = class();

--[[
	function name	   : BasePay.ctor
	description  	   : Construct a class.
	param 	 	 	   : self
	last-modified-date : Nov.29 2013
	create-time  	   : Oct.29 2013
]]
BasePay.ctor = function (self)
	self.m_payId = "";   -- 支付id
	self.m_pmode = "";   -- pmode
	self.m_text = "";	 -- 当前的支付方式名称
	self.m_payCode = nil; -- 计费点
	self.m_isSms = kThirdPay; -- 是短代还是第三方 短代是什么短代
	EventDispatcher.getInstance():register(SocketManager.s_phpMsg, self, self.onPhpMsgResponse);
end

--[[
	function name	   : BasePay.dtor
	description  	   : Destructor a class.
	param 	 	 	   : self
	last-modified-date : Nov.29 2013
	create-time  	   : Oct.29 2013
]]
BasePay.dtor = function (self)
	EventDispatcher.getInstance():unregister(SocketManager.s_phpMsg, self, self.onPhpMsgResponse);
	self.m_pmode = "";   -- pmode
	self.m_text = "";	 -- 当前的支付方式名称
	self.m_payCode = nil; -- 计费点
	self.m_isSms = false; -- 是否是短信的计费
end

--[[
	function name	   : BasePay.login
	description  	   : To login.For it's son class,it must duplicate this class .
	param 	 	 	   : self
	last-modified-date : Nov.29 2013
	create-time  	   : Oct.29 2013
]]
BasePay.pay = function ( self,product)
	if not product then 
		return;
	end

	self.m_product = product;
	local param = {};
	param.id = product.id or "";
	param.appid = PlatformFactory.curPlatform.getLoginAppId() or "";
	param.pamount = product.pamount or 0;
	param.pname = product.pname or "";
	param.ptype = product.ptype or "";

	if self.m_payId == PlatformConfig.WebPay then 
		local param  = {};
		param.payType = self.m_payId;
		param.pamount = self.m_product.pamount;

		param.productName = ( self.m_product.pname or 0 ..CreatingViewUsingData.commonData.coinStr);

		local otherParam = self:concatOtherParam(data);

		if otherParam then 
			for k, v in pairs(otherParam) do 
				param[k] = v;
			end
		end

		if isPlatform_Win32() then 
			--弹出模拟支付框
			mahjongPrint(param);
			local text = "方式:" .. self.m_text .. " 金额  " .. param.pamount .. "元"  .. "  商品名字: " .. param.productName .. "  计费码:" .. (param.collideCode or "无计费码") ;
				
			if otherParam then 
				for k,v in pairs(otherParam) do 
					text = text .. "  其他参数:" .. k .. ":" .. v;
				end
			end
			local view = PopuFrame.showNormalDialog( "支付提示", text, GameConstant.curGameSceneRef, nil,nil,true, false,"确定");

			view.closeBtn:setOnClick(self, function ( self )
				PayConfigDataManager.getInstance():cancelPay(self.m_payId);
				view:hideWnd();
			end
			);

			view:setConfirmCallback(self, function ( self )
				PayConfigDataManager.getInstance():confirmPay(self.m_payId);
			end);

			view:setCallback(view, function ( view, isShow )
				if not isShow then
					
				end
			end);

		else 
			self:toExecuteJava(param);
		end
		return;
	end
	self:onRequestPayOrderPHP(param);

end

---------------------------------------------------------------PHP  Request--------------------------------------------------------------------------------------

--[[
	function name      : BasePay.OnRequestLoginPHP
	description  	   : Login Request.
	param 	 	 	   : param 		Table [
											id 		-- 商品id
											appid   -- 商品对应的appid
											pamount -- 金额
											ptype 	-- 金币还是博雅币
									]
	last-modified-date : Nov.29 2013
	create-time		   : Oct.29 2013
]]
BasePay.onRequestPayOrderPHP = function (self,param)
	if not param then
		return;
	end
	local url = GameConstant.CommonUrl .. PlatformConfig.ORDERURL;
	local param_data = {};
	param_data.id = param.id;
	param_data.sid =  7;
	param_data.pmode = self.m_pmode or "";
	param_data.appid = param.appid or "0"; -- 商品的appid
	param_data.pamount = param.pamount or "0"; -- 商品金额
	if tonumber(param_data.pmode) == 109 or tonumber(param_data.pmode) == 437 then
		param_data.appname = PlatformFactory.curPlatform:getApplicationShareName() or "";	
		param_data.feename = param.pname or "";
		param_data.mac = string.gsub(GameConstant.macAddress,":","")
		if mac == "" then 
			param_data.mac = "00000000";
		end

		param_data.imei = GameConstant.imei2;
		param_data.appversion = GameConstant.Version;
		local pcode = self.m_payCode[param_data.pamount .. ""] or "";
		local num = string.find( pcode,"|");
		if num then 
			local feeid = string.sub( pcode,num+1) or 0;
			param_data.serviceid = feeid;
			local pcode_length = string.len(feeid);
			if pcode_length > 3 then 
				local extra_appId = string.sub(feeid,1,pcode_length -3);
				param_data.ext_appid = extra_appId or "";
			end
		end
		param_data.channelid = PlatformFactory.curPlatform:getUnicomChannelId() or "";

	end

	SocketManager.getInstance():sendPack(PHP_CMD_CREATE_ORDER,param_data,url);
end

--[[
	请求支付场景上报接口
	param : data  Table [ scene_id    场景id
						  order_id    订单号
						  party_type  一级场次level
						  party_level 二级场次level
						  basechip 	  底注
						  bankrupt 	  破产
						  pcoins 	  博雅币
						  pchips 	  金币
						  pamount 	  币种数量
				]

]]
BasePay.onRequestPayScenePHP = function(self,data)
	if not data then 
		return ;
	end
	local param = {};
	param.scene_id = data.scene_id or 0; -- 场景id
	param.sitemid = PlayerManager.getInstance():myself().mid or ""; -- 平台用户id
	param.order_id = data.order_id or ""; -- 订单号
	param.party_type = data.party_type or 0; -- 一级场次level
	param.party_level = data.party_level or 0; -- 二级场次level
	param.basechip = data.basechip or 0; -- 底注
	param.bankrupt = data.bankrupt or 0; -- 是否破产
	param.pmode = self.m_pmode ; 
	param.pcoins = data.pcoins or 0; --博雅币
	param.pchips = data.pchips or 0; -- 金币
	param.current_type = 1; --人民币
	param.current_num = data.pamount or 0; --币种数量

	SocketManager.getInstance():sendPack(PHP_CMD_REPORT_ORDER,param);
end

--请求支付成功接口
BasePay.onRequestSuccessPHP = function(self)
	if not self.m_orderId then 
		return ; 
	end
	local param = {};
	param.order = self.m_orderId or "";
	param.pmode = self.m_pmode ;
	SocketManager.getInstance():sendPack(PHP_CMD_REPORT_PAY_PRODUCT_INFO,param_data);
end

--[[
	function name	   : BasePay.callEvent
	description  	   : For it's son class,it must duplicate this class .
	param 	 	 	   : self
	last-modified-date : Nov.29 2013
	create-time		   : Nov.29 2013
]]
BasePay.callEvent = function(self)
	
end

--[[
	function name      : BasePay.onPayHttpRequestsListenster
	description  	   : To send http request.
	param 	 	 	   : self
					   : command  		 Table 	   -- PHP command which from HttpModule.
	last-modified-date : Nov.29 2013
	create-time		   : Oct.29 2013
]]
BasePay.onPhpMsgResponse = function(self, param, cmd, isSuccess, ...)
	if self.httpRequestsCallBackFuncMap[cmd] then
     	self.httpRequestsCallBackFuncMap[cmd](self,isSuccess,param,...);
	end 
end

 --[[
	function name      : BasePay.createOrderCallBack
	description  	   : For it's son class,it must duplicate this class .
	param 	 	 	   : self
					   : isSuccess      Boolean   -- The value of the php return,if Success returns true,it expresses success,and false,it express failed.
					   : data           Table     -- The data of PHP command returns.
	last-modified-date : Nov.29 2013
	create-time		   : Oct.29 2013
]]
BasePay.createOrderCallBack = function (self, isSuccess, data)
	local orderId = data.data.ORDER
	if (tostring(GameConstant.orderId) or "") == tostring(orderId) then return end  --防止重复调用
	GameConstant.orderId = data.data.ORDER
	if isSuccess then
		DebugLog("createOrderCallBack")
		if tonumber(data.status) == 1 then
			PayController:createOrderCallback(self:getTableData(data.data))
			-- self.m_orderId = data.data.ORDER or "";

			-- local param  = {};
			-- param.payType = self.m_payId;
			-- param.orderId = self.m_orderId;
			-- param.pamount = self.m_product.pamount;
			-- if self.m_payCode then 
			-- 	param.collideCode = self.m_payCode[param.pamount .. ""];
			-- end

			-- mahjongPrint(self.m_product)

			-- -- if kNumZero ~= tonumber(self.m_product.pcoins) then -- 博雅币
			-- -- 	param.productName = (self.m_product.pcoins or 0) ..CreatingViewUsingData.commonData.boyaaStr;
		
			-- -- elseif kNumZero ~= tonumber(self.m_product.pchips) then -- 金币
			-- 	param.productName = ( self.m_product.pname or 0 ..CreatingViewUsingData.commonData.coinStr);
			-- -- end

			-- local otherParam = self:concatOtherParam(data);

			-- if otherParam then 
			-- 	for k, v in pairs(otherParam) do 
			-- 		param[k] = v;
			-- 	end
			-- end

			-- if isPlatform_Win32() then 
			-- 	--弹出模拟支付框
			-- 	mahjongPrint(param);
			-- 	local text = "方式:" .. self.m_text .. "  订单号: " .. param.orderId .. " 金额  " .. param.pamount .. "元"  .. "  商品名字: " .. param.productName .. "  计费码:" .. (param.collideCode or "无计费码") ;
				
			-- 	if otherParam then 
			-- 		for k,v in pairs(otherParam) do 
			-- 			text = text .. "  其他参数:" .. k .. ":" .. v;
			-- 		end
			-- 	end
			-- 	local view = PopuFrame.showNormalDialog( "支付提示", text, GameConstant.curGameSceneRef, nil,nil,true, false,"确定");

			-- 	view.closeBtn:setOnClick(self, function ( self )
			-- 		PayConfigDataManager.getInstance():cancelPay(self.m_payId);
			-- 		view:hideWnd();
			-- 	end
			-- 	);

			-- 	view:setConfirmCallback(self, function ( self )
			-- 		PayConfigDataManager.getInstance():confirmPay(self.m_payId);
			-- 	end);

			-- 	view:setCallback(view, function ( view, isShow )
			-- 		if not isShow then
			-- 			
			-- 		end
			-- 	end);

			-- else 
			-- 	self:toExecuteJava(param);
			-- end

			-- if not self.m_product.payScene then 
			-- 	return;
			-- end
			
			-- local payScene = {};
			-- payScene.scene_id = self.m_product.payScene.scene_id;
			-- payScene.order_id = param.orderId or "";
			-- payScene.party_type = self.m_product.payScene.party_type ;
			-- payScene.party_level = self.m_product.payScene.party_level;
			-- payScene.basechip = self.m_product.payScene.basechip;
			-- payScene.bankrupt = self.m_product.payScene.bankrupt;
			-- payScene.pcoins = self.m_product.payScene.pcoins;
			-- payScene.pchips = self.m_product.payScene.pchips;
			-- payScene.pamount = self.m_product.payScene.pamount;
			-- self:onRequestPayScenePHP(payScene);					 
		end
	end
end

--http转lua table
function BasePay:getTableData( orderTable )
	local tem = {}
	for k, v in pairs(orderTable) do 
		tem[k] = orderTable[k]
	end
	return tem
end

BasePay.concatOtherParam = function(self,data)
end

BasePay.toExecuteJava = function(self,param)
	if not param then 
		return;
	end
	param.pluginId = PluginUtil:convertPayId2Plugin(param.payType or 0)
	native_to_java(kMutiPay, json.encode(param));
end

--场景上报
BasePay.reportOrderSceneCallBack = function(self,isSuccess,data)
	
end

--成功订单上报
BasePay.reportPayProductInfoCallBack = function(self,isSuccess,data) 
	
end

BasePay.httpRequestsCallBackFuncMap =
{
	[PHP_CMD_CREATE_ORDER] = BasePay.createOrderCallBack,
	[PHP_CMD_REPORT_ORDER] = BasePay.reportOrderSceneCallBack,
	[PHP_CMD_REPORT_PAY_PRODUCT_INFO] = BasePay.reportPayProductInfoCallBack,

};


