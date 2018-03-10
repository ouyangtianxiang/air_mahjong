--[[
	className    	     :  WDJEGamePay
	Description  	     :  支付类-子类(爱游戏支付)
	last-modified-date   :  Dec.23 2013
	create-time 	     :  Oct.29 2013
	last-modified-author :  ClarkWu
	create-author        :  ClarkWu
]]
require("MahjongPay/Pay/BasePay");

WDJEGamePay = class(BasePay);

WDJEGamePay.ctor = function(self)
	self.m_payId = "1019";   -- 支付id
	self.m_pmode = "438";   -- pmode
	self.m_text = "豌豆荚爱游戏支付";
	self.m_payCode = {};
	self.m_payCode["2"]	= "2";
	self.m_payCode["6"]	= "6";
	self.m_payCode["10"]= "10";
	self.m_payCode["20"]= "20";
	self.m_payCode["30"]= "30";
	self.m_isSms = kTelecomSmsPay;
end

