local certificateWindow = require(ViewLuaPath.."certificateWindow");

CertificateWindow = class(SCWindow);

CertificateWindow.REWARD_START = "奖励：";
CertificateWindow.REWARD_TYPE = "金币";
CertificateWindow.CERTIFICATE_DETAILS = "特此表彰，以资鼓励！";
CertificateWindow.SESSION_HEAD = "恭喜您在";
CertificateWindow.SESSION_TAIL = "中获得";

CertificateWindow.EXIT_TYPE_BACK = 1; -- 返回大厅
CertificateWindow.EXIT_TYPE_CONTINUE = 2; -- 继续报名

-- certificateContent: 奖状名称 string
-- ranking: 排名 int
-- reward: 奖励 string
CertificateWindow.ctor = function( self, data)
    
    DebugLog("[CertificateWindow]:ctor");
    if data then
        DebugLog("data rank:"..tostring(data.rank)..
                 " awardString:"..tostring(data.awardString)..
                 " time:"..tostring(data.time)..
                 " is_large_award:"..tostring(data.is_large_award));
    end

    EventDispatcher.getInstance():register(SocketManager.s_phpMsg, self, self.onPhpMsgResponse);

    self.ranking = data.rank or 0;
    self.reward = data.awardString or "";
    self.time= data.time;
    self.is_large_award = data.is_large_award or 0;--字段表示获得实物奖   1表示有实物  0表示没有
	self:setVisible( false );
	self:setLevel( GameConstant.view_level.CertificateWindow  );


	local tempCerCont = data.name or "";
	self.certificateContent = CertificateWindow.SESSION_HEAD..tempCerCont..CertificateWindow.SESSION_TAIL;
	self.isPlaying = false;

	self.window = SceneLoader.load( certificateWindow );
	self:addChild(self.window);
	self:setWindowNode( self.window );

	self.myself = PlayerManager.getInstance():myself();

	self:initView();
end

CertificateWindow.dtor = function( self)
    EventDispatcher.getInstance():unregister(SocketManager.s_phpMsg, self, self.onPhpMsgResponse);
end


-- 初始化控件
CertificateWindow.initView = function( self )
	self.bg = publ_getItemFromTree( self.window, { "bg" } );
	self.btnSaveCertificate = publ_getItemFromTree( self.window, { "bg", "btn_save_certificate" } );
	self.btnBack = publ_getItemFromTree( self.window, { "bg", "btn_back_to_hall" } );
	self.btnContinueContest = publ_getItemFromTree( self.window, { "bg", "btn_contine_contest" } );
    self.btnContinueContest.t = publ_getItemFromTree( self.btnContinueContest, {  "text_continue" } );
    
	self.imgRank = publ_getItemFromTree( self.window, { "bg", "window_bg", "img_rank" } );
	self.imgRankDecade = publ_getItemFromTree( self.window, { "bg", "window_bg", "img_rank_decade" } );
	self.imgRankUnits = publ_getItemFromTree( self.window, { "bg", "window_bg", "img_rank_units" } );
	self.textRewardContent = publ_getItemFromTree( self.window, { "bg", "window_bg", "text_reward_content" } );
	self.textReward = publ_getItemFromTree( self.window, { "bg", "window_bg", "text_reward" } );
	self.textTime = publ_getItemFromTree( self.window, { "bg", "window_bg", "text_time" } );

    if self.is_large_award == 1 then
        self.btnContinueContest.t:setText("领取奖励");
    end

	self.window:setEventTouch(self, function ( self )
--        self.bType = CertificateWindow.EXIT_TYPE_BACK;
--        self:hideWnd();
	end);

	if self.ranking then
		local ranking = tonumber( self.ranking ) or 0;
		if ranking > 0 and ranking < 10 then
			self.imgRank:setVisible( true );
			self.imgRankDecade:setVisible( false );
			self.imgRankUnits:setVisible( false );
			self.imgRank:setFile( "Room/certificate/" .. ranking .. ".png" );
		elseif ranking >= 10 and ranking < 100 then
			self.imgRank:setVisible( false );
			self.imgRankDecade:setVisible( true );
			self.imgRankUnits:setVisible( true );
			local decade = ( ranking - ranking%10 )/10;
			local units = ranking%10;

			self.imgRankDecade:setFile( "Room/certificate/" .. decade .. ".png" );
			self.imgRankUnits:setFile( "Room/certificate/" .. units .. ".png" );
		else
			self.imgRank:setVisible( true );
			self.imgRankDecade:setVisible( false );
			self.imgRankUnits:setVisible( false );
			self.imgRank:setFile( "Room/certificate/" .. 0 .. ".png" );
		end
	end

	self.textRewardContent:setText( self.certificateContent or "" );
	self.textReward:setText( CertificateWindow.REWARD_START..( self.reward or "" ) );
    local time_str = "";
    if self.time  then
        local date = os.date("*t", self.time );
	    time_str = string.format("%4d年%2d月%02d日", date.year, date.month, date.day);
    else
        time_str = os.date( "%Y年%m月%d日" , os.time())
    end
	self.textTime:setText( CertificateWindow.CERTIFICATE_DETAILS.. time_str);

	self.btnBack:setOnClick( self, function( self )
		self.bType = CertificateWindow.EXIT_TYPE_BACK;
		self:hideWnd();
	end);

	self.btnContinueContest:setOnClick( self, function( self )
        --打开填写实物兑换信息界面
        if self.is_large_award == 1 then
            self:showExchangeWindow();
        else
            self:continueContest();
        end
		
	end);

	self.btnSaveCertificate:setOnClick( self, function( self )
		self:saveScreenShot();
	end);

	if not PlatformFactory.curPlatform:needToShareWindow() then 
		self.btnSaveCertificate:setVisible(false);
	end
