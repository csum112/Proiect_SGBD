#!/bin/bash

cat /init_scripts/create_account.sql | sqlplus -s SYSTEM/oracle &&\
cat /init_scripts/create_populate_tables.sql | sqlplus -s STUDENT/STUDENT &&\
cat /init_scripts/gen_tests.sql | sqlplus -s STUDENT/STUDENT &&\
cat /init_scripts/calculator.sql | sqlplus -s STUDENT/STUDENT &&\
rm -r /init_scripts;

