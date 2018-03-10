local friendMessage=
{
	name="friendMessage",type=0,typeName="View",time=0,x=0,y=0,width=1280,height=720,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTopLeft,
	{
		name="content",type=0,typeName="View",time=99369571,x=0,y=-6,width=1182,height=540,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignCenter,fillTopLeftX=20,fillBottomRightX=20,fillTopLeftY=15,fillBottomRightY=30,
		{
			name="listview",type=0,typeName="ScrollView",time=99369572,x=0,y=25,width=1120,height=485,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignCenter,fillTopLeftY=50,fillTopLeftX=0,fillBottomRightX=0,fillBottomRightY=0
		},
		{
			name="listview_sys",type=0,typeName="ListView",time=99385195,x=0,y=25,width=1120,height=484,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignCenter,fillTopLeftY=50,fillTopLeftX=0,fillBottomRightX=0,fillBottomRightY=0
		},
		{
			name="empty_tip_text",type=4,typeName="Text",time=99385211,x=0,y=0,width=0,height=0,visible=0,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=26,textAlign=kAlignLeft,colorRed=255,colorGreen=255,colorBlue=255,string=[[暂无动态消息]],colorA=1
		},
		{
			name="tip",type=1,typeName="Image",time=99385595,x=0,y=0,width=1118,height=38,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="Commonx/while_half.png",gridLeft=15,gridRight=15,gridTop=15,gridBottom=15,
			{
				name="Text1",type=4,typeName="Text",time=99385895,x=0,y=0,width=0,height=0,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=26,textAlign=kAlignLeft,colorRed=255,colorGreen=255,colorBlue=255,string=[[只保留15天内最近的100条记录!]]
			}
		}
	}
}
return friendMessage;