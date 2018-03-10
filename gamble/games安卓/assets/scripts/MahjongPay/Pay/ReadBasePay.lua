--[[
	className    	     :  ReadBasePay
	Description  	     :  支付类-子类(阅读基地，联通第二套裸码支付)
	last-modified-date   :  Dec.23 2013
	create-time 	     :  Oct.29 2013
	last-modified-author :  ClarkWu
	create-author        :  ClarkWu
]]
require("MahjongPay/Pay/BasePay");

ReadBasePay = class(BasePay);

ReadBasePay.ctor = function(self)
	self.m_payId = "25";   -- 支付id
	self.m_pmode = "351";   -- pmode
	self.m_text = "阅读基地，联通第二套裸码支付";
	self.m_payCode = {};
	self.m_payCOde["1"]  ="23000001";
	self.m_payCOde["2"]  ="23000002";
	self.m_payCOde["5"]  ="23000005";
	self.m_payCOde["6"]  ="23000006";
	self.m_payCOde["10"] ="23000010";
	self.m_payCOde["15"] ="23000011";
	self.m_payCOde["20"] ="23000012";
	self.m_payCOde["30"] ="23000013";
	self.m_payCOde["50"] ="23000014";
	self.m_isSms = kUnicomSmsPay;
end

