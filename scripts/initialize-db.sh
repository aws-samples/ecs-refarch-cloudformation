#!/bin/bash
. functions.sh

cmd_private_jump "sudo apt-get --assume-yes install mysql-client"

cmd_rds_mysql_root "show databases;"
#cmd_rds_mysql_root "create database cyglass; GRANT ALL PRIVILEGES ON cyglass.* to 'cyglassUser'@'%' identified by 'cyglassPassword';"

# copy up create sql script
#cmd_private_jump "mysql -u cyglass -pcyglass -h $api_rds_cluster_address -P $api_rds_cluster_port cyglass < cyglass-dev.sql "
#cmd_private_jump "mysql -u cyglassUser -pcyglassPassword -h $api_rds_cluster_address -P $api_rds_cluster_port cyglass < CyGlassApiSampleData.sql "


