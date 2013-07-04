#!/bin/bash
#
# This script, developed by XWiki SAS team, indend to provide an easy way to migrate Engine or Character Set/Collation of XWiki tables.
# It only works with MySQL for the moment
#
# Feel free to push updates
#
## CONFIGURATION ##
mysql_cmd="mysql -u root --password="
###################

function migrate_engine_code() {

echo -n "Migrating database $db ..."
TABLES=$($mysql_cmd_short -e "show tables from $db;")
for tb in $TABLES
do
  $mysql_cmd -e "ALTER TABLE $db.$tb ENGINE = $to_engine;"
done
if [[ $? == "0" ]] ; then
    echo "[OK]"
else
    echo "[ERROR]"
fi

start

}

function migrate_charset_code() {

echo -n "Migrating database $db ..."
TABLES=$($mysql_cmd_short -e "show tables from $db;")
for tb in $TABLES;
do
  $mysql_cmd -e "ALTER TABLE $db.$tb CONVERT TO CHARACTER SET $to_character_set collate $to_collation;"
done
if [[ $? == "0" ]] ; then
    echo "[OK]"
else
    echo "[ERROR]"
fi

start

}

function migrate_engine_onedb() {

echo "Please enter the name of database you want to migrate:"
read db

echo "Enter the engine you want. [InnoDB/MyISAM]"
read to_engine

if [[ "$($mysql_cmd_short -e "use $db;show tables" |grep xwikidoc)" == "" ]] ; then
    echo "Database $db is not a valid XWiki Database"
    exit 1
fi

migrate_engine_code

}

function migrate_engine_alldbs() {

echo "Enter the engine you want. [InnoDB/MyISAM]"
read to_engine

DATABASES="$($mysql_cmd_short -e "show databases")"
for db in $DATABASES
do
    if [[ "$($mysql_cmd_short -e "use $db;show tables" |grep xwikidoc)" == "" ]] ; then
        echo "Database $db is not a valid XWiki Database"
    else

        migrate_engine_code        

    fi
done

}

function migrate_engine() {

continue=0
while [ $continue == 0 ]; do
    echo "What database(s) do you want to migrate?"
    echo "1 - One database only."
    echo "2 - All XWiki databases."
    echo "3 - Go back."
    read choice
    case $choice in
        1) migrate_engine_onedb;;
        2) migrate_engine_alldbs;;
        3) start;;
        *) echo "Wrong choice. Enter 1, 2 or 3."
    esac
done

}

function migrate_charset_onedb() {
echo "Please enter the name of database you want to migrate:"
read db
echo "Enter the character set you want. [utf8/latin1]"
read to_character_set
echo "Enter the collation set you want [utf8_bin, utf8_general_ci / latin1_bin, latin1_general_ci]"
read to_collation

if [[ "$($mysql_cmd_short -e "use $db;show tables" |grep xwikidoc)" == "" ]] ; then
    echo "Database $db is not a valid XWiki Database"
    exit 1
fi

migrate_charset_code
}

function migrate_charset_alldbs() {

echo "Enter the character set you want. [utf8/latin1]"
read to_character_set
echo "Enter the collation set you want [utf8_bin, utf8_general_ci / latin1_bin, latin1_general_ci]"
read to_collation

DATABASES="$($mysql_cmd_short -e "show databases")"
for db in $DATABASES
do
    if [[ "$($mysql_cmd_short -e "use $db;show tables" |grep xwikidoc)" == "" ]] ; then
        echo "Database $db is not a valid XWiki Database"
    else

        migrate_charset_code        

    fi
done
}

function migrate_charset() {

continue=0
while [ $continue == 0 ]; do
    echo "What database(s) do you want to migrate?"
    echo "1 - One database only."
    echo "2 - All XWiki databases."
    echo "3 - Go back."
    read choice
    case $choice in
        1) migrate_charset_onedb;;
        2) migrate_charset_alldbs;;
        3) start;;
        *) echo "Wrong choice. Enter 1, 2 or 3."
    esac
done

}

function start() {
continue=0
while [ $continue == 0 ]; do
    echo "Hello there. What do you want to do? Enter according digit."
    echo "1 - Migrate tables' engine (MyISAM or InnoDB)"
    echo "2 - Migrate tables' character set and collation (utf8 or latin1)"
    echo "3 - Exit"
    read choice
    case $choice in
        1) migrate_engine;;
        2) migrate_charset;;
        3) echo "Goodbye!" ; exit 0;;
        *) echo "Wrong choice. Enter 1, 2 or 3."
    esac
done
}

# Entry point
mysql_cmd_short="$mysql_cmd -N -r -s"
start


