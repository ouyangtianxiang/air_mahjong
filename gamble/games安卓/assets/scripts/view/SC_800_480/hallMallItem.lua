local hallMallItem=
{
	name="hallMallItem",type=0,typeName="View",time=0,x=0,y=0,width=258,height=354,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,
	{
		name="item_bg",type=2,typeName="Button",time=89627183,x=0,y=0,width=258,height=354,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="Hall/HallMall/item_bg.png",
		{
			name="price_text",type=4,typeName="Text",time=89627212,x=40,y=10,width=178,height=40,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=30,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[6.00元]]
		},
		{
			name="icon_img",type=1,typeName="Image",time=89627217,x=0,y=-24,width=112,height=112,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="Hall/HallMall/coin1.png"
		},
		{
			name="tips_bg_img",type=1,typeName="Image",time=89627221,x=45,y=215,width=106,height=44,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopRight,file="Hall/HallMall/tips_green.png",gridLeft=15,gridRight=80,gridTop=20,gridBottom=15,
			{
				name="tips_text",type=4,typeName="Text",time=89627222,x=9,y=4,width=88,height=30,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignRight,fontSize=22,textAlign=kAlignRight,colorRed=255,colorGreen=255,colorBlue=255,string=[[加送8%]]
			}
		},
		{
			name="name_text",type=4,typeName="Text",time=89627224,x=20,y=270,width=218,height=50,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=30,textAlign=kAlignCenter,colorRed=204,colorGreen=68,colorBlue=0,string=[[65万金币]]
		},
		{
			name="tag_img",type=1,typeName="Image",time=89627227,x=8,y=80,width=86,height=47,visible=0,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="Hall/HallMall/chaozhi.png"
		}
	}
}
return hallMallItem;