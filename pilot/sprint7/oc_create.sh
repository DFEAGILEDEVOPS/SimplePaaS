echo oc_project_name=$oc_project_name
echo oc_build_config_name=$oc_build_config_name
echo oc_runtime_image=$oc_runtime_image
echo oc_nexus_credentials=$oc_nexus_credentials
echo oc_openshift_credentials=$oc_openshift_credentials 

# Download oc
#curl -u $oc_nexus_credentials -O -k https://nexus.demo.dfe.secnix.co.uk/repository/dfe_admin/oc-3.6.173.0.49-linux.tar
wget --quiet -O oc.tar https://www.dropbox.com/s/ir3xms1m72p5lsh/oc-3.6.173.0.49-linux.tar?dl=0
tar xfv oc.tar

echo ### LOGGING IN
./oc login --insecure-skip-tls-verify https://demo.dfe.secnix.co.uk:8443 --token="$oc_openshift_credentials"

echo . ./create_${oc_runtime_image}.sh $oc_project_name $oc_build_config_name
. ./create_${oc_runtime_image}.sh $oc_project_name $oc_build_config_name
