#!/bin/bash

## XWiki large history is not really a problem. It can be, regarding the disk space used, and performances only when someone looks at the history (history tab on a wiki page) of a heavy page.
## By default, XWiki saves a page differentially and store the whole content every 5 versions. So xwikircs table can grow exponentially if the wiki get spammed.
## To sum up, don't pay attention to the history except if your wiki is public (open to guests - and robots) or if your wiki is very old and you're lacking disk space.
#
## To clean the history of a page, you can use the "reset" action from the wiki. Accessing http://wiki/xwiki/bin/reset/XWiki/HugeHistoryPage
#

## Built to work a on XWiki Schema (3.x or 4.x)
nbhistorymin=1000  ## This script will show document having a number of versions (history) > of that value. 0 to deactivate any limit.
nbresults=15  ## Number of lines shown for every database.

mysql_cmd="mysql -u root --password="
mysql_cmd_short="$mysql_cmd -N -r -s"

databases=$($mysql_cmd_short -e 'show databases'|grep -v -E '^(information|performance)_schema$|^mysql$')

for db in ${databases}
do

   if [[ -z "$($mysql_cmd_short -e "use $db;show tables" |grep xwikidoc)" ]]
   then
        echo "Database $db is not a valid XWiki Database"
   else

   	echo "Showing history for database *** $db *** :"
   	$mysql_cmd -e "use $db;select count(r.xwr_docid) as NbVersions,d.xwd_id as DocId,d.xwd_fullname as DocName from xwikircs as r,xwikidoc as d where r.xwr_docid=d.xwd_id group by DocId having NbVersions >= $nbhistorymin order by NbVersions DESC limit $nbresults;"
   fi
done
