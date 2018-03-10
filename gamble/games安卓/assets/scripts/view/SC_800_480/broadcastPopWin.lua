local broadcastPopWin=
{
	name="broadcastPopWin",type=0,typeName="View",time=0,x=0,y=0,width=1280,height=720,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,
	{
		name="img_bg",type=1,typeName="Image",time=76126862,x=0,y=0,width=860,height=584,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="Commonx/bg1.png",gridLeft=30,gridRight=30,gridTop=30,gridBottom=30,
		{
			name="img_inner_bg",type=1,typeName="Image",time=101533163,x=0,y=-80,width=830,height=395,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="Commonx/inner1.png",gridLeft=15,gridRight=15,gridTop=15,gridBottom=15
		},
		{
			name="btn_close",type=2,typeName="Button",time=101533196,x=-24,y=-24,width=66,height=70,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopRight,file="Commonx/close_btn.png",file2="Commonx/close_btn_disable.png"
		},
		{
			name="Image1",type=1,typeName="Image",time=101533201,x=15,y=420,width=830,height=140,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="Commonx/text_editor_bg2.png",gridLeft=20,gridRight=20,gridTop=20,gridBottom=20,
			{
				name="ScrollView1",type=0,typeName="ScrollView",time=101534615,x=0,y=0,width=830,height=110,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTopLeft
			}
		}
	}
}
return broadcastPopWin;