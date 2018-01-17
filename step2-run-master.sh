#!/bin/bash

usage(){
cat << EOF
usage: $0 <aws_profile> <aws_region> <environment>

This script will copy the cloudformation templates to the S3 locations specified in the master.yaml

ARGUMENTS: 

  <aws_profile>  name of the profile to use for AWS CLI commands
  <aws_region>   region for deployment (e.g. us-east-2)
  <environment>  which environment to deploy, dev, staging, or production

EOF
}

AWS_PROFILE=$1
AWS_REGION=$2
ENVIRON=$3

if [[ $AWS_PROFILE == "" ]]; then
	echo "ERROR: aws_profile is a required argument."
    usage
    exit 1;
fi
if [[ $AWS_REGION == "" ]]; then
	echo "ERROR: aws_region is a required argument."
    usage
    exit 1;
fi
if [[ $ENVIRON == "" ]]; then
	echo "ERROR: environment is a required argument."
    usage
    exit 1;
fi


#!/bin/bash
aws \
--profile $AWS_PROFILE \
--region $AWS_REGION \
cloudformation create-stack  \
--stack-name $ENVIRON \
--capabilities CAPABILITY_NAMED_IAM \
--template-body file://infrastructure/$ENVIRON/master.yaml
