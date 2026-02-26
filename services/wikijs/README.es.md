[English](README.md) | [Svenska](README.sv.md) | [Espanol](README.es.md)

# Servicio Wiki.js

<a id="overview"></a>
## Resumen

Wiki.js es un modulo opcional de documentacion/wiki expuesto por Traefik en `https://wiki.${DEV_DOMAIN}`.

<a id="location"></a>
## Ubicacion

- `services/wikijs/compose.yml`
- `services/wikijs/config/wikijs.env.example`
- `services/wikijs/rendered/` (generado; ignorado por git)

<a id="run"></a>
## Ejecucion

```bash
make wikijs-bootstrap
make wikijs-up
make wikijs-status
```

<a id="configuration"></a>
## Configuracion

Variables relevantes en `.env.example`:
- `WIKIJS_HOSTNAME` (por defecto `wiki`)
- `WIKIJS_IMAGE`
- `WIKIJS_DB_*`
- `WIKIJS_KEYCLOAK_*` (opcional)
- `WIKIJS_OBSERVABILITY_*` (opcional)
- `WIKIJS_STEPCA_TRUST_*` (opcional)

<a id="ports"></a>
## Puertos, redes, volumenes

- Puertos: puerto de contenedor `3000` (sin publicar en host)
- Redes: `proxy`, `wikijs-internal`
- Volumenes: `wikijs-data`, `wikijs-db-data`

<a id="security"></a>
## Seguridad

- Wiki.js solo se expone mediante routers de Traefik.
- La base de datos usa una red interna.
- Keycloak y observabilidad estan desactivados por defecto.
- Si Keycloak usa certificados de step-ca, activa las opciones `WIKIJS_STEPCA_TRUST_*` y ejecuta `make wikijs-bootstrap`.

<a id="troubleshooting"></a>
## Solucion de problemas

- Si preflight indica que falta config renderizada, ejecuta `make wikijs-bootstrap`.
- Revisa `make wikijs-logs` para `wikijs` y `wikijs-db`.
- Verifica que `wiki.${DEV_DOMAIN}` resuelve a esta maquina.

<a id="related"></a>
## Paginas relacionadas

- [README raiz](../../README.es.md)
- [Traefik](../traefik/README.es.md)
- [Step-CA](../step-ca/README.es.md)
