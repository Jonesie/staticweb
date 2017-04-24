#!/bin/bash

echo Deploy static site to jonesie.kiwi

aws_profile="jonesie-kiwi"
aws_region="us-west-2"
site_bucket_name="site-jonesie-kiwi"

# destroy the aws infrastructure
terraform destroy -var "aws_profile=$aws_profile" -var "aws_region=$aws_region" -var "site_bucket_name=$site_bucket_name" aws
