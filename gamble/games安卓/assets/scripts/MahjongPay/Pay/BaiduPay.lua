--[[
	className    	     :  BaiduPay
	Description  	     :  支付类-子类(百度支付)
	last-modified-date   :  Dec.23 2013
	create-time 	     :  Oct.29 2013
	last-modified-author :  ClarkWu
	create-author        :  ClarkWu
]]
require("MahjongPay/Pay/BasePay");

BaiduPay = class(BasePay);

BaiduPay.ctor = function(self)
	self.m_payId = "2003";   -- 支付id
	self.m_pmode = "294";   -- pmode
	self.m_text = "百度支付";
	self.m_payCode = {};
	self.m_payCode["0.1"]="2326";
	self.m_payCode["2"]="2327";
	self.m_payCode["6"]="2328";
	self.m_payCode["10"]="2329";
	self.m_payCode["15"]="2330";
	self.m_payCode["20"]="2331";
	self.m_payCode["30"]="2332";
	self.m_payCode["50"]="2333";
	self.m_payCode["100"]="2334";
	self.m_payCode["200"]="2335";
	self.m_payCode["500"]="2336";
	self.m_payCode["10b"]="2337";
	self.m_payCode["30b"]="2338";
	self.m_payCode["98b"]="2339";
	self.m_payCode["500b"]="2340";
	self.m_payCode["998"]="10278";

	self.m_isSms = kThirdPay;
end
