--[[
	className    	     :  MobileOnlyPay
	Description  	     :  支付类-子类(基地支付)
	last-modified-date   :  Dec.23 2013
	create-time 	     :  Oct.29 2013
	last-modified-author :  ClarkWu
	create-author        :  ClarkWu
]]
require("MahjongPay/Pay/BasePay");

MobileOnlyPay = class(BasePay);

MobileOnlyPay.ctor = function(self)
	self.m_payId = "2012";   -- 支付id
	self.m_pmode = "31";   -- pmode
	self.m_text = "移动基地联运支付";
	self.m_payCode = {};
	self.m_payCode["2"] 	= "001";
	self.m_payCode["6"] 	= "002";
	self.m_payCode["1"] 	= "005";
	self.m_payCode["9b"] 	= "003";
	self.m_payCode["29b"] 	= "004";
	self.m_payCode["5"] 	= "006";
	self.m_payCode["10"] 	= "007";
	self.m_payCode["20"] 	= "008";
	self.m_payCode["30"] 	= "009";
	self.m_payCode["01"] 	= "010";
	self.m_payCode["5i"] 	= "011";
	self.m_isSms = kMobileSmsPay;
end

