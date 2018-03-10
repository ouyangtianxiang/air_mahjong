--[[
	className    	     :  CreatingViewUsingData
	Description  	     :  所有手动创建界面相关需要的文本数据信息类
	last-modified-date   :  Dec.13 2013
	create-time 	   	 :  Dec.13 2013
	last-modified-author :  ClarkWu
	create-author        :　ClarkWu
]]
CreatingViewUsingData = {};

--local hall_pin_map = require("qnPlist/hall_pin")

--*********************************************************博雅通行证界面*****************************************************--
CreatingViewUsingData.boyaaView = {};
--背景图
CreatingViewUsingData.boyaaView.bg 			 			 = {fileName="Common/bigDialogBg.png",x1=-7,y1=-4,x2=64,y2=36};
--关闭按钮
CreatingViewUsingData.boyaaView.closeBtn 	 			 = {fileName="Login/boyaaLogin/close_btn.png",x=638,y=-15};
--标题
CreatingViewUsingData.boyaaView.titleText 	 			 = {name="游客绑定博雅通行证",x=228,y=25,w=0,h=0,align=kAlignLeft,size=24,r=255,g=200,b=0};
--分割符
CreatingViewUsingData.boyaaView.split 		  			 = {fileName="Login/boyaaLogin/split.png",x=43,y=63};
--博雅通行证说明背景
CreatingViewUsingData.boyaaView.bgIllustrate  			 = {fileName="Login/boyaaLogin/functionIllustrate.png",x=23,y=222};
--说明金币图片
CreatingViewUsingData.boyaaView.picGold		  			 = {fileName="Login/boyaaLogin/gold.png",x=36,y=239};
--说明安全图片
CreatingViewUsingData.boyaaView.picSecure 	  			 = {fileName="Login/boyaaLogin/secure.png",x=327,y=239};
--说明多设备图片
CreatingViewUsingData.boyaaView.picMultiple   			 = {fileName="Login/boyaaLogin/mulit_device.png",x=36,y=309};
--说明博雅游戏图片
CreatingViewUsingData.boyaaView.picBoyaaGame  			 = {fileName="Login/boyaaLogin/boyaa_game.png",x=329,y=309};
--说明文字数组 数据结构{"文字内容",x坐标,y坐标,字体大小,颜色{r,g,b}}
CreatingViewUsingData.boyaaView.strIllustrate 			 = {
															{"绑定博雅通行证可具备以下功能：", 44, 195, kAlignLeft,18, 255, 255, 255},
															{"绑定送金币", 114, 245, kAlignLeft,20, 255, 200, 0},
															{"首次绑定送10000金币", 114, 271,kAlignLeft, 16, 255, 200, 0},
															{"密码保护", 408, 245,kAlignLeft,20, 255, 200, 0},
															{"密码保护更安全", 408, 271,kAlignLeft,16, 255, 200, 0},
															{"支持多设备", 114, 320,kAlignLeft,20, 255, 200, 0},
															{"一个账号可在不同设备访问", 114, 346,kAlignLeft,16, 255, 200, 0},
															{"支持博雅游戏", 408, 321,kAlignLeft, 20, 255, 200, 0},
															{"一个账号可以玩转博雅所有游戏", 408, 346,kAlignLeft,16, 255, 200, 0}
														 };
CreatingViewUsingData.boyaaView.firstBidStr1  			 = "首次绑定送";
CreatingViewUsingData.boyaaView.firstBidStr2  			 = "10000";
CreatingViewUsingData.boyaaView.firstBidStr3  			 = "金币";
--博雅通行证用户信息背景
CreatingViewUsingData.boyaaView.userBg 		  			 = {fileName="Login/boyaaLogin/userInfoBg.png",x=23,y=72};
--博雅通行证用户头像框
CreatingViewUsingData.boyaaView.headIcon 	  			 = {fileName="Login/boyaaLogin/head_icon.png",x=50,y=81};
--博雅通行证头像坐标
CreatingViewUsingData.boyaaView.headImg 	 			 = {x=55,y=86,w=60,h=60};
--博雅通行证昵称坐标
CreatingViewUsingData.boyaaView.nameText 	  			 = {x=130,y=95,w=0,h=0,size=18,align=kAlignLeft,r=255,g=255,b=255};
--博雅通行证金币坐标
CreatingViewUsingData.boyaaView.moneyText	  			 = {x=129,y=124,w=0,h=0,size=18,align=kAlignLeft,r=255,g=205,b=22};
--博雅通行证登录按钮
CreatingViewUsingData.boyaaView.loginBtn 	  			 = {x=317,y=102,str="登陆通行证",size=20,r=255,g=255,b=255};
--博雅通行证注册按钮
CreatingViewUsingData.boyaaView.registBtn 	  			 = {fileName="Common/cancelBg.png",x=473,y=102,str="注册通行证",size=20,r=255,g=255,b=255};

