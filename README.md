### GithubAction Terragrunt Wrapper
#
#### Examples:
##### env/terragrunt.hcl
```
generate "s3_backend" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
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
    key                         = "demo/${path_relative_to_include()}/terraform.tfstate"
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
EOF
}
```
#
##### env/infra/terragrunt.hcl
```
include "root" {
  path = find_in_parent_folders()
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
  tg_working_dir: 'env/infra'
  # GITHUB TOKEN USED for fmt to upload formated code
  GITHUB_TOKEN: "${{ secrets.OAUTH_TOKEN }}"
  TF_VAR_yandex_token: "${{ secrets.YANDEX_TOKEN }}"
  AWS_ACCESS_KEY_ID: "${{ secrets.AWS_ACCESS_KEY_ID }}"
  AWS_SECRET_ACCESS_KEY: "${{ secrets.AWS_SECRET_ACCESS_KEY }}"  
  # Defaults to latest terraform release
  TERRAFORM_VERSION: '1.3.5'
  # Defaults to latest terragrunt release
  TERRAGRUNT_VERSION: 'v0.42.1'  

jobs:
  check:
    name: Terragrunt IaC
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v3

      - name: Terragrunt install
        uses: darzanebor/github-terragrunt-wrapper@v0.0.3
        with:
          tg_command: 'install'

      - name: Terragrunt init/fmt
        uses: darzanebor/github-terragrunt-wrapper@v0.0.3
        with:
          tg_command: 'fmt'
          git_pattern: '(:!.terraform.lock.hcl)(:!.terraform)'
          tg_path: "${{ env.tg_working_dir }}"

      - name: Terragrunt plan
        uses: darzanebor/github-terragrunt-wrapper@v0.0.3
        with:
          tg_command: 'plan'
          tg_path: "${{ env.tg_working_dir }}"

      - name: Terragrunt apply
        uses: darzanebor/github-terragrunt-wrapper@v0.0.3
        with:
          tg_command: 'apply'
          tg_path: "${{ env.tg_working_dir }}"

```
