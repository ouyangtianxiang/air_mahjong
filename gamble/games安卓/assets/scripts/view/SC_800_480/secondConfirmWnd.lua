local secondConfirmWnd=
{
	name="secondConfirmWnd",type=0,typeName="View",time=0,x=0,y=0,width=1280,height=800,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTopLeft,
	{
		name="img_window_bg",type=1,typeName="Image",time=68110965,x=0,y=0,width=632,height=426,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="Commonx/pop_window_small.png",gridLeft=50,gridRight=50,gridTop=86,gridBottom=50,
		{
			name="btn_close",type=2,typeName="Button",time=68111038,x=-20,y=-20,width=66,height=70,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopRight,file="Commonx/close_btn.png",file2="Commonx/close_btn_disable.png"
		},
		{
			name="text_title",type=4,typeName="Text",time=68111158,x=0,y=-163,width=144,height=36,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=36,textAlign=kAlignCenter,colorRed=236,colorGreen=236,colorBlue=236,string=[[温馨提示]]
		},
		{
			name="btn_confirm",type=2,typeName="Button",time=68111504,x=0,y=152,width=222,height=74,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="Commonx/green_big_wide_btn.png",
			{
				name="text_confirm",type=4,typeName="Text",time=68111597,x=0,y=0,width=56,height=28,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=28,textAlign=kAlignLeft,colorRed=255,colorGreen=255,colorBlue=255,string=[[确定]]
			}
		},
		{
			name="img_inner",type=0,typeName="View",time=95071991,x=0,y=-10,width=560,height=250,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,
			{
				name="text_content",type=5,typeName="TextView",time=95072015,x=0,y=0,width=540,height=230,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=30,textAlign=kAlignLeft,colorRed=75,colorGreen=43,colorBlue=28
			}
		}
	}
}
return secondConfirmWnd;