--*****************************************************切换登录界面**************************************************************--
CreatingViewUsingData.switchLoginView = {
	--登录背景logo及分割线
	logoFile         = {logo="Login/logo.png", logoBg="Login/logoBg.png", splite="Commonx/split_hori.png"};
	--游客登录按钮
	vistorLoginBtn 	 = {fileName="Login/visitorLoginIcon.png", x=0,y=0,text="游客登录"};
    --游客登录按钮
	cellphoneLoginBtn 	 = {fileName="Login/cellLoginIcon.png", x=0,y=0,text="手机登录"};
	--QQ登录按钮
	qqLoginBtn 		 = {fileName="Login/qqLoginIcon.png",x=0,y=0,text="QQ登录"};
	--新浪登录按钮
	sinaLoginBtn 	 = {fileName="Login/sinaLoginIcon.png",x=0,y=0,text="新浪微博"};
	--博雅登录按钮
	boyaaLoginBtn 	 = {fileName="Login/boyaaLoginIcon.png",x=0,y=0,text="博雅通行证"};
	--微信登陆
	loginWeChatBtn 	 = {fileName="Login/wechatLoginIcon.png",x=0,y=0,text="微信登录"};
	-- 移动基地登陆按钮
	mobileLoginBtn	 = {fileName="Login/visitorLoginIcon.png",x=-100,y=0,text="移动基地"};
	--360登录按钮
	login360Btn 	 = {fileName="Login/login360Icon.png",x=-80,y=0, text="360登录"};
	--Oppo登录按钮
	loginOppoBtn 	 = {fileName="Login/loginOppoIcon.png",x=-100,y=0,text="登录"};
	--91助手登录按钮
	login91Btn 		 = {fileName="Login/login91Icon.png",x=0,y=0};
	--搜狗登录按钮
	loginSouGouBtn 	 = {fileName="Login/sogou.png",x=0,y=0};
	--百度多酷登录按钮
	loginBaiduBtn 	 = {fileName="Login/duokuLogin.png",x=0,y=0};
	--lenovo登录按钮
	loginLenovoBtn 	 = {fileName="Login/lenovoLoginIcon.png",x=0,y=0};
	--安智登录按钮
	loginAnzhiBtn 	 = {fileName="Login/anzhiLoginIcon.png",x=-100,y=0,text="安智登录"};
	--华为登录按钮
	loginHuaWeiBtn    = {fileName="Login/huaweiLoginIcon.png",x=-70,y=0, text="华为登录"};
	--豌豆荚登录按钮
	wandouLoginBtn 	 = {fileName="Login/wandouLoginIcon.png",x=0,y=0,text="豌豆荚登录"};
	--切换登录背景[主版本、华为版本]
	loginBg 		 = {fileName="Login/loginBg.png",x=114,y=48,startX=114,startY=48};
	--切换登录背景按钮距离[主版本、华为版本]
	loginBtn	     = {x=20,y=320,split=88};
	--360登录按钮切换值
	loginTo360Btn  	 = {x=0,y=220,split=88};
	--360拉取token列表
	login360AnimToken  = {startX=0,startY=1,expired_in=1000,delay=0};
	--飞信登录
	loginFetionBtn    = {fileName="Login/fetionLoginIcon.png",x=0,y=0, text="飞信登录"};
	--傲天登录
	aotianLoginBtn 	 = {fileName="Login/aotianLoginIcon.png",x=0,y=0, text="傲天登录"};
	--易信登录
	yixinLoginBtn 	 = {fileName="Login/yixinLoginIcon.png",x=0,y=0, text="易信登录"};
	--爱游戏登录
	loginNewEgameBtn = {fileName="Login/egameLoginIcon.png",x=-90,y=0,text="爱游戏登录"};
	--触宝登录按钮
	loginChubaoBtn    = {fileName="Login/chubaoLoginIcon.png",x=-70,y=0, text="触宝登录"};
};

--******************************************************好友界面*****************************************************************--
CreatingViewUsingData.friendView = {};
--好友界面左侧选中图片
CreatingViewUsingData.friendView.selectFriend 			 = {fileName="friend/select_friend.png"};
--好友界面左侧是否在线图片
CreatingViewUsingData.friendView.isOnlinePic 			 = {onlineName="friend/online_nogame_flag.png",nolineName="friend/outline_flag.png"};
--好友界面右侧追踪按钮图片[灰图]
CreatingViewUsingData.friendView.trackBtnGrayed			 = {fileName="newHall/rank/rank_btn_2.png"};
--好友界面右上方文字切换背景坐标
CreatingViewUsingData.friendView.rightTextBg 			 = {x1=452,x2=616,y1=4,y2=4,w=156,h=66};
--好友界面右上方文字我的好友文字信息
CreatingViewUsingData.friendView.rightMyFriend 			 = {str="我的好友",x=487,y=27,w=44,h=22,align=kAlignCenter,size=22,r=255,g=200,b=0};
--好友界面右上方文字好友消息文字信息
CreatingViewUsingData.friendView.rightFriendNotice 		 = {str="好友消息",x=651,y=27,w=44,h=22,align=kAlignCenter,size=22,r=250,g=170,b=99};
--好友上方动画相关信息
CreatingViewUsingData.friendView.anim 					 = {delay=200,from=0,to=0,param6=0,param7=0,leftTo=-164,rightTo=164};
--好友下方左侧背景
CreatingViewUsingData.friendView.friendBg 				 = {noFileName="friend/friendbgbox2.png",fileName="friend/friendbgbox1.png",x=13,y=80};
--好友下方右侧背景
CreatingViewUsingData.friendView.rightFriend 			 = {x=485,y=80};
--好友下方背景遮罩
CreatingViewUsingData.friendView.zhezhao 				 = {fileName="friend/zhezhao.png",x=13,y=80};

