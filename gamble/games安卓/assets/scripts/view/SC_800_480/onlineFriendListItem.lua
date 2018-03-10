local onlineFriendListItem=
{
	name="onlineFriendListItem",type=0,typeName="View",time=0,x=0,y=0,width=410,height=115,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,
	{
		name="head_bg",type=1,typeName="Image",time=0,x=12,y=0,width=90,height=90,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,file="Hall/hallRank/head_bg.png",
		{
			name="head",type=1,typeName="Image",time=0,x=0,y=0,width=2,height=2,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="Commonx/blank.png"
		}
	},
	{
		name="name",type=4,typeName="Text",time=0,x=110,y=47,width=0,height=0,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=20,textAlign=kAlignLeft,colorRed=75,colorGreen=43,colorBlue=28,colorA=1
	},
	{
		name="invite",type=1,typeName="Button",time=0,x=15,y=5,width=156,height=62,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignRight,file="Commonx/green_small_btn.png",
		{
			name="Text6",type=4,typeName="Text",time=0,x=0,y=-4,width=0,height=0,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=30,textAlign=kAlignLeft,colorRed=255,colorGreen=255,colorBlue=255,string=[[邀 请]],colorA=1
		}
	},
	{
		name="Image6",type=1,typeName="Image",time=0,x=0,y=0,width=365,height=2,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottom,file="Commonx/split_hori.png"
	}
}
return onlineFriendListItem;