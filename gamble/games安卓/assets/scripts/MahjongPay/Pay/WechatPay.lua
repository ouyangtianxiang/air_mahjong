--[[
	className    	     :  WechatPay
	Description  	     :  支付类-子类(微信支付)
	last-modified-date   :  Dec.23 2013
	create-time 	     :  Oct.29 2013
	last-modified-author :  ClarkWu
	create-author        :  ClarkWu
]]
require("MahjongPay/Pay/BasePay");

WechatPay = class(BasePay);

WechatPay.ctor = function(self)
	self.m_payId = "8";   -- 支付id
	self.m_pmode = "431";   -- pmode
	self.m_payCode = nil; -- 计费点
	self.m_text = "微信支付";
	self.m_isSms = kThirdPay;
end

WechatPay.concatOtherParam = function(self,data)
	local param = {};
	param.appId = data.data.appid
	param.partnerId = data.data.partnerid
	param.nonceStr = data.data.noncestr
	param.package = data.data.package
	param.prepayId = data.data.prepayid
	param.timeStamp = data.data.timestamp
	param.sign = data.data.sign
	return param;
end