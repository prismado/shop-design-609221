/*M!999999\- enable the sandbox mode */
-- MariaDB dump 10.19  Distrib 10.11.14-MariaDB, for debian-linux-gnu (x86_64)
--
-- Host: db-60528-algo-main-naitik    Database: db_shopd
-- ------------------------------------------------------
-- Server version       11.8.8-MariaDB-ubu2404

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `options_feat`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `options_feat` (
  `id` mediumint(8) unsigned NOT NULL AUTO_INCREMENT,
  `option_id` mediumint(8) unsigned NOT NULL COMMENT 'foreign key',
  `instime` timestamp NOT NULL DEFAULT current_timestamp(),
  `lang` char(3) NOT NULL DEFAULT 'de',
  `details_id` mediumint(8) unsigned NOT NULL DEFAULT 0 COMMENT 'Refers to options_details',
  `description` varchar(511) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '02Apr2024: zu utf8mb4',
  PRIMARY KEY (`id`),
  UNIQUE KEY `unq` (`option_id`,`lang`,`details_id`),
  KEY `option_id` (`option_id`),
  KEY `details_id` (`details_id`),
  KEY `lang` (`lang`)
) ENGINE=MyISAM AUTO_INCREMENT=2485 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
