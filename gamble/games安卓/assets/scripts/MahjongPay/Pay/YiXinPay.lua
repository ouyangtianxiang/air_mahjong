--[[
	className    	     :  YiXinPay
	Description  	     :  支付类-子类(易信支付)
	last-modified-date   :  Dec.23 2013
	create-time 	     :  Oct.29 2013
	last-modified-author :  ClarkWu
	create-author        :  ClarkWu
]]
require("MahjongPay/Pay/BasePay");

YiXinPay = class(BasePay);

YiXinPay.ctor = function(self)
	self.m_payId = "2010";   -- 支付id
	self.m_pmode = "34";   -- pmode
	self.m_text = "易信支付";
	self.m_payCode = nil; -- 计费点
	self.m_isSms = kThirdPay;
end
