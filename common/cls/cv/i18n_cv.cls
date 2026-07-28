%===============================================================================
% i18n_cv.cls
% Localized UI strings used by CV layout/components.
%
% Provides: \cvSetLanguage, localized labels for ATS, footer page words.
% Depends on: shared_adjustment.cls (logging).
% Used by: components_cv.cls (ATS labels), layout_cv.cls (footer page words)
%===============================================================================

\debug{Loading i18n_cv.cls}

\newcommand{\cvLanguage}{de}

\newcommand{\cvSetLanguage}[1]{%
  \def\cvLanguage{#1}%
  \ifstrequal{#1}{en}{%
    \def\cvLabelName{Name: }%
    \def\cvLabelDate{Date: }%
    \def\cvLabelLocation{Location: }%
    \def\cvLabelAddress{Address: }%
    \def\cvLabelStreet{Street: }%
    \def\cvLabelCity{City: }%
    \def\cvLabelZip{Zip: }%
    \def\cvLabelCountry{Country: }%
    \def\cvLabelPhone{Phone: }%
    \def\cvLabelEmail{Email: }%
    \def\cvLabelLinkedIn{LinkedIn: }%
    \def\cvLabelGitHub{GitHub: }%
    \def\cvLabelHomepage{Homepage: }%
    \def\cvLabelOrcid{ORCID: }%
    \def\cvLabelAds{ADS: }%
    \def\cvPageWord{Page}%
    \def\cvOfWord{of}%
    \def\cvPresentWord{Present}%
    \def\cvSkillLevelI{Basic}%
    \def\cvSkillLevelII{Intermediate}%
    \def\cvSkillLevelIII{Advanced}%
    \def\cvSkillLevelIV{Proficient}%
    \def\cvSkillLevelV{Expert}%
    \def\cvLangLevelI{Basic (A1-A2)}%
    \def\cvLangLevelII{Conversational (B1)}%
    \def\cvLangLevelIII{Fluent (B2)}%
    \def\cvLangLevelIV{Business Fluent (C1)}%
    \def\cvLangLevelV{Native / Bilingual (C2)}%
  }{%
    \ifstrequal{#1}{de}{}{%
      \cvwarn{Unknown language '#1'. Falling back to German ('de').}%
      \def\cvLanguage{de}%
    }%
    \def\cvLabelName{Name: }%
    \def\cvLabelDate{Datum: }%
    \def\cvLabelLocation{Ort: }%
    \def\cvLabelAddress{Adresse: }%
    \def\cvLabelStreet{Straße: }%
    \def\cvLabelCity{Stadt: }%
    \def\cvLabelZip{PLZ: }%
    \def\cvLabelCountry{Land: }%
    \def\cvLabelPhone{Telefon: }%
    \def\cvLabelEmail{E-Mail: }%
    \def\cvLabelLinkedIn{LinkedIn: }%
    \def\cvLabelGitHub{GitHub: }%
    \def\cvLabelHomepage{Webseite: }%
    \def\cvLabelOrcid{ORCID: }%
    \def\cvLabelAds{ADS: }%
    \def\cvPageWord{Seite}%
    \def\cvOfWord{von}%
    \def\cvPresentWord{Aktuell}%
    \def\cvSkillLevelI{Grundlagen}%
    \def\cvSkillLevelII{Erweitert}%
    \def\cvSkillLevelIII{Fortgeschritten}%
    \def\cvSkillLevelIV{Vertieft}%
    \def\cvSkillLevelV{Experte}%
    \def\cvLangLevelI{Grundkenntnisse (A1-A2)}%
    \def\cvLangLevelII{Konversationssicher (B1)}%
    \def\cvLangLevelIII{Fließend (B2)}%
    \def\cvLangLevelIV{Verhandlungssicher (C1)}%
    \def\cvLangLevelV{Muttersprache / Zweisprachig (C2)}%
  }%
}

% Default language: German
\cvSetLanguage{de}

\debug{i18n_cv.cls loaded (default language=\cvLanguage)}
