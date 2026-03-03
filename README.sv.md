[English](README.md) | [Svenska](README.sv.md) | [Espanol](README.es.md)

# Traefik Docker Compose Edge Stack

<a id="overview"></a>
## Oversikt

Detta repo ger en Docker Compose edge stack centrerad runt Traefik. Den ar gjord for lokal utveckling, med valfria profiler for BIND (DNS), Let's Encrypt (Certbot) och step-ca. Dokumentationssystemet bygger pa README-filer och finns pa engelska, svenska och spanska.

<a id="quickstart"></a>
## Snabbstart (Mode A: Lokal Self-Signed TLS)

1. **Klona repo**
   ```bash
   git clone https://github.com/aladrocMatiner/compose-traeffik.git
   cd compose-traeffik
   ```

2. **Bootstrap av env och secrets (produktion-minimal som standard)**
   ```bash
   make bootstrap
   # Produktion-minimala defaults (valfria profiler avstangda).
   # Uppdatera DEV_DOMAIN, BASE_DOMAIN, LOOPBACK_X, ENDPOINTS vid behov.
   # Standard ar lokal-dominen local.test.
   ```
   Fulla defaults (valfria profiler aktiverade):
   ```bash
   make bootstrap-full
   # Detta matchar de fulla defaultsen i templaten.
   # BasicAuth htpasswd genereras fran credentials i .env.
   ```
   Alternativ: generera `.env` direkt fran mallen:
   ```bash
   ./scripts/env-generate.sh --mode=prod
   # Anvand --mode=full for fulla defaults eller --force for att generera om.
   # ./scripts/env-generate.sh --mode=full --force
   ```

3. **Skapa lokala certifikat**
   ```bash
   make certs-local
   ```

4. **Mappa lokala subdomaner till loopback (rekommenderas)**
   ```bash
   make hosts-generate
   sudo make hosts-apply
   make hosts-status
   ```

5. **Starta stacken**
   ```bash
   make up
   ```

6. **Kor smoke tests**
   ```bash
   make test
   ```

7. **Verifiera demo-servicen**
   ```bash
   curl -vk "https://whoami.${DEV_DOMAIN}"
   ```

