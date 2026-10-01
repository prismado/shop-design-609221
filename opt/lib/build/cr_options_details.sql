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
-- Table structure for table `options_details`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `options_details` (
  `id` mediumint(8) unsigned NOT NULL AUTO_INCREMENT,
  `instime` timestamp NOT NULL DEFAULT current_timestamp(),
  `ref` char(31) DEFAULT NULL,
  `amount` double DEFAULT NULL COMMENT 'Excl. VAT',
  `stock` int(11) NOT NULL DEFAULT -1 COMMENT 'Availble items. -1 = unlim',
  PRIMARY KEY (`id`),
  UNIQUE KEY `ref` (`ref`)
) ENGINE=MyISAM AUTO_INCREMENT=772 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='Elements of an option group';
/*!40101 SET character_set_client = @saved_cs_client */;
