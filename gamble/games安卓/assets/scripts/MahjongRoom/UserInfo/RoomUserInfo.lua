--[[
	className    	     :  RoomUserInfo
	Description  	     :  房间内个人信息界面.
	last-modified-date   :  Dec. 6 2013
	create-time 	   	 :  Nov. 6 2013
	last-modified-author :  ClarkWu
	create-author        :  YifanHe
]]
local roomUserInfoLayout = require(ViewLuaPath.."roomUserInfoLayout");
local SingleImagePin_map = require("qnPlist/SingleImagePin")

RoomUserInfo = class(SCWindow);

--[[
	function name	   : RoomUserInfo.ctor
	description  	   : Construct a class.
	param 	 	 	   : self
						 _player    -- 点击的玩家信息
						 _root      -- 添加的节点
	last-modified-date : Dec. 6 2013
	create-time  	   : Nov. 6 2013
]]
function RoomUserInfo.ctor( self, _player, _root, inMatchRoom)
	DebugLog("RoomUserInfo ctor");
	self.start = os.clock() * 1000;
	self.root = _root;

	--self.cover:setFile(CreatingViewUsingData.commonData.blankBg.fileName, CreatingViewUsingData.commonData.bg.x,CreatingViewUsingData.commonData.bg.y);

	EventDispatcher.getInstance():register(SocketManager.s_phpMsg, self, self.onPhpMsgResponse);

	self.player = _player;
	self:searchFriendById();

	self.inMatchRoom = inMatchRoom or false;

	self.layout = SceneLoader.load(roomUserInfoLayout);
	self:addChild(self.layout);

	self:findViewById();


	self.propId = {};
	if GameConstant.isSingleGame then
		GameConstant.roomPropTab = {};
		GameConstant.roomPropTab[1] = 10;
		GameConstant.roomPropTab[2] = 10;
		GameConstant.roomPropTab[3] = 10;
		GameConstant.roomPropTab[4] = 10;
		GameConstant.roomPropTab[5] = 10;
	end
	DebugLog("RoomUserInfo.ctor")
	self:updateUserInfo(self.player);
	self.root:addChild(self);

	if RoomScene_instance and RoomScene_instance:isFreeMatchGame() then
		self.isFreeMatchGame = RoomScene_instance:isFreeMatchGame()
	else
		self.isFreeMatchGame = false
	end

    self.cover:setEventTouch(self , function ( self )
--        local common = require("libEffect.shaders.common")
--        common.removeEffect(self.addFriendBtn)
        self:hideWnd();
    end);
end


