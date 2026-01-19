# File: Makefile
#
# Makefile for managing the Docker Compose Traefik Edge Stack.
# Provides convenient targets for common development workflows.
#
# Usage:
#   make help                 - Display this help message.
#   make up                   - Start the default stack (Traefik + whoami).
#   make down                 - Stop and remove the default stack.
#   COMPOSE_PROFILES=le make up - Start stack with Let's Encrypt profile.
#   make certs-local          - Generate local self-signed certificates (Mode A).
#   make test                 - Run all smoke tests.
#

# --- Configuration Variables ---
SHELL := /bin/bash # Ensure bash is used for shell commands
.DEFAULT_GOAL := help # Default target if none is specified
.PHONY: help up down restart logs ps test docs-check bootstrap \
        certs-local local-ca-trust-install local-ca-trust-uninstall local-ca-trust-verify \
        certs-le-issue certs-le-renew \
        stepca-up stepca-down stepca-bootstrap stepca-verify-cert \
        stepca-trust-install stepca-trust-uninstall stepca-trust-verify \
        hosts-generate hosts-apply hosts-remove hosts-status \
        dns-up dns-down dns-logs dns-status dns-provision dns-provision-dry \
dns-config-apply dns-config-remove dns-config-status

# Include .env for environment variables if it exists.
# This makes variables in .env available to the Makefile.
-include .env
.EXPORT_ALL_VARIABLES:

# --- Docker Compose Commands ---

# Files that define the layered compose graph (base + individual services).
COMPOSE_FILES := \
  -f compose/base.yml \
  -f services/traefik/compose.yml \
  -f services/whoami/compose.yml \
  -f services/dns/compose.yml \
  -f services/certbot/compose.yml \
  -f services/step-ca/compose.yml

# Pin compose project directory/name to avoid cross-CWD conflicts.
COMPOSE_PROJECT_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
COMPOSE_PROJECT_NAME ?= $(PROJECT_NAME)
ifeq ($(COMPOSE_PROJECT_NAME),)
COMPOSE_PROJECT_NAME := $(notdir $(abspath $(COMPOSE_PROJECT_DIR)))
endif

CERTS_DIR := shared/certs

COMPOSE_CMD := docker compose --env-file .env --project-directory $(COMPOSE_PROJECT_DIR) --project-name $(COMPOSE_PROJECT_NAME) $(COMPOSE_FILES)
COMPOSE_OPTS ?=
comma := ,
COMPOSE_PROFILES_LIST = $(strip $(subst $(comma), ,$(COMPOSE_PROFILES)))
COMPOSE_PROFILES_ARG = $(foreach profile,$(COMPOSE_PROFILES_LIST),--profile $(profile))

# Hosts subdomain mapper options
HOSTS_ENV_ARGS :=
ifneq ($(ENV_FILE),)
HOSTS_ENV_ARGS += --env-file $(ENV_FILE)
endif
ifneq ($(HOSTS_FILE),)
HOSTS_ENV_ARGS += --hosts-file $(HOSTS_FILE)
endif

DNS_ENV_ARGS :=
ifneq ($(ENV_FILE),)
DNS_ENV_ARGS += --env-file $(ENV_FILE)
endif

# Start the stack
up:
	@echo "Starting Docker Compose stack with profiles: ${COMPOSE_PROFILES}"
	./scripts/up.sh $(COMPOSE_PROFILES_ARG)

# Stop the stack
down:
	@echo "Stopping Docker Compose stack with profiles: ${COMPOSE_PROFILES}"
	./scripts/down.sh $(COMPOSE_PROFILES_ARG)

# Restart the stack
restart: down up

# View logs for all services
logs:
	@echo "Showing logs for Docker Compose stack with profiles: ${COMPOSE_PROFILES}"
	./scripts/logs.sh $(COMPOSE_PROFILES_ARG)

# List running services
ps:
	@echo "Listing services for Docker Compose stack with profiles: ${COMPOSE_PROFILES}"
	$(COMPOSE_CMD) $(COMPOSE_PROFILES_ARG) $(COMPOSE_OPTS) ps

# --- Certificate Management (Mode A: Local Self-Signed) ---

bootstrap:
	@echo "Bootstrapping local environment (.env and directories)..."
	./scripts/env-generate.sh
	mkdir -p shared/certs shared/certs/local-ca shared/certs/local

certs-local:
	@echo "Generating local self-signed certificates..."
	./scripts/certs-selfsigned-generate.sh

# Install Mode A local CA into Ubuntu trust store
local-ca-trust-install:
	@echo "Installing local CA into system trust store..."
	./scripts/local-ca-trust-install.sh

