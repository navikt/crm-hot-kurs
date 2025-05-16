#!/usr/bin/env bash
set -euo pipefail

echo "▶ Looking up the Guest User…"
GUEST_USER_ID=$(sf data query \
  --query "SELECT Id FROM User WHERE Name='Kurs Site Guest User' LIMIT 1" \
  --result-format csv \
  | tail -n +2)

if [[ -z "$GUEST_USER_ID" ]]; then
  echo "⚠️  No user named 'Kurs Site Guest User' found in the current org." >&2
  exit 1
fi
echo "   Found Guest User Id: $GUEST_USER_ID"

echo "▶ Looking up the Permission Set…"
PERMSET_ID=$(sf data query \
  --query "SELECT Id FROM PermissionSet WHERE Label='Ekstern - Kurs' LIMIT 1" \
  --result-format csv \
  | tail -n +2)

if [[ -z "$PERMSET_ID" ]]; then
  echo "⚠️  No Permission Set with label 'Ekstern - Kurs' found in the current org." >&2
  exit 1
fi
echo "   Found Permission Set Id: $PERMSET_ID"

echo "▶ Assigning Permission Set to Guest User…"
sf data create record \
  --sobject PermissionSetAssignment \
  --values "AssigneeId=$GUEST_USER_ID PermissionSetId=$PERMSET_ID"

echo "✅ Done: ‘Ekstern – Kurs’ assigned to ‘Kurs Site Guest User’."
