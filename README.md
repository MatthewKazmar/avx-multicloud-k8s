# avx-multicloud-k8s

This repo demonstrates multicloud private K8S connectivity using [Aviatrix](https://www.aviatrix.com). Pod IP spaces will be reachable from anywhere on the network.

The Terraform assumes:
- the Aviatrix Controller is already deployed and has accounts onboarded. Create a **terraform.tfvars** file to avoid having to enter the name each time.

The account name is the display name in the controller.

```
aws_account_name   = "aws-account"
azure_account_name = "azure-account"
gcp_account_name   = "gcp-account"
```

- the Aviatrix Controller [environment variables](https://registry.terraform.io/providers/AviatrixSystems/aviatrix/latest/docs#environment-variables) for authentication are set.

```
export AVIATRIX_CONTROLLER_IP = "1.2.3.4"
export AVIATRIX_USERNAME = "admin"
export AVIATRIX_PASSWORD = "password"
```

- AWS, Azure, and GCP default credentials (CLI, Env, etc) are configured, defaults chosen, etc.

Will deploy:
- Avx Transit
- Avx Spoke in AWS, Azure, GCP
- Managed K8S in AWS, Azure, GCP

The repo also has a netshoot deployment that can be applied to each cluster for testing.