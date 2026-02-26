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
.PHONY: help up down restart logs ps test test-core test-dns test-awx test-ctfd test-observability test-plane test-docling test-freeipa test-webui docs-check bootstrap \
        certs-local local-ca-trust-install local-ca-trust-uninstall local-ca-trust-verify \
        certs-le-issue certs-le-renew \
        stepca-up stepca-down stepca-bootstrap stepca-verify-cert \
        stepca-trust-install stepca-trust-uninstall stepca-trust-verify \
        hosts-generate hosts-apply hosts-remove hosts-status \
        bind-up bind-down bind-restart bind-logs bind-status bind-provision bind-provision-dry \
        awx-bootstrap awx-k3d-up awx-k3d-down awx-up awx-down awx-status awx-logs awx-admin-password awx-debug awx-backup awx-restore awx-upgrade \
        ctfd-bootstrap ctfd-up ctfd-down ctfd-restart ctfd-logs ctfd-status \
        observability-bootstrap observability-up observability-down observability-restart observability-logs observability-status observability-k6 \
        plane-bootstrap plane-up plane-down plane-restart plane-logs plane-status \
        docling-bootstrap docling-up docling-down docling-restart docling-logs docling-status \
        freeipa-bootstrap freeipa-up freeipa-down freeipa-restart freeipa-logs freeipa-status \
        webui-up webui-down webui-restart webui-logs webui-status

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
  -f services/keycloak/compose.yml \
  -f services/dns-bind/compose.yml \
  -f services/certbot/compose.yml \
  -f services/step-ca/compose.yml \
  -f services/ctfd/compose.yml \
  -f services/observability/compose.yml \
  -f services/plane/compose.yml \
  -f services/docling/compose.yml \
  -f services/freeipa/compose.yml \
  -f services/openwebui/compose.yml

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

AWX_ENV_ARGS :=
ifneq ($(ENV_FILE),)
AWX_ENV_ARGS += --env-file $(ENV_FILE)
endif

CTFD_ENV_ARGS :=
ifneq ($(ENV_FILE),)
CTFD_ENV_ARGS += --env-file $(ENV_FILE)
endif

OBS_ENV_ARGS :=
ifneq ($(ENV_FILE),)
OBS_ENV_ARGS += --env-file $(ENV_FILE)
endif

PLANE_ENV_ARGS :=
ifneq ($(ENV_FILE),)
PLANE_ENV_ARGS += --env-file $(ENV_FILE)
endif

DOCLING_ENV_ARGS :=
ifneq ($(ENV_FILE),)
DOCLING_ENV_ARGS += --env-file $(ENV_FILE)
endif

FREEIPA_ENV_ARGS :=
ifneq ($(ENV_FILE),)
FREEIPA_ENV_ARGS += --env-file $(ENV_FILE)
endif

SMOKE_TEST_DIR := $(REPO_ROOT)/tests/smoke

CORE_SMOKE_TESTS := \
	test_traefik_ready.sh \
	test_routing.sh \
	test_tls_handshake.sh \
	test_http_redirect.sh \
	test_hosts_subdomains.sh

DNS_SMOKE_TESTS := \
	test_bind_service_config.sh \
	test_bind_zone_generation.sh \
	test_bind_make_targets.sh \
	test_bind_guardrails.sh \
	test_bind_file_permissions.sh \
	test_bind_provisioning_validation.sh \
	test_bind_security_runtime.sh

AWX_SMOKE_TESTS := \
	test_awx_make_targets.sh \
	test_awx_guardrails.sh \
	test_awx_k8s_templates.sh \
	test_awx_traefik_routing_config.sh \
	test_awx_day2_make_targets.sh \
	test_awx_day2_confirmation.sh

CTFD_SMOKE_TESTS := \
	test_ctfd_service_config.sh \
	test_ctfd_guardrails.sh \
	test_ctfd_make_targets.sh \
	test_ctfd_bootstrap_env.sh

