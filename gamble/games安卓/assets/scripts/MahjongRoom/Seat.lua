require("Animation/ExpressionAnim");
require("Animation/FaceConfig");
local roomPlayerInfo = require(ViewLuaPath.."roomPlayerInfo");
local FMRroomPlayerInfo = require(ViewLuaPath.."FMRroomPlayerInfo");
require("Animation/PlayCardsAnim/animationBankrupt");
--require("MahjongRoom/fetionInFriendPop");
require("MahjongData/PlayerManager");
local seatPinx_map = require("qnPlist/seatPinx")
local DingQueViewPin_map = require("qnPlist/DingQueViewPin")
-- require("MahjongRoom/SeatManager");
require("Animation/UtilAnim/voiceAnim")

Seat = class(Node);

-- 坐标定义

Seat.waitingCoor = {
	[kSeatMine] = {368, 336},
	[kSeatRight] = {628, 176},
	[kSeatTop] = {368, 19},
	[kSeatLeft] = {106, 176}
}

Seat.inGameCoor = {
	[kSeatMine] = {104, 328},
	[kSeatRight] = {728, 188},
	[kSeatTop] = {104, 4},
	[kSeatLeft] = {8, 187}
}

-- 聊天背景偏移量
Seat.chatCoorOffset = {
	[kSeatMine] = {-49, 54 },
	[kSeatRight] = {247, 0},
	[kSeatTop] = {-28, -75},
	[kSeatLeft] = {-18, -55}
}

Seat.voiceCoorOffset = {
	[kSeatMine] = {90, 40 },
	[kSeatRight] = {-120, 40},
	[kSeatTop] = {90, 40},
	[kSeatLeft] = {90, 40}	
}

Seat.queCoor = {
	[kSeatMine] = {165, 335},
	[kSeatRight] = {728, 157},
	[kSeatTop] = {165, 6},
	[kSeatLeft] = {8, 158}
}

Seat.bankCoor = {
	[kSeatMine] = {165, 362},
	[kSeatRight] = {760, 157},
	[kSeatTop] = {165, 37},
	[kSeatLeft] = {45, 158}
}


Seat.matchScoreCoor = {
	[kSeatMine] = {0, 0},
	[kSeatRight]= {0, 0},
	[kSeatTop]  = {0, 0},
	[kSeatLeft] = {0, 0}
}

Seat.faceCoor = {
	[kSeatMine] = {193, 274	},
	[kSeatRight] = {491, 269},
	[kSeatTop] = {164, 79},
	[kSeatLeft] = {66, 272}
}

Seat.againCoor = {
	0, 0
}

Seat.dir = {
	[kWanMahjongType] = DingQueViewPin_map["ding_0.png"],
	[kTongMahjongType] = DingQueViewPin_map["ding_1.png"],
	[kTiaoMahjongType] = DingQueViewPin_map["ding_2.png"]
}

Seat.movePropSque = 1; -- 移动属性

Seat.rootDir = "Room/";

Seat.ctor = function ( self, seatID, roomSceneRef, inMatchRoom )
    EventDispatcher.getInstance():register(NativeManager._Event, self, self.callEvent);
	EventDispatcher.getInstance():register(GlobalDataManager.updateSceneEvent, self, self.updateCoin);
	self.seatID = seatID; -- 对应 座位编号
	self.isIngameStatus = false; --座位处于什么状态（未开始还是游戏中）
	self.bReady = false; -- 是否已经准备：如果是在ingame状态，bReady一定为true
	self.hasSetData = false; -- 是否已经设置数据
	self.textFildNode = nil; -- 名称金币等描述区域节点
	self.queImg = nil;
	self.isMineSeat = false;
	self.x = 0; -- 头像坐标
	self.y = 0;
	self.iconDir = nil;
	self.iconUrl = nil;
	self.sex = nil;
	self.iconBtn = nil; 
	--self.iconImg = nil;
	--self.readyBtn = nil;
	self.readyImg = nil;
	self.moneyIcon = nil;
	-- self.quickPayBtn = nil;
	self.bankImg = nil;
	self.isSingleGameFirst = true;
	self.inviteFriendBtn = nil; -- 座位没人时的邀请好友按钮

	self.huTypeImg = nil; -- 胡牌后的胡牌标志

	-- 血流成河
	self.huTypeInfoXLCH = nil;

	--是否在比赛场
	self.inMatchRoom = inMatchRoom;

	self.roomSceneRef = RoomScene_instance;
	self.seatManager = new(SeatManager , self.roomSceneRef);
	
	self:create();
	
end

Seat.dtor = function ( self )
    EventDispatcher.getInstance():unregister(NativeManager._Event, self, self.callEvent);
	EventDispatcher.getInstance():unregister(GlobalDataManager.updateSceneEvent, self, self.updateCoin);
	if self._leftBtn then
	    self.roomSceneRef.nodeOperation:removeChild(self._leftBtn, true);
	    self._leftBtn = nil;
	end
	if self._rightBtn then 
		self.roomSceneRef.nodeOperation:removeChild(self._rightBtn, true);
		self._rightBtn = nil;
	end 
	self.player = nil;
	self.isIngameStatus = false;
	self.bReady = false;
	self:removeAllChildren();
	self.iconBtn = nil;
	--self.iconImg = nil;
	
	self.readyImg = nil;
	self.moneyIcon = nil;
	-- self.quickPayBtn = nil;
	self.bankImg = nil;
	self.inviteFriendBtn = nil;
	self.textFildNode = nil;
	self.huTypeInfoXLCH = nil;
end

