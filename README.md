## Auth0 Terraform modules for application/client creation

Provisioning of auth0 clients and respective credentials using AWS Secret Manager

📦clients
 ┣ 📂common
 ┣ 📂dev
 ┣ 📂non-prod
 ┣ 📂staging
 ┣ 📂prod

To create/update/delete clients run terraform init/plan/apply for clients common across all environments along with environment specific clients

`./infra-scripts/plan.sh clients/common dev && ./infra-scripts/plan.sh clients/dev dev`
