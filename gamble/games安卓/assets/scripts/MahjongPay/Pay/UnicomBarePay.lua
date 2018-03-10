--[[
	className    	     :  UnicomBarePay
	Description  	     :  支付类-子类(联通裸码支付)
	last-modified-date   :  Dec.23 2013
	create-time 	     :  Oct.29 2013
	last-modified-author :  ClarkWu
	create-author        :  ClarkWu
]]
require("MahjongPay/Pay/BasePay");

UnicomBarePay = class(BasePay);

UnicomBarePay.ctor = function(self)
	self.m_payId = "19";   -- 支付id
	self.m_pmode = "298";   -- pmode
	self.m_text = "联通裸码支付";
	self.m_payCode = {};
	self.m_payCode["2"]   = "bbb";
	self.m_payCode["6"]   = "bbc";
	self.m_payCode["10"]  = "bbd";
	self.m_payCode["20"]  = "bbf";
	self.m_payCode["30"]  = "bbg";
	self.m_payCode["10b"] = "bbh";
	self.m_payCode["30b"] = "bbj";
	self.m_isSms = kUnicomSmsPay;
end

