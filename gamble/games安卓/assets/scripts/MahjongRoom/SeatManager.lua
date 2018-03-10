require("MahjongRoom/Seat");
SeatManager = class();

SeatManager.ctor = function ( self , _root, inMatchRoom )
	DebugLog("SeatManager ctor");
	self.root = _root;
	self.seatList = {};
	self.inMatchRoom = inMatchRoom or false;
end

SeatManager.getSeatList = function ( self )
	return self.seatList;
end

SeatManager.changeToStartGameStatu = function ( self, bNeedAnim )
	for k,v in pairs(self.seatList) do
		v:changeToIngameStatu(bNeedAnim);
	end
end

SeatManager.gameFinish = function ( self )
	for k,v in pairs(self.seatList) do
		v:gameFinish();
	end
end

SeatManager.changeToWaittingStatu = function ( self )
	for k,v in pairs(self.seatList) do
		v:changeToWaitStaty();
	end
end

SeatManager.getSeatByLocalSeatID = function ( self, seatID)
	if not self.seatList[seatID] then
		self.seatList[seatID] = new(Seat, seatID , self.root, self.inMatchRoom);
	end
	return self.seatList[seatID];
end

SeatManager.dtor = function ( self )
	DebugLog("SeatManager dtor");
	for k,v in pairs(self.seatList) do
		delete(v);
	end
	self.seatList = nil;
end

