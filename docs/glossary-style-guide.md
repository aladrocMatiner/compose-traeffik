# Glossary and Style Guide

## Glossary

This section defines key terms used throughout the documentation to ensure consistent understanding.

*   **Edge Stack**: A collection of services, typically including a reverse proxy (like Traefik), that handles incoming requests at the edge of a network, often providing routing, load balancing, and TLS termination.
*   **Traefik**: An open-source Edge Router that makes publishing services a fun and easy experience. It receives requests and finds out which components are responsible for handling them.
*   **TLS (Transport Layer Security)**: A cryptographic protocol designed to provide communications security over a computer network. Often referred to as SSL.
*   **CA (Certificate Authority)**: A trusted entity that issues digital certificates.
*   **Self-Signed Certificate**: A security certificate that is signed by the entity it certifies, rather than by a trusted third-party certificate authority (CA). Used primarily for development or internal systems.
*   **ACME (Automated Certificate Management Environment)**: A protocol for automating interactions between certificate authorities and their users' web servers, allowing for automated deployment of public key infrastructure at a very low cost. (e.g., Let's Encrypt).
*   **Certbot**: A free, open source software tool for automatically using Let's Encrypt certificates on manually-administrated websites to enable HTTPS.
*   **Smallstep `step-ca`**: An open-source, private certificate authority that can act as an ACME server for internal certificate management.
*   **`DEV_DOMAIN`**: An environment variable defined in `.env` that specifies the base domain for local development (e.g., `local.test`).
*   **Service (Docker Compose)**: An isolated containerized application that is part of the larger stack defined in `docker-compose.yml`.
*   **Router (Traefik)**: Defines the conditions under which requests are handled by a service. Routers analyze the incoming request (host, path, headers) to determine which service should receive it.
*   **Entrypoint (Traefik)**: The network port on which Traefik listens for incoming requests. Common entrypoints are `web` (HTTP) and `websecure` (HTTPS).
*   **Middleware (Traefik)**: Components that can modify requests before they are sent to your services, or responses before they are sent back to the client. Examples include redirects, authentication, or header manipulation.
*   **File Provider (Traefik)**: A Traefik provider that reads its configuration from static `.toml`, `.yaml`, or `.json` files. Used here for dynamic configurations like TLS options or middlewares.
*   **Docker Provider (Traefik)**: A Traefik provider that automatically discovers services and applies routing configuration based on Docker labels.
*   **`traefik-proxy` network**: The dedicated Docker network used to connect Traefik to other services, isolating it from the default Docker bridge network.

## Style Guide

This section outlines writing and formatting guidelines for all documentation to ensure consistency and readability.

### General Writing Principles

*   **Clarity and Conciseness**: Use clear, simple language. Avoid jargon where possible, or explain it in the glossary. Get straight to the point.
*   **Audience**: Assume the reader is a developer familiar with Docker and basic networking concepts, but new to this specific stack and Traefik.
*   **Tone**: Professional, helpful, and direct.
*   **"Explain then do"**: For every procedure, briefly explain the concept first, then provide exact, runnable steps.

### Formatting

*   **Headings**: Use ATX style headings (e.g., `# H1`, `## H2`). Follow a logical hierarchy.
*   **Code Blocks**:
    *   Use triple backticks (```) for code blocks.
    *   Specify the language for syntax highlighting (e.g., ````bash`, ````yaml`, ````ini`).
    *   Ensure commands and snippets are directly copy-pastable and runnable.
    *   Include expected output where relevant.
*   **Inline Code**: Use single backticks (`) for inline code, file names, directory names, variable names, and commands.
*   **Lists**: Use ordered lists for sequential steps and unordered lists for features or non-sequential items.
*   **Bold**: Use `**text**` for emphasis.
*   **Links**: Use descriptive link text (e.g., `[Traefik Proxy](https://traefik.io/)` instead of `https://traefik.io/`).
*   **Notes/Warnings**: Use blockquotes for important notes, warnings, or tips.

    ```
    > **Note:** This is an important note.
    ```
    ```
    > **Warning:** This action can have serious consequences.
    ```

### Consistency

*   **Terminology**: Always use terms as defined in the [Glossary](#glossary).
*   **Paths**: Refer to file paths relative to the repository root (e.g., `.env.example`, `certs/local/`).
*   **Variable Names**: Match variable names exactly as they appear in `.env.example` or scripts (e.g., `DEV_DOMAIN`, `COMPOSE_PROFILES`).
*   **Commands**: Ensure all commands are accurate and match `Makefile` targets or script names.
*   **Expected Results/Verification**: Every procedure should clearly state the "Expected Result" and provide "How to Verify" steps.
*   **Troubleshooting**: Embed troubleshooting tips relevant to the section at the end of major guides, or link to the main troubleshooting guide.

### Cross-Linking

*   **README**: The main `README.md` should serve as a high-level entry point, linking to all major documentation files within the `docs/` directory.
*   **Internal Links**: Use relative links for navigation within the documentation set (e.g., `[Architecture Overview](architecture.md)`).
*   **External Links**: Provide links to external resources (e.g., Docker documentation, Traefik website) where appropriate.

### Security Communication

*   Highlight security-by-default decisions.
*   Document how secrets are handled and what sensitive information should NOT be exposed.
*   Explicitly call out potentially unsafe defaults and how this repository mitigates them.
