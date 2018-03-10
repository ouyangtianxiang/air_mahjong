require("MahjongSocket/socketCmd");

require("MahjongHall/HongBao/HongBaoViewManager")
HongBaoModel = class()

HongBaoModel.m_Instance = nil

HongBaoModel.HongBaoMsgs = EventDispatcher.getInstance():getUserEvent();

HongBaoModel.DissmissHongbao = EventDispatcher.getInstance():getUserEvent();

HongBaoModel.recieveNewHongBao 			= 1 --新红包通知
HongBaoModel.qiangHongBaoSuccess		= 2 --抢红包成功
HongBaoModel.qiangHongBaoFail			= 3 --抢红包失败

HongBaoModel.getUserInfoDone            = 4 --获取了发红包者的详细信息 name ,imgUrl, sex,

HongBaoModel.exchangeHongBaoEvent       = 5 --购买了红包道具
HongBaoModel.UsedHongBaoEvent           = 6 --消耗了红包道具


function HongBaoModel.getInstance()
	if not HongBaoModel.m_Instance then
		HongBaoModel.m_Instance = new(HongBaoModel)
	end
	return HongBaoModel.m_Instance
end

function HongBaoModel.ctor(self)
	self.config = {} -- from php

	self.hongbaoInfo = {}
	self.userInfo    = {}

	self.userInfo[1] = {}
	self.userInfo[1].uid    = 1
	self.userInfo[1].imgUrl = "default_man"
	self.userInfo[1].name   = "系统管理员"
	self.userInfo[1].sex    = kSexMan

	EventDispatcher.getInstance():register(SocketManager.s_phpMsg, self, self.onPhpMsgResponse);
	EventDispatcher.getInstance():register(SocketManager.s_serverMsg, self, self.onSocketPackEvent);
	EventDispatcher.getInstance():register(HongBaoModel.HongBaoMsgs, self, self.onHongbaoMsgEvent);	
	FriendDataManager.getInstance():addListener(self,self.onCallBackFunc);
end

function HongBaoModel.dtor(self)
	self.config 	 = nil
	self.hongbaoInfo = nil
	self.userInfo    = nil
	EventDispatcher.getInstance():unregister(SocketManager.s_phpMsg, self, self.onPhpMsgResponse);
	EventDispatcher.getInstance():unregister(SocketManager.s_serverMsg, self, self.onSocketPackEvent);
	EventDispatcher.getInstance():register(HongBaoModel.HongBaoMsgs, self, self.onHongbaoMsgEvent);	
	FriendDataManager.getInstance():removeListener(self,self.onCallBackFunc);
	HongBaoModel.m_Instance = nil;	
end


----------------------------------------------------------config info------------------------------------------
function HongBaoModel.getMoneySelectConfig( self )
	mahjongPrint(self.config.moneyArray)
	return self.config.moneyArray
end

function HongBaoModel.getUserInfo( self, mid )
	return self.userInfo[mid]
end

function HongBaoModel.getHongBaoInfo( self, hid )
	return self.hongbaoInfo[hid]
end

function HongBaoModel.checkIsSuitSendCondition( self )
	local player = PlayerManager.getInstance():myself()
	local money = self.config.moneyArray[1]*100/self.config.per 
	
	--[[
	local hongbaoNum = GameConstant.changeNickTimes.rednum
	local item = ProductManager.getInstance():getExchangeListItem(ItemManager.HONG_BAO_CID)
	
	if hongbaoNum and hongbaoNum <= 0 and item and item.money then
		money = money +  tonumber(item.money)
	end 
]]
	if player.money < money then 
		Banner.getInstance():showMsg("高于".. money .."金币才可以使用红包哦！")
		return false
	end
	return true
end

function HongBaoModel.getMaxSendMoneyConfigIndex( self )
	local player = PlayerManager.getInstance():myself()
	local maxMoney = player.money * self.config.per / 100
	for i=#self.config.moneyArray,1,-1 do
		if(maxMoney >= self.config.moneyArray[i]) then 
			return i 
		end 
	end
	return 1
end

