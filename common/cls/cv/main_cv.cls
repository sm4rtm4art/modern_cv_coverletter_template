% !TeX program = xelatex

%===============================================================================
% main_cv.cls
% Modular two-column CV class for XeLaTeX.
%
% Provides: Document class with options (singlesided|doublesided, debug).
% Loads: shared_adjustment.cls -> defaults_cv.cls -> i18n_cv.cls ->
%        ats_cv.cls -> layout_cv.cls -> components_cv.cls
% Used by: Lebenslauf.tex (via \documentclass{main_cv})
%===============================================================================

\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{main_cv}[2026/02/10 v4.0 Modular two-column CV class]

%===============================================================================
% Engine and options
%===============================================================================



\RequirePackage{ifthen}
\newif\ifcvTwoSided
\newif\ifdebugMode
\cvTwoSidedfalse
\debugModefalse

\DeclareOption{singlesided}{%
  \cvTwoSidedfalse
  \PassOptionsToClass{oneside}{scrartcl}%
}
\DeclareOption{doublesided}{%
  \cvTwoSidedtrue
  \PassOptionsToClass{twoside}{scrartcl}%
}
\DeclareOption{debug}{\debugModetrue}
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{scrartcl}}
\ExecuteOptions{singlesided}
\ProcessOptions\relax
\LoadClass{scrartcl}

%===============================================================================
% Logging and error helpers
%===============================================================================

\newcommand{\cvlog}[1]{\typeout{[CV-INFO] #1}}
\newcommand{\cvinfo}[1]{\typeout{[CV-INFO] #1}}
\newcommand{\debug}[1]{\ifdebugMode\typeout{[CV-DEBUG] #1}\fi}
\let\cvdebug\debug
\newcommand{\cvwarn}[1]{\ClassWarning{main_cv}{#1}}
\newcommand{\cverror}[2]{\ClassError{main_cv}{#1}{#2}}
\newcommand{\debugmeaning}[2]{\debug{#1 = \meaning#2}}
\let\debugtok\debugmeaning



%===============================================================================
% Core packages
%===============================================================================

% Package loader with explicit debug/error traces.
\newcommand{\cvRequirePackage}[2][]{%
  \debug{Package load requested: #2 (options='#1')}%
  \IfFileExists{#2.sty}{%
    \ifthenelse{\equal{#1}{}}{\RequirePackage{#2}}{\RequirePackage[#1]{#2}}%
    \debug{Package loaded: #2}%
  }{%
    \cverror{Required package '#2' not found}{%
      Install package '#2' in your TeX distribution and recompile.}%
  }%
}


\cvRequirePackage{silence}
\WarningFilter{hyperref}{Token not allowed in a PDF string}
\WarningFilter{hyperref}{Option `colorlinks' has already been used}
\WarningFilter{scrlayer-scrpage}{Very small head height detected!}

\cvRequirePackage[bindingoffset=0cm,nomarginpar,noheadfoot]{geometry}
\cvRequirePackage{scrlayer-scrpage}
\cvRequirePackage{tikz}
\usetikzlibrary{arrows}
\cvRequirePackage[skins]{tcolorbox}
\cvRequirePackage{graphicx}
\cvRequirePackage{xstring}
\cvRequirePackage{xcolor}
\cvRequirePackage{fontspec}
\cvRequirePackage{fontawesome5}
\cvRequirePackage{academicons}
\cvRequirePackage{enumitem}
\setlist[itemize]{noitemsep, topsep=0pt, leftmargin=1em}
\cvRequirePackage{etoolbox}
\cvRequirePackage{tabularx}
\cvRequirePackage{array}
\cvRequirePackage{ragged2e}
\cvRequirePackage{ifoddpage}
\cvRequirePackage{hyperref}
\cvRequirePackage{lastpage}
\cvRequirePackage{refcount}

\AtBeginDocument{\setcounter{secnumdepth}{-1}}


%===============================================================================
% Module loading
%===============================================================================


% 2.Loading logica (Cascade: Lokal -> Module -> Shared -> Error)
\newcommand{\cvLoadModule}[1]{%
  \debug{Module load requested: #1.cls}%
  % Step A: Searched in the local folder of the tex file
  \IfFileExists{#1.cls}{%
    \cvlog{Loading local module: #1.cls}%
    \input{#1.cls}%
    \debug{Loaded local module: #1.cls}%
  }{%
    % Step B: search in the cv folder
    \IfFileExists{\cvModulePath#1.cls}{%
      \cvlog{Loading cv module: \cvModulePath#1.cls}%
      \input{\cvModulePath#1.cls}%
      \debug{Loaded cv module: \cvModulePath#1.cls}%
    }{%
      % Step C: search in the cls folder
      \IfFileExists{\cvSharedPath#1.cls}{%
        \cvlog{Loading shared module: \cvSharedPath#1.cls}%
        \input{\cvSharedPath#1.cls}%
        \debug{Loaded shared module: \cvSharedPath#1.cls}%
      }{%
        % Error: not found
        \cverror{Module '#1' not found}{%
          File '#1.cls' not found in:\MessageBreak
          - Local directory\MessageBreak
          - \cvModulePath\MessageBreak
          - \cvSharedPath
        }%
      }%
    }%
  }%
}
% 1.define path% (ats_cv, defaults_cv...)
\newcommand{\cvModulePath}{../../common/cls/cv/}
% Path for shared files (adjustment.cls, ats.cls, ...)
\newcommand{\cvSharedPath}{../../common/cls/shared_cls/}

%%% ----- Execution -----
\debug{Starting module load sequence: shared_adjustment -> defaults_cv -> i18n_cv -> ats_cv -> layout_cv -> components_cv}
\cvLoadModule{adjustment}
\cvLoadModule{ats}
\cvLoadModule{defaults_cv}
\cvLoadModule{i18n_cv}
\cvLoadModule{layout_cv}
\cvLoadModule{components_cv}
\makeatletter % restore after modules that may have changed @ catcode
\ifdebugMode\cvSharedDebugtrue\fi
\debug{Completed module load sequence}

%===============================================================================
% Final setup
%===============================================================================

\AtBeginDocument{%
  \pagestyle{headerhighlightmain}%
  \thispagestyle{headerhighlightmain}%
}

\errorcontextlines=999


%================================================================================
% END OF FILE
%================================================================================
\debug{main_cv.cls loaded successfully.}
