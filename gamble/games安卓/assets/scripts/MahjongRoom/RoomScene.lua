require("gameBase/gameScene")
require("Animation/ShaiziAnimation");
require("MahjongRoom/Mahjong/MahjongViewManager");
require("MahjongRoom/SelectQueView");
require("MahjongRoom/TuoGuanAni");
require("MahjongRoom/OutCardTimer");
require("Animation/SCSprite");
require("MahjongRoom/RoomCoor");
require("Animation/SpriteConfig");
require("Animation/ChangeMoneyAnim");
require("MahjongRoom/Operation");
require("MahjongRoom/GameResult/GameResultWindow");
require("MahjongRoom/QuickChatWnd");
require("MahjongCommon/BankruptcyDlg");
require("MahjongRoom/Activity/RoomActivity");
require("Animation/BroadcastAnimation");
require("Animation/DafanxinAnim");
require("libs/bit");
require("MahjongHall/HallConfigDataManager");
require("MahjongRoom/UserInfo/RoomUserInfo");
require( "MahjongRoom/HuCardTips/HuCardTipsManager" );
require("MahjongRoom/Mahjong/MahjongManager");
require("Animation/GameResultNumberAnim")
require("Animation/AnimationDropCoins")
require("Animation/PlayCardsAnim/animationWind");
require("Animation/PlayCardsAnim/animationRain");
require("Animation/PlayCardsAnim/animationPeng");
require("Animation/PlayCardsAnim/animationZiMo");
require("Animation/PlayCardsAnim/animationDaJiao");
require("Animation/PlayCardsAnim/animationFangPao");
require("Animation/PlayCardsAnim/animationHuaZhu");
require("MahjongCommon/FirstChargeView");

--require("MahjongHall/Friend/CreateFriendRoomView");
--require("MahjongRoom/fetionScorePop");
require("MahjongRoom/GameResult/ShareWindow");
require("teach/TeachManager");

-- require("MahjongRoom/BroadcastPopWin");
require("MahjongRoom/Seat");
require("MahjongRoom/SeatManager");
require("MahjongCommon/RechargeTip");
--require("MahjongSingleGame/Client/SingleRoomScene");

require("Animation/FriendsAnim/animationCheers");
require("Animation/FriendsAnim/animationSendKiss");
require("Animation/FriendsAnim/animationSendRose");
require("Animation/FriendsAnim/animationShakeHands");
require("Animation/FriendsAnim/animationThrowBomb");
require("Animation/FriendsAnim/animationThrowEgg");
require("Animation/FriendsAnim/animationThrowRock");
require("Animation/FriendsAnim/animationThrowSoap");
require("Animation/FriendsAnim/animationThrowTomato");
require("Animation/FriendsAnim/animationSendFlower");
require("Animation/FriendsAnim/animationToPraise");

require("MahjongHall/Friend/InviteFriendWindow");
require("MahjongHall/HongBao/HongBaoModel")
--require("MahjongHall/HongBao/HongBaoViewManager")

local button_pin = require(ViewLuaPath.."button_pin");
local seatPinx_map = require("qnPlist/seatPinx")
local MahjongImage_map = require("qnPlist/MahjongImage")
local timePin_map = require("qnPlist/timePin")

RoomScene = class(GameScene);
RoomScene.propIndexSettingView = 1; -- 操作栏平移属性的sque

RoomScene.ctor = function(self, viewConfig, state)
--	g_GameMonitor:addTblToUnderMemLeakMonitor("房间",self)
	DebugLog("RoomScene ctor");
	RoomScene_instance = self;
	GameConstant.curGameSceneRef = self;

	FriendDataManager.getInstance():addListener(self,self.friendDataControlled);
	self.pm = PlayerManager.getInstance();
	self.beforeServerOutCardValue = 0;
	self.isShowHighLevel = false;
	self.isChangeTableActively = false; -- 是否主动请求换桌
	self.isShowRoomInfo = false; -- 换桌时与重连后是否显示房间信息（底注，出牌时间，玩法）
	self.roomData = RoomData.getInstance(); -- 房间数据
	self.lastStatu = StateMachine.getInstance().m_lastState; -- 进入房间之前的上一个状态
	self.myself = PlayerManager.getInstance():myself();

	GameConstant.needEvaluate = true  --需要评价
	GameConstant.isInRoom = true;
	GameConstant.noPopEvaluate = false
	self.roomData:initHuTypeInfo();
	self.isInSocketRoom = true;
	self.exitWnd = nil;
	self.propAnimManager = {};
	self.animIndex = 0;
	if GameConstant.iosDeviceType>0 then
		local statuslist = {};
		statuslist.status = 1;
		native_to_java("iosEnterRoomStatus",json.encode(statuslist))
	end

    --添加打包日志调试时间戳
    if DEBUGMODE == 1 then
        local profileNode = require('MahjongCommon/ProfileNode')
        self.profileNode = new(profileNode)
        self.profileNode:setPos(0,80)
        self.profileNode:setLevel(99999)
        self:addChild(self.profileNode)
    end
end

RoomScene.initView = function( self, isMatch )

	if DEBUGMODE == 1 then
		local scale = System.getLayoutScale();
		self.roomTips = UICreator.createText("",400,300, 1280*scale , 720*scale, kAlignCenter, 30,255,0,0);
		self:addChild( self.roomTips );
	end

	self.startTime = os.clock() * 1000;
	-- 房间的节点， 根据需要修改
	self.nodeRoomItem = new(Node); -- 座位等所在的组件层
	self.nodeHandCard = new(Node); -- 手牌，碰杠牌层
	self.nodeOperation = new(Node); -- 操作栏层
	self.nodeDingQue = new(Node);   -- 定缺层

	self.animationLayer = new(Node);--动画层
	self.chatNode = new(Node);
	self.nodePopu = new(Node); -- 弹窗层
	self.m_root:addChild(self.nodeRoomItem);
	self.nodeRoomItem:setFillParent(true , true);
	self.nodeHandCard:setFillParent(true , true);
	self.m_root:addChild(self.nodeHandCard);
	self.m_root:addChild(self.nodeOperation);
	self.m_root:addChild(self.nodeDingQue);

	self.m_root:addChild(self.animationLayer);
	self.m_root:addChild(self.chatNode);
	self.m_root:addChild(self.nodePopu);
	self.nodePopu:setLevel(100);

	self.mahjongManager = new(MahjongManager, self.nodeHandCard , self);
	self.seatManager = new(SeatManager, self, isMatch);

	self.settingView = nil; -- 设置操作栏
	self.selectQueView = nil; -- 选缺界面
	self.operationView = nil; -- 操作界面
	self.resultView = nil;
	--设置座位信息
	local scale = System.getLayoutScale();
	local scaleW = System.getScreenWidth() / System.getLayoutWidth() / scale;
	local scaleH = System.getScreenHeight() / System.getLayoutHeight() / scale;

	local  screenW, screenH = System.getScreenWidth() / scale, System.getScreenHeight()/ scale;

	--桌布中间棱形4个顶点的坐标
	local waitingCoor =
	{
		[kSeatMine] 	= {400, 360},
		[kSeatRight] 	= {530, 236},
		[kSeatTop] 		= {400, 106},
		[kSeatLeft] 	= {270, 236}
	};

	local avatarW, avatarH 	= self.mahjongManager.mahjongFrame:getAvatarSize(1);

	--等待时座位坐标
	Seat.waitingCoor[0][1], Seat.waitingCoor[0][2] = (screenW -avatarW)/ 2 , screenH / 2 + 190-40;
	Seat.waitingCoor[1][1], Seat.waitingCoor[1][2] = screenW / 2 + 400, (screenH - 200) / 2;
	Seat.waitingCoor[2][1], Seat.waitingCoor[2][2] = (screenW -avatarW)/ 2, screenH / 2 - 350 +20;
	Seat.waitingCoor[3][1], Seat.waitingCoor[3][2] = screenW / 2 - 400 - avatarW, (screenH - 200) / 2;
	--游戏中座位坐标
	Seat.inGameCoor[0][1], Seat.inGameCoor[0][2] = self.mahjongManager.mahjongFrame:getAvatarPos(0);
	Seat.inGameCoor[1][1], Seat.inGameCoor[1][2] = self.mahjongManager.mahjongFrame:getAvatarPos(1);
	Seat.inGameCoor[2][1], Seat.inGameCoor[2][2] = self.mahjongManager.mahjongFrame:getAvatarPos(2);
	Seat.inGameCoor[3][1], Seat.inGameCoor[3][2] = self.mahjongManager.mahjongFrame:getAvatarPos(3);
--[[
	Seat.inGameCoor[0][2] = Seat.inGameCoor[0][2] - 10

	Seat.inGameCoor[1][1] = Seat.inGameCoor[1][1] - 10
	Seat.inGameCoor[1][2] = Seat.inGameCoor[1][2] - 15
	Seat.inGameCoor[2][2] = Seat.inGameCoor[2][2] + 30
	Seat.inGameCoor[3][2] = Seat.inGameCoor[3][2] + 25
	]]
	--庄家坐标
	Seat.bankCoor[0][1], Seat.bankCoor[0][2] = self.mahjongManager.mahjongFrame:getBankPos(0);
	Seat.bankCoor[1][1], Seat.bankCoor[1][2] = self.mahjongManager.mahjongFrame:getBankPos(1);
	Seat.bankCoor[2][1], Seat.bankCoor[2][2] = self.mahjongManager.mahjongFrame:getBankPos(2);
	Seat.bankCoor[3][1], Seat.bankCoor[3][2] = self.mahjongManager.mahjongFrame:getBankPos(3);
	--比赛积分坐标
	Seat.matchScoreCoor[0][1], Seat.matchScoreCoor[0][2] = self.mahjongManager.mahjongFrame:getMatchScorePos(0);
	Seat.matchScoreCoor[1][1], Seat.matchScoreCoor[1][2] = self.mahjongManager.mahjongFrame:getMatchScorePos(1);
	Seat.matchScoreCoor[2][1], Seat.matchScoreCoor[2][2] = self.mahjongManager.mahjongFrame:getMatchScorePos(2);
	Seat.matchScoreCoor[3][1], Seat.matchScoreCoor[3][2] = self.mahjongManager.mahjongFrame:getMatchScorePos(3);
	--定缺坐标(靠近头像)
	Seat.queCoor[0][1], Seat.queCoor[0][2] = self.mahjongManager.mahjongFrame:getSelectPos(0);
	Seat.queCoor[1][1], Seat.queCoor[1][2] = self.mahjongManager.mahjongFrame:getSelectPos(1);
	Seat.queCoor[2][1], Seat.queCoor[2][2] = self.mahjongManager.mahjongFrame:getSelectPos(2);
	Seat.queCoor[3][1], Seat.queCoor[3][2] = self.mahjongManager.mahjongFrame:getSelectPos(3);
	--骰子坐标
	--居中
	RoomCoor.shaizhiAni.x = 640 * scaleW - RoomCoor.shaizhiAni.w / 2 + 60;
	RoomCoor.shaizhiAni.y = 400 * scaleH - RoomCoor.shaizhiAni.h / 2;
	--碰杠操作
	Operation.sX, Operation.sY 	= self.mahjongManager.mahjongFrame:getPos(0)
	Operation.sW 				= self.mahjongManager.mahjongFrame:getSize(0);

	--各种动画坐标

	local spriteSize = {
						[SpriteConfig.TYPE_PENG]		= {280,250},
						[SpriteConfig.TYPE_GUAFENG] 	= {390,300},
						[SpriteConfig.TYPE_XIAYU] 		= {300,400},
						[SpriteConfig.TYPE_CHADAJIAO] 	= {300,235},
						[SpriteConfig.TYPE_CHAHUAZHU] 	= {300,235},
						[SpriteConfig.TYPE_FANGPAO] 	= {235,300},
						[SpriteConfig.TYPE_ZIMO] 		= {275,340}};
	--下玩家
	local x, y = self.mahjongManager.mahjongFrame:getPos(kSeatMine);
	local w, h = self.mahjongManager.mahjongFrame:getSize(kSeatMine);

	for i = 1, 7 do
		RoomCoor.gameAnim[i][kSeatMine][1] = x + w / 2 - spriteSize[i][1]/2;
		RoomCoor.gameAnim[i][kSeatMine][2] = y - spriteSize[i][2];
	end

	--右玩家
	x, y = self.mahjongManager.mahjongFrame:getPos(kSeatRight);
	w, h = self.mahjongManager.mahjongFrame:getHandCardsSize(kSeatRight);

	y = System.getScreenHeight() / System.getLayoutScale();--改为屏幕中间 (现实中不会出现奇葩的分辨率)
	h = System.getScreenHeight() / System.getLayoutScale();

	for i = 1, 7 do
		RoomCoor.gameAnim[i][kSeatRight][1] = x - spriteSize[i][1];
		RoomCoor.gameAnim[i][kSeatRight][2] = y - h / 2 - spriteSize[i][2] / 2;
	end
	--上玩家

	x, y = self.mahjongManager.mahjongFrame:getPos(kSeatTop);
	w, h = self.mahjongManager.mahjongFrame:getSize(kSeatTop);

	x = 0;--改为屏幕中间 (现实中不会出现奇葩的分辨率)
	w = System.getScreenWidth() / System.getLayoutScale();

	for i = 1, 7 do
		--改为位于高度一半，防止动画偏向 桌子中间
		RoomCoor.gameAnim[i][kSeatTop][1] = x + w / 2 - spriteSize[i][1]/2;
		RoomCoor.gameAnim[i][kSeatTop][2] = y + h/2;
	end

	--左玩家
	x, y = self.mahjongManager.mahjongFrame:getPos(kSeatLeft);
	w, h = self.mahjongManager.mahjongFrame:getHandCardsSize(kSeatLeft);

	y = 0;--改为屏幕中间 (现实中不会出现奇葩的分辨率)
	h = System.getScreenHeight() / System.getLayoutScale();

	for i = 1, 7 do
		RoomCoor.gameAnim[i][kSeatLeft][1] = x + w;
		RoomCoor.gameAnim[i][kSeatLeft][2] = y + h / 2 - spriteSize[i][2] / 2;
	end
	--加减金币动画坐标
	for i = 0, 3 do
		local avatarW, avatarH 	= self.mahjongManager.mahjongFrame:getAvatarSize(i);
		local posX,posY = self.mahjongManager.mahjongFrame:getAvatarPos(i);
		RoomCoor.showMoneyCoor[i][1],RoomCoor.showMoneyCoor[i][2] = posX , posY;
		if i == 1 then
			RoomCoor.showMoneyCoor[i][1] = RoomCoor.showMoneyCoor[i][1] + avatarW;
		end
		RoomCoor.showMoneyCoor[i][2] = RoomCoor.showMoneyCoor[i][2] + avatarH/2;
	end

	--胡 自摸标志坐标

	--下玩家
	local x, y = self.mahjongManager.mahjongFrame:getPos(kSeatMine);
	local w, h = self.mahjongManager.mahjongFrame:getSize(kSeatMine);
	local discardX, discardY = 	self.mahjongManager.mahjongFrame:getDiscardFrame(kSeatMine,1);
	local discardW, discardH = self.mahjongManager.mahjongFrame:getDiscardSize(kSeatMine);

	local flagW = 45  + 40; --图片宽度 - 减8 + 文字宽度
	local flag1W= 83 + 40;--自摸
	local flagH = 45;--图片高度 - 减8 + 文字宽度
	-- 一个时候的位置
	Seat.HuFlagCoorXLCHOne[kSeatMine][1] = x + (w - flagW)/2;
	Seat.HuFlagCoorXLCHOne[kSeatMine][2] = discardY - discardH - 10;
	-- 两个的时候
	Seat.HuFlagCoorXLCH[kSeatMine][1] = x + (w - flagW - flag1W)/2 + flag1W;
	Seat.HuFlagCoorXLCH[kSeatMine][2] = discardY - discardH - 10;

	Seat.zimoFlagCoorXLCH[kSeatMine][1] = x + (w - flagW - flag1W)/2;
	Seat.zimoFlagCoorXLCH[kSeatMine][2] = discardY - discardH - 10;


	--上玩家
	local x, y = 0, 0; --改为居屏幕中间
	local w, h = System.getScreenWidth() / scale, System.getScreenHeight() / scale;

	local discardX, discardY = 	self.mahjongManager.mahjongFrame:getDiscardFrame(kSeatTop,1);
	local discardW, discardH = self.mahjongManager.mahjongFrame:getDiscardSize(kSeatTop);

	-- 一个时候的位置
	Seat.HuFlagCoorXLCHOne[kSeatTop][1] = x + (w - flagW)/2;
	Seat.HuFlagCoorXLCHOne[kSeatTop][2] = discardY + discardH + 10;
	-- 两个的时候
	Seat.HuFlagCoorXLCH[kSeatTop][1] = x + (w - flagW * 2)/2 ;
	Seat.HuFlagCoorXLCH[kSeatTop][2] = discardY + discardH + 10;

	Seat.zimoFlagCoorXLCH[kSeatTop][1] = x + (w - flagW * 2)/2 +  flagW;
	Seat.zimoFlagCoorXLCH[kSeatTop][2] = discardY + discardH + 10;

	--右玩家
	local x, y = self.mahjongManager.mahjongFrame:getPos(kSeatRight);
	local w, h = self.mahjongManager.mahjongFrame:getSize(kSeatRight);
	local discardX, discardY = 	self.mahjongManager.mahjongFrame:getDiscardFrame(kSeatRight,1);
	local discardW, discardH = self.mahjongManager.mahjongFrame:getDiscardSize(kSeatRight);

	-- 一个时候的位置
	Seat.HuFlagCoorXLCHOne[kSeatRight][1] = discardX - 10 - flag1W;
	Seat.HuFlagCoorXLCHOne[kSeatRight][2] = y - (h - flagH)/2 - flagH;
	-- 两个的时候
	local flagSpaceH = 20;
	Seat.HuFlagCoorXLCH[kSeatRight][1] = discardX - 10 - flag1W;
	Seat.HuFlagCoorXLCH[kSeatRight][2] = y - (h - flagH * 2 - flagSpaceH)/2 - flagH;

	Seat.zimoFlagCoorXLCH[kSeatRight][1] = discardX - 10 - flag1W;
	Seat.zimoFlagCoorXLCH[kSeatRight][2] = y - (h - flagH * 2 - flagSpaceH )/2 - 2 * flagH - flagSpaceH;

	--左玩家
	local x, y = self.mahjongManager.mahjongFrame:getPos(kSeatLeft);
	local w, h = self.mahjongManager.mahjongFrame:getSize(kSeatLeft);
	local discardX, discardY = 	self.mahjongManager.mahjongFrame:getDiscardFrame(kSeatLeft,1);
	local discardW, discardH = self.mahjongManager.mahjongFrame:getDiscardSize(kSeatLeft);
	-- 一个时候的位置
	Seat.HuFlagCoorXLCHOne[kSeatLeft][1] = discardX + discardW + 10 ;
	Seat.HuFlagCoorXLCHOne[kSeatLeft][2] = y + (h - flagH)/2 ;
	-- 两个的时候
	local flagSpaceH = 20;
	Seat.HuFlagCoorXLCH[kSeatLeft][1] = discardX + discardW + 10 ;
	Seat.HuFlagCoorXLCH[kSeatLeft][2] = y + (h - flagH * 2 - flagSpaceH) / 2 + flagH + flagSpaceH;

	Seat.zimoFlagCoorXLCH[kSeatLeft][1] = discardX + discardW + 10 ;
	Seat.zimoFlagCoorXLCH[kSeatLeft][2] = y + (h - flagH * 2 - flagSpaceH) / 2 ;
	-- 普通胡牌时胡标志坐标

	local flagW = 45; --图片宽度
	local flagH = 45; --图片高度

	--下玩家
	local x, y = self.mahjongManager.mahjongFrame:getPos(kSeatMine);
	local w, h = self.mahjongManager.mahjongFrame:getSize(kSeatMine);
	local discardX, discardY = 	self.mahjongManager.mahjongFrame:getDiscardFrame(kSeatMine,1);
	local discardW, discardH = self.mahjongManager.mahjongFrame:getDiscardSize(kSeatMine);

	Seat.HuFlagCoor[kSeatMine][1] = x + (w - flagW)/2;
	Seat.HuFlagCoor[kSeatMine][2] = discardY - flagH - 10 - (88 - flagH)/2; -- 88为准备按钮的高度


	--上玩家
	local x, y = 0, 0; --改为居屏幕中间
	local w, h = System.getScreenWidth() / scale, System.getScreenHeight() / scale;

	local discardX, discardY = 	self.mahjongManager.mahjongFrame:getDiscardFrame(kSeatTop,1);
	local discardW, discardH = self.mahjongManager.mahjongFrame:getDiscardSize(kSeatTop);
	Seat.HuFlagCoor[kSeatTop][1] = x + (w - flagW)/2;
	Seat.HuFlagCoor[kSeatTop][2] = discardY + discardH + 10;

	--右玩家
	local x, y = self.mahjongManager.mahjongFrame:getPos(kSeatRight);
	local w, h = self.mahjongManager.mahjongFrame:getSize(kSeatRight);

	local discardX, discardY = 	self.mahjongManager.mahjongFrame:getDiscardFrame(kSeatRight,1);
	local discardW, discardH = self.mahjongManager.mahjongFrame:getDiscardSize(kSeatRight);

	Seat.HuFlagCoor[kSeatRight][1] = discardX - 10 - flagW;
	Seat.HuFlagCoor[kSeatRight][2] = y - (h - flagH)/2 - flagH;

	--左玩家
	local x, y = self.mahjongManager.mahjongFrame:getPos(kSeatLeft);
	local w, h = self.mahjongManager.mahjongFrame:getSize(kSeatLeft);
	local discardX, discardY = 	self.mahjongManager.mahjongFrame:getDiscardFrame(kSeatLeft,1);
	local discardW, discardH = self.mahjongManager.mahjongFrame:getDiscardSize(kSeatLeft);
	-- 一个时候的位置
	Seat.HuFlagCoor[kSeatLeft][1] = discardX + discardW + 10 ;
	Seat.HuFlagCoor[kSeatLeft][2] = y + (h - flagH)/2 ;

	--单机 再来一局按钮 坐标
	local againW, againH = 243, 88;
	local onlineW, onlineH = 243, 88;
	local againOnlineSpaceW = 120;

	local x, y = self.mahjongManager.mahjongFrame:getPos(kSeatMine);
	local w, h = self.mahjongManager.mahjongFrame:getSize(kSeatMine);
	local discardX, discardY = 	self.mahjongManager.mahjongFrame:getDiscardFrame(kSeatMine,1);
	local discardW, discardH = self.mahjongManager.mahjongFrame:getDiscardSize(kSeatMine);

	Seat.againCoor[1] = x + (w - againW - onlineW - againOnlineSpaceW) / 2;
	Seat.againCoor[2] = discardY - againH - 10;


	--本局所得金钱信息 坐标

	local x, y = self.mahjongManager.mahjongFrame:getAvatarPos(0);
	local w, h = self.mahjongManager.mahjongFrame:getAvatarSize(0);

	local pJsmoneyBg = self:getControl(RoomScene.s_controls.jsmoneyBg)
	pJsmoneyBg:setPos(x,y + h + 9);
	--money 缩小84%
	local coinIcon = publ_getItemFromTree(pJsmoneyBg, {"img_icon_coin"})
	coinIcon:addPropScaleSolid(1, 0.84, 0.84, kCenterDrawing);

	local pText = self:getControl(RoomScene.s_controls.mt)
	pText:addPropScaleSolid(1, 0.84, 0.84, kCenterDrawing);

	--选缺坐标
	local selectW, selectH = 158, 146;
	local x, y = self.mahjongManager.mahjongFrame:getPos(kSeatMine);
	local w, h = self.mahjongManager.mahjongFrame:getSize(kSeatMine);

	SelectQueView.selectCoor[1] = x + (w - selectW * 3 - 60*2)/2;
	SelectQueView.selectCoor[2] = y - selectH - 5;

	--选缺小图标
	local SelectFlagW, selectFlagH = 111,53; --水平
	local SelectFlag1W, selectFlag1H = 70,70; --水平

	--下玩家
	local x, y = self.mahjongManager.mahjongFrame:getPos(kSeatMine);
	local w, h = self.mahjongManager.mahjongFrame:getSize(kSeatMine);

	SelectQueView.coor[kSeatMine][1] = x + (w - SelectFlag1W)/2;
	SelectQueView.coor[kSeatMine][2] = y - selectFlag1H - 20;

	--上玩家
	local x, y = self.mahjongManager.mahjongFrame:getPos(kSeatTop);
	local w, h = self.mahjongManager.mahjongFrame:getSize(kSeatTop);

	x = 0; --改为居屏幕中间
	w = System.getScreenWidth() / System.getLayoutScale();

	SelectQueView.coor[kSeatTop][1] = x + (w - SelectFlagW)/2;
	SelectQueView.coor[kSeatTop][2] = y + h + 20;

	--选缺小图标
	local SelectFlagW, selectFlagH = 52,114; --垂直

	--右玩家
	local x, y = self.mahjongManager.mahjongFrame:getPos(kSeatRight);
	local w, h = self.mahjongManager.mahjongFrame:getSize(kSeatRight);

	SelectQueView.coor[kSeatRight][1] = x - 20 - SelectFlagW;
	SelectQueView.coor[kSeatRight][2] = y - (h - selectFlagH)/2 - selectFlagH ;

	--左玩家
	local x, y = self.mahjongManager.mahjongFrame:getPos(kSeatLeft);
	local w, h = self.mahjongManager.mahjongFrame:getSize(kSeatLeft);

	SelectQueView.coor[kSeatLeft][1] = x + w + 20;
	SelectQueView.coor[kSeatLeft][2] = y + (h - selectFlagH)/2;
	--托管坐标
	local tuoGuanW,tuoGuanH = 376,431;
	-- local x, y = self.mahjongManager.mahjongFrame:getPos(kSeatMine);
	-- local w, h = self.mahjongManager.mahjongFrame:getSize(kSeatMine);
	local x, y = 0,System.getScreenHeight() / System.getLayoutScale();
	local w, h = System.getScreenWidth() / System.getLayoutScale(), 0;
	RoomCoor.tuoGuanAniPos[1]= x + w - tuoGuanW;
	RoomCoor.tuoGuanAniPos[2]= y + h - tuoGuanH;
	--tips坐标
	local x, y = self.mahjongManager.mahjongFrame:getPos(kSeatMine);
	local w, h = self.mahjongManager.mahjongFrame:getSize(kSeatMine);
	local discardX, discardY = 	self.mahjongManager.mahjongFrame:getDiscardFrame(kSeatMine,1);
	local discardW, discardH = self.mahjongManager.mahjongFrame:getDiscardSize(kSeatMine);
	--绿色为出过的牌
	local outCardTipW, outCardTipH = 302, 32;
	RoomCoor.showTipCoor[1][1] = x + (w - outCardTipW) / 2;
	RoomCoor.showTipCoor[1][2] = discardY - outCardTipH;
	--还有多少张牌查大叫
	local leftCardW, leftCardH = 250, 24;
	RoomCoor.showTipCoor[2][1] = x + (w - leftCardW) / 2;
	RoomCoor.showTipCoor[2][2] = discardY - leftCardH;
	--最后四张才能胡牌
	RoomCoor.showTipCoor[3][1] = x + (w - leftCardW) / 2;
	RoomCoor.showTipCoor[3][2] = discardY - leftCardH;
	--显示被踢出房间提示 的坐标
	RoomCoor.kickOutTip[1] = (System.getScreenWidth() / System.getLayoutScale() - 250)/2;
	RoomCoor.kickOutTip[2] = 255 * System.getScreenHeight() / System.getLayoutHeight() / System.getLayoutScale();
	 --DaFanXin的动画坐标(中心坐标)
	for i = 0 , 3 do
		local posX , posY = self.mahjongManager.mahjongFrame:getAvatarPos(i);
		RoomCoor.daFanXinCoor[i][1], RoomCoor.daFanXinCoor[i][2] = posX , posY;
		local avatarW, avatarH = self.mahjongManager.mahjongFrame:getAvatarSize(i);
		RoomCoor.daFanXinCoor[i][1] = RoomCoor.daFanXinCoor[i][1] + avatarW / 2;
		RoomCoor.daFanXinCoor[i][2] = RoomCoor.daFanXinCoor[i][2] + avatarH / 2;
	end

	--结算界面的破产提示
	local bankruptW, bankruptH = 134, 100;
	--主玩家
	for i = 0, 3 do
		local x, y = self.mahjongManager.mahjongFrame:getAvatarPos(i);
		GameResultWindow.bankraptcyCoord[i][1] = x - 15;
		GameResultWindow.bankraptcyCoord[i][2] = y - bankruptH + 110;
	end
	-- -- 比赛场
	-- for i = 0, 3 do
	-- 	local x, y = self.mahjongManager.mahjongFrame:getAvatarPos(i);
	-- 	GameResultWindowMatch.bankraptcyCoord[i][1] = x - 15;
	-- 	GameResultWindowMatch.bankraptcyCoord[i][2] = y - bankruptH + 110;
	-- end

	self:createSeat();
	self:showReadyBtn()

	self:createSettingView();

	self:startTimer();
	self.turnToSeat = -1;  -- 轮到谁来打牌

	-- 播放背景音乐
	self.mySex = PlayerManager.getInstance():myself().sex;
	GameConstant.curGameSceneRef = self;
	self:playBackGroundMusic("bgm")
	self.dafanxinAnimList = {};

	self.quickChatBtn = UICreator.createBtn(seatPinx_map["quickchat.png"]);
	self.quickChatBtn:setPos(self.mahjongManager.mahjongFrame:getChatBtnPos());
	self.quickChatBtn:setOnClick(self, self.chat);
	self.mahjongManager.mineToolBar:addChild(self.quickChatBtn);

	local data = {};
	for i =1, 4 do
		player = PlayerManager.getInstance():getPlayerBySeat(i-1);
		if player then
			table.insert(data, player.mid);
		end
	end
	-- data = {12636027,12636029,12636027,12636029};  -- debug
	if RoomData.getInstance().inFetionRoom then
		FriendDataManager.getInstance():requestFetionScore(data);
		self.fetionScorePop = new(FetionScorePop, self);
	end

	self.quickPay = self:getControl(RoomScene.s_controls.quickPay);
	-- --重新设置快充坐标
	local x, y = self.mahjongManager.mahjongFrame:getAvatarPos(kSeatRight);
	local w, h = self.mahjongManager.mahjongFrame:getAvatarSize(kSeatRight);
	local payW, payH = self.quickPay:getSize();
	local mx, my = self.mahjongManager.mahjongFrame:getPos(kSeatMine);

	self.quickPay:setPos(x + (w - payW) / 2-5, my - payH - 60);

	self.quickPay:setOnClick(self,self.quickCharge);
	if GameConstant.isSingleGame then
		self.quickPay:setVisible(false);
	end

	if GameConstant.platformType == PlatformConfig.platformContest then
		self.quickPay:setVisible(false);
		-- self.taskWnd:setVisible(false);
	end
	if GameConstant.checkType == kCheckStatusOpen then  --审核状态
		self.quickPay:setVisible(false)
	end

	self.reconnectRoom = false;
	self.chatLogs = {}; -- 当前局的聊天记录
	--首先进去不显示时间
	--self:getControl(RoomScene.s_controls.gameType):setVisible(false);
	--self:getControl(RoomScene.s_controls.di):setVisible(false);
	self:showTableInfo(1,false)
	--self:setRoomDisplayInfo(1)----玩法位置


	--减轻其他activity返回时候的黑屏问题
	local backGround = self:getControl(RoomScene.s_controls.backGround);
	sys_set_int("res_image_reload_pass0", backGround.m_res.m_resID );

	-- 检查是否安装微信
	if PlatformConfig.platformYiXin ~= GameConstant.platformType then
		checkWechatInstalled();
	end

	--
	self:getControl(RoomScene.s_controls.exitBtn):setOnClick(self, function ( self )
		self:exitGameRequire()
	end)
	-- 初始化新手引导
	local teachNode = new(TeachManager, screenW - screenW/4, screenH/2 - 50 + 2, screenW, screenH);
	self.chatNode:addChild(teachNode);
	TeachManager.setInstance(teachNode);

	self:initBroadCastView();
	self:initReconnectBtn();

	if PlatformConfig.platformWDJ == GameConstant.platformType or
	   PlatformConfig.platformWDJNet == GameConstant.platformType then
		self.RDI.logo:setFile("Login/wdj/Room/roomInfo/logo.png");
	elseif PlatformConfig.platformYiXin == GameConstant.platformType then
		self.RDI.logo:setFile("Login/yx/Room/roomInfo/logo.png");
		self.RDI.logo:setSize(319,64);
	end

	self.timeIntervalImg = self:getControl(RoomScene.s_controls.signalImg);
	if DEBUGMODE == 1 then--剩余            张",0,45,200,26,kAlignCenter,22, 0x17 , 0xe3 , 0x77
		self.timeIntervalText = UICreator.createText("",75,30,30,30,kAlignTopLeft,24, 0xff, 0xff, 0xff)
		self:getControl(RoomScene.s_controls.backGround):addChild(self.timeIntervalText)
	end

