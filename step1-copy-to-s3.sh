#!/bin/bash

usage(){
cat << EOF
usage: $0 <aws_profile>

This script will copy the cloudformation templates to the S3 locations specified in the master.yaml

ARGUMENTS: 

  <aws_profile>  name of the profile to use for AWS CLI commands

    
EOF
}

AWS_PROFILE=$1

if [[ $AWS_PROFILE == "" ]]; then
	echo "ERROR: aws_profile is a required argument."
    usage
    exit 1;
fi

aws --profile $AWS_PROFILE s3 sync infrastructure s3://staging.api.cyglass.com/cloudformation/infrastructure
#aws --profile $AWS_PROFILE s3 sync services s3://staging.api.cyglass.com/cloudformation/services