function RoomUserInfo.findViewById( self )
	self.bg = publ_getItemFromTree(self.layout, {"bg"});
	self:setWindowNode( self.bg );
	self:setCoverEnable( true );
	self:setAutoRemove( false );

	--获得节点信息
	self.headIcon       = publ_getItemFromTree(self.layout, {"bg","headEdge","headImg"});
	self.idText         = publ_getItemFromTree(self.layout, {"bg","id"});
	self.genderIcon     = publ_getItemFromTree(self.layout, {"bg","genderIcon"});
	self.nameText       = publ_getItemFromTree(self.layout, {"bg","nameText"});
	self.levelText      = publ_getItemFromTree(self.layout, {"bg","level"});
	self.moneyText      = publ_getItemFromTree(self.layout, {"bg","money"});
	self.gameInfoText   = publ_getItemFromTree(self.layout, {"bg","gameInfo"});
	self.winRateText    = publ_getItemFromTree(self.layout, {"bg","winRate"});
	self.kickOutBtn     = publ_getItemFromTree(self.layout, {"bg","kickOutBtn"});
	self.kickOutBtnText = publ_getItemFromTree(self.layout, {"bg","kickOutBtn", "text"});
	self.addFriendBtn   = publ_getItemFromTree(self.layout, {"bg","addFriendBtn"});
	self.reportBtn   	= publ_getItemFromTree(self.layout, {"bg","reportBtn"});
	self.vipImg         = publ_getItemFromTree(self.layout, {"bg","vipImg"});
	self.favourText     = publ_getItemFromTree(self.layout, {"bg","favourCount"});
	self.charmText      = publ_getItemFromTree(self.layout, {"bg","charmValueBg", "charmValue"});
	self.charmLvImg     = publ_getItemFromTree(self.layout, {"bg","charmLvImg"});
	self.favourImg      = publ_getItemFromTree(self.layout, {"bg","favourBtn", "favour"});
	self.favourBtn      = publ_getItemFromTree(self.layout, {"bg","favourBtn"});
	self.favourBtn:setType(Button.Gray_Type)
	self.favourStr      = publ_getItemFromTree(self.layout, {"bg","favourBtn", "text"});

	self.propBtn1       = publ_getItemFromTree(self.layout, {"bg", "props", "prop1"});
	self.propBtn2       = publ_getItemFromTree(self.layout, {"bg", "props", "prop2"});
	self.propBtn3       = publ_getItemFromTree(self.layout, {"bg", "props", "prop3"});
	self.propBtn4       = publ_getItemFromTree(self.layout, {"bg", "props", "prop4"});
	self.propBtn5       = publ_getItemFromTree(self.layout, {"bg", "props", "prop5"});

	self.popImg         = publ_getItemFromTree(self.layout, {"cover"});
	self.reportMenu     = publ_getItemFromTree(self.layout, {"cover","pop_img"});



    self.popImg:setVisible(false);
	self.popImg:setEventTouch(self , function ( self, finger_action, x, y, drawing_id_first, drawing_id_current )
		self.popImg:setVisible(false);
	end);

	publ_getItemFromTree(self.layout, {"cover", "pop_img", "ffmb"}):setOnClick(self,self.onClickFFMB);
	publ_getItemFromTree(self.layout, {"cover", "pop_img", "sqtx"}):setOnClick(self,self.onClickSQTX);
	publ_getItemFromTree(self.layout, {"cover", "pop_img", "lhzb"}):setOnClick(self,self.onClickLHZB);

	self.propBtn1:setOnClick(self, self.onClickPropBtn1);
	self.propBtn2:setOnClick(self, self.onClickPropBtn2);
	self.propBtn3:setOnClick(self, self.onClickPropBtn3);
	self.propBtn4:setOnClick(self, self.onClickPropBtn4);
	self.propBtn5:setOnClick(self, self.onClickPropBtn5);

	if PlatformConfig.platformWDJ == GameConstant.platformType or
	   PlatformConfig.platformWDJNet == GameConstant.platformType then
        self.propBtn1:setFile("Login/wdj/Hall/popinfo/prop_bg.png");
        self.propBtn2:setFile("Login/wdj/Hall/popinfo/prop_bg.png");
        self.propBtn3:setFile("Login/wdj/Hall/popinfo/prop_bg.png");
        self.propBtn4:setFile("Login/wdj/Hall/popinfo/prop_bg.png");
        self.propBtn5:setFile("Login/wdj/Hall/popinfo/prop_bg.png");
        self.bg:setFile("Login/wdj/Hall/popinfo/window_bg_big.png");
    end

	-- self:showLongClickTips();

	self.propBtn1:setOnLongClick( self, function( self )
		self:commonClick(1);
	end);

	self.propBtn2:setOnLongClick( self, function( self )
		self:commonClick(2);
	end);

	self.propBtn3:setOnLongClick( self, function( self )
		self:commonClick(3);
	end);

	self.propBtn4:setOnLongClick( self, function( self )
		self:commonClick(4);
	end);

	self.propBtn5:setOnLongClick( self, function( self )
		self:commonClick(5);
	end);

	self.addFriendBtn:setOnClick(self,self.onClickAddFriendBtn);
	self.kickOutBtn:setOnClick(self , self.onClickKickOutBtn);
	self.reportBtn:setOnClick(self, self.onClickReportBtn);

	self.favourBtn:setOnClick(self , function( self )
		if not self.favoured then
			local param = {};
			param.a_uid = PlayerManager.getInstance():myself().mid;
			param.p_id  = 0;
			param.count = 1;
			param.b_uid = self.player.mid;
			SocketManager.getInstance():sendPack( SERVERGB_BROADCAST_USEPROP, param );
			self:hide();
		end
	end);

	self.buttonsPos = {{},{},{}};
	self.buttonsPos[1].x,self.buttonsPos[1].y = self.addFriendBtn:getPos();
	self.buttonsPos[2].x,self.buttonsPos[2].y = self.kickOutBtn:getPos();
	self.buttonsPos[3].x,self.buttonsPos[3].y = self.reportBtn:getPos();

	self.reportMenuPos = {};
	self.reportMenuPos.x,self.reportMenuPos.y = self.reportMenu:getPos();

