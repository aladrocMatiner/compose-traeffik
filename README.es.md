[English](README.md) | [Svenska](README.sv.md) | [Espanol](README.es.md)

# Traefik Docker Compose Edge Stack

<a id="overview"></a>
## Resumen

Este repositorio ofrece una edge stack de Docker Compose centrada en Traefik. Esta pensada para desarrollo local, con perfiles opcionales para DNS, Let's Encrypt (Certbot) y step-ca. El sistema de documentacion se basa en README y esta disponible en ingles, sueco y espanol.

<a id="quickstart"></a>
## Inicio rapido (Mode A: TLS Self-Signed local)

1. **Clona el repositorio**
   ```bash
   git clone https://github.com/aladrocMatiner/compose-traeffik.git
   cd compose-traeffik
   ```

2. **Bootstrap de env y secretos**
   ```bash
   make bootstrap
   # Actualiza DEV_DOMAIN, BASE_DOMAIN, LOOPBACK_X, ENDPOINTS segun sea necesario.
   # El valor por defecto usa el dominio local local.test.
   # Bootstrap copia los archivos BasicAuth a services/traefik/auth/.
   ```
   Alternativa: genera `.env` directamente desde la plantilla:
   ```bash
   ./scripts/env-generate.sh
   # Usa --force para regenerar desde .env.example.
   # ./scripts/env-generate.sh --force
   ```

3. **Genera certificados locales**
   ```bash
   make certs-local
   ```

4. **Mapea subdominios locales a loopback (recomendado)**
   ```bash
   make hosts-generate
   sudo make hosts-apply
   make hosts-status
   ```

5. **Inicia la stack**
   ```bash
   make up
   ```

6. **Ejecuta smoke tests**
   ```bash
   make test
   ```

7. **Verifica el servicio demo**
   ```bash
   curl -vk "https://whoami.${DEV_DOMAIN}"
   ```

Guias de TLS:
- [Mode A: Self-signed](docs/tls-mode-a-selfsigned.md)
- [Mode B: Let's Encrypt + Certbot](docs/tls-mode-b-letsencrypt-certbot.md)
- [Mode C: Step-CA ACME](docs/tls-mode-c-stepca-acme.md)

<a id="endpoints"></a>
## Endpoints

- **Whoami**: `https://whoami.${DEV_DOMAIN}` (stack por defecto)
- **Traefik dashboard**: `https://traefik.${DEV_DOMAIN}` (BasicAuth; habilitado por defecto)
- **DNS UI**: `https://dns.${BASE_DOMAIN}` (perfil `dns`, BasicAuth; habilitado por defecto)
- **Step-CA UI**: `https://step-ca.${DEV_DOMAIN}` (perfil `stepca`; habilitado por defecto)

<a id="services"></a>
## Servicios

- [Traefik](services/traefik/README.es.md) - reverse proxy y nucleo de routing.
- [Whoami](services/whoami/README.es.md) - servicio demo para pruebas de routing.
- [DNS (Technitium)](services/dns/README.es.md) - perfil opcional `dns`.
- [Certbot](services/certbot/README.es.md) - perfil opcional `le`.
- [Step-CA](services/step-ca/README.es.md) - perfil opcional `stepca`.

<a id="docs-map"></a>
## Mapa de documentos

- Resumen, Inicio rapido, Endpoints, Operaciones, Testing, Troubleshooting (esta pagina)
- Guias TLS (en `docs/`):
  - [Mode A: Self-signed](docs/tls-mode-a-selfsigned.md)
  - [Mode B: Let's Encrypt + Certbot](docs/tls-mode-b-letsencrypt-certbot.md)
  - [Mode C: Step-CA ACME](docs/tls-mode-c-stepca-acme.md)
- Paginas de servicio (enlaces arriba)
- Nota de migracion y como agregar docs de servicio (esta pagina)

<a id="operations"></a>
## Operaciones

Comandos comunes:
- `make up`, `make down`, `make logs`, `make ps`
- `make certs-local`
- `make certs-le-issue`, `make certs-le-renew` (perfil `le`)
- `make stepca-up`, `make stepca-bootstrap`, `make stepca-trust-install`
- `make dns-up`, `make dns-provision`, `make dns-config-apply`
- `make hosts-generate`, `make hosts-apply`, `make hosts-status`

Archivos auth:
- `services/traefik/auth/dns-ui.htpasswd.example`
- `services/traefik/auth/traefik-dashboard.htpasswd.example`
- `make bootstrap` copia los example a `services/traefik/auth/*.htpasswd` (credenciales por defecto: `admin` / `change-me`).
- Reemplaza con `htpasswd -nbB admin 'new-pass' > services/traefik/auth/<file>.htpasswd`.

<a id="testing"></a>
## Testing

Ejecuta smoke tests con:
```bash
make test
```
Ve `tests/README.md` para detalles.
Scripts operativos: ver `scripts/README.md`.

<a id="troubleshooting"></a>
## Troubleshooting

- Verifica que `DEV_DOMAIN` y `BASE_DOMAIN` coincidan con tu hosts/DNS.
- Si los puertos 80/443 estan en uso, deten servicios en conflicto y reintenta `make up`.
- Usa `make logs` para ver logs de Traefik y servicios.

<a id="add-service-doc"></a>
## Agregar docs de servicio

1. Crea `services/<service>/README.md`, `README.sv.md`, y `README.es.md`.
2. Agrega el selector de idioma en la primera linea.
3. Usa los mismos anclajes y orden de secciones que otras READMEs.
4. Agrega el servicio en `docs.manifest.json`.
5. Ejecuta `make docs-check`.

<a id="migration"></a>
## Nota de migracion

- La documentacion raiz ahora vive en `README.md`, `README.sv.md`, y `README.es.md`.
- La documentacion de servicios vive en `services/<service>/README*.md`.
- El contenido legado de `docs/` se mantiene como referencia pero ya no es el punto principal.
- Si tenias enlaces personalizados a `docs/`, actualizalos a las nuevas rutas README.
