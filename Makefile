# ############################################################################ #
# Variables
# ############################################################################ #

APP_NAME=app-fun
NAMESPACE=app-fun
HELM_RELEASE=app-fun-release
HELM_CHART=charts/app-fun
HELM_VALUES_FILE:=deploy/local/values.yaml
KUBE_CONTEXT=docker-desktop
DOCKER_IMAGE=app-fun
DOCKER_TAG=latest
DOCKER_CONTAINER_NAME=app-fun-container

# commands
HELM=helm --debug --kube-context ${KUBE_CONTEXT} --namespace ${NAMESPACE}
KUBECTL=kubectl --context ${KUBE_CONTEXT}
KUBECTL_NAMESPACE=kubectl --context ${KUBE_CONTEXT} --namespace ${NAMESPACE}
KUBECTL_GET_POD_NAME=${KUBECTL_NAMESPACE} get pods -l "app.kubernetes.io/instance=${HELM_RELEASE},app.kubernetes.io/name=${APP_NAME}" -o jsonpath="{.items[0].metadata.name}"

# derived
DOCKER_IMAGE_TAGGED=${DOCKER_IMAGE}:${DOCKER_TAG}
define SET_POD_NAME # evaluate this after the pod is running
	$(eval POD_NAME=$(shell ${KUBECTL_GET_POD_NAME}))
endef
define HELPER_FILE_TEXT
# Helper functions for ${APP_NAME} release ${HELM_RELEASE}

# env
export POD_NAME=$$(${KUBECTL_GET_POD_NAME})

# aliases
alias k-describe-pod="${KUBECTL} --namespace ${NAMESPACE} describe pod $${POD_NAME}"
alias k-app="${KUBECTL_NAMESPACE}"

endef
export HELPER_FILE_TEXT

# ############################################################################ #
# Commands
# ############################################################################ #

# Create the namespace if it does not exists
create-namespace:
ifeq ("$(shell ${KUBECTL} get namespaces | grep ${NAMESPACE})", "")
	${KUBECTL} create namespace ${NAMESPACE}
else
	@echo "namespace ${NAMESPACE} found"
endif

# Delete the namespace if it exists
delete-namespace:
ifeq ("$(shell ${KUBECTL} get namespaces | grep ${NAMESPACE})", "")
	@echo "namespace ${NAMESPACE} not found"
else
	${KUBECTL} delete namespace ${NAMESPACE}
endif

# Helm lint the chart
helm-lint:
	helm lint ${HELM_CHART}

# Helm install the app service
helm-install: create-namespace
	${HELM} install -f ${HELM_VALUES_FILE} ${HELM_RELEASE} ${HELM_CHART}
	@echo "Go to http://localhost:8080"

# Helm upgrade the app service
helm-upgrade:
	${HELM} upgrade -f ${HELM_VALUES_FILE} ${HELM_RELEASE} ${HELM_CHART}
	@echo "Go to http://localhost:8080"

# Helm uninstall the app service
helm-uninstall:
	${HELM} uninstall ${HELM_RELEASE}

# Stats about the running service namespace
stat-get:
	${KUBECTL_NAMESPACE} get all -o wide

# Stats about the running pod
stat-pod:
	${KUBECTL_NAMESPACE} describe pod $(shell ${KUBECTL_GET_POD_NAME})

# Pod logs
stat-logs:
	${KUBECTL_NAMESPACE} logs $(shell ${KUBECTL_GET_POD_NAME})

# Stats about the running service
stat: stat-get stat-pod
	@echo "$$HELPER_FILE_TEXT" > /tmp/helpers.sh
	@echo --------------------------------------
	@echo Run this for helper functions:
	@echo
	@echo source /tmp/helpers.sh

# Build the docker container
docker-build:
	docker build --rm --tag ${DOCKER_IMAGE_TAGGED} -f Dockerfile .

# Run the container directly
docker-run:
	docker container run -d --rm --name ${DOCKER_CONTAINER_NAME} -p 9000:8000 ${DOCKER_IMAGE_TAGGED}

# Remove the container and image
docker-stop:
	docker container stop ${DOCKER_CONTAINER_NAME}

# Remove the docker image
docker-clean:
	docker container rm ${DOCKER_CONTAINER_NAME}
	docker image rm ${DOCKER_IMAGE_TAGGED}

# Build and Install
build: docker-build helm-install

# Remove all changes
clean: helm-uninstall delete-namespace # docker-clean
