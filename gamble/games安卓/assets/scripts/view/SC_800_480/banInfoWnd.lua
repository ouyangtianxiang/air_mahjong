local banInfoWnd=
{
	name="banInfoWnd",type=0,typeName="View",time=0,x=0,y=0,width=1280,height=800,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,
	{
		name="img_bg",type=1,typeName="Image",time=85822285,x=0,y=0,width=500,height=350,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="Commonx/pop_window_small.png",gridLeft=50,gridRight=50,gridTop=50,gridBottom=50,
		{
			name="btn_ok",type=2,typeName="Button",time=85822635,x=0,y=120,width=180,height=70,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="Commonx/green_small_btn.png",
			{
				name="text_btn_ok",type=4,typeName="Text",time=85822678,x=0,y=-4,width=0,height=0,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=27,textAlign=kAlignLeft,colorRed=255,colorGreen=255,colorBlue=255,string=[[确定]]
			}
		},
		{
			name="text_title",type=4,typeName="Text",time=85824282,x=0,y=-135,width=0,height=0,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=34,textAlign=kAlignLeft,colorRed=255,colorGreen=255,colorBlue=255,string=[[温馨提示]]
		},
		{
			name="img_inner_bg",type=0,typeName="View",time=94717054,x=0,y=-10,width=430,height=180,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,
			{
				name="text_tips",type=5,typeName="TextView",time=94717087,x=0,y=0,width=420,height=160,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=24,textAlign=kAlignLeft,colorRed=255,colorGreen=255,colorBlue=255
			}
		}
	}
}
return banInfoWnd;