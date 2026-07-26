%===============================================================================
% components_cv.cls
% CV component library: header, sections, sidebar, and mainbar entries.
%
% Structure:
%   S1. Preamble
%   S2. Variable definitions (all data storage)
%   S3. Public setter API (name, prefix, tagline, contact fields, photo)
%   S4. Header component (render name, render contacts, auto-grow, makeheader)
%   S5. Section rendering (section, sectionIcon)
%   S6. Sidebar components (cvSideSection, cvSkill, cvBar*, cert, tags)
%   S7. Mainbar components (cvJobOverview, cvEduOverview, cvJobDetail)
%
% Depends on: defaults_cv.cls (geometry, styles), ats.cls (AccText, dates),
%             i18n_cv.cls (labels), layout_cv.cls (state flags),
%             adjustment.cls (colors, fonts, logging)
%===============================================================================

%===============================================================================
% S1. PREAMBLE
%===============================================================================

\debug{Loading components_cv.cls}

% Validation helper (primary definition in adjustment.cls;
% \providecommand here for standalone usage).
\providecommand{\cvAssertNonEmpty}[3]{%
  \ifblank{#1}{\cverror{#2}{#3}}{}%
}

%===============================================================================
% S2. VARIABLE DEFINITIONS
%===============================================================================

% --- Personal data ---
\newcommand{\cvName}{}
\newcommand{\cvPrefix}{}
\newcommand{\cvPhoto}{}
\newcommand{\cvPhotoDiameter}{}
\newcommand{\cvPhotoFormat}{circle}

% --- Contact data (set by setter commands, read by renderer) ---
\newcommand{\cvEmail}{}
\newcommand{\cvPhonePrefix}{}
\newcommand{\cvPhoneNumber}{}
\newcommand{\cvAddressStreet}{}
\newcommand{\cvAddressZip}{}
\newcommand{\cvAddressCity}{}
\newcommand{\cvAddressCountry}{}
\newcommand{\cvGitHubLabel}{}
\newcommand{\cvGitHubUrl}{}
\newcommand{\cvLinkedInLabel}{}
\newcommand{\cvLinkedInUrl}{}

% --- Default icons (overridable from .tex via \renewcommand) ---
\newcommand{\cvAddressIcon}{\faMapMarker*}
\newcommand{\cvPhoneIcon}{\faPhone}
\newcommand{\cvEmailIcon}{\faEnvelope}
\newcommand{\cvGitHubIcon}{\faGithub}
\newcommand{\cvLinkedInIcon}{\faLinkedin}

% --- Presence flags (renderer checks these) ---
\newif\ifcvHasAddress   \cvHasAddressfalse
\newif\ifcvHasPhone     \cvHasPhonefalse
\newif\ifcvHasEmail     \cvHasEmailfalse
\newif\ifcvHasGitHub    \cvHasGitHubfalse
\newif\ifcvHasLinkedIn  \cvHasLinkedInfalse

% --- Header alignment primitives ---
\newlength{\cvNameFontHeight}
\newlength{\cvNameLineHeight}
\newlength{\cvHeaderInfoWidth}
\newlength{\cvContactNaturalHeight}
\settoheight{\cvNameFontHeight}{\Huge\bfseries\MakeUppercase{A}}
\setlength{\cvNameLineHeight}{0.5\cvNameFontHeight}

%===============================================================================
% S3. PUBLIC SETTER API
%===============================================================================

% --- Name / prefix ---
\newcommand{\name}[1]{\def\cvName{#1}}
\newcommand{\prefix}[1]{\def\cvPrefix{#1}}

% Computed on demand — no caching needed.
\newcommand{\cvFullNamePlain}{\ifblank{\cvPrefix}{}{\cvPrefix\space}\cvName}

% --- Tagline (thin executor: runs the setter commands inside) ---
\newcommand{\tagline}[1]{#1}

% --- Photo ---
\newcommand{\photo}[3][]{%
  \ifblank{#2}{%
    \cverror{Photo path is empty}{Use \string\photo[shape]{path}{size} with a non-empty path.}%
  }{}%
  \ifblank{#3}{%
    \cverror{Photo size is empty}{Use \string\photo[shape]{path}{size} with a non-empty size.}%
  }{}%
  \def\cvPhoto{#2}%
  \def\cvPhotoDiameter{#3}%
  \ifblank{#1}{\def\cvPhotoFormat{circle}}{\def\cvPhotoFormat{#1}}%
}

% --- Address (3 required + 1 optional country) ---
\NewDocumentCommand{\address}{m m m g}{%
  \def\cvAddressStreet{#1}%
  \def\cvAddressZip{#2}%
  \def\cvAddressCity{#3}%
  \IfNoValueTF{#4}{\def\cvAddressCountry{}}{\def\cvAddressCountry{#4}}%
  \cvHasAddresstrue
}

% --- Phone (prefix + number) ---
\NewDocumentCommand{\phone}{m m}{%
  \def\cvPhonePrefix{#1}%
  \def\cvPhoneNumber{#2}%
  \cvHasPhonetrue
}

% --- Email ---
% Store both the LaTeX-formatted and plain-text versions.
% Plain version replaces \_ with _ for clean ATS extraction.
\newcommand{\email}[1]{%
  \def\cvEmail{#1}%
  \StrSubstitute{#1}{\_}{_}[\cvTmpPlain]%
  \edef\cvEmailPlain{\cvTmpPlain}%
  \cvHasEmailtrue
}

% --- GitHub (label + URL, with auto-resolution) ---
\newcommand{\github}[2]{%
  \def\cvGitHubLabel{#1}%
  \IfBeginWith{#2}{http}{%
    \def\cvGitHubUrl{#2}%
  }{%
    \IfSubStr{#2}{github.com}{%
      \def\cvGitHubUrl{https://#2}%
    }{%
      \def\cvGitHubUrl{https://github.com/#2}%
    }%
  }%
  \cvHasGitHubtrue
}

% --- LinkedIn (label + URL, with auto-resolution) ---
\newcommand{\linkedin}[2]{%
  \def\cvLinkedInLabel{#1}%
  \IfBeginWith{#2}{http}{%
    \def\cvLinkedInUrl{#2}%
  }{%
    \IfSubStr{#2}{linkedin.com}{%
      \def\cvLinkedInUrl{https://#2}%
    }{%
      \IfSubStr{#2}{ }{%
        \def\cvLinkedInUrl{https://www.linkedin.com/}%
      }{%
        \def\cvLinkedInUrl{https://www.linkedin.com/in/#2}%
      }%
    }%
  }%
  \cvHasLinkedIntrue
}

%===============================================================================
% S4. HEADER COMPONENT
%===============================================================================

% --- Photo conditional ---
\newcommand{\cvIfHasPhotoTF}[2]{\ifdefempty{\cvPhotoDiameter}{#2}{#1}}

% --- Photo renderer ---
\newcommand{\cvRenderPhoto}{%
  \ifthenelse{\equal{\cvPhotoFormat}{square}}{%
    \includegraphics[width=\linewidth]{\cvPhoto}%
  }{%
    \ifthenelse{\equal{\cvPhotoFormat}{roundedbottom}}{%
      \sbox0{\includegraphics[width=\linewidth]{\cvPhoto}}%
      \begin{tikzpicture}
        \clip (0,\ht0) -- (\wd0,\ht0) --
              (\wd0,6pt) arc[start angle=0,end angle=-90,radius=6pt] --
              (6pt,0) arc[start angle=270,end angle=180,radius=6pt] -- cycle;
        \node[anchor=south west,inner sep=0pt] at (0,0) {\usebox0};
      \end{tikzpicture}%
    }{%
      \tikz\path[fill overzoom image={\cvPhoto}]circle[radius=0.5\linewidth];%
    }%
  }%
}

% --- Name block ---
\newcommand{\cvRenderNameBlock}{%
  \cvNameStyle{%
    \AccText{%
      \mbox{\ifblank{\cvPrefix}{}{\cvPrefix~}\MakeUppercase{\cvName}}%
    }{\cvLabelName\space\cvFullNamePlain}%
  }\par
}

% --- Contact line combiner (icon + text + ATS) ---
% Pattern: fixed-width icon box | gap | styled text with ATS layer.
% \HideFromText hides icon from text extraction.
% \AccText replaces visible text with ATS-readable plain text.
\newcommand{\cvContactLine}[3]{%
  % #1 = icon, #2 = visible text, #3 = ATS plain text
  \noindent
  \makebox[\cvContactIconWidth][c]{%
    \raisebox{\cvContactIconRaise}{%
      \HideFromText{\cvContactIconSize{#1}}%
    }%
  }%
  \hspace{\cvContactIconGap}%
  \AccText{\cvContactTextStyle{#2}}{#3}%
  \par\vspace{\cvHeaderContactRowGap}%
}

% --- Per-field formatters (compute vis + ATS, call combiner) ---
% ATS text builders live in ats.cls; formatters here handle visual + combiner.
\newcommand{\cvFormatAddress}{%
  \begingroup
  % Visual: omit blanks. Locality is "ZIP CITY" (space, no comma between).
  % Units joined with ", ": street | locality | country
  % Use \ifdefempty (etoolbox) so macro contents are tested, not the csname.
  \def\cvVis{}%
  \def\cvVisSep{}%
  \ifdefempty{\cvAddressStreet}{}{%
    \edef\cvVis{\cvVis\cvVisSep\cvAddressStreet}%
    \def\cvVisSep{, }%
  }%
  \ifdefempty{\cvAddressZip}{%
    \ifdefempty{\cvAddressCity}{}{%
      \edef\cvVis{\cvVis\cvVisSep\cvAddressCity}%
      \def\cvVisSep{, }%
    }%
  }{%
    \ifdefempty{\cvAddressCity}{%
      \edef\cvVis{\cvVis\cvVisSep\cvAddressZip}%
      \def\cvVisSep{, }%
    }{%
      \edef\cvVis{\cvVis\cvVisSep\cvAddressZip\space\cvAddressCity}%
      \def\cvVisSep{, }%
    }%
  }%
  \ifdefempty{\cvAddressCountry}{}{%
    \edef\cvVis{\cvVis\cvVisSep\cvAddressCountry}%
  }%
  \cvAtsAddress{\cvAddressStreet}{\cvAddressZip}{\cvAddressCity}{\cvAddressCountry}%
  \cvContactLine{\cvAddressIcon}{\cvVis}{\cvAtsResult}%
  \endgroup}

\newcommand{\cvFormatPhone}{%
  \begingroup
  \ifstrequal{\cvLanguage}{en}{%
    \edef\cvVis{\cvPhonePrefix\space\cvPhoneNumber}%
  }{%
    \def\cvVis{\cvPhoneNumber}%
  }%
  \cvAtsPhone{\cvPhonePrefix}{\cvPhoneNumber}{\cvLanguage}%
  \cvContactLine{\cvPhoneIcon}{\cvVis}{\cvAtsResult}%
  \endgroup}

\newcommand{\cvFormatEmail}{%
  \cvContactLine{\cvEmailIcon}{\href{mailto:\cvEmailPlain}{\cvEmail}}{\cvLabelEmail\cvEmailPlain}}

\newcommand{\cvFormatGitHub}{%
  \cvContactLine{\cvGitHubIcon}{\href{\cvGitHubUrl}{\cvGitHubLabel}}{\cvLabelGitHub\cvGitHubUrl}}

\newcommand{\cvFormatLinkedIn}{%
  \cvContactLine{\cvLinkedInIcon}{\href{\cvLinkedInUrl}{\cvLinkedInLabel}}{\cvLabelLinkedIn\cvLinkedInUrl}}

% --- Contact block builder ---
\newcommand{\cvRenderContactBlock}{%
  \ifcvHasAddress  \cvFormatAddress  \fi
  \ifcvHasPhone    \cvFormatPhone    \fi
  \ifcvHasEmail    \cvFormatEmail    \fi
  \ifcvHasGitHub   \cvFormatGitHub   \fi
  \ifcvHasLinkedIn \cvFormatLinkedIn \fi
}

% --- Auto-grow header height if contact block overflows ---
% Measures the exact content that \makeheader renders, then grows
% \headerheight when the natural content exceeds the configured height.
\newcommand{\cvAutoGrowHeader}{%
  \setlength{\cvHeaderInfoWidth}{\textwidth}%
  \cvIfHasPhotoTF{%
    \setlength{\cvHeaderInfoWidth}{\dimexpr\textwidth-\cvPhotoDiameter\relax}%
  }{}%
  % Measure the exact layout that \makeheader renders (minipage + vspace).
  \setbox0=\vbox{%
    \hsize=\textwidth
    \linewidth=\textwidth
    \vspace{\cvHeaderTopShift}%
    \vspace{\dimexpr\cvNameFontHeight-\cvNameLineHeight\relax}%
    \cvIfHasPhotoTF{%
      \begin{minipage}[t]{\cvHeaderInfoWidth}%
        \vspace{\cvHeaderNameBlockShift}%
        \cvRenderNameBlock
        \vspace{\cvHeaderNameTaglineGap}%
        \cvRenderContactBlock
      \end{minipage}%
    }{%
      \begin{minipage}[t]{\cvHeaderInfoWidth}%
        \cvRenderNameBlock
        \vspace{\cvHeaderNameTaglineGap}%
        \cvRenderContactBlock
      \end{minipage}%
    }%
  }%
  \setlength{\cvContactNaturalHeight}{\dimexpr\ht0+\dp0\relax}%
  \ifdim\cvContactNaturalHeight>\headerheight
    \setlength{\headerheight}{\dimexpr\cvContactNaturalHeight+3mm\relax}%
    \cvwarn{Header content exceeded configured \string\headerheight. Increased automatically.}%
  \fi
}

% --- Main header command ---
\newcommand{\makeheader}{%
  \begingroup
  % Scope white links to header only (body uses hidelinks from .tex).
  \hypersetup{urlcolor=headerfontcolor, linkcolor=headerfontcolor}%
  \cvAutoGrowHeader
  \thispagestyle{headerhighlightmain}%
  \begin{minipage}[t][\headerheight]{\textwidth}%
    \vspace{\cvHeaderTopShift}%
    \vspace{\dimexpr\cvNameFontHeight-\cvNameLineHeight\relax}%
    \cvIfHasPhotoTF{%
      % --- With photo: name+contacts left, photo right ---
      \begin{minipage}[t]{\dimexpr\textwidth-\cvPhotoDiameter\relax}%
        \vspace{\cvHeaderNameBlockShift}%
        \cvRenderNameBlock
        \vspace{\cvHeaderNameTaglineGap}%
        \cvRenderContactBlock
      \end{minipage}\hfil
      \begin{minipage}[t]{\cvPhotoDiameter}%
        \vspace{0cm}%
        \cvRenderPhoto
      \end{minipage}%
    }{%
      % --- Without photo: full-width name+contacts ---
      \begin{minipage}[t]{\textwidth}%
        \cvRenderNameBlock
        \vspace{\cvHeaderNameTaglineGap}%
        \cvRenderContactBlock
      \end{minipage}%
    }%
  \end{minipage}%
  \endgroup
}

\newcommand{\emptyheader}{\vspace*{\dimexpr\headerheight+0.5em}}

%===============================================================================
% S5. SECTION RENDERING
%===============================================================================

\newcommand{\sectionIcon}[1]{%
  \HideFromText{%
    \raisebox{\sectionIconRaise}[0pt][0pt]{\sectionIconStyle{#1}}%
  }%
}

% \section[icon]{Title} -- mainbar section (\Large)
\renewcommand{\section}[2][]{%
  \par
  \ifcvFirstSection\vspace{0pt}\else\vspace{\sectionPreskip}\fi
  \noindent\leavevmode
  \begingroup
  \ifstrequal{#1}{}{}{%
    \makebox[\sectionIconWidth][c]{\sectionIcon{#1}}\hspace{\sectionIconSep}}%
  {\color{heading}\Large\bfseries\headingfont\sectionTitleStrut
    \addfontfeature{LetterSpace=-\cvSectionLetterSpace}%
    \AccText{\MakeUppercase{#2}}{#2}}\par
  \endgroup
  \nointerlineskip
  \vspace{\sectionAfterTitle}%
  {\color{heading}\rule{\linewidth}{\sectionRuleThick}\par}%
  \vspace{\sectionAfterRule}%
  \cvFirstSectionfalse
}

% \sidebarSection[icon]{Title} -- sidebar section (\large)
\newcommand{\sidebarSection}[2][]{%
  \par
  \ifcvFirstSection\vspace{0pt}\else\vspace{\sidebarSectionPreskip}\fi
  \noindent\leavevmode
  \begingroup
  \ifstrequal{#1}{}{}{%
    \makebox[\sectionIconWidth][c]{\sectionIcon{#1}}\hspace{\sectionIconSep}}%
  {\fontsize{14pt}{14pt}\bfseries\headingfont\sectionTitleStrut\color{heading}
    \addfontfeature{LetterSpace=-\cvSidebarSectionLetterSpace}
    \AccText{\MakeUppercase{#2}}{#2}\par
  }
  \endgroup
  \nointerlineskip
  \vspace{\sidebarSectionAfterTitle}%
  {\color{heading}\rule{\linewidth}{\sectionRuleThick}\par}%
  \vspace{\sidebarSectionAfterRule}%
  \cvFirstSectionfalse
}

%===============================================================================
% S6. SIDEBAR COMPONENTS
%===============================================================================

% --- Sidebar section heading ---
\newcommand{\cvSideSection}[2][]{%
  \par\addvspace{0.2em}%
  {\fontsize{12pt}{14pt}\headingfont\bfseries\color{accent}
    \ifstrequal{#1}{}{}{\raisebox{0.05ex}{\small\HideFromText{#1}}\hspace{0.2em}}%
    #2\par}%
  \nointerlineskip\vspace{0.4em}%
  {\color{accent!40}\hrule height 0.8pt}
  \par
  \vspace{0.6em}%
}


% --- Skill entries ---
% #1 = skill name, #2 = level (1–5)
% ATS strategy: skill name is plain text (readable as-is). AccSupp needs real
% glyphs to anchor ActualText — kerns/spaces are invisible to pdftotext.
% We render a zero-width period (\rlap) in the sidebar background color as the
% anchor glyph, preceded by ~ (non-breaking space) for ATS word separation.
% Total added width: one interword space (same as original layout).
\newcommand{\cvSkill}[2]{%
  \cvResolveSkillLevel{#2}%
  \par\noindent
  \begin{minipage}[t]{\linewidth}
    \textbf{\color{accent}#1}%
    ~\AccText{\rlap{\textcolor{highlightbarcolor}{.}}}{(\cvSkillLevelLabel)}%
    \hfill \mbox{\cvBar{#2}}
  \end{minipage}\par
  \vspace{0.3em}%
}

% Spoken language with CEFR-oriented ATS labels (same bar UI as \cvSkill).
% #1 = language name, #2 = level (1–5)
\newcommand{\cvLang}[2]{%
  \cvResolveLangLevel{#2}%
  \par\noindent
  \begin{minipage}[t]{\linewidth}
    \textbf{\color{accent}#1}%
    ~\AccText{\rlap{\textcolor{highlightbarcolor}{.}}}{(\cvSkillLevelLabel)}%
    \hfill \mbox{\cvBar{#2}}
  \end{minipage}\par
  \vspace{0.3em}%
}

% #1 = skill name, #2 = level (1–5), #3 = description
\newcommand{\cvSkillDetail}[3]{%
  \cvResolveSkillLevel{#2}%
  \par\noindent
  \begin{minipage}[t]{\linewidth}
    \textbf{\color{accent}#1}%
    ~\AccText{\rlap{\textcolor{highlightbarcolor}{.}}}{(\cvSkillLevelLabel)}%
    \hfill \mbox{\cvBar{#2}}\par
    \vspace{0.1em}
    {\lightfont\small\color{mediumgray}\raggedright #3\par}
  \end{minipage}\par
  \vspace{0.5em}%
}


% --- Skill bar palette ---
\newcommand{\cvSkillColorBgSpec}{highlight!10}
\newcommand{\cvSkillColorFillSpec}{highlight!60}
\newcommand{\cvSkillColorTipFullSpec}{highlight!30}
\newcommand{\cvSkillColorTipPartSpec}{highlight!15}
\newcommand{\cvSetSkillPalette}[4]{%
  \renewcommand{\cvSkillColorBgSpec}{#1}%
  \renewcommand{\cvSkillColorFillSpec}{#2}%
  \renewcommand{\cvSkillColorTipFullSpec}{#3}%
  \renewcommand{\cvSkillColorTipPartSpec}{#4}%
}
\newcommand{\SetSkillColors}{%
  \colorlet{skillBg}{\cvSkillColorBgSpec}
  \colorlet{skillFill}{\cvSkillColorFillSpec}
  \colorlet{skillTipFull}{\cvSkillColorTipFullSpec}
  \colorlet{skillTipPart}{\cvSkillColorTipPartSpec}
}


% --- Bar style switch ---
\newcommand{\cvSkillBarStyle}{segmented}
\newif\ifcvSkillBarSegmented
\cvSkillBarSegmentedtrue


\newcommand{\cvUseSkillBarStyle}[1]{%
  \def\cvSkillBarStyle{#1}%
  \ifstrequal{#1}{segmented}{%
    \cvSkillBarSegmentedtrue
  }{%
    \cvSkillBarSegmentedfalse
    \ifstrequal{#1}{classic}{}{%
      \cvwarn{Unknown skill-bar style '#1'. Falling back to 'classic'.}%
      \def\cvSkillBarStyle{classic}%
    }
  }%
}

\newcommand{\cvBar}[1]{%
  \ifcvSkillBarSegmented
    \cvBarSegmented{#1}%
  \else
    \cvBarClassic{#1}%
  \fi
}

% --- Classic bar variant ---
\newcommand{\cvBarClassic}[1]{%
  \SetSkillColors
  \begin{tikzpicture}[x=1mm, y=1pt, baseline=-0.3ex]
    \fill[skillBg, rounded corners=\skillBarR] (0,0) rectangle (\skillBarW, \skillBarH);
    \begin{scope}
      \clip[rounded corners=\skillBarR] (0,0) rectangle (\skillBarW, \skillBarH);
      \fill[skillFill] (0,0) rectangle ({\skillBarW*#1/5}, \skillBarH);
      \shade[left color=skillFill, right color=skillTipFull]
        ({\skillBarW*#1/5*0.75}, 0) rectangle ({\skillBarW*#1/5}, \skillBarH);
    \end{scope}
  \end{tikzpicture}%
}

% --- Segmented bar variant ---
\newcommand{\cvBarSegmented}[1]{%
  \SetSkillColors%
  \begin{tikzpicture}[x=1mm, y=1pt, baseline=-0.3ex]%
    % 1) Background track
    \fill[skillBg, rounded corners=\skillBarR] (0,0) rectangle (\skillBarW, \skillBarH);%
    \begin{scope}%
      \clip[rounded corners=\skillBarR] (0,0) rectangle (\skillBarW, \skillBarH);%
      % 2) Geometry
      \pgfmathsetmacro{\segW}{\skillBarW/5}%
      \pgfmathsetmacro{\filledW}{\segW*(#1)}%
      % 3) Fade sizing
      \pgfmathsetmacro{\fadeWmax}{0.35*\segW}%
      \pgfmathsetmacro{\fadeW}{min(\fadeWmax, 0.40*\filledW)}%
      \pgfmathsetmacro{\solidW}{max(0,\filledW-\fadeW)}%
      % 4) Fill + tip/fade
      \ifnum#1>0\relax%
      \ifnum#1=5\relax%
      \fill[skillFill] (0,0) rectangle (\skillBarW, \skillBarH);%
      \shade[left color=skillFill, right color=skillTipFull] ({\skillBarW-\fadeW},0) rectangle (\skillBarW,\skillBarH);%
      \else%
      \fill[skillFill] (0,0) rectangle (\solidW, \skillBarH);%
      \shade[left color=skillFill, right color=skillTipPart] (\solidW,0) rectangle (\filledW,\skillBarH);%
      \fi%
      \fi%
      % 5) Segment separators (only in solid region)
      \pgfmathtruncatemacro{\nsep}{max(0,#1-1)}%
      \ifnum\nsep>0\relax%
      \foreach \i in {1,...,\nsep}{%
        \pgfmathsetmacro{\xsep}{\segW*\i}%
        \pgfmathtruncatemacro{\doDraw}{(\xsep < \solidW) ? 1 : 0}%
        \ifnum\doDraw=1\relax%
        \shade[left color=skillFill, right color=highlight, opacity=\skillSepOpacity] ({\xsep-\skillSepW/2},0) rectangle ({\xsep+\skillSepW/2},\skillBarH);%
        \fi%
      }%
      \fi%
    \end{scope}%
  \end{tikzpicture}%
}%


% --- Tags and pills ---
\newcommand{\cvDrawTag}[3]{%
  \tikz[baseline=(X.base)] {%
    \node[
      fill=#2,
      text=#3,
      inner ysep=3.5pt,
      inner xsep=6pt,
      rounded corners=4pt,
      font=\sffamily\footnotesize\bfseries,
      anchor=base
    ] (X) {#1};
  }%
  \hspace{1.5pt}%
}
\newcommand{\cvProcessTagList}[3]{%
  \renewcommand*{\do}[1]{\cvDrawTag{##1}{#2}{#3}\allowbreak}%
  \docsvlist{#1}%
}
\newcommand{\cvJobTags}[1]{\cvProcessTagList{#1}{highlight!15}{highlight}}

\newcommand{\cvSkillTags}[1]{\cvProcessTagList{#1}{highlight!15}{highlight}}
\newenvironment{cvTagCloud}{\raggedright\linespread{1.4}\selectfont}{\par}

% --- Certificates ---
\newcommand{\certBullet}{%
  \tikz[baseline=-0.5ex]\fill[accent] (0,0) circle (0.28ex);%
}

\newcommand{\cert}[2]{%
  {\footnotesize\par\noindent
    \hspace*{0.5em}%
    \hangindent=\dimexpr\skillIndent+\certBulletWidth\relax
    \hangafter=1
    \makebox[\certBulletWidth][l]{\certBullet\hspace{0.0em}}%
    \textbf{\color{accent}#1}{\addfontfeature{RawFeature={-calt}}:} #2\par}%
  \vspace{0.25em}%
}

%===============================================================================
% S7. MAINBAR COMPONENTS
%===============================================================================

% --- Meta line helpers (date/location rendering for overview entries) ---
\newif\ifcvLocationSplit
\cvLocationSplitfalse

\newcolumntype{L}{>{\RaggedRight\arraybackslash}X}
\newcolumntype{R}[1]{>{\arraybackslash}p{#1}}
\newcommand{\cvMetaStyle}{\small\lightfont\color{mediumgray}\strut}

% Meta line renderers: icon (hidden from ATS) + visible text with ATS layer.
% #1 = icon, #2 = ATS label prefix (e.g. \cvLabelDate), #3 = visual, #4 = ATS plain text.
% Match \cvContactLine pattern: icon in its own box, then AccDate
% wraps only the inline date text — no enclosing \makebox[\linewidth].
% Fixed-width boxes break AccSupp BDC/EMC spans in xdvipdfmx.
\newcommand{\cvMetaLineSplitAcc}[4]{%
  {\cvMetaStyle
    \noindent
    \makebox[\cvMetaIconWidth][c]{\HideFromText{#1}}%
    \hspace{\cvMetaGap}\hfill
    \AccDate{#3}{#2#4}%
  }%
}

\newcommand{\cvMetaLineCompactAcc}[4]{%
  {\cvMetaStyle
    \noindent
    \makebox[\cvMetaIconWidth][c]{\HideFromText{#1}}%
    \hspace{\cvMetaGap}%
    \AccDate{#3}{#2#4}%
  }%
}

\newcommand{\cvMetaLineAcc}[4]{%
  \ifcvLocationSplit
    \cvMetaLineSplitAcc{#1}{#2}{#3}{#4}%
  \else
    \cvMetaLineCompactAcc{#1}{#2}{#3}{#4}%
  \fi
}

% --- Overview entries ---
% Date parsing (xstring + \@for) must happen OUTSIDE tabularx.
% tabularx trial measurements run in internal vertical mode where
% \spacefactor-based commands (\@for) fail.
\newcommand{\cvOverviewEntryBuilder}[7]{%
  \par
  \begingroup
  \cvDateParse{#4}%
  \global\let\cvDateVisResult\cvDateVisTmp
  \global\let\cvDatePlainResult\cvDatePlainTmp
  \endgroup
  \noindent
  \begin{tabularx}{\linewidth}{@{} L @{\hspace{\cvColGap}} R{#7} @{}}
    {%
      \vspace{0pt}%
      {\large\headingfont\bfseries\color{accent}\strut #2}\par
      \vspace{\cvInternalRowSpacing}%
      {\normalsize\color{highlight}\bfseries\strut #3}%
    }
    &
    {%
      \vspace{0pt}%
      \cvMetaLineAcc{#1}{\cvLabelDate}{\cvDateVisResult}{\cvDatePlainResult}\par
      \vspace{\cvInternalRowSpacing}%
      \cvMetaLineAcc{\faMapMarker*}{\cvLabelLocation}{#5}{#5}%
    }
  \end{tabularx}%
  \par
  \ifstrequal{#6}{}{}{%
    \vspace{\cvHighlightSpacing}%
    {\small\color{accent!70}\lightfont\itshape\noindent #6\par}%
  }%
  \par\vspace{\cvEntrySpacing}%
}

\NewDocumentCommand{\cvJobOverview}{ m m m m O{} }{%
  \cvAssertNonEmpty{#1}{\string\cvJobOverview company is empty}{Provide a non-empty company/institution value.}%
  \cvAssertNonEmpty{#2}{\string\cvJobOverview role is empty}{Provide a non-empty role/title value.}%
  \cvAssertNonEmpty{#3}{\string\cvJobOverview date is empty}{Provide a non-empty date range value.}%
  \cvAssertNonEmpty{#4}{\string\cvJobOverview location is empty}{Provide a non-empty location value.}%
  \cvOverviewEntryBuilder{\faCalendarCheck[regular]}{#1}{#2}{#3}{#4}{#5}{\cvJobDateWidth}%
}

\NewDocumentCommand{\cvEduOverview}{ m m m m O{} }{%
  \cvAssertNonEmpty{#1}{\string\cvEduOverview institution is empty}{Provide a non-empty institution value.}%
  \cvAssertNonEmpty{#2}{\string\cvEduOverview degree is empty}{Provide a non-empty degree value.}%
  \cvAssertNonEmpty{#3}{\string\cvEduOverview date is empty}{Provide a non-empty date range value.}%
  \cvAssertNonEmpty{#4}{\string\cvEduOverview location is empty}{Provide a non-empty location value.}%
  \cvOverviewEntryBuilder{\faGraduationCap}{#1}{#2}{#3}{#4}{#5}{\cvEduDateWidth}%
}

% --- Detailed job / experience entries ---
\newcommand{\cvDetailItem}[2]{\item \textbf{#1} #2}

% Horizontal rule for full-width portfolio pages (between \cvExpDetail blocks).
\newcommand{\cvDivider}{%
  \par\vspace{0.025cm}%
  \noindent{\color{black}\rule{\linewidth}{0.5pt}}%
  \par\vspace{0.025cm}%
}

\newlength{\cvJobDetailEmptySpacing} \setlength{\cvJobDetailEmptySpacing}{5mm}

%===============================================================================
% Detail builders (layout only — validation is in public wrappers)
% #1 = context/company, #2 = title/role, #3 = date,
% #4 = meta icon (e.g. \faMapMarker*), #5 = meta text, #6 = bullets, #7 = tags
%===============================================================================
\newcommand{\cvDetailBuilder}[7]{%
  \par
  \addvspace{0.8em}%
  \noindent
  {\color{accent}\large\headingfont\bfseries #2}\hfill
  {\color{mediumgray}\small
    \makebox[\cvMetaIconWidth][c]{\HideFromText{\faCalendarCheck[regular]}}%
    \hspace{\cvMetaGap}\cvDateFmtAcc{#3}%
  }%
  \par\vspace{0.4em}%
  {\lightfont\color{body}\large #1}%
  \ifstrempty{#5}{}{%
    \hfill{\color{mediumgray}\small
      \ifstrempty{#4}{}{%
        \makebox[\cvMetaIconWidth][c]{\HideFromText{#4}}%
        \hspace{\cvMetaGap}%
      }%
      #5%
    }%
  }%
  \par\vspace{\cvJobDetailDescSpacing}%
  \ifstrempty{#6}{%
    \cvwarn{Detail block has an empty bullet list for '#1'.}%
  }{%
    {\fontsize{9}{13}\selectfont
      \begin{itemize}[
        leftmargin=*, labelsep=0.4em, nosep, itemsep=1.5pt,
        label={\color{highlight}\raisebox{0.5ex}{\HideFromText{\scalebox{0.25}{\faCircle}}}}
      ]
        #6
      \end{itemize}
    }%
  }%
  \ifstrequal{#7}{}{%
  % No tags: smaller spacing after the block
  \par\vspace{\cvJobDetailEmptySpacing}%
}{%
  % Tags present: tag spacing, then tags, then general spacing
  \par\vspace{\cvJobDetailTagSpacing}%
  {\raggedright\linespread{1.3}\selectfont\noindent\ignorespaces #7\par}%
  \par\vspace{\cvJobDetailGeneralSpacing}%
}%
}%

\newcommand{\cvJobDetailBuilder}[6]{%
  \cvDetailBuilder{#1}{#2}{#3}{\faMapMarker*}{#4}{#5}{#6}%
}


\NewDocumentCommand{\cvJobDetail}{ m m m m +m O{}}{%
  \cvAssertNonEmpty{#1}{\string\cvJobDetail company is empty}{Provide a non-empty company value.}%
  \cvAssertNonEmpty{#2}{\string\cvJobDetail role is empty}{Provide a non-empty role value.}%
  \cvAssertNonEmpty{#3}{\string\cvJobDetail date is empty}{Provide a non-empty date value.}%
  \cvAssertNonEmpty{#4}{\string\cvJobDetail location is empty}{Provide a non-empty location value.}%
  \cvJobDetailBuilder{#1}{#2}{#3}{#4}{#5}{#6}%
}

% Portfolio / project detail (full-width pages).
% \cvExpDetail{context}{title}{date}[icon]{meta}{bullets}[tags]
%   icon — optional FA glyph (hidden from ATS via \HideFromText)
%   meta — plain text / URL / repo path (no icons here)
\NewDocumentCommand{\cvExpDetail}{ m m m O{} m +m O{}}{%
  \cvAssertNonEmpty{#1}{\string\cvExpDetail context is empty}{Provide a non-empty context/category value.}%
  \cvAssertNonEmpty{#2}{\string\cvExpDetail title is empty}{Provide a non-empty title value.}%
  \cvAssertNonEmpty{#3}{\string\cvExpDetail date is empty}{Provide a non-empty date value.}%
  \cvDetailBuilder{#1}{#2}{#3}{#4}{#5}{#6}{#7}%
}



%===============================================================================
% END OF FILE
%===============================================================================
\debug{components_cv.cls loaded}