-- 创建一个空座位
Seat.create = function ( self)
	DebugLog("Seat.create")
	local tempCoor = Seat.waitingCoor;
	if kSeatMine == self.seatID then
		self.isMineSeat = true;
	else
		self.isMineSeat = false;
	end

	self.textFildNode = new(Node);
	self:addChild(self.textFildNode);
	self.textFildNode:setPos(-7, 0);


	self.x, self.y = tempCoor[self.seatID][1], tempCoor[self.seatID][2];

	--self:setPos(tempCoor[self.seatID][1], tempCoor[self.seatID][2]);

	-- 邀请好友
	if RoomData.getInstance().inFetionRoom then
		self.inviteFriendBtn = UICreator.createBtn( "fetion/inviteIcon.png", self.x, self.y );-- for fetion
	else
		self.inviteFriendBtn  = UICreator.createBtn( seatPinx_map["playerDefault.png"], self.x, self.y );--
		self.inviteFriendIcon = UICreator.createImg( seatPinx_map["inviteFriendIcon.png"], -18, -20);--
        self.inviteFriendIcon:setSize(128, 128);
		self.inviteFriendBtn:addChild(self.inviteFriendIcon);
		self.inviteFriendIcon:setVisible(not self.inMatchRoom);
	end

    if FriendMatchRoomScene_instance and self.inviteFriendIcon then
        self.inviteFriendIcon:setSize(100, 100);
        self.inviteFriendIcon:setPos(-4, -6);
        self.inviteFriendIcon:setFile("Room/friend_invite.png");
    end

	self:addChild(self.inviteFriendBtn);
	self.inviteFriendBtn:setOnClick(self,self.onInviteClick);

	self.inviteFriendBtn:setPickable(not self.inMatchRoom);
	
	-- 创建头像
	-- 底
	self.iconBtn 		= new(Node)--UICreator.createBtn( "Room/icon_bg.png", self.x, self.y );	
	self.buttonInIcon 	= UICreator.createBtn( "Commonx/blank.png", 0, 0);--UICreator.createBtn( seatPinx_map["icon_bg.png"], 0, 0 );--80*80
	self.buttonInIcon:setSize(80,80)
	self.iconBtn:setPos(self.x, self.y);
	self.iconBtn:setSize(self.buttonInIcon:getSize());
	-- 照片
	self.iconDefaultImg = UICreator.createImg( "Commonx/blank.png", 0, 3);
	local iconImgPath   = "Commonx/default_man.png"
	--self.iconImg 	  	= UICreator.createImg( "Commonx/default_man.png", 0, 0);
	if PlatformConfig.platformYiXin == GameConstant.platformType then 
	    --self.iconImg:setFile("Login/yx/Commonx/default_man.png");
	    iconImgPath  = "Login/yx/Commonx/default_man.png"
	end
	-- 边框
	self.iconFrameImg 	= UICreator.createImg( "Room/seat/icon_frame_10002.png", 0, 0);
	setMaskImg(self.iconDefaultImg,"Room/seat/mask.png",iconImgPath)
	--self.iconImg:setSize(self.iconBtn:getSize());
	--self.iconImg:setClip(2,5,76,76)
	--self.iconImg:setClipRes(self.iconBtn.m_res);

	self:addChild(self.iconBtn);
	
	self.iconDefaultImg:setAlign(kAlignCenter)
	self.buttonInIcon:addChild(self.iconDefaultImg);
	self.iconFrameImg:setAlign(kAlignCenter);
	self.buttonInIcon:addChild(self.iconFrameImg);

	--self.iconFrameImg:setPos(-18,-25);
	

	self.buttonInIcon:setOnClick(self, self.iconOnClick);

	--创建玩家信息
	if FriendMatchRoomScene_instance then 
		self.playerInfoView = SceneLoader.load(FMRroomPlayerInfo);
	else 
		self.playerInfoView = SceneLoader.load(roomPlayerInfo);
	end
	self.iconBtn:addChild(self.playerInfoView);
	self.playerInfoView:setAlign(kAlignCenter);
	self.playerInfoView:setPos(0, 90);

	--money 缩小84%
	local coinIcon = publ_getItemFromTree(self.playerInfoView, {"img_player_info","view_2","img_icon_coin"})
	coinIcon:addPropScaleSolid(1, 0.84, 0.84, kCenterDrawing);

	local pText = publ_getItemFromTree(self.playerInfoView, {"img_player_info","view_2","text_coin"})
	pText:addPropScaleSolid(1, 0.84, 0.84, kCenterDrawing);	

	self.bankImg = UICreator.createImg( seatPinx_map["zhangjia.png"],  self:getBankImgPos(self.seatID));
	self.bankImg:setLevel(10)
	self.iconBtn:addChild(self.bankImg);
--UICreator.createImg = function ( imgDIr, x, y ,leftWidth, rightWidth, topWidth, bottomWidth)
	--比赛积分
	local _x,_y = self:getMatchScoreImgPos(self.seatID)
	if self.seatID == kSeatMine and FriendMatchRoomScene_instance then 
		_y = _y + 125
	end 
	self.matchScoreImg = UICreator.createImg( seatPinx_map["matchScoreBg.png"], _x-13,_y,40,20,17,17);
	self.iconBtn:addChild(self.matchScoreImg);
	self.matchScoreText = UICreator.createText( "0", 0, 0, 0, 0, kAlignLeft , 22, 255, 210, 34 );
	self.matchScoreText:setAlign(kAlignLeft);
	self.matchScoreText:setPos(40, -2);
	self.matchScoreImg:addChild(self.matchScoreText);

	self.matchScoreImg:setSize(116,34)

	self.iconBtn:addChild(self.buttonInIcon);

	self:initBtnConfig()
	self:initCreateBtn()

	-- 准备按钮
	if self.isMineSeat then
		--继续
		if MatchRoomScene_instance then
			self:showContinueBtn1()
		else 
			self:showReadyBtn()
		end
	end

	self.huTypeInfoXLCH = new(Node);
	self:addChild(self.huTypeInfoXLCH);
	self:emptyStatu();
end


function Seat.createInviteBtnInFetionRoom(self)

end 

Seat.callEvent = function ( self, param, _detailData )
    if param == kDownloadImageOne then
        if _detailData then
            if self.player and self.iconBtn and _detailData == self.player.localIconDir then -- 下载成功
            	--self.iconImg:setFile("k_"..self.player.localIconDir);
            	setMaskImg(self.iconDefaultImg,"Room/seat/mask.png",self.player.localIconDir)
        --     	--setMaskImg( self.iconBtn , seatPinx_map["icon_mask.png"], "k_"..self.player.localIconDir  )
            end
        end
    end
end

Seat.updateCoin = function ( self, param )
	if not param or GlobalDataManager.UI_UPDATA_MONEY == param.type then
		if self.player and self.player.mid >= 0 then
			local pText = publ_getItemFromTree(self.playerInfoView,{"img_player_info","view_2","text_coin"})
			pText:setText("")
					

			if FriendMatchRoomScene_instance and self.player == PlayerManager.getInstance():myself() then 
				setMoneyNode( self.player:getFriendMatchScore(),pText )	
			else
				 setMoneyNode( self.player.money,pText )	
			end 
		end
	end
end

--邀请按键请求
function Seat.onInviteClick(self)
	if self._inviteObj and self._inviteFunc then 
		self._inviteFunc(self._inviteObj)
	end 
end

function Seat.setOnInviteClickEvent( self, obj ,func )
	self._inviteObj  = obj 
	self._inviteFunc = func
end

--头像框点击事件
function Seat.iconOnClick( self )
	self.roomSceneRef:showPlayerInfoBySeat(self.seatID);
end

Seat.chatBgDir = {
	[kSeatMine] =  "chat_own.png",
	[kSeatRight] = "chat_right.png",
	[kSeatTop] =  "chat_right.png",
	[kSeatLeft] =  "chat_right.png",
};

Seat.setChatNode = function ( self, node )
	self.chatNode = node;
end

Seat.setUserInfoNode = function ( self, node )
	self.userInfoNode = node;
end

Seat.showChat = function ( self, msg )
	DebugLog("[Seat]:showChat msg:"..tostring(msg));
	if not self.chatNode then
		return;
	end
	if not msg or #publ_trim(msg) < 1 then
		return;
	end	
	local msg = stringFormatWithString( msg, GameConstant.chatMaxCharNum, true);

	if not self.chatItem then
		self.chatItem = new(ShowChatItem, self);
		self.chatNode:addChild(self.chatItem);
		self:resetChatitemPos();
	end

	self.chatItem:setVisible(true);
	self.chatItem:showMsg(msg);
