# opa-example-app

OPA Example App

## Install Dependencies

Before installing the specific trigger, install the tekton piplines and
triggers
https://github.com/tektoncd/triggers/blob/master/docs/getting-started/README.md#install-dependencies.

## Configure the cluster

- Create the Namespace where the resoures will live:

```bash
kubectl create namespace opa-example-app
```

- Create the secret to access your container registry:

```bash
kubectl create secret docker-registry regcred \
                    --docker-server=<your-registry-server> \
                    --docker-username=<your-name> \
                    --docker-password=<your-pword> \
                    --docker-email=<your-email>
```

- Create the admin user, role and rolebinding

```bash
kubectl apply -f ./config/tekton/trigger/admin-role.yaml
```

- Create the webhook user, role and rolebinding

```bash
kubectl apply -f ./config/tekton/trigger/webhook-role.yaml
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

Delete the `opa-example-app` namespace:

```bash
kubectl delete namespace opa-example-app
```
