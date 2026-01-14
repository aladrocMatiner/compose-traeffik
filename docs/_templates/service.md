# Service Documentation Template

This template provides a consistent structure for documenting individual services within the Traefik Docker Compose Edge Stack.

---

## <Service Name>

### Purpose / Overview

Briefly explain what this service is, its primary function within the stack, and why it exists.

### Where it Lives

*   **Docker Compose File**: `docker-compose.yml` (e.g., `<service_name>` service entry)
*   **Configuration Files**: List specific configuration files (e.g., `traefik/traefik.yml`, `traefik/dynamic/middlewares.yml`)
*   **Related Scripts**: List any `scripts/` that directly interact with or manage this service.
*   **Docker Image**: `<image_name>:<tag>` (e.g., `traefik/whoami:latest`)

### Configuration

#### Environment Variables

List any environment variables (`.env` or `docker-compose.yml` `environment` section) that affect this service's behavior.
*   `VARIABLE_NAME`: Brief description, default value (e.g., `TRAEFIK_IMAGE`, `DEV_DOMAIN`).

#### Ports, Networks, and Volumes

*   **Ports**: List any host ports exposed, or internal container ports.
*   **Networks**:
    *   `<network_name>`: (e.g., `traefik-proxy`). Explain its purpose.
*   **Volumes**:
    *   `<host_path_or_volume_name>:<container_path>`: Brief description of the volume's purpose.

#### Traefik Labels (if applicable)

If this service is exposed via Traefik, list and explain the key Traefik labels used in `docker-compose.yml`.

```yaml
labels:
  - "traefik.enable=true"
  - "traefik.http.routers.<service_name>-web.rule=Host(`<service_host_name>.<DEV_DOMAIN>`)"
  # ... other relevant labels
```

### How to Run / Manage

*   **Start/Stop**:
    ```bash
    # Start only this service (if applicable)
    docker compose up -d <service_name>

    # Stop only this service
    docker compose stop <service_name>
    ```
*   **View Logs**:
    ```bash
    docker compose logs -f <service_name>
    ```
*   **Health/Readiness Check**:
    Describe how to check if the service is running and healthy. (e.g., specific HTTP endpoint, `docker compose ps`).

### Common Operations

List any specific commands or procedures related to managing this service (e.g., certificate renewal for Certbot, bootstrapping for Step-CA).

### Security Notes

Highlight any security considerations relevant to this service (e.g., dashboard exposure, secret handling).

### Troubleshooting

List common issues specific to this service and their solutions.

*   **Symptom**:
    *   **Cause**:
    *   **Diagnose**:
    *   **Fix**:

### Links to Related Documentation

*   [Overall Architecture](../01-architecture.md)
*   [Makefile & Scripts Usage](../03-make-and-scripts.md)
*   [Relevant TLS Mode Guide](../05-tls/<mode_name>.md)
*   [Troubleshooting Guide](../08-troubleshooting.md)