OBSERVABILITY_SMOKE_TESTS := \
	test_observability_service_config.sh \
	test_observability_advanced_service_config.sh \
	test_observability_alloy_signal_pipelines.sh \
	test_observability_traefik_config.sh \
	test_observability_guardrails.sh \
	test_observability_make_targets.sh \
	test_observability_bootstrap_env.sh \
	test_observability_grafana_provisioning.sh \
	test_observability_k6_wiring.sh \
	test_observability_app_pack_tolerance.sh

PLANE_SMOKE_TESTS := \
	test_plane_service_config.sh \
	test_plane_guardrails.sh \
	test_plane_make_targets.sh \
	test_plane_bootstrap_env.sh \
	test_plane_optional_integrations.sh

DOCLING_SMOKE_TESTS := \
	test_docling_service_config.sh \
	test_docling_guardrails.sh \
	test_docling_make_targets.sh \
	test_docling_bootstrap_env.sh \
	test_docling_optional_integrations.sh

FREEIPA_SMOKE_TESTS := \
	test_freeipa_service_config.sh \
	test_freeipa_guardrails.sh \
	test_freeipa_make_targets.sh \
	test_freeipa_bootstrap_env.sh \
	test_freeipa_optional_integrations.sh

WEBUI_SMOKE_TESTS := \
	test_openwebui_service_config.sh \
	test_openwebui_make_targets.sh

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
	mkdir -p shared/certs shared/certs/local-ca shared/certs/local services/n8n/rendered

bootstrap-full:
	@echo "Bootstrapping local environment (.env and directories) with full defaults..."
	./scripts/env-generate.sh --mode=full
	mkdir -p shared/certs shared/certs/local-ca shared/certs/local services/n8n/rendered

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

test-core:
	@echo "Running core Traefik/whoami smoke tests..."
	@set -euo pipefail; rc=0; \
	for test_script in $(CORE_SMOKE_TESTS); do \
		echo "==> $$test_script"; \
		if ! "$(SMOKE_TEST_DIR)/$$test_script"; then \
			rc=1; \
		fi; \
	done; \
	exit $$rc

test-dns:
	@echo "Running DNS/BIND smoke tests..."
	@set -euo pipefail; rc=0; \
	for test_script in $(DNS_SMOKE_TESTS); do \
		echo "==> $$test_script"; \
		if ! "$(SMOKE_TEST_DIR)/$$test_script"; then \
			rc=1; \
		fi; \
	done; \
	exit $$rc

test-awx:
	@echo "Running AWX static smoke tests..."
	@set -euo pipefail; rc=0; \
	for test_script in $(AWX_SMOKE_TESTS); do \
		echo "==> $$test_script"; \
		if ! "$(SMOKE_TEST_DIR)/$$test_script"; then \
			rc=1; \
		fi; \
	done; \
	exit $$rc

test-ctfd:
	@echo "Running CTFd smoke tests..."
	@set -euo pipefail; rc=0; \
	for test_script in $(CTFD_SMOKE_TESTS); do \
		echo "==> $$test_script"; \
		if ! "$(SMOKE_TEST_DIR)/$$test_script"; then \
			rc=1; \
		fi; \
	done; \
	exit $$rc

test-observability:
	@echo "Running observability smoke tests..."
	@set -euo pipefail; rc=0; \
	for test_script in $(OBSERVABILITY_SMOKE_TESTS); do \
		echo "==> $$test_script"; \
		if ! "$(SMOKE_TEST_DIR)/$$test_script"; then \
			rc=1; \
		fi; \
	done; \
	exit $$rc

test-plane:
	@echo "Running Plane smoke tests..."
	@set -euo pipefail; rc=0; \
	for test_script in $(PLANE_SMOKE_TESTS); do \
		echo "==> $$test_script"; \
		if ! "$(SMOKE_TEST_DIR)/$$test_script"; then \
			rc=1; \
		fi; \
	done; \
	exit $$rc

test-docling:
	@echo "Running Docling smoke tests..."
	@set -euo pipefail; rc=0; \
	for test_script in $(DOCLING_SMOKE_TESTS); do \
		echo "==> $$test_script"; \
		if ! "$(SMOKE_TEST_DIR)/$$test_script"; then \
			rc=1; \
		fi; \
	done; \
	exit $$rc

