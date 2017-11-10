### This file takes a built and zipped VSO, adds a deploy to rhel7 docker file, 
### and uploads it to a nexus repo, the deploys it to openshift. 

echo BUILD_BUILDID=$BUILD_BUILDID
echo oc_nexus_credentials=$oc_nexus_credentials
echo oc_openshift_credentials=$oc_openshift_credentials
echo oc_dfe_deploy_url=$oc_dfe_deploy_url
echo oc_nexus_repo=$oc_nexus_repo
echo oc_project_name=$oc_project_name
echo oc_build_config_name=$oc_build_config_name
echo artifact_path=$artifact_path

cd $artifact_path
DROP_ZIP=`find . -name \*.zip`
echo DROP_ZIP=$INNER_ZIP
release_name=$oc_project_name.$oc_project_name.$BUILD_BUILDID.zip
mv $DROP_ZIP $release_name

# Create the docker file
cat > Dockerfile <<EOF
FROM registry.access.redhat.com/dotnet/dotnet-20-runtime-rhel7

ADD . .

CMD ["dotnet", "govukblank.dll"]
EOF

echo ### ADDING Dockerfile TO $INNER_ZIP
zip $release_name Dockerfile

wget -q -O oc.tar https://www.dropbox.com/s/ir3xms1m72p5lsh/oc-3.6.173.0.49-linux.tar?dl=0
tar xfv oc.tar

echo ### LOGGING IN
./oc login --insecure-skip-tls-verify https://demo.dfe.secnix.co.uk:8443 --token="$oc_openshift_credentials"

echo ### RUNNIGN BUILD appname IN $oc_project_name WITH $BUILD_BUILDID.zip
./oc project $oc_project_name
./oc start-build $oc_build_config_name -n $oc_project_name --from-archive=$release_name