--[[
	className    	     :  OppoPay
	Description  	     : JiuYou-子类(jiuyou支付)
	last-modified-date   :  Dec.23 2013
	create-time 	     :  Oct.29 2013
	last-modified-author :  ClarkWu
	create-author        :  ClarkWu
]]
require("MahjongPay/Pay/BasePay");

JiuYouPay = class(BasePay);

JiuYouPay.ctor = function(self)
	self.m_payId = "1030";   -- 支付id
	self.m_pmode = "617";   -- pmode
	self.m_payCode = nil; -- 计费点
	self.m_text = "九游支付";
	self.m_isSms = kThirdPay;
end