--没有好友下方女孩
CreatingViewUsingData.friendView.noFriendGirlPic		 = {fileName="friend/nofriendgirl.png",x=196,y=120};
--没有好友下方添加按钮
CreatingViewUsingData.friendView.noFriendAddBtn 		 = {fileName="friend/add_btn.png",x=528,y=346,str="添加",size=18,r=255,g=255,b=255};
--没有好友下方输入背景
CreatingViewUsingData.friendView.noFriendInputBg 		 = {fileName="friend/input_img.png",x=220,y=346};
--没有好友下方输入框
CreatingViewUsingData.friendView.noFriendEditText 		 = {w=260,h=24,x=238,y=353,align=kAlignTopLeft,size=20,r=50,g=180,b=120,hintText="输入好友id"};
--没有好友下方文字
CreatingViewUsingData.friendView.noFriendText 			 = {str1="你还没有添加好友！",str2="立即邀请好友加入...",x=369,y1=229,y2=259,w=0,h=0,align=kAlignLeft,size=24,r=255,g=255,b=255};

--左侧列表背景图片
CreatingViewUsingData.friendView.addFriendFrame 		 = {fileName="friend/add_friend_frame.png",x=14,y=385};
--左侧列表下输入框背景
CreatingViewUsingData.friendView.leftInputBg 			 = {fileName="friend/input_img.png",x=38,y=403};
--左侧列表下输入框
CreatingViewUsingData.friendView.leftInputEditText		 = {w=260,h=24,x=56,y=410,align=kAlignTopLeft,size=20,r=50,g=180,b=120,hintText="输入好友id"};
--左侧列表下方添加按钮
CreatingViewUsingData.friendView.leftAddBtn 			 = {fileName="friend/add_btn.png",x=346,y=403,str="添加",size=18,r=255,g=255,b=255};
--左侧ListView
CreatingViewUsingData.friendView.friendListView 		 = {startX=0,startY=0,x=15,y=82,w=428,h=303,align=kAlignTopLeft,scrollBarWidth=2,maxClickOffset=5};


--右侧列表头像框
CreatingViewUsingData.friendView.rightFrame 			 = {fileName="friend/head_icon.png",x=53,y=40};
--右侧Id
CreatingViewUsingData.friendView.rightId 			 	 = {str="ID    ：",x1=11,x2=60,y=197,w=0,h=0,align=kAlignLeft,size=18,r=255,g=200,b=0};
--右侧图像
CreatingViewUsingData.friendView.rightImg 			 	 = {x=56,y=42,w=134,h=136};
--右侧等级
CreatingViewUsingData.friendView.rightLevel 			 = {str="等级：",x1=151,x2=208,y=197,w=0,h=0,align=kAlignLeft,size=18,r=255,g=200,b=0};
--右侧局数
CreatingViewUsingData.friendView.rightJuShu				 = {str="局数：",defaultstr="0局",x1=11,x2=68,y=240,w=0,h=0,align=kAlignLeft,size=18,r=255,g=200,b=0};
--右侧胜率
CreatingViewUsingData.friendView.rightShengLv			 = {str="胜率：",defaultStr="0%",x1=151,x2=208,y=240,w=0,h=0,align=kAlignLeft,size=18,r=255,g=200,b=0};
--右侧删除按钮
CreatingViewUsingData.friendView.rightDeleteBtn 		 = {str="删除好友",x=141,y=321,size=20,r=255,g=255,b=255};
--右侧追踪按钮
CreatingViewUsingData.friendView.rightTrackBtn			 = {str="追踪好友",x=-19,y=321,size=20,r=255,g=255,b=255};
--删除好友提示文本
CreatingViewUsingData.friendView.deleteFriendStr 		 = {prompt1="您好，确定要删除好友‘",prompt2="’吗？"}
--增加好友提示文本
CreatingViewUsingData.friendView.addFriendStr 			 = {prompt1="您好,‘ ",prompt2=" ’请求加您为好友"};

--好友消息界面
CreatingViewUsingData.friendView.friendNoticeBg			 = {fileName="friend/friendbgbox2.png",x=13,y=80};
--没有好友消息文本
CreatingViewUsingData.friendView.noFriendNotices 		 = {str = "您暂时没有消息！",x=315,y=244,w=0,h=0,align=kAlignLeft,size=20,r=50,g=180,b=120};
--好友消息列表
CreatingViewUsingData.friendView.friendNoticeListView 	 = {x=20,y=82,w=760,h=375,align=kAlignTopLeft,scrollBarWidth=2,maxClickOffset=5};

--增加好友按键动画
CreatingViewUsingData.friendView.addFriendAnim 			 = {from=-1,to=-1,time=3000,delay=1};

--读取好友界面Loading的View
CreatingViewUsingData.friendView.loading 				 = {fileName="Common/loading.png",x1=347,y1=173,x2=564,y2=215,from=0,to=360,delay=1000};

--*******************************************************好友列表界面************************************************************--
-- CreatingViewUsingData.friendListView = {};
-- --好友背景
-- CreatingViewUsingData.friendListView.bg 				 = {x=10,y=0,w=428,h=83};
-- --好友每一个按键
-- CreatingViewUsingData.friendListView.perButton 			 = {x=0,y=0,w=428,h=82,fileSelectedName="friend/select_friend.png"};
-- --头像界面
-- CreatingViewUsingData.friendListView.leftImg 			 = {x=28,y=9,w=60,h=60};
-- --性别图像
-- CreatingViewUsingData.friendListView.leftSexImg 		 = {fileBoyName="friend/sex_boy.png",fileGirlName="friend/sex_girl.png",x=100,y=11};
-- --性别后名字
-- CreatingViewUsingData.friendListView.leftName 			 = {x=140,y=11,w=0,h=0,align=kAlignLeft,size=20,r=255,g=255,b=255};
-- --金币图标
-- CreatingViewUsingData.friendListView.coinImg 			 = {fileName=hall_pin_map["moneyIcon.png"],x=100,y=46};
-- --金币数
-- CreatingViewUsingData.friendListView.coinText 			 = {x=140,y=45,w=0,h=0,align=kAlignLeft,Asize=20,r=255,g=200,b=0};
-- --上下线图标
-- CreatingViewUsingData.friendListView.onlineNolineImg 	 = {fileOnlineName="friend/online_nogame_flag.png",fileNoLineName="friend/outline_flag.png",x=147,y=12};
-- --每个好友之间的分割线
-- CreatingViewUsingData.friendListView.split 				 = {fileName="friend/friend_split.png",x=0,y=82};

