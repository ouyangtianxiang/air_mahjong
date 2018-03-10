--[[
	className    	     :  NewEgamePay
	Description  	     :  支付类-子类(爱游戏支付)
	last-modified-date   :  Dec.23 2013
	create-time 	     :  Oct.29 2013
	last-modified-author :  ClarkWu
	create-author        :  ClarkWu
]]
require("MahjongPay/Pay/BasePay");

NewEgamePay = class(BasePay);

NewEgamePay.ctor = function(self)
	self.m_payId = "1020";   -- 支付id
	self.m_pmode = "34";   -- pmode
	self.m_text = "爱游戏联运支付";
	self.m_payCode = {};
	self.m_payCode["2"]	= "2";
	self.m_payCode["6"]	= "6";
	self.m_payCode["10"]= "10";
	self.m_payCode["20"]= "20";
	self.m_payCode["30"]= "30";
	self.m_isSms = kThirdPay;
end

