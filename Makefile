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
        bind-up bind-down bind-restart bind-logs bind-status bind-provision bind-provision-dry bind-port-check \
        deployment deployment-ubuntu deployment-plan deployment-destroy deployment-output deployment-ssh deployment-list deployment-list-os deployment-list-targets \
        deployment-project deployment-project-list \
        deployment-wait deployment-bootstrap deployment-bootstrap-check deployment-ready deployment-validate deployment-ansible-syntax deployment-ansible-lint \
        ubuntu debian debian12 debian13 gentoo opensuse-leap almalinux9 rockylinux9 fedora-cloud libvirt qemu proxmox

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
  -f services/step-ca/compose.yml

# Pin compose project directory/name to avoid cross-CWD conflicts.
COMPOSE_PROJECT_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
REPO_ROOT := $(abspath $(COMPOSE_PROJECT_DIR))
SCRIPTS_DIR := $(REPO_ROOT)/scripts
DEPLOYMENT_SCRIPTS_DIR := $(REPO_ROOT)/deployment/scripts
DEPLOYMENT_ANSIBLE_DIR := $(REPO_ROOT)/deployment/ansible
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

# Deployment provisioning options (libvirt/qemu + proxmox targets with multiple OS profiles)
DEPLOYMENT_TARGET ?= libvirt
DEPLOYMENT_OS ?= ubuntu
DEPLOYMENT_INIT ?=
DEPLOYMENT_NAME ?=
DEPLOYMENT_PROJECT ?=
DEPLOYMENT_PROJECT_TARGET ?= qemu
DEPLOYMENT_PROJECT_OS ?= ubuntu
DEPLOYMENT_SUPPORTED_OS_SELECTORS := ubuntu debian12 debian13 debian gentoo opensuse-leap almalinux9 rockylinux9 fedora-cloud
DEPLOYMENT_SUPPORTED_TARGET_SELECTORS := qemu

# Lowercase convenience vars (GNU Make CLI style), e.g. `make deployment os=gentoo init=openrc`
ifneq ($(strip $(target)),)
DEPLOYMENT_TARGET := $(target)
endif
ifneq ($(strip $(os)),)
DEPLOYMENT_OS := $(os)
endif
ifneq ($(strip $(init)),)
DEPLOYMENT_INIT := $(init)
endif
ifneq ($(strip $(name)),)
DEPLOYMENT_NAME := $(name)
endif
ifneq ($(strip $(project)),)
DEPLOYMENT_PROJECT := $(project)
endif
ifneq ($(strip $(project_target)),)
DEPLOYMENT_PROJECT_TARGET := $(project_target)
endif
ifneq ($(strip $(project_os)),)
DEPLOYMENT_PROJECT_OS := $(project_os)
endif
ifneq ($(strip $(target)),)
DEPLOYMENT_PROJECT_TARGET := $(target)
endif
ifneq ($(strip $(os)),)
DEPLOYMENT_PROJECT_OS := $(os)
endif

DEPLOYMENT_INIT_ARG :=
ifneq ($(strip $(DEPLOYMENT_INIT)),)
DEPLOYMENT_INIT_ARG := --init "$(DEPLOYMENT_INIT)"
endif

