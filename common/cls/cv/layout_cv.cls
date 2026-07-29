%===============================================================================
% layout_cv.cls
% Page layers, page styles, footer API, and two-column body composition.
%
% Provides: \makecvfooter, \highlightbar, \mainbar, \fullbar, \makebody, page styles.
% Depends on: defaults_cv.cls (geometry), i18n_cv.cls (\cvPageWord, \cvOfWord),
%             shared_adjustment.cls (colors, logging), lastpage+refcount packages.
% Used by: Lebenslauf.tex (via \makecvfooter, \highlightbar, \mainbar, \makebody)
%===============================================================================

\debug{Loading layout_cv.cls}

% Sidebar background layers
\DeclareNewLayer[
  background, oddpage, innermargin, width=\highlightwidth,
  contents={\color{highlightbarcolor}\rule{\layerwidth}{\layerheight}}
]{highlightbar.odd}

\ifcvTwoSided
  \DeclareNewLayer[
    clone=highlightbar.odd, evenpage, align=r, hoffset=\paperwidth
  ]{highlightbar.even}
\else
  \DeclareNewLayer[
    background, evenpage, outermargin, width=\highlightwidth,
    contents={\color{highlightbarcolor}\rule{\layerwidth}{\layerheight}}
  ]{highlightbar.even}
\fi

% Header background layer
\DeclareNewLayer[
  background, topmargin, addheight=\headerheight,
  contents={\color{headerbarcolor}\rule{\layerwidth}{\layerheight}}
]{header.bg}


%===============================================================================
% Body layout
%===============================================================================

% Body layout state flags
\newif\ifcvInHighlightbar  \cvInHighlightbarfalse
\newif\ifcvFirstSection    \cvFirstSectionfalse
\newif\ifcvFullWidthBody   \cvFullWidthBodyfalse

% Body content buffers
\def\cvHighlightbarContent{}%
\def\cvMainbarContent{}%

% Sidebar text width helper
\newcommand{\cvSidebarTextWidth}{%
  \dimexpr\highlightwidth-\marginleft-\marginright\relax
}

% Capture sidebar content
\newcommand{\highlightbar}[1]{%
  \cvFullWidthBodyfalse
  \def\cvHighlightbarContent{%
    \begin{minipage}[t]{\cvSidebarTextWidth}%
      \begingroup
      \cvInHighlightbartrue
      \cvFirstSectiontrue
      \setlength{\parskip}{0pt}%
      \setlength{\parindent}{0pt}%
      \vspace*{\bodytopskip}%
      #1%
      \endgroup
    \end{minipage}%
  }%
}

% Capture main content
\newcommand{\mainbar}[1]{%
  \cvFullWidthBodyfalse
  \def\cvMainbarContent{%
    \begin{minipage}[t]{\dimexpr\textwidth-\cvSidebarTextWidth-\cvColSep\relax}%
      \begingroup
      \cvInHighlightbarfalse
      \cvFirstSectiontrue
      \setlength{\parskip}{0pt}%
      \setlength{\parindent}{0pt}%
      \vspace*{\bodytopskip}%
      #1%
      \endgroup
    \end{minipage}%
  }%
}

% Capture full-width content for pages without a highlightbar (typically page 3+).
% Automatically switches to mainonly (label-page3 footer, no highlightbar layers).
% Call after \clearpage. Override with \pagestyle{...} after \fullbar if needed.
\newcommand{\fullbar}[1]{%
  \cvFullWidthBodytrue
  \pagestyle{mainonly}%
  \thispagestyle{mainonly}%
  \def\cvHighlightbarContent{}%
  \def\cvMainbarContent{%
    \begin{minipage}[t]{\textwidth}%
      \begingroup
      \cvInHighlightbarfalse
      \cvFirstSectiontrue
      \setlength{\parskip}{0pt}%
      \setlength{\parindent}{0pt}%
      \vspace*{\bodytopskip}%
      #1%
      \endgroup
    \end{minipage}%
  }%
}

% Emit the sidebar content.  When a \sidebarATSSummary is active, disable
% inner AccSupp spans so pdftotext reads only the single outer ActualText
% (fallback for extractors that ignore content-stream order).
\newcommand{\cvEmitSidebar}{%
  \ifdefempty{\cvSidebarAtsSummary}{%
    \cvHighlightbarContent
  }{%
    \begingroup
    \XeTeXgenerateactualtext=0
    \cvAtsDisableInnertrue
    \BeginAccSupp{method=escape,ActualText={\cvSidebarAtsSummary}}%
    \cvHighlightbarContent
    \EndAccSupp{}%
    \endgroup
  }%
  \cvResetSidebarAtsSummary
}

% Optional ATS stream-order helper (unused by default): emit #2 first in a
% zero-width overlay, then #1. Can nudge extractors that respect content-stream
% order, but changes box placement enough to shift carefully tuned line breaks
% (e.g. Über mich / Profile). Kept for experiments; \makebody uses side-by-side.
\newcommand{\cvRenderColumns}[2]{%  % #1 = sidebar, #2 = mainbar
  \makebox[0pt][l]{%
    \hspace*{\dimexpr\cvSidebarTextWidth+\cvColSep\relax}%
    #2%
  }%
  #1%
}