# Remove Mode A local CA from Ubuntu trust store
local-ca-trust-uninstall:
	@echo "Removing local CA from system trust store..."
	./scripts/local-ca-trust-uninstall.sh

# Verify Mode A local CA is trusted by Ubuntu
local-ca-trust-verify:
	@echo "Verifying local CA trust..."
	./scripts/local-ca-trust-verify.sh

# --- Certificate Management (Mode B: Let's Encrypt with Certbot) ---

# Note: certbot service needs to be running. Use COMPOSE_PROFILES=le make up first.
certs-le-issue:
	@echo "Attempting to issue Let's Encrypt certificate via Certbot..."
	@if [ -z "$(ACME_EMAIL)" ]; then echo "Error: ACME_EMAIL not set in .env. Aborting."; exit 1; fi
	./scripts/certbot-issue.sh

certs-le-renew:
	@echo "Attempting to renew Let's Encrypt certificate via Certbot..."
	./scripts/certbot-renew.sh

# --- Certificate Management (Mode C: Step-CA) ---

# Start step-ca service
stepca-up:
	@echo "Starting Step-CA service..."
	COMPOSE_PROFILES=stepca $(COMPOSE_CMD) $(COMPOSE_OPTS) up -d step-ca

# Stop step-ca service
stepca-down:
	@echo "Stopping Step-CA service..."
	COMPOSE_PROFILES=stepca $(COMPOSE_CMD) $(COMPOSE_OPTS) stop step-ca || true
	COMPOSE_PROFILES=stepca $(COMPOSE_CMD) $(COMPOSE_OPTS) rm -f step-ca || true

# Bootstrap step-ca server
stepca-bootstrap: stepca-up
	@echo "Bootstrapping Step-CA server..."
	@if [ -z "$(STEP_CA_ADMIN_PROVISIONER_PASSWORD)" ] || [ -z "$(STEP_CA_PASSWORD)" ]; then echo "Error: STEP_CA_ADMIN_PROVISIONER_PASSWORD or STEP_CA_PASSWORD not set in .env. Aborting."; exit 1; fi
	./scripts/stepca-bootstrap.sh

# Install Step-CA root CA into Ubuntu trust store
stepca-trust-install:
	@echo "Installing Step-CA root CA into system trust store..."
	./scripts/stepca-trust-install.sh

# Remove Step-CA root CA from Ubuntu trust store
stepca-trust-uninstall:
	@echo "Removing Step-CA root CA from system trust store..."
	./scripts/stepca-trust-uninstall.sh

# Verify Step-CA root CA is trusted by Ubuntu
stepca-trust-verify:
	@echo "Verifying Step-CA root CA trust..."
	./scripts/stepca-trust-verify.sh

# --- Testing ---

test:
	@echo "Running smoke tests..."
	./scripts/healthcheck.sh

# --- Documentation ---

docs-check:
	@echo "Validating multilingual README structure..."
	./scripts/docs-check.sh

# --- Hosts Subdomain Mapper ---

hosts-generate:
	./scripts/hosts-subdomains.sh $(HOSTS_ENV_ARGS) generate

hosts-apply:
	@echo "Applying hosts block (sudo may be required for /etc/hosts)..."
	./scripts/hosts-subdomains.sh $(HOSTS_ENV_ARGS) apply

hosts-remove:
	@echo "Removing hosts block (sudo may be required for /etc/hosts)..."
	./scripts/hosts-subdomains.sh $(HOSTS_ENV_ARGS) remove

hosts-status:
	./scripts/hosts-subdomains.sh $(HOSTS_ENV_ARGS) status

# --- DNS Service ---

dns-up:
	@echo "Starting DNS service (profile: dns)..."
	COMPOSE_PROFILES=dns ./scripts/compose.sh --profile dns $(COMPOSE_OPTS) up -d dns

dns-down:
	@echo "Stopping DNS service..."
	COMPOSE_PROFILES=dns ./scripts/compose.sh --profile dns $(COMPOSE_OPTS) stop dns || true
	COMPOSE_PROFILES=dns ./scripts/compose.sh --profile dns $(COMPOSE_OPTS) rm -f dns || true

dns-logs:
	@echo "Showing DNS service logs..."
	COMPOSE_PROFILES=dns ./scripts/compose.sh --profile dns $(COMPOSE_OPTS) logs -f dns

dns-status:
	@echo "DNS service status:"
	COMPOSE_PROFILES=dns ./scripts/compose.sh --profile dns $(COMPOSE_OPTS) ps dns

