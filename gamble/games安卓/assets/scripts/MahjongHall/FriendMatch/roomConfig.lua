
RoomConfig = class();

function RoomConfig:ctor()
	DebugLog("RoomConfig:ctor")
	
	self:initDefaultData()
end

function RoomConfig:dtor()
	DebugLog("RoomConfig:dtor")
end


function RoomConfig:initDefaultData()
	--self.rounds     		= {8,16,24}
	--self.moneys             = {80000,160000,240000}
	self.playTypes  		= {"xz","xl","lfp"}---单选的玩法
	self.checkBoxPlayTypes  = {"hsz"}-----复选的玩法"dq"
	self.dis        		= {1,2,5,10}
	self.level              = 20

	self.roundsArr          = {
		{
			costnum  = 20000,
			coststr  = "20000金币",
			costtype = 0,
			roundnum = 4,
		},
		{
			costnum  = 30000,
			coststr  = "30000金币",
			costtype = 0,
			roundnum = 8,
		},
		{
			costnum  = 50000,
			coststr  = "50000金币",
			costtype = 0,
			roundnum = 16,
		},		
		{
			costnum  = 80000,
			coststr  = "80000金币",
			costtype = 0,
			roundnum = 32,
		},				
	}
	self.ftips              = ""
	--self.costDescs          = {"80000金币","160000金币","240000金币"}
	self.mostTypes          = {6,8,0}----封顶番数
end


function RoomConfig:getMoneyByRound( roundNum )
	DebugLog("RoomConfig:getMoneyByRound"..roundNum)
	-- body
	if not roundNum then 
		return nil 
	end 

	local num = tonumber(roundNum) or 0
	for i=1,#self.roundsArr do
		if self.roundsArr[i].roundnum == num then 
			DebugLog("RoomConfig:getMoneyByRound return:"..self.roundsArr[i].costnum..",costtype:"..self.roundsArr[i].costtype)
			return self.roundsArr[i].costnum,self.roundsArr[i].costtype
		end 
	end
	return nil
end
--[[
	playType
   "10":"血战到底",
   "11":"血流成河",
   "12":"两房牌",
   "13":"换三张",
   "14":"定缺",
]]
function RoomConfig:parseNetData( data )
	if not data then 
		return 
	end 
	self.level   = tonumber(data.level or 20)

    --每次打赏数量 (四川才有)
    self.m_num_for_tip = tonumber(data.num_for_tip) or 0;
    --最低持有钻石数量(四川才有)
    self.m_min_diamand_for_tip = tonumber(data.min_diamand_for_tip) or 0;
    --单场最多打赏次数(四川才有)
    self.m_max_tiping_times = tonumber(data.max_tiping_times) or 0;
    --打赏总开关 ，1表示开(四川才有)
    self.m_reward_open = tonumber(data.switch) or 0;

	--local moneyDesc = {}--------money,roundnum,cost具有相关性  key相同的 值对应
	--封顶番薯
	if data.fengdingfan and type(data.fengdingfan) == "table" then --		self.rounds = {}
		self.mostTypes = {}
		for k,v in pairs(data.fengdingfan) do
			table.insert(self.mostTypes,tonumber(k))
		end

		table.sort(self.mostTypes,function (  a,b)
			return a < b
		end)
	end 

	--局数
	if data.detail and type(data.detail) == "table" then --		self.rounds = {}
		self.roundsArr = {}
		for k,v in pairs(data.detail) do
			local item = {}
			item.costnum = tonumber(v.cost_num)
			item.coststr = tostring(v.cost_str)
			item.costtype= tonumber(v.cost_type)
			item.roundnum= tonumber(v.round)
			table.insert(self.roundsArr,item)
		end

		table.sort(self.roundsArr,function ( a,b )
			return a.roundnum < b.roundnum
		end)
	end 

	self.ftips = data.ftips or ""
	----这里是与php约定好的
	local myMap = {
		["10"] = {"xz"  ,"playTypes"},
		["11"] = {"xl"  ,"playTypes"},
		["12"] = {"lfp" ,"playTypes"},
		["13"] = {"hsz" ,"checkBoxPlayTypes"},
		["14"] = {"dq"  ,"checkBoxPlayTypes"},
	}
	--玩法
	if data.playtype and type(data.playtype) == "table" then 
		self.playTypes = {}
		self.checkBoxPlayTypes = {}

		for k,v in pairs(myMap) do
			if data.playtype[k] then 
				table.insert(self[v[2]],1,v[1])
			end 
		end
	end 

	--底分
	if data.basepoint and type(data.basepoint) == "table" then 
		self.dis = {}
		for k,v in pairs(data.basepoint) do
			table.insert(self.dis,tonumber(k) or 0)
		end
		table.sort( self.dis )
	end 

	if #self.mostTypes > 1 and self.mostTypes[1] == 0 then 
		for i=2,#self.mostTypes do
			self.mostTypes[i-1] = self.mostTypes[i]
		end
		self.mostTypes[#self.mostTypes] = 0
	end 
end


