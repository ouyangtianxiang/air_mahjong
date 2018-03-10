local voicePin_map = require("qnPlist/voicePin");
local voicePlayTip=
{
	name="voicePlayTip",type=0,typeName="View",time=0,x=0,y=0,width=110,height=46,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,
	{
		name="bg",type=1,typeName="Image",time=0,x=0,y=0,width=110,height=46,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file=voicePin_map['msgBg.png'],
		{
			name="animImg",type=1,typeName="Image",time=0,x=20,y=0,width=16,height=24,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,file=voicePin_map['play03.png']
		},
		{
			name="right",type=4,typeName="Text",time=0,x=5,y=-2,width=0,height=0,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignRight,fontSize=20,textAlign=kAlignRight,colorRed=0,colorGreen=153,colorBlue=51,string=[[6'']],colorA=1
		},
		{
			name="tip",type=1,typeName="Image",time=0,x=-10,y=-10,width=26,height=26,visible=0,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopRight,file="Commonx/tip.png",
			{
				name="text",type=4,typeName="Text",time=0,x=0,y=0,width=26,height=26,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=16,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[1]],colorA=1
			}
		}
	}
}
return voicePlayTip;