end

function RoomUserInfo.onClickReportBtn( self )
	if  self.popImg and  not self.popImg:getVisible() then
		self.popImg:setVisible(true);
	end
end

function RoomUserInfo.showLongClickTips( self )
	if not GameConstant.isSingleGame and not self.isFreeMatchGame then
		local isShow, which = self:showLongCLickTipAndWhich();
		if isShow and not self.player.isMyself then
			local morePropTipsText = UICreator.createText("长按有惊喜", 20, 30, 0, 0, kAlignCenter, 22, 204, 93, 8);
			self.morePropTipsImg = UICreator.createImg( "Room/userInfo/morePropTips.png" );
			self.morePropTipsImg:addChild( morePropTipsText );

			local w,h = self.morePropTipsImg:getSize();
			local w1,h1 = self.propBtn1:getSize();
			self.morePropTipsImg:setPos( -( w-w1 )/2 , -h+10 );

			local btn;
			if which == 1 then
				btn = self.propBtn1;
			elseif which == 2 then
				btn = self.propBtn2;
			elseif which == 3 then
				btn = self.propBtn3;
			elseif which == 4 then
				btn = self.propBtn4;
			elseif which == 5 then
				btn = self.propBtn5;
			end

			btn:addChild( self.morePropTipsImg );
		end
	end
end

function RoomUserInfo.showLongCLickTipAndWhich( self )
	local num = math.random(1, 10);
	return num == 1, math.random(1,5);
end

--[[点击的公用方法
	currentBtn 表示当前点击的哪个道具
]]
function RoomUserInfo.commonClick( self, currentBtn )
	if not GameConstant.isSingleGame and not self.player.isMyself and not self.isFreeMatchGame then
		if not self.propId[currentBtn] then
			return
		end
		require("MahjongRoom/UserInfo/RoomBuyPropWnd");
		self.roomBuypRPwnd = new (RoomBuyPropWnd, self.propId[currentBtn], self.player, self, self.m_propCanUseMoney );
		self.roomBuypRPwnd:setOnWindowHideListener( self, function( self )
			self.roomBuypRPwnd = nil;
		end);
		self.currentBuyNum = 10; --默认10个
		self.currentBtn = currentBtn;

		--购买
		self.roomBuypRPwnd:setConfirmCallBack(self, function( self )
			self:useProp(self.currentBtn, self.roomBuypRPwnd.count);
		end);

		self.roomBuypRPwnd:showWnd();
	end
end

function RoomUserInfo.setPropCanUseMoney( self, money )
	self.m_propCanUseMoney = money;
	self:showLongClickTips();
	if self.roomBuypRPwnd then
		self.roomBuypRPwnd:setFreeMoney( self.m_propCanUseMoney );
	end
	log( "RoomUserInfo.setPropCanUseMoney = "..self.m_propCanUseMoney );
end