function HongBaoModel.getLimitTime( self )
	if self.config then 
		return self.config.time
	end 
	return nil 
end

function HongBaoModel.getConfigMsg( self )
	if self.config then 
		return self.config.msg
	end 
	return nil 
end
-----------------------------------------------php-----------------------------------------------------------


function HongBaoModel.onRequestConfig( self, data)
	DebugLog("HongBaoModel.onRequestConfig")
	if data then
		mahjongPrint(data)

		self.config.open = tonumber(data.open)     --开启状态 0:不开启 1：开启
		if self.config.open == 1 then 

			self.config.num    = tonumber(data.num)	  --领取红包人数
			-----------------这四个限制条件 四川没有用,二人用
			--[[
			self.config.slevel = tonumber(data.slevel) --发红包等级
			self.config.glevel = tonumber(data.glevel) --开红包等级
			self.config.smoney = tonumber(data.smoney) --发红包充值金额
			self.config.gmoney = tonumber(data.gmoney) --开红包充值金额
			]]
			self.config.per    = tonumber(data.per)
			self.config.time   = tonumber(data.time)
			self.config.msg    = data.msg
			
			if data.moneyArr and data.moneyArr then 
				self.config.moneyArray = {}
				for i=1,#data.moneyArr do
					table.insert(self.config.moneyArray,data.moneyArr[i]*10000)
				end
			end 
		end
		DebugLog("config:")
		mahjongPrint(self.config)
	end	
end 

function HongBaoModel.requestSendHongbao(self, money ,msg)
	if self.config.open ~= 1 then --红包系统未开放
		return 
	end
	
	self.sendMoney = money or 0

	local post_data 		= {};
	post_data.mid 			= PlayerManager:getInstance():myself().mid;
	post_data.api 		    = PlayerManager:getInstance():myself().api;
	post_data.money         = money
	post_data.msg 		    = msg
	post_data.num           = self.config.num
	SocketManager.getInstance():sendPack( PHP_CMD_REQUEST_SEND_HONGBAO,post_data);
end

function HongBaoModel.onRequestSendHongbao(self, isSuccess, data )
	DebugLog("HongBaoModel.onRequestSendHongbao")
	mahjongPrint(data)
	
	if data then 
		local status = data.status
		local msg    = data.msg


		Banner.getInstance():showMsg(msg or "nil")
		if status == 1 then 
			GameConstant.changeNickTimes.rednum = GameConstant.changeNickTimes.rednum - 1			
			EventDispatcher.getInstance():dispatch(HongBaoModel.HongBaoMsgs,HongBaoModel.UsedHongBaoEvent);
			PlayerManager:getInstance():myself():addMoney(-self.sendMoney)
		end 
	end 
end 



function HongBaoModel.checkAndRequestUserInfo( self, uid )
	if not self.userInfo[uid] then 
		local uinfo = {}
		uinfo.uid    = uid 
		uinfo.imgUrl = ""
		uinfo.name   = ""
		uinfo.sex    = kSexMan

		self.userInfo[uid] = uinfo

		FriendDataManager.getInstance():QueryUserInfo(PHP_CMD_QUERY_USER_INFO,{uid},{"mnick","sex", "small_image"})
	end 
end

function HongBaoModel.onRequestUserInfo( self, data)
	local result = nil;
	
	if data and type(data) == "table" and #data > 0 then
		result = data[1]
		result.mid = tonumber(result.mid or 0)

		local uinfo = self.userInfo[result.mid]
		if uinfo then 
			uinfo.imgUrl = result.small_image
			uinfo.sex    = result.sex
			uinfo.name   = result.mnick
			EventDispatcher.getInstance():dispatch(HongBaoModel.HongBaoMsgs,HongBaoModel.getUserInfoDone,result.mid)
		end
	end
end



