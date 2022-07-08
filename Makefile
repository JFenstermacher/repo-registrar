.PHONY: build test

# Constants
ROOT_DIRECTORY := `pwd`
OUTPUT_DIRECTORY := $(ROOT_DIRECTORY)/_output
TERRAFORM_DIR := terraform
ARTIFACTS_BUCKET := jff-global-lambda-deployments

TEAM := infra
SERVICE := repo-registrar
GIT_SHA := `git rev-parse HEAD`
API_NAME := $(SERVICE)-api

STAGE ?= production
TERRAFORM_ENV_DIR := $(TERRAFORM_DIR)/environments/$(STAGE)

# Utility Images
BUILD_IMAGE := golang:1.18
S3_PUSH_IMAGE := amazon/aws-cli
TERRAFORM_IMAGE := hashicorp/terraform

build: build-api

build-api:
	@mkdir -p ${OUTPUT_DIRECTORY}
	docker run \
		-v ${ROOT_DIRECTORY}:/usr/src/app \
		-w /usr/src/app \
		${BUILD_IMAGE} \
		/bin/sh -c "go build -o _output/${API_NAME} cmd/${API_NAME}/main.go"
	@cd ${OUTPUT_DIRECTORY} && zip ${API_NAME}.zip ${API_NAME}
	@rm -rf ${OUTPUT_DIRECTORY}/${API_NAME}

push: push-api

push-api:
	docker run \
		-v ${HOME}/.aws:/root/.aws \
		-v ${OUTPUT_DIRECTORY}:/usr/src/_output \
		-w /usr/src \
		${S3_PUSH_IMAGE} s3 cp _output/${API_NAME}.zip s3://${ARTIFACTS_BUCKET}/${TEAM}/${SERVICE}/${API_NAME}/${GIT_SHA}.zip

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
