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
	ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i $api_public_jump_key_pem ubuntu@$api_public_jump_public_ip "$1"
}

# sourcefile,destfile
copy_public_jump() {
    scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i $api_public_jump_key_pem  $1 ubuntu@$api_public_jump_public_ip:$2
}

cmd_private_jump() {
    ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ProxyCommand="ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i $api_public_jump_key_pem ubuntu@$api_public_jump_public_ip nc $api_private_jump_private_ip 22"  -i $api_private_jump_key_pem ubuntu@$api_private_jump_private_ip "$1"
}

# sourcefile,destfile
copy_private_jump() {	
	scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ProxyCommand="ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i $api_public_jump_key_pem ubuntu@$api_public_jump_public_ip nc $api_private_jump_private_ip 22"  -i $api_private_jump_key_pem  "$1" ubuntu@$api_private_jump_private_ip:$2   
    #scp -o ProxyCommand="ssh $jump_host nc $host 22" $local_path $host:$destination_path
}

cmd_rds_mysql_root() {
    cmd_private_jump "mysql -u cyglass -ppassword -h $api_rds_cluster_address -P $api_rds_cluster_port -e \"$1\" "	
}

cmd_rds_mysql_cyglassUser() {
    cmd_private_jump "mysql -u cyglassUser -pcyglassPassword -h $api_rds_cluster_address -P $api_rds_cluster_port -e \"$1\" "	
}


#cmd_private_jump "rm geek.txt"
#cmd_private_jump "ls -lrth; ifconfig -a"