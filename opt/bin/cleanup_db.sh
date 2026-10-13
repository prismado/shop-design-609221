#!/bin/bash

# -- Framework(s):

DBNAME=$DB_NAME
DBHOST=$DB_HOST
DBPASS=$DB_PASS

echo "DELETE FROM session WHERE TIMESTAMPDIFF(minute, tstamp, NOW()) > 144000 AND \`key\` LIKE '\_%'"    | mysql -h $DBHOST -p$DBPASS -u apache -D $DBNAME # -- 100 days
echo 'DELETE FROM log     WHERE time_to_sec(timediff(now(), tstamp)) > 259200'                           | mysql -h $DBHOST -p$DBPASS -u apache -D $DBNAME # -- 3 days
echo "DELETE FROM session WHERE time_to_sec(timediff(now(), tstamp)) > 28800 AND \`key\` NOT LIKE '\_%'" | mysql -h $DBHOST -p$DBPASS -u apache -D $DBNAME # -- 8 hours
echo 'DELETE FROM work    WHERE time_to_sec(timediff(now(), tstamp)) > 259200'                           | mysql -h $DBHOST -p$DBPASS -u apache -D $DBNAME # -- 3 days
echo 'DELETE FROM orders_status WHERE status_id IN (5000, 5001) AND TIMESTAMPDIFF(MINUTE, created_at, NOW()) > 180' | mysql -h $DBHOST -p$DBPASS -u apache -D $DBNAME

echo 'OPTIMIZE TABLE config, log, work, session, sid_seq, users, orders_status' | mysql -h $DBHOST -p$DBPASS -u apache -D $DBNAME
