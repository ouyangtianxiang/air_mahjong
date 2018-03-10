local friendListItem=
{
	name="friendListItem",type=0,typeName="View",time=0,x=0,y=0,width=368,height=96,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,
	{
		name="bg_btn",type=2,typeName="Button",time=89438904,x=0,y=0,width=368,height=96,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="Hall/HallSocial/itemBg.png",gridLeft=20,gridRight=20,gridTop=20,gridBottom=20,
		{
			name="name_text",type=4,typeName="Text",time=89439010,x=100,y=15,width=150,height=30,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=30,textAlign=kAlignLeft,colorRed=102,colorGreen=68,colorBlue=51,string=[[殷桃小丸子]]
		},
		{
			name="money_text",type=4,typeName="Text",time=89439027,x=100,y=15,width=100,height=30,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottomLeft,fontSize=26,textAlign=kAlignLeft,colorRed=204,colorGreen=68,colorBlue=0,string=[[88524万]]
		},
		{
			name="send_btn",type=2,typeName="Button",time=89439593,x=10,y=0,width=70,height=70,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignRight,file="Hall/HallSocial/coin.png"
		},
		{
			name="bg",type=1,typeName="Image",time=92913207,x=5,y=-2,width=90,height=90,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,file="Hall/hallRank/head_bg.png",
			{
				name="head_img",type=1,typeName="Image",time=92913471,x=0,y=0,width=2,height=2,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="Commonx/blank.png"
			},
			{
				name="crown_img",type=1,typeName="Image",time=92913549,x=-5,y=-5,width=48,height=46,visible=0,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="Hall/HallSocial/crown1.png"
			}
		}
	}
}
return friendListItem;