-- 玩家信息类
require("MahjongConstant/GameConstant");

Player = class()

Player.myNetSeat = 0; -- 自己的网络位置

-- 计算网络玩家的本地位置方法
Player.getLocalSeat = function ( netSeatID )
	local offset = 4 - Player.myNetSeat;
	return (netSeatID + offset) % 4;
end

Player.ctor = function (self)
	self.isMyself = false;
	self.api = PlatformFactory.curPlatform.api;
	self.localSeatId = -1; -- 默认没有本地id容错
	self:resetPlayerData();
end

Player.setFriendMatchScore =function ( self, score )
	self.fmScore = score or 0
	EventDispatcher.getInstance():dispatch(GlobalDataManager.updateSceneEvent); -- 通知界面更新金币
end
Player.addFriendMatchScore = function ( self, score )
	self.fmScore = self.fmScore + (score or 0)
	EventDispatcher.getInstance():dispatch(GlobalDataManager.updateSceneEvent); -- 通知界面更新金币
end

Player.getFriendMatchScore = function ( self )
	return self.fmScore
end

Player.setMoney = function ( self, money )
	self.money =  money or 0;
	EventDispatcher.getInstance():dispatch(GlobalDataManager.updateSceneEvent); -- 通知界面更新金币
	-- end
end

Player.addMoney = function ( self, money )
	self.money = self.money + (money or 0);
	EventDispatcher.getInstance():dispatch(GlobalDataManager.updateSceneEvent); -- 通知界面更新金币
end

Player.set_diamond = function ( self, money )
	self.boyaacoin =  money or 0;
	EventDispatcher.getInstance():dispatch(GlobalDataManager.updateSceneEvent); -- 通知界面更新金币
	-- end
end

Player.add_diamond = function ( self, money )
	self.boyaacoin = self.boyaacoin + (money or 0);
	EventDispatcher.getInstance():dispatch(GlobalDataManager.updateSceneEvent); -- 通知界面更新金币
end

Player.setMatchScore = function ( self, score )
	self.matchScore =  score or 0;
	if self.matchScore < 0 then
		self.matchScore = 0;
	end
	
	EventDispatcher.getInstance():dispatch(GlobalDataManager.updateSceneEvent); -- 通知界面更新金币
end

Player.addMatchScore = function ( self, score )
	self.matchScore = self.matchScore + (score or 0);
	EventDispatcher.getInstance():dispatch(GlobalDataManager.updateSceneEvent); -- 通知界面更新金币
end

Player.setCoupons = function ( self, coupons )
	--判断是否增加了话费券  --首次获得话费券 要增加banner提示  v5.1.0需求
	if self.isMyself then 
		local srcCoupons  = tonumber(self.coupons or 0) 
		local destCoupons = tonumber(coupons or 0) 
		if destCoupons > srcCoupons then --增加了话费券
			local gettedCounpons = g_DiskDataMgr:getAppData("gettedCoupons",0)
			if gettedCoupons == 0 then --从未获取过话费券
				g_DiskDataMgr:setAppData("gettedCoupons",1)
				Banner.getInstance():showMsg("积累相应的话费券可在兑换功能处兑换精美礼品哦!");
			end
		end
	end 
	--


	self.coupons =  coupons or 0;
	if self.coupons < 0 then
		self.coupons = 0;
	end
	DebugLog("set self.coupons = ")
	DebugLog(self.coupons)
	EventDispatcher.getInstance():dispatch(GlobalDataManager.updateSceneEvent); -- 通知界面更新金币
end

Player.addCoupons = function ( self, coupons )
	self:setCoupons( (self.coupons or 0) + (coupons or 0) );
end


Player.getCoupons = function ( self )
	return tonumber(self.coupons or 0);
end



-- 自己退出游戏时调用一次
Player.exitGame = function ( self )
	self.isInGame = false;
	self.isReady = false; -- 是否已准备
	self.seatId = 0; -- 网络座位id
	self.localSeatId = 0; -- 本地座位id
	self.dingQueType = nil; -- 定缺的类型
	Player.myNetSeat = 0; 
	self.isHu = false;
	self.gfxyMoney = 0;
	self.hasBankruptInGame = false;
	if not self.isMyself then
		self.likesData = nil;
	end
