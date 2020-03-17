#!/bin/sh
set -e

if [[ -z "${YAML_CONF}" ]]; then
  echo "CR not found in YAML_CONF env variable"
  exit 1
fi

RELEASE_NAME=$(echo "$YAML_CONF" | yq r - metadata.name)

kubectl get secrets $RELEASE_NAME-operator-state-backup -o go-template --template='{{index .data "operator-keys"}}' | base64 -d > operator-keys.tar.gz
mkdir operator-keys
tar -C operator-keys -zxvf operator-keys.tar.gz



git config --global credential.helper store

GITHUB_TOKEN=$(echo "$YAML_CONF" | yq r - spec.git.accessToken)

REPO=$(echo "$YAML_CONF" | yq r - spec.git.repository)

BRANCH=$(echo "$YAML_CONF" | yq r - spec.gitOps.watchBranch)
PROFILE_NAME=$(echo "$YAML_CONF" | yq r - spec.profile)
PROFILE_DIR="manifests/$PROFILE_NAME"
echo "https://${GITHUB_TOKEN}:x-oauth-basic@github.com" >> ~/.git-credentials

CONFIG_OUT_DIR="config_repo"
git clone $REPO $CONFIG_OUT_DIR
cd $CONFIG_OUT_DIR
git checkout $BRANCH
cd $PROFILE_DIR



kustomize build . | kubectl apply -f -