--	local t = {}
--	t.hongbaoId = 1
--	self:recieveHongBaoNews(HongBaoModel.recieveNewHongBao,t)
	if GameConstant.iosDeviceType>0 and GameConstant.iosPingBiFee then
		self:hideChestStartup();
	end

end


function RoomScene.updateTimeInterval( self, interval )
	if self.timeIntervalImg and interval then
		if interval > 0 and interval <= 100 then
			self.timeIntervalImg:setFile( "Room/signal5.png")
		elseif interval > 100 and interval <= 200 then
			self.timeIntervalImg:setFile( "Room/signal4.png")
		elseif interval > 200 and interval <= 400 then
			self.timeIntervalImg:setFile( "Room/signal3.png")
		elseif interval > 400 and interval <= 600 then
			self.timeIntervalImg:setFile( "Room/signal2.png")
		elseif interval > 600 and interval < 1000 then
			self.timeIntervalImg:setFile( "Room/signal1.png")
			Banner.getInstance():showMsg( "当前网络不佳,请检查下网络！" );
		else
			self.timeIntervalImg:setFile( "Room/signal0.png")
			Banner.getInstance():showMsg( "当前网络不佳,请检查下网络！"  );
		end
		if DEBUGMODE == 1 and self.timeIntervalText then
			self.timeIntervalText:setText(interval .. "ms")
		end
		--
	end
end

function RoomScene.initReconnectBtn( self )
	-- if DEBUGMODE == 1 then
	-- 	self.btn_reconnect = self:getControl(RoomScene.s_controls.reconnectBtn);
	-- 	self.btn_reconnect:setVisible(true);
	-- 	self.btn_reconnect:setOnClick( self, function( self )
 --            isClickBackToReconnect = true;
	-- 		SocketManager.getInstance():socketCloseAndOpen()
	-- 		--SocketManager.getInstance():syncClose();
	-- 		--SocketManager.getInstance():openSocket();
	-- 	end);
	-- end
end

function RoomScene.testKeyEvent( self, key )
    if DEBUGMODE ~= 1 then
        return;
    end
    DebugLog( "key = "..key );
    if key == 84 then -- T 按键
		local param = {};
		param.mid = PlayerManager.getInstance():myself().mid;
		SocketManager.getInstance():sendPack(CLIENT_COMMAND_REQ_LOGOUT, param);
    end
end

-- 认输弹窗
RoomScene.showQuitPopWin = function ( self, data, timeFlag )
	if self.quitPopWin then
		self.nodePopu:removeChild(self.quitPopWin, true);
		self.quitPopWin = nil;
	end

	require("MahjongRoom/QuitPopWin");
	self.quitPopWin = new(QuitPopWin, data, self.nodePopu, timeFlag);
	self.quitPopWin:setLevel(600);
end


-- 比赛奖状窗口
RoomScene.showCertificateWindow = function ( self )
	GameConstant.curRoomLevel = 80;
	local data = {};
	data.matchName = "掉金币比赛";
	data.rank = 1;
	data.awardString = "100,000,000金币";
    local data = {name = data.matchName, rank = data.rank, awardString = data.awardString, is_large_award = data.is_large_award};
	self.certificateWnd = new(CertificateWindow, data);
	self.certificateWnd:show();
end

RoomScene.showFirstChargeView = function ( self, noEnoughMoney )
	local firstChargeWnd = FirstChargeView.getInstance();
	firstChargeWnd:setNoEnoughMoney( noEnoughMoney );
	firstChargeWnd:setRoomLevel( GameConstant.curRoomLevel );
	firstChargeWnd:show();
	return 1 == FirstChargeView.getInstance().isOpenFirstChargeView;
end

function RoomScene.setOutCardTimer(self , seat , time)
	if not self.outCardTimer then
		self.outCardTimer = new(OutCardTimer);
		self.outCardTimer:setAlign(kAlignCenter);
		self.outCardTimer:setPos(0, -50+15);
		self.nodeRoomItem:addChild(self.outCardTimer);
	end
	self.outCardTimer:show(seat , time);
end

function RoomScene.setOutCardTimerAudioFlag(self , flag)
	if not self.outCardTimer then
		self.outCardTimer = new(OutCardTimer);
		self.outCardTimer:setAlign(kAlignCenter);
		self.outCardTimer:setPos(0, -50+15);
		self.nodeRoomItem:addChild(self.outCardTimer);
	end
	self.outCardTimer:setNeedPlayAudio(flag);
end

-- 显示胡牌提示
RoomScene.showHuCardTips = function( self, data )
	log( "RoomScene.showHuCardTips" );
	HuCardTipsManager.getInstance():setHuCardTips( self.mahjongManager:getMineInHandCards(), data );
end

RoomScene.quickCharge = function ( self )

	umengStatics_lua(kUmengInRoomPayBtn);
    local param_t = {t = RechargeTip.enum.enter_game,
        isShow = true, roomlevel = GameConstant.curRoomLevel, money= requireMoney,
        is_check_bankruptcy = false,
        is_check_giftpack = true,};
    if GameConstant.platformType == PlatformConfig.platformChubao then
   		param_t.isShow = true
   	end
    RechargeTip.create(param_t)
end

RoomScene.dtor = function(self)

    if self.resultFinal then
        delete(self.resultFinal);
        self.resultFinal = nil;
    end
	showOrHide_sprite_lua(1);
	self:unregisterAllEvent();
	FriendDataManager.getInstance():removeListener(self,self.friendDataControlled);
	delete(self.swapCardAnim);
	self.swapCardAnim = nil;
	GameConstant.isInRoom = false;
	GameConstant.getingRoomActivityDetail = false;


	ExpressionAnim.release();
	for k, v in pairs(self.dafanxinAnimList) do
		v:stop();
	end
	if self.resultView then
		delete(self.resultView);
		self.resultView = nil;
	end
	if self.awardAnim then
		delete(self.awardAnim);
		self.awardAnim = nil;
	end
	if self.awardLightAnim then
		delete(self.awardLightAnim);
		self.awardLightAnim = nil;
	end

	self.reconnectRoom = false;
	--self:unregisterAllEvent()

	delete(self.myBroadcast);
	self.myBroadcast = nil;

	DebugLog("RoomScene dtor");
	delete(self.mahjongManager);
	self.mahjongManager = nil;
	delete(self.showResultAnim);
	self.showResultAnim = nil;
	self.selectQueView = nil;
	delete(self.seatManager);
	ShaiziAnimation.release();
	self.tuoGuanAni = nil;
	self:stopTimeOutTip(); -- 释放超时踢出anim
	delete(self.timerAnim);
	self.leftCardNumText = nil;
	self.leftCardNumStatic = nil;
	self.m_root:removeAllChildren();
	GameMusic.getInstance():stop();

	RoomScene_instance = nil;
	GameConstant.curGameSceneRef = nil;

	BroadcastMsgManager.getInstance():push();
	if GameConstant.iosDeviceType>0 then
			local statuslist = {};
			statuslist.status = 0;
			native_to_java("iosEnterRoomStatus",json.encode(statuslist));
		end
	DebugLog("【房间释放完成】");
end

RoomScene.downloadImgSuccess = function(self, name)
	if name ~= nil and self.RDI and self.RDI.roomName then
		self.RDI.roomName:setFile(name)
		-- self:getControl(RoomScene.s_controls.roomName):setFile(name);
	end
end

-- 显示当前时间
RoomScene.startTimer = function ( self )
	self.timerAnim = new(AnimInt, kAnimLoop, -1, -1, 1000, -1);
	self.timerAnim:setDebugName("RoomScene|self.timerAnim");
	self.timerAnim:setEvent(self, RoomScene.updataTimer);
	self:getControl(RoomScene.s_controls.timePoint):setText(":");

end

RoomScene.updataTimer = function ( self )

	local curHour = os.date("*t",os.time()).hour;
    local curMin  = os.date("*t",os.time()).min;

    if curHour < 10 then
    	curHour = "0"..curHour;
    end
    if curMin < 10 then
    	curMin = "0"..curMin;
    end

    local pointX, pointY = 66, 10;

    local scaleW = System.getScreenWidth() / System.getLayoutWidth() / System.getLayoutScale();
	local scaleH = System.getScreenHeight() / System.getLayoutHeight() / System.getLayoutScale();

	pointX, pointY = pointX * scaleW, pointY * scaleH;

	local pointW, pointH = self:getControl(RoomScene.s_controls.timePoint):getSize();
	-- self:getControl(RoomScene.s_controls.timePoint):setPos(pointX - pointW/2,pointY - pointH/2);
	local timePoint = self:getControl(RoomScene.s_controls.timePoint);
    timePoint:setVisible(not timePoint.m_visible);


	local hourW, hourH = self:getControl(RoomScene.s_controls.timeHour):getSize();
    self:getControl(RoomScene.s_controls.timeHour):setText(curHour);

    local minW, minH = self:getControl(RoomScene.s_controls.timeMin):getSize();
	-- self:getControl(RoomScene.s_controls.timeMin):setPos(pointX + pointW/2,pointY - minH / 2 + 1);
    self:getControl(RoomScene.s_controls.timeMin):setText(curMin);
end

-- 显示剩余牌数
RoomScene.showLeftCardNum = function ( self, leftNum )
	if not self.leftCardNumStatic then
		self.leftCardNumStatic = UICreator.createText( "剩余            张",0,45,200,26,kAlignCenter,22, 0x17 , 0xe3 , 0x77 );
		self.leftCardNumStatic:setAlign(kAlignCenter);
		self.nodeRoomItem:addChild(self.leftCardNumStatic);

		self.leftCardNumText = UICreator.createText( "", 10, 45, 50, 26, kAlignCenter, 26, 0xff, 0xea, 0x73);
		self.leftCardNumText:setAlign(kAlignCenter);
		self.nodeRoomItem:addChild(self.leftCardNumText);
	end
	self.leftCardNumStatic:setVisible(true);
	self.leftCardNumText:setVisible(true);
	local text = GameString.convert2Platform(leftNum);
	self.leftCardNumText:setText(text);
end

-- 创建房间座位按钮节点
RoomScene.createSeat = function ( self )
	local seatMgr = self.seatManager;
	self.nodeRoomItem:addChild(seatMgr:getSeatByLocalSeatID(kSeatRight));
	self.nodeRoomItem:addChild(seatMgr:getSeatByLocalSeatID(kSeatTop));
	self.nodeRoomItem:addChild(seatMgr:getSeatByLocalSeatID(kSeatLeft));
	self.nodeRoomItem:addChild(seatMgr:getSeatByLocalSeatID(kSeatMine));
	for k,v in pairs(seatMgr.seatList) do
		v:setChatNode(self.chatNode);
		v:setUserInfoNode(self.nodePopu);
		v:setOnInviteClickEvent(self,self.onClickedInviteFriendCallback)
	end
	seatMgr:getSeatByLocalSeatID(kSeatMine):setReadyBtnFun( self, self.readyAction );
end



function RoomScene:onClickedInviteFriendCallback( )

	if not self.m_inviteRoomWindow then
		self.m_inviteRoomWindow = new(InviteFriendWindow,tonumber(RoomData.getInstance().level));
		self.nodePopu:addChild(self.m_inviteRoomWindow);
		self.m_inviteRoomWindow:setOnWindowHideListener(self, function( self )
			self.m_inviteRoomWindow = nil
		end);

		self.m_inviteRoomWindow:showWnd()
	end

end

-- 打牌过程不显示该信息


RoomScene.showBankruptInSingle = function ( self , time)
	require("MahjongSingleGame/Client/BankruptcyDlgInSingle");
	self.bankcruptWnd = new(BankruptcyDlgInSingle, time);
	self.nodePopu:addChild(self.bankcruptWnd);
end

-- 准备时候，如果服务器判断到金币不足，会返回换桌（因金币不足，换桌会失败，回到大厅）和金币不足的踢人命令。
RoomScene.readyAction = function ( self )
	DebugLog("RoomScene.readyAction");
	-- if true then
	-- 	require("MahjongCommon/animProp")
	-- 	self.settingBtn = self:getControl(RoomScene.s_controls.settingBtn);
	-- 	-- AnimProp.addPropTranslate(self.settingBtn , 0 , 400 , 0 , 0 , 2000 , 0 , kAnimLoop , Acceleration)
	-- 	AnimProp.addPropBessel(self.settingBtn , 0 , 400 , 1 , 0 , 2000 , 0 , kAnimLoop)
	-- 	-- AnimProp.addPropColor(self.settingBtn , 400 , 400 , 0 , 0 , 2000 , 0 , kAnimLoop , Acceleration)
	-- 	-- AnimProp.addPropTransparency(self.settingBtn , 400 , 400 , 0 , 0 , 2000 , 0 , kAnimLoop , Acceleration)
	-- 	return
	-- end
	if PlayerManager.getInstance():myself().isReady then
		return;
	end
	if GameConstant.isSingleGame then --单机破产
		if 0 > PlayerManager.getInstance():myself().money then
			local timemark = g_DiskDataMgr:getAppData('singletimemark',-1)
			local time = 0;
			if 0 > timemark then
				g_DiskDataMgr:setAppData('singletimemark',os.time())
				self:showBankruptInSingle(GameConstant.singleBankruptTime);
			else
				time = GameConstant.singleBankruptTime - (os.time()-timemark);
				if time <= 0 then
					self:showBankruptInSingle(0);
				else
					self:showBankruptInSingle(time);
				end
			end

			return;
		end
	end

	if PlatformConfig.platformContest ~= GameConstant.platformType then
		if not self:judgeMoneyAndShowChargeWnd() then -- 客户端判断到金币不足，显示金币购买弹窗
			return;
		end
	end
	for k,v in pairs(self.seatManager.seatList) do
		v:changeToWaitStaty();
		if v.seatID == 0 then
			v.isSingleGameFirst = false;
		end
	end

	if GameConstant.isSingleGame then
		self:readyActionToServer()
		self:clearDesk();
	else
		if not self:useChangeTable() then
			DebugLog("request ready  not change table")
			self:readyActionToServer()
			self:clearDesk();
		end
	end
end

RoomScene.useChangeTable = function( self )
	DebugLog("RoomScene.useChangeTable")
	DebugLog("level: "..tostring(RoomData.getInstance().level ))

	local userMoney = PlayerManager.getInstance():myself().money;

--[[
	if GameConstant.go_to_high then --要去高倍场
		DebugLog("GameConstant.go_to_high")
		local data = {};
		data.result = 0;
		self.m_controller:changeTable( data );
		return true;
	end
]]--
	DebugLog("not GameConstant.go_to_high")
	local allDatas = HallConfigDataManager.getInstance():returnDataByLevel( RoomData.getInstance().level );

	if not allDatas or not allDatas.uppermost or not allDatas.xzrequire then
		DebugLog("not allDatas")
		return false;
	end
	DebugLog("userMoney: "..tostring(userMoney))
	DebugLog("allDatas.uppermost: "..allDatas.uppermost)
	DebugLog("allDatas.xzrequire: "..allDatas.xzrequire)
	if userMoney > allDatas.uppermost or userMoney < allDatas.xzrequire then
		DebugLog("need change table")
		local data = {};
		data.result = 0;
		self:changeTable( data );
		return true;
	else
		return false;
	end
end

RoomScene.goToHigh = function ( self )
	-- body
	local data = {};
	data.result = 0;
	self:changeTable( data );
end

-- 打牌
RoomScene.outCardRequest = function (self , value)
	GameEffect.getInstance():play("AUDIO_OC");
	if self.mySex == 0 then
		GameEffect.getInstance():play("m"..value);  --播放男声出牌
	else
		GameEffect.getInstance():play("w"..value);  --播放女声出牌
	end
	self.mahjongManager:setAllMahjongFrameDown();
	self.mahjongManager:setMineInHandCardsWhenWait();
	self:outCardAction(value)
end

--显示充值活动按钮
RoomScene.showAwardBtn = function( self, data )
	DebugLog("RoomScene.showAwardBtn")
	if GameConstant.isSingleGame then
		DebugLog("danji")
		return;  --单机中不显示宝箱
	end
	local activityState = tonumber(data.data.open) or 0;
	local boxType = tonumber(data.data.award) or 0;
	local awardBtn = self:getControl(RoomScene.s_controls.AwardBtn);

	DebugLog("activityState "..activityState);
	DebugLog("award "..activityState);

	if activityState == 1 and self.isInSocketRoom and not (boxType == 2) then
		if boxType == 1 then --可以领奖
			awardBtn:setFile("Room/chest/awardBox.png");
		else
			awardBtn:setFile("Room/chest/box.png");
		end
		awardBtn:setVisible(true);
		self.awardLight = self:getControl(RoomScene.s_controls.AwardLight);
		self.awardLight:addPropRotate(1, kAnimRepeat, 4500, 0, -360, 0, kCenterDrawing);
		self.awardLight:setVisible(true);
		awardBtn:setOnClick(self, function( self )
			umengStatics_lua(kUmengRoomPayBoxBtn);
			self.activityWinow = new(RoomActivity, self.m_root, self);
			self:getRoomActivityDetail()
		end);
	else
		awardBtn:setVisible(false);
		self:getControl(RoomScene.s_controls.AwardLight):setVisible(false);
	end
end

RoomScene.updateAwardWindow = function( self, data )
	if GameConstant.roomActivityShowing then
		self.activityWinow:updateInfo(data);  --正在显示时更新数据
	end
end

RoomScene.changeFrameCount = function( self, count )
	self.mahjongManager:changeFrameCount(count);
end


-- 操作栏
RoomScene.createSettingView = function ( self )
	local setBtn = self:getControl(RoomScene.s_controls.settingBtn);
	setBtn:setOnClick(self, RoomScene.gameSet);
end

RoomScene.hideSettingBar = function ( self )

end

RoomScene.showSettingBar = function ( self )
	-- 处于显示状态或者正在动画中
	if self.settingView.m_y > 0 or self.settingView.isAniming then
		return;
	end
	local settingBarAnim = self.settingView:addPropTranslate(1, kAnimNormal, 400, 0, 0, 0, 0, 400);
	self.settingView.isAniming = true;
	self.showBtn:setEnable(false);
	settingBarAnim:setEvent(self, function ( self )
		self.settingView.isAniming = false;
		self.showBtn:setVisible(false);
		self.settingView:removeProp(1);
		self.settingView:setPos(self.settingView.m_x, self.settingView.m_y + 400);
	end);
end

RoomScene.toHall = function ( self )
	self:exitGameRequire()
end

RoomScene.gameSet = function ( self )
--test
-- if true then
-- 	DebugLog("self:showMyselfSelectQueView");
-- 	self:showMyselfSelectQueView();
-- 	return;
-- end
--end
	require("MahjongRoom/RoomSettingWindow");
	self.settingWnd = new(RoomSettingWindow , self);
	self.nodePopu:addChild(self.settingWnd);
	self.settingWnd:show();
end

RoomScene.chat = function ( self )
	self:openQuickChatWnd();
end

RoomScene.openQuickChatWnd = function ( self )
	if not self.chatWnd then
		self.chatWnd = new(QuickChatWnd);
		self.chatWnd:setCallback(self, function ( self, beShow )
			if beShow then -- 显示时的回调

			else -- 隐藏时的回调
				-- 要delete弹窗的话，就在这里添加逻辑
				delete(self.chatWnd);
				self.chatWnd = nil;
			end
		end);
		local chatWndW, chatWndH = 630, 410;


		self.nodePopu:addChild(self.chatWnd);
	end
	self.chatWnd:show(self.chatLogs);
end

RoomScene.gameHelp = function ( self )

end

-- 刚进房间时，初始化当前房间内的玩家
RoomScene.initIngamePlayer = function ( self )
	local playerMgr = PlayerManager.getInstance();
	for k,v in pairs(playerMgr.playerList) do
		self:playerEnterGame(v);
	end
end

RoomScene.handleCmd = function(self, cmd, ...)
	if not self.s_cmdConfig[cmd] then
		FwLog("Scene, no such cmd  "..cmd);
	end
	return self.s_cmdConfig[cmd](self,...);
end

RoomScene.playerEnterGame = function ( self, player )
	local seat = self.seatManager:getSeatByLocalSeatID(player.localSeatId,self);
	if seat then
		seat:setData(player);
	end
end

-- 直接重连时刚好游戏结束的处理逻辑
RoomScene.reconnectGameDirectWhenOver = function ( self, player )
	local seat = self.seatManager:getSeatByLocalSeatID(player.localSeatId, self);
	if seat then
		seat:setData(player);
	end
	--[[
	if self.outCardTimer then
		self.outCardTimer:hide();
	end

	if self.leftCardNumText then
		self.leftCardNumText:setVisible(false);
		self.leftCardNumStatic:setVisible(false);
	end
	]]
end

RoomScene.taskComplitePush = function ( self, data )
	-- if self.taskWnd then
	-- 	self.taskWnd:taskComplitePush(data.taskId, data.result);
	-- end
end

RoomScene.playerChangeReadyStatu = function ( self, player )
	local seat = self.seatManager:getSeatByLocalSeatID(player.localSeatId,self);
	seat:setReadyStatu(player.isReady);
end

RoomScene.showOrHideTimeOutTip = function ( self, bShow, time )
	if bShow then
		self:showTimeOutTip(time);
	else
		self:stopTimeOutTip();
	end
end


RoomScene.showTimeOutTip = function ( self, time )
	if self.showingTimeOutTip then -- 如果正在显示踢出提示，先关闭
		self:stopTimeOutTip();
	end

	local time = time; -- 超时事件
	local str = GameString.convert2Platform("您不准备会被踢出:  ");
	if not self.timeOutBg then
		-- self.timeOutText = UICreator.createText( str..time, 0, 0, 250, 24, kAlignCenter, 18, 228, 161, 41);
		if time < 0 then
			time = 0;
		end
		if time > 99 then
			time = 99;
		end
		local units = 0;  --个位
		local tens = 0;  --十位
		units = time % 10;
		tens = getIntPart(time / 10);
		if not self.tensImg and not self.unitsImg then
			local timePin_map = require("qnPlist/timePin")

			self.tensImg = UICreator.createImg(timePin_map[tens..".png"], 17, 22)
			self.unitsImg = UICreator.createImg(timePin_map[units..".png"], 43, 22)
			self.tensImg:setSize(self.tensImg.m_res.m_width,self.tensImg.m_res.m_height)
			self.unitsImg:setSize(self.unitsImg.m_res.m_width,self.unitsImg.m_res.m_height)
		end
		self.timeOutBg = UICreator.createImg( "Commonx/zhezhao.png", 0, 0);
		self.timeOutBg:setSize(73, 73);
		self.timeOutBg:setPos(3, 7);
		self.timeOutBg:addChild(self.tensImg);
		self.timeOutBg:addChild(self.unitsImg);
		-- self.nodeRoomItem

		self.seatManager:getSeatByLocalSeatID(kSeatMine, self).iconBtn:addChild(self.timeOutBg);
	end
	self.showingTimeOutTip = true;
	self.timeOutBg:setVisible(true);
	-- self.timeOutText:setText(str..time);
	self.kickTimeAnim = new(AnimInt,kAnimRepeat,-1,-1,1000,-1);
	self.kickTimeAnim:setDebugName("RoomScene|self.kickTimeAnim");
	self.kickTimeAnim:setEvent(self, function ( self )
		time = time - 1;
		if -1 == time then -- 注意：如果服务器踢出命令先过来，这里不会被调用到
			self:stopTimeOutTip();
			self:kickTimeOut()
		else
			-- self.timeOutText:setText(str..time); -- 刷新时间
			if time < 0 then
				time = 0;
			end

			if time <= 3 and time > 0 then
				GameEffect.getInstance():play("AUDIO_TIPS");
			end

			if time > 99 then
				time = 99;
			end
			local units = 0;  --个位
			local tens = 0;  --十位
			units = time % 10;
			tens = getIntPart(time / 10);
			if self.tensImg and self.unitsImg then
				self.tensImg:setFile(timePin_map[tens..".png"]);
				self.unitsImg:setFile(timePin_map[units..".png"]);
				self.tensImg:setSize(self.tensImg.m_res.m_width,self.tensImg.m_res.m_height)
				self.unitsImg:setSize(self.unitsImg.m_res.m_width,self.unitsImg.m_res.m_height)
			end
		end
	end);
end

RoomScene.stopTimeOutTip = function ( self )
	if self.timeOutBg then
		self.timeOutBg:setVisible(false);
	end
	delete(self.kickTimeAnim);
	self.kickTimeAnim = nil;
	-- delete(self.timeOutBg);
	-- self.timeOutBg = nil;
	self.showingTimeOutTip = false;
end

-- 准备开始游戏 摇骰 定庄
RoomScene.readyStartGame = function ( self, data )
	if RoomData.getInstance().inFetionRoom then
		local mySeat = self.seatManager:getSeatByLocalSeatID( kSeatMine );
		mySeat.fetionInviteLeft:setVisible(false);
		mySeat.fetionInviteRight:setVisible(false);
	end
	RoomData.getInstance().mineCurGameWinMoney = 0;
	if self.m_inviteRoomWindow then   --邀请好友弹框
		self.m_inviteRoomWindow:hideWnd()
	end

	self:showTableInfo(2,true)

	local seatMgr = self.seatManager;
	seatMgr:changeToStartGameStatu(true);
	seatMgr:getSeatByLocalSeatID(data,self):setBankSeat();
	ShaiziAnimation.setDelegate(self, data);
	local shaiziNode = ShaiziAnimation.play(RoomCoor.shaizhiAni.x, RoomCoor.shaizhiAni.y, RoomCoor.shaizhiAni.w, RoomCoor.shaizhiAni.h);
	if shaiziNode then
		self.nodeOperation:addChild(shaiziNode);
	end
end

RoomScene.playerExitGame = function ( self, player )
	local seatPlayer = self.seatManager:getSeatByLocalSeatID(player.localSeatId,self);
	if seatPlayer then
		seatPlayer:clearData();
	end
end

-- 广播发牌
RoomScene.startGameDealCard = function (self , data, serviceFee)
	if GameConstant.higherInviteRefuse then  --只有在被拒绝以后才开始计数
		GameConstant.playedCountAtferRefuse = GameConstant.playedCountAtferRefuse + 1;  --高场次邀请玩牌计数
	end
	self.mahjongManager:setPlayersMahjong(data);

	if serviceFee then
		PlayerManager.getInstance():myself():addMoney(-serviceFee);
	end
end

-- 广播当前的摸牌玩家
RoomScene.broadcastCurrentPlayer = function (self ,data)
	if self.operationView then -- 隐藏
		self.operationView:hideOperation();
	end
	self.reconnectRoom = false;
	self.chiPengGangCard = 0;
	self.mahjongManager:showBigCardCenterDiscard();
	-- 移除中心显示的打出牌
	self.mahjongManager:removeBigShowCenterView();

	local player = PlayerManager.getInstance():getPlayerById(data.userId);
	if player then
		self.turnToSeat = player.localSeatId;
		self.mahjongManager:playerCatchCard(player.localSeatId , 0);
		self:setOutCardTimer(player.localSeatId, RoomData.getInstance().outCardTimeLimit);
	end
end

-- 开始换三张
RoomScene.startSwapCard = function ( self, param )
	local roomData = RoomData.getInstance();
	roomData.isStartSwapCard = true;
	roomData.firstSwapClick = false;
	roomData.swapCardList = param.swapCard;
	roomData.swapCardTime = param.swapTime;
	roomData.swapCardNum = param.cardNum;

	self.swapCardAnim = new(AnimInt , kAnimNormal , 0, 1, 3000, 0);
	self.swapCardAnim:setDebugName("RoomScene|self.swapCardAnim");
	self.swapCardAnim:setEvent(self, function ( self )
		delete(self.swapCardAnim);
		self.swapCardAnim = nil;

		self.reconnectRoom = false;
		local rd = RoomData.getInstance();
		self.mahjongManager:setMineInHandCardsCanBeTouch();
		self.mahjongManager:setMineInhandCardsOpen();
		self.mahjongManager:setMahjongFrameUpNomal(rd.swapCardList);
		self.mahjongManager:setAllAddFan();
		self:setOutCardTimer(-1, RoomData.getInstance().swapCardTime );
		self:setOutCardTimerAudioFlag(true);
		self:showSwapCardTip(1);
	end);

end


RoomScene.serverSwapCardFinish = function ( self, data )
	local roomData = RoomData.getInstance();
	roomData.isStartSwapCard = false;
	--
	self.mahjongManager:recreateMyHandCard(data.handCard);
	self.mahjongManager:setMineInHandCardsWhenWait();
	self.mahjongManager:setMahjongFrameUpNomal(data.swapCard);
	self.mahjongManager:setMahjongFrameDownNomal(true, nil, true);
	self:showSwapCardTip(3);
end

RoomScene.swapCardEnd = function ( self )
	self:hideSwapCardTip();
end

