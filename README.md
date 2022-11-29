### GithubAction Terraform Wrapper
#
#### Examples:
##### main.tf
```
terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"

  backend "s3" {
    endpoint                    = "storage.yandexcloud.net"
    bucket                      = "muffs-tf-state"
    region                      = "ru-central1"
    key                         = "state/terraform.tfstate"
    skip_region_validation      = true
    skip_credentials_validation = true
  }
}


variable "yandex_token" {}


provider "yandex" {
  token     = var.yandex_token
  cloud_id  = "fake-cloud-id"
  folder_id = "fake-folder-id"
  zone      = "ru-central1-a"
}
```
#
##### workflow.yaml
#

```
on:
  push:
  workflow_dispatch:

env:
  tf_working_dir: './tf'

jobs:
  check:
    name: Terraform IaC
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v3

      - name: Terraform install
        uses: darzanebor/github-terraform-wrapper@v0.0.3
        env:
          # Defaults to latest terraform release
          TERRAFORM_VERSION: '1.3.5'
        with:
          tf_command: 'install'
          
      - name: Terraform fmt
        uses: darzanebor/github-terraform-wrapper@v0.0.3
        env:
          GITHUB_TOKEN: "${{ secrets.OAUTH_TOKEN }}"        
        with:
          tf_command: 'fmt'
          tf_path: "${{ env.tf_working_dir }}"

      - name: Terraform init
        uses: darzanebor/github-terraform-wrapper@v0.0.3
        env:
          TF_VAR_yandex_token: "${{ secrets.YANDEX_TOKEN }}"
          AWS_ACCESS_KEY_ID: "${{ secrets.AWS_ACCESS_KEY_ID }}"
          AWS_SECRET_ACCESS_KEY: "${{ secrets.AWS_SECRET_ACCESS_KEY }}"
        with:
          tf_command: 'init'
          tf_path: "${{ env.tf_working_dir }}"

      - name: Terraform plan
        uses: darzanebor/github-terraform-wrapper@v0.0.3
        env:
          TF_VAR_yandex_token: "${{ secrets.YANDEX_TOKEN }}"
          AWS_ACCESS_KEY_ID: "${{ secrets.AWS_ACCESS_KEY_ID }}"
          AWS_SECRET_ACCESS_KEY: "${{ secrets.AWS_SECRET_ACCESS_KEY }}"
        with:
          tf_command: 'plan'
          tf_path: "${{ env.tf_working_dir }}"

      - name: Terraform apply
        uses: darzanebor/github-terraform-wrapper@v0.0.3
        env:
          TF_VAR_yandex_token: "${{ secrets.YANDEX_TOKEN }}"
          AWS_ACCESS_KEY_ID: "${{ secrets.AWS_ACCESS_KEY_ID }}"
          AWS_SECRET_ACCESS_KEY: "${{ secrets.AWS_SECRET_ACCESS_KEY }}"
        with:
          tf_command: 'apply'
          tf_path: "${{ env.tf_working_dir }}"

```
