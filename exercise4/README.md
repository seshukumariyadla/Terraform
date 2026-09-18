# Exercise 4: Multi-Environment Terraform 

This exercise deploys the same infrastructure to multiple environments using Terraform modules and environment-specific variable files.

Each deployment creates:

- Two EC2 instances: `web01` and `web02`
- One S3 bucket
- Environment-specific resource names and tags
- Remote Terraform state stored in an S3 backend

## Directory structure

```text
exercise4/
├── backend.tf
├── provider.tf
├── variables.tf
├── main.tf
├── outputs.tf
├── dev.tfvars
├── qa.tfvars
├── prod.tfvars
└── modules/
    ├── ec2/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    └── s3/
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

## How it works

The root module calls the EC2 module twice:

```text
EC2 module ──> web01
           └──> web02

S3 module  ──> environment-specific bucket
```

The selected `.tfvars` file provides the environment name and infrastructure settings. The modules append that environment to resource names:

```hcl
# modules/ec2/main.tf
Name = "${var.instance_name}-${var.environment}"

# modules/s3/main.tf
bucket = "${var.bucket_name}-${var.environment}"
```

For example, when `environment = "dev"`, the EC2 module combines `web01` with `dev` to create `web01-dev`, while the S3 module combines the bucket base name with `dev`.

| Environment | EC2 names | S3 bucket name |
| --- | --- | --- |
| `dev` | `web01-dev`, `web02-dev` | `<bucket_name>-dev` |
| `qa` | `web01-qa`, `web02-qa` | `<bucket_name>-qa` |
| `prod` | `web01-prod`, `web02-prod` | `<bucket_name>-prod` |

All resources receive an `Environment` tag with the chosen value.

## Remote state

`backend.tf` configures Terraform to store state in this S3 bucket:

```hcl
bucket = "terraaform-iac-july26"
key    = "terraform.tfstate"
region = "us-east-1"
```

Create this bucket before running `terraform init`. The backend bucket is separate from the S3 bucket created by the `s3` module.

> The current backend uses one state key for every environment. Run one environment at a time, or configure a separate backend key/workspace per environment to keep their states isolated.

## Deploy an environment

Run the commands from the `exercise4` directory.

```bash
terraform init
terraform fmt -recursive
terraform validate
```

Preview and apply the development environment:

```bash
terraform plan -var-file="dev.tfvars"
terraform apply -var-file="dev.tfvars"
```

Use `qa.tfvars` or `prod.tfvars` to deploy the other environments:

```bash
terraform apply -var-file="qa.tfvars"
terraform apply -var-file="prod.tfvars"
```

## Inputs

| Variable | Description |
| --- | --- |
| `aws_region` | AWS region used by the provider |
| `environment` | Deployment environment: `dev`, `qa`, or `prod` |
| `ami_id` | AMI ID for both EC2 instances |
| `instance_type` | EC2 instance size |
| `key_name` | Existing EC2 key pair name |
| `ec2_sg` | Security group ID assigned to both instances |
| `bucket_name` | Base name for the application S3 bucket |

Update the variable files with values available in your AWS account before applying.

## Outputs

Terraform prints:

- Instance ID, public IP, and private IP for `web01`
- Instance ID, public IP, and private IP for `web02`
- ID and ARN for the S3 bucket

View the deployed values at any time with:

```bash
terraform output
```

## Destroy resources

Destroy the resources for the environment currently stored in the active Terraform state:

```bash
terraform destroy -var-file="dev.tfvars"
```

Use the same `.tfvars` file that was used for the deployment.
