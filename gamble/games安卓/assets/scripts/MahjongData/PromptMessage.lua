--[[
	className    	     :  PromptMessage
	Description  	     :  所有界面的提示信息
	last-modified-date   :  Dec.12 2013
	create-time 	   	 :  Dec.12 2013
	last-modified-author :  ClarkWu
	create-author        :　ClarkWu
]]
PromptMessage = {};

--****************************************************************登录相关**************************************************************************************--
--登录时候的提示语句
PromptMessage.loadingLogin 					= 	"正在为您登录...";

--博雅登录相关
--第一次绑定游客帐号送金币提示语句
PromptMessage.firstBidBoyaa 				= 	"绑定博雅账号成功，赠送10,000金币。";
--博雅通行证绑定失败，重新登录通行证提示语句
PromptMessage.failLoginNeedReloginBoyaa 	= 	"博雅通行证登录游戏失败，请重新登录博雅通行证！";
--博雅通行证登录，数据异常
PromptMessage.failLoginBoyaaDataError 		= 	"博雅通行证数据异常，请重新登录！";

--登录失败的提示语句
PromptMessage.loginFailed  					= 	"登录失败，请稍后再试！";

--****************************************************************好友相关**************************************************************************************--
--添加好友相关
--输入信息为空的提示语句
PromptMessage.friendMidInputIsNullError 	= 	"输入为空，请输入好友id号";
--输入不合法提示语句
PromptMessage.friendInputIllegal 			= 	"输入不合法";
--添加好友不能添加自己提示语句
PromptMessage.notAddYourselfError 			= 	"不能添加自己为好友";
--添加好友已经到达限制提示语句
PromptMessage.fullFriendException 			= 	"您添加的好友已满";
--已经是好友了的提示语句
PromptMessage.isAlreadyFriendException 		= 	"已经是好友了";
--添加好友数据异常的提示语句
PromptMessage.addFriendException  			= 	"添加好友失败，请稍后重试";
--确定添加好友返回数据异常的提示语句
PromptMessage.addFriendReturnDataException  =   "确定好友网络包发送失败，请稍后重试";
--对方拒绝了请求的提示语句
PromptMessage.refuseFriendReqeust			=	"对方拒绝了您的添加请求";
--添加成功的提示语句
PromptMessage.addFriendSuccess				= 	"添加成功";
--添加成功的提示语句
PromptMessage.serverBusy					= 	"系统繁忙，请稍候再试";
PromptMessage.friendIsExist					= 	"好友已存在";
PromptMessage.friendNumLimit				= 	"好友人数已达到上限,请提升VIP等级";
PromptMessage.versionNotSupport				= 	"对方版本不支持添加好友";
PromptMessage.requestSent 					= 	"好友请求已发送，等待对方添加";
PromptMessage.addselfExcption 				= 	"对不起，不能加自己为好友"
PromptMessage.otherFriendNumLimit           =   "对方好友人数已达到上限!"

--删除好友相关
--删除好友，好友列表中的mid与之前拉取的列表mid不匹配，出错提示语句
PromptMessage.deleteFriendFailed 			= 	"删除好友失败，请重新再试";
--删除好友数据异常的提示语句
PromptMessage.deleteFriendDataException     =   "删除好友失败，请稍后重试";
--正在删除好友提示语句
PromptMessage.isDeletingFriend    			=   "正在删除好友...";
--删除成功的提示语句
PromptMessage.deleteFriendSuccess			=	"成功删除好友";
--删除好友正在等待后台处理的提示语句
PromptMessage.productingDeleteFriendWaiting	=	"处理中...";

--在线好友相关
--请求在线好友列表(仅在好友里面存在)的提示语句
PromptMessage.requestOnlineFriendList		=   "请求在线好友信息";

--邀请好友相关
--邀请好友数据异常的提示语句
PromptMessage.inviteFriendDataException		=	"邀请好友失败,请稍后重试";
--已经发出邀请信息的提示语句
PromptMessage.isInvitingFriendInform 		=	"邀请信息已经发出，请等待...";
--好友不在房间的提示语句
PromptMessage.friendIsNotInRoom				=	"此玩家暂时不在房间";
--房间人数已满的提示语句
PromptMessage.inviteFriendRoomFull			=	"此玩家所在房间已满人";
--版本不一致导致邀请失败提示语句
PromptMessage.versionNotSuitable			= 	"您的游戏版本与好友的游戏版本不相同，无法进入。";
--需要升级应用才能和好友一起游戏提示语句
PromptMessage.needUpdateVersion				=	"请您或您的好友升级应用版本才可以在一起玩牌哦！";
--邀请好友好友同意后给主动方的提示语句
PromptMessage.inviteAgree					=	"好友正在进入...";
--邀请好友的文字
PromptMessage.inviteMessage 				= 	{dq="【定缺】",xlch="【血流场】",hsz="【换三张】",xzdd="【血战场】",lfp="【两房牌】",str1="您的好友‘ ",str2=" ’邀请您一起游戏",diStr="【",str3="，是否加入游戏?"};
--邀请好友好友拒绝了你的请求的提示语句
PromptMessage.refuseYourInviting			=	"好友拒绝了你的邀请";
--邀请好友的好友在玩牌的提示语句
PromptMessage.invitedIsInGame				= 	"好友正在游戏中";
--邀请好友好友不在线的提示语句
PromptMessage.inviteFriendIsNotOnline		= 	"好友不在线";

