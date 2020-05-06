# poorman gitops

This provides a Docker image that pulls kustomize config from a Git repository/branch indicated in the Qliksense CR as `spec.git.repository` and `spec.opsRunner.watchBranch`.
The Qliksense CR is expected to be provided by the `YAML_CONF` env variable.
The script sends the CR and the kustomize config out for kustomization to the service provided by the operator (configured by the `OPERATOR_SERVICE_NAME` and `OPERATOR_SERVICE_PORT` env variables).

The response from the kustomization service is then applied to the cluster by running: `kubectl apply --validate=false`.

You must note that since the `spec.git.repository` is specified in the CR, 
the Qliksense operator will also perform an initial install of the config from the `spec.git.repository` at version `metadata.labels.version`. 

After the initial install is performed by the operator, this container will be scheduled as a CronJob, 
if the Qliksense CR sets `spec.opsRunner.schedule`:

```yaml
apiVersion: qlik.com/v1
kind: Qliksense
metadata:
  name: qlik-default
  labels:
    version: v0.0.8
spec:
  profile: docker-desktop
  git:
    repository: https://github.com/qlik-oss/qliksense-k8s
    accessToken: ""
    userName: ""
  opsRunner:
    enabled: "yes"
    schedule: "*/10 * * * *"
    watchBranch: master
    image: qlik-docker-oss.bintray.io/qliksense-gitops-runner:latest
  secrets:
    qliksense:
      - name: mongoDbUri
        value: mongodb://qlik-default-mongodb:27017/qliksense?ssl=false
  configs:
    qliksense:
      - name: acceptEULA
        value: "yes"
  rotateKeys: "yes"
```

After the initial install is performed by the operator, this container will be scheduled as a regular one-time Job, 
if the Qliksense CR does not set `spec.opsRunner.schedule`:

```yaml
apiVersion: qlik.com/v1
kind: Qliksense
metadata:
  name: qlik-default
  labels:
    version: v0.0.8
spec:
  profile: docker-desktop
  git:
    repository: https://github.com/qlik-oss/qliksense-k8s
    accessToken: ""
    userName: ""
  opsRunner:
    enabled: "yes"
    schedule: ""
    watchBranch: master
    image: qlik-docker-oss.bintray.io/qliksense-gitops-runner:latest
  secrets:
    qliksense:
      - name: mongoDbUri
        value: mongodb://qlik-default-mongodb:27017/qliksense?ssl=false
  configs:
    qliksense:
      - name: acceptEULA
        value: "yes"
  rotateKeys: "yes"
```
