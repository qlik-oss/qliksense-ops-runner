# poorman gitops

It is simple container that just pull a particular branch and based on the profile in CR it just run `kustomize build . | kubectl apply -f - --validate=false`

It expects the CR to be in the environment variable `YAML_CONF`. The CR should have at least following spec

```yaml
apiVersion: qlik.com/v1
kind: Qliksense
metadata:
  name: qlik-default
  labels:
    version: v0.0.2
spec:
  git:
    repository: https://github.com/ffoysal/qliksense-k8s
    accessToken: token_to_be_used_to_access_git_repo
    userName: "blblbl"
  gitOps:
    enabled: "no"
    schedule: "*/5 * * * *"
    watchBranch: pr-branch-24868a33
    image: qlik-docker-oss.bintray.io/qliksense-repo-watcher
  profile: docker-desktop
  ```
  