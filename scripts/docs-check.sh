#!/bin/bash
# Validate multilingual README structure and links.

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(cd "${SCRIPT_DIR}/.." && pwd)
MANIFEST_PATH="${REPO_ROOT}/docs.manifest.json"

if [ ! -f "$MANIFEST_PATH" ]; then
  echo "ERROR: Manifest not found at ${MANIFEST_PATH}" >&2
  exit 1
fi

REPO_ROOT="$REPO_ROOT" python3 - <<'PY'
import json
import os
import re
import sys

repo_root = os.environ.get("REPO_ROOT")
if not repo_root:
    print("ERROR: REPO_ROOT is not set", file=sys.stderr)
    sys.exit(1)
manifest_path = os.path.join(repo_root, "docs.manifest.json")

with open(manifest_path, "r", encoding="utf-8") as f:
    manifest = json.load(f)

languages = manifest["languages"]
root_files = manifest["root"]["files"]
root_anchors = manifest["root"]["anchors"]
service_anchors = manifest["servicePage"]["anchors"]
services = manifest["services"]

selector_line = "[English](README.md) | [Svenska](README.sv.md) | [Espanol](README.es.md)"

errors = []

def read_file(path):
    with open(path, "r", encoding="utf-8") as f:
        return f.read()

def first_non_empty_line(text):
    for line in text.splitlines():
        if line.strip():
            return line.strip()
    return ""

def check_selector(path):
    text = read_file(path)
    first_line = first_non_empty_line(text)
    if first_line != selector_line:
        errors.append(f"Missing or incorrect language selector in {path}")

def check_anchors(path, anchors):
    text = read_file(path)
    for anchor in anchors:
        token = f"<a id=\"{anchor}\"></a>"
        if token not in text:
            errors.append(f"Missing anchor '{anchor}' in {path}")

def check_root_service_links(lang, path):
    text = read_file(path)
    suffix = ".md" if lang == "en" else f".{lang}.md"
    for svc in services:
        slug = svc["slug"]
        expected = f"services/{slug}/README{suffix}"
        if expected not in text:
            errors.append(f"Missing service link '{expected}' in {path}")

        # Disallow other language links for service pages in root docs.
        for other in languages:
            if other == lang:
                continue
            other_suffix = ".md" if other == "en" else f".{other}.md"
            wrong = f"services/{slug}/README{other_suffix}"
            if wrong in text:
                errors.append(f"Wrong-language service link '{wrong}' in {path}")

def check_internal_links(lang, path):
    text = read_file(path)
    lines = text.splitlines()
    link_re = re.compile(r"\[[^\]]+\]\(([^)]+)\)")

    selector_index = None
    for i, line in enumerate(lines):
        if line.strip() == selector_line:
            selector_index = i
            break

    for i, line in enumerate(lines):
        if selector_index is not None and i == selector_index:
            continue
        for match in link_re.findall(line):
            if "README" not in match:
                continue
            if match.endswith("README.md"):
                if lang != "en":
                    errors.append(f"Non-{lang} link to README.md in {path}")
            if match.endswith("README.sv.md"):
                if lang != "sv":
                    errors.append(f"Non-{lang} link to README.sv.md in {path}")
            if match.endswith("README.es.md"):
                if lang != "es":
                    errors.append(f"Non-{lang} link to README.es.md in {path}")

# Check root files exist and validate.
for lang, rel_path in root_files.items():
    path = os.path.join(repo_root, rel_path)
    if not os.path.exists(path):
        errors.append(f"Missing root README for {lang}: {rel_path}")
        continue
    check_selector(path)
    check_anchors(path, root_anchors)
    check_root_service_links(lang, path)
    check_internal_links(lang, path)

# Check service files exist and validate.
for svc in services:
    slug = svc["slug"]
    for lang in languages:
        filename = "README.md" if lang == "en" else f"README.{lang}.md"
        rel_path = os.path.join("services", slug, filename)
        path = os.path.join(repo_root, rel_path)
        if not os.path.exists(path):
            errors.append(f"Missing service README for {slug} ({lang}): {rel_path}")
            continue
        check_selector(path)
        check_anchors(path, service_anchors)
        check_internal_links(lang, path)

if errors:
    for err in errors:
        print(f"ERROR: {err}")
    sys.exit(1)

print("docs-check: OK")
PY