--********************************************************好友消息界面***********************************************************--
CreatingViewUsingData.friendNoticeView = {};
--背景
CreatingViewUsingData.friendNoticeView.bg 				 = {x=0,y=0,w=760,h=80};
--头像
CreatingViewUsingData.friendNoticeView.albumImg 		 = {x=18,y=18,w=60,h=60};
--头像旁边名字
CreatingViewUsingData.friendNoticeView.albumNameText 	 = {x=98,y=34,w=0,h=0,align=kAlignLeft,size=20,r=255,g=200,b=0};
--说明文字
CreatingViewUsingData.friendNoticeView.illustrateText 	 = {x=10,y=34,w=0,h=0,align=kAlignLeft,size=18,r=255,g=255,b=255};
--忽略邀请按钮
CreatingViewUsingData.friendNoticeView.ignoreInviteBtn 	 = {x=446,y=26,str="忽略邀请",size=20,r=255,g=255,b=255};
--接受邀请按钮
CreatingViewUsingData.friendNoticeView.acceptInviteBtn 	 = {x=600,y=26,str="接受邀请",size=20,r=255,g=255,b=255};
--好友消息分割线
CreatingViewUsingData.friendNoticeView.split 			 = {fileName="friend/friend_line.png",x=18,y=88};

--********************************************************邀请好友界面***********************************************************--
CreatingViewUsingData.inviteFriendView = {};
--背景
CreatingViewUsingData.inviteFriendView.bg 				 = {fileName="friend/invite_bg.png",x=142,y=40};
--邀请好友标题
CreatingViewUsingData.inviteFriendView.title 			 = {str="邀请好友",x=350,y=67,w=0,h=0,align=kAlignLeft,size=22,r=255,g=255,b=255};
--没有在线好友文字
CreatingViewUsingData.inviteFriendView.noInvitedFriend 	 = {str="暂无可邀请好友,您可以试着邀请以下玩家一起游戏！",x=325,y=205,w=0,h=0,align=kAlignCenter,size=22,r=110,g=40,b=0};
--邀请好友界面列表
CreatingViewUsingData.inviteFriendView.inviteListView 	 = {x=142,y=110,w=502,h=260,align=kAlignTopLeft,scrollBarWidth=2,maxClickOffset=5};

--*******************************************************邀请好友列表界面********************************************************--
CreatingViewUsingData.inviteFriendListView = {};
--背景
CreatingViewUsingData.inviteFriendListView.bg 			 = {x1=10,y1=0,w=428,h=83,x2=0,y2=20};
--头像
CreatingViewUsingData.inviteFriendListView.album 		 = {w=60,h=60};
--性别图标
CreatingViewUsingData.inviteFriendListView.sexImg 		 = {fileBoyName="Commonx/male.png",fileGirlName="Commonx/female.png",x=70,y=3};
--金币图标
--CreatingViewUsingData.inviteFriendListView.coinImg 		 = {fileName=hall_pin_map["moneyIcon.png"],x=70,y=38};
--金币文字
CreatingViewUsingData.inviteFriendListView.coinText 	 = {x=100,y=38,w=0,h=0,align=kAlignLeft,size=20,r=110,g=40,b=0};
--邀请好友名字
CreatingViewUsingData.inviteFriendListView.name 		 = {x=100,y=3,w=0,h=0,align=kAlignLeft,size=20,r=110,g=40,b=0};
--邀请按钮
CreatingViewUsingData.inviteFriendListView.inviteBtn 	 = {fileLightName="",fileDarkName="",x=430,y=3};

--邀请好友动画
CreatingViewUsingData.inviteFriendListView.inviteAnim 	 = {from=-1,to=-1,delay=-1,time=7};

--*******************************************************房间内用户信息界面******************************************************--
CreatingViewUsingData.roomUserInfoView = {};
--背景
CreatingViewUsingData.roomUserInfoView.bg 				 = {x=124,y=64,w=553,h=292};
--添加好友动画
CreatingViewUsingData.roomUserInfoView.addFriendAnim 	 = {fileLightName="Room/userInfo/addFriend.png",fileDarkName="Room/userInfo/addFriendUnable.png",from=0,to=1,time=10,delay=-1};
--性别为女的图标
CreatingViewUsingData.roomUserInfoView.girlSex  		 = {fileName="Room/userInfo/girlsymbol.png"};
--ID号
CreatingViewUsingData.roomUserInfoView.idText 			 = {title="ID:"};
--名字
CreatingViewUsingData.roomUserInfoView.nameText 		 = {limit=12};
--真实金币数
CreatingViewUsingData.roomUserInfoView.coinText 		 = {x=0,y=0,w=0,h=0,align=kTextAlignLeft,size=20,r=16,g=198,b=97};
--胜负文字
CreatingViewUsingData.roomUserInfoView.winLostText 		 = {win="胜/",lost="负/",ping="平"};
--快捷支付按钮
CreatingViewUsingData.roomUserInfoView.quicklyBtn 		 = {x=20};

