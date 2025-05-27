@echo off
setlocal

echo ▶ Looking up the Guest User…
SET "GUEST_USER_ID="

FOR /F "skip=1 tokens=*" %%i IN (
  'sf data query --query "SELECT Id FROM User WHERE Name='Kurs Site Guest User' LIMIT 1" --result-format csv 2^>NUL'
) DO (
    SET "GUEST_USER_ID=%%i"
)

REM Check if the Guest User ID was successfully retrieved.
IF "%GUEST_USER_ID%"=="" (
  echo ⚠️  No user named 'Kurs Site Guest User' found in the current org. >&2
  echo    Please ensure the user exists and the 'sf' CLI is authenticated and configured correctly. >&2
  endlocal
  exit /b 1
)
echo    Found Guest User Id: %GUEST_USER_ID%

echo ▶ Looking up the Permission Set…
SET "PERMSET_ID="
REM Execute the Salesforce CLI command to find the Permission Set ID.
FOR /F "skip=1 tokens=*" %%i IN (
  'sf data query --query "SELECT Id FROM PermissionSet WHERE Label='Ekstern - Kurs' LIMIT 1" --result-format csv 2^>NUL'
) DO (
    SET "PERMSET_ID=%%i"
)

REM Check if the Permission Set ID was successfully retrieved.
IF "%PERMSET_ID%"=="" (
  echo ⚠️  No Permission Set with label 'Ekstern - Kurs' found in the current org. >&2
  echo    Please ensure the permission set exists and the 'sf' CLI is authenticated and configured correctly. >&2
  endlocal
  exit /b 1
)
echo    Found Permission Set Id: %PERMSET_ID%

echo ▶ Assigning Permission Set to Guest User…
REM Execute the Salesforce CLI command to assign the permission set.
sf data create record --sobject PermissionSetAssignment --values "AssigneeId=%GUEST_USER_ID% PermissionSetId=%PERMSET_ID%"

REM Check the exit code of the 'sf data create record' command.
REM ERRORLEVEL 1 means the command failed (exit code 1 or higher).
IF ERRORLEVEL 1 (
  echo ⚠️  Failed to assign Permission Set 'Ekstern - Kurs' to 'Kurs Site Guest User'. >&2
  echo    Check the output from the 'sf' command above for more details. >&2
  endlocal
  exit /b 1
)

echo ✅ Done: ‘Ekstern – Kurs’ assigned to ‘Kurs Site Guest User’.

endlocal
exit /b 0
