--[[
	className    	     :  MMPay
	Description  	     :  支付类-子类(MM支付)
	last-modified-date   :  Dec.23 2013
	create-time 	     :  Oct.29 2013
	last-modified-author :  ClarkWu
	create-author        :  ClarkWu
]]
require("MahjongPay/Pay/BasePay");

MMPay = class(BasePay);

MMPay.ctor = function(self)
	self.m_payId = "4";   -- 支付id
	self.m_pmode = "218";   -- pmode
	self.m_text = "MM支付";
	self.m_payCode = {};
	self.m_payCode["0.01"]	="30000821997901";
	self.m_payCode["0.1"]	="30000821997902";
	self.m_payCode["0.5"]	="30000821997903";
	self.m_payCode["1"]		="30000821997904";
	self.m_payCode["2"]		="30000821997905";
	self.m_payCode["6"]		="30000821997906";
	self.m_payCode["10"]	="30000821997907";
	self.m_payCode["15"]	="30000821997908";
	self.m_payCode["20"]	="30000821997909";
	self.m_payCode["30"]	="30000821997910";
	self.m_isSms = kMobileSmsPay;
end

-- MMPay.concatOtherParam = function(self,data)
-- 	local param = {};
-- 	param.orderId = string.sub(self.m_orderId,string.len(self.m_orderId)-15,string.len(self.m_orderId));
-- 	return param;
-- end