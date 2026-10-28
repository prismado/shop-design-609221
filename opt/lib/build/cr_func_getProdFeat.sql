DELIMITER //

CREATE FUNCTION `getProdFeat`(
    `prodid` MEDIUMINT,
    `featk` CHAR(31)
)
RETURNS VARCHAR(2047)
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_general_ci
READS SQL DATA
RETURN (
    SELECT `description`
    FROM `products_feat`
    WHERE `product_id` = `prodid`
      AND `lang` IN ('de', 'SYS')
      AND `featkey` = `featk`
    LIMIT 1
)//

DELIMITER ;