end

CertificateWindow.showExchangeWindow = function (self)
        require("MahjongPopu/ExchangeGoodsWindow");

        local exchangeGoodsWindow = new(ExchangeGoodsWindow);
        self:addChild(exchangeGoodsWindow);
        self.exchangeGoodsWindow = exchangeGoodsWindow;
        exchangeGoodsWindow:setOKCallBack(self, function(self) 
            local exchangeGoodsWindow = self.exchangeGoodsWindow;    
            local strPhoneNum   = exchangeGoodsWindow:getPhoneNum() or "";           
            local strAddress    = exchangeGoodsWindow:getAddress() or "";
            local strName       = exchangeGoodsWindow:getName() or "";

            if not strPhoneNum or strPhoneNum == "" then
                Banner.getInstance():showMsg("请填写您的手机号码");
                return ;
            end
          
            if not tonumber(publ_trim(strPhoneNum)) then
                Banner.getInstance():showMsg("请填写11位有效手机号码");
                return;
            end

            if string.len(publ_trim(strPhoneNum)) ~= 11 then 
                Banner.getInstance():showMsg("请填写11位有效手机号码");
                return;
            end

            if not strName or strName == "" or publ_trim(strName) == "" then
                Banner.getInstance():showMsg("请填写您的姓名");
                return ;
            end

            if string.len(publ_trim(getStringLen(strName))) > 10 then
                Banner.getInstance():showMsg("请填写不超过10个字符的姓名");
                return ;
            end
            if string.len(publ_trim(getStringLen(strAddress))) < 1 or strAddress == ""  then
                Banner.getInstance():showMsg("请填写正确的地址");
                return ;
            end


            GlobalDataManager.getInstance():setExchangeDictInfo(strPhoneNum, strName, strAddress);
            self:requestSetExchangeInfo(strName, strPhoneNum, strAddress);
           
            exchangeGoodsWindow:hideWnd();
            self.exchangeGoodsWindow = nil;
    end);
    local phone, name, ad = GlobalDataManager.getInstance():getExchangeDictInfo();
    exchangeGoodsWindow:setName(name or "");
    exchangeGoodsWindow:setAddress(ad or "");
    exchangeGoodsWindow:setPhoneNum(phone or "");
end

--发送命令请求 兑换信息填写
CertificateWindow.requestSetExchangeInfo = function(self, name, phone, addr)
    local param = {};
    param.name = name or "";
    param.phone = phone or 0;
    param.addr = addr or "";
    SocketManager.getInstance():sendPack( PHP_CMD_SET_MATCH_EXCHANGE_INFO, param);
end

CertificateWindow.matchApplySet = function (self)
    self.btnContinueContest:setVisible(false);
    self.btnBack:setVisible(false);
    self.window:setEventTouch(self, function ( self )
    	self.bType = CertificateWindow.EXIT_TYPE_BACK;
		self:hideWnd();
	end);
end

-- 调用java保存截图
CertificateWindow.saveScreenShot = function ( self )
    if not GameConstant.isQQInstalled and not GameConstant.isWechatInstalled then
        Banner.getInstance():showMsg("未安装QQ和微信，不能分享");
    else
    	self:hideBtn();
        local dd = self:createShareMsg();
        local shareData = {d = nil, share = dd , t = GameConstant.shareConfig.certificate, b = false};
        global_screen_shot(shareData);
    end
end

