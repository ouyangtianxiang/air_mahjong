--[[
	className    	     :  WDJPay
	Description  	     :  支付类-子类(豌豆荚MM支付)
	last-modified-date   :  Dec.23 2013
	create-time 	     :  Oct.29 2013
	last-modified-author :  ClarkWu
	create-author        :  ClarkWu
]]
require("MahjongPay/Pay/BasePay");

WDJPay = class(BasePay);

WDJPay.ctor = function(self)
	self.m_payId = "1014";   -- 支付id
	self.m_pmode = "235";   -- pmode
	self.m_text = "豌豆荚支付";
	self.m_isSms = kThirdPay;
end

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
WDJPay.onRequestPayOrderPHP = function (self,param)
	if not param then
		return;
	end
	local url = GameConstant.CommonUrl .. PlatformConfig.ORDERURL;
	local param_data = {};
	param_data.id = param.id;
	param_data.sid =  7;
	param_data.pmode = self.m_pmode or "";
	param_data.appid = param.appid or "0"; -- 商品的appid
	param_data.pamount = param.pamount * 0.7 or "0"; -- 商品金额

	HttpModule.getInstance():execute(HttpModule.s_cmds.createOrder,param_data,self.m_event,url);
end

WDJPay.concatOtherParam = function(self,data)
	local param = {};
	param.pamount = data.data.PAMOUNT
	return param;
end
