% !TeX program = xelatex

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%=
% shared_adjustment.cls
% Shared design tokens for both CV and cover letter classes.
%
% Provides: Structured logging, unified color palette, font configuration.
% Depends on: xcolor, fontspec, etoolbox (loaded by parent class before this file).
% Used by: main_cv.cls (after core packages), main_cover_letter.cls (after packages)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%=

\typeout{[CV-DEBUG] Loading shared_adjustment.cls}

%-------------------------------------------------------------------------------
% 1. Structured logging
%-------------------------------------------------------------------------------
% Shared debug flag — parent class activates via \cvSharedDebugtrue.
\newif\ifcvSharedDebug
\cvSharedDebugfalse

% Logging macros with TeXStudio-friendly prefixes for log filtering.
% \ClassWarning and \ClassError integrate with TeXStudio's warning/error panels.
% \providecommand: safe to load alongside main_cv.cls which defines its own set.
\providecommand{\cvlog}[1]{\typeout{[CV-INFO] #1}}
\providecommand{\cvinfo}[1]{\typeout{[CV-INFO] #1}}
\providecommand{\cvwarn}[1]{\ClassWarning{modern-cv}{#1}}
\providecommand{\cvdebug}[1]{\ifcvSharedDebug\typeout{[CV-DEBUG] #1}\fi}
\providecommand{\cverror}[2]{\ClassError{modern-cv}{#1}{#2}}

% Assertion helper (used for required-field checks).
\providecommand{\cvAssertNonEmpty}[3]{\ifblank{#1}{\cverror{#2}{#3}}{}}

% Validate expected parent-loaded dependencies for clearer tracebacks.
\@ifpackageloaded{xcolor}{}{%
  \cverror{shared_adjustment requires package 'xcolor'}{Load xcolor before shared_adjustment.cls.}%
}
\@ifpackageloaded{fontspec}{}{%
  \cverror{shared_adjustment requires package 'fontspec'}{Load fontspec before shared_adjustment.cls.}%
}
\@ifpackageloaded{etoolbox}{}{%
  \cverror{shared_adjustment requires package 'etoolbox'}{Load etoolbox before shared_adjustment.cls.}%
}

%-------------------------------------------------------------------------------
% 2. Unified color palette
%-------------------------------------------------------------------------------
% Gray tones (fixed reference palette — not intended for user override).
\definecolor{white}{HTML}{FFFFFF}

\definecolor{black}{HTML}{000000}
\definecolor{darkgray}{HTML}{1c1c1e}
\definecolor{mediumgray}{HTML}{444444}
\definecolor{gray}{HTML}{5D5D5D}
\definecolor{lightgray}{HTML}{999999}
\definecolor{silver}{HTML}{DEE0E3}
\definecolor{palegray}{HTML}{e0e0e0}

% Primary design colors (override in .tex with \definecolor or \colorlet).
%   highlight  — main accent color: tags, skill bars, section dividers
%   accent     — entry titles, bold headings (often black or = highlight)
%   heading    — section heading text color
%   body       — main body text color
\definecolor{highlight}{HTML}{2e457e}
\colorlet{accent}{black}
\colorlet{heading}{black}
\colorlet{body}{black}

% CV structural colors (override in .tex).
%   headerbarcolor     — CV header background
%   headerfontcolor    — CV header text (use white on dark header)
%   highlightbarcolor  — CV sidebar background
\colorlet{headerbarcolor}{black}
\colorlet{headerfontcolor}{white}
\colorlet{highlightbarcolor}{palegray}

%-------------------------------------------------------------------------------
% 3. Font configuration (SF Pro with TeX Gyre Heros fallback)
%-------------------------------------------------------------------------------
\defaultfontfeatures{Ligatures=TeX}

% Fix SF Pro glyph mapping: SF Pro maps uppercase K to U+212A (Kelvin sign)
% instead of U+004B (Latin K). XeTeX's ActualText generation overrides the
% font's internal cmap, ensuring correct Unicode text extraction from PDFs.
\XeTeXgenerateactualtext=1

\IfFontExistsTF{SF Pro Text}{%
  \cvlog{Font: SF Pro Text found.}%
  \setmainfont{SF Pro Text}[
    UprightFont    = SF Pro Text Regular,
    BoldFont       = SF Pro Text Semibold,
    ItalicFont     = SF Pro Text Regular Italic,
    BoldItalicFont = SF Pro Text Semibold Italic,
    FontFace       = {l}{n}{SF Pro Text Light},
    FontFace       = {l}{it}{SF Pro Text Light Italic}
  ]%
  \setsansfont{SF Pro Text}%
}{%
  \cvwarn{SF Pro Text not found — using TeX Gyre Heros fallback.
    Install Apple SF Pro fonts for the intended design}%
  \setmainfont{TeX Gyre Heros}%
  \setsansfont{TeX Gyre Heros}%
}

\IfFontExistsTF{SF Pro Display}{%
  \cvlog{Font: SF Pro Display found.}%
  \newfontfamily\headingfont{SF Pro Display}[
    UprightFont    = SF Pro Display Semibold,
    BoldFont       = SF Pro Display Bold,
    MediumFont     = SF Pro Display Medium,
    FontFace       = {l}{n}{SF Pro Display Light},       % Light Upright
    FontFace       = {l}{it}{SF Pro Display Light Italic}% Light Italic
  ]%
}{%
  \cvwarn{SF Pro Display not found — using TeX Gyre Heros fallback}%
  \newfontfamily\headingfont{TeX Gyre Heros}%
}

% Light weight shortcut (available with SF Pro; degrades gracefully with fallback).
\providecommand{\lightfont}{\fontseries{l}\selectfont}

\cvlog{adjustment.cls loaded.}