end

Seat.resetChatitemPos = function ( self )
	if self.chatItem then
		local x, y = 0, 0;
		if self.isIngameStatus then
			tempCoor = Seat.inGameCoor;
		else
			tempCoor = Seat.waitingCoor;
		end
		x = tempCoor[self.seatID][1] - Seat.chatCoorOffset[self.seatID][1];
		y = tempCoor[self.seatID][2] - Seat.chatCoorOffset[self.seatID][2];
		
		self.chatItem:setPos(x, y);
	end
end

Seat.hideChatItem = function ( self )
	if self.chatItem then
		self.chatItem:setVisible(false);
	end
end
---
function Seat:showVoice(item, num)
	if not self.chatNode then 
		return 
	end 
	--无数据
	if not item or num <= 0 then 
		self:hideVoice()
		return 
	end 
	--
	if not self.voiceAnim then 
		self.voiceAnim =  new(VoicePlayAnim,"voicePlayTip",self.seatID)
		self.chatNode:addChild(self.voiceAnim)

		if self.seatID == kSeatRight then 
			self.voiceAnim:setFlipX(true)
		end
		if self.roomSceneRef then 
			self.voiceAnim:setPlayCallback(self.roomSceneRef,self.roomSceneRef.startPlay)
		end 
	end 
	self:resetVoicePos()
	self.voiceAnim:setSeconds(item.time)
	self.voiceAnim:setCurFile(item.file)
	self.voiceAnim:showRedTip(num)
	self.voiceAnim:setVisible(true)
end
function Seat:resetVoicePos()
	if self.voiceAnim then
		local x, y = 0, 0;
		if self.isIngameStatus then
			tempCoor = Seat.inGameCoor;
		else
			tempCoor = Seat.waitingCoor;
		end
		x = tempCoor[self.seatID][1] + Seat.voiceCoorOffset[self.seatID][1];
		y = tempCoor[self.seatID][2] + Seat.voiceCoorOffset[self.seatID][2];
		
		self.voiceAnim:setPos(x, y);
	end
end

function Seat:getVoice( ... )
	return self.voiceAnim
end

function Seat:hideVoice()
	if self.voiceAnim then 
		self.voiceAnim:stop()
		self.voiceAnim:setVisible(false)
	end 
end


-- Seat.showReadyAndChangeBtn = function(self)
-- 	DebugLog("Seat.showReadyAndChangeBtn")

-- 		local curLevel    = RoomData.getInstance().level
-- 		local curRoomType = HallConfigDataManager.getInstance():returnTypeForLevel( curLevel )
-- 		local curMoney    = PlayerManager.getInstance():myself().money
-- 		local curVipLevel = PlayerManager.getInstance():myself().vipLevel
-- 		local ret,hd = HallConfigDataManager.getInstance():returnMinRequireHallDataForTypeAndLevel(curRoomType,curLevel,curMoney,curVipLevel)						
-- 		GameConstant.go_to_high = ret and hd

-- 	local title = self.changeRoom:getChildByName("text")
-- 	if title and GameConstant.go_to_high then 
-- 		title:setText("去高倍场")
-- 	elseif title then 
-- 		title:setText("换 桌") 
-- 	end 
-- end



Seat.setBankSeat = function ( self )
	self.bankImg:setVisible(true);
end

Seat.setMatchScoreVisible = function ( self, visible )
	self.matchScoreImg:setVisible(visible);
end

Seat.setMatchScore = function ( self, score )
	self.matchScoreText:setText(score and tostring(score) or "0");
end


Seat.getBankImgPos = function ( self, seatID )
	return Seat.bankCoor[seatID][1], Seat.bankCoor[seatID][2];
end
Seat.getMatchScoreImgPos = function ( self, seatID )
	return Seat.matchScoreCoor[seatID][1], Seat.matchScoreCoor[seatID][2];
end


Seat.getReadyImgPos = function ( self, seatID )

	--底框 		180x80
	--准备手势 	41*45
	--头像 		80*80

	if kSeatMine == seatID then
		return Seat.waitingCoor[kSeatMine][1] + 80 / 2 - 41/2, Seat.waitingCoor[kSeatMine][2] - 45 - 20;
	elseif kSeatRight == seatID then
		return Seat.waitingCoor[kSeatRight][1] + 80 / 2 - 180/2 - 20 - 41, Seat.waitingCoor[kSeatRight][2] + 80 - 45/2;
	elseif kSeatTop == seatID then
		return Seat.waitingCoor[kSeatTop][1] + 80 / 2 - 41/2, Seat.waitingCoor[kSeatTop][2] + 80 + 80 + 40;
	elseif kSeatLeft == seatID then
		return Seat.waitingCoor[kSeatLeft][1] + 80 / 2 + 180/2 + 20 , Seat.waitingCoor[kSeatLeft][2] + 80 - 45/2;
	end

end



Seat.emptyStatu = function ( self )
	self.player = nil;
	self.inviteFriendBtn:setVisible(true);
	if self.isIngameStatus then
		local moveX = Seat.inGameCoor[self.seatID][1] - Seat.waitingCoor[self.seatID][1];
		local moveY = Seat.inGameCoor[self.seatID][2] - Seat.waitingCoor[self.seatID][2];
		self.inviteFriendBtn:setPos(self.x + moveX, self.y + moveY);
	else
		self.inviteFriendBtn:setPos(self.x, self.y);
	end

	self.iconBtn:setVisible(false);
	self.playerInfoView:setVisible(false);
	
	self:setReady(false);

	self.bankImg:setVisible(false);
	self.matchScoreImg:setVisible(false);
	if self.queImg then
		self.queImg:setVisible(false);
	end
	if self.isMineSeat then
		self:hideAllBtn()
	end

	self.textFildNode:setVisible(false);
	self:hideChatItem();
end

-- 这里可以添加移动效果
Seat.changeToIngameStatu = function ( self, bNeedAnim )
	if not self.hasSetData and self.isIngameStatus then
		DebugLog("   Seat   changeToIngameStatu  error ! cus it is a empty seat . ");
		return;
	end
	self:setReady(false);
	
	self.textFildNode:setVisible(false);
	self.playerInfoView:setVisible(false);
	local moveX = Seat.inGameCoor[self.seatID][1] - Seat.waitingCoor[self.seatID][1];
	local moveY = Seat.inGameCoor[self.seatID][2] - Seat.waitingCoor[self.seatID][2];
	if bNeedAnim then
		if self.iconBtn then
			local anim = self.iconBtn:addPropTranslate(Seat.movePropSque, kAnimNormal, 500, 0, 0, moveX, 0, moveY);
			if anim then
				anim:setEvent(self, function ( self )

					self.iconBtn:setPos(self.iconBtn.m_x / System.getLayoutScale()+ moveX, self.iconBtn.m_y / System.getLayoutScale()+ moveY);
					self.iconBtn:removeProp(Seat.movePropSque);
					--设置金币可见
					self.roomSceneRef:showMoneyExchange(true);
				end)
			end
		end
	else
		self.iconBtn:setPos(Seat.inGameCoor[self.seatID][1], Seat.inGameCoor[self.seatID][2] );
	end
	
	if self.isMineSeat then
		self:hideAllBtn()
	end
	self.isIngameStatus = true;
	self:resetChatitemPos();
	self:resetVoicePos()
