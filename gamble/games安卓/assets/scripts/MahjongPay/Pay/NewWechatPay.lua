--[[
	className    	     :  WechatPay
	Description  	     :  支付类-子类(微信支付)
	last-modified-date   :  Dec.23 2013
	create-time 	     :  Oct.29 2013
	last-modified-author :  ClarkWu
	create-author        :  ClarkWu
]]
require("MahjongPay/Pay/BasePay");

NewWechatPay = class(BasePay);

NewWechatPay.ctor = function(self)
	self.m_payId = "27";   -- 支付id
	self.m_pmode = "431";   -- pmode
	self.m_payCode = nil; -- 计费点
	self.m_text = "新微信支付";
	self.m_isSms = kThirdPay;
end

NewWechatPay.concatOtherParam = function(self,data)
	local param = {};
	param.appid = data.data.appid
	param.partnerId = data.data.partnerid
	param.nonceStr = data.data.noncestr
	param.package = data.data.package
	param.prepayId = data.data.prepayid
	param.timeStamp = data.data.timestamp
	param.sign = data.data.sign
	return param;
end