end

-- 玩家开始已经游戏
Player.startGame = function ( self )
	self.hasBankruptInGame = false;
	self.isInGame = true;
	self.isAi = false;
	self.isHu = false;
	self.gfxyMoney = 0;
	self.dingQueType = nil;
end

-- 一局游戏结束
Player.gameOver = function ( self )
	self.hasBankruptInGame = false;
	self.isInGame = false;
	self.isReady = false;
	self.dingQueType = nil;
	self.isAi = false;
	self.isHu = false;
	self.gfxyMoney = 0;
end

Player.setReady = function ( self, bReady )
	self.isReady = bReady;
end

-- 初始化网络用户数据，进入房间时，房间内的用户数据
Player.initSocketUserData = function(self, playerInfo, inFetionRoom)

	if(playerInfo.isReady ~= 0) then
        self.isReady = true;
    else
    	self.isReady = false;
    end

	if(inFetionRoom ~= 0) then
        self.inFetionRoom = true;
    else
    	self.inFetionRoom = false;
    end

	self.mid = tonumber(playerInfo.userId);
	self.money = tonumber(playerInfo.money);
	self.seatId = playerInfo.seatId;
	self.matchScore = playerInfo.matchScore;
	-- 计算自己的本地座位id
	self.localSeatId = Player.getLocalSeat( self.seatId );

	local data = json.mahjong_decode_node(playerInfo.userinfo) -- 基础数据,json格式
   	self.sex = tonumber(data.sex) -- 用户性别
	self.level = data.level -- 游戏等级
	self.money = self.money or tonumber(data.money) or 0 -- 金币
	self.nickName = GameString.convert2Platform(data.nickName) -- 用户昵称
	self.losetimes = data.loseCount
	self.wintimes = data.winCount
	self.drawtimes = data.deuceCount;
	self.small_image = data.smallHeadPhoto or ""
	self.large_image = data.largeHeadPhoto or "";
	self.levelName=data.levelName 
	self.exp = data.exp

	self.fmScore = 0--好友比赛的 积分字段
	
	self.circletype = tonumber(data.circletype) or 0;
	if(self.drawtimes == nil ) then
        self.drawtimes=0
	end
	if(self.losetimes == nil ) then
        self.losetimes=0
	end
	if(self.wintimes == nil ) then
        self.wintimes=0
	end
	self.localIconDir = "" -- 头像本地路径
	
	if self.large_image ~= "" then
		self:downloadIconImg()
	end

	if not data.vipInfo then 
		self.vipLevel = 0
		self.kxtxk    = 0
		self.hhmjz    = 0
	else  
		--VIP信息  
		self.vipLevel = tonumber(data.vipInfo.vip) or 0; --等级
		--  0为没有使用权  -1是无限使用权  其他为使用期限
		self.kxtxk = tonumber(data.vipInfo.tq.kxtxk) or 0  --头像框
		self.hhmjz = tonumber(data.vipInfo.tq.hhmjz) or 0  --麻将子
	end 
	require("MahjongRoom/Mahjong/MahjongViewManager")
	self.paizhi = tostring(data.paizhi) or MahjongViewManager.MahongTypeTable.MAHJONG_TYPE_NORMAL; -- 麻将子

	if not self.isMyself then
		self.likesData = nil
	end
end 

Player.setLocalIconDir = function ( self, dir )
	self.localIconDir = dir;
end

Player.getLocalIconDir = function ( self, dir )
	return self.localIconDir;
end

-- 下载头像
Player.downloadIconImg = function ( self )
    local isExist , localDir = NativeManager.getInstance():downloadImage(self.large_image);
    self:setLocalIconDir(localDir);
end

