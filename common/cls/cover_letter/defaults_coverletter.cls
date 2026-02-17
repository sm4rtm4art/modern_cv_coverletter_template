%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%=
% defaults_coverletter.cls
% Cover-letter-specific configuration (geometry, spacing, footer locale).
%
% Provides: Page geometry, header spacing, footer locale words.
% Depends on: shared_adjustment.cls (fonts, colors, logging — loaded separately).
% Used by: main_cover_letter.cls (loaded early, before packages)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%=

%-------------------------------------------------------------------------------
% Page geometry defaults
%-------------------------------------------------------------------------------
\providecommand{\letterMarginLeft}{1.5cm}
\providecommand{\letterMarginTop}{1.0cm}
\providecommand{\letterMarginRight}{1.5cm}
\providecommand{\letterMarginBottom}{1.0cm}
\providecommand{\letterFootskip}{0.55cm}
% Extra top offset for continuation pages (page 2+).
\providecommand{\letterFollowingPageTopExtra}{3mm}

%-------------------------------------------------------------------------------
% Letter body defaults
%-------------------------------------------------------------------------------

\providecommand{\letterBodySpread}{1.0}


%-------------------------------------------------------------------------------
% Footer behavior defaults
%-------------------------------------------------------------------------------
% Locale: auto (detect via babel), de, or en.
\providecommand{\letterLocale}{auto}
\providecommand{\letterPageWordDe}{Seite}
\providecommand{\letterOfWordDe}{von}
\providecommand{\letterPageWordEn}{Page}
\providecommand{\letterOfWordEn}{of}

%-------------------------------------------------------------------------------
% Header spacing defaults
%-------------------------------------------------------------------------------
% \providecommand{\letterHeaderNameDelim}{\space}
% \providecommand{\letterHeaderAfterNameSkip}{1.2mm}
% \providecommand{\letterHeaderAfterPositionSkip}{1mm}
% \providecommand{\letterHeaderAfterAddressSkip}{-0.5mm}
% \providecommand{\letterHeaderIconSep}{\space}
% \providecommand{\letterHeaderSocialSep}{\quad\textbar\quad}
% \providecommand{\letterHeaderAfterSocialSkip}{6mm}


%-------------------------------------------------------------------------------
%  HEADER CONFIGURATION
%-------------------------------------------------------------------------------


\newlength{\headerHeight}
\setlength{\headerHeight}{0cm}

\newlength{\headerNameWidth}
\setlength{\headerNameWidth}{0.64\textwidth}

\newlength{\headerContactWidth}
\setlength{\headerContactWidth}{0.32\textwidth}

\newlength{\headerNameSpace}
\setlength{\headerNameSpace}{4.5mm}

\newlength{\headerPositionSpace}
\setlength{\headerPositionSpace}{0.75em}

\newlength{\headerAddressIconSpacing}
\setlength{\headerAddressIconSpacing}{0.3em}

\newlength{\headerSocialSpacing}
\setlength{\headerSocialSpacing}{-0.2mm}

\newlength{\headerContactOffset}
\setlength{\headerContactOffset}{0mm}

\newlength{\headerSocialtOffset}
\setlength{\headerSocialtOffset}{5em} % invisible Box ofset of social side

\newlength{\headerSocialYOffset}
\setlength{\headerSocialYOffset}{-0.4em} % vertical offset of social side

\newlength{\headerIconhSpacing}
\setlength{\headerIconhSpacing}{0.3em}

\newlength{\headerIconVOffset}
\setlength{\headerIconVOffset}{0em}

\newlength{\headerLineThickness}
\setlength{\headerLineThickness}{0.5pt}

\newlength{\headerLineSpace}
\setlength{\headerLineSpace}{2mm}


%-------------------------------------------------------------------------------
% RECIPIANT CONFIGURATION
%-------------------------------------------------------------------------------


\newlength{\letterDateWidth}
\setlength{\letterDateWidth}{4.5cm}

\newlength{\recipientIndent}
\setlength{\recipientIndent}{0mm}

\newlength{\recipientTopSkip}
\setlength{\recipientTopSkip}{5mm}

\newlength{\recipientAdressSkip}
\setlength{\recipientAdressSkip}{2mm}

\newlength{\recipientLineGap}
\setlength{\recipientLineGap}{0.4mm}



%-------------------------------------------------------------------------------
% Opening CONFICS
%-------------------------------------------------------------------------------


\newlength{\openingSpaceAbove}
\setlength{\openingSpaceAbove}{3mm}

\newlength{\openingSpaceBelow}
\setlength{\openingSpaceBelow}{1mm}

\newlength{\letterOpeningIndent}
\setlength{\letterOpeningIndent}{1mm}

%-------------------------------------------------------------------------------
% CLOSING CONFICS
%-------------------------------------------------------------------------------


\newlength{\letterClosingSkipV}
\setlength{\letterClosingSkipV}{1mm}

\newlength{\letterClosingNameSkipV}
\setlength{\letterClosingNameSkipV}{5mm}

\newlength{\letterClosingSkipH}
\setlength{\letterClosingSkipH}{10mm}

\newlength{\letterClosingNameSkipH}
\setlength{\letterClosingNameSkipH}{15mm}
