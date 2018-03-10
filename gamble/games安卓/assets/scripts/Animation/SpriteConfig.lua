local TeachPin_map = require("qnPlist/TeachPin")

require("MahjongPinTu/playCardsAnimPin")



-- 动画配置表

SpriteConfig = {};

SpriteConfig.TYPE_PENG = 1; -- 碰
SpriteConfig.TYPE_GUAFENG = 2; -- 刮风
SpriteConfig.TYPE_XIAYU = 3; -- 下雨
SpriteConfig.TYPE_CHADAJIAO = 4; -- 查大叫
SpriteConfig.TYPE_CHAHUAZHU = 5; -- 查花猪
SpriteConfig.TYPE_FANGPAO = 6; -- 放炮
SpriteConfig.TYPE_ZIMO = 7; -- 胡
SpriteConfig.TYPE_LOADING = 8; -- load界面的文字动画
SpriteConfig.TYPE_LOADING_ANIM = 9; -- 等待网络数据时的loading小动画
--SpriteConfig.TYPE_TEACH_CLICK = 10;  -- 新手教程点击下一步的动画


SpriteConfig.ROOT_DIR_ROOM = "Room/anim/"; -- 房间动画的根目录
SpriteConfig.ROOT_DIR_LOADING = "Loading/"; -- loading动画的根目录
SpriteConfig.ROOT_DIR_TEACH = "Teach/"; --新手教程的根目录


SpriteConfig.loading = {
	imgDirs = {SpriteConfig.ROOT_DIR_LOADING.."reload_1.png",
	SpriteConfig.ROOT_DIR_LOADING.."reload_2.png",
	SpriteConfig.ROOT_DIR_LOADING.."reload_3.png"},
	roundTime = 1500
};

local LoadingPin_map = require("qnPlist/LoadingPin")

SpriteConfig.loadingAnim = {
	imgDirs = {
		LoadingPin_map["loading1.png"],
		LoadingPin_map["loading2.png"],
		LoadingPin_map["loading3.png"],
		LoadingPin_map["loading4.png"],
		LoadingPin_map["loading5.png"],
		LoadingPin_map["loading6.png"],
		LoadingPin_map["loading7.png"],
		LoadingPin_map["loading8.png"]
	},
	roundTime = 500
};




SpriteConfig.configMap = {
	[SpriteConfig.TYPE_LOADING] = SpriteConfig.loading,
	[SpriteConfig.TYPE_LOADING_ANIM] = SpriteConfig.loadingAnim,
};





