[English](README.md) | [Svenska](README.sv.md) | [Espanol](README.es.md)

# Wiki.js-tjanst

<a id="overview"></a>
## Oversikt

Wiki.js ar en valfri dokumentations/wiki-modul som exponeras via Traefik pa `https://wiki.${DEV_DOMAIN}`.

<a id="location"></a>
## Placering

- `services/wikijs/compose.yml`
- `services/wikijs/config/wikijs.env.example`
- `services/wikijs/rendered/` (genererad; gitignorerad)

<a id="run"></a>
## Korning

```bash
make wikijs-bootstrap
make wikijs-up
make wikijs-status
```

<a id="configuration"></a>
## Konfiguration

Relevanta variabler i `.env.example`:
- `WIKIJS_HOSTNAME` (standard `wiki`)
- `WIKIJS_IMAGE`
- `WIKIJS_DB_*`
- `WIKIJS_KEYCLOAK_*` (valfritt)
- `WIKIJS_OBSERVABILITY_*` (valfritt)
- `WIKIJS_STEPCA_TRUST_*` (valfritt)

<a id="ports"></a>
## Portar, natverk, volymer

- Portar: containerport `3000` (inte publicerad pa vardmaskinen)
- Natverk: `proxy`, `wikijs-internal`
- Volymer: `wikijs-data`, `wikijs-db-data`

<a id="security"></a>
## Sakerhet

- Wiki.js exponeras endast via Traefik-routerregler.
- Databasen ligger pa ett internt natverk.
- Keycloak och observability ar avstangda som standard.
- Vid step-ca-signerat Keycloak-certifikat, aktivera `WIKIJS_STEPCA_TRUST_*` och kor `make wikijs-bootstrap` igen.

<a id="troubleshooting"></a>
## Felsokning

- Om preflight sager att renderad konfiguration saknas eller ar gammal, kor `make wikijs-bootstrap`.
- Kontrollera `make wikijs-logs` for loggar fran `wikijs` och `wikijs-db`.
- Bekrafta att `wiki.${DEV_DOMAIN}` pekar mot denna vard (hosts eller DNS).

<a id="related"></a>
## Relaterade sidor

- [Rot-README](../../README.sv.md)
- [Traefik](../traefik/README.sv.md)
- [Step-CA](../step-ca/README.sv.md)