--初始化自己的VIP信息
Player.initVipInfo = function(self, data)
	self.vipState = tonumber(data.status) -- VIP状态 (-1:获取失败  1:正常)
	if self.vipState == -1 then
		GlobalDataManager.getInstance():getMyVipInfo()  --再次请求自己的VIP信息
	elseif self.vipState == 1 then
		self.vipLevel = tonumber(data.vipInfo.vip) or 0  --VIP等级
		self.vipScore = tonumber(data.vipInfo.jifen) or 0  --VIP积分
		self.vipTTL = tonumber(data.vipInfo.ttl) or 0  --VIP过期时间
		if self.vipLevel > 0 then
			self.trgn = tonumber(data.vipInfo.tq.trgn)  --VIP踢人功能
			self.kxtxk = tonumber(data.vipInfo.tq.kxtxk)  --VIP头像框
			self.zdycyy = tonumber(data.vipInfo.tq.zdycyy)  --VIP自定义常用语
			self.ffdbjb = tonumber(data.vipInfo.tq.ffdbjb)  --VIP表情包
			self.hhmjz = tonumber(data.vipInfo.tq.hhmjz)  --VIP麻将子
			self.zsch = data.vipInfo.tq.zsch  --VIP称号
			self.xgnc = data.vipInfo.tq.xgnc  --VIP昵称修改次数
			
			if data.vipInfo.tq.sykbx then 
				self.vipBoxRight = data.vipInfo.tq.sykbx  --VIP开包厢(FIX ME)
				self.huanSan = data.vipInfo.tq.sykbx.huanSan or 0
				self.xueLiu = data.vipInfo.tq.sykbx.xueLiu or 0
				self.dizhuList = {};
				for k,v in pairs(data.vipInfo.tq.sykbx.dizhu) do
					if type( v ) ~= "table" then
						break;
					end
					table.insert(self.dizhuList, tonumber(v))
				end
			else 
				self.vipBoxRight = 0
				self.huanSan =  0
				self.xueLiu = 0
				self.dizhuList = {};
			end 
		else
			self.trgn = 0;  --VIP踢人功能
			self.kxtxk = 0;  --VIP头像框
			self.zdycyy = 0;  --VIP自定义常用语
			self.ffdbjb = 0;  --VIP表情包
			self.hhmjz = 0;  --VIP麻将子
			self.zsch = 0;  --VIP称号
			self.xgnc = 0;  --VIP昵称修改次数
			self.vipBoxRight = 0;  --VIP开包厢(FIX ME)
			self.huanSan = 0;
			self.xueLiu = 0;
			self.dizhuList = {};
		end
	end
end

Player.isVip = function( self )
	if self.vipLevel then
		if tonumber( self.vipLevel or 0 ) > 0 then
			return true;
		end
		return false;
	end
	return false;
end

-- vip特权是否能开包厢
Player.boxVipXueliu = function ( self )
	if not self.xueLiu or 0 == self.xueLiu then
		return false;
	end
	return true;
end

Player.boxVipHsz = function ( self )
	if not self.huanSan or 0 == self.huanSan then
		return false;
	end
	return true;
end

Player.boxVipDizhu = function ( self, dizhu )
	if 20000 == dizhu or 50000 == dizhu then -- 需要判断的低注,目前是写死了。
		if not self.dizhuList or #self.dizhuList < 1 then
			return false;
		end
		for k,v in pairs(self.dizhuList) do
			if v == dizhu then -- 有这个特权
				return true;
			end
		end
	end
	return true;
end

Player.VIP_TR = 1; -- vip踢人功能
Player.VIP_TXK = 2; -- vip头像狂
Player.VIP_CYY = 3; -- vip自定义常用语
Player.VIP_BQB = 4; -- vip表情包
Player.VIP_MZZ = 5; -- vip麻将子

-- 判断对应vip功能是否可用的函数
Player.checkVipStatu = function ( self, fun_type )
	if Player.VIP_TR == fun_type and self.trgn and 0 ~= self.trgn then
		return true;
	elseif Player.VIP_TXK == fun_type and self.kxtxk and 0 ~= self.kxtxk then
		return true;
	elseif Player.VIP_CYY == fun_type and self.zdycyy and 0 ~= self.zdycyy then
		return true;
	elseif Player.VIP_BQB == fun_type and self.ffdbjb and 0 ~= self.ffdbjb then
		return true;
	elseif Player.VIP_MZZ == fun_type and self.hhmjz and 0 ~= self.hhmjz then
		return true;
	end
	return false;
