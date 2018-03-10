--[[
	className    	     :  WDJMMPay
	Description  	     :  支付类-子类(豌豆荚MM支付)
	last-modified-date   :  Dec.23 2013
	create-time 	     :  Oct.29 2013
	last-modified-author :  ClarkWu
	create-author        :  ClarkWu
]]
require("MahjongPay/Pay/BasePay");

WDJMMPay = class(BasePay);

WDJMMPay.ctor = function(self)
	self.m_payId = "1017";   -- 支付id
	self.m_pmode = "218";   -- pmode
	self.m_text = "豌豆荚MM支付";
	self.m_payCode = {};
	self.m_payCode["2"]		="30000923192501";
	self.m_payCode["6"]		="30000923192502";
	self.m_payCode["10"]	="30000923192503";
	self.m_payCode["20"]	="30000923192504";
	self.m_payCode["30"]	="30000923192505";
	self.m_isSms = kMobileSmsPay;
end