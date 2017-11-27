### This file takes a built and zipped VSO, adds a deploy to rhel7 docker file, and uploads it to a nexus repo, the deploys it to openshift. 

echo oc_nexus_credentials=$oc_nexus_credentials
echo oc_openshift_credentials=$oc_openshift_credentials
echo oc_dfe_deploy_url=$oc_dfe_deploy_url
echo oc_nexus_repo=$oc_nexus_repo
echo oc_project=$oc_project
echo oc_app=$oc_app
echo oc_entry_point=$oc_entry_point

echo BUILD_ARTIFACTSTAGINGDIRECTORY=$BUILD_ARTIFACTSTAGINGDIRECTORY
echo BUILD_BINARIESDIRECTORY=$BUILD_BINARIESDIRECTORY
echo BUILD_BUILDID=$BUILD_BUILDID

echo oc_environment=$oc_entry_point

cd $BUILD_ARTIFACTSTAGINGDIRECTORY
echo current location is `pwd`
find . -name \*.zip
INNER_ZIP=`find . -name \*.zip`
echo INNER_ZIP=$INNER_ZIP

# create the secret loader
cat > secret_entrypoint<<EOF
#!/bin/sh
set -a                                                                                                                                                                
. /etc/secret-volume/secret.properties
set +a
exec "$@"
EOF

chmod +x secret_entrypoint

# Create the docker file
cat > Dockerfile <<EOF
FROM registry.access.redhat.com/dotnet/dotnet-20-runtime-rhel7

ADD . .

ENTRYPOINT [ "secret_entrypoint" ]
CMD ["dotnet", "$oc_entry_point"]
EOF

cat Dockerfile

echo ### ADDING Dockerfile TO $INNER_ZIP
zip $INNER_ZIP Dockerfile
mv $INNER_ZIP $BUILD_BUILDID.zip

#echo ### PUBLISHING $INNER_ZIP TO $oc_nexus_repo
#curl -k -v -u $oc_nexus_credentials --upload-file $BUILD_BUILDID.zip $oc_nexus_repo

# Download oc
#curl -u $oc_nexus_credentials -O -k https://nexus.demo.dfe.secnix.co.uk/repository/dfe_admin/oc-3.6.173.0.49-linux.tar
#tar xfv oc-3.6.173.0.49-linux.tar
wget -q -O oc.tar https://www.dropbox.com/s/ir3xms1m72p5lsh/oc-3.6.173.0.49-linux.tar?dl=0
tar xfv oc.tar

echo ### LOGGING IN
./oc login --insecure-skip-tls-verify https://demo.dfe.secnix.co.uk:8443 --token="$oc_openshift_credentials"

echo ### RUNNIGN BUILD appname IN $OC_PROJECT WITH $BUILD_BUILDID.zip
./oc project $oc_project
./oc start-build $oc_app -n $oc_project --from-archive=$BUILD_BUILDID.zip
### This is a bit annoying that we are having to patch this in repeatedly
./oc volume dc/$oc_app --add --type=secret --secret-name=azure-key-vault -m /etc/secret-volume
./oc env dc/$oc_app ASPNETCORE_ENVIRONMENT=${oc_environment}
