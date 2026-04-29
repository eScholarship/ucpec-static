#!/usr/bin/env bash
# frozen_string_literal: true

# Deploys the output/ folder to S3

# Usage:
#   ./deploy.sh --profile <aws-profile>                   # dry run
#   ./deploy.sh --profile <aws-profile> --execute         # perform the actual sync
#   ./deploy.sh --profile <aws-profile> --env stg --execute

# Syncs:
#   output/  -> s3://ucpec/<env>/ucpressebooks/

set -euo pipefail

BUCKET="ucpec"
PROFILE=""
ENV="stg"
DRY_RUN=true

while [[ $# -gt 0 ]]; do
  case $1 in
    --execute)   DRY_RUN=false ;;
    --env)       ENV="$2"; shift ;;
    --profile)   PROFILE="$2"; shift ;;
    *)           echo "Unknown option: $1"; exit 1 ;;
  esac
  shift
done

if [[ -z "$PROFILE" ]]; then
  echo "Error: --profile <aws-profile> is required"
  exit 1
fi

OUTPUT_DIR="$(cd "$(dirname "$0")/output" && pwd)"

if [[ ! -d "$OUTPUT_DIR" ]]; then
  echo "Error: output/ directory not found at $OUTPUT_DIR"
  echo "Run the generation scripts first."
  exit 1
fi

S3_BASE="s3://${BUCKET}/${ENV}/ucpressebooks"

SYNC_ARGS=(
  --profile "$PROFILE"
  --delete
  --exclude ".DS_Store"
)

if $DRY_RUN; then
  SYNC_ARGS+=(--dryrun)
  echo "=== DRY RUN — pass --execute to deploy ==="
fi

echo "Environment : $ENV"
echo "Bucket      : $BUCKET"
echo "Profile     : $PROFILE"
echo ""

echo "Syncing output/ ..."
aws s3 sync "${OUTPUT_DIR}/" "${S3_BASE}/" "${SYNC_ARGS[@]}"

echo ""
if $DRY_RUN; then
  echo "Dry run complete. Run with --execute to deploy."
else
  echo "Deploy complete -> ${S3_BASE}/"
fi
