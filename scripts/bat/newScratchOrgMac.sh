#!/bin/bash

echo "Oppretter scratch org"
sf org create scratch --definition-file config/project-scratch-def.json --alias "$1" --duration-days "$2" --set-default --json --wait 30

echo "Installerer crm-platform-base ver. 0.218"
sf package install --package 04t7U000000Y3esQAC --no-prompt --installation-key "$3" --wait 30 --publish-wait 30

echo "Installerer crm-platform-access-control ver. 0.125"
sf package install --package 04t7U000000Y3V7QAK --no-prompt --installation-key "$3" --wait 30 --publish-wait 30

echo "Installerer crm-community-base ver. 0.102"
sf package install --package 04t7U000000Y3eTQAS --no-prompt --installation-key "$3" --wait 30 --publish-wait 30

echo "Installerer crm-platform-email-scheduling ver. 1.7"
sf package install --package 04t7U000000Y2bXQAS --no-prompt --installation-key "$3" --wait 30 --publish-wait 30

echo "Dytter kildekoden til scratch org'en"
sf project deploy start

echo "Tildeler tilatelsessett til brukeren"
sf org assign permset --name Kurs_Salesforce_Admin

echo "Publish Experience Site"
sf community publish --name Kurs

echo "Ferdig"