-- 显示换三张提示信息。level：1~3 1是换牌阶段 2是等待服务器处理换牌阶段 3是等待其他玩家换牌阶段
RoomScene.showSwapCardTip = function ( self, level )
	DebugLog("RoomScene.showSwapCardTip level: "..tostring(level));
	local roomData = RoomData.getInstance();
	local cardNum  = roomData.swapCardNum or 3;

	if not self.swapTipImg then


		self.bg = UICreator.createImg("Room/changeCardBg.png", 0, 0 );
		local bgW, bgH 				= self.bg:getSize();


		self.swapTipImg =UICreator.createText("请选择要换的"..cardNum.."张牌",0,0,0,0,kAlignLeft,32, 0xff, 0xea, 0x73)--( str, x, y, width,height, align ,fontSize, r, g, b )

		self.tipMahjong = UICreator.createImg("Room/mahjong.png",0,0)
		self.tipMahjong:setAlign(kAlignBottomLeft)
		if PlatformConfig.platformYiXin == GameConstant.platformType then
			self.tipMahjong:setFile("Login/yx/Room/mahjong.png");
		end

		local buttons = SceneLoader.load(button_pin);
		self.swapCancelBtn = publ_getItemFromTree(buttons,{"btn_rechoose"});
		self.swapCancelBtn:setOnClick(self, function ( self )
			self.mahjongManager:setMahjongFrameDownNomal(true, nil, false);
		end);

		self.swapConfimBtn = publ_getItemFromTree(buttons,{"btn_confirm"});
		self.swapConfimBtn:setOnClick(self, function ( self )
			self:showSwapCardTip(2);
			self:setOutCardTimerAudioFlag(false);
			self:swapCardConfirm(self.mahjongManager:getFrameUpNomalMahjongValueList())
			self.mahjongManager:setMineInHandCardsEnbale(false);
		end);

		self.serverDealTipImg = UICreator.createText("正在为您换牌,请稍候...",0,0,0,0,kAlignLeft,32, 0xff, 0xea, 0x73)

		self.waitTipImg = UICreator.createText("等待其他玩家换牌",0,0,0,0,kAlignLeft,32, 0xff, 0xea, 0x73)

		self.nodeOperation:addChild(self.bg);
		self.bg:addChild(self.tipMahjong)
		self.bg:addChild(self.swapTipImg);

		self.bg:addChild(buttons);

		self.bg:addChild(self.serverDealTipImg);
		self.bg:addChild(self.waitTipImg);

		local x, y = self.mahjongManager.mahjongFrame:getPos(kSeatMine);
		local tipMahjongW, tipMahjongH = self.tipMahjong:getSize()

		local startTipW, startTipH 	= self.swapTipImg:getSize();
		local cancelW, cancelH		= self.swapCancelBtn:getSize();
		local confimW, confimH		= self.swapConfimBtn:getSize();

		local width = tipMahjongW + 5 + startTipW + 25 + cancelW + 5 + confimW;

		self.bg:setPos((System.getScreenWidth() / System.getLayoutScale() - bgW) / 2 , y - bgH - 80) ; -- 离牌面距离80
		bgH = bgH - 22
		self.tipMahjong:setPos(0,15)
		self.swapTipImg:setPos(tipMahjongW + 5,(bgH - startTipH)/2)

		--self.swapTipImg:setPos((bgW - width)/2 , (bgH - startTipH)/2);

		self.swapCancelBtn:setPos((bgW - width)/2 + startTipW + 5 + tipMahjongW + 5, (bgH - cancelH + 8)/2);
		self.swapConfimBtn:setPos((bgW - width)/2 + startTipW + 5 + cancelW + 5 + tipMahjongW + 5, (bgH - confimH + 8)/2);

		local serverDealTipW, serverDealTipH = self.serverDealTipImg:getSize();
		self.serverDealTipImg:setPos((bgW - serverDealTipW)/2 , (bgH - serverDealTipH)/2);

		local waitTipW, waitTipH = self.waitTipImg:getSize();
		self.waitTipImg:setPos((bgW - waitTipW)/2 , (bgH - waitTipH)/2);

	end

	self:hideSwapCardTip();
	self.bg:setVisible(true);
	if level == 1 then
		self.swapTipImg:setVisible(true);
		self.swapConfimBtn:setVisible(true);
		self.swapCancelBtn:setVisible(true);
		if cardNum == 3 then
			TeachManager.getInstance():show(TeachManager.HAUNG_PAI_TIP);
		elseif cardNum == 2 then
			TeachManager.getInstance():show(TeachManager.HAUNG_PAI_TIP1);
		end

	elseif level == 2 then
		self.serverDealTipImg:setVisible(true);
	elseif level == 3 then
		self.waitTipImg:setVisible(true);
	end
	self.isSwapCardHide = false;
end

-- 隐藏换牌提示
RoomScene.hideSwapCardTip = function ( self )
	if not self.isSwapCardHide and self.swapTipImg then
		self.isSwapCardHide = true;
		self.swapTipImg:setVisible(false);
		self.serverDealTipImg:setVisible(false);
		self.waitTipImg:setVisible(false);
		self.swapConfimBtn:setVisible(false);
		self.bg:setVisible(false);
		self.swapCancelBtn:setVisible(false);
		TeachManager.getInstance():hide();
	end
end

-- 自己抓牌
RoomScene.myselfCatchCard = function (self , data)
	self.reconnectRoom = false;
	if self.operationView then -- 隐藏
		self.operationView:hideOperation();
	end

	local myself = PlayerManager.getInstance():myself();
	self.mahjongManager:showBigCardCenterDiscard();
	-- 移除中心显示的打出牌
	self.mahjongManager:removeBigShowCenterView();
	self.turnToSeat = kSeatMine;

	self.mahjongManager:playerCatchCard(kSeatMine , data.lastCard);
	self.mahjongManager:setAllMahjongFrameDown();

	--加番相关
	self.mahjongManager:setOneCardForAddFan(data.lastCard);
	--时间
	self:setOutCardTimer(myself.localSeatId, data.opTime or 0);

	if data.operateValue > 0 then -- 有操作
		DebugLog("自己抓牌有操作opTime : "..(data.opTime or 0));
		local opTime = data.opTime or 0;
		if opTime <= 0 then
			opTime = RoomData.getInstance().operationTime;
		end
		local param = {};
		for k , v in pairs(data.angang) do
			if v > 0 then
				local t = {};
				t.card = v;
				t.operatype = AN_KONG;
				table.insert(param , t);
			end
		end
		for k , v in pairs(data.bugang) do
			if v > 0 then
				local t = {};
				t.card = v;
				t.operatype = BU_KONG;
				table.insert(param , t);
			end
		end
		if operatorValueHasHu(data.operateValue) then
			local t = {};
			t.card = data.lastCard;
			t.operatype = ZI_MO;
			table.insert(param , t);
		end
		if not operatorValueHasGuo(data.operateValue) then -- 注意是 NOT
			local t = {};
			t.card = 0;
			t.operatype = GUO;
			table.insert(param , t);
		end
		self:showOperator(param);
		self.mahjongManager:setMineInHandCardsWhenOperate();

		if data and data.huCardTips then
			HuCardTipsManager.getInstance():setHuCardTipsDataHolder( data.huCardTips );
		end
	else
		DebugLog("自己抓牌无操作opTime : "..(data.opTime or 0));
		local opTime = data.opTime or 0;
		if opTime <= 0 then
			opTime = RoomData.getInstance().outCardTimeLimit;
		end

		if myself.isAi then
			return;
		end

		if RoomData.getInstance().isXueLiu then
			self.mahjongManager:setMineInHandCardsWhenOutCardXLCH();
		else
			self.mahjongManager:setMineInHandCardsWhenOutCard();
		end

		if self.mahjongManager:hasTheTypeMahjong(PlayerManager.getInstance():myself().dingQueType) then
			TeachManager.getInstance():show(TeachManager.CHU_PAI_1_TIP); -- 抓到牌
		else
			TeachManager.getInstance():show(TeachManager.CHU_PAI_TIP); -- 抓到牌
		end

		if data and data.huCardTips then
			self:showHuCardTips( data.huCardTips );
		end
	end
end

-- 广播出牌
RoomScene.broadcastOutCard = function (self , data)
	self.reconnectRoom = false;
	self.chiPengGangCard = 0;
	local player = PlayerManager.getInstance():getPlayerById(data.userId);
	if player then
		self.mahjongManager:playOutCard(player.localSeatId, data.card); -- 把牌打出去
		if player.sex == 0 then
			GameEffect.getInstance():play("m"..data.card); --播放男声出牌
		else
			GameEffect.getInstance():play("w"..data.card); --播放女声出牌
		end

		if player.isMyself or RoomData.getInstance().isXueLiu then
			self.mahjongManager:drawInhandCards(kSeatMine);
			self.mahjongManager:setMineInHandCardsWhenWait();
		end
	end

	GameEffect.getInstance():play("AUDIO_OC");

	local myself = PlayerManager.getInstance():myself();
	local opTime = data.opTime or 0;

	if opTime <= 0 then
		DebugLog("error : 打出牌没有等待时间");
		opTime = RoomData.getInstance().operationTime;
	end

	if data.operateValue > 0 then
		local param = {};
		if operatorValueHasGang(data.operateValue) then
			local t = {};
			t.card = data.card;
			t.operatype = PUNG_KONG;
			table.insert(param , t);
		end
		if operatorValueHasPeng(data.operateValue) then
			local t = {};
			t.card = data.card;
			t.operatype = PUNG;
			table.insert(param , t);
		end
		if operatorValueHasHu(data.operateValue) then
			local t = {};
			t.card = data.card;
			t.operatype = QIANG;
			table.insert(param , t);
		end
		if not operatorValueHasGuo(data.operateValue) then -- 注意是 NOT
			local t = {};
			t.card = 0;
			t.operatype = GUO;
			table.insert(param , t);
		end
		self:showOperator(param);
		self.mahjongManager:setAllMahjongFrameDown();
		self.mahjongManager:setMineInHandCardsWhenOperate();
		self:setOutCardTimer(myself.localSeatId, opTime);
	else
		self:setOutCardTimer(-1, opTime);
	end
end

-- 提示可以抢杠胡
RoomScene.operationHint = function (self ,data)
	if data.type > 0 and not self.myself.isAi then
		self.reconnectRoom = false;
		if self.operationView then
			self.operationView:hideOperation();
		end
		local myself = PlayerManager.getInstance():myself();
		if data.type > 0 then
			self:setOutCardTimer(myself.localSeatId,RoomData.getInstance().operationTime);
			local param = {};
			if operatorValueHasGang(data.type) then
				local t = {};
				t.card = data.card;
				t.operatype = PUNG_KONG;
				table.insert(param , t);
			end
			if operatorValueHasPeng(data.type) then
				local t = {};
				t.card = data.card;
				t.operatype = PUNG;
				table.insert(param , t);
			end
			if operatorValueHasHu(data.type) then
				local t = {};
				t.card = data.card;
				t.operatype = QIANG;
				if hu_qiangGang(data.type) then -- and GameConstant.isSingleGame
					t.operatype = QIANG_GANG_HU;
				end
				table.insert(param , t);
			end

			if not operatorValueHasGuo(data.type) then -- 注意是 NOT
				local t = {};
				t.card = 0;
				t.operatype = GUO;
				table.insert(param , t);
			end

			self:showOperator(param);
			self.mahjongManager:setAllMahjongFrameDown();
			self.mahjongManager:setMineInHandCardsWhenOperate();
		end
	end
end

-- 显示操作界面
RoomScene.showOperator = function ( self, param )
	if not self.operationView then
		self.operationView = new(Operation , self);
		self.nodeOperation:addChild(self.operationView);
	end
	self.operationView:showOperation(param);
end

-- 玩家选择操作后的回调（包括取消操作）：这里只是把请求发出去，如果操作成功 服务器会广播用户进行的操作
RoomScene.operationCallback = function ( self, operationType, cardValue )
	self.operationView:hideOperation();
	-- 玩家选择取消时：operationType, cardValue都为0
	self.chiPengGangCard = cardValue;
	local param = {};
	param.cardValue = cardValue;
	param.operatorValue = operationType;
	self.mahjongManager:setAllMahjongFrameDown();
	-- 有可能网络包回来有延时，禁止出牌
	self.mahjongManager:setMineInHandCardsWhenWait(); -- 自己不能出牌了
	local player = PlayerManager.getInstance():myself();
	if 0 == operationType and not player.isAi then  -- 取消操作
		if kSeatMine == self.turnToSeat then
			if RoomData.getInstance().isXueLiu then
				self.mahjongManager:setMineInHandCardsWhenOutCardXLCH();
			else
				self.mahjongManager:setMineInHandCardsWhenOutCard();
			end
			self:setMineInHandCardsWithChiPengGangCard();
		end
	end
	self.chiPengGangCard = 0;
	self:takeOperation(param)
end

-- 设置吃碰杠的牌不能打出
RoomScene.setMineInHandCardsWithChiPengGangCard = function (self)
	if self.chiPengGangCard > 0 then
		local inHandCards = self.mahjongManager:getInHandCardsBySeat(kSeatMine);
		for k ,v in pairs(inHandCards) do
			if v.value == chiPengGangCard then
				v:setShadeWithImage();
			end
		end
	end
end

