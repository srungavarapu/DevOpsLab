#!/bin/bash

if [ -z "$1" ]; then
  echo -e "\e[31mInput Machine Name is needed\e[0m"
  exit 1
fi

COMPONENT=$1
#ZONE_ID="Z10463313EB4T9QXP0E6T"

create_ec2() {
  PRIVATE_IP=$(aws ec2 run-instances \
      --image-id ${AMI_ID} \
      --instance-type t2.micro \
      --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=${COMPONENT}}]" \
      --instance-market-options "MarketType=spot,SpotOptions={SpotInstanceType=persistent,InstanceInterruptionBehavior=stop}"\
      --security-group-ids ${SGID} \
      | jq '.Instances[].PrivateIpAddress' | sed -e 's/"//g')

  #sed -e "s/IPADDRESS/${PRIVATE_IP}/" -e "s/COMPONENT/${COMPONENT}/" route53.json >/tmp/record.json
  #aws route53 change-resource-record-sets --hosted-zone-id ${ZONE_ID} --change-batch file:///tmp/record.json | jq
}

AMI_ID=$(aws ec2 describe-images --filters "Name=name,Values=Centos-7-DevOps-Practice" | jq '.Images[].ImageId' | sed -e 's/"//g')
SGID=$(aws ec2 describe-security-groups --filters Name=group-name,Values=DevOps-LAB | jq  '.SecurityGroups[].GroupId' | sed -e 's/"//g')

if [ "$1" == "all" ]; then
  for component in catalogue cart user shipping payment frontend mongodb mysql rabbitmq redis ; do
    COMPONENT=$component
    create_ec2
  done
else
  create_ec2
fi

# Deploy EC2 from the AWS CLI
# aws ec2 run-instances --image-id ami-0bb6af715826253bf --security-group-ids sg-008147de9733254d3 --instance-type t2.small
# Running AWS Command Line Interface using Jenkins build job
# /usr/local/bin/aws ec2 run-instances --image-id ami-0bb6af715826253bf --security-group-ids sg-008147de9733254d3 --instance-type t2.small