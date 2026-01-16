# Documentation Quality Checklist

This checklist is a mandatory tool for reviewing and ensuring the quality of all documentation changes before they are merged. It helps maintain accuracy, consistency, and a high standard of user experience.

---

## 1. Accuracy Checks

*   [ ] **Commands Validation**: Every command shown (e.g., `make <target>`, `docker compose <command>`, `scripts/<script>.sh`, `curl <url>`) exists and works as described in the current repository.
    *   *Self-check*: Execute a sample of commands from the PR description to confirm functionality.
*   [ ] **Environment Variable Validation**: Every environment variable mentioned in the documentation exists in `.env.example` and is referenced correctly (e.g., `DEV_DOMAIN`, not `MY_DOMAIN`).
*   [ ] **Path Validation**: Every file or directory path referenced (e.g., `services/traefik/traefik.yml`, `services/traefik/dynamic/middlewares.yml`, `shared/certs/local-ca/ca.crt`) actually exists in the repository structure.
*   [ ] **Compose Profiles & Networks**: Docker Compose profile names (`le`, `stepca`, `dns`) and network names (`traefik-proxy`, `stepca-internal`) match the files under `compose/base.yml` and `services/<service>/compose.yml` and are consistent with `docs/90-facts.md`.

## 2. Content Checks

*   [ ] **Consistent Structure**: Each guide or service documentation follows the structure defined in the [Style Guide](99-style-guide.md) (e.g., "Purpose", "Prerequisites", "Steps", "Expected Result", "Verification", "Common Pitfalls").
*   [ ] **Copy/Paste-First Examples**: All code and command examples are directly copy/paste-able and executable. They avoid `$` or `>` prompts.
*   [ ] **Safe-by-Default Examples**: Examples reflect secure practices (e.g., `cp .env.example .env`).
*   [ ] **Security Callouts**: Relevant security considerations (e.g., Traefik dashboard exposure, handling private keys, network isolation) are clearly highlighted and explained where appropriate.
*   [ ] **"Expected Result" & "Verification"**: Every procedural guide (especially quickstarts and TLS modes) includes clear descriptions of the expected outcome and specific commands to verify success.
*   [ ] **"Common Pitfalls"**: Each major guide includes a section for common issues, their causes, diagnosis, and fixes.
*   [ ] **Glossary Usage**: Technical terms are consistently used as defined in the [Glossary](99-glossary.md), or new terms are added.

## 3. Link Checks

*   [ ] **Internal Links Validity**: All internal links between documentation files (e.g., `[Glossary](99-glossary.md)`) are valid and point to existing targets.
*   [ ] **"Planned" Docs**: Any documentation section or file that is still "planned" or "coming next" is clearly marked as such and *not* linked if the file does not yet exist.

## 4. Review Workflow

*   [ ] **`make help` Consistency**: Run `make help` and verify that any `Makefile` targets mentioned in the documentation are present and described accurately.
*   [ ] **`make test` Verification**: If changes impact core functionality, run `make test` (or relevant specific tests) to ensure everything is still working as expected.
*   [ ] **Spot-check commands**: Randomly pick a few `curl` or `openssl` commands from the documentation and execute them to verify their output.
*   [ ] **Readability & Tone**: The documentation is easy to read, uses an appropriate tone, and adheres to the writing style defined in the [Style Guide](99-style-guide.md).