end

Seat.setReadyStatu = function ( self, bReady )
	if not self.hasSetData then
		DebugLog(" Seat:setReadyStatu failed, caus now is not hasSetData ! ");
		return;
	end


	self.bReady = bReady;
	self:updataReadyView();
end

Seat.updataReadyView = function ( self )
	if self.bReady then
		self:setReady(true);
		if self.isMineSeat then
			self:hideAllBtn()
		end
	else
		self:setReady(false);
		if self.isMineSeat then
			if GameConstant.isSingleGame and not self.isSingleGameFirst then
				self._leftBtn:setPos(Seat.againCoor[1], Seat.againCoor[2]);
			end
		end
	end
end

Seat.setReady = function ( self, bReady )
	if self.readyImg then
		self:removeChild(self.readyImg,true);
		self.readyImg = nil;
	end

	if bReady then
		self.readyImg = UICreator.createImg(seatPinx_map["readyText.png"], self:getReadyImgPos(self.seatID) );
		self:addChild(self.readyImg);
	end


end

-- 可在这里添加移动效果
Seat.changeToWaitStaty = function ( self )
	self.isIngameStatus = false;
	self:resetChatitemPos();
	self:resetVoicePos()
	self.bankImg:setVisible(false);
	self.matchScoreImg:setVisible(false);
	if self.queImg then
		self.queImg:setVisible(false);
	end
	if self.huTypeImg then
		self.huTypeImg:setVisible(false);
	end

	if self.isMineSeat then
		self:setBtnState(1)
	end
	
	if self.huTypeInfoXLCH then
		self.huTypeInfoXLCH:removeAllChildren();
		self.flagHuImg = nil;
	end
	if self.hasSetData then	
		self.iconBtn:setPos( self.x, self.y );
		self.textFildNode:setVisible(true);
		self.playerInfoView:setVisible(true);
		self:updataReadyView();
	else
		self.inviteFriendBtn:setPos( self.x, self.y );
	end

	--设置金币不可见
	self.roomSceneRef:showMoneyExchange(false);
end

Seat.dingque = function ( self, queType )
-- Seat.queCoor
	DebugLog("Seat.dingque")
	if not self.queImg then
		self.queImg = UICreator.createImg(Seat.dir[queType], Seat.queCoor[self.seatID][1], Seat.queCoor[self.seatID][2] );
		self:addChild(self.queImg);
	else
		self.queImg:setFile(Seat.dir[queType]);
		self.queImg:setVisible(true);
	end
end

-- 普通胡牌图标位置
Seat.HuFlagCoor = {
	[kSeatMine] = {375, 270},
	[kSeatRight] = {570, 197},
	[kSeatTop] = {375, 125 + 8},
	[kSeatLeft] = {189, 197}
}


Seat.widthSmaller = 8;
Seat.heightSmaller = 8;
-- 一个时候的位置
Seat.HuFlagCoorXLCHOne = {
	[kSeatMine] = {375, 270},
	[kSeatRight] = {570 - 38, 197},
	[kSeatTop] = {375, 125 + 8},
	[kSeatLeft] = {189, 197}
}

-- 血流成河胡牌位置 42 * 36
Seat.HuFlagCoorXLCH = {
	[kSeatMine] = {375 + 25, 270},
	[kSeatRight] = {570 - 38, 228},
	[kSeatTop] = {375 + 25, 125 + 8},
	[kSeatLeft] = {189, 228}
}

-- 血流成河自摸位置
Seat.zimoFlagCoorXLCH = {
	[kSeatMine] = {350 - 25, 270},
	[kSeatRight] = {570 - 38, 173},
	[kSeatTop] = {350 - 25, 125 + 8},
	[kSeatLeft] = {189, 173}
}


Seat.PLAY_AGAIN_TYPE = 1; -- 再玩一局
Seat.CHANGE_ROOM_TYPE = 2; -- 换房间

Seat.setBtnCallback = function ( self, obj, callback )
	self.obj = obj;
	self.callback = callback;
end

-- 游戏中胡牌了 huType 1 放炮  2 自摸
Seat.huInGame = function ( self, huType )
	DebugLog("Seat.huInGame")
	if not self.huTypeImg then
		self.huTypeImg = UICreator.createImg(seatPinx_map["hu"..huType..".png"], 0, 0);
		self:addChild(self.huTypeImg);
	else
		self.huTypeImg:setFile(seatPinx_map["hu"..huType..".png"]);
		self.huTypeImg:setSize(self.huTypeImg.m_res.m_width,self.huTypeImg.m_res.m_height);
		self.huTypeImg:setVisible(true);
	end

	local x,y = Seat.HuFlagCoor[self.seatID][1],Seat.HuFlagCoor[self.seatID][2];

	if huType == 2 then
		--注意，因为自摸图标和胡图标大小不一样，所以需要调整
		if kSeatMine == self.seatID or kSeatTop == self.seatID then
			x = x - (83 - 45) / 2;
		elseif kSeatRight == self.seatID then
			x = x - (83 - 45);
		end

	end

	self.huTypeImg:setPos(x, y);

	if kSeatMine == self.seatID  and not GameConstant.isSingleGame  
								 and not MatchRoomScene_instance 
								 and not FriendMatchRoomScene_instance then -- 私人房间或飞信熟人房不显示换房间按钮
		DebugLog("提前胡 不是私人房  不是单机  不是比赛  不是飞信")
		--换桌
		-----------------------分类判断   能去更高场次  显示去高倍场
		-------------------------------------其他  显示再来一局
		local curLevel = RoomData.getInstance().level
		DebugLog("---------------------!!!" .. tostring(curLevel))
		if not curLevel then
			DebugLog("not level ")
			return;
		end
		local curRoomType = HallConfigDataManager.getInstance():returnTypeForLevel( curLevel )
		local curMoney    = PlayerManager.getInstance():myself().money
		local curVipLevel = PlayerManager.getInstance():myself().vipLevel
		DebugLog("curLevel type:" .. type(curLevel) .. "curRoomType type:" .. type(curRoomType) .. " curMoney type:" .. type(curMoney))
		DebugLog( "curLevel:" .. tostring(curLevel) .. " curRoomType: " .. tostring(curRoomType) .. " curMoney:" .. tostring(curMoney))
		local ret,hd = HallConfigDataManager.getInstance():returnMinRequireHallDataForTypeAndLevel(curRoomType,curLevel,curMoney,curVipLevel)						
		GameConstant.go_to_high = ret and hd

		self:showDetailAndChangeBtn(GameConstant.go_to_high)
	
	elseif kSeatMine == self.seatID and not GameConstant.isSingleGame  and (8 == GameConstant.matchStatus.matchStage) then
		DebugLog("比赛中提前胡")
		self:showDetailAndContinueBtn()
	elseif kSeatMine == self.seatID and FriendMatchRoomScene_instance then --好友对战 提前胡 只显示详情
		self:showDetailBtn()
	end
