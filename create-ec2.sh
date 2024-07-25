#!/bin/bash

instances=("mongodb" "redis" "mysql" "rabbitmq" "catalogue" "user" "cart" "shipping" "payment" "web")
domain_name="daws24.online"
hosted_zone_id="" #copy from route 53 record AWS

for name in ${instances[@]}; do
  if [ $name == "shipping" ] || [ $name == "mysql" ]
  then
      instance_type="t3.medium"
  else
      instance_type="t3.micro"
  fi 

echo "creating ec2 instance for: $name with instance type is:  $instance_type"
instance_id=$(aws ec2 run-instances --image-id   --instance-type $instance_type --subnet-id  --security-group-ids  --query 'Instances[0].InstanceId' --output text)

echo "Instance created for: $name"
aws ec2 create-tags --resources $instance_id --tags Key=Name,Value=$name

if [$name == "web"]
then 
   aws ec2 wait instance-running --instance-ids $instance_id 

    public_ip=$(aws ec2 describe-instances --instance-ids $instance_id --query 'Reservations[0].Instances[0].PublicIPAddress' 
    --output text)
    ip_to_use=$public_ip
else
    private_ip=$(aws ec2 describe-instances --instance-ids $instance_id --query 'Reservations[0].Instances[0].PrivateIPAddress' 
    --output text)
    ip_to_use=$private_ip
fi

echo "creating route 53 record for $name"

aws route53 change-resource-record-sets --hosted-zone-id $hosted_zone_id --change-batch '
  {
    "Comment": "Creating a record set for '$name'"
    ,"Changes": [{
      "Action"              : "UPSERT"
      ,"ResourceRecordSet"  : {
        "Name"              : "'$name.$domain_name'"
        ,"Type"             : "A"
        ,"TTL"              : 1
        ,"ResourceRecords"  : [{
            "Value"         : "'$ip_to_use'"
        }]
      }
    }]
  }'
done