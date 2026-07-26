# Modern CV & Cover Letter — LaTeX Template

A modular, bilingual (DE/EN) CV and cover-letter system for XeLaTeX.
Built for maintainability and Applicant Tracking Systems (ATS): shared design
tokens, AccSupp/`ActualText` for clean text extraction, and optional 1–3 page
layouts (overview, detail, full-width portfolio). Templates compile with
`latexmk` (aux in `build/`), ship with TeXStudio magic comments, and stay
public-safe via placeholders plus a PII guard for GitHub publication.

## Preview

> Preview PNGs live under [`docs/previews/`](docs/previews/) (all pages). The README shows page 1 only — open that folder for pages 2–3 (e.g. `cv_de-2.png`, `cv_de-3.png`). Regenerate locally or from the CI `preview-pngs` artifact when MOCK layouts change.

| German CV (Page 1) | German Cover Letter |
|:--------------:|:-------------------:|
| ![CV DE](docs/previews/cv_de-1.png) | ![CL DE](docs/previews/cover_letter_de-1.png) |

| English CV (Page1) | English Cover Letter |
|:---------------:|:--------------------:|
| ![CV EN](docs/previews/cv_en-1.png) | ![CL EN](docs/previews/cover_letter_en-1.png) |

## Why this project

- **Modular architecture**: CV logic is split into focused class modules instead of a monolithic `.cls`.
- **Unified design tokens**: Fonts, colors, and logging shared between CV and cover letter via `adjustment.cls`.
- **Bilingual templates**: Ready-to-use German and English starter templates.
- **ATS support**: Date normalization and `ActualText` for Applicant Tracking Systems.
- **GitHub-ready**: Public-safe placeholders, PII guard, and CI/CD pipeline.

## Repository structure

```text
modern_cv/
├── common/cls/
│   ├── shared_cls/          # Fonts, colors, logging, ATS (adjustment.cls, ats.cls)
│   ├── cv/                  # main_cv, layout, components, i18n, defaults
│   └── cover_letter/        # Cover letter document class + defaults
├── applications/
│   ├── _template_de/        # MOCK Lebenslauf + Anschreiben
│   └── _template_en/        # MOCK CV + cover letter
├── images/                  # Photo placeholder
├── scripts/                 # new_application.sh, pii_guard.sh
├── docs/previews/           # Auto-generated PDF preview images
└── .github/workflows/       # CI
```

## Requirements

- TeX distribution with `xelatex` (TeX Live 2024+ / MacTeX recommended)
- **Fonts**: SF Pro Text & SF Pro Display (macOS default), or TeX Gyre Heros as automatic fallback
- Font Awesome 5 (via TeX distribution)
- Shell environment for scripts (macOS/Linux)

## Quick start

1. Create a new application folder:
   ```bash
   bash scripts/new_application.sh "Company" "Role_ID1234" de
   ```
2. Edit the `.tex` files in `applications/Company/Role_ID1234/`.
3. Compile with latexmk (XeLaTeX; usually two passes for page refs):
   ```bash
   latexmk MOCK_Lebenslauf.tex
   ```
   Aux files go to `./build/`; the PDF and `.synctex.gz` stay next to the `.tex`.
4. Place final PDFs in the `sendouts/` folder.

## Customization

### Colors

Override accents in your `.tex` (defaults live in `adjustment.cls`):

```latex
\definecolor{highlight}{HTML}{0055FF}   % tags, skill bars, section dividers
%\colorlet{accent}{highlight}
%\colorlet{headerbarcolor}{black}
%\colorlet{headerfontcolor}{white}
%\colorlet{highlightbarcolor}{palegray}
```

| Name | Purpose |
| ---- | ------- |
| `highlight` | Main accent: tags, bars, dividers |
| `accent` / `heading` / `body` | Entry titles, section heads, body text |
| `headerbarcolor` / `headerfontcolor` | CV header |
| `highlightbarcolor` | Sidebar background |

### Fonts

Configured in `adjustment.cls`: SF Pro Text (body) and SF Pro Display (headings), with TeX Gyre Heros if SF Pro is missing. A `[CV-WARN]` is logged on fallback.

### Footer

```latex
\makecvfooter
  {\today}                          % Left: date (all pages)
  {Tabellarischer Lebenslauf}       % Center: page 1
  {Detaillierte Arbeitserfahrung}   % Center: page 2
  {Projekte \& Portfolio}           % Center: page 3+ (\fullbar / mainonly)
  % optional: [Dr. Max Mustermann]  % Right on single-page CVs; else \prefix+\name
```

On multi-page CVs the right field shows `Seite n von N` / `Page n of N`.

### CV pages

The MOCK CVs are built as up to three pages; drop trailing blocks if you need fewer:

| Page | Layout | Typical content |
| ---: | ------ | --------------- |
| 1 | Header + sidebar (`\highlightbar`) + main (`\mainbar`) | Overview / résumé |
| 2 | Sidebar + main (`\pagestyle{highlightmain}`) | Detailed experience |
| 3 | Full width (`\fullbar`, auto-`mainonly`) | Projects / portfolio (`\cvExpDetail`, `\cvDivider`) |

Footer center labels come from `\makecvfooter` (one per page type). Details and examples live in the MOCK templates.

### Skill bars

```latex
\cvUseSkillBarStyle{segmented}  % or classic
\cvSkill{LaTeX}{5}              % tech skills (levels 1–5)
\cvLang{German}{5}              % spoken languages (CEFR-oriented ATS labels)
```

Level wording lives in `i18n_cv.cls` (tech vs language). Optional palette: `\cvSetSkillPalette{...}`.

### Address

`\address{street}{zip}{city}{country}` — blank parts are omitted. ZIP and city are joined by a space (no comma). Country is optional. Examples: full line, or `\address{}{}{Berlin}{Deutschland}` for city + country only. Drop the `\address{...}` call inside `\tagline` if you want no address at all.

### Language & ATS

```latex
\cvSetLanguage{de}                 % or en — footer/section labels
\cvSetAtsDateMode{normalized}      % default; or raw
```

Compact dates (e.g. `12|25 \textendash Aktuell`) are exposed to ATS via `ActualText` in a normalized form. Skill/language levels and contact fields use the same accessibility layer so extractors see clean labels.

## TeXStudio

Templates ship with:

```latex
% !TeX program = xelatex
% !TeX TXS-program:compile = txs:///latexmk
```

For error highlighting with `aux_dir=build`: Options → Configure TeXstudio → Build → Additional Search Paths → Log File → `./build`.

Debug: add `debug` to the document class options.

## Overleaf

Overleaf no longer accepts CV/résumé projects under their current policies. Prefer local TeX Live / TeXStudio (or another desktop TeX setup). If you still upload elsewhere, use **XeLaTeX**; SF Pro will fall back to TeX Gyre Heros.

## CI, privacy & scripts

- **GitHub Actions**: compiles DE/EN templates, uploads PDFs and all-page preview PNGs as artifacts, runs chktex, PII guard, and shellcheck. Refresh `docs/previews/` in a PR when MOCK layouts change (CI does not push to `main`).
- **Pre-commit**: `pip install pre-commit && pre-commit install` (whitespace, shellcheck, PII).
- **Privacy**: templates use placeholders; `scripts/pii_guard.sh` plus `.pii_blocklist` (see `.pii_blocklist.example`). Company application folders are gitignored; `_template_*` stay tracked.
- **New application**: `scripts/new_application.sh "ACME" "Role_ID42" de` (or `"ACME/Role_ID42" de`) copies the template, inits a local git repo, and adds `sendouts/` + `.gitignore`.

## License

See `LICENSE`.
