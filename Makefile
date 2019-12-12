# Project variables
PROJECT_NAME ?= myapp
ORG_NAME ?= dockerproductionaws
REPO_NAME ?= microtrader
TEST_REPO_NAME ?= microtrader-dev
TEST_DIR ?= build/test-results/junit/
CONDA_ENV_NAME ?= devops-test

# Import local environment overrides
# $(shell conda env update $(CONDA_ENV_NAME))
# $(shell conda env activate $(CONDA_ENV_NAME))

# Push to ECR
# AWS_ACCOUNT_ID ?= 684585179542
# DOCKER_REGISTRY ?= $(AWS_ACCOUNT_ID).dkr.ecr.eu-west-3.amazonaws.com
# DOCKER_LOGIN_EXPRESSION := eval $$(aws get-login --registry-ids $(AWS_ACCOUNT_ID))

# Release settings
# export HTTP_PORT ?= 8000
# export AUDIT_HTTP_ROOT ?= /audit/
# export QUOTE_HTTP_ROOT ?.= /quote/
# export MARKET_DATA_ADDRESS ?= market
# export MARKET_PERIOD ?= 3000
# export DB_NAME ?= audit
# export DB_USER ?= audit
# export DB_PASSWORD ?= password
# export BUILD_ID ?=

# Common settings
include Makefile.settings

.PHONY: version

# .PHONY: version test build release clean tag tag%default login logout publish compose dcompose database save load demo all

# Prints version
version:
	${INFO} "App version:"
	@ echo $(APP_VERSION)



