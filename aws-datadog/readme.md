 Using Terraform provisioner and providers - AWS and Datadog.
  The provisioning is seggreated in to two modules:
  * Infrastruture
  * Monitoring

  ##### Infrastructure
  * Creates a custom VPC with 10.0.0.0/26 CIDR.
  * Creates and attaches an internet gateway to the VPC. 
  * Creates an internet facing subnet with 10.0.0.0/28 CIDR inside the VPC.
  * Creates security group for the VPC and the ELB.
  * Creates a launch configuration and auto-scaling group with 2 nodes for HA in the subnet.
  * Uses a userdata script to install and set up Apache HTTPD and create a sample index.html file.
  * Creates an ELB in the subnet, with health checks to ensure load is balanced between healthy instances in the auto-scaling group.
  * Outputs the ELB DNS name.

  ##### Monitoring
  Monitoring is achieved by way of creating an integration between AWS and Datadog, so there isn't a need to store Datadog api keys in the EC2 instances. Listed below are the steps this module accomplishes:
  * Creates an AWS-Datadog integration.
  * Creates AWS policy that grants read-only access to Cloudwatch and ELB metrics
  * Creates an AWS role that attaches the above policy and grants those permissions to the Datadog AWS account ID, 464622532012.

  ##### Files Included:

  | Name | Purpose |
  | ------ | ------ |
  | infra.tf | Provisions AWS application resources |
  | userdata.sh | Bootstraps the AWS computes |
  | vars.tf | Variables for both the AWS and Datadog components |
  | monitor.tf | Provisions Datadog and AWS monitoring components |
  | dd-int-api.sh | Script to create AWS-Datadog integration using Datadog APIs |
  | dd-int-api-del.sh | Script to delete AWS-Datadog integration using Datadog APIs |

  #### Usage

  ##### Create
  Please make sure to update the "changeme"'s in vars.tf before running the module.
  ```sh
  $ terraform init
  $ terraform plan
  $ terraform apply
  ```
  ##### NOTE: 
  For reasons unbeknownst to me, there seems to be a one-time (as long as the integration is not uninstalled) need to manually click the "Update Configuration" button in the configuration tab of https://app.datadoghq.com/account/settings#integrations/amazon_web_services after the above provisioning steps complete, in the AWS-Integration dialog box in the Datadog Integration screen. Post which metrics should flow in to Datadog in few minutes.

  ##### Destroy
  A destroy deletes the AWS-Datadog account from the integration and not the integration itself.
  ```sh
  $ terraform destroy
  ```
