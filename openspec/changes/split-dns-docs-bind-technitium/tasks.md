## 1. Inventario de referencias
- [ ] Title: Localizar referencias a service-dns-bind
  Files: docs/README.md, docs/00-index.md, README.md
  Acceptance: Lista de enlaces actuales a la guia DNS existente.

## 2. Renombrar guia Technitium
- [ ] Title: Mover service-dns-bind a service-dns-technitium
  Files: docs/06-howto/service-dns-bind.md
  Acceptance: La guia Technitium vive en `service-dns-technitium.md` y el titulo refleja Technitium.

## 3. Crear guia BIND
- [ ] Title: Crear nueva guia service-dns-bind
  Files: docs/06-howto/service-dns-bind.md
  Acceptance: La guia BIND sigue la estructura estandar y menciona el profile `bind`.

## 4. Actualizar indices de docs
- [ ] Title: Actualizar docs/README.md y docs/00-index.md
  Files: docs/README.md, docs/00-index.md
  Acceptance: Los indices listan ambas guias (Technitium y BIND) con enlaces correctos.

## 5. Actualizar README root
- [ ] Title: Ajustar links en README.md
  Files: README.md
  Acceptance: README root apunta a las dos guias DNS con nombres correctos.

## 6. Verificar consistencia de enlaces
- [ ] Title: Añadir verificacion manual de docs-check
  Files: openspec/changes/split-dns-docs-bind-technitium/proposal.md
  Acceptance: La verificacion menciona `make docs-check` para validar enlaces.

## 7. Limpieza de referencias antiguas
- [ ] Title: Remover menciones al path antiguo
  Files: docs/06-howto/service-dns-bind.md, docs/README.md, docs/00-index.md, README.md
  Acceptance: No quedan referencias al path antiguo en los archivos tocados.
