/*
SQLyog Ultimate v8.32 
MySQL - 5.5.53 : Database - ncmj
*********************************************************************
*/

/*!40101 SET NAMES utf8 */;

/*!40101 SET SQL_MODE=''*/;

/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
CREATE DATABASE /*!32312 IF NOT EXISTS*/`ncmj` /*!40100 DEFAULT CHARACTER SET utf8 COLLATE utf8_bin */;

USE `ncmj`;

/*Table structure for table `t_brand` */

DROP TABLE IF EXISTS `t_brand`;

CREATE TABLE `t_brand` (
  `id` int(11) NOT NULL COMMENT '$',
  `value` tinyint(4) DEFAULT NULL,
  `state` tinyint(4) DEFAULT NULL,
  `index` tinyint(4) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

/*Data for the table `t_brand` */

/*Table structure for table `t_state` */

DROP TABLE IF EXISTS `t_state`;

CREATE TABLE `t_state` (
  `userId` int(11) NOT NULL COMMENT '$',
  `index` tinyint(4) DEFAULT NULL,
  `state` tinyint(4) DEFAULT NULL,
  PRIMARY KEY (`userId`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

/*Data for the table `t_state` */

/*Table structure for table `u_data` */

DROP TABLE IF EXISTS `u_data`;

CREATE TABLE `u_data` (
  `userId` int(11) NOT NULL COMMENT '$',
  `state` tinyint(4) DEFAULT NULL,
  `roomCard` int(11) DEFAULT NULL,
  PRIMARY KEY (`userId`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

/*Data for the table `u_data` */

/*Table structure for table `u_info` */

DROP TABLE IF EXISTS `u_info`;

CREATE TABLE `u_info` (
  `id` int(11) NOT NULL COMMENT '$',
  `passId` varchar(40) COLLATE utf8_bin DEFAULT NULL COMMENT '通行证id',
  `password` varchar(40) COLLATE utf8_bin DEFAULT NULL COMMENT '用户密码',
  `regTime` int(11) DEFAULT NULL COMMENT '注册时间(首次登录时间)',
  `loginTime` int(11) DEFAULT NULL COMMENT '最近登录时间',
  `ip` int(11) DEFAULT NULL COMMENT '最近登录时的IP',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

/*Data for the table `u_info` */

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
