--[[
	className    	     :  WDJUnicomPay
	Description  	     :  支付类-子类(联通支付)
	last-modified-date   :  Dec.23 2013
	create-time 	     :  Oct.29 2013
	last-modified-author :  ClarkWu
	create-author        :  ClarkWu
]]
require("MahjongPay/Pay/BasePay");

WDJUnicomPay = class(BasePay);

WDJUnicomPay.ctor = function(self)
	self.m_payId = "2000";   -- 支付id
	self.m_pmode = "437";   -- pmode
	self.m_text = "豌豆荚联通支付";

	self.m_payCode = {};
	self.m_payCode["2"]="150525111414|9010792216420150525150036513300002";
	self.m_payCode["6"]="150525111418|9010792216420150525150036513300006";
	self.m_payCode["10"]="150525111422|9010792216420150525150036513300010";
	self.m_payCode["20"]="150525111432|9010792216420150525150036513300020";
	self.m_payCode["30"]="150525111442|9010792216420150525150036513300030";
	self.m_isSms = kUnicomSmsPay;
end

