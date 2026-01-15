# Trust Step-CA on Ubuntu 24.04

This guide installs the Step-CA root certificate into the Ubuntu 24.04 system trust store so local TLS works without browser warnings.

## Prerequisites

1. Bootstrap Step-CA and obtain the public root certificate:
   ```bash
   make stepca-bootstrap
   docker compose --profile stepca cp step-ca:/home/step/config/ca.crt ./step-ca/config/ca.crt
   ```

2. Confirm the certificate exists:
   ```bash
   ls -l ./step-ca/config/ca.crt
   ```

## Install Trust

```bash
sudo make stepca-trust-install
```

## Verify Trust

```bash
make stepca-trust-verify
```

## Uninstall Trust

```bash
sudo make stepca-trust-uninstall
```

## Security Notes

- Only the public CA certificate is used: `./step-ca/config/ca.crt`.
- Never copy or reference `./step-ca/secrets/` or any private key material.
- If you need a different CA certificate location, set `STEPCA_CA_CERT_PATH` before running the scripts.
