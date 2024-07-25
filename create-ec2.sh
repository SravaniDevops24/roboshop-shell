#!/bin/bash

instances=("mongodb" "redis" "mysql" "rabbitmq" "catalogue" "user" "cart" "shipping" "payment" "web")

for name in ($instances[@]) ; do
echo "creating ec2 instance for: $name" 
done