Detaljerade TLS-floden:
- [Mode A: Self-signed](docs/tls-mode-a-selfsigned.md)
- [Mode B: Let's Encrypt + Certbot](docs/tls-mode-b-letsencrypt-certbot.md)
- [Mode C: Step-CA ACME](docs/tls-mode-c-stepca-acme.md)

<a id="endpoints"></a>
## Endpoints

- **Whoami**: `https://whoami.${DEV_DOMAIN}` (standardstack)
- **Traefik dashboard**: `https://traefik.${DEV_DOMAIN}` (BasicAuth; aktiverad som standard)
- **Step-CA UI**: `https://step-ca.${DEV_DOMAIN}` (profil `stepca`; aktiverad som standard)
- **CTFd**: `https://ctfd.${DEV_DOMAIN}` (profil `ctfd`; valfri)
- **Grafana**: `https://grafana.${DEV_DOMAIN}` (profil `observability`; valfri)
- **Plane**: `https://plane.${DEV_DOMAIN}` (profil `plane`; valfri)
- **Docling**: `https://docling.${DEV_DOMAIN}` (profil `docling`; valfri)
- **FreeIPA**: `https://freeipa.${DEV_DOMAIN}` (profil `freeipa`; valfri)
- **OpenWebUI**: `https://openwebui.${DEV_DOMAIN}` (profil `webui`; valfri)
- **AWX**: `https://awx.${DEV_DOMAIN}` (hybridmodul `k3d` + AWX Operator; kraver `make awx-*`)
- **Prometheus/Loki/Tempo/Pyroscope**: interna som standard (profil `observability`; ingen publik endpoint)

<a id="services"></a>
## Tjanster

- [Traefik](services/traefik/README.sv.md) - reverse proxy och routing-karnan.
- [Whoami](services/whoami/README.sv.md) - demo-service for routingtester.
- [DNS (BIND)](services/dns-bind/README.sv.md) - valfri profil `bind`.
- [Certbot](services/certbot/README.sv.md) - valfri profil `le`.
- [Step-CA](services/step-ca/README.sv.md) - valfri profil `stepca`.
- [CTFd](services/ctfd/README.sv.md) - valfri profil `ctfd` (CTF-plattform + DB + Redis).
- [Observability](services/observability/README.sv.md) - valfri profil `observability` (Grafana/Prometheus/Loki/Tempo/Pyroscope/Alloy + k6 synthetic checks).
- [Plane](services/plane/README.sv.md) - valfri profil `plane` (projektledning + PostgreSQL/Redis/RabbitMQ/MinIO).
- [Docling](services/docling/README.sv.md) - valfri profil `docling` (dokumentkonverterings-API + intern Redis for async/RQ-lage).
- [FreeIPA](services/freeipa/README.sv.md) - valfri profil `freeipa` (identitetshanteringstjanst bakom Traefik).
- [OpenWebUI](services/openwebui/README.sv.md) - valfri profil `webui` (webb/chat UI bakom Traefik).
- [AWX](services/awx/README.sv.md) - hybridmodul (`k3d` + AWX Operator) bakom Traefik.

<a id="docs-map"></a>
## Dokumentkarta

- Oversikt, Snabbstart, Endpoints, Operationer, Tester, Felsokning (denna sida)
- TLS-guider (i `docs/`):
  - [Mode A: Self-signed](docs/tls-mode-a-selfsigned.md)
  - [Mode B: Let's Encrypt + Certbot](docs/tls-mode-b-letsencrypt-certbot.md)
  - [Mode C: Step-CA ACME](docs/tls-mode-c-stepca-acme.md)
- Service-sidor (lankar ovan)
- Migreringsnoter och hur man lagger till en service-doc (denna sida)

<a id="operations"></a>
## Operationer

Vanliga kommandon:
- `make up`, `make down`, `make logs`, `make ps`
- `make certs-local`
- `make certs-le-issue`, `make certs-le-renew` (profil `le`)
- `make stepca-up`, `make stepca-bootstrap`, `make stepca-trust-install`
- `make bind-up`, `make bind-status`, `make bind-restart`, `make bind-provision`
- `make ctfd-bootstrap`, `make ctfd-up`, `make ctfd-status`
- `make observability-bootstrap`, `make observability-up`, `make observability-status`, `make observability-k6`
- `make plane-bootstrap`, `make plane-up`, `make plane-status`
- `make docling-bootstrap`, `make docling-up`, `make docling-status`
- `make freeipa-bootstrap`, `make freeipa-up`, `make freeipa-status`
- `make webui-up`, `make webui-status`
- `make awx-bootstrap`, `make awx-k3d-up`, `make awx-up`, `make awx-status`, `make awx-admin-password`
- `make awx-debug`, `make awx-backup`
- `make awx-restore AWX_RESTORE_ARGS="--backup-name <name> --confirm"` (kan vara destruktivt; krav pa explicit bekräftelse)
- `make awx-upgrade AWX_UPGRADE_ARGS="--confirm ..."` (stateful underhall; krav pa explicit bekräftelse)
- `make hosts-generate`, `make hosts-apply`, `make hosts-status`

AWX-forutsattningar (hybridmodul):
- `docker`, `k3d`, `kubectl`, `helm`
- Traefik maste vara igang (`make up` eller minst `traefik`) for `https://awx.${DEV_DOMAIN}`

Auth-filer:
- `services/traefik/auth/traefik-dashboard.htpasswd.example`
- `make bootstrap-full` genererar `services/traefik/auth/*.htpasswd` fran `.env`-varden:
  - `TRAEFIK_DASHBOARD_BASIC_AUTH_USER` / `TRAEFIK_DASHBOARD_BASIC_AUTH_PASSWORD`
- For att rotera credentials, uppdatera `.env` och kor `./scripts/env-generate.sh --mode=full`.

DNS-sakerhetsdefaults:
- BIND kor som auktoritativ lokal DNS med recursion avstangt och AXFR blockerat.
- `BIND_BIND_ADDRESS` bor vara loopback som standard.
- For avsiktlig exponering utanfor loopback, satt `BIND_ALLOW_NONLOCAL_BIND=true`.

Hosts-not:
- Om du hanterar `ENDPOINTS` manuellt, lagg till `ctfd`, `grafana`, `plane`, `docling`, `freeipa` och/eller `openwebui` innan `make hosts-apply`.
- Lagg till `awx` ocksa om du vill ha lokal routing for AWX via Traefik.
- Lagg till `keycloak` ocksa om du planerar Plane med lokal Keycloak-routing.
- Eller lamna `ENDPOINTS` tomt for auto-discovery via `Host()`-regler.

<a id="testing"></a>
## Tester

Kor smoke tests med:
```bash
make test
```
Se `tests/README.md` for detaljer.
Operativa script: se `scripts/README.md`.

<a id="troubleshooting"></a>
## Felsokning

- Kontrollera att `DEV_DOMAIN` och `BASE_DOMAIN` matchar din hosts/DNS.
- Om portar 80/443 ar upptagna, stoppa konflikter och forsok `make up` igen.
- Anvand `make logs` for att se Traefik och service-loggar.

<a id="add-service-doc"></a>
## Lagg till en service-doc

1. Skapa `services/<service>/README.md`, `README.sv.md`, och `README.es.md`.
2. Lagg till sprakselektorn langst upp.
3. Anvand samma ankare och sectionsordning som andra service READMEs.
4. Lagg till servicen i `docs.manifest.json`.
5. Kor `make docs-check`.

<a id="migration"></a>
## Migreringsnot

- Rotdokumentation finns nu i `README.md`, `README.sv.md`, och `README.es.md`.
- Service-dokumentation finns under `services/<service>/README*.md`.
- Aldre `docs/`-innehall finns kvar for referens men ar inte langre primar ingang.
- Om du hade egna lankar till gamla `docs/`, uppdatera till nya README-platser.
