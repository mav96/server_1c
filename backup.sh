#!/bin/sh

mkdir -p /backup
chmod 777 /backup
cd /backup

TODAY=$(date +"%a")
OLD=$(date +"%a" --date="5 days ago")

for i in `su -c "psql -t  -c 'select datname from pg_database' | grep -v postgres | grep -v template | grep -v -e '^$' | sed 's/ //g'" postgres`; 
do 
  su -c "pg_dump -U postgres -Fc -Z9 ${i}  -f ./${i}-${TODAY}.dump" postgres
done

for i in `drive list | grep "$TODAY.dump" | awk '{print $1}'`;
do
  drive delete -i  $i
done

for i in `ls | grep "$TODAY.dump"`;
do
  drive upload -f $i
done

for i in `drive list | grep "$OLD.dump" | awk '{print $1}'`;
do
  drive delete -i  $i
done

drive list > /var/log/backup.log

