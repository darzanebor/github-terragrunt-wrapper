#!/usr/bin/env bash
# Define some variables
HELP_MESSAGE="sub commands:\n  - fmt\n  - install\n  - init\n  - plan\n  - apply"

# Get latest terraform version and build url if custom version is not set.
if [[ -z "${TERRAFORM_VERSION}" ]]; then
  TERRAFORM_URL="https://releases.hashicorp.com/terraform/$(curl -s https://checkpoint-api.hashicorp.com/v1/check/terraform | jq -r -M '.current_version')/terraform_$(curl -s https://checkpoint-api.hashicorp.com/v1/check/terraform | jq -r -M '.current_version')_linux_amd64.zip"
else
  TERRAFORM_URL="https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" 
fi

# Get latest terraform version and build url if custom version is not set.
if [[ -z "${TERRAGRUNT_VERSION}" ]]; then
  TERRAGRUNT_URL="https://github.com/gruntwork-io/terragrunt/releases/download/$(curl -s https://api.github.com/repos/gruntwork-io/terragrunt/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')/terragrunt_linux_amd64"
else
  TERRAGRUNT_URL="https://github.com/gruntwork-io/terragrunt/releases/download/${TERRAGRUNT_VERSION}/terragrunt_linux_amd64"
fi

# Wrap around terraform
case $1 in
  "install" )
    if [ ! -d "${HOME}/.local/bin" ];then
        mkdir -p "${HOME}/.local/bin"
    fi
    if [ ! -f "${HOME}/.local/bin/terraform" ]; then
        echo -e "Downloading terraform\n"        
        echo "${HOME}/.local/bin" >> $GITHUB_PATH
        curl -Ls "${TERRAFORM_URL}" -o terraform.zip
        unzip terraform.zip
        mv ./terraform "${HOME}/.local/bin/"
        rm -rf terraform.zip
        echo -e "\nInstalled terraform:"
        terraform version
    fi
    if [ ! -f "${HOME}/.local/bin/terragrunt" ]; then
        echo -e "Downloading terragrunt\n"        
        echo "${HOME}/.local/bin" >> $GITHUB_PATH
        curl -Ls "${TERRAFORM_URL}" -o terragrunt
        chmod u+x terragrunt
        mv terragrunt "${HOME}/.local/bin/"
        echo -e "\nInstalled terragrunt:"
        terragrunt version
    fi    
    ;;
  "init" )
    terraform -chdir=$2 init -input=false
    ;;
  "plan" )
    terraform -chdir=$2 plan -input=false
    ;;
  "apply" )
    terraform -chdir=$2 apply -auto-approve
    ;;    
  "fmt" )
    terraform -chdir=$2 fmt -recursive
    ;;
  * )
    echo -e "${HELP_MESSAGE}\n"
esac
