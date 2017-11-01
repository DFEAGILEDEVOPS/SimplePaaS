#!/bin/bash
PROJECT_NAME=$1
echo PROJECT_NAME=$PROJECT_NAME
APP_NAME=$2
echo APP_NAME=$APP_NAME

oc new-project $PROJECT_NAME
oc new-app --name=$APP_NAME dotnet:2.0~https://github.com/DFEAGILEDEVOPS/govuk-blank.git
oc create route edge --service=$APP_NAME --hostname=$APP_NAME.demo.dfe.secnix.co.uk
oc delete bc $APP_NAME -n $PROJECT_NAME
oc create -f - <<EOF 
apiVersion: v1
kind: BuildConfig
metadata:
  name: ${APP_NAME}
  namespace: ${PROJECT_NAME}
  labels:
    app: ${APP_NAME}
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
      name: '${APP_NAME}:latest'
  resources: {}
  postCommit: {}
  nodeSelector: null
status:
  lastVersion: 25
EOF