test-freeipa:
	@echo "Running FreeIPA smoke tests..."
	@set -euo pipefail; rc=0; \
	for test_script in $(FREEIPA_SMOKE_TESTS); do \
		echo "==> $$test_script"; \
		if ! "$(SMOKE_TEST_DIR)/$$test_script"; then \
			rc=1; \
		fi; \
	done; \
	exit $$rc

test-webui:
	@echo "Running OpenWebUI smoke tests..."
	@set -euo pipefail; rc=0; \
	for test_script in $(WEBUI_SMOKE_TESTS); do \
		echo "==> $$test_script"; \
		if ! "$(SMOKE_TEST_DIR)/$$test_script"; then \
			rc=1; \
		fi; \
	done; \
	exit $$rc

# --- Documentation ---

docs-check:
	@echo "Validating multilingual README structure..."
	./scripts/docs-check.sh

# --- n8n (optional profile: n8n) ---

n8n-bootstrap:
	@echo "Rendering n8n runtime config and optional integration runbooks..."
	./scripts/n8n-bootstrap.sh

n8n-up: n8n-bootstrap
	@echo "Starting n8n service (profile: n8n)..."
	COMPOSE_PROFILES=n8n "$(SCRIPTS_DIR)/compose.sh" --profile n8n $(COMPOSE_OPTS) up -d n8n n8n-db

n8n-down:
	@echo "Stopping n8n service..."
	COMPOSE_PROFILES=n8n "$(SCRIPTS_DIR)/compose.sh" --profile n8n $(COMPOSE_OPTS) stop n8n n8n-db || true
	COMPOSE_PROFILES=n8n "$(SCRIPTS_DIR)/compose.sh" --profile n8n $(COMPOSE_OPTS) rm -f n8n n8n-db || true

n8n-restart: n8n-down n8n-up

n8n-logs:
	@echo "Showing n8n logs..."
	COMPOSE_PROFILES=n8n "$(SCRIPTS_DIR)/compose.sh" --profile n8n $(COMPOSE_OPTS) logs -f n8n n8n-db

n8n-status:
	@echo "n8n service status:"
	COMPOSE_PROFILES=n8n "$(SCRIPTS_DIR)/compose.sh" --profile n8n $(COMPOSE_OPTS) ps n8n n8n-db

test-n8n:
	@echo "Running n8n static smoke tests..."
	./tests/smoke/test_n8n_make_targets.sh
	./tests/smoke/test_n8n_compose_wiring.sh
	./tests/smoke/test_n8n_guardrails.sh
	./tests/smoke/test_n8n_render_config.sh

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

# --- AWX (k3d + AWX Operator) Hybrid Module ---

awx-bootstrap:
	"$(SCRIPTS_DIR)/awx-bootstrap.sh" $(AWX_ENV_ARGS)

awx-k3d-up:
	@echo "Creating/ensuring local k3d cluster for AWX..."
	"$(SCRIPTS_DIR)/awx-k3d-up.sh" $(AWX_ENV_ARGS)

awx-k3d-down:
	@echo "Deleting local k3d cluster for AWX..."
	"$(SCRIPTS_DIR)/awx-k3d-down.sh" $(AWX_ENV_ARGS)

awx-up:
	@echo "Deploying/updating AWX (operator + instance) on k3d..."
	@echo "Note: Traefik should be running (make up) to access https://$${AWX_HOSTNAME:-awx}.$${DEV_DOMAIN}"
	"$(SCRIPTS_DIR)/awx-up.sh" $(AWX_ENV_ARGS)

awx-down:
	@echo "Deleting AWX instance (cluster is kept)..."
	"$(SCRIPTS_DIR)/awx-down.sh" $(AWX_ENV_ARGS)

awx-status:
	@echo "AWX/k3d status:"
	"$(SCRIPTS_DIR)/awx-status.sh" $(AWX_ENV_ARGS)