# Allow positional shorthand: `make deployment ubuntu`, `make deployment gentoo`, `make deployment libvirt`
ifneq (,$(filter ubuntu,$(MAKECMDGOALS)))
DEPLOYMENT_OS := ubuntu
$(eval ubuntu:;@:)
endif
ifneq (,$(filter debian,$(MAKECMDGOALS)))
DEPLOYMENT_OS := debian13
$(eval debian:;@:)
endif
ifneq (,$(filter debian13,$(MAKECMDGOALS)))
DEPLOYMENT_OS := debian13
$(eval debian13:;@:)
endif
ifneq (,$(filter debian12,$(MAKECMDGOALS)))
DEPLOYMENT_OS := debian12
$(eval debian12:;@:)
endif
ifneq (,$(filter gentoo,$(MAKECMDGOALS)))
DEPLOYMENT_OS := gentoo
$(eval gentoo:;@:)
endif
ifneq (,$(filter opensuse-leap,$(MAKECMDGOALS)))
DEPLOYMENT_OS := opensuse-leap
$(eval opensuse-leap:;@:)
endif
ifneq (,$(filter almalinux9,$(MAKECMDGOALS)))
DEPLOYMENT_OS := almalinux9
$(eval almalinux9:;@:)
endif
ifneq (,$(filter rockylinux9,$(MAKECMDGOALS)))
DEPLOYMENT_OS := rockylinux9
$(eval rockylinux9:;@:)
endif
ifneq (,$(filter fedora-cloud,$(MAKECMDGOALS)))
DEPLOYMENT_OS := fedora-cloud
$(eval fedora-cloud:;@:)
endif
ifneq (,$(filter libvirt,$(MAKECMDGOALS)))
DEPLOYMENT_TARGET := libvirt
$(eval libvirt:;@:)
endif
ifneq (,$(filter qemu,$(MAKECMDGOALS)))
DEPLOYMENT_TARGET := qemu
$(eval qemu:;@:)
endif
ifneq (,$(filter proxmox,$(MAKECMDGOALS)))
DEPLOYMENT_TARGET := proxmox
$(eval proxmox:;@:)
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
	@"$(SCRIPTS_DIR)/bind-port-check.sh"
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

bind-port-check:
	@"$(SCRIPTS_DIR)/bind-port-check.sh"

# --- VM Deployment Provisioning (Phase 1 bootstrap host) ---

deployment:
	@echo "Provisioning $(DEPLOYMENT_OS) VM on target $(DEPLOYMENT_TARGET)..."
	@"$(DEPLOYMENT_SCRIPTS_DIR)/infra-provision.sh" apply --target "$(DEPLOYMENT_TARGET)" --os "$(DEPLOYMENT_OS)" $(DEPLOYMENT_INIT_ARG)

deployment-ubuntu:
	@$(MAKE) deployment DEPLOYMENT_TARGET=libvirt DEPLOYMENT_OS=ubuntu

deployment-plan:
	@echo "Planning $(DEPLOYMENT_OS) VM on target $(DEPLOYMENT_TARGET)..."
	@"$(DEPLOYMENT_SCRIPTS_DIR)/infra-provision.sh" plan --target "$(DEPLOYMENT_TARGET)" --os "$(DEPLOYMENT_OS)" $(DEPLOYMENT_INIT_ARG)

deployment-destroy:
	@echo "Destroying deployment VM on target $(DEPLOYMENT_TARGET)..."
	@"$(DEPLOYMENT_SCRIPTS_DIR)/infra-provision.sh" destroy --target "$(DEPLOYMENT_TARGET)" --os "$(DEPLOYMENT_OS)" $(DEPLOYMENT_INIT_ARG)

deployment-output:
	@"$(DEPLOYMENT_SCRIPTS_DIR)/infra-provision.sh" output --target "$(DEPLOYMENT_TARGET)" --os "$(DEPLOYMENT_OS)" $(DEPLOYMENT_INIT_ARG)

deployment-ssh:
	@if [[ -n "$(DEPLOYMENT_NAME)" || "$(DEPLOYMENT_TARGET)" == "qemu" ]]; then \
		"$(DEPLOYMENT_SCRIPTS_DIR)/deployment-access.sh" ssh --target "$(DEPLOYMENT_TARGET)" --name "$(DEPLOYMENT_NAME)"; \
	else \
		"$(DEPLOYMENT_SCRIPTS_DIR)/infra-provision.sh" ssh --target "$(DEPLOYMENT_TARGET)" --os "$(DEPLOYMENT_OS)" $(DEPLOYMENT_INIT_ARG); \
	fi

deployment-list:
	@"$(DEPLOYMENT_SCRIPTS_DIR)/deployment-access.sh" list --target "$(DEPLOYMENT_TARGET)"

deployment-list-os:
	@printf '%s\n' $(DEPLOYMENT_SUPPORTED_OS_SELECTORS)

deployment-list-targets:
	@printf '%s\n' $(DEPLOYMENT_SUPPORTED_TARGET_SELECTORS)

deployment-project-list:
	@"$(DEPLOYMENT_SCRIPTS_DIR)/deployment-project.sh" list

