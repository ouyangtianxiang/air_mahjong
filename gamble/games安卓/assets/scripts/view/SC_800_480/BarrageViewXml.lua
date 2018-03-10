local BarrageViewXml=
{
	name="BarrageViewXml",type=0,typeName="View",time=0,x=0,y=0,width=1280,height=720,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignCenter,
	{
		name="img",type=1,typeName="Image",time=0,x=0,y=0,width=1280,height=90,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottom,file="apply/blank_1.png",
		{
			name="bg",type=1,typeName="Image",time=108876965,x=0,y=4,width=1106,height=80,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottom,file="Commonx/blank.png",
			{
				name="imgEditText",type=1,typeName="Image",time=108887081,x=0,y=0,width=1106,height=66,visible=1,fillParentWidth=1,fillParentHeight=0,nodeAlign=kAlignCenter,file="Commonx/text_editor_bg2.png",gridLeft=20,gridRight=20,gridTop=20,gridBottom=20,
				{
					name="btnSend",type=2,typeName="Button",time=108877238,x=4,y=-1,width=58,height=58,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignRight,file="apply/btn_send.png"
				},
				{
					name="editText",type=6,typeName="EditText",time=109224419,x=30,y=0,width=1003,height=65,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,fontSize=26,textAlign=kAlignLeft,colorRed=192,colorGreen=96,colorBlue=0,string=[[请输入文字]],colorA=1
				}
			}
		}
	}
}
return BarrageViewXml;