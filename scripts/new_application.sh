#!/usr/bin/env bash
# ============================================================================
# new_application.sh — Create a new application folder from a language template.
#
# Creates:
#   applications/<Company>/<Submission>/
#
# Copies from:
#   applications/_template_<lang>/
#
# Initializes:
#   - build/ directory for LaTeX auxiliary files
#   - sendouts/ directory for final submitted PDFs
#   - local Git repository for document versioning
#   - blue Finder tag on macOS for active drafts
#   - preferred Finder icon layout
#
# Classes resolve via TEXINPUTS (thin .latexmkrc stub → common/latexmk/latexmkrc)
# with ../../ and ../../../ relative fallbacks if latexmk is not used.
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

APPLICATIONS_DIR="${ROOT_DIR}/applications"
TEMPLATES_DIR="${APPLICATIONS_DIR}"

# Traditional Finder label mapping:
#   1 = orange
#   2 = red
#   3 = yellow
#   4 = blue
#   5 = purple
#   6 = green
#   7 = gray
FINDER_DRAFT_LABEL_INDEX="${FINDER_DRAFT_LABEL_INDEX:-4}"

# Files and directories excluded when copying a template.
EXCLUDE_PATTERNS=(
  '.DS_Store'
  '.git'

  '*.aux'
  '*.bcf'
  '*.bbl'
  '*.blg'
  '*.fdb_latexmk'
  '*.fls'
  '*.log'
  '*.nav'
  '*.out'
  '*.synctex.gz'
  '*.snm'
  '*.toc'
  '*.run.xml'
  '*.xdv'
  '*.vrb'
  '*.pdf'

  'missfont.log'
  'build'
)

# ---------------------------------------------------------------------------
# General helper functions
# ---------------------------------------------------------------------------
usage() {
  cat <<'EOF'
Usage:
  scripts/new_application.sh "Company" "Submission" [de|en]
  scripts/new_application.sh "Company/Submission" [de|en]

Examples:
  scripts/new_application.sh \
    "IMEC" \
    "Applied_AI_Researcher_ID12345" \
    en

  scripts/new_application.sh \
    "IMEC/Applied_AI_Researcher_ID12345" \
    en

  scripts/new_application.sh \
    "50Hertz" \
    "Domain_Data_Scientist_ID10395" \
    de

Notes:
  - Creates: applications/<Company>/<Submission>/
  - Copies from: applications/_template_<lang>/
  - Copies .latexmkrc (TEXINPUTS + aux → build/) from the selected template.
  - Creates build/ and sendouts/.
  - Initializes a local Git repository.
  - Skips existing LaTeX build artifacts and PDFs.
  - Applies a blue Finder tag on macOS.
  - Arranges known files in Finder icon view.
  - Rejects capitalization conflicts such as TEST versus test.
EOF
}

die() {
  echo "ERROR: $1" >&2
  exit 1
}

warn() {
  echo "[WARN] $1" >&2
}

info() {
  echo "[INFO] $1"
}

require_command() {
  local command_name="$1"

  if ! command -v "$command_name" >/dev/null 2>&1; then
    die "Required command not found: ${command_name}"
  fi
}

slugify() {
  local value="$1"

  value="${value// /_}"
  value="${value//\//-}"
  value="${value//:/-}"

  value="$(printf '%s' "$value" | tr -cd '[:alnum:]_.-')"

  printf '%s\n' "$value"
}

canonical_dir() {
  local directory="$1"

  (
    cd "$directory"
    pwd -P
  )
}

casefold_ascii() {
  printf '%s' "$1" | LC_ALL=C tr '[:upper:]' '[:lower:]'
}

# Search for an existing child entry while ignoring ASCII capitalization.
#
# Exact spelling is preferred. This prevents an existing directory such as
# "test" from silently being used when "TEST" was requested.
find_case_insensitive_entry() {
  local parent="$1"
  local requested_name="$2"

  local exact_path="${parent}/${requested_name}"
  local requested_fold=""
  local entry=""
  local entry_name=""
  local entry_fold=""

  if [[ -e "$exact_path" ]]; then
    printf '%s\n' "$exact_path"
    return 0
  fi

  requested_fold="$(casefold_ascii "$requested_name")"

  while IFS= read -r -d '' entry; do
    entry_name="${entry##*/}"
    entry_fold="$(casefold_ascii "$entry_name")"

    if [[ "$entry_fold" == "$requested_fold" ]]; then
      printf '%s\n' "$entry"
      return 0
    fi
  done < <(
    find "$parent" \
      -mindepth 1 \
      -maxdepth 1 \
      -print0
  )

  return 1
}

