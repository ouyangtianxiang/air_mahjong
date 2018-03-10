--[[
	className    	     :  MiniStdAliPay
	Description  	     :  支付类-子类(支付宝极简支付)
	last-modified-date   :  Dec.23 2013
	create-time 	     :  Oct.29 2013
	last-modified-author :  ClarkWu
	create-author        :  ClarkWu
]]
require("MahjongPay/Pay/BasePay");

MiniStdAliPay = class(BasePay);

MiniStdAliPay.ctor = function(self)
	self.m_payId = "24";   -- 支付id
	self.m_pmode = "265";   -- pmode
	self.m_text = "支付宝极简支付";
	self.m_payCode = nil; -- 计费点
	self.m_isSms = kThirdPay;
end

MiniStdAliPay.concatOtherParam = function(self,data)
	local param = {};
	param.notify_url = data.data.NOTIFY_URL
	param.desc = self.m_product.pdesc or "";
	return param;
end