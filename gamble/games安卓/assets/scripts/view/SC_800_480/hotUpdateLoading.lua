local hotUpdateLoading=
{
	name="hotUpdateLoading",type=0,typeName="View",time=0,x=0,y=0,width=1280,height=720,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTopLeft,
	{
		name="bg",type=1,typeName="Image",time=0,x=0,y=0,width=1280,height=720,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTopLeft,file="Loading/loading.jpg",
		{
			name="text_bg",type=1,typeName="Image",time=0,x=0,y=20,width=512,height=40,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottom,file="Loading/text_bg.png",
			{
				name="Text6",type=4,typeName="Text",time=0,x=0,y=0,width=512,height=40,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=24,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[正在检查更新...]],colorA=1
			}
		},
		{
			name="progress_bg",type=1,typeName="Image",time=0,x=0,y=70,width=662,height=30,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottom,file="Loading/progress_bg.png",
			{
				name="progress",type=1,typeName="Image",time=0,x=0,y=0,width=662,height=30,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="Loading/progress_pre.png"
			}
		}
	}
}
return hotUpdateLoading;