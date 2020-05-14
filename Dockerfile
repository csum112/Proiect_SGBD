FROM wnameless/oracle-xe-11g-r2
COPY ./scripts.sql /scripts.sql
COPY ./init_db.sh /docker-entrypoint-initdb.d/