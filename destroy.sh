#!/bin/bash
echo "Starting to destroy AWS environment by terraform"
cd ./project
terraform destroy -auto-approve

echo "Starting to destroy S3 bucket by terraform"
cd ../prerequisites
terraform destroy -auto-approve

echo "Starting to delete ami images and snapshots"

IMAGE_ID=$(aws ec2 describe-images --region ${AWS_DEFAULT_REGION} --owners "self" --filters Name=name,Values="moodle-server*" --query 'Images[*].ImageId' --output text)
IMAGE_VPL_ID=$(aws ec2 describe-images --region ${AWS_DEFAULT_REGION} --owners "self" --filters Name=name,Values="vpl-server*" --query 'Images[*].ImageId' --output text)
SNAPSHOTS_ID=$(aws ec2 describe-snapshots --filters Name=tag:Name,Values="Packer Builder" --output text | cut -f 6)
ALL="$IMAGE_ID $IMAGE_VPL_ID"
echo $SNAPSHOTS_ID
echo $ALL

for id in $ALL; do
    aws ec2 deregister-image --image-id $id
    echo "Successfully deregistered ami imsge $id"
done
## To Fetch all the SNAPSHOT_ID with Tag Name=Packer Builder

for i in $SNAPSHOTS_ID; do
    aws ec2 delete-snapshot --snapshot-id "$i"
    echo "Successfully deleted snapshot $i"
done
