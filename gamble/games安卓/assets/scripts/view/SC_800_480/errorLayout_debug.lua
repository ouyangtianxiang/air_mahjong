local errorLayout_debug=
{
	name="errorLayout_debug",type=0,typeName="View",time=0,x=0,y=0,width=1280,height=800,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTopLeft,
	{
		name="bg",type=1,typeName="Image",time=31807474,x=0,y=0,width=1280,height=800,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTopLeft,file="Loading/load_Bg.jpg"
	},
	{
		name="subWindow",type=0,typeName="View",time=49426070,x=0,y=0,width=1280,height=800,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignCenter,
		{
			name="confirm",type=2,typeName="Button",time=31807866,x=0,y=10,width=222,height=74,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottom,file="Commonx/green_big_wide_btn.png",
			{
				name="confirmText",type=4,typeName="Text",time=31807899,x=0,y=0,width=85,height=35,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=34,textAlign=kAlignCenter,colorRed=210,colorGreen=234,colorBlue=190,string=[[确  定]]
			}
		},
		{
			name="errorInfo",type=5,typeName="TextView",time=31807711,x=0,y=0,width=1280,height=700,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,fontSize=34,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[出错信息]]
		}
	}
}
return errorLayout_debug;