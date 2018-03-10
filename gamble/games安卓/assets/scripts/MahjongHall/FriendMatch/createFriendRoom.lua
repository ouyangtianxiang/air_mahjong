local createFriendMatchRoom = require(ViewLuaPath.."createFriendMatchRoom");
require("ui/radioButton");
 require("MahjongHall/FriendMatch/IconItem")
 require("MahjongConstant/GameDefine");
CreateFriendRoom = class(SCWindow);

function CreateFriendRoom:ctor( config )
	DebugLog("CreateFriendRoom:ctor")
	self._config = config
    self.m_ignoreDq = false;
    --拉取配置
    GlobalDataManager.getInstance():requestFriendMatchConfig()

	self:initLoadView()


	--FriendDataManager.getInstance():addListener(self,self.onCallBackFunc);
end

function CreateFriendRoom:dtor()
	DebugLog("CreateFriendRoom:dtor")
	self.onlineFriendsInfo = nil 

	--FriendDataManager.getInstance():removeListener(self,self.onCallBackFunc);
end

-- 遮罩点击消息响应函数
function CreateFriendRoom.onCoverClick( self )
	DebugLog("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
end

function CreateFriendRoom:initLoadView()

	self._layout = SceneLoader.load(createFriendMatchRoom);
	self:addChild(self._layout)

    --记录每一行的最后一个节点的位置
    self.m_nodeMaxPos = 0;
    self.m_nodePosTotal = 600;
    self.m_nodeLastPos = self.m_nodePosTotal - self.m_nodePosTotal / 4;
	-- RadioButton.s_defaultImages = origin
	local winBg = publ_getItemFromTree(self._layout, {"bg"});
	self:setWindowNode( winBg );
	self:setCoverEnable( true );-- 允许点击cover

	publ_getItemFromTree(self._layout,{"bg","closeBtn"}):setOnClick(self,function ( self )
		self:hideWnd()
	end)

	publ_getItemFromTree(self._layout,{"bg","createBtn"}):setOnClick(self,function ( self )
		self:requestCreateRoom()
	end)

	--self.m_listView = publ_getItemFromTree(self._layout,{"bg","row4","ListView1"})

	---------------------
	self.row1               = publ_getItemFromTree(self._layout,{"bg","row1"})
	self.row2               = publ_getItemFromTree(self._layout,{"bg","row2"})
	self.row3               = publ_getItemFromTree(self._layout,{"bg","row3"})
	self.row4               = publ_getItemFromTree(self._layout,{"bg","row4"})

	self.roundRadioGroup    = publ_getItemFromTree(self.row1,{"RadioButtonGroup1"})
	self.playTypeRadioGroup = publ_getItemFromTree(self.row2,{"RadioButtonGroup1"})
	self.diRadioGroup       = publ_getItemFromTree(self.row3,{"RadioButtonGroup1"})
	self.mostRadioGroup     = publ_getItemFromTree(self.row4,{"RadioButtonGroup1"})

	self.checkView          = publ_getItemFromTree(self.row2,{"View1"})
	self.playTypeCheckGroup = publ_getItemFromTree(self.row2,{"View1","CheckBoxGroup1"})

	self.costText           = publ_getItemFromTree(self._layout,{"bg","row5","rightText"})

	self.roundRadioGroup:setOnChange(self,self.selectRoundCallback)
	self.playTypeRadioGroup:setOnChange(self,self.selectPlayTypeCallback)
	self.diRadioGroup:setOnChange(self,self.selectDiCallback)
	self.mostRadioGroup:setOnChange(self,self.selectMostCallback)

	self.playTypeCheckGroup:setOnChange(self,self.selectWanfaCallback)

	self:initControlsFromConfig()

	self:defaultSelected()
	--self:createFriendItems()
end



function CreateFriendRoom:initControlsFromConfig( )
	if not self._config then
		DebugLog("not config data!")
	end  
	mahjongPrint(self._config)

	for i=1,#self._config.roundsArr do
		local str = self._config.roundsArr[i].roundnum .. "局"
        local bLast = false;
        if i == 2 then
            bLast = false;
        else
            bLast = (i == #self._config.roundsArr)
        end
		self:addRadioItem(self.row1, self.roundRadioGroup, i, self:getWidthByCount(#self._config.roundsArr), str, bLast)
	end

	local textMap = {
		["xl"]  = "血流成河",--成河
		["xz"]  = "血战到底",--到底
		["lfp"] = "两房牌",
		["dq"]  = "定缺",
		["hsz"] = "换三张",
	}

	for i=1,#self._config.playTypes do
		local key = self._config.playTypes[i]
		local str =  textMap[key] or ""
        local bLast = false;
        if i == 2 or i == 1 then
            bLast = false;
        else
            bLast = (i == #self._config.playTypes)
        end
		self:addRadioItem(self.row2, self.playTypeRadioGroup, i, self:getWidthByCount(#self._config.playTypes), str, bLast)
	end

	for i=1,#self._config.checkBoxPlayTypes do
		local key = self._config.checkBoxPlayTypes[i]
		local str =  textMap[key] or ""
        local bLast = false;
        if i == 2 or i == 1 then
            bLast = false;
        else
            bLast = (i == #self._config.checkBoxPlayTypes)
        end
		self:addCheckboxItem(self.checkView, self.playTypeCheckGroup, i, self:getWidthByCount(#self._config.checkBoxPlayTypes), str, key, bLast)
	end	

	for i=1,#self._config.dis do
		local str = self._config.dis[i] .. "分"
        local bLast = false;
        if i == 2 or i == 1  then
            bLast = false;
        else
            bLast = (i == #self._config.dis)
        end
		self:addRadioItem(self.row3, self.diRadioGroup, i, self:getWidthByCount(#self._config.dis), str, bLast)
	end	

	for i=1,#self._config.mostTypes do 
		local str = self._config.mostTypes[i] .. "番"
		if self._config.mostTypes[i] == 0 then 
			str   = "不封顶"
		end 

        local bLast = false;
        if i == 2 or i == 1 then
            bLast = false;
        else
            bLast = (i == #self._config.mostTypes)
        end
		self:addRadioItem(self.row4, self.mostRadioGroup, i, self:getWidthByCount(#self._config.mostTypes), str, bLast)
	end 
end



function CreateFriendRoom:getWidthByCount( num, bLast )

    local total = self.m_nodePosTotal;
    if num == 2 or num == 3 then
        ret = 225;
    else
        ret = self.m_nodePosTotal/4;
    end

    --ret = (num == 3 or num == 2) and 225 or total/num;
    DebugLog("getWidthByCount:"..ret);
    return ret;
end

function CreateFriendRoom:addRadioItem( labelParent, radioParent, atIndex ,itemWidth, str, bLast )
	if not labelParent or not radioParent or not atIndex or not itemWidth or not str then 
		DebugLog("args error!")
		return 
	end

    local lastpos = bLast == true and self.m_nodeLastPos or nil;

	local node = new(RadioButton,{"Commonx/c2.png","Commonx/c1.png"});
	node:setPos(lastpos or (atIndex - 1)*itemWidth , 0 );
	node:setAlign(kAlignLeft);
	radioParent:addButton(node)

	local startX,startY = radioParent:getPos()

	local text = UICreator.createText( str, 0, 0, 80,50, kAlignLeft ,30, 0x4b, 0x2b, 0x1c )
	text:setAlign(kAlignTopLeft)
	text:setPos((lastpos or (atIndex - 1)*itemWidth) + 50 + startX + 10, 0)
	labelParent:addChild(text)

end

function CreateFriendRoom:addCheckboxItem( labelParent, checkGroup, atIndex, itemWidth, str, tag, bLast)
	if not labelParent or not checkGroup or not atIndex or not itemWidth or not str then 
		DebugLog("args error!")
		return 
	end--CheckBox
    
    local lastpos = bLast == true and self.m_nodeLastPos or nil;

	local node = new(CheckBox,{"Commonx/checkbox_quare_normal.png","Commonx/checkbox_quare_selected.png"});
	node:setPos(2+(lastpos or (atIndex - 1)*itemWidth) , 0 );
	node:setAlign(kAlignLeft);
	checkGroup:addCheckBox(node)
	node.__checkTag = tag

	local text = UICreator.createText( str, 0, 0, 80,50, kAlignLeft ,30, 0x4b, 0x2b, 0x1c )
	text:setAlign(kAlignTopLeft)
	text:setPos((lastpos or (atIndex - 1)*itemWidth) + 50 + 10, 0)
	labelParent:addChild(text)
    node.t = text;	



    if tag == "dq" then
        node:setPickable(fals);
        node:setTransparency(0.6);
        text:setTransparency(0.6);
        --node:setChecked(true);
    end
    
     
    if tag == "hsz" then 
		self.hszText = text
	end 

end

--index start from 1
function CreateFriendRoom:selectRoundCallback(index, button)
	DebugLog("index:".. index)
	self.m_selectRoundIndex = index

	local descArr = self._config.roundsArr
	if descArr and descArr[index].coststr then 
		self.costText:setText(descArr[index].coststr)
	end 
end

function CreateFriendRoom:selectPlayTypeCallback(index, button)
	DebugLog("index:".. index)
	self.m_selectPlayTypeIndex = index


	--------
	if self.hszText and self.m_selectPlayTypeIndex > 0 and self.m_selectPlayTypeIndex <= #self._config.playTypes then 
		local curSelect = self._config.playTypes[self.m_selectPlayTypeIndex]
		if curSelect == "lfp" then
			self.hszText:setText("换两张")
		else 
			self.hszText:setText("换三张")
		end 
        local item = nil;
        local checkItems = self.playTypeCheckGroup.m_items
        for i=1,#checkItems do
			local itemTmp = checkItems[i]
			if itemTmp and itemTmp.__checkTag == "dq" then 
				item = itemTmp;
                break;
			end 
		end
        if item then
    	    item:setChecked(curSelect == "xz");
        end
        self.m_ignoreDq = not (curSelect == "xz");
	end 
end

function CreateFriendRoom:selectDiCallback(index, button)
	DebugLog("index:".. index)
	self.m_selectDiIndex = index
end

function CreateFriendRoom:selectMostCallback(index, button)
	DebugLog("index:".. index)
	self.m_selectMostIndex = index
end

function CreateFriendRoom:selectWanfaCallback( ... )
	-- body
end
--底分信息
function CreateFriendRoom:getCurSelectDi()
	if self.m_selectDiIndex > 0 and self.m_selectDiIndex <= #self._config.dis then 
		return self._config.dis[self.m_selectDiIndex]
	end 
end
--局数
function CreateFriendRoom:getCurSelectRoundNum()
	if self.m_selectRoundIndex > 0 and self.m_selectRoundIndex <= #self._config.roundsArr then 
		return self._config.roundsArr[self.m_selectRoundIndex].roundnum
	end 
end

function CreateFriendRoom:getCurSelectMost()
	if self.m_selectMostIndex > 0 and self.m_selectMostIndex <= #self._config.mostTypes then 
		return self._config.mostTypes[self.m_selectMostIndex]
	end 
end

function CreateFriendRoom:getCurSelectRoundMoney()
	local m,t = self._config:getMoneyByRound(self:getCurSelectRoundNum())
	return m,t
end
--玩法
function CreateFriendRoom:getCurSelectPlayType()
	-- body
	if self.m_selectPlayTypeIndex > 0 and self.m_selectPlayTypeIndex <= #self._config.playTypes then 
		local result = 0
		--单选 radiobox
		local curSelect = self._config.playTypes[self.m_selectPlayTypeIndex]--bit.bor(m, n) -- bitwise or (m | n)
		if curSelect == "xz" then 
			--result = bit.bor(result,0x0000)--0
		elseif curSelect == "xl" then 
			result = bit.bor(result,0x0002)
		elseif curSelect == "lfp" then
			result = bit.bor(result,0x0010)
		end 
		--复选项 checkbox
		local checkItems = self.playTypeCheckGroup.m_items
		for i=1,#checkItems do
			local item = checkItems[i]
			if item and item:isChecked() then 
				if self.m_ignoreDq == false and item.__checkTag == "dq" then 
					result = bit.bor(result,0x0001)
				elseif item.__checkTag == "hsz" then 
					result = bit.bor(result,0x0004)
				end 
			end 
		end

		return result
	end 

	return 0
end
--[[
function CreateFriendRoom:createFriendItems( data )
	self.m_listView:setDirection(kHorizontal)
	self.m_listView:setScrollBarWidth(0)

	self:updateAdapter(true)
end

function CreateFriendRoom:sortFriends( )
	-- body
	table.sort(self.onlineFriendsInfo, function ( a , b)

		return (a.isPhoneAdd == 1)
	end)
end

function CreateFriendRoom:createNoOnlineFriendText( )--UICreator.createText = function ( str, x, y, width,height, align ,fontSize, r, g, b )
	self.noFriendText = UICreator.createText("当前无在线好友",270,0,720,50,kAlignLeft,30, 0x4b, 0x2b, 0x1c)
	self.noFriendText:setAlign(kAlignTopLeft)
	self.row4:addChild(self.noFriendText)
end

function CreateFriendRoom:showNoOnlineFriendText( bShow )
	if not self.noFriendText then 
		self:createNoOnlineFriendText()
	end
	self.noFriendText:setVisible(bShow)
end

function CreateFriendRoom:updateAdapter( isInit )

	self.onlineFriendsInfo = FriendDataManager.getInstance():getOnlineFriends()
	if not self.onlineFriendsInfo or #self.onlineFriendsInfo == 0 then 
		self.m_adapter = nil 
		self.m_listView:setAdapter(nil)
		self:showNoOnlineFriendText(true)
		return 
	end 

	self:sortFriends()

	if isInit then 
		for i=1,#self.onlineFriendsInfo do
			self.onlineFriendsInfo[i]._isCheck =false
		end		
	end 

	if not self.m_adapter then 
		self.m_adapter = new(CacheAdapter, IconItem, self.onlineFriendsInfo)
		self.m_listView:setAdapter(self.m_adapter)
	else 
		self.m_adapter:changeData(self.onlineFriendsInfo)
	end 
	self:showNoOnlineFriendText(false)

end

function CreateFriendRoom:setInviteFriendsInfo( roundNum, wanfa )
	DebugLog("CreateFriendRoom:setInviteFriendsInfo")
	local params = {}
	params.friends = {}

	for i=1,#self.onlineFriendsInfo do
		if self.onlineFriendsInfo[i]._isCheck then 
			local item = {}
			item.name  = self.onlineFriendsInfo[i].mnick 
			item.mid   = tonumber(self.onlineFriendsInfo[i].mid)
			table.insert(params.friends, item)
		end 
	end

	if #params.friends <= 0 then 
		GlobalDataManager.getInstance():setInviteBattleInfo( nil )
		return nil 
	end 

	params.mid  = tonumber(PlayerManager.getInstance():myself().mid) 
	params.name = PlayerManager.getInstance():myself().nickName 
	params.fid  = 0 
	params.roundNum = roundNum
	params.wanfa    = wanfa
	params.cmd2 	= FRIEND_CMD_BATTLE_INVITE

	GlobalDataManager.getInstance():setInviteBattleInfo( params )
	mahjongPrint(params)
	--return params
	--
	--SocketManager.getInstance():sendPack(FRIEND_CMD_FORWARD, param);
end

CreateFriendRoom.onCallBackFunc = function (self, actionType, actionParam)
	DebugLog("CreateFriendRoom.onCallBackFunc............")
	local sid = tostring(actionParam)
    if kFriendComeBySocket == actionType then 
    	self:updateAdapter()
    elseif kFriendGoneBySocket == actionType then 
		self:updateAdapter()
	end
end

]]--

--获取当前自己的金币
CreateFriendRoom.get_current_money = function (self)
	local m,t = self:getCurSelectRoundMoney();
    local myself = PlayerManager.getInstance():myself();
	local my_money = t == GameConstant.fm_money_type.coin and  myself.money or  myself.boyaacoin;
    return my_money;
end

function CreateFriendRoom:IsConditionSatisfied()
	local m,t = self:getCurSelectRoundMoney();
    local myself = PlayerManager.getInstance():myself();
	local myMoney = self:get_current_money();

	if m and myMoney and myMoney >= m then 
		--self:notEnoughMoney()
		return true
	end 

	self:notEnoughMoney()
	return false
end


function CreateFriendRoom:notEnoughMoney( )
	local m,t = self:getCurSelectRoundMoney();
    --如果是钻石不足
    local tmp_moneytype = global_transform_money_type_2(t, false) 

    --创建快速充值界面
    local param_t = {t = RechargeTip.enum.friend_match_wnd, 
                        isShow = true, money = m or 0, moneytype = tmp_moneytype, 
                        is_check_bankruptcy = false, 
                        is_check_giftpack = false};
	RechargeTip.create(param_t)

end

function CreateFriendRoom:defaultSelected( )
	--default click
	local defaultRound     = g_DiskDataMgr:getFileKeyValue(kFMRConfigDict,"roundNum",8)
	local defaultWanfa 	   = g_DiskDataMgr:getFileKeyValue(kFMRConfigDict,"wanfa",1)
	local defaultBasePoint = g_DiskDataMgr:getFileKeyValue(kFMRConfigDict,"basePoint",1)
	local defaultMost      = g_DiskDataMgr:getFileKeyValue(kFMRConfigDict,"most",0)

	local textMap = {
		["xl"]  = 0x0002,--成河
		--["xz"]  = 0x0000,--到底
		["lfp"] = 0x0010,
		["dq"]  = 0x0001,
		["hsz"] = 0x0004,
	}
	local xzIndex = 1
	local selectIndex = nil 
	for i=1,#self._config.playTypes do
		local key = self._config.playTypes[i]--xz,xl,lfp
		if key == "xz" then 
			xzIndex = i
		elseif textMap[key] and bit.band(defaultWanfa, textMap[key]) ~= 0 then 
			selectIndex = i
			break
		end 
	end
	self.playTypeRadioGroup:onItemClick(self.playTypeRadioGroup:getButton(selectIndex or xzIndex))

    local bFind = false;
	for i=1,#self._config.checkBoxPlayTypes do
		local key = self._config.checkBoxPlayTypes[i]--dq,hsz
        if key == "dq" then--默认选择定缺，且不能点击
--            self.playTypeCheckGroup:onItemClick(self.playTypeCheckGroup:getCheckBox(i))
--            self.playTypeCheckGroup:getCheckBox(i):setPickable(false);
        elseif textMap[key] and bit.band(defaultWanfa, textMap[key]) ~= 0 then 
			self.playTypeCheckGroup:onItemClick(self.playTypeCheckGroup:getCheckBox(i))
            bFind = true;
        end
		
	end

--    if bFind == false then
--        self.playTypeCheckGroup:onItemClick(self.playTypeCheckGroup:getCheckBox(1))
--    end

    bFind = false;
	for i=1,#self._config.roundsArr do
		if self._config.roundsArr[i].roundnum == defaultRound then 
			self.roundRadioGroup:onItemClick(self.roundRadioGroup:getButton(i))
            bFind = true;
			break
		end 
	end
    if bFind == false then
        self.roundRadioGroup:onItemClick(self.roundRadioGroup:getButton(1))
    end	

    bFind = false;
	for i=1,#self._config.dis do
		if self._config.dis[i] == defaultBasePoint then 
			self.diRadioGroup:onItemClick(self.diRadioGroup:getButton(i))
            bFind = true;
			break
		end 
	end
    if bFind == false then
        self.diRadioGroup:onItemClick(self.diRadioGroup:getButton(1))
    end

    bFind = false
    for i=1,#self._config.mostTypes do
    	if self._config.mostTypes[i] == defaultMost then 
    		self.mostRadioGroup:onItemClick(self.mostRadioGroup:getButton(i))
    		bFind = true;
    		break
    	end 
    end
    if bFind == false then
        self.mostRadioGroup:onItemClick(self.mostRadioGroup:getButton(1))
    end

end

function CreateFriendRoom:rememberLastSelected(roundNum, wanfa, basePoint, mostNum)
	g_DiskDataMgr:setFileKeyValue(kFMRConfigDict, "roundNum", roundNum or 8);
	g_DiskDataMgr:setFileKeyValue(kFMRConfigDict, "wanfa"   , wanfa or 0);
	g_DiskDataMgr:setFileKeyValue(kFMRConfigDict, "basePoint", basePoint or 1);
	g_DiskDataMgr:setFileKeyValue(kFMRConfigDict, "most", mostNum or 0);
end

function CreateFriendRoom:requestCreateRoom()
	DebugLog("CreateFriendRoom:requestCreateRoom")

	if not self:IsConditionSatisfied() then 
		return
	end 
    self:hideWnd()

	local param  	= {}
	local player 	= PlayerManager.getInstance():myself()
	param.level   		= self._config.level
	param.money   		= self:get_current_money() or 0; 
	param.userInfo		= json.encode(player:getUserData())--
	param.mtk           = player.mtkey
	param.from          = player.api
	param.version       = 1--GameConstant.Version
	param.versionName   = GameConstant.Version

	param.mahjongCode   = 6--川麻6
	param.roundNum      = self:getCurSelectRoundNum() or 8
	param.playType      = self:getCurSelectPlayType() or 1
	param.basePoint     = 1--self:getCurSelectDi() or 1
	param.mostNum       = self:getCurSelectMost() or 0
	
	self:rememberLastSelected(param.roundNum,param.playType,param.basePoint, param.mostNum)

	if bit.band(param.playType, 0x0004) == 0 then 
		param.changeNum = 0
	else 
		param.changeNum = 1
	end 
	--mahjongPrint(param)
	param.isJoinRoom = false

	RoomData.getInstance():setPrivateRoomData(param);
	StateMachine.getInstance():changeState(States.Loading,nil,States.FriendMatchRoom);	


	--self:hideWnd()
end



