--[[
	className    	     :  MobileBarePay
	Description  	     :  支付类-子类(基地裸码支付)
	last-modified-date   :  Dec.23 2013
	create-time 	     :  Oct.29 2013
	last-modified-author :  ClarkWu
	create-author        :  ClarkWu
]]
require("MahjongPay/Pay/BasePay");

MobileBarePay = class(BasePay);

MobileBarePay.ctor = function(self)
	self.m_payId = "3";   -- 支付id
	self.m_pmode = "292";   -- pmode
	self.m_text = "基地裸码支付";
	self.m_payCode = {};
	self.m_payCode["2"]="006043201002";
	self.m_payCode["6"]="006043201004";
	self.m_payCode["10"]="006043201006";
	self.m_isSms = kMobileSmsPay;
end

