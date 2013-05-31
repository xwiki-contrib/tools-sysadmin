#!/bin/bash

## Built to work a on XWiki Schema (3.x or 4.x)
nbcoms=50  ## Number of comments above which you get alerted (Spam Threshold).

mysql_cmd="mysql -u root --password="
mysql_cmd_short="$mysql_cmd -N -r -s"

databases=$($mysql_cmd_short -e 'show databases'|grep -v -E '^(information|performance)_schema$|^mysql$')

for db in ${databases}
do

   if [[ -z "$($mysql_cmd_short -e "use $db;show tables" |grep xwikidoc)" ]]
   then
        echo "Database $db is not a valid XWiki Database"
   else

   check_commands=$($mysql_cmd -e "use $db; select count(XWO_NAME) as coms,XWO_NAME as doc from xwikiobjects where XWO_CLASSNAME='XWiki.XWikiComments' GROUP BY XWO_NAME HAVING coms >= $nbcoms;")

       if [[ -n ${check_commands} ]]
       then
           echo "We have found more than $nbcoms comments in database  *** $db *** :"
           $mysql_cmd -e "use $db; select count(XWO_NAME) as coms,XWO_NAME as doc from xwikiobjects where XWO_CLASSNAME='XWiki.XWikiComments' GROUP BY XWO_NAME HAVING coms >= $nbcoms;"
       fi
   fi
done
