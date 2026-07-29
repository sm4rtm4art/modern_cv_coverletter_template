%% Start of file `main_cover_letter.cls'.
%===============================================================================
% Cover Letter class (based on Awesome-CV by Claud D. Park).
%
% Provides: Cover letter layout, header, footer, recipient block, letter body.
% Depends on: shared_adjustment.cls (fonts, colors, logging),
%             defaults_coverletter.cls (geometry, spacing, locale).
% Used by: MOCK_Bewerbungsanschreiben.tex, MOCK_cover_letter.tex
%
% Configurable from .tex:
%   - Colors : \definecolor{highlight}{HTML}{...}, \colorlet{sectiondivider}{...}
%   - Fonts  : Handled centrally by shared_adjustment.cls
%   - Body   : \setLetterBodySpread{1.2} for line spacing
%
% Architecture:
%   1. Identification & options    5. Colors (from shared palette)
%   2. Packages                    6. Fonts & styles
%   3. Warning filters & hyperref  7. Personal information commands
%   3b. Shared design tokens       8. Header, footer, sections
%   4. Layout                      9. Cover letter commands
%
% Class license: LPPL v1.3c (http://www.latex-project.org/lppl)
%===============================================================================


%-------------------------------------------------------------------------------
%  1. IDENTIFICATION & OPTIONS
%-------------------------------------------------------------------------------
\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{main_cover_letter}[2026/02/12 v4.0 Cover Letter class]



\RequirePackage{ifthen}

% Debug mode: enables verbose output for troubleshooting
\newboolean{@debugmode}
\setboolean{@debugmode}{false}
\DeclareOption{debug}{\setboolean{@debugmode}{true}}

% Options for draft or final
\DeclareOption{draft}{\setlength\overfullrule{5pt}}
\DeclareOption{final}{\setlength\overfullrule{0pt}}

% Inherit options of article
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{article}}
\ProcessOptions\relax
\LoadClass{article}


% Unified logging helpers (same API as CV class).
\newcommand{\coverLetterLog}[1]{\typeout{[COVERLETTER-INFO] #1}}
\newcommand{\coverLetterInfo}[1]{\typeout{[COVERLETTER-INFO] #1}}
\newcommand{\debug}[1]{%
  \ifthenelse{\boolean{@debugmode}}{\typeout{[COVERLETTER-DEBUG] #1}}{}%
}
\newcommand{\coverLetterWarn}[1]{\ClassWarning{main_cover_letter}{#1}}
\newcommand{\coverLetterError}[2]{\ClassError{main_cover_letter}{#1}{#2}}
\let\letterDebug\debug


%-------------------------------------------------------------------------------
%  2. PACKAGES
%-------------------------------------------------------------------------------

% Package loader with explicit debug/error traces.
\newcommand{\coverletterRequirePackage}[2][]{%
  \debug{Package load requested: #2 (options='#1')}%
  \IfFileExists{#2.sty}{%
    \ifthenelse{\equal{#1}{}}{\RequirePackage{#2}}{\RequirePackage[#1]{#2}}%
    \debug{Package loaded: #2}%
  }{%
    \coverLetterError{Required package '#2' not found}{%
      Install package '#2' in your TeX distribution and recompile.}%
  }%
}

\coverletterRequirePackage{array}
\coverletterRequirePackage{geometry}
\coverletterRequirePackage{fancyhdr}
\coverletterRequirePackage{xcolor}
\coverletterRequirePackage{ifxetex}
\coverletterRequirePackage{xifthen}
\coverletterRequirePackage{xstring}
\coverletterRequirePackage{etoolbox}
\coverletterRequirePackage{tikz}
\coverletterRequirePackage{calc}
\coverletterRequirePackage{setspace}
\coverletterRequirePackage[quiet]{fontspec}
\defaultfontfeatures{Ligatures=TeX}
\coverletterRequirePackage{unicode-math}
\coverletterRequirePackage{fontawesome5}
\coverletterRequirePackage{parskip}
\coverletterRequirePackage{changepage}
\coverletterRequirePackage{lastpage}
\coverletterRequirePackage{refcount}
%-------------------------------------------------------------------------------
%  3. WARNING FILTERS & HYPERREF
%-------------------------------------------------------------------------------
\coverletterRequirePackage{silence}
\WarningFilter{hyperref}{Token not allowed in a PDF string}
\WarningFilter{hyperref}{Option `colorlinks' has already been used}

