## 1. Especificar layout de zonas
- [ ] Title: Definir ruta y estructura del zone file
  Files: services/dns-bind/zones/
  Acceptance: Se documenta la ruta canonica para `db.${BASE_DOMAIN}`.

## 2. Script de provisión
- [ ] Title: Implementar bind-provision.sh con validaciones
  Files: scripts/bind-provision.sh
  Acceptance: El script valida `BASE_DOMAIN` y `LOOPBACK_X` y soporta `--env-file`.

## 3. Render de zone file
- [ ] Title: Generar registros desde ENDPOINTS
  Files: scripts/bind-provision.sh
  Acceptance: El zone file incluye A records para todos los endpoints y `bind.${BASE_DOMAIN}`.

## 4. Dry-run
- [ ] Title: Añadir modo dry-run
  Files: scripts/bind-provision.sh
  Acceptance: `--dry-run` imprime el contenido sin escribir archivos.

## 5. Makefile targets
- [ ] Title: Añadir bind-provision y bind-provision-dry
  Files: Makefile
  Acceptance: Targets aparecen en help y llaman al script correctamente.

## 6. Documentacion del flujo
- [ ] Title: Documentar provisión en README del servicio
  Files: services/dns-bind/README.md, services/dns-bind/README.es.md, services/dns-bind/README.sv.md
  Acceptance: La seccion Run/Configuration incluye bind-provision.

## 7. Verificacion
- [ ] Title: Añadir pasos de verificacion manual
  Files: services/dns-bind/README.md
  Acceptance: Se indican comandos para verificar el zone file generado.
