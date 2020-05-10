FROM wnameless/oracle-xe-11g-r2
COPY ./init_scripts /init_scripts
COPY ./init_db.sh /docker-entrypoint-initdb.d/