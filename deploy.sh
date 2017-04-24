#!/bin/bash

echo Deploy static site to jonesie.kiwi

aws_profile="jonesie-kiwi"
aws_region="us-west-2"
domain_name="jonesie.kiwi"
site_bucket_name="jonesie.kiwi"
site_bucket_url="http://$site_bucket_name.s3-website-$aws_region.amazonaws.com"

# create the aws infrastructure
terraform apply \
    -var "aws_profile=$aws_profile" \
    -var "aws_region=$aws_region" \
    -var "domain_name=jonesie.kiwi" \
    -var "site_bucket_name=$site_bucket_name" \
    aws

# copy the content to the bucket
if [ $? -eq 0 ]
then
    aws s3 cp \
        content/ s3://$site_bucket_name \
        --profile $aws_profile \
        --recursive 
fi

