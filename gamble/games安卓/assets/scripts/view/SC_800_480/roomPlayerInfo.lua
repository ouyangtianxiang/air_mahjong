local seatPinx_map = require("qnPlist/seatPinx");
local roomPlayerInfo=
{
	name="roomPlayerInfo",type=0,typeName="View",time=0,x=0,y=0,width=160,height=80,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,
	{
		name="img_player_info",type=0,typeName="View",time=94284573,x=0,y=0,width=160,height=80,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,
		{
			name="view_1",type=0,typeName="View",time=94284594,x=0,y=4,width=160,height=34,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,
			{
				name="img_icon_sex",type=1,typeName="Image",time=94284595,x=0,y=0,width=35,height=34,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,file="Commonx/female.png"
			},
			{
				name="text_name",type=4,typeName="Text",time=94284596,x=40,y=0,width=110,height=35,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,fontSize=22,textAlign=kAlignLeft,colorRed=255,colorGreen=255,colorBlue=255
			}
		},
		{
			name="view_2",type=0,typeName="View",time=94284596,x=0,y=46,width=160,height=34,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,
			{
				name="Image1",type=1,typeName="Image",time=94284828,x=0,y=0,width=154,height=34,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file=seatPinx_map['scoring_bg.png'],packFile="MahjongPinTu/seatPinx.lua"
			},
			{
				name="img_icon_coin",type=1,typeName="Image",time=94285098,x=-2,y=0,width=40,height=40,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,file="Commonx/coin.png"
			},
			{
				name="text_coin",type=4,typeName="Text",time=94285101,x=40,y=0,width=105,height=35,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,fontSize=22,textAlign=kAlignLeft,colorRed=255,colorGreen=255,colorBlue=255
			}
		}
	}
}
return roomPlayerInfo;