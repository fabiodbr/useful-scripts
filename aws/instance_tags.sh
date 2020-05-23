#!/usr/bin/env bash
#################################
# Program Name: ec2_get_tags.sh
#
# Description: Get instance tags and outputs to stdout in a NAME=VALUE format.
#              Useful in a systemd EnvironmentFile for service configuration.
#
# Requirements:
#  - Tools: aws-cli, curl, jq
#  - IAM Policy: "Action": "ec2:DescribeTags"
#
# Author: github.com/fabiodbr
# License: GPLv3
#################################

METADATA="http://169.254.169.254/latest"
REGION=$(curl -s ${METADATA}/dynamic/instance-identity/document | jq -r .region)
INSTANCE_ID=$(curl -s ${METADATA}/meta-data/instance-id)
TAGS=$(aws ec2 describe-tags --filters "Name=resource-id,Values=${INSTANCE_ID}" \
       --region="${REGION}" --query 'Tags[].Key' --output text)
for NAME in $TAGS; do
  VALUE=$(aws ec2 describe-tags \
          --filters "Name=resource-id,Values=${INSTANCE_ID}" "Name=key,Values=${NAME}" \
          --region "${REGION}" \
          --query 'Tags[].[Value]' \
          --output text)
  echo "${NAME^^}"="${VALUE}"
done