--拉取好友列表的提示语句
PromptMessage.isLoadingFriendsList			= 	"正在加载好友列表...";

--消息发送出后的提示语句
PromptMessage.sendMessageSuccess 			=	"消息已经发出，等待对方回应";

--追踪好友提示
PromptMessage.trackMessage					= 	"正在进入...";

--好友上下线提示
PromptMessage.onlineOrNoOnlinePrompt		= 	{str1= "好友 ",online=" 上线",notonline=" 下线"};

--拉取好友列表的提示语句
PromptMessage.isLoadingFriendsList			= 	"正在加载好友列表...";

--消息发送出后的提示语句
PromptMessage.sendMessageSuccess 			=	"消息已经发出，等待对方回应";

--****************************************************************防沉迷相关************************************************************************************--
--防沉迷姓名为空时候的提示语句
PromptMessage.avoidNullNameMessage			= 	"用户名为空";
--防沉迷身份证信息为空的时候的提示语句
PromptMessage.avoidNullIdentityMessage 		= 	"身份证为空";
--防沉迷身份证位数不正确的提示语句
PromptMessage.avoidIdentityLenError 		= 	"身份证位数不对";
--防沉迷身份证号码不是数字的提示语句
PromptMessage.avoidIdentityNotNumber 		= 	"身份证号码不是数字";
--防沉迷身份证号码不合法的提示语句
PromptMessage.avoidIdentityNotForRule 		= 	"身份证号码输入不合法";
--防沉迷身份证号码年份输入有误的提示语句
PromptMessage.avoidIdentityYearError 		= 	"身份证的年份不正确";

--****************************************************************帮助相关**************************************************************************************--
--加载loading
PromptMessage.helpViewLoadingMall 			= 	"正在加载商城数据，请稍候";
--进商城限制
PromptMessage.helpViewMallLimit 			= 	"要先登录才能购买哦";
--反馈限制
PromptMessage.helpViewFeedLimit 			= 	"要先登录才能反馈哦";
--反馈信息为空的提示语句
PromptMessage.helpViewFeedNull				= 	"请您填写需要反馈的内容";
--反馈内容一致的提示语句
PromptMessage.helpViewSameAsLast 			= 	"您已经反馈过该内容";
--网络异常，反馈失败的提示语句
PromptMessage.helpViewFeedFailed 			= 	"网络异常，请重新发送反馈。";
--反馈成功，感谢您对我们工作的支持的提示语句
PromptMessage.helpViewFeedSuccess 			= 	"反馈成功，感谢您对我们工作的支持。";
--感谢您的详细反馈。反馈成功后的回复语句
PromptMessage.helpViewFeedThanksFeed 		= 	"感谢您的详细反馈。";
--图片加载失败，请重新再试的提示语句
PromptMessage.helpViewLoadPicFailed 		= 	"图片加载失败，请重试";


--****************************************************************支付相关**************************************************************************************--
--没有装SIM卡，无法进行短信支付的提示语句
PromptMessage.noSimCard 					= 	"您没有安装SIM卡，无法进行短信支付。";

--创建订单的Loading语句
PromptMessage.createOrderMessage 			= 	"正在创建订单";
--充值成功的提示语句
PromptMessage.orderSuccessMessage 			= 	"充值成功，请安心等待...";
--用户取消购买的提示语句
PromptMessage.userCancelBugMessage 			= 	"用户取消购买！";
--创建订单失败的提示语句
PromptMessage.createOrderFailedMessage 		= 	"创建订单失败！";
--创建订单失败的网络问题
PromptMessage.createOrderFailedNetMessage  	= 	"创建订单失败，请检查网络，稍后再试！";
--联通宽带版本非联通卡支付时的提示语句
PromptMessage.notUnicomCard                 =   "您不支持该支付功能。";

PromptMessage.loginException 				=	"登录失败，请稍后再试！"

