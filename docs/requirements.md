# Requirements and Host Configuration

**Role: Platform Architect / DevOps UX Engineer**
*Mission: Ensure developers have the necessary tools and host configurations to run the stack successfully.*

This document details the software requirements and host system configurations necessary to run the Traefik Docker Compose edge stack.

## Prerequisites

Ensure you have the following software installed on your system:

*   **Docker**: [Install Docker Desktop](https://www.docker.com/products/docker-desktop/) or Docker Engine. This is essential for running containerized services.
*   **Docker Compose**: Typically bundled with Docker Desktop or installed separately. Used for defining and running multi-container Docker applications.
*   **`make`**: Usually available on Linux/macOS systems. This project uses a `Makefile` for simplifying common development and operational tasks.
*   **`curl`**: A command-line tool for transferring data with URLs. Used for testing HTTP/HTTPS endpoints and verifying service responses.
*   **`openssl`**: A toolkit for the Transport Layer Security (TLS) and Secure Sockets Layer (SSL) protocols. Used for generating local certificates and testing TLS handshakes.

## Host System Configuration

For local development, you'll need to configure your operating system's hosts file to map your chosen `DEV_DOMAIN` (defined in `.env`) to `127.0.0.1`. This allows your browser and tools to resolve your local service domains.

### Steps to Configure `/etc/hosts`

1.  **Identify `DEV_DOMAIN`**:
    Ensure you have copied `.env.example` to `.env` and set your desired `DEV_DOMAIN` value. For example, if `DEV_DOMAIN` is `local.test`.

2.  **Edit your hosts file**: You will need administrator/root privileges to modify this file.

    **Linux/macOS:**
    Open a terminal and run:
    ```bash
    sudo nano /etc/hosts
    ```
    Add the following lines (replace `local.test` with your `DEV_DOMAIN`):
    ```
    # Add the following lines for Traefik Edge Stack services
    127.0.0.1 whoami.local.test
    127.0.0.1 traefik.local.test
    127.0.0.1 step-ca.local.test
    ```
    Save and exit the editor (`Ctrl+X`, `Y`, `Enter` for nano).

    **Windows:**
    1.  Open Notepad or your preferred text editor as an **Administrator**. To do this, search for the editor, right-click, and select "Run as administrator".
    2.  In the editor, open the file: `C:\Windows\System32\drivers\etc\hosts`.
    3.  Add the following lines (replace `local.test` with your `DEV_DOMAIN`):
        ```
        # Add the following lines for Traefik Edge Stack services
        127.0.0.1 whoami.local.test
        127.0.0.1 traefik.local.test
        127.0.0.1 step-ca.local.test
        ```
    4.  Save the file.

## Expected Result

After configuring your hosts file, you should be able to ping your development domains (e.g., `whoami.local.test`) and see them resolve to `127.0.0.1`.

## Verification

Open your terminal and try to ping one of the configured domains:

```bash
ping -c 1 whoami.<DEV_DOMAIN>
# Example: ping -c 1 whoami.local.test
```

The output should show that the domain resolves to `127.0.0.1`.

## Common Pitfalls

*   **`ping` command fails or resolves to an incorrect IP**: Double-check that you have saved the changes to your hosts file and that there are no typos. Ensure you have administrator/root privileges when editing the file.
*   **Changes not taking effect immediately**: Sometimes, DNS caches need to be flushed.
    *   **macOS**: `sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder`
    *   **Linux**: `sudo systemd-resolve --flush-caches` or `sudo /etc/init.d/nscd restart` (depending on distribution)
    *   **Windows**: `ipconfig /flushdns`
*   **`DEV_DOMAIN` mismatch**: Ensure the `DEV_DOMAIN` in your `.env` file matches the domain used in your `/etc/hosts` configuration.
