# Data source to fetch account id
data "aws_caller_identity" "current" {}

# Data source for AWS-Datadog integration - create
data "template_file" "dd_int_api" {
	template = "${file("dd-int-api.sh")}"

  vars {
    account_id = "${data.aws_caller_identity.current.account_id}"
		role_name = "${var.aws_dd_integration_role_name}"
		datadog_api_key = "${var.datadog_api_key}"
		datadog_app_key = "${var.datadog_app_key}"
  }
}

# File to store AWS-Datadog integration external id
resource "local_file" "stdout" {
  content  = ""
	filename = "local_file.stdout"
}

resource "null_resource" "ddawsapi" {

  # Create the AWS-Datadog integration
	provisioner "local-exec" {
    command = "${data.template_file.dd_int_api.rendered}"
	}

  # Delete the AWS-Datadog integration when destroy is called
	provisioner "local-exec" {
    when = "destroy"
    command = "${data.template_file.dd_int_api_del.rendered}"
    on_failure = "continue"
	}
}

# Data source once the external id is exported out post integration
data "local_file" "stdout" {
  filename   = "local_file.stdout"
  depends_on = ["null_resource.ddawsapi", "local_file.stdout"]
}

# Get the exported external id
resource "null_resource" "contents" {
  triggers = {
    stdout = "${data.local_file.stdout.content}"
  }

  lifecycle {
    ignore_changes = [
      "triggers",
    ]
  }
}

# Store the external id in a variable after stripping newlines
locals {
	external_id = "${chomp(null_resource.contents.triggers["stdout"])}"
}

# Data source for AWS-Datadog integration - delete
data "template_file" "dd_int_api_del" {
	template = "${file("dd-int-api-del.sh")}"

  vars {
    account_id = "${data.aws_caller_identity.current.account_id}"
		role_name = "${var.aws_dd_integration_role_name}"
		datadog_api_key = "${var.datadog_api_key}"
		datadog_app_key = "${var.datadog_app_key}"
  }
}

# Create the Datadog integration policy
resource "aws_iam_policy" "dd_integration_policy" {
  name        = "${var.aws_dd_integration_policy}"
  path        = "/"
  description = "${var.aws_dd_integration_policy}"

  policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": [
          "autoscaling:Describe*",
          "cloudwatch:Describe*",
          "cloudwatch:Get*",
          "cloudwatch:List*",
          "ec2:Describe*",
          "ec2:Get*",
          "elasticloadbalancing:Describe*",
          "support:*",
          "tag:GetResources",
          "tag:GetTagKeys",
          "tag:GetTagValues"
        ],
        "Effect": "Allow",
        "Resource": "*"
      }
    ]
  }
  EOF
}

# Create the Datadog integration role
resource "aws_iam_role" "dd_integration_role" {
  name = "${var.aws_dd_integration_role_name}"

  assume_role_policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": {
      "Effect": "Allow",
      "Principal": { "AWS": "arn:aws:iam::464622532012:root" },
      "Action": "sts:AssumeRole",
      "Condition": { 
        "StringEquals": { "sts:ExternalId": "${local.external_id}" },
        "Bool": {"aws:MultiFactorAuthPresent": "false"}
      }
    }
  }
  EOF
}

# Attach the Datadog integration policy to the role
resource "aws_iam_policy_attachment" "allow_dd_role" {
  name       = "Allow Datadog PolicyAccess via Role"
  roles      = ["${var.aws_dd_integration_role_name}"]
  policy_arn = "${aws_iam_policy.dd_integration_policy.arn}"
}
