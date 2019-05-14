## Estimated Minimum Base Cost of this architecture with various scenarios 

Note: 
- Data Transfer costs are not included. 
- Cloudwatch logs storage cost and API calls cost are not included


### Resources Monthly Cost
2 Nat Gateway- $0.045*24*30*2 = $64.8\
1 ALB with 1 LCU = [Example Pricing for ALB](https://aws.amazon.com/elasticloadbalancing/pricing/) $0.03114 per hour ($0.0225 hourly charge + $0.00864 LCU charge); or
$22.42 per month ($0.03114 * 24 hours * 30 days).\
4 EC2 Instances at On-demand pricing  ( default: c4.large) = 4*0.10*24*30 = $288 


### Total 
64.8+22.42+288 = $375.22

### Total with 1 year reserved Instances ( no upfront)
64.8+22.42+183.96 = $271.18




## If no of instances changed to 2 
Total = 64.8+22.42+144 = $231.22


## If no of instances changed to 2 and using 1 year Reserved Instances
Total = 64.8+22.42+92 = $179.22
