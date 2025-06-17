environment               = "prod"
ecr_image_tag_mutability  = "IMMUTABLE"
ecr_enable_image_scanning = true
bucket_name               = "asseto-prod"

ecr_repository_names = [
  "prod-activity-log-service",
  "prod-asset-management-service",
  "prod-asset-search-service",
  "prod-audit-log-search-service",
  "prod-bca-management-service",
  "prod-case-management-service",
  "prod-case-registration-webform",
  "prod-case-search-service",
  "prod-common-service",
  "prod-configuration-service",
  "prod-eptw-management-service",
  "prod-firebase-service",
  "prod-inventory-search-service",
  "prod-iot-device-service",
  "prod-job-scheduler",
  "prod-mail-service",
  "prod-notification-management",
  "prod-payment-service",
  "prod-product-page",
  "prod-shift-search-service",
  "prod-shift-service",
  "prod-user-configuration-service",
  "prod-user-search-service",
  "prod-user-service",
  "prod-webapp",
  "prod-workflow-orchestrator",
  "prod-workflow-service",
  "prod-workorder-search-service",
  "prod-workorder-service",
  "prod-inventory-service",
  "keycloak"
]
