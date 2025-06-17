output "web_acl_arn" {
  description = "The ARN for Web ACL"
  value       = aws_wafv2_web_acl.proctoring-waf.arn
}
