--[[
	className    	     :  UnicomBareThirdPay
	Description  	     :  支付类-子类(联通第三套裸码支付)
	last-modified-date   :  Dec.23 2013
	create-time 	     :  Oct.29 2013
	last-modified-author :  ClarkWu
	create-author        :  ClarkWu
]]
require("MahjongPay/Pay/BasePay");

UnicomBareThirdPay = class(BasePay);

UnicomBareThirdPay.ctor = function(self)
	self.m_payId = "23";   -- 支付id
	self.m_pmode = "308";   -- pmode
	self.m_payCode = {};
	self.m_text = "联通第三套裸码支付";
	self.m_payCode["2"]="000005000195";
	self.m_payCode["6"]="000005000197";
	self.m_payCode["10"]="000005000199";
	self.m_payCode["20"]="000005000202";
	self.m_payCode["30"]="000005000204";
	self.m_payCode["10b"]="000005000199";
	self.m_payCode["30b"]="000005000204";
	self.m_isSms = kUnicomSmsPay;
end

