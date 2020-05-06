# poorman gitops

This provides a Docker image that operates on a local copy of the kustomize config (provided at image build time).
The Qliksense CR is expected to be provided by the `YAML_CONF` env variable.
The script sends the CR and the kustomize config out for kustomization to the service provided by the operator (configured by the `OPERATOR_SERVICE_NAME` and `OPERATOR_SERVICE_PORT` env variables).

The response from the kustomization service is then applied to the cluster by running: `kubectl apply --validate=false`.

This container may be scheduled as a regular one-time Job if the CR is as follows:

```yaml
apiVersion: qlik.com/v1
kind: Qliksense
metadata:
  name: qlik-default
  labels:
    version: notImportantHere
spec:
  profile: docker-desktop
  opsRunner:
    enabled: "yes"
    image: qlik-docker-oss.bintray.io/qliksense-ops-runner:latest
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
