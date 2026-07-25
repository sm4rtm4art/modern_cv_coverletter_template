%===============================================================================
% ats_cv.cls
% ATS/accessibility helpers and date normalization utilities.
%
% Provides: \AccText, \HideFromText, \cvDateParse, \cvDateFmt, \cvDateFmtAcc,
%           \cvMetaDateLine, \cvDateSideNormalize
% Depends on: defaults_cv.cls (loaded before), shared_adjustment.cls (logging)
% Used by: components_cv.cls (\cvOverviewEntryDecoupled, \cvJobDetail)
%
% Why this module exists:
% - Keep visible CV typography/icon style unchanged.
% - Provide machine-readable "ActualText" for ATS parsers and copy/paste.
%
% Main flow for CV overview dates:
% 1) components_cv.cls passes a date token to \cvMetaDateLine.
% 2) \cvMetaDateLine calls \cvDateParse.
% 3) \cvDateParse builds:
%    - \cvDateVisTmp   (what the user sees in PDF)
%    - \cvDatePlainTmp (what ATS reads from ActualText)
% 4) \cvMetaLineAcc wraps visible text with ATS plain fallback.
%===============================================================================

\debug{Loading ats.cls}

\IfFileExists{accsupp.sty}{%
  \RequirePackage{accsupp}%
  \debug{Loaded optional package: accsupp}%
  % Fix XeTeX/xdvipdfmx ActualText misplacement (StackExchange #262492).
  % Default accsupp wraps BDC/EMC in coordinate-transformation q/Q pairs,
  % which grossly offsets the ActualText box. Using pdf:code emits BDC/EMC
  % directly into the content stream (like pdfTeX's \pdfliteral direct).
  \makeatletter
  \def\ACCSUPP@bdc{%
    \special{pdf:code \ACCSUPP@span BDC}%
  }%
  \def\ACCSUPP@emc{%
    \special{pdf:code EMC}%
  }%
  \makeatother
}{%
  \cvwarn{Optional package 'accsupp' not found. ATS ActualText support may be reduced.}%
}

\newif\ifcvATSBuild
\ifdefined\ATSBUILD\cvATSBuildtrue\else\cvATSBuildfalse\fi

% When true, inner AccSupp spans are suppressed so an outer
% \cvAtsReplaceBlock can provide a single ActualText for the whole region
% (used by \cvEmitSidebar to prevent column interleaving in pdftotext).
\newif\ifcvAtsDisableInner  \cvAtsDisableInnerfalse

\newcommand{\HideFromText}[1]{%
  \leavevmode
  \ifcvAtsDisableInner
    #1%
  \else
    \begingroup\XeTeXgenerateactualtext=0
    \BeginAccSupp{method=hex,unicode,ActualText=0020}#1\EndAccSupp{}%
    \endgroup
  \fi
}

% Expose visible formatted text with a simpler ATS/plain-text alternative.
\newcommand{\AccText}[2]{%
  \ifcvAtsDisableInner
    #1%
  \else
    \begingroup\XeTeXgenerateactualtext=0
    \BeginAccSupp{method=escape,ActualText={#2}}#1\EndAccSupp{}%
    \endgroup
  \fi
}

% Robust date accessibility helper for XeTeX/xdvipdfmx.
% Renders visible date (e.g. 12|25) while embedding ATS-readable date (e.g. 12/2025).
% Strategy: hide visual glyphs from text extraction, then overlay invisible
% real text that \XeTeXgenerateactualtext picks up glyph-by-glyph.


% Render compact visual date, embed normalized ATS via ActualText.
% #1 = visual (e.g. 12|25 – Aktuell), #2 = ATS plain (e.g. 12/2025 - 02/2026)
% PDF readers that honour ActualText (Preview, Adobe, real ATS parsers)
% extract #2.  The visual glyphs show #1.
\newcommand{\AccDate}[2]{\AccText{#1}{#2}}

% CONFIGS


\newcommand{\cvTwoDigit}[1]{\ifnum#1<10 0\fi\number#1}
\newcommand{\cvTodayMMYYYY}{\cvTwoDigit{\month}/\number\year}

% ATS date output mode:
% - default (false): normalize plain ATS dates
% - true: keep plain ATS date text exactly as entered
\newif\ifcvRawAtsDates
\cvRawAtsDatesfalse

% Public date mode helpers.
\newcommand{\cvUseRawAtsDates}{\cvRawAtsDatestrue}
\newcommand{\cvUseNormalizedAtsDates}{\cvRawAtsDatesfalse}
\newcommand{\cvSetAtsDateMode}[1]{%
  \ifstrequal{#1}{raw}{%
    \cvUseRawAtsDates
  }{%
    \ifstrequal{#1}{normalized}{%
      \cvUseNormalizedAtsDates
    }{%
      \cvwarn{Unknown ATS date mode '#1'. Use 'raw' or 'normalized'. Keeping current mode.}%
    }%
  }%
}

\newcommand{\cvZapSpacesTo}[2]{%
  \StrSubstitute{#1}{ }{}[\cvTmpNoSpaces]%
  \IfSubStr{\cvTmpNoSpaces}{ }{%
    \expandafter\cvZapSpacesTo\expandafter{\cvTmpNoSpaces}{#2}%
  }{%
    \edef#2{\cvTmpNoSpaces}%
  }%
}

%===============================================================================
% Date parser (LaTeX2e) for ATS:
% Input:  06|2025\textendash Aktuell   or  06|2025\textendash10|2025
% Visible: 06/2025 – Aktuell           or  06/2025 – 10/2025
% ATS:     06/2025 - <today MM/YYYY>   or  06/2025 - 10/2025
%===============================================================================

%% Current position naming => Date \today
% IMPORTANT: Keep on a single line — newlines become leading spaces that
%            break \IfSubStr matching inside \cvIfPresentTokenTF.
\providecommand{\cvPresentTokens}{Aktuell,aktuell,present,Present,current,Current}



% Normalize one date side:
% - remove spaces
% - map "MM|YY" or "MM|YYYY" to "MM/YYYY"
% - pad one-digit month to two digits
\newcommand{\cvDateSideNormalize}[2]{%
  \cvZapSpacesTo{#1}{\cvSideTmp}%
  \IfEndWith{\cvSideTmp}{|}{\StrGobbleRight{\cvSideTmp}{1}[\cvSideTmp]}{}%
  \IfEndWith{\cvSideTmp}{/}{\StrGobbleRight{\cvSideTmp}{1}[\cvSideTmp]}{}%
  \StrSubstitute{\cvSideTmp}{|}{/}[\cvSideTmp]%
  \IfEndWith{\cvSideTmp}{/}{\StrGobbleRight{\cvSideTmp}{1}[\cvSideTmp]}{}%
  \IfSubStr{\cvSideTmp}{/}{%
    \StrBefore{\cvSideTmp}{/}[\cvMM]%
    \StrBehind{\cvSideTmp}{/}[\cvYY]%
    \StrLen{\cvMM}[\cvMMLen]%
    \ifnum\cvMMLen=1 \edef\cvMM{0\cvMM}\fi
    \StrLen{\cvYY}[\cvYYLen]%
    \ifnum\cvYYLen=2 \edef\cvYY{20\cvYY}\fi
    \edef#2{\cvMM/\cvYY}%
  }{%
    \edef#2{\cvSideTmp}%
  }%
}

% Configurable list of tokens that mean "present/current" in date ranges.
% Each item is checked case-sensitively against the date string.
% Override or extend in defaults_cv.cls or .tex:
%   \def\cvPresentTokens{Aktuell,aktuell,present,Present,current,Current,heute}

% Internal: iterate over \cvPresentTokens and test if any matches.
% Uses etoolbox \docsvlist (no @-catcode dependency) instead of \@for.
\newif\ifcvFoundPresent
\newcommand{\cvIfPresentTokenTF}[3]{%
  \cvZapSpacesTo{#1}{\cvTok}%
  \cvFoundPresentfalse
  \renewcommand*{\do}[1]{\IfSubStr{\cvTok}{##1}{\cvFoundPresenttrue}{}}%
  \expandafter\docsvlist\expandafter{\cvPresentTokens}%
  \ifcvFoundPresent #2\else #3\fi
}

% Parse full range with separators "-" or "\textendash".
% Produces two outputs:
%   \cvDateVisTmp  — formatted visual: MM/YYYY - MM/YYYY (or "Aktuell")
%   \cvDatePlainTmp — ATS plain text:  MM/YYYY - MM/YYYY (Aktuell→today)
% Visual uses "/" and "-" (ASCII) so glyph-level ActualText extracts cleanly.
\newcommand{\cvDateParse}[1]{%
  \def\cvIn{#1}%
  \ifcvRawAtsDates
    \def\cvDateVisTmp{#1}%
    \def\cvDatePlainTmp{#1}%
  \else
    \IfSubStr{\cvIn}{\textendash}{%
      \StrBefore{\cvIn}{\textendash}[\cvLRaw]%
      \StrBehind{\cvIn}{\textendash}[\cvRRaw]%
    }{%
      \IfSubStr{\cvIn}{-}{%
        \StrBefore{\cvIn}{-}[\cvLRaw]%
        \StrBehind{\cvIn}{-}[\cvRRaw]%
      }{%
        \edef\cvLRaw{\cvIn}%
        \edef\cvRRaw{}%
      }%
    }%
    \cvDateSideNormalize{\cvLRaw}{\cvLNorm}%
    \edef\cvLNorm{\cvLNorm}% freeze left side before right side overwrites shared macros
    \cvZapSpacesTo{\cvRRaw}{\cvRTrim}%
    \cvZapSpacesTo{\cvLRaw}{\cvLVis}%
    \ifstrequal{\cvRTrim}{}{%
      \edef\cvDateVisTmp{\cvLVis}%
      \edef\cvDatePlainTmp{\cvLNorm}%
    }{%
      \cvIfPresentTokenTF{\cvRTrim}{%
        \edef\cvDateVisTmp{\cvLVis\space\noexpand\textendash\space Aktuell}%
        \edef\cvDatePlainTmp{\cvLNorm\space-\space\cvTodayMMYYYY}%
      }{%
        \cvDateSideNormalize{\cvRRaw}{\cvRNorm}%
        \edef\cvRNorm{\cvRNorm}% freeze right side
        \cvZapSpacesTo{\cvRRaw}{\cvRVis}%
        \edef\cvDateVisTmp{\cvLVis\space\noexpand\textendash\space\cvRVis}%
        \edef\cvDatePlainTmp{\cvLNorm\space-\space\cvRNorm}%
      }%
    }%
  \fi
}

% Global scratch macros for passing date results out of parsing groups.
% \cvDateParse uses xstring (catcode/stream changes) that can break accsupp
% BDC/EMC markers if both run in the same group. Solution: parse in a group,
% export results via \global\let, close the group, then render AccText cleanly.
\def\cvDateVisResult{}
\def\cvDatePlainResult{}

% Bridge used by components_cv overview entries.
\newcommand{\cvMetaDateLine}[3]{%
  \begingroup
  \cvDateParse{#3}%
  \global\let\cvDateVisResult\cvDateVisTmp
  \global\let\cvDatePlainResult\cvDatePlainTmp
  \endgroup
  \cvMetaLineAcc{#1}{#2}{\cvDateVisResult}{\cvDatePlainResult}%
}

% Public date format helpers for template usage.
\newcommand{\cvDateFmt}[1]{%
  \begingroup
  \cvDateParse{#1}%
  \cvDateVisTmp%
  \endgroup
}

\newcommand{\cvDateFmtAcc}[1]{%
  \begingroup
  \cvDateParse{#1}%
  \global\let\cvDateVisResult\cvDateVisTmp
  \global\let\cvDatePlainResult\cvDatePlainTmp
  \endgroup
  \AccDate{\cvDateVisResult}{\cvDatePlainResult}%
}

% Deferred-safe date formatter: renders ATS-normalized plain text directly.
% Use this in contexts captured via \def (e.g. \mainbar, \highlightbar)
% where \AccText/\AccDate lose their effect.
\newcommand{\cvDateFmtPlain}[1]{%
  \begingroup
  \cvDateParse{#1}%
  \cvDatePlainTmp%
  \endgroup
}

%===============================================================================
% Skill level resolver: map numeric level (1–5) to ATS-readable label.
% Uses i18n labels \cvSkillLevelI..V defined in i18n_cv.cls.
% Result stored in \cvSkillLevelLabel.
%===============================================================================
\newcommand{\cvSkillLevelLabel}{}
\newcommand{\cvResolveSkillLevel}[1]{%
  \ifcase#1\relax
    \def\cvSkillLevelLabel{?}%
  \or \def\cvSkillLevelLabel{\cvSkillLevelI}%
  \or \def\cvSkillLevelLabel{\cvSkillLevelII}%
  \or \def\cvSkillLevelLabel{\cvSkillLevelIII}%
  \or \def\cvSkillLevelLabel{\cvSkillLevelIV}%
  \or \def\cvSkillLevelLabel{\cvSkillLevelV}%
  \else\def\cvSkillLevelLabel{?}%
  \fi
}

%===============================================================================
% Contact field ATS text builders.
% These produce plain-text strings for ATS extraction from structured
% contact data. Used by components_cv.cls formatters.
% Depends on: i18n_cv.cls labels (\cvLabelAddress, \cvLabelStreet, etc.)
%===============================================================================

% Build ATS-readable address string from components.
% Sets \cvAtsResult to the formatted string.
% #1=street, #2=zip, #3=city, #4=country (may be empty)
\newcommand{\cvAtsAddress}[4]{%
  \ifblank{#4}{%
    \edef\cvAtsResult{\cvLabelAddress\cvLabelStreet\space#1, \cvLabelZip\space#2, \cvLabelCity\space#3}%
  }{%
    \edef\cvAtsResult{\cvLabelAddress\cvLabelStreet\space#1, \cvLabelZip\space#2, \cvLabelCity\space#3, \cvLabelCountry\space#4}%
  }%
}

% Build ATS-readable phone string.
% #1=prefix, #2=number, #3=language code
\newcommand{\cvAtsPhone}[3]{%
  \ifstrequal{#3}{en}{%
    \StrSubstitute{#2}{ }{}[\cvTmpPhone]%
    \IfBeginWith{\cvTmpPhone}{0}{\StrGobbleLeft{\cvTmpPhone}{1}[\cvIntlPhone]}{\let\cvIntlPhone\cvTmpPhone}%
    \edef\cvAtsResult{\cvLabelPhone#1\space\cvIntlPhone}%
  }{%
    \edef\cvAtsResult{\cvLabelPhone#2}%
  }%
}

%===============================================================================
% Column-level ATS helpers for two-column layout.
% Problem: pdftotext reads left-to-right across both columns, interleaving
% sidebar and mainbar content. Solution: wrap the sidebar in ActualText
% that emits a clean, sequential summary instead of the visual content.
%
% Usage: call \sidebarATSSummary{plain text...} before \makebody.
% The summary replaces the sidebar's ATS extraction for that page.
% After \makebody consumes it, it resets automatically.
% Must be PLAIN TEXT — no TeX formatting commands.
%===============================================================================

\def\cvSidebarAtsSummary{}
\newcommand{\sidebarATSSummary}[1]{\def\cvSidebarAtsSummary{#1}}
\newcommand{\cvResetSidebarAtsSummary}{\def\cvSidebarAtsSummary{}}

% Hide an entire block from ATS text extraction.
% Unlike \HideFromText (single-line), this works on multi-paragraph content
% by wrapping it in a vbox so accsupp spans the full block.
\newcommand{\cvAtsHideBlock}[1]{%
  \begingroup\XeTeXgenerateactualtext=0
  \BeginAccSupp{method=hex,unicode,ActualText=0020}%
  #1%
  \EndAccSupp{}%
  \endgroup
}

% Replace an entire block's ATS text with a plain-text summary.
% #1 = visible content (rendered normally), #2 = ATS plain text replacement.
\newcommand{\cvAtsReplaceBlock}[2]{%
  \begingroup\XeTeXgenerateactualtext=0
  \BeginAccSupp{method=escape,ActualText={#2}}%
  #1%
  \EndAccSupp{}%
  \endgroup
}

\debug{ats.cls loaded}