function CertificateWindow.createShareMsg( self )
	math.randomseed( tonumber(tostring(os.time()):reverse():sub(0,#kShareTextContent)) ) 
	local rand = math.random();
	local index = math.modf( rand*1000%6 );
	local player = PlayerManager.getInstance():myself();

	local data = {};
	data.title = PlatformFactory.curPlatform:getApplicationShareName();
	data.content = kShareTextContent[ index or 1 ];
	data.username = player.nickName or "川麻小王子";
	data.url = GameConstant.shareMessage.url or ""

	DebugLog( index );
	DebugLog( data.title );
	DebugLog( data.content );
	DebugLog( data.username );
	
	return data;
end

-- 隐藏按钮
CertificateWindow.hideBtn = function( self )
	self.btnBack:setVisible( false );
	self.btnContinueContest:setVisible( false );
	self.btnSaveCertificate:setVisible( false );
end

function CertificateWindow.share( self, json_data )

end

-- 显示按钮
function CertificateWindow.showBtn( self )
	self.btnBack:setVisible( true );
	self.btnContinueContest:setVisible( true );
end

-- 返回大厅按钮设置监听器
CertificateWindow.setOnBackClick = function( self, obj, func )
	self.onBackObj = obj;
	self.onBackFunc = func;
end

-- 继续报名按钮监听器
CertificateWindow.setOnContinueClick = function( self, obj, func )
	self.onContinueObj = obj;
	self.onContinueFunc = func;
end

-- 显示奖状窗口
CertificateWindow.show = function( self )
	if GameConstant.curGameSceneRef then
		GameConstant.curGameSceneRef:addChild( self );
	else
		self:addToRoot();
	end
	self:showWnd();
end

-- 隐藏奖状窗口
CertificateWindow.hide = function( self )
	self:hideWnd();
end

function CertificateWindow.onWindowHide( self )
	if self.hideHandleObj and self.hideHandleFunc then
		self.hideHandleFunc(self.hideHandleObj);
	else
		if self.bType == CertificateWindow.EXIT_TYPE_BACK then
			self:backToHall();
		end
	end
end

CertificateWindow.backToHall = function( self )
	if RoomScene_instance then
		RoomScene_instance:backToMatchSelectView();
	end
	PlayerManager.getInstance():myself().isInGame = false;
   
end

CertificateWindow.continueContest = function( self )
	DebugLog( "CertificateWindow.continueContest" );
	local matchRoomData = HallConfigDataManager.getInstance():returnMatchDataByLevel(GameConstant.curRoomLevel);
	if not matchRoomData then 
		Banner.getInstance():showMsg("您的网络不稳定");
        DebugLog("matchRoomData is nil: roomlevel:"..tostring(GameConstant.curRoomLevel));
		self:backToHall();
		return;
	end

	local money = self.myself.money;
    DebugLog("matchRoomData.offline:"..tostring(matchRoomData.offline).." matchRoomData.exceed:"..tostring(matchRoomData.exceed).." :mymoney"..tostring(money));
	if matchRoomData.offline > money then
		require("MahjongCommon/RechargeTip");

        local param_t = {t = RechargeTip.enum.enter_game,
                    parent = self; 
                    isShow = true, roomlevel = GameConstant.curRoomLevel, 
                    money= matchRoomData.offline,
                    recommend= matchRoomData.recommend,
                    is_check_bankruptcy = true, 
                    is_check_giftpack = true,};
	    RechargeTip.create(param_t)
	elseif matchRoomData.exceed < money then
		local str = "      作为一代大虾，您怎么能在低级场欺负小盆友呢？赶快去更高级别的场次，与高手战斗吧！";
		local view = PopuFrame.showNormalDialog( "温馨提示", str, GameConstant.curGameSceneRef, nil, nil, true, false );
		view:setConfirmCallback(self, function ( self )
			GameConstant.continueMatchFlag = 1;
			self:backToHall();
		end);
		if view then
			view:setCallback(view, function ( view, isShow )
				if not isShow then
					
				end
			end);
		end
	else
		GameConstant.continueMatchFlag = 1;
		self:backToHall();
	end
end


CertificateWindow.requestSetExchangeInfoCallBack = function (self, isSuccess, data, jsonData)
    if data and data.msg  then
        Banner.getInstance():showMsg(data.msg);
    end


    if not isSuccess or not data then
        return;
    end

    if data.status ~= 1 then
        return;
    end
    --Banner.getInstance():showMsg("您的兑换信息已提交成功");
end

--http回调
CertificateWindow.onPhpMsgResponse = function ( self, param, cmd, isSuccess,... )
    if self.httpRequestsCallBackFuncMap[cmd] then
        self.httpRequestsCallBackFuncMap[cmd](self,isSuccess,param,...)
    end
end

CertificateWindow.httpRequestsCallBackFuncMap =
{
    [PHP_CMD_SET_MATCH_EXCHANGE_INFO] = CertificateWindow.requestSetExchangeInfoCallBack,
};