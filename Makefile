# ############################################################################ #
# Variables
# ############################################################################ #

# defined
APP_NAME=app-fun
KUBE_CONTEXT=docker-desktop
DOCKER_IMAGE=app-fun
DOCKER_TAG=latest

# commands
HELM=helm --debug --kube-context ${KUBE_CONTEXT} --namespace ${NAMESPACE}

# derived
HELM_CHART=${APP_NAME}
NAMESPACE=example
DOCKER_IMAGE_TAGGED=${DOCKER_IMAGE}:${DOCKER_TAG}

POD_SELECTOR_LABELS=app.kubernetes.io/name=${APP_NAME},app.kubernetes.io/instance=${APP_NAME}
# POD_NAME=$(shell kubectl get pods --namespace ${NAMESPACE} -l "${POD_SELECTOR_LABELS}" -o jsonpath="{.items[0].metadata.name}")
# 
# NODE_PORT=$(shell kubectl get --namespace app-fun -o jsonpath="{.spec.ports[0].nodePort}" services app-fun)
# NODE_IP=$(shell kubectl get nodes --namespace app-fun -o jsonpath="{.items[0].status.addresses[0].address}")

define SET_POD_NAME
	$(eval POD_NAME=$(shell kubectl get pods --namespace ${NAMESPACE} -l "${POD_SELECTOR_LABELS}" -o jsonpath="{.items[0].metadata.name}"))
endef

define SET_CONTAINER_PORT
	${SET_POD_NAME}
	$(eval CONTAINER_PORT=$(shell kubectl get pod --namespace ${NAMESPACE} ${POD_NAME} -o jsonpath="{.spec.containers[0].ports[0].containerPort}"))
endef


# ############################################################################ #
# Commands
# ############################################################################ #

namespace:
	-kubectl --context docker-desktop create namespace example

install: namespace
	helm --kube-context docker-desktop --namespace example install -f deploy/local/values.yaml appfun ./charts/app-fun

uninstall:
	helm --kube-context docker-desktop --namespace example uninstall appfun
	kubectl --context docker-desktop delete namespace example

stat:
	kubectl --context docker-desktop --namespace example get all





build-docker:
	docker build \
		--rm \
		--tag ${DOCKER_IMAGE_TAGGED} \
		-f Dockerfile \
		.

build-helm:
ifeq ($(shell kubectl get namespace | grep ${NAMESPACE}), 1)
	kubectl create namespace ${NAMESPACE}
else
	@echo "Namespace '${NAMESPACE}' exists."
endif
	${HELM} install ${HELM_CHART} ./charts/${HELM_CHART}

build: build-docker build-helm

deploy:
	${HELM} upgrade ${HELM_CHART} ./charts/${HELM_CHART}

run-docker:
	docker container run --rm -p 8008:8000 ${DOCKER_IMAGE_TAGGED}

run:
	@echo "-------- run --------"
	@echo "Forwarding ${POD_NAME} 8080:${CONTAINER_PORT}"
	@echo "Visit http://localhost:8080 to use your application"
	@echo "echo http://${NODE_IP}:${NODE_PORT}"
	@echo "-------- run --------"
	# kubectl --namespace ${NAMESPACE} port-forward ${POD_NAME} 8080:${CONTAINER_PORT}

lint:
	helm lint ./charts/${HELM_CHART}

info: 
	kubectl get all --namespace ${NAMESPACE}

	${SET_POD_NAME}
	${SET_CONTAINER_PORT}
	@echo "visit ${POD_NAME} ${CONTAINER_PORT}"

#   export POD_NAME=$(kubectl get pods --namespace default -l "app.kubernetes.io/name=app-fun,app.kubernetes.io/instance=app-fun" -o jsonpath="{.items[0].metadata.name}")
#   export CONTAINER_PORT=$(kubectl get pod --namespace default $POD_NAME -o jsonpath="{.spec.containers[0].ports[0].containerPort}")
#   echo "Visit http://127.0.0.1:8080 to use your application"
#   kubectl --namespace default port-forward $POD_NAME 8080:$CONTAINER_PORT

info-logs:
	${SET_POD_NAME}
	kubectl logs --namespace ${NAMESPACE} ${POD_NAME}

info-pod:
	${SET_POD_NAME}
	kubectl describe pod ${POD_NAME}

clean-docker:
	docker image rm app-fun:latest

# clean-k8s:
# ifeq ($(shell kubectl get namespace | grep ${NAMESPACE}), 1)
# 	@echo "Namespace '${NAMESPACE}' was deleted previously."
# else
# 	kubectl delete namespace ${NAMESPACE}
# endif

clean-helm:
	${HELM} uninstall ${HELM_CHART} 

clean: clean-helm clean-docker clean-k8s
