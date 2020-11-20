# Simple Kubernetes App with Helm

Creating an example web app with helm

# Setup

## local

- `make install`
- `make stat` when pod is ready go to `http://localhost:8080/`


### Ingress on `docker-for-mac`

From nginx:

https://github.com/kubernetes/ingress-nginx/blob/master/docs/deploy/index.md#docker-for-mac

run `kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/cloud/deploy.yaml`

This should allow ingress on your local machine then you could set the ingress
to true in the `deploy/local/values.yaml` file and set the service type back to
`NodePort`.


Note: ingress with traefic/maesh is probably a better solution in prod.


# EXtra

http://localhost:8080/api/v1/proxy/namespaces/<NAMESPACE>/services/<SERVICE-NAME>:<PORT-NAME>/
http://localhost:8080/api/v1/namespaces/default/services/app-fun:http/