end

-- 血流中途有人胡牌
Seat.huInGameXLCH = function (self , info)
	if not info or not info.hu or not info.zimo then
		return;
	end
	local num = 0;
	if info.hu > 0 then
		num = num + 1;
	end
	if info.zimo > 0 then
		num = num + 1;
	end
	if num <= 0 then
		return ;
	end

	if not self.flagHuImg then
		self.flagHuImg = UICreator.createImg(seatPinx_map["hu1.png"], x, y);
		self.huTypeInfoXLCH:addChild(self.flagHuImg);
		self.flagZimoImg = UICreator.createImg(seatPinx_map["hu2.png"], x, y);
		self.huTypeInfoXLCH:addChild(self.flagZimoImg);
		self.flagHuImg:setVisible(false);
		self.flagZimoImg:setVisible(false);

		self.zimoText = UICreator.createText( "x0", 0, 0, 83, 30, kAlignLeft , 26, 250, 200, 0 );
		self.huTypeInfoXLCH:addChild(self.zimoText);
		self.zimoText:setVisible(false);

		self.huText = UICreator.createText( "x0", 0, 0, 83, 30, kAlignLeft , 26, 250, 200, 0 );
		self.huTypeInfoXLCH:addChild(self.huText);
		self.huText:setVisible(false);
		-- 图片比正常的小一点
		self.flagHuImg:setSize(self.flagHuImg.m_width - Seat.widthSmaller, self.flagHuImg.m_height - Seat.heightSmaller);
		self.flagZimoImg:setSize(self.flagZimoImg.m_width - Seat.widthSmaller, self.flagZimoImg.m_height - Seat.heightSmaller);
	end

	if 1 == num then 
		if info.hu > 0 then -- hu
			self.flagHuImg:setVisible(true);
			self.flagHuImg:setPos(Seat.HuFlagCoorXLCHOne[self.seatID][1], Seat.HuFlagCoorXLCHOne[self.seatID][2]);
			self.huText:setVisible(true);
			self.huText:setText("x"..info.hu);
			self.huText:setPos(Seat.HuFlagCoorXLCHOne[self.seatID][1] + 40, Seat.HuFlagCoorXLCHOne[self.seatID][2] );
		else -- zimo
			self.flagZimoImg:setVisible(true);
			self.flagZimoImg:setPos(Seat.HuFlagCoorXLCHOne[self.seatID][1], Seat.HuFlagCoorXLCHOne[self.seatID][2]);
			self.zimoText:setVisible(true);
			self.zimoText:setText("x"..info.zimo);
			self.zimoText:setPos(Seat.HuFlagCoorXLCHOne[self.seatID][1] + 80, Seat.HuFlagCoorXLCHOne[self.seatID][2] );
		end
	else
		self.flagHuImg:setVisible(true);
		self.flagZimoImg:setVisible(true);
		self.zimoText:setVisible(true);
		self.huText:setVisible(true);
		self.flagHuImg:setPos(Seat.HuFlagCoorXLCH[self.seatID][1], Seat.HuFlagCoorXLCH[self.seatID][2]);
		self.flagZimoImg:setPos(Seat.zimoFlagCoorXLCH[self.seatID][1], Seat.zimoFlagCoorXLCH[self.seatID][2]);
		self.huText:setText("x"..info.hu);
		self.huText:setPos(Seat.HuFlagCoorXLCH[self.seatID][1] + 40, Seat.HuFlagCoorXLCH[self.seatID][2] );
		self.zimoText:setText("x"..info.zimo);
		self.zimoText:setPos(Seat.zimoFlagCoorXLCH[self.seatID][1] + 80, Seat.zimoFlagCoorXLCH[self.seatID][2]);
	end


	
end

-- 一局游戏结束
Seat.gameFinish = function ( self )
	DebugLog("Seat.gameFinish")----------------------------
	self:hideChatItem();

	self:hideAllBtn()

	self.bReady = false; -- 准备状态修改
	if MatchRoomScene_instance then
		if self.flagHuImg then
			self.flagHuImg:setVisible(false);
		end
		if self.flagZimoImg then
			self.flagZimoImg:setVisible(false);
		end
		if self.zimoText then
			self.zimoText:setVisible(false);
		end
		if self.huText then
			self.huText:setVisible(false);
		end
	end
end