--*******************************************************大厅界面****************************************************************--
-- CreatingViewUsingData.hallView = {};
-- --好友消息图标
-- CreatingViewUsingData.hallView.friendNoticeIcon 		 = {fileName=hall_pin_map["tip.png"],x=544,y=420};
-- --好友消息数字
-- CreatingViewUsingData.hallView.friendNoticeNum 			 = {x=552,y=422,w=0,h=0,align=kAlignCenter,size=16,r=255,g=210,b=160};

--*******************************************************帮助界面****************************************************************--
CreatingViewUsingData.helpView = {};
--当前选择框
CreatingViewUsingData.helpView.currentTarget 			 = {fileName="newHall/mall/target.png",x=124,y=4};
--我要提问
CreatingViewUsingData.helpView.iWantToKnow 				 = {x=124,y=4,w=156,h=66};
CreatingViewUsingData.helpView.iWantToKnowText 			 = {str="我要提问",x=159,y=27,w=44,h=22,align=kAlignCenter,size=22,r=255,g=200,b=0};
--常见问题
CreatingViewUsingData.helpView.commonQuestionView		 = {x=288,y=4,w=156,h=66};
CreatingViewUsingData.helpView.commonQuestionText 		 = {str="常见问题",x=323,y=27,w=44,h=22,align=kAlignCenter,size=22,r=255,g=170,b=99};
--基本玩法
CreatingViewUsingData.helpView.playMethodView 			 = {x=452,y=4,w=156,h=66};
CreatingViewUsingData.helpView.playMethodText 			 = {str="基本玩法",x=487,y=27,w=44,h=22,align=kAlignCenter,size=22,r=250,g=170,b=99};
--番型计算
CreatingViewUsingData.helpView.fanCalculateView			 = {x=616,y=4,w=156,h=66};
CreatingViewUsingData.helpView.fanCalculateText 		 = {str="番型计算",x=651,y=27,w=44,h=22,align=kAlignCenter,size=22,r=250,g=170,b=99};

--动画切换效果
CreatingViewUsingData.helpView.pingSwitchViewText 		 = {str1="我要提问",str2="常见问题",str3="基本玩法",str4="番型计算",w=44,h=22,r1=250,g1=170,b1=99,r2=255,g2=200,b2=0,bg_x1=124,bg_x2=288,bg_x3=452,bg_x4=616,bg_y=4};

--帮助界面上方切换动画设定
CreatingViewUsingData.helpView.switchViewAnim 			 = {delay=200,fromX=0,toX=0,fromY=0,toY=0,scale1=-164,scale2=-328,scale3=-492,scale4=164,scale5=328,scale6=492};

--反馈界面
CreatingViewUsingData.helpView.feedBack = {};
--背景
CreatingViewUsingData.helpView.feedBack.bg 				 = {x=800,y=480};
--反馈输入框
CreatingViewUsingData.helpView.feedBack.editView 		 = {defaultStr="",x=228,y=101,w=510,h=110,align=kAlignTopLeft,size=22,r=255,g=255,b=255,hintText="请填写您的宝贵意见，我们会在1~3日内进行答复。",hintR=60,hintG=220,hintB=170};
--输入框下方文字
CreatingViewUsingData.helpView.feedBack.downEdit 		 = {str="",x=42,y=236,w=400,h=16,align=kAlignLeft,size=16,r=60,g=220,b=170};
CreatingViewUsingData.helpView.feedBack.downEdit1 		 = {str="联系我们:QQ群(216208119)、客服电话(400-663-1888或0755-86166169)",x=42,y=240,w=400,h=16,align=kAlignLeft,size=16,r=60,g=220,b=170};

--发送按钮
CreatingViewUsingData.helpView.feedBack.sendButton 		 = {fileName="newHall/task/btnBg.png",x=612,y=226,str="发送",size=22,r=255,g=255,b=255};
--反馈下方分割线
CreatingViewUsingData.helpView.feedBack.split 			 = {fileName="newHall/help/cutoffRule.png",x=32,y=298};
--反馈下方loading
CreatingViewUsingData.helpView.feedBack.loading 		 = {fileName="Common/loading.png",x=350,y=340,from=1000,to=0,fromSecond=360,toSecond=0,delay1=0,delay2=0,align=kCenterDrawing};
--无反馈文字
CreatingViewUsingData.helpView.feedBack.noFeedText 		 = {str="您暂时还未提交过反馈信息。",x=40,y=310,w=300,h=22,align=kAlignLeft,size=22,r=60,g=220,b=170};
--反馈列表
CreatingViewUsingData.helpView.feedBack.feedBackList 	 = {x=40,y=310,w=700,h=150};
--反馈问题
CreatingViewUsingData.helpView.feedBack.feedAsk 		 = {str="问：",x=700,y=nil,align=kAlignLeft,size=22,r=60,g=220,b=170};
--反馈回答
CreatingViewUsingData.helpView.feedBack.feedAnswer		 = {str="答：",x=700,y=nil,align=kAlignLeft,size=22,r=60,g=220,b=170,informing="您的问题已经提交成功，客服人员正在处理，感谢您的支持。"};
--反馈分隔符
CreatingViewUsingData.helpView.feedBack.feedSplit 		 = {str=" ", x=0,y=0,w=700,h=22,align=kAlignLeft,size=22,r=60,g=220,b=170};
--反馈清单
CreatingViewUsingData.helpView.feedBack.feedList 		 = {loginType="【登录方式",model_name="】【机型:",macAddress="】【机器码:",version="】【游戏版本:",device="】【设备类型:Android",net="】【联网方式:",ip="】【IP地址:",
															isSdCard="】【是否有SD卡:",platformType= "】【版本平台:",api="】【当前API:",mini_ver="】【当前mini_ver:",endingType="】"
														   };
