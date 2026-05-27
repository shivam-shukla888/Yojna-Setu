#!/bin/bash
cd /home/ubuntu
nohup java -Xmx512m -jar yojna-setu-0.0.1-SNAPSHOT.jar --spring.datasource.username=yojna --spring.datasource.password=Ankjus@123 > app.log 2>&1 &
