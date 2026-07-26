#!/usr/bin/env bash
# ============================================================================
# new_application.sh — Create a new application folder from a language template.
#
# Creates: applications/<Company>/<Submission>/
# Copies from: applications/_template_<lang>/ (excluding build artifacts)
# Initializes: local git repo inside the new folder for document versioning
#
# Usage:
#   scripts/new_application.sh "Company" "Submission" [de|en]
#   scripts/new_application.sh "Company/Submission" [de|en]
# ============================================================================
set -euo pipefail

# ---------------------------------------------------------------------------
# Constants and paths
# ---------------------------------------------------------------------------
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "${SCRIPT_DIR}/.." && pwd)"

# LaTeX build artifacts to exclude from copy.
EXCLUDE_PATTERNS=(
  '.DS_Store'
  '*.aux' '*.bcf' '*.bbl' '*.blg'
  '*.fdb_latexmk' '*.fls' '*.log'
  '*.nav' '*.out' '*.synctex.gz'
  '*.snm' '*.toc' '*.run.xml'
  '*.xdv' '*.vrb' '*.pdf'
  'missfont.log'
  'build/*'
)

# ---------------------------------------------------------------------------
# Functions
# ---------------------------------------------------------------------------
usage() {
  cat <<'EOF'
Usage:
  scripts/new_application.sh "Company" "Submission" [de|en]
  scripts/new_application.sh "Company/Submission" [de|en]

Examples:
  scripts/new_application.sh "IMEC" "Applied_AI_Researcher_ID12345" en
  scripts/new_application.sh "IMEC/Applied_AI_Researcher_ID12345" en
  scripts/new_application.sh "50Hertz" "Domain_Data_Scientist_ID10395" de

Notes:
  - Creates: applications/<Company>/<Submission>/
  - Copies from: applications/_template_<lang>/
  - Initializes a local git repo for document version control.
  - Skips LaTeX build artifacts and PDFs.
  - Creates an empty sendouts/ folder inside the submission directory.
EOF
}

die() {
  echo "ERROR: $1" >&2
  exit 1
}

info() {
  echo "[INFO] $1"
}

slugify() {
  local s="$1"
  s="${s// /_}"
  s="${s//\//-}"
  echo "$s"
}

# ---------------------------------------------------------------------------
# Argument parsing
# ---------------------------------------------------------------------------
path_or_company="${1:-}"
arg2="${2:-}"
arg3="${3:-}"

if [[ -z "$path_or_company" ]]; then
  usage
  exit 1
fi

company=""
submission=""
lang=""

if [[ "$path_or_company" == *"/"* ]]; then
  company="${path_or_company%%/*}"
  submission="${path_or_company#*/}"
  lang="${arg2:-}"
else
  company="$path_or_company"
  if [[ -z "$arg2" || "$arg2" == "de" || "$arg2" == "en" ]]; then
    die "Missing Submission argument. Run with no arguments for usage help."
  fi
  submission="$arg2"
  lang="${arg3:-}"
fi

# Validate inputs.
[[ -z "$company" ]] && die "Company name must not be empty."
[[ -z "$submission" ]] && die "Submission name must not be empty."

# Default language: German if template exists, else English.
if [[ -z "$lang" ]]; then
  if [[ -d "${ROOT_DIR}/applications/_template_de" ]]; then
    lang="de"
  else
    lang="en"
  fi
fi

if [[ "$lang" != "de" && "$lang" != "en" ]]; then
  die "Unsupported language: '$lang' (expected: de or en)."
fi

# ---------------------------------------------------------------------------
# Template validation
# ---------------------------------------------------------------------------
template="${ROOT_DIR}/applications/_template_${lang}"

if [[ ! -d "$template" ]]; then
  die "Template not found: $template"
fi

# ---------------------------------------------------------------------------
# Create destination
# ---------------------------------------------------------------------------
company_slug="$(slugify "$company")"
submission_slug="$(slugify "$submission")"
dest="${ROOT_DIR}/applications/${company_slug}/${submission_slug}"

if [[ -e "$dest" ]]; then
  die "Destination already exists: $dest"
fi

info "Creating application: ${company_slug}/${submission_slug} (lang=${lang})"
mkdir -p "$dest"

# Build rsync exclude arguments from array.
rsync_excludes=()
for pat in "${EXCLUDE_PATTERNS[@]}"; do
  rsync_excludes+=(--exclude "$pat")
done

rsync -a "${rsync_excludes[@]}" "$template/" "$dest/"

mkdir -p "$dest/sendouts"

# ---------------------------------------------------------------------------
# Initialize local git repo for document version control
# ---------------------------------------------------------------------------
info "Initializing local git repository for document versioning..."

cat > "$dest/.gitignore" <<'GITIGNORE'
# LaTeX build artifacts
*.aux
*.bcf
*.bbl
*.blg
*.fdb_latexmk
*.fls
*.log
*.nav
*.out
*.synctex.gz
*.snm
*.toc
*.run.xml
*.xdv
*.vrb
missfont.log
.DS_Store

# latexmk aux directory (PDF + .synctex.gz stay next to .tex)
build/*
!build/.gitignore

# Keep PDFs in sendouts/, ignore working PDFs
*.pdf
!sendouts/*.pdf
GITIGNORE

(
  cd "$dest"
  git init --quiet
  git add -A
  git commit --quiet -m "Initial template (${lang}) for ${company} / ${submission}"
)

# ---------------------------------------------------------------------------
# Done
# ---------------------------------------------------------------------------
dest_rel="${dest#"${ROOT_DIR}"/}"

echo ""
info "Created new application folder:"
echo "  ${dest_rel}"
echo ""
echo "Next steps:"
echo "  1. Edit the .tex files in ${dest_rel}/"
echo "  2. Compile with latexmk / TeXStudio (magic comments use txs:///latexmk; aux → build/)"
echo "  3. Place final PDFs in ${dest_rel}/sendouts/"
echo "  4. Use 'git -C ${dest_rel} log' to view document history"
