local changeNicknameWnd=
{
	name="changeNicknameWnd",type=0,typeName="View",time=0,x=0,y=0,width=1280,height=800,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,
	{
		name="img_bg",type=1,typeName="Image",time=85051887,x=0,y=0,width=632,height=346,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="Commonx/pop_window_small.png",gridLeft=50,gridRight=50,gridTop=50,gridBottom=50,
		{
			name="btn_close",type=2,typeName="Button",time=85051949,x=-15,y=-15,width=66,height=70,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopRight,file="Commonx/close_btn.png",file2="Commonx/close_btn_disable.png"
		},
		{
			name="text_title",type=4,typeName="Text",time=85052085,x=0,y=-130,width=156,height=39,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=40,textAlign=kAlignLeft,colorRed=255,colorGreen=255,colorBlue=255,string=[[修改昵称]]
		},
		{
			name="img_nickname_bg",type=1,typeName="Image",time=85052178,x=0,y=-30,width=520,height=64,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="Commonx/text_editor_bg2.png",gridLeft=25,gridRight=25,gridTop=25,gridBottom=25,
			{
				name="text_nickname",type=7,typeName="EditTextView",time=86938720,x=0,y=0,width=500,height=0,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=34,textAlign=kAlignLeft,colorRed=173,colorGreen=158,colorBlue=149
			}
		},
		{
			name="text_left_change_tips",type=4,typeName="Text",time=85052247,x=0,y=30,width=320,height=20,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=22,textAlign=kAlignLeft,colorRed=75,colorGreen=43,colorBlue=28,string=[[修改昵称修改昵称修改昵称修改昵称]]
		},
		{
			name="btn_ok",type=2,typeName="Button",time=85052310,x=0,y=90,width=222,height=74,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="Commonx/green_big_wide_btn.png",
			{
				name="text_btn_ok",type=4,typeName="Text",time=85052398,x=0,y=-5,width=0,height=0,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=36,textAlign=kAlignLeft,colorRed=255,colorGreen=255,colorBlue=255,string=[[确  认]]
			}
		}
	}
}
return changeNicknameWnd;