\coverletterRequirePackage[hidelinks,unicode,pdfpagelabels=false,colorlinks=true]{hyperref}
\hypersetup{%
  pdftitle={},
  pdfauthor={},
  pdfsubject={},
  pdfkeywords={},
  linkcolor=black,
  urlcolor=black,
  citecolor=black
}
\coverletterRequirePackage{bookmark}


% Prefer TEXINPUTS / cwd. Fallbacks: ../../../ then ../../ (see main_cv.cls).
\newcommand{\coverletterLoadModule}[1]{%
  \IfFileExists{#1.cls}{%
    \coverLetterLog{Loading module: #1.cls}%
    \input{#1.cls}%
    \debug{Loaded module: #1.cls}%
  }{%
    \IfFileExists{../../../common/cls/cover_letter/#1.cls}{%
      \coverLetterLog{Loading coverletter module (../../../): #1.cls}%
      \input{../../../common/cls/cover_letter/#1.cls}%
    }{%
      \IfFileExists{../../common/cls/cover_letter/#1.cls}{%
        \coverLetterLog{Loading coverletter module (../../): #1.cls}%
        \input{../../common/cls/cover_letter/#1.cls}%
      }{%
        \IfFileExists{../../../common/cls/shared_cls/#1.cls}{%
          \coverLetterLog{Loading shared module (../../../): #1.cls}%
          \input{../../../common/cls/shared_cls/#1.cls}%
        }{%
          \IfFileExists{../../common/cls/shared_cls/#1.cls}{%
            \coverLetterLog{Loading shared module (../../): #1.cls}%
            \input{../../common/cls/shared_cls/#1.cls}%
          }{%
            \coverLetterError{Module '#1' not found}{%
              File '#1.cls' not found via TEXINPUTS or relative\MessageBreak
              ../../ / ../../../ common/cls/{cover_letter,shared_cls}/.\MessageBreak
              Prefer latexmk (template .latexmkrc stub → common/latexmk/).
            }%
          }%
        }%
      }%
    }%
  }%
}

% 3. The execution loop
\newcommand{\coverletterLoadAllModules}[1]{%
  \@for\next:=#1\do{%
    \coverletterLoadModule{\next}%
  }%
}


%%% ----- Execution -----
\debug{Starting module load sequence: TEMP_defaults_coverletter,shared_adjustment}
\coverletterLoadAllModules{defaults_coverletter,adjustment,ats}
\makeatletter % restore after modules that may have changed @ catcode
% Route shared \cvwarn/\cverror (used by ats.cls) through cover-letter panels.
\let\cvwarn\coverLetterWarn
\renewcommand{\cverror}[2]{\coverLetterError{#1}{#2}}%
\debug{Completed module load sequence}


%-------------------------------------------------------------------------------
%  4. LAYOUT
%-------------------------------------------------------------------------------

\geometry{
  left=\letterMarginLeft,
  top=\dimexpr\letterMarginTop+\letterFollowingPageTopExtra\relax,
  right=\letterMarginRight,
  bottom=\letterMarginBottom,
  footskip=\letterFootskip
}

\fancyhfoffset{0em}
\renewcommand{\headrulewidth}{0pt}
\fancyhf{}
\pagestyle{fancy}



%-------------------------------------------------------------------------------
%  5. COLORS (derived from shared_adjustment.cls unified palette)
%-------------------------------------------------------------------------------
% Cover-letter semantic colors mapped from shared palette.
% Override highlight, heading, body in .tex to customize.
\colorlet{darktext}{mediumgray}
\colorlet{text}{darkgray}
\colorlet{lighttext}{lightgray}
\colorlet{sectiondivider}{gray}

% Section color highlighting toggle:
%   true  = first 3 chars of section headings get highlight color
%   false = section headings are plain text color
\newbool{letterSectionColorHighlight}
\setbool{letterSectionColorHighlight}{true}

\def\@sectioncolor#1#2#3{%
  \ifbool{letterSectionColorHighlight}{{\color{highlight}#1#2#3}}{#1#2#3}%
}


%-------------------------------------------------------------------------------
%  6. FONTS & STYLES (fonts from shared_adjustment.cls)
%-------------------------------------------------------------------------------
% Font family shortcuts (derived from shared_adjustment.cls \headingfont / \sffamily).
\newcommand*{\headerfont}{\headingfont}
\newcommand*{\footerfont}{\sffamily}
\newcommand*{\bodyfont}{\sffamily}

%-------------------------------------------------------------------------------
%  STYLE DEFINITIONS (Apple Design Update)
%-------------------------------------------------------------------------------

% 1. NAME: Big, Bold, Highlight Color, SF Pro (headingfont)
% Note: We use the same style for first and last name now.
\newcommand*{\headerNameStyle}[1]{
  {\fontsize{24pt}{28pt}\selectfont\headingfont\bfseries\color{text}\textls[10] {#1}}
  }

% 2. POSITION: Medium, Gray, Regular weight
\newcommand*{\headerPositionStyle}[1]{
  {\fontsize{12pt}{15pt}\selectfont\lightfont\bfseries\color{highlight}\textls[10] {#1}}
  }

% 3. ADDRESS & META: Small, Gray (Matches the Socials)
\newcommand*{\headerAddressStyle}[1]{
  {\fontsize{11pt}{13pt}\selectfont\headingfont\color{lighttext}\textls[10] {#1}}
  }

% 4. SOCIALS: Small, Gray, Specific Line Height
\newcommand*{\headerSocialStyle}[1]{
  {\fontsize{9pt}{11pt}\selectfont\headingfont\color{lighttext} #1}
  }

% 5. ICONS: Tiny bit smaller than text, raised for alignment
\newcommand*{\headerIconStyle}[1]{
  {\fontsize{8pt}{2em}\selectfont\headerfont\color{lighttext}\raisebox{0pt}{#1}}
  }

% 6. Footer: Defines the footer
\newcommand*{\footerstyle}[1]{
  {\fontsize{8pt}{1em}\footerfont\scshape\color{lighttext} #1}
  }

% 7.  Currently not in use
\newcommand*{\sectionstyle}[1]{
  {\fontsize{16pt}{1em}\bodyfont\bfseries\color{text}\@sectioncolor #1}
  }

% 8. Currently not in use
\newcommand*{\subsectionstyle}[1]{{\fontsize{12pt}{1em}\bodyfont\scshape\textcolor{text}{#1}}}

% Letter styles

% 9. Letter title / Subject line
\newcommand*{\letterTitleStyle}[1]{
  {\fontsize{12pt}{10pt}\lightfont\bfseries\color{highlight}\textls[10] {#1}}}


% 10. Letter section / Subject line (space costly ! % \lettersection{title})
\newcommand*{\lettersectionstyle}[1]{
  {\fontsize{14pt}{1em}\bodyfont\bfseries\color{text}\@sectioncolor #1}
  }

% 11. Datestyle defines the date style of the cover_letter
\newcommand*{\letterDateStyle}[1]{
  {\fontsize{10pt}{1em}\lightfont\color{darktext} #1}
  }


% 11. Textstyle
\newcommand*{\letterTextStyle}{
  \fontsize{11pt}{14pt}\lightfont\upshape\color{text}
  }

\newcommand*{\letterOpeningStyle}{
  \fontsize{11pt}{14pt}\lightfont\color{text}
  }


% 12. Namestyle defines the the Header Name style of the cover_letter
\newcommand*{\letterNameStyle}[1]{
  {\fontsize{12pt}{1em}\headerfont\bfseries\color{darktext}\textls[10] {#1}}}

% 13. Enclosurestyle defines the the Enclosure style of the cover_letter
\newcommand*{\letterenClosureStyle}[1]{
  \fontsize{11pt}{14pt}\lightfont\upshape\color{text}
  }

% 14. Recipienttitlestyle defines the the Recipient title style of the cover_letter
\newcommand*{\recipientTitleStyle}[1]{{
  \fontsize{11pt}{14pt}\bodyfont\bfseries\color{darktext} #1}}

% 15. recipientNamestyle defines the the Recipient name style of the cover_letter
\newcommand*{\recipientNamestyle}[1]{{
  \fontsize{10pt}{12pt}\headerfont\color{lighttext} #1}}

% 16. recipientAddressStyle defines the the Recipient address style of the cover_letter
\newcommand*{\recipientAddressStyle}[1]{
  {\fontsize{10pt}{12pt}\headerfont\color{lighttext} #1}}


%-------------------------------------------------------------------------------
%  7. PERSONAL INFORMATION COMMANDS
%-------------------------------------------------------------------------------
% When a setter is used, its value must be non-empty (omit the command entirely
% to hide that header row). \namePrefix and \position may stay empty/optional.

% Name: \name{Max Mustermann}
\newcommand*{\name}[1]{%
  \cvAssertNonEmpty{#1}{\string\name{} is empty}{Provide a non-empty name.}%
  \def\@name{#1}%
}

% Name prefix/title: \namePrefix{Dr.} (default: empty)
\newcommand*{\namePrefix}[1]{\def\@namePrefix{#1}}
\def\@namePrefix{} % default

% 1. The Logic (Public Command)
\newcommand*{\fullname}{%
	\ifx\@namePrefix\@empty\else\@namePrefix\space\fi
	\@name%
}\def\@fullname{\fullname}


% Contact info (single-line address API — not the CV 4-part \address)
\newcommand*{\address}[1]{%
  \cvAssertNonEmpty{#1}{\string\address{} is empty}{Provide a non-empty address line, or omit \string\address.}%
  \def\@address{#1}%
}
\newcommand*{\position}[1]{\def\@position{#1}}% optional subtitle under the name
\newcommand*{\phone}[1]{%
  \cvAssertNonEmpty{#1}{\string\phone{} is empty}{Provide a non-empty phone number, or omit \string\phone.}%
  \def\@phone{#1}%
}
\newcommand*{\email}[1]{%
  \cvAssertNonEmpty{#1}{\string\email{} is empty}{Provide a non-empty email address, or omit \string\email.}%
  \def\@email{#1}%
}


\newcommand*{\github}[1]{%
  \cvAssertNonEmpty{#1}{\string\github{} is empty}{Provide a username or URL, or omit \string\github.}%
  \def\@github{#1}%
  \IfBeginWith{#1}{http}{%
    \def\@githuburl{#1}%
  }{%
    \IfSubStr{#1}{github.com}{
    	\def\@githuburl{https://#1}
    	}
    	{\def\@githuburl{https://github.com/#1}}%
  }%
}
% \linkedin{display-name}{url} — unified 2-arg API (same as CV).
\newcommand*{\linkedin}[2]{%
  \cvAssertNonEmpty{#1}{\string\linkedin{} label is empty}{Provide a non-empty display label.}%
  \cvAssertNonEmpty{#2}{\string\linkedin{} URL/handle is empty}{Provide a URL or profile handle.}%
  \def\@linkedin{#1}%
  \IfBeginWith{#2}{http}{%
    \def\@linkedinurl{#2}%
  }{%
    \IfSubStr{#2}{linkedin.com}{%
      \def\@linkedinurl{https://#2}%
    }{%
      \IfSubStr{#2}{ }{%
        \def\@linkedinurl{https://www.linkedin.com/}%
      }{%
        \def\@linkedinurl{https://www.linkedin.com/in/#2}%
      }%
    }%
  }%
}

% Recipient info — optional color: \recipientCompany[highlight]
\newcommand*{\recipientCompany}[2][]{%
  \cvAssertNonEmpty{#2}{\string\recipientCompany{} is empty}{Provide a non-empty company name.}%
  \def\@recipientCompanyplain{#2}%
  \ifblank{#1}{%
    \def\@recipientCompany{#2}%
  }{%
    \def\@recipientCompany{\textcolor{#1}{#2}}%
  }%
}

% Recipient info (cover letter)
\newcommand*{\recipientName}[1]{\def\@recipientName{#1}}
\newcommand*{\recipientStreet}[1]{\def\@recipientStreet{#1}}
\newcommand*{\recipientCity}[1]{\def\@recipientCity{#1}}

% Public accessors for reuse in letter body text.
%\newcommand*{\thecompany}{\@recipientCompanyplain}


% Letter metadata — optional color: \letterTitle[black]{Bewerbung: ...}
\newcommand*{\letterTitle}[3][]{%
  \ifblank{#1}{%
    \def\@letterTitle{ #3}%
  }{%
    \def\@letterTitle{\textcolor{#1}{#2} #3}%
  }%
}
\newcommand*{\letterDate}[1]{\def\@letterDate{#1}}
\newcommand*{\letterOpening}[1]{\def\@letterOpening{#1}}
\newcommand*{\letterclosing}[1]{\def\@letterclosing{#1}}
\newcommand*{\letterenclname}[1][Enclosure]{\def\@letterenclname{#1}}
\newcommand*{\letterenclosure}[2][]{%
  \ifthenelse{\equal{#1}{}}{}{\def\@letterenclname{#1}}
  \def\@letterenclosure{#2}
}



%-------------------------------------------------------------------------------
%  8. HEADER, FOOTER, SECTIONS
%-------------------------------------------------------------------------------

% Utility commands
\newcolumntype{L}[1]{>{
  \raggedright\let\newline\\\arraybackslash\hspace{0pt}}m{#1}
  }

%\newcolumntype{C}[1]{>{
%  \centering\let\newline\\\arraybackslash\hspace{0pt}}m{#1}
%  }

\newcolumntype{R}[1]{>{
  \raggedleft\let\newline\\\arraybackslash\hspace{0pt}}m{#1}
  }
\def\vhrulefill#1{\leavevmode\leaders\hrule\@height#1\hfill \kern\z@
}

\newcommand*{\ifempty}[3]{\ifthenelse{\isempty{#1}}{#2}{#3}}


% ===============================================================================
%   HEADER LOGIC
%===============================================================================

\newif\ifInvertedHeader\InvertedHeaderfalse % Default: Normal

%\colorlet{linecolor}{highlight}

% 2. INTERNAL HELPERS (Local definitions to avoid conflicts)

% A fixed-width box for icons to prevent wobbling
\newcommand{\headerIconBox}[1]{%
  \makebox[\headerIconhSpacing][c]{%

    \headerIconStyle{\raisebox{1pt}{#1}}%
  }%
}

% Combines Icon with Social links
\newcommand{\drawSocialItem}[3]{%
\mbox{% Keeps the icon and text on the same line (no breaks)
  \href{#1}{%
    \headerIconBox{\HideFromText{#2}}%
    \hspace{\headerIconhSpacing}%
    %
    % Render the actual text label
    \headerSocialStyle #3%
  }%
}\par\vspace{\headerSocialSpacing}% Adds vertical breathing room between rows
}


\newcommand{\buildName}[2]{%
  \mbox{%
    \ifdefined\@namePrefix
    \ifx\@namePrefix\@empty
    \else\@namePrefix\ \fi
    \fi
    \MakeUppercase{#1}%
  }%
}

\newcommand{\buildPosition}[1]{%
  \mbox{#1}%
}

\newlength{\headerNameLineHeight}
\newlength{\headerSocialLineHeight}
\newlength{\headerSocialVShift}


\newcommand{\computeHeaderVShift}{%
  \settoheight{\headerNameLineHeight}{\hbox{\headerNameStyle{X}}}%
  \settoheight{\headerSocialLineHeight}{\hbox{{\headerSocialStyle X}}}%
  \setlength{\headerSocialVShift}{%
    \dimexpr\headerNameLineHeight-\headerSocialLineHeight\relax
  }%
}

\newcommand{\drawNameSection}{%
  \begin{minipage}[t]{\headerNameWidth}
    \vspace*{0pt}% important for true top-align
    \sloppy
    \setlength{\parskip}{0pt}%
    \ifInvertedHeader \raggedleft \else \raggedright \fi
    \headerNameStyle{\buildName{\@name}{\@namePrefix}}%
    \par\nointerlineskip\vspace{\headerNameSpace}%
		% Position
		\ifthenelse{\isundefined{\@position}}{}{%
			\headerPositionStyle{\buildPosition{\@position}}%
			\par\nointerlineskip\vspace{\headerPositionSpace}%
		}%
		% Address
		\ifthenelse{\isundefined{\@address}}{}{%
		\hspace{0.5em}%
    \headerIconBox{\faMapMarker*}%
			\hspace{\headerAddressIconSpacing}%
		  {\headerAddressStyle{\@address}}%
      \par\nointerlineskip\vspace{\headerLineSpace}%
		}%
	\end{minipage}%
}

%

% Right Side: Socials
\newcommand{\drawSocialSection}{%
  % Vertical Alignment Adjustment:
  % Shifts the entire block vertically so that the baseline of the first social item
  % aligns perfectly with the baseline of the Name on the left side.
  % Uses \dimexpr to calculate the negative shift based on pre-calculated heights.
  \raisebox{\dimexpr-\headerSocialVShift-\headerSocialYOffset\relax}{%
    %
    % Container: Use minipage to reserve a specific width for the block
    \begin{minipage}[t]{\headerContactWidth}
      \vspace*{0pt}% Trick to force the minipage to align from the very top baseline
      \setlength{\parskip}{0pt}% Remove extra paragraph spacing inside the box

      % Layout Logic:
      % Switch alignment based on the header configuration ([L] or [R]).
      \ifInvertedHeader \raggedright \else \raggedleft \fi

      % Conditional Rendering (Builder Pattern):
      % Only render the row if the corresponding data variable is defined.
      \ifthenelse{\isundefined{\@phone}}{}{%
        \drawSocialItem{tel:\@phone}{\faPhone}{\@phone}
      }%
      \ifthenelse{\isundefined{\@email}}{}{%
        \drawSocialItem{mailto:\@email}{\faEnvelope}{\@email}
      }%
      \ifthenelse{\isundefined{\@linkedin}}{}{%
        \drawSocialItem{\@linkedinurl}{\faLinkedin}{\@linkedin}
      }%
      \ifthenelse{\isundefined{\@github}}{}{%
        \drawSocialItem{\@githuburl}{\faGithub}{\@github}
      }%
    \end{minipage}%
  }%
}

% 3. MAIN ASSEMBLY (Accepts [L] or [R])
\newcommand*{\makeLetterHeader}[1][L]{%
	\vspace*{\headerHeight}
	\noindent
  \computeHeaderVShift
	% LOGIC: Check argument. If R, set Inverted flag to true.
	\ifthenelse{\equal{#1}{R}}{%
		\InvertedHeadertrue
		% Draw Socials LEFT, Name RIGHT
		\drawSocialSection%
		\hfill%
		\drawNameSection%
	}{%
		\InvertedHeaderfalse
		% Draw Name LEFT, Socials RIGHT (Standard)
		\drawNameSection%
		\hfill%
		\drawSocialSection%
	}%
	% Divider Line
  \drawFadingLine

	%\vspace{\headerNameSpace}
	% \par\noindent
	%\makebox[\textwidth][c]{%
	%	\textcolor{mediumgray}{\rule{\textwidth}{\headerLineThickness}}
  %}
}


\newcommand{\drawFadingLine}{%
  \par\noindent%
  \begin{tikzpicture}[baseline]
    % Wichtig: useasboundingbox verhindert vertikales Springen
    \useasboundingbox (0,0) rectangle (\textwidth, 2pt);
    % Der Verlauf: Weiß -> Grau -> Weiß
    \fill[left color=white, right color=white, middle color=mediumgray]
      (0,0) rectangle (\textwidth, 0.5pt);
  \end{tikzpicture}%
  \vspace{1em}%
}


%-------------------------------------------------------------------------------
%  FOOTER
%-------------------------------------------------------------------------------

% --- Footer ---
% \makeLetterFooter{left}{center}{right}
%   right = {} defaults to \fullname on single-page, page counter on multi-page.

\newcommand*{\letterApplyLocale}{%
  \def\letterPageWord{\letterPageWordDe}%
  \def\letterOfWord{\letterOfWordDe}%
  \ifstrequal{\letterLocale}{en}{%
    \def\letterPageWord{\letterPageWordEn}%
    \def\letterOfWord{\letterOfWordEn}%
  }{%
    \ifstrequal{\letterLocale}{de}{%
      \def\letterPageWord{\letterPageWordDe}%
      \def\letterOfWord{\letterOfWordDe}%
    }{%
      \@ifpackageloaded{babel}{%
        \iflanguage{english}{%
          \def\letterPageWord{\letterPageWordEn}%
          \def\letterOfWord{\letterOfWordEn}%
        }{}%
      }{}%
    }%
  }%
}


\newcommand*{\makeLetterFooter}[3]{%
  \letterApplyLocale
  \edef\letterLastPageNumber{\number\getpagerefnumber{LastPage}}%
  % If R is empty, default to full name on page 1.
  \def\letterFirstPageRight{#3}%
  \ifthenelse{\equal{#3}{}}{%
    \def\letterFirstPageRight{\@fullname}%
  }{}%
  \ifnum\letterLastPageNumber>1\relax
    \def\letterFirstPageRight{\letterPageWord~\thepage~\letterOfWord~\pageref*{LastPage}}%
  \fi
  % First page footer.
  \fancypagestyle{letterfirstpage}{%
    \fancyhf{}
    \renewcommand{\headrulewidth}{0pt}
    \fancyfoot[L]{\footerstyle{#1}}
    \fancyfoot[C]{\footerstyle{#2}}
    \fancyfoot[R]{\footerstyle{\letterFirstPageRight}}
  }
  % Following pages footer (page counter).
  \fancypagestyle{letterfollowing}{%
    \fancyhf{}
    \renewcommand{\headrulewidth}{0pt}
    \fancyfoot[L]{\footerstyle{#1}}
    \fancyfoot[C]{\footerstyle{#2}}
    \fancyfoot[R]{\footerstyle{\letterPageWord~\thepage~\letterOfWord~\pageref*{LastPage}}}
  }
  \pagestyle{letterfollowing}%
  \thispagestyle{letterfirstpage}%
}


%-------------------------------------------------------------------------------
%  9. COVER LETTER COMMANDS
%-------------------------------------------------------------------------------

% Letter body line spacing (set in .tex: \setLetterBodySpread{1.2}).
\providecommand{\letterBodySpread}{1.0}
\newcommand{\setLetterBodySpread}[1]{\renewcommand{\letterBodySpread}{#1}}

% Letter body environment with line spacing and slight indentation.
\newenvironment{cover_letter}{%
  \letterTextStyle
  \linespread{\letterBodySpread}\selectfont
  %\raggedright
  \begin{adjustwidth}{0.1cm}{0.15cm}
}{%
  \end{adjustwidth}
}

% \lettersection{title}
\newcommand{\lettersection}[1]{%
  \par\addvspace{2.5ex}
  \phantomsection{}
  \lettersectionstyle{#1}
  \color{sectiondivider}\vhrulefill{0.9pt}
  \par\nobreak\addvspace{0.4ex}
  \letterTextStyle
}

\newlength{\recipientBottomSkip}
\setlength{\recipientBottomSkip}{5mm}


\newcommand{\letterRecipientBlockBuilder}[5]{%
  \vspace*{\recipientTopSkip}%
  \noindent
  \begin{minipage}[t]{\dimexpr\textwidth-\letterDateWidth\relax}
    \vspace*{0pt}%
    \recipientTitleStyle{#1}\par
    \vspace{\recipientAdressSkip}%
    \begin{singlespace}
      \recipientNamestyle{\hspace*{\recipientIndent}#3}\par
      \vspace{\recipientLineGap}%
      \recipientAddressStyle{\hspace*{\recipientIndent}#4}\par
      \vspace{\recipientLineGap}%
      \recipientAddressStyle{\hspace*{\recipientIndent}#5}\par
    \end{singlespace}
  \end{minipage}%
  \hfill
  \begin{minipage}[t]{\letterDateWidth}
    \vspace*{0pt}%
    \raggedleft\letterDateStyle{#2}\par
  \end{minipage}%
  \par
  \vspace{\recipientBottomSkip}%
}


\newcommand{\letterTitleBlockBuilder}[2]{%
  % #1 Title can be empty, #2 opening
  \ifthenelse{\equal{#1}{}}{}{%
    \vspace{\openingSpaceAbove}%
    \noindent\letterTitleStyle{#1}\par
  }%
  \vspace{\openingSpaceAbove}%
  \hspace*{\letterOpeningIndent}\noindent\letterOpeningStyle{#2}\par
  \vspace{\openingSpaceBelow}%
}


\newcommand*{\makeletterTitle}{%
  \ifthenelse{\isundefined{\@recipientCompany}}{%
    \ClassError{main_cover_letter}{Missing \string\recipientCompany}{Set \string\recipientCompany before \string\makeletterTitle.}%
  }{}%
  \ifthenelse{\isundefined{\@letterDate}}{%
    \ClassError{main_cover_letter}{Missing \string\letterDate}{Set \string\letterDate before \string\makeletterTitle.}%
  }{}%
  \ifthenelse{\isundefined{\@letterOpening}}{%
    \ClassError{main_cover_letter}{Missing \string\letterOpening}{Set \string\letterOpening before \string\makeletterTitle.}%
  }{}%

  % Recipientblock (left) + date (right)
  \letterRecipientBlockBuilder
    {\@recipientCompany}
    {\@letterDate}
    {\@recipientName}
    {\@recipientStreet}
    {\@recipientCity}

  % Titie optional
  \ifthenelse{\isundefined{\@letterTitle}}{%
    \letterTitleBlockBuilder{}{\@letterOpening}%
  }{%
    \letterTitleBlockBuilder{\@letterTitle}{\@letterOpening}%
  }%
}%


% \makeLetterClosing — renders closing, name, and optional enclosure
%   Adjust \letterClosingSkip and \letterNameSkip in .tex to control spacing.



\newcommand{\drawLetterClosing}{%
  \par
  \vspace*{\letterClosingSkipV}%

  \noindent %
  \hspace*{\letterClosingSkipH}%
  \begin{minipage}[t]{\dimexpr\textwidth-\letterClosingSkipH\relax}
      % Reset Layout inside of the box
      \setlength{\parindent}{0pt}%
      \setlength{\parskip}{0pt}%
      \raggedright

      % CLosing
      \letterTextStyle{\@letterclosing}\par

      \vspace*{\letterClosingNameSkipV}%
      % Set full name
      \hspace*{\letterClosingNameSkipH}\letterNameStyle{\fullname}\par
  \end{minipage}

  % Attachments
  \ifthenelse{\isundefined{\@letterenclosure}}{}{%
    \par
    \vspace{1mm}%
    \hspace*{\letterClosingSkipH}
    \letterenClosureStyle{\@letterenclname:\@letterenclosure}%
  }%
}

\newcommand*{\makeLetterClosing}{%
  % 1. Checks for opening
  \ifthenelse{\isundefined{\@letterclosing}}{%
    \ClassError{main_cover_letter}{Missing \string\letterclosing}{%
      Set \string\letterclosing{...} in your tex file before calling \string\makeLetterClosing.}%
  }{}%

  % 2. calls builder
  \drawLetterClosing
}

%-------------------------------------------------------------------------------
%  Class loaded
%-------------------------------------------------------------------------------
\letterDebug{main_cover_letter.cls loaded successfully.}
