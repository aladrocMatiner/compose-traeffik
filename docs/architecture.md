# Architecture Overview

**Role: Platform Architect**
*Mission: Guarantee technical correctness and architectural clarity by accurately describing networks, profiles, routing models, and design choices.*

This document provides a high-level overview of the Traefik Docker Compose edge stack's architecture, detailing its network topology, routing model, and key design decisions. Understanding these components is crucial for effective development and troubleshooting within this environment.

<h2>Network Topology</h2>

The core of this edge stack's network design revolves around isolation and efficient communication between Traefik and your services.

<h3>`traefik-proxy` Network</h3>

*   **Purpose**: This is a dedicated, internal Docker network (`traefik-proxy`) used exclusively for communication between the Traefik proxy and all the services it manages.
*   **Isolation**: Services connected to `traefik-proxy` are isolated from the host's network and other Docker networks, enhancing security. Traefik acts as the single entry point.
*   **Service Discovery**: Traefik's Docker provider monitors this network for services with appropriate labels, enabling dynamic routing.

<h3>External Network Access</h3>

*   Traefik itself is exposed to the host system via standard HTTP (port 80) and HTTPS (port 443) ports. These are the only ports directly exposed by the stack for inbound traffic.
*   All other services within the `traefik-proxy` network are not directly exposed to the host or external networks, relying on Traefik for ingress.

<h2>Routing Model</h2>

Traefik implements a dynamic routing model based on Docker service labels.

<h3>Key Components</h3>

*   **Entrypoints**: Traefik listens for incoming connections on configured entrypoints. By default, these are `web` (HTTP on port 80) and `websecure` (HTTPS on port 443).
*   **Routers**: A router evaluates incoming requests against defined rules (e.g., `Host()`, `PathPrefix()`). When a rule matches, the router forwards the request to a service.
    *   **HTTP Routers**: Typically configured to redirect HTTP traffic to their HTTPS counterparts using the `redirect-to-https@file` middleware.
    *   **HTTPS Routers**: Securely handle requests over TLS, often applying security headers via `security-headers@file` middleware.
*   **Services**: These represent your Docker containers or container groups. Traefik forwards requests to these services.
*   **Middlewares**: Modify requests or responses. Common middlewares in this stack include:
    *   `redirect-to-https@file`: Forces all HTTP traffic to HTTPS.
    *   `security-headers@file`: Adds recommended security headers to responses.

<h3>Dynamic Configuration Flow</h3>

1.  A request arrives at Traefik's `web` (HTTP) or `websecure` (HTTPS) entrypoint.
2.  Traefik's Docker provider detects services within the `traefik-proxy` network based on their Docker Compose labels.
3.  Labels on your service define Traefik **routers**, **services**, and **middlewares**.
4.  If an HTTP router matches, it uses the `redirect-to-https` middleware.
5.  If an HTTPS router matches, it determines the correct **service** and applies any associated **middlewares** (like `security-headers`) before forwarding the request.
6.  The request reaches your application container within the `traefik-proxy` network.

<h2>Design Choices and Rationale</h2>

Several key design decisions underpin this edge stack's architecture, prioritizing security, flexibility, and ease of use in a development context.

<h3>1. Dedicated `traefik-proxy` Network</h3>

*   **Rationale**: Enhances security by isolating application services from direct public exposure. Only Traefik needs its ports open to the outside world. It also simplifies service discovery within the Traefik ecosystem.

<h3>2. `exposedByDefault=false` for Docker Provider</h3>

*   **Rationale**: In `traefik/traefik.yml`, the Docker provider is configured with `exposedByDefault=false`. This is a critical security decision. By default, Traefik will *not* expose any Docker service unless it explicitly has the label `traefik.enable=true`.
*   **Benefit**: Prevents accidental exposure of internal or auxiliary services (like databases, Redis, etc.) that should not be routed externally by Traefik. You must explicitly opt-in each service you want Traefik to manage.

<h3>3. Separation of Static and Dynamic Configuration</h3>

*   **Rationale**: Improves maintainability and allows for hot-reloading of routing rules.
    *   `traefik.yml`: Contains static, infrequently changing settings (entrypoints, providers).
    *   `dynamic/`: Contains dynamic configurations for TLS, middlewares, etc., which Traefik can update without a full restart.

<h3>4. Support for Multiple TLS Modes (A, B, C)</h3>

*   **Rationale**: Provides flexibility for various development and deployment scenarios:
    *   **Mode A (Local Self-Signed)**: Quick and easy for pure local development, no internet access required.
    *   **Mode B (Let's Encrypt)**: For services requiring publicly trusted certificates in testing or staging environments, leveraging automation.
    *   **Mode C (Smallstep `step-ca`)**: Ideal for internal services or private networks where automated, custom CA-issued certificates are needed.

<h3>5. `Makefile` and Helper Scripts</h3>

*   **Rationale**: Streamlines common operations, reduces cognitive load, and enforces consistent command usage. The `Makefile` acts as a facade, abstracting complex `docker compose` commands and script invocations.

<h2>Verified Diagrams / Explanations</h2>

Future iterations of this documentation may include visual diagrams to further clarify the network and routing architecture. For now, the textual descriptions provide the foundational understanding.
