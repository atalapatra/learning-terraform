# Terraform Learning Notes

## Core Workflow

```sh
terraform init       # Download providers, initialize backend. Run once, or after backend/provider changes.
terraform plan       # Preview what Terraform will create/change/destroy. Never modifies real infrastructure.
terraform apply      # Apply the plan. Prompts for confirmation.
terraform apply -auto-approve  # Apply without confirmation prompt (use when plan shows no infra changes).
terraform destroy    # Destroy all managed infrastructure.
terraform output     # Print output values from state.
```

## Provider & Lock File

```sh
terraform init -upgrade  # Re-resolve provider versions and update .terraform.lock.hcl
```

## AWS CLI (used for bootstrap, not managed by Terraform)

```sh
aws configure --profile <name>          # Set up a named AWS credentials profile
aws sts get-caller-identity --profile <name>  # Verify credentials are working

# Remote state bootstrap (run once manually)
aws s3api create-bucket --bucket <name> --region us-east-1
aws s3api put-bucket-versioning --bucket <name> --versioning-configuration Status=Enabled
aws dynamodb create-table \
  --table-name terraform-state-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST

aws s3 ls s3://<bucket-name>/           # Verify state file exists in S3
```

## File Conventions

| File | Purpose | Git |
|---|---|---|
| `main.tf` | Resources | ✅ |
| `variables.tf` | Variable declarations | ✅ |
| `outputs.tf` | Output declarations | ✅ |
| `terraform.tfvars` | Variable values (may contain secrets) | ❌ |
| `terraform.tfvars.example` | Placeholder values for teammates | ✅ |
| `.terraform.lock.hcl` | Locks provider versions | ✅ |
| `.terraform/` | Downloaded provider plugins | ❌ |
| `terraform.tfstate` | State file (use remote state instead) | ❌ |

## Syntax Reference

```hcl
# Reference a variable
var.variable_name

# Reference another resource's attribute
resource_type.resource_name.attribute

# Resource block structure
resource "<provider>_<type>" "<local_name>" {
  argument = value
}
```
