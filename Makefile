# ############################################################################ #
# Variables
# ############################################################################ #

# defined
APP_NAME=app-fun
KUBE_CONTEXT=ml-v1-dashing-kit-context
DOCKER_IMAGE=verdigristech/app-fun
DOCKER_TAG=latest

# commands
HELM=helm --debug --kube-context ${KUBE_CONTEXT} --namespace ${NAMESPACE}

# derived
HELM_CHART=${APP_NAME}
NAMESPACE=default
DOCKER_IMAGE_TAGGED=${DOCKER_IMAGE}:${DOCKER_TAG}

# POD_SELECTOR_LABELS=app.kubernetes.io/name=${APP_NAME},app.kubernetes.io/instance=${APP_NAME}
# POD_NAME=$(shell kubectl get pods --namespace ${NAMESPACE} -l "${POD_SELECTOR_LABELS}" -o jsonpath="{.items[0].metadata.name}")
# CONTAINER_PORT=$(shell kubectl get pod --namespace ${NAMESPACE} ${POD_NAME} -o jsonpath="{.spec.containers[0].ports[0].containerPort}")
# NODE_PORT=$(shell kubectl get --namespace app-fun -o jsonpath="{.spec.ports[0].nodePort}" services app-fun)
# NODE_IP=$(shell kubectl get nodes --namespace app-fun -o jsonpath="{.items[0].status.addresses[0].address}")


# ############################################################################ #
# Commands
# ############################################################################ #

build-docker:
	docker build \
		--rm \
		--tag ${DOCKER_IMAGE_TAGGED} \
		-f Dockerfile \
		.

push-docker:
	docker push ${DOCKER_IMAGE_TAGGED}

build-helm:
	# [ ! "$(kubectl get namespace | grep ${NAMESPACE})" ] && kubectl create namespace ${NAMESPACE}
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
	helm lint ./${HELM_CHART}

info: 
	kubectl get all --namespace ${NAMESPACE}

info-logs:
	kubectl logs --namespace ${NAMESPACE} ${POD_NAME}

clean-docker:
	docker image rm ${DOCKER_IMAGE_TAGGED}

clean-k8s:
	[ "$(kubectl get namespace | grep ${NAMESPACE})" ] && kubectl delete namespace ${NAMESPACE}

clean-helm:
	${HELM} uninstall ${HELM_CHART} 

clean: clean-helm # clean-docker clean-k8s
	

#   export POD_NAME=$(kubectl get pods --namespace default -l "app.kubernetes.io/name=app-fun,app.kubernetes.io/instance=app-fun" -o jsonpath="{.items[0].metadata.name}")
#   export CONTAINER_PORT=$(kubectl get pod --namespace default $POD_NAME -o jsonpath="{.spec.containers[0].ports[0].containerPort}")
#   echo "Visit http://127.0.0.1:8080 to use your application"
#   kubectl --namespace default port-forward $POD_NAME 8080:$CONTAINER_PORT
