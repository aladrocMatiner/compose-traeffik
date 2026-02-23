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
        bind-up bind-down bind-restart bind-logs bind-status bind-provision bind-provision-dry \
        wg-up wg-down wg-restart wg-logs wg-status wg-bootstrap

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
  -f services/dns-bind/compose.yml \
  -f services/certbot/compose.yml \
  -f services/step-ca/compose.yml \
  -f services/wg-easy/compose.yml

# Pin compose project directory/name to avoid cross-CWD conflicts.
COMPOSE_PROJECT_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
REPO_ROOT := $(abspath $(COMPOSE_PROJECT_DIR))
SCRIPTS_DIR := $(REPO_ROOT)/scripts
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

BIND_ENV_ARGS :=
ifneq ($(ENV_FILE),)
BIND_ENV_ARGS += --env-file $(ENV_FILE)
endif

WG_BOOTSTRAP_ARGS ?=

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
	./scripts/env-generate.sh --mode=prod
	mkdir -p shared/certs shared/certs/local-ca shared/certs/local

bootstrap-full:
	@echo "Bootstrapping local environment (.env and directories) with full defaults..."
	./scripts/env-generate.sh --mode=full
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

# --- Bind DNS Provisioning ---

bind-up:
	@echo "Starting BIND service (profile: bind)..."
	COMPOSE_PROFILES=bind "$(SCRIPTS_DIR)/compose.sh" --profile bind $(COMPOSE_OPTS) up -d bind

bind-down:
	@echo "Stopping BIND service..."
	COMPOSE_PROFILES=bind "$(SCRIPTS_DIR)/compose.sh" --profile bind $(COMPOSE_OPTS) stop bind || true
	COMPOSE_PROFILES=bind "$(SCRIPTS_DIR)/compose.sh" --profile bind $(COMPOSE_OPTS) rm -f bind || true

bind-restart: bind-down bind-up

bind-logs:
	@echo "Showing BIND service logs..."
	COMPOSE_PROFILES=bind "$(SCRIPTS_DIR)/compose.sh" --profile bind $(COMPOSE_OPTS) logs -f bind

bind-status:
	@echo "BIND service status:"
	COMPOSE_PROFILES=bind "$(SCRIPTS_DIR)/compose.sh" --profile bind $(COMPOSE_OPTS) ps bind

bind-provision:
	"$(SCRIPTS_DIR)/bind-provision.sh" $(BIND_ENV_ARGS)

bind-provision-dry:
	"$(SCRIPTS_DIR)/bind-provision.sh" $(BIND_ENV_ARGS) --dry-run

# --- WireGuard (wg-easy) ---

wg-up:
	@echo "Starting wg-easy service (profile: wg)..."
	COMPOSE_PROFILES=wg "$(SCRIPTS_DIR)/compose.sh" --profile wg $(COMPOSE_OPTS) up -d wg-easy

wg-down:
	@echo "Stopping wg-easy service..."
	COMPOSE_PROFILES=wg "$(SCRIPTS_DIR)/compose.sh" --profile wg $(COMPOSE_OPTS) stop wg-easy || true
	COMPOSE_PROFILES=wg "$(SCRIPTS_DIR)/compose.sh" --profile wg $(COMPOSE_OPTS) rm -f wg-easy || true

wg-restart: wg-down wg-up

wg-logs:
	@echo "Showing wg-easy service logs..."
	COMPOSE_PROFILES=wg "$(SCRIPTS_DIR)/compose.sh" --profile wg $(COMPOSE_OPTS) logs -f wg-easy

wg-status:
	@echo "wg-easy service status:"
	COMPOSE_PROFILES=wg "$(SCRIPTS_DIR)/compose.sh" --profile wg $(COMPOSE_OPTS) ps wg-easy

wg-bootstrap:
	@echo "Bootstrapping wg-easy admin variables in .env..."
	./scripts/wg-bootstrap.sh $(WG_BOOTSTRAP_ARGS)

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
	@echo "  bootstrap             Create .env with production-minimal defaults and required directories."
	@echo "  bootstrap-full        Create .env with full defaults and required directories."
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
	@echo "Bind DNS:"
	@echo "  bind-up               Start the BIND service (profile: bind)."
	@echo "  bind-down             Stop and remove the BIND containers."
	@echo "  bind-restart          Restart the BIND service (bind-down + bind-up)."
	@echo "  bind-logs             Follow BIND service logs."
	@echo "  bind-status           Show BIND service status."
	@echo "  bind-provision        Generate the BIND zone file from ENDPOINTS."
	@echo "  bind-provision-dry    Print the generated zone file without writing."
	@echo ""
	@echo "WireGuard (wg-easy):"
	@echo "  wg-bootstrap         Generate/persist wg-easy admin bootstrap variables in .env."
	@echo "                      Use WG_BOOTSTRAP_ARGS=--force to rotate supported values."
	@echo "  wg-up                Start the wg-easy service (profile: wg)."
	@echo "  wg-down              Stop and remove the wg-easy container."
	@echo "  wg-restart           Restart the wg-easy service (wg-down + wg-up)."
	@echo "  wg-logs              Follow wg-easy service logs."
	@echo "  wg-status            Show wg-easy service status."
	@echo ""
	@echo "Profiles:"
	@echo "  Use COMPOSE_PROFILES=<profile_name> before make commands to activate profiles."
	@echo "  Available profiles: bind, le, stepca, wg"
	@echo "  Example: COMPOSE_PROFILES=le make up"
	@echo ""
