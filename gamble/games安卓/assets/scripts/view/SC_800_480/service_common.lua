local service_common=
{
	name="service_common",type=0,typeName="View",time=0,x=0,y=0,width=0,height=0,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignLeft,
	{
		name="return_bg",type=2,typeName="Button",time=92980595,x=18,y=20,width=80,height=82,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="Commonx/return_btn.png"
	},
	{
		name="mainContent",type=0,typeName="View",time=92987938,x=0,y=0,width=0,height=720,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,
		{
			name="bg",type=1,typeName="Image",time=92987992,x=40,y=110,width=1212,height=592,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="Bgx/bg2.png",gridLeft=50,gridRight=50,gridTop=50,gridBottom=50,
			{
				name="top_view",type=1,typeName="Image",time=92988110,x=0,y=-76,width=304,height=76,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="Commonx/tag_bg.png",
				{
					name="top_bg",type=1,typeName="Image",time=92988111,x=0,y=0,width=304,height=76,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="Commonx/tag_red.png"
				},
				{
					name="top_text",type=4,typeName="Text",time=92988112,x=0,y=0,width=0,height=0,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=36,textAlign=kAlignLeft,colorRed=255,colorGreen=255,colorBlue=255
				}
			}
		}
	}
}
return service_common;