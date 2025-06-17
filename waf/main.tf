# AWS Managed group rule usage
resource "aws_wafv2_web_acl" "proctoring-waf" {
  name        = "Asseto-Dev-WAF"
  description = "AWS WAFv2 Web ACL"
  scope       = "REGIONAL"

  default_action {
    allow {}
  }

  rule {
    name     = "AWS-AWSManagedRulesAmazonIpReputationList"
    priority = 1

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        vendor_name = "AWS"
        name        = "AWSManagedRulesAmazonIpReputationList"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesAmazonIpReputationList"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWS-AWSManagedRulesAnonymousIpList"
    priority = 2

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        vendor_name = "AWS"
        name        = "AWSManagedRulesAnonymousIpList"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesAnonymousIpList"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWS-AWSManagedRulesKnownBadInputsRuleSet"
    priority = 3

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        vendor_name = "AWS"
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesKnownBadInputsRuleSet"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWS-AWSManagedRulesCommonRuleSet"
    priority = 4

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        vendor_name = "AWS"
        name        = "AWSManagedRulesCommonRuleSet"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesCommonRuleSet"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "ProctoringWebACL"
    sampled_requests_enabled   = true
  }
}

# Attach ALB to the Web ACL
resource "aws_wafv2_web_acl_association" "alb_association" {
  resource_arn = lookup(var.alb_arn, terraform.workspace)
  web_acl_arn  = aws_wafv2_web_acl.proctoring-waf.arn
}

# Enable logging for the WAF WebACL
resource "aws_wafv2_web_acl_logging_configuration" "proctoring_logging" {
  resource_arn = aws_wafv2_web_acl.proctoring-waf.arn

  log_destination_configs = [
    aws_cloudwatch_log_group.proctoring_waf_log_group.arn
  ]

  redacted_fields {
    single_header {
      name = "authorization" # parts of the request that you want to hide or mask in the AWS WAF logs
    }
  }
}

# Create a logging group
resource "aws_cloudwatch_log_group" "proctoring_waf_log_group" {
  name              = "aws-waf-logs-proctoring-waf"
  retention_in_days = 14 # Adjust retention as needed
}
