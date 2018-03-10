local pswInputLayout=
{
	name="pswInputLayout",type=0,typeName="View",time=0,x=0,y=0,width=500,height=250,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,
	{
		name="bg",type=1,typeName="Image",time=32085854,x=0,y=0,width=500,height=250,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="Commonx/pop_window_small.png",gridLeft=20,gridRight=20,gridTop=60,gridBottom=20
	},
	{
		name="title",type=4,typeName="Text",time=32085905,x=0,y=23,width=0,height=0,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,fontSize=40,textAlign=kAlignCenter,colorRed=250,colorGreen=240,colorBlue=200,string=[[输入密码]]
	},
	{
		name="inputBg",type=1,typeName="Image",time=32085963,x=0,y=85,width=415,height=55,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="Commonx/text_editor_bg2.png",gridLeft=20,gridRight=20,gridTop=20,gridBottom=20,
		{
			name="pswInput",type=6,typeName="EditText",time=32086347,x=0,y=0,width=300,height=35,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=30,textAlign=kAlignCenter,colorRed=173,colorGreen=158,colorBlue=149
		}
	},
	{
		name="confirm",type=2,typeName="Button",time=32086146,x=0,y=25,width=156,height=62,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottom,file="Commonx/green_small_btn.png",gridTop=35,gridBottom=35,
		{
			name="confirn",type=4,typeName="Text",time=32086259,x=0,y=-4,width=0,height=0,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=34,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[确定]]
		}
	},
	{
		name="cancel",type=2,typeName="Button",time=32086153,x=-20,y=-20,width=66,height=70,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopRight,file="Commonx/close_btn.png",file2="Commonx/close_btn_disable.png"
	}
}
return pswInputLayout;