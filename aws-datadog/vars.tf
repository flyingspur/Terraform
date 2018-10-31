variable "AWS_ACCESS_KEY_ID" {
  description = "AWS Access Key ID"
	default = "changeme"
}

variable "AWS_SECRET_ACCESS_KEY" {
  description = "AWS Secret Access Key"
	default = "changeme"
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
	default = "changeme"
}

variable "datadog_api_key" {
  description = "Datadog api key"
	default = "changeme"
}

variable "datadog_app_key" {
  description = "Datadog app key"
	default = "changeme"
}

variable "aws_dd_integration_role_name" {
  default = "DatadogAWSIntegrationRole"
}

variable "aws_dd_integration_policy" {
  default = "DatadogAWSIntegrationPolicy"
}
