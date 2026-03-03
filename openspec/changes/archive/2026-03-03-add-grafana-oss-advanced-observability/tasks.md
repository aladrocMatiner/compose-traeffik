## 1. Upstream Verification
- [x] 1.1 Pin and verify image tags for Tempo, Pyroscope, and k6 from official Grafana OSS sources.
- [x] 1.2 Verify Alloy syntax for OTLP trace/profile ingestion and forwarding for selected image version.
- [x] 1.3 Verify Grafana provisioning compatibility for Tempo and Pyroscope datasources on selected Grafana version.
- [x] 1.4 Verify supported and stable output path for k6 results in this stack (Prometheus remote-write or approved alternative).

## 2. Observability Module Expansion
- [x] 2.1 Add `tempo` service config under `services/observability/tempo/` and wire it in `services/observability/compose.yml`.
- [x] 2.2 Add `pyroscope` service config under `services/observability/pyroscope/` and wire it in `services/observability/compose.yml`.
- [x] 2.3 Keep Tempo/Pyroscope internal-only by default (no host ports, no public Traefik routers).
- [x] 2.4 Add persistent volumes and bounded retention defaults for new backends.

## 3. Collector and Provisioning
- [x] 3.1 Extend `services/observability/alloy/config.alloy` with trace and profile pipelines.
- [x] 3.2 Keep existing Loki log ingestion behavior intact for Traefik and app containers.
- [x] 3.3 Extend Grafana datasources provisioning with Tempo and Pyroscope.
- [x] 3.4 Add starter dashboards/panels/queries for traces and profiles (core + service-pack friendly structure).

## 4. Synthetic Checks (k6)
- [x] 4.1 Add a k6 script directory for reusable HTTP checks against Traefik-routed endpoints.
- [x] 4.2 Add Make target(s) to run k6 on demand through repo wrappers.
- [x] 4.3 Ensure k6 output is consumable in Grafana through the chosen telemetry path.

## 5. Environment and Guardrails
- [x] 5.1 Add `.env.example` variables for Tempo, Pyroscope, k6, and feature toggles.
- [x] 5.2 Extend `scripts/validate-env.sh` with profile-gated checks for new observability variables.
- [x] 5.3 Preserve compatibility for existing observability users when new variables are unset and defaults are safe.

## 6. Tests and Documentation
- [x] 6.1 Add smoke tests for Tempo/Pyroscope service wiring and exposure constraints.
- [x] 6.2 Add smoke tests for Alloy trace/profile pipeline presence.
- [x] 6.3 Add smoke tests for Grafana datasource provisioning (Tempo/Pyroscope).
- [x] 6.4 Add smoke tests for k6 Make target wiring and script presence.
- [x] 6.5 Update root and observability READMEs (EN/ES/SV) with signal matrix and operating instructions.
- [x] 6.6 Run `openspec validate add-grafana-oss-advanced-observability --strict`.
