.SILENT :
.PHONY : config-keycloak build-webap deploy undeploy

# Compose files
define COMPOSE_FILES
	-f docker-compose.yml \
	-f docker-compose.config.yml \
	-f docker-compose.app.yml
endef

# Include common Make tasks
include ./makefiles/help.Makefile
include ./makefiles/compose.Makefile

## Configure keycloak
config-keycloak:
	docker-compose $(COMPOSE_FILES) run keycloak-config

## Build Web App
build-webapp:
	echo "Building Web App..."
	docker-compose $(COMPOSE_FILES) run build-webapp

## Deploy infrastructure to Docker host
deploy:
	echo "Setup Nunux Keeper..."
	cat .env
	docker-compose up -d
	$(MAKE) build-webapp
	$(MAKE) config service=keycloak
	docker-compose \
		-f docker-compose.yml \
		-f docker-compose.app.yml \
		up -d
	echo "Congrats! Nunux Keeper up and running."

## Teardown infrastructure from Docker host
undeploy:
	echo "Teardown Nunux Keeper..."
	docker-compose $(COMPOSE_FILES) down
	echo "Nunux Keeper stopped and removed."

