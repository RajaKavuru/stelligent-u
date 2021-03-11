#!/usr/bin/env bash

function set_aws_keys() {

    unset AWS_ACCESS_KEY_ID
    unset AWS_SECRET_ACCESS_KEY
    unset AWS_DEFAULT_REGION

    MFA_TOKEN=$1
    AWS_SERIAL_NUMBER=$( aws sts get-caller-identity | jq -r '.Arn' | sed 's/user\//mfa\//')
    echo "Calling for tokens using user: $AWS_SERIAL_NUMBER"
    _sts_call=$(aws sts get-session-token --serial-number "$AWS_SERIAL_NUMBER" --token-code "$MFA_TOKEN")

    export AWS_ACCESS_KEY_ID=$(jq -r '.Credentials.AccessKeyId' <<<"""$_sts_call""")
    export AWS_SECRET_ACCESS_KEY=$(jq -r '.Credentials.SecretAccessKey' <<<"""$_sts_call""")
    export AWS_SESSION_TOKEN=$(jq -r '.Credentials.SessionToken' <<<"""$_sts_call""")

}

set_aws_keys "$1"
exec "$SHELL" -i
