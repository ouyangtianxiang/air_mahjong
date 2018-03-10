--[[
	className    	     :  PlatformFactory
	Description  	     :  To wrap all the entrance of the views of platforms.
	last-modified-date   :  Dec. 3 2013
	create-time 	   	 :  Oct.22 2013
	last-modified-author :  ClarkWu
	create-author        :　jkinLiu
]]

PlatformFactory = {};
--public parameter describes the current platform.
PlatformFactory.curPlatform = nil;

--[[
	function name	   : PlatformFactory.initPlatform
	description  	   : To init the platform.
	param 	 	 	   : platformType   Number  -- the number of platform
	last-modified-date : Oct.22 2013
	create-time  	   : Oct.22 2013
]]
PlatformFactory.initPlatform = function ( platformType)
	if PlatformFactory.curPlatform then
		delete(PlatformFactory.curPlatform);
		PlatformFactory.curPlatform = nil;
	end
	PlatformFactory.curPlatform = PlatformFactory.platformFactory(platformType);
end

--[[
	function name	   : PlatformFactory.platformFactory
	description  	   : To construct new platform by its platformType.
	param 	 	 	   : platformType   Number  -- the number of platform
	last-modified-date : Oct.22 2013
	create-time  	   : Oct.22 2013
]]
PlatformFactory.platformFactory = function ( platformType)
	require("MahjongPlatform/PlatformConfig");

	if PlatformConfig.platformTrunk == platformType or platformType == PlatformConfig.platformHuafubaoLianyun then
		require("MahjongPlatform/Platform/TrunkPlatform");
		return new(TrunkPlatform);
	elseif PlatformConfig.platformHuawei == platformType then
		require("MahjongPlatform/Platform/HuaweiPlatform");
		return new(HuaweiPlatform);
	elseif PlatformConfig.platformDianxin == platformType then
		require("MahjongPlatform/Platform/TelePlatform");
		return new(TelePlatform);
	elseif PlatformConfig.platformQihoo == platformType then
		require("MahjongPlatform/Platform/QihuPlatform");
		return new(QihuPlatform);
	elseif PlatformConfig.platformTOM == platformType then
		--TODO
	elseif PlatformConfig.platformOPPO == platformType then
		require("MahjongPlatform/Platform/OppoPlatform");
		return new(OppoPlatform);
	elseif PlatformConfig.platformPlayPlus == platformType then
		--TODO
	elseif PlatformConfig.platformMobile == platformType then
		require("MahjongPlatform/Platform/MobilePlatform");
		return new(MobilePlatform);
	elseif PlatformConfig.platformEGAME == platformType then
		require("MahjongPlatform/Platform/EgamePlatform");
		return new(EgamePlatform);
	elseif PlatformConfig.platformTCL == platformType then
		--TODO
	elseif PlatformConfig.platform2324Game == platformType then
		--TODO
	elseif PlatformConfig.platformYidongMM == platformType then
		require("MahjongPlatform/Platform/YiDongMMPlatform");
		return new(YiDongMMPlatform);
	elseif PlatformConfig.platformWOSHOP == platformType
		or PlatformConfig.platformUnicomWdj == platformType then
		require("MahjongPlatform/Platform/UnicomPlatform");
		return new(UnicomPlatform);
	elseif PlatformConfig.platformAssistant91 == platformType then
		require("MahjongPlatform/Platform/Assistant91Platform");
		return new(Assistant91Platform);
	elseif PlatformConfig.platformTrunkPre == platformType then
		require("MahjongPlatform/Platform/TrunkPrePlatform");
		return new(TrunkPrePlatform);
	elseif PlatformConfig.platformSouGou == platformType then
		require("MahjongPlatform/Platform/SoGouPlatform");
		return new(SoGouPlatform);
	elseif PlatformConfig.platformBaidu == platformType then
		require("MahjongPlatform/Platform/BaiduPlatform");
		return new(BaiduPlatform);
	elseif PlatformConfig.platformLenovo == platformType then
		require("MahjongPlatform/Platform/LenovoPlatform");
		return new(LenovoPlatform);
	elseif PlatformConfig.platformContest == platformType then
		require("MahjongPlatform/Platform/ContestPlatform");
		return new(ContestPlatform);
	elseif PlatformConfig.platformAnZhi == platformType then
		require("MahjongPlatform/Platform/AnZhiPlatform");
		return new(AnZhiPlatform);
	elseif PlatformConfig.platformGuangDianTong == platformType then
		require("MahjongPlatform/Platform/GuangDianTongPlatform");
		return new(GuangDianTongPlatform);
	elseif PlatformConfig.platformUnicomKd == platformType then
		require("MahjongPlatform/Platform/UnicomKdPlatform");
		return new(UnicomKdPlatform);
	elseif PlatformConfig.platformFetion == platformType then
		require("MahjongPlatform/Platform/FetionPlatform");
		return new(FetionPlatform);
	elseif PlatformConfig.platformJinLi == platformType then
		require("MahjongPlatform/Platform/JinLiPlatform");
		return new(JinLiPlatform);
	elseif PlatformConfig.platform37Wan == platformType then
		require("MahjongPlatform/Platform/Wan37Platform");
		return new(Wan37Platform);
	elseif PlatformConfig.platform3Net == platformType then
		require("MahjongPlatform/Platform/ThreeNetPlatform");
		return new(ThreeNetPlatform);
	elseif PlatformConfig.platformWDJ == platformType then
		require("MahjongPlatform/Platform/WDJPlatform");
		return new(WDJPlatform);
	elseif PlatformConfig.platformDingkai == platformType then
		require("MahjongPlatform/Platform/DingkaiPlatform");
		return new(DingkaiPlatform);
	elseif PlatformConfig.platformBaiduChannel == platformType then
		require("MahjongPlatform/Platform/BaiduChannelPlatform");
		return new(BaiduChannelPlatform);
	elseif PlatformConfig.platformLenovoBare == platformType then
		require("MahjongPlatform/Platform/LenovoBarePlatform");
		return new(LenovoBarePlatform);
    elseif PlatformConfig.platform3NetJiDi == platformType then
        require("MahjongPlatform/Platform/ThreeNetJiDiPlatform");
		return new(ThreeNetJiDiPlatform);
	elseif PlatformConfig.platformLenovoBareMall == platformType then
		require("MahjongPlatform/Platform/LenovoBareMallPlatform");
		return new(LenovoBareMallPlatform);
	elseif PlatformConfig.platformThreeNetMi == platformType then
		require("MahjongPlatform/Platform/ThreeNetXiaoMiPlatform");
		return new(ThreeNetXiaoMiPlatform);
	elseif PlatformConfig.platformYiXin == platformType then
		require("MahjongPlatform/Platform/YiXinPlatform");
		return new(YiXinPlatform);
	elseif PlatformConfig.platformThreeNetYYH == platformType then
		require("MahjongPlatform/Platform/ThreeNetYYHPlatform");
		return new(ThreeNetYYHPlatform);
	elseif PlatformConfig.platformVivo == platformType then
		require("MahjongPlatform/Platform/BuBuGaoPlatform");
		return new(BuBuGaoPlatform);
	elseif PlatformConfig.platformThreeNet3636 == platformType then
		require("MahjongPlatform/Platform/ThreeNet3636Platform");
		return new(ThreeNet3636Platform);
	elseif PlatformConfig.platformThreeNetTencent == platformType or
		PlatformConfig.platformThreeNetTencentYYB == platformType or
		PlatformConfig.platformThreeNetTencentYXZX == platformType or
		PlatformConfig.platformThreeNetTencentYYSC == platformType or
		PlatformConfig.platformThreeNetTencentJS == platformType or
		PlatformConfig.platformThreeNetTencentQQBrowser == platformType or
		PlatformConfig.platformThreeNetTencentSJJL == platformType or
		PlatformConfig.platformThreenetTencentTXSP == platformType then
		require("MahjongPlatform/Platform/ThreeNetTencentPlatform");
		return new(ThreeNetTencentPlatform);
	elseif PlatformConfig.platformXYAssistant == platformType then
		require("MahjongPlatform/Platform/XYAssistantPlatform");
		return new(XYAssistantPlatform);
	elseif PlatformConfig.platformLeShi == platformType then
		require("MahjongPlatform/Platform/LeShiPlatform");
		return new(LeShiPlatform);
	elseif PlatformConfig.platformMeiZu == platformType then
		require("MahjongPlatform/Platform/MeiZuPlatform");
		return new(MeiZuPlatform);
	elseif PlatformConfig.platformBaiDuCps == platformType then
		require("MahjongPlatform/Platform/BaiduCpsPlatform");
		return new(BaiduCpsPlatform);
	elseif PlatformConfig.platform2345 == platformType then
		require("MahjongPlatform/Platform/Trunk2345Platform");
		return new(Trunk2345Platform);
	elseif PlatformConfig.platform3NetPPAssistant == platformType then
		require("MahjongPlatform/Platform/PPAssistantPlatform");
		return new(PPAssistantPlatform);
	elseif PlatformConfig.platformHuaweiSecond == platformType then
		require("MahjongPlatform/Platform/HuaweiSecondPlatform");
		return new(HuaweiSecondPlatform);
	elseif PlatformConfig.platformNewEgame == platformType
		or PlatformConfig.platformEgameWdj == platformType then
		require("MahjongPlatform/Platform/NewEgamePlatform");
		return new(NewEgamePlatform);
	elseif PlatformConfig.platformAoTian == platformType then
		require("MahjongPlatform/Platform/AoTianPlatform");
		return new(AoTianPlatform);
	elseif PlatformConfig.platformZancheng == platformType then
		require("MahjongPlatform/Platform/ZanChengPlatform");
		return new(ZanChengPlatform);
	elseif PlatformConfig.platformZhangMeng == platformType then
		require("MahjongPlatform/Platform/ZhangMengPlatform");
		return new(ZhangMengPlatform);
	elseif PlatformConfig.platformZhuoYi == platformType then
		require("MahjongPlatform/Platform/ZhuoYiPlatform");
		return new(ZhuoYiPlatform);
	elseif PlatformConfig.platformDangle == platformType then
		require("MahjongPlatform/Platform/DangLePlatform");
		return new(DangLePlatform);
	elseif PlatformConfig.platformJiuYou == platformType then
		require("MahjongPlatform/Platform/JiuYouPlatform");
		return new(JiuYouPlatform);
	elseif PlatformConfig.platformMoGu == platformType then
		require("MahjongPlatform/Platform/MoGuPlatform");
		return new(MoGuPlatform);
	elseif PlatformConfig.platformTianYi == platformType then
		require("MahjongPlatform/Platform/TianYiPlatform");
		return new(TianYiPlatform);
	elseif PlatformConfig.platformWDJNet == platformType then
		require("MahjongPlatform/Platform/WDJ_NetPlatform");
		return new(WDJ_NetPlatform);
	elseif PlatformConfig.platformThreeNetMi == platformType then
		require("MahjongPlatform/Platform/ThreeNetXiaoMiPlatform");
		return new(ThreeNetXiaoMiPlatform);
	elseif PlatformConfig.platformSamSung == platformType then
		require("MahjongPlatform/Platform/ThreeNetSamSungPlatform");
		return new(ThreeNetSamSungPlatform);
	elseif PlatformConfig.platformMMCps == platformType then
		require("MahjongPlatform/Platform/MMCpsPlatform");
		return new(MMCpsPlatform);
	elseif PlatformConfig.platformIOSMainVesion == platformType then
		require("MahjongPlatform/Platform/IOSMainPlatform");
	  return new(IOSMainPlatform);
	elseif PlatformConfig.platformSikaiMPZM == platformType
		or PlatformConfig.platformSikaiMPSC == platformType 
		or PlatformConfig.platformSikaiMPYX == platformType 
		or PlatformConfig.platformSikaiMPLLQ == platformType then 
		require("MahjongPlatform/Platform/SikaiCPSPlatform")
		return new(SikaiCPSPlatform)
	elseif PlatformConfig.platformChubao == platformType then 
		require("MahjongPlatform/Platform/ChubaoPlatform")
		return new(ChubaoPlatform)
	end
end
