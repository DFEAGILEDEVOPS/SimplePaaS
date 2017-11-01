OC_PROJECT=simon
RELEASE_ZIP=$1
NEXUS3_CREDS=$2
echo ### Deploying RELEASE_ZIP
unzip $RELEASE_ZIP
rm $RELEASE_ZIP
INNER_ZIP=`find . -name \*.zip`
cat > Dockerfile <<EOF
FROM registry.access.redhat.com/dotnet/dotnet-20-runtime-rhel7

ADD . .

CMD ["dotnet", "govukblank.dll"]
EOF
zip $INNER_ZIP Dockerfile
curl -u $NEXUS3_CREDS -O -k https://nexus.demo.dfe.secnix.co.uk/repository/dfe_admin/oc-3.6.173.0.49-linux.tar
tar xfv oc-3.6.173.0.49-linux.tar
echo ### LOGGING IN
./oc login --insecure-skip-tls-verify https://demo.dfe.secnix.co.uk:8443 --token=Mb5h2r7moo3slRnXUeun3kXEHx1BexHoNeiaOyrGJ2M
echo ### SETTING PROJECT
./oc project $OC_PROJECT
echo ### VIEW DETAILS
./oc start-build appname -n $OC_PROJECT --from-archive=$INNER_ZIP