end

-- 初始化自己的数据，登录成功时服务器返回
Player.initPhpUserData = function(self,data)
	self.mid = tonumber(data.mid)or 0 -- 用户ID
	self.sex = tonumber(data.sex) -- 用户性别
	self.level = data.level -- 游戏等级
	self.money = tonumber(data.money) or 0; -- 金币
	self.exp = data.exp -- 经验值
    self.dingkaiCoin = nil;  --起凡币

    --如果为起凡，名字和头像都用起凡的
    if GameConstant.platformType ~= PlatformConfig.platformDingkai then
        self.nickName = GameString.convert2Platform(data.mnick) -- 用户昵称
        self.large_image = data.large_image
        self.small_image = data.small_image
        self.dingkaiCoin = GameConstant.dingkai_coin or 0;
    end
	
	self.losetimes = data.losetimes or 0
	self.wintimes = data.wintimes or 0
	self.drawtimes = data.drawtimes or 0

	
	self.type = data.type
	self.isRegister = tonumber(data.isRegister) or 0
	self.city = data.city
	self.province = data.province
	self.loginreward_available =data.loginreward_available
	self.description = data.description
	self.activetime = data.activetime
	self.mtstatus = data.mtstatus
	self.tasktime = data.tasktime
	self.mttime = data.mttime
	self.svid = data.svid
	self.tid = data.tid
	self.isTodayFirst = data.isTodayFirst
	self.chips = data.chips
	self.mtaskcount = data.mtaskcount
	self.mentercount = data.mentercount
	self.mactivetime = data.mactivetime
	self.sitemid = data.sitemid
	self.mtime = data.mtime or 0
	-- self.mtkey = "009bf200de3a132b9b063022abb525d7" or data.mtkey --传说中的万能key
	self.mtkey = data.mtkey
	self.boyaacoin = tonumber(data.boyaacoin) or 0--钻石
	self:setCoupons( tonumber(data.coupons) or 0 )
	self.isAdult = tonumber(data.isAult);
	self.circletype = tonumber(data.circletype) or 0;
	if data.cards then
		for k , v in pairs(data.cards) do
			if kHuanSanZhangCardId == tonumber(k) then
				self.kHuanSanZhangCardId = tonumber(v);
			end
			if kXueLiuChengHeCardId == tonumber(k) then
				self.xlchCardNum = tonumber(v);
			end
			if kQianDaoCardId == tonumber(k) then
				
			end
		end
	end

	--只有飞信平台才会上传头像
	if GameConstant.platformType == PlatformConfig.platformFetion then
		if not self.large_image or string.find(self.large_image, "default_woman") or string.find(self.large_image, "default_man") then
			local param = {};
			local api = {};
		    api.mid = self.mid;
		    api.username = "user_"..self.mid;
		    api.time = os.time();
		    api.api = tonumber(PlatformFactory.curPlatform.api);
		    api.langtype = 1;
		    api.version = GameConstant.Version;
		    api.mtkey = self.mtkey;
		    api.sid = tonumber(PlatformFactory.curPlatform.sid);
			api.method = "IconAndroid.upload";
		    local signature = Joins(api, "");
		    api.sig = md5_string(signature);

			param.mid = tostring(self.mid);
			param.api = api;
			param.url = GameConstant.CommonUrl.."?m=android&p=upicon";
			local dataStr = json.encode(param);
			native_to_java(kFetionUploadHeadicon,dataStr);
			DebugLog("upload fetion headIcon");
		end
	end
	
	self.localIconDir = publ_downloadImg(self.large_image); -- 下载头像
end