dns-provision:
	./scripts/dns-provision.sh $(DNS_ENV_ARGS)

dns-provision-dry:
	./scripts/dns-provision.sh $(DNS_ENV_ARGS) --dry-run

dns-config-apply:
	./scripts/dns-configure-ubuntu.sh $(DNS_ENV_ARGS) apply

dns-config-remove:
	./scripts/dns-configure-ubuntu.sh $(DNS_ENV_ARGS) remove

dns-config-status:
	./scripts/dns-configure-ubuntu.sh $(DNS_ENV_ARGS) status

# --- Help ---

help:
	@echo ""
	@echo "Docker Compose Traefik Edge Stack - Makefile Help"
	@echo ""
	@echo "Usage:"
	@echo "  make <target>"
	@echo "  COMPOSE_PROFILES=<profile1,profile2> make <target>"
	@echo ""
	@echo "General Commands:"
	@echo "  help                  Display this help message."
	@echo "  bootstrap             Create .env with random secrets and required directories."
	@echo "  up                    Start the default stack (Traefik + whoami)."
	@echo "  down                  Stop and remove the default stack."
	@echo "  restart               Restart the default stack."
	@echo "  logs                  Follow logs for all running services."
	@echo "  ps                    List services in the stack."
	@echo ""
	@echo "Certificate Management (Mode A: Local Self-Signed):"
	@echo "  certs-local           Generate local self-signed certificates in $(CERTS_DIR)/local/."
	@echo "  local-ca-trust-install  Install local CA into Ubuntu trust store (requires sudo)."
	@echo "  local-ca-trust-uninstall Remove local CA from Ubuntu trust store (requires sudo)."
	@echo "  local-ca-trust-verify   Verify local CA trust on Ubuntu."
	@echo ""
	@echo "Certificate Management (Mode B: Let's Encrypt with Certbot):"
	@echo "  certs-le-issue        Issue a new Let's Encrypt certificate using certbot (requires 'le' profile)."
	@echo "                        Requires ACME_EMAIL in .env. Run 'COMPOSE_PROFILES=le make up' first."
	@echo "  certs-le-renew        Renew existing Let's Encrypt certificates (requires 'le' profile)."
	@echo "                        Run 'COMPOSE_PROFILES=le make up' first."
	@echo ""
	@echo "Certificate Management (Mode C: Step-CA):"
	@echo "  stepca-up             Start the Step-CA service (activates 'stepca' profile)."
	@echo "  stepca-down           Stop and remove the Step-CA container."
	@echo "  stepca-bootstrap      Initialize and bootstrap the Step-CA server (requires 'stepca' profile)."
	@echo "                        Requires STEP_CA_ADMIN_PROVISIONER_PASSWORD and STEP_CA_PASSWORD in .env."
	@echo "  stepca-trust-install  Install Step-CA root CA into Ubuntu trust store (requires sudo)."
	@echo "  stepca-trust-uninstall Remove Step-CA root CA from Ubuntu trust store (requires sudo)."
	@echo "  stepca-trust-verify   Verify Step-CA root CA trust on Ubuntu."
	@echo ""
	@echo "Testing:"
	@echo "  test                  Run all smoke tests for the current configuration."
	@echo ""
	@echo "Docs:"
	@echo "  docs-check            Validate multilingual README structure and links."
	@echo ""
	@echo "Hosts Subdomain Mapper:"
	@echo "  hosts-generate        Print the managed hosts block."
	@echo "  hosts-apply           Insert or update the managed hosts block."
	@echo "  hosts-remove          Remove the managed hosts block."
	@echo "  hosts-status          Show whether the managed block exists."
	@echo ""
	@echo "DNS Service:"
	@echo "  dns-up                Start the DNS service (profile: dns)."
	@echo "  dns-down              Stop and remove the DNS container."
	@echo "  dns-logs              Follow DNS service logs."
	@echo "  dns-status            Show DNS service status."
	@echo "  dns-provision         Provision DNS records via API."
	@echo "  dns-provision-dry      Dry-run DNS provisioning."
	@echo "  dns-config-apply      Configure Ubuntu split-DNS (requires sudo)."
	@echo "  dns-config-remove     Remove Ubuntu split-DNS config (requires sudo)."
	@echo "  dns-config-status     Show Ubuntu split-DNS status."
	@echo ""
	@echo "Profiles:"
	@echo "  Use COMPOSE_PROFILES=<profile_name> before make commands to activate profiles."
	@echo "  Available profiles: le, stepca"
	@echo "  Example: COMPOSE_PROFILES=le make up"
	@echo ""
