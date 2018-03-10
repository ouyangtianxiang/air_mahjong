local seatPinx_map = require("qnPlist/seatPinx");
local FMRroomPlayerInfo=
{
	name="FMRroomPlayerInfo",type=0,typeName="View",time=0,x=0,y=0,width=160,height=80,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,
	{
		name="img_player_info",type=0,typeName="View",time=114094329,x=0,y=0,width=160,height=80,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,
		{
			name="view_1",type=0,typeName="View",time=114094330,x=0,y=4,width=160,height=34,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,
			{
				name="img_icon_sex",type=1,typeName="Image",time=114094331,x=0,y=0,width=35,height=34,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,file="Commonx/female.png"
			},
			{
				name="text_name",type=4,typeName="Text",time=114094332,x=40,y=0,width=110,height=35,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,fontSize=22,textAlign=kAlignLeft,colorRed=255,colorGreen=255,colorBlue=255
			}
		},
		{
			name="view_2",type=0,typeName="View",time=114094333,x=0,y=46,width=160,height=34,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,
			{
				name="Image1",type=1,typeName="Image",time=114094349,x=0,y=0,width=160,height=34,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,file=seatPinx_map['matchScoreBg.png'],packFile="MahjongPinTu/seatPinx.lua",gridLeft=40,gridRight=20,gridTop=17,gridBottom=17
			},
			{
				name="img_icon_coin",type=1,typeName="Image",time=114094365,x=-2,y=0,width=40,height=40,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,file="Commonx/blank.png"
			},
			{
				name="text_coin",type=4,typeName="Text",time=114094385,x=40,y=0,width=105,height=35,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,fontSize=22,textAlign=kAlignLeft,colorRed=255,colorGreen=255,colorBlue=255
			}
		}
	}
}
return FMRroomPlayerInfo;