CreatingViewUsingData.helpView.feedBack.selectImg 		 = {fileName="myScreenshot.png",x=8,y=8,w=133,h=107};

--常见问题
CreatingViewUsingData.helpView.commonQuestion = {};
--背景
CreatingViewUsingData.helpView.commonQuestion.bg 		 = {x=26,y=100,w=748,h=335};
--如何获取金币
CreatingViewUsingData.helpView.commonQuestion.howGetCoin = {w=748,h=176};
--什么是游客账号
CreatingViewUsingData.helpView.commonQuestion.whatGuest  = {w=748,h=148};
--我的游戏币为什么不见了
CreatingViewUsingData.helpView.commonQuestion.whyNotCoin = {w=748,h=127};
--为什么有时无法登录游戏、突然掉线...
CreatingViewUsingData.helpView.commonQuestion.whyDown 	 = {w=748,h=125};
--为什么有时游戏会自动退出或者无法进入
CreatingViewUsingData.helpView.commonQuestion.whyExit 	 = {w=748,h=151};
--为什么我的商城中无法显示商品
CreatingViewUsingData.helpView.commonQuestion.whyNoShop  = {w=748,h=127};
--为什么我支付成功了，金币没有到账
CreatingViewUsingData.helpView.commonQuestion.whyNoPay 	 = {w=748,h=127};
--为什么我不可以赠送金币了?
CreatingViewUsingData.helpView.commonQuestion.sendCoin   = {w=748,h=101};
--每局每日金币有上限
CreatingViewUsingData.helpView.commonQuestion.limit 	 = {w=748,h=102};
--游戏是否收服务费
CreatingViewUsingData.helpView.commonQuestion.gameServe  = {w=748,h=80};
--常见问题中文字的格式需求
CreatingViewUsingData.helpView.commonQuestion.wordFormat = {w=748,h=30,align=kAlignLeft,size=22,rTitle=255,gTitle=200,bTitle=0,rContent=60,gContent=220,bContent=170};
--常见问题中购买金币列的坐标
CreatingViewUsingData.helpView.commonQuestion.buyCoinText= {x=0,y1=35,y2=60,y3=85,y4=110};
--常见问题中购买金币按钮
CreatingViewUsingData.helpView.commonQuestion.buyCoinBtn = {fileName="newHall/task/btnBg.png",x=265,y=13,str="购买金币",size=16,r=255,g=255,b=255};
--常见问题中的第二个问题的坐标
CreatingViewUsingData.helpView.commonQuestion.comQuest2  = {x=0,y1=35,y2=60,y3=85};
--常见问题中的第三个问题的坐标
CreatingViewUsingData.helpView.commonQuestion.comQuest3  = {x=0,y1=35,y2=60};
--常见问题中的第四个问题的坐标
CreatingViewUsingData.helpView.commonQuestion.comQuest4  = {x=0,y1=35,y2=60};
--常见问题中的第五个问题的坐标
CreatingViewUsingData.helpView.commonQuestion.comQuest5  = {x=0,y1=35,y2=60,y3=85};
--常见问题中的第六个问题的坐标
CreatingViewUsingData.helpView.commonQuestion.comQuest6  = {x=0,y1=35,y2=60};
--常见问题中的第七个问题的坐标
CreatingViewUsingData.helpView.commonQuestion.comQuest7  = {x=0,y1=35,y2=60};
--常见问题中的第八个问题的坐标
CreatingViewUsingData.helpView.commonQuestion.comQuest8  = {x=0,y1=35};
--常见问题中的第九个问题的坐标
CreatingViewUsingData.helpView.commonQuestion.comQuest9  = {x=0,y1=35};
--常见问题中的第十个问题的坐标
CreatingViewUsingData.helpView.commonQuestion.comQuest10 = {x=0,y1=35};

--基本玩法
CreatingViewUsingData.helpView.playMethod = {};
--背景
CreatingViewUsingData.helpView.playMethod.bg 			 = {x=26,y=100,w=748,h=335};
--术语解释
CreatingViewUsingData.helpView.playMethod.shuyuExplain 	 = {w=738,h=798};
--换三张
CreatingViewUsingData.helpView.playMethod.huanSanZhang 	 = {w=738,h=149};
--血流成河
CreatingViewUsingData.helpView.playMethod.xiuliuHe 		 = {w=738,h=249};
--血流成河的番型
CreatingViewUsingData.helpView.playMethod.xiuliuHeFan 	 = {w=738,h=180};
--加番玩法
CreatingViewUsingData.helpView.playMethod.addFan 		 = {w=738,h=150};

--基本玩法中文字的格式要求
CreatingViewUsingData.helpView.playMethod.wordFormat 	 = {w=748,h=30,align=kAlignLeft,size=22,rTitle=255,gTitle=200,bTitle=0,rContent=60,gContent=220,bContent=170};
--基本玩法中的术语解释每一项的具体坐标
CreatingViewUsingData.helpView.playMethod.termExplain 	 = {x=0,y1=35,y2=60,y3=85,y4=110,y5=135,y6=160,y7=185,y8=210,y9=235,y10=260,y11=285,y12=310,y13=335,y14=360,y15=385,y16=410,y17=435,y18=460,y19=485,y20=510,
															y21=535,y22=560,y23=585,y24=610,y25=635,y26=660,y27=685,y28=710,y29=735
														};