-- 广播某人进行操作
RoomScene.broadcastTakeOperation = function (self ,data)
	if self.reconnectRoom then
		self.reconnectRoom = false;
		if data.beBlockServerSeatId >= 0 then
			local seatId = Player.getLocalSeat(data.beBlockServerSeatId);
			DebugLog("seatId : "..(seatId or 0).."card"..(data.card or 0));
			self.mahjongManager:clearACardshowDiscardOnTable(seatId , data.card);
		end
	end
	if self.operationView then -- 隐藏
		self.operationView:hideOperation();
	end
	local pm = PlayerManager.getInstance();

	if operatorValueHasHu(data.operateValue) then
		return;
	end
	-- 移除中心显示的打出牌
	self.mahjongManager:removeBigShowCenterView();

	local player = PlayerManager.getInstance():getPlayerById(data.userId);

	if not player then
		return;
	end

	self.turnToSeat = player.localSeatId;
	-- 是碰，杠操作时，处理手牌数据
	-- 先去掉手中的牌
	self.mahjongManager:removePengGangInHandCards(player.localSeatId , data.card , data.operateValue);
	self.mahjongManager:playerBlockWithSeatAndValue(player.localSeatId, data.card, data.operateValue);

	if peng(data.operateValue) then
		self:playGameAnim(SpriteConfig.TYPE_PENG , player.localSeatId);
		self:setOutCardTimer(player.localSeatId, RoomData.getInstance().outCardTimeLimit);
	else
		self:setOutCardTimer(-1, RoomData.getInstance().outCardTimeLimit);
	end

	if player.isMyself then -- 是自己
		self.mahjongManager:setAllMahjongFrameDown();
		self.mahjongManager:sortInHandCards(player.dingQueType);
		self.mahjongManager:drawInhandCards(kSeatMine);
		local inHandCards = self.mahjongManager:getInHandCardsBySeat(kSeatMine);
		if peng(data.operateValue) and not player.isAi then
			if RoomData.getInstance().isXueLiu then
				self.mahjongManager:setMineInHandCardsWhenOutCardXLCH();
			else
				self.mahjongManager:setMineInHandCardsWhenOutCard();
			end
		elseif guo(data.operateValue) and not player.isAi and needToDiscard(#inHandCards) then
			self.mahjongManager:setMineInHandCardsWhenOutCard();
		else
			self.mahjongManager:setMineInHandCardsWhenWait();
		end
	end

	--加番相关
	--设置吃碰杠的加番图标
	self.mahjongManager:setChiPengGangAndHuAddFan(player.localSeatId);

	if data and data.huCardTips then
		self:showHuCardTips( data.huCardTips );
	end
end

-- 广播刮风下雨
RoomScene.broadcastGFXYToTable = function (self , data)
	local player = PlayerManager.getInstance():getPlayerById(data.userId);

	if player then
		player.gfxyMoney = player.gfxyMoney + data.userMoney;
		if 1 == data.gangType then  -- 刮风
			self:playGameAnim(SpriteConfig.TYPE_GUAFENG , player.localSeatId);
		elseif 2 == data.gangType then -- 下雨
			self:playGameAnim(SpriteConfig.TYPE_XIAYU , player.localSeatId);
		end
		self:showChangMoneyAnim(data.userId, data.userMoney);
		for k,v in pairs(data.userList) do
			self:showChangMoneyAnim(v.userId, v.gangMoney);
			local player = PlayerManager.getInstance():getPlayerById(v.userId);
			player.gfxyMoney = player.gfxyMoney + v.gangMoney;
		end
	end

	local userList = data.userList;
	for k,v in pairs(userList) do
		self:showBankruptTips( v.userId, data.userId );
	end

end

RoomScene.showBankruptTips = function( self, beihuMid, huMid )

	-- 如果某个场次开启了破产补助，则不提示破产无法获取金币信息
	if self.roomData then
		if self.roomData.isBankruptSubsidize then
			return;
		end
	end

	local tips = "";
	if not beihuMid or not huMid then
		return;
	end
	if beihuMid == huMid then
		return;
	end
	local playerManager = PlayerManager.getInstance();
	local myselfMid = playerManager:myself().mid;

	if huMid ~= myselfMid then
		return;
	end
	local player = playerManager:getPlayerById( beihuMid );
	if not player then
		return;
	end
	if player.money > 0 then
		return;
	end
	tips = player.nickName.."已破产，无法赢取他的金币";

	Banner.getInstance():showMsg( tips );
end


RoomScene.showChangMoneyAnim = function ( self, mid, money )
	log( "RoomScene.showChangMoneyAnim" );
	if self.creatingChangeMoneyAnim or self:isFreeMatchGame() then--积分赛无金币流动
		return;
	end
	self.creatingChangeMoneyAnim = true;
	local player = PlayerManager.getInstance():getPlayerById(mid);

	log( "get player by mid" );

	if not player then
		return;
	end

	log( "playing change money anim" );

	local x, y = RoomCoor.showMoneyCoor[player.localSeatId][1], RoomCoor.showMoneyCoor[player.localSeatId][2];
	if player.localSeatId == kSeatRight then
		x = x - 51 * (money > 0 and string.len("+".. money) or string.len("" .. money) ); -- 右对齐
	end

	local key  =  "money" .. mid;
	local anim = self.nodeOperation:getChildByName(key);

	if anim then
		self.nodeOperation:removeChild(anim,true);
	end

	anim = new(ChangeMoneyAnim, tonumber(money), x, y,nil,true);
	anim:setName(key);
	self.nodeOperation:addChild(anim);
	anim:show();

	if kSeatMine == player.localSeatId then
		self:caluMoneyExchange( tonumber(money));
	end

	-- 实时计算玩家金币数
	player:addMoney(tonumber(money));
	self.creatingChangeMoneyAnim = false;

	if GameConstant.isSingleGame then
		g_DiskDataMgr:setAppData('singleMyMoney',PlayerManager.getInstance():myself().money)
		if player.money < 0 and player.money < 0 then
			self:playBankruptAnim(player.localSeatId);
		end
	end
end



RoomScene.playBankruptAnim = function ( self, seatId )
	if self.seatManager.seatList[seatId] then
		self.seatManager.seatList[seatId]:showBankruptAnim(seatId, self.nodeOperation);
	end
end

RoomScene.testGameAnim = function ( self )
	self:playGameAnim(SpriteConfig.TYPE_CHAHUAZHU , kSeatMine);
	self:playGameAnim(SpriteConfig.TYPE_CHAHUAZHU , kSeatRight);
	self:playGameAnim(SpriteConfig.TYPE_CHAHUAZHU , kSeatTop);
	self:playGameAnim(SpriteConfig.TYPE_CHAHUAZHU , kSeatLeft);
end

-- 播放碰，杠等动画
RoomScene.playGameAnim = function ( self, animType, seatId)
	local x,y = 0,0;
	x = RoomCoor.gameAnim[animType][seatId][1];
	y = RoomCoor.gameAnim[animType][seatId][2];

	if GameConstant.platformType == PlatformConfig.platformGuangDianTong then
		if publ_IsResDownLoaded( GameConstant.DOWNLOAD_RES_TYPE_OPT_ANIM ) then
			self:playCommonOptAnim( animType, x, y );
		else
			require("Animation/PlayCardsAnim/small/AnimSmallCommonOpt");
			local optAnim = new( AnimSmallCommonOpt, { x, y }, animType );
			optAnim:play();
		end
	else
		self:playCommonOptAnim( animType, x, y );
	end

	if SpriteAudioConfig[animType] then
		GameEffect.getInstance():play(SpriteAudioConfig[animType]);
		local sex = PlayerManager.getInstance():getPlayerBySeat(seatId).sex;
		if sex == 0 then
			GameEffect.getInstance():play("m"..SpriteAudioConfig[animType]);  --男声操作音
		else
			GameEffect.getInstance():play("w"..SpriteAudioConfig[animType]);  --女声操作音
		end
	end
end

function RoomScene.playCommonOptAnim( self, animType, x, y )
	if SpriteConfig.TYPE_GUAFENG == animType then
		local view = new(AnimationWind, {x,y});
		self.nodeOperation:addChild(view);
		view:play();
	elseif SpriteConfig.TYPE_XIAYU == animType then
		local view = new(AnimationRain, {x,y});
		self.nodeOperation:addChild(view);
		view:play();
	elseif SpriteConfig.TYPE_PENG == animType then
		local view = new(AnimationPeng, {x,y});
		self.nodeOperation:addChild(view);
		view:play();
	elseif SpriteConfig.TYPE_FANGPAO == animType then
		local view = new(AnimationFangPao, {x,y});
		self.nodeOperation:addChild(view);
		view:play();
	elseif SpriteConfig.TYPE_ZIMO == animType then
		local view = new(AnimationZiMo, {x,y});
		self.nodeOperation:addChild(view);
		view:play();
	elseif SpriteConfig.TYPE_CHADAJIAO == animType then
		local view = new(AnimationDaJiao, {x,y});
		self.nodeOperation:addChild(view);
		view:play();
	elseif SpriteConfig.TYPE_CHAHUAZHU == animType then
		local view = new(AnimationHuaZhu, {x,y});
		self.nodeOperation:addChild(view);
		view:play();
	end
end

-- 自己打出的牌和服务器不同，换牌
RoomScene.backendBeforeOutCard = function (self , beforeCard , data)
	self.mahjongManager:backendBeforeOutCard(beforeCard , data.card);
end

RoomScene.setBaseInfoHide = function ( self, bVisible )
	self:getControl(RoomScene.s_controls.baseInfoView):setVisible(bVisible);
end

function RoomScene:setRoomName( file )
	if self.RDI and self.RDI.roomName then
		self.RDI.roomName:setFile(file)
	end
end



-- 设置托管
RoomScene.showOrDisapperTuoguan = function ( self, bShow )
	if not self.tuoGuanAni then
		self.tuoGuanAni = new(TuoGuanAni);
		--设置为不可见
		self.tuoGuanAni:setPos(System.getScreenWidth() / System.getLayoutScale(), RoomCoor.tuoGuanAniPos[2]);--
		self.nodeOperation:addChild(self.tuoGuanAni);
		self.tuoGuanAni:setDisapperCallback(self, function ( self )
			self:cancelAI()
			self:mineCancelAi();
		end);

	end
	if bShow then
		self:mineShowAi();
		self:resetMyCradState();
	else
		self:mineCancelAi();
	end
end

-- 设置AI时的状态
RoomScene.mineShowAi = function (self)
	if not self.tuoGuanAni or self.tuoGuanAni.isShow then
		return;
	end
	-- self:hideSettingBar();
	GameEffect.getInstance():play("AUDIO_TG");
	local myself = PlayerManager.getInstance():myself();
	myself.isAi = true;
	self.tuoGuanAni:show();
end

RoomScene.resetMyCradState = function( self )
	if self.operationView then -- 隐藏
		self.operationView:hideOperation();
	end
	local myself = PlayerManager.getInstance():myself();
	if not PlayerManager:getInstance():myself().isInGame or myself.isHu then
		return;
	end
	self.mahjongManager:setAllMahjongFrameDown();
	self.mahjongManager:setMineInHandCardsCanNotDoAnything(); -- 不能操作牌了
end

-- 取消AI时设置手牌
RoomScene.mineCancelAi = function (self)
	if not self.tuoGuanAni or not self.tuoGuanAni.isShow then
		return;
	end
	local myself = PlayerManager.getInstance():myself();
	myself.isAi = false;
	self.tuoGuanAni:disapper();
	if not PlayerManager:getInstance():myself().isInGame or myself.isHu then
		return;
	end
	self:checkMyselfOutCardState();
end

RoomScene.checkMyselfOutCardState = function (self)
	self.mahjongManager:setAllMahjongFrameDown();
	local inHandCards = self.mahjongManager:getInHandCardsBySeat(kSeatMine);
	if (not self.operationView or not self.operationView.m_visible) and needToDiscard(#inHandCards) then  -- 到自己出牌了
		if RoomData.getInstance().isXueLiu then
			self.mahjongManager:setMineInHandCardsWhenOutCardXLCH();
		else
			self.mahjongManager:setMineInHandCardsWhenOutCard();
		end
	elseif self.operationView and self.operationView.m_visible then  -- 如果有操作
		self.mahjongManager:setMineInHandCardsWhenOperate();
	else
		self.mahjongManager:setMineInHandCardsWhenWait(); -- 自己不能出牌了
	end
end

-- 广播开始选缺
RoomScene.broadcastSelectQue = function (self ,data)
	self:swapCardEnd()
	self:showSelectQueView(data);
	self.mahjongManager:setAllMahjongFrameDown();
	self.mahjongManager:setMineInHandCardsCanNotDoAnything();
	self:setOutCardTimer(-1, RoomData.getInstance().outCardTimeLimit);
	self:setOutCardTimerAudioFlag(true);
end

-- 显示选缺画面
RoomScene.showSelectQueView = function (self , data)
	DebugLog("RoomScene.showSelectQueView")
	if self.selectQueView then
		self.nodeDingQue:removeChild(self.selectQueView, true);
		self.selectQueView = nil;
	end
	self.selectQueView = new(SelectQueView);
	self.nodeDingQue:addChild(self.selectQueView);
	self.selectQueView:setClickCallback(self, function ( self, selectType )
		self:setOutCardTimerAudioFlag(false);
		self.mahjongManager:setMineInHandCardsWhenWait();
		self:clientSelectQue(selectType)
	end);
	if data then
	    self.selectQueView:showSelectQue(tonumber(data.recQue));
	else
	    self.selectQueView:showSelectQue(-1);
	end
end

RoomScene.showMyselfSelectQueView = function (self , data)
	DebugLog("RoomScene.showMyselfSelectQueView")
	if self.selectQueView then
		self.nodeDingQue:removeChild(self.selectQueView, true);
		self.selectQueView = nil;
	end
	self.selectQueView = new(SelectQueView);
	self.nodeDingQue:addChild(self.selectQueView);
	--self.selectQueView:setClickCallback(self, function ( self, selectType )
		--self:setOutCardTimerAudioFlag(false);
		--self.mahjongManager:setMineInHandCardsWhenWait();
		--self:clientSelectQue(selectType)
	--end);
	self.selectQueView:showSelectQue();
	self.selectQueView:hiddenSomeImage(data);
end

-- 服务器返回定缺
RoomScene.broadcastdingque = function ( self, data )
	DebugLog("RoomScene.broadcastdingque")
	mahjongPrint(data)
	local pm = PlayerManager.getInstance();
	local queInfo = {};
	for k,v in pairs(data) do
		local mid = v.id;
		local queType = v.type;
		local player = pm:getPlayerById(mid);
		if player then
			player.dingQueType = queType;
			queInfo[player.localSeatId] = queType;
		end
	end

	if self.selectQueView then
		self.selectQueView:broadcastdingque(queInfo);
		self.selectQueView:setMoveAniCallback(self, function ( self )
			for k,v in pairs(queInfo) do
				self.seatManager.seatList[k]:dingque(v);
			end
		end);
	else
		for k,v in pairs(queInfo) do
			self.seatManager.seatList[k]:dingque(v);
		end
	end
	TeachManager.getInstance():hide();
	-- 选完缺，手牌变黑 不能出牌  能被点击
	self.mahjongManager:setAllMahjongFrameDown();
	self.mahjongManager:sortInHandCards(queInfo[kSeatMine]);
	self.mahjongManager:drawInhandCards(kSeatMine);
	self.mahjongManager:setMineInHandCardsWhenWait();
	self.reconnectRoom = false;
end

-- 血流玩法中间有人胡
RoomScene.huXLCH = function (self , infoTable)
	-- 移除中心显示的打出牌
	self.mahjongManager:removeBigShowCenterView();

	local sm = self.seatManager;
	local seat , card;  -- 表示胡的牌的位置   胡牌

	local fangPaoId = -1;
	for k , v in pairs(infoTable.normalInfo) do
		card = v.huCard;
		local dafanxin = new(DaFanXin, v.paiType, PlayerManager.getInstance():getLocalSeatIdByMid(v.userId), self.m_root);
		dafanxin:play();
		table.insert(self.dafanxinAnimList, dafanxin);
		if 1 == v.huType then
			fangPaoId = PlayerManager.getInstance():getLocalSeatIdByMid(v.fangPaoUserID);
		end
	end

	local moneyexchange = {};

	for k , v in pairs(infoTable.xueLiuInfo) do
		local player = PlayerManager.getInstance():getPlayerById(v.winUserId);
		local inHandCards = self.mahjongManager:getInHandCardsBySeat(player.localSeatId);
		if 1 ~= v.huType and needToDiscard(#inHandCards) then
			self.mahjongManager:removeAMahjong(player.localSeatId , #inHandCards);
		end
		if player.isMyself then
			self.mahjongManager:setMineInHandCardsWhenWait();
		end
		if 1 == v.huType then -- 放炮
			-- self:playGameAnim(SpriteConfig.TYPE_HU, player.localSeatId);

			self:playGameAnim(SpriteConfig.TYPE_FANGPAO, fangPaoId);
			seat = PlayerManager.getInstance():getPlayerById(v.paoId).localSeatId;
			-- 钱动画
			if not moneyexchange[v.paoId] then
          		moneyexchange[v.paoId] = 0;
          	end
          	moneyexchange[v.paoId] = moneyexchange[v.paoId] - v.winMoney;
          	if not moneyexchange[v.winUserId] then
          		moneyexchange[v.winUserId] = 0;
          	end
          	moneyexchange[v.winUserId] = moneyexchange[v.winUserId] + v.winMoney;
		else
			self:playGameAnim(SpriteConfig.TYPE_ZIMO, player.localSeatId);
			seat = player.localSeatId;
			local loseMoney = -v.winMoney/3; -- 每个人输的钱数
			-- 播放输赢钱动画
			for m,j in pairs(PlayerManager.getInstance().playerList) do
				if j.mid == v.winUserId then
					if not moneyexchange[j.mid] then
		          		moneyexchange[j.mid] = 0;
		          	end
		          	moneyexchange[j.mid] = moneyexchange[j.mid] + v.winMoney;
				else
					if not moneyexchange[j.mid] then
		          		moneyexchange[j.mid] = 0;
		          	end
		          	moneyexchange[j.mid] = moneyexchange[j.mid] + loseMoney;
				end
			end
		end
		local huTypeInfo = RoomData.getInstance():getHuTypeInfoBySeat(player.localSeatId);
		sm.seatList[player.localSeatId]:huInGameXLCH(huTypeInfo);
	end

	for k,v in pairs(moneyexchange) do
		self:showChangMoneyAnim(k, v);
	end

	if self.reconnectRoom and fangPaoId >= 0 then
		self.reconnectRoom = false;
		local seatId = fangPaoId;
		self.mahjongManager:clearACardshowDiscardOnTable(seatId , card);
	end
	self.reconnectRoom = false;

	-- 将胡牌显示到桌面
	self.mahjongManager:showDiscardOnTableAnim(seat , card , 2 , true);

	--加番牌显示
	-- self.mahjongManager:setOneCardForAddFan(card);
end

RoomScene.huXLCH2 = function ( self, infoTable )
	-- 移除中心显示的打出牌
	self.mahjongManager:removeBigShowCenterView();

	local fangPaoId, huCard = -1,0;
	local sm = self.seatManager;
	local pm = PlayerManager.getInstance();
	local seat , card;  -- 表示胡的牌的位置   胡牌

	for k,v in pairs(infoTable) do
		card = v.huCard;
		local player = pm:getPlayerById(v.mid);
		local huSeatId = player.localSeatId;
		-- 显示桌面信息
		local huTypeInfo = RoomData.getInstance():getHuTypeInfoBySeat(huSeatId);
		sm.seatList[huSeatId]:huInGameXLCH(huTypeInfo);

		local inHandCards = self.mahjongManager:getInHandCardsBySeat(huSeatId);
		if 1 ~= v.huType and needToDiscard(#inHandCards) then
			self.mahjongManager:removeAMahjong(huSeatId, #inHandCards);
		end
		if player.isMyself then
			self.mahjongManager:setMineInHandCardsWhenWait();
		end

		if kSeatMine == huSeatId then
			GameEffect.getInstance():play("AUDIO_WIN");
		end

		-- 清空被抢杠胡的杠牌
		if 1 == v.isQiangGangHu then
			self.mahjongManager:playerQiangGangHu(v.huCard);
		end

		-- 胡牌动画
		if 1 == v.huType then
			-- self:playGameAnim(SpriteConfig.TYPE_HU, huSeatId);
			huCard = v.huCard;
			for j,n in pairs(v.beHu) do -- 放炮的时候这里只有一个
				fangPaoId = pm:getLocalSeatIdByMid(n.mid);
			end

			self:playGameAnim(SpriteConfig.TYPE_FANGPAO, fangPaoId);
			seat = fangPaoId;
		else
			seat = huSeatId;
			self:playGameAnim(SpriteConfig.TYPE_ZIMO, huSeatId);
		end
		-- 大番型动画
		local dafanxin = new(DaFanXin, v.paiTypeStr, huSeatId, self.m_root);
		dafanxin:play();
		table.insert(self.dafanxinAnimList, dafanxin);
	end

	if self.reconnectRoom and fangPaoId >= 0 then
		self.reconnectRoom = false;
		local seatId = fangPaoId;
		self.mahjongManager:clearACardshowDiscardOnTable(seatId , huCard);
	end
	self.reconnectRoom = false;
	-- 将胡牌显示到桌面

	--加番牌显示
	-- self.mahjongManager:setOneCardForAddFan(huCard);
	self.mahjongManager:showDiscardOnTableAnim(seat , card , 2 , true);
end



RoomScene.hu2 = function ( self, infoTable )
	self:hasHued()

	if RoomData.getInstance().isXueLiu then
		self:huXLCH2(infoTable);
		return;
	end

	-- 移除中心显示的打出牌
	self.mahjongManager:removeBigShowCenterView();
	local fangPaoId, huCard = -1,0;
	local sm = self.seatManager;
	local pm = PlayerManager.getInstance();

	for k,v in pairs(infoTable) do
		local player = pm:getPlayerById(v.mid);
		local huSeatId = player.localSeatId;
		sm.seatList[huSeatId]:huInGame(v.huType);
		if kSeatMine == huSeatId then
			GameEffect.getInstance():play("AUDIO_WIN");
			self.mahjongManager:setAllMahjongFrameDown();
			self:setMineGameFinish();
		end
		-- 清空被抢杠胡的杠牌
		if 1 == v.isQiangGangHu then
			self.mahjongManager:playerQiangGangHu(v.huCard);
		end
		-- 胡牌动画
		if 1 == v.huType then
			-- self:playGameAnim(SpriteConfig.TYPE_HU, huSeatId);
			huCard = v.huCard;
			for j,n in pairs(v.beHu) do -- 放炮的时候这里只有一个
				fangPaoId = pm:getLocalSeatIdByMid(n.mid);
			end
			self:playGameAnim(SpriteConfig.TYPE_FANGPAO, fangPaoId);
		else
			self:playGameAnim(SpriteConfig.TYPE_ZIMO, huSeatId);
		end
		-- 大番型动画
		local dafanxin = new(DaFanXin, v.paiTypeStr, huSeatId, self.m_root);
		dafanxin:play();
		table.insert(self.dafanxinAnimList, dafanxin);
		-- 设置牌状态
		self.mahjongManager:setInHandCardsWhenHuBySeat(huSeatId);
		self.mahjongManager:setHuCardBySeat(huSeatId, v.huCard , v.huType);

		DebugLog("设置胡牌的人的加番牌图标1")
		self.mahjongManager:setAddFanHuForSeat(huSeatId);

	end

	if PlayerManager.getInstance():getHuPlayerNum() > 2 then
		local changeRoom = self.seatManager:getSeatByLocalSeatID( kSeatMine ).changeRoom;
		local detailBtn = self.seatManager:getSeatByLocalSeatID( kSeatMine ).detailBtn;
		local continueBtn = self.seatManager:getSeatByLocalSeatID( kSeatMine ).continueBtn;
		if changeRoom then
			changeRoom:setVisible( false );
		end

		if detailBtn then
			detailBtn:setVisible( false );
		end

		if continueBtn then
			continueBtn:setVisible( false );
		end
	end

	if self.reconnectRoom and fangPaoId >= 0 then
		self.reconnectRoom = false;
		local seatId = fangPaoId;
		self.mahjongManager:clearACardshowDiscardOnTable(seatId , huCard);
	end
	self.reconnectRoom = false;
end

-- 普通玩法中间有人胡
RoomScene.hu = function ( self, infoTable )
	--self:hasHued()
	-- 移除中心显示的打出牌
	self.mahjongManager:removeBigShowCenterView();

	local fangPaoId, huCard = -1,0;
	local sm = self.seatManager;

	for k,v in pairs(infoTable) do
		local player = PlayerManager.getInstance():getPlayerBySeat(v.seatId);

		sm.seatList[v.seatId]:huInGame(v.huType);
		if kSeatMine == v.seatId then
			GameEffect.getInstance():play("AUDIO_WIN");
			self.mahjongManager:setAllMahjongFrameDown();
			self:setMineGameFinish();
		end
		-- 清空被抢杠胡的杠牌
		if 1 == v.isQiangGangHu then
			self.mahjongManager:playerQiangGangHu(v.huCard);
		end
		if 1 == v.huType then
			-- self:playGameAnim(SpriteConfig.TYPE_HU, v.seatId);
			fangPaoId = PlayerManager.getInstance():getLocalSeatIdByMid(v.fangPaoUserID);
			self:playGameAnim(SpriteConfig.TYPE_FANGPAO, fangPaoId);
			huCard = v.huCard;
		else
			self:playGameAnim(SpriteConfig.TYPE_ZIMO, v.seatId);
		end

		local dafanxin = new(DaFanXin, v.paiType, v.seatId, self.m_root);
		dafanxin:play();
		table.insert(self.dafanxinAnimList, dafanxin);
		self.mahjongManager:setInHandCardsWhenHuBySeat(v.seatId);
		self.mahjongManager:setHuCardBySeat(v.seatId , v.huCard , v.huType);

		DebugLog("设置胡牌的人的加番牌图标1")
		self.mahjongManager:setAddFanHuForSeat(v.seatId);

	end


	if self.reconnectRoom and fangPaoId >= 0 then
		self.reconnectRoom = false;
		local seatId = fangPaoId;
		self.mahjongManager:clearACardshowDiscardOnTable(seatId , huCard);
	end
	self.reconnectRoom = false;
end

-- 计算自己当前局的赢钱数
RoomScene.caluMoneyExchange = function ( self, money )
	RoomData.getInstance().mineCurGameWinMoney = RoomData.getInstance().mineCurGameWinMoney + (money or 0);
	DebugLog( "mineCurGameWinMoney = ".. RoomData.getInstance().mineCurGameWinMoney );
end

RoomScene.showMoneyExchange = function ( self, bSHow )
	if bSHow then
		-- if RoomData.getInstance().isReconnect then -- 重连不显示
		-- 	return;
		-- end
		-- local mstr = RoomData.getInstance().mineCurGameWinMoney or 0;
		-- if tonumber(mstr) > 0 then
		-- 	mstr = "+"..mstr;
		-- end
		self:broadcastUpdateMoney()
		self:getControl(RoomScene.s_controls.mt):setVisible(true);
		self:getControl(RoomScene.s_controls.jsmoneyBg):setVisible(true);
	else
		self:getControl(RoomScene.s_controls.mt):setVisible(false);
		self:getControl(RoomScene.s_controls.jsmoneyBg):setVisible(false);
	end
end

-- 界面的点击
-- 点击背景
RoomScene.OnClickBackGroundImg = function (self , finger_action,x, y,drawing_id_first,drawing_id_current)
    if self.mahjongManager:isMahjongTouch(x , y) then
	    self.mahjongManager:mahjongOnTouchUp(finger_action,x,y,drawing_id_first,drawing_id_current);
    elseif not RoomData.getInstance().isStartSwapCard then
	    self.mahjongManager:setAllMahjongFrameDown();
    end
end

-- 广播条点击事件
RoomScene.OnBroadcastBtnClick = function ( self )
	-- -- 友盟上报喇叭使用次数
	umengStatics_lua(kUmengHallSpeaker);
	if 1 ~= GameConstant.isDisplayBroadcast then
		GameConstant.isDisplayBroadcast = 1;
		g_DiskDataMgr:setAppData('displayBroadcastMessage',GameConstant.isDisplayBroadcast)
	end
    if self.broadcastPopWin then
        self.broadcastPopWin:createMsgItem();
    else
		require("MahjongCommon/BroadcastMsgPop");
		self.broadcastPopWin = new(BroadcastMsgPop);
		self.nodePopu:addChild(self.broadcastPopWin);
    end
end


RoomScene.showExchangePopu = function ( self )
	Banner.getInstance():showMsg("您缺少喇叭，请购买");
	require("MahjongCommon/ExchangePopu");
	self.exchangePopu = new(ExchangePopu, ItemManager.LABA_CID, self);
end

RoomScene.gameOver2 = function ( self, data )
	DebugLog("ResultViewUmengError: RoomScene,gameOver2,begin")
	DebugLog("RoomScene.gameOver2")
	self.reconnectRoom = false;
	GameEffect.getInstance():stop();
	self.mahjongManager:setAllMahjongFrameDown();
	self:dealGameOverInHandCards2(data.playerList);
    --设置分享用的share data
    if true then
        --DebugLog("RoomScene.gameOver2..................:"..tostring(os.time()))
        local shareData = {};
        local handCards = self.mahjongManager.mineInHandCards;--手牌
        local block = self.mahjongManager.mineBlockCards;
        shareData.handcard = handCards;
        shareData.angang = {};
        shareData.gang = {};
        shareData.peng = {};
        table.insert(shareData.angang, "0");
        table.insert(shareData.gang, "0");
        table.insert(shareData.peng, "0");

        for i = 1,#data.playerList do
            if PlayerManager.getInstance():myself().mid == data.playerList[i].mid then
                shareData.money = data.playerList[i].turnMoney;
                break;
            end
            --DebugLog("RoomScene.gameOver2..................1");
        end
        for i = 1, #block do
            if (peng(block[i].opreatType)) then
                table.insert(shareData.peng, block[i].card);
                shareData.peng[1] = "1";
            elseif peng_gang(block[i].opreatType) or bu_gang(block[i].opreatType) then
                shareData.gang[1] = "2";
                table.insert(shareData.gang, block[i].card);
            elseif an_gang(block[i].opreatType) then
                shareData.angang[1] = "2";
                table.insert(shareData.angang, block[i].card);
            end
            --DebugLog("RoomScene.gameOver2..................2");
        end
        self.shareData = shareData;
        --DebugLog("RoomScene.gameOver2..................3");
        --mahjongPrint( self.shareData );这里打印要死人的，要简化要打印的数据--解析这个数据要11--30s的样子
        --DebugLog("RoomScene.gameOver2..................:"..tostring(os.time()));
    end

	if self.operationView then
		self.operationView:hideOperation();
	end
	local sm = self.seatManager;
	sm:gameFinish();

	self.mahjongManager:showBigCardCenterDiscard();
	-- 移除中心显示的打出牌
	self.mahjongManager:removeBigShowCenterView();

	self:showOrDisapperTuoguan(false);
	--[[
	if self.outCardTimer then
		self.outCardTimer:hide();
	end

	if self.leftCardNumText then
		self.leftCardNumText:setVisible(false);
		self.leftCardNumStatic:setVisible(false);
	end
]]
	-- 查花猪和查大叫动画播放
	local huazhuList = {};
	local dajiaoList = {};
	for k,v in pairs(data.huazhuList) do
		local p = PlayerManager.getInstance():getPlayerById(v.beiChaMid);
		huazhuList[p.localSeatId] = 1;
	end
	for k,v in pairs(data.dajiaoList) do
		local p = PlayerManager.getInstance():getPlayerById(v.beiChaMid);
		dajiaoList[p.localSeatId] = 1;
	end

	for k,v in pairs(huazhuList) do
		if 1 == v then
			self:playGameAnim(SpriteConfig.TYPE_CHAHUAZHU, k);

			if k == kSeatMine then -- 新手引导 查花猪
				TeachManager.getInstance():show(TeachManager.CHA_DA_JIAO_TIP);
			end
		end
	end
	for k,v in pairs(dajiaoList) do
		if 1 == v then
			self:playGameAnim(SpriteConfig.TYPE_CHADAJIAO, k);
			if k == kSeatMine then -- 新手引导 查大叫
				TeachManager.getInstance():show(TeachManager.CHA_DA_JIAO_TIP);
			end
		end
	end

	-- 胡牌后直接在桌面显示总的输赢钱数
	for k,v in pairs(data.playerList) do
		if v.mid == PlayerManager.getInstance():myself().mid then
			-- 更新一次本局金币数
			RoomData.getInstance().isReconnect = false;
			if RoomData.getInstance().isBankruptSubsidize then
				RoomData.getInstance().mineCurGameWinMoney = v.tempTurnMoney;
			else
				RoomData.getInstance().mineCurGameWinMoney = v.turnMoney;
			end
			self:caluMoneyExchange( 0 );
		end
	end

	-- 显示暗杠的牌
	self.mahjongManager:showAnGangMahjongWhenGameOver();

	if self.littleResultDetailView then
		self.littleResultDetailView:hideWnd();
	end


	-- 先把界面创建出来，延迟显示
	self.resultView = new(GameResultWindow, self);
	DebugLog("ResultViewUmengError: RoomScene,gameOver2,resultView new")
	self.resultView:parseDataAndShowInitinfo( data, true );
	self.resultView:setCallbackClose(self, function ( self )
		if self.resultView then
			self.nodePopu:removeChild(self.resultView, true);
			self.resultView = nil;
		end
		self:showReadyBtn();
	end);

	self.resultView:setAgainCallback(self, function ( self,isForceReady )
		self:againBtnFun(isForceReady);
	end);

	local curLevel    = RoomData.getInstance().level
	local curRoomType = HallConfigDataManager.getInstance():returnTypeForLevel( curLevel )
	local curMoney    = PlayerManager.getInstance():myself().money
	local curVipLevel = PlayerManager.getInstance():myself().vipLevel
	DebugLog("curLevel type:" .. type(curLevel) .. "curRoomType type:" .. type(curRoomType) .. " curMoney type:" .. type(curMoney))
	DebugLog( "curLevel:" .. tostring(curLevel) .. " curRoomType: " .. tostring(curRoomType) .. " curMoney:" .. tostring(curMoney))
	local ret,hd = HallConfigDataManager.getInstance():returnMinRequireHallDataForTypeAndLevel(curRoomType,curLevel,curMoney,curVipLevel)
	local  disStr = nil
	GameConstant.go_to_high = ret and hd
	if GameConstant.go_to_high then
		disStr = "去高倍场"
	else
		disStr = "再来一局"
	end
	self.resultView:setBtnAgainText(disStr)
	--结算界面显示换桌
	--普通场
	if not RoomData.getInstance().isPrivateRoom  and  RoomData.getInstance().wanfa == 0x1 or GameConstant.inFetionRoom then

		self.resultView:setConfirmCallback("换 桌", self, function ( self )
			-- 客户端判断到金币不足，显示金币购买弹窗
			if not GameConstant.curGameSceneRef:judgeMoneyAndShowChargeWnd() then
				return;
			end
			-- 请求换桌
			local param = {};
			param.mid = PlayerManager.getInstance():myself().mid;
			SocketManager.getInstance():sendPack(CLIENT_COMMAND_REQ_LOGOUT, param);
		end);
	else
		self.resultView:setAgainCenter();
		self.resultView:setComfirmVisible(false);
	end

	self.resultView:hide();
	delete(self.showResultAnim);
	self.showResultAnim = new(AnimInt, kAnimNormal,0,1,2000,0);
	DebugLog("ResultViewUmengError: RoomScene,gameOver2,showResultAnim new")
	self.showResultAnim:setDebugName("RoomScene|self.showResultAnim");
	self.showResultAnim:setEvent(self, function ( self )
		-- self:showOrHideAgainBtn(true); -- 显示再来一局按钮
		delete(self.showResultAnim);
		self.showResultAnim = nil;
		for k,v in pairs(self.seatManager.seatList) do
			-- v:changeToWaitStaty();
			local p = PlayerManager.getInstance():getPlayerBySeat(k);
			if p then
			    v:setReadyStatu(p.isReady);
			end
		end
		DebugLog("ResultViewUmengError: RoomScene,gameOver2,showResultAnim Event happen")
		if self.resultView then
			self.nodePopu:addChild(self.resultView);
			self.resultView:show();
		end

		self:hideReadyBtn();

		TeachManager.getInstance():hide();

	end);



	--显示金币雨
	--播放掉金币动画
	if self.resultView and self.resultView:getResultMoney() > 0 then
		showGoldDropAnimation();
	end

	if GameConstant.platformType ~= PlatformConfig.platformContest then
		-- 游戏结束时判断一次金币数，如果不足则显示充值界面
		self:judgeMoneyAndShowChargeWnd();
	end

	--self:checkIs5Cards()

end

RoomScene.showLittleResultDetail = function ( self, data )
	--if not data then
	--	return;
	--end

	if self.littleResultDetailView then
		self.littleResultDetailView:showWnd();
	else
		if data then
			require("MahjongRoom/GameResult/GameResultWindowLittle");
			self.littleResultDetailView = new(GameResultWindowLittle, data);
			self.littleResultDetailView:setOnWindowHideListener( self, function( self )
				self.littleResultDetailView = nil;
			end);
			self.nodePopu:addChild(self.littleResultDetailView);
		else
			local t = {};
			t.mid = PlayerManager.getInstance():myself().mid;
			SocketManager.getInstance():sendPack(SERVER_NOTIFY_USER_MONEYINFO,t);
		end
	end
end

-- Seat 函数
function RoomScene.showPlayerInfoBySeat(self , seatID)
	local player = PlayerManager.getInstance():getPlayerBySeat(seatID);
	if player then
		if not self.roomUserInfo then
			self.roomUserInfo = new(RoomUserInfo , player , self.nodePopu);
		else
			self.roomUserInfo:updateUserInfo(player);
		end

		self.roomUserInfo:setPropCanUseMoney( self:getPropCanUseMoney() );
	end
end

RoomScene.getPropCanUseMoney = function( self )
	local curMoney = PlayerManager.getInstance():myself().money;
	local limitMoney = 0;
	limitMoney = GameConstant.propLimit;

	return curMoney - limitMoney;
end

RoomScene.hideReadyBtn = function ( self )
	DebugLog("RoomScene.hideReadyBtn ")
	local seat = self.seatManager:getSeatByLocalSeatID(kSeatMine,self);
	seat:hideAllBtn()
end
RoomScene.showReadyBtn = function ( self )
	DebugLog("RoomScene.showReadyBtn")
	local seat = self.seatManager:getSeatByLocalSeatID(kSeatMine,self);

	local curLevel    = RoomData.getInstance().level
	local curRoomType = HallConfigDataManager.getInstance():returnTypeForLevel( curLevel )
	local curMoney    = PlayerManager.getInstance():myself().money
	local curVipLevel = PlayerManager.getInstance():myself().vipLevel
	local ret,hd = HallConfigDataManager.getInstance():returnMinRequireHallDataForTypeAndLevel(curRoomType,curLevel,curMoney,curVipLevel)

	GameConstant.go_to_high = ret and hd
	seat:showReadyChangeBtn(GameConstant.go_to_high);
end

RoomScene.againBtnFun = function( self, isForceReady )
	DebugLog("RoomScene.againBtnFun")
	if GameConstant.isSingleGame then --单机破产
		if 0 > PlayerManager.getInstance():myself().money then
			local timemark = g_DiskDataMgr:getAppData('singletimemark',-1)
			local time = 0;
			if 0 > timemark then
				g_DiskDataMgr:setAppData('singletimemark',os.time())
				self:showBankruptInSingle(GameConstant.singleBankruptTime);
			else
				time = GameConstant.singleBankruptTime - (os.time()-timemark);
				if time <= 0 then
					self:showBankruptInSingle(0);
				else
					self:showBankruptInSingle(time);
				end
			end
			return;
		end
	end

	math.randomseed(os.time());
	local randomNum = math.random(1, 100);
	local myMoney = PlayerManager.getInstance():myself().money;
	local moneyEnoughFlag = false;
	local otherFlag = true;
	--没有赢钱以及单机还有包厢中不弹出高级场提示框
	if GameConstant.isSingleGame or RoomData.getInstance().isPrivateRoom or GameConstant.inFetionRoom then
		otherFlag = false;
	end
	--获取当前场次的金币限额
	local currentLevel = RoomData.getInstance().level;

	local requireNum = -1;

	local currentData = nil;

	if not GameConstant.isSingleGame then
		--判断下是否是两房场
		if not HallConfigDataManager.getInstance():returnHallDataForLFPByLevel(currentLevel) and currentLevel ~= 50 then
			currentData = HallConfigDataManager.getInstance():returnHallConfigByLevel(currentLevel);
			if not currentData then
				return;
			end
			requireNum = tonumber(currentData.require);

			-- 得到当前所有的场次require
			local allRequires = HallConfigDataManager.getInstance():changeAllRequiresFromHallDataByKey(currentData.key);

			if #allRequires > 1 then
				table.sort(allRequires,function(a,b) return a > b end );
			end

			for i=1,#allRequires do
				if tonumber(myMoney) >= tonumber(allRequires[i]) and tonumber(allRequires[i]) > requireNum then
					moneyEnoughFlag = true;
				end
			end
		end
	end

	-- 客户端判断到金币不足，显示金币购买弹窗
	if not self:judgeMoneyAndShowChargeWnd()
		and GameConstant.platformConfig ~= PlatformConfig.platformContest then
		return;
	end

	---------------------
	if isForceReady then
		self:readyAction();
	else
		if not GameConstant.go_to_high then
			self:readyAction();
		else
			self:goToHigh()
		end
	end
	if self.resultView then
		self.nodePopu:removeChild(self.resultView, true);
		self.resultView = nil;
	end
--[[  需求变更
	-- 30%的概率触发高场次推荐事件(拒绝后10场内不再推荐)
	if otherFlag and moneyEnoughFlag and randomNum <= (GameConstant.gameTipOdds * 100)
		and (GameConstant.playedCountAtferRefuse >= GameConstant.gameTipCount
			or not GameConstant.higherInviteRefuse) then
	-- if true then -- debug
		self.nodePopu:removeChild(self.resultView, true);
		self.resultView = nil;

		local content = "恭喜大侠获胜！建议您加入更高级别的赛场，与高手过招，感受精彩对决！";
		local dialogView = PopuFrame.showNormalDialogForCenter("温馨提示", content, GameConstant.curGameSceneRef, nil, nil, false, nil, "接受挑战", "拒绝挑战");
		dialogView:setConfirmCallback(self, function( self )
			--若弹出时牌局计数大于等于10局则重新开始计数
			if GameConstant.playedCountAtferRefuse >= 10 then
				GameConstant.playedCountAtferRefuse = 0;
			end
			GameConstant.needQuickPlayGame = true;
			GameConstant.higherInviteRefuse = false;
			GameConstant.upperEnterRoomFlag = currentData.key; -- 标记是高级场次推荐
			local params = {};
			params.result = 0;
			self.m_controller:changeTable( params );
		end);
		dialogView:setCancelCallback(self, function( self )
			--若弹出时牌局计数大于等于10局则重新开始计数
			if GameConstant.playedCountAtferRefuse >= 10 then
				GameConstant.playedCountAtferRefuse = 0;
			end
			GameConstant.higherInviteRefuse = true;
			GameConstant.needQuickPlayGame = false;
			GameConstant.higherInviteRefuse = false;
			self:requestCtrlCmd(RoomController.s_cmds.exitGame);
		end);
		dialogView:setCloseCallback(self, function( self )
			--若弹出时牌局计数大于等于10局则重新开始计数
			if GameConstant.playedCountAtferRefuse >= 10 then
				GameConstant.playedCountAtferRefuse = 0;
			end
			GameConstant.higherInviteRefuse = true;
			GameConstant.needQuickPlayGame = false;
			GameConstant.higherInviteRefuse = false;
			self:requestCtrlCmd(RoomController.s_cmds.exitGame);
		end);
	else
		-- 客户端判断到金币不足，显示金币购买弹窗
		if not self:judgeMoneyAndShowChargeWnd()
			and GameConstant.platformConfig ~= PlatformConfig.platformContest then
			return;
		end
		self:readyAction();
		self.nodePopu:removeChild(self.resultView, true);
		self.resultView = nil;
	end
]]--

end

-- 普通场一局结束
RoomScene.gameOver = function ( self, data )
	DebugLog("RoomScene.gameOver")
	self.reconnectRoom = false;
	GameEffect.getInstance():stop();
	self.mahjongManager:setAllMahjongFrameDown();
	self:dealGameOverInHandCards(data.resuleInfoList);

	local isFinalHu = false;
	local sm = self.seatManager;
	for k , v in pairs(data.resuleInfoList) do
		local player = PlayerManager.getInstance():getPlayerById(v.userId);
		if 1 == v.isDaJiao then -- 被查大叫
			self:playGameAnim(SpriteConfig.TYPE_CHADAJIAO, player.localSeatId);
			TeachManager.getInstance():show(TeachManager.CHA_DA_JIAO_TIP);
		end
		if 1 == v.isHuaZhu then -- 被查花猪
			self:playGameAnim(SpriteConfig.TYPE_CHAHUAZHU, player.localSeatId);
			TeachManager.getInstance():show(TeachManager.CHA_DA_JIAO_TIP);
		end
	end
	sm:gameFinish();

	self.mahjongManager:showBigCardCenterDiscard();
	-- 移除中心显示的打出牌
	self.mahjongManager:removeBigShowCenterView();
	--设置所有加番的牌图标为有
	self.mahjongManager:setAllHuAddFan();

	self:showOrDisapperTuoguan(false);

--[[
	if self.outCardTimer then
		self.outCardTimer:hide();
	end

	if self.leftCardNumText then
		self.leftCardNumText:setVisible(false);
		self.leftCardNumStatic:setVisible(false);
	end
]]
	for k,v in pairs(data.resuleInfoList) do
		if v.userId == PlayerManager.getInstance():myself().mid then
			-- 更新一次本局金币数
			RoomData.getInstance().isReconnect = false;
			if RoomData.getInstance().isBankruptSubsidize then
				RoomData.getInstance().mineCurGameWinMoney = v.tempTurnMoney;
			else
				RoomData.getInstance().mineCurGameWinMoney = v.turnMoney;
			end
			self:caluMoneyExchange( 0 );
		end
	end

	-- 显示暗杠的牌
	self.mahjongManager:showAnGangMahjongWhenGameOver();


	-- 先把界面创建出来，延迟显示
	self.resultView = new(GameResultWindow, self);
	self.nodePopu:addChild(self.resultView);
	self.resultView:hide();
	self.resultView:parseDataAndShowInitinfo( data );
	self.resultView:setCallbackClose(self, function ( self )
		if self.resultView then
			self.nodePopu:removeChild(self.resultView, true);
			self.resultView = nil;
		end
		self:showReadyBtn();
	end);
	self.resultView:setAgainCallback(self, function ( self , isForceReady)
		self:againBtnFun(isForceReady);
	end);

	--设置单机版的联网
	self.resultView:setConfirmCallback("联 网", self, function ( self )
        -- 当前money存入硬盘
        g_DiskDataMgr:setAppData('singleMyMoney',PlayerManager.getInstance():myself().money)
		self:toHall();
		GameConstant.singleToOnline = true;
	end);

	delete(self.showResultAnim);
	self.showResultAnim = new(AnimInt, kAnimNormal,0,1,3000,0);
	self.showResultAnim:setDebugName("RoomScene|self.showResultAnim");
	self.showResultAnim:setEvent(self, function ( self )
		-- self:showOrHideAgainBtn(true); -- 显示再来一局按钮
		delete(self.showResultAnim);
		self.showResultAnim = nil;
		for k,v in pairs(self.seatManager.seatList) do
			-- v:changeToWaitStaty();
			local p = PlayerManager.getInstance():getPlayerBySeat(k);
			if p then
				v:setReadyStatu(p.isReady);
			end
		end
		-- self:clearDesk();
		if self.resultView then
			self.resultView:show();
		end
		self:hideReadyBtn();
		TeachManager.getInstance():hide();

		--显示金币雨
		--播放掉金币动画
		if self.resultView and self.resultView:getResultMoney() > 0 then
			showGoldDropAnimation();
		end
	end);
end

-- 处理牌局结束后玩家的手牌
RoomScene.dealGameOverInHandCards = function (self, result)
	for k , v in pairs(result) do
		local player = PlayerManager.getInstance():getPlayerById(v.userId);
		local list = v.cardList;
		if 1 == v.isHu then
			if not RoomData.getInstance().isXueLiu then
				if needToDiscard(#list) then  -- 如果多了胡牌
					for r , t in pairs(list) do
						if t == v.huCard then
							table.remove(list , r);
							break;
						end
					end
				end
				self.mahjongManager:setHuCardBySeat(player.localSeatId , v.huCard , v.huType , true);
			end
			self.mahjongManager:setInHandCardsWhenGameOver(player.localSeatId ,list);
			if v.isQiangGangHu and 1 == v.isQiangGangHu then
				self.mahjongManager:playerQiangGangHu(v.huCard);
			end
		else
			self.mahjongManager:setInHandCardsWhenGameOver(player.localSeatId ,list);
		end
	end
end

RoomScene.dealGameOverInHandCards2 = function (self, result)
	DebugLog("dealGameOverInHandCards2");
	for k , v in pairs(result) do
		local player = PlayerManager.getInstance():getPlayerById(v.mid);
		local list = v.cards;
		for j,n in pairs(v.huInfo) do
			if n.isQiangGangHu == 1 then
				self.mahjongManager:playerQiangGangHu(n.huCard);
			end
		end
		self.mahjongManager:setInHandCardsWhenGameOver(player.localSeatId ,list);
		if v.huCount > 0 then
			if not RoomData.getInstance().isXueLiu then
				if needToDiscard(#list) then  -- 如果多了胡牌
					for r , t in pairs(list) do
						if t == v.huInfo[1].huCard then
							table.remove(list , r);
							break;
						end
					end
				end
				self.mahjongManager:setHuCardBySeat(player.localSeatId , v.huInfo[1].huCard, v.huInfo[1].huType , true);
			end
			self.mahjongManager:setInHandCardsWhenGameOver(player.localSeatId ,list);
		else
			self.mahjongManager:setInHandCardsWhenGameOver(player.localSeatId ,list);
		end
	end
end

-- 重连处理桌面信息
RoomScene.dealTableInfo = function (self , data)
	if self.selectQueView then
		self.nodeDingQue:removeChild(self.selectQueView, true);
		self.selectQueView = nil;
	end

	local roomData = RoomData.getInstance();
	roomData.isStartSwapCard = false;

	self:hideSwapCardTip();

	self:showTableInfo(2,true)

	for k,v in pairs(PlayerManager.getInstance().playerList) do
		self.seatManager.seatList[v.localSeatId]:setData(v);
	end
	local myself = PlayerManager.getInstance():myself();
	self.seatManager.seatList[kSeatMine]:setData(myself);

	local bankSeatId = Player.getLocalSeat(data.roomInfo.bankSeatId);
	self.seatManager:getSeatByLocalSeatID(bankSeatId,self):setBankSeat();
	self.seatManager:changeToStartGameStatu(false);
	RoomData.getInstance().leftcard = data.roomInfo.remainCardCount;
	self:showLeftCardNum( RoomData.getInstance().leftcard )
	local reconnectquelist = {};
	if 1 == RoomData.getInstance().diQue then   -- 如果是选缺
		for k = kSeatMine , kSeatLeft do
			local aplayer = PlayerManager.getInstance():getPlayerBySeat(k);
			DebugLog("kSeatMine , kSeatLeft k:"..tostring(k));
			if aplayer.dingQueType then
				DebugLog("aplayer.dingQueType:"..tostring(aplayer.dingQueType));
			else
				DebugLog("not aplayer.dingQueType");
			end
			if aplayer and aplayer.dingQueType and aplayer.dingQueType >= 0 and aplayer.dingQueType <= 2 then -- 如果已经选好缺
				self.seatManager.seatList[k]:dingque(aplayer.dingQueType);
				if k ~= kSeatMine then
					reconnectquelist[tostring(k)] = aplayer.dingQueType;
				end
			else
				if k == kSeatMine then
					self.mahjongManager:setMineInHandCardsCanNotDoAnything();
					--self:showMyselfSelectQueView();
				end
				--
			end
		end

		if self._fmrData then
			--自己被server选择了 其他玩家看情况
			DebugLog("reconnectquelist");
			DebugLog(reconnectquelist);
			--1定却 2换三张 0
			if data.connectStatus then
				if data.connectStatus==1 then
					local countmax = table.maxValue(reconnectquelist);
					if countmax < 3  then
						self:showMyselfSelectQueView(reconnectquelist);
					end
				elseif data.connectStatus==2 then
					--提示正在换三张
					self:showSwapCardTip(2);
				end
			end
			--local view = PopuFrame.showNormalDialog( "温馨提示", "data.connectStatus:"..tostring(data.connectStatus), nil, nil, nil, false, false, "确定");
		end
	end

end
-- 重连成功处理玩家的信息
RoomScene.reconnectDealPlayerInfo = function (self , data)
	DebugLog("RoomScene.reconnectDealPlayerInfo")
	local playerMgr = PlayerManager.getInstance();
	playerMgr:removeOtherPlay(); -- 先移除其他玩家
	local mySelf = playerMgr:myself();
	local roomData = RoomData.getInstance();
	roomData:enterRoom(data.roomInfo); -- 初始化进入房间的数据
	if roomData.di == 0 then -- 说明是私人房间
		roomData:setPrivateRoomInfo(roomData:getLastPrivateRoomInfo()); -- 设置私人房间数据
		roomData.di = tonumber(roomData:getLastPrivateRoomInfo() or 0);
	end
	-- 自己的网络座位id一定要先赋值，用于计算其他玩家的本地座位id
	Player.myNetSeat = roomData.mySeatId;
	mySelf.seatId = Player.myNetSeat;
	mySelf.money = roomData.myMoney;
	mySelf.isReady = false; -- 自己进入房间时是未准备状态
	-- 先把player信息拿到
	local playerInfo = data.playerInfo;
	for k , v in pairs(playerInfo) do
		local pi = {};
		pi.userId =   v.userId;
		pi.seatId =   v.seatId;
		pi.isReady =  1;
		pi.userinfo = v.userinfo;
		pi.money =    v.money;
		local player = PlayerManager.getInstance():parseNetPlayerData(pi);
		if v.isDingQue > 0 then
			player.dingQueType = v.dingQueType;
		end
		if v.isHu > 0 then
			player.isHu = true;
		end
	end
	if data.selfInfo.isDingQue > 0 then
		RoomData.getInstance().diQue = 1;
		mySelf.dingQueType = data.selfInfo.dingQueType;
	end
	if data.selfInfo.isHu > 0 then
		mySelf.isHu = true;
	end
end

-- 重连成功
RoomScene.reconnectSuccess = function (self , data)
	-- 测试多次重连
	DebugLog("测试多次重连")
	DebugLog(data);
	--self.isFreeMatch = data.isFreeMatch;

	-- if isTestReconnect then
	-- 	DebugLog("测试多次重连...222")
	-- end
	-- if not isTestReconnect then
	-- 	DebugLog("测试多次重连.....1")
	-- 	isTestReconnect = true
	-- 	self:reconnectSuccess(data)
	-- end
	self:clearAllScene()

	self:getRoomActivityInfo();  --开始获取金币活动

	self.beforeServerOutCardValue = 0;
	GlobalDataManager.getInstance():getTuiJianProduct();
	PlayerManager:getInstance():myself().isInGame = true;
	self.reconnectingGameDirect = false;
	self:reconnectDealPlayerInfo(data);
	self:requireChestStatus();   -- 请求宝箱
	-----------
	RoomData.getInstance().isReconnect = true;
	DebugLog("重连成功");
	self.reconnectRoom = true;
	--self.reconnectFlagShowInfo = false;

	self:changeFrameCount(data.isLiangFanPai and 11 or 14);

	self:dealTableInfo(data);
	self:reconnectSetOthersPlayerCards(data.playerInfo);
	self:reconnectSetMineCards(data.selfInfo);
	local player = PlayerManager.getInstance():myself();
	local localfid = data.fid or 0;
	if not player.isHu then
		if localfid==0 then
			player.isAi = true;
			self:showOrDisapperTuoguan(true);
		else
			--self:checkMyselfOutCardState();
		end
		PlayerManager:getInstance():myself().isInGame = true;
		self.mahjongManager:setAllAddFan();
	else
		PlayerManager:getInstance():myself().isInGame = false;
		self.mahjongManager:setAllHuAddFan();
	end

	--金币可见
	self:showMoneyExchange(true);

	--fuckkkkk
	self:reconnectShowPlayerPosition(data.playerInfo,data.selfInfo,false);

end

RoomScene.reconnectShowPlayerPosition = function (self ,playerInfo, selfInfo, isxueliu)
	--fuckkkkk 重连设置当前玩家的指示位置
	self:setOutCardTimer(-1,RoomData.getInstance().operationTime);

	for k , v in pairs(playerInfo) do
		local player = PlayerManager.getInstance():getPlayerById(v.userId);
		local inHandCards = self.mahjongManager:getInHandCardsBySeat(player.localSeatId);
		local xcount = table.maxValue(inHandCards);
		if checkShowPlayerTurn(xcount) then
			if isxueliu then
				self:setOutCardTimer(player.localSeatId, RoomData.getInstance().outCardTimeLimit);
			else
				if v.isHu<=0 then
					self:setOutCardTimer(player.localSeatId, RoomData.getInstance().outCardTimeLimit);
				end
			end
		end
	end
	local player = PlayerManager.getInstance():myself();
	local inHandCards = self.mahjongManager:getInHandCardsBySeat(player.localSeatId);
	local xcount = table.maxValue(inHandCards);
	if checkShowPlayerTurn(xcount) then
		if isxueliu then
			self:setOutCardTimer(player.localSeatId, RoomData.getInstance().outCardTimeLimit);
		else
			if selfInfo.isHu<=0 then
				self:setOutCardTimer(player.localSeatId, RoomData.getInstance().outCardTimeLimit);
			end
		end
	end
end

-- 重连成功自己的牌
RoomScene.reconnectSetMineCards = function (self , selfInfo)
	local player = PlayerManager.getInstance():myself();
	for r , t in pairs(selfInfo.pengList) do
		self.mahjongManager:playerBlockWithSeatAndValue(player.localSeatId , t , PUNG);
	end
	for r , t in pairs(selfInfo.gangList) do
		local opType;
		if t.isAnGang > 0 then
			opType = AN_KONG;
		else
			opType = PUNG_KONG;
		end
		self.mahjongManager:playerBlockWithSeatAndValue(player.localSeatId , t.card , opType);
	end
	for r , t in pairs(selfInfo.outCardList) do
		if 1 ~= t.symbol then   -- 如果不是被碰杠的牌
			self.mahjongManager:showDiscardOnTable(player.localSeatId , t.card);
		end
	end
	if selfInfo.isHu > 0 then
		player.isHu = selfInfo.isHu;
		if needToDiscard(#selfInfo.cardList) then  -- 如果多了胡牌
			for r , t in pairs(selfInfo.cardList) do
				if t == selfInfo.huCard then
					table.remove(selfInfo.cardList , r);
					break;
				end
			end
		end
	end
	self.mahjongManager:creatMineMahjong(selfInfo.cardList);
	self.mahjongManager:sortInHandCards(player.dingQueType);
	self.mahjongManager:drawInhandCards(player.localSeatId);
	local inHandCards = self.mahjongManager:getInHandCardsBySeat(player.localSeatId);
	for r , t in pairs(inHandCards) do
		t:setVisible(true);
	end
	if selfInfo.isHu > 0 then
		self.mahjongManager:setInHandCardsWhenHuBySeat(player.localSeatId);
		self.mahjongManager:setHuCardBySeat(player.localSeatId , selfInfo.huCard , selfInfo.huType);
		local sm = self.seatManager;
		sm.seatList[player.localSeatId]:huInGame(selfInfo.huType);
	else
		self.mahjongManager:setMineInHandCardsCanNotDoAnything();
		if needToDiscard(#inHandCards) then
			self.turnToSeat = kSeatMine;
			self:setOutCardTimer(kSeatMine , RoomData.getInstance().outCardTimeLimit);
		else
			self:setOutCardTimer(-1 , RoomData.getInstance().outCardTimeLimit);
		end
	end

end

-- 重连成功其他人的牌
RoomScene.reconnectSetOthersPlayerCards = function (self , playerInfo)
	for k , v in pairs(playerInfo) do
		local player = PlayerManager.getInstance():getPlayerById(v.userId);
		for r , t in pairs(v.pengList) do
			self.mahjongManager:playerBlockWithSeatAndValue(player.localSeatId , t , PUNG);
		end
		for r , t in pairs(v.gangList) do
			local opType;
			if t.isAnGang > 0 then
				opType = AN_KONG;
			else
				opType = PUNG_KONG;
			end
			self.mahjongManager:playerBlockWithSeatAndValue(player.localSeatId , t.card , opType);
		end
		for r , t in pairs(v.outCardList) do
			if 1 ~= t.symbol then   -- 如果不是被碰杠的牌
				self.mahjongManager:showDiscardOnTable(player.localSeatId , t.card);
			end
		end
		self.mahjongManager:creatOtherPlayerMahjong(player.localSeatId , v.cardCount);
		self.mahjongManager:drawInhandCards(player.localSeatId);
		local inHandCards = self.mahjongManager:getInHandCardsBySeat(player.localSeatId);
		for r , t in pairs(inHandCards) do
			t:setVisible(true);
		end
		if v.isHu > 0 then
			player.isHu = v.isHu;
			self.mahjongManager:setInHandCardsWhenHuBySeat(player.localSeatId);
			self.mahjongManager:setHuCardBySeat(player.localSeatId , v.huCard , v.huType);
			local sm = self.seatManager;
			sm.seatList[player.localSeatId]:huInGame(v.huType);
		end
	end
end
RoomScene.clearAllScene = function(self)
	for k,v in pairs(self.seatManager.seatList) do
		v:changeToWaitStaty();
		v:clearData();
	end
	self:clearDesk()
end
-- 血流重连成功
RoomScene.reconnectSuccessScXLCH = function (self , data)
	self:clearAllScene()
	self:getRoomActivityInfo();  --开始获取金币活动

	self.beforeServerOutCardValue = 0;
	GlobalDataManager.getInstance():getTuiJianProduct();
	PlayerManager:getInstance():myself().isInGame = true;
	self.reconnectingGameDirect = false;
	self:reconnectDealPlayerInfo(data);
	self:reconnectDealHuInfo(data);
	self:setPrivateRoomData(data);
	self:requireChestStatus();   -- 请求宝箱
	------------------------------------
	self.reconnectRoom = true;
	RoomData.getInstance().isReconnect = true;
	DebugLog("血流重连成功");
	self:changeFrameCount(data.isLiangFanPai and 11 or 14);
	self:dealTableInfo(data);
	self:reconnectSetOthersPlayerCardsXLCH(data.playerInfo);
	self:reconnectSetMineCardsXLCH(data.selfInfo);
	local player = PlayerManager.getInstance():myself();
	local localfid = data.fid or 0;
	if not player.isHu then
		if localfid==0 then
			player.isAi = true;
			self:showOrDisapperTuoguan(true);
		else
			--self:checkMyselfOutCardState();
		end
	end

	local addFanCard = data.addFanCard;
	self:updateAddFan(addFanCard);
	self:createRecconectAddFan();
	self.mahjongManager:setAllAddFan();

	--金币可见
	self:showMoneyExchange(true);
	--
	if data.roomInfo and data.roomInfo.isXueLiu then
		RoomData.getInstance().isXueLiu = true;
	end

end
-- 血流重连处理胡牌信息
RoomScene.reconnectDealHuInfo = function (self , data)
	local playerInfo = data.playerInfo;
	for k , v in pairs(playerInfo) do
		if v.isHu > 0 then
			local player = PlayerManager.getInstance():getPlayerById(v.userId);
			for r , t in pairs(v.huInfo) do
				player.isHu = true;
				local huTypeInfo = RoomData.getInstance():getHuTypeInfoBySeat(player.localSeatId);
				if 1 == t.huType then
					huTypeInfo.hu = huTypeInfo.hu + 1;
				else
					huTypeInfo.zimo = huTypeInfo.zimo + 1;
				end
			end
		end
	end
	if data.selfInfo.isHu > 0 then
		local player = PlayerManager.getInstance():myself();
		player.isHu = true;
		for r , t in pairs(data.selfInfo.huInfo) do
			local huTypeInfo = RoomData.getInstance():getHuTypeInfoBySeat(player.localSeatId);
			if 1 == t.huType then
				huTypeInfo.hu = huTypeInfo.hu + 1;
			else
				huTypeInfo.zimo = huTypeInfo.zimo + 1;
			end
		end
	end
end


RoomScene.setPrivateRoomData = function ( self, data )
	local roomData = {};
	if data.roomInfo.isXueLiu then
		roomData.isXlch = 1;
	else
		roomData.isXlch = 0;
	end
	roomData.curDi = data.roomInfo.tai;
	RoomData.getInstance():setPrivateRoomData(roomData);
end



RoomScene.showChatOrFace = function ( self, data )
	DebugLog("[RoomScene]:showChatOrFace");
	local mid = data.mid;

	local player = PlayerManager.getInstance():getPlayerById(mid);
	if not player then-- or player == PlayerManager.getInstance():myself()
		return;
	end

	local seat = self.seatManager:getSeatByLocalSeatID(player.localSeatId);
	if not seat then
		return;
	end

	if "face" == data.type then -- 显示表情
		seat:showFace(data.faceType);
	else -- 显示文字
		seat:showChat(data.msg);
		self:addChatLog(data);
	end
end
----
--[[
	data = {}
	data.type = "chat"  ||  or  "voice"
	data.mid  = 9000772
	data.msg  = "很高兴的空间疯狂地"
	data.filename = "xxxxx.amr"
]]
------
RoomScene.addChatLog = function (self, data )
	data.time     = os.time()
	--data.filename = data.filename

	local player  = PlayerManager.getInstance():getPlayerById(data.mid)
	data.name     = player and player.nickName or ""
	table.insert(self.chatLogs, data)
end

-- 判断玩家钱数，如钱数不足则显示破产弹窗
RoomScene.judgeMoneyAndShowChargeWnd = function ( self )
	if GameConstant.isSingleGame then
		return true;
	end
	local roomNeedMoney = getHallConfigLimitByLevel(GameConstant.curRoomLevel);
	if not roomNeedMoney or PlayerManager.getInstance():myself().money >= roomNeedMoney then
		return true;
	end
	-- 玩家的钱数小于房间要求的金币数，显示购买弹窗
	self:playerMoneyNoEnough(roomNeedMoney);
	return false;
end

-- 玩家钱数不足
-- requireMoney 要求的钱数
RoomScene.playerMoneyNoEnough = function ( self, requireMoney )
    local param_t = {t = RechargeTip.enum.enter_game,
        isShow = true, roomlevel = GameConstant.curRoomLevel, money= requireMoney,
        noEnoughMoney = true,
        probability_giftpack = 1,
        is_check_bankruptcy = true,
        is_check_giftpack = true,};
    RechargeTip.create(param_t)
end

-- 钱不足，服务器把玩家踢出房间（现在是在玩家准备时进行钱数判断）
RoomScene.kickoutRoom = function ( self, data )

end

-- 血流重连成功自己的牌
RoomScene.reconnectSetMineCardsXLCH = function (self , selfInfo)
	local player = PlayerManager.getInstance():myself();
	for r , t in pairs(selfInfo.pengList) do
		self.mahjongManager:playerBlockWithSeatAndValue(player.localSeatId , t , PUNG);
	end
	for r , t in pairs(selfInfo.gangList) do
		local opType;
		if t.isAnGang > 0 then
			opType = AN_KONG;
		else
			opType = PUNG_KONG;
		end
		self.mahjongManager:playerBlockWithSeatAndValue(player.localSeatId , t.card , opType);
	end
	for r , t in pairs(selfInfo.outCardList) do
		if 1 ~= t.symbol then   -- 如果不是被碰杠的牌
			self.mahjongManager:showDiscardOnTable(player.localSeatId , t.card , t.symbol);
		end
	end
	self.mahjongManager:creatMineMahjong(selfInfo.cardList);
	self.mahjongManager:sortInHandCards(player.dingQueType);
	self.mahjongManager:drawInhandCards(player.localSeatId);
	local inHandCards = self.mahjongManager:getInHandCardsBySeat(player.localSeatId);
	for r , t in pairs(inHandCards) do
		t:setVisible(true);
	end
	self.mahjongManager:setMineInHandCardsCanNotDoAnything();
	if needToDiscard(#inHandCards) then
		self.turnToSeat = kSeatMine;
		self:setOutCardTimer(kSeatMine , RoomData.getInstance().outCardTimeLimit);
	else
		self:setOutCardTimer(-1 , RoomData.getInstance().outCardTimeLimit);
	end
	if player.isHu then
		local sm = self.seatManager;
		local huTypeInfo = RoomData.getInstance():getHuTypeInfoBySeat(player.localSeatId);
		sm.seatList[player.localSeatId]:huInGameXLCH(huTypeInfo);
	end
end

-- 血流重连成功其他人的牌
RoomScene.reconnectSetOthersPlayerCardsXLCH = function (self , playerInfo)
	for k , v in pairs(playerInfo) do
		local player = PlayerManager.getInstance():getPlayerById(v.userId);
		for r , t in pairs(v.pengList) do
			self.mahjongManager:playerBlockWithSeatAndValue(player.localSeatId , t , PUNG);
		end
		for r , t in pairs(v.gangList) do
			local opType;
			if t.isAnGang > 0 then
				opType = AN_KONG;
			else
				opType = PUNG_KONG;
			end
			self.mahjongManager:playerBlockWithSeatAndValue(player.localSeatId , t.card , opType);
		end
		for r , t in pairs(v.outCardList) do
			if 1 ~= t.symbol then   -- 如果不是被碰杠的牌
				self.mahjongManager:showDiscardOnTable(player.localSeatId , t.card , t.symbol);
			end
		end
		self.mahjongManager:creatOtherPlayerMahjong(player.localSeatId , v.cardCount);
		self.mahjongManager:drawInhandCards(player.localSeatId);
		local inHandCards = self.mahjongManager:getInHandCardsBySeat(player.localSeatId);
		for r , t in pairs(inHandCards) do
			t:setVisible(true);
		end
		if v.isHu > 0 then
			local sm = self.seatManager;
			local huTypeInfo = RoomData.getInstance():getHuTypeInfoBySeat(player.localSeatId);
			sm.seatList[player.localSeatId]:huInGameXLCH(huTypeInfo);
		end
	end
end

RoomScene.clearDesk = function ( self )
	self.mahjongManager:clearData();
	if not PlayerManager.getInstance():myself().isHu then --  自己之前有胡牌的话，在这里清理一次数据
		self:setMineGameFinish();
	end
	RoomData.getInstance():initHuTypeInfo();

	--清除中央提示
	if self.centerTipBg then
		delete(self.centerTipBg);
		self.centerTipBg = nil;
	end
	if self.centerTipCard then
		delete(self.centerTipCard);
		self.centerTipCard = nil;
	end
--[[
	if self.outCardTimer then
		self.outCardTimer:hide();
	end

	if self.leftCardNumText then
		self.leftCardNumText:setVisible(false);
		self.leftCardNumStatic:setVisible(false);
	end
]]
	self:hideReadyBtn()

	if self.resultView then
		self.nodePopu:removeChild(self.resultView, true);
		self.resultView = nil;
	end

	--删除加番
	self:deleteAddFanNode();

	self:showTableInfo(1,true)

end

RoomScene.setMineGameFinish = function ( self )
    if self.tuoGuanAni then
	    self.tuoGuanAni:disapper();
	end
end



RoomScene.backEvent = function ( self )
    if HallScene_instance then
        return;
    end
    -- pop window
    if back_event_manager.get_instance():get_display_size() < 1 then
        self:exitGameRequire();
    else
        back_event_manager.get_instance():excute();
    end
end
--------------------------------加番相关------------------------------------------------------------
--加番玩法
RoomScene.updateAddFan = function(self,fan_card)

	-- fan_card = 1;--测试测效果用
	if not fan_card then
		return;
	end
	if tonumber(fan_card) > 50 or GameConstant.isSingleGame then
		return;
	end
	GameConstant.addFanPai = string.format("0x%02X",fan_card);
end

RoomScene.createAddFan = function(self)
	if GameConstant.isSingleGame then
		return;
	end
	--加番场开始创建加番
	if GameConstant.addFanPai ~= "" then
		local fan_card_pic = "own_hand_" .. GameConstant.addFanPai .. ".png";
		if not MahjongImage_map[fan_card_pic] then
			return;
		end

		local FanW, FanH = 134, 134;
		local x, y = self.mahjongManager.mahjongFrame:getPos(kSeatMine);
		local w, h = self.mahjongManager.mahjongFrame:getSize(kSeatMine);

		x = x + (w - FanW)/2;
		y = y- 10 - FanH;

		self:createFanNode(fan_card_pic,x, y);
	end
end

RoomScene.showUserUpdateAnim = function( self, infoTable )
	local player = PlayerManager:getInstance():myself();
	local mid = player.mid;
	if infoTable.matchScoreTable and infoTable.matchScoreTable[mid..""] then
		if infoTable.matchScoreTable[mid..""].explevel and infoTable.matchScoreTable[mid..""].expmoney then
			local level = tonumber( infoTable.matchScoreTable[mid..""].explevel );
			local money = tonumber( infoTable.matchScoreTable[mid..""].expmoney );

			if level and level > player.level then
				self:updateLevelAndMoney( level, money );
				require("Animation/UserUpdateAnim");
				local testanim = new( UserUpdateAnim, nil, money or 0 );
				testanim:play( function()
					delete( testanim );
				end);
			else
				log( "未达到升级条件" );
			end
		end
	end
end

RoomScene.updateLevelAndMoney = function( self, level, money )
	local player = PlayerManager.getInstance():myself();
	player.level = level;
	player:addMoney( money );
end

RoomScene.updateMatchInfo = function ( self, data )
	DebugLog("ttt RoomScene.updateMatchInfo")
end

RoomScene.createFanNode = function(self,fan_card_pic, x, y)
	if GameConstant.isSingleGame then
		return;
	end
	self.addFanNode = new(Node);
	self.addFanNode:setLevel(20000);

	self.m_image = UICreator.createImg("Room/addfan/add_fan_light.png",0,0);
	local m_diTu = UICreator.createImg("Room/addfan/addfan_bg.png",0,0);
	local paiDi = UICreator.createImg(MahjongImage_map["front_block_2.png"],38,9);
	local paiShu = UICreator.createImg(MahjongImage_map[fan_card_pic],43,26);
	local add_fan_icon = UICreator.createImg("Room/addfan/add_fan_up.png",25,83);
	--围绕中心点旋转，5000毫秒一圈(ps:500ms太快了)
	self.m_image:addPropRotate(1, kAnimRepeat, 5000, 0, -360, 0, kCenterDrawing);
	--转4秒停止
	self.m_image.animIndex=new(AnimInt,kAnimNormal,0,500,2*1000,-1);
	self.m_image.animIndex:setEvent(self,self.removePropRotate);

	self.addFanNode:addChild(self.m_image);
	self.addFanNode:addChild(m_diTu);

	self.addFanNode:addChild(paiDi);
	self.addFanNode:addChild(paiShu);
	self.addFanNode:addChild(add_fan_icon);
	self.nodeOperation:addChild(self.addFanNode);

	self.addFanNode:setPos(x,y);

	--设置自己的加番牌可见
	self.mahjongManager:setAddFanForSeat(kSeatMine);
end

RoomScene.removePropRotate = function(self)
	delete(self.m_image.animIndex);
	self.m_image.animIndex = nil;
	local scaleFactor 	= 0.65;
	local FanW, FanH 	= 134, 134;
	local duration 		= 800;
	self.addFanNode:addPropScale(4,kAnimNormal,duration,0,1.0,scaleFactor,1.0,scaleFactor,kCenterXY,FanW/2,FanH/2);
	self.addFanNode:addPropTranslate(5,kAnimNormal,duration,0,0,-(self.addFanNode.m_x / System.getLayoutScale() + FanW * (1-scaleFactor) / 2 )/scaleFactor,0,-self.addFanNode.m_y / System.getLayoutScale()/ scaleFactor);
end

--删除加番的东西
RoomScene.deleteAddFanNode = function(self)
	if self.addFanNode then
		GameConstant.addFanPai = "";
		self.nodeOperation:removeChild(self.addFanNode,true);
		self.addFanNode = nil;
	end
end

RoomScene.createRecconectAddFan = function(self)
	if GameConstant.addFanPai ~= "" and GameConstant.addFanPai ~= "0x00" then
		local fan_card_pic = "own_hand_" .. GameConstant.addFanPai .. ".png";

		self:createFanNode(fan_card_pic, 0, 0);
		self:removePropRotate();
	end
end

RoomScene.broadcastMsg = function( self )
--[[
	if not self.myBroadcast then
		self.myBroadcast = new(BroadcastAnimation, self.broadcastTrumpet);
	end
	self.myBroadcast:play(2, self.broadcastView, self.broadcastImg, 2, self.broadcastBtn);
    if self.broadcastPopWin and self.broadcastPopWin:getVisible() then
        self.broadcastPopWin:flushMesItem();
    end
]]

	if not self.myBroadcast then
		self:initBroadCastView()
	end
	self.myBroadcast:play();
	if self.broadcastPopWin and self.broadcastPopWin:getVisible() then
		self.broadcastPopWin:flushMesItem();
	end
end

function RoomScene.resetOutCardTimer( self , data )
	if not data then
		return;
	end
	if self.operationView then -- 隐藏
		self.operationView:hideOperation();
	end
	local player = PlayerManager.getInstance():getPlayerById(data.mid);
	if player then
		self:setOutCardTimer(player.localSeatId, data.outtime);
		if player.isMyself then
			if RoomData.getInstance().isXueLiu then
				self.mahjongManager:setMineInHandCardsWhenOutCardXLCH();
			else
				self.mahjongManager:setMineInHandCardsWhenOutCard();
			end
		end
	end
end

function RoomScene.enterRoomEroor( self , data )
	-- 进入房间失败，直接退出
	Banner.getInstance():showMsg(data.msg or "进入房间失败！");
	self:exitGame();
end

function RoomScene.initBroadCastView( self )
	require("Animation/BroadcastAnimation");
	local w,h,x,y = 700,500,0,0

	--w,h,x,y = 830,630,0,150

	self.myBroadcast = new(BroadcastAnimation, w,h,50);
	self.myBroadcast:setAlign(kAlignTop)
	self.myBroadcast:setPos(x,y)
	self.myBroadcast:setLevel(500)
	self:addChild(self.myBroadcast)

	self.myBroadcast:setOnClickedCallback(self, self.OnBroadcastBtnClick)

	if GameConstant.isSingleGame then
		self.myBroadcast:setVisible(false);
	end

end

RoomScene.showChestStartup = function ( self, t )
	if 1 == t.open and not GameConstant.isSingleGame and not TeachRoomScene_instance and not self:isFreeMatchGame() then
		local chestBtn = self:getControl(RoomScene.s_controls.chestBtn);
		local chestText = self:getControl(RoomScene.s_controls.chestText);

		chestBtn:setOnClick(self, function( self )
			self:requireChestPopWnd();
		end);
		local text = "玩牌(" .. t.process .. "/" .. t.need .. ")";

		local boxType = t.boxType;
		local imgStatus = 1
		if 1 == t.award then
			imgStatus = 2--open
		end
		self:updateChestImg(imgStatus)
		chestBtn:setVisible(true);
		chestText:setText(text);
		chestText:setVisible(true)
	end

end

RoomScene.showChestPopWnd = function(self, data)
	require("MahjongRoom/ChestPop");
	self.chestPopWnd = new(ChestPop, data);
	self.nodePopu:addChild(self.chestPopWnd);
end

RoomScene.updateChestText = function ( self, t )
	local chestText = self:getControl(RoomScene.s_controls.chestText);
	local text = "玩牌(" .. t.process .. "/" .. t.need .. ")";
	chestText:setText(text);
end

RoomScene.hideChestStartup = function ( self )
	self.chestProcessJu = -1;
	self:getControl(RoomScene.s_controls.chestBtn):setVisible(false);
	self:getControl(RoomScene.s_controls.chestText):setText("");
end

RoomScene.updateChestImg = function ( self, status )
	local boxType = RoomData.getInstance().boxType;
	local imgPath = "";
	if 1 == status then
		imgPath = "Room/chest/chest_l_"..boxType..".png";
	elseif 2 == status then
		imgPath = "Room/chest/chest_l_open_"..boxType..".png";
	end
	self:getControl(RoomScene.s_controls.chestBtn):setFile(imgPath);
end



RoomScene.showChestAwardTip = function ( self, str )
	AnimationAwardTips.play(str);
end

RoomScene.broadcastUpdateMoney = function ( self )
	-- body
	--更新自己金币
	-- DebugLog( "broadcastUpdateMoney orignal money = "..PlayerManager.getInstance():myself().money );
	-- DebugLog( "broadcastUpdateMoney = ".. trunNumberIntoThreeOneFormWithInt(PlayerManager.getInstance():myself().money or "", true));
	local pText = self:getControl(RoomScene.s_controls.mt)
	pText:setText("")
	setMoneyNode( PlayerManager.getInstance():myself().money ,pText )
end

RoomScene.nativeCallEvent = function ( self, param, data )
	DebugLog( "RoomScene.callEvent param = "..param);
	if param == kCheckWechatInstalled then
		self:resetShareAppInstalledState( param );
	end

	if param == kFetionUploadHeadicon then
		local json_data = initResult(param);
		if json_data then
			local player = PlayerManager.getInstance():myself();
			if player.mid > 0  then
				player.localIconDir = player.mid .. ".png";
			end
		end
	elseif kScreenShot == param then -- 显示分享窗口

	elseif param == kNoticeLoopCallLua then
		DebugLog("MusicLog  java to lua kNoticeLoopCallLua")
		local json_data = initResult( param )
		local musicName = json_data.musicName
		if musicName == MusicConfig["bgmHu"] then --胡牌音乐播放结束了
			self:playBackGroundMusic("bgm")
		end
	elseif kDownloadImageOne == param then  --下载头像
		if data == self.nameUrlDir then
			self:downloadImgSuccess( self.nameUrlDir )
		end
	end
end
--kNoticeLoopCallLua
----------------------------------------------------------------------------------------
----牌局开始时
function RoomScene:whenOverPlayNormalMusic()
	DebugLog("MusicLog  native_to_java kNoticeLoopCallLua")
	-- body
	--self.someoneHu = false
	--native_to_java(kNoticeLoopCallLua)
end

function RoomScene:hasHued( )
	--胡了,立马切换播放音乐
	--self.someoneHu = true
	if GameConstant.iosDeviceType > 0 then
		return ;
	end
	self:playBackGroundMusic("bgmHu", false)
end

function RoomScene:playBackGroundMusic( key, isLoop )
	if GameConstant.iosDeviceType > 0 then
		GameMusic.getInstance():play( key, true);
		return ;
	end
	if self.currentPlayingKey and self.currentPlayingKey == "bgmHu" and key == "bgmHu" then
		return
	end
	if isLoop == nil then  --默认是循环播放
		isLoop = true
	end
	DebugLog("MusicLog  playBackGroundMusic key:"..key)
	GameMusic.getInstance():play( key, isLoop);
	self.currentPlayingKey = key
end
------------------------------------------------------------------------------------------

function RoomScene.recieveHongBaoNews( self, status, data  )
	DebugLog("RoomScene.recieveHongBaoNews")
	if status == HongBaoModel.recieveNewHongBao then
		self.hongbaoId = data.hongbaoId

		if self.hongbaoNode then
			self:startHongBaoTimer()
		else
			self:createHongBaoEntry()
		end
	end

end

function RoomScene.createHongBaoEntry( self )
	-- body
	self.hongbaoNode = new(Node)
	local lightBg = UICreator.createImg("Room/light.png",0,0);
	lightBg:setAlign(kAlignCenter)
	self.hongbaoNode:addChild(lightBg)
	lightBg:addPropRotate(1,kAnimRepeat,4500,0,0,360,kCenterDrawing)

	local hongbaoImg = nil--UICreator.createImg("")
	hongbaoImg = UICreator.createImg("Hall/hongbao/entry_room.png",0,0);
	hongbaoImg:setAlign(kAlignCenter)
	self.hongbaoNode:addChild(hongbaoImg)

	hongbaoImg:setEventTouch(self , function(self, finger_action, x, y, drawing_id_first, drawing_id_current)
		if kFingerUp == finger_action then

			HongBaoViewManager.getInstance():showHongBaoOpenningView(self.hongbaoId)

			if self.hongbaoNode then
				self.hongbaoNode:removeFromSuper()
				self.hongbaoNode = nil
			end
		end
	end);

	--addtoPos
	self.hongbaoNode:setAlign(kAlignTopRight)
	self.hongbaoNode:setPos(260,160)
	self.hongbaoNode:setLevel(99)
	self.m_root:addChild(self.hongbaoNode)

end


function RoomScene.startHongBaoTimer( self )
	if self.hongbaoNode then
		if not self.hongbaoNode:checkAddProp(0) then
			self.hongbaoNode:removeProp(0)
		end
		local liveTime = HongBaoModel.getInstance():getLimitTime() or 120--
		liveTime = liveTime * 1000
	    local anim = self.hongbaoNode:addPropTranslate(0,kAnimNormal,liveTime,0,0,0,0,0)
	    anim:setDebugName("hongbao alive time anim");
	    anim:setEvent(self,function ( self )
	    	if self.hongbaoNode then
	    		self.hongbaoNode:removeProp(0)
	    		self.hongbaoNode:removeFromSuper()
	    		self.hongbaoNode = nil
	    	end
	    end)
	end
end

---------------------------------------------------------------

RoomScene.resetShareAppInstalledState = function(  self , param )
	local json_date = initResult(param);
	if json_date then
		local QQState = json_date.QQState
		local wechatState = json_date.wechatState
		DebugLog( "QQState "..QQState );
		DebugLog( "wechatState "..wechatState );

		if QQState and tonumber( QQState ) == 1 then
			GameConstant.isQQInstalled = true;
		else
			GameConstant.isQQInstalled = false;
		end

		if wechatState and tonumber( wechatState ) == 1 then
			GameConstant.isWechatInstalled = true;
		else
			GameConstant.isWechatInstalled = false;
		end
	end
end


RoomScene.resume = function(self)
	DebugLog("RoomScene resume");
	GameConstant.curGameSceneRef = self;
	showOrHide_sprite_lua(0);

	self:registerAllEvent()
	GameScene.resume(self);
	--有还未播放的广播则继续播放
	--if not BroadcastMsgManager.getInstance():isEmpty() then
		self:broadcastMsg();
	--end

	DebugLog("time_13 : "..(os.clock() * 1000 - self.startTime));
	-- self:setRoomInfoOnPlaying();

end

RoomScene.pause = function(self)
	DebugLog("RoomScene pause");
	GameScene.pause(self);
	self:unregisterAllEvent()

end

RoomScene.run = function(self)
	GameScene.run(self);
end


RoomScene.stop = function(self)
	GameScene.stop(self);
	self:unregisterAllEvent();
end

RoomScene.pushStateStack = function(self, obj, func)
	if not self.m_state then
		return;
	end
	self.m_state:pushStateStack(obj,func);
end

RoomScene.popStateStack = function(self)
	if not self.m_state then
		return;
	end
	self.m_state:popStateStack();
end


--注销所有的监听事件
RoomScene.registerAllEvent = function ( self )



	EventDispatcher.getInstance():register(SocketManager.s_phpMsg, self, self.onPhpMsgResponse);
	EventDispatcher.getInstance():register(SocketManager.s_serverMsg, self, self.onSocketPackEvent);
	EventDispatcher.getInstance():register(SocketManager.s_serverState, self, self.onSocketStateEvent);
	EventDispatcher.getInstance():register(BaseLogin.loginResuleEvent,self,self.requestLoginCallBack);

	EventDispatcher.getInstance():register(HongBaoModel.HongBaoMsgs, self, self.recieveHongBaoNews);
	------
	EventDispatcher.getInstance():register(Event.Back, self, self.backEvent);
	EventDispatcher.getInstance():register(BroadcastMsgManager.updateSceneEvent, self, self.broadcastMsg);
	EventDispatcher.getInstance():register(GlobalDataManager.updateSceneEvent, self, self.broadcastUpdateMoney);
	EventDispatcher.getInstance():register(NativeManager._Event, self, self.nativeCallEvent);
end

--注销所有的监听事件
RoomScene.unregisterAllEvent = function ( self )
	EventDispatcher.getInstance():unregister(SocketManager.s_phpMsg, self, self.onPhpMsgResponse);
	EventDispatcher.getInstance():unregister(SocketManager.s_serverMsg, self, self.onSocketPackEvent);
	EventDispatcher.getInstance():unregister(SocketManager.s_serverState, self, self.onSocketStateEvent);

	EventDispatcher.getInstance():unregister(BaseLogin.loginResuleEvent,self,self.requestLoginCallBack);
	EventDispatcher.getInstance():unregister(HongBaoModel.HongBaoMsgs, self, self.recieveHongBaoNews);
	--
	EventDispatcher.getInstance():unregister(Event.Back, self, self.backEvent);
	EventDispatcher.getInstance():unregister(BroadcastMsgManager.updateSceneEvent, self, self.broadcastMsg);
	EventDispatcher.getInstance():unregister(GlobalDataManager.updateSceneEvent, self, self.broadcastUpdateMoney);
	EventDispatcher.getInstance():unregister(NativeManager._Event, self, self.nativeCallEvent);
end
-------------------------------------------------------------------------------------------------
RoomScene.friendDataControlled = function(self,actionType, actionParam)
	if actionType == kInvitingFriendInRoom then
		GameConstant.isInvited = true;
		self:exitGame();

	elseif kTrackFriendByPHP == actionType then
		if actionParam then
			if MatchRoomScene_instance and 8 ~= GameConstant.matchStatus.matchStage and 9 ~= GameConstant.matchStatus.matchStage then
				Banner.getInstance():showMsg("请在游戏结束后再追踪！");
			else
				GameConstant.curRoomLevel = actionParam.level;
				RoomData.getInstance():setRoomAddr(actionParam);
				GameConstant.traceFlag = true;
				self:exitGame();
			end
		end
	end
end


RoomScene.requestLoginCallBack = function ( self, isSuccess ,data )
	-- body
	if isSuccess and data then
		PlayerManager:getInstance():myself():initPhpUserData(data.userinfo);
	else
		self:exitGame()
	end
end
-- 直接退出游戏，不做其他判断
-- noClearRoomData : 退出房间时是否清除数据，默认清除
RoomScene.exitGame = function ( self )
	self:unregisterAllEvent();
	PlayerManager:getInstance():myself():exitGame(); -- 改变自己的状态
	self:sendExitCmd();
	GameState.changeState( nil, States.Loading,nil,States.Hall );
end
function RoomScene.sendExitCmd( self, isChangeTableActively )
	self.isChangeTableActively = isChangeTableActively or false;
	self.isShowRoomInfo = self.isChangeTableActively;
	PlayerManager:getInstance():removeOtherPlay(); -- 移除其他玩家数据
	RoomData.getInstance():clearData(); -- 清除房间数据
	SocketManager.getInstance():sendPack( CLIENT_COMMAND_LOGOUT ); -- 退出命令，发了之后直接退出房间
end

-- socket的状态
RoomScene.onSocketStateEvent = function (self , eventType)
	if eventType == kSocketConnected then
		DebugLog("eventType : kSocketConnected");
		-- 直接重连，不退房间
	elseif eventType == kSocketReconnecting then
		DebugLog("eventType : kSocketReconnecting");
		Banner.getInstance():showMsg("您的网络连接断开，正在努力为您重连");
	elseif eventType == kSocketConnectivity then
		DebugLog("eventType : kSocketConnectivity");
	elseif eventType == kSocketConnectFailed then
		DebugLog("eventType : kSocketConnectFailed");
		Banner.getInstance():showMsg("网络连接失败，请检查您的网络");
		GameConstant.HallViewType = nil;
		self:exitGame();
	elseif eventType == kSocketRecvPacket then
		DebugLog("eventType : kSocketRecvPacket");
	elseif eventType == kSocketUserClose then
		DebugLog("RoomScene eventType : kSocketUserClose");

		if not isClickBackToReconnect then
			GameConstant.HallViewType = nil;
			if GameConstant.isNeedReconnectGame then -- 切换后台关闭socket引起的重连
				DebugLog("eventType : kSocketUserClose");
				-- self:reconnectGame();
				self:exitGame();
			elseif self.isInSocketRoom then
				DebugLog("eventType : kSocketUserClose isInSocketRoom");
				self:exitGame();
			end
		else
			isClickBackToReconnect = false;
		end

	end
end

-- php事件


RoomScene.onPhpMsgResponse = function ( self, param, cmd, isSuccess )
	if self.phpMsgResponseCallBackFuncMap[cmd] then
		self.phpMsgResponseCallBackFuncMap[cmd](self,isSuccess,param)
	end
end


-- 打开socket
RoomScene.openHallSocketAndLogin = function (self)
	--
	SocketManager.getInstance():openSocket();

end



--获取是否显示金币活动入口
RoomScene.getRoomActivityInfo = function(self)
	if GameConstant.isSingleGame then
		return;
	end
	DebugLog("RoomScene.getRoomActivityInfo")
if GameConstant.iosDeviceType>0 and GameConstant.iosPingBiFee then
	return;
end
	local param_data = {};
	SocketManager.getInstance():sendPack(PHP_CMD_GET_ROOM_ACTIVITY_INFO,param_data)
end

RoomScene.getRoomActivityInfoCallBack = function( self, isSuccess, data, jsonData )
	DebugLog("RoomScene.getRoomActivityInfoCallBack: " .. tostring(isSuccess))
	if not isSuccess or not data or not data.data then
		return;
	end
	local activityState = tonumber(data.data.open) or 0;
	local awardState = tonumber(data.data.award) or 0;
	self:showAwardBtn(data)
	--self:updateView(RoomScene.s_cmds.showAwardBtn, data);
end

--获取金币活动具体信息
RoomScene.getRoomActivityDetail = function(self)
	if not GameConstant.getingRoomActivityDetail then  --如果正在获取数据则不重复拉取
		GameConstant.getingRoomActivityDetail = true;
		local param_data = {};
		SocketManager.getInstance():sendPack(PHP_CMD_GET_ROOM_ACTIVITY_DETAIL,param_data)
	end
end

RoomScene.getRoomActivityDetailCallBack = function( self, isSuccess, data, jsonData )
	GameConstant.getingRoomActivityDetail = false;
	if not isSuccess or not data then
		Banner.getInstance():showMsg("网络数据获取失败，请稍候重试。");
		return;
	end
	self:updateAwardWindow(data)
	--self:updateView(RoomScene.s_cmds.updateAwardWindow, data);
end

--房间内活动领取奖励
RoomScene.getRoomActivityAward = function(self)
	local param_data = {};
	SocketManager.getInstance():sendPack(PHP_CMD_GET_ROOM_ACTIVITY_AWARD,param_data)
end

RoomScene.getRoomActivityAwardCallBack = function( self, isSuccess, data, jsonData )
	if not isSuccess or not data then
		return;
	end
	if isSuccess then
		local money = tonumber(data.data.money) or 0;
		local msg = data.msg or "";
		local status = tonumber(data.status) or 0;
		Banner.getInstance():showMsg(msg);
		if status == 1 then
			showGoldDropAnimation();
			self.myself:addMoney(money);
			if not FriendMatchRoomScene_instance then
				SocketSender.getInstance():send(CLIENT_COMMAND_GET_NEW_MONEY, {["mid"] = PlayerManager.getInstance():myself().mid});
			end
		end
		self:getControl(RoomScene.s_controls.AwardBtn):setVisible(false);
		self:getControl(RoomScene.s_controls.AwardLight):setVisible(false);
		self:getRoomActivityInfo();  --刷新活动数据
	end
end

RoomScene.getRoomPropListCallBack = function( self, isSuccess, data, jsonData )
	DebugLog("RoomScene.getRoomPropListCallBack")
	if not isSuccess or not data or not data.data then
		return;
	end
	local status = tonumber(data.status) or -1;
	if status == -1 or status == 0 then
		Banner.getInstance():showMsg(data.msg);
		return;
	end
	local propTab = {};

	-- 道具列表可能为空的情况容错
	-- ########################################################## --
	if not data.data or  rawget(data.data,"list") == nil then
		propTab[0] = 0;
		GameConstant.roomPropTab = propTab;
	else
		for k, v in pairs(data.data.list) do
			propTab[tonumber(v.pid or 0 ) or 0] = tonumber(v.money or 0) or 0;
		end
	end

	GameConstant.propLimit = tonumber(data.data.limit) or 0;
	GameConstant.propInterval = tonumber(data.data.time) or 5;
	GameConstant.roomPropTab = propTab;

	if DEBUGMODE == 1 then
		if self.roomTips then
			self.roomTips:setText( "丢道具限制："..GameConstant.propLimit );
		end
	end
end


RoomScene.requireChestStatus = function ( self )
	if GameConstant.iosDeviceType>0 and GameConstant.iosPingBiFee then
		return ;
	end
	local params = {};
	params.level = GameConstant.curRoomLevel;
	SocketManager.getInstance():sendPack(PHP_CMD_REQUIRE_CHEST_STATUS,params)
end

RoomScene.requireChestStatusCallBack = function ( self, isSuccess,data )
	if not isSuccess or not data then
		return;
	end

	local status = data.status
	if status and tonumber(status) == 1 then
		local t = {};
		t.open    = tonumber(data.data.open)
		t.need    = tonumber(data.data.need)
		t.process = tonumber(data.data.process)
		t.award   = tonumber(data.data.award)
		t.boxType = tonumber( data.data.boxtype) or 0
		RoomData.getInstance().boxType = t.boxType;
		self.chestProcessJu = tonumber(data.data.process)
		self.chestNeedJu = tonumber(data.data.need)
		GlobalDataManager.getInstance():updateExitTipInfo(GameConstant.curRoomLevel,self.chestProcessJu,self.chestNeedJu)

		self:updateChestImg(1)
		if 0 == tonumber(data.data.open) then
			self.chestProcessJu = -1;
		elseif t and 1 == tonumber(data.data.open) then
			self:showChestStartup(t);
		end
	end
end
RoomScene.requireChestPopWnd = function ( self )
	local params = {};
	params.level = GameConstant.curRoomLevel;
	SocketManager.getInstance():sendPack(PHP_CMD_REQUIRE_CHEST_POP_WND,params)
end


RoomScene.requireChestPopWndCallBack = function ( self, isSuccess, data )
	if not isSuccess or not data then
		return;
	end

	local status = data.status
	if status and tonumber(status) == 1 then
		if 0 == tonumber(data.data.open) then
			self.m_view:hideChestStartup();
			return;
		end

		local t = {};
		t.need    = tonumber(data.data.need);
		t.process = tonumber(data.data.process);

		if t.need < t.process then
			return;
		end

		self.chestNeedJu = t.need;
		self.chestProcessJu = t.process;

		GlobalDataManager.getInstance():updateExitTipInfo(GameConstant.curRoomLevel,self.chestProcessJu,self.chestNeedJu)

		self:updateChestText(t);
		self:showChestPopWnd(data);
	end
end

--请求配置（更高场次拉取，获取提示概率(0-1之间的数) 防打扰场次）
RoomScene.requireLoginConfig = function( self )
	local param_data = {};

	param_data.lastTime = tonumber(g_DiskDataMgr:getAppData(kSystemConfigDictKey_Value.loginConfigTime,'1')) or 1;
	SocketManager.getInstance():sendPack(PHP_CMD_REQUIRE_LOGIN_CONFIG,param_data)
end

--登录配置
RoomScene.requireLoginConfigCallBack = function( self, isSuccess, data )
	if not isSuccess or not data then
		return;
	end
	if isSuccess and data then
		if tonumber(data.status) == 1 then
			local probability = data.info.higherPull.probability;
			local Innings = data.info.higherPull.Innings
			g_DiskDataMgr:setAppData(kSystemConfigDictKey_Value.gameTipOdds, probability)
			g_DiskDataMgr:setAppData(kSystemConfigDictKey_Value.gameTipCount,Innings)
		end
		local probability = g_DiskDataMgr:getAppData(kSystemConfigDictKey_Value.gameTipOdds,'')
		GameConstant.gameTipOdds = tonumber(probability) or GameConstant.gameTipOdds;
		GameConstant.gameTipCount = tonumber(g_DiskDataMgr:getAppData(kSystemConfigDictKey_Value.gameTipCount,'')) or GameConstant.gameTipCount;
		g_DiskDataMgr:setAppData(kSystemConfigDictKey_Value.loginConfigTime, data.time)
	end
end
----------------------------------------------------------------------------------------------------------------------------
-- 请求退出房间，不一定能成功退出
RoomScene.exitGameRequire = function( self )
    local myself = PlayerManager:getInstance():myself();
	if not myself.isInGame then
		DebugLog("RoomScene.backEvent  myself.isInGame== false ####");
		GameConstant.isBackToHallActivitely = true;
		new_pop_wnd_mgr.get_instance():set_back_to_hall_actively( true ); -- 主动返回大厅标记
	end

	if not myself.isInGame or GameConstant.isSingleGame then
		if GameConstant.isSingleGame then
			if not self.exitWnd then
				self.exitWnd = PopuFrame.showNormalDialog( "温馨提示", "是否退出游戏？", GameConstant.curGameSceneRef, nil, nil, false, false );
				self.exitWnd:setConfirmCallback(self, function ( self )
					g_DiskDataMgr:setAppData('singleMyMoney',PlayerManager.getInstance():myself().money)
					self:exitGame();
				end);

				self.exitWnd:setCancelCallback( self, function( self )
					self.exitWnd = nil;
				end);
				self.exitWnd:setCloseCallback( self, function( self )
					self.exitWnd = nil;
				end);
			else
				self.exitWnd:hide();
				self.exitWnd = nil;
			end
			return false;
		else
			if PlayerManager.getInstance():isAllReady() and not myself.isHu then
				Banner.getInstance():showMsg("请在游戏结束后退出房间！");
				return false
			end
			self:exitGame();
			return true;
		end
	else
		Banner.getInstance():showMsg("请在游戏结束后退出房间！");
		return false;
	end
end

RoomScene.readyActionToServer = function ( self )
	SocketManager.getInstance():sendPack( CLIENT_COMMAND_READY );
	--self:startReadyTimer()
	----
	if self.outCardTimer then
		self.outCardTimer:hide();
	end

	if self.leftCardNumText then
		self.leftCardNumText:setVisible(false);
		self.leftCardNumStatic:setVisible(false);
	end
end

---起个定时器 让玩家准备后2s内 不能退出游戏
RoomScene.startReadyTimer = function ( self )
	-- body
	--self.isReadying = true
    -- DebugLog("RoomScene:startReadyTimer")
    -- if not self.m_readyTimer then
    --     self.m_readyTimer = new(AnimInt , kAnimNormal , 0 , 1 , 2000 , 0);
    --     self.m_readyTimer:setDebugName("AnimInt ---- room ready timer ->");
    --     self.m_readyTimer:setEvent(self , self.readyTimeout);
    -- end
end

RoomScene.readyTimeout = function ( self )
	-- delete(self.m_readyTimer);
 --    self.m_readyTimer = nil;
end


-- 打牌请求
RoomScene.outCardAction = function (self , value)
	self.beforeServerOutCardValue = value;
	local param = {};
	param.card = value;
	param.isTing = 0;
	SocketManager.getInstance():sendPack( CLIENT_COMMAND_OUTCARD , param );

	HuCardTipsManager.getInstance():clearAll();
	TeachManager.getInstance():hide(); -- 抓到牌
end

-- 客户端选定缺
RoomScene.clientSelectQue = function (self , que)
	local param = {};
	param.que = que;
	SocketManager.getInstance():sendPack( CLIENT_COMMAND_SELECT_QUE , param );
end

RoomScene.kickTimeOut = function ( self )
	self:exitGame(); -- 超时直接退出游戏
end

RoomScene.cancelAI = function ( self )
	local t = {};
	t.type = 0;
	SocketManager.getInstance():sendPack( CLIENT_COMMAND_REQUEST_AI, t ); -- 取消托管
end

-- 进行操作
RoomScene.takeOperation = function ( self, data )
	if data.operatorValue == 0 then
		self:showHuCardTips(); -- 玩家摸牌后首先显示操作提示，点击过以后显示胡牌提示
	else
		HuCardTipsManager.getInstance():clearAll();
	end
	mahjongPrint( data );
	SocketManager.getInstance():sendPack( CLIENT_COMMAND_TAKE_OPERATION, data );
end

RoomScene.swapCardConfirm = function ( self, data )
	local roomData = RoomData.getInstance();
	roomData.isStartSwapCard = false;

	local param = {};
	param.cardNum = roomData.swapCardNum or 3;
	param.swapCardList = {};
	for i=1,3 do
		if i <= #data then
			param.swapCardList[i] = data[i];
		else
			param.swapCardList[i] = 0;
		end
	end
	SocketManager.getInstance():sendPack( CLIENT_COMMAND_SWAP_CARD, param );
end

-----------------------------------------------------------------------------------------------------------------------

-- 登录房间成功
RoomScene.joinGameSuccess = function (self , data)
	---------------------------------------------------------
	DebugLog("RoomScene joinGameSuccess");
	mahjongPrint(data)
	if GameConstant.platformType == PlatformConfig.platformMobile then
		if roomData and roomData.tai then
			Banner.getInstance():showMsg("本局游戏将收取"..roomData.tai.."金币的服务费");
		end
	end

	---GameConstant.boxRoomFlag = false;已经去掉包厢, 去掉无效代码

	self:changeFrameCount( data.isLiangFanPai and 11 or 14 )
	local playerMgr = PlayerManager.getInstance();
	playerMgr:removeOtherPlay(); -- 先移除其他玩家
	local mySelf = playerMgr:myself();
	local roomData = RoomData.getInstance();
	roomData:enterRoom(data); -- 初始化进入房间的数据
	roomData:setIpAndPort(data);

	self:getRoomActivityInfo();  --开始获取金币活动
	self:requireChestStatus();   -- 请求宝箱
	-- 自己的网络座位id一定要先赋值，用于计算其他玩家的本地座位id
	self:showTableInfo(1,true)

	Player.myNetSeat = roomData.mySeatId;
	mySelf.seatId = Player.myNetSeat;
	mySelf.money = roomData.myMoney;

	local isSendReady =false
	if mySelf.isReady then --有可能server主动配桌
		self:readyActionToServer()
		isSendReady = true
	end



	-- 创建玩家
	for k,v in pairs(data.playerInfo) do -- 游戏玩家数据
		local player = playerMgr:parseNetPlayerData(v, data.inFetionRoom);
		self:playerEnterGame( player )
	end
	local myself = playerMgr:myself();
	self:playerEnterGame( mySelf )


	if self.reconnectingGameDirect then -- 重连的时候刚好牌局结束，重新设置自己的位置
		self.reconnectingGameDirect = false;
		PlayerManager:getInstance():myself().isInGame = false;
		self:reconnectGameDirectWhenOver( mySelf )
	end

	if GameConstant.isLowLevelClicked then -- 判断是否点击了去低倍场按钮，如果点击了去低倍场按钮就自动准备
		GameConstant.isLowLevelClicked = false;
		GameConstant.isDirtPlayGame = true;
	end



	if GameConstant.isDirtPlayGame then -- 快速进入游戏则直接准备
		GameConstant.isDirtPlayGame = false;
		isSendReady = true
		self:readyActionToServer()
	end

	------------------------------------------------------
	local privateRoomLevel = 0
	if data and data.roomLevel then
		privateRoomLevel = tonumber(data.roomLevel)
	end

	if not mySelf.isReady and not isSendReady and ( privateRoomLevel ~= 50) and not GameConstant.isSingleGame then
		self:showReadyBtn()
	end
	---------------------------	-----------------------------
	if not myself.isReady and not self.hasShowTimeOutTip then -- 自己没准备并且没显示准备提示
		if #playerMgr:getReadyPlayerList() == 3 then -- 其他3人已经准备
			self.hasShowTimeOutTip = true;
			if not GameConstant.isSingleGame then
				self:showOrHideTimeOutTip( true, RoomData.getInstance().kickTime )
			end
		end
	end
end

RoomScene.roomLevelAndName = function ( self, data )

	self.roomData:parseNameAndLevel( data );
	self:setPrivateRoomData2();

	if self.isShowRoomInfo then
		-- if GameConstant.isSingleGame then
		-- 	self:getControl(RoomScene.s_controls.timeBg):setVisible(false);
		-- else
		-- 	self:getControl(RoomScene.s_controls.timeBg):setVisible(true);
		-- end
		self.isShowRoomInfo = false;
	end
	self:showTableInfo(nil,true)

	--根据数据获取道具信息
	if not GameConstant.isSingleGame then

		--获取道具列表
		local param_data = {};
		param_data.party_id = tonumber(data.level); --GameConstant.curRoomLevel or 50;
		DebugLog("HttpModule.s_cmds.getRoomPropList,")
		SocketManager.getInstance():sendPack(PHP_CMD_GET_ROOM_PROP_LIST,param_data)
	end
end

RoomScene.setPrivateRoomData2 = function ( self )
	local roomData = {};
	if RoomData.getInstance().isXueLiu then
		roomData.isXlch = 1;
	else
		roomData.isXlch = 0;
	end
	roomData.curDi = RoomData.getInstance().di;
	RoomData.getInstance():setPrivateRoomData(roomData);
end

RoomScene.userLoginRoom = function ( self, data )
	DebugLog( "RoomScene.userLoginRoom" );
	mahjongPrint( data );
	GameEffect.getInstance():play("AUDIO_ENTERROOM");
	local player = PlayerManager.getInstance():parseNetPlayerData(data);
	self:playerEnterGame( player )

	if self.m_inviteRoomWindow and FriendDataManager.getInstance():hastheFriend(data.mid) then
		self.m_inviteRoomWindow:updateFriend();
	end
end

RoomScene.userReady = function ( self, param )
	local mid = tonumber(param.mid);
	local pm = PlayerManager.getInstance();
	local player = pm:getPlayerById(mid);
	if player then
		player:setReady(true);
		GameEffect.getInstance():play("AUDIO_READY");
		self:playerChangeReadyStatu( player )
	else
		DebugLog(" set player ready failed : no player with id "..mid);
	end
	local myself = pm:myself();
	if not myself.isReady and not self.hasShowTimeOutTip then -- 自己没准备并且没显示准备提示
		if #pm:getReadyPlayerList() == 3 then -- 其他3人已经准备
			self.hasShowTimeOutTip = true;
			self:showOrHideTimeOutTip( true, RoomData.getInstance().kickTime )
		end
	end

-- 	if mySelf == player then
-- --		self:readyTimeout()--
-- 	end

	if myself == player and self.hasShowTimeOutTip then -- 自己准备,并且之前已经显示了超时提示
		self:showOrHideTimeOutTip( false )
		self.hasShowTimeOutTip = false;
	end
end

-- 其他玩家退出游戏
RoomScene.userLogoutRoom = function ( self, data )
	local player = PlayerManager.getInstance():getPlayerById(tonumber(data.mid));
	if not player then
		return;
	end
	self:playerExitGame( player )
	PlayerManager.getInstance():removePlayerByMid(tonumber(data.mid));
	if self.hasShowTimeOutTip then -- 之前已经显示了超时提示，有其他玩家退出，则隐藏
		self:showOrHideTimeOutTip( false )
		self.hasShowTimeOutTip = false;
	end

	if self.m_inviteRoomWindow and FriendDataManager.getInstance():hastheFriend(data.mid) then
		self.m_inviteRoomWindow:updateFriend();
	end

end

-- 退出房间，包括被踢出房间
RoomScene.selfLogoutRoom = function ( self, data )
	if self.isChangeTableActively then
		self.isChangeTableActively = false;
		local playerMgr = PlayerManager.getInstance():removeOtherPlay();

		for k,v in pairs(self.seatManager.seatList) do
			v:changeToWaitStaty();
			if v.seatID ~= kSeatMine then
				v:clearData();
			end
		end
		self:clearDesk()
		GameConstant.isDirtPlayGame = true;

		if self.isShowHighLevel then
			self.isShowHighLevel = false;
			AnimationAwardTips.play("恭喜您晋级到更高场次！");
		end
		self:requireJoinGame(1);
	else
		self:exitGame();
	end
end

-- 登录房间
RoomScene.requireJoinGame = function (self, changeTableFlag)
	DebugLog("RoomScene.requireJoinGame")
	local param = {};
	local player = PlayerManager.getInstance():myself();
	local uesrInfo = player:getUserData();
	param.level = GameConstant.curRoomLevel;
	param.money = player.money;
	param.userInfo = json.encode(uesrInfo);
	param.mtk = player.mtkey;
	param.from = player.api;
	param.version = 1;
	param.versionName = GameConstant.Version;
	param.changeTableFlag = changeTableFlag;
	SocketManager.getInstance():sendPack(CLIENT_CMD_JOIN_GAME4, param);
end

-- 服务器广播准备开始游戏
RoomScene.readyStartGameServer = function ( self, data )
	--self:playNormalMusicWhenStart()
--[[
	if RoomData.getInstance().inFetionRoom then
		local data = {};
		for i =1, 4 do
			player = PlayerManager.getInstance():getPlayerBySeat(i-1);
			if player then
				table.insert(data, player.mid);
			end
		end
		FriendDataManager.getInstance():requestFetionScore(data);
	end
]]
	if not self:checkAddProp(0) then
		self:removeProp(0)
	end

	local anim = self:addPropTranslate(0,kAnimNormal,1000,0,0,0,0,0)
	anim:setDebugName("game start delay 1s anim");
	anim:setEvent(self,function ( self )
		self:removeProp(0)
		self:startGameTrueAction(data)
	end)

end



-------0x4002游戏要延迟1s才开始 v5.1.0需求
RoomScene.startGameTrueAction = function ( self,data )
	RoomData.getInstance().isReconnect = false;
	local localSeat = Player.getLocalSeat(data.bankSeatId); -- 庄家位置
	PlayerManager:getInstance():myself():startGame();
	self:readyStartGame( localSeat )
end


-- 广播开始游戏发牌
RoomScene.startGameDealCardServer = function (self , data)
	self:hideReadyBtn()

	if not GameConstant.isSingleGame then
		if self.chestProcessJu and self.chestProcessJu > -1 then
			self.chestProcessJu = self.chestProcessJu + 1;
			if self.chestProcessJu >= self.chestNeedJu then
				self.chestProcessJu = self.chestNeedJu;
				self:updateChestImg(2); --chest open
			end

			local t = {};
			t.need = self.chestNeedJu;
			t.process = self.chestProcessJu;
			self:updateChestText(t);
		end
		self:updateAddFan( data.addFanCard )

		GlobalDataManager.getInstance():updateExitTipInfo(GameConstant.curRoomLevel,self.chestProcessJu,self.chestNeedJu)

		if data.serviceFee then
			for i=1,3 do
				local player = PlayerManager.getInstance():getPlayerBySeat(i);
				if player then
					player:addMoney(-data.serviceFee);
				end
			end
		end
	end
	self:startGameDealCard( data.cardList, data.serviceFee )

	-- 计算并更新剩余牌数
	local roomData = RoomData.getInstance();
	roomData.leftcard = roomData.isLiangFanPai and 32 or 56;
	self:showLeftCardNum( roomData.leftcard )

end

-- 广播当前抓牌玩家
RoomScene.broadcastCurrentPlayerServer = function (self , data)
	self:broadcastCurrentPlayer( data )
	-- 计算并更新剩余牌数
	local roomData = RoomData.getInstance();
	roomData.leftcard = roomData.leftcard - 1;
	self:showLeftCardNum( roomData.leftcard )
	self:swapCardEnd()
end


function RoomScene:checkMineInHandCardsIsNormal()--检查自己大小相公
	--判断是否大小相公  如果大小相公了  主动断线重连
	if not GameConstant.isSingleGame and not self.mahjongManager:checkMineInHandCardsIsNormal() then
 	    isClickBackToReconnect = true;
		SocketManager.getInstance():socketCloseAndOpen();
		--SocketManager.getInstance():openSocket();
	end
end
function RoomScene:checkIs5Cards( )--检查是否5张牌
	--判断是否大小相公  如果大小相公了  主动断线重连
	-- if not GameConstant.isSingleGame and  self.mahjongManager:checkIs5Cards() then
 -- 	    isClickBackToReconnect = true;
	-- 	SocketManager.getInstance():socketCloseAndOpen();
	-- 	--SocketManager.getInstance():openSocket();
	-- end
	--self.mahjongManager:printAllCardsFunc()
end

-- 自己抓牌
RoomScene.myselfCatchCardServer = function (self , data)
	DebugLog("RoomScene.myselfCatchCardServer....自己抓牌了！！！！！！！！！！！！！")
	self:myselfCatchCard( data )

	--self:checkIs5Cards()
	self:checkMineInHandCardsIsNormal()

	-- 计算并更新剩余牌数
	local roomData = RoomData.getInstance();
	roomData.leftcard = roomData.leftcard - 1;
	self:showLeftCardNum( roomData.leftcard )
	self:swapCardEnd()
	if PlayerManager.getInstance():myself().isAi then -- 防止客户端没显示托管
		self:showOrDisapperTuoguan(true)
	end
end

-- server广播出牌
RoomScene.broadcastOutCardServer = function (self , data)
	local cardValue = data.card;
	local player = PlayerManager.getInstance():getPlayerById(data.userId);
	if player and player.isMyself and self.beforeServerOutCardValue ~= 0 then
		if cardValue ~= self.beforeServerOutCardValue then
			self:backendBeforeOutCard( self.beforeServerOutCardValue, data )
		else
			DebugLog("我自己打出了牌");
			self:setOutCardTimer(-1 , RoomData.getInstance().operationTime);
		end
	else
		self:broadcastOutCard( data )
	end
	self.beforeServerOutCardValue = 0;

	if player and player.isMyself then
		TeachManager.getInstance():hide(); -- 可能超时抓到牌
	end

	HuCardTipsManager.getInstance():clearAll();
--	self:checkIs5Cards()
end



RoomScene.broadcastTuoguan = function ( self, data )
	local myself = PlayerManager.getInstance():myself();
	if data.userId == myself.mid then -- 自己
		if 1 == data.aiType then
			if myself.isHu then
				-- self:cancelAI();
				-- myself.isAi = false;
			elseif not myself.isAi then
				self:showOrDisapperTuoguan(true)
				myself.isAi = true;
			end
		elseif myself.isAi then
			self:showOrDisapperTuoguan( false )
			myself.isAi = false;
		end
	end
end

-- 游戏中胡牌
RoomScene.broadcastHu = function ( self, infoTable )
	if self.roomData.isXueLiu then
		self:someOneWinInGamingXLCH(infoTable);
		self:huXLCH( infoTable )
	else
		local t = self:someOneWinInGaming(infoTable.normalInfo);
		self:hu( t )
	end
end

RoomScene.broadcastHu2 = function ( self, infoTable )
	if not GameConstant.isSingleGame then
		GameConstant.justPlayGame = true;
	end
	GameConstant.needCheckMoney = true;
	local moneyexchange = {}; -- 统计钱数，用于显示动画
	local huMid = nil;
	for k , v in pairs(infoTable.playerList) do
		huMid = v.mid;
		local player = PlayerManager.getInstance():getPlayerById(v.mid);
		if not player then
			return
		end
		if player and kSeatMine == player.localSeatId and not self.roomData.isXueLiu then
			PlayerManager:getInstance():myself().isInGame = false;
		end
		-- 血流用于统计胡牌次数的
		local huTypeInfo = RoomData.getInstance():getHuTypeInfoBySeat(player.localSeatId);
		if 1 == v.huType then
			huTypeInfo.hu = huTypeInfo.hu + 1;
		else
			huTypeInfo.zimo = huTypeInfo.zimo + 1;
		end
		-- 胡牌标志
		player.isHu = true;
		-- 计算赢钱数
		local winMoney = 0;
		if not self.roomData.isXueLiu then -- 非血流成河，计算当前局金币
			winMoney = v.winMoney + v.hjzy; -- 胡牌的钱数
			local turnMoney = player.gfxyMoney + winMoney; -- 当前局总的输赢钱数
			-- player:addMoney(turnMoney); -- 加钱
			-- 计算胜率
			if turnMoney > 0 then
				player.wintimes = player.wintimes + 1;
			elseif turnMoney < 0 then
				player.losetimes = player.losetimes + 1;
			else
				player.drawtimes = player.drawtimes + 1;
			end
		else
			winMoney = v.winMoney + v.hjzy;
		end
		if not moneyexchange[v.mid] then
			moneyexchange[v.mid] = 0;
		end
		moneyexchange[v.mid] = moneyexchange[v.mid] + winMoney;
		-- 计算放炮玩家输的钱
		for j,n in pairs(v.beHu) do
			if not moneyexchange[n.mid] then
				moneyexchange[n.mid] = 0;
			end
			moneyexchange[n.mid] = moneyexchange[n.mid] + n.loseMoney;

			---如果有呼叫转移 被胡的人要减去杠的钱
			if v.hjzy and v.hjzy > 0 then
				moneyexchange[n.mid] = moneyexchange[n.mid] - v.hjzy
			end ----
			self:showBankruptTips( n.mid, v.mid );
		end
	end

	for k,v in pairs(moneyexchange) do -- 显示钱动画
		self:showChangMoneyAnim( k,v )
	end
	self:hu2( infoTable.playerList )


	-- 更新相关
	if PlayerManager.getInstance():myself().isHu and not self.roomData.isXueLiu then
		PlayerManager.getInstance():myself().isInGame = false;
		native_to_java(kGameOver);
		if GameConstant.updateFinishButInGame then
			GameConstant.updateFinishButInGame = false;
			native_to_java(kUpdate);
		end
	end

	-- 判断是否显示升级动画
	-- self:showUserUpdateAnim( infoTable );
	self:showUserUpdateAnim( infoTable )

	-- local test = "isXueLiu:"..tostring(RoomData.getInstance().isXueLiu);
	-- local view = PopuFrame.showNormalDialog( "温馨提示", test, nil, nil, nil, true, false, "确定");
	-- if RoomData.getInstance().isXueLiu then
	-- 	local detailBtn = self.seatManager:getSeatByLocalSeatID( kSeatMine ).detailBtn;
	-- 	if detailBtn then
	-- 		detailBtn:setVisible( false );
	-- 	end
	-- end

end



RoomScene.gameOver2Server = function ( self, data )
	HuCardTipsManager.getInstance():clearAll();

	if not GameConstant.isSingleGame then
		GameConstant.justPlayGame = true;
	end
	GameConstant.needCheckMoney = true;
	self:deleteAddFanNode(data)-- 如果是加番玩法，删除加番节点


	for k, v in pairs(data.playerList) do
		local player = PlayerManager:getInstance():getPlayerById(v.mid);
		if player then
			player.money = v.totalMoney;
		end

		if player and kSeatMine == player.localSeatId then
			PlayerManager:getInstance():myself().isInGame = false;
		end

		if player and not GameConstant.isSingleGame then
			if self.roomData.isXueLiu or not player.isHu then -- 血流场或是普通场没有胡牌的玩家在这里计算胜率
				if v.turnMoney > 0 then
					player.wintimes = player.wintimes + 1;
				elseif v.turnMoney < 0 then
					player.losetimes = player.losetimes + 1;
				else
					player.drawtimes = player.drawtimes + 1;
				end
			end
		end
	end

	-- 更新界面
	EventDispatcher.getInstance():dispatch(GlobalDataManager.updateSceneEvent); -- 直接更新一次金币
	self:gameOver2(data)

	-- GlobalDataManager.getInstance():updateScene();
	for k,v in pairs(PlayerManager:getInstance().playerList) do
		v:gameOver();
	end
	self:showUserUpdateAnim( data )

end

RoomScene.gameOverServer = function ( self, data )
	self:deleteAddFanNode(data) -- 如果是加番玩法，删除加番节点
	for k, v in pairs(data.resuleInfoList) do
		local player = PlayerManager:getInstance():getPlayerById(v.userId);
		if player then
			player.money = v.totalMoney;
		end
		if player and not GameConstant.isSingleGame then
			if v.turnMoney > 0 then
				player.wintimes = player.wintimes + 1;
			elseif v.turnMoney < 0 then
				player.losetimes = player.losetimes + 1;
			else
				player.drawtimes = player.drawtimes + 1;
			end
		end
	end
	EventDispatcher.getInstance():dispatch(GlobalDataManager.updateSceneEvent); -- 直接更新一次金币
	self:gameOver(data)

	-- GlobalDataManager.getInstance():updateScene();
	for k,v in pairs(PlayerManager:getInstance().playerList) do
		v:gameOver();
	end
end

RoomScene.bcUserChat = function ( self, data )
	DebugLog("[RoomScene]:bcUserChat");
	if PlatformFactory.curPlatform:notUseChat() then
		return;
	end
	local t = {};
	t.type = "chat";
	t.mid = data.userId;
	t.msg = data.chatinfo;
	self:showChatOrFace( t )

	self:checkAndPlayChatSound(t.mid, t.msg);
end

RoomScene.checkAndPlayChatSound = function ( self, mid, chatStr )
	local player = PlayerManager.getInstance():getPlayerById(mid);
	if not player then
		return;
	end
	for k,v in pairs(QuickChatWnd.chatStr) do
		if GameString.convert2Platform(v) == GameString.convert2Platform(chatStr or "") then
			local str = "W";
			if player.sex == kSexMan then
				str = "M";
			end
			GameEffect.getInstance():play(string.format("%s_CHAT%d", str, k - 1));
			return;
		end
	end

	for k,v in pairs(QuickChatWnd.mandarinChatStr) do
		if GameString.convert2Platform(v) == GameString.convert2Platform(chatStr or "") then
			local str = "W";
			if player.sex == kSexMan then
				str = "M";
			end
			GameEffect.getInstance():play(string.format("%s_CHAT%d", str, k - 1));
			return;
		end
	end

end

RoomScene.bcChatFace = function ( self, data )
	DebugLog("[RoomScene]:bcChatFace");
	if PlatformFactory.curPlatform:notUseChat() then
		return;
	end
	local t = {};
	t.type = "face";
	t.mid = data.userId;
	t.faceType = data.faceType;
	self:showChatOrFace( t )
end
RoomScene.kickoutRoom = function ( self , param )
	DebugLog("server kick out caus not enough money,clent not deal this cmd！");
	-- self:updateView(RoomScene.s_cmds.kickoutRoom, param);
end

--[[
	function name	   : RoomScene.fcmNotify
	description  	   : 防沉迷Socket返回信息.
	param 	 	 	   : self
						 data 	--Table 防沉迷信息
	last-modified-date : Dec. 16 2013
	create-time  	   : Oct. 31 2013
]]
RoomScene.fcmNotify = function(self,data)
	if not data then
		return;
	end
	local isT = data.isT;
	local isWhyStr = data.isWhyStr;
	local playerGameTime = data.playerGameTime;
	local surplusTime = data.surplusTime;
	local confirmText;

	playerGameTime = math.floor(playerGameTime/kNumOneHourSecond);
	surplusTime = math.floor(surplusTime/kNumOneHourSecond);

	confirmText = CreatingViewUsingData.commonData.certainText;

	if tonumber(isT) == kNumOne then
		self:exitGame();
		confirmText = "";--CreatingViewUsingData.avoidWallowView.knowText;--防沉迷会报错
	end

	if isWhyStr == nil or isWhyStr == kNullStringStr  then
		-- isWhyStr=string.format(CreatingViewUsingData.avoidWallowView.fcmMessage,playerGameTime,surplusTime);--防沉迷会报错
		isWhyStr = "";
	end

	local view = PopuFrame.showNormalDialogForCenter( CreatingViewUsingData.avoidWallowView.fcmTitle, isWhyStr,nil, nil, nil, true);
	view.confirmText:setText(confirmText);
	view:setNotOnClickFeeling(true);
	if view then
		view:setCallback(view, function ( view, isShow )
			if not isShow then

			end
		end);
	end
end

RoomScene.loginError = function(self,data)
	local  faultinfo = nil;
	if kERROR_USERKEY == data.errType or kERROR_MTKEY == data.errType then
		--踢人了同一个账号在不同设备登陆
		local loginType = PlatformFactory.curPlatform:changeLoginMethod(GameConstant.lastLoginType);
		loginType:logout();

		--切换平台
		faultinfo="您的账号在别处已登录。";
		Banner.getInstance():showMsg(faultinfo);
		return;
	elseif kERROR_MYSQL == data.errType or kERROR_NO_THIS_MAHJONG_TYPE == data.errType then
		self:exitGame();
		faultinfo="非常抱歉，服务器错误，请再次进入房间。";
		Banner.getInstance():showMsg(faultinfo);
	elseif kERROR_TABLE_NOT_EXIST == data.errType or kERROR_MATCH_ROOM_NOT_EXIST == data.errType then
		self:exitGame();
		faultinfo="非常抱歉，您选择的房间不存在。";
		Banner.getInstance():showMsg(faultinfo);
	elseif kERROR_USER_NOT_LOGIN_TABLE == data.errType then
		self:exitGame();
		faultinfo="非常抱歉，进入房间失败。请检查网络连接后再次进入房间。";
		Banner.getInstance():showMsg(faultinfo);
	elseif kERROR_TABLE_MAX_COUNT == data.errType or kERROR_NO_EMPTY_SEAT ==  data.errType then
		self:exitGame();
		faultinfo="非常抱歉，你进入的房间座位已满。";
		Banner.getInstance():showMsg(faultinfo);
	elseif kERROR_NOT_ENOUCH_MONEY == data.errType then
		self:exitGame();
		faultinfo="对不起，您的金币不足以进入该房间。";
		Banner.getInstance():showMsg(faultinfo);
	elseif kERROR_UNKNOWN == data.errType then
		self:exitGame();
		faultinfo="非常抱歉，进入房间失败。请检查网络连接后再次进入房间。";
		Banner.getInstance():showMsg(faultinfo);
	elseif kERROR_KICK_OTHER_USER == data.errType then
		DebugLog("踢掉自己异地登录的帐号");
	elseif kERROR_SAME_IP == data.errType then
		self:exitGame();
		faultinfo="非常抱歉，相同IP不能进入同一个房间。";
		Banner.getInstance():showMsg(faultinfo);
	elseif kERROR_TOO_MANY_MONEY == data.errType then
		self:exitGame();
		faultinfo="您的金币太多了，不能在这么低的场次欺负小朋友哦。";
		Banner.getInstance():showMsg(faultinfo);
	elseif kERROR_ROOM_VIP_LIMIT == data.errType then
		self:exitGame()
		faultinfo="VIP等级不足,无法进入该游戏场!";
		Banner.getInstance():showMsg(faultinfo);
	elseif kERROR_FCM == data.errType then
		self:exitGame();
		local time=data.fcmTime;
		local hour=math.floor(time/kNumOneHourSecond);
		local min=math.floor((time%kNumOneHourSecond)/kNumSixty);

		local tipStr=string.format(CreatingViewUsingData.avoidWallowView.fcmChaoShiMessage.str1,hour,min);

		if hour == kNumZero and min == kNumZero then
			tipStr=string.format(CreatingViewUsingData.avoidWallowView.fcmChaoShiMessage.str2,time%kNumSixty);
		elseif hour == kNumZero and min ~= kNumZero then
			tipStr=string.format(CreatingViewUsingData.avoidWallowView.fcmChaoShiMessage.str3,time/kNumSixty);
		end

		if GameConstant.isAdult ==  kNumZero then
			faultinfo = string.format(CreatingViewUsingData.avoidWallowView.fcmChaoShiMessage.strText1,tipStr);
		elseif GameConstant.isAult == kNumMinusOne or GameConstant.isAult == kNumMinusTwo then
			faultinfo=string.format(CreatingViewUsingData.avoidWallowView.fcmChaoShiMessage.strText2,tipStr);
		else
			faultinfo=string.format(CreatingViewUsingData.avoidWallowView.fcmChaoShiMessage.strText3,tipStr);
		end

		Banner.getInstance():showMsg(faultinfo);
		return;
	else
		self:exitGame();
		faultinfo="非常抱歉，进入房间失败。请检查网络连接后再次进入房间。";
		Banner.getInstance():showMsg(faultinfo);
	end
end

RoomScene.otherError = function (self , data)
	if not data then
		return;
	end
	if 2 == data.errType then
		self:exitGame();
	end
end

RoomScene.kickOut = function (self)
	self.myself.mid = 0;
	self.myself.nickName = "";
	SocketManager.getInstance():syncClose();
	self:exitGame();
	Banner.getInstance():showMsg("对不起，您的帐号在异地登录，请重新登录");
end

RoomScene.changeTable = function ( self, data )
	DebugLog( "RoomScene.changeTable" );
	if tonumber(data.result) == 0 then
		--拿到当前的level
		local currentLevel = self.roomData.level;

		local allDatas = HallConfigDataManager.getInstance():returnHallConfigByLevel(currentLevel);

		if not allDatas then
			--看下是不是两房牌
			allDatas = HallConfigDataManager.getInstance():returnHallDataForLFPByLevel(currentLevel);
			if not allDatas then
				return;
			end
		end
		GameConstant.upperEnterRoomFlag = allDatas.key;  -- 标记是高级场次推荐
		GameConstant.upperEnterRoomLevel = currentLevel; -- 标记换桌的场次


		local userMoney = PlayerManager.getInstance():myself().money;
		local userVip   = PlayerManager.getInstance():myself().vipLevel
		if GameConstant.go_to_high then

			local suc,highData = HallConfigDataManager.getInstance():returnMinRequireHallDataForTypeAndLevel(allDatas.type,allDatas.level,userMoney,userVip)
			if suc and highData then
				DebugLog("highData: "..tostring(highData.level))
				self.isShowHighLevel = true;
				GameConstant.curRoomLevel = tonumber(highData.level)
				self:sendExitCmd( true );
				return
			end
		end

		if userMoney > allDatas.uppermost or userMoney < allDatas.xzrequire then
			DebugLog("userMoney: " .. tostring(userMoney))
			--self.isShowHighLevel = true;
			GameConstant.curRoomLevel = getSuitableLevel( PlayerManager.getInstance():myself().money, currentLevel )
			--两房牌
			if not GameConstant.curRoomLevel then
				local suc,roomdata = HallConfigDataManager.getInstance():returnDataByKey("lfp",tonumber(userMoney) )
				if suc and roomdata then
					GameConstant.curRoomLevel = tonumber(roomdata.level)
				end
			end

			if userMoney > allDatas.uppermost then
				self.isShowHighLevel = true
			end
		else
			self.isShowHighLevel = false;
			GameConstant.curRoomLevel = currentLevel;
		end

		self:sendExitCmd( true );
	else
		Banner.getInstance():showMsg("您还不满足换桌的条件哦。");
	end
end
RoomScene.broadcastSystemConMsg = function (self , data)
	if not data then
		return;
	end
	Banner.getInstance():showMsg(tostring(data.sysMsg));
end
function RoomScene:serverNoticeSameIp( data )
	Banner.getInstance():showMsg(data.msg or "")
end

RoomScene.serverNoticeMsg = function (self , data)
	if not data then
		return;
	end
	local title = data.title;
	if not title or title == "" then
		title = "温馨提示";
	end
	local content = data.msg or "";

	if 1 == data.state then -- vip不计负场提示用banner来显示
		if content ~= nil and content ~= "" then
			Banner.getInstance():showMsg(content);
		end
		self.myself.losetimes = self.myself.losetimes - 1;
	elseif 2 == data.state then --banner来显示
		self.myself.losetimes = self.myself.losetimes - 1;
    elseif 3 == data.state then --比赛淘汰温馨提示框，小框；
		local view = PopuFrame.showNormalDialogForCenter(title, content,nil, nil, nil, true, false);
		if view then
			view:setConfirmCallback(view, function ( view, isShow )
				if not isShow then

                    if self.quitPopWin then
                        self.quitPopWin:onClickBackToHallBtn();
                        self.quitPopWin:hideWnd();
                    end
				end
			end);
		end
	else
		local view = PopuFrame.showNormalDialogForCenter(title, content,nil, nil, nil, true);
		if view then
			view:setCallback(view, function ( view, isShow )
				if not isShow then

				end
			end);
		end
	end
end

-- 游戏中重新连接了一次大厅socket，處理两种情况：1 游戏中重连 2 不在游戏中退出到大厅
RoomScene.connectSocketSuccess = function ( self, data )
	if 1 == data.isInGame then
		Banner.getInstance():showMsg("游戏重连成功。");
		RoomData.getInstance():setRoomAddr(data);
		for k,v in pairs(self.seatManager.seatList) do
			v:changeToWaitStaty();
			v:clearData();
		end
		self:clearDesk()

		self:requireJoinGame(0);
		self.reconnectingGameDirect = true; -- 是否是房间内直接重连
	else
		PlayerManager.getInstance():myself().isInGame = false;
		Banner.getInstance():showMsg("网络重连成功。");
		self:exitGame();
	end
end


-- 服务器返回踢人
RoomScene.serverVIPKickoutPlayer = function (self, data)
	if not data then
		return;
	end
	if 1 == data.kickVIPKey then
		self:kickoutPlayerVIPKey(data);
	end
end
-- VIP踢人
RoomScene.kickoutPlayerVIPKey = function (self, data)
	local myself = PlayerManager.getInstance():myself();
	if 0 == data.state then
		if myself.mid == data.kickMid then
			local confirmStr = "成为VIP";
			if PlayerManager.getInstance():myself().vipLevel > 0 then
				confirmStr = "提升VIP";
			end
			local view = PopuFrame.showNormalDialog( "温馨提示", "    "..data.strMsg, nil, nil, nil, false, false, confirmStr, "确定");
			view:setConfirmCallback(self, function ( self )
				local pamount;
				if tonumber(PlayerManager.getInstance():myself().vipLevel) > 0 then
					--VIP用户
					pamount = ProductManager.getInstance():getProductOverop(30) or 0;
				else
					--非VIP用户
					pamount = ProductManager.getInstance():getProductOverop(10) or 0;
				end
				if pamount ~= 0 then
					local payScene = {};
					payScene.scene_id = PlatformConfig.VIPKickForPay;
					GlobalDataManager.getInstance():quickPay(pamount, payScene);
				else
					Banner.getInstance():showMsg("还未获取到商品数据，请稍候重试。");
				end
			end);
			view:setCallback(view, function ( view, isShow )
				if not isShow then

				end
			end);
			self:exitGame();
		elseif myself.mid == data.VIPMid then
			Banner.getInstance():showMsg(data.strMsg);
		else
			Banner.getInstance():showMsg(data.strMsg);
		end
	else
		Banner.getInstance():showMsg(tostring(data.strMsg or ""));
	end
end

-- 任务完成推送
RoomScene.taskPush = function ( self, data )
--[[
	if not data then
		return;
	end
	local myself = PlayerManager.getInstance():myself()
	if data.mid == myself.mid and data.subCmd == SERVER_SUB_COMMAND_TASK_COMPLITE then
		self:updateView(RoomScene.s_cmds.taskComplitePush, data);
	end
]]
end


RoomScene.bankruptPush = function ( self, data )
	if data then
		if data.bankruptMids then
			for k,v in pairs(data.bankruptMids) do
				local player = PlayerManager.getInstance():getPlayerById(tonumber(v));
				if player and player:isFirstTimeBankruptInGame() then
					player.hasBankruptInGame = true;
					self:playBankruptAnim(player.localSeatId);
				end
			end
		end
	end
end

RoomScene.noEnoughMoneyPlayGame = function ( self, data )
	Banner.getInstance():showMsg("您的金币不足以在本场次玩牌！");
end


--刷新房间里的玩家金币信息
---- {"MONEY":"995000","UID":"519069687","VIP":"0"}
RoomScene.playerMoney = function ( self , data)
	if not data then
		return;
	end
	DebugLog("我接收到了更新金币");
	local myselfUid = PlayerManager.getInstance():myself().mid;

	for i = 1, #data do
		local player =  PlayerManager.getInstance():getPlayerById(tonumber(data[i].UID) or 0);
		if  player  and player.mid ~= myselfUid then
			player:setMoney(tonumber(data[i].MONEY) or player.money);
			player.vipLevel = tonumber(data[i].VIP) or player.vipLevel;
		end
	end
end

--道具动画表  id  --  anim
RoomScene.propAnimTab = {
	[0]  = AnimationToPraise,
	[1]  = AnimationThrowEgg,
	[2]  = AnimationShakeHands,
	[3]  = AnimationThrowSoap,
	[4]  = AnimationSendKiss,
	[5]  = AnimationThrowTomato,
	[6]  = AnimationCheers,
	[7]  = AnimationThrowRock,
	[8]  = AnimationSendFlower,
	[9]  = AnimationSendRose,
	[10] = AnimationThrowBomb
}

--广播使用道具
RoomScene.broadcasrUsedProp = function( self, data )
	DebugLog("RoomScene.broadcasrUsedProp")
	if not data then
		Banner.getInstance():showMsg(data.msg or "网络繁忙，请稍候再试。");
		return;
	end
	if data.flag and data.msg and data.flag == 0 then
		Banner.getInstance():showMsg( data.msg );
		return;
	end
	local sPlayer =  PlayerManager.getInstance():getPlayerById(data.mid or 0);  --发送玩家

	if not sPlayer then
		return;
	end

	if GameConstant.isSingleGame and sPlayer.money <= 10 then -- 单机道具价格=10金币
		return;
	end
    if not isPlatform_Win32() and not (GameConstant.iosDeviceType>0) then
        --资源未下载
        if not publ_IsResDownLoaded( GameConstant.DOWNLOAD_RES_TYPE_FRIEND_ANIM ) then
            return;
        end
    end


	self.animIndex = self.animIndex + 1;
	local sSeat = self.seatManager:getSeatByLocalSeatID(sPlayer.localSeatId);
	local changeMoney = data.money or 0;
	self.sCharm = data.scharm;

	if FriendMatchRoomScene_instance then --------好友比赛 只有自己更新金币
		if sPlayer == PlayerManager.getInstance():myself() then
			sPlayer:addMoney(-changeMoney);  --更新金币
		end
	else---------------非好友对战 所有人都得更新金币
		sPlayer:addMoney(-changeMoney);  --更新金币
	end


	-- local animList = {};
	GameConstant.propAnimList[self.animIndex] = {};

	if data.data then
		if #data.data >= 1 then
			if data.data and data.data[1] then
				local totalTcharm = 0;
				if not GameConstant.isSingleGame then
					for k,value in pairs(data.data) do
						totalTcharm = totalTcharm + value.tcharm;
					end
				end
				local v = data.data[1];
				local tPlayer =  PlayerManager.getInstance():getPlayerById(v.tagmid or 0);  --接收玩家
				if not tPlayer then
					return;
				end
				local tSeat = self.seatManager:getSeatByLocalSeatID(tPlayer.localSeatId);
				local pid = v.pid;
				local tagmid = v.tagmid;
				local pointStartX, pointStartY = sSeat.iconBtn:getPos();
				local pointEndX, pointEndY =  tSeat.iconBtn:getPos();
				local iconW, iconH = tSeat.iconBtn:getSize();
				if RoomScene.propAnimTab[pid] then --AnimationThrowEgg

					local propAnim = new(RoomScene.propAnimTab[pid], {x=pointStartX, y=pointStartY}, {x=pointEndX, y=pointEndY},
						totalTcharm,self.sCharm, {w=iconW,h=iconH}, tagmid, sPlayer.localSeatId, tPlayer.localSeatId, #data.data);
					self.animationLayer:addChild(propAnim)
					propAnim:play();
					table.insert(GameConstant.propAnimList[self.animIndex], propAnim );
				end
			end
		end
	end
end

RoomScene.OPERATE_FAILED = 0;
RoomScene.OPERATE_SUCCESS = 1;
RoomScene.ERROR_ROOM_NOT_EXIST = 1;
RoomScene.ERROR_MAX_USERCOUNT = 2;
RoomScene.ERROR_PASSWORD = 3;

RoomScene.reenterPrivateRoom = function ( self, data )
	if data.result == self.OPERATE_FAILED then
		if data.errorCode == self.ERROR_ROOM_NOT_EXIST then

			Banner.getInstance():showMsg(GameString.convert2Platform("房间不存在！"));
			--self:requestPrivateRoomList(); -- 刷新一次
		elseif data.errorCode == self.ERROR_MAX_USERCOUNT then

			Banner.getInstance():showMsg(GameString.convert2Platform("房间玩家已满！"));
			--self:requestPrivateRoomList(); -- 刷新一次
		elseif data.errorCode == self.ERROR_PASSWORD then

			Banner.getInstance():showMsg(GameString.convert2Platform("密码错误！"));
		else
			Banner.getInstance():showMsg(GameString.convert2Platform("进入房间失败！"));
		end
	else
		RoomData.getInstance():setRoomAddr(data);
		self:requireJoinGame(0);
	end
end
RoomScene.serverRetiredReconnected = function ( self )
	SocketManager.getInstance():openSocket()
	--self:OnRequestHallIpPort();
end



-- SERVER退休，后台切换房间
RoomScene.serverRetiredChangeTable = function ( self, data )
	local param = {};

	param.roomid = data.roomId;
	param.password = data.passwd or "";
	RoomData.getInstance().roomId = data.roomId; -- 给房间id赋值
	SocketSender.getInstance():send( CMD_CLIENT_ENTER_PRIVATE_ROOM, param);
end

function RoomScene.joinGameRet( self, data )
	DebugLog("RoomScene.joinGameRet")
	if data and data.ip and 0 < data.port and 0 < data.roomId then
		RoomData.getInstance():setRoomAddr(data);
		if self.isShowHighLevel then
			self.isShowHighLevel = false;
			AnimationAwardTips.play("恭喜您晋级到更高场次！");
		end
		self:requireJoinGame(1);
	else
		Banner.getInstance():showMsg("对不起，进入房间失败，请稍后重试！");
	end
end

-- 比赛列表或比赛奖励有更新时推送
RoomScene.phpNotice = function ( self, data )
	if not data then
		return;
	end

	DebugLog("ttttt RoomScene.phpNotice")
	if data.cmdRequest == SERVER_MATCHLIST_RES or data.cmdRequest == SERVER_MATCHLIST_TIME_RES then -- 比赛场次列表
		--获取比赛场次配置
		local tmp = json.mahjong_decode_node(data.info);
		if 1 == data.perationType then
			DebugLog("add");
			HallConfigDataManager.getInstance():addMatchList(tmp);
		elseif 2 == data.perationType then
			HallConfigDataManager.getInstance():deleteMatchList(data.perationId);
			DebugLog("delet");
		elseif 3 == data.perationType then
			DebugLog("change");
			HallConfigDataManager.getInstance():deleteMatchList(data.perationId);
			HallConfigDataManager.getInstance():addMatchList(tmp);
		end
	elseif data.cmdRequest == SERVER_MAIL_SYS_CANCEL then
		local playeId = PlayerManager.getInstance():myself().mid
		local msgId   = data.msgId
		local data    = GlobalDataManager.getInstance().systemData
		SystemMessageData.deleteMsgById(playeId,msgId,data)
	end
end

-- 比赛的状态信息(积分与钱，是否要等待，比赛阶段等)
RoomScene.matchStatus = function ( self, data )
	DebugLog("ttt RoomScene matchStatus");
end
function RoomScene.addFriendInTable( self , data )
	if not data then
		return;
	end

	local player1 = PlayerManager.getInstance():getPlayerById( data.mid1 );
	local player2 = PlayerManager.getInstance():getPlayerById( data.mid2 );

	if not player1 or not player2 then
		log( "未找到相应的用户" );
		return;
	end

	local seatMyself = self.seatManager:getSeatByLocalSeatID(player1.localSeatId);
	local seatAddFriend = self.seatManager:getSeatByLocalSeatID(player2.localSeatId);

	local startPos = {};
	local endPos = {};
	startPos.x,startPos.y = seatMyself.iconBtn:getPos();
	endPos.x,endPos.y = seatAddFriend.iconBtn:getPos();

	require( "Animation/AddFriendAnim" );
	local anim = new(AddFriendAnim, startPos, endPos );
	anim:play();
end




RoomScene.onSocketPackEvent = function ( self, param, cmd )
	if self.scoketEventFuncMap[cmd] then
		DebugLog(string.format("Room deal socket cmd 0x%x",cmd));
		self.scoketEventFuncMap[cmd](self, param);
	end
end

RoomScene.initHttpRequestsCallBackFuncMap = function( self )

	RoomScene.phpMsgResponseCallBackFuncMap =
	{
		[PHP_CMD_GET_ROOM_ACTIVITY_INFO] 	=  self.getRoomActivityInfoCallBack,
		[PHP_CMD_GET_ROOM_ACTIVITY_DETAIL] 	=  self.getRoomActivityDetailCallBack,
		[PHP_CMD_GET_ROOM_ACTIVITY_AWARD] 	=  self.getRoomActivityAwardCallBack,
		[PHP_CMD_GET_ROOM_PROP_LIST] 		=  self.getRoomPropListCallBack,
		--[HttpModule.s_cmds.requestHallIpPort] =  self.requestHallIpPortCallBack,
		[PHP_CMD_REQUIRE_CHEST_STATUS]      =  self.requireChestStatusCallBack,
		[PHP_CMD_REQUIRE_CHEST_POP_WND] 	=  self.requireChestPopWndCallBack,
		[PHP_CMD_REQUIRE_LOGIN_CONFIG] 		= self.requireLoginConfigCallBack,
	}
end



RoomScene.someOneWinInGaming = function (self , infoTable)
	local t = {};
	local moneyexchange = {};
	for k,v in pairs(infoTable) do
		local money = 0;
		local totalFan = 0;
		totalFan = totalFan + v.fanNum;
		if(v.isGangShangPao == 1) then
			totalFan=totalFan+1;
		end
		if(v.isQiangGangHu == 1) then
			totalFan=totalFan+1;
		end
		if(v.isGangShangKaiHua == 1) then
			totalFan=totalFan+1;
		end
		totalFan=totalFan+v.genNum;
		totalFan=totalFan+v.gangNum;
		local player = PlayerManager.getInstance():getPlayerById(v.userId);
		local huTypeInfo = RoomData.getInstance():getHuTypeInfoBySeat(player.localSeatId);
		if 1 == v.huType then
			huTypeInfo.hu = huTypeInfo.hu + 1;
		else
			huTypeInfo.zimo = huTypeInfo.zimo + 1;
		end
		local money = math.pow(2, totalFan-1) * RoomData.getInstance().di;
		if v.huType == 1 then -- 放炮
			if (v.isGangShangPao == 1) then
				money = money + v.hjzyMoney;
			end
			if(v.paiType == 2) then
				money = 32*RoomData.getInstance().di * v.huCount;-- 地胡 放炮者输6番的底钱
				-- self:updateView(RoomScene.s_cmds.showChangMoneyAnim, v.fangPaoUserID , -money);
				if not moneyexchange[v.fangPaoUserID] then
					moneyexchange[v.fangPaoUserID] = 0;
				end
				moneyexchange[v.fangPaoUserID] = moneyexchange[v.fangPaoUserID] - money;
			else
				-- self:updateView(RoomScene.s_cmds.showChangMoneyAnim, v.fangPaoUserID , -money);
				if not moneyexchange[v.fangPaoUserID] then
					moneyexchange[v.fangPaoUserID] = 0;
				end
				moneyexchange[v.fangPaoUserID] = moneyexchange[v.fangPaoUserID] - money;
			end
		else -- 自摸
			money = money + RoomData.getInstance().di;
			if(v.paiType == 1 or v.paiType == 2) then
				money = 32*RoomData.getInstance().di; --天胡要出的钱
			else
				money = math.ceil(money);
			end
			for j,m in pairs(self.pm.playerList) do
				if m.mid ~= v.userId and not m.isHu then -- 非胡牌玩家
					-- self:updateView(RoomScene.s_cmds.showChangMoneyAnim, m.mid, -money);
					if not moneyexchange[m.mid] then
						moneyexchange[m.mid] = 0;
					end
					moneyexchange[m.mid] = moneyexchange[m.mid] - money;
				end
			end
		end
		self.pm:getPlayerById(v.userId).isHu = true;
		local winMoney = 0; -- 计算赢钱数
		if(v.huType == 1 and v.paiType == 2) then -- 放炮地胡
			winMoney = 32 * RoomData.getInstance().di;
		elseif(v.huType == 2 and v.paiType == 2) then -- 自摸地胡
			winMoney = ( 4 - PlayerManager.getInstance():getHuPlayerNum() ) * 32 * RoomData.getInstance().di;
		elseif(v.huType == 2 and v.paiType == 1) then --天胡
			winMoney = ( 4 - PlayerManager.getInstance():getHuPlayerNum() ) * 32 * RoomData.getInstance().di;
		elseif(v.huType == 1) then --放炮
			winMoney = money;
		elseif(v.huType == 2) then --自摸
			winMoney = (4 - PlayerManager.getInstance():getHuPlayerNum() ) * money;
		end
		-- self:updateView(RoomScene.s_cmds.showChangMoneyAnim, v.userId, winMoney);
		if not moneyexchange[v.userId] then
			moneyexchange[v.userId] = 0;
		end
		moneyexchange[v.userId] = moneyexchange[v.userId] + winMoney;

		winMoney = PlayerManager.getInstance():getPlayerById(v.userId).gfxyMoney + winMoney; -- 加上刮风下雨
		-- self.pm:getPlayerById(v.userId):addMoney(winMoney);

		local info = v;
		info.seatId = info.seatId or self.pm:getLocalSeatIdByMid(v.userId);
		info.winMoney = winMoney;
		table.insert(t, info);
	end

	for k,v in pairs(moneyexchange) do
		self:showChangMoneyAnim(k,v)
		--self:updateView(RoomScene.s_cmds.showChangMoneyAnim, k, v);
	end

	if GameConstant.isSingleGame then
		if PlayerManager.getInstance():myself().money < 0 then
			g_DiskDataMgr:setAppData('singleMyMoney',PlayerManager.getInstance():myself().money)
		end
	end

	if PlayerManager.getInstance():myself().isHu and not self.roomData.isXueLiu then
		PlayerManager.getInstance():myself().isInGame = false;
		native_to_java(kGameOver);
		if GameConstant.updateFinishButInGame then
			GameConstant.updateFinishButInGame = false;
			native_to_java(kUpdate);
		end
	end

	return t;
end

RoomScene.someOneWinInGamingXLCH = function (self , infoTable)
	for k , v in pairs(infoTable.xueLiuInfo) do
		local player = PlayerManager.getInstance():getPlayerById(v.winUserId);
		player.isHu = true;
		local huTypeInfo = RoomData.getInstance():getHuTypeInfoBySeat(player.localSeatId);
		if 1 == v.huType then
			huTypeInfo.hu = huTypeInfo.hu + 1;
		else
			huTypeInfo.zimo = huTypeInfo.zimo + 1;
		end
	end
end

RoomScene.setIsFreeMatchGame = function ( self, value )
	self.isFreeMatch = value
	--左宝箱
	if self:isFreeMatchGame() then
		local chestBtn = self:getControl(RoomScene.s_controls.chestBtn);
		local chestText = self:getControl(RoomScene.s_controls.chestText);
		chestBtn:setVisible(false)
		chestText:setVisible(false)
	end
end

RoomScene.isFreeMatchGame = function ( self )
	return (self.isFreeMatch and (self.isFreeMatch == 1))
end
------------------------------------------------
-- 游戏退到后台的重连事件
RoomScene.reconnectGame = function ( self )
	-- 打开socket
	--if GameConstant.HallIp and GameConstant.HallPort then
		if self.myself.mid > 0 then
			SocketManager.getInstance():openSocket();
			return;
		end
	--end
	self:exitGame();
end

-- 返回比赛场选择界面,报名
RoomScene.backToMatchSelectView = function ( self )
	-- 可以弹出强推界面，这里需要将这个标志置为false，否则强推无法弹出
	GameConstant.isInApplyWindow = false;
	self:unregisterAllEvent();
	PlayerManager:getInstance():removeOtherPlay(); -- 移除其他玩家数据
	RoomData.getInstance():clearData(); -- 清除房间数据
	PlayerManager:getInstance():myself():exitGame(); -- 改变自己的状态
	GameState.changeState( nil,States.Loading,nil, States.Hall );
end

RoomScene.resetRoomController = function ( self )
	self.beforeServerOutCardValue = 0;
	self:init();
	self:clearDesk();
end

RoomScene.init = function ( self )
	--请求基本的配置信息（防打扰场次， 提示概率(0-1之间））
	self:requireLoginConfig();
	-- 先创建目前在线玩家
	self:initIngamePlayer()

end

-----------------------------------------------------------------------------------------------------
--桌子上的logo,房间名,玩法,底注显示逻辑
--位置两种  开局前,游戏中
function RoomScene:showTableInfo(status, visible)
	if status then
		self:setTableInfoStatus(status)
	end

	self:showRoomName()

	local left,mid,right
	local wanfa  = RoomData.getInstance().wanfa;
	local result = self:getWanfaStr(wanfa)

	if result then
		left = result[1]
		mid  = result[2]
	end

	right = (RoomData.getInstance().di or 0).."底"
	self:showWanfaAndDi(visible,left,mid,right)
end

function RoomScene:showRoomName( )
	local level  = RoomData.getInstance().level;
    if not level then
        return;
    end

	local hallData = HallConfigDataManager.getInstance():returnDataByLevel(level);
	if not hallData then
		hallData = HallConfigDataManager.getInstance():returnHallDataForLFPByLevel(level);
		if not hallData then
			if GameConstant.isSingleGame then
				self:setRoomName("Room/roomInfo/danji.png")
			else
				-- 只有可能是包厢了
				self:setRoomName("Room/roomInfo/baoxiang.png")
			end
			return;
		end
	end
	local disType = hallData.type
    if not disType then
         disType = 0
    end
    if disType == 6 then--6是对应的
        self:setRoomName("Room/roomInfo/logo_xz4.png")
--    elseif disType == 5 then
--        self:setRoomName("Room/roomInfo/logo5.png")
    else
    	if disType < 1 or disType > 5 then
		    disType = 0
	    end
        self:setRoomName("Room/roomInfo/logo" .. disType .. ".png")
    end


end

----创建桌子显示信息 玩法,底注
function RoomScene:createTableInfo( )
	if not self.RDI then
		local parentNode = self:getControl(RoomScene.s_controls.baseInfoView)

		local createImgFunc = function( imgName, align, x, y , parent )
			local img = UICreator.createImg(imgName,x,y)
			img:setAlign(align)
			parent:addChild(img)
			return img
		end

		self.RDI = {}
		self.RDI.logo 		= createImgFunc("Room/roomInfo/logo.png",kAlignCenter,0,0, parentNode)
		self.RDI.roomName   = createImgFunc("Commonx/blank.png"     ,kAlignCenter,0,0, parentNode)
		self.RDI.roomName:setSize(210,33)

		self.RDI.leftArrow  = createImgFunc("Room/roomInfo/logoLeft.png"  ,kAlignRight,0,0, parentNode)
		self.RDI.rightArrow = createImgFunc("Room/roomInfo/logoRight.png" ,kAlignLeft,0,0, parentNode)

		self.RDI.wanfaBg    = UICreator.createImg( "Room/roomInfo/infoFrame.png", 0, 0 ,20, 20, 20, 20)
		self.RDI.wanfaBg:setSize(300,40)
		self.RDI.wanfaBg:setAlign(kAlignCenter)
		parentNode:addChild(self.RDI.wanfaBg)

		local leftText  = UICreator.createText( "",-80, 0, 86,26, kAlignCenter ,22, 0x17, 0xe3, 0x77 )
		leftText:setAlign(kAlignCenter)
		self.RDI.wanfaBg:addChild(leftText)

		local midText  = UICreator.createText( "",0, 0, 50,26, kAlignCenter ,22, 0x17, 0xe3, 0x77 )
		midText:setAlign(kAlignCenter)
		self.RDI.wanfaBg:addChild(midText)

		local rightText = UICreator.createText( "", 80, 0, 86,26, kAlignCenter ,22, 0x17, 0xe3, 0x77 )
		rightText:setAlign(kAlignCenter)
		self.RDI.wanfaBg:addChild(rightText)

		self.RDI.wanfaBg.lt = leftText
		self.RDI.wanfaBg.rt = rightText
		self.RDI.wanfaBg.mt = midText
	end
end

function RoomScene:getWanfaStr( wanfa )
	if not wanfa then
		return nil
	end

	local result = {}
	local pre,mid
	local isLFP = false
	if bit.band(wanfa, 0x10) ~= 0 then
		pre   = "两房牌"
		isLFP = true
	end

	if bit.band(wanfa, 0x02) ~= 0 then
		pre = "血流成河"
	end

	if not pre then
		pre = "血战到底"
	end
	table.insert(result,pre)
	if bit.band(wanfa, 0x04) ~= 0 then
		if isLFP then
			mid = "换两张"
		else
			mid = "换三张"
		end
		table.insert(result,mid)
	end
	return result
end

function RoomScene:showWanfaAndDi( visible, left, mid ,right  )

	self.RDI.wanfaBg.rt:setText(right or "")
	self.RDI.wanfaBg.lt:setText(left or "")
	self.RDI.wanfaBg.mt:setText(mid or "")

	self.RDI.wanfaBg.rt:setVisible(visible)
	self.RDI.wanfaBg.lt:setVisible(visible)
	self.RDI.wanfaBg.mt:setVisible(visible)

end
-----根据状态 显示位置 是否显示
function RoomScene:setTableInfoStatus( status )
	--status=1  牌局未开始状态
	--status=2  牌局开始状态
	assert(status and (status ~= 1 or status ~= 2))

	status = status or 1
	local configMap = {
		{
		    ["logo"] 		= {0   ,-122,true},
		    ["roomName"]	= {0   , -66,true},
		    ["leftArrow"]   = {113, -66,true},
		    ["rightArrow"]  = {113, -66,true},
		    ["wanfaBg"]     = {0   ,   0,true},
		},
		{
		    ["logo"] 		= {0   ,-122,true},
		    ["roomName"]	= {0   , -66,false},
		    ["leftArrow"]   = {150,  105,true},
		    ["rightArrow"]  = {150,  105,true},
		    ["wanfaBg"]     = {  0,   105,true},
		},
	}

	local configInfo = configMap[status]

	self:createTableInfo()

	local curConfigItem = nil
	for key,nodes in pairs(self.RDI) do
		curConfigItem = configInfo[key]
		if curConfigItem then
			nodes:setPos(curConfigItem[1],curConfigItem[2])
			nodes:setVisible(curConfigItem[3])
		end
	end

end

function RoomScene:pauseGameSound( ... )
	GameMusic.getInstance():pause();
	GameEffect.getInstance():setMute(true);
end

function RoomScene:resumeGameSound( ... )
	GameMusic.getInstance():resume();
	GameEffect.getInstance():setMute(false);
end

-----------------------------------------------------------------------------------------------------
function RoomScene:requestExitCallback( data )
	-- body
end
function RoomScene:resultOfRequestBack( data )
	-- body
end
function RoomScene:disbandTable( data )
	-- body
end
function RoomScene:fmrGameOver( data )
	-- body
end
function RoomScene:fmrPayFee( data )
	-- body
end
--------------------------------------------------
RoomScene.initSocketEventFuncMap = function( self )
	RoomScene.scoketEventFuncMap =
	{
		[SERVER_COMMAND_LOGIN_SUCCESS] = self.joinGameSuccess,    --进入房间成功
		[SERVER_COMMAND_TELL_LEVEL_AND_NAME] = self.roomLevelAndName,  --房间信息接口
		[SERVER_BROADCAST_USER_LOGIN] = self.userLoginRoom,			--有玩家进入房间
		[SERVER_BROADCAST_USER_READY] = self.userReady,				--有玩家准备
		[SERVER_BROADCAST_USER_LOGOUT] = self.userLogoutRoom,			--有玩家退出房间
		[SERVER_COMMAND_LOGOUT_SUCCESS] = self.selfLogoutRoom,		--自己退出房间
		[SERVER_BROADCAST_READY_START] = self.readyStartGameServer,			--准备开始游戏

		[SERVER_COMMAND_DEAL_CARD] = self.startGameDealCardServer,			--发牌
		[SERVER_BROADCAST_CURRENT_PLAYER] = self.broadcastCurrentPlayerServer,	--广播当前抓拍玩家(非自己)
		[SERVER_COMMAND_GRAB_CARD] = self.myselfCatchCardServer,			--自己抓牌
		[SERVER_BROADCAST_OUT_CARD] = self.broadcastOutCardServer,			--广播出牌玩家
		[SERVER_BROADCAST_TAKE_OPERATION] = self.broadcastTakeOperation,  --广播玩家操作
		[SERVER_COMMAND_USER_SELECT_QUE] = self.broadcastSelectQue,		--广播开始选缺
		[SERVER_BROADCAST_USER_AI] = self.broadcastTuoguan,				--广播玩家托管
		[SERVER_COMMAND_SELECT_PAI] = self.broadcastdingque,						--所有玩家定缺
		[SERVER_BROADCAST_GFXY_TO_TABLE] = self.broadcastGFXYToTable,		--广播玩家刮风下雨
		[SERVER_BROADCAST_HU_TO_TABLE] = self.broadcastHu, -- 老结算
		[SERVER_BROADCAST_HU_TO_TABLE2] = self.broadcastHu2, -- 新结算  小结算
		[SERVER_BROADCAST_STOP_ROUND] = self.gameOverServer, -- 老结算
		[SERVER_BROADCAST_STOP_ROUND2] = self.gameOver2Server, -- 新结算(血战+血流)  大结算
		[SERVER_COMMAND_OPEERATION_HINT] = self.operationHint,			--提示抢杠胡
		[SERVER_COMMAND_RECONNECT_SUCCESS] = self.reconnectSuccess,		--网络重连成功
		[SERVER_COMMAND_SWAP_REQ_CARDS] = self.startSwapCard,				--开始换3张
		[SERVER_COMMAND_SWAP_RES_CARD] = self.serverSwapCardFinish,		--换3张结束
		[SERVER_COMMAND_RECONNECT_SUCCESS_SC_XLCH] = self.reconnectSuccessScXLCH,
		[CLIENT_COMMAND_USER_CHAT] = self.bcUserChat,
		[CLIENT_COMMAND_SEND_FACE] = self.bcChatFace,
		[SERVER_COMMAND_KICK_OUT] = self.kickoutRoom,--server kick out caus not enough money,clent not deal this cmd！
		--防沉迷
		[SERVER_COMMAND_FCM_NOTIFY] = self.fcmNotify,
		[SERVER_COMMAND_LOGIN_ERR] = self.loginError,
		[SERVER_COMMAND_OTHER_ERR] = self.otherError,
		[HALL_SERVER_COMMAND_KICK_OUT] = self.kickOut,
		[CLIENT_COMMAND_RSP_LOGOUT] = self.changeTable,
		[SERVER_BROADCAST_SYSCONMSG] = self.broadcastSystemConMsg,
		[SERVER_COMMAND_MSG_NOTIFY] = self.serverNoticeMsg,
		[HALL_SERVER_COMMAND_LOGIN_SUCCESS] = self.connectSocketSuccess,

		[SERVER_COMMAND_VIP_KICK_PLAYER] = self.serverVIPKickoutPlayer, -- 服务器返回踢人
		[SERVER_COMMAND_TASK_PUSH] = self.taskPush,
		[SERVERGB_BROADCAST_BANKRUPT] = self.bankruptPush,
		[SERVER_NOT_ENOUGH_MONEY] = self.noEnoughMoneyPlayGame,
		[SERVER_COMMAND_GET_NEW_MONEY] = self.playerMoney, -- 玩家金币信息
		[SERVERGB_BROADCAST_USEPROP] = self.broadcasrUsedProp, --广播道具使用
		[SERVER_CMD_RETIRED_CHANGETABLE] = self.serverRetiredChangeTable, -- 告诉客户端服务器退休了，换桌
		[HALL_SERVER_RESPOND_ENTER_ROOM] = self.reenterPrivateRoom,  -- 退休重进私人房
		[SERVER_CMD_RETIRED_RECONNECTED] = self.serverRetiredReconnected, -- 告诉客户端服务器退休了，重连
		[SERVER_NOTIFY_USER_MONEYINFO]   = self.showLittleResultDetail, --中途胡牌后查看详情接口
		[HALL_SERVER_RESPOND_JOIN_GAME2] = self.joinGameRet, -- 请求进入房间
		[SERVER_MATCHUPDATE_CMD] = self.phpNotice,

		-- 比赛相关
		[SERVER_MATCHSERVER_CMD] = self.matchStatus, -- 比赛状态
		[SERVER_MATCHTABLE_WAIT] = self.reconnectWaitToMatch, -- 比赛重连等待状态
		[SERVERGB_BROADCAST_ADDFRI] = self.addFriendInTable, -- 牌桌上添加好友
		[SERVER_BROADCAST_OP_TIME] = self.resetOutCardTimer,
		[SEVER_CMD_JOIN_GAME4] = self.enterRoomEroor, -- 进入房间失败

		[CLIENT_COMMAND_JIFENREQUESTLOGOUT] = self.requestExitCallback,--自己请求退出 返回有没有请求成功
		[CLIENT_COMMAND_JIFENRESPONSE]      = self.resultOfRequestBack,--请求退出的 投票结果返回
		[SERVER_BROADCAST_TABLEDISBAND ]    = self.disbandTable,--解散牌局
		[CLIENT_COMMAND_FRI_PAY_FEE]        = self.fmrPayFee,--好友对战扣台费
		[SERVER_BROADCAST_JIFENRESULT]		= self.fmrGameOver,--好友对战总结算
		[SERVER_NOTICE_SAME_IP]             = self.serverNoticeSameIp,
	};
end

RoomScene.scoketEventFuncMap = {
}
-- 定义可操作控件的标识
RoomScene.s_controls =
{
	backGround = 1,
	---------------------
	-- timeBg = 2,
	-- roomName = 3,
	-- di = 4,
	-- gameType = 5,
	-------------------------
	timeHour = 9,
	timeMin = 10,
	timePoint = 11,
	jsmoneyBg = 13,
	mt = 14,
	baseInfoView = 15,
	bgImg = 17,
	quickPay = 18,
	settingBtn = 19,
	AwardBtn = 20,
	AwardLight = 21,
	broadcastBtn = 22,
	broadcastView = 23,
	----------------------------------
	logo = 24,
	logo_l = 25,
	logo_r = 26,
	----------------------------------
	broadcastBar = 27,
	broadcastTrumpet = 28,
	chestBtn = 29,
	chestText = 30,
	broadcastViewBg = 31,
	reconnectBtn = 32,
	--------------------------------------------
	-- logo_room_info_bg = 33,
	-- logo_room_info_di = 34,
	-- logo_room_info_type = 35,
	-- logo_container = 36,
	----------------------------------------------------
	exitBtn = 37,
	signalImg = 38,

	baseInfoView = 39,

	voiceImg     = 45,
}

-- 可操作控件在布局文件中的位置
RoomScene.s_controlConfig =
{
	[RoomScene.s_controls.backGround] 		= { "backGround" },
	--[RoomScene.s_controls.baseInfoView]     = { "baseInfoView"},
	--------------------------------------------------------------------------------------------------
	-- [RoomScene.s_controls.timeBg] 			= { "baseInfoView", "timeBg" },
	-- [RoomScene.s_controls.roomName] 		= { "baseInfoView", "roomName" },
	-- [RoomScene.s_controls.logo_container] 	= { "baseInfoView", "view_logo"},
	-- [RoomScene.s_controls.logo] 			= { "baseInfoView", "view_logo", "logo" },
	-- [RoomScene.s_controls.logo_l] 			= { "baseInfoView", "view_logo", "left" },
	-- [RoomScene.s_controls.logo_r] 			= { "baseInfoView", "view_logo", "right" },
	-- [RoomScene.s_controls.logo_room_info_bg] 	= { "baseInfoView", "view_logo", "img_room_info_bg" },
	-- [RoomScene.s_controls.logo_room_info_di] 	= { "baseInfoView", "view_logo", "img_room_info_bg", "text_room_di" },
	-- [RoomScene.s_controls.logo_room_info_type] 	= { "baseInfoView", "view_logo", "img_room_info_bg", "text_play_type" },
	-- [RoomScene.s_controls.di] 			    = { "baseInfoView", "timeBg", "roomDi" },
	-- [RoomScene.s_controls.gameType] 		= { "baseInfoView", "timeBg", "timeOutCard" },
	---------------------------------------------------------------------------------------------------

	[RoomScene.s_controls.timeHour] 		= { "time", "hourText" },
	[RoomScene.s_controls.timeMin] 			= { "time", "minText" },
	[RoomScene.s_controls.jsmoneyBg] 		= { "moneyBgImg" },
	[RoomScene.s_controls.mt] 			    = { "moneyBgImg","mt" },
	[RoomScene.s_controls.timePoint] 		= { "time", "pointText" },
	[RoomScene.s_controls.baseInfoView] 	= { "baseInfoView" },
	[RoomScene.s_controls.quickPay] 		= { "gainCoin" },
	[RoomScene.s_controls.settingBtn] 		= { "settingBtn" },
	[RoomScene.s_controls.AwardBtn]         = { "AwardBtn" },
	[RoomScene.s_controls.AwardLight]       = { "light" },
	[RoomScene.s_controls.exitBtn]			= { "menu_bg","exit"},
	--[RoomScene.s_controls.broadcastBtn]     = { "broadcastViewBg", "broadcastBtn" };
	--[RoomScene.s_controls.broadcastBar]     = { "broadcastViewBg", "broadcastTextBg" },
	--[RoomScene.s_controls.broadcastView]    = { "broadcastViewBg", "broadcastTextBg", "broadcastView" },
	--[RoomScene.s_controls.broadcastViewBg]  = { "broadcastViewBg" },
	--[RoomScene.s_controls.broadcastTrumpet] = { "broadcastViewBg", "broadcastBtn","trumpet" },
	[RoomScene.s_controls.chestBtn]         = { "chestBtn" },
	[RoomScene.s_controls.chestText]        = { "chestText" },
	[RoomScene.s_controls.reconnectBtn]     = { "backGround", "btn_reconnect" },
	[RoomScene.s_controls.signalImg]        = { "time", "signal"},

	[RoomScene.s_controls.voiceImg]         = { "voiceImg"},
}

-- 可操作控件的响应函数
RoomScene.s_controlFuncMap =
{
	[RoomScene.s_controls.backGround] = RoomScene.OnClickBackGroundImg,
	--[RoomScene.s_controls.broadcastBtn] = RoomScene.OnBroadcastBtnClick,
}

-- 可接受的更新界面命令
RoomScene.s_cmds =
{

};

RoomScene.initCmdConfig = function( self )
	-- 命令响应函数
	RoomScene.s_cmdConfig =
	{

	};
end

-- 命令响应函数
RoomScene.s_cmdConfig =
{
};
