#!/bin/bash
aws --profile jay --region us-west-2 cloudformation create-stack  --stack-name staging --capabilities CAPABILITY_NAMED_IAM --template-body file://master.yaml
