local mailSystemMessageItem=
{
	name="mailSystemMessageItem",type=0,typeName="View",time=0,x=0,y=0,width=1118,height=130,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,
	{
		name="bg",type=2,typeName="Button",time=107662380,x=0,y=0,width=1118,height=120,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="Hall/task/bg.png",
		{
			name="tag",type=1,typeName="Image",time=107662438,x=10,y=0,width=48,height=88,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="Hall/chat/sys.png"
		},
		{
			name="title",type=4,typeName="Text",time=107662441,x=70,y=0,width=400,height=50,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=30,textAlign=kAlignBottomLeft,colorRed=75,colorGreen=43,colorBlue=28,string=[[系统补偿]]
		},
		{
			name="content",type=4,typeName="Text",time=107662443,x=70,y=65,width=400,height=55,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=26,textAlign=kAlignTopLeft,colorRed=148,colorGreen=50,colorBlue=0,string=[[补偿您50,000,000金币]]
		},
		{
			name="check",type=2,typeName="Button",time=107662446,x=40,y=2,width=156,height=62,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignRight,file="Commonx/green_small_btn.png",
			{
				name="text",type=4,typeName="Text",time=107662447,x=0,y=-4,width=0,height=0,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=30,textAlign=kAlignLeft,colorRed=255,colorGreen=255,colorBlue=255,string=[[查 看]]
			}
		}
	}
}
return mailSystemMessageItem;