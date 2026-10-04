CREATE VIEW `voptions2` AS

select  `o`.`id` AS `id`,`d`.`label` AS `label`,`d`.`lang` AS `lang`,`o`.`mandatory` AS `mandatory`,
        `o`.`style` AS `style`,`o`.`instime` AS `instime`,`o`.`weight` AS `weight`,
        `o`.`inc_art_no` AS `inc_art_no`,`f`.`description` AS `sel_desc`,`f`.`details_id` AS `det_id`,
        `f`.`id` AS `feat_id`,`x`.`ref` AS `ref`,`x`.`amount` AS `amount`,`x`.`stock` AS `stock`,
        `x`.`instime` AS `feat_instime`

from    (((`options` `o` join `options_desc` `d` on(`o`.`id` = `d`.`option_id`))

        join    `options_feat` `f` on(`f`.`option_id` = `o`.`id`))

        left join `options_details` `x` on(`f`.`details_id` = `x`.`id`))

where   `d`.`lang` = `f`.`lang`;
