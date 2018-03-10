local settingPopWindow=
{
	name="settingPopWindow",type=0,typeName="View",time=0,x=0,y=0,width=1280,height=720,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignCenter,
	{
		name="img_win_bg",type=1,typeName="Image",time=51435238,x=0,y=0,width=862,height=544,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="Commonx/pop_window_mid.png",gridLeft=50,gridRight=50,gridTop=50,gridBottom=50,
		{
			name="img_win_inner_bg",type=0,typeName="View",time=90484958,x=15,y=82,width=832,height=438,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,
			{
				name="sv_info",type=0,typeName="ScrollView",time=90485042,x=2,y=10,width=916,height=450,fillTopLeftX=2,fillTopLeftY=12,fillBottomRightX=2,fillBottomRightY=12,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignCenter
			}
		},
		{
			name="View1",type=0,typeName="View",time=90485057,x=0,y=0,width=862,height=85,visible=1,fillParentWidth=1,fillParentHeight=0,nodeAlign=kAlignTopLeft,
			{
				name="Text1",type=4,typeName="Text",time=90485058,x=0,y=5,width=115,height=0,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=40,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[设   置]]
			}
		},
		{
			name="btn_close",type=2,typeName="Button",time=90485060,x=-15,y=-15,width=64,height=64,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopRight,file="Commonx/close_btn.png",file2="Commonx/close_btn_disable.png"
		}
	}
}
return settingPopWindow;