-- 登录房间时发给服务器的数据
Player.getUserData = function(self)
    local userData = {};
    userData.nickName = self.nickName;
    userData.sex = self.sex;
    userData.level = self.level;
    userData.exp = self.exp;
    userData.levelName = self.levelName;
    userData.money = self.money;
    userData.winCount = self.wintimes;
    userData.loseCount = self.losetimes;
    userData.deuceCount = self.drawtimes;
    userData.smallHeadPhoto = self.small_image;
    userData.largeHeadPhoto = self.large_image;
    userData.largeHeadPhoto = self.large_image;
    userData.circletype = self.circletype;
    --VIP信息
    userData.vipInfo = {};  
    userData.vipInfo.vip = self.vipLevel;
    userData.vipInfo.tq = {};
    userData.vipInfo.tq.kxtxk = self.kxtxk;  --头像框
    userData.vipInfo.tq.hhmjz = self.hhmjz;  --麻将子
    userData.paizhi = self.paizhi; -- 牌纸字段
    return userData; 
end


Player.dtor = function(self)
	self:resetPlayerData();
end

Player.isFirstTimeBankruptInGame = function ( self )
	-- if self.money >= GameConstant.bankruptMoney then
	-- 	return false;
	-- end
	return not self.hasBankruptInGame;
end

--用户数据重置
Player.resetPlayerData = function(self)
	self.isInGame = false;
	self.isReady = false; -- 是否已准备
	self.seatId = 0; -- 网络座位id
	self.localSeatId = 0; -- 本地座位id
	self.isHu = false;
	self.isBank = false;
	self.hasBankruptInGame = false;
	self.dingQueType = nil; -- 定缺的类型
	self.inFetionRoom = false;  -- 飞信

	self.iconDir = nil;
	self.iconUrl = nil;

	self.gfxyMoney = 0;

	self.mid = 0;   --用户ID
	self.sex = 0; --用户性别  0--> man 1 --> woman 2 --> secret
	self.level = 0; --游戏等级
	self.money = 0; --金币
	self.boyaacoin   	= 0; -- 博雅币
	self.exp  	= 0; --经验值
	self.nickName 	= ""; --用户昵称
	self.losetimes     	= 0; --负局
	self.wintimes 		= 0; --胜局
	self.drawtimes 		= 0; --平局
	self.small_image 	=""; --小头像
	self.large_image 	= ""; --大头像
	self.type 	= ""; --游戏类型（暂时不处理）
	self.isRegister 	= 0; --是否刚刚注册
	self.isAdult        = -2;--重来没有登录过
	self.coupons = 0
	--self:setCoupons(0)
	self.isAi = false;  

	self.city 	= ""; --所在城市
	self.province 	= ""; --所在省份
	self.vip 	= ""; --暂未用
	self.loginreward_available 	= ""; --是否领取了登陆奖励
	self.viptime 	= ""; --暂未用
	self.description 	= ""; --描述
	self.activetime 	= ""; --活跃时间
	self.mtstatus 	= 0; --当前状态，0为大厅，1为旁观，2为游戏中。
	self.tasktime 	= ""; --暂未知
	self.mttime 	= ""; --最后更新时间
	self.svid 	= ""; --暂未用
	self.tid 	= ""; --对应的tables 暂未用
	self.isTodayFirst 	= 0; --是否今天第一次登陆
	self.chips 	= 0; --积分
	self.sid 	= 0; --平台ID，安卓四川麻将是308
	self.mtime 	= ""; --注册时间
	self.mtkey 	= ""; --唯一值,用户登录插入KEY
	self.mtaskcount 	= 0; --完成新手任务次数
	self.mentercount 	= 0; --用户进入游戏的次数，每天统计一次
	self.mactivetime 	= ""; --最后登陆时间
	self.sitemid 	= ""; --平台id
	self.levelName 	= ""; --等级名称
	self.circletype = 10002; -- 是否有特殊头像框,目前大于零为有特殊头像框
	self.localIconDir = "";

	--vip
	self.vipLevel = 0;
	self.vipScore = 0;
	self.vipTTL = 0;
	self.trgn = 0;
	self.kxtxk = 0;
	self.zdycyy = 0;
	self.ffdbjb = 0;
	self.hhmjz = 0;
	self.zsch = 0;
	self.xgnc = 0;

	self.matchScore = 0; --比赛积分
	self.fmScore    = 0 --好友比赛积分
	
	self.paizhi = "10000"; -- -1 代表默认牌纸，如果是vip就显示vip牌纸，如果是普通用户则显示普通牌纸
end

