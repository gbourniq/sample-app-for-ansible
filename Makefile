# Common settings
include Makefile.settings

# Docker container settings
export APP_HTTP_PORT ?= 4000
export CLIENT_HTTP_PORT ?= 3000
export MONGO_HTTP_PORT ?= 27017
export APP_HTTP_ROOT ?= 
export CLIENT_HTTP_ROOT ?=
# export DB_NAME ?= audit
# export DB_USER ?= audit
# export DB_PASSWORD ?= password

.PHONY: version test build clean tag tag-latest login logout publish all

# Prints version
version:
	${INFO} "App version:"
	@ echo $(APP_VERSION)

# Login to Docker registry
login:
	${INFO} "Logging in to Docker registry $(DOCKER_REGISTRY)..."
	@ $(DOCKER_LOGIN_EXPRESSION)
	${INFO} "Logged in to Docker registry $(DOCKER_REGISTRY)"

# Logout of Docker registry
logout:
	${INFO} "Logging out of Docker registry $(DOCKER_REGISTRY)..."
	@ docker logout
	${INFO} "Logged out of Docker registry $(DOCKER_REGISTRY)"

test:
	${INFO} "Running tests..."
	# Run unit tests

# Executes a full workflow
all: clean test build tag-latest publish clean

# Build environments: create images, run containers and acceptance tests
# Then images must be pushed to a registry 
build:
	${INFO} "Building images..."
	@ docker-compose $(BUILD_ARGS) build app client mongo
	
	${INFO} "Starting mongo database..."
	@ docker-compose $(BUILD_ARGS) up -d mongo
	@ $(call check_service_health,$(BUILD_ARGS),mongo)

	${INFO} "Starting app service..."
	@ docker-compose $(BUILD_ARGS) up -d app
	@ $(call check_service_health,$(BUILD_ARGS),app)

	${INFO} "Starting client service..."
	@ docker-compose $(BUILD_ARGS) up -d client
	@ $(call check_service_health,$(BUILD_ARGS),client)

	${INFO} "Build environment created"
	${INFO} "App REST endpoint is running at http://$(DOCKER_HOST_IP):$(call get_port_mapping,$(BUILD_ARGS),app,$(APP_HTTP_PORT))$(APP_HTTP_ROOT)"
	${INFO} "Client REST endpoint is running at http://$(DOCKER_HOST_IP):$(call get_port_mapping,$(BUILD_ARGS),client,$(CLIENT_HTTP_PORT))$(CLIENT_HTTP_ROOT)"

# Prod environment: Pull images from registry and run containers
prod:
	${INFO} "Building images..."
	@ docker-compose $(PROD_ARGS) build app client mongo
	
	${INFO} "Starting mongo database..."
	@ docker-compose $(PROD_ARGS) up -d mongo
	@ $(call check_service_health,$(PROD_ARGS),mongo)

	${INFO} "Starting app service..."
	@ docker-compose $(PROD_ARGS) up -d app
	@ $(call check_service_health,$(PROD_ARGS),app)

	${INFO} "Starting client service..."
	@ docker-compose $(PROD_ARGS) up -d client
	@ $(call check_service_health,$(PROD_ARGS),client)

	${INFO} "Prod environment created"
	${INFO} "App REST endpoint is running at http://$(DOCKER_HOST_IP):$(call get_port_mapping,$(PROD_ARGS),app,$(APP_HTTP_PORT))$(APP_HTTP_ROOT)"
	${INFO} "Client REST endpoint is running at http://$(DOCKER_HOST_IP):$(call get_port_mapping,$(PROD_ARGS),client,$(CLIENT_HTTP_PORT))$(CLIENT_HTTP_ROOT)"

# Cleans environment
clean: clean-release clean-prod
	${INFO} "Removing dangling images..."
	@ $(call clean_dangling_images,$(REPO_NAME))
	${INFO} "Clean complete"

clean%build:
	${INFO} "Destroying build environment..."
	@ docker-compose $(BUILD_ARGS) down -v || true

clean%prod:
	${INFO} "Destroying prod environment..."
	@ docker-compose $(PROD_ARGS) down -v || true

# Tags with latest
tag-latest:
	@ make tag latest

# 'make tag <tag> [<tag>...]' tags development and/or release image with specified tag(s)
tag:
	${INFO} "Tagging release images with tags $(TAG_ARGS)..."
	@ $(foreach tag,$(TAG_ARGS),$(call tag_image,$(BUILD_ARGS),app,$(DOCKER_REGISTRY)/$(ORG_NAME)/$(REPO_NAME_BASE)_app:$(tag));)
	@ $(foreach tag,$(TAG_ARGS),$(call tag_image,$(BUILD_ARGS),client,$(DOCKER_REGISTRY)/$(ORG_NAME)/$(REPO_NAME_BASE)_client:$(tag));)
	@ $(foreach tag,$(TAG_ARGS),$(call tag_image,$(BUILD_ARGS),mongo,$(DOCKER_REGISTRY)/$(ORG_NAME)/$(REPO_NAME_BASE)_mongo:$(tag));)
	${INFO} "Tagging complete"

# Publishes image(s) tagged using make tag commands
publish:
	${INFO} "Publishing release images to $(DOCKER_REGISTRY)/$(ORG_NAME)..."
	@ $(call publish_image,$(BUILD_ARGS),app,$(DOCKER_REGISTRY)/$(ORG_NAME)/$(REPO_NAME_BASE)_app)
	@ $(call publish_image,$(BUILD_ARGS),client,$(DOCKER_REGISTRY)/$(ORG_NAME)/$(REPO_NAME_BASE)_client)
	@ $(call publish_image,$(BUILD_ARGS),mongo,$(DOCKER_REGISTRY)/$(ORG_NAME)/$(REPO_NAME_BASE)_mongo)
	${INFO} "Publish complete"

# IMPORTANT - ensures arguments are not interpreted as make targets
%:
	@:
