# Output the ELB DNS name
output "elb_dns_name" {
  value = "${aws_elb.cloudappelb.dns_name}"
}
