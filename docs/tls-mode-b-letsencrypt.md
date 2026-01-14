# TLS Mode B: Let's Encrypt via Certbot

**Role: TLS / PKI Specialist**
*Mission: Document certificate issuance and renewal prerequisites and operational steps using Certbot with Let's Encrypt.*

This guide explains how to enable and operate TLS Mode B, which utilizes Certbot to obtain publicly trusted certificates from Let's Encrypt. This mode is suitable for public-facing services that require widely recognized TLS certificates.

<h2>How it works</h2>

The `le` Docker Compose profile adds a `certbot` service to your stack. This service is responsible for:
1.  **Domain Verification**: Using the HTTP-01 challenge, Certbot proves ownership of your domain(s) to Let's Encrypt. This requires your server to be publicly accessible on ports 80 and 443.
2.  **Certificate Issuance**: Once verified, Certbot obtains the TLS certificates and stores them in the `certbot/conf/` directory.
3.  **Traefik Integration**: Traefik is configured to use an ACME (Automated Certificate Management Environment) resolver. When `TLS_CERT_RESOLVER` is set to `le-resolver`, Traefik automatically requests and manages certificates from Let's Encrypt using the ACME protocol, storing them internally.

<h2>Prerequisites</h2>

*   **Publicly Accessible Domain**: You must own and control the domain(s) you wish to secure (e.g., `whoami.<DEV_DOMAIN>`). These domains must point to the public IP address of the machine running this stack.
*   **Open Ports**: Ports 80 (HTTP) and 443 (HTTPS) on your server must be open and accessible from the internet for Certbot to complete the HTTP-01 challenge.
*   **Email Address**: A valid email address is required for Let's Encrypt registration and urgent notices. Set this in your `.env` file via `ACME_EMAIL`.
*   **`LETSENCRYPT_STAGING`**: For initial testing, it is **highly recommended** to set `LETSENCRYPT_STAGING=true` in your `.env` file to avoid hitting Let's Encrypt rate limits. Change to `false` only when you are ready for production certificates.
*   **`TLS_CERT_RESOLVER`**: Ensure `TLS_CERT_RESOLVER=le-resolver` is set in your `.env` to enable Traefik's Let's Encrypt ACME resolver.

<h2>Steps</h2>

1.  **Configure `.env`**:
    Ensure your `.env` file contains the following (replace with your actual email and desired staging setting):
    ```ini
    ACME_EMAIL="your_email@example.com"
    LETSENCRYPT_STAGING=true # Set to false for production certs after successful testing
    TLS_CERT_RESOLVER=le-resolver
    ```

2.  **Bring up the stack with the `le` profile**:
    ```bash
    COMPOSE_PROFILES=le make up
    ```
    This command starts Traefik and your services, enabling the `certbot` container or configuring Traefik to use its internal ACME client for Let's Encrypt.

3.  **Monitor Traefik for Certificate Acquisition**:
    Traefik should automatically attempt to acquire certificates for any domains specified in your service labels (e.g., for `whoami.<DEV_DOMAIN>`). You can monitor the Traefik logs for this process:
    ```bash
    make logs traefik
    ```
    Look for messages indicating certificate acquisition or errors from the ACME client.

4.  **Issue Certificates via Certbot (if using the external Certbot service)**:
    If you've explicitly added a `certbot` service and labels to `docker-compose.yml` to trigger Certbot externally (rather than relying solely on Traefik's internal ACME client), you might need to run:
    ```bash
    make certs-le-issue
    ```
    Follow any prompts from Certbot. This will obtain certificates and place them in `certbot/conf/`. Traefik will then pick up these new certificates.

<h2>Expected Result</h2>

*   Your services should be accessible via HTTPS with certificates issued by Let's Encrypt (either staging or production).
*   Your browser should display a valid padlock icon, indicating a secure connection.
*   Traefik logs should show successful certificate acquisition messages.

<h2>Verification</h2>

1.  **Check Traefik Dashboard**:
    Navigate to `https://traefik.<DEV_DOMAIN>/dashboard/` and inspect the TLS configurations. You should see certificates associated with your domains, issued by `(STAGING) Let's Encrypt` or `Let's Encrypt`.

2.  **Access your service via browser**:
    Open `https://whoami.<DEV_DOMAIN>` (or your new service's domain) in a browser. Verify the connection is secure and the certificate details show Let's Encrypt as the issuer.

3.  **Verify with `curl`**:
    ```bash
    curl -v https://whoami.<DEV_DOMAIN> 2>&1 | grep "SSL certificate"
    ```
    You should see output similar to:
    ```
    *  SSL certificate verify ok.
    *  subjectAltName: host "whoami.<DEV_DOMAIN>" matched "whoami.<DEV_DOMAIN>"
    *  SSL certificate: <your_domain_certificate>
    ```

<h2>Certificate Renewal</h2>

Let's Encrypt certificates are typically valid for 90 days. You need to renew them regularly.

<h3>Steps for Renewal</h3>

1.  **Automated Renewal**:
    If relying on Traefik's internal ACME client, Traefik handles renewals automatically. Ensure your stack is running, and Traefik will attempt renewal when certificates are close to expiration.

2.  **Manual/Scripted Renewal (if using external Certbot service)**:
    Set up a cron job or similar automation to periodically run:
    ```bash
    COMPOSE_PROFILES=le make certs-le-renew
    ```
    This command can typically be run without stopping the main stack. Traefik will automatically pick up renewed certificates.

<h2>Common Pitfalls</h2>

*   **Domain Not Pointing Correctly**: Ensure your public DNS records (A/AAAA records) for `whoami.<DEV_DOMAIN>` and other services point to the public IP of your server.
*   **Ports 80/443 Blocked**: If Certbot (or Traefik's ACME client) cannot reach your server on ports 80 and 443 from the internet, the HTTP-01 challenge will fail. Check firewall rules.
*   **`ACME_EMAIL` Not Set**: Let's Encrypt requires a contact email.
*   **Rate Limits**: If you try to issue too many certificates for the same domain in a short period, you might hit Let's Encrypt rate limits. Use `LETSENCRYPT_STAGING=true` for testing.
*   **Traefik Logs indicate ACME errors**: Check `make logs traefik` for detailed error messages from Traefik's ACME client. These often provide specific reasons for certificate acquisition failures.
