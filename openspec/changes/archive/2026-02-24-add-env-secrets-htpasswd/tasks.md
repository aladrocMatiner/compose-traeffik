## 1. Inventario de secretos y destinos
- [x] Title: Enumerar credenciales y archivos htpasswd actuales
  Files: scripts/env-generate.sh, services/traefik/auth/, services/dns/auth/
  Acceptance: Lista de variables necesarias y sus destinos (htpasswd) documentada en el change.

## 2. Definir variables canonicas en .env.example
- [x] Title: Agregar placeholders de secretos en .env.example
  Files: .env.example
  Acceptance: Las variables de credenciales aparecen con placeholders claros y sin valores reales.

## 3. Generacion de secretos en bootstrap
- [x] Title: Rellenar secretos faltantes en .env durante bootstrap
  Files: scripts/env-generate.sh
  Acceptance: Si falta un secreto, se genera uno y se escribe en .env; si ya existe, se conserva.

## 4. Generar htpasswd desde .env
- [x] Title: Construir htpasswd usando las credenciales del .env
  Files: scripts/env-generate.sh
  Acceptance: Los archivos htpasswd se regeneran con las credenciales del .env.

## 5. Ajustar Quickstart y docs
- [x] Title: Documentar flujo de credenciales persistentes
  Files: README.md, docs/quickstart*, docs/README*
  Acceptance: Quickstart indica que las credenciales estan en .env y se usan para generar htpasswd.

## 6. Verificacion manual
- [x] Title: Añadir pasos de verificacion
  Files: openspec/changes/add-env-secrets-htpasswd/proposal.md
  Acceptance: Se incluyen checks manuales para confirmar login con credenciales del .env.
