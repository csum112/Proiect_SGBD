#!/bin/bash

cat /init_scripts/create_account.sql | sqlplus -s SYSTEM/oracle;
cat /init_scripts/create_populate_tables.sql | sqlplus -s STUDENT/STUDENT;
rm -r /init_scripts;