#!/bin/bash
echo "CREATE USER STUDENT IDENTIFIED BY STUDENT;" | sqlplus -s SYSTEM/oracle &&\
echo "GRANT ALL PRIVILEGES TO STUDENT;" | sqlplus -s SYSTEM/oracle &&\
cat /scripts.sql | sqlplus -s STUDENT/STUDENT &&\
rm /scripts.sql

