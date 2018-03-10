require("ui/node");
local xlchItem = require(ViewLuaPath.."xlchItem");
local number4Pin_map = require("qnPlist/number4Pin")

XlchRoomItem = class(Node);

XlchRoomItem.ctor = function ( self, data)
	DebugLog("XlchRoomItem.ctor")
	if not data then
		return;
	end
	self.bg = nil;
	self.onlineNum = 0;
	self.type = 0;
	self.limit = nil;
	self.index = data.index or 1

    --定义左右摆动弧度，及延迟时间
    local value1 = { startValue = 10, endValue = -10, delayTime = -1};
    local value2 = { startValue = -10, endValue = 10, delayTime = 0};
    local value3 = { startValue = 10, endValue = -10, delayTime = 100};
    local value4 = { startValue = -10, endValue = 10, delayTime = 1000};
    self.userDefineAnim ={ value1, value2, value3, value4};

	self:create()
	self:setData(data)
	EventDispatcher.getInstance():register(NativeManager._Event, self, self.nativeCallEvent);
end

XlchRoomItem.create = function ( self )

	self.m_item = SceneLoader.load(xlchItem)
	self:addChild(self.m_item)
	self.bgBtn = publ_getItemFromTree(self.m_item, {"Button1"} )
	local modeindex = self.index % 4
	self.bgBtn:setFile("Hall/chooseLevel/xl_item" .. tostring(modeindex) .. ".png")

	self.diNumImg = publ_getItemFromTree(self.m_item, {"Button1", "mid","Image1"} )
	self.midView    = publ_getItemFromTree(self.m_item, {"Button1", "mid"})
	--self.pandaImg:setFile("Hall/chooseLevel/game" .. tostring(modeindex) .. ".png")

	self.roomNameImg = publ_getItemFromTree(self.m_item, {"Button1","Image2"})
	--self.roomNameImg:setFile("Hall/chooseLevel/game_default.png")

	self.limitText = publ_getItemFromTree(self.m_item, {"Button1","View1","Text1"})
	self.onlineUserText = publ_getItemFromTree(self.m_item, {"Button1","View2","Text1"})

	self.bgBtn:setOnClick(self, self.enterRoomClick);

	if DEBUGMODE == 1 then
		self.typeName = UICreator.createText("",0,0,0,0,kAlignTopLeft,40,255,255,255);
		self.bgBtn:addChild( self.typeName );
	end
	DebugLog("-----------------------------------create");
end

--number4Pin_map["1.png"]

--[[
	data:
		time:出牌时间
		value:底注
		uppermost:房间上限
		level :房间level
		require:房间准入金币
		xlch:是否血流场 1 true
		dq:是否定缺场 1 true
		hsz:是否换三张 1 true
		lfp:是否两房牌 1 true
		hlz:是否换两张 1 true
]]
XlchRoomItem.setData = function ( self, data )
	if not data then
		return;
	end
	--self:clearData();--------------------
	mahjongPrint(data)

	self.limit 		= data.require or 0;
	self.name 		= data.name or ""
	self.onlineText = data.onlineText or "人在线";
	--self.desc 		= data.desc
	self.nameUrl 	= data.nameUrl or ""
	--self.sub 		= data.sub---
	self.level 		= data.level or 0
	self.di         = data.di or 0

    self.uppermost = data.uppermost or 0;
	
	local limitDesc = nil
