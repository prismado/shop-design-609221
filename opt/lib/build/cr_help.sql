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
-- Table structure for table `help`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `help` (
  `id` mediumint(8) unsigned NOT NULL AUTO_INCREMENT,
  `area` tinyint(3) unsigned NOT NULL,
  `sub_area` tinyint(3) unsigned NOT NULL DEFAULT 1,
  `mnemonic` char(31) NOT NULL,
  `audience` char(15) NOT NULL DEFAULT 'adm' COMMENT 'adm or dev',
  `title_en` varchar(255) NOT NULL,
  `title_de` varchar(255) NOT NULL,
  `created` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00' ON UPDATE current_timestamp(),
  `xval_en` varchar(2047) NOT NULL,
  `xval_de` varchar(2047) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `areas` (`area`,`sub_area`),
  UNIQUE KEY `mnemonic` (`mnemonic`),
  FULLTEXT KEY `title_en` (`title_en`),
  FULLTEXT KEY `title_de` (`title_de`),
  FULLTEXT KEY `xval_de` (`xval_de`),
  FULLTEXT KEY `xval_en` (`xval_en`)
) ENGINE=MyISAM AUTO_INCREMENT=80 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `help`
--

LOCK TABLES `help` WRITE;
/*!40000 ALTER TABLE `help` DISABLE KEYS */;
INSERT INTO `help` VALUES
(1,4,1,'cancel_order','adm','Bestellung stornieren','Bestellung stornieren','2024-07-13 10:59:41','2024-07-14 12:18:04','','Stornierung von Bestellungen<!-- offene/pendente/storno -->'),
(2,7,3,'copy_product','adm','Produkt kopieren','Produkt kopieren','2024-07-13 10:59:41','2024-07-13 17:00:09','','Bestehendes Produkt kopieren'),
(3,4,2,'order','adm','','Bestellung','2024-07-13 13:03:57','2024-07-19 13:18:04','','Informationen zu Bestellungen<!-- mail -->'),
(4,4,3,'delivery_note','adm','','Lieferschein','2024-07-13 13:03:57','2024-10-04 15:00:10','','Erstellen und Bearbeiten von ...<!-- EDI,PDF -->'),
(5,4,5,'order_hist','adm','','History / Verlauf','2024-07-13 13:03:57','2024-07-19 11:09:03','','Ereignisse rund um den Bestellverlauf<!-- Status -->'),
(6,4,4,'send_remind_pend_order','adm','','Erinnerung bei offener Bestellung','2024-07-13 13:03:57','2024-07-13 17:09:03','','Automatische E-Mail nach tbd Std./Min.'),
(7,1,1,'user_general','adm','','Allgemein','2024-07-13 13:03:57','2024-10-26 13:09:04','','Benutzer anlegen und generelle Informationen, Berechtigungen'),
(8,1,2,'user_history','adm','','Aktivit&auml;tsverlauf','2024-07-13 13:03:57','2024-07-13 17:00:09','','User History'),
(9,7,1,'create_product','adm','','Produkt erstellen','2024-07-13 13:03:57','2024-10-15 08:45:03','','Neues Produkt<!-- Artikelnummer,Grade,Grading -->'),
(10,7,5,'prod_discount','adm','','Rabatt','2024-07-13 13:03:57','2024-11-28 09:00:25','','Produkt mit Rabatt reduzieren: Prozent oder Betrag<!-- Geplante Rabatte -->'),
(11,7,2,'gtin','adm','','GTIN','2024-07-13 13:03:57','2024-07-13 16:45:02','','8, oder 12 bis 14-stellige Zahl'),
(12,7,4,'product_manage','adm','','Artikelbearbeitung','2024-07-13 13:03:57','2024-09-27 15:36:07','','Erstellen und Bearbeiten von Artikeln<!-- Exclude,Optionen -->'),
(13,9,1,'err_407131_6','adm','','Fehler / Hinweise','2024-07-13 13:03:57','2024-07-13 17:09:03','','Fehlerbehandlung und Hinweise'),
(15,9,4,'tbd_407131_13','adm','','Fehler Tbd 2','2024-07-13 13:11:35','2024-07-13 13:18:21','','Eine Fehlerbehandlung'),
(16,10,1,'tbd_407141_6','adm','','Online-Hilfe und System-Dokumentation','2024-07-14 10:00:07','2024-10-10 11:45:03','','F&uuml;r Entwickler<!-- Upload -->'),
(17,10,4,'tbd_407141_14','adm','','Online-Hilfe 2','2024-07-14 10:00:07','0000-00-00 00:00:00','','...'),
(18,10,2,'sub_routines','adm','','System-Dokumentation: Sub-Routinen','2024-07-14 14:45:04','0000-00-00 00:00:00','','...'),
(22,4,6,'edi_order','adm','','EDI-Bestellung (Galaxus)','2024-07-16 10:00:05','0000-00-00 00:00:00','','Bestellungen via EDI-Schnittstelle'),
(23,11,1,'prism_core','dev','','Core','2024-07-16 10:00:05','2024-07-23 12:00:08','','Prismado Core Functions<!-- get_webenv,mail_x -->'),
(24,11,2,'web_components','dev','','Web Components','2024-07-16 10:00:05','2024-09-12 10:09:05','','DataTables etc.<!-- Modal,orders,Prismado Dialog -->'),
(25,12,1,'dhl','adm','','DHL-Schnittstelle','2024-07-16 13:27:02','2024-10-16 11:45:03','','...'),
(26,12,4,'newsletter','dev','','Newsletter','2024-07-16 13:27:02','2024-10-06 11:27:03','','Einstellungen<!-- E-Mail,email,Newsletter -->'),
(27,11,3,'sys_jobs','dev','','System Jobs','2024-07-19 10:00:06','2024-08-21 08:36:05','','Periodische automatische Verarbeitungen<!-- EDI,hourly_tasks -->'),
(28,11,4,'prism_shop_core','dev','','Shop','2024-07-19 13:09:03','2024-08-27 12:18:05','','Prismado Core Functions<!-- add_item,env,is_primary -->'),
(29,1,3,'forgot_login','dev','','Login / Passwort vergessen','2024-07-20 10:00:06','0000-00-00 00:00:00','','...<!-- forgot,login,password -->'),
(30,13,1,'main_data','adm','','Stammdaten','2024-07-20 10:00:06','2024-09-13 08:00:26','','Masterdaten, Stammdaten, Logo<!-- ChatGPT,KI,Properties,Safe properties -->'),
(31,13,4,'mail_templates','dev','','E-Mail Templates','2024-07-20 10:00:06','2024-08-13 09:36:04','','E-Mail-Templates, Vorlagen'),
(32,14,1,'tbd_407221_7','adm','','Pro-Zone','2024-07-22 09:00:07','0000-00-00 00:00:00','','Zusammenfassung zur Funktion Mitarbeiter-Shop<!-- prozone -->'),
(33,14,2,'tbd_407221_17','dev','','Pro-Zone (2)','2024-07-22 09:00:07','0000-00-00 00:00:00','','Devel<!-- prozone -->'),
(34,11,5,'web_redir','dev','','Redirects','2024-07-22 09:00:07','0000-00-00 00:00:00','','...<!-- Redirects,Redirs -->'),
(35,1,4,'tbd','dev','','send_register_invitation','2024-07-22 13:09:03','0000-00-00 00:00:00','','...<!-- send_register_invitation -->'),
(36,15,1,'docker_setup','dev','','Setup','2024-07-23 15:27:02','2024-07-24 08:00:06','','Docker Container Setup'),
(37,15,4,'tbx_407232_15','dev','','Tbd 2','2024-07-24 08:00:06','0000-00-00 00:00:00','','...'),
(38,11,6,'session','dev','','Sessions','2024-07-26 11:45:03','0000-00-00 00:00:00','','...<!-- sessions -->'),
(39,7,6,'delete_product','dev','','Produkt l&ouml;schen','2024-07-28 15:54:04','0000-00-00 00:00:00','','...'),
(40,7,7,'product_hist','dev','','History / Verlauf','2024-07-30 08:00:07','0000-00-00 00:00:00','','...<!-- History -->'),
(41,13,5,'art_properties','adm','','Artikeleigenschaften','2024-08-16 09:54:04','2024-09-15 14:00:08','','Standard-Label der Artikeleigenschaften<!-- Stammdaten,Vorauswahl -->'),
(42,11,7,'product_dev','dev','','Produkt','2024-09-01 12:36:06','2024-12-04 09:00:14','','Artikel<!-- Alarmierung,Alert,Aufmerksamkeit,Benachrichtigung,Produkt,Spezialfall,Upload -->'),
(43,11,8,'action','dev','','Actions','2024-09-02 08:00:27','0000-00-00 00:00:00','','...<!-- actions -->'),
(44,11,9,'wysiwyg_edit','dev','','Wysiwyg Editor','2024-09-09 11:54:04','0000-00-00 00:00:00','','<!-- Editor,Wysiwyg -->'),
(45,3,1,'payment_overview','adm','','Payment','2024-09-10 09:45:03','0000-00-00 00:00:00','','&Uuml;bersicht<!-- Payment,Payrexx -->'),
(46,3,2,'voucher','dev','','Gutschein-Code (Voucher)','2024-09-10 09:45:04','2024-09-23 08:00:12','','...<!-- Gutschein,Voucher -->'),
(47,11,10,'ui_components','dev','','UI Components','2024-09-12 11:54:04','2024-09-12 12:00:10','','Forms, Input<!-- Dropdown -->'),
(48,16,1,'ai_overview','dev','','&Uuml;bersicht','2024-09-13 14:00:09','2024-09-13 14:09:03','','tbd<!-- AI,KI -->'),
(49,16,2,'tbx_409131_15','dev','','Tbd 2','2024-09-13 14:00:09','0000-00-00 00:00:00','','...'),
(50,11,11,'post_proc','dev','','Post-processing','2024-09-17 10:09:05','0000-00-00 00:00:00','','...<!-- tbd -->'),
(51,7,8,'edi_product_export','adm','','EDI Produkte-Export','2024-09-20 08:00:17','2024-10-13 08:00:07','','EDI Produkte-Export<!-- Restock Date -->'),
(52,17,1,'design_overview','adm','','&Uuml;bersicht','2024-09-22 09:45:03','2024-12-29 09:00:03','','Inhalt<!-- Design,Font,Layout,Schriftarten,Symbole,Unicode,Upload -->'),
(53,17,2,'design_basket','dev','','Warenkorb','2024-09-22 09:45:03','2024-09-22 12:52:04','','Warenkorb<!-- Basket -->'),
(54,3,3,'vat','adm','','Mehrwertsteuer (VAT / Tax)','2024-09-23 14:36:06','0000-00-00 00:00:00','','...<!-- Mehrwertsteuer,TAX,VAT -->'),
(55,17,3,'teaser','adm','','Teaser','2024-09-25 08:45:03','2024-11-26 09:00:17','','Inhalte<!-- Banner,Content,Teaser -->'),
(56,17,4,'seo','adm','','SEO - Keywords','2024-10-03 13:22:05','2024-10-03 13:36:08','','Einstellungen<!-- Google,Keywords,SEO -->'),
(57,4,7,'paypal','adm','','PayPal','2024-10-04 11:36:07','0000-00-00 00:00:00','','Bestellung<!-- PayPal -->'),
(58,4,8,'invoice','adm','','PDF QR-Rechnung','2024-10-04 15:09:04','0000-00-00 00:00:00','','PDF-Rechnung<!-- QR -->'),
(59,17,5,'product_presentation','adm','','Produkte-Pr&auml;sentation','2024-10-13 08:36:05','0000-00-00 00:00:00','','Inhalte<!-- Darstellung,Design,Produkt -->'),
(60,7,9,'edi_product_refurbished','adm','','EDI Produkte Refurbished','2024-10-13 13:46:04','2025-04-02 10:27:02','','Refurbished<!-- EDI, Restock Date -->'),
(61,7,10,'daily_offer','adm','','Tagesangebot / Daily Offer','2024-10-15 08:00:07','0000-00-00 00:00:00','','...<!-- Daily Offer,Tagesangebot -->'),
(62,12,2,'ads','adm','','Google Ads / SEO / SEA','2024-10-16 11:45:03','0000-00-00 00:00:00','','Google'),
(63,4,9,'returns','adm','','Retouren','2024-10-22 08:00:14','0000-00-00 00:00:00','','RMA / Retouren / Sales Returns'),
(64,11,12,'failover','dev','','Failover','2024-10-22 09:18:05','0000-00-00 00:00:00','','Backup<!-- Failover -->'),
(65,12,5,'rating','adm','','Rating','2024-10-23 08:00:07','0000-00-00 00:00:00','','..<!-- Rating -->'),
(66,7,11,'category','adm','','Kategorien','2024-10-26 12:08:10','2024-10-26 13:30:07','','Kategorien<!-- Category,Service-Portal -->'),
(67,11,13,'mail_reports','dev','','E-Mail-Reports','2024-11-02 09:18:04','0000-00-00 00:00:00','','Daily Reports<!-- Alerts -->'),
(68,11,14,'performance','dev','','Performance','2024-11-03 09:09:04','0000-00-00 00:00:00','','Leistungsoptimierung<!-- Performance -->'),
(69,11,15,'theme','dev','','Theme / Webseiten-Template','2024-11-03 09:45:05','2024-11-03 12:27:03','','Infos<!-- Performance,LazyLoad,Theme -->'),
(70,12,6,'cmp','dev','','Consent Mode v2','2024-11-06 09:00:21','0000-00-00 00:00:00','','Cookie-Einwilligung<!-- Einwilligung,CMP,Consent Mode -->'),
(71,11,16,'modal','dev','','Modal','2024-11-17 17:00:08','0000-00-00 00:00:00','','Modal'),
(72,11,17,'css','dev','','CSS','2024-11-19 12:27:03','0000-00-00 00:00:00','','Theme / CSS'),
(73,17,6,'dark_mode','adm','','Dark Mode','2024-11-25 13:20:03','0000-00-00 00:00:00','','Dark Mode'),
(74,4,10,'sales_report','adm','','Verkaufs-Statistiken','2024-11-26 13:34:16','2024-11-26 13:44:14','','Verkaufs-Statistiken, Umsatz'),
(75,12,7,'edi_config','dev','','EDI-Konfiguration','2025-01-16 10:00:03','0000-00-00 00:00:00','','EDI-Konfiguration'),
(76,13,6,'notifications','adm','','Benachrichtigungen','2025-01-25 13:05:03','0000-00-00 00:00:00','','E-Mail-Benachrichtigungen, Notifications'),
(77,11,18,'cleanup','dev','','Cleanup','2025-01-25 13:54:02','0000-00-00 00:00:00','','tbd<!-- Performance,LazyLoad,Theme -->'),
(78,4,11,'edi_order_process','adm','','EDI-Bestellung, Admin-Bearbeitung','2025-03-18 09:45:02','0000-00-00 00:00:00','','Bestellungen via EDI-Schnittstelle'),
(79,11,19,'prism_multilang','dev','','Core','2026-04-02 09:27:02','0000-00-00 00:00:00','','Prismado Multilingualit&auuml;t<!-- lang,multilang -->');
/*!40000 ALTER TABLE `help` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-10-01 11:39:05
