#!/bin/sh
set -e
echo "starting..."

if [[ -z "${YAML_CONF}" ]]; then
  echo "CR not found in YAML_CONF env variable"
  exit 1
fi

CONFIG_OUT_DIR="config_repo"
cd ${CONFIG_OUT_DIR}
echo "compressing config directory in preparation for a kustomization request"
tar -czf ../${CONFIG_OUT_DIR}.tgz .
cd ..

echo 'setting rotateKeys="yes" in the CR'
echo "${YAML_CONF}" > cr.yaml
yq write -i cr.yaml --style=double spec.rotateKeys yes

CR_BASE64=$(cat cr.yaml | base64 -w 0)
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
cat ./manifests/*.yaml
cat ./manifests/*.yaml | kubectl apply --validate=false -f -