function RoomUserInfo.setViewEmptyStatus( self )
	DebugLog("RoomUserInfo.setViewEmptyStatus")
	local isMyself,isMyFriend,isNotVip,remainTime
	-- READY TODO : 将两个表合并成一个
	if GameConstant.roomPropTab then
		DebugLog("GameConstant.roomPropTab")
		mahjongPrint(GameConstant.roomPropTab)
		local count = 1;
		for i = 1 , 11 do
			if GameConstant.roomPropTab[i] then
				local img = publ_getItemFromTree(self.layout, {"bg", "props", "prop"..count, "img"});
				self.propId[count] = i;
				local moneyText = publ_getItemFromTree(self.layout, {"bg", "props", "prop"..count, "money"});
				if GameConstant.roomPropMap[i] then
					img:setFile(GameConstant.roomPropMap[i]);
					moneyText:setText(GameConstant.roomPropTab[i] or "0");
					if count < 5 then
						count = count + 1;
					end
				end
			end
		end
	end
    --修改透明度，和ios保持一致0.6-1
    local util_fun = function (btn, enable)
        btn:setEnable(enable);
        btn:setTransparency(enable == true and 1.0 or 0.6);
    end

	DebugLog("GameConstant.roomPropTab end")
    util_fun(self.propBtn1, not self.player.isMyself);
    util_fun(self.propBtn2, not self.player.isMyself);
    util_fun(self.propBtn3, not self.player.isMyself);
    util_fun(self.propBtn4, not self.player.isMyself);
    util_fun(self.propBtn5, not self.player.isMyself);

	if self.player.isMyself then
		--自己不能使用添加好友和踢出
		isMyself = true;
	elseif PlayerManager.getInstance():myself().vipLevel <= 0 then
		isNotVip = true;
	end

	if not GameConstant.isSingleGame then
		FriendDataManager.getInstance():addListener(self,self.onCallBackFunc);
		if  FriendDataManager.getInstance():selectFriendByMid(tostring(self.player.mid)) then
			isMyFriend = true;
		else
			local time = os.time();
			local coord = CreatingViewUsingData.roomUserInfoView.addFriendAnim;
			if GameConstant.addTime[self.player.mid .. ""] and GameConstant.addTime[self.player.mid .. ""].time then
				local costTime = time - GameConstant.addTime[self.player.mid .. ""].time;

				remainTime = coord.time - costTime;
				if remainTime < 0 or remainTime > coord.time then
					remainTime = 0;
				end
				DebugLog("remainTime : "..remainTime);
			end
		end
	end

	self:setButtonsState(isMyself,isMyFriend,isNotVip,remainTime);
end


function RoomUserInfo.setButtonsState(self, isMyself,isMyFriend,isNotVip,remainTime)
	--init state
	self.addFriendBtn:setVisible(true)
	self.kickOutBtn:setVisible(true)
	self.reportBtn:setVisible(true)

	if GameConstant.isSingleGame or isMyself then --单机场或者自己 (添加好友,踢出,举报均不可见)
		self.addFriendBtn:setVisible(false)
		self.kickOutBtn:setVisible(false)
		self.reportBtn:setVisible(false)
	elseif self.inMatchRoom then  --比赛场 (无踢出按钮)
		self.kickOutBtn:setVisible(false)
		if isMyFriend then --已经是好友 ,不显示添加好友
			self.addFriendBtn:setVisible(false)
		end
	else --
		if isMyFriend then --已经是好友 ,不显示添加好友
			self.addFriendBtn:setVisible(false)
		end
	end
	---------
	local startIndex = 1;
	if self.addFriendBtn:getVisible() then
		self.addFriendBtn:setPos(self.buttonsPos[startIndex].x,self.buttonsPos[startIndex].y)
		startIndex = startIndex+1

		if remainTime == nil or remainTime <= 0 then
            DebugLog("remainTime == nil or remainTime <= 0");
			self.addFriendBtn:setIsGray(false);
			self.addFriendBtn:setPickable(true);
			GameConstant.addTime[self.player.mid .. ""] = {};
		elseif  remainTime and remainTime > 0 then
            DebugLog("remainTime == nil or remainTime <= 0");
			self.addFriendBtn:setIsGray(true);
			self.addFriendBtn:setPickable(false);
			if not self.addFriendBtn:checkAddProp(0) then
		        self.addFriendBtn:removeProp(0);
	        end
			local anim = self.addFriendBtn:addPropTranslate( 0 , kAnimNormal , remainTime * 1000 , 0 , 0 , 0 , 0 ,0);
		  	anim:setEvent(self,self.changeEnabled);
		end
		--
	end
	if self.kickOutBtn:getVisible() then
		self.kickOutBtn:setPos(self.buttonsPos[startIndex].x,self.buttonsPos[startIndex].y)
		startIndex = startIndex+1
		--变灰图标且增加角标
		if isNotVip then
	        self.kickOutBtn:setVisible(true);
			self.kickOutBtn:setIsGray(true);
			self.kickOutBtn:setPickable(false);
			self.kickOutVipImg = UICreator.createImg("Room/userInfo/vipTag.png", 150, -15);
			self.kickOutBtn:addChild(self.kickOutVipImg);
		end
	end
	if self.reportBtn:getVisible() then
		self.reportBtn:setPos(self.buttonsPos[startIndex].x,self.buttonsPos[startIndex].y)
	end

	if FriendMatchRoomScene_instance then
		self.kickOutBtn:setIsGray(true);
		self.kickOutBtn:setPickable(false);
	end

	local x,y = self.reportBtn:getPos()
	y = self.buttonsPos[3].y - y
	self.reportMenu:setPos( self.reportMenuPos.x,self.reportMenuPos.y - y )