# ---------------------------------------------------------------------------
# macOS Finder helpers
# ---------------------------------------------------------------------------
apply_finder_tag() {
  local target_path="$1"
  local label_index="$2"

  if [[ "$(uname -s)" != "Darwin" ]]; then
    info "Finder tag skipped: operating system is not macOS."
    return 0
  fi

  if [[ ! -x "/usr/bin/osascript" ]]; then
    warn "Finder tag skipped: /usr/bin/osascript was not found."
    return 0
  fi

  /usr/bin/osascript \
    - "$target_path" "$label_index" \
    >/dev/null <<'APPLESCRIPT'
on run argv
  set targetPath to item 1 of argv
  set targetLabel to (item 2 of argv) as integer
  set targetItem to (POSIX file targetPath) as alias

  tell application "Finder"
    set label index of targetItem to targetLabel
  end tell
end run
APPLESCRIPT
}

arrange_application_icons() {
  local target_path="$1"
  local language="$2"

  local cv_name=""
  local letter_name=""

  if [[ "$(uname -s)" != "Darwin" ]]; then
    info "Finder layout skipped: operating system is not macOS."
    return 0
  fi

  if [[ ! -x "/usr/bin/osascript" ]]; then
    warn "Finder layout skipped: /usr/bin/osascript was not found."
    return 0
  fi

  case "$language" in
    de)
      cv_name="MOCK_Lebenslauf.tex"
      letter_name="MOCK_Bewerbungsanschreiben.tex"
      ;;
    en)
      cv_name="MOCK_curriculum_vitae.tex"
      letter_name="MOCK_cover_letter.tex"
      ;;
    *)
      warn "Finder layout skipped: unsupported language '${language}'."
      return 0
      ;;
  esac

  /usr/bin/osascript \
    - "$target_path" "$cv_name" "$letter_name" \
    >/dev/null <<'APPLESCRIPT'
on placeItem(targetFolder, itemName, itemPosition)
  tell application "Finder"
    if exists item itemName of targetFolder then
      set position of item itemName of targetFolder to itemPosition
    end if
  end tell
end placeItem
on placeLayout(targetFolder, cvName, letterName)
  my placeItem(targetFolder, cvName, {66, 46})
  my placeItem(targetFolder, letterName, {66, 172})

  my placeItem(targetFolder, "build", {66, 298})
  my placeItem(targetFolder, "sendouts", {178, 298})
  my placeItem(targetFolder, "README.md", {290, 298})

  my placeItem(targetFolder, ".git", {66, 424})
  my placeItem(targetFolder, ".gitignore", {178, 424})
end placeLayout

on run argv
  set targetPath to item 1 of argv
  set cvName to item 2 of argv
  set letterName to item 3 of argv

  set targetFolder to (POSIX file targetPath) as alias
  set targetPosix to POSIX path of targetFolder

  tell application "Finder"
    activate

    -- Close already-open Finder windows for this folder.
    -- This avoids stale Finder window state on every second run.
    repeat with finderWindow in Finder windows
      try
        set windowTarget to target of finderWindow as alias
        if POSIX path of windowTarget is targetPosix then
          close finderWindow
        end if
      end try
    end repeat

    delay 0.3

    open targetFolder
    delay 0.7

    set targetWindow to front window
    set bounds of targetWindow to {120, 100, 980, 720}
    set current view of targetWindow to icon view

    tell icon view options of targetWindow
      set arrangement to not arranged
      set icon size to 64
      set text size to 12
      set label position to bottom
    end tell

    delay 0.3

    -- Native Finder cleanup only as initial reset.
    -- Important: no cleanup after the custom layout.
    try
      clean up targetWindow by name
    end try

    delay 0.3

    tell icon view options of targetWindow
      set arrangement to not arranged
    end tell
  end tell

  -- Custom layout pass.
  my placeLayout(targetFolder, cvName, letterName)

  delay 0.5

  -- Stabilization pass for Finder/iCloud refresh.
  my placeLayout(targetFolder, cvName, letterName)

  tell application "Finder"
    set index of targetWindow to 1
  end tell
end run
APPLESCRIPT
}

# ---------------------------------------------------------------------------
# Dependency checks
# ---------------------------------------------------------------------------
require_command "git"
require_command "rsync"
require_command "find"

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
    die "Missing Submission argument. Run without arguments for usage help."
  fi

  submission="$arg2"
  lang="${arg3:-}"
fi

[[ -z "$company" ]] && die "Company name must not be empty."
[[ -z "$submission" ]] && die "Submission name must not be empty."

# Default language: German when the German template exists.
if [[ -z "$lang" ]]; then
  if [[ -d "${TEMPLATES_DIR}/_template_de" ]]; then
    lang="de"
  else
    lang="en"
  fi
fi

if [[ "$lang" != "de" && "$lang" != "en" ]]; then
  die "Unsupported language: '${lang}' (expected: de or en)."
fi

# ---------------------------------------------------------------------------
# Template validation
# ---------------------------------------------------------------------------
template="${TEMPLATES_DIR}/_template_${lang}"

if [[ ! -d "$template" ]]; then
  die "Template not found: ${template}"
fi

