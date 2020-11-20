# Simple Kubernetes App with Helm

Creating an example web app with helm

# Setup

* `make build` - Will create docker image, install service via helm chart, and k8s namespace.
* `make stat` - Statistics about the running service. Will also provide some helper function for debugging.
* `make clean` - Deletes docker image, service via helm, and k8s namespace.

### Ingress on `docker-for-mac`

From nginx:

https://github.com/kubernetes/ingress-nginx/blob/master/docs/deploy/index.md#docker-for-mac

run `kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/cloud/deploy.yaml`

This should allow ingress on your local machine then you could set the ingress
to true in the `deploy/local/values.yaml` file and set the service type back to
`NodePort`.

Note: ingress with traefic/maesh is probably a better solution in prod.