------------------------------------sever---------------------------------------------------------------------
function HongBaoModel.qiangHongBaoRequest( self, hid )
	if self.config.open ~= 1 then --红包系统未开放
		return 
	end


	local hongbao = self.hongbaoInfo[hid]

	if hongbao then 
		local param = {}
		param.sendUid   = hongbao.sendUid									--发红包玩家Uid 
		param.hongbaoId = hongbao.hongbaoId 								--红包唯一标识
		param.grabUid   = PlayerManager.getInstance():myself().mid			--抢红包玩家Uid
		param.from      = PlayerManager.getInstance():myself().api			--抢红包玩家from字段(api )
		SocketSender.getInstance():send(CLIENT_COMMAND_QIANG_HONGBAO, param);
	end
end



function HongBaoModel.recieveHongbaoInfo( self, data )
	DebugLog("HongBaoModel.recieveHongbaoInfo")
	if not data or self.config.open ~= 1 then 
		return 
	end 
	
	local hongbao = self.hongbaoInfo[data.hongbaoId] or {}
	self.hongbaoInfo[data.hongbaoId] = hongbao

	hongbao.hongbaoId = data.hongbaoId
	hongbao.hongbaoType = data.hongbaoType
	hongbao.sendUid   = data.sendUid
	hongbao.cmdRequest= data.cmdRequest

	if data.cmdRequest == MSG_CMD_BROADCAST_RED then --来了一个新红包
		self:checkAndRequestUserInfo(hongbao.sendUid)-- 检查是否有发红包者的信息,如果没有去php请求
		hongbao.tipsStr = data.tipsStr
		DebugLog("hongbao.tipsStr:"..tostring(hongbao.tipsStr))
		EventDispatcher.getInstance():dispatch(HongBaoModel.HongBaoMsgs,HongBaoModel.recieveNewHongBao,hongbao)
	elseif data.cmdRequest == MSG_CMD_NOTIFY_RED_SUCC then --抢红包成功
		hongbao.money = data.money
		if hongbao.hongbaoType and hongbao.hongbaoType == 2 then 
			PlayerManager.getInstance():myself():addCoupons(tonumber(data.money))
		else 
			PlayerManager.getInstance():myself():addMoney(tonumber(data.money));
		end
		showGoldDropAnimation()
		EventDispatcher.getInstance():dispatch(HongBaoModel.HongBaoMsgs,HongBaoModel.qiangHongBaoSuccess,hongbao)
		if RoomScene_instance and not FriendMatchRoomScene_instance then 
			SocketSender.getInstance():send(CLIENT_COMMAND_GET_NEW_MONEY, {["mid"] = PlayerManager.getInstance():myself().mid}); 
		end 
	else--抢红包失败  没了 or 已经抢过 or 没有该红包(过期)
		EventDispatcher.getInstance():dispatch(HongBaoModel.HongBaoMsgs,HongBaoModel.qiangHongBaoFail,hongbao)
	end

end

--------------------------------------------------------------------------------------------------------------
function HongBaoModel.onSocketPackEvent( self, param, cmd )
	if HongBaoModel.scoketEventFuncMap[cmd] then
		DebugLog("HongBaoModel deal socket cmd "..cmd);
		HongBaoModel.scoketEventFuncMap[cmd](self, param);
	end
end


HongBaoModel.onPhpMsgResponse = function ( self, param, cmd, isSuccess,... )
	if self.httpRequestsCallBackFuncMap[cmd] then 
		self.httpRequestsCallBackFuncMap[cmd](self,isSuccess,param,...)
	end
end


HongBaoModel.onCallBackFunc = function(self, actionType, actionParam)
	if kFriendSearchByPHP == actionType then --查找ID
		self:onRequestUserInfo(actionParam);
	end
end

-------------------------------------------------------------------------------------
function HongBaoModel.onHongbaoMsgEvent( self,status )
	if status == HongBaoModel.exchangeHongBaoEvent then 
		if HongBaoModel.getInstance():checkIsSuitSendCondition() then
			HongBaoViewManager.getInstance():showHongBaoSendView()
		end		
	end
end



HongBaoModel.httpRequestsCallBackFuncMap ={
	[PHP_CMD_REQUEST_SEND_HONGBAO]       = HongBaoModel.onRequestSendHongbao,
};

HongBaoModel.scoketEventFuncMap = {
	[SERVER_COMMAND_NEW_HONGBAO] = HongBaoModel.recieveHongbaoInfo,
}





