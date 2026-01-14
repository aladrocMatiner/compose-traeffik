# Guide Template

This template provides a consistent structure for procedural guides, such as TLS mode configurations or how-to articles.

---

## <Guide Title>

### Purpose / Scope

Briefly explain the goal of this guide and who it's intended for. What problem does it solve or what task does it accomplish?

### Prerequisites

List any requirements that must be met *before* starting this guide. This could include:
*   Software installations (e.g., `openssl`, `curl`)
*   Network configurations (e.g., open ports, public IP)
*   Previous steps completed (e.g., "You must have completed the [Quickstart Guide](../quickstart-mode-a.md)")
*   Environment variables set in `.env` (e.g., `ACME_EMAIL`)

### Steps

Follow these steps to complete the task. Each step should be clear, concise, and copy/paste-friendly.

1.  **Step 1 Action**
    Brief description of the action.
    ```bash
    # Command 1 to execute
    # Command 2 to execute (if multi-line)
    ```
    *   Explanation or notes for the step.

2.  **Step 2 Action**
    ... and so on.

### Expected Result

Describe what the outcome should look like after successfully completing all steps. This might include:
*   A service becoming accessible.
*   New files being generated.
*   A specific log message appearing.
*   A browser showing a valid certificate.

### Verification Commands

Provide specific commands that users can run to confirm the expected result.

```bash
# Command to verify success
```
*   Explain what output to look for to confirm verification.

### Rollback / Disable Instructions (if applicable)

If this guide makes a significant configuration change, provide clear instructions on how to revert or disable the changes.

### Common Pitfalls and Troubleshooting

List common issues that users might encounter when following this guide, along with their causes, diagnosis steps, and fixes.

*   **Symptom**:
    *   **Cause**:
    *   **Diagnose**:
    *   **Fix**:

### Links to Related Documentation

*   [Glossary](../99-glossary.md)
*   [Troubleshooting Guide](../08-troubleshooting.md)
*   [Relevant Service Documentation](../04-services/<service_name>.md)
