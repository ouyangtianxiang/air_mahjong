local chatWindow=
{
	name="chatWindow",type=0,typeName="View",time=0,x=0,y=0,width=1280,height=800,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,
	{
		name="bg",type=1,typeName="Image",time=54803751,x=0,y=0,width=862,height=544,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="Hall/chat/bg.png",gridLeft=40,gridRight=40,gridTop=100,gridBottom=40,
		{
			name="closeBtn",type=2,typeName="Button",time=54803879,x=-15,y=-15,width=66,height=70,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopRight,file="Commonx/close_btn.png",file2="Commonx/close_btn_disable.png"
		},
		{
			name="title",type=4,typeName="Text",time=54804717,x=0,y=27,width=300,height=40,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,fontSize=40,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255
		},
		{
			name="chat_content",type=0,typeName="View",time=91529869,x=15,y=142,width=832,height=300,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft
		},
		{
			name="chatEditBg",type=1,typeName="Image",time=91529877,x=15,y=455,width=662,height=64,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="Commonx/text_editor_bg2.png",gridLeft=20,gridRight=20,
			{
				name="edit",type=7,typeName="EditTextView",time=91529878,x=0,y=0,width=592,height=40,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=34,textAlign=kAlignLeft,colorRed=173,colorGreen=158,colorBlue=149,colorA=1
			}
		},
		{
			name="send",type=2,typeName="Button",time=91529879,x=20,y=458,width=156,height=62,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopRight,file="Commonx/green_small_btn.png",
			{
				name="button_title",type=4,typeName="Text",time=91529880,x=0,y=-4,width=0,height=0,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=36,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[发 送]]
			}
		}
	}
}
return chatWindow;