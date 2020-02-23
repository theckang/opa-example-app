# opa-example-app

OPA Example App

## Install Dependencies

Before proceeding with this tutorial, you'll need to install the following:
1. Install the tekton [piplines and
   triggers](https://github.com/tektoncd/triggers/blob/master/docs/getting-started/README.md#install-dependencies).
2. Install the TektonCD Dashboard by following these
   [instructions](https://github.com/tektoncd/dashboard#install-dashboard).
   Once installed, you can install the following Ingress resources to expose it
   via the same load balancer IP address being used by the other Ingress
   resources. Be sure to modify the host field to provide your own fully
   qualified domain name.
   ```bash
   kubectl apply -f ./config/tekton/dashboard/ingress.yaml
   ```
3. If using GCP, follow the [instructions for using the Nginx Ingress
   Controller](https://github.com/tektoncd/triggers/blob/master/docs/exposing-eventlisteners.md#using-nginx-ingress)
   pasted here for convenience:
   ```bash
   kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/mandatory.yaml
   kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/cloud-generic.yaml
   ```

## Fork This Repository

You'll want to fork this repository in order run through the tutorial so that
you can commit and push changes to trigger builds.

## Configure the cluster

- Create the Namespace where the resoures will live:

```bash
kubectl create namespace opa-example-app
kubectl create namespace opa-example-app-trigger
```

- Set the namespace for the `current-context`:

```bash
kubectl config set-context $(kubectl config current-context) --namespace opa-example-app-trigger
```

- Create the secret to access your container registry. If using Quay, you can
  create a robot account and provide it the necessary permissions to push to
  your container registry repo.

```bash
kubectl create secret docker-registry regcred \
                    --docker-server=<your-registry-server> \
                    --docker-username=<your-name> \
                    --docker-password=<your-pword> \
                    --docker-email=<your-email>
```

- Create the trigger admin user, role and rolebinding

```bash
kubectl apply -f ./config/tekton/trigger/admin-role.yaml
```

- Create the webhook user, role and rolebinding

```bash
kubectl apply -f ./config/tekton/trigger/webhook-role.yaml
```

- Create the deploy role and rolebinding in the namespace that will host the
  opa-example-app:

```bash
kubectl -n opa-example-app apply -f ./config/tekton/trigger/admin-role.yaml
```

## Install the Pipeline and Trigger

### Install the Pipeline

Be sure to replace the `targetPath` for the `go test` `Condition` according to
your github repo source code. Then run:

```bash
kubectl apply -f ./config/tekton/trigger/pipeline.yaml
```

### Install the TriggerTemplate, TriggerBinding and EventListener

Be sure to replace the image `PipelineResource` `image-source` `url` field with
the respective container registry and repository to use for pushing the built
image. Then run:

```bash
kubectl apply -f ./config/tekton/trigger/triggers.yaml
```

## Add Ingress and GitHub-Webhook Tasks

```bash
kubectl apply -f ./config/tekton/trigger/create-ingress.yaml
kubectl apply -f ./config/tekton/trigger/create-webhook.yaml
```

## Run Ingress Task

Be sure to replace the `ExternalDomain` parameter value with your FQDN. This
will be used by the GitHub webhook to reach the ingress in your cluster in
order to pass the relevent GitHub commit details to the `EventListener` service
running in your cluster. Then run:

```bash
kubectl apply -f ./config/tekton/trigger/ingress-run.yaml
```

## Run GitHub Webhook Task

You will need to create a [GitHub Personal Access
Token](https://help.github.com/en/articles/creating-a-personal-access-token-for-the-command-line#creating-a-token)
with the following access:

- public_repo
- admin:repo_hook

Next, create a secret like so with your access token.

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: webhook-secret
    namespace: opa-example-app
    stringData:
      token: YOUR-GITHUB-ACCESS-TOKEN
        secret: random-string-data
```

Next you'll want to edit the `webhook-run.yaml` file:
- Modify the `GitHubOrg` and `GitHubUser` fields to match your setup.
- Modify the `ExternalDomain` field to match the FQDN used in
  `ingress-run.yaml` for configuring the GitHub webhook to use this FQDN to
  talk to the `EventListener`.

Then Create the webhook task:

```bash
kubectl apply -f ./config/tekton/trigger/webhook-run.yaml
```

## Watch it work!

Commit and push an empty commit to your development repo.

```bash
git commit -a -m "build commit" --allow-empty && git push origin mybranch
```

## Cleanup

Delete the namespaces:

```bash
kubectl delete namespace opa-example-app-trigger
kubectl delete namespace opa-example-app
```