-- 给座位设置数据：头像，名称等
-- {iconDir, iconUrl, sex, nickName, money, bIngame, bReady }
Seat.setData = function ( self, player )
	if not player then
		return;
	end

	self.player = player;
	self.inviteFriendBtn:setVisible(false);
	self.hasSetData = true;

	local iconDir ;
	local iconSexDir ;
	if publ_isFileExsit_lua(self.player.localIconDir) then -- 图片已下载
		iconDir = self.player.localIconDir;
	else -- 图片下载启动
		self.player:downloadIconImg();
		if tonumber(self.player.sex) == kSexMan then
			--iconSexDir = "Commonx/male.png"
			if not iconDir then -- 设置默认图片
				iconDir = "Commonx/default_man.png";
				if PlatformConfig.platformYiXin == GameConstant.platformType then 
				    localDir = "Login/yx/Commonx/default_man.png";
				end
			end
		else
			--iconSexDir = "Commonx/female.png"
			if not iconDir then -- 设置默认图片
				iconDir = "Commonx/default_woman.png";
				if PlatformConfig.platformYiXin == GameConstant.platformType then 
				    localDir = "Login/yx/Commonx/default_woman.png";
				end
			end
		end
		if GameConstant.uploadHeadIconName 
			and GameConstant.uploadHeadIconName ~= ""  
			and PlayerManager.getInstance():myself().mid == self.player.mid then
			
			iconDir = GameConstant.uploadHeadIconName;
		end 		
	end 

	if tonumber(self.player.sex) == kSexMan then
		iconSexDir = "Commonx/male.png"
	else
		iconSexDir = "Commonx/female.png"
	end
	
	if iconDir then	
		--setMaskImg( self.iconBtn , seatPinx_map["icon_mask.png"], iconDir  )	
		setMaskImg(self.iconDefaultImg,"Room/seat/mask.png",iconDir)
		--self.iconImg:setFile(iconDir);
	end

	local iconFrameDir = self:getIconFrame();
	DebugLog( "iconFrameDir = "..iconFrameDir );

	-- if self.player:checkVipStatu(Player.VIP_TXK) then -- vip头像
	-- 	iconFrameDir = seatPin_map["icon_frame_vip.png"];
	-- elseif self.player.circletype > 0 then -- 龙戒
	-- 	iconFrameDir = seatPin_map["longjieIcon.png"];
	-- else
	-- 	iconFrameDir = seatPin_map["icon_frame.png"];
	-- end

	--设置头像边框
	if iconFrameDir then
		self.iconFrameImg:setFile(iconFrameDir);
	end

	--设置信息
	if iconSexDir then
		publ_getItemFromTree(self.playerInfoView,{"img_player_info","view_1","img_icon_sex"}):setFile(iconSexDir);
	end

	local nameStr = "";
	if FriendDataManager.getInstance():getFriendNameById(tonumber(player.mid)) then
		nameStr = FriendDataManager.getInstance():getFriendNameById(tonumber(player.mid));
	else
		nameStr = player.nickName;
	end
	publ_getItemFromTree(self.playerInfoView,{"img_player_info","view_1","text_name"}):setText(stringFormatWithString(nameStr, 8));
	self:updateCoin()
	--publ_getItemFromTree(self.playerInfoView,{"img_player_info","view_2","text_coin"}):setText(trunNumberIntoThreeOneFormWithInt(player.money, true));

	self:resetChatitemPos();
	
	self.iconBtn:setVisible(true);

	self.bReady = player.isReady;

	if self.isIngameStatus then
		self:changeToIngameStatu(false);
	else
		self:changeToWaitStaty();
	end

	if GameConstant.isSingleGame and self.seatID ~= 0 then
		local fileStr = "";
		local nick = GameString.convert2Platform(player.nickName);
		--"大叔", "男神", "萌妹纸", "邻家MM", "可爱姑娘"
		if nick == GameString.convert2Platform("大叔") then
			fileStr = fileStr .. "touxiang1";
		elseif nick == GameString.convert2Platform("男神") then
			fileStr = fileStr .. "touxiang2";
		elseif nick == GameString.convert2Platform("萌妹纸") then
			fileStr = fileStr .. "touxiang3";
		elseif nick == GameString.convert2Platform("邻家MM") then
			fileStr = fileStr .. "touxiang4";
		else
			player.nickName = "大叔";
			fileStr = fileStr .. "touxiang1";
		end
		fileStr = fileStr .. ".png";
		local SingleImagePin_map = require("qnPlist/SingleImagePin")

		--setMaskImg( self.iconBtn , seatPinx_map["icon_mask.png"], SingleImagePin_map[fileStr]  )
		setMaskImg(self.iconDefaultImg,"Room/seat/mask.png",SingleImagePin_map[fileStr])
		--self.iconImg:setFile(SingleImagePin_map[fileStr]);
	end
end


-- 获取头像框图片
Seat.getIconFrame = function( self )
	DebugLog( "Seat.getIconFrame" );
	local imgIconFrame = nil;

	local function getVipIconFrame( vipLevel )
		if vipLevel and vipLevel > 0 and vipLevel <= 10 then 
			return "Room/seat/VIP" ..vipLevel.. ".png" ;
		end 
	end
    --又不用新id了，先注释--5.30 新配置的龙戒旧id 5,32,33,34,新id 62,64,365,63,
    local file_list = {
 		[5] = "Room/seat/icon_frame_5.png",
 		--[62] = "Room/seat/icon_frame_5.png",
 		[32] = "Room/seat/icon_frame_32.png",
 		--[64] = "Room/seat/icon_frame_32.png",
 		[33] = "Room/seat/icon_frame_33.png",
 		--[65] = "Room/seat/icon_frame_33.png",
 		[34] = "Room/seat/icon_frame_34.png", 
 		--[63] = "Room/seat/icon_frame_34.png",
 		default = "Room/seat/icon_frame_10002.png", 		  
    };
    
	if self.player.circletype and self:isExistIcon( self.player.circletype ) then
		DebugLog( "exist new icon frame" );
		
		local ctype = tonumber(self.player.circletype)
		if ctype and ctype == 10003 then 
			imgIconFrame =getVipIconFrame(tonumber(self.player.vipLevel))
		end 
		imgIconFrame = imgIconFrame or file_list[ctype] or file_list.default--"Room/seat/icon_frame_"..self.player.circletype..".png";
	else
		DebugLog( "not exist new icon frame" );
		local frame = getVipIconFrame(tonumber(self.player.vipLevel))
		if frame then 
			imgIconFrame = frame ;
		--if self.player:checkVipStatu(Player.VIP_TXK) then -- vip头像
		--	imgIconFrame = "Room/seat/icon_frame_10003.png";
		elseif self.player.circletype > 0 then -- 龙戒
			imgIconFrame = "Room/seat/icon_frame_5.png";
		else
			imgIconFrame = "Room/seat/icon_frame_10002.png";
		end
	end
    DebugLog("imgIconFrame:"..imgIconFrame.." ctype:"..tostring(ctype));
	return imgIconFrame;
end

-- 是否存在头像框
Seat.isExistIcon = function ( self, iconFrameId )
	if not iconFrameId then
		return false;
	end

	local ids = { 5, 10002, 10003, 32, 33, 34 };

	for k,v in pairs(ids) do
		if tonumber( v ) == tonumber( iconFrameId ) then
			return true;
		end
	end

	return false;
end



-- 显示破产动画
Seat.showBankruptAnim = function ( self, seatID, rootNode )
	local Seat = self.seatManager:getSeatByLocalSeatID(seatID);
	local p = {Seat.iconBtn:getPos()};
	local view = new(AnimationBankrupt, p, rootNode);
	-- self.chatNode:addChild(view);
	view:play();
end

Seat.showFace = function( self, faceType)
	if( 1 ~= GameConstant.faceIsCanUse )then
		return;
	end

    local num = 0;

	local s = "%02d.png";
	local str ="0";
	local count =0;
	local playCount = 0;
	local ms = 0;

	local oldVersion = true;

	local playerVipIndex = -1;
	
	if faceType == 2^16+1 then
		num = faceType - (2^16);
		str =string.format("happybaby%d0",num);
		count=faceBConfigArray[num].imgCount;
		playCount=faceBConfigArray[num].playCount;
		ms=faceBConfigArray[num].ms;
	elseif faceType < 12 then -- 1 - 11 狐狸表情
		num = faceType;
		str = string.format("expressionMagic%d",num);
		s   = "";
		playCount = 1;
		count = 1;
		ms = 150;
		oldVersion = false;
		-- str = string.format("expression-Magic%d0",num);
		-- count= faceMConfigArray[num].imgCount;
		-- playCount = faceMConfigArray[num].playCount;
		-- ms = faceMConfigArray[num].ms;
	elseif faceType > 100 and faceType < 128 then -- 101 ~ 127 普通表情
		num = faceType - 100;
		str = string.format("expression%d0",num);
		count = faceQConfigArray[num].imgCount;
		playCount = faceQConfigArray[num].playCount;
		ms = faceQConfigArray[num].ms;
	elseif faceType > 400 and faceType < 413 then -- 401 ~ 412 妹子表情
		playerVipIndex = faceType - 400;
		str = "vip" .. (faceType - 400);
		playCount = 1;
		count = 1;
		ms = 150;
		s = "";
		oldVersion = false;
	end

	if str ~= "0" and faceValue ~= 0 then
		local x, y = 0, 0;
		if self.isIngameStatus then
			tempCoor = Seat.inGameCoor;
		else
			tempCoor = Seat.waitingCoor;
		end
		x = tempCoor[self.seatID][1] - Seat.chatCoorOffset[self.seatID][1];
		y = tempCoor[self.seatID][2] - Seat.chatCoorOffset[self.seatID][2];
		if kSeatLeft == self.seatID then
			y = y - 20;
		elseif kSeatRight == self.seatID then
			x = x + 150;
			y = y - 130;
		end
		if self.isIngameStatus then
			if kSeatLeft == self.seatID then
				y = y - 60;
			elseif kSeatTop == self.seatID then
				y = y - 80;
			end
		end

		local node = nil;
		node = ExpressionAnim.play(self.seatID, str .. s, 1, count, ms, playCount, x, y,nil,nil,oldVersion);
		if node then
			self.chatNode:addChild(node);
		end
	end
