% !TeX program = xelatex


%===============================================================================
% defaults_cv.cls
% CV-specific geometry, spacing, and layout dimensions.
%
% Provides: Page geometry, spacing primitives, section/entry layout lengths.
% Depends on: shared_adjustment.cls (colors, fonts, logging — loaded before this).
% Used by: main_cv.cls (first module loaded after shared_adjustment.cls)
%===============================================================================

\debug{Loading defaults_cv.cls}

% Page geometry defaults
\newlength\highlightwidth  \setlength\highlightwidth{8cm}
\newlength\headerheight    \setlength\headerheight{6cm}
\newlength\marginleft      \setlength\marginleft{1cm}
\newlength\marginright     \setlength\marginright{\marginleft}
\newlength\margintop       \setlength\margintop{1cm}
\newlength\marginbottom    \setlength\marginbottom{1cm}

\geometry{left=\marginleft,right=\marginright,top=\margintop,bottom=\marginbottom}
\setlength{\parindent}{0pt}

% Global spacing primitives
\newlength{\bodytopskip}   \setlength{\bodytopskip}{2mm}
\newlength{\cvColSep}      \setlength{\cvColSep}{5em}
\newlength{\skillIndent}   \setlength{\skillIndent}{0.0em}
\newlength{\certBulletWidth} \setlength{\certBulletWidth}{0.8em}
\newlength{\cvHeaderTopShift} \setlength{\cvHeaderTopShift}{-0.4em}


% Section heading geometry (shared)
\newlength{\sectionIconWidth}   \setlength{\sectionIconWidth}{5mm}
\newlength{\sectionIconSep}     \setlength{\sectionIconSep}{0.25em}
\newlength{\sectionRuleThick}   \setlength{\sectionRuleThick}{1.0pt}
\newcommand{\cvSectionLetterSpace}{2.0}
\newcommand{\cvSidebarSectionLetterSpace}{2.0pt}



% Mainbar \section spacing
\newlength{\sectionPreskip}     \setlength{\sectionPreskip}{0.35\baselineskip}
\newlength{\sectionAfterTitle}  \setlength{\sectionAfterTitle}{0.4em}
\newlength{\sectionAfterRule}   \setlength{\sectionAfterRule}{0.25em}

% Sidebar \sidebarSection spacing
\newlength{\sidebarSectionPreskip}    \setlength{\sidebarSectionPreskip}{0.50\baselineskip}
\newlength{\sidebarSectionAfterTitle} \setlength{\sidebarSectionAfterTitle}{0.4em}
\newlength{\sidebarSectionAfterRule}  \setlength{\sidebarSectionAfterRule}{0.25em}

% Overview entry layout geometry
\newlength{\cvMetaWidth}          \setlength{\cvMetaWidth}{28mm}
\newlength{\cvEduMetaExtra}       \setlength{\cvEduMetaExtra}{8mm}
\newlength{\cvJobDateWidth}       \setlength{\cvJobDateWidth}{\cvMetaWidth}
\newlength{\cvEduDateWidth}       \setlength{\cvEduDateWidth}{\dimexpr\cvMetaWidth+\cvEduMetaExtra\relax}
\newlength{\cvEntrySpacing}       \setlength{\cvEntrySpacing}{0cm}
\newlength{\cvColGap}             \setlength{\cvColGap}{0.2em}

% Jobdetail layout geometry
\newlength{\cvJobDetailWidth}       \setlength{\cvJobDetailWidth}{2cm}
\newlength{\cvJobDetailDescSpacing} \setlength{\cvJobDetailDescSpacing}{3mm}
\newlength{\cvJobDetailTagSpacing} \setlength{\cvJobDetailTagSpacing}{2mm}
\newlength{\cvJobDetailGeneralSpacing} \setlength{\cvJobDetailGeneralSpacing}{0.6mm}



% Header contact field rendering
\newlength{\cvHeaderNameBlockShift} \setlength{\cvHeaderNameBlockShift}{-0.2cm}
\newlength{\cvHeaderNameTaglineGap} \setlength{\cvHeaderNameTaglineGap}{3mm}
\newlength{\cvHeaderContactRowGap} \setlength{\cvHeaderContactRowGap}{0.2em}
\newlength{\cvContactIconWidth}  \setlength{\cvContactIconWidth}{5mm}
\newlength{\cvContactIconGap}    \setlength{\cvContactIconGap}{0.5em}
\newlength{\cvContactIconRaise}  \setlength{\cvContactIconRaise}{0mm}

% Jobdescription Icons
\newlength{\cvInternalRowSpacing} \setlength{\cvInternalRowSpacing}{0pt}
\newlength{\cvHighlightSpacing}   \setlength{\cvHighlightSpacing}{2pt}
\newlength{\cvMetaIconWidth}      \setlength{\cvMetaIconWidth}{0.8em}
\newlength{\cvMetaGap}            \setlength{\cvMetaGap}{0.25em}



% Style commands (override from .tex via \renewcommand)
\newcommand{\cvNameStyle}[1]{{\Huge\bfseries\headingfont\color{headerfontcolor}#1}}
\newcommand{\cvContactIconSize}[1]{{\fontsize{8pt}{1em}\headingfont\color{headerfontcolor}#1}}
\newcommand{\cvContactTextStyle}[1]{{\fontsize{10pt}{2em}\bfseries\rmfamily\color{headerfontcolor}#1}}
\newcommand{\sectionIconStyle}[1]{{\fontsize{9.5}{9.5}\rmfamily #1}}
\newcommand{\sectionIconRaise}{0.6ex}
\newcommand{\sectionTitleStrut}{\rule{0pt}{2.0ex}}

%===============================================================================
% S4. SKILL BAR GEOMETRY
%===============================================================================
\newcommand{\skillBarW}{16}
\newcommand{\skillBarH}{5}
\newcommand{\skillBarR}{2pt}
\newcommand{\skillSepOpacity}{0.15}
\newcommand{\skillSepW}{1.5} % mm
% Colors, fonts, and logging are defined in shared_adjustment.cls.
\debug{defaults_cv.cls loaded}
