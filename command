#Comando per lanciare un terraform code da un container docker temporaneo , dove mappaiamo la nostra folder con il codice terraform alll'interno del pod e lanciamo lo facciamo eseguire all'interno del container stesso.
docker run -i -t -v ${PWD}:/usr/tf -w /usr/tf \
--env ARM_CLIENT_ID="dafebf91-30bb-4d9f-a6ee-938b5b797f0f" \
--env ARM_CLIENT_SECRET="kjZ8Q~8hCwaxi2ichZaJ2V5aiay3wka2hN6Grdju" \
--env ARM_SUBSCRIPTION_ID="2f712ec6-ce7d-4e04-a296-7f2bfa377acc" \
--env ARM_TENANT_ID="0692be0c-fb8f-4528-b7c3-237e428ca1d8" \
--env ARM_ACCESS_KEY="Qql8EDB1m5rACaTFzClHSzRX4UasOJFTSvz2e93Y57X9IeNYGaxrj7IeggDRyKh8YCzdy1XtKo5J+AStMRV0Iw==" \
hashicorp/terraform:latest \
init -backend-config="backend.tfvars"


export ARM_SUBSCRIPTION_ID="2f712ec6-ce7d-4e04-a296-7f2bfa377acc"
export ARM_CLIENT_ID="dafebf91-30bb-4d9f-a6ee-938b5b797f0f"
export ARM_CLIENT_SECRET="kjZ8Q~8hCwaxi2ichZaJ2V5aiay3wka2hN6Grdju"
export ARM_TENANT_ID="0692be0c-fb8f-4528-b7c3-237e428ca1d8"
export ARM_ACCESS_KEY="Qql8EDB1m5rACaTFzClHSzRX4UasOJFTSvz2e93Y57X9IeNYGaxrj7IeggDRyKh8YCzdy1XtKo5J+AStMRV0Iw=="