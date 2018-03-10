--[[
	className    	     :  WebPay
	Description  	     :  支付类-子类(联通支付)
	last-modified-date   :  Dec.23 2013
	create-time 	     :  Oct.29 2013
	last-modified-author :  ClarkWu
	create-author        :  ClarkWu
]]
require("MahjongPay/Pay/BasePay");

WebPay = class(BasePay);

WebPay.ctor = function(self)
	self.m_payId = "10000";   -- 支付id
	self.m_pmode = "10000";   -- pmode
	self.m_text = "网页支付";
	self.m_isSms = kThirdPay;
end

WebPay.concatOtherParam = function(self,data)
	local param = {};
	param.orderurl = GameConstant.CommonUrl;
	param.sid = tonumber(PlatformFactory.curPlatform.sid);
	param.appid = GameConstant.appid;
	param.mid = PlayerManager.getInstance():myself().mid or "";
	param.ptype = self.m_product.ptype;
	return param;
end