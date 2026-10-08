CREATE TABLE IF NOT EXISTS `teaser` (
  `id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
  `is_active` tinyint(1) DEFAULT '1',
  `weight` smallint(6) DEFAULT NULL,
  `prod_id` mediumint(8) unsigned DEFAULT NULL,
  `last_mod` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `last_user` char(63) DEFAULT NULL,
  `valid_from` timestamp NULL DEFAULT NULL,
  `valid_to` timestamp NULL DEFAULT NULL,
  `xtext` mediumtext,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 AUTO_INCREMENT=2 ;

ALTER TABLE `teaser` ADD `url` CHAR( 255 ) NULL AFTER `prod_id` ;
