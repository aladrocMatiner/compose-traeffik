# Traefik & Routing

**Role: Traefik & Routing Specialist**
*Mission: Document Traefik behavior, service integration patterns, and dashboard usage.*

This section explains how Traefik is configured in this edge stack, how it routes traffic to your services, and how you can integrate new applications.

## Traefik Configuration Overview

Traefik in this setup uses a combination of static and dynamic configurations:

*   **Static Configuration (`traefik/traefik.yml`)**: Defines Traefik's entrypoints (ports it listens on), providers (how it discovers services, e.g., Docker), and global settings like the dashboard.
*   **Dynamic Configuration (`traefik/dynamic/*.yml`)**: Defines routers, services, and middlewares that can change without restarting Traefik. This includes HTTP to HTTPS redirection, security headers, and TLS configurations.

Traefik discovers your services using the **Docker provider**. This means that by adding specific labels to your Docker Compose services, you can tell Traefik how to route traffic to them.

<h2>Key Traefik Concepts</h2>

*   **Entrypoints**: These are the network ports where Traefik listens for incoming requests. In this setup, `web` (HTTP:80) and `websecure` (HTTPS:443) are the primary entrypoints.
*   **Routers**: Routers analyze incoming requests (based on `Host`, `Path`, `Headers`, etc.) and determine which service should handle them.
*   **Services**: These are your actual applications (e.g., `whoami` demo service). Traefik forwards requests to these services.
*   **Middlewares**: These are small pieces of logic that can modify requests before they reach your service or modify responses before they are sent back to the client. Examples include HTTP to HTTPS redirection, adding security headers, or authentication.
*   **Proxy Network (`traefik-proxy`)**: A dedicated Docker network that isolates Traefik and all routed services. Services must be connected to this network to be discoverable and routable by Traefik.

<h2>Adding a New Service</h2>

Integrating a new Docker Compose service into the Traefik edge stack is straightforward using Traefik's Docker labels.

<h3>Prerequisites</h3>

*   Your new service is defined in `docker-compose.yml`.
*   You have configured your `DEV_DOMAIN` in `.env` and updated your host system's `/etc/hosts` file (refer to [Requirements and Host Configuration](../requirements.md)).
*   The Traefik stack is running (e.g., `make up`).

<h3>Steps</h3>

1.  **Define your service in `docker-compose.yml`**:
    Add your new service definition to `docker-compose.yml`. Crucially, ensure it's connected to the `proxy` network and has the necessary Traefik labels.

    ```yaml
    # Example snippet for a new service
    my-new-service:
      image: your/service-image:latest # Replace with your service's image
      container_name: my-new-service
      restart: unless-stopped
      networks:
        - proxy # CRUCIAL: Connect to the shared proxy network
      labels:
        # Enable Traefik for this service
        - "traefik.enable=true"

        # HTTP to HTTPS Redirect (Optional but Recommended)
        # This router listens on the 'web' (HTTP) entrypoint
        - "traefik.http.routers.my-new-service-http.rule=Host(`my-new-service.${DEV_DOMAIN}`)"
        - "traefik.http.routers.my-new-service-http.entrypoints=web"
        - "traefik.http.routers.my-new-service-http.middlewares=redirect-to-https@file"

        # HTTPS Router (Mandatory for secure services)
        # This router listens on the 'websecure' (HTTPS) entrypoint
        - "traefik.http.routers.my-new-service-https.rule=Host(`my-new-service.${DEV_DOMAIN}`)"
        - "traefik.http.routers.my-new-service-https.entrypoints=websecure"
        - "traefik.http.routers.my-new-service-https.service=my-new-service-service"
        - "traefik.http.routers.my-new-service-https.tls=true"
        # Apply the correct certificate resolver based on active profile (or leave empty for Mode A)
        - "traefik.http.routers.my-new-service-https.tls.certresolver=${TLS_CERT_RESOLVER:-}"

        # Service definition (Traefik targets this service internally)
        # Replace '80' with the port your application listens on INSIDE its container
        - "traefik.http.services.my-new-service-service.loadbalancer.server.port=80"

        # Apply security headers middleware (Optional but Recommended)
        # Ensure this middleware is defined in traefik/dynamic/middlewares.yml
        - "traefik.http.routers.my-new-service-https.middlewares=security-headers@file"
    ```
    > **Note:** The `TLS_CERT_RESOLVER` variable is crucial for dynamically configuring which ACME resolver (Let's Encrypt or step-ca) Traefik should use. If left empty, Traefik will use certificates defined by the file provider (Mode A).

2.  **Update `.env` and `/etc/hosts`**:
    Add `my-new-service.<DEV_DOMAIN>` to your `/etc/hosts` file to resolve the new domain to `127.0.0.1`.

3.  **Restart the stack**:
    ```bash
    make restart
    ```
    This will ensure Traefik re-reads the Docker labels and applies the new routing configuration.

<h3>Expected Result</h3>

After restarting the stack, your new service should be accessible via the configured domain over HTTPS. Traefik's dashboard should reflect the new router and service.

<h3>Verification</h3>

1.  **Check Traefik Dashboard**:
    Navigate to `https://traefik.<DEV_DOMAIN>/dashboard/` and verify that a new router and service corresponding to `my-new-service` are listed.

2.  **Access the new service**:
    Open your browser to `https://my-new-service.<DEV_DOMAIN>`. You should see the expected output from your application.
    You can also use `curl`:
    ```bash
    curl -k https://my-new-service.<DEV_DOMAIN>
    ```
    The `-k` flag is often needed if you are still using self-signed certificates and have not fully trusted them system-wide.

3.  **Verify HTTP to HTTPS redirect**:
    Attempt to access your service via HTTP: `http://my-new-service.<DEV_DOMAIN>`. It should automatically redirect to `https://my-new-service.<DEV_DOMAIN>`.

<h2>Traefik Dashboard</h2>

The Traefik dashboard provides a real-time overview of your routers, services, middlewares, and TLS configurations.

<h3>Accessing the Dashboard</h3>

The dashboard is accessible at `https://traefik.<DEV_DOMAIN>/dashboard/`.

<h3>Security Considerations</h3>

*   **Disabled by Default**: The Traefik dashboard is configured to be **disabled by default** in this repository's `traefik/traefik.yml` to prevent accidental exposure.
*   **Secured Access**: When enabled, access to the dashboard should always be secured via HTTPS and, ideally, behind an authentication middleware (e.g., BasicAuth). In this setup, it's exposed on the `websecure` entrypoint and requires TLS.
*   **Local Access Only**: For development, it's configured for local access only via `traefik.<DEV_DOMAIN>`. Do not expose it publicly without proper authentication and authorization.

<h3>Common Pitfalls</h3>

*   **Service not appearing in Traefik Dashboard**:
    *   Ensure your service is connected to the `proxy` network in `docker-compose.yml`.
    *   Double-check that `traefik.enable=true` label is set.
    *   Verify there are no typos in your Traefik labels.
    *   Check `make logs traefik` for any Traefik configuration errors.
*   **`my-new-service.<DEV_DOMAIN>` does not resolve**: Review your `/etc/hosts` configuration for the new domain.
*   **`404 Not Found` or `Bad Gateway`**:
    *   Check the `loadbalancer.server.port` label in your `docker-compose.yml` matches the port your application is listening on *inside* its container.
    *   Ensure your service container is running (`docker ps`).
    *   Examine Traefik logs (`make logs traefik`) for routing errors.