% Render captured columns according to placement mode:
% - full-width (\fullbar): emit main content only
% - singlesided: keep the same column order on every page
% - doublesided: mirror column order on even pages
% Side-by-side \hspace placement preserves the pre-ATS-overlay visual layout.
\newcommand{\makebody}{%
  \ifcvFullWidthBody
    \ifblank{\cvMainbarContent}{%
      \cvwarn{No full-width content found. Did you call \string\fullbar{...}?}%
    }{}%
    \cvMainbarContent%
  \else
    \ifblank{\cvHighlightbarContent}{%
      \cvwarn{No sidebar content found. Did you call \string\highlightbar{...}?}%
    }{}%
    \ifblank{\cvMainbarContent}{%
      \cvwarn{No main content found. Did you call \string\mainbar{...}?}%
    }{}%

    \ifcvTwoSided
      \checkoddpage
      \ifoddpage
        \cvEmitSidebar\hspace{\cvColSep}\cvMainbarContent%
      \else
        \cvMainbarContent\hspace{\cvColSep}\cvEmitSidebar%
      \fi
    \else
      \cvEmitSidebar\hspace{\cvColSep}\cvMainbarContent%
    \fi
  \fi
}

%===============================================================================
% Footer system
%===============================================================================
% State variables (set by \makecvfooter in .tex).
\def\cvFooterDate{}
\def\cvFooterLabelOne{}
\def\cvFooterLabelTwo{}
\def\cvFooterLabelThree{}
\def\cvFooterName{}

% \makecvfooter{date}{label-page1}{label-page2}{label-page3}[name]
%   date       — left field on all pages (e.g. \today)
%   label-page1 — center field on page 1 (e.g. "Tabellarischer Lebenslauf")
%   label-page2 — center field on page 2 (e.g. "Detaillierte Arbeitserfahrung")
%   label-page3 — center field on main-only portfolio/addendum pages
%   name       — optional right field on single-page CVs (e.g. "Dr. Max Mustermann")
%
% Right field behavior (auto-detected via lastpage):
%   1 page:  shows name
%   2+ pages: shows "Seite n von N"
\NewDocumentCommand{\makecvfooter}{m m m m O{}}{%
  \def\cvFooterDate{#1}%
  \def\cvFooterLabelOne{#2}%
  \def\cvFooterLabelTwo{#3}%
  \def\cvFooterLabelThree{#4}%
  \ifblank{#5}{%
    \def\cvFooterName{\cvFullNamePlain}%
  }{%
    \def\cvFooterName{#5}%
  }%
}

% Helper: right field for page 1 (name if single page, page counter if multi-page).
\newcommand{\cvFooterRightPageOne}{%
  \edef\cvLastPageNum{\number\getpagerefnumber{LastPage}}%
  \ifnum\cvLastPageNum>1\relax
    \cvPageWord~\thepage~\cvOfWord~\cvLastPageNum
  \else
    \cvFooterName
  \fi
}

% Footer layer: page 1 (with header)
\DeclareNewLayer[foreground, page, mode=picture,
  contents={\putLL{\raisebox{0.35\marginbottom}{%
    \rlap{\makebox[\layerwidth][l]{\hspace{\marginleft}\footnotesize\color{mediumgray}\cvFooterDate}}%
    \rlap{\makebox[\layerwidth][c]{\lightfont\footnotesize\color{mediumgray}\cvFooterLabelOne}}%
    \makebox[\layerwidth][r]{\footnotesize\color{mediumgray}%
      \cvFooterRightPageOne\hspace{\marginright}}}}}
]{footer.one}

% Footer layer: page 2 (no header, always shows page counter)
\DeclareNewLayer[foreground, page, mode=picture,
  contents={\putLL{\raisebox{0.35\marginbottom}{%
    \rlap{\makebox[\layerwidth][l]{\hspace{\marginleft}\footnotesize\color{mediumgray}\cvFooterDate}}%
    \rlap{\makebox[\layerwidth][c]{\footnotesize\color{mediumgray}\cvFooterLabelTwo}}%
    \makebox[\layerwidth][r]{\footnotesize\color{mediumgray}%
      \cvPageWord~\thepage~\cvOfWord~\number\getpagerefnumber{LastPage}\hspace{\marginright}}}}}
]{footer.two}

% Footer layer: main-only addendum pages (no header/highlightbar).
\DeclareNewLayer[foreground, page, mode=picture,
  contents={\putLL{\raisebox{0.35\marginbottom}{%
    \rlap{\makebox[\layerwidth][l]{\hspace{\marginleft}\footnotesize\color{mediumgray}\cvFooterDate}}%
    \rlap{\makebox[\layerwidth][c]{\footnotesize\color{mediumgray}\cvFooterLabelThree}}%
    \makebox[\layerwidth][r]{\footnotesize\color{mediumgray}%
      \cvPageWord~\thepage~\cvOfWord~\number\getpagerefnumber{LastPage}\hspace{\marginright}}}}}
]{footer.three}

% Page styles
\DeclareNewPageStyleByLayers{headerhighlightmain}{%
  highlightbar.even, highlightbar.odd, header.bg, footer.one}
\DeclareNewPageStyleByLayers{highlightmain}{%
  highlightbar.even, highlightbar.odd, footer.two}
\DeclareNewPageStyleByLayers{mainonly}{footer.three}
\DeclareNewPageStyleByLayers{headermain}{header.bg}

% Clear all header/footer fields
\lehead[]{}\cehead[]{}\rehead[]{}
\lohead[]{}\cohead[]{}\rohead[]{}
\lefoot[]{}\cefoot[]{}\refoot[]{}
\lofoot[]{}\cofoot[]{}\rofoot[]{}

\debug{layout_cv.cls loaded}
