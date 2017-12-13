# CyGlass API Deployment

This repository contains the resources necessary to create a full deployment of the API system on AWS. This is a fork of https://github.com/awslabs/ecs-refarch-cloudformation.

* RDS and API instances run on isolated private networks at differing depths.
* Currently the deployment is *not* fully automated, several steps still require manual attention. Such as DB user creation.

## Prerequisites

Read all these instructions before beginning deploy. This setup utilizes a combination of coordinate artifacts to deploy the system:

* Cloudformation templates (a master and several nested templates)
  * templates are executed from the root directory of the project
* Bash scripts (requiring the AWS CLI)
  * scripts are executed from the `scripts` directory of the project
* Optionally, some manual adjustments

## Notes

* The region that you specify on the CLI is the region the system will be deployed into. Be wary of what you specify for the `--region` argument to the CLI, **or** what you've set as your default region in your `~/.aws` directory.
* The templates include the creation of two EC2 jump boxes for use during configuration only. 
* The master template (`master.yml`) specifies *all* parameters for the nested templates and the resources it creates. You should inspect these parameters and adjust as needed. For example, the RDS master username and password might need to be changed (and also adjusted in the configuration scripts).
* Credentials for the RDS database may need to be manually synchronized between the CF templates and init scripts. This is a **TODO** improvement item for future work.
* The first versions of the CF templates utilized a private jump box in addition to the public jump box. The private jump was eliminated because the public subnet now has access to the deeper RDS subnets via their routing table. This may change as we add deeper defenses.

## Steps

#### 1. Deploy/update CF templates to S3

Use `aws s3 sync` CLI to copy template sources to an S3 bucket, or take a look at the script `step1-copy-to-s3.sh` that can do this for you.

Example:
```
aws --profile $AWS_PROFILE s3 sync infrastructure s3://staging.api.cyglass.com/cloudformation/infrastructure
```

#### 2. Create CF stack using master template

Use `aws cloudformation create-stack` to invoke the `master.yaml` CF template. You can look at *and adjust* the `step2-run-master.sh` script that can do this for you.

Example:
```
aws --profile jay --region us-west-2 cloudformation create-stack  --stack-name staging --capabilities CAPABILITY_NAMED_IAM --template-body file://master.yaml
```
#### 3. Monitor and Verify

On the [Cloudformation page on the AWS console](https://us-west-2.console.aws.amazon.com/cloudformation/home?region=us-west-2#/stacks?filter=active) (be sure to go to the appropriate region) watch and monitor the deployment for success. The deploy usually takes 20-30 minutes to complete.

Any failures will require manual resolution. 
 
#### 4. Configure the Deploy
 
##### 4.1. Prepare local scripting environment
From the scripts directory, run the ```configure.sh``` script. This will create a file called ```environment``` that the next set of scripts will use to configure the API deployment.

Example run:
`configure.sh -p jay -r us-west-2 -e staging -k $HOME/.ssh/aws`
 
Usage looks like this:
```
usage: ./configure.sh options

This script will generate an environment file for use in configuring a deploy of the API system.

OPTIONS:
   -h      Show this message
   -p      (Required) AWS profile
   -r      (Required) AWS region (e.g. us-west-2)
   -e      (Required) Environment name (e.g. staging)
   -k      (Required) Directory containing the SSH keys for the deployment

```
 
##### 4.2. Initialize RDS Database

Run the `initialize-db.sh` script.

##### 4.3. Deploy API Docker
 
#### 5. Verify and Cleanup

Shutdown the jump instance

 
 


<hr/>



## Diagram

![infrastructure-overview](images/architecture-overview.png)

The repository consists of a set of nested templates that deploy the following:

 - A tiered [VPC](http://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/VPC_Introduction.html) with public and private subnets, spanning an AWS region.
 - A highly available ECS cluster deployed across two [Availability Zones](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html) in an [Auto Scaling](https://aws.amazon.com/autoscaling/) group.
 - A pair of [NAT gateways](http://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/vpc-nat-gateway.html) (one in each zone) to handle outbound traffic.
 - Two interconnecting microservices deployed as [ECS services](http://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs_services.html) (website-service and product-service). 
 - An [Application Load Balancer (ALB)](https://aws.amazon.com/elasticloadbalancing/applicationloadbalancer/) to the public subnets to handle inbound traffic.
 - ALB path-based routes for each ECS service to route the inbound traffic to the correct service.
 - Centralized container logging with [Amazon CloudWatch Logs](http://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/WhatIsCloudWatchLogs.html).



## Template details

The templates below are included in this repository and reference architecture:

| Template | Description |
| --- | --- | 
| [master.yaml](master.yaml) | This is the master template - deploy it to CloudFormation and it includes all of the others automatically. |
| [infrastructure/vpc.yaml](infrastructure/vpc.yaml) | This template deploys a VPC with a pair of public and private subnets spread across two Availability Zones. It deploys an [Internet gateway](http://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/VPC_Internet_Gateway.html), with a default route on the public subnets. It deploys a pair of NAT gateways (one in each zone), and default routes for them in the private subnets. |
| [infrastructure/security-groups.yaml](infrastructure/security-groups.yaml) | This template contains the [security groups](http://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/VPC_SecurityGroups.html) required by the entire stack. They are created in a separate nested template, so that they can be referenced by all of the other nested templates. |
| [infrastructure/load-balancers.yaml](infrastructure/load-balancers.yaml) | This template deploys an ALB to the public subnets, which exposes the various ECS services. It is created in in a separate nested template, so that it can be referenced by all of the other nested templates and so that the various ECS services can register with it. |
| [infrastructure/ecs-cluster.yaml](infrastructure/ecs-cluster.yaml) | This template deploys an ECS cluster to the private subnets using an Auto Scaling group. |
| [services/product-service/service.yaml](services/product-service/service.yaml) | This is an example of a long-running ECS service that serves a JSON API of products. For the full source for the service, see [services/product-service/src](services/product-service/src).|
| [services/website-service/service.yaml](services/website-service/service.yaml) | This is an example of a long-running ECS service that needs to connect to another service (product-service) via the load-balanced URL. We use an environment variable to pass the product-service URL to the containers. For the full source for this service, see [services/website-service/src](services/website-service/src). |



## License

Copyright 2011-2016 Amazon.com, Inc. or its affiliates. All Rights Reserved.

Licensed under the Apache License, Version 2.0 (the "License"). You may not use this file except in compliance with the License. A copy of the License is located at

[http://aws.amazon.com/apache2.0/](http://aws.amazon.com/apache2.0/)

or in the "license" file accompanying this file. This file is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