awx-logs:
	@echo "AWX logs (default: list pods; pass ROLE=<operator|web|task> for convenience)..."
	"$(SCRIPTS_DIR)/awx-logs.sh" $(AWX_ENV_ARGS) $(if $(ROLE),$(ROLE),)

awx-admin-password:
	@echo "AWX admin password from Kubernetes secret:"
	"$(SCRIPTS_DIR)/awx-admin-password.sh" $(AWX_ENV_ARGS)

awx-debug:
	@echo "Collecting AWX debug bundle..."
	"$(SCRIPTS_DIR)/awx-debug.sh" $(AWX_ENV_ARGS)

awx-backup:
	@echo "Creating AWX backup (operator-managed AWXBackup CR + local metadata bundle)..."
	"$(SCRIPTS_DIR)/awx-backup.sh" $(AWX_ENV_ARGS)

awx-restore:
	@echo "Restoring AWX from an operator-managed backup (requires explicit confirmation)..."
	"$(SCRIPTS_DIR)/awx-restore.sh" $(AWX_ENV_ARGS) $(AWX_RESTORE_ARGS)

awx-upgrade:
	@echo "Upgrading AWX/operator (requires explicit confirmation)..."
	"$(SCRIPTS_DIR)/awx-upgrade.sh" $(AWX_ENV_ARGS) $(AWX_UPGRADE_ARGS)

# --- CTFd Module ---

ctfd-bootstrap:
	"$(SCRIPTS_DIR)/ctfd-bootstrap.sh" $(CTFD_ENV_ARGS)

ctfd-up:
	@echo "Starting CTFd module (profile: ctfd)..."
	COMPOSE_PROFILES=ctfd "$(SCRIPTS_DIR)/compose.sh" --profile ctfd $(COMPOSE_OPTS) up -d ctfd ctfd-db ctfd-redis

ctfd-down:
	@echo "Stopping CTFd module..."
	COMPOSE_PROFILES=ctfd "$(SCRIPTS_DIR)/compose.sh" --profile ctfd $(COMPOSE_OPTS) stop ctfd ctfd-db ctfd-redis || true
	COMPOSE_PROFILES=ctfd "$(SCRIPTS_DIR)/compose.sh" --profile ctfd $(COMPOSE_OPTS) rm -f ctfd ctfd-db ctfd-redis || true

ctfd-restart: ctfd-down ctfd-up

ctfd-logs:
	@echo "Showing CTFd module logs..."
	COMPOSE_PROFILES=ctfd "$(SCRIPTS_DIR)/compose.sh" --profile ctfd $(COMPOSE_OPTS) logs -f ctfd ctfd-db ctfd-redis

ctfd-status:
	@echo "CTFd module status:"
	COMPOSE_PROFILES=ctfd "$(SCRIPTS_DIR)/compose.sh" --profile ctfd $(COMPOSE_OPTS) ps ctfd ctfd-db ctfd-redis

# --- Observability Module ---

observability-bootstrap:
	"$(SCRIPTS_DIR)/observability-bootstrap.sh" $(OBS_ENV_ARGS)

observability-up:
	@echo "Starting observability module (profile: observability)..."
	COMPOSE_PROFILES=observability "$(SCRIPTS_DIR)/compose.sh" --profile observability $(COMPOSE_OPTS) up -d grafana prometheus loki tempo pyroscope alloy

observability-down:
	@echo "Stopping observability module..."
	COMPOSE_PROFILES=observability "$(SCRIPTS_DIR)/compose.sh" --profile observability $(COMPOSE_OPTS) stop grafana prometheus loki tempo pyroscope alloy || true
	COMPOSE_PROFILES=observability "$(SCRIPTS_DIR)/compose.sh" --profile observability $(COMPOSE_OPTS) rm -f grafana prometheus loki tempo pyroscope alloy || true

observability-restart: observability-down observability-up

observability-logs:
	@echo "Showing observability module logs..."
	COMPOSE_PROFILES=observability "$(SCRIPTS_DIR)/compose.sh" --profile observability $(COMPOSE_OPTS) logs -f grafana prometheus loki tempo pyroscope alloy

