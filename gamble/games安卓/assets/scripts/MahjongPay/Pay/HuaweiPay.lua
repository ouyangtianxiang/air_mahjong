--[[
	className    	     :  HuaweiPay
	Description  	     :  支付类-子类(huawei支付)
	last-modified-date   :  Dec.23 2013
	create-time 	     :  Oct.29 2013
	last-modified-author :  ClarkWu
	create-author        :  ClarkWu
]]
require("MahjongPay/Pay/BasePay");

HuaweiPay = class(BasePay);

HuaweiPay.ctor = function(self)
	self.m_payId = "1103";   -- 支付id
	self.m_pmode = "274";   -- pmode
	self.m_payCode = nil; -- 计费点
	self.m_text = "Huawei支付";
	self.m_isSms = kThirdPay;
end

HuaweiPay.concatOtherParam = function(self,data)
	local param = {};
	param.desc = self.m_product.pdesc or "";
	return param;
end