# ---------------------------------------------------------------------------
# Resolve destination with strict capitalization handling
# ---------------------------------------------------------------------------
company_slug="$(slugify "$company")"
submission_slug="$(slugify "$submission")"

[[ -z "$company_slug" ]] && die "Company slug must not be empty."
[[ -z "$submission_slug" ]] && die "Submission slug must not be empty."

mkdir -p "$APPLICATIONS_DIR"

company_dir=""

if existing_company_entry="$(
  find_case_insensitive_entry "$APPLICATIONS_DIR" "$company_slug"
)"; then
  actual_company_name="${existing_company_entry##*/}"

  if [[ "$actual_company_name" != "$company_slug" ]]; then
    die "Company-folder capitalization mismatch:
  Requested: ${company_slug}
  Existing:  ${actual_company_name}
  Path:      ${existing_company_entry}

Use the existing spelling or rename the folder explicitly."
  fi

  if [[ ! -d "$existing_company_entry" ]]; then
    die "Company path exists but is not a directory:
  ${existing_company_entry}"
  fi

  company_dir="$(canonical_dir "$existing_company_entry")"
else
  company_dir="${APPLICATIONS_DIR}/${company_slug}"
  mkdir -p "$company_dir"
  company_dir="$(canonical_dir "$company_dir")"
fi

if existing_submission_entry="$(
  find_case_insensitive_entry "$company_dir" "$submission_slug"
)"; then
  actual_submission_name="${existing_submission_entry##*/}"

  if [[ "$actual_submission_name" != "$submission_slug" ]]; then
    die "Submission-folder capitalization mismatch:
  Requested: ${submission_slug}
  Existing:  ${actual_submission_name}
  Path:      ${existing_submission_entry}"
  fi

  die "Destination already exists:
  ${existing_submission_entry}"
fi

requested_dest="${company_dir}/${submission_slug}"

info "Creating application: ${company_slug}/${submission_slug} (lang=${lang})"

mkdir -p "$requested_dest"
dest="$(canonical_dir "$requested_dest")"

# ---------------------------------------------------------------------------
# Copy language template
# ---------------------------------------------------------------------------
rsync_excludes=()

for pattern in "${EXCLUDE_PATTERNS[@]}"; do
  rsync_excludes+=(--exclude "$pattern")
done

rsync \
  -a \
  "${rsync_excludes[@]}" \
  "$template/" \
  "$dest/"

# Explicitly create workflow directories + keep build/.gitignore tracked.
mkdir -p \
  "$dest/build" \
  "$dest/sendouts"
touch "$dest/sendouts/.gitkeep"

cat > "$dest/build/.gitignore" <<'BUILDIGNORE'
# Keep the directory in git; ignore everything generated inside.
*
!.gitignore
BUILDIGNORE

# ---------------------------------------------------------------------------
# Git ignore rules
# ---------------------------------------------------------------------------
cat > "$dest/.gitignore" <<'GITIGNORE'
# Finder metadata
.DS_Store

# latexmk aux directory (PDF + .synctex.gz stay next to .tex)
build/*
!build/.gitignore

# LaTeX build artifacts outside build/ as a safety net
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

# Ignore working PDFs in the application root
*.pdf

# Track final submitted PDFs
!sendouts/*.pdf
GITIGNORE

# ---------------------------------------------------------------------------
# Initialize local Git repository
# ---------------------------------------------------------------------------
info "Initializing local Git repository for document versioning..."

(
  cd "$dest"

  git init --quiet
  git add -A

  if ! git commit \
    --quiet \
    -m "Initial template (${lang}) for ${company} / ${submission}"
  then
    warn "Initial Git commit failed."
    warn "Check git user.name and git user.email."
    warn "The application folder and repository were still created."
  fi
)

# ---------------------------------------------------------------------------
# Finder draft tag
# ---------------------------------------------------------------------------
info "Applying blue Finder tag for active draft..."

if ! apply_finder_tag "$dest" "$FINDER_DRAFT_LABEL_INDEX"; then
  warn "Could not apply the Finder tag."
  warn "The application folder was created successfully without it."
fi

# ---------------------------------------------------------------------------
# Finder icon layout
# ---------------------------------------------------------------------------
info "Arranging application files in Finder..."

if ! arrange_application_icons "$dest" "$lang"; then
  warn "Could not apply the preferred Finder icon layout."
  warn "The application folder was still created successfully."
fi

# ---------------------------------------------------------------------------
# Done
# ---------------------------------------------------------------------------
dest_rel="${dest#"${ROOT_DIR}"/}"

echo ""
info "Created new application folder:"
echo "  Relative: ${dest_rel}"
echo "  Absolute: ${dest}"
echo ""
echo "Next steps:"
echo "  1. Edit the .tex files in ${dest_rel}/"
echo "  2. Compile with latexmk / TeXStudio (magic comments use txs:///latexmk; aux → build/)"
echo "  3. Place final PDFs in ${dest_rel}/sendouts/"
echo "  4. Use 'git -C ${dest_rel} log' to view document history"
