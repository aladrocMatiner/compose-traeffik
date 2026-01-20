[English](README.md) | [Svenska](README.sv.md) | [Espanol](README.es.md)

# Traefik Docker Compose Edge Stack

<a id="overview"></a>
## Oversikt

Detta repo ger en Docker Compose edge stack centrerad runt Traefik. Den ar gjord for lokal utveckling, med valfria profiler for DNS, Let's Encrypt (Certbot) och step-ca. Dokumentationssystemet bygger pa README-filer och finns pa engelska, svenska och spanska.

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
- **DNS UI**: `https://dns.${BASE_DOMAIN}` (profil `dns`, BasicAuth; aktiverad som standard)
- **Step-CA UI**: `https://step-ca.${DEV_DOMAIN}` (profil `stepca`; aktiverad som standard)

<a id="services"></a>
## Tjanster

- [Traefik](services/traefik/README.sv.md) - reverse proxy och routing-karnan.
- [Whoami](services/whoami/README.sv.md) - demo-service for routingtester.
- [DNS (Technitium)](services/dns/README.sv.md) - valfri profil `dns`.
- [Certbot](services/certbot/README.sv.md) - valfri profil `le`.
- [Step-CA](services/step-ca/README.sv.md) - valfri profil `stepca`.

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
- `make dns-up`, `make dns-provision`, `make dns-config-apply`
- `make hosts-generate`, `make hosts-apply`, `make hosts-status`

Auth-filer:
- `services/traefik/auth/dns-ui.htpasswd.example`
- `services/traefik/auth/traefik-dashboard.htpasswd.example`
- `make bootstrap` kopierar example till `services/traefik/auth/*.htpasswd` (standard: `admin` / `change-me`).
- Byt med `htpasswd -nbB admin 'new-pass' > services/traefik/auth/<file>.htpasswd`.

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
