local errorLayout=
{
	name="errorLayout",type=0,typeName="View",time=0,x=0,y=0,width=0,height=0,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTopLeft,
	{
		name="bg",type=1,typeName="Image",time=57831432,x=0,y=0,width=1280,height=800,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTopLeft,file="Loading/load_Bg.jpg"
	},
	{
		name="subWindow",type=0,typeName="View",time=57831534,x=0,y=0,width=1280,height=800,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignCenter,
		{
			name="logo",type=1,typeName="Image",time=57831602,x=0,y=55,width=427,height=460,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="Loading/load_logo.png"
		},
		{
			name="tipsBg",type=1,typeName="Image",time=57831720,x=0,y=169,width=1081,height=80,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="Loading/load_tipBg.png",
			{
				name="tip",type=4,typeName="Text",time=57833185,x=0,y=0,width=480,height=60,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=30,textAlign=kAlignCenter,colorRed=255,colorGreen=200,colorBlue=0,string=[[亲,游戏玩累了,喝杯清茶休息一会儿吧!]]
			}
		},
		{
			name="confirm",type=2,typeName="Button",time=57832214,x=0,y=290,width=222,height=74,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="Commonx/green_big_wide_btn.png",
			{
				name="confirmText",type=1,typeName="Image",time=57833614,x=0,y=0,width=145,height=84,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="Loading/cancel.png"
			}
		}
	}
}
return errorLayout;