end

Seat.clearData = function ( self )
	self.hasSetData = false;
	self:emptyStatu();
end

Seat.setVisible = function ( self, bVisible )
	self:setVisible(bVisible);
end

ShowChatItem = class(Node);
ShowChatItem.ctor = function ( self, seat )
	self.seat = seat;
	self.textView = nil;
	self.m_anim = nil;
	self.moveAnim = nil;
	self.speed = 2;
	--這裡要根據位置移動圖標
	self.parentNode = new(Node);
	self.contentArea = new(Node);
	if seat.seatID == kSeatMine then
		self.chatBg = UICreator.createImg("Room/chat/" .. Seat.chatBgDir[seat.seatID], 0, 0, 50, 50, 0, 0);
		self:setContentArea(18, 0, 250, 50);
	elseif seat.seatID == kSeatRight then
		self.chatBg = UICreator.createImg("Room/chat/" .. Seat.chatBgDir[seat.seatID], 0, 0, 50, 50, 0, 0);		
		self:setContentArea(18, 0, 250, 50);
	elseif seat.seatID == kSeatTop then
		self.chatBg = UICreator.createImg("Room/chat/" .. Seat.chatBgDir[seat.seatID], 0, 0, 50, 50, 0, 0);		
		self.chatBg:setRotate(180, kCenterDrawing); 
		self:setContentArea(18, 7, 250, 55);
	elseif seat.seatID == kSeatLeft then
		self.chatBg = UICreator.createImg("Room/chat/" .. Seat.chatBgDir[seat.seatID], 0, 0, 50, 50, 0, 0);
		self.chatBg:setRotate(180, kCenterDrawing);
		self:setContentArea(18, 7, 250, 55);
	end
	self.chatBg:setSize(298,72);
	self.parentNode:addChild(self.chatBg);
	self.parentNode:addChild(self.contentArea);
	self:addChild(self.parentNode);
end


ShowChatItem.setContentArea = function ( self, x, y, w, h )
	self.contentArea:setPos(x, y);
	self.contentArea:setSize(w, h);
	self.contentArea:setClip(x, y, w, h);
end

ShowChatItem.showMsg = function ( self, msg )
	delete(self.m_anim);
	self.m_anim = nil;
	delete(self.moveAnim);
	self.moveAnim = nil;
	if self.textView then
		self.contentArea:removeChild(self.textView, true);
	end

	local textW , textH = self.contentArea:getSize();
	if  kSeatRight == self.seat.seatID or kSeatMine == self.seat.seatID then
		self.textView = UICreator.createText( msg, 0, 0, textW, textH, kAlignLeft, 26, 48, 6, 0 );
	else
		self.textView = UICreator.createText( msg, 0, 14, textW, textH, kAlignLeft, 26, 48, 6, 0 );
	end

	self.contentArea:addChild(self.textView);
	self.dist = self.textView.m_res.m_width - self.contentArea.m_width; -- 未显示完的部分
	self.m_anim = new(AnimInt, kAnimNormal, 0, 1, 2500, -1); -- 1s 后移动或是消失
	self.m_anim:setDebugName("ShowChatItem|self.m_anim");
  	self.m_anim:setEvent(self, self.onTimer);
end

ShowChatItem.onTimer = function ( self )
	delete(self.m_anim);
	self.m_anim = nil;
	if self.dist > 0 then
		delete(self.moveAnim);
		self.moveAnim = nil;
		self.moveAnim = new(AnimInt, kAnimRepeat, 0, 1, 1, 0);
		self.moveAnim:setEvent(self, function ( self )
			self.textView:setPos(self.textView.m_x / System.getLayoutScale() - self.speed, self.textView.m_y / System.getLayoutScale());
			self.dist = self.dist - self.speed;
			if self.dist <= -10 then
				delete(self.moveAnim);
				self.moveAnim = nil;
				self.m_anim = new(AnimInt, kAnimNormal, 0, 1, 1000, -1); -- 1s 后移动或是消失
  				self.m_anim:setEvent(self, function ( self )
  					delete(self.m_anim);
  					self.m_anim = nil;
  					self.seat:hideChatItem();
  				end);
			end	
		end);
	else
		self.seat:hideChatItem();
	end
end

ShowChatItem.dtor = function ( self )
	delete(self.m_anim);
	delete(self.moveAnim);
	self:removeAllChildren();
end



--------------------------------------------------------------换桌,准备,详情等按钮显示逻辑
function Seat:initBtnConfig( )
	self._btnConfig = {
		["posX"] = {
						-281.5,-70.5,118.5,--left,mid,right
					},
		["posY"] = -105,
		["file"] = {
					"Commonx/green_big_wide_btn.png","Commonx/yellow_bg_wide_btn.png",---green,yellow
	    },
	}



	self._btnState = {
		{1,"准 备"},--1个绿色准备按钮
		{1,"继 续"},
		{2,"换 桌"},--1个黄色换桌按钮
		{2,1,"换 桌","准 备"},--显示2个按钮,左颜色,右颜色,左label str，右边label str
		{2,1,"详 情","换 桌"},--5
		{2,1,"去高倍场","准备"},
		{2,1,"详 情","去高倍场"},
		{2,1,"详 情","继 续"},
		{1,1,"准 备","联 网"},
		{1,"详 情"},--10
		{2,1,"解散房间","继续开局"},--11
		--{true,true,2,1,"换桌","准备"}
	}
end

--解散牌局 和 继续开局
function Seat:showFMRGameResultBtn(obj, leftFunc, rightFunc)
	self:setBtnState(11)
	self._leftBtn:setOnClick(obj,leftFunc)
	self._rightBtn:setOnClick(obj,rightFunc)
end

function Seat:hideAllBtn()
	self._leftBtn:setVisible(false)
	self._rightBtn:setVisible(false)
end

