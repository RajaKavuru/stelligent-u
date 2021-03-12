#!/usr/bin/env python3
from typing import Dict
import boto3
from botocore.exceptions import ClientError
import json
import argparse

session = boto3.Session()


def create_stack(stack, region):
    cfn = session.client("cloudformation", region_name=region)
    response = cfn.create_stack(
        StackName=stack,
        ResourceTypes=["AWS::*"],
        TemplateURL="https://raja.kavuru.labs.cft.s3.amazonaws.com/bucket-cft.json",
    )
    if response:
        print("Stack {} created in {}.".format(stack, region))


def delete_stack(stack, region):
    cfn = session.client("cloudformation", region_name=region)
    response = cfn.delete_stack(
        StackName=stack
    )
    if response:
        print("Stack {} deleted in {}.".format(stack, region))


def run_action(action, stack, region):
    if "create" in action:
        create_stack(stack, region)
    elif "delete" in action:
        delete_stack(stack, region)


parser = argparse.ArgumentParser()
parser.add_argument(
    "-a", "--action", help="Action to perform: create or delete", required=True
)
parser.add_argument(
    "-s", "--stack", help="CFN stack name", default="raja-kavuru-labs-01-3"
)

parser.add_argument(
    "-l", "--location", help="Path to regions JSON file", default="regions.json"
)

args = parser.parse_args()

with open(args.location) as f:
    regions = json.load(f)

if "regions" in regions.keys():
    for region in regions["regions"]:
        run_action(args.action, args.stack, region)
else:
    raise KeyError("Regions not found")