#!/bin/bash

# Exit if any of the intermediate steps fail
set -e

eval "$(jq -r '@sh "IAM_ROLE=\(.iam_role) SESSION=\(.session) PROFILE=\(.profile)"')"

aws sts assume-role --role-arn "$IAM_ROLE"  --role-session-name "$SESSION" --duration-seconds 18000 --profile "$PROFILE" | jq '.Credentials'