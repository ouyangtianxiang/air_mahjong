--[[
	AnZhiclassName    	     :  安智MMPay
	Description  	     :  支付类-子类(安智MM支付)
	last-modified-date   :  Dec.23 2013
	create-time 	     :  Oct.29 2013
	last-modified-author :  ClarkWu
	create-author        :  ClarkWu
]]
require("MahjongPay/Pay/BasePay");

AnZhiMMPay = class(BasePay);

AnZhiMMPay.ctor = function(self)
	self.m_payId = "1031";   -- 支付id
	self.m_pmode = "218";   -- pmode
	self.m_text = "安智MM支付";
	self.m_payCode = {};
	self.m_payCode["2"]		="30000900032402";
	self.m_payCode["6"]		="30000900032403";
	self.m_payCode["10"]	="30000900032404";
	self.m_payCode["20"]	="30000900032406";
	self.m_payCode["30"]	="30000900032405";
	self.m_isSms = kMobileSmsPay;
end
