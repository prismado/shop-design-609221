/*M!999999\- enable the sandbox mode */ 
-- MariaDB dump 10.19  Distrib 10.11.14-MariaDB, for debian-linux-gnu (x86_64)
--
-- Host: db-60528-algo-main-naitik    Database: db_shopd
-- ------------------------------------------------------
-- Server version	11.8.8-MariaDB-ubu2404

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
-- Table structure for table `pdf_config`
--

DROP TABLE IF EXISTS `pdf_config`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `pdf_config` (
  `id` mediumint(8) unsigned NOT NULL AUTO_INCREMENT COMMENT 'REM:=Primary Key || READONLY:=readonly',
  `xkey` char(63) NOT NULL COMMENT 'REM:=Param||STYLE:=color:red; font-family:Courier; background-color:#f0f0f0',
  `type` tinyint(3) unsigned DEFAULT NULL,
  `xval` mediumtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT 'STYLE:=background-color:lightyellow; font-weight:bold',
  PRIMARY KEY (`id`),
  UNIQUE KEY `unq` (`xkey`,`type`)
) ENGINE=InnoDB AUTO_INCREMENT=27 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='PDF Konfiguration';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pdf_config`
--

LOCK TABLES `pdf_config` WRITE;
/*!40000 ALTER TABLE `pdf_config` DISABLE KEYS */;
INSERT INTO `pdf_config` VALUES
(1,'default_font',1,'RobotoFlex-Regular'),
(3,'default_font_size',0,'9.5'),
(4,'default_bold_font',0,'Helvetica-Bold'),
(5,'default_margin_left_a4p',0,'60'),
(6,'default_page_start_a4p',0,'750'),
(7,'default_logo_pos_y',0,'760'),
(8,'company',0,'PDF & ACME GmbH'),
(9,'company_street',0,'Moussonstrasse 8'),
(11,'company_zip',0,'8044'),
(12,'company_city',0,'Züri'),
(13,'company_phone',0,'+41 44 555 44 33'),
(15,'logo_path',0,'images/logo_algonetic_black_on_white_299x96.png'),
(17,'logo_height',0,'34'),
(18,'logo_width',0,'105'),
(19,'address_pos_x',0,'355'),
(20,'address_pos_y',0,'695'),
(21,'default_line_height',0,'12'),
(22,'company_vat_no',0,'CHE-434.825.408 (MWST)'),
(23,'company_iban',0,'CH93 0483 5277 5229 1100 1'),
(24,'company_iban_2',0,'CH66 0483 5277 5229 1100 2'),
(25,'company_email',0,'foo.bar@example.ch'),
(26,'company_slogan',0,'im Auftrag der Sub-ACME Züri');
/*!40000 ALTER TABLE `pdf_config` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-10-14 15:46:36
