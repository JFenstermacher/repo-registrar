# General variables

MAJOR_VERSION := 1
MINOR_VERSION := 0
BUILD_VERSION ?= ${USER}
VERSION := ${MAJOR_VERSION}.${MINOR_VERSION}.${BUILD_VERSION}

ROOT_DIRECTORY := `pwd`
TERRAFORM_DIR := terraform
ARTIFACTS_BUCKET := jff-global-lambda-deployments

TEAM := infra
SERVICE := repo-registrar
GIT_SHA := `git rev-parse HEAD`

STAGE ?= production
TERRAFORM_ENV_DIR := $(TERRAFORM_DIR)/environments/$(STAGE)

BUILD_IMAGE := ${SERVICE}-builder
TERRAFORM_IMAGE := hashicorp/terraform

# Terraform variables

TERRAFORM_DIRECTORY := ${ROOT_DIRECTORY}/terraform

# Build variables

OUTPUT_DIRECTORY := _output
API_NAME := ${SERVICE}-api

################
# BUILD COMMANDS
################

build: build-api

build-api:
	@echo Building ${API_NAME} zip
	@mkdir -p ${OUTPUT_DIRECTORY}
	CGO_ENABLED=0 GOOS=linux go build -o ${ROOT_DIRECTORY}/_output/${API_NAME} ${ROOT_DIRECTORY}/cmd/api
	@cd ${OUTPUT_DIRECTORY} && zip ${API_NAME}.zip ${API_NAME}
	@rm -rf ${OUTPUT_DIRECTORY}/${API_NAME}

push: push-api

push-api:
	@echo Pushing ${API_NAME} zip to s3://${ARTIFACTS_BUCKET}/${TEAM}/${SERVICE}/${API_NAME}/${GIT_SHA}.zip
	@aws s3 cp _output/${API_NAME}.zip s3://${ARTIFACTS_BUCKET}/${TEAM}/${SERVICE}/${API_NAME}/${GIT_SHA}.zip

####################
# TERRAFORM COMMANDS
####################

terraform/init:
	docker run \
		-v ${HOME}/.aws:/root/.aws \
		-v ${ROOT_DIRECTORY}:/usr/src \
		-w /usr/src \
		-e TF_VAR_git_sha=${GIT_SHA} \
		${TERRAFORM_IMAGE} -chdir=${TERRAFORM_ENV_DIR} init

terraform/apply:
	docker run \
		-v ${HOME}/.aws:/root/.aws \
		-v ${ROOT_DIRECTORY}:/usr/src \
		-w /usr/src \
		-e TF_VAR_git_sha=${GIT_SHA} \
		${TERRAFORM_IMAGE} -chdir=${TERRAFORM_ENV_DIR} apply -auto-approve

terraform/destroy:
	docker run \
		-v ${HOME}/.aws:/root/.aws \
		-v ${ROOT_DIRECTORY}:/usr/src \
		-w /usr/src \
		-e TF_VAR_git_sha=${GIT_SHA} \
		${TERRAFORM_IMAGE} -chdir=${TERRAFORM_ENV_DIR} destroy -auto-approve
