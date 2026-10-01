DROP VIEW IF EXISTS voptions;

CREATE ALGORITHM=UNDEFINED 
	DEFINER=`root`@`localhost` 
	SQL SECURITY DEFINER 
	VIEW `voptions` AS (

	select	`o`.`id` AS `id`,`o`.`style` AS `style`, o.mandatory,
		`d`.`lang` AS `lang`,`d`.`label` AS `label`,
		`f`.`description` AS `description`,`p`.`ref` AS `ref`,`p`.`amount` AS `amount`,
		`p`.`id` AS `det_id`,`f`.`id` AS `feat_id`,
		`o`.`weight` AS `weight`,`p`.`stock` AS `stock`

	from 	(((`options` `o`
		join `options_desc` `d`)
		join `options_feat` `f`)
		join `options_details` `p`)

	where 	((`o`.`id` = `d`.`option_id`)
		and (`o`.`id` = `f`.`option_id`)
		and (`f`.`lang` = `d`.`lang`)
		and (`f`.`details_id` = `p`.`id`))

);
