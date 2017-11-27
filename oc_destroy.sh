#!/bin/bash

# these are our openshift container platform args
oc_project_name=$1
oc_openshift_credentials=$2

echo oc_project_name=$oc_project_nam
echo oc_openshift_credentials=$oc_openshift_credentials 

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