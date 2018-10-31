variable "AWS_ACCESS_KEY_ID" {
  description = "AWS Access Key ID"
}

variable "AWS_SECRET_ACCESS_KEY" {
  description = "AWS Secret Access Key"
}

variable "AWS_REGION" {
  default = "us-east-1"
}

variable "AMI" {
  type = "map"
  default = {
    us-east-1 = "ami-0922553b7b0369273"
  }
}

variable "AWS_KEY_PAIR" {
  description = "AWS Existing Key Pair"
}

variable "datadog_api_key" {
  description = "Datadog api key"
}

variable "datadog_app_key" {
  description = "Datadog app key"
}

variable "aws_dd_integration_role_name" {
  default = "DatadogAWSIntegrationRole"
}

variable "aws_dd_integration_policy" {
  default = "DatadogAWSIntegrationPolicy"
}
