local resultPin_map = require("qnPlist/resultPin");
local gameResult=
{
	name="gameResult",type=0,typeName="View",time=0,x=0,y=0,width=1280,height=720,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignCenter,
	{
		name="btn_close",type=2,typeName="Button",time=52977247,x=0,y=0,width=76,height=76,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopRight,file=resultPin_map['close.png'],packFile="MahjongPinTu/resultPin.lua"
	},
	{
		name="view_main",type=0,typeName="View",time=52977344,x=0,y=-118,width=1280,height=720,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,
		{
			name="btn_again",type=2,typeName="Button",time=52979629,x=150,y=-10,width=222,height=74,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottom,file="Commonx/green_big_wide_btn.png",
			{
				name="Text1",type=4,typeName="Text",time=52979633,x=0,y=-4,width=0,height=0,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=36,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[再来一局]]
			}
		},
		{
			name="btn_detail",type=2,typeName="Button",time=52979635,x=-150,y=-10,width=222,height=74,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottom,file="Commonx/yellow_bg_wide_btn.png",
			{
				name="Text1",type=4,typeName="Text",time=52979639,x=0,y=-4,width=0,height=0,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=36,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[查看详情]]
			}
		}
	},
	{
		name="view_share",type=0,typeName="View",time=62835855,x=860,y=100,width=140,height=140,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,
		{
			name="img_share_shine",type=1,typeName="Image",time=62835969,x=0,y=0,width=138,height=138,visible=0,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file=resultPin_map['share_shine.png'],packFile="MahjongPinTu/resultPin.lua"
		},
		{
			name="btn_share",type=2,typeName="Button",time=61007351,x=0,y=0,width=138,height=138,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file=resultPin_map['share.png'],packFile="MahjongPinTu/resultPin.lua"
		}
	}
}
return gameResult;