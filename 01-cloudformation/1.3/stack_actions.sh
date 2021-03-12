#!/usr/bin/env bash

# Usage: ./stack_actions.sh [create|delete] stack_name (optional)

STACK_ACTION="$1"
STACK_NAME=${2:-"raja-kavuru-labs-01-3"}

[[ -z $STACK_ACTION ]] && echo "Please specify stack action: create or delete" && exit

declare -a regions
regions=($(cat regions.json | jq -r '.regions[]'))

for region in "${regions[@]}"; do
    echo "Invoking $STACK_ACTION for $STACK_NAME in $region"
    if [[ $STACK_ACTION == "create" ]]; then
        aws cloudformation create-stack --stack-name ${STACK_NAME} --template-body file://bucket-cft.yml --region ${region} --parameters file://parameters.json &
    elif [[ $STACK_ACTION == "delete" ]]; then
        aws cloudformation delete-stack --stack-name ${STACK_NAME} --region ${region} &
    fi
done
