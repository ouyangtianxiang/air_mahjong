local error=
{
	name="error",type=0,typeName="View",time=0,x=0,y=0,width=0,height=0,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,
	{
		name="bg",type=1,typeName="Image",time=31807474,x=0,y=0,width=800,height=480,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="Commonx/bg.png"
	},
	{
		name="logo",type=1,typeName="Image",time=31807643,x=282,y=3,width=200,height=200,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="Loading/loading_logo.png"
	},
	{
		name="tipsBg",type=1,typeName="Image",time=34238381,x=94,y=199,width=604,height=35,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="Loading/reload_bg.png"
	},
	{
		name="tip",type=4,typeName="Text",time=31807664,x=206,y=203,width=0,height=0,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=24,textAlign=kAlignCenter,colorRed=255,colorGreen=200,colorBlue=0,string=[[出错啦！点击确定重新开始游戏。]]
	},
	{
		name="errorInfo",type=5,typeName="TextView",time=31807711,x=46,y=245,width=700,height=150,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=24,textAlign=kAlignTopLeft,colorRed=255,colorGreen=255,colorBlue=255,string=[[出错信息]]
	},
	{
		name="confirm",type=2,typeName="Button",time=31807866,x=314,y=405,width=0,height=0,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="Commonx/confirmBg.png",
		{
			name="confirmText",type=4,typeName="Text",time=31807899,x=33,y=6,width=85,height=35,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=24,textAlign=kAlignCenter,colorRed=0,colorGreen=0,colorBlue=0,string=[[确  定]]
		}
	}
}
return error;