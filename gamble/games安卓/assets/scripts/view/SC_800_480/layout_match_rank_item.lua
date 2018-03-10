local layout_match_rank_item=
{
	name="layout_match_rank_item",type=0,typeName="View",time=0,x=0,y=0,width=466,height=103,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,
	{
		name="v",type=0,typeName="View",time=0,x=0,y=0,width=0,height=0,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTopLeft,
		{
			name="t_rank",type=4,typeName="Text",time=0,x=20,y=0,width=50,height=0,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,fontSize=26,textAlign=kAlignCenter,colorRed=204,colorGreen=68,colorBlue=0,colorA=1
		},
		{
			name="head",type=1,typeName="Image",time=0,x=70,y=0,width=86,height=84,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,file="match_rank/head.png"
		},
		{
			name="t_name",type=4,typeName="Text",time=0,x=164,y=0,width=0,height=0,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,fontSize=26,textAlign=kAlignLeft,colorRed=137,colorGreen=78,colorBlue=50,colorA=1
		},
		{
			name="t_score",type=4,typeName="Text",time=0,x=15,y=0,width=95,height=0,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignRight,fontSize=26,textAlign=kAlignCenter,colorRed=204,colorGreen=68,colorBlue=0,colorA=1
		},
		{
			name="line",type=1,typeName="Image",time=0,x=0,y=1,width=70,height=2,visible=1,fillParentWidth=1,fillParentHeight=0,nodeAlign=kAlignBottom,file="Commonx/split_hori.png"
		}
	}
}
return layout_match_rank_item;