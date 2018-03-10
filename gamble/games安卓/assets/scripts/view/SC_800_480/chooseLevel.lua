local chooseLevel=
{
	name="chooseLevel",type=0,typeName="View",time=0,x=0,y=0,width=1280,height=720,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTopLeft,
	{
		name="bg",type=1,typeName="Image",time=90646620,x=34,y=120,width=1212,height=550,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="Hall/chooseLevel/bg.png",gridLeft=60,gridRight=60,gridTop=60,gridBottom=60,
		{
			name="Image1",type=1,typeName="Image",time=90646761,x=0,y=-76,width=386,height=78,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="Hall/chooseLevel/game_tag.png"
		},
		{
			name="Button1",type=2,typeName="Button",time=90647000,x=0,y=-50,width=362,height=134,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottom,file="Hall/hallComon/quickStart.png"
		},
		{
			name="ListView1",type=0,typeName="ScrollView",time=90731092,x=55,y=90,width=1100,height=360,visible=1,fillParentWidth=1,fillParentHeight=0,nodeAlign=kAlignTopLeft,fillTopLeftX=50,fillBottomRightX=50,fillTopLeftY=90,fillBottomRightY=100
		}
	},
	{
		name="return_btn",type=2,typeName="Button",time=90665040,x=40,y=20,width=80,height=82,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="Commonx/return_btn.png"
	}
}
return chooseLevel;