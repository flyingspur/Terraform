#!/bin/bash

# Create the Datadog/AWS integration and store the result.
external_id=$(curl -s -X POST -H "Content-type: application/json" \
-d '{
      "account_id": "${account_id}",
      "filter_tags": ["Name:cloudapp"],
      "host_tags": ["account:new-team"],
      "role_name": "${role_name}",
      "account_specific_namespace_rules": {
        "cloudwatch_events": true,
        "ec2": true,
        "elb": true,
        "application_elb": true,
        "auto_scaling": true
      }
   }' \
"https://app.datadoghq.com/api/v1/integration/aws?api_key=${datadog_api_key}&application_key=${datadog_app_key}")

echo "$external_id" | awk -F\" '{print $4}' > local_file.stdout
