local button_pin=
{
	name="button_pin",type=0,typeName="View",time=0,x=0,y=0,width=1280,height=720,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTopLeft,
	{
		name="btn_confirm",type=2,typeName="Button",time=53231705,x=165,y=0,width=156,height=62,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="Commonx/green_small_btn.png",
		{
			name="Text1",type=4,typeName="Text",time=53231709,x=0,y=-4,width=0,height=0,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=32,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[确定]]
		}
	},
	{
		name="btn_rechoose",type=2,typeName="Button",time=53233456,x=0,y=0,width=156,height=62,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="Commonx/yellow_small_btn.png",
		{
			name="Text1",type=4,typeName="Text",time=53233460,x=0,y=-4,width=0,height=0,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=32,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[重选]]
		}
	}
}
return button_pin;