deployment-project:
	@"$(DEPLOYMENT_SCRIPTS_DIR)/deployment-project.sh" run \
		--project "$(DEPLOYMENT_PROJECT)" \
		--target "$(DEPLOYMENT_PROJECT_TARGET)" \
		--os "$(DEPLOYMENT_PROJECT_OS)" \
		$(DEPLOYMENT_INIT_ARG)

deployment-wait:
	@echo "Waiting for deployment VM SSH/cloud-init ($(DEPLOYMENT_TARGET)/$(DEPLOYMENT_OS))..."
	@"$(DEPLOYMENT_SCRIPTS_DIR)/host-wait-ssh.sh" --target "$(DEPLOYMENT_TARGET)" --os "$(DEPLOYMENT_OS)" $(DEPLOYMENT_INIT_ARG)

deployment-bootstrap:
	@echo "Installing Docker on deployment VM ($(DEPLOYMENT_TARGET)/$(DEPLOYMENT_OS))..."
	@"$(DEPLOYMENT_SCRIPTS_DIR)/host-bootstrap.sh" --target "$(DEPLOYMENT_TARGET)" --os "$(DEPLOYMENT_OS)" $(DEPLOYMENT_INIT_ARG)

deployment-bootstrap-check:
	@echo "Checking deployment VM readiness ($(DEPLOYMENT_TARGET)/$(DEPLOYMENT_OS))..."
	@"$(DEPLOYMENT_SCRIPTS_DIR)/host-bootstrap-check.sh" --target "$(DEPLOYMENT_TARGET)" --os "$(DEPLOYMENT_OS)" $(DEPLOYMENT_INIT_ARG)

deployment-ready: deployment deployment-wait deployment-bootstrap deployment-bootstrap-check
	@echo "Deployment VM is provisioned and Docker-ready for Ansible."

deployment-validate:
	@echo "Validating terraform targets (libvirt + proxmox)..."
	@"$(DEPLOYMENT_SCRIPTS_DIR)/infra-validate.sh"

deployment-ansible-syntax:
	@echo "Running deployment Ansible syntax checks..."
	@ANSIBLE_CONFIG="$(DEPLOYMENT_ANSIBLE_DIR)/ansible.cfg" ansible-playbook -i "$(DEPLOYMENT_ANSIBLE_DIR)/inventory/localhost.ini" "$(DEPLOYMENT_ANSIBLE_DIR)/playbooks/system_update.yml" --syntax-check
	@ANSIBLE_CONFIG="$(DEPLOYMENT_ANSIBLE_DIR)/ansible.cfg" ansible-playbook -i "$(DEPLOYMENT_ANSIBLE_DIR)/inventory/localhost.ini" "$(DEPLOYMENT_ANSIBLE_DIR)/playbooks/docker_git.yml" --syntax-check
	@ANSIBLE_CONFIG="$(DEPLOYMENT_ANSIBLE_DIR)/ansible.cfg" ansible-playbook -i "$(DEPLOYMENT_ANSIBLE_DIR)/inventory/localhost.ini" "$(DEPLOYMENT_ANSIBLE_DIR)/playbooks/system_bootstrap.yml" --syntax-check
	@ANSIBLE_CONFIG="$(DEPLOYMENT_ANSIBLE_DIR)/ansible.cfg" ansible-playbook -i "$(DEPLOYMENT_ANSIBLE_DIR)/inventory/localhost.ini" "$(DEPLOYMENT_ANSIBLE_DIR)/playbooks/project_deploy.yml" --syntax-check

