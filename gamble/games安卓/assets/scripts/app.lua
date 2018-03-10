-- 這個作為整個項目的獨立的存在

local App = class()

function App:createOrderReal(goodsInfo)
	Banner.getInstance():showMsg("正在创建订单...")
	mahjongPrint(goodsInfo)
	require("MahjongData/PlayerManager");
	goodsInfo.sitemid = PlayerManager.getInstance():myself().sitemid;
	goodsInfo.nickName = PlayerManager.getInstance():myself().nickName;

	SocketManager.getInstance():sendPack(PHP_CMD_CREATE_ORDER , goodsInfo);
end

function App:showPayConfirmWindow(goodsInfo, confrimFuc, cancelFuc)
	local secondConfirmText = SecondConfirmWnd.getInstance();
	if not secondConfirmText.titleText and not secondConfirmText.contentText and not secondConfirmText.btnText then
		DebugLog( "没有获取到配置信息" );
		return;
	end

	secondConfirmText:show( tostring(goodsInfo.pname), goodsInfo.pamount );

	secondConfirmText:setOnConfirmClick( self, function( self )
		confrimFuc(PayController)
	end);

	secondConfirmText:setOnCloseClick( self, function( self )
		cancelFuc(PayController)
	end)
end

function App:showPaySelectWindow(payInfo)
	require( "MahjongPlatform/PaymentSelectWindow" );
	if not self.payWnd then
		self.payWnd = new(PaymentSelectWindow, payInfo.goodInfo,payInfo.paySelectInfo,self);
	end

	self.payWnd:setLevel(10005);
	if HallScene_instance and HallScene_instance.m_mainView then
		HallScene_instance.m_mainView:addChild(self.payWnd);
	elseif RoomScene_instance and RoomScene_instance.m_root then
		RoomScene_instance.m_root:addChild(self.payWnd);
	end

end

function App:showXiaoMiSmsWindow(cancelFuc)
	if GameConstant.isMiUiSystem then
		local mid = PlayerManager.getInstance():myself().mid;
		--
		if g_DiskDataMgr:getAppData('ismiui',0) ~= 1 then
			require("MahjongHall/Mall/MiuiSmsSettingWnd");
			if not self.m_miuismsWnd then
				self.m_miuismsWnd = new( MiuiSmsSettingWnd,self,cancelFuc);
			end
			g_DiskDataMgr:setAppData('ismiui',1)
			if HallScene_instance and HallScene_instance.m_mainView then
				HallScene_instance.m_mainView:addChild(self.m_miuismsWnd);
			elseif RoomScene_instance and RoomScene_instance.m_root then
				RoomScene_instance.m_root:addChild(self.m_miuismsWnd);
			end
			return true;
		end
	end
	return false;
end

return App
