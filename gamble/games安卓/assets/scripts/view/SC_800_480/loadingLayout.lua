local LoadingPin_map = require("qnPlist/LoadingPin");
local loadingLayout=
{
	name="loadingLayout",type=0,typeName="View",time=0,x=0,y=0,width=1280,height=800,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,
	{
		name="img_bg",type=1,typeName="Image",time=53609575,x=0,y=0,width=404,height=252,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file=LoadingPin_map['loading_bg.png'],packFile="MahjongPinTu/LoadingPin.lua",
		{
			name="btn_close",type=2,typeName="Button",time=53609691,x=-25,y=-25,width=66,height=70,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopRight,file="Commonx/close_btn.png",file2="Commonx/close_btn_disable.png"
		},
		{
			name="text_loading",type=4,typeName="Text",time=53609791,x=0,y=40,width=180,height=30,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottom,fontSize=30,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[正在为您登陆...]]
		},
		{
			name="view_ani",type=0,typeName="View",time=53659552,x=0,y=-15,width=100,height=100,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter
		}
	}
}
return loadingLayout;