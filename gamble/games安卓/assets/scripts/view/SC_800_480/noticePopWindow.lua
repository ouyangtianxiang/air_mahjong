local noticePopWindow=
{
	name="noticePopWindow",type=0,typeName="View",time=0,x=0,y=0,width=1280,height=720,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,
	{
		name="win_bg",type=1,typeName="Image",time=51435238,x=0,y=0,width=862,height=544,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="Commonx/pop_window_mid.png",gridLeft=50,gridRight=50,gridTop=50,gridBottom=50,
		{
			name="win_inner_bg",type=0,typeName="View",time=93506792,x=0,y=112,width=750,height=370,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop
		},
		{
			name="view_title",type=0,typeName="View",time=93506831,x=0,y=0,width=800,height=85,visible=1,fillParentWidth=1,fillParentHeight=0,nodeAlign=kAlignTopLeft,
			{
				name="text_title",type=4,typeName="Text",time=93506832,x=0,y=5,width=164,height=46,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=40,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[系统公告]]
			}
		},
		{
			name="btn_close",type=2,typeName="Button",time=93506833,x=-20,y=-20,width=66,height=70,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopRight,file="Commonx/close_btn.png",file2="Commonx/close_btn_disable.png"
		}
	}
}
return noticePopWindow;