/*
SQLyog Ultimate v8.32 
MySQL - 5.0.22-community-nt : Database - game
*********************************************************************
*/

/*!40101 SET NAMES utf8 */;

/*!40101 SET SQL_MODE=''*/;

/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
CREATE DATABASE /*!32312 IF NOT EXISTS*/`game` /*!40100 DEFAULT CHARACTER SET utf8 COLLATE utf8_bin */;

USE `game`;

/*Table structure for table `h_online` */

DROP TABLE IF EXISTS `h_online`;

CREATE TABLE `h_online` (
  `userid` int(11) NOT NULL default '0' COMMENT '$用户ID',
  `loginTime` int(11) NOT NULL default '0' COMMENT '$上线时间',
  `logoutTime` int(11) NOT NULL COMMENT '下线时间',
  `ip` int(11) NOT NULL default '0' COMMENT '在线用户数',
  PRIMARY KEY  (`userid`,`loginTime`),
  KEY `time` (`loginTime`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='在线用户数表(每次用户上下线都插入此表)';

/*Data for the table `h_online` */

insert  into `h_online`(`userid`,`loginTime`,`logoutTime`,`ip`) values (1010000001,1456378537,1456382092,2130706433),(1010000001,1456383648,1456383648,2130706433),(1010000001,1456384507,1456384507,2130706433),(1010000001,1456384560,1456384560,2130706433),(1010000001,1456384561,1456384561,2130706433),(1010000001,1456384562,1456384562,2130706433),(1010000001,1456384563,1456384563,2130706433),(1010000001,1456384564,1456384564,2130706433),(1010000001,1456385002,1456385002,2130706433),(1010000001,1456385035,1456385039,2130706433),(1010000001,1456385149,1456385276,2130706433),(1010000001,1456385266,1456385267,2130706433),(1010000001,1456385612,1456386066,2130706433);

/*Table structure for table `s_avatar` */

DROP TABLE IF EXISTS `s_avatar`;

CREATE TABLE `s_avatar` (
  `id` int(11) NOT NULL COMMENT '%自增ID',
  `name` varchar(32) collate utf8_bin NOT NULL COMMENT '皮肤名称',
  `info` varchar(256) collate utf8_bin NOT NULL COMMENT '皮肤描述',
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

/*Data for the table `s_avatar` */

/*Table structure for table `s_gene` */

DROP TABLE IF EXISTS `s_gene`;

CREATE TABLE `s_gene` (
  `id` smallint(6) NOT NULL COMMENT '$基因ID',
  `name` varchar(32) collate utf8_bin NOT NULL COMMENT '基因名称',
  `type` tinyint(4) NOT NULL COMMENT '基因类型',
  `effect` tinyint(4) default NULL COMMENT '加成效果',
  `info` varchar(128) collate utf8_bin default NULL COMMENT '基因描述',
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

/*Data for the table `s_gene` */

insert  into `s_gene`(`id`,`name`,`type`,`effect`,`info`) values (101,'生命基因',1,1,'生命值'),(102,'防御基因',1,2,'防御力'),(103,'潜能基因',1,3,'初始SP值'),(104,'战斗基因',2,4,'攻击力'),(105,'穿透基因',2,5,'破甲\r\n'),(106,'狂击基因',2,6,'技能伤害'),(107,'时空基因',3,7,'CD缩减'),(108,'激怒基因',3,8,'SP增长速度'),(109,'节能基因',3,9,'推进消耗减免'),(110,'特能基因',4,10,'SP效果（持续时间/伤害）'),(111,'极速基因',4,11,'移动速度'),(112,'精神基因',4,12,'推进力');

/*Table structure for table `s_gene_lv` */

DROP TABLE IF EXISTS `s_gene_lv`;

CREATE TABLE `s_gene_lv` (
  `geneID` smallint(6) NOT NULL COMMENT '$基因ID',
  `lv` tinyint(4) NOT NULL COMMENT '$基因等级',
  `value` float NOT NULL COMMENT '加成数值',
  PRIMARY KEY  (`geneID`,`lv`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

/*Data for the table `s_gene_lv` */

insert  into `s_gene_lv`(`geneID`,`lv`,`value`) values (101,1,10),(101,2,20),(101,3,30),(101,4,40),(101,5,50),(102,1,5),(102,2,10),(102,3,15),(102,4,20),(102,5,25),(103,1,5),(103,2,10),(103,3,15),(103,4,20),(103,5,25),(104,1,5),(104,2,10),(104,3,15),(104,4,20),(104,5,25),(105,1,0.01),(105,2,0.02),(105,3,0.03),(105,4,0.04),(105,5,0.05),(106,1,0.005),(106,2,0.01),(106,3,0.015),(106,4,0.02),(106,5,0.025),(107,1,0.01),(107,2,0.02),(107,3,0.03),(107,4,0.04),(107,5,0.05),(108,1,0.01),(108,2,0.02),(108,3,0.03),(108,4,0.04),(108,5,0.05),(109,1,0.02),(109,2,0.04),(109,3,0.06),(109,4,0.08),(109,5,0.01),(1010,1,0.02),(1010,2,0.04),(1010,3,0.06),(1010,4,0.08),(1010,5,0.01),(1011,1,0.005),(1011,2,0.01),(1011,3,0.015),(1011,4,0.02),(1011,5,0.025),(1012,1,10),(1012,2,20),(1012,3,30),(1012,4,40),(1012,5,50);

/*Table structure for table `s_hero` */

DROP TABLE IF EXISTS `s_hero`;

CREATE TABLE `s_hero` (
  `id` int(11) NOT NULL COMMENT '$自增ID',
  `name` varchar(32) collate utf8_bin NOT NULL COMMENT '英雄名称',
  PRIMARY KEY  (`id`,`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

/*Data for the table `s_hero` */

/*Table structure for table `s_hero_lv` */

DROP TABLE IF EXISTS `s_hero_lv`;

CREATE TABLE `s_hero_lv` (
  `heroId` smallint(6) NOT NULL COMMENT '$',
  `heroLv` tinyint(4) NOT NULL COMMENT '$',
  PRIMARY KEY  (`heroId`,`heroLv`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

/*Data for the table `s_hero_lv` */

/*Table structure for table `s_prop` */

DROP TABLE IF EXISTS `s_prop`;

CREATE TABLE `s_prop` (
  `id` smallint(6) NOT NULL COMMENT '$道具ID',
  `name` varchar(32) collate utf8_bin NOT NULL COMMENT '道具名称',
  `gold` smallint(6) NOT NULL COMMENT '金币价格',
  `diamond` smallint(6) NOT NULL COMMENT '钻石价格',
  `reo` smallint(6) NOT NULL COMMENT '稀土价格',
  `info` varchar(256) collate utf8_bin NOT NULL COMMENT '道具说明',
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

/*Data for the table `s_prop` */

insert  into `s_prop`(`id`,`name`,`gold`,`diamond`,`reo`,`info`) values (1,'玩家经验卡（1日）',0,300,0,'对局后玩家获得双倍经验'),(2,'玩家经验卡（3日）',0,650,0,'对局后玩家获得双倍经验'),(3,'玩家经验卡（7日）',0,1100,0,'对局后玩家获得双倍经验'),(4,'角色经验卡（1日）',0,300,0,'对局后使用角色获得双倍经验'),(5,'角色经验卡（3日）',0,650,0,'对局后使用角色获得双倍经验'),(6,'角色经验卡（7日）',0,1100,0,'对局后使用角色获得双倍经验'),(7,'胜利经验卡（角色4胜）',0,150,0,'对局后使用角色获得双倍经验'),(8,'胜利经验卡（角色10胜）',0,250,0,'对局后使用角色获得双倍经验'),(9,'双倍金币卡（1日）',0,300,0,'对局结算获得双倍金币'),(10,'双倍金币卡（3日）',0,650,0,'对局结算获得双倍金币'),(11,'双倍金币卡（7日）',0,1100,0,'对局结算获得双倍金币'),(12,'胜利经验卡（4胜）',0,150,0,'对局结算获得双倍金币'),(13,'胜利经验卡（10胜）',0,250,0,'对局结算获得双倍金币'),(14,'超能基因页X2',0,1500,0,'获得额外超能基因装备页码');

/*Table structure for table `s_skill` */

DROP TABLE IF EXISTS `s_skill`;

CREATE TABLE `s_skill` (
  `id` smallint(6) NOT NULL COMMENT '%自增ID',
  `name` varchar(32) collate utf8_bin NOT NULL COMMENT '技能名称',
  `info` varchar(256) collate utf8_bin NOT NULL COMMENT '技能描述',
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

/*Data for the table `s_skill` */

/*Table structure for table `t_nickname` */

DROP TABLE IF EXISTS `t_nickname`;

CREATE TABLE `t_nickname` (
  `nickname` varchar(20) NOT NULL default '' COMMENT '$昵称',
  `userId` int(11) NOT NULL default '0' COMMENT '角色Id',
  PRIMARY KEY  (`userId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

/*Data for the table `t_nickname` */

/*Table structure for table `t_scene` */

DROP TABLE IF EXISTS `t_scene`;

CREATE TABLE `t_scene` (
  `userId` int(11) NOT NULL default '0' COMMENT '$角色Id',
  `nickname` varchar(20) NOT NULL default '' COMMENT '昵称',
  `careerId` tinyint(3) NOT NULL default '0' COMMENT '职业Id',
  `lv` tinyint(3) NOT NULL default '0' COMMENT '等级',
  `battleValue` int(11) NOT NULL default '0' COMMENT '战斗力',
  `achievement` smallint(6) NOT NULL default '0' COMMENT '成就点',
  `totalPaySum` int(11) NOT NULL default '0' COMMENT '总充值金额(人民币,此值确定vip等级)',
  `vipExperienceEndTime` int(11) NOT NULL default '0' COMMENT 'vip体验卡的结束时间',
  `charm` int(11) NOT NULL default '0' COMMENT '魅力值',
  `unionId` int(11) NOT NULL default '0' COMMENT '公会id',
  `fashionId` smallint(6) NOT NULL default '0' COMMENT '穿上的时装id',
  `wingId` smallint(6) NOT NULL default '0' COMMENT '穿上的翅膀id',
  `titleId` smallint(6) NOT NULL default '0' COMMENT '使用的称号id',
  `weaponQuality` tinyint(3) NOT NULL default '0' COMMENT '使用的武器品质',
  `clothesQuality` tinyint(3) NOT NULL default '0' COMMENT '使用的衣服品质',
  `mercId` int(11) NOT NULL default '0' COMMENT '佣兵的自增id',
  PRIMARY KEY  (`userId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='用户场景临时数据表';

/*Data for the table `t_scene` */

/*Table structure for table `t_userid` */

DROP TABLE IF EXISTS `t_userid`;

CREATE TABLE `t_userid` (
  `userId` int(11) NOT NULL default '0' COMMENT '$角色Id',
  `nickname` varchar(20) NOT NULL default '' COMMENT '昵称',
  `careerId` tinyint(4) default NULL,
  `unionId` int(11) default NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

/*Data for the table `t_userid` */

/*Table structure for table `u_data` */

DROP TABLE IF EXISTS `u_data`;

CREATE TABLE `u_data` (
  `userId` int(11) NOT NULL default '0' COMMENT '$角色Id',
  `blessTime` int(11) NOT NULL default '0' COMMENT '最后祈福时间',
  `blessGoldSum` tinyint(3) NOT NULL default '0' COMMENT '当日祈福金币次数',
  `blessSoulSum` tinyint(3) NOT NULL default '0' COMMENT '当日祈福战魂次数',
  `blessGodhoodSum` tinyint(3) NOT NULL default '0' COMMENT '当日祈福神格次数',
  `getPayFirstTime` int(11) NOT NULL default '0' COMMENT '领取首冲奖励的时间',
  `checkinTime` int(11) NOT NULL default '0' COMMENT '最后签到时间',
  PRIMARY KEY  (`userId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='用户数据表';

/*Data for the table `u_data` */

/*Table structure for table `u_hero` */

DROP TABLE IF EXISTS `u_hero`;

CREATE TABLE `u_hero` (
  `id` int(11) NOT NULL COMMENT '$自增ID',
  `heroId` smallint(6) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

/*Data for the table `u_hero` */

/*Table structure for table `u_info` */

DROP TABLE IF EXISTS `u_info`;

CREATE TABLE `u_info` (
  `id` int(11) NOT NULL default '0' COMMENT '$自增id',
  `passId` varchar(100) collate utf8_bin NOT NULL default '0' COMMENT '通行证id',
  `platform` varchar(100) collate utf8_bin NOT NULL default '' COMMENT '平台名',
  `info` varchar(100) collate utf8_bin NOT NULL default '' COMMENT '平台返回的用户昵称(例：九游玩家706083160，后面的数字为UC号)',
  PRIMARY KEY  (`id`),
  UNIQUE KEY `passId_serverId` (`passId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='@用户信息表(登录时更新)';

/*Data for the table `u_info` */

insert  into `u_info`(`id`,`passId`,`platform`,`info`) values (1010000001,'900086000026343714','*','');

/*Table structure for table `u_player` */

DROP TABLE IF EXISTS `u_player`;

CREATE TABLE `u_player` (
  `userId` int(11) NOT NULL default '0' COMMENT '$角色Id',
  `infoId` int(11) NOT NULL COMMENT 'U_info ID',
  `areaId` smallint(6) NOT NULL COMMENT '区服ID',
  `nickname` varchar(60) collate utf8_bin NOT NULL default '' COMMENT '昵称',
  `vip` tinyint(4) NOT NULL COMMENT 'VIP',
  `lv` tinyint(3) NOT NULL default '0' COMMENT '等级',
  `exp` int(11) NOT NULL default '0' COMMENT '经验',
  `gold` int(11) NOT NULL default '0' COMMENT '金币',
  `reo` int(11) NOT NULL default '0' COMMENT '稀土',
  `diamond` int(11) NOT NULL COMMENT '钻石',
  PRIMARY KEY  (`userId`),
  UNIQUE KEY `nickname` (`nickname`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='用户属性表';

/*Data for the table `u_player` */

insert  into `u_player`(`userId`,`infoId`,`areaId`,`nickname`,`vip`,`lv`,`exp`,`gold`,`reo`,`diamond`) values (1010000001,1010000001,1,'txoy',0,1,0,10,10,10),(1010000002,1010000001,1,'',0,1,0,10,10,10);

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
