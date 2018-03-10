--[[
	className    	     :  TianYiPay
	Description  	     :  支付类-子类(天翼支付)
	last-modified-date   :  Dec.23 2013
	create-time 	     :  Oct.29 2013
	last-modified-author :  ClarkWu
	create-author        :  ClarkWu
]]
require("MahjongPay/Pay/BasePay");

TianYiPay = class(BasePay);

TianYiPay.ctor = function(self)
	self.m_payId = "2013";   -- 支付id
	self.m_pmode = "658";   -- pmode
	self.m_payCode = {};
	self.m_text = "天翼支付";
	self.m_payCode["1"] ="F57F04DA14CD4BDDE0430100007FAE46";
	self.m_payCode["2"] ="E225C16A3D675C3FE040007F010022F2";
	self.m_payCode["6"] ="E225C16A3D685C3FE040007F010022F2";
	self.m_payCode["10"] ="E225C16A3D695C3FE040007F010022F2";
	self.m_payCode["20"] ="E40C1DBFA3BA48F1E040640A041E5CAA";
	self.m_isSms = kTelecomSmsPay;
end

TianYiPay.concatOtherParam = function(self,data)
	local param = {};
	param.orderId = string.sub(self.m_orderId,string.len(self.m_orderId)-9,string.len(self.m_orderId));
	return param;
end