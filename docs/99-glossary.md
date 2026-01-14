# Glossary

This glossary defines key terms and concepts used within the Traefik Docker Compose Edge Stack repository. Consistent use of these terms is crucial for clear and effective communication.

---

*   **ACME (Automated Certificate Management Environment)**: A protocol used by Certificate Authorities (CAs), like Let's Encrypt and step-ca, to automate interactions between CA and a server's ACME client, simplifying certificate issuance and renewal.
*   **ACME Directory**: An endpoint provided by an ACME server (CA) that an ACME client uses to discover the various services offered by that CA (e.g., authorization, new order, revoke certificate). Traefik uses this to obtain certificates.
*   **Certbot**: A free, open-source software tool that automates the process of obtaining and renewing SSL/TLS certificates from Let's Encrypt. It typically runs as a standalone client.
*   **Compose Profiles**: A Docker Compose feature that allows you to enable or disable services based on a profile name. This helps in managing different environments or optional components (e.g., `le` for Let's Encrypt, `stepca` for step-ca).
*   **DEV_DOMAIN**: An environment variable (`.env` file) that defines the base domain name for local development (e.g., `local.test`). Services in the stack will typically be exposed as subdomains of this (e.g., `whoami.$DEV_DOMAIN`).
*   **Docker Provider (Traefik)**: A Traefik provider that integrates directly with the Docker API, dynamically discovering containers and configuring routing rules based on Docker labels.
*   **Entrypoint (Traefik)**: A network listening point in Traefik (e.g., `web` on port 80, `websecure` on port 443). Traffic enters Traefik through entrypoints.
*   **File Provider (Traefik)**: A Traefik provider that loads dynamic configuration (routers, services, middlewares, TLS certificates) from static files (YAML, TOML, JSON) on the filesystem.
*   **Leaf Certificate**: An end-entity certificate that identifies a server or client. It is signed by an intermediate CA, which is ultimately signed by a Root CA. This is the certificate presented to the client during a TLS handshake.
*   **Let's Encrypt**: A free, automated, and open Certificate Authority (CA) that issues publicly trusted SSL/TLS certificates.
*   **Middleware (Traefik)**: Components in Traefik that can modify requests before they are sent to services, or responses before they are sent back to clients. Examples include HTTP-to-HTTPS redirection, security headers, authentication, etc.
*   **Mode A (TLS)**: Refers to the TLS configuration mode using locally generated **self-signed certificates** for development purposes. Not publicly trusted.
*   **Mode B (TLS)**: Refers to the TLS configuration mode using **Let's Encrypt certificates** obtained via Certbot, for publicly trusted certificates.
*   **Mode C (TLS)**: Refers to the TLS configuration mode using **Smallstep step-ca** as an internal ACME server for automated private certificate issuance.
*   **Proxy Network (`traefik-proxy`)**: The Docker network (`traefik-proxy`) to which Traefik and all exposed services (like `whoami`) are connected. This allows Traefik to route traffic to these services using their internal Docker network names.
*   **Root CA (Certificate Authority)**: The ultimate trust anchor in a Public Key Infrastructure (PKI). A Root CA issues certificates to intermediate CAs or directly to end-entities. Its certificate is self-signed.
*   **Router (Traefik)**: A Traefik component that analyzes incoming requests (e.g., host header, path) and decides which service should handle them. Routers are configured with rules and entrypoints.
*   **SAN (Subject Alternative Name)**: An extension to X.509 certificates that allows multiple hostnames (DNS names, IP addresses) to be protected by a single certificate.
*   **Self-Signed Certificate**: A digital certificate signed by the entity it identifies, rather than by a trusted third-party Certificate Authority. Typically used for internal or development environments.
*   **Service (Traefik)**: A Traefik component that points to the actual backend servers or Docker containers that will handle the requests forwarded by a router.
*   **Smallstep `step-ca`**: An open-source, flexible Certificate Authority (CA) that can be used to build a private PKI, including acting as an internal ACME server.
*   **TLS (Transport Layer Security)**: A cryptographic protocol designed to provide communication security over a computer network. It is widely used in applications like web browsing, email, instant messaging, and voice over IP (VoIP). Often referred to by its predecessor, SSL.
*   **Traefik**: An open-source Edge Router that makes publishing services easy. It receives requests and finds out which components are responsible for handling them.
*   **Whoami**: A simple web service often used for testing, which returns information about the request and the host it's running on. In this stack, it serves as a demo service routed by Traefik.
