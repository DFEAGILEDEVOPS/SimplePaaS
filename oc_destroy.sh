#!/bin/bash

# these are our openshift container platform args
oc_project_name=$1
oc_build_config_name=$2
oc_runtime_image=$3
oc_nexus_credentials=$4
oc_openshift_credentials=$5
# these are our azure key store vault args
akv_vault_url=$6
akv_vault_client_id=$7
akv_vault_client_secret=$8
akv_azure_tenant_id=$9

# vsts masks out credential but the stars show us that they are not blank missing args
echo oc_nexus_credentials=$oc_nexus_credentials
echo oc_openshift_credentials=$oc_openshift_credentials 

# echo out the project data
echo oc_project_name=$oc_project_name
echo oc_build_config_name=$oc_build_config_name
echo oc_runtime_image=$oc_runtime_image

#echo out the azure key vault data
echo akv_vault_url=$akv_vault_url
echo akv_vault_client_id=$akv_vault_client_id
echo akv_vault_client_secret=$akv_vault_client_secret
echo akv_azure_tenant_id=$akv_azure_tenant_id

# Download oc
#curl -u $oc_nexus_credentials -O -k https://nexus.demo.dfe.secnix.co.uk/repository/dfe_admin/oc-3.6.173.0.49-linux.tar
wget -O oc.tar https://www.dropbox.com/s/ir3xms1m72p5lsh/oc-3.6.173.0.49-linux.tar?dl=0
tar xfv oc.tar

echo ### LOGGING IN
./oc login --insecure-skip-tls-verify https://demo.dfe.secnix.co.uk:8443 --token="$oc_openshift_credentials"
exists=`./oc projects | grep $oc_project_name`
if [ -n "$exists" ]; then
    ./oc delete project $oc_project_name
fi