--[[
	className    	     :  LoveAnimatePay
	Description  	     :  支付类-子类(爱动漫支付)
	last-modified-date   :  Dec.23 2013
	create-time 	     :  Oct.29 2013
	last-modified-author :  ClarkWu
	create-author        :  ClarkWu
]]
require("MahjongPay/Pay/BasePay");

LoveAnimatePay = class(BasePay);

LoveAnimatePay.ctor = function(self)
	self.m_payId = "10";   -- 支付id
	self.m_pmode = "282";   -- pmode
	self.m_payCode = {};
	self.m_text = "爱动漫支付";
	self.m_payCode["2"] ="B000gf|11802115020";
	self.m_payCode["6"] ="B000gg|11802115060";
	self.m_payCode["10"] ="B000gh|11802115100";
	self.m_payCode["20"] ="B000gi|11802115200";
	self.m_payCode["30"] ="B000gj|11802115300";
	self.m_payCode["10b"] ="B000gk|11802115200";
	self.m_payCode["30b"] ="B000gl|11802115300";
	self.m_isSms = kTelecomSmsPay;
end