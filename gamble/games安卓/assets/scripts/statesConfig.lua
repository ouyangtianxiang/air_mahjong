require("MahjongHall/HallState");
			
require("MahjongRoom/NormalRoom/NormalRoomState");
			
require("MahjongTeachRoom/TeachRoomState");
			
require("MahjongSingleGame/Client/SingleRoomState");
			
require("MahjongRoom/MatchRoom/MatchRoomState");
require("MahjongRoom/FriendMatchRoom/FriendMatchRoomState");	

local LoadingState   = require("ResLoading/LoadingState")
local HotUpdateState = require("ResLoading/HotUpdateState") 
States = 
{
	Hall 		= 1,
	NormalRoom  = 2,
	TeachRoom 	= 3,
	SingleRoom 	= 4,
	MatchRoom   = 5,
	FriendMatchRoom = 6,
	Loading         = 7,
	HotUpdate       = 8,
};



StatesMap = 
{
	[States.Hall] 		= HallState,
	[States.NormalRoom] = NormalRoomState,
	[States.TeachRoom] 	= TeachRoomState,
	[States.SingleRoom] = SingleRoomState,
	[States.MatchRoom]  = MatchRoomState,
	[States.FriendMatchRoom] = FriendMatchRoomState,
	[States.Loading]    = LoadingState,
	[States.HotUpdate]  = HotUpdateState,
};

function autoRequrie( stateType )
	if StatesMap[stateType] == nil then
		if stateType == States.Hall then
			require("MahjongHall/HallState");
			StatesMap[stateType] = HallState;
		elseif stateType == States.NormalRoom then
			require("MahjongRoom/NormalRoom/NormalRoomState");
			StatesMap[stateType] = NormalRoomState;
		elseif stateType == States.TeachRoom then
			require("MahjongTeachRoom/TeachRoomState");
			StatesMap[stateType] = TeachRoomState;
		elseif stateType == States.SingleRoom then
			require("MahjongSingleGame/Client/SingleRoomState");
			StatesMap[stateType] = SingleRoomState;
		elseif stateType == States.MatchRoom then
			require("MahjongRoom/MatchRoom/MatchRoomState");
			StatesMap[stateType] = MatchRoomState;
		elseif stateType == States.FriendMatchRoom then 
			StatesMap[stateType] = FriendMatchRoomState;
		elseif stateType == States.Loading then 
			StatesMap[stateType] = LoadingState
		elseif stateType == States.HotUpdate then 
			StatesMap[stateType] = HotUpdateState
		end		
	end
end


