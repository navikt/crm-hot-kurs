#!/bin/bash

echo "Oppretter scratch org"
sf org create scratch --definition-file config/project-scratch-def.json --alias "$1" --duration-days "$2" --set-default --json --wait 30

echo "Installerer crm-platform-base ver. 0.218"
sf package install --package 04t7U000000Y3esQAC --no-prompt --installation-key "$3" --wait 30 --publish-wait 30

echo "Installerer crm-platform-access-control ver. 0.125"
sf package install --package 04t7U000000Y3V7QAK --no-prompt --installation-key "$3" --wait 30 --publish-wait 30

echo "Installerer crm-platform-reporting ver. 0.37"
sf package install --package 04t7U000000Y2VoQAK --no-prompt --installation-key "$3" --wait 30 --publish-wait 30

echo "Installerer crm-shared-base ver. 1.1"
sf package install --package 04t2o000000ySqpAAE --no-prompt --installation-key "$3" --wait 30 --publish-wait 30

echo "Installerer crm-thread-view ver. 0.2"
sf package install --package 04t7U000000TqvIQAS --no-prompt --installation-key "$3" --wait 30 --publish-wait 30

echo "Installerer crm-shared-timeline ver. 1.22"
sf package install --package 04t7U000000Y2OEQA0 --no-prompt --installation-key "$3" --wait 30 --publish-wait 30

echo "Installerer crm-shared-flowComponents ver. 0.4"
sf package install --package 04t7U0000008qz4QAA --no-prompt --installation-key "$3" --wait 30 --publish-wait 30

echo "Installerer crm-henvendelse-base ver. 0.18"
sf package install --package 04t7U000000LPPAQA4 --no-prompt --installation-key "$3" --wait 30 --publish-wait 30

echo "Installerer crm-platform-integration ver. 0.110"
sf package install --package 04t7U000000Y3pWQAS --no-prompt --installation-key "$3" --wait 30 --publish-wait 30

echo "Installerer crm-journal-utilities ver. 0.28"
sf package install --package 04t7U000000Y3iGQAS --no-prompt --installation-key "$3" --wait 30 --publish-wait 30

echo "Installerer crm-platform-oppgave ver. 0.53"
sf package install --package 04t7U000000Y3r3QAC --no-prompt --installation-key "$3" --wait 30 --publish-wait 30

echo "Installerer crm-arbeidsgiver-base ver. 1.411"
sf package install --package 04t7U000000Y3qFQAS --no-prompt --installation-key "$3" --wait 30 --publish-wait 30

echo "Installerer crm-community-base ver. 0.102"
sf package install --package 04t7U000000Y3eTQAS --no-prompt --installation-key "$3" --wait 30 --publish-wait 30

echo "Installerer crm-platform-email-scheduling ver. 1.7"
sf package install --package 04t7U000000Y2bXQAS --no-prompt --installation-key "$3" --wait 30 --publish-wait 30

echo "Dytter kildekoden til scratch org'en"
sf project deploy start

echo "Tildeler tilatelsessett til brukeren"
sf org assign permset --name Kurs_Salesforce_Admin

echo "Tildeler tilatelsessett til brukeren"
sf org assign permset --name Course_Admin

echo "Publish Experience Site"
sf community publish --name Kurs

echo "Kjører assignGuestUserPerm.sh…"
bash "$(dirname "$0")/assignGuestUserPerm.sh"

#Trenger dette for at course registration skal fungere.
echo "Oppretter EncryptionKey"
sf data create record \
  --sobject EncryptionKey__c \
  --values "Name='encryptionKey' Value__c='FkU94SvM4cn0jBhYXkgb9dLuFSh3+qtoVWmuW/0elB8='"

echo "Ferdig"
