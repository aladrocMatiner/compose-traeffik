[English](README.md) | [Svenska](README.sv.md) | [Espanol](README.es.md)

# WebUI Service

This service provides a placeholder WebUI that can be deployed behind Traefik.

## Overview

The `webui` service is a simple nginx-based web server that serves as a placeholder for a real WebUI application. It's designed to demonstrate how to deploy applications behind Traefik with proper routing and TLS configuration.

## Configuration

### Environment Variables

None required.

### Docker Labels

- `traefik.enable=true`
- `traefik.http.routers.webui.rule=PathPrefix(\`/webui\`)`
- `traefik.http.routers.webui.entrypoints=websecure`
- `traefik.http.routers.webui.tls.certresolver=stepca-resolver`
- `traefik.http.services.webui.loadbalancer.server.port=80`
- `traefik.http.middlewares.webui-strip-prefix.stripprefix.prefixes=/webui`
- `traefik.http.routers.webui.middlewares=webui-strip-prefix`

## Usage

The WebUI is accessible at:
- `https://webui.${DEV_DOMAIN}` (when using StepCA ACME)

## Deployment

This service is automatically included in the default stack when the `webui` profile is activated.

## TLS Integration

The service integrates with Traefik's TLS management system. When deployed with the `stepca` profile, it uses the StepCA certificate resolver for TLS termination.
