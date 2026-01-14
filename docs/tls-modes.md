# TLS Modes Overview

**Role: Documentation Lead / TLS / PKI Specialist**
*Mission: Provide a clear overview of available TLS modes and guide users to detailed documentation for each mode.*

This Traefik edge stack is designed to support various TLS (Transport Layer Security) certificate management strategies, allowing developers to choose the most appropriate method for their environment. Three distinct modes are available, catering to local development, public testing, and internal ACME certificate automation.

<h2>Available TLS Modes</h2>

<h3>[Mode A: Local Self-Signed CA + Certificates](quickstart-mode-a.md)</h3>

*   **Purpose**: Ideal for local development environments where publicly trusted certificates are not required.
*   **Description**: Uses a locally generated self-signed Certificate Authority (CA) to issue certificates for your services. These certificates are trusted only after you manually install the local CA's root certificate into your operating system's trust store.
*   **Key Features**:
    *   No public domain or internet access required.
    *   Fast and easy setup for local testing.
    *   Completely isolated from external certificate authorities.
*   **Further Details**: Refer to [Quickstart: Local Self-Signed TLS (Mode A)](quickstart-mode-a.md) for a detailed guide.

<h3>[Mode B: Let's Encrypt via Certbot](tls-mode-b-letsencrypt.md)</h3>

*   **Purpose**: Suitable for public-facing services that require widely recognized and automatically renewed TLS certificates.
*   **Description**: Integrates with Let's Encrypt, a free, automated, and open Certificate Authority, using Certbot or Traefik's internal ACME client to issue and renew certificates. This requires your service to be publicly accessible for domain validation.
*   **Key Features**:
    *   Publicly trusted certificates.
    *   Automated certificate issuance and renewal.
    *   Requires a public domain and open ports 80/443.
*   **Further Details**: Refer to [TLS Mode B: Let's Encrypt via Certbot](tls-mode-b-letsencrypt.md) for a detailed guide.

<h3>[Mode C: Smallstep `step-ca` as Internal ACME Server](tls-mode-c-stepca.md)</h3>

*   **Purpose**: Designed for internal services, private networks, or enterprise environments that need automated certificate management using a custom, private Certificate Authority.
*   **Description**: Leverages Smallstep `step-ca` as a private ACME server. Traefik's ACME client communicates with your internal `step-ca` instance to issue certificates. Like Mode A, the `step-ca`'s root certificate must be manually trusted by clients.
*   **Key Features**:
    *   Automated certificate management within a private PKI.
    *   Certificates issued by your own trusted CA.
    *   Does not require public internet access for certificate issuance.
    *   Ideal for microservices in private clouds or VPNs.
*   **Further Details**: Refer to [TLS Mode C: Smallstep `step-ca` as Internal ACME Server](tls-mode-c-stepca.md) for a detailed guide.

<h2>Choosing a TLS Mode</h2>

The choice of TLS mode depends on your specific needs:

*   **Local Development/Testing**: Use **Mode A** for quick setups without external dependencies, or **Mode C** if you want to simulate an enterprise internal PKI.
*   **Public-Facing Applications (Staging/Production)**: Use **Mode B** for publicly trusted certificates.
*   **Internal Services/APIs**: **Mode C** offers automated certificate management within your private infrastructure.
