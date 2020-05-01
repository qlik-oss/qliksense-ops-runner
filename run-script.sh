#!/bin/sh
set -e
echo "starting..."

if [[ -z "${YAML_CONF}" ]]; then
  echo "CR not found in YAML_CONF env variable"
  exit 1
fi

git config --global credential.helper store

GITHUB_TOKEN=$(echo "${YAML_CONF}" | yq r - spec.git.accessToken)
REPO=$(echo "${YAML_CONF}" | yq r - spec.git.repository)
BRANCH=$(echo "${YAML_CONF}" | yq r - spec.opsRunner.watchBranch)
echo "https://${GITHUB_TOKEN}:x-oauth-basic@github.com" >> ~/.git-credentials

CONFIG_OUT_DIR="config_repo"
echo "cloning repo: ${REPO}"
git clone ${REPO} ${CONFIG_OUT_DIR}
echo "cloned repo: ${REPO}"
cd ${CONFIG_OUT_DIR}
git checkout ${BRANCH}
echo "checked out branch: ${BRANCH}"

echo "compressing config directory in preparation for a kustomization request"
tar -czf ../${CONFIG_OUT_DIR}.tgz .
cd ..

CR_BASE64=$(echo "${YAML_CONF}" | base64 -w 0)
CONFIG_BASE64=$(cat "${CONFIG_OUT_DIR}.tgz" | base64 -w 0)
echo '{"cr":"'${CR_BASE64}'","config":"'${CONFIG_BASE64}'"}' > post_data.json

KUZ_SERVICE_ENDPOINT=http://${OPERATOR_SERVICE_NAME}:${OPERATOR_SERVICE_PORT}/kuz
echo "sending a kustomization request to: ${KUZ_SERVICE_ENDPOINT}"
curl -X POST -H "Content-Type: application/json" -d @./post_data.json ${KUZ_SERVICE_ENDPOINT} > kuz_response.json
echo "received a kustomization response"

echo "processing the kustomization response"
cat kuz_response.json | jq --raw-output '.manifests' | base64 -d > manifests.tgz

echo "uncompressing the kustomization response"
mkdir manifests
tar -xzf manifests.tgz -C ./manifests

echo "applying the kustomized manifest(s) to the cluster"
kubectl apply --validate=false -f ./manifests
