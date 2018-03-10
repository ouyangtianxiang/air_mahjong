
-- 房间坐标

RoomCoor = {};

-- 筛子动画位置
RoomCoor.shaizhiAni = {
	x = 300,
	y = 140,
	w = 500,
	h = 500
};

RoomCoor.tuoGuanAniPos = {1280, 369};

RoomCoor.kickOutTip = {324 - 57, 255};

-- 碰 刮风 下雨 等动画位置
RoomCoor.gameAnim = {
	[SpriteConfig.TYPE_PENG] = {
		[kSeatMine] = {308,236},
		[kSeatRight] = {506,140},
		[kSeatTop] = {308,14},
		[kSeatLeft] = {78,140}
	},
	[SpriteConfig.TYPE_GUAFENG] = {
		[kSeatMine] = {294,236},
		[kSeatRight] = {506,140},
		[kSeatTop] = {294,14},
		[kSeatLeft] = {78,140}
	},
	[SpriteConfig.TYPE_XIAYU] = {
		[kSeatMine] = {294,236},
		[kSeatRight] = {506,140},
		[kSeatTop] = {294,14},
		[kSeatLeft] = {78,140}
	},
	[SpriteConfig.TYPE_CHADAJIAO] = {
		[kSeatMine] = {290,236},
		[kSeatRight] = {506,140},
		[kSeatTop] = {290,14},
		[kSeatLeft] = {78,140}
	},
	[SpriteConfig.TYPE_CHAHUAZHU] = {
		[kSeatMine] = {290,236},
		[kSeatRight] = {506,140},
		[kSeatTop] = {290,14},
		[kSeatLeft] = {78,140}
	},
	[SpriteConfig.TYPE_FANGPAO] = {
		[kSeatMine] = {308,236},
		[kSeatRight] = {506,140},
		[kSeatTop] = {308,14},
		[kSeatLeft] = {78,140}
	},

	[SpriteConfig.TYPE_ZIMO] = {
		[kSeatMine] = {294,236},
		[kSeatRight] = {506,140},
		[kSeatTop] = {294,14},
		[kSeatLeft] = {78,140}
	}
};

RoomCoor.showMoneyCoor = {
	[kSeatMine] = {100, 363},
	[kSeatRight] = {780, 219},
	[kSeatTop] = {100, 38},
	[kSeatLeft] = {10, 219}
};


RoomCoor.showTipCoor = {
	[1] = {0, 0},
	[2] = {0, 0},
	[3] = {0, 0},
};

RoomCoor.daFanXinCoor = {
	[kSeatMine] = {0,0},
	[kSeatRight]= {0,0},
	[kSeatTop] 	= {0,0},
	[kSeatLeft] = {0,0}
};

