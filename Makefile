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
.PHONY: help up down restart logs ps test \
        certs-local certs-le-issue certs-le-renew \
        stepca-up stepca-down stepca-bootstrap stepca-verify-cert

# Include .env for environment variables if it exists.
# This makes variables in .env available to the Makefile.
-include .env
.EXPORT_ALL_VARIABLES:

# --- Docker Compose Commands ---

# Helper to construct compose command with profiles
COMPOSE_BASE := docker compose --env-file .env
COMPOSE_OPTS ?=
COMPOSE_PROFILES_ARG := $(if $(COMPOSE_PROFILES),--profile $(subst ',', --profile ,$(COMPOSE_PROFILES)),)

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
	$(COMPOSE_BASE) $(COMPOSE_PROFILES_ARG) $(COMPOSE_OPTS) ps

# --- Certificate Management (Mode A: Local Self-Signed) ---

certs-local:
	@echo "Generating local self-signed certificates..."
	./scripts/certs-selfsigned-generate.sh

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
	COMPOSE_PROFILES=stepca $(COMPOSE_BASE) $(COMPOSE_OPTS) up -d step-ca

# Stop step-ca service
stepca-down:
	@echo "Stopping Step-CA service..."
	COMPOSE_PROFILES=stepca $(COMPOSE_BASE) $(COMPOSE_OPTS) down step-ca

# Bootstrap step-ca server
stepca-bootstrap: stepca-up
	@echo "Bootstrapping Step-CA server..."
	@if [ -z "$(STEP_CA_ADMIN_PROVISIONER_PASSWORD)" ] || [ -z "$(STEP_CA_PASSWORD)" ]; then echo "Error: STEP_CA_ADMIN_PROVISIONER_PASSWORD or STEP_CA_PASSWORD not set in .env. Aborting."; exit 1; fi
	./scripts/stepca-bootstrap.sh

# --- Testing ---

test:
	@echo "Running smoke tests..."
	./scripts/healthcheck.sh

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
	@echo "  up                    Start the default stack (Traefik + whoami)."
	@echo "  down                  Stop and remove the default stack."
	@echo "  restart               Restart the default stack."
	@echo "  logs                  Follow logs for all running services."
	@echo "  ps                    List services in the stack."
	@echo ""
	@echo "Certificate Management (Mode A: Local Self-Signed):"
	@echo "  certs-local           Generate local self-signed certificates in certs/local/."
	@echo ""
	@echo "Certificate Management (Mode B: Let's Encrypt with Certbot):"
	@echo "  certs-le-issue        Issue a new Let's Encrypt certificate using certbot (requires 'le' profile)."
	@echo "                        Requires ACME_EMAIL in .env. Run 'COMPOSE_PROFILES=le make up' first."
	@echo "  certs-le-renew        Renew existing Let's Encrypt certificates (requires 'le' profile)."
	@echo "                        Run 'COMPOSE_PROFILES=le make up' first."
	@echo ""
	@echo "Certificate Management (Mode C: Step-CA):"
	@echo "  stepca-up             Start the Step-CA service (activates 'stepca' profile)."
	@echo "  stepca-down           Stop and remove the Step-CA service."
	@echo "  stepca-bootstrap      Initialize and bootstrap the Step-CA server (requires 'stepca' profile)."
	@echo "                        Requires STEP_CA_ADMIN_PROVISIONER_PASSWORD and STEP_CA_PASSWORD in .env."
	@echo ""
	@echo "Testing:"
	@echo "  test                  Run all smoke tests for the current configuration."
	@echo ""
	@echo "Profiles:"
	@echo "  Use COMPOSE_PROFILES=<profile_name> before make commands to activate profiles."
	@echo "  Available profiles: le, stepca"
	@echo "  Example: COMPOSE_PROFILES=le make up"
	@echo ""