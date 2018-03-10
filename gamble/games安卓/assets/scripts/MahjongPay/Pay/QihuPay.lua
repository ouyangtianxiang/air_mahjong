--
-- Created by IntelliJ IDEA.
-- User: BenLuo
-- Date: 2016/1/24
-- Time: 15:46
-- To change this template use File | Settings | File Templates.
--

require("MahjongPay/Pay/BasePay");

QihuPay = class(BasePay);

QihuPay.ctor = function(self)
    self.m_payId = "1002";   -- 支付id
    self.m_pmode = "136";   -- pmode
    self.m_payCode = nil; -- 计费点
    self.m_text = "Qihu支付";
    self.m_isSms = kThirdPay;
end

QihuPay.concatOtherParam = function(self,data)
	local param = {};
	param.notify_url = data.data.NOTIFY_URL
	param.appUserId = PlayerManager.getInstance():myself().mid or "";
	param.appUserName = PlayerManager.getInstance():myself().nickName or "";
	param.qihoUserId = PlayerManager.getInstance():myself().sitemid or "";
	param.accessToken = GameConstant.accesscode or "";
	param.productId = data.data.PAYCONFID or "";
	return param;
end