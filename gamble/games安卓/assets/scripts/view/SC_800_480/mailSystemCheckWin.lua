local mailSystemCheckWin=
{
	name="mailSystemCheckWin",type=0,typeName="View",time=0,x=0,y=0,width=0,height=0,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignCenter,
	{
		name="bg",type=1,typeName="Image",time=99391644,x=0,y=0,width=862,height=544,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="Commonx/pop_window_mid.png",
		{
			name="frame",type=1,typeName="Image",time=99391692,x=0,y=-10,width=754,height=308,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="Commonx/innerBg.png",gridLeft=15,gridRight=15,gridTop=15,gridBottom=15,
			{
				name="view2",type=0,typeName="View",time=99395510,x=25,y=20,width=700,height=270,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft
			}
		},
		{
			name="title",type=4,typeName="Text",time=99391876,x=0,y=10,width=200,height=70,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,fontSize=40,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255
		},
		{
			name="close_btn",type=2,typeName="Button",time=99391962,x=820,y=-30,width=66,height=70,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="Commonx/close_btn.png",file2="Commonx/close_btn_disable.png"
		},
		{
			name="Button2",type=2,typeName="Button",time=99392000,x=0,y=35,width=222,height=74,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottom,file="Commonx/green_big_wide_btn.png",
			{
				name="Text2",type=4,typeName="Text",time=99392056,x=0,y=-3,width=0,height=0,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=40,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[知道了]]
			}
		}
	}
}
return mailSystemCheckWin;