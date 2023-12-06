#!/bin/bash

#prima di tutto accedi al tenant e scegli la subsciption che devi ottonere poi lancia lo script
#az login --tenant<tenant id>
#az account set --subscription="<Subscription ID>" (se hai piu di una subsciption)

SP_NAME="SPFORTERRAFORM"
SUBSCRIPTION=$(az account show -o yaml | grep id | awk '{print $2}')

az ad sp create-for-rbac --name="$SP_NAME" --role="Contributor" --scopes="/subscriptions/$SUBSCRIPTION" > "SP_$SP_NAME"