
PayConfigMap = {}

-- 下单业务侧函数的obj和fuc
PayConfigMap.createOrderIdObj = App
PayConfigMap.createOrderIdFuc = App.createOrderReal

-- 显示营销页的obj和fuc
PayConfigMap.showPayConfirmWindowObj = App
PayConfigMap.showPayConfirmWindowFuc = App.showPayConfirmWindow

-- 显示支付选择框的obj和fuc
PayConfigMap.showPaySelectWindowObj = App
PayConfigMap.showPaySelectWindowFuc = App.showPaySelectWindow

-- 短信顯示小米提示
PayConfigMap.showXiaoMiSmsWindowObj = App
PayConfigMap.showXiaoMiSmsWindowFuc = App.showXiaoMiSmsWindow

kNoneSIM = -1
kYiDongSIM = 1
kLianTongSIM = 2
kDianXinSIM = 3

--短代计费码的额度（key:pmode, 0表示金币，1表示钻石）
PayConfigMap.m_allPayCodeLimit = {
	[218] = {                           --移动mm
		[0] = {2, 6, 10, 20, 30},
		[1] = {2, 6, 12, 20, 30},
	},
	[109] = {                           --联通沃
		[0] = {2, 6, 10, 20, 30},
		[1] = {2, 6, 12, 20, 30},
	},
	[217] = {                           --话付宝
		[0] = {1, 2, 5, 6, 30},
	},
	[282] = {                           --爱动漫
		[0] = {2, 6, 10, 20, 30},
	},
	[34] = {                            --爱游戏
		[0] = {2, 6, 10, 20, 30},
		[1] = {2, 6, 12, 20, 30},
	},
	[349] = {                           --话付宝综合
		[0] = {2, 6, 20, 30},
	},
	[31] = {                            --移动基地
		[0] = {2, 6, 10, 20, 30},
	},
	[294] = {                           --百度支付
		[0] = {2, 6, 10, 15, 20, 30, 50, 100, 200, 500, 998},
		[1] = {2, 6, 10, 15, 20, 30, 50, 100, 200, 500, 998},
	},
}