--	if self.limit >= 10000 then
--		limitDesc = math.ceil(self.limit/10000) .. "万金币准入"
--	else
--		limitDesc = self.limit .. "金币准入" 
--	end 
    if self.uppermost >= 2000000000 then
        limitDesc = trunNumberIntoThreeOneFormWithInt(self.limit, true, true) .. "金币以上"
    else
        limitDesc = trunNumberIntoThreeOneFormWithInt(self.limit, true, true) .. "-"..trunNumberIntoThreeOneFormWithInt(self.uppermost, true, true);
        limitDesc = (limitDesc and limitDesc.."金币")or "" ;
    end


	self.limitText:setText(limitDesc or "");
	self.onlineUserText:setText( (self.onlineNum or 0) .. (data.onlineText or "人在玩") )-- 这个数据要通过socket获得
	self.dataFinish = true;

	local isExist, localDir = NativeManager.getInstance():downloadImage(self.nameUrl);
    self.nameUrlDir = localDir;
    if isExist then
        self.roomNameImg:setFile(self.nameUrlDir);
    end

    --
    --self.diNumImg
    local node = setMoney3Node(self.di, self.diNumImg, number4Pin_map)
    local w,h = node:getSize()
    self.midView:setSize(44+8+w, 64)
    --local w1,h1 = self.mid:getSize()


    if DEBUGMODE == 1 then
		self.typeName:setText( self.level .. "" );
	end

 --    if self.sub and tonumber(self.sub) then

 --        local isub = tonumber(self.sub)
 --        if isub > 0 and isub < 7 then 
 --            local path = "newHall/roomItem/activity";
 --            path = path .. tonumber(self.sub) .. ".png"



	-- 		if self.tagImage then
	-- 			self.bgBtn:removeChild(self.tagImage,true)
	-- 			self.tagImage = nil
	-- 		end            

	-- 		local filename = path
	-- 		local x,y,rx = 10,0,0

			
	-- 		if filename then
	-- 			self.tagImage = UICreator.createImg(filename, 0, 0 );
	-- 			self.bgBtn:addChild(self.tagImage);
	-- 			self.tagImage:setAlign(kAlignTopRight)
	-- 			self.tagImage:setPos(x,y)


	-- 			local iCount = #self.userDefineAnim;
	--             --math.randomseed(tostring(os.time()):reverse():sub(1,9)); -- 短时间内保证产生的随机数尽量不一致
	--             local rdId = math.random();
	--             if rdId <= 0.25 then
	--                 rdId = 1;
	--             elseif  rdId > 0.25 and rdId <= 0.5 then
	--                 rdId = 2;
	--             elseif  rdId > 0.5 and rdId <= 0.75 then
	--                 rdId = 3;
	--             else
	--                 rdId = 4;
	--             end
	--             local width = select(1, self.tagImage:getSize());
	--             local RotateAnim =  self.tagImage:addPropRotate(0, kAnimLoop, 1800, self.userDefineAnim[rdId].delayTime, 
	--                     self.userDefineAnim[rdId].startValue, self.userDefineAnim[rdId].endValue, kCenterXY, width / 2 + rx, 0);
	--             RotateAnim:setDebugName("GameRoomItem RotateAnim");
	-- 		end
	-- 	end 
	-- end

	
end


XlchRoomItem.getLevel = function ( self )
	if not self.dataFinish then
		DebugLog("  get type failed, room item data is nil");
		return 0;
	end
	return self.level;
end




XlchRoomItem.setCallback = function ( self, obj, fun )
	self.obj = obj;
	self.callback = fun;
end

XlchRoomItem.enterRoomClick = function ( self )
	self:reportRoomItemClick();
	if self.obj and self.callback then
		self.callback(self.obj);
	end
end

XlchRoomItem.reportRoomItemClick = function ( self )
	--[[local roomItemTable = {Umeng_ScreenChuJi , Umeng_ScreenZhongJi,Umeng_ScreenGaoJi,Umeng_ScreenDaShi,Umeng_ScreenXueZhan,Umeng_ScreenXueLiu};
	if roomItemTable[self.num] then
		DebugLog(roomItemTable[self.num]);
		umengStatics_lua(roomItemTable[self.num]);
	end]]--
end

XlchRoomItem.setOnlineNum = function ( self, num )
	if not num then
		return;
	end
	self.onlineNum = num;
	if self.onlineUserText then 
		self.onlineUserText:setText((self.onlineNum or 0) .. (self.onlineText or "人在线")); -- 这个数据要通过socket获得
	end 
end

function XlchRoomItem.nativeCallEvent(self, param, _detailData)
	if kDownloadImageOne == param then
		if _detailData == self.nameUrlDir then
			self:downloadImgSuccess( self.nameUrlDir );
		end
	end
end

function XlchRoomItem.downloadImgSuccess(self, name)
	if name ~= nil then
		self.roomNameImg:setFile(name);
	end
end

XlchRoomItem.dtor = function ( self )
	self.userDefineAnim = nil
	self:removeAllChildren();
	self.onlineUserText = nil
	EventDispatcher.getInstance():unregister(NativeManager._Event, self, self.nativeCallEvent);
end

