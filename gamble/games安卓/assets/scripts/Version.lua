--name: Version.lua
--author: OnlynightZhang
--description: this module use for indicate the game version.

Version = {};

-- 版本号对应说明
-- 主版本4.4.0开启热更新
-- 每次大版本更新增加lua_ver版本号，热更新只改变mini_ver版本号

-- version 文件说明：
-- 热更新会对应一个version文件，该文件内存放类似于android的versioncode的数值，当这个数值比上一次大时才能够正常更新
-- 这里讲version文件上传，每次热更新时记得增加version的值(与update在同一级目录)

-- 制作热更新包说明：
-- 制作热更新包时：
-- 1. 首先需要在线上版本的基础上（若上一次有做热更新必须在上一次热更新的基础上），对比与线上不同的代码文件；
-- 2. 新建文件夹，在文件夹内新建文件夹命名为update，在该文件夹内放置与线上版本不同的资源文件（包括images,scripts,audio三个文件夹，若只更新代码则值新建scripts文件夹即可）；
-- 3. 在update文件夹中的目录结构必须与工程中的目录结构相同；
-- 4. 将version文件复制到与update文件夹相同目录下，并且增加version的版本号；
-- 5. 选中update文件夹以及version文件，点击右键压缩为zip文件（注意update文件夹和version文件是在压缩包的根目录下）；
-- 6. 修改压缩包名称为update_[lua_ver]_[mini_ver].zip（例如：update_1_2.zip）；
-- 7. 使用MD5签名工具对压缩包进行签名（签名成功后压缩包名称会带有该文件的md5签名，切记不要修改否则会导致下载不成功重复下载！！！！！）；
-- 8. 开发服/测试服上传更新包（找欧阳对接），并测试是否更新成功。
--
-- 注意：第二次启动以后才能够更新成功。
-- 更新成功标志：每次启动游戏时会弹出banner提示当前的lua_ver以及mini_ver，若已修改为更新包中的版本号即为更新成功，若未修改成功重启游戏后再试；
-- 若多次重启后还未更新成功请参考以上文档检查压缩包是否正常。

-- 版本对应表
-- game_version		lua_ver		mini_ver	version_file_max_value
-- 4.4.0 		=> 	1			1,2 		2
-- 4.4.2		=> 	2			1,2			2
-- 4.5.0		=>	3			1,2,3			3

--大版本号
Version.lua_ver = 537;
--小版本号
Version.mini_ver = 1;