end

function RoomUserInfo.searchFriendById(self)
	--获取详细信息
	if not GameConstant.isSingleGame then

		FriendDataManager.getInstance():QueryUserInfo(PHP_CMD_QUERY_USER_INFO,{self.player.mid},{"money","charms", "likes", "like_status", "charms_level"})
	end
end

function RoomUserInfo.onWindowShow( self )

    self:setViewEmptyStatus();
	self:setPlayerLikeStatus();
	self:searchFriendById();
end



--[[
	function name	   : RoomUserInfo.dtor
	description  	   : Destruct a class.
	param 	 	 	   : self
	last-modified-date : Nov. 6 2013
	create-time  	   : Nov. 6 2013
]]
function RoomUserInfo.dtor( self )
	DebugLog("RoomUserInfo dtor");
	self.isPlaying = false;
	EventDispatcher.getInstance():unregister(SocketManager.s_phpMsg, self, self.onPhpMsgResponse);
	if not GameConstant.isSingleGame then
		FriendDataManager.getInstance():removeListener(self, self.onCallBackFunc);
	end
	self:removeAllChildren();
end

--[[
	function name	   : RoomUserInfo.hide
	description  	   : To Destruct a class.
	param 	 	 	   : self
	last-modified-date : Nov. 6 2013
	create-time  	   : Nov. 6 2013
]]
function RoomUserInfo.hide( self )
	self.popImg:setVisible(false)

	self:hideWnd();
	-- self.morePropTipsImg:removeFromSuper();
	-- self.morePropTipsImg = nil;
end

function RoomUserInfo.hideWnd( self )
	log( "RoomUserInfo.hideWnd" );

	self.popImg:setVisible(false)
	self.super.hideWnd( self );

	if self.morePropTipsImg then
		self.morePropTipsImg:removeFromSuper();
		self.morePropTipsImg = nil;
	end
end

--[[
	function name	   : RoomUserInfo.updateUserInfo
	description  	   : 更新用户界面信息方法.
	param 	 	 	   : self
	last-modified-date : Nov. 6 2013
	create-time  	   : Nov. 6 2013
]]
function RoomUserInfo.updateUserInfo( self , _player )
	self.player = _player;
	DebugLog("RoomUserInfo.updateUserInfo")
