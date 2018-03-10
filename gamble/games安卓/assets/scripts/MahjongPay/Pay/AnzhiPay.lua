--[[
	className    	     :  AnzhiPay
	Description  	     :  支付类-子类(anzhi支付)
	last-modified-date   :  Dec.23 2013
	create-time 	     :  Oct.29 2013
	last-modified-author :  ClarkWu
	create-author        :  ClarkWu
]]
require("MahjongPay/Pay/BasePay");

AnzhiPay = class(BasePay);

AnzhiPay.ctor = function(self)
	self.m_payId = "1004";   -- 支付id
	self.m_pmode = "238";   -- pmode
	self.m_payCode = nil; -- 计费点
	self.m_text = "安智支付";
	self.m_isSms = kThirdPay;
end