observability-status:
	@echo "Observability module status:"
	COMPOSE_PROFILES=observability "$(SCRIPTS_DIR)/compose.sh" --profile observability $(COMPOSE_OPTS) ps grafana prometheus loki tempo pyroscope alloy

observability-k6:
	@if [ -z "$(K6_TARGET_URL)" ]; then echo "Error: K6_TARGET_URL is required."; exit 1; fi
	@echo "Running observability synthetic check with k6 against $(K6_TARGET_URL)..."
	COMPOSE_PROFILES=observability "$(SCRIPTS_DIR)/compose.sh" --profile observability $(COMPOSE_OPTS) run --rm k6

# --- Plane Module ---

plane-bootstrap:
	"$(SCRIPTS_DIR)/plane-bootstrap.sh" $(PLANE_ENV_ARGS)

plane-up:
	@echo "Starting Plane module (profile: plane)..."
	COMPOSE_PROFILES=plane "$(SCRIPTS_DIR)/compose.sh" --profile plane $(COMPOSE_OPTS) up -d plane-web plane-space plane-admin plane-live plane-api plane-worker plane-beat-worker plane-migrator plane-db plane-redis plane-mq plane-minio

plane-down:
	@echo "Stopping Plane module..."
	COMPOSE_PROFILES=plane "$(SCRIPTS_DIR)/compose.sh" --profile plane $(COMPOSE_OPTS) stop plane-web plane-space plane-admin plane-live plane-api plane-worker plane-beat-worker plane-migrator plane-db plane-redis plane-mq plane-minio || true
	COMPOSE_PROFILES=plane "$(SCRIPTS_DIR)/compose.sh" --profile plane $(COMPOSE_OPTS) rm -f plane-web plane-space plane-admin plane-live plane-api plane-worker plane-beat-worker plane-migrator plane-db plane-redis plane-mq plane-minio || true

plane-restart: plane-down plane-up

plane-logs:
	@echo "Showing Plane module logs..."
	COMPOSE_PROFILES=plane "$(SCRIPTS_DIR)/compose.sh" --profile plane $(COMPOSE_OPTS) logs -f plane-web plane-space plane-admin plane-live plane-api plane-worker plane-beat-worker plane-migrator plane-db plane-redis plane-mq plane-minio

plane-status:
	@echo "Plane module status:"
	COMPOSE_PROFILES=plane "$(SCRIPTS_DIR)/compose.sh" --profile plane $(COMPOSE_OPTS) ps plane-web plane-space plane-admin plane-live plane-api plane-worker plane-beat-worker plane-migrator plane-db plane-redis plane-mq plane-minio

# --- Docling Module ---

docling-bootstrap:
	"$(SCRIPTS_DIR)/docling-bootstrap.sh" $(DOCLING_ENV_ARGS)

docling-up:
	@echo "Starting Docling module (profile: docling)..."
	COMPOSE_PROFILES=docling "$(SCRIPTS_DIR)/compose.sh" --profile docling $(COMPOSE_OPTS) up -d docling docling-redis

docling-down:
	@echo "Stopping Docling module..."
	COMPOSE_PROFILES=docling "$(SCRIPTS_DIR)/compose.sh" --profile docling $(COMPOSE_OPTS) stop docling docling-redis || true
	COMPOSE_PROFILES=docling "$(SCRIPTS_DIR)/compose.sh" --profile docling $(COMPOSE_OPTS) rm -f docling docling-redis || true

docling-restart: docling-down docling-up

docling-logs:
	@echo "Showing Docling module logs..."
	COMPOSE_PROFILES=docling "$(SCRIPTS_DIR)/compose.sh" --profile docling $(COMPOSE_OPTS) logs -f docling docling-redis

docling-status:
	@echo "Docling module status:"
	COMPOSE_PROFILES=docling "$(SCRIPTS_DIR)/compose.sh" --profile docling $(COMPOSE_OPTS) ps docling docling-redis

# --- FreeIPA Module ---

