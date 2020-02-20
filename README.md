# opa-example-app

OPA Example App

## Install Dependencies

Before proceeding with this tutorial, you'll need to install the following:
1. Install the tekton [piplines and
   triggers](https://github.com/tektoncd/triggers/blob/master/docs/getting-started/README.md#install-dependencies).
2. If using GCP, follow the [instructions for using the Nginx Ingress
   Controller](https://github.com/tektoncd/triggers/blob/master/docs/exposing-eventlisteners.md#using-nginx-ingress)
   pasted here for convenience:
   ```bash
   kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/mandatory.yaml
   kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/cloud-generic.yaml
   ```

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

```bash
kubectl apply -f ./config/tekton/trigger/pipeline.yaml
```

### Install the TriggerTemplate, TriggerBinding and EventListener

```bash
kubectl apply -f ./config/tekton/trigger/triggers.yaml
```

## Add Ingress and GitHub-Webhook Tasks

```bash
kubectl apply -f ./config/tekton/trigger/create-ingress.yaml
kubectl apply -f ./config/tekton/trigger/create-webhook.yaml
```

## Run Ingress Task

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

Create the webhook task:

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