--	self:setViewEmptyStatus();
	self:setPlayerLikeStatus();


	if self.player.sex == kNumOne or self.player.sex == kNumTwo then
		if publ_isFileExsit_lua(self.player.localIconDir) then
			self.headIcon:setFile(self.player.localIconDir);
		else
			self.headIcon:setFile(CreatingViewUsingData.commonData.girlPicLocate);
		end
		self.genderIcon:setFile("Commonx/female.png");
	else
		if publ_isFileExsit_lua(self.player.localIconDir) then
			self.headIcon:setFile(self.player.localIconDir);
		else
			self.headIcon:setFile(CreatingViewUsingData.commonData.boyPicLocate);
		end
		self.genderIcon:setFile("Commonx/male.png");
	end

	--单机游戏电脑AI头像
	if GameConstant.isSingleGame then
		if self.player.mid ~= 1 then
			local fileStr = "";
			local nick = GameString.convert2Platform(self.player.nickName);
			if nick == GameString.convert2Platform("大叔") then
				fileStr = fileStr .. "touxiang1";
			elseif nick == GameString.convert2Platform("男神") then
				fileStr = fileStr .. "touxiang2";
			elseif nick == GameString.convert2Platform("萌妹纸") then
				fileStr = fileStr .. "touxiang3";
			elseif nick == GameString.convert2Platform("邻家MM") then
				fileStr = fileStr .. "touxiang4";
			else
				fileStr = fileStr .. "touxiang1";
			end
			fileStr = fileStr .. ".png";
			self.headIcon:setFile(SingleImagePin_map[fileStr]);
		end
	end

	--vip标识
	if self.player.vipLevel <= 0 then
		self.vipImg:setVisible(false);
	else
		self.vipImg:setVisible(true);
		local vipLevel = self.player.vipLevel
		if vipLevel >= 10 then
			vipLevel = 10
		end
		local hall_user_infoPin_map = require("qnPlist/hall_user_infoPin")

		self.vipImg:setFile( hall_user_infoPin_map["VIP"..vipLevel..".png"] );
	end

	self.idText:setText("ID:"..self.player.mid);

	local nameStr = "";
	if FriendDataManager.getInstance():getFriendNameById(tonumber(self.player.mid)) then
		nameStr = FriendDataManager.getInstance():getFriendNameById(tonumber(self.player.mid));
	else
		nameStr = self.player.nickName;
	end
	self.nameText:setText(stringFormatWithString(nameStr, 10, true));

	self.levelText:setText("等级:"..self.player.level);

	if not FriendMatchRoomScene_instance then
		self.moneyText:setText("金币:"..trunNumberIntoThreeOneFormWithInt(self.player.money));
	else
		self.moneyText:setText("金币:");
	end
	--local moneyStr = self.moneyText:getText();

	--local coord = CreatingViewUsingData.roomUserInfoView.coinText;
	--local moneyTextCopy = UICreator.createText( moneyStr, coord.x,coord.y,coord.w,coord.h,coord.align,coord.size,coord.r,coord.g,coord.b);

	coord = CreatingViewUsingData.roomUserInfoView.winLostText;
	local gameInfoStr = self.player.wintimes .. coord.win ..
					    self.player.losetimes .. coord.lost ..
					    self.player.drawtimes .. coord.ping;
	self.gameInfoText:setText("战绩:"..gameInfoStr);
	if self.player.wintimes ~= kNumZero then
		local rate = self.player.wintimes/(self.player.losetimes + self.player.drawtimes + self.player.wintimes)*kNumHundred;
		local rateInteger = math.floor(rate);  --战绩整数部分
		local rateDecimal = math.floor(rate*kNumHundred) - (rateInteger*kNumHundred);  --战绩两位小数
		rateDecimal = tostring(rateDecimal);
		if #rateDecimal == kNumOne then
			rateDecimal = kNumStrZero..rateDecimal;
		end
		self.winRateText:setText("胜率:"..rateInteger..kPoint..rateDecimal..kPercent);
	else
		self.winRateText:setText("胜率:"..kNumZero .. kPercent);
	end

	self:showWnd()
end

-- 设置个人信息中的魅力和赞
function RoomUserInfo.setPlayerLikeStatus(self)
	if  self.playing then
		return;
	end
	if self.player.likesData then
		--for k, v in pairs(self.player.likesData) do
			self.favourText:setText(tostring(self.player.likesData.likes));
			self.charmText:setText(tostring(self.player.likesData.charms));
			self.charmLvImg:setFile("Hall/popinfo/charmLv" .. (self.player.likesData.charms_level or 0) .. ".png");

			if FriendMatchRoomScene_instance then --好友比赛用拉取的金币
				self.moneyText:setText("金币:"..trunNumberIntoThreeOneFormWithInt(self.player.likesData.money or ""));
			end

			if tonumber(self.player.likesData.like_status) == 1 then
				self.favoured = true;
				self.favourImg:setFile("Hall/popinfo/zan2.png");
				self.favourStr:setText("已赞");
			else
				self.favoured = false;
				self.favourImg:setFile("Hall/popinfo/zan1.png");
				self.favourStr:setText("赞");
			end
		--end
	else
		self.favourText:setText("");
		self.charmText:setText("");
		if FriendMatchRoomScene_instance then --好友比赛用拉取的金币
			self.moneyText:setText("金币:")
		end
		self.charmLvImg:setFile("Hall/popinfo/charmLv" .. (0) .. ".png");
		self.favoured = false;
		self.favourImg:setFile("Hall/popinfo/zan1.png");
		self.favourStr:setText("");
	end
