. environment
SCRIPT_LABEL=$0
log() {
 tmpd=`date "+%F %H:%M:%S"`
 tmp="$tmpd [$SCRIPT_LABEL] $1"
 #echo $tmp >> $LOG
 echo $tmp
}

error() {
 log "ERROR $@"
 #log "$@"
 exit 1
}

# shared functions
cmd_public_jump() {
	ssh -q -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i $api_public_jump_key_pem ubuntu@$api_public_jump_public_ip "$1"
}

# sourcefile,destfile
copy_public_jump() {
    scp -q -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i $api_public_jump_key_pem  $1 ubuntu@$api_public_jump_public_ip:$2
}

# run sql as root, no database selected
cmd_rds_mysql_root() {
	log "---> running: mysql -u cyglass -ppassword -h $api_rds_cluster_address -P $api_rds_cluster_port -e \"$@\" "
    cmd_public_jump "mysql -u cyglass -ppassword -h $api_rds_cluster_address -P $api_rds_cluster_port -e \"$@\" "	
}

# run sql as API user, with API database selected
cmd_rds_mysql_cyglassUser() {
    cmd_public_jump "mysql -u cyglassUser -pcyglassPassword -h $api_rds_cluster_address -P $api_rds_cluster_port $api_environment_name -e \"$@\" "	
}

#cmd_rds_mysql_root "show databases;"
#cmd_private_jump "rm geek.txt"
#cmd_private_jump "ls -lrth; ifconfig -a"