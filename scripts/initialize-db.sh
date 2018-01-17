#!/bin/bash
. functions.sh


log "extracting sql from build artifact"
jar xf $api_build_jar BOOT-INF/classes/sql/cyglass-dev.sql
jar xf $api_build_jar BOOT-INF/classes/sql/CyGlassApiSampleData.sql

log "installing mysql-client on jump"
cmd_public_jump "sudo apt-get --assume-yes install mysql-client"

sql="GRANT ALL PRIVILEGES ON $api_environment_name.* TO 'cyglassUser'@'%' IDENTIFIED BY 'cyglassPassword';"
log "creating api database and user: $sql" 
cmd_rds_mysql_root "$sql"

log "copy up create sql scripts"
copy_public_jump BOOT-INF/classes/sql/cyglass-dev.sql .

sql="mysql -u cyglass -ppassword -h $api_rds_cluster_address -P $api_rds_cluster_port $api_environment_name < cyglass-dev.sql "
log "run create sql script: $sql"
cmd_public_jump "$sql"

sql="use $api_environment_name; show tables;"
log "print tables in database: $sql"
cmd_rds_mysql_cyglassUser "$sql"

