local compartmentListItem=
{
	name="compartmentListItem",type=0,typeName="View",time=0,x=0,y=0,width=1129,height=101,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,
	{
		name="bg",type=1,typeName="Image",time=92288879,x=0,y=0,width=1129,height=101,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="Hall/compartment/item_bg.png",
		{
			name="lock",type=1,typeName="Image",time=92289328,x=25,y=-2,width=30,height=34,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,file="Hall/compartment/lock.png"
		},
		{
			name="name",type=4,typeName="Text",time=92289402,x=70,y=-2,width=245,height=0,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,fontSize=30,textAlign=kAlignLeft,colorRed=75,colorGreen=43,colorBlue=28
		},
		{
			name="di",type=4,typeName="Text",time=92289481,x=330,y=-2,width=230,height=0,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,fontSize=30,textAlign=kAlignCenter,colorRed=148,colorGreen=50,colorBlue=0,string=[[5000]]
		},
		{
			name="num",type=4,typeName="Text",time=92290098,x=560,y=-2,width=240,height=0,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,fontSize=30,textAlign=kAlignCenter,colorRed=75,colorGreen=43,colorBlue=28,string=[[1 / 4]]
		},
		{
			name="play",type=0,typeName="View",time=92290298,x=0,y=0,width=320,height=101,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignRight,
			{
				name="que",type=1,typeName="Image",time=92290378,x=-75,y=0,width=54,height=56,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="Hall/compartment/que.png"
			},
			{
				name="liu",type=1,typeName="Image",time=92290405,x=-5,y=0,width=54,height=56,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="Hall/compartment/liu.png"
			},
			{
				name="san",type=1,typeName="Image",time=92290407,x=65,y=0,width=54,height=56,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="Hall/compartment/san.png"
			}
		}
	}
}
return compartmentListItem;