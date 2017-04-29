provider "aws" {
  region  = "${var.aws_region}"
  profile = "${var.aws_profile}"
}

resource "aws_s3_bucket" "sitebucket" {
  bucket = "${var.site_bucket_name}"
  acl    = "public-read"

  website {
    index_document = "index.html"
    error_document = "error.html"
  }

  logging {
    target_bucket = "${aws_s3_bucket.sitebucket-log.id}"
    target_prefix = "log/"
    
  }

  policy = <<EOF
{
  "Version":"2012-10-17",
  "Statement": [{
    "Sid": "Allow Public Access to All Objects",
    "Effect": "Allow",
    "Principal": "*",
    "Action": "s3:GetObject",
    "Resource": "arn:aws:s3:::${var.site_bucket_name}/*"
  }
 ]
}
EOF
}

resource "aws_s3_bucket" "sitebucket-log" {
  bucket = "logs.${var.site_bucket_name}"
  acl    = "log-delivery-write"

  lifecycle_rule {
    id = "log"
    prefix = "log/"
    enabled = true

    expiration {
      days = 30
    }
  }
}

resource "aws_s3_bucket" "sitebucket-www" {
  bucket = "www.${var.site_bucket_name}"
  acl    = "public-read"
  
  website {
    redirect_all_requests_to = "${var.site_bucket_name}"
  }
}

data "aws_route53_zone" "zone" {
  name = "${var.domain_name}"
}

resource "aws_route53_record" "siteroot" {
  zone_id = "${data.aws_route53_zone.zone.zone_id}"
  name    = "${var.domain_name}"
  type    = "A"

  alias {
    name                   = "${aws_s3_bucket.sitebucket.website_domain}"
    zone_id                = "${aws_s3_bucket.sitebucket.hosted_zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "sitewww" {
  zone_id = "${data.aws_route53_zone.zone.zone_id}"
  name    = "www.${var.domain_name}"
  type    = "A"

  alias {
    name                   = "${aws_s3_bucket.sitebucket.website_domain}"
    zone_id                = "${aws_s3_bucket.sitebucket.hosted_zone_id}"
    evaluate_target_health = false
  }
}