end

function RoomUserInfo.reportPlayerCallback( self, isSuccess, data, jsonData )
	if not isSuccess or not data then
		Banner.getInstance():showMsg("网络不稳定...")
		return;
	end
	if tonumber(data.status) == 1 then
		--举报成功
	end
	Banner.getInstance():showMsg( data.msg )
end

function RoomUserInfo.searchFriendByIdCallback(self, data)
	if data and type(data) == "table" and #data == 1 then
		local v = data[1]
		local mid = tonumber(v.mid);
		local player = PlayerManager.getInstance():getPlayerById(mid);
		if player then
			player.likesData = v;
			if mid == self.player.mid then
				DebugLog("是当前id");
				self:setPlayerLikeStatus();
			end
		end

	end
end

----------------------------------------------------------回调函数-------------------------------------------------------------
--[[
	function name	   : RoomUserInfo.onCallBackFunc
	description  	   : PHP或者socket请求返回.根据行为指令调用不同方法.
	param 	 	 	   : self
						 actionType  -- 行为指令
						 actionParam -- 行为参数
	last-modified-date : Dec. 10 2013
	create-time  	   : Dec. 4 2013
]]
function RoomUserInfo.onCallBackFunc(self,actionType,actionParam)
	if actionType == kFriendAddSuccessBySocket and tostring(actionParam) == tostring(self.player.mid) then
		self:addFriendSuccess();
	elseif kFriendSearchByPHP == actionType then
		self:searchFriendByIdCallback(actionParam);
	end
end

--[[
	function name	   : RoomUserInfo.addFriendSuccess
	description  	   : 响应增加好友成功命令
	param 	 	 	   : self
	last-modified-date : Dec. 10 2013
	create-time  	   : Dec. 4 2013
]]
function RoomUserInfo.addFriendSuccess(self)
	--self:setAddFriendBtnVisibleState(false);
	local isMyself,isMyFriend,isNotVip,remainTime

	if self.player.isMyself then
		isMyself = true;
	end

	if PlayerManager.getInstance():myself().vipLevel <= 0 then
		isNotVip = true;
	end
	self:setButtonsState(isMyself,true,isNotVip,0);
end

----------------------------------------------------------按键监听-------------------------------------------------------------
--[[
	function name	   : RoomUserInfo.onClickAddFriendBtn
	description  	   : 加好友按键监听.
	param 	 	 	   : self
	last-modified-date : Dec. 6  2013
	create-time  	   : Nov. 11 2013
]]
function RoomUserInfo.onClickAddFriendBtn(self)
	umengStatics_lua(kUmengRoomAddFriend);

	self.addFriendBtn:setPickable(false);
	self.addFriendBtn:setIsGray(true);

	GameConstant.addTime[self.player.mid .. ""] = {};
	GameConstant.addTime[self.player.mid .. ""].time = os.time();

	-- TODO
	FriendDataManager.getInstance():addFriendSocket(self.player.mid);
	Banner.getInstance():showMsg(PromptMessage.sendMessageSuccess);

	if self.addFriendClickFunc and self.addFriendClickObj then
		self.addFriendClickFunc( self.addFriendClickObj );
	end

	self:hideWnd();
end

function RoomUserInfo:setOnclickAddFriendBtnListener( obj, func )
	self.addFriendClickObj = obj;
	self.addFriendClickFunc = func;
end

function RoomUserInfo.onClickKickOutBtn(self)
	umengStatics_lua(kUmengRoomKickOutPlayer);
	if PlayerManager.getInstance():myself().vipLevel <= 0 then
		Banner.getInstance():showMsg("充值成为VIP使用踢人特权");
		return;
	end
	local param = {};
	param.mid = self.player.mid;
	param.msg = "";
	SocketSender.getInstance():send( CLIENT_COMMAND_VIP_KICK_PLAYER, param);

	self:hide();
end


function RoomUserInfo.onClickLHZB( self )
	-- body
	self:requestReportPlayer(3)
	self.popImg:setVisible(false);