function Seat:showContinueBtn( )
	self:setBtnState(2)--继续
	self._leftBtn:setOnClick(self, self.onClickedContinueBtnInMatch);
end

function Seat:showContinueBtn1( )
	self:setBtnState(2)--继续
	self._leftBtn:setOnClick(self, self.onClickedContinueBtn1InMatch);
end


function Seat:showReadyBtn( )
	self:setBtnState(1)--准备
	if self._readyObj and self._readyFunc then 
		self._leftBtn:setOnClick(self._readyObj, self._readyFunc)
	end 
end

function Seat:showDetailBtn( )
	self:setBtnState(10)
	self._leftBtn:setOnClick(self,self.onCLickedDetailBtn)
end

function Seat:showReadyChangeBtn(isHigh)
	local state = 4

	if isHigh then 
		state = 6
	end 
	self:setBtnState(state)
	
	if self._readyObj and self._readyFunc then 
		self._rightBtn:setOnClick(self._readyObj, self._readyFunc)
	end 	
	self._leftBtn:setOnClick(self,self.onClickedChangeRoomBtn)
end

function Seat:showDetailAndChangeBtn( isHigh )
	local state = 5

	if isHigh then 
		state = 7
	end 
	self:setBtnState(state)
	
	self._rightBtn:setOnClick(self,self.onClickedChangeRoomBtn)	
	self._leftBtn:setOnClick(self,self.onCLickedDetailBtn)
end

function Seat:showDetailAndContinueBtn()
	self:setBtnState(8)
	self._leftBtn:setOnClick(self,self.onCLickedDetailBtn)
	self._rightBtn:setOnClick(self,self.onClickedContinueBtnInMatch)
end

function Seat:showReadyOnlineBtn(  )
	self:setBtnState(9)
	self._leftBtn:setOnClick(self,self.onCLickedDetailBtn)
	self._rightBtn:setOnClick(self,self.onClickedOnlineBtn)
end

----------------------------------------------------------比赛 继续

function Seat.setReadyBtnFun( self, obj, fun )
	if self.isMineSeat then
		self._readyObj  = obj 
		self._readyFunc = fun
		--self._leftBtn:setOnClick(obj,fun)
	end
end

function Seat.onCLickedDetailBtn( self )
	GameConstant.curGameSceneRef:showLittleResultDetail();
end

function Seat.onClickedOnlineBtn( self )
	GameConstant.curGameSceneRef:onClickedOnlineBtn();
end
function Seat.onClickedChangeRoomBtn( self )
	-- 客户端判断到金币不足，显示金币购买弹窗
	if not GameConstant.curGameSceneRef:judgeMoneyAndShowChargeWnd() then 
		return;
	end
	-- 提前胡请求换桌
	local param = {};
	param.mid = PlayerManager.getInstance():myself().mid;
	SocketManager.getInstance():sendPack(CLIENT_COMMAND_REQ_LOGOUT, param);
end

function Seat.onClickedContinueBtn1InMatch( self )
	self._leftBtn:setVisible(false)

	PlayerManager:getInstance():removeOtherPlay(); -- 移除其他玩家数据
	RoomData.getInstance():clearData(); -- 清除房间数据
	for k,v in pairs(RoomScene_instance.seatManager.seatList) do
		v:changeToWaitStaty();
		if v.seatID ~= kSeatMine then
			v:clearData();
		end
	end
	RoomScene_instance:clearDesk();
	GameConstant.isDirtPlayGame = true;
	if 8 == GameConstant.matchStatus.matchStage then
		MatchRoomScene_instance:showWaitStartOrRankView("正在为您配桌");
	elseif 9 == GameConstant.matchStatus.matchStage then
		local str = "预赛已结束，" .. string.sub(os.date("%X", GameConstant.matchStatus.taoTaiStartTime), 0, 5) .. "系统将排名并确定晋级名单";
		MatchRoomScene_instance:showWaitStartOrRankView(str);
	end
	MatchRoomScene_instance:processLoginRoom();
end

function Seat.onClickedContinueBtnInMatch( self )
	-- 提前胡请求换桌
	local param = {};
	param.mid = PlayerManager.getInstance():myself().mid;
	SocketManager.getInstance():sendPack(CLIENT_COMMAND_REQ_LOGOUT, param);
	if 8 == GameConstant.matchStatus.matchStage then
		MatchRoomScene_instance:showWaitStartOrRankView("正在为您配桌");
	elseif 9 == GameConstant.matchStatus.matchStage then
		local str = "预赛已结束，" .. string.sub(os.date("%X", GameConstant.matchStatus.taoTaiStartTime), 0, 5) .. "系统将排名并确定晋级名单";
		MatchRoomScene_instance:showWaitStartOrRankView(str);
	end
end




function Seat:initCreateBtn( )
	-----left
	self._leftBtn = UICreator.createBtn( "Commonx/yellow_bg_wide_btn.png", 0,0)
	self.roomSceneRef.nodeOperation:addChild(self._leftBtn);
	self._leftBtn:setVisible(false)

	self._leftBtn._label = UICreator.createText( "", 0, -5, 0, 0, kAlignCenter, 36, 255, 255, 255)--
	self._leftBtn:addChild(self._leftBtn._label);
	self._leftBtn._label:setAlign(kAlignCenter);		
	----right
	self._rightBtn = UICreator.createBtn( "Commonx/green_big_wide_btn.png", 0,0)
	self.roomSceneRef.nodeOperation:addChild(self._rightBtn);
	self._rightBtn:setVisible(false)

	self._rightBtn._label = UICreator.createText( "", 0, -5, 0, 0, kAlignCenter, 36, 255, 255, 255)--
	self._rightBtn:addChild(self._rightBtn._label);
	self._rightBtn._label:setAlign(kAlignCenter);
end

function Seat:resetBtn( btn, file, posX, posY, str , visible )
	--assert(not btn)
	--btn:setFile(file or "")
	btn:setPos(self.x + (posX or 0), self.y + (posY or 0))
	btn._label:setText(str or "")
	btn:setVisible(visible)
end

function Seat:setBtnState( state )
	if not self._btnState then 
		self:initBtnConfig()
	end 

	---assert(not state  or type(state) ~= "number" or state < 0 or state > #self._btnState )
	local conf = self._btnState[state]
	local len  = #conf
	---assert(len ~= 2 and len ~= 4)
	
	if len == 2 then 
		self:resetBtn(self._leftBtn,
					  self._btnConfig.file[conf[1]],
					  self._btnConfig.posX[2],
					  self._btnConfig.posY,
					  conf[2],
					  true)
		self._rightBtn:setVisible(false)
	else 
		self:resetBtn(self._leftBtn,
					  self._btnConfig.file[conf[1]],
					  self._btnConfig.posX[1],
					  self._btnConfig.posY,
					  conf[3],
					  true)

		self:resetBtn(self._rightBtn,
					  self._btnConfig.file[conf[2]],
					  self._btnConfig.posX[3],
					  self._btnConfig.posY,
					  conf[4],
					  true)	
	end
end