freeipa-bootstrap:
	"$(SCRIPTS_DIR)/freeipa-bootstrap.sh" $(FREEIPA_ENV_ARGS)

freeipa-up:
	@echo "Starting FreeIPA module (profile: freeipa)..."
	COMPOSE_PROFILES=freeipa "$(SCRIPTS_DIR)/compose.sh" --profile freeipa $(COMPOSE_OPTS) up -d freeipa

freeipa-down:
	@echo "Stopping FreeIPA module..."
	COMPOSE_PROFILES=freeipa "$(SCRIPTS_DIR)/compose.sh" --profile freeipa $(COMPOSE_OPTS) stop freeipa || true
	COMPOSE_PROFILES=freeipa "$(SCRIPTS_DIR)/compose.sh" --profile freeipa $(COMPOSE_OPTS) rm -f freeipa || true

freeipa-restart: freeipa-down freeipa-up

freeipa-logs:
	@echo "Showing FreeIPA module logs..."
	COMPOSE_PROFILES=freeipa "$(SCRIPTS_DIR)/compose.sh" --profile freeipa $(COMPOSE_OPTS) logs -f freeipa

freeipa-status:
	@echo "FreeIPA module status:"
	COMPOSE_PROFILES=freeipa "$(SCRIPTS_DIR)/compose.sh" --profile freeipa $(COMPOSE_OPTS) ps freeipa

# --- OpenWebUI Module ---

webui-up:
	@echo "Starting OpenWebUI module (profile: webui)..."
	COMPOSE_PROFILES=webui "$(SCRIPTS_DIR)/compose.sh" --profile webui $(COMPOSE_OPTS) up -d openwebui

webui-down:
	@echo "Stopping OpenWebUI module..."
	COMPOSE_PROFILES=webui "$(SCRIPTS_DIR)/compose.sh" --profile webui $(COMPOSE_OPTS) stop openwebui || true
	COMPOSE_PROFILES=webui "$(SCRIPTS_DIR)/compose.sh" --profile webui $(COMPOSE_OPTS) rm -f openwebui || true

webui-restart: webui-down webui-up

webui-logs:
	@echo "Showing OpenWebUI module logs..."
	COMPOSE_PROFILES=webui "$(SCRIPTS_DIR)/compose.sh" --profile webui $(COMPOSE_OPTS) logs -f openwebui

