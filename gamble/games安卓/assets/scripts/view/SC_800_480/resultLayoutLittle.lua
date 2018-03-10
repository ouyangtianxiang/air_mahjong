local roomResultDetailPin_map = require("qnPlist/roomResultDetailPin");
local resultLayoutLittle=
{
	name="resultLayoutLittle",type=0,typeName="View",time=0,x=0,y=0,width=1280,height=720,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,
	{
		name="bg",type=1,typeName="Image",time=29904932,x=0,y=35,width=860,height=484,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file=roomResultDetailPin_map['lost_bg.png'],packFile="MahjongPinTu/roomResultDetailPin.lua",gridLeft=50,gridRight=50,gridTop=50,gridBottom=50,
		{
			name="close",type=2,typeName="Button",time=39682877,x=-20,y=-20,width=66,height=70,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopRight,file="Commonx/close_btn.png",file2="Commonx/close_btn_disable.png"
		},
		{
			name="listBg",type=1,typeName="Image",time=39680628,x=0,y=75,width=860,height=408,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file=roomResultDetailPin_map['lost_bg2.png'],packFile="MahjongPinTu/roomResultDetailPin.lua",gridLeft=30,gridRight=30,gridTop=40,gridBottom=40,
			{
				name="money_bg",type=1,typeName="Image",time=53754439,x=16,y=-29,width=828,height=55,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file=roomResultDetailPin_map['win_score_bg.png'],packFile="MahjongPinTu/roomResultDetailPin.lua",gridLeft=5,gridRight=5,gridTop=20,gridBottom=20,
				{
					name="Text2",type=4,typeName="Text",time=76154130,x=0,y=-1,width=200,height=50,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=30,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255
				}
			}
		},
		{
			name="changeTable",type=2,typeName="Button",time=53085968,x=0,y=41,width=222,height=74,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottom,file="Commonx/green_big_wide_btn.png",
			{
				name="Text1",type=4,typeName="Text",time=53085972,x=0,y=-4,width=0,height=0,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=36,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[换  桌]]
			}
		},
		{
			name="continue",type=2,typeName="Button",time=79507668,x=0,y=40,width=222,height=74,visible=0,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottom,file="Commonx/green_big_wide_btn.png",
			{
				name="Text1",type=4,typeName="Text",time=94892126,x=0,y=-4,width=0,height=0,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=36,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[继  续]]
			}
		},
		{
			name="title",type=1,typeName="Image",time=94892059,x=0,y=-85,width=479,height=156,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file=roomResultDetailPin_map['title_bg.png'],packFile="MahjongPinTu/roomResultDetailPin.lua",
			{
				name="titleStr",type=1,typeName="Image",time=94892060,x=0,y=-20,width=259,height=141,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file=roomResultDetailPin_map['title_win.png'],packFile="MahjongPinTu/roomResultDetailPin.lua"
			},
			{
				name="firework_1",type=1,typeName="Image",time=94892061,x=-11,y=-28,width=142,height=141,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file=roomResultDetailPin_map['firework_1.png'],packFile="MahjongPinTu/roomResultDetailPin.lua"
			},
			{
				name="firework_2",type=1,typeName="Image",time=94892062,x=-8,y=13,width=132,height=132,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopRight,file=roomResultDetailPin_map['firework_2.png'],packFile="MahjongPinTu/roomResultDetailPin.lua"
			},
			{
				name="wind",type=1,typeName="Image",time=94892063,x=0,y=10,width=538,height=168,visible=0,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottom,file=roomResultDetailPin_map['br_dialog_title_decorate.png'],packFile="MahjongPinTu/roomResultDetailPin.lua"
			}
		}
	}
}
return resultLayoutLittle;