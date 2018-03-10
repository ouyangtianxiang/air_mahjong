local selectDomainLayout=
{
	name="selectDomainLayout",type=0,typeName="View",time=0,x=0,y=0,width=0,height=0,visible=1,fillParentWidth=0,fillParentHeight=1,nodeAlign=kAlignTopLeft,
	{
		name="Text2",type=4,typeName="Text",time=54791769,x=16,y=115,width=100,height=60,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=24,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[域名]]
	},
	{
		name="list_all",type=0,typeName="ListView",time=54791891,x=0,y=200,width=1280,height=600,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft
	},
	{
		name="btn_edit",type=2,typeName="Button",time=54807171,x=136,y=116,width=1000,height=80,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="ui/button.png",gridLeft=30,gridRight=30,gridTop=30,gridBottom=30,
		{
			name="edit_domain",type=6,typeName="EditText",time=54791688,x=0,y=0,width=1000,height=80,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=24,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255
		}
	},
	{
		name="btn_save",type=2,typeName="Button",time=54791519,x=949,y=10,width=150,height=64,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="ui/button.png",gridLeft=30,gridRight=30,gridTop=30,gridBottom=30,
		{
			name="Text1",type=4,typeName="Text",time=54791600,x=0,y=0,width=150,height=64,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=24,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[完成配置]]
		}
	},
	{
		name="btn_cancel",type=2,typeName="Button",time=54884514,x=30,y=10,width=150,height=64,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="ui/button.png",gridLeft=20,gridRight=20,gridTop=20,gridBottom=20,
		{
			name="Text3",type=4,typeName="Text",time=54884609,x=0,y=0,width=0,height=0,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=24,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[取  消]]
		}
	},
	{
		name="Text4",type=4,typeName="Text",time=54884743,x=150,y=80,width=0,height=0,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=24,textAlign=kAlignLeft,colorRed=255,colorGreen=255,colorBlue=255,string=[[http://*****/mahjong_weibo/application/,只需要输入*****的内容即可]]
	}
}
return selectDomainLayout;