PayConfigMap.m_allPayConfig = {
	{
		pclientid = 4,
		pmode = 218,
		pname = "移动MM弱网",  -- just for descrption
		ptypename = "短信",
		ptypesim = kYiDongSIM,
		pimage = "img_sms.png",
	},
	{
		pclientid = 5,
		pmode = 109,
		pname = "联通支付",  -- just for descrption
		ptypename = "短信",
		ptypesim = kLianTongSIM,
		pimage = "img_sms.png",
	},
	{
		pclientid = 6,
		pmode = 198,
		pname = "银联支付",  -- just for descrption
		ptypename = "银联",
		ptypesim = kNoneSIM,
		pimage = "img_yinlian.png",
	},
	{
		pclientid = 9,
		pmode = 217,
		pname = "话付宝支付",  -- just for descrption
		ptypename = "短信",
		ptypesim = kYiDongSIM,
		pimage = "img_sms.png",
	},
	{
		pclientid = 10,
		pmode = 282,
		pname = "爱动漫",  -- just for descrption
		ptypename = "短信",
		ptypesim = kDianXinSIM,
		pimage = "img_sms.png",
	},
	{
		pclientid = 22,
		pmode = 34,
		pname = "爱游戏",  -- just for descrption
		ptypename = "短信",
		ptypesim = kDianXinSIM,
		pimage = "img_sms.png",
	},
	{
		pclientid = 24,
		pmode = 265,
		pname = "支付宝",  -- just for descrption
		ptypename = "支付宝",
		ptypesim = kNoneSIM,
		pimage = "img_zhifubao.png",
	},
	{
		pclientid = 26,
		pmode = 349,
		pname = "话付宝综合",  -- just for descrption
		ptypename = "短信",
		ptypesim = kYiDongSIM,
		pimage = "img_sms.png",
	},
	{
		pclientid = 27,
		pmode = 431,
		pname = "微信",  -- just for descrption
		ptypename = "微信",
		ptypesim = kNoneSIM,
		pimage = "img_weixin.png",
	},
	{
		pclientid = 1005,
		pmode = 31,
		pname = "基地支付",  -- just for descrption
		ptypename = "短信",
		ptypesim = kYiDongSIM,
		pimage = "img_sms.png",
	},
	{
		pclientid = 1103,
		pmode = 274,
		pname = "华为支付",  -- just for descrption
		ptypename = "华为",
		ptypesim = kNoneSIM,
		pimage = "huawei.png",
	},
	{
    	pclientid = 2003,
    	pmode = 294,
    	pname = "百度支付",  -- just for descrption
    	ptypename = "百度",
    	ptypesim = kNoneSIM,
    	pimage = "baidu.png",
    },
    {
    	pclientid = 1004,
    	pmode = 238,
    	pname = "安智支付",  -- just for descrption
    	ptypename = "安智",
    	ptypesim = kNoneSIM,
    	pimage = "anzhi.png",
	},
	{
		pclientid = 2011,
		pmode = 109,
		pname = "联通沃支付",  -- just for descrption
		ptypename = "联通沃",
		ptypesim = kNoneSIM,
		pimage = "img_sms.png",
	},

	{
		pclientid = 1020,
		pmode = 34,
		pname = "爱游戏支付",  -- just for descrption
		ptypename = "爱游戏",
		ptypesim = kNoneSIM,
		pimage = "img_sms.png",
	},

	{
		pclientid = 1002,
		pmode = 136,
		pname = "360支付",  -- just for descrption
		ptypename = "360",
		ptypesim = kNoneSIM,
		pimage = "360.png",
	},
	{
		pclientid = 1014,
		pmode = 235,
		pname = "豌豆荚支付",  -- just for descrption
		ptypename = "豌豆荚",
		ptypesim = kNoneSIM,
		pimage = "wdjpay.png",
	},
	{
		pclientid = 2000,
		pmode = 437,
		pname = "联通支付",  -- just for descrption
		ptypename = "短信",
		ptypesim = kLianTongSIM,
		pimage = "img_sms.png",
	},
	{
		pclientid = 1001,
		pmode = 215,
		pname = "OPPO支付",  -- just for descrption
		ptypename = "Oppo",
		ptypesim = kNoneSIM,
		pimage = "OPPO.png",
	},
	{
		pclientid = 2010,
		pmode = 296,
		pname = "易信支付",  -- just for descrption
		ptypename = "易信",
		ptypesim = kNoneSIM,
		pimage = "img_sms.png",
	},
	{
		pclientid = 1030,
		pmode = 617,
		pname = "九游支付",  -- just for descrption
		ptypename = "九游",
		ptypesim = kNoneSIM,
		pimage = "jiuyoupay.png",
	},
	{
		pclientid = 28,
		pmode = 767,
		pname = "触宝支付",  -- just for descrption
		ptypename = "触宝",
		ptypesim = kNoneSIM,
		pimage = "chubao.png",
	},
	-- {
	-- 	pmode = 218,
	-- 	pname = "移动MM弱网"  -- just for descrption
	-- 	ptypename = "短信支付"
	-- 	ptypesim = kYiDongSIM
	-- }
	-- {
	-- 	pmode = 218,
	-- 	pname = "移动MM弱网"  -- just for descrption
	-- 	ptypename = "短信支付"
	-- 	ptypesim = kYiDongSIM
	-- }
}


PayConfigMap.m_all_iosPayConfig = {
	{
		pclientid = 27,
		pmode = 463,
		pname = "微信",  -- just for descrption
		ptypename = "微信",
		ptypesim = kNoneSIM,
		pimage = "img_weixin.png",
	},
	{
		pclientid = 24,
		pmode = 620,
		pname = "支付宝",  -- just for descrption
		ptypename = "支付宝",
		ptypesim = kNoneSIM,
		pimage = "img_zhifubao.png",
	},
	{
		pclientid = 6,
		pmode = 198,
		pname = "银联支付",  -- just for descrption
		ptypename = "银联",
		ptypesim = kNoneSIM,
		pimage = "img_yinlian.png",
	},
	{
		pclientid = 999,
		pmode = 99,
		pname = "苹果支付",  -- just for descrption
		ptypename = "苹果",
		ptypesim = kNoneSIM,
		pimage = "img_apple.png",
	}
}

PayConfigMap.m_default_iosSupportPayConfig = {
{
		pclientid = 27,
		plimit = -1,
		ptips = 0
}, {
		pclientid = 24,
		plimit = -1,
		ptips = 0
}, {
		pclientid = 6,
		plimit = -1,
		ptips = 0
}, {
		pclientid = 999,
		plimit = -1,
		ptips = 0
	}
}
