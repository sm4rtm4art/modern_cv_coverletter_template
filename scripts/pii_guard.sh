#!/usr/bin/env bash
# ============================================================================
# pii_guard.sh — Scan .tex/.cls files for potential PII leaks.
#
# Two-layer protection:
#   1. BLOCKLIST: Exact strings from .pii_blocklist that must NEVER appear
#      in tracked files (your real name, phone, email, address, etc.)
#   2. PATTERN:   Regex patterns for phone numbers, emails, and street
#      addresses, with a whitelist for known template placeholders.
#
# Setup: Create .pii_blocklist in the repo root (gitignored) with one
# personal string per line. Example:
#   Martin Kärgell
#   +49 170 realphone
#   real.email@provider.com
#   Realstraße 42
#
# Usage (standalone):  scripts/pii_guard.sh file1.tex file2.tex ...
# Usage (pre-commit):  configured in .pre-commit-config.yaml
# ============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "${SCRIPT_DIR}/.." && pwd)"
BLOCKLIST_FILE="${ROOT_DIR}/.pii_blocklist"

# ---------------------------------------------------------------------------
# Whitelisted patterns (template placeholder values safe to commit).
# ---------------------------------------------------------------------------
WHITELIST_PATTERNS=(
  'Mustermänn'
  'Mustermann'
  'Karl Märks'
  'ACME GmbH'
  'Musterstraße'
  'Hauptstraße 101'
  'noone@posteo\.de'
  '\+49 150 1234561'
  'D-12345'
  '\\address\{'
  '\\phone\{'
  '\\mobile\{'
  '\\email\{'
  '\\recipientstreet\{'
  '\\recipientcity\{'
  'linkedin\.com'
  'github\.com'
  'posteo\.de'
  'example\.com'
  'example\.org'
  'TODO'
  'Kussbrause'
)

# ---------------------------------------------------------------------------
# PII detection patterns (extended regex).
# ---------------------------------------------------------------------------
PHONE_PATTERN='\+[0-9]{1,3}[ -]?[0-9]{2,4}[ -]?[0-9]{4,10}'
EMAIL_PATTERN='[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}'
STREET_PATTERN='[A-ZÄÖÜ][a-zäöüß]+(straße|str\.|weg|platz|allee|ring|damm|gasse)[ ]+[0-9]'

found_pii=0

is_whitelisted() {
  local line="$1"
  for wl in "${WHITELIST_PATTERNS[@]}"; do
    if echo "$line" | grep -qEi "$wl"; then
      return 0
    fi
  done
  return 1
}

# ---------------------------------------------------------------------------
# Layer 1: Blocklist check (exact personal strings)
# ---------------------------------------------------------------------------
check_blocklist() {
  if [[ ! -f "$BLOCKLIST_FILE" ]]; then
    return 0
  fi

  local file="$1"
  while IFS= read -r blocked_string || [[ -n "$blocked_string" ]]; do
    # Skip empty lines and comments.
    [[ -z "$blocked_string" ]] && continue
    [[ "$blocked_string" =~ ^[[:space:]]*# ]] && continue

    if grep -qF "$blocked_string" "$file"; then
      local line_num
      line_num=$(grep -nF "$blocked_string" "$file" | head -1 | cut -d: -f1)
      echo "BLOCKED PII ${file}:${line_num}: contains '${blocked_string}'"
      found_pii=1
    fi
  done < "$BLOCKLIST_FILE"
}

# ---------------------------------------------------------------------------
# Layer 2: Pattern-based check (phone, email, address)
# ---------------------------------------------------------------------------
check_patterns() {
  local file="$1"
  local line_num=0

  while IFS= read -r line || [[ -n "$line" ]]; do
    line_num=$((line_num + 1))

    # Skip comment-only lines.
    if [[ "$line" =~ ^[[:space:]]*% ]]; then
      continue
    fi

    for pattern in "$PHONE_PATTERN" "$EMAIL_PATTERN" "$STREET_PATTERN"; do
      if echo "$line" | grep -qEi "$pattern"; then
        if ! is_whitelisted "$line"; then
          echo "PII? ${file}:${line_num}: ${line}"
          found_pii=1
        fi
      fi
    done
  done < "$file"
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
if [[ $# -eq 0 ]]; then
  echo "Usage: $0 file1.tex [file2.tex ...]" >&2
  exit 1
fi

for f in "$@"; do
  if [[ -f "$f" ]]; then
    check_blocklist "$f"
    check_patterns "$f"
  fi
done

if [[ $found_pii -ne 0 ]]; then
  echo ""
  echo "Potential PII detected! Review the lines above."
  echo ""
  echo "  BLOCKED PII = matched your .pii_blocklist (must be fixed)"
  echo "  PII?        = matched a pattern (review if it's a real leak)"
  echo ""
  echo "If a pattern match is a safe placeholder, add it to WHITELIST_PATTERNS"
  echo "in scripts/pii_guard.sh."
  exit 1
fi

exit 0
