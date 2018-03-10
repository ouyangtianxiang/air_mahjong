local friendRemarkWindow=
{
	name="friendRemarkWindow",type=0,typeName="View",time=0,x=0,y=0,width=1280,height=800,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,
	{
		name="img_win_bg",type=1,typeName="Image",time=51435238,x=0,y=0,width=632,height=426,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="Commonx/pop_window_small.png",
		{
			name="img_edit_bg",type=1,typeName="Image",time=51436862,x=0,y=169,width=500,height=72,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="Commonx/text_editor_bg2.png",gridLeft=20,gridRight=20,
			{
				name="et_alias",type=7,typeName="EditTextView",time=57314664,x=10,y=0,width=480,height=64,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,fontSize=30,textAlign=kAlignLeft,colorRed=173,colorGreen=158,colorBlue=149
			}
		},
		{
			name="view_title",type=0,typeName="View",time=51437228,x=0,y=0,width=600,height=85,visible=1,fillParentWidth=1,fillParentHeight=0,nodeAlign=kAlignTopLeft,
			{
				name="text_title",type=4,typeName="Text",time=51437278,x=0,y=5,width=164,height=46,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=40,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[添加备注]]
			}
		},
		{
			name="btn_close",type=2,typeName="Button",time=51852720,x=-20,y=-20,width=66,height=70,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopRight,file="Commonx/close_btn.png",file2="Commonx/close_btn_disable.png"
		},
		{
			name="btn_left",type=2,typeName="Button",time=53773437,x=-135,y=35,width=222,height=74,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottom,file="Commonx/green_big_wide_btn.png",
			{
				name="text_name",type=4,typeName="Text",time=53773441,x=0,y=-4,width=0,height=0,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=34,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[取 消]]
			}
		},
		{
			name="btn_right",type=2,typeName="Button",time=53773443,x=135,y=35,width=222,height=74,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottom,file="Commonx/red_big_wide_btn.png",
			{
				name="text_name",type=4,typeName="Text",time=53773447,x=0,y=-4,width=0,height=0,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=36,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[确 认]]
			}
		}
	}
}
return friendRemarkWindow;