--[[
	className    	     :  UnicomPay
	Description  	     :  支付类-子类(联通支付)
	last-modified-date   :  Dec.23 2013
	create-time 	     :  Oct.29 2013
	last-modified-author :  ClarkWu
	create-author        :  ClarkWu
]]
require("MahjongPay/Pay/BasePay");

UnicomPay = class(BasePay);

UnicomPay.ctor = function(self)
	self.m_payId = "5";   -- 支付id
	self.m_pmode = "109";   -- pmode
	self.m_text = "联通支付";
	self.m_payCode = {};
	self.m_payCode["2"]="130426000651|90349971220130426160142944800001";
	self.m_payCode["6"]="130426000652|90349971220130426160142944800002";
	self.m_payCode["10"]="130426000653|90349971220130426160142944800003";
	self.m_payCode["20"]="140326030379|90349971220130426160142944800005";
	self.m_payCode["30"]="140326030380|90349971220130426160142944800006";
	self.m_isSms = kUnicomSmsPay;
end

