local logoutMatchLayout=
{
	name="logoutMatchLayout",type=0,typeName="View",time=0,x=0,y=0,width=1280,height=720,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTopLeft,
	{
		name="bgImage",type=1,typeName="Image",time=66391300,x=0,y=0,width=632,height=426,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="Commonx/pop_window_small.png",gridLeft=20,gridRight=20,gridTop=20,gridBottom=20,
		{
			name="txtTitle",type=4,typeName="Text",time=66391466,x=200,y=25,width=180,height=40,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=40,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[温馨提示]]
		},
		{
			name="btnOk",type=2,typeName="Button",time=66391654,x=320,y=315,width=222,height=74,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="Commonx/green_big_wide_btn.png",
			{
				name="txtOK",type=4,typeName="Text",time=66391675,x=0,y=-4,width=0,height=0,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=30,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[确定]]
			}
		},
		{
			name="btnCancel",type=2,typeName="Button",time=66391659,x=80,y=315,width=222,height=74,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="Commonx/red_big_wide_btn.png",
			{
				name="txtCancel",type=4,typeName="Text",time=66391733,x=0,y=-4,width=0,height=0,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=30,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[取消]]
			}
		},
		{
			name="framImg",type=1,typeName="Image",time=66899052,x=50,y=100,width=524,height=196,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="Room/roomActivityBg.png",gridLeft=10,gridRight=10,gridTop=10,gridBottom=10,
			{
				name="Text1",type=4,typeName="Text",time=78629879,x=0,y=-44,width=450,height=50,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=24,textAlign=kAlignCenter,colorRed=204,colorGreen=68,colorBlue=0,string=[[本场积分：150 排名：20]]
			},
			{
				name="Text2",type=4,typeName="Text",time=78629969,x=0,y=5,width=450,height=50,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=24,textAlign=kAlignCenter,colorRed=204,colorGreen=68,colorBlue=0,string=[[XXX比赛正在进行中，确定要退出吗？]]
			},
			{
				name="Text3",type=4,typeName="Text",time=78630165,x=0,y=55,width=450,height=50,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=24,textAlign=kAlignCenter,colorRed=204,colorGreen=68,colorBlue=0,string=[[请保持09：00在线且未开始其他游戏，否]]
			}
		},
		{
			name="btnClose",type=2,typeName="Button",time=66899832,x=585,y=-25,width=66,height=70,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="Commonx/close_btn.png",file2="Commonx/close_btn_disable.png"
		}
	}
}
return logoutMatchLayout;