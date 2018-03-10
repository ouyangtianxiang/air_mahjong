local matchHelpLayout=
{
	name="matchHelpLayout",type=0,typeName="View",time=0,x=0,y=0,width=0,height=0,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTopLeft,
	{
		name="bgImage",type=1,typeName="Image",time=66452498,x=209,y=88,width=862,height=544,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="Commonx/pop_window_mid.png",gridLeft=20,gridRight=20,gridTop=20,gridBottom=20,
		{
			name="txtTitle",type=4,typeName="Text",time=66452583,x=0,y=20,width=200,height=50,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,fontSize=40,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[比赛详情]]
		},
		{
			name="btnClose",type=2,typeName="Button",time=66812372,x=815,y=-25,width=66,height=70,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="Commonx/close_btn.png",file2="Commonx/close_btn_disable.png"
		},
		{
			name="helpFormBgImg",type=0,typeName="View",time=94822251,x=50,y=82,width=762,height=420,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,
			{
				name="helpScrollView",type=0,typeName="ScrollView",time=94822256,x=6,y=20,width=750,height=400,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft
			}
		}
	}
}
return matchHelpLayout;