end

function RoomUserInfo.onClickSQTX( self )
	self:requestReportPlayer(1)
	self.popImg:setVisible(false);
end

function RoomUserInfo.onClickFFMB( self )
	self:requestReportPlayer(2)
	self.popImg:setVisible(false);
end

function RoomUserInfo.requestReportPlayer( self,type )
	local param_data = {};
	param_data.tmid 	= self.player.mid
	param_data.mid 		= PlayerManager.getInstance():myself().mid;
	param_data.version  = GameConstant.Version;
	--param_data.api 		= GameConstant.api
	param_data.type     = type
	SocketManager.getInstance():sendPack( PHP_CMD_REQUEST_REPORT, param_data);
end

function RoomUserInfo.onClickPropBtn1( self )
	self:useProp(1);
end

function RoomUserInfo.onClickPropBtn2( self )
	self:useProp(2);
end

function RoomUserInfo.onClickPropBtn3( self )
	self:useProp(3);
end

function RoomUserInfo.onClickPropBtn4( self )
	self:useProp(4);
end

function RoomUserInfo.onClickPropBtn5( self )
	self:useProp(5);
end

function RoomUserInfo.useProp( self, num, propCount )

	if not self.propId[num] then
		Banner.getInstance():showMsg("非常抱歉，没有您选择的道具。");
		return;
	end
    DebugLog("RoomUserInfo.useProp 道具是否下载:"..tostring(publ_IsResDownLoaded( GameConstant.DOWNLOAD_RES_TYPE_FRIEND_ANIM )));
	local currentPropCount = propCount or 1;
	--如果平台是小包，就去下载资源，然后再使用
	-- 判断资源是否存在，不存在则下载资源
	if  not isPlatform_Win32() and not publ_IsResDownLoaded( GameConstant.DOWNLOAD_RES_TYPE_FRIEND_ANIM ) and not (GameConstant.iosDeviceType>0) then
		--and GameConstant.platformType == PlatformConfig.platformGuangDianTong then
        Banner.getInstance():showMsg("下载中，您可以先进行游戏");
		if GameConstant.isDownloading then
			Banner.getInstance():showMsg("下载中，您可以先进行游戏");
			return;
		end
		GlobalDataManager.getInstance():downloadRes(GameConstant.DOWNLOAD_RES_TYPE_FRIEND_ANIM, true);
	else
		local curTime = os.time();
		if curTime < GameConstant.propColdDownTime then
			GameConstant.propColdDownTime = curTime;
		end
		if curTime - GameConstant.propColdDownTime < GameConstant.propInterval then
			Banner.getInstance():showMsg("请休息片刻再使用吧。");
			return;
		end
		local param = {};
		param.a_uid = PlayerManager.getInstance():myself().mid;
		param.p_id = self.propId[num];
		param.count = currentPropCount;--currentPropCount
		param.b_uid = self.player.mid;
		SocketManager.getInstance():sendPack( SERVERGB_BROADCAST_USEPROP, param );

		GameConstant.propColdDownTime = curTime;
	end
	self:hide();
end

--[[
	function name	   : RoomUserInfo.changeEnabled
	description  	   : 房间内加好友按键动画.(10秒压下效果)
	param 	 	 	   : self
	last-modified-date : Dec. 6  2013
	create-time  	   : Nov. 11 2013
]]
function RoomUserInfo.changeEnabled(self)
    DebugLog("RoomUserInfo.changeEnabled..");
	self.addFriendBtn:setIsGray(false);
	self.addFriendBtn:setPickable(true);
	self.addFriendBtn:removeProp(0);
	GameConstant.addTime[self.player.mid .. ""] = {};
end


RoomUserInfo.onPhpMsgResponse = function ( self, param, cmd, isSuccess,... )
	if self.httpRequestsCallBackFuncMap[cmd] then
		self.httpRequestsCallBackFuncMap[cmd](self,isSuccess,param,...)
	end
end

RoomUserInfo.httpRequestsCallBackFuncMap =
{
	[PHP_CMD_REQUEST_REPORT] 	 =  RoomUserInfo.reportPlayerCallback,
};
