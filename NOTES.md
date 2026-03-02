# Terraform Learning Notes

## Where to Continue
Steps completed: credentials → first config → core workflow → variables/outputs → remote state → modules

Next options:
- **Workspaces** — manage dev/staging/prod with the same config
- **Data sources** — read existing AWS resources not created by Terraform
- **Real-world project** — VPC + EC2 instance
- **Terraform Cloud** — managed remote state + CI/CD runs

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

## State Management

```sh
terraform state mv <old_address> <new_address>  # Rename a resource in state without touching real infrastructure
```

Use `state mv` when refactoring — e.g. moving a resource into a module changes its address from
`aws_s3_bucket.my_bucket` to `module.my_bucket.aws_s3_bucket.this`.

## Modules

```hcl
# Calling a local module
module "my_bucket" {
  source             = "./modules/s3_bucket"
  bucket_name        = var.bucket_name
  versioning_enabled = true
}

# Referencing a module output
module.my_bucket.bucket_name
```

- A module is just a folder of Terraform files
- Modules have their own `variables.tf` (inputs) and `outputs.tf` (outputs)
- Run `terraform init` after adding a new module
- Inside a module, name the resource `this` when there's only one resource of that type

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
