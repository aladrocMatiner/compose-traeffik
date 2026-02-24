# Change: add-env-secrets-htpasswd

## Summary
Guardar credenciales en `.env` (gitignored) y generar los archivos `htpasswd` a partir de esos valores durante el bootstrap, para evitar perder contraseñas locales.

## Problem
Las credenciales de BasicAuth para Traefik/DNS se generan en archivos `htpasswd`, pero la contraseña original no queda registrada. Esto hace difícil recuperar o rotar la contraseña si se pierde el archivo o se regenera.

## Goals
- Persistir las contraseñas en `.env` local (no versionado).
- Generar `htpasswd` desde `.env` en el bootstrap usando scripts existentes.
- Mantener el flujo idempotente: no sobrescribir secretos si ya existen.

## Non-goals
- Cambiar el mecanismo de autenticacion (seguimos usando BasicAuth).
- Introducir un gestor de secretos externo.
- Exponer secretos en commits o en `.env.example`.

## Approach
- Definir variables canonicas en `.env` para credenciales de BasicAuth (p. ej. `TRAEFIK_DASHBOARD_PASSWORD`, `DNS_ADMIN_PASSWORD`), con placeholders en `.env.example`.
- Actualizar el bootstrap (`scripts/env-generate.sh` y/o `make bootstrap`) para:
  - Rellenar secretos vacios en `.env` si faltan.
  - Generar los `htpasswd` a partir de los valores de `.env`.
  - No sobrescribir valores existentes sin `--force`.
- Mantener `.env` en `.gitignore` y documentar el flujo en Quickstart.

Inventario (actual):
- DNS UI BasicAuth: `DNS_UI_BASIC_AUTH_HTPASSWD_PATH` -> `/etc/traefik/auth/dns-ui.htpasswd` -> `services/traefik/auth/dns-ui.htpasswd`.
- Traefik dashboard BasicAuth: `TRAEFIK_DASHBOARD_BASIC_AUTH_HTPASSWD_PATH` -> `/etc/traefik/auth/traefik-dashboard.htpasswd` -> `services/traefik/auth/traefik-dashboard.htpasswd`.

## Affected files
- `.env.example`
- `.gitignore`
- `scripts/env-generate.sh`
- `scripts/compose.sh` (si ya orquesta bootstrap)
- `services/traefik/auth/*.htpasswd` (generados)
- `services/dns/auth/*.htpasswd` (generados)
- `README.md` y docs Quickstart

## Verification
- `.env` contiene las credenciales definidas y no se sobrescriben en re-ejecuciones sin `--force`.
- Los archivos `htpasswd` se regeneran a partir de `.env` y funcionan con las credenciales guardadas.
- `.env` sigue fuera del control de versiones.
- Verificar login en `https://traefik.${DEV_DOMAIN}` y `https://dns.${BASE_DOMAIN}` usando las credenciales guardadas en `.env`.
