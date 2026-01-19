# Change: Harden default configuration values

## Why
Some default configuration values can lead to unsafe or non-reproducible behavior, such as using public-looking domains or unpinned container images.

## What Changes
- Update default local domains in .env.example to non-public local-only values.
- Pin the Technitium DNS image to a specific version for reproducibility.
- Add guardrails so enabling dashboard/DNS UI requires a non-example htpasswd path.

## Impact
- Affected specs: stack-config
- Affected code: .env.example, services/dns/compose.yml, scripts (validation or bootstrap), README(s) as needed
