## 1. Servicio BIND + UI (compose)
- [x] Title: Crear compose del servicio bind y UI web
  Files: services/dns-bind/compose.yml
  Acceptance: Existe el profile `bind` con BIND + UI, redes y volumenes definidos.

## 2. Traefik router + middleware
- [x] Title: Añadir router y BasicAuth para bind UI
  Files: services/traefik/dynamic/middlewares.yml, scripts/traefik-render-dynamic.sh
  Acceptance: Template incluye `bind-ui-auth` y el render sustituye `__BIND_UI_BASIC_AUTH_HTPASSWD_PATH__`.

## 3. Variables y bootstrap
- [x] Title: Definir variables de bind en .env y generar credenciales
  Files: .env.example, scripts/env-generate.sh
  Acceptance: `BIND_UI_BASIC_AUTH_*` se generan si faltan y se crea `bind-ui.htpasswd`.

## 4. Validaciones de entorno
- [x] Title: Validar profile bind y bloquear bind+dns simultaneo
  Files: scripts/validate-env.sh
  Acceptance: Si `bind` esta activo, exige htpasswd y falla si `dns` tambien esta activo.

## 5. Integracion con Makefile y compose wrapper
- [x] Title: Añadir compose y targets bind-* en Makefile
  Files: scripts/compose.sh, Makefile
  Acceptance: `make bind-up/bind-down/bind-logs/bind-status` funcionan y aparecen en help.

## 6. Hosts subdomains
- [x] Title: Incluir bind.${BASE_DOMAIN} en hosts-subdomains
  Files: scripts/hosts-subdomains.sh
  Acceptance: Con profile `bind`, `make hosts-generate` incluye el host `bind`.

## 7. Documentacion del servicio
- [x] Title: Crear README del servicio bind y registrar en manifest
  Files: services/dns-bind/README.md, services/dns-bind/README.es.md, services/dns-bind/README.sv.md, docs.manifest.json, README.md, README.es.md, README.sv.md
  Acceptance: Servicio bind aparece en docs y endpoints con instrucciones basicas.
