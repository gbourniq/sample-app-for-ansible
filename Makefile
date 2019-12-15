# Common settings
include Makefile.settings

# Docker container settings
export APP_HTTP_PORT ?= 4000
export CLIENT_HTTP_PORT ?= 3000
export MONGO_HTTP_PORT ?= 27017
export APP_HTTP_ROOT ?= 
export CLIENT_HTTP_ROOT ?=

.PHONY: docker-app-version docker-test docker-build docker-clean docker-tag docker-tag-latest docker-login docker-logout docker-publish docker-all

# Prints version
docker-app-version:
	${INFO} "App version:"
	@ echo $(APP_VERSION)

# Login to Docker registry
docker-login:
	${INFO} "Logging in to Docker registry $(DOCKER_REGISTRY)..."
	@ $(DOCKER_LOGIN_EXPRESSION)
	${SUCCESS} "Logged in to Docker registry $(DOCKER_REGISTRY)"

# Logout of Docker registry
docker-logout:
	${INFO} "Logging out of Docker registry $(DOCKER_REGISTRY)..."
	@ docker logout
	${SUCCESS} "Logged out of Docker registry $(DOCKER_REGISTRY)"

docker-test:
	${INFO} "Running tests..."
	# Run unit tests

# Executes a full workflow
docker-all: clean test build tag-latest publish clean

# Build environments: create images, run containers and acceptance tests
# Then images must be pushed to a registry 
docker-build:
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

	${SUCCESS} "Build environment created"
	${SUCCESS} "App REST endpoint is running at http://$(DOCKER_HOST_IP):$(call get_port_mapping,$(BUILD_ARGS),app,$(APP_HTTP_PORT))$(APP_HTTP_ROOT)"
	${SUCCESS} "Client REST endpoint is running at http://$(DOCKER_HOST_IP):$(call get_port_mapping,$(BUILD_ARGS),client,$(CLIENT_HTTP_PORT))$(CLIENT_HTTP_ROOT)"

# Prod environment: Pull images from registry and run containers
docker-prod:
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

	${SUCCESS} "Prod environment created"
	${SUCCESS} "App REST endpoint is running at http://$(DOCKER_HOST_IP):$(call get_port_mapping,$(PROD_ARGS),app,$(APP_HTTP_PORT))$(APP_HTTP_ROOT)"
	${SUCCESS} "Client REST endpoint is running at http://$(DOCKER_HOST_IP):$(call get_port_mapping,$(PROD_ARGS),client,$(CLIENT_HTTP_PORT))$(CLIENT_HTTP_ROOT)"

# Cleans environment
docker-clean: clean-release clean-prod
	${INFO} "Removing dangling images..."
	@ $(call clean_dangling_images,$(REPO_NAME))
	${SUCCESS} "Clean up complete"

docker-clean%build:
	${INFO} "Destroying build environment..."
	@ docker-compose $(BUILD_ARGS) down -v || true

docker-clean%prod:
	${INFO} "Destroying prod environment..."
	@ docker-compose $(PROD_ARGS) down -v || true

# Tags with latest
docker-tag-latest:
	@ make tag latest

# 'make tag <tag> [<tag>...]' tags development and/or release image with specified tag(s)
docker-tag:
	${INFO} "Tagging release images with tags $(TAG_ARGS)..."
	@ $(foreach tag,$(TAG_ARGS),$(call tag_image,$(BUILD_ARGS),app,$(DOCKER_REGISTRY)/$(ORG_NAME)/$(REPO_NAME_BASE)_app:$(tag));)
	@ $(foreach tag,$(TAG_ARGS),$(call tag_image,$(BUILD_ARGS),client,$(DOCKER_REGISTRY)/$(ORG_NAME)/$(REPO_NAME_BASE)_client:$(tag));)
	@ $(foreach tag,$(TAG_ARGS),$(call tag_image,$(BUILD_ARGS),mongo,$(DOCKER_REGISTRY)/$(ORG_NAME)/$(REPO_NAME_BASE)_mongo:$(tag));)
	${SUCCESS} "Tagging complete"

