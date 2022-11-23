#!/bin/bash
docker build -t mysqld_exporter:latest .
docker tag mysqld_exporter:latest swr.cn-south-1.myhuaweicloud.com/starsl.cn/mysqld_exporter:latest
docker push swr.cn-south-1.myhuaweicloud.com/starsl.cn/mysqld_exporter:latest
