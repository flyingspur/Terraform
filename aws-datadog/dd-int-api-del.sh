#!/bin/bash

# Delete the Datadog/AWS integration
curl -s -X DELETE -H "Content-type: application/json" \
-d '{
      "account_id": "${account_id}",
      "role_name": "${role_name}"
   }' \
"https://app.datadoghq.com/api/v1/integration/aws?api_key=${datadog_api_key}&application_key=${datadog_app_key}"
