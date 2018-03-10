--[[
	className    	     :  HuaFuBaoPay
	Description  	     :  支付类-子类(话付宝支付)
	last-modified-date   :  Dec.23 2013
	create-time 	     :  Oct.29 2013
	last-modified-author :  ClarkWu
	create-author        :  ClarkWu
]]
require("MahjongPay/Pay/BasePay");

HuaFuBaoPay = class(BasePay);

HuaFuBaoPay.ctor = function(self)
	self.m_payId = "9";   -- 支付id
	self.m_pmode = "217";   -- pmode
	self.m_text = "话付宝支付";
	self.m_payCode = {};
	self.m_payCode["1"]="010";
	self.m_payCode["2"]="020";
	self.m_payCode["5"]="050";
	self.m_payCode["6"]="060";
	self.m_payCode["30"]="300";
	self.m_isSms = kMobileSmsPay;
end

