#!/bin/bash

AMI=ami-09c813fb71547fc4f
SG_ID=sg-0c6cdeaf019975023

INSTANCES=("mongodb" "redis" "rabbitmq" "mysql" "catalogue" "user" "cart" "shipping" "payment" "dispatch" "web")

for i in "${INSTANCES[@]}"
do
    if [ $i == 'mongodb'] || [ $i == 'mysql'] || [ $i == 'shipping'] 
    then
        INSTANCE_TYPE="t3.small"
    else
        INSTANCE_TYPE="t2.micro"
    fi

    aws ec2 run-instances   --image-id $AMI   --count 1   --instance-type $INSTANCE_TYPE   --security-group-ids $SG_ID --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$i}]"

done