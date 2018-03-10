--[[
	className    	     :  YinLianPay
	Description  	     :  支付类-子类(银联支付)
	last-modified-date   :  Dec.23 2013
	create-time 	     :  Oct.29 2013
	last-modified-author :  ClarkWu
	create-author        :  ClarkWu
]]
require("MahjongPay/Pay/BasePay");

YinLianPay = class(BasePay);

YinLianPay.ctor = function(self)
	self.m_payId = "6";   -- 支付id
	self.m_pmode = "198";   -- pmode
	self.m_payCode = nil; -- 计费点
	self.m_text = "银联支付";
	self.m_isSms = kThirdPay;
end

YinLianPay.concatOtherParam = function(self,data)
	local param = {};
	param.tn = data.data.tn
	return param;
end