local fmrFinalResultView=
{
	name="fmrFinalResultView",type=0,typeName="View",time=0,x=0,y=0,width=1280,height=720,visible=1,fillParentWidth=0,fillParentHeight=1,nodeAlign=kAlignTopLeft,
	{
		name="bg",type=1,typeName="Image",time=113563093,x=0,y=0,width=862,height=544,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="Commonx/pop_window_mid.png",
		{
			name="close",type=2,typeName="Button",time=113563130,x=-25,y=-25,width=66,height=70,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopRight,file="Commonx/close_btn.png",file2="Commonx/close_btn_disable.png"
		},
		{
			name="shareBtn",type=2,typeName="Button",time=113563898,x=0,y=50,width=222,height=74,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottom,file="Commonx/green_big_wide_btn.png",
			{
				name="Text3",type=4,typeName="Text",time=113564038,x=0,y=-4,width=0,height=0,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=36,textAlign=kAlignLeft,colorRed=255,colorGreen=255,colorBlue=255,string=[[分享战况]]
			}
		},
		{
			name="Text4",type=4,typeName="Text",time=113564099,x=0,y=10,width=0,height=72,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,fontSize=40,textAlign=kAlignLeft,colorRed=255,colorGreen=255,colorBlue=255,string=[[牌局结算]]
		}
	}
}
return fmrFinalResultView;