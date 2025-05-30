echo "Oppretter scratch org"
call sf org create scratch --definition-file config\project-scratch-def.json --alias %1 --duration-days %2 --set-default --json --wait 30

echo "Installerer crm-platform-base ver. 0.270"
call sf package install --package 04tQC000000kpU9YAI --no-prompt --installation-key %3 --wait 30 --publish-wait 30

echo "Installerer crm-platform-access-control ver. 0.160"
call sf package install --package 04tKB000000YBLfYAO --no-prompt --installation-key %3 --wait 30 --publish-wait 30

echo "Installerer crm-platform-reporting ver. 0.41"
call sf package install --package 04tKB000000YAWDYA4 --no-prompt --installation-key %3 --wait 30 --publish-wait 30

echo "Installerer crm-shared-base ver. 1.1"
call sf package install --package 04t2o000000ySqpAAE --no-prompt --installation-key %3 --wait 30 --publish-wait 30

echo "Installerer crm-thread-view ver. 0.6"
call sf package install --package 04tKB000000YEDVYA4 --no-prompt --installation-key %3 --wait 30 --publish-wait 30

echo "Installerer crm-shared-timeline ver. 1.32"
call sf package install --package 04tQC000000kTYTYA2 --no-prompt --installation-key %3 --wait 30 --publish-wait 30

echo "Installerer crm-shared-flowComponents ver. 0.4"
call sf package install --package 04t7U0000008qz4QAA --no-prompt --installation-key %3 --wait 30 --publish-wait 30

echo "Installerer crm-henvendelse-base ver. 0.31"
call sf package install --package 04tKB000000Y9AdYAK --no-prompt --installation-key %3 --wait 30 --publish-wait 30

echo "Installerer crm-platform-integration ver. 0.155"
call sf package install --package 04tQC000000lBhZYAU --no-prompt --installation-key %3 --wait 30 --publish-wait 30

echo "Installerer crm-journal-utilities ver. 0.43"
call sf package install --package 04tKB000000Y9WtYAK --no-prompt --installation-key %3 --wait 30 --publish-wait 30

echo "Installerer crm-platform-oppgave ver. 0.64"
call sf package install --package 04tKB000000YB09YAG --no-prompt --installation-key %3 --wait 30 --publish-wait 30

echo "Installerer crm-arbeidsgiver-base ver. 1.561"
call sf package install --package 04tQC000000kCSnYAM --no-prompt --installation-key %3 --wait 30 --publish-wait 30

echo "Installerer crm-community-base ver. 0.121"
call sf package install --package 04tQC000000ieEfYAI --no-prompt --installation-key %3 --wait 30 --publish-wait 30

echo "Installerer crm-platform-email-scheduling ver. 1.7"
call sf package install --package 04t7U000000Y2bXQAS --no-prompt --installation-key %3 --wait 30 --publish-wait 30

echo "Dytter kildekoden til scratch org'en"
call sf project deploy start

echo "Tildeler tilatelsessett til brukeren"
call sf org assign permset --name Kurs_Salesforce_Admin

echo "Publish Experience Site"
call sf community publish --name Kurs

@echo off
echo Kjører assignGuestUserPerm.bat...
call "%~dp0assignGuestUserPerm.bat"

REM Trenger dette for at course registration skal fungere.
echo Oppretter EncryptionKey
sf data create record ^
  --sobject EncryptionKey__c ^
  --values "Name='encryptionKey' Value__c='FkU94SvM4cn0jBhYXkgb9dLuFSh3+qtoVWmuW/0elB8='"


echo "Ferdig"