--基本玩法中的换三张具体坐标
CreatingViewUsingData.helpView.playMethod.changeSanZhang = {x=0,y1=35,y2=60,y3=85};
--基本玩法中的血流成河具体坐标
CreatingViewUsingData.helpView.playMethod.xiuliuhe 		 = {x=0,y1=35,y2=60,y3=85,y4=110,y5=135,y6=160,y7=185};
--基本玩法中的血流成河番型具体坐标
CreatingViewUsingData.helpView.playMethod.xiuliuheFan 	 = {x=0,y1=35,y2=60,y3=85,y4=110};
--基本玩法中的加番玩法的具体坐标
CreatingViewUsingData.helpView.playMethod.addFanMethod 	 = {x=0,y1=35,y2=60,y3=85,y4=110};

--番型计算
CreatingViewUsingData.helpView.calCulateFan = {};
--背景
CreatingViewUsingData.helpView.calCulateFan.bg 			 = {x=26,y=100,w=748,h=340};
--1番
CreatingViewUsingData.helpView.calCulateFan.oneFan 		 = {w=738,h=190};
--2番
CreatingViewUsingData.helpView.calCulateFan.twoFan 		 = {w=738,h=190};
--3番
CreatingViewUsingData.helpView.calCulateFan.ThreeFan 	 = {w=738,h=499};
--4番
CreatingViewUsingData.helpView.calCulateFan.FourFan 	 = {w=738,h=345};
--5番
CreatingViewUsingData.helpView.calCulateFan.FiveFan 	 = {w=738,h=524};
--6番
CreatingViewUsingData.helpView.calCulateFan.SixFan 		 = {w=738,h=173};
--另加番
CreatingViewUsingData.helpView.calCulateFan.AnotherFan 	 = {w=738,h=472};
--正常计算
CreatingViewUsingData.helpView.calCulateFan.normalCalcu  = {w=738,h=268};
--正常胡牌
CreatingViewUsingData.helpView.calCulateFan.normalHu 	 = {w=738,h=195};
--流局
CreatingViewUsingData.helpView.calCulateFan.liuHu 		 = {w=738,h=146};
--逃跑处理
CreatingViewUsingData.helpView.calCulateFan.escape 		 = {w=738,h=83};
--海底捞月
CreatingViewUsingData.helpView.calCulateFan.haidilaoyue  = {w=738,h=100};
--金钩钓
CreatingViewUsingData.helpView.calCulateFan.jingoudiao   = {w=738,h=100};
--绝张
CreatingViewUsingData.helpView.calCulateFan.juezhang 	 = {w=738,h=110};

--番型计算中文字的格式要求
CreatingViewUsingData.helpView.calCulateFan.wordFormat 	 = {w=738,h=30,w2=0,h2=0,align=kAlignLeft,size=22,rTitle=255,gTitle=200,bTitle=0,rContent=60,gContent=220,bContent=170};
--番型计算中的图片位置
CreatingViewUsingData.helpView.calCulateFan.picXY 		 = {fileName1="newHall/help/help_1.png",fileName2="newHall/help/help_2.png",fileName3="newHall/help/help_3_1.png",fileName4="newHall/help/help_3_2.png",fileName5="newHall/help/help_3_3.png",fileName6="newHall/help/help_4_1.png",
															fileName7="newHall/help/help_4_2.png",fileName8="newHall/help/help_5_1.png",fileName9="newHall/help/help_5_2.png",fileName10="newHall/help/help_5_3.png",x1=0,y1=80,y2=235,y3=390,y4=105,y5=255,y6=415};
--番型计算文字中的每一项的具体坐标
CreatingViewUsingData.helpView.calCulateFan.fanXing 	 = {x1=0,y1=35,y2=190,y3=345,y4=60,y5=215,y6=370,x2=66,x3=198,x4=88};
--番型计算文字中有规则的每一项的具体坐标
CreatingViewUsingData.helpView.calCulateFan.fanXingRegu  = {x1=0,x2=60,x3=66,x4=108,y1=35,y2=60,y3=85,y4=110,y5=135,y6=160,y7=185,y8=210,y9=235,y10=260,y11=285,y12=310,y13=335,y14=360,y15=385,y16=410,y17=435};

--*******************************************************  支付相关  ************************************************************--

--*******************************************************公共信息相关************************************************************--
CreatingViewUsingData.commonData = {};

--顶部有返回的背景图
CreatingViewUsingData.commonData.topBg 					 = {fileName="Common/subViewTopBar.png",x=0,y=0};
--房间或大厅背景图
CreatingViewUsingData.commonData.bg 					 = {fileName="Common/bg.png",x=0,y=0};
--大对话框背景
CreatingViewUsingData.commonData.bigDialogBg 			 = {fileName="Common/bigDialogBg.png"};
--关闭按钮
CreatingViewUsingData.commonData.closeBtn 				 = {fileName="Common/close.png"};
--大厅或房间透明背景图
CreatingViewUsingData.commonData.blankBg 				 = {fileName="Commonx/blank.png"};
--确认按钮图片
CreatingViewUsingData.commonData.confirmBtnBg 			 = {fileName="Common/confirmBg.png"};
--取消按钮图片
CreatingViewUsingData.commonData.cancelBg 				 = {fileName="Common/cancelBg.png"};
--顶部有返回的返回按键
CreatingViewUsingData.commonData.topReturnBtn 			 = {fileName="Common/retBtn.png",x=24,y=10};
--顶部有返回的返回分割符图片
CreatingViewUsingData.commonData.topSplitImg			 = {fileName="Common/split.png",x=100,y=8};
--顶部有返回的右侧选中文字背景图片
CreatingViewUsingData.commonData.selectTextBg 			 = {fileName="newHall/mall/target.png",x=452,y=4};
--弹出框PopuFrame文本
CreatingViewUsingData.commonData.popuFrame 				 = {title="温馨提示",x=0,y=0};

