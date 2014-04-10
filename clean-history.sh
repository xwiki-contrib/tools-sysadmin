#!/bin/bash

# Script to clean all history before a specific time ($NOTSINCE) for all $LIMIT biggest xwikircs pages. For every pages before that date, it never removes everything but keeps the last version (in order to avoid having nothing at all in the history tab) or more ($KEEP)
#

DB='xwiki'

#Never Delete Since (YYYY-MM-DD):
NOTSINCE='2014-04-01'

# Operate on $LIMIT pages with biggest history
LIMIT=20

# How many versions to keep.
KEEP=1

TMPFILE='/tmp/.cleanhistory'


rm -f "$TMPFILE" 2>/dev/null

mysql -N -s -r -e "use $DB; select count(r.xwr_docid),d.xwd_id from xwikircs as r,xwikidoc as d WHERE r.xwr_docid=d.xwd_id AND r.xwr_date < \"$NOTSINCE\" group by d.xwd_id order by count(r.xwr_docid) DESC limit $LIMIT INTO OUTFILE \"$TMPFILE\" FIELDS TERMINATED BY ' ';"

if [[ -s "$TMPFILE" ]];then

 while read line ; do
   # read every line of the generated result file and put every field in a variable, to process them later
   read occ id <<<$(echo $line)
   occ=$(($occ-$KEEP))
   mysql -e "use $DB; delete FROM xwikircs WHERE xwr_docid=$id AND xwr_date < $NOTSINCE limit $occ;"
 done < "$TMPFILE"

 rm -f "$TMPFILE" 2>/dev/null

else
 echo "Nothing to do…"
fi