# Publishes image(s) tagged using make tag commands
docker-publish:
	${INFO} "Publishing release images to $(DOCKER_REGISTRY)/$(ORG_NAME)..."
	@ $(call publish_image,$(BUILD_ARGS),app,$(DOCKER_REGISTRY)/$(ORG_NAME)/$(REPO_NAME_BASE)_app)
	@ $(call publish_image,$(BUILD_ARGS),client,$(DOCKER_REGISTRY)/$(ORG_NAME)/$(REPO_NAME_BASE)_client)
	@ $(call publish_image,$(BUILD_ARGS),mongo,$(DOCKER_REGISTRY)/$(ORG_NAME)/$(REPO_NAME_BASE)_mongo)
	${SUCCESS} "Publish complete"

# IMPORTANT - ensures arguments are not interpreted as make targets
%:
	@:

# ansible related commands
.PHONY: ansible-all ansible-checksyntax ansible-instance-setup ansible-deploy-build ansible-instance-cleanup ansible-deploy-prod

# Executes a full workflow
ansible-all: ansible-checksyntax ansible-instance-setup ansible-deploy-build ansible-instance-cleanup ansible-deploy-prod

ansible-checksyntax:
	${INFO} "Checking ansible command syntax..."
	@ ansible-playbook -i ec2-deployment/inventory.yml ec2-deployment/site.yml --syntax-check
	${SUCCESS} "Syntax check complete..."

ansible-instance-setup:
	${INFO} "Running ansible playbook for machine setup + build deployment"
	@ ansible-playbook -i ec2-deployment/inventory.yml --vault-id ec2-deployment/roles/setup/vars/ansible-vault-pw ec2-deployment/site.yml -vv --tags=system,instance-setup
	${SUCCESS} "Instance setup complete"

ansible-deploy-build:
	${INFO} "Running ansible playbook for build deployment"
	@ ansible-playbook -i ec2-deployment/inventory.yml --vault-id ec2-deployment/roles/setup/vars/ansible-vault-pw ec2-deployment/site.yml -vv --tags=system,docker-cleanup,clone-repo,build,push-registry
	${SUCCESS} "Deployment complete"

ansible-instance-cleanup:
	${INFO} "Delete repo folder, remove all running containers, and run docker system prune"
	@ ansible-playbook -i ec2-deployment/inventory.yml --vault-id ec2-deployment/roles/setup/vars/ansible-vault-pw ec2-deployment/site.yml -vv --tags=docker-cleanup
	${SUCCESS} "Cleanup complete"

ansible-deploy-prod:
	${INFO} "Running ansible playbook for build deployment"
	@ ansible-playbook -i ec2-deployment/inventory.yml --vault-id ec2-deployment/roles/setup/vars/ansible-vault-pw ec2-deployment/site.yml -vv --tags=system,prod
	${SUCCESS} "Deployment complete"


# roles:
# 	${INFO} "Installing Ansible roles from roles/requirements.yml..."
# 	@ ansible-galaxy install -r ec2-deployment/roles/requirements.yml --force
# 	${INFO} "Installation complete"

# environment/%:
# 	@ mkdir -p group_vars/$*
# 	@ touch group_vars/$*/vars.yml
# 	@ echo >> inventory
# 	@ echo '[$*]' >> inventory
# 	@ echo '$* ansible_connection=local' >> inventory
# 	${INFO} "Created environment $*"

# generate/%:
# 	${INFO} "Generating templates for $*..."
# 	@ ansible-playbook site.yml -e 'Sts.Disabled=true' -e env=$* $(FLAGS) --tags generate
# 	${INFO} "Generation complete"

# delete/%:
# 	${INFO} "Deleting environment $*..."
# 	@ ansible-playbook site.yml -e env=$* -e 'Stack.Delete=true' $(FLAGS)
# 	${INFO} "Delete complete"

