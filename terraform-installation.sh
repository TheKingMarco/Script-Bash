#!/bin/bash

#VARIABLES
TERRAFORM_VERSION="1.6.3" #Update with your desired version
INSTALLING_FOLDER="/usr/local/bin/"

#MAIN
curl -Os https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip
curl -Os https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_SHA256SUMS
curl https://keybase.io/hashicorp/pgp_keys.asc | gpg --import
curl -Os https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_SHA256SUMS.sig
gpg --verify terraform_${TERRAFORM_VERSION}_SHA256SUMS.sig terraform_${TERRAFORM_VERSION}_SHA256SUMS
shasum -a 256 -c terraform_${TERRAFORM_VERSION}_SHA256SUMS 2>&1 | grep "${TERRAFORM_VERSION}_linux_amd64.zip:\sOK"
unzip -o terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d $INSTALLING_FOLDER