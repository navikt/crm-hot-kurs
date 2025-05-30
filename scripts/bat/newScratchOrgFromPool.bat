echo "Hent scratch org fra pool"
call sfp pool fetch --tag dev --targetdevhubusername %2 --alias %1 --setdefaultusername
call timeout /t 30

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
