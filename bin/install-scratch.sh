#!/bin/bash
SCRIPT_PATH=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
cd $SCRIPT_PATH/..

ORG_ALIAS="AG-Kurs"


echo ""
echo "Installing crm-arbeidsgiver- scratch org ($ORG_ALIAS)"
echo ""

echo "Cleaning previous scratch org..."
sfdx force:org:delete -p -u $ORG_ALIAS &> /dev/null
echo ""

echo "Creating scratch org..." && \
sfdx force:org:create -s -f config/project-scratch-def.json -d 7 -a $ORG_ALIAS && \
echo "" && \

echo "Installing dependencies..."
secret=$(jq '.PACKAGE_KEY' env.json -r)
keys="" && for p in $(jq '.packageAliases | keys[]' sfdx-project.json -r); do keys+=$p":"$secret" "; done 
sfdx sfpowerkit:package:dependencies:install -u $ORG_ALIAS -r -a -w 60 -k "${keys}"
echo ""

echo "Assigning permissions..."
sfdx force:user:permset:assign -n Course_Admin
echo ""

echo "Pushing metadata..."
sfdx force:source:push
echo ""

echo "Inserting test data..."
sfdx force:data:tree:import -p  dummy-data/courses/plan.json
echo ""


echo "Opening org..." && \
sfdx force:org:open
echo ""


EXIT_CODE="$?"
echo ""

# Check exit code
echo ""
if [ "$EXIT_CODE" -eq 0 ]; then
  echo "Installation completed."
else
    echo "Installation failed."
fi
exit $EXIT_CODE
