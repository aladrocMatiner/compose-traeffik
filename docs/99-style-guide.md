# Documentation Style Guide

This guide outlines the conventions and best practices for writing clear, consistent, and high-quality documentation for the Traefik Docker Compose Edge Stack repository. Adhering to these guidelines ensures a uniform user experience and simplifies maintenance.

---

## 1. Structure and Headings

Maintain a consistent document structure for all major guides and service documentation.

*   **Top-level headings (H1)**: Use only once per document for the main title.
*   **Subheadings (H2, H3, H4)**: Use to organize content logically.
*   **Consistent Sections**: For guides and service docs, use the following sections where applicable:
    *   **Purpose / When to use**: Briefly explain the document's goal or the component's function.
    *   **Prerequisites**: List any software, configuration, or prior steps required.
    *   **Steps**: Detailed, numbered instructions for a procedure.
    *   **Expected Result**: Describe what should happen after executing steps.
    *   **Verification Commands**: Provide commands to confirm success.
    *   **Common Pitfalls**: Highlight typical issues and how to avoid them.
    *   **Links to Related Docs**: Cross-reference other relevant documentation.

---

## 2. Language and Tone

*   **Clear and Concise**: Use plain language, avoid jargon where possible, and explain technical terms (or link to the glossary).
*   **Action-Oriented**: Use imperative verbs for instructions (e.g., "Install," "Configure," "Run").
*   **Consistent Terminology**: Always use terms as defined in the [Glossary](99-glossary.md).
*   **Tone**: Professional, helpful, and direct.

---

## 3. Code and Command Formatting

*   **Copy/Paste-First**: All command-line instructions and code snippets must be directly copy/paste-able and executable.
    *   Use triple backticks (```bash) for multi-line commands or code blocks.
    *   Use single backticks (`` `command` ``) for inline commands or file names.
*   **Avoid `$ `**: Do not include `$` or `>` prefixes in command examples; users should be able to paste directly.
*   **File Paths**: Always use relative paths within the repository (e.g., `scripts/up.sh`, `traefik/traefik.yml`).
*   **Environment Variables**:
    *   Always refer to environment variables by their name as they appear in `.env.example` (e.g., `DEV_DOMAIN`, `TRAEFIK_IMAGE`).
    *   When showing a command that uses an env var, use shell syntax (e.g., `echo $DEV_DOMAIN`).
    *   When describing a variable, use `DEV_DOMAIN` (code block) for the name.

### Example Conventions

To ensure consistency and accuracy, adhere to these conventions when presenting examples:

*   **Initial Setup**: Always show `cp .env.example .env` as the first step for local configuration.
    ```bash
    cp .env.example .env
    ```
*   **Environment Variable Usage**: Use actual environment variable names (e.g., `$DEV_DOMAIN`) in command examples, rather than hardcoding values.
    ```bash
    echo "Accessing whoami at: https://whoami.$DEV_DOMAIN"
    ```
*   **Profile Usage Pattern**: When demonstrating Docker Compose profile activation, use the `COMPOSE_PROFILES=<profile_name> make <target>` pattern.
    ```bash
    COMPOSE_PROFILES=le make up
    ```
*   **Verification Commands**: For HTTP/HTTPS verification, use `curl -vk https://<hostname>/` (or similar) adapting to the specific hostname variable.
    ```bash
    curl -vk "https://whoami.$DEV_DOMAIN/"
    ```
*   **Grounding in Facts**: All examples must align with the factual details documented in `docs/90-facts.md` (e.g., correct make targets, script names, network names).

---

## 4. Security Callouts

Security is paramount. Highlight any security-related decisions or implications.

*   **Secure-by-Default**: Document *why* certain choices are secure-by-default (e.g., Traefik dashboard disabled, `exposedByDefault: false`).
*   **Warnings**: Use `**WARNING:**` or `**IMPORTANT:**` for critical security advisories (e.g., "Do not expose X publicly", "Handle secrets carefully").
*   **Sensitive Data**: Provide guidance on managing sensitive data (e.g., certificate private keys, passwords for `step-ca`).

---

## 5. Troubleshooting Style

Adopt a structured approach for troubleshooting sections:

*   **Symptom**: Describe the problem clearly (e.g., "Browser shows certificate warning," "Service not reachable").
*   **Cause**: Explain the most common reasons for the symptom.
*   **Diagnose**: Provide commands or steps to identify the root cause.
*   **Fix**: Offer clear, actionable solutions.

---

## 6. Cross-Linking

*   **Internal Links**: Link generously within the documentation set using relative paths (e.g., `[Glossary](99-glossary.md)`).
*   **External Links**: Use when referencing external resources (e.g., Docker documentation, Traefik docs).
*   **Consistent Anchors**: Use `[Link text](#heading-slug)` for internal page anchors.

---

## 7. Review Checklist

Before publishing, ensure documentation meets these criteria:

*   Does it achieve its stated purpose?
*   Are all instructions clear, concise, and copy/paste-ready?
*   Are all commands and file paths accurate and functional?
*   Are environment variables correctly referenced?
*   Are security implications clearly explained and warned against?
*   Is the terminology consistent with the Glossary?
*   Are all internal links valid?
*   Is the tone appropriate and professional?
