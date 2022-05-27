# crm-arbeidsgiver-community

[![Build](https://github.com/navikt/crm-arbeidsgiver-community/workflows/master/badge.svg)](https://github.com/navikt/crm-arbeidsgiver-community/actions?query=workflow%3ABuild)
[![GitHub version](https://badgen.net/github/release/navikt/crm-arbeidsgiver-community/stable)](https://github.com/navikt/crm-arbeidsgiver-community)
[![MIT License](https://img.shields.io/apm/l/atomic-design-ui.svg?)](https://github.com/navikt/crm-arbeidsgiver-community/blob/master/LICENSE)
[![codecov](https://codecov.io/gh/navikt/crm-arbeidsgiver-community/branch/master/graph/badge.svg)](https://codecov.io/gh/navikt/crm-arbeidsgiver-community)

Repo for Salesforce communities som blir brukt i sammenheng med PO Arbeidsgiver.

## Dependencies

Pakken er avhengig av følgende pakker:

-   [crm-platform-base](https://github.com/navikt/crm-platform-base) (internal)
-   [crm-platform-access-control](https://github.com/navikt/crm-platform-access-control) (internal)
-   [crm-community-base](https://github.com/navikt/crm-community-base) (internal)
-   [crm-arbeidsgiver-base](https://github.com/navikt/crm-arbeidsgiver-base)

## Komme i gang

1. Salesforce DX-bruker. Kontakt #crm-plattform-team på Slack om du ikke har dette
2. Installer Salesforce DX CLI (SFDX)
    - Last ned fra [Salesforce.com](https://developer.salesforce.com/tools/sfdxcli)
    - Eller benytt npm: `npm install sfdx-cli --global`
3. Klon dette repoet ([GitHub Desktop](https://desktop.github.com) anbefales for ikke-utviklere)
4. Installer [SSDX](https://github.com/navikt/ssdx)
    - Med SSDX kan du lage scratch orger og gjøre deklarative endringer (gjøre endringer i nettleseren på Salesforce, altså ikke-utvikling)
    - **Trenger du ikke verktøy utvikling kan du stoppe her**
5. Installer [VS Code](https://code.visualstudio.com) (anbefalt)
6. Installer [Salesforce Extension Pack](https://marketplace.visualstudio.com/items?itemName=salesforce.salesforcedx-vscode)
7. Installer [AdoptOpenJDK](https://adoptopenjdk.net) (kun versjon 8 eller 11)
8. Åpne VS Code Settings og søk etter `salesforcedx-vscode-apex`
9. Under `Java Home`, legg inn følgende:
    - macOS: `/Library/Java/JavaVirtualMachines/adoptopenjdk-11.jdk/Contents/Home`
    - Windows: `C:\\Program Files\\AdoptOpenJDK\\jdk-11.0.3.7-hotspot` (merk at versjonsnummer kan endre seg)

## Bygg

For å bygge lokalt uten SSDX, bruk føglende

1. Hvis du ikke har autentisert en DevHub, kjør `sfdx auth:web:login -d -a production` og så logge inn.
2. Installer sfdx plugin `echo y | sfdx plugins:install sfpowerkit@2.0.1`
3. Opprette en fil i prosjekets root directory med navn `env.json`

```
{
    "PACKAGE_KEY": "Your Package Key"
}

```

4. Opprette scratch org, installer avhengigheter og så pushe metadata:

```
npm install
npm run mac:build
```

## Utvikling

Utvikling foregår i hovedsak på to fronter, i nettleseren i din scratch org og på din maskin i din prefererte IDE. Ved endringer i nettleseren på din scratch org (som lever i skyen), så må alle endringer pulles til din maskin. Ved endringer av metadata i din IDE, må endringer pushes til din scratch org.

Ved å bruke VS Code som IDE, er det lagt inn konfigurasjon som automatisk pusher endringer av metadata til din scratch org ved lagring. For å pulle endringer fra kan man enten bruke Salesforce DX CLI til å pulle, men også pushe om man ikke ønsker automatisk push. Se under for kommandoer. Man kan også bruke hjelpeverktøyet SSDX (nevnt over) for å pushe, pulle, åpne scratch org-er, slette gamle, blant annet.

-   `sfdx force:org:open` for å åpne instansen(salesforce applikasjonen din).
-   `sfdx force:source:pull` for å hente endringer som du gjør i konfigurasjon i applikasjonen online.
-   `sfdx force:source:push` for å publisere endringer du gjør i kode lokalt til applikasjonen online.

## Annet

For spørsmål om denne applikasjonen, bruk #arbeidsgiver-crm på Slack.
