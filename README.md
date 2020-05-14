# Proiect SGBD


### Getting Started
```
git clone https://github.com/csum112/Proiect_SGBD.git &&\
cd Proiect_SGBD &&\
docker build . -t csum112/proiect-sgbd-db &&\
docker run -d --rm --name "proiect-sgbd" -p "1521:1521" csum112/proiect-sgbd-db:latest
```
DB credentials
user: STUDENT
password: STUDENT