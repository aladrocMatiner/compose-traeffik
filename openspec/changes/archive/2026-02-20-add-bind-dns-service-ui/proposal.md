# Change: add-bind-dns-service-ui

## Summary
Agregar un servicio DNS alternativo basado en BIND con una UI web de administracion, integrado con Traefik, profiles, bootstrap y docs como el resto de servicios.

## Problem
El stack solo ofrece Technitium DNS. Se necesita un servicio alternativo basado en BIND con UI web, integrado con el ecosistema (Traefik, .env, bootstrap, hosts, Makefile, docs) y con el mismo nivel de control operacional.

## Goals
- Añadir un profile `bind` con BIND9 y un UI web administrable.
- Exponer la UI via Traefik en `https://bind.${BASE_DOMAIN}` con BasicAuth.
- Generar credenciales en bootstrap y persistirlas en `.env`.
- Integrar el servicio con Makefile, compose wrapper, hosts-subdomains y docs.

## Non-goals
- Reemplazar Technitium o soportar ambos a la vez en el mismo host (conflicto por puerto 53).
- Implementar provisión de zonas/registros (se trata en otro change).
- Ajustes de seguridad avanzados fuera de BasicAuth.

## Approach
- Crear `services/dns-bind/compose.yml` con profile `bind`.
  - Contenedor BIND: `internetsystemsconsortium/bind9:9.18` (config y zones en `services/dns-bind/`).
  - Contenedor UI: `ghcr.io/linuxserver/webmin:latest` (o tag fijo), expuesto solo via Traefik.
- Añadir labels Traefik para la UI: `Host(\`bind.${BASE_DOMAIN}\`)`, entrypoint `websecure` y servicio en el puerto del UI.
- Añadir middleware BasicAuth nuevo en `services/traefik/dynamic/middlewares.yml` (ej: `bind-ui-auth`) con placeholder `__BIND_UI_BASIC_AUTH_HTPASSWD_PATH__`.
- Extender `scripts/traefik-render-dynamic.sh` para renderizar el nuevo placeholder.
- Añadir variables `.env`:
  - `BIND_UI_HOSTNAME=bind`
  - `BIND_UI_BASIC_AUTH_USER`, `BIND_UI_BASIC_AUTH_PASSWORD`
  - `BIND_UI_BASIC_AUTH_HTPASSWD_PATH=/etc/traefik/auth/bind-ui.htpasswd`
  - `BIND_BIND_ADDRESS` (para 53/tcp, 53/udp)
- Extender `scripts/env-generate.sh` para generar passwords y htpasswd.
- Extender `scripts/validate-env.sh` para requerir htpasswd al activar profile `bind` y bloquear `dns` + `bind` juntos.
- Incluir el compose del servicio en `scripts/compose.sh` y añadir targets `bind-*` en Makefile.
- Añadir endpoint `bind.${BASE_DOMAIN}` en `scripts/hosts-subdomains.sh` cuando profile `bind` este activo.
- Documentar el nuevo servicio en `services/dns-bind/README*.md` y registrar en `docs.manifest.json`.

## Affected files
- `services/dns-bind/compose.yml`
- `services/dns-bind/README.md`
- `services/dns-bind/README.es.md`
- `services/dns-bind/README.sv.md`
- `services/traefik/dynamic/middlewares.yml`
- `scripts/traefik-render-dynamic.sh`
- `.env.example`
- `scripts/env-generate.sh`
- `scripts/validate-env.sh`
- `scripts/hosts-subdomains.sh`
- `scripts/compose.sh`
- `Makefile`
- `docs.manifest.json`
- `README.md`, `README.es.md`, `README.sv.md`

## Verification
- `make bind-up` levanta BIND + UI con profile `bind`.
- `https://bind.${BASE_DOMAIN}` solicita BasicAuth y responde con la UI.
- `make hosts-generate` incluye `bind.${BASE_DOMAIN}` cuando profile `bind` esta activo.
- Re-ejecutar `./scripts/env-generate.sh --mode=full` mantiene credenciales en `.env` y regenera `bind-ui.htpasswd`.
