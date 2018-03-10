--[[
	className    	     :  OppoPay
	Description  	     :  支付类-子类(Oppo支付)
	last-modified-date   :  Dec.23 2013
	create-time 	     :  Oct.29 2013
	last-modified-author :  ClarkWu
	create-author        :  ClarkWu
]]
require("MahjongPay/Pay/BasePay");

OppoPay = class(BasePay);

OppoPay.ctor = function(self)
	self.m_payId = "1001";   -- 支付id
	self.m_pmode = "215";   -- pmode
	self.m_payCode = nil; -- 计费点
	self.m_text = "Oppo支付";
	self.m_isSms = kThirdPay;
end