webui-status:
	@echo "OpenWebUI module status:"
	COMPOSE_PROFILES=webui "$(SCRIPTS_DIR)/compose.sh" --profile webui $(COMPOSE_OPTS) ps openwebui

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
	@echo "  test                  Run smoke tests for running services (plus common utility tests)."
	@echo "  test-core             Run core Traefik/whoami smoke tests."
	@echo "  test-dns              Run DNS/BIND smoke tests only."
	@echo "  test-awx              Run AWX static smoke tests only."
	@echo "  test-ctfd             Run CTFd smoke tests only."
	@echo "  test-observability    Run observability smoke tests only."
	@echo "  test-plane            Run Plane smoke tests only."
	@echo "  test-docling          Run Docling smoke tests only."
	@echo "  test-freeipa          Run FreeIPA smoke tests only."
	@echo "  test-webui            Run OpenWebUI smoke tests only."
	@echo ""
	@echo "Docs:"
	@echo "  docs-check            Validate multilingual README structure and links."
	@echo ""
	@echo "n8n:"
	@echo "  n8n-bootstrap         Render n8n runtime config and optional integration runbooks."
	@echo "  n8n-up                Start n8n + PostgreSQL (profile: n8n)."
	@echo "  n8n-down              Stop and remove n8n containers."
	@echo "  n8n-restart           Restart n8n (n8n-down + n8n-up)."
	@echo "  n8n-logs              Follow n8n and PostgreSQL logs."
	@echo "  n8n-status            Show n8n service status."
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
	@echo "AWX (k3d hybrid module):"
	@echo "  awx-bootstrap         Generate/persist AWX bootstrap secrets and defaults in .env."
	@echo "  awx-k3d-up            Create/ensure local k3d cluster for AWX."
	@echo "  awx-k3d-down          Delete the local AWX k3d cluster."
	@echo "  awx-up                Install/upgrade AWX Operator and apply AWX instance on k3d."
	@echo "  awx-down              Delete the AWX instance (keeps the cluster)."
	@echo "  awx-status            Show AWX/operator resources and pod status."
	@echo "  awx-logs              Show AWX/operator logs (optional ROLE=operator|web|task)."
	@echo "  awx-admin-password    Print the AWX admin password from the Kubernetes secret."
	@echo "  awx-debug             Collect a local AWX debug bundle under .local/awx/debug/."
	@echo "  awx-backup            Create AWXBackup CR and save local backup metadata bundle."
	@echo "  awx-restore           Restore from backup (pass AWX_RESTORE_ARGS='--backup-name ... --confirm')."
	@echo "  awx-upgrade           Upgrade/reapply AWX (pass AWX_UPGRADE_ARGS='--confirm ...')."
	@echo ""
	@echo "CTFd:"
	@echo "  ctfd-bootstrap        Generate/persist CTFd secrets in .env."
	@echo "  ctfd-up               Start the CTFd module (profile: ctfd)."
	@echo "  ctfd-down             Stop and remove the CTFd module containers."
	@echo "  ctfd-restart          Restart the CTFd module."
	@echo "  ctfd-logs             Follow CTFd module logs."
	@echo "  ctfd-status           Show CTFd module status."
	@echo ""
	@echo "Observability:"
	@echo "  observability-bootstrap  Generate/persist Grafana admin secrets in .env."
	@echo "  observability-up         Start the observability module (profile: observability)."
	@echo "  observability-down       Stop and remove observability module containers."
	@echo "  observability-restart    Restart the observability module."
	@echo "  observability-logs       Follow observability module logs."
	@echo "  observability-status     Show observability module status."
	@echo "  observability-k6         Run on-demand synthetic HTTP checks with k6."
	@echo ""
	@echo "Plane:"
	@echo "  plane-bootstrap          Generate/persist Plane secrets in .env."
	@echo "  plane-up                 Start the Plane module (profile: plane)."
	@echo "  plane-down               Stop and remove Plane module containers."
	@echo "  plane-restart            Restart the Plane module."
	@echo "  plane-logs               Follow Plane module logs."
	@echo "  plane-status             Show Plane module status."
	@echo ""
	@echo "Docling:"
	@echo "  docling-bootstrap        Generate/persist Docling secrets in .env."
	@echo "  docling-up               Start the Docling module (profile: docling)."
	@echo "  docling-down             Stop and remove Docling module containers."
	@echo "  docling-restart          Restart the Docling module."
	@echo "  docling-logs             Follow Docling module logs."
	@echo "  docling-status           Show Docling module status."
	@echo ""
	@echo "FreeIPA:"
	@echo "  freeipa-bootstrap        Generate/persist FreeIPA secrets in .env."
	@echo "  freeipa-up               Start the FreeIPA module (profile: freeipa)."
	@echo "  freeipa-down             Stop and remove FreeIPA module containers."
	@echo "  freeipa-restart          Restart the FreeIPA module."
	@echo "  freeipa-logs             Follow FreeIPA module logs."
	@echo "  freeipa-status           Show FreeIPA module status."
	@echo ""
	@echo "OpenWebUI:"
	@echo "  webui-up                 Start the OpenWebUI module (profile: webui)."
	@echo "  webui-down               Stop and remove OpenWebUI module containers."
	@echo "  webui-restart            Restart the OpenWebUI module."
	@echo "  webui-logs               Follow OpenWebUI module logs."
	@echo "  webui-status             Show OpenWebUI module status."
	@echo ""
	@echo "Profiles:"
	@echo "  Use COMPOSE_PROFILES=<profile_name> before make commands to activate profiles."
	@echo "  Available profiles: bind, ctfd, docling, freeipa, le, observability, plane, stepca, webui"
	@echo "  Example: COMPOSE_PROFILES=le make up"
	@echo ""
