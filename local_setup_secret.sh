#!/bin/bash
if [ "x$1" == "x" ];then
  NAMESPACE=$1
else
  NAMESPACE="default"
fi
AWS_ACCOUNT="493490470276"
AWS_REGION="cn-north-1"
if [ "x$SECRET_NAME" == "x" ]; then SECRET_NAME=${AWS_REGION}-ecr-registry-key; fi
TOKEN=`aws ecr --region=$AWS_REGION get-authorization-token --output text --query authorizationData[].authorizationToken | base64 -D | cut -f2 -d:`
DOCKER_CFG_SECRET=`printf '{"%s":{"username":"AWS","password":"%s"}}' "https://${AWS_ACCOUNT}.dkr.ecr.${AWS_REGION}.amazonaws.com.cn" "${TOKEN}" | base64 | tr -d '\n'`

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
data:
  .dockercfg: ${DOCKER_CFG_SECRET}
metadata:
  name: ${SECRET_NAME}
  namespace: ${NAMESPACE}
type: kubernetes.io/dockercfg
EOF
