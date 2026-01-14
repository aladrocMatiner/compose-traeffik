# TLS Mode C: Smallstep `step-ca` as Internal ACME Server

**Role: TLS / PKI Specialist**
*Mission: Document `step-ca` bootstrap, ACME directory, trust root, and Traefik resolver usage for internal ACME.*

This guide explains how to enable and operate TLS Mode C, which uses Smallstep `step-ca` as a private Certificate Authority that also functions as an ACME server. This mode is particularly useful for internal services, private networks, or development environments where public trust is not required, but automated certificate management is desired.

<h2>How it works</h2>

The `stepca` Docker Compose profile brings up a `step-ca` service. This service:
1.  **Bootstraps a Private CA**: Initializes a private Certificate Authority.
2.  **Exposes an ACME Provisioner**: Acts as an ACME server, allowing clients (like Traefik) to request certificates.
3.  **Traefik Integration**: Traefik is configured to use its internal ACME client, but instead of connecting to a public ACME provider like Let's Encrypt, it connects to the internal `step-ca` service's ACME endpoint.

<h2>Prerequisites</h2>

*   **`DEV_DOMAIN` configured**: Ensure your `.env` file has `DEV_DOMAIN` set and your host system's `/etc/hosts` file maps `step-ca.<DEV_DOMAIN>` to `127.0.0.1` (refer to [Requirements and Host Configuration](../requirements.md)).
*   **CA Passwords**: For bootstrapping `step-ca`, you need to set `STEP_CA_ADMIN_PROVISIONER_PASSWORD` and `STEP_CA_PASSWORD` in your `.env` file. These are used only during the initial setup.
*   **`TLS_CERT_RESOLVER`**: Ensure `TLS_CERT_RESOLVER=stepca-resolver` is set in your `.env` to enable Traefik's `step-ca` ACME resolver.

<h2>Steps</h2>

1.  **Configure `.env`**:
    Ensure your `.env` file contains the following (replace with strong, unique passwords):
    ```ini
    STEP_CA_ADMIN_PROVISIONER_PASSWORD="your_admin_password"
    STEP_CA_PASSWORD="your_ca_password"
    TLS_CERT_RESOLVER=stepca-resolver
    ```

2.  **Bring up and Bootstrap the `step-ca` service**:
    It's important to bootstrap the `step-ca` service first.
    ```bash
    COMPOSE_PROFILES=stepca make up step-ca # Start only the step-ca service initially
    make stepca-bootstrap                   # Then bootstrap it
    ```
    The `make stepca-bootstrap` command will:
    *   Initialize the `step-ca` server.
    *   Create an ACME provisioner.
    *   Output the ACME Directory URL.
    *   Place the `step-ca` root certificate (`step-ca/config/ca.crt`) in the `step-ca/config` directory.

    > **Note:** If the `step-ca` service is not running when `make stepca-bootstrap` is executed, the script will attempt to start it.

3.  **Trust the `step-ca` Root Certificate (One-Time Setup)**:
    For your browser and `curl` to trust certificates issued by your private `step-ca`, you *must* manually add the `step-ca` root certificate (`step-ca/config/ca.crt`) to your operating system's trust store. This is similar to Mode A.

    *   **macOS**: Open `step-ca/config/ca.crt`, add it to Keychain Access, and set it to "Always Trust".
    *   **Linux (Debian/Ubuntu)**:
        ```bash
        sudo cp step-ca/config/ca.crt /usr/local/share/ca-certificates/step_ca.crt
        sudo update-ca-certificates
        ```
    *   **Windows**: Double-click `step-ca/config/ca.crt`, select "Install Certificate", choose "Local Machine", and place it in the "Trusted Root Certification Authorities" store.

    > **Warning:** Skipping this step will result in browser warnings (e.g., `NET::ERR_CERT_AUTHORITY_INVALID`) and `curl` errors regarding untrusted certificates.

4.  **Bring up the full stack with the `stepca` profile**:
    ```bash
    COMPOSE_PROFILES=stepca make up
    ```
    Traefik will now start and attempt to obtain certificates for `whoami.<DEV_DOMAIN>`, `traefik.<DEV_DOMAIN>`, and `step-ca.<DEV_DOMAIN>` from your internal `step-ca` server.

<h2>Expected Result</h2>

*   Your services should be accessible via HTTPS with certificates issued by your private `step-ca`.
*   Your browser should display a valid padlock icon, indicating a secure connection (after trusting the CA).
*   Traefik logs should show successful certificate acquisition messages from the `step-ca` ACME endpoint.

<h2>Verification</h2>

1.  **Check Traefik Dashboard**:
    Navigate to `https://traefik.<DEV_DOMAIN>/dashboard/` and inspect the TLS configurations. You should see certificates associated with your domains, issued by your `step-ca` (e.g., "Step Certificates").

2.  **Access your service via browser**:
    Open `https://whoami.<DEV_DOMAIN>` (or your new service's domain) in a browser. Verify the connection is secure and the certificate details show your `step-ca` as the issuer.

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

<h2>Common Pitfalls</h2>

*   **`step-ca` not bootstrapped**: Ensure you have successfully run `make stepca-bootstrap` and that the `step-ca` container is running without errors. Check `make logs step-ca`.
*   **CA Certificate Not Trusted**: Similar to Mode A, if you haven't trusted `step-ca/config/ca.crt` in your OS trust store, you will encounter certificate warnings.
*   **`DEV_DOMAIN` mismatch**: Ensure the `DEV_DOMAIN` in your `.env` file matches the domain used in your `/etc/hosts` configuration for `step-ca.<DEV_DOMAIN>`.
*   **Traefik Logs indicate ACME errors**: Check `make logs traefik` for detailed error messages. These might indicate issues with `step-ca`'s ACME endpoint or Traefik's configuration.
*   **Lost `step-ca/secrets`**: If you lose the `step-ca/secrets` volume, you'll need to re-bootstrap the `step-ca`. This will invalidate previously issued certificates, requiring new ones to be issued.
