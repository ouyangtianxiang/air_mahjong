local resultPin_map = require("qnPlist/resultPin");
local gameResultMatch=
{
	name="gameResultMatch",type=0,typeName="View",time=0,x=0,y=0,width=1280,height=720,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignCenter,
	{
		name="view_main",type=0,typeName="View",time=52977344,x=0,y=-20,width=1280,height=720,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,
		{
			name="btn_continue",type=2,typeName="Button",time=52979629,x=0,y=50,width=222,height=74,visible=0,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottom,file="Commonx/green_big_wide_btn.png"
		},
		{
			name="btn_continue_time",type=2,typeName="Button",time=79003928,x=150,y=40,width=222,height=74,visible=0,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottom,file="Commonx/green_big_wide_btn.png",
			{
				name="Text1",type=4,typeName="Text",time=94877747,x=0,y=-8,width=0,height=0,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=36,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[继  续]],colorA=1
			}
		},
		{
			name="btn_detail_time",type=2,typeName="Button",time=79064678,x=-150,y=40,width=222,height=74,visible=0,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottom,file="Commonx/yellow_bg_wide_btn.png",
			{
				name="Text1",type=4,typeName="Text",time=94877783,x=0,y=-8,width=0,height=0,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=36,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[详  情]]
			}
		}
	},
	{
		name="btn_close",type=2,typeName="Button",time=79068184,x=0,y=0,width=76,height=76,visible=0,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopRight,file=resultPin_map['close.png'],packFile="MahjongPinTu/resultPin.lua"
	}
}
return gameResultMatch;