deployment-ansible-lint:
	@echo "Running deployment Ansible lint checks..."
	@ANSIBLE_CONFIG="$(DEPLOYMENT_ANSIBLE_DIR)/ansible.cfg" ansible-lint -p \
		"$(DEPLOYMENT_ANSIBLE_DIR)/playbooks/system_update.yml" \
		"$(DEPLOYMENT_ANSIBLE_DIR)/playbooks/docker_git.yml" \
		"$(DEPLOYMENT_ANSIBLE_DIR)/playbooks/system_bootstrap.yml" \
		"$(DEPLOYMENT_ANSIBLE_DIR)/playbooks/project_deploy.yml" \
		"$(DEPLOYMENT_ANSIBLE_DIR)/roles/system_update" \
		"$(DEPLOYMENT_ANSIBLE_DIR)/roles/docker_git" \
		"$(DEPLOYMENT_ANSIBLE_DIR)/roles/project_deploy"

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
	@echo "  bind-port-check       Validate host port 53 is free before starting BIND."
	@echo ""
	@echo "VM Deployment Provisioning (Phase 1: libvirt + proxmox targets):"
	@echo "  deployment            Provision a VM (default: target=libvirt os=ubuntu)."
	@echo "  deployment-plan       Run terraform plan for the deployment VM."
	@echo "  deployment-output     Print terraform outputs (JSON) for the provisioned VM."
	@echo "  deployment-ssh        SSH into the provisioned VM using terraform outputs."
	@echo "  deployment-list       List managed deployment VMs by backend target."
	@echo "  deployment-list-os    List supported deployment OS selectors (one per line)."
	@echo "  deployment-list-targets  List supported deployment targets (one per line)."
	@echo "  deployment-project-list  List supported deployment project ids (one per line)."
	@echo "  deployment-project    End-to-end project workflow (provision -> wait -> system_bootstrap -> project deploy)."
	@echo "  deployment-wait       Wait for SSH and cloud-init completion on the provisioned VM."
	@echo "  deployment-bootstrap  Install Docker Engine + Compose plugin on the provisioned Ubuntu/Debian(12/13) VM."
	@echo "  deployment-bootstrap-check  Verify SSH, Python, Docker and Compose on the provisioned VM."
	@echo "  deployment-ready      End-to-end: provision + wait + Docker bootstrap + readiness check."
	@echo "  deployment-validate   Run terraform fmt/validate checks for libvirt and proxmox targets."
	@echo "  deployment-ansible-syntax  Run Ansible syntax checks for deployment roles/playbooks."
	@echo "  deployment-ansible-lint    Run ansible-lint for deployment roles/playbooks."
	@echo "  deployment-destroy    Destroy the provisioned VM and related resources."
	@echo "  deployment-ubuntu     Alias for 'make deployment DEPLOYMENT_TARGET=libvirt DEPLOYMENT_OS=ubuntu'."
	@echo "                       You can also run: make deployment ubuntu"
	@echo "                       (GNU Make does not support custom flags like '--ubuntu')."
	@echo "  New selector syntax:  make deployment target=<libvirt|qemu|proxmox> os=<ubuntu|debian12|debian13|gentoo|opensuse-leap|almalinux9|rockylinux9|fedora-cloud> [init=<openrc|systemd>]"
	@echo "                       'debian' is accepted as an alias of 'debian13'; qemu maps to libvirt."
	@echo "                       'init' is only valid for os=gentoo and defaults to openrc."
	@echo "                       target=proxmox currently supports os=ubuntu."
	@echo "                       Docker bootstrap/checks currently support ubuntu, debian12 and debian13; gentoo remains separate/experimental."
	@echo "  SSH selector syntax:  make deployment-ssh target=<qemu|proxmox> name=<vm-name>"
	@echo "                       make deployment-list target=<qemu|proxmox>"
	@echo "  Project workflow:     make deployment-project project=<id> [target=<qemu>] [os=<ubuntu>]"
	@echo "                       make deployment-project-list"
	@echo "  Discovery commands:   make deployment-list-os"
	@echo "                       make deployment-list-targets   # current phase output: qemu"
	@echo "  Common overrides: DEPLOYMENT_VM_NAME, DEPLOYMENT_VM_IP, DEPLOYMENT_VM_GATEWAY,"
	@echo "                    DEPLOYMENT_DNS_SERVERS, DEPLOYMENT_SSH_USER, DEPLOYMENT_SSH_PUBKEY_PATH"
	@echo ""
	@echo "Profiles:"
	@echo "  Use COMPOSE_PROFILES=<profile_name> before make commands to activate profiles."
	@echo "  Available profiles: bind, le, stepca"
	@echo "  Example: COMPOSE_PROFILES=le make up"
	@echo ""
