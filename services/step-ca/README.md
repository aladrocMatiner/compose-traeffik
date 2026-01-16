# Step-CA service

This directory groups configuration, secrets, and compose metadata for the `step-ca` profile (Mode C TLS).

- `compose.yml` defines the `step-ca` container, its networks (`stepca-internal` + `proxy`), and Traefik labels.
- `config/` and `secrets/` mirror the contents of the container paths `/home/step/config` and `/home/step/secrets`.
- `stepca-data` (declared in `compose/base.yml`) stores persistent certificates and issuance data.

**Run step-ca**
```bash
docker compose \
  -f compose/base.yml \
  -f services/step-ca/compose.yml \
  --env-file .env --profile stepca up step-ca
```
