#!/bin/bash
oc_project_name=$1
echo oc_project_name=$oc_project_name
oc_build_config_name=$2
echo oc_build_config_name=$oc_build_config_name
oc_environment=$3
echo oc_environment

# create the project
./oc new-project $oc_project_name
# create a default dotnet2.0 from source which will be deleted later but we will keep the deployment it creates
./oc new-app --name=$oc_build_config_name dotnet:2.0~https://github.com/DFEAGILEDEVOPS/govuk-blank.git
# create the route in from outside
./oc create route edge --service=$oc_build_config_name --hostname=${oc_build_config_name}-${oc_project_name}.demo.dfe.secnix.co.uk
# delete the from source build config and replace it with a from binary build config
./oc delete bc $oc_build_config_name -n $oc_project_name
./oc create -f - <<EOF 
apiVersion: v1
kind: BuildConfig
metadata:
  name: ${oc_build_config_name}
  namespace: ${oc_project_name}
  labels:
    app: ${oc_build_config_name}
    component: development
    logging-infra: development
    provider: openshift
spec:
  triggers:
    - type: ConfigChange
  runPolicy: Serial
  source:
    type: Binary
    binary: {}
  strategy:
    type: Docker
    dockerStrategy:
      from:
        kind: DockerImage
        name: dotnet/dotnet-20-runtime-rhel7
      dockerfilePath: Dockerfile
  output:
    to:
      kind: ImageStreamTag
      name: '${oc_build_config_name}:latest'
  resources: {}
  postCommit: {}
  nodeSelector: null
status:
  lastVersion: 25
EOF
# create the azure key vault secret
# ./oc create -f - <<EOF 
# apiVersion: v1
# kind: Secret
# metadata:
#   name: azure-secret
# stringData:
#   hostname: ${oc_build_config_name}-${oc_project_name}.demo.dfe.secnix.co.uk
#   secret.properties: |-     
#     akv_vault_url=${akv_vault_url}
#     akv_vault_client_id=${akv_vault_client_id}
#     akv_vault_client_secret=${akv_vault_client_secret}
#     akv_azure_tenant_id=${akv_azure_tenant_id}
# EOF

#echo out the azure key vault data
echo akv_vault_url=$akv_vault_url
echo akv_vault_client_id=$akv_vault_client_id
echo akv_vault_client_secret=$akv_vault_client_secret
echo akv_azure_tenant_id=$akv_azure_tenant_id

./oc process -f dotnet-20-runtime-rhel7.json \
  -p akv_vault_url=$akv_vault_url \
  -p akv_vault_client_id=$akv_vault_client_id \
  -p akv_vault_client_secret=$akv_vault_client_secret \
  -p akv_azure_tenant_id=$akv_azure_tenant_id \
| \
./oc create -f -
