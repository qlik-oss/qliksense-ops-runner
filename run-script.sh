#!/bin/sh
set -e

if [[ -z "${YAML_CONF}" ]]; then
  echo "CR not found in YAML_CONF env variable"
  exit 1
fi

RELEASE_NAME=$(echo "$YAML_CONF" | yq r - metadata.name)

echo "Get EJSON from cluster"

kubectl get secrets $RELEASE_NAME-operator-state-backup -o go-template --template='{{index .data "ejson-keys"}}' | base64 -d > ejson-keys.tar.gz

tar -C $EJSON_KEYDIR -zxvf ejson-keys.tar.gz

echo "EJSON env dir: $EJSON_KEYDIR"

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

# check if last commit happened within 10 minutes
#lastCommitDetails=$(git log -1 --format=raw)
#lastCommit=$(git log -1 --format=%ct)
#currentMinusTenMinute=$(date -v-10M +"%s")
#count=$(expr $lastCommit - $currentMinusTenMinute)
#if [ $count -lt 0 ]
#then
#  echo "No need to apply again \n already applied commit details \n $lastCommitDetails"
#  exit 0
#fi
  
git checkout $BRANCH
cd $PROFILE_DIR

kustomize build . | kubectl apply -f - --validate=false




