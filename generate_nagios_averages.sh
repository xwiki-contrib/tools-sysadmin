#!/bin/sh
# 
# This script is designed to automate some information gathering from Nagios, and is by no means complete, good, or valuable in its current state, 
# however, it can be extended and fixed to better suit any specific needs
# It connects to a Nagios instance (using an username and password) then parses the output of the avail.cgi script for all the months of the current year 
# in order to get the average values and construct the data as required by the Graphing script (https://developers.google.com/chart/)
#

# You need to edit this part
USERPASS='username:password'
HOST='http://127.0.0.1'
SERVICES='Host_Uptime Check_Backup Check_XWiki_Service Load_Average Mysql Tomcat_Service Xinit_Cron_Service Check_Disk_Service Check_Puppet'

# Rest of the code
MONTH=`date +"%m" | sed -e 's/^0//'`
Month_Names=('January' 'February' 'March' 'April' 'May' 'June' 'July' 'August' 'September' 'October' 'November' 'December');
HEADER="['Date', "
for i in `seq 0 $MONTH`
do
  LINE="['${Month_Names[$i-1]} 2013', "
  for service in $SERVICES
  do
    if [ $i -eq 0 ] 
      then
      HEADER="$HEADER '$service', "
    fi
    if [ $i -ne 0 ] 
     then
     if [ "$service" == "Host_Uptime" ]
       then
       NUMBER=`curl -s -u $USERPASS "$HOST/cgi-bin/avail.cgi?show_log_entries=&host=all&timeperiod=custom&smon=$i&sday=1&syear=2013&shour=0&smin=0&ssec=0&emon=$i&eday=30&eyear=2013&ehour=24&emin=0&esec=0&rpttimeperiod=&assumeinitialstates=yes&assumestateretention=yes&assumestatesduringnotrunning=yes&includesoftstates=no&initialassumedhoststate=3&initialassumedservicestate=6&backtrack=4" | grep ".*Average<\/td><td CLASS='hostUP'>" | sed -e "s/.*Average<\/td><td CLASS='hostUP'>//" | sed -e "s/% (.*$//"`
        LINE="${LINE}${NUMBER}, "
      else 
       NUMBER=`curl -s -u $USERPASS "$HOST/cgi-bin/avail.cgi?show_log_entries=&servicegroup=$service&timeperiod=custom&smon=$i&sday=1&syear=2013&shour=0&smin=0&ssec=0&emon=$i&eday=30&eyear=2013&ehour=24&emin=0&esec=0&rpttimeperiod=&assumeinitialstates=yes&assumestateretention=yes&assumestatesduringnotrunning=yes&includesoftstates=no&initialassumedhoststate=3&initialassumedservicestate=6&backtrack=4" 2>&1 | grep "colspan='2'>Average</td><td CLASS='serviceOK'>" | sed -e "s/<tr CLASS='dataEven'><td CLASS='dataEven' colspan='2'>Average<\/td><td CLASS='serviceOK'>//" | sed -e "s/% (.*$//"`
        LINE="${LINE}${NUMBER}, "
      fi
    fi 
  done
  if [ $i -eq 0 ]
    then
    echo "$HEADER],"
  else
    echo "$LINE],"
  fi
done
