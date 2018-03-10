local voicePin_map = require("qnPlist/voicePin");
local voiceRecordTip=
{
	name="voiceRecordTip",type=0,typeName="View",time=0,x=0,y=0,width=190,height=190,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,
	{
		name="bg",type=1,typeName="Image",time=0,x=0,y=0,width=190,height=190,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="Room/voice/tipBg.png",
		{
			name="text",type=4,typeName="Text",time=0,x=0,y=15,width=0,height=0,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottom,fontSize=20,textAlign=kAlignLeft,colorRed=255,colorGreen=255,colorBlue=255,string=[[手指上滑，取消发送]],colorA=1
		},
		{
			name="left",type=1,typeName="Image",time=0,x=25,y=-10,width=66,height=90,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,file=voicePin_map['btn.png']
		},
		{
			name="animImg",type=1,typeName="Image",time=0,x=25,y=-10,width=52,height=86,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignRight,file=voicePin_map['record1.png']
		}
	},
	{
		name="cancelView",type=0,typeName="View",time=0,x=115,y=432,width=100,height=100,visible=0,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTopLeft,
		{
			name="red",type=1,typeName="Image",time=0,x=0,y=0,width=190,height=44,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottom,file=voicePin_map['red.png']
		},
		{
			name="text8",type=4,typeName="Text",time=0,x=0,y=15,width=0,height=0,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottom,fontSize=20,textAlign=kAlignLeft,colorRed=255,colorGreen=255,colorBlue=255,string=[[松开手指，取消发送]],colorA=1
		},
		{
			name="Image9",type=1,typeName="Image",time=0,x=0,y=-15,width=76,height=100,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file=voicePin_map['cancel.png']
		}
	}
}
return voiceRecordTip;