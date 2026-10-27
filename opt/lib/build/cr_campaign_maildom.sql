CREATE TABLE `campaign_maildom` (
  `id`          mediumint(8) unsigned NOT NULL  AUTO_INCREMENT COMMENT 'XXX Refers to products : campaign_id',
  `instime`     timestamp NOT NULL              DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `company_id`  smallint(5) unsigned            NOT NULL COMMENT 'Refers to companies [id]',
  `mail_domain` char(127)                       DEFAULT NULL,

  PRIMARY KEY (`id`),
  KEY `company_id` (`company_id`)

) ENGINE=MyISAM AUTO_INCREMENT=37 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