--一些界面需要的常量设定
CreatingViewUsingData.commonData.coinStr 	   			 = "金币";
CreatingViewUsingData.commonData.boyaaStr 				 = "博雅币";
CreatingViewUsingData.commonData.maoHaoStr 	   			 = "：";
CreatingViewUsingData.commonData.boyPicLocate  			 = "Commonx/default_man.png";
CreatingViewUsingData.commonData.boyPic 				 = "default_man.png";
CreatingViewUsingData.commonData.girlPicLocate 			 = "Commonx/default_woman.png";
CreatingViewUsingData.commonData.girlPic 				 = "default_woman.png";
CreatingViewUsingData.commonData.commonSepearate		 = "Common/";
CreatingViewUsingData.commonData.certainText 			 = "确定";
--图片正则判断
CreatingViewUsingData.commonData.regularJudge 			 = "[%w_]+\.[jpg][png][%w%p_]+";
--增加好友正则判断输入
CreatingViewUsingData.commonData.regularJudgeAdd 		 = "^%d*$";
--好友胜率的正则判断
CreatingViewUsingData.commonData.regularFriendShenglv 	 = "%d";

--Setting界面的用户信息
CreatingViewUsingData.commonData.userIdentityQQ 		 = "QQ用户：";
CreatingViewUsingData.commonData.userIdentitySina 		 = "新浪用户：";
CreatingViewUsingData.commonData.userIdentityGuest 		 = "游客用户：";
CreatingViewUsingData.commonData.userIdentityGuest2345	 = "2345游客用户：";
CreatingViewUsingData.commonData.userIdentityBoyaa 		 = "博雅用户：";
CreatingViewUsingData.commonData.userIdentityHuawei 	 = "华为用户：";
CreatingViewUsingData.commonData.userIdentityChubao 	 = "触宝用户：";
CreatingViewUsingData.commonData.userIdentityOppo 		 = "Oppo用户：";
CreatingViewUsingData.commonData.userIdentity360 		 = "360用户：";
CreatingViewUsingData.commonData.userIdentityMobile 	 = "移动基地用户：";
CreatingViewUsingData.commonData.userIdentity91 	 	 = "91用户：";
CreatingViewUsingData.commonData.userIdentitySouGou	 	 = "搜狗用户：";
CreatingViewUsingData.commonData.userIdentityBaidu	 	 = "百度多酷用户：";
CreatingViewUsingData.commonData.userIdentityLenovo 	 = "联想用户：";
CreatingViewUsingData.commonData.userIdentityContest 	 = "比赛游客用户：";
CreatingViewUsingData.commonData.userIdentityAnZhi 		 = "安智用户：";
CreatingViewUsingData.commonData.userIdentityFETION 	 = "飞信用户：";
CreatingViewUsingData.commonData.userIdentityWeChat 	 = "微信用户：";
CreatingViewUsingData.commonData.userIdentityWanDouJia 	 = "豌豆荚用户：";
CreatingViewUsingData.commonData.userIdentityDingkai 	 = "起凡互娱用户：";
CreatingViewUsingData.commonData.userIdentityAoTian 	 = "傲天用户：";
CreatingViewUsingData.commonData.userIdentityYiXin	 	 = "易信用户：";
CreatingViewUsingData.commonData.userIdentityCellphone	 	 = "手机用户：";

--防沉迷身份证的正则判断
CreatingViewUsingData.commonData.regularJudgeByIdentity  = "^[0-9]*$";
--防沉迷身份证年份的正则判断
CreatingViewUsingData.commonData.regularJudgeYear		 = "%Y";

--loading界面的提示语句
CreatingViewUsingData.commonData.loadingText 			 = {
															"四川麻将要缺万、筒、条的一门才能胡牌。",
															"结束时没下叫（听牌）的会被查大叫，要赔钱给下叫的人。",
															"查花猪指你的牌共有三种花色，要赔16倍底注金币。",
															"血流成河是指大家都可以反复和牌，直到摸完所有的牌为止。",
															"游客在登录页面可以点击头像修改头像资料。",
															"如果在游戏中有任何疑问，请在游戏帮助中选择我要提问向官方提交问题。",
															"当您破产后，系统会免费赠送您一定的金币。",
															"请在游戏中保持礼貌和谦逊，这样能让您获得更多的朋友。",
															"您可以在游戏设置中阅读隐私策略和服务协议，来了解相关内容。",
															"您可以通过完成任务，来获得系统赠送的金币奖励。",
															"您可以通过充值来获得VIP积分，从而提升VIP等级。",
															"每完成一局游戏后，系统都会收取一定的金币台费保证系统经济的平衡。",
															"请随时关注游戏的活动信息，这样会让您获得更多的优惠或者奖励。",
															"每个游戏场均有一定的金币上下限要求，达到相应要求才可以进入游戏。",
															"如果您超过16岁，请尽快完成游戏的实名认证。",
															"您可以通过游戏的消息模块来关注游戏的最新动态。",
															"每拥有1张加番牌，赢牌时则增加